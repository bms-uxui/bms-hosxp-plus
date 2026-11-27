/// ฉากห้องฉุกเฉินสามมิติจริง ทำงานด้วย three.js ใน WebView (Android / iOS)
///
/// โหลด assets/models/er_room.glb ซึ่งมีเตียงเป็น object แยกชื่อ bed_<รหัส>
/// แตะเตียงบนฉากแล้วฝั่ง Dart จะได้รหัสเตียงกลับมา และสั่งให้กล้องแพนไปหา
/// เตียงใดก็ได้ จำนวนเตียงที่แสดงมาจากรายการที่ส่งเข้าไป ไม่ได้ฝังไว้ในฉาก
///
/// ไฟล์ three.js กับ GLTFLoader เก็บไว้ในแอป ไม่ต้องต่อเน็ต โดยเสิร์ฟผ่าน
/// เว็บเซิร์ฟเวอร์เล็ก ๆ ที่เปิดเฉพาะ 127.0.0.1 เพราะ WebView โหลดไฟล์
/// ข้ามโดเมนจาก asset โดยตรงไม่ได้
library;

import 'dart:async';
import '../er_shared/er_web_alive.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import '../er_shared/er_web_frame.dart';

import 'er_room_types.dart';

class ErRoom3D extends StatefulWidget {
  const ErRoom3D({
    super.key,
    required this.beds,
    required this.selectedCode,
    this.cam = const ErCam(),
    this.onBedTap,
    this.onPositions,
    this.onHotspots,
    this.topView = false,
    this.layer = 'skin',
    this.highlight = const [],
    this.dark = false,
    this.pageBg = 0xFFFFFF,
    this.zoom = 1.0,
    this.zoomTick = 0,
    this.pickMode = false,
    this.onBodyPick,
    this.vitals,
    this.waiting = const [],
    this.draw,
    this.drawings = const [],
    this.onDrawStroke,
    this.onDrawErase,
    this.onRegionPick,
    this.regionLines = false,
    this.cloth = true,
    this.instant = false,
    this.onReady,
    this.regionSel,
    this.drawCtl,
  });

  /// โหมดวาดบนตัวหุ่น (studio ภาพการตรวจร่างกาย): null = ปิด
  /// {tool: 'pen'|'eraser', color: '#rrggbb', r: รัศมีเส้นเป็นเมตร}
  final Map<String, Object?>? draw;

  /// เส้นที่วาดไว้แล้ว (พิกัดของหุ่น) แสดงบนหุ่นของเตียงที่เลือก
  /// [{id, color, r, pts: [[x,y,z], ...]}]
  final List<Map<String, Object?>> drawings;

  /// วาดเสร็จหนึ่งเส้น: {id, color, r, bone (กระดูก rig ที่ใกล้สุด), pts}
  final ValueChanged<Map<String, Object?>>? onDrawStroke;

  /// ยางลบลบเส้น id นี้
  final ValueChanged<String>? onDrawErase;

  /// แสดงเส้นแบ่งบริเวณร่างกาย (taxonomy CIS) บนผิวหุ่น
  final bool regionLines;

  /// บริเวณที่เลือก (id แบบ CIS) ระบายฟ้าอ่อนบนหุ่น body map
  final String? regionSel;

  /// true = เปิดเป็นมุมมองรายละเอียดทันที ไม่เล่นกล้องบินจากห้อง
  final bool instant;

  /// ฉากพร้อม (โหลดหน้าแล้ว)
  final VoidCallback? onReady;

  /// false = ถอดเสื้อผ้า (กางเกงขาสั้น/เสื้อกล้าม) เห็นผิวทั้งตัว
  final bool cloth;

  /// โหมด draw tool 'region': แตะบนผิว = บริเวณ (id แบบ CIS body map) + จุดในพิกัดหุ่น
  final void Function(String? region, List<double> pt)? onRegionPick;

  /// สั่งย้อน/ล้าง/ถ่ายภาพฉาก
  final ErRoomDrawCtl? drawCtl;

  /// สัญญาณชีพของเตียงที่เลือก: แสดงบนจอ monitor ติดกำแพงเหนือหัวเตียงในฉาก
  /// {hr, spo2, bp, rr, bt, time, alarms:[...], bad:[...]} · null = ซ่อนจอ
  final Map<String, Object?>? vitals;

  /// ผู้ป่วยที่ยังไม่ได้เตียง: นั่งเก้าอี้แถว/รถเข็นต่อท้ายแถวเตียง
  final List<ErRoomWaiter> waiting;

  final List<ErRoomBed> beds;
  final String selectedCode;
  final ErCam cam;
  final ValueChanged<String>? onBedTap;
  final ValueChanged<List<ErBedScreenPos>>? onPositions;

  /// ตำแหน่งบนจอของจุดสำคัญบนตัวหุ่นของเตียงที่เลือก (หัว แขน ท้อง ข้อเท้า)
  /// ใช้วางเครื่องหมายอาการทับบนฉากตอนมองจากบน
  final ValueChanged<List<ErBedScreenPos>>? onHotspots;

  /// true = กล้องเลื่อนไปมองเตียงที่เลือกจากด้านบน (หน้าข้อมูลผู้ป่วย)
  final bool topView;

  /// ชั้นที่กำลังดู: skin | bone | organ | vessel
  final String layer;

  /// อวัยวะที่ให้เรืองแสงตามอาการ (brain heart lungs liver stomach kidneys
  /// intestine bladder) ว่าง = ไม่เน้น ผิวจะโปร่งเมื่อมีรายการ
  final List<String> highlight;

  /// โหมดสรุปเคส: พื้นมืด หุ่นเอกซเรย์
  final bool dark;

  /// สีพื้นของหน้าตอนมองจากบน (RGB) ให้กลืนกับพื้นหลังของหน้าที่วางฉาก
  final int pageBg;

  /// ระยะกล้องมุมมองรายละเอียด (น้อย = ใกล้) ส่งเมื่อ zoomTick เปลี่ยน
  /// (ผู้ใช้หุบ/กางนิ้วเองได้ ปุ่ม + − จึงสั่งผ่านตัวนับแทนการเทียบค่า)
  final double zoom;
  final int zoomTick;

  /// true = แตะบนตัวหุ่น (มุมมองรายละเอียด) เพื่อระบุตำแหน่ง เช่น ตำแหน่งบาดแผล
  final bool pickMode;

  /// ตำแหน่งที่แตะในโหมด pickMode: ชื่อกระดูก rig ที่ใกล้จุดนั้นที่สุด
  /// (Head Neck Chest Belly Pelvis Collar UpperArm Forearm Palm Hip Shin Foot Toes + .L/.R · Hip = ต้นขา)
  final ValueChanged<String>? onBodyPick;

  @override
  State<ErRoom3D> createState() => _ErRoom3DState();
}

/// สั่งงานโหมดวาดบนหุ่นจากแอป: ย้อน · ล้าง · ถ่ายภาพฉาก (JPEG)
class ErRoomDrawCtl {
  _ErRoom3DState? _s;
  Completer<Uint8List?>? _snap;

  void undo() => _s?._js('window.erDrawUndo && window.erDrawUndo()');
  void clear() => _s?._js('window.erDrawClear && window.erDrawClear()');

  /// ไปมุมมองรายละเอียดทันที (ไม่เล่นกล้องบินจากห้อง)
  void instant() => _s?._js('window.erInstant && window.erInstant()');

  /// ลบเส้น id นี้ออกจากหุ่น
  void erase(String id) =>
      _s?._js('window.erDrawErase && window.erDrawErase(${jsonEncode(id)})');

  /// เลื่อนกล้องไปที่บริเวณบนหุ่น {a, b, t, spin, tilt, zoom} · null = ทั้งตัว
  void focus(Map<String, Object?>? f) =>
      _s?._js('window.erFocus && window.erFocus(${jsonEncode(f)})');

  /// ภาพฉากตอนนี้ (null = ถ่ายไม่ได้)
  Future<Uint8List?> snapshot() {
    final s = _s;
    if (s == null || !s._ready) return Future.value(null);
    _snap?.complete(null);
    final c = _snap = Completer<Uint8List?>();
    s._js('window.erDrawSnap && window.erDrawSnap()');
    return c.future.timeout(const Duration(seconds: 4), onTimeout: () => null);
  }
}

class _ErRoom3DState extends State<ErRoom3D> {
  WebViewController? _web;

  /// heartbeat กัน WKWebView ล่มตอน hot restart (ดู ErWebAlive)
  late final ErWebAlive _alive = ErWebAlive((js) => _web?.runJavaScript(js));
  HttpServer? _server;

  /// เว็บ: ฉากเดียวกันใน iframe แทน WebView + HttpServer
  ErWebFrame? _frame;
  bool _ready = false;

  /// debug: hot reload แล้วโหลดหน้าใหม่ ให้ JS/HTML ที่แก้มีผลทันที (ไม่ต้องสลับหน้า/รันใหม่)
  @override
  void reassemble() {
    super.reassemble();
    final s = _server;
    if (_web == null || s == null) return;
    _ready = false;
    _web!.loadRequest(Uri.parse(
        'http://127.0.0.1:${s.port}/index.html?v=${DateTime.now().millisecondsSinceEpoch}'));
  }

  @override
  void initState() {
    super.initState();
    widget.drawCtl?._s = this;
    _boot();
  }

  void _pushDraw() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erDrawMode && window.erDrawMode(${jsonEncode(widget.draw)})');
  }

  void _pushRegionSel() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erRegionSel && window.erRegionSel(${jsonEncode(widget.regionSel)})');
  }

  void _pushCloth() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erCloth && window.erCloth(${widget.cloth})');
  }

  void _pushRegionLines() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erRegionLines && window.erRegionLines(${widget.regionLines})');
  }

  void _pushDrawings() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erDrawLoad && window.erDrawLoad(${jsonEncode(widget.drawings)})');
  }

  @override
  void didUpdateWidget(covariant ErRoom3D old) {
    super.didUpdateWidget(old);
    if (old.selectedCode != widget.selectedCode) _pushSelection();
    if (old.cam.js != widget.cam.js) _pushCam();
    if (old.topView != widget.topView) {
      _pushView();
      if (widget.zoomTick > 0) _pushZoom();
    }
    if (old.layer != widget.layer) _pushLayer();
    if (!listEquals(old.highlight, widget.highlight)) _pushHighlight();
    if (old.dark != widget.dark) _pushDark();
    if (old.pageBg != widget.pageBg) _pushBg();
    if (old.zoomTick != widget.zoomTick) _pushZoom();
    if (old.pickMode != widget.pickMode) _pushPick();
    if (jsonEncode(old.draw) != jsonEncode(widget.draw)) _pushDraw();
    if (old.regionLines != widget.regionLines) _pushRegionLines();
    if (old.cloth != widget.cloth) _pushCloth();
    if (old.regionSel != widget.regionSel) _pushRegionSel();
    if (old.drawings.length != widget.drawings.length ||
        !identical(old.drawings, widget.drawings) &&
            jsonEncode(old.drawings) != jsonEncode(widget.drawings)) {
      _pushDrawings();
    }
    if (old.drawCtl != widget.drawCtl) widget.drawCtl?._s = this;
    if (jsonEncode(old.vitals) != jsonEncode(widget.vitals)) _pushVitals();
    if (jsonEncode(old.waiting) != jsonEncode(widget.waiting)) _pushWaiting();
    // เตียงเปลี่ยน ว่าง/มีคน หรือเพศผู้ป่วยเปลี่ยน = ส่งใหม่
    String sig(List<ErRoomBed> l) => l
        .map((b) => '${b.code}${b.vacant ? 0 : 1}${b.female ? 'f' : 'm'}')
        .join(',');
    if (sig(old.beds) != sig(widget.beds)) {
      _pushBeds();
    }
  }

  @override
  void dispose() {
    _alive.stop();
    // server ใช้ร่วมทุก instance (ดู _startServer) ไม่ปิด
    _frame?.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    if (kIsWeb) {
      setState(() => _frame = ErWebFrame(
            html: _html,
            channel: 'ErRoom',
            routes: [
              (
                r'^/three\.min\.js$',
                'assets/web/three.min.js',
                'application/javascript'
              ),
              (
                r'^/GLTFLoader\.js$',
                'assets/web/GLTFLoader.js',
                'application/javascript'
              ),
              (
                r'^/er_room\.glb$',
                'assets/models/er_room.glb',
                'model/gltf-binary'
              ),
              (
                r'^/clothes_(m|f)\.glb$',
                r'assets/models/er_patient_clothes_$1.glb',
                'model/gltf-binary'
              ),
              (
                r'^/tandem\.glb$',
                'assets/models/er_tandem_seat.glb',
                'model/gltf-binary'
              ),
              (
                r'^/wheelchair\.glb$',
                'assets/models/er_wheelchair.glb',
                'model/gltf-binary'
              ),
              (
                r'^/figure\.glb$',
                'assets/models/er_patient_figure.glb',
                'model/gltf-binary'
              ),
              (
                r'^/body_m\.glb$',
                'assets/models/er_body_male.glb',
                'model/gltf-binary'
              ),
              (
                r'^/body_f\.glb$',
                'assets/models/er_body_female.glb',
                'model/gltf-binary'
              ),
              (
                r'^/body_bp\.glb$',
                'assets/models/er_body_skin.glb',
                'model/gltf-binary'
              ),
              (
                r'^/anat\.glb$',
                'assets/models/er_body_realistic.glb',
                'model/gltf-binary'
              ),
              (
                r'^/anat_n\.jpg$',
                'assets/models/er_body_realistic_normal.jpg',
                'image/jpeg'
              ),
              (
                r'^/anat_ao\.jpg$',
                'assets/models/er_body_realistic_ao.jpg',
                'image/jpeg'
              ),
              (
                r'^/anat_f\.glb$',
                'assets/models/er_body_realistic_f.glb',
                'model/gltf-binary'
              ),
              (
                r'^/anat_f_n\.jpg$',
                'assets/models/er_body_realistic_f_normal.jpg',
                'image/jpeg'
              ),
              (
                r'^/anat_f_ao\.jpg$',
                'assets/models/er_body_realistic_f_ao.jpg',
                'image/jpeg'
              ),
              (
                r'^/layer_bone\.glb$',
                'assets/models/er_layer_bone.glb',
                'model/gltf-binary'
              ),
              (
                r'^/layer_organ\.glb$',
                'assets/models/er_layer_organ.glb',
                'model/gltf-binary'
              ),
              (
                r'^/layer_vessel\.glb$',
                'assets/models/er_layer_vessel.glb',
                'model/gltf-binary'
              ),
              (
                r'^/bone/([a-z_]+)\.glb$',
                r'assets/models/bone/er_bone_$1.glb',
                'model/gltf-binary'
              ),
              (
                r'^/organ_([a-z_]+)\.glb$',
                r'assets/models/er_organ_$1.glb',
                'model/gltf-binary'
              ),
            ],
            onMessage: (m) => _onMessage(JavaScriptMessage(message: m)),
          ));
      return;
    }
    final server = await _startServer();
    if (!mounted) return;
    _server = server;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('ErRoom', onMessageReceived: _onMessage)
      // query กัน WebView ใช้หน้าเก่าจาก cache หลังแก้ฉาก
      ..loadRequest(Uri.parse(
          'http://127.0.0.1:${server.port}/index.html?v=${DateTime.now().millisecondsSinceEpoch}'));
    setState(() => _web = controller);
    _alive.start();
  }

  /// รัน JS ในฉาก: iframe บนเว็บ หรือ WebView บนมือถือ
  void _js(String js) {
    if (_frame != null) {
      _frame!.run(js);
      return;
    }
    _web?.runJavaScript(js);
  }

  void _onMessage(JavaScriptMessage message) {
    // ข้อความจาก WebView อาจมาถึงหลังหน้านี้ถูกปิดแล้ว (เช่นปิด studio วาดภาพ)
    // ต้องไม่โยน exception กลับเข้า WKScriptMessageHandler: iOS จะ fatal error แอปหลุด
    if (!mounted) return;
    try {
      _handleMessage(message);
    } catch (e, st) {
      debugPrint('ErRoom3D message error: $e\n$st');
    }
  }

  void _handleMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        _ready = true;
        debugPrint('ErRoom3D พร้อม เตียงในฉาก: ${data['beds']}');
        _pushBeds();
        _pushCam();
        _pushSelection();
        _pushView();
        _pushHighlight();
        // ชั้นที่เลือกไว้ (เช่น กระดูก) ต้องส่งซ้ำหลังหน้าโหลดใหม่ ไม่งั้นกลับเป็นผิวหนัง
        _pushLayer();
        _pushDark();
        _pushBg();
        if (widget.zoomTick > 0) _pushZoom();
        _pushPick();
        _pushDraw();
        if (widget.drawings.isNotEmpty) _pushDrawings();
        if (widget.regionLines) _pushRegionLines();
        if (widget.instant) _js('window.erInstant && window.erInstant()');
        widget.onReady?.call();
        if (!widget.cloth) _pushCloth();
        if (widget.regionSel != null) _pushRegionSel();
        _pushVitals();
        _pushWaiting();
        break;
      case 'bodyPick':
        widget.onBodyPick?.call(data['bone'] as String);
        break;
      case 'regionPick':
        widget.onRegionPick?.call(data['region'] as String?,
            [for (final v in data['pt'] as List) (v as num).toDouble()]);
        break;
      case 'drawStroke':
        widget.onDrawStroke?.call(data);
        break;
      case 'drawErase':
        widget.onDrawErase?.call(data['id'] as String);
        break;
      case 'drawSnap':
        final url = '${data['data'] ?? ''}';
        final i = url.indexOf(',');
        final c = widget.drawCtl?._snap;
        widget.drawCtl?._snap = null;
        c?.complete(i < 0 ? null : base64Decode(url.substring(i + 1)));
        break;
      case 'tap':
        widget.onBedTap?.call(data['code'] as String);
        break;
      case 'error':
        debugPrint('ErRoom3D ผิดพลาด: ${data['message']}');
        break;
      case 'debug':
        debugPrint('ErRoom3D debug: $data');
        break;
      case 'positions':
        final list = (data['items'] as List)
            .map((e) => ErBedScreenPos(
                  e['code'] as String,
                  (e['x'] as num).toDouble(),
                  (e['y'] as num).toDouble(),
                  e['visible'] as bool,
                ))
            .toList();
        widget.onPositions?.call(list);
        final hs = data['hotspots'];
        if (hs is List) {
          widget.onHotspots?.call(hs
              .map((e) => ErBedScreenPos(
                    e['key'] as String,
                    (e['x'] as num).toDouble(),
                    (e['y'] as num).toDouble(),
                    e['visible'] as bool,
                  ))
              .toList());
        }
        break;
    }
  }

  void _pushVitals() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erVitals(${jsonEncode(widget.vitals)})');
  }

  void _pushWaiting() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erSetWaiting(${jsonEncode(widget.waiting)})');
  }

  void _pushBeds() {
    if (!_ready || (_web == null && _frame == null)) return;
    final payload = jsonEncode(widget.beds.map((b) => b.toJson()).toList());
    _js('window.erSetBeds($payload)');
  }

  void _pushCam() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erSetCam(${widget.cam.js})');
  }

  void _pushView() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erSetView(${widget.topView})');
  }

  void _pushLayer() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js("window.erSetLayer('${widget.layer}')");
  }

  void _pushDark() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erSetDark && window.erSetDark(${widget.dark})');
  }

  void _pushBg() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erSetPageBg && window.erSetPageBg(${widget.pageBg})');
  }

  void _pushZoom() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erSetZoom && window.erSetZoom(${widget.zoom})');
  }

  void _pushPick() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erPickMode && window.erPickMode(${widget.pickMode})');
  }

  void _pushHighlight() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js('window.erHighlight(${jsonEncode(widget.highlight)})');
  }

  void _pushSelection() {
    if (!_ready || (_web == null && _frame == null)) return;
    _js("window.erSelect('${widget.selectedCode}')");
  }

  /// server เดียวทั้งแอป: origin (port) เดิมทุกครั้ง WebView จึงใช้ HTTP cache ของ
  /// three.js และ .glb (หลาย MB) ซ้ำได้ ไม่โหลด/อ่าน asset ใหม่ทุกครั้งที่สร้างฉาก
  static Future<HttpServer>? _shared;

  /// asset ที่อ่านจาก bundle แล้ว เก็บไว้ในหน่วยความจำ (อ่าน rootBundle ครั้งเดียว)
  static final Map<String, Uint8List> _bytes = {};

  /// เสิร์ฟไฟล์ฉากและไลบรารีจาก asset ให้ WebView บนเครื่องเท่านั้น
  Future<HttpServer> _startServer() => _shared ??= _bindServer();

  Future<HttpServer> _bindServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      String path = req.uri.path;
      if (path == '/' || path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
        req.response.headers.set('cache-control', 'no-store');
        req.response.write(_html);
        await req.response.close();
        return;
      }
      const assets = {
        '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
        '/GLTFLoader.js': [
          'assets/web/GLTFLoader.js',
          'application/javascript'
        ],
        '/er_room.glb': ['assets/models/er_room.glb', 'model/gltf-binary'],
        // เก้าอี้แถวรอตรวจ + รถเข็น (Sketchfab) สำหรับผู้ป่วยที่ยังไม่ได้เตียง
        // ชุดผู้ป่วย (ปั้นใน Blender จากหุ่นผิวจริง) ใส่ทับหุ่นท่านั่ง
        '/clothes_m.glb': [
          'assets/models/er_patient_clothes_m.glb',
          'model/gltf-binary'
        ],
        '/clothes_f.glb': [
          'assets/models/er_patient_clothes_f.glb',
          'model/gltf-binary'
        ],
        '/tandem.glb': [
          'assets/models/er_tandem_seat.glb',
          'model/gltf-binary'
        ],
        '/wheelchair.glb': [
          'assets/models/er_wheelchair.glb',
          'model/gltf-binary'
        ],
        // หุ่นผู้ป่วยแบบมีโครงกระดูก วางนอนบนเตียงที่มีคน
        '/figure.glb': [
          'assets/models/er_patient_figure.glb',
          'model/gltf-binary'
        ],
        // ผิวทั้งตัวจาก BodyParts3D ใช้แทนหุ่นตอนมุมมองรายละเอียด
        // BodyParts3D, © The Database Center for Life Science (CC BY)
        // ร่างชาย/หญิงจาก MakeHuman base mesh (CC0)
        '/body_m.glb': ['assets/models/er_body_male.glb', 'model/gltf-binary'],
        '/body_f.glb': [
          'assets/models/er_body_female.glb',
          'model/gltf-binary'
        ],
        // ผิวทั้งตัวจาก BodyParts3D ชุดเดียวกับชั้นข้างใน สัดส่วนจึงตรงกันพอดี
        '/body_bp.glb': ['assets/models/er_body_skin.glb', 'model/gltf-binary'],
        // หุ่นผิวจริงจาก ThaiWell (body_male + normal/AO map) ใช้ในหน้ารายละเอียด
        // ห่อด้วย node bp3d_frame แปลงเป็นพิกัด BodyParts3D (สูงเท่ากัน ปลายเท้าตรงกัน)
        // จึงวางทับด้วย bp3dToFigure ชุดเดียวกับชั้นกระดูก/อวัยวะ
        '/anat.glb': [
          'assets/models/er_body_realistic.glb',
          'model/gltf-binary'
        ],
        '/anat_n.jpg': [
          'assets/models/er_body_realistic_normal.jpg',
          'image/jpeg'
        ],
        '/anat_ao.jpg': [
          'assets/models/er_body_realistic_ao.jpg',
          'image/jpeg'
        ],
        '/anat_f.glb': [
          'assets/models/er_body_realistic_f.glb',
          'model/gltf-binary'
        ],
        '/anat_f_n.jpg': [
          'assets/models/er_body_realistic_f_normal.jpg',
          'image/jpeg'
        ],
        '/anat_f_ao.jpg': [
          'assets/models/er_body_realistic_f_ao.jpg',
          'image/jpeg'
        ],
        // ชั้นกายวิภาคจาก BodyParts3D: กระดูก อวัยวะ เส้นเลือด
        '/layer_bone.glb': [
          'assets/models/er_layer_bone.glb',
          'model/gltf-binary'
        ],
        '/layer_organ.glb': [
          'assets/models/er_layer_organ.glb',
          'model/gltf-binary'
        ],
        '/layer_vessel.glb': [
          'assets/models/er_layer_vessel.glb',
          'model/gltf-binary'
        ],
        // อวัยวะแยกชิ้น ไว้เรืองแสงตามอาการ
        '/organ_brain.glb': [
          'assets/models/er_organ_brain.glb',
          'model/gltf-binary'
        ],
        '/organ_heart.glb': [
          'assets/models/er_organ_heart.glb',
          'model/gltf-binary'
        ],
        '/organ_lungs.glb': [
          'assets/models/er_organ_lungs.glb',
          'model/gltf-binary'
        ],
        '/organ_liver.glb': [
          'assets/models/er_organ_liver.glb',
          'model/gltf-binary'
        ],
        '/organ_stomach.glb': [
          'assets/models/er_organ_stomach.glb',
          'model/gltf-binary'
        ],
        '/organ_kidneys.glb': [
          'assets/models/er_organ_kidneys.glb',
          'model/gltf-binary'
        ],
        '/organ_intestine.glb': [
          'assets/models/er_organ_intestine.glb',
          'model/gltf-binary'
        ],
        '/organ_bladder.glb': [
          'assets/models/er_organ_bladder.glb',
          'model/gltf-binary'
        ],
      };
      // กระดูกแยกชิ้นจาก BodyParts3D (ครบทั้งแขนขา) /bone/<ชิ้น>.glb
      final bone = RegExp(r'^/bone/([a-z_]+)\.glb$').firstMatch(path);
      // อวัยวะจาก BodyParts3D ทุกชิ้น /organ_<id>.glb (สร้างด้วย build_organs.py)
      final organ = RegExp(r'^/organ_([a-z_]+)\.glb$').firstMatch(path);
      final entry = bone != null
          ? [
              'assets/models/bone/er_bone_${bone.group(1)}.glb',
              'model/gltf-binary'
            ]
          : organ != null
              ? [
                  'assets/models/er_organ_${organ.group(1)}.glb',
                  'model/gltf-binary'
                ]
              : assets[path];
      if (entry == null) {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
        return;
      }
      final bytes = _bytes[entry[0]] ??=
          (await rootBundle.load(entry[0])).buffer.asUint8List();
      req.response.headers.set('content-type', entry[1]);
      // asset ไม่เปลี่ยนระหว่างรัน: ให้ WebView cache (หน้า index ยัง no-store)
      req.response.headers.set('cache-control', 'public, max-age=86400');
      req.response.add(bytes);
      await req.response.close();
    });
    return server;
  }

  @override
  Widget build(BuildContext context) {
    if (_frame != null) return _frame!.view();
    if (_web == null) return const SizedBox.shrink();
    return WebViewWidget(controller: _web!);
  }
}

// getter (ไม่ใช่ const): hot reload เห็น JS ที่แก้
String get _html => r'''
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
<style>
  html, body { margin:0; height:100%; overflow:hidden; background:#EEF2F7; }
  /* กดค้างบนหุ่น (ลากวาดช้า ๆ) ไม่ให้ iOS เลือกข้อความทั้งหน้า/โชว์เมนู */
  * { -webkit-user-select:none; user-select:none; -webkit-touch-callout:none; -webkit-tap-highlight-color:transparent; }
  canvas { display:block; touch-action:none; }
</style>
<script src="three.min.js"></script>
<script src="GLTFLoader.js"></script>
</head>
<body>
<script>
// ฉากห้องฉุกเฉิน: กล้องมองเข้าแถวเตียง แพนตามเตียงที่เลือก
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x8FA3B3);

// กล้อง orthographic ให้ภาพแบบ isometric เส้นขนานไม่ลู่เข้าหากัน
const persp = new THREE.PerspectiveCamera(
  40, window.innerWidth / Math.max(window.innerHeight, 1), 0.05, 300);
const ortho = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 400);
let camera = persp;       // กล้องที่ใช้อยู่ สลับได้จากแผงปรับฉาก

const renderer = new THREE.WebGLRenderer({
  antialias: true,
  powerPreference: 'high-performance',
});
// จอแท็บเล็ตความละเอียดสูง ถ้าเรนเดอร์เต็ม dpr จะหนักโดยไม่ได้คุณภาพเพิ่ม
// 1.25 พอ (แท็บเล็ต 2560 px): ลดพิกเซลที่ GPU ต้องวาด ~30% เทียบ 1.5
const PR_FULL = Math.min(window.devicePixelRatio, 1.25);
const PR_MOVE = 0.85;
renderer.setPixelRatio(PR_FULL);
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.outputEncoding = THREE.sRGBEncoding;
// ACES = คอนทราสต์ของฉากห้อง (Linear ทำให้ทั้งฉากจืด) · หุ่น/ชุดไม่ผ่าน tone mapping (toneMapped false)
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
// ในฉากนี้ไม่มีอะไรเคลื่อนที่ เงาจึงคำนวณครั้งเดียวพอ
renderer.shadowMap.autoUpdate = false;
// สว่างสดแบบโถงโรงพยาบาลจริง (หุ่น/ชุดไม่ผ่าน tone mapping สีผิวไม่เปลี่ยน)
// ห้องเตียง 1.0 · โถงนั่งรอ 1.1 (สลับใน lobbyLight)
renderer.toneMappingExposure = 1.0;
document.body.appendChild(renderer.domElement);

// แสงรอบตัวเทาอมฟ้าแบบภาพหุ่นสแกนใบหน้า (เดิมเหลืองอุ่น)
// แสงรอบตัวน้อยลง (ห้องเตียงสว่างจ้าไม่มีมิติ 2026-11-26): ไฟหลักกำหนดทิศแสง ด้านเงามีน้ำหนัก
const hemi = new THREE.HemisphereLight(0xffffff, 0x8f97a6, 0.42);
scene.add(hemi);
// ไฟหลักขาวกลาง เฉียงบน (เดิมส้มอุ่น)
// ไฟหลักห้องเตียง: แดดอุ่นเฉียง (ชุดเดียวกับโถงนั่งรอ) เงาเตียง/ม่านตกพื้นชัด
const key = new THREE.DirectionalLight(0xfff1df, 1.75);
key.position.set(3.5, 6.5, 3.0);
key.castShadow = true;
key.shadow.mapSize.set(2048, 2048);
key.shadow.camera.near = 0.5;
key.shadow.camera.far = 60;
key.shadow.camera.left = -14;
key.shadow.camera.right = 14;
key.shadow.camera.top = 10;
key.shadow.camera.bottom = -10;
key.shadow.bias = -0.0006;
key.shadow.normalBias = 0.02;
scene.add(key);
// ไฟเติมจากอีกฝั่ง ลดเงาทึบ + ไฟขอบจากด้านหลังเฉียงบน (สัดส่วนเดียวกับภาพหุ่นสแกนใบหน้า)
const fill = new THREE.DirectionalLight(0xffffff, 0.42);
fill.position.set(-4, 3, 4);
scene.add(fill);
const rim = new THREE.DirectionalLight(0xffffff, 0.5);
rim.position.set(-2, 5, -5);
scene.add(rim);

// ---------------------------------------------------------------- วัสดุ
// โมเดลห้องมี texture ของตัวเองมาแล้ว จึงไม่สร้างพื้นผิวเพิ่มให้เปลืองหน่วยความจำ
// ระดับพื้นห้องสำหรับ shader ผนัง (อัปเดตเมื่อรู้ floorY)
const wallFloorU = { value: 0 };
function dressMaterials(root) {
  root.traverse(function (m) {
    if (!m.isMesh || !m.material) return;
    m.castShadow = true;
    m.receiveShadow = true;
    const mats = Array.isArray(m.material) ? m.material : [m.material];
    mats.forEach(function (mat) {
      mat.side = THREE.DoubleSide;
      // ไม้โอ๊คในฉากเตียง (ผู้ใช้ 2026-11-26): ตู้ = ลายไม้โอ๊ค · บัวผนังไม้ (วาดใน shader ผนังด้านล่าง) · เตียงคงสีเดิม
      if ((mat.name === 'Cabinet1' || mat.name === 'Cabinet2') && !mat.userData.oak) {
        mat.userData.oak = true;
        const t = woodTex(0).clone(); t.needsUpdate = true; t.repeat.set(1, 1);
        mat.map = t;
        mat.color.setHex(0xffffff);
        mat.roughness = 0.6;
        mat.needsUpdate = true;
      }
      // ผนังห้อง = ขาวจั๊ว (ผู้ใช้ 2026-11-26 "สีกำแพงยังดูเทา ๆ") · ทิ้ง texture ผนังเทาเดิม
      if (mat.name === 'Wall1' && !mat.userData.white) {
        mat.userData.white = true;
        mat.map = null;
        mat.color.setHex(0xffffff);
        if (mat.emissive) { mat.emissive.setHex(0x000000); mat.emissiveIntensity = 0.0; }
        mat.roughness = 0.9;
        // มิติแบบผนังโถง: เงาสัมผัสที่โคนผนัง + ขอบบนหม่นลง (คิดจากความสูงจริงเหนือพื้นห้อง)
        mat.onBeforeCompile = function (sh) {
          sh.uniforms.uFloor = wallFloorU;
          sh.vertexShader = sh.vertexShader
            .replace('#include <common>', '#include <common>\nvarying float vWY;\nvarying float vWU;')
            .replace('#include <worldpos_vertex>', '#include <worldpos_vertex>\nvec4 wq = modelMatrix * vec4(transformed, 1.0);\nvWY = wq.y;\nvWU = wq.x + wq.z;');
          sh.fragmentShader = sh.fragmentShader
            .replace('#include <common>', '#include <common>\nvarying float vWY;\nvarying float vWU;\nuniform float uFloor;')
            .replace('#include <color_fragment>', '#include <color_fragment>\n' +
              'float wh = max(vWY - uFloor, 0.0);\n' +
              'diffuseColor.rgb *= 1.0 - 0.40 * exp(-wh / 0.35) - 0.22 * clamp((wh - 1.6) / 1.4, 0.0, 1.0);\n' +
              // ราวกันชนไม้โอ๊คแบบหน้าเก้าอี้ (WAIT.kickY 0.30 สูง 12 ซม.) · ขอบบนรับแสง ขอบล่างเงา
              // + เงาตกบนผนังใต้ราว (ราวยื่นออกจากผนัง) · ลายเสี้ยนไม้ตามแนวยาวผนัง
              'float rb = smoothstep(0.238, 0.242, wh) * (1.0 - smoothstep(0.358, 0.362, wh));\n' +
              'float rt = smoothstep(0.340, 0.358, wh);\n' +
              'float rlow = 1.0 - smoothstep(0.242, 0.258, wh);\n' +
              'float grain = 0.93 + 0.07 * sin(vWU * 120.0 + sin(vWU * 9.0) * 0.8);\n' +
              'vec3 oak = vec3(0.553, 0.333, 0.165) * grain * (1.0 + 0.10 * rt - 0.22 * rlow);\n' +
              'diffuseColor.rgb *= 1.0 - 0.22 * smoothstep(0.17, 0.238, wh) * (1.0 - smoothstep(0.238, 0.242, wh));\n' +
              'diffuseColor.rgb = mix(diffuseColor.rgb, oak, rb);');
        };
        mat.customProgramCacheKey = function () { return 'room-wall-depth-rail'; };
        mat.needsUpdate = true;
      }
      if (mat.roughness !== undefined && mat.roughness > 0.95) {
        mat.roughness = 0.8;
      }
    });
  });
}

// ห้องทั้งก้อน (เตียง ผนัง ของติดช่อง) · ซ่อนตอนแสดงโถงนั่งรอ
let roomRoot = null;
const envMats = [];       // วัสดุของห้อง ไว้จางตอนโชว์เฉพาะผู้ป่วย
const beds = {};          // รหัสเตียง -> object3D
const glows = {};         // รหัสเตียง -> วงไฟที่พื้น
let order = [];           // ลำดับเตียงตามข้อมูลที่ส่งมาจากแอป
// ส่ง error ที่หลุดใน JS กลับไปให้ Dart log (ฉากค้างเงียบ ๆ หาสาเหตุไม่ได้)
window.addEventListener('error', function (e) {
  try { send({ type: 'error', message: String(e.message) + ' @' + e.lineno }); } catch (_) {}
});
let selected = null;
// จอ monitor เหนือหัวเตียง (ประกาศก่อน frame() ใช้ ไม่งั้นเจอ TDZ แล้วฉากค้าง)
let mon = null, monData = null, monT = 0;
let roomHalfWidth = 4;
let rowDir = null;        // ทิศทางของแนวเตียง ใช้ตอนลากนิ้วเลื่อนดู

function send(payload) {
  // หลัง hot restart (heartbeat หยุด) ไม่ส่งเข้า Dart ตัวใหม่ กันแอปล่ม
  if (window.__erDbg && Date.now() - (window.__erAlive || 0) > 700) return; 
  if (window.ErRoom) window.ErRoom.postMessage(JSON.stringify(payload));
}

// ---------------------------------------------------------------- โหลดฉาก
new THREE.GLTFLoader().load('er_room.glb', function (gltf) {
  const root = gltf.scene;
  roomRoot = root;
  scene.add(root);
  // ชื่อโหนดจาก Blender อาจมีเลขต่อท้าย เช่น bed_A1_0 จึงตัดออกก่อนใช้เป็นรหัส
  root.traverse(function (o) {
    if (o.name && o.name.indexOf('bed_') === 0) {
      const code = o.name.slice(4).replace(/_\d+$/, '');
      if (!beds[code]) {
        beds[code] = o;
        o.userData.isBed = true;
        // เก็บรายการวัสดุไว้เลย จะได้ไม่ต้อง traverse ทุกเฟรมตอนไล่ความจาง
        const mats = [];
        o.traverse(function (mm) {
          if (!mm.isMesh || !mm.material) return;
          (Array.isArray(mm.material) ? mm.material : [mm.material])
            .forEach(function (mat) { mats.push(mat); });
        });
        o.userData.mats = mats;
        // จำสเกลเดิมไว้ ฉากถูกย่อมาเป็นหน่วยเมตรตั้งแต่ตอน export
        o.userData.baseScale = o.scale.x;
        // วัสดุถูกใช้ร่วมกันทุกเตียง ต้องโคลนก่อน ไม่งั้นจางพร้อมกันหมด
        o.traverse(function (m) {
          if (!m.isMesh || !m.material) return;
          m.material = Array.isArray(m.material)
            ? m.material.map(function (x) { return x.clone(); })
            : m.material.clone();
        });
      }
    }
  });
  // ใส่พื้นผิวและเปิดเงาให้ทุกชิ้นในฉาก
  dressMaterials(root);
  // ตู้ในโมเดลห้องวางจมเข้าผนัง (ผู้ใช้ 2026-11-26 "ตู้ทะลุกำแพง") = ซ่อน (ของตกแต่ง ไม่มีข้อมูล)
  root.traverse(function (m) {
    if (!m.isMesh || !m.material) return;
    const mn = (Array.isArray(m.material) ? m.material : [m.material]).map(function (x) { return x.name; });
    if (mn.indexOf('Cabinet1') >= 0 || mn.indexOf('Cabinet2') >= 0) m.visible = false;
  });
  // วัสดุของห้อง (ที่ไม่ใช่เตียง) เก็บไว้ค่อย ๆ จางตอนเข้าหน้ารายละเอียด
  const bedMatSet = [];
  Object.keys(beds).forEach(function (code) {
    (beds[code].userData.mats || []).forEach(function (m) { bedMatSet.push(m); });
  });
  root.traverse(function (m) {
    if (!m.isMesh || !m.material) return;
    (Array.isArray(m.material) ? m.material : [m.material]).forEach(function (mat) {
      if (bedMatSet.indexOf(mat) < 0 && envMats.indexOf(mat) < 0) envMats.push(mat);
    });
  });
  const box = new THREE.Box3().setFromObject(root);
  roomHalfWidth = (box.max.x - box.min.x) / 2;
  floorY = box.min.y;
  wallFloorU.value = floorY;
  // คำนวณกรอบของเตียงครั้งเดียวตอนโหลด setFromObject ไล่ทุกจุดยอด แพงเกินกว่า
  // จะทำทุกเฟรม เตียงไม่ขยับ จึงใช้ค่าที่เก็บไว้ได้ตลอด
  Object.keys(beds).forEach(function (code) {
    const b = beds[code];
    const bb = new THREE.Box3().setFromObject(b);
    b.userData.box = bb;
    b.userData.center = bb.getCenter(new THREE.Vector3());
    b.userData.top = bb.max.y;
    b.userData.nearZ = bb.max.z;
    b.userData.farZ = bb.min.z;
  });
  renderer.shadowMap.needsUpdate = true;
  applyFrustum();
  send({ type: 'ready', beds: Object.keys(beds) });
  animate();
}, undefined, function (err) {
  send({ type: 'error', message: String(err) });
});

// ---------------------------------------------------------------- กล้อง
// เตียงเรียงเฉียง กล้องจึงต้องตามทั้งแกน x และ z
let targetPos = new THREE.Vector3(0, 0, 0);
let currentPos = new THREE.Vector3(0, 0, 0);
let camH = 3.0;           // ความสูงกล้องจากพื้น
let camD = 6.42;           // ระยะห่างจากเตียงที่เลือก
let yaw = 0;              // มุมเอียงด้านข้าง (องศา)
let lookY = -0.45;         // ความสูงของจุดที่กล้องเล็ง
let tagLift = 0.02;        // ระยะยกป้ายเตียง
let shiftX = 0.0;
let shiftY = 0;           // เลื่อนฉากขึ้นลง (เมตร)
let iso = false;          // true = ภาพแบบ isometric
let zoomIso = 4.2;        // ความสูงกรอบภาพตอนเป็น isometric
let pitch = 16;
let bedTurn = 0;
let screenX = 0;        // เลื่อนภาพทั้งฉากบนจอ (พิกเซล)         // หมุนตัวเตียงเทียบกับกล้อง           // มุมก้มตอนเป็น isometric        // เลื่อนกล้องแนวนอน ดันเตียงให้พ้นแผงที่ทับอยู่
let floorY = 0;           // ระดับพื้นห้อง

function applyFrustum() {
  const aspect = window.innerWidth / Math.max(window.innerHeight, 1);
  persp.aspect = aspect;
  persp.updateProjectionMatrix();
  const h = zoomIso / 2, w = h * aspect;
  ortho.left = -w;
  ortho.right = w;
  ortho.top = h;
  ortho.bottom = -h;
  ortho.updateProjectionMatrix();
  // เลื่อนกรอบภาพบนจอ ใช้ดันฉากไปอยู่ฝั่งซ้าย โดยไม่ต้องขยับกล้องจริง
  const vw = window.innerWidth, vh = window.innerHeight;
  [persp, ortho].forEach(function (c) {
    if (!screenX) { c.clearViewOffset(); return; }
    c.setViewOffset(vw, vh, screenX, 0, vw, vh);
  });
  camera = iso ? ortho : persp;
}

// มุมมองจากบน: 0 = มุมปกติ, 1 = มองลงมาที่เตียงที่เลือกตรง ๆ
// ค่อย ๆ ไล่จาก topMix ไป topWant ทุกเฟรม กล้องจึงลอยไปแบบต่อเนื่อง
let topWant = 0;
let topMix = 0;
let TOP_H_BASE = 3.1;          // ความสูงกล้องตอนมองจากบน (เมตร) เห็นทั้งเตียงมีขอบเหลือ
const TOP_LOOK_Y = 0.6;     // จุดเล็งระดับที่นอน
window.erSetView = function (top) {
  topWant = top ? 1 : 0;
  markDirty(200);
};
// เข้าหน้ารายละเอียดทันที (ไม่เล่นกล้องบินจากห้องลงเตียง) · ใช้กับ studio วาดภาพ
window.erInstant = function () {
  topMix = topWant;
  envMix = topWant;
  currentPos.copy(targetPos);
  if (typeof zoomK !== 'undefined') zoomK = zoomWant;
  markDirty(30);
};
// ระดับการจางของห้อง (เตียง ผนัง จอ) แยกจากกล้อง: หุ่นอยู่ต่อเนื่อง จางเฉพาะห้อง
// เข้าหน้ารายละเอียด = ห้องจางออกทันที · กลับ = ห้องค่อยกลับมาตอนกล้องใกล้ถึงมุมห้อง
let envMix = 0;
let envLast = performance.now();
const ENV_SEC = 0.32;
function envFade() {
  const t = envMix;
  return t * t * (3 - 2 * t);
}
// คืน true ถ้ายังจางอยู่ (ต้องวาดเฟรมต่อ)
function stepEnv() {
  const now = performance.now();
  const dt = Math.min(0.1, (now - envLast) / 1000);
  envLast = now;
  const want = topWant > 0.5 ? 1 : (topMix < 0.55 ? 0 : 1);
  if (envMix === want) return false;
  const d = dt / ENV_SEC;
  envMix = want > envMix ? Math.min(want, envMix + d) : Math.max(want, envMix - d);
  return true;
}
const BG_ROOM = new THREE.Color(0x8FA3B3);
const BG_PAGE = new THREE.Color(0xFFFFFF);
window.erSetPageBg = function (hex) {
  BG_PAGE.setHex(hex);
  applyEnvFade();
  markDirty(10);
};
// โหมดสรุปเคส: พื้นมืด หุ่นเป็นเอกซเรย์ฟ้า อวัยวะเรืองแดง
const BG_DARK = new THREE.Color(0x0A0E1A);
let darkMode = false;
function applyEnvFade() {
  const f = envFade();
  for (let i = 0; i < envMats.length; i++) {
    const mat = envMats[i];
    if (mat.userData.baseOpacity === undefined) mat.userData.baseOpacity = mat.opacity;
    if (!mat.transparent) mat.transparent = true;
    mat.opacity = mat.userData.baseOpacity * (1 - f);
    mat.depthWrite = f < 0.5;
    mat.visible = f < 0.995;
  }
  Object.keys(glows).forEach(function (c) { glows[c].visible = (c === selected) && f < 0.5; });
  if (pin) pin.visible = f < 0.5;
  scene.background.copy(BG_ROOM).lerp(darkMode ? BG_DARK : BG_PAGE, f);
}

let lastBedAngle = null;
// ความสูงจุดกลางหุ่นที่เลือก null = ยังไม่มีหุ่น
let focusY = null;
const _fp = new THREE.Vector3(), _dir = new THREE.Vector3();
const _right = new THREE.Vector3(), _up = new THREE.Vector3();

// กล้องเล็งจุดต่ำกว่าหุ่น มุมเฉียงทำให้หุ่นเหลื่อมไปด้านข้าง
// ฉายจุดกลางหุ่นลงจอแล้วเลื่อนกล้องขนานระนาบภาพ ให้หุ่นอยู่กลางฉากพอดี
// โหมดห้องแก้เฉพาะแนวนอน · หน้ารายละเอียดแก้ทั้งสองแนว
function centerOnFocus(target, topE) {
  if (focusY === null || iso) return;
  _fp.set(currentPos.x + shiftX, focusY, currentPos.z);
  camera.updateMatrixWorld();
  const v = _fp.clone().project(camera);
  camera.getWorldDirection(_dir);
  const dist = _fp.clone().sub(camera.position).dot(_dir);
  if (!(dist > 0)) return;
  const halfH = dist * Math.tan(camera.fov * Math.PI / 360);
  const halfW = halfH * camera.aspect;
  _right.setFromMatrixColumn(camera.matrixWorld, 0);
  _up.setFromMatrixColumn(camera.matrixWorld, 1);
  const off = _right.multiplyScalar(v.x * halfW)
      .add(_up.multiplyScalar(v.y * halfH * topE));
  camera.position.add(off);
  target.add(off);
  camera.lookAt(target);
}

function frame() {
  const a = yaw * Math.PI / 180;
  // เตียงหันปลายเข้าหากล้อง ตั้งค่าเฉพาะตอนมุมเปลี่ยน ไม่ใช่ทุกเฟรม
  const bedAngle = a + bedTurn * Math.PI / 180;
  if (bedAngle !== lastBedAngle) {
    lastBedAngle = bedAngle;
    placeMonitor();
    for (let i = 0; i < order.length; i++) {
      const b = beds[order[i]];
      if (b) b.rotation.y = bedAngle;
    }
  }
  const target = new THREE.Vector3(
    currentPos.x + shiftX, floorY + lookY + shiftY, currentPos.z);
  if (iso) {
    const p = pitch * Math.PI / 180, d = 60;
    camera.position.set(
      target.x + Math.sin(a) * Math.cos(p) * d,
      target.y + Math.sin(p) * d,
      target.z + Math.cos(a) * Math.cos(p) * d
    );
  } else {
    camera.position.set(
      target.x + Math.sin(a) * camD,
      floorY + camH + shiftY,
      target.z + Math.cos(a) * camD
    );
  }
  waitCam(target);
  if (topMix > 0.0005 && !iso) {
    // smoothstep ให้ออกตัวและเข้าจอดนุ่ม ๆ
    const e = topMix * topMix * (3 - 2 * topMix);
    const topPos = new THREE.Vector3(
        target.x, floorY + TOP_H_BASE * zoomK + shiftY, target.z + 0.001);
    camera.position.lerp(topPos, e);
    target.y += (floorY + TOP_LOOK_Y + shiftY - target.y) * e;
    // เล็งเยื้องไปทางหัวเตียงนิด ให้หัวหุ่นพ้นแถวชิปด้านบนจอ
    // จุดเล็งคือกลางหุ่นอยู่แล้ว ไม่ต้องเยื้อง
    // หมุน "ด้านบนของภาพ" จาก +Y ไป -Z หัวเตียงจึงอยู่ด้านบนจอ
    camera.up.set(0, 1 - e, -e).normalize();
  } else {
    camera.up.set(0, 1, 0);
  }
  camera.lookAt(target);
  const te = topMix * topMix * (3 - 2 * topMix);
  centerOnFocus(target, te);
}

window.erSetCam = function (o) {
  markDirty(8);
  if (o.height != null) camH = o.height;
  if (o.distance != null) camD = o.distance;
  if (o.yaw != null) yaw = o.yaw;
  if (o.lookY != null) lookY = o.lookY;
  if (o.tagLift != null) tagLift = o.tagLift;
  if (o.shiftX != null) shiftX = o.shiftX;
  if (o.shiftY != null) shiftY = o.shiftY;
  if (o.iso != null) iso = o.iso;
  if (o.zoom != null) zoomIso = o.zoom;
  if (o.pitch != null) pitch = o.pitch;
  if (o.bedTurn != null) bedTurn = o.bedTurn;
  if (o.screenX != null) screenX = o.screenX;
  if (o.fov != null) persp.fov = o.fov;
  applyFrustum();
};

// ---------------------------------------------------------------- ไฟไฮไลต์
function makeGlow(color) {
  const g = new THREE.Mesh(
    new THREE.CircleGeometry(1.05, 48),
    new THREE.MeshBasicMaterial({
      color: color, transparent: true, opacity: 0.38,
      depthWrite: false,
    })
  );
  g.rotation.x = -Math.PI / 2;
  return g;
}

// ---------------------------------------------------------------- หุ่นผู้ป่วย
// ไฟล์เดียวมีสองร่าง (ชาย/หญิง) แต่ละร่างมีโครงกระดูกของตัวเอง
// โหลด buffer ครั้งเดียวแล้ว parse ใหม่ต่อเตียง จะได้โครงกระดูกแยกกัน
// (SkeletonUtils.clone ไม่มีใน three.min.js ตัวที่ฝังไว้)
const figures = {};       // รหัสเตียง -> object3D ของหุ่น
let figureBuffer = null;
let figureLoading = null;

function loadFigureBuffer() {
  if (figureBuffer) return Promise.resolve(figureBuffer);
  if (figureLoading) return figureLoading;
  figureLoading = fetch('figure.glb')
    .then(function (r) { return r.arrayBuffer(); })
    .then(function (buf) { figureBuffer = buf; return buf; });
  return figureLoading;
}

// หมุนกระดูกเพิ่มจากท่าตั้งต้น (องศา) แกน x หมุนแขนขาให้พับ/กาง
// GLTFLoader ตัดจุดออกจากชื่อโหนด (UpperArm.L_19 → UpperArmL_19) จึงเทียบแบบไม่มีจุด
function bare(n) { return String(n || '').replace(/\./g, ''); }
function findNode(root, name) {
  const key = bare(name);
  let hit = null;
  root.traverse(function (o) {
    if (!hit && bare(o.name).indexOf(key) === 0) hit = o;
  });
  return hit;
}
function bendBone(root, name, x, y, z) {
  const bone = findNode(root, name);
  if (!bone) return;
  bone.rotation.x += THREE.MathUtils.degToRad(x || 0);
  bone.rotation.y += THREE.MathUtils.degToRad(y || 0);
  bone.rotation.z += THREE.MathUtils.degToRad(z || 0);
}

// หาทิศหมุนต้นแขนที่ทำให้ฝ่ามือลงไปอยู่ต่ำสุดข้างลำตัว (ทำตอนหุ่นยังยืนอยู่)
function tuckArm(body, armName, palmName, minGap) {
  const arm = findNode(body, armName);
  const palm = findNode(body, palmName);
  if (!arm || !palm) return;
  const base = arm.rotation.clone();
  const p = new THREE.Vector3();
  let best = null;
  ['x', 'y', 'z'].forEach(function (axis) {
    for (let deg = -110; deg <= 110; deg += 5) {
      arm.rotation.copy(base);
      arm.rotation[axis] += THREE.MathUtils.degToRad(deg);
      body.updateMatrixWorld(true);
      palm.getWorldPosition(p);
      // ต่ำสุดก่อน แต่ห้ามมือมุดเข้าลำตัว — ต่ำกว่าระยะกันชนแล้วโดนหักคะแนนหนัก
      const gap = Math.abs(p.x);
      const score = p.y * 10 + Math.max(0, minGap - gap) * 60;
      if (!best || score < best.score) {
        best = { axis: axis, deg: deg, score: score };
      }
    }
  });
  arm.rotation.copy(base);
  // ถอยจากมุมที่แนบที่สุดราว 12% ให้แขนกางออกจากลำตัวนิดหนึ่ง
  // แนบสนิทเกินไปทำให้มือจมเข้าสะโพกและข้อมือบิดผิดรูป
  if (best) arm.rotation[best.axis] += THREE.MathUtils.degToRad(best.deg * 0.88);
  body.updateMatrixWorld(true);
}

// กางแขนออกจากลำตัวตรง ๆ: หมุนต้นแขนรอบแกน "หน้า" ของร่างตามองศาที่สั่ง
// (หาแกนด้วยการแปลงทิศหน้าจากพิกัดโลกเข้าไปอยู่ในพิกัดของกระดูกพ่อ)
function abductArm(body, armName, frontWorld, deg) {
  const arm = findNode(body, armName);
  if (!arm || !arm.parent) return;
  arm.parent.updateMatrixWorld(true);
  const pq = arm.parent.getWorldQuaternion(new THREE.Quaternion()).invert();
  const axis = frontWorld.clone().applyQuaternion(pq).normalize();
  const q = new THREE.Quaternion()
      .setFromAxisAngle(axis, THREE.MathUtils.degToRad(deg));
  arm.quaternion.premultiply(q);
  body.updateMatrixWorld(true);
}

// ขยับปลายแขนไปให้ใกล้ทิศที่ต้องการ (มาหน้าลำตัว + กางออกข้าง)
// ลองหมุนต้นแขนทีละแกนทีละองศา เลือกอันที่ฝ่ามือเลื่อนไปใกล้เป้าหมายที่สุด
function pushArm(body, armName, palmName, target) {
  const arm = findNode(body, armName);
  const palm = findNode(body, palmName);
  if (!arm || !palm) return;
  const base = arm.rotation.clone();
  const p0 = new THREE.Vector3();
  body.updateMatrixWorld(true);
  palm.getWorldPosition(p0);
  const p = new THREE.Vector3();
  let best = null;
  ['x', 'y', 'z'].forEach(function (axis) {
    for (let deg = -75; deg <= 75; deg += 3) {
      if (deg === 0) continue;
      arm.rotation.copy(base);
      arm.rotation[axis] += THREE.MathUtils.degToRad(deg);
      body.updateMatrixWorld(true);
      palm.getWorldPosition(p);
      const move = p.clone().sub(p0);
      const score = move.distanceTo(target);
      if (!best || score < best.score) {
        best = { axis: axis, deg: deg, score: score };
      }
    }
  });
  arm.rotation.copy(base);
  if (best) arm.rotation[best.axis] += THREE.MathUtils.degToRad(best.deg);
  body.updateMatrixWorld(true);
}

// จัดท่านอนหงาย: ยืนตรง → ล้มไปข้างหลัง หัวไปทางหัวเตียง
// แขนเก็บแนบลำตัว ขาเหยียดตรงอยู่แล้ว หัวเงยขึ้นเล็กน้อยให้เหมือนหนุนหมอน
function poseLying(fig, female) {
  // วัดสัดส่วนจากไฟล์: Armature_60 สะโพกกว้างกว่าอก = ร่างหญิง
  // Armature.001_121 อกกว้างเท่าสะโพก = ร่างชาย (เดิมสลับกันอยู่)
  const male = findNode(fig, 'Armature.001_121');
  const fem = findNode(fig, 'Armature_60');
  if (male) male.visible = !female;
  if (fem) fem.visible = female;
  const body = female ? fem : male;
  fig.userData.body = body || fig;
  if (!body) return;
  // หุบแขนเข้าหาลำตัว: แกนกระดูกของ rig นี้ไม่ตรงไปตรงมา
  // จึงลองหมุนทุกแกน/ทุกมุม แล้วเลือกท่าที่ฝ่ามือต่ำสุด (= แขนแนบลำตัว)
  // ระยะกันชน: ฝ่ามือต้องอยู่ห่างแกนกลางอย่างน้อย 80% ของครึ่งช่วงไหล่
  const shL = bonePos(body, 'Collar.L');
  const shR = bonePos(body, 'Collar.R');
  const minGap = Math.abs(shR.x - shL.x) * 0.40;
  tuckArm(body, 'UpperArm.L', 'Palm.L', minGap);
  tuckArm(body, 'UpperArm.R', 'Palm.R', minGap);
  // ขยับแขน: มาหน้าลำตัวราว 18% ของช่วงไหล่ แล้วกางออกข้างอีก 45%
  const feetA = bonePos(body, 'Toes.L').add(bonePos(body, 'Toes.R'))
      .multiplyScalar(0.5);
  const upA = bonePos(body, 'Head').sub(feetA).normalize();
  const rightA = shR.clone().sub(shL).normalize();
  const frontA = new THREE.Vector3().crossVectors(upA, rightA).normalize();
  const span = Math.abs(shR.x - shL.x);
  const fwd = frontA.clone().multiplyScalar(span * 0.18);
  const outL = rightA.clone().multiplyScalar(-span * 0.45);
  const outR = rightA.clone().multiplyScalar(span * 0.45);
  pushArm(body, 'UpperArm.L', 'Palm.L', fwd.clone());
  pushArm(body, 'UpperArm.R', 'Palm.R', fwd.clone());
  // กางออกเป็นรอบที่สอง หมุนรอบแกนหน้าตรง ๆ จะได้กางได้มากตามที่ต้องการ
  abductArm(body, 'UpperArm.L', frontA, 28);
  abductArm(body, 'UpperArm.R', frontA, -28);
  // เข่างอนิด ๆ ไม่ให้แข็งทื่อ และเงยหน้าเหมือนหนุนหมอน
  bendBone(body, 'Shin.L', 6, 0, 0);
  bendBone(body, 'Shin.R', 6, 0, 0);
  bendBone(body, 'Neck', 18, 0, 0);
}

// กรอบจากตำแหน่งกระดูกทุกชิ้น — Box3.setFromObject ของ skinned mesh
// ให้กรอบท่า bind pose ไม่ใช่ท่าที่จัดแล้ว จึงเชื่อไม่ได้
function boneCloud(body) {
  const box = new THREE.Box3();
  const p = new THREE.Vector3();
  body.updateMatrixWorld(true);
  body.traverse(function (o) {
    if (!o.isBone) return;
    // กระดูกเป้า IK (KneeIK, ElbowIK, HandIK, LegIK) ลอยห่างตัวเป็นเมตร ไม่นับ
    if (o.name.indexOf('IK') >= 0) return;
    o.getWorldPosition(p);
    box.expandByPoint(p);
  });
  return box;
}

function bonePos(body, name) {
  const n = findNode(body, name);
  const p = new THREE.Vector3();
  if (n) n.getWorldPosition(p);
  return p;
}

function placeFigureOnBed(fig, bed) {
  const bb = bed.userData.box || new THREE.Box3().setFromObject(bed);
  const size = bb.getSize(new THREE.Vector3());
  const center = bb.getCenter(new THREE.Vector3());
  const bedLen = size.z;
  // กรอบเตียงรวมหัวเตียงสูง ~0.9 ม. ที่นอนจริงอยู่ราว 2/3 ของความสูงนั้น
  const mattressY = bb.min.y + size.y * 0.66;
  const body = fig.userData.body || fig;

  // ทิศของร่างวัดจากกระดูกจริง: ขึ้น = เชิงกราน→หัว, ขวา = ไหล่ซ้าย→ไหล่ขวา
  // หน้า = ขึ้น × ขวา  (rig ของ Sketchfab มีแกนซ้อนหลายชั้น เดาเอาไม่ได้)
  fig.rotation.set(0, 0, 0);
  fig.scale.setScalar(1);
  fig.position.set(0, 0, 0);
  fig.updateMatrixWorld(true);
  // แกนขึ้นวัดจากกลางเท้าถึงหัว (ทั้งตัว) ไม่ใช่เชิงกราน→หัว
  // เพราะกระดูกสันหลังของ rig โค้งไปหน้า ทำให้แกนเอียง ตัวเลยนอนเทเท้าจมที่นอน
  const head = bonePos(body, 'Head');
  const feet = bonePos(body, 'Toes.L').add(bonePos(body, 'Toes.R')).multiplyScalar(0.5);
  const shL = bonePos(body, 'Collar.L');
  const shR = bonePos(body, 'Collar.R');
  const up = head.clone().sub(feet).normalize();
  const right = shR.clone().sub(shL).normalize();
  const front = new THREE.Vector3().crossVectors(up, right).normalize();
  right.crossVectors(front, up).normalize();   // ให้ตั้งฉากกันพอดี
  // เป้าหมาย: หัวไป -Z (หัวเตียงชิดผนังหลัง) หน้าหงายขึ้น +Y
  const tUp = new THREE.Vector3(0, 0, -1);
  const tFront = new THREE.Vector3(0, 1, 0);
  const tRight = new THREE.Vector3().crossVectors(tFront, tUp).normalize();
  const src = new THREE.Matrix4().makeBasis(right, up, front);
  const dst = new THREE.Matrix4().makeBasis(tRight, tUp, tFront);
  const rot = dst.multiply(src.clone().invert());
  fig.quaternion.setFromRotationMatrix(rot);
  fig.updateMatrixWorld(true);

  // ย่อให้ยาว 82% ของเตียง วัดจากหัวถึงเท้าจากกระดูก (+ เผื่อกะโหลกกับปลายเท้า)
  const c1 = boneCloud(body);
  const len = (c1.max.z - c1.min.z) + 0.24;
  const k = (bedLen * 0.82) / Math.max(len, 0.001);
  fig.scale.setScalar(k);
  fig.updateMatrixWorld(true);

  // วางกึ่งกลางเตียง แผ่นหลังแตะที่นอน (กระดูกอยู่ในเนื้อ จึงยกขึ้นอีกนิด)
  const c2 = boneCloud(body);
  const cc = c2.getCenter(new THREE.Vector3());
  fig.position.x += center.x - cc.x;
  fig.position.z += center.z - cc.z;
  fig.position.y += mattressY + 0.10 - c2.min.y;
  fig.updateMatrixWorld(true);
}

// ---------------------------------------------- ร่างผู้ป่วยในมุมมองรายละเอียด
// ใช้หุ่นตัวเดียวกับที่นอนอยู่บนเตียง (มีกระดูก จัดท่าแล้ว ชาย/หญิงแยกกัน)
// แค่ห่อด้วยแกนหมุนไว้กลางตัว เพื่อให้ลากหมุนดูรอบตัวได้โดยไม่หลุดจากเตียง
const bodies = {};

function ensureBody(code, female) {
  if (bodies[code]) return;
  const bed = beds[code];
  const fig = figures[code];
  if (!bed || !fig || fig === 'loading') return;   // รอหุ่นโหลดเสร็จก่อน
  const body = fig.userData.body || fig;
  const cloud = boneCloud(body);
  const ctr = cloud.getCenter(new THREE.Vector3());
  const bs = cloud.getSize(new THREE.Vector3());

  const pivot = new THREE.Object3D();
  pivot.name = 'body_' + code;
  pivot.position.copy(ctr);
  scene.add(pivot);
  bed.attach(pivot);      // ยึดกับเตียง ขยับเตียงแล้วตามไปด้วย
  pivot.attach(fig);      // รักษาตำแหน่งเดิมของหุ่นไว้

  // หมุดอาการ: ยิงรังสีจากด้านบนลงมาหาผิวจริงของหุ่น แล้วปักไว้ตรงจุดที่โดน
  const marks = {
    head: [0.0, -0.40],     // หัวอยู่ทาง -Z (หัวเตียง)
    neck: [0.0, -0.31],
    chest: [0.08, -0.18],
    heart: [-0.06, -0.15],
    arm: [-0.34, 0.10],
    abdomen: [0.0, -0.03],
    belly: [0.03, 0.06],
    knee: [0.09, 0.22],
    ankle: [0.10, 0.40],
  };
  const rc = new THREE.Raycaster();
  fig.updateMatrixWorld(true);
  // จุดที่มีกระดูกอ้างอิงได้ ใช้ตำแหน่งกระดูกจริงเป็นจุดยิง (แขนกางแล้วยังตรง)
  const markBone = { arm: 'Forearm.L' };
  Object.keys(marks).forEach(function (k) {
    const m = marks[k];
    const from = new THREE.Vector3(m[0] * bs.x, bs.y * 1.5, m[1] * bs.z);
    if (markBone[k] && findNode(body, markBone[k])) {
      const bl = pivot.worldToLocal(bonePos(body, markBone[k]));
      from.set(bl.x, bs.y * 1.5, bl.z);
    }
    pivot.localToWorld(from);
    const down = new THREE.Vector3(0, -1, 0)
        .applyQuaternion(pivot.getWorldQuaternion(new THREE.Quaternion()));
    rc.set(from, down);
    const hit = rc.intersectObject(fig, true)[0];
    const o3 = new THREE.Object3D();
    if (hit) {
      const local = pivot.worldToLocal(hit.point.clone());
      local.y += bs.y * 0.05;     // ยกพ้นผิวนิดหนึ่ง จะได้ไม่จมเนื้อ
      o3.position.copy(local);
    } else {
      o3.position.set(m[0] * bs.x, bs.y * 0.45, m[1] * bs.z);
    }
    o3.name = 'mark_' + k;
    pivot.add(o3);
  });

  bodies[code] = pivot;
  markDirty(8);
}

// เพศของผู้ป่วยแต่ละเตียง (ส่งมาจากแอปใน erSetBeds)
const femaleBy = {};
function femaleOf(code) {
  return !!femaleBy[code];
}

// หาตัวหุ่น (ลูกที่เป็น figure_*) ในแกนหมุน
function skinOf(pivot) {
  return pivot.children.filter(function (c) {
    return c.name.indexOf('figure_') === 0;
  })[0];
}

// ------------------------------------------------ ชั้นกายวิภาค
// กระดูก อวัยวะ เส้นเลือด จาก BodyParts3D (หน่วยมิลลิเมตร แกน Z = เท้า→หัว
// ด้านหน้าของลำตัวคือ -Y) วางทับหุ่นโดยเทียบจากกระดูกของหุ่นเอง
const LAYER_FILES = {
  bone: 'layer_bone.glb',
  organ: 'layer_organ.glb',
  vessel: 'layer_vessel.glb',
  // อวัยวะแยกชิ้น ใช้เป็นชั้นย่อยที่เปิดเฉพาะตอนเน้นตามอาการ
  brain: 'organ_brain.glb',
  heart: 'organ_heart.glb',
  lungs: 'organ_lungs.glb',
  liver: 'organ_liver.glb',
  stomach: 'organ_stomach.glb',
  kidneys: 'organ_kidneys.glb',
  intestine: 'organ_intestine.glb',
  bladder: 'organ_bladder.glb',
};
const LAYER_COLOR = { bone: 0xC9B078, organ: 0xC4443A, vessel: 0xA51B20 };
// สีเรืองแสงของอวัยวะที่ถูกเน้น
const HI_COLOR = 0xE8261C;
// อวัยวะที่กำลังเน้นตามอาการ (ชื่อใน LAYER_FILES)
let hiSet = new Set();
// กรอบของร่าง BodyParts3D เต็มตัว (มม.) วัดจาก er_body_skin.glb
// ชั้นในแต่ละชั้นไม่ได้ครบทั้งตัว (กระดูก/อวัยวะ ไม่มีขา) จึงต้องอ้างกรอบนี้แทน
const BP3D_REF = {
  min: new THREE.Vector3(-333.92, -246.57, -78.08),
  max: new THREE.Vector3(332.61, 44.90, 1641.36),
  size: new THREE.Vector3(666.53, 291.47, 1719.44),
  ctr: new THREE.Vector3(-0.66, -100.84, 781.64),
};
// ปรับละเอียด เป็นสัดส่วนของความสูงร่าง (+z = เลื่อนไปทางหัว, +y = ไปทางหน้า)
const LAYER_TUNE = { k: 1.0, x: 0.0, y: 0.0, z: 0.0 };
const layerCache = {};
let layerWant = 'skin';

// สร้างเมทริกซ์แปลงจากพิกัด BodyParts3D → พิกัดภายในของหุ่น
// โดยเทียบแกนจากกระดูกจริง (เท้า→หัว, ไหล่ซ้าย→ไหล่ขวา) และจับกระหม่อมชนกัน
function bp3dToFigure(fig) {
  const body = fig.userData.body || fig;
  fig.updateMatrixWorld(true);
  const toLocal = function (v) { return fig.worldToLocal(v.clone()); };
  const head = toLocal(bonePos(body, 'Head'));
  const feet = toLocal(bonePos(body, 'Toes.L'))
      .add(toLocal(bonePos(body, 'Toes.R'))).multiplyScalar(0.5);
  const shL = toLocal(bonePos(body, 'Collar.L'));
  const shR = toLocal(bonePos(body, 'Collar.R'));
  const up = head.clone().sub(feet);
  const span = up.length();
  if (span < 0.0001) return null;
  up.normalize();
  const right = shR.clone().sub(shL).normalize();
  const front = new THREE.Vector3().crossVectors(up, right).normalize();
  right.crossVectors(front, up).normalize();

  // กระดูกหัวอยู่กลางกะโหลก ปลายเท้าอยู่ต่ำกว่ากระดูกนิ้วเท้าเล็กน้อย
  // เผื่อหัวท้ายให้เป็นความสูงจริงราว 1.14 เท่าของช่วงกระดูก
  const h = span * 1.14 * LAYER_TUNE.k;
  const k = h / BP3D_REF.size.z;
  const crown = head.clone().add(up.clone().multiplyScalar(span * 0.09));

  // BodyParts3D หันหน้าไป -Y ส่วนแกน front ของหุ่นคือ +  จึงหมุนรอบแกนยาว 180°
  // (หมุนจริง ไม่ใช่การกลับด้าน ซ้าย-ขวาจึงยังถูกข้าง — ตับ/หัวใจไม่สลับฝั่ง)
  const basis = new THREE.Matrix4().makeBasis(right, front, up);
  const m = basis.multiply(new THREE.Matrix4().makeRotationZ(Math.PI));
  const q = new THREE.Quaternion().setFromRotationMatrix(m);

  // จุดกระหม่อมของ BodyParts3D → กระหม่อมของหุ่น
  const src = new THREE.Vector3(BP3D_REF.ctr.x, BP3D_REF.ctr.y, BP3D_REF.max.z)
      .multiplyScalar(k).applyQuaternion(q);
  const pos = crown.clone().sub(src)
      .add(right.clone().multiplyScalar(h * LAYER_TUNE.x))
      .add(front.clone().multiplyScalar(h * LAYER_TUNE.y))
      .add(up.clone().multiplyScalar(h * LAYER_TUNE.z));
  return { q: q, k: k, pos: pos };
}

function ensureLayer(code, name) {
  if (name === 'bone') return ensureSkeleton(code);
  const pivot = bodies[code];
  if (!pivot || pivot === 'loading') return;
  pivot.userData.layers = pivot.userData.layers || {};
  if (pivot.userData.layers[name]) return;
  pivot.userData.layers[name] = 'loading';
  // อวัยวะที่ไม่ได้ลงไว้ใน LAYER_FILES โหลดตามชื่อ organ_<id>.glb
  const file = LAYER_FILES[name] || ('organ_' + name + '.glb');
  const get = layerCache[file]
      ? Promise.resolve(layerCache[file])
      : fetch(file).then(function (r) { return r.arrayBuffer(); })
          .then(function (b) { layerCache[file] = b; return b; });
  get.then(function (buf) {
    new THREE.GLTFLoader().parse(buf, '', function (gltf) {
      const obj = gltf.scene;
      obj.traverse(function (m) {
        if (!m.isMesh) return;
        if (m.geometry && !m.geometry.attributes.normal) {
          m.geometry.computeVertexNormals();
        }
        m.frustumCulled = false;
        m.material = new THREE.MeshStandardMaterial({
          color: LAYER_COLOR[name] || 0xCCCCCC,
          roughness: 0.8, metalness: 0.0,
        });
      });
      const fig = skinOf(pivot);
      const fit = fig ? bp3dToFigure(fig) : null;
      if (!fig || !fit) {
        pivot.userData.layers[name] = null;
        send({ type: 'error', message: 'layer fit: no figure' });
        return;
      }
      // ผูกกับตัวหุ่น ชั้นในจะได้ขยับ/หมุนไปพร้อมกับร่างเสมอ
      fig.add(obj);
      obj.quaternion.copy(fit.q);
      obj.scale.setScalar(fit.k);
      obj.position.copy(fit.pos);
      obj.updateMatrix();
      obj.name = 'layer_' + name;
      obj.userData.fade = 0;
      obj.visible = false;
      pivot.userData.layers[name] = obj;
      applyLayer();
      markDirty(8);
    }, function (err) {
      pivot.userData.layers[name] = null;
      send({ type: 'error', message: 'layer: ' + String(err) });
    });
  });
}

// ------------------------------------------------ หุ่นผิวจริง (ThaiWell)
// หน้ารายละเอียดใช้หุ่นผิวจริง (body_male + normal/AO map) แทนหุ่นใส่ชุดผู้ป่วย
// วางด้วย bp3dToFigure ชุดเดียวกับชั้นใน จึงซ้อนกับกระดูก/อวัยวะได้
// สายรัดข้อมือยังผูกกับกระดูกของหุ่นเดิม (ซ่อนแค่ผิวที่เป็น skinned mesh)
const ANAT_SKIN = 0xC98F6E;     // สีผิวหุ่นของ ThaiWell (skin.model)
const ANAT_SKIN_SOFT = 0xEBA683; // สีผิวแบบภาพหุ่นสแกนใบหน้า (ใช้กับแสงนุ่ม)
const ANAT_CLOTH = 0x3E5361;    // กางเกงขาสั้น/เสื้อกล้าม (garment.base)
// ไฟล์ของแต่ละเพศ · ผู้หญิงใส่เสื้อกล้ามสั้นเพิ่ม (แอปต้นทางไม่มีเสื้อผ้า)
const ANAT_SET = {
  m: { glb: 'anat.glb', n: 'anat_n.jpg', ao: 'anat_ao.jpg', top: false, wx: 1.0 },
  f: { glb: 'anat_f.glb', n: 'anat_f_n.jpg', ao: 'anat_f_ao.jpg', top: true, wx: 0.954 },
};
// ความสูงอ้างอิงของค่าช่วงเสื้อผ้า/ข้อต่อ (หุ่นชาย ThaiWell สูง 1.69 ม.)
const ANAT_REF_H = 1.690071;
const anatBuf = {};
const anatMaps = {};

// พิกัดเท้าและความสูงของผิว เก็บไว้ใน extras ของ node bp3d_frame ตอนสร้างไฟล์
function anatFrameInfo(obj) {
  const f = obj.getObjectByName('bp3d_frame');
  const u = (f && f.userData) || {};
  return { feetY: u.feetY || 0, h: u.height || ANAT_REF_H };
}

function anatTex(url) {
  const t = new THREE.TextureLoader().load(url, function () { markDirty(4); });
  t.flipY = false;   // UV ของ glTF ไม่กลับแนวตั้ง
  return t;
}

// แสงนุ่มแบบภาพหุ่นสแกนใบหน้า (2026-11-26 แทน toon 3 ระดับ + เส้นขอบ): พิกัดกล้อง = ทิศแสงคงที่แบบสตูดิโอ
// ไฟหลักเฉียงบนขวา + ไฟเติมซ้าย + ขอบตามมุมมอง + แสงรอบตัว · AO ของหุ่น (ถ้ามี) คูณทับ
// ไม่ใช้แสงห้อง: ผิวไม่ซีดตาม ACES/ไฟเพดาน สีคงเดิมทุกฉาก
// spec/shin = ความเงา (Blinn-Phong ไฟหลัก + ขอบ fresnel) · ผิว = เงานุ่มแบบผิวคน · ผ้า = เบามาก
function anatSoftLight(spec, shin) {
  return 'vec3 sn = normalize(normal);\n' +
    'vec3 sv = normalize(-vViewPosition);\n' +
    'vec3 sL = normalize(vec3(0.45, 0.55, 0.70));\n' +
    'float sk = max(dot(sn, sL), 0.0);\n' +
    'float sf = max(dot(sn, normalize(vec3(-0.70, 0.15, 0.55))), 0.0);\n' +
    'float sr = pow(1.0 - max(dot(sn, sv), 0.0), 3.0);\n' +
    'float sao = 1.0;\n' +
    '#ifdef USE_AOMAP\n' +
    'sao = (texture2D(aoMap, vUv2).r - 1.0) * aoMapIntensity + 1.0;\n' +
    '#endif\n' +
    // สี hex เป็นค่า sRGB: แปลงเป็น linear ก่อนคิดแสง (ไม่งั้น output sRGB ยกสีจนซีดจืด)
    'float sl = (0.50 + 0.58 * sk + 0.18 * sf) * sao + 0.10 * sr;\n' +
    // ไฮไลต์สะท้อนแสง: จุดเงาบนโหนกแก้ม จมูก หน้าผาก ไหล่ (ตามไฟหลัก) + ขอบเงานิดตามมุมมอง
    'float sp = pow(max(dot(sn, normalize(sL + sv)), 0.0), ' + shin.toFixed(1) + ') * ' + spec.toFixed(3) + ' * sao;\n' +
    'outgoingLight = pow(diffuseColor.rgb, vec3(2.2)) * sl + vec3(sp + ' + (spec * 0.35).toFixed(3) + ' * sr);\n' +
    'gl_FragColor = vec4( outgoingLight, diffuseColor.a );';
}
const ANAT_SOFT_LIGHT = anatSoftLight(0.42, 26.0);
const ANAT_CLOTH_LIGHT = anatSoftLight(0.10, 14.0);
let anatRamp = null;
function anatToonRamp() {
  if (anatRamp) return anatRamp;
  const d = new Uint8Array([150, 150, 150, 255, 215, 215, 215, 255, 255, 255, 255, 255]);
  anatRamp = new THREE.DataTexture(d, 3, 1, THREE.RGBAFormat);
  anatRamp.minFilter = anatRamp.magFilter = THREE.NearestFilter;
  anatRamp.needsUpdate = true;
  return anatRamp;
}

// วัสดุผิว: toon flat + ระบายเสื้อผ้าลงบนผิวโดยตรง
// ตำแหน่งในพิกัดหุ่น (เมตร) ย่อ/ขยายตามความสูง ให้ใช้ค่าช่วงชุดเดียวกับหุ่นชาย 1.69 ม.
// ใส่/ถอดเสื้อผ้าบนผิว (studio ตรวจร่างกาย = ถอด) · uniform ร่วมทุกวัสดุผิวในหน้านี้
const clothU = { value: 1.0 };
window.erCloth = function (on) { clothU.value = on ? 1.0 : 0.0; markDirty(6); };
// rest = true: ระบายเสื้อผ้าตามพิกัดท่ายืนเดิม (attribute 'rest') ใช้กับหุ่นที่จัดท่าแล้ว (นั่ง)
// กางเกงจึงอยู่ที่สะโพก/ต้นขาเหมือนท่ายืน ไม่เลื่อนตามความสูงหลังพับขา
// gown = true: ชุดคนไข้ (เสื้อแขนสั้นคอวี + กางเกงขายาว สีฟ้า) แทนกางเกงขาสั้น · ใช้กับหุ่นนั่งรอ
function anatSkinMat(key, info, rest, gown) {
  const set = ANAT_SET[key];
  // ผิวแบบภาพหุ่นสแกนใบหน้า: normal + AO ของหุ่น แสงนุ่ม (ANAT_SOFT_LIGHT) ไม่แบ่งเฉด
  if (!anatMaps[key]) anatMaps[key] = { n: anatTex(set.n), ao: anatTex(set.ao) };
  const mat = new THREE.MeshToonMaterial({
    // สีผิวเดียวกับภาพหุ่นสแกนใบหน้า (#E9A27C) · สีเดิมของหุ่น (#C98F6E) พอคิดแสงแบบ linear แล้วเข้มเกินจริง
    color: ANAT_SKIN_SOFT, gradientMap: anatToonRamp(),
    normalMap: anatMaps[key].n, normalScale: new THREE.Vector2(0.8, 0.8),
    aoMap: anatMaps[key].ao, aoMapIntensity: 0.85,
  });
  // ไม่ผ่าน ACES: สีผิวตรงตามภาพ GCS
  mat.toneMapped = false;
  const shorts = new THREE.Color(ANAT_CLOTH);
  const ky = (ANAT_REF_H / info.h).toFixed(5);
  // เสื้อกล้ามสั้น (หุ่นหญิง): ใต้อก→เหนืออก รอบลำตัว ไม่โดนแขน
  const shirt = new THREE.Color(0x9ec5e3), pants = new THREE.Color(0x7fa6cc);
  const vc = function (c) { return 'vec3(' + c.r.toFixed(4) + ', ' + c.g.toFixed(4) + ', ' + c.b.toFixed(4) + ')'; };
  // ชุดคนไข้ระบายตามพิกัดท่ายืน (แขนกาง A-pose): แขน = |x| เกิน ~0.18 ที่ระดับอก
  const gownSrc = gown
    ? 'float ax = abs(vBodyPos.x), gy = vBodyPos.y;\n' +
      // เสื้อ: เอว 0.80 ถึงคอ 1.47 · แขนสั้นครึ่งต้นแขน (ต่ำกว่า 1.22 = ผิว)
      'float sh = smoothstep(0.80, 0.806, gy) * (1.0 - smoothstep(1.47, 1.476, gy));\n' +
      'float onArm = smoothstep(0.17, 0.19, ax);\n' +
      'sh *= 1.0 - onArm * (1.0 - smoothstep(1.215, 1.225, gy));\n' +
      // คอวีด้านหน้า
      // ลึกกว่าคอวีของชุดผ้า (1.33 + 1.25|x|) เล็กน้อย: ชุดระบายไม่โผล่ในช่องคอเสื้อผ้า
      'float vy = 1.30 + 1.25 * ax;\n' +
      'sh *= 1.0 - step(0.0, vBodyPos.z) * smoothstep(vy - 0.004, vy + 0.004, gy);\n' +
      // กางเกง: เอวถึงข้อเท้า เฉพาะช่วงขา (มือ A-pose อยู่นอก |x| 0.27)
      'float pt = (1.0 - smoothstep(0.22, 0.235, ax)) * smoothstep(0.10, 0.106, gy) * (1.0 - smoothstep(0.95, 0.956, gy));\n' +
      'vec3 cs = ' + vc(shirt) + ', cp = ' + vc(pants) + ';\n' +
      // ขอบชาย/แขนเสื้อ/ปลายขากางเกงเข้มลงนิด
      'cs *= 1.0 - 0.14 * (1.0 - smoothstep(0.815, 0.82, gy)) - 0.14 * onArm * (1.0 - smoothstep(1.235, 1.24, gy));\n' +
      'cp *= 1.0 - 0.14 * (1.0 - smoothstep(0.12, 0.125, gy));\n' +
      'vec3 gcol = mix(cp, cs, sh);\n' +
      'diffuseColor.rgb = mix(diffuseColor.rgb, gcol, max(sh, pt) * uCloth);'
    : null;
  const top = set.top
    ? 'float tIn = (1.0 - smoothstep(0.155, 0.17, abs(vBodyPos.x)))' +
      ' * smoothstep(1.095, 1.105, vBodyPos.y) * (1.0 - smoothstep(1.285, 1.295, vBodyPos.y));\n' +
      'gShorts = max(gShorts, tIn);\n'
    : '';
  mat.onBeforeCompile = function (sh) {
    sh.uniforms.uCloth = clothU;
    sh.vertexShader = sh.vertexShader
      .replace('#include <common>', '#include <common>\nvarying vec3 vBodyPos;' +
          (rest ? '\nattribute vec3 rest;' : ''))
      .replace('#include <begin_vertex>',
          '#include <begin_vertex>\nvec3 bp = ' + (rest ? 'rest' : 'position') +
          ';\nvBodyPos = vec3(bp.x, (bp.y - (' +
          info.feetY.toFixed(6) + ')) * ' + ky + ', bp.z);');
    sh.fragmentShader = sh.fragmentShader
      .replace('#include <common>', '#include <common>\nvarying vec3 vBodyPos;\nfloat gShorts;\nuniform float uCloth;')
      .replace('#include <color_fragment>', gownSrc
          ? '#include <color_fragment>\n' + gownSrc
          : '#include <color_fragment>\n' +
          'float sInX = 1.0 - smoothstep(0.2, 0.215, abs(vBodyPos.x));\n' +
          'float hem = 0.67 + 0.03 * (1.0 - smoothstep(0.03, 0.09, abs(vBodyPos.x)));\n' +
          'gShorts = sInX * smoothstep(hem - 0.004, hem + 0.004, vBodyPos.y)' +
          ' * (1.0 - smoothstep(0.946, 0.954, vBodyPos.y));\n' +
          'vec3 fabric = vec3(' + shorts.r.toFixed(4) + ', ' + shorts.g.toFixed(4) +
          ', ' + shorts.b.toFixed(4) + ');\n' +
          'float band = smoothstep(0.916, 0.92, vBodyPos.y)' +
          ' + (1.0 - smoothstep(hem + 0.014, hem + 0.018, vBodyPos.y));\n' +
          'fabric *= 1.0 - 0.18 * clamp(band, 0.0, 1.0);\n' +
          top +
          'diffuseColor.rgb = mix(diffuseColor.rgb, fabric, gShorts * uCloth);')
      // แสงนุ่มแบบภาพหุ่นสแกนใบหน้า (ไม่ใช้แสงห้อง ผิวจึงไม่ซีด)
      .replace('gl_FragColor = vec4( outgoingLight, diffuseColor.a );', ANAT_SOFT_LIGHT);
  };
  mat.customProgramCacheKey = function () { return 'anat-skin-soft3-' + key + (rest ? '-rest' : '') + (gown ? '-gown' : ''); };
  return mat;
}

// ข้อต่อของหุ่นผิวจริง (เมตร เท้าที่ y=0 +x = ซ้ายของผู้ป่วย) จาก LANDMARK ใน Body3D ของ ThaiWell
// จับคู่กับชื่อกระดูก rig ที่ LIMB_FIT ใช้ (.L = ซ้ายของผู้ป่วย)
const ANAT_JOINT = {
  'UpperArm.L': [0.235, 1.34, -0.01], 'UpperArm.R': [-0.235, 1.34, -0.01],
  'Forearm.L': [0.3, 1.08, 0], 'Forearm.R': [-0.3, 1.08, 0],
  'Palm.L': [0.375, 0.88, 0.067], 'Palm.R': [-0.375, 0.88, 0.067],
  'Middle3.L': [0.42, 0.77, 0.11], 'Middle3.R': [-0.42, 0.77, 0.11],
  'Hip.L': [0.09, 0.87, 0.02], 'Hip.R': [-0.09, 0.87, 0.02],
  'Shin.L': [0.13, 0.47, -0.01], 'Shin.R': [-0.13, 0.47, -0.01],
  'Foot.L': [0.17, 0.09, -0.055], 'Foot.R': [-0.17, 0.09, -0.055],
  'Toes.L': [0.21, 0.015, 0.1], 'Toes.R': [-0.21, 0.015, 0.1],
};

// ---- ท่านอน: แขนแนบลำตัว (ต้นฉบับกางแขนแบบ A-pose)
// หมุนแขนรอบข้อไหล่ในระนาบหน้า (แกน z) เข้าหาลำตัว ทำงานในพิกัด LANDMARK ของหุ่นชาย
const ANAT_ARM_DEG = 15;
const ANAT_SHOULDER = [0.2, 1.36];   // จุดหมุน (x ข้างซ้าย, y)

// ขอบลำตัวด้านข้างตามความสูง: จุดที่ |x| เกินนี้นับเป็นแขน (ไล่น้ำหนักช่วง 4 ซม.)
function anatArmWeight(X, Y) {
  if (Y > 1.48 || Y < 0.6) return 0;
  // หัวไหล่/รักแร้ 0.16 · เอว 0.15 · สะโพก/ต้นขา 0.21 (มืออยู่นอกต้นขา)
  const b = Y > 1.2 ? 0.16 : Y > 1.0 ? 0.15 : 0.21;
  const t = (Math.abs(X) - b) / 0.04;
  const w = Math.min(1, Math.max(0, t));
  return w * w * (3 - 2 * w);
}

// หมุนจุด (X, Y) ของแขนเข้าหาลำตัวตามน้ำหนัก w (พิกัด LANDMARK)
function anatArmMove(X, Y, w) {
  if (w <= 0) return [X, Y];
  const s = X >= 0 ? 1 : -1;
  const a = -s * ANAT_ARM_DEG * Math.PI / 180 * w;
  const px = s * ANAT_SHOULDER[0], py = ANAT_SHOULDER[1];
  const dx = X - px, dy = Y - py;
  const c = Math.cos(a), n = Math.sin(a);
  return [px + dx * c - dy * n, py + dx * n + dy * c];
}

// จัดท่าแขนบน geometry ของผิว (พิกัด mesh: เมตร เท้าที่ feetY)
function anatPoseArms(g, set, info) {
  const p = g.attributes.position;
  const nrm = g.attributes.normal;
  const ky = info.h / ANAT_REF_H;
  for (let i = 0; i < p.count; i++) {
    const X = p.getX(i) / set.wx, Y = (p.getY(i) - info.feetY) / ky;
    const w = anatArmWeight(X, Y);
    if (w <= 0) continue;
    const q = anatArmMove(X, Y, w);
    p.setXY(i, q[0] * set.wx, q[1] * ky + info.feetY);
    if (nrm) {
      const a = -(X >= 0 ? 1 : -1) * ANAT_ARM_DEG * Math.PI / 180 * w;
      const nx = nrm.getX(i), ny = nrm.getY(i);
      nrm.setXY(i, nx * Math.cos(a) - ny * Math.sin(a), nx * Math.sin(a) + ny * Math.cos(a));
    }
  }
  p.needsUpdate = true;
  if (nrm) nrm.needsUpdate = true;
  g.computeBoundingBox();
  g.computeBoundingSphere();
}

// ข้อต่อของหุ่นผิวจริงในพิกัดของตัวหุ่น (fig) · null = ยังไม่ได้โหลดหุ่นผิวจริง
function anatJointLocal(fig) {
  const anat = fig.userData.anat;
  if (!anat || anat === 'loading') return null;
  // พิกัด LANDMARK = พิกัดของ mesh ผิว (ใหญ่สุด) ซึ่งจัดกลาง x ไว้แล้วในไฟล์
  let frame = null;
  anat.traverse(function (m) {
    if (!m.isMesh || /eye/i.test(m.name)) return;
    if (!frame || m.geometry.attributes.position.count >
        frame.geometry.attributes.position.count) frame = m;
  });
  if (!frame) return null;
  // LANDMARK วัดจากเท้า = 0 บนหุ่นชาย 1.69 ม. · หุ่นหญิงย่อตามความสูง/ความกว้าง
  const info = anatFrameInfo(anat);
  const set = ANAT_SET[anat.userData.key] || ANAT_SET.m;
  const ky = info.h / ANAT_REF_H;
  anat.updateMatrixWorld(true);
  const out = {};
  Object.keys(ANAT_JOINT).forEach(function (n) {
    const j = ANAT_JOINT[n];
    // แขนถูกหมุนแนบลำตัวแล้ว ข้อต่อแขนต้องหมุนตาม (ข้อไหล่เป็นจุดหมุน ไม่ขยับ)
    const arm = /^(Forearm|Palm|Middle3)\./.test(n);
    const q = arm ? anatArmMove(j[0], j[1], 1) : [j[0], j[1]];
    const v = new THREE.Vector3(q[0] * set.wx, q[1] * ky + info.feetY, j[2])
        .applyMatrix4(frame.matrixWorld);
    out[n] = fig.worldToLocal(v);
  });
  return out;
}

// ตา: ระบายตาขาว ม่านตา รูม่านตาด้วยสีจุดยอด (มองไป +z ในพิกัดของหุ่น)
// ---- กระพริบตา: เปลือกตา (ทรงรีสีผิว ครอบลูกตา) ซ่อนอยู่ · ถึงรอบ = ยืดลงปิดแล้วเปิดใน ~0.42 วิ
// สุ่มรอบละ 4.5–8 วิ ทุกหุ่นกระพริบพร้อมกันไม่ได้ (สุ่มแยกต่อตา คู่ซ้าย-ขวาใช้รอบเดียวกันตามหุ่น)
const blinkLids = [];
let blinkGeo = null, blinkMat = null;
function addEyelid(eye, male) {
  if (!blinkGeo) {
    blinkGeo = new THREE.SphereGeometry(1, 20, 14);
    // สีเดียวกับผิวแสงนุ่ม (ANAT_SKIN_SOFT) ไม่ใช้แสงห้อง · ค่า hex เป็น sRGB = แปลง linear ก่อน
    // (ไม่งั้นจอยกสีจนซีด) · เข้มลงนิดเป็นเงาเปลือกตา (คูณใน linear: 0.88 บนจอ ≈ 0.755)
    blinkMat = new THREE.MeshBasicMaterial({ color: new THREE.Color(ANAT_SKIN_SOFT).convertSRGBToLinear().multiplyScalar(0.755) });
    blinkMat.toneMapped = false;
  }
  const g = eye.geometry;
  if (!g.boundingBox) g.computeBoundingBox();
  const c = g.boundingBox.getCenter(new THREE.Vector3());
  // หญิง = ค่าเดิมที่พอดีแล้ว · ชาย = ลูกตาใหญ่กว่า ย่อ + แบนลง ไม่โป่งเกินเบ้าตา
  // ต้องใหญ่กว่าลูกตา (ครึ่งขนาด = รัศมี) ทุกแกนเล็กน้อย ไม่งั้นจมในลูกตามองไม่เห็น
  // ชาย: เบ้าตาลึก ผิวรอบตาตกเงาเข้ม · เปลือกตาพอดีลูกตา ไม่ล้นถึงคิ้ว
  const box = g.boundingBox.getSize(new THREE.Vector3());
  const sz = male
      ? new THREE.Vector3(box.x * 0.55, box.y * 0.52, box.z * 0.54)
      : box.clone().multiplyScalar(0.58);
  const lid = new THREE.Mesh(blinkGeo, blinkMat.clone());
  // ชาย: เบ้าตาลึก ผิวรอบตาตกเงาเข้มกว่า (0.80 บนจอ ≈ 0.61 linear)
  if (male) lid.material.color.copy(new THREE.Color(ANAT_SKIN_SOFT).convertSRGBToLinear().multiplyScalar(0.61));
  lid.name = 'anat_lid';
  lid.position.copy(c);
  lid.userData.base = sz;
  lid.scale.set(sz.x, 0.001, sz.z);
  lid.visible = false;
  lid.raycast = function () {};
  eye.add(lid);
  blinkLids.push(lid);
}
let blinkAt = performance.now() + 4500, blinkT0 = -1;
setInterval(function () {
  for (let i = blinkLids.length - 1; i >= 0; i--) {
    let o = blinkLids[i], live = false;
    while (o) { if (o === scene) { live = true; break; } o = o.parent; }
    if (!live) blinkLids.splice(i, 1);
  }
  if (!blinkLids.length) return;
  const now = performance.now();
  if (blinkT0 < 0 && now >= blinkAt) blinkT0 = now;
  if (blinkT0 < 0) return;
  // กระพริบช้า ๆ สบาย ๆ: ปิด-เปิดราว 0.42 วิ (ease นุ่มทั้งสองช่วง)
  const t = (now - blinkT0) / 420;
  // ปิดเร็ว เปิดช้ากว่านิด (0→1→0)
  const e = function (x) { return x * x * (3 - 2 * x); };
  const k = t >= 1 ? 0 : (t < 0.45 ? e(t / 0.45) : 1 - e((t - 0.45) / 0.55));
  blinkLids.forEach(function (l) {
    l.visible = k > 0.02;
    l.scale.y = Math.max(0.001, l.userData.base.y * k);
  });
  if (t >= 1) { blinkT0 = -1; blinkAt = now + 4500 + Math.random() * 3500; }
  markDirty(2);
}, 16);

function anatEyeMat(m) {
  const g = m.geometry;
  const p = g.attributes.position;
  const v = new THREE.Vector3();
  const pts = [];
  const ctr = new THREE.Vector3();
  for (let i = 0; i < p.count; i++) {
    v.fromBufferAttribute(p, i).applyMatrix4(m.matrix);
    pts.push(v.clone());
    ctr.add(v);
  }
  ctr.multiplyScalar(1 / Math.max(1, p.count));
  const sclera = new THREE.Color(0xEFE6DE), edge = new THREE.Color(0x3E2A1F);
  const iris = new THREE.Color(0x6A4A35), pupil = new THREE.Color(0x1B1310);
  const ramp = function (a, b, x) { return Math.min(1, Math.max(0, (x - a) / (b - a))); };
  const col = new THREE.Color();
  const out = new Float32Array(p.count * 3);
  for (let i = 0; i < p.count; i++) {
    const t = pts[i].sub(ctr).normalize().z;
    col.copy(sclera).lerp(edge, ramp(0.8, 0.83, t)).lerp(iris, ramp(0.84, 0.9, t))
        .lerp(pupil, ramp(0.955, 0.97, t));
    out[i * 3] = col.r; out[i * 3 + 1] = col.g; out[i * 3 + 2] = col.b;
  }
  g.setAttribute('color', new THREE.BufferAttribute(out, 3));
  return new THREE.MeshStandardMaterial({ vertexColors: true, roughness: 0.3, metalness: 0.0 });
}

// ผูกกับหุ่นของเตียง (figures[code]) ใช้ทั้งตอนนอนบนเตียงและในหน้ารายละเอียด
function ensureAnat(code, female) {
  const fig0 = figures[code];
  if (!fig0 || fig0 === 'loading' || fig0.userData.anat) return;
  fig0.userData.anat = 'loading';
  const key = female ? 'f' : 'm';
  const get = anatBuf[key]
      ? Promise.resolve(anatBuf[key])
      : fetch(ANAT_SET[key].glb).then(function (r) { return r.arrayBuffer(); })
          .then(function (b) { anatBuf[key] = b; return b; })
          .catch(function (e) { send({ type: 'error', message: 'anat fetch: ' + e }); throw e; });
  get.then(function (buf) {
    new THREE.GLTFLoader().parse(buf, '', function (gltf) {
      try {
      const fig = figures[code];
      const fit = fig && fig !== 'loading' ? bp3dToFigure(fig) : null;
      if (!fit) {
        if (fig && fig !== 'loading') fig.userData.anat = null;
        send({ type: 'error', message: 'anat fit: no figure' });
        return;
      }
      const obj = gltf.scene;
      obj.userData.key = key;
      obj.updateMatrixWorld(true);
      const info = anatFrameInfo(obj);
      let skinMesh = null;
      obj.traverse(function (m) {
        // เส้นขอบที่เพิ่งเพิ่มเป็นลูกของ mesh: ข้าม ไม่งั้นวนไม่จบ
        if (!m.isMesh || m.name === 'anat_line' || m.name === 'anat_lid') return;
        m.frustumCulled = false;
        m.castShadow = true;
        if (/eye/i.test(m.name)) {
          m.material = anatEyeMat(m);
          addEyelid(m, key === 'm');
          return;
        }
        // AO map ของ three r128 อ่านจาก uv2 ใช้ UV ชุดเดียวกัน
        const g = m.geometry;
        if (g.attributes.uv && !g.attributes.uv2) g.setAttribute('uv2', g.attributes.uv);
        // ชุดผู้ป่วยระบายบนผิว (ตามพิกัดท่ายืน) อยู่ใต้ชุดผ้า: ช่องว่างรักแร้/เอวของชุดผ้าเห็นเป็นสีเสื้อ ไม่ใช่ผิว
        if (!g.attributes.rest) g.setAttribute('rest', g.attributes.position.clone());
        anatPoseArms(g, ANAT_SET[key], info);
        m.material = anatSkinMat(key, info, true, true);
        m.userData.anat = { wx: ANAT_SET[key].wx, feet: info.feetY, ky: info.h / ANAT_REF_H };
        // เส้นขอบน้ำตาลเข้ม: ผิวด้านหลังพองออกเล็กน้อย (แบบภาพ GCS)
        const line = new THREE.Mesh(g, new THREE.MeshBasicMaterial({ color: 0x6B4434, side: THREE.BackSide }));
        line.material.onBeforeCompile = function (sh) {
          sh.vertexShader = sh.vertexShader.replace('#include <begin_vertex>', 'vec3 transformed = position + normal * ' + (info.h * 0.0024).toFixed(6) + ';');
        };
        line.name = 'anat_line';
        line.visible = false; // แสงนุ่มแบบภาพหุ่นสแกนใบหน้า: ไม่มีเส้นขอบ toon
        m.add(line);
        skinMesh = m;
      });
      // ชุดผู้ป่วย (ไฟล์เดียวกับคนนั่งรอ) จัดแขนแนบตัวเหมือนผิว ผูกใต้ mesh ผิว = พิกัดเดียวกัน
      if (skinMesh) {
        const sm = skinMesh;
        loadProp('clothes_' + key + '.glb').then(function (cl) {
          if (!sm.parent) return;
          anatDress(cl, info, function (geo) { anatPoseArms(geo, ANAT_SET[key], info); })
            .forEach(function (c) { sm.add(c); });
          applyLayer();
          markDirty(8);
        }, function (e) { send({ type: 'error', message: 'bed clothes: ' + e }); });
      }
      fig.add(obj);
      obj.quaternion.copy(fit.q);
      obj.scale.setScalar(fit.k);
      obj.position.copy(fit.pos);
      obj.name = 'anat_skin';
      fig.userData.anat = obj;
      anatWristband(fig);
      renderer.shadowMap.needsUpdate = true;
      // โครงกระดูกที่สร้างไว้ก่อนวางตาม rig เดิม → สร้างใหม่ให้ตามข้อต่อของหุ่นนี้
      const pivot = bodies[code];
      const L = pivot && pivot !== 'loading' ? pivot.userData.layers : null;
      if (L && L.bone && L.bone !== 'loading') {
        if (L.bone.parent) L.bone.parent.remove(L.bone);
        delete L.bone;
        ensureSkeleton(code);
      }
      syncAnat();
      applyLayer();
      markDirty(8);
      } catch (e) { send({ type: 'error', message: 'anat: ' + e + ' ' + (e.stack || '').split('\n')[1] }); }
    }, function (err) {
      const f = figures[code];
      if (f && f !== 'loading') f.userData.anat = null;
      send({ type: 'error', message: 'anat: ' + String(err) });
    });
  });
}

// หุ่นผิวจริงพร้อมแล้ว: ซ่อนผิวหุ่นเดิม (skinned mesh) ทั้งบนเตียงและในหน้ารายละเอียด
function syncAnat() {
  Object.keys(figures).forEach(function (c) {
    const fig = figures[c];
    if (!fig || fig === 'loading') return;
    const anat = fig.userData.anat;
    const ready = !!anat && anat !== 'loading';
    if (!ready) return;
    anat.visible = true;
    fig.traverse(function (m) {
      if (m.isSkinnedMesh) m.visible = false;
    });
  });
}

// สายรัดข้อมือ ESI: ย้ายจากกระดูกฝ่ามือของหุ่นเดิมมาที่ข้อมือซ้ายของหุ่นผิวจริง
// วางเหนือข้อมือเล็กน้อย แกนสายตามแนวแขน (ข้อศอก→ข้อมือ)
function anatWristband(fig) {
  const band = fig.userData.bandObj;
  const j = anatJointLocal(fig);
  if (!band || !j) return;
  const wrist = j['Palm.L'], elbow = j['Forearm.L'];
  if (!wrist || !elbow) return;
  fig.add(band);
  const axis = wrist.clone().sub(elbow);
  band.position.copy(wrist).add(axis.clone().multiplyScalar(-0.1));
  band.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), axis.normalize());
  // ขนาดสายเป็นเมตรจริง หักสเกลของตัวหุ่นออก
  fig.updateMatrixWorld(true);
  const ws = fig.getWorldScale(new THREE.Vector3());
  band.scale.set(1 / ws.x, 1 / ws.y, 1 / ws.z);
  band.visible = true;
}


// ------------------------------------------------ หน้าต่างเอกซเรย์บนผิว
// ผิวทึบทั้งตัว เจาะโปร่งเฉพาะรอบจุดที่บาดเจ็บ (แคปซูลตามแนวกระดูก/อวัยวะ)
// หนึ่งเคสมีได้หลายจุด สูงสุด XR_MAX หน้าต่าง
const XR_MAX = 8;
const XR = {
  xrA: { value: Array.from({ length: XR_MAX }, function () { return new THREE.Vector3(); }) },
  xrB: { value: Array.from({ length: XR_MAX }, function () { return new THREE.Vector3(); }) },
  xrR: { value: new Array(XR_MAX).fill(0) },
  xrN: { value: 0 },
};
function patchXray(mat) {
  if (mat.userData.xrPatched) return;
  mat.userData.xrPatched = true;
  // ต่อจาก shader เดิมของวัสดุ (เช่น กางเกงบนผิวหุ่น) ไม่เขียนทับ
  const prev = mat.onBeforeCompile;
  // แยก cache ของ shader ตามวัสดุเดิม (ไม่งั้นหุ่นเดิมกับหุ่นใหม่ใช้โปรแกรมเดียวกัน)
  const prevKey = mat.customProgramCacheKey.call(mat);
  mat.customProgramCacheKey = function () { return prevKey + '|xr'; };
  mat.onBeforeCompile = function (sh, r) {
    if (prev) prev.call(mat, sh, r);
    sh.uniforms.xrA = XR.xrA; sh.uniforms.xrB = XR.xrB;
    sh.uniforms.xrR = XR.xrR; sh.uniforms.xrN = XR.xrN;
    sh.vertexShader = sh.vertexShader
      .replace('#include <common>', '#include <common>\nvarying vec3 vXrW;')
      .replace('#include <project_vertex>',
          '#include <project_vertex>\nvXrW = (modelMatrix * vec4(transformed, 1.0)).xyz;');
    sh.fragmentShader = sh.fragmentShader
      .replace('#include <common>', '#include <common>\nvarying vec3 vXrW;\n' +
          'uniform vec3 xrA[' + XR_MAX + '];\nuniform vec3 xrB[' + XR_MAX + '];\n' +
          'uniform float xrR[' + XR_MAX + '];\nuniform int xrN;')
      .replace('#include <dithering_fragment>',
          '#include <dithering_fragment>\n' +
          'float xr = 1.0;\n' +
          'for (int i = 0; i < ' + XR_MAX + '; i++) {\n' +
          '  if (i >= xrN) break;\n' +
          '  vec3 pa = vXrW - xrA[i]; vec3 ba = xrB[i] - xrA[i];\n' +
          '  float h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-6), 0.0, 1.0);\n' +
          '  float d = length(pa - ba * h);\n' +
          '  xr = min(xr, smoothstep(xrR[i] * 0.7, xrR[i] * 1.12, d));\n' +
          '}\n' +
          'float edge = (1.0 - xr) * xr * 4.0;\n' +
          'gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(0.62, 0.80, 1.0), (1.0 - xr) * 0.45 + edge * 0.35);\n' +
          'gl_FragColor.a *= mix(0.07, 1.0, xr);');
  };
  mat.needsUpdate = true;
}

// แคปซูลโลกจากกรอบของชิ้น (แกนยาวสุด) ใช้เป็นหน้าต่างเอกซเรย์
const _xb = new THREE.Box3(), _xc = new THREE.Vector3();
function capsuleOf(obj) {
  _xb.makeEmpty();
  obj.traverse(function (m) {
    if (!m.isMesh || !m.geometry) return;
    if (!m.geometry.boundingBox) m.geometry.computeBoundingBox();
    const bb = m.geometry.boundingBox;
    for (let i = 0; i < 8; i++) {
      _xc.set(i & 1 ? bb.max.x : bb.min.x, i & 2 ? bb.max.y : bb.min.y,
          i & 4 ? bb.max.z : bb.min.z).applyMatrix4(m.matrixWorld);
      _xb.expandByPoint(_xc);
    }
  });
  if (_xb.isEmpty()) return null;
  const size = _xb.getSize(new THREE.Vector3());
  const ctr = _xb.getCenter(new THREE.Vector3());
  const ax = size.x >= size.y && size.x >= size.z ? 'x' : (size.y >= size.z ? 'y' : 'z');
  const others = ['x', 'y', 'z'].filter(function (k) { return k !== ax; });
  const r = Math.max(size[others[0]], size[others[1]]) * 0.5 + 0.035;
  const half = Math.max(0, size[ax] * 0.5 - r * 0.5);
  const a = ctr.clone(), b = ctr.clone();
  a[ax] -= half; b[ax] += half;
  return [a, b, r];
}

function updateXray(pivot) {
  const wins = [];
  const layers = pivot.userData.layers || {};
  if (layerWant === 'skin' && detailMode()) {
    const skel = layers.bone;
    if (skel && skel !== 'loading') {
      boneHi.forEach(function (id) {
        const o = skel.getObjectByName('bone_' + id);
        const c = o && capsuleOf(o);
        if (c) wins.push(c);
      });
    }
    hiSet.forEach(function (n) {
      const o = layers[n];
      const c = o && o !== 'loading' && capsuleOf(o);
      if (c) wins.push(c);
    });
  }
  const n = Math.min(wins.length, XR_MAX);
  for (let i = 0; i < n; i++) {
    XR.xrA.value[i].copy(wins[i][0]);
    XR.xrB.value[i].copy(wins[i][1]);
    XR.xrR.value[i] = wins[i][2];
  }
  XR.xrN.value = n;
  return n;
}

function applyLayer() {
  Object.keys(bodies).forEach(function (c) {
    const pivot = bodies[c];
    if (!pivot || pivot === 'loading') return;
    const skin = skinOf(pivot);
    if (!skin) return;
    if (c === selected) syncZoneFx(pivot);
    const layers = pivot.userData.layers || {};
    let moving = false;
    // ชั้นที่เลือกค่อย ๆ ปรากฏ ชั้นเก่าค่อย ๆ จางหาย
    Object.keys(layers).forEach(function (n) {
      const o = layers[n];
      if (!o || o === 'loading') return;
      const hi = hiSet.has(n);
      // ตอนเน้นอวัยวะ ให้กระดูกโผล่จาง ๆ เป็นภาพเอกซเรย์ประกอบ
      const xray = layerWant === 'skin' &&
          (hiSet.size > 0 || boneHi.size > 0) && n === 'bone';
      // โหมดผิว: โครงกระดูกโผล่เฉพาะชิ้นที่บาดเจ็บ (ในหน้าต่างเอกซเรย์) ไม่โชว์ทั้งโครง
      const want = (n === layerWant || hi) ? 1
          : (xray ? (boneHi.size > 0 ? 1 : 0) : 0);
      const cur = o.userData.fade === undefined ? 0 : o.userData.fade;
      const next = cur + (want - cur) * 0.2;
      o.userData.fade = Math.abs(next - want) < 0.01 ? want : next;
      if (o.userData.fade !== want) moving = true;
      o.visible = o.userData.fade > 0.01;
      // อวัยวะที่เน้น: แดงเรืองแสงเต้นเป็นจังหวะ ไม่เน้น: สีเดิมของชั้น
      const pulse = 0.6;
      o.traverse(function (m) {
        if (!m.isMesh || !m.material) return;
        m.material.transparent = o.userData.fade < 0.99;
        m.material.opacity = o.userData.fade;
        m.material.depthWrite = o.userData.fade > 0.5;
        // ชิ้นกระดูกที่บาดเจ็บเรืองแดงแบบเดียวกับอวัยวะที่เน้น
        const hiPiece = n === 'bone' && boneHi.has(m.userData.piece);
        if (n === 'bone') m.visible = layerWant === 'bone' || hiPiece;
        if (hi || hiPiece) {
          // หุ่นมีผิวซ้อนหลายชั้น (ตัว เสื้อ ผม) ถ้าปล่อยให้วาดทับ สีจะซีดเป็นชั้น ๆ
          // จึงย้ายอวัยวะไปวาดท้ายสุดในรอบโปร่งแสง ไม่เช็กความลึก → สีเต็มเสมอ
          m.material.color.setHex(HI_COLOR);
          m.material.emissive.setHex(HI_COLOR);
          m.material.emissiveIntensity = pulse;
          // ACES tone mapping กดสีแดงสว่างให้กลายเป็นส้มซีด ปิดเฉพาะชิ้นที่เน้น
          m.material.toneMapped = false;
          m.material.transparent = true;
          m.material.opacity = hiPiece
              ? Math.max(0.95, o.userData.fade)
              : Math.min(1, o.userData.fade * 1.2);
          m.material.depthTest = false;
          m.material.depthWrite = false;
          m.renderOrder = 20;
        } else {
          // ชั้นในทั่วไปเติมแสงในตัวเล็กน้อย ไม่งั้นแสงในฉากทำให้สีจืด
          const base = xray ? (darkMode ? 0xB8CCEA : 0x8FA3BC) : (LAYER_COLOR[n] || 0xB9BFC7);
          m.material.color.setHex(base);
          m.material.emissive.setHex(base);
          m.material.emissiveIntensity = xray ? 0.15 : 0.35;
          m.material.toneMapped = true;
          m.material.depthTest = true;
          m.renderOrder = 0;
        }
      });
    });
    // ผิวจางลงเท่าที่ชั้นในปรากฏ ทั้งสองอย่างจึงเปลี่ยนพร้อมกันอย่างนุ่มนวล
    const inner = Object.keys(layers).reduce(function (mx, n) {
      const o = layers[n];
      if (!o || o === 'loading') return mx;
      return Math.max(mx, o.userData.fade || 0);
    }, 0);
    // เน้นอวัยวะอย่างเดียว (ไม่ได้เปิดชั้นกระดูก/อวัยวะ/เส้นเลือด):
    // ผิวเหลือเป็นแก้วขุ่น ยังเห็นรูปร่างตัว แต่ให้อวัยวะที่เรืองแสงเด่นกว่า
    // โหมดผิว: ผิวทึบทั้งตัว เจาะโปร่งเฉพาะหน้าต่างเอกซเรย์ (หลายจุดได้)
    const xrN = c === selected ? updateXray(pivot) : 0;
    const skinMode = layerWant === 'skin';
    const skinOpacity = skinMode ? 1.0 : 1.0 - inner * 0.92;
    // ชั้นใน/อวัยวะผูกอยู่ใต้ตัวหุ่นเหมือนกัน ต้องข้าม ไม่งั้นโดนจางไปด้วย
    skin.children.forEach(function (ch) {
      if (ch.name.indexOf('layer_') === 0) return;
      // จุดความร้อน (heat_) ต้องโปร่งเสมอ ถ้าโดนตั้งทึบตามผิวจะเห็นเป็นกรอบสี่เหลี่ยมดำ
      if (ch.name.indexOf('heat_') === 0) return;
      ch.traverse(function (m) {
        if (!m.isMesh || !m.material) return;
        // ชุดผู้ป่วย: จาง/เจาะหน้าต่างเอกซเรย์ตามผิว (เห็นอวัยวะทะลุชุด) · เส้นขอบผ้าแสดงเฉพาะตอนทึบ
        if (m.name === 'anat_cloth_line') {
          // เส้นขอบ toon ไม่ใช้แล้ว (แสงนุ่มแบบภาพหุ่นสแกนใบหน้า)
          m.visible = false;
          patchXray(m.material);
          return;
        }
        if (m.name === 'anat_cloth') {
          m.visible = !darkMode;
          patchXray(m.material);
          // ผ้าทึบไว้ก่อน (ผ้าโปร่งตามผิว = เห็นเงาผิวข้างใต้เป็นรอยด่าง) · ดูอวัยวะผ่านหน้าต่างเอกซเรย์
          // จางจริงเฉพาะตอนเปิดชั้นใน (ผิวเหลือ < 0.5)
          const cop = Math.min(1.0, skinOpacity * 2.0);
          m.material.transparent = cop < 0.99 || xrN > 0;
          m.material.opacity = cop;
          m.material.depthWrite = cop > 0.9;
          return;
        }
        // เส้นขอบ toon: แสดงเฉพาะตอนผิวทึบ (โหมดเอกซเรย์/ผิวจาง ซ่อน)
        if (m.name === 'anat_line') {
          // เส้นขอบ toon ไม่ใช้แล้ว (แสงนุ่มแบบภาพหุ่นสแกนใบหน้า)
          m.visible = false;
          patchXray(m.material);
          return;
        }
        const mat = m.material;
        if (mat.userData.origColor === undefined && mat.color) {
          mat.userData.origColor = mat.color.getHex();
          mat.userData.origEmissive = mat.emissive ? mat.emissive.getHex() : 0;
          mat.userData.origEI = mat.emissiveIntensity || 0;
          mat.userData.origMap = mat.map || null;
        }
        if (darkMode) {
          // เอกซเรย์: ผิวฟ้าเย็นเรืองจาง ๆ ไม่ใช้ลายผิวเดิม
          mat.map = null;
          mat.color.setHex(0x5E7FB0);
          if (mat.emissive) mat.emissive.setHex(0x2A4C85);
          mat.emissiveIntensity = 0.55;
          mat.transparent = true;
          mat.opacity = Math.min(skinOpacity, 0.30);
          mat.depthWrite = false;
        } else {
          if (mat.userData.origColor !== undefined) {
            mat.map = mat.userData.origMap;
            mat.color.setHex(mat.userData.origColor);
            if (mat.emissive) mat.emissive.setHex(mat.userData.origEmissive);
            mat.emissiveIntensity = mat.userData.origEI;
          }
          patchXray(mat);
          mat.transparent = skinOpacity < 0.99 || xrN > 0;
          mat.opacity = skinOpacity;
          mat.depthWrite = skinOpacity > 0.9;
        }
        mat.needsUpdate = true;
      });
    });
    if (moving) markDirty(2);
  });
}

window.erSetDark = function (on) {
  darkMode = !!on;
  applyEnvFade();
  applyLayer();
  markDirty(10);
};

// หุ่นลายเส้น: มีอวัยวะที่เน้น = ผิวโปร่ง เห็นอวัยวะเรืองด้านใน
function mannAlpha() {
  const pivot = bodies[selected];
  const fig = pivot && pivot !== 'loading' ? skinOf(pivot) : null;
  const mn = fig && fig.userData.mann;
  if (!mn || !mn.mats) return;
  const see = hiSet.size > 0;
  mn.mats.forEach(function (m) {
    m.uniforms.uAlpha.value = see ? 0.28 : 1.0;
    m.transparent = see;
    m.depthWrite = !see;
    m.needsUpdate = true;
  });
  markDirty(6);
}
window.erHighlight = function (names) {
  // รหัส bone:xxx = ตำแหน่งกระดูกที่บาดเจ็บ · ที่เหลือ = ชั้นอวัยวะ
  const all = names || [];
  hiSet = new Set(all.filter(function (n) {
    return n.indexOf('bone:') !== 0 && n.indexOf('zone:') !== 0 &&
        ['bone', 'organ', 'vessel'].indexOf(n) < 0;
  }));
  boneHi = new Set(all.filter(function (n) { return n.indexOf('bone:') === 0; })
      .map(function (n) { return n.slice(5); }));
  zoneHi = new Set(all.filter(function (n) { return n.indexOf('zone:') === 0; })
      .map(function (n) { return n.slice(5); }));
  hiSet.forEach(function (n) { ensureLayer(selected, n); });
  if (hiSet.size > 0 || boneHi.size > 0) ensureLayer(selected, 'bone');
  applyLayer();
  mannAlpha();
  markDirty(10);
};

window.erSetLayer = function (name) {
  layerWant = name;
  if (name !== 'skin') ensureLayer(selected, name);
  applyLayer();
  markDirty(10);
};

// ------------------------------------------------ heatmap อาการไม่ระบุตำแหน่ง
// อาการกว้าง ๆ (ปวดท้อง คลื่นไส้ เจ็บหน้าอก) ไม่ระบายอวัยวะ แต่เป็นความร้อนบนผิว
// จุดกลางโซนคิดจากข้อต่อ rig แล้วยิงรังสีลงหาผิวจริงของหุ่น
let zoneHi = new Set();
// [ข้อต่อ a, ข้อต่อ b, สัดส่วน a→b, เยื้องข้าง (+ขวา/-ซ้าย × ครึ่งไหล่), รัศมี ม.]
const ZONE_AT = {
  head: ['Head', 'Neck', -0.35, 0, 0.12],
  throat: ['Neck', 'Head', 0.2, 0, 0.06],
  chest: ['Chest', 'Neck', 0.25, 0, 0.16],
  epigastric: ['Belly', 'Chest', 0.55, 0, 0.09],
  ruq: ['Belly', 'Chest', 0.3, 0.45, 0.09],
  luq: ['Belly', 'Chest', 0.3, -0.45, 0.09],
  abdomen: ['Belly', 'Chest', 0.0, 0, 0.15],
  rlq: ['Pelvis', 'Belly', 0.35, 0.42, 0.085],
  llq: ['Pelvis', 'Belly', 0.35, -0.42, 0.085],
  suprapubic: ['Pelvis', 'Belly', 0.05, 0, 0.08],
  flank_r: ['Pelvis', 'Belly', 0.85, 0.75, 0.08],
  flank_l: ['Pelvis', 'Belly', 0.85, -0.75, 0.08],
  lowback: ['Pelvis', 'Belly', 0.6, 0, 0.12],
  // แขนขา (จากภาพการตรวจร่างกายที่วาด): กึ่งกลางท่อนระหว่างข้อต่อ rig · .R/.L = ขวา/ซ้ายของผู้ป่วย
  shoulder_r: ['UpperArm.R', 'Collar.R', 0.15, 0, 0.06],
  arm_r: ['UpperArm.R', 'Forearm.R', 0.5, 0, 0.06],
  forearm_r: ['Forearm.R', 'Palm.R', 0.5, 0, 0.05],
  hand_r: ['Palm.R', 'Forearm.R', -0.25, 0, 0.045],
  thigh_r: ['Hip.R', 'Shin.R', 0.5, 0, 0.08],
  shin_r: ['Shin.R', 'Foot.R', 0.5, 0, 0.06],
  foot_r: ['Foot.R', 'Toes.R', 0.4, 0, 0.05],
  shoulder_l: ['UpperArm.L', 'Collar.L', 0.15, 0, 0.06],
  arm_l: ['UpperArm.L', 'Forearm.L', 0.5, 0, 0.06],
  forearm_l: ['Forearm.L', 'Palm.L', 0.5, 0, 0.05],
  hand_l: ['Palm.L', 'Forearm.L', -0.25, 0, 0.045],
  thigh_l: ['Hip.L', 'Shin.L', 0.5, 0, 0.08],
  shin_l: ['Shin.L', 'Foot.L', 0.5, 0, 0.06],
  foot_l: ['Foot.L', 'Toes.L', 0.4, 0, 0.05],
};
let heatTex = null;
function heatTexture() {
  if (heatTex) return heatTex;
  const c = document.createElement('canvas');
  c.width = c.height = 128;
  const g = c.getContext('2d');
  const gr = g.createRadialGradient(64, 64, 0, 64, 64, 64);
  gr.addColorStop(0.0, 'rgba(225,25,18,0.92)');
  gr.addColorStop(0.3, 'rgba(238,80,28,0.72)');
  gr.addColorStop(0.62, 'rgba(250,180,50,0.38)');
  gr.addColorStop(1.0, 'rgba(252,220,90,0)');
  g.fillStyle = gr;
  g.fillRect(0, 0, 128, 128);
  heatTex = new THREE.CanvasTexture(c);
  return heatTex;
}

function zonePoint(body, id) {
  const z = ZONE_AT[id];
  if (!z || !findNode(body, z[0]) || !findNode(body, z[1])) return null;
  const a = bonePos(body, z[0]), b = bonePos(body, z[1]);
  const p = a.clone().lerp(b, z[2]);
  if (z[3] && findNode(body, 'Collar.R') && findNode(body, 'Collar.L')) {
    const half = bonePos(body, 'Collar.R').sub(bonePos(body, 'Collar.L')).multiplyScalar(0.5);
    p.add(half.multiplyScalar(z[3]));
  }
  return p;
}

const _zr = new THREE.Raycaster();
function syncZoneFx(pivot) {
  const fig = skinOf(pivot);
  if (!fig) return;
  const body = fig.userData.body || fig;
  const fx = pivot.userData.zoneFx = pivot.userData.zoneFx || {};
  Object.keys(fx).forEach(function (id) {
    if (!zoneHi.has(id) || !detailMode()) {
      fx[id].parent && fx[id].parent.remove(fx[id]);
      delete fx[id];
    }
  });
  if (!detailMode()) return;
  zoneHi.forEach(function (id) {
    if (fx[id]) return;
    const p = zonePoint(body, id);
    if (!p) return;
    fig.updateMatrixWorld(true);
    // ยิงจากเหนือจุด (ผู้ป่วยนอนหงาย ด้านหน้าคือ +Y ของโลก) ลงหาผิว
    _zr.set(p.clone().add(new THREE.Vector3(0, 1, 0)), new THREE.Vector3(0, -1, 0));
    const hit = _zr.intersectObject(fig, true).filter(function (h) {
      return h.object.name.indexOf('bone_') !== 0 && !h.object.userData.piece &&
          h.object.parent && String(h.object.parent.name).indexOf('layer_') !== 0;
    })[0];
    const at = hit ? hit.point.clone() : p.clone();
    const nWorld = hit && hit.face
        ? hit.face.normal.clone().transformDirection(hit.object.matrixWorld)
        : new THREE.Vector3(0, 1, 0);
    at.add(nWorld.clone().multiplyScalar(0.006));
    const ws = fig.getWorldScale(new THREE.Vector3()).x || 1;
    const r = ZONE_AT[id][4] / ws;
    const m = new THREE.Mesh(new THREE.PlaneGeometry(2 * r, 2 * r),
        new THREE.MeshBasicMaterial({
          map: heatTexture(), transparent: true, depthWrite: false,
          depthTest: false, toneMapped: false, side: THREE.DoubleSide,
        }));
    m.renderOrder = 24;
    m.frustumCulled = false;
    m.name = 'heat_' + id;
    m.position.copy(fig.worldToLocal(at));
    const figQ = fig.getWorldQuaternion(new THREE.Quaternion());
    const nLocal = nWorld.clone().applyQuaternion(figQ.clone().invert());
    m.quaternion.setFromUnitVectors(new THREE.Vector3(0, 0, 1), nLocal.normalize());
    fig.add(m);
    fx[id] = m;
  });
  const t = 0.8;
  Object.keys(fx).forEach(function (id) {
    fx[id].material.opacity = 0.7 + 0.3 * t;
    fx[id].scale.setScalar(0.94 + 0.12 * t);
  });
}

// ------------------------------------------------ โครงกระดูกแยกชิ้น
// BodyParts3D ครบทั้งตัว 28 ชิ้น · ลำตัววางด้วยการเทียบทั้งร่าง (bp3dToFigure)
// แขนขาแต่ละชิ้นจัดเข้ากับข้อต่อจริงของ rig หุ่น (ต้น→ปลาย) จึงกางแขน/ขาตามหุ่น
// กระดูกที่บาดเจ็บ (boneHi) = ชิ้นจริงชิ้นนั้นเรืองแดง
let boneHi = new Set();
const BONE_PIECES = [
  'skull', 'cspine', 'tspine', 'lspine', 'pelvis', 'sternum',
  'ribs_l', 'ribs_r', 'clavicle_l', 'clavicle_r', 'scapula_l', 'scapula_r',
  'humerus_l', 'humerus_r', 'forearm_l', 'forearm_r', 'hand_l', 'hand_r',
  'femur_l', 'femur_r', 'knee_l', 'knee_r', 'tibia_l', 'tibia_r',
  'ankle_l', 'ankle_r', 'foot_l', 'foot_r',
];
// ชิ้นแขนขา → [ชิ้นที่ใช้วัดแกน, ข้อต่อ rig ต้น, ข้อต่อ rig ปลาย]
// BodyParts3D: ขวาของผู้ป่วย = -X · rig: .R = ขวาของหุ่น
const LIMB_FIT = {};
['l', 'r'].forEach(function (s) {
  const S = s.toUpperCase();
  LIMB_FIT['humerus_' + s] = ['humerus_' + s, 'UpperArm.' + S, 'Forearm.' + S];
  LIMB_FIT['forearm_' + s] = ['forearm_' + s, 'Forearm.' + S, 'Palm.' + S];
  LIMB_FIT['hand_' + s] = ['hand_' + s, 'Palm.' + S, 'Middle3.' + S];
  LIMB_FIT['femur_' + s] = ['femur_' + s, 'Hip.' + S, 'Shin.' + S];
  LIMB_FIT['knee_' + s] = ['femur_' + s, 'Hip.' + S, 'Shin.' + S];
  LIMB_FIT['tibia_' + s] = ['tibia_' + s, 'Shin.' + S, 'Foot.' + S];
  LIMB_FIT['ankle_' + s] = ['foot*' + s, 'Foot.' + S, 'Toes.' + S];
  LIMB_FIT['foot_' + s] = ['foot*' + s, 'Foot.' + S, 'Toes.' + S];
});

function geomOf(obj) {
  let g = null;
  obj.traverse(function (m) { if (!g && m.isMesh) g = m.geometry; });
  return g;
}

// ปลายบน/ล่างของกระดูกยาว (พิกัด BodyParts3D มม.): จุดกลางของจุดยอดที่อยู่ปลายแกน Z
function longEnds(geom) {
  const a = geom.attributes.position;
  let zmin = Infinity, zmax = -Infinity;
  for (let i = 0; i < a.count; i++) {
    const z = a.getZ(i);
    if (z < zmin) zmin = z;
    if (z > zmax) zmax = z;
  }
  const band = (zmax - zmin) * 0.06;
  const top = new THREE.Vector3(), bot = new THREE.Vector3();
  let nt = 0, nb = 0;
  for (let i = 0; i < a.count; i++) {
    const z = a.getZ(i);
    if (z > zmax - band) { top.x += a.getX(i); top.y += a.getY(i); top.z += z; nt++; }
    if (z < zmin + band) { bot.x += a.getX(i); bot.y += a.getY(i); bot.z += z; nb++; }
  }
  return [top.divideScalar(Math.max(nt, 1)), bot.divideScalar(Math.max(nb, 1))];
}

// เท้า: ข้อเท้า (โดมของ talus = ยอดของชิ้น ankle) → ปลายเท้า (ด้านหน้าสุด -Y)
function footEnds(ankleGeom, footGeom) {
  const top = longEnds(ankleGeom)[0];
  const a = footGeom.attributes.position;
  let ymin = Infinity, ymax = -Infinity;
  for (let i = 0; i < a.count; i++) {
    const y = a.getY(i);
    if (y < ymin) ymin = y;
    if (y > ymax) ymax = y;
  }
  const band = (ymax - ymin) * 0.12;
  const tip = new THREE.Vector3();
  let n = 0;
  for (let i = 0; i < a.count; i++) {
    if (a.getY(i) < ymin + band) {
      tip.x += a.getX(i); tip.y += a.getY(i); tip.z += a.getZ(i); n++;
    }
  }
  return [top, tip.divideScalar(Math.max(n, 1))];
}

function loadPiece(id) {
  const file = 'bone/' + id + '.glb';
  const get = layerCache[file]
      ? Promise.resolve(layerCache[file])
      : fetch(file).then(function (r) { return r.arrayBuffer(); })
          .then(function (b) { layerCache[file] = b; return b; });
  return get.then(function (buf) {
    return new Promise(function (ok) {
      new THREE.GLTFLoader().parse(buf, '', function (g) { ok(g.scene); },
          function () { ok(null); });
    });
  });
}

function ensureSkeleton(code) {
  const pivot = bodies[code];
  if (!pivot || pivot === 'loading') return;
  pivot.userData.layers = pivot.userData.layers || {};
  if (pivot.userData.layers.bone) return;
  pivot.userData.layers.bone = 'loading';
  Promise.all(BONE_PIECES.map(loadPiece)).then(function (objs) {
    const fig = skinOf(pivot);
    const fit = fig ? bp3dToFigure(fig) : null;
    if (!fig || !fit) {
      pivot.userData.layers.bone = null;
      send({ type: 'error', message: 'skeleton fit: no figure' });
      return;
    }
    const body = fig.userData.body || fig;
    fig.updateMatrixWorld(true);
    const byId = {};
    BONE_PIECES.forEach(function (id, i) { byId[id] = objs[i]; });
    const root = new THREE.Group();
    root.name = 'layer_bone';
    // แสดงหุ่นผิวจริงอยู่: วางกระดูกแขนขาตามข้อต่อของหุ่นนั้น (ท่า/สัดส่วนต่างจาก rig)
    const anatJ = anatJointLocal(fig);
    const jointLocal = function (n) {
      if (anatJ && anatJ[n]) return anatJ[n];
      const b = findNode(body, n);
      return b ? fig.worldToLocal(bonePos(body, n)) : null;
    };
    BONE_PIECES.forEach(function (id) {
      const obj = byId[id];
      if (!obj) return;
      obj.traverse(function (m) {
        if (!m.isMesh) return;
        if (m.geometry && !m.geometry.attributes.normal) m.geometry.computeVertexNormals();
        m.frustumCulled = false;
        m.userData.piece = id;
        m.material = new THREE.MeshStandardMaterial({
          color: LAYER_COLOR.bone, roughness: 0.8, metalness: 0.0,
        });
      });
      const lf = LIMB_FIT[id];
      let placed = false;
      if (lf) {
        const ja = jointLocal(lf[1]), jb = jointLocal(lf[2]);
        let ends = null;
        if (lf[0].indexOf('foot*') === 0) {
          const s = lf[0].slice(5);
          const ag = byId['ankle_' + s] && geomOf(byId['ankle_' + s]);
          const fg = byId['foot_' + s] && geomOf(byId['foot_' + s]);
          if (ag && fg) ends = footEnds(ag, fg);
        } else if (byId[lf[0]]) {
          ends = longEnds(geomOf(byId[lf[0]]));
        }
        if (ja && jb && ends) {
          // src (มม.) หมุนตามทิศร่างก่อน แล้วหมุนแกนกระดูกให้ชี้ตามข้อต่อ rig
          const srcDir = ends[1].clone().sub(ends[0]).applyQuaternion(fit.q);
          const tgt = jb.clone().sub(ja);
          const s = tgt.length() / Math.max(srcDir.length(), 1e-6);
          const rm = new THREE.Quaternion().setFromUnitVectors(
              srcDir.clone().normalize(), tgt.clone().normalize());
          const q = rm.clone().multiply(fit.q);
          obj.quaternion.copy(q);
          obj.scale.setScalar(s);
          obj.position.copy(ja).sub(ends[0].clone().multiplyScalar(s).applyQuaternion(q));
          placed = true;
        }
      }
      if (!placed) {
        obj.quaternion.copy(fit.q);
        obj.scale.setScalar(fit.k);
        obj.position.copy(fit.pos);
      }
      obj.name = 'bone_' + id;
      root.add(obj);
    });
    fig.add(root);
    root.userData.fade = 0;
    root.visible = false;
    pivot.userData.layers.bone = root;
    applyLayer();
    markDirty(8);
  });
}

// สลับระหว่างหุ่นมีกระดูกกับร่างกายจริง ตามระดับการจางของห้อง
let wasDetail = false;
function applyBodySwap() {
  const detail = envFade() > 0.55;
  // ออกจากหน้ารายละเอียด: คืนท่านอนตั้งต้น (ไม่เก็บมุมหมุน/เอียง/ซูมไว้ข้ามหน้า)
  if (wasDetail && !detail) {
    spinWant = 0; tiltWant = 0; zoomWant = 1; spinVel = 0;
    bodySpin = 0; bodyTilt = 0; zoomK = 1;
    applyBodySpin();
  }
  wasDetail = detail;
  if (detail) {
    ensureBody(selected, femaleOf(selected));
    ensureAnat(selected, femaleOf(selected));
    if (layerWant !== 'skin') ensureLayer(selected, layerWant);
    hiSet.forEach(function (n) { ensureLayer(selected, n); });
    if (hiSet.size > 0 || boneHi.size > 0) ensureLayer(selected, 'bone');
  }
  Object.keys(figures).forEach(function (c) {
    const f = figures[c];
    // โหมดรายละเอียดเหลือหุ่นของเตียงที่เลือกตัวเดียว
    if (f && f !== 'loading') f.visible = !detail || c === selected;
  });
  // โหมดรายละเอียดซ่อนเตียงและของติดเตียงทั้งก้อน (ถุงปัสสาวะ สายน้ำเกลือ ฯลฯ)
  // การจางด้วยวัสดุอย่างเดียวไม่พอ บางชิ้นใช้วัสดุที่ไม่ได้อยู่ในชุด envMats
  // เดินลงไล่เอง เพื่อไม่ให้ลงไปโดนกิ่งของร่างผู้ป่วย
  function hideFurniture(node) {
    node.children.forEach(function (o) {
      if (o.name.indexOf('body_') === 0 || o.name.indexOf('figure_') === 0) {
        return;
      }
      if (o.isMesh) o.visible = !detail;
      hideFurniture(o);
    });
  }
  Object.keys(beds).forEach(function (c) {
    const b = beds[c];
    if (b) hideFurniture(b);
  });
  syncAnat();
  if (detail) applyLayer();
}

// ---------------------------------------------- สายรัดข้อมือสีตามระดับ ESI
// ผูกกับกระดูกฝ่ามือซ้าย (โคนฝ่ามือ = ข้อมือ) ขยับตามท่าหุ่นเอง
// ขนาดคิดเป็นเมตรในโลก แล้วหักสเกลของกระดูกออก
const bandColor = {};     // รหัสเตียง -> สี ESI

function addWristband(fig, color) {
  const body = fig.userData.body || fig;
  const wrist = findNode(body, 'Palm.L');
  if (!wrist) return;
  fig.updateMatrixWorld(true);
  const ws = wrist.getWorldScale(new THREE.Vector3());
  const band = new THREE.Group();
  band.name = 'wristband';
  const mat = new THREE.MeshStandardMaterial({
    color: color, roughness: 0.45, metalness: 0.0, side: THREE.DoubleSide,
  });
  // สายแบนรอบข้อมือ (แกน Y ของกระดูก = ตามแนวแขน) ข้อมือแบนจึงบีบด้านหนึ่ง
  const strap = new THREE.Mesh(
      new THREE.CylinderGeometry(0.036, 0.036, 0.03, 32, 1, true), mat);
  strap.scale.set(1, 1, 0.78);
  band.add(strap);
  // ขอบสายนูนเล็กน้อยให้ดูมีความหนา
  [0.015, -0.015].forEach(function (y) {
    const rim = new THREE.Mesh(
        new THREE.TorusGeometry(0.036, 0.0026, 8, 40), mat);
    rim.rotation.x = Math.PI / 2;
    rim.scale.set(1, 0.78, 1);
    rim.position.y = y;
    band.add(rim);
  });
  // ป้ายชื่อขาวบนสาย (แบบสายรัดข้อมือผู้ป่วยจริง)
  const tag = new THREE.Mesh(
      new THREE.BoxGeometry(0.034, 0.02, 0.007),
      new THREE.MeshStandardMaterial({ color: 0xFFFFFF, roughness: 0.6 }));
  tag.position.set(0.036, 0, 0);
  tag.rotation.y = Math.PI / 2;
  band.add(tag);
  band.scale.set(1 / ws.x, 1 / ws.y, 1 / ws.z);
  band.traverse(function (m) { if (m.isMesh) m.castShadow = true; });
  wrist.add(band);
  fig.userData.band = mat;
  fig.userData.bandObj = band;
}

function setBandColor(code, color) {
  bandColor[code] = color;
  const f = figures[code];
  if (f && f !== 'loading' && f.userData.band) {
    f.userData.band.color.setHex(color);
  }
}

function ensureFigure(code, female) {
  if (figures[code]) return;
  const bed = beds[code];
  if (!bed) return;
  figures[code] = 'loading';
  loadFigureBuffer().then(function (buf) {
    new THREE.GLTFLoader().parse(buf, '', function (gltf) {
      if (figures[code] !== 'loading') return;   // ถูกยกเลิกไปแล้ว
      const fig = gltf.scene;
      fig.traverse(function (m) {
        if (!m.isMesh || !m.material) return;
        m.castShadow = true;
        m.frustumCulled = false;   // skinned mesh กรอบไม่อัปเดตตามท่า
        // วัสดุเดิมดำสนิท เปลี่ยนเป็นชุดผู้ป่วยฟ้าอ่อน
        // three r128 ต้องเปิด skinning ที่วัสดุเอง ไม่งั้นกระดูกหมุนแล้วผิวไม่ตาม
        m.material = new THREE.MeshStandardMaterial({
          color: 0xA9C3EA, roughness: 0.85, metalness: 0.0, skinning: true,
        });
      });
      poseLying(fig, female);
      placeFigureOnBed(fig, bed);
      addWristband(fig, bandColor[code] !== undefined ? bandColor[code] : 0x9AA0A6);
      fig.name = 'figure_' + code;
      // ผูกเข้ากับเตียง เตียงที่เลือกมีอนิเมชันขยาย/ยก หุ่นจะได้ขยับตาม
      scene.add(fig);
      bed.attach(fig);

      figures[code] = fig;
      ensureAnat(code, female);
      if (code === selected) {
        const f = focusOf(code);
        if (f) { targetPos.set(f.x, 0, f.z); focusY = f.y; }
      }
      renderer.shadowMap.needsUpdate = true;
      markDirty(8);
    }, function (err) {
      delete figures[code];
      send({ type: 'error', message: 'figure: ' + String(err) });
    });
  });
}

function removeFigure(code) {
  const f = figures[code];
  if (f && f !== 'loading' && f.parent) f.parent.remove(f);
  delete figures[code];
  // ร่างโหมดรายละเอียด (แกนหมุน + ชั้นอวัยวะ/กระดูก) ของเตียงนี้ทิ้งด้วย
  const b = bodies[code];
  if (b && b.parent) b.parent.remove(b);
  delete bodies[code];
}

// จัดเตียงตามลำดับรายชื่อของแอป: ช่องเตียงในห้องคงที่ (ตำแหน่งเดิมเรียงตามแนวแถว)
// เตียงลำดับที่ i ย้ายไปอยู่ช่องที่ i · หุ่นผูกกับเตียงอยู่แล้วจึงย้ายตาม
let bedSlots = null;
function arrangeBeds(codes) {
  const all = Object.keys(beds).filter(function (c) { return beds[c].userData.center; });
  if (all.length < 2) return;
  if (!bedSlots) {
    all.sort();
    const a = beds[all[0]].userData.center, z = beds[all[all.length - 1]].userData.center;
    const dir = z.clone().sub(a).setY(0).normalize();
    bedSlots = all.map(function (c) { return beds[c].userData.center.clone(); })
      .sort(function (p, q) { return p.dot(dir) - q.dot(dir); });
  }
  const seq = codes.filter(function (c) { return beds[c]; })
    .concat(all.filter(function (c) { return codes.indexOf(c) < 0; }));
  seq.forEach(function (c, i) {
    const b = beds[c], to = bedSlots[i];
    if (!to) return;
    const d = to.clone().sub(b.userData.center).setY(0);
    if (d.lengthSq() < 1e-8) return;
    const w = b.getWorldPosition(new THREE.Vector3()).add(d);
    b.position.copy(b.parent.worldToLocal(w));
    b.updateMatrixWorld(true);
    b.userData.box.translate(d);
    b.userData.center.add(d);
    b.userData.nearZ += d.z;
    b.userData.farZ += d.z;
  });
  renderer.shadowMap.needsUpdate = true;
}
window.erSetBeds = function (list) {
  markDirty(8);
  // หุ่นนอนเฉพาะเตียงที่มีคน · ร่างหญิง/ชายตามเพศผู้ป่วยจริง
  // เพศเปลี่ยน (คนใหม่บนเตียงเดิม) = สร้างหุ่นใหม่
  const occupied = {};
  list.forEach(function (b) {
    if (b.vacant) return;
    occupied[b.code] = true;
    const female = !!b.female;
    if (figures[b.code] && femaleBy[b.code] !== female) removeFigure(b.code);
    femaleBy[b.code] = female;
    setBandColor(b.code, b.color);
    ensureFigure(b.code, female);
  });
  Object.keys(figures).forEach(function (code) {
    if (!occupied[code]) removeFigure(code);
  });
  order = list.map(function (b) { return b.code; });
  arrangeBeds(order);
  if (order.length > 1) {
    const a = new THREE.Box3().setFromObject(beds[order[0]])
        .getCenter(new THREE.Vector3());
    const z = new THREE.Box3().setFromObject(beds[order[order.length - 1]])
        .getCenter(new THREE.Vector3());
    rowDir = z.sub(a).setY(0).normalize();
  }
  Object.keys(glows).forEach(function (code) {
    scene.remove(glows[code]);
    delete glows[code];
  });
  list.forEach(function (b) {
    const bed = beds[b.code];
    if (!bed) return;
    bed.visible = true;
    const glow = makeGlow(b.color);
    const p = bed.userData.center ||
        new THREE.Box3().setFromObject(bed).getCenter(new THREE.Vector3());
    glow.position.set(p.x, 0.012, p.z);
    glow.visible = false;
    glows[b.code] = glow;
    scene.add(glow);
  });
  // เตียงที่ไม่มีในข้อมูล ซ่อนไปเลย จำนวนเตียงจึงมาจากข้อมูลจริง
  Object.keys(beds).forEach(function (code) {
    if (order.indexOf(code) < 0) beds[code].visible = false;
  });
};

// ---------------------------------------------- ผู้ป่วยที่ยังไม่ได้เตียง
// ต่อท้ายแถวเตียง: เก้าอี้แถว (เดินมา) + รถเข็น (มาด้วยรถนั่ง) มีหุ่นนั่งสีตาม ESI
const waitRoot = new THREE.Group(); waitRoot.name = 'waiting';
let waitList = [];
const propCache = {};
function loadProp(file) {
  if (propCache[file]) return propCache[file];
  propCache[file] = new Promise(function (ok, bad) {
    new THREE.GLTFLoader().load(file, function (g) { ok(g.scene); }, undefined, bad);
  });
  return propCache[file];
}
// ย่อ/วางโมเดลให้ยาวตามแกนที่ยาวสุด = len เมตร ฐานแตะพื้น จุดกลางที่ (0,0)
// เก้าอี้แถว: เบาะ/พนักสีเขียวเดิม → ไม้โอ๊คอ่อน (โครงโลหะคงเดิม) · โทนโรงพยาบาลขาว + ไม้
function woodBench(g) {
  const hsl = {};
  g.traverse(function (m) {
    if (!m.isMesh || !m.material) return;
    const mats = Array.isArray(m.material) ? m.material : [m.material];
    m.material = mats.map(function (mt) {
      if (!mt.color) return mt;
      mt.color.getHSL(hsl);
      // เขียว (hue 0.2–0.5) และมีสี = เบาะ
      if (hsl.h > 0.18 && hsl.h < 0.52 && hsl.s > 0.08) {
        const w = mt.clone();
        w.color.setHex(WOOD_HEX).convertSRGBToLinear(); // hex เป็น sRGB: แปลงก่อน (ไม่งั้นจอยกจนขาวซีด)
        w.map = null; w.roughness = 0.55;
        return w;
      }
      return mt;
    });
    if (m.material.length === 1) m.material = m.material[0];
  });
  return g;
}

function fitProp(obj, len) {
  const g = new THREE.Group();
  g.add(obj);
  obj.updateMatrixWorld(true);
  const bb = new THREE.Box3().setFromObject(obj);
  const sz = bb.getSize(new THREE.Vector3());
  const k = len / Math.max(sz.x, sz.z, 0.001);
  obj.scale.multiplyScalar(k);
  obj.updateMatrixWorld(true);
  const b2 = new THREE.Box3().setFromObject(obj);
  const c = b2.getCenter(new THREE.Vector3());
  obj.position.x -= c.x; obj.position.z -= c.z; obj.position.y -= b2.min.y;
  obj.traverse(function (m) { if (m.isMesh) { m.castShadow = true; m.receiveShadow = true; } });
  return g;
}
// ---- ท่านั่ง (หุ่นผิวจริง): พับสะโพก 90° ไปหน้า (+Z) แล้วพับเข่า 90° ให้หน้าแข้งตั้ง
// ทำบน geometry (พิกัด LANDMARK เท้าที่ y=0) เฉพาะช่วงขา · ไล่น้ำหนักรอบข้อต่อกันผิวฉีก
function anatSmooth(t) { const w = Math.min(1, Math.max(0, t)); return w * w * (3 - 2 * w); }
function anatPoseSit(g, set, info) {
  const p = g.attributes.position, nrm = g.attributes.normal;
  const ky = info.h / ANAT_REF_H;
  const HY = 0.87, HZ = 0.02, KY = 0.47, KZ = -0.01;
  function rot(y, z, py, pz, a) {
    const dy = y - py, dz = z - pz, c = Math.cos(a), n = Math.sin(a);
    return [py + dy * c - dz * n, pz + dy * n + dz * c];
  }
  for (let i = 0; i < p.count; i++) {
    const X = p.getX(i) / set.wx, Y = (p.getY(i) - info.feetY) / ky;
    let Z = p.getZ(i);
    // ข้าม: เหนือสะโพก และแขน/มือ (อยู่สูงกว่า 0.6 เสมอ) · ต่ำกว่า 0.6 = ขา/เท้าทั้งหมด
    // (ขอบนอกของเท้ากว้างถึง 0.275 เดิมถูกข้าม ค้างอยู่ที่พื้น ดึงผิวเป็นเส้นและหุ่นลอยสูง)
    if (Y > HY + 0.04 || (Y > 0.6 && Math.abs(X) > 0.27)) continue;
    const wk = anatSmooth((KY + 0.03 - Y) / 0.06);
    const wh = anatSmooth((HY + 0.04 - Y) / 0.10);
    let y = Y, z = Z;
    const ak = Math.PI / 2 * wk, ah = -Math.PI / 2 * wh;
    if (wk > 0) { const r = rot(y, z, KY, KZ, ak); y = r[0]; z = r[1]; }
    if (wh > 0) { const r = rot(y, z, HY, HZ, ah); y = r[0]; z = r[1]; }
    p.setY(i, y * ky + info.feetY);
    p.setZ(i, z);
    if (nrm) {
      let ny = nrm.getY(i), nz = nrm.getZ(i);
      const a = ak + ah, c = Math.cos(a), n = Math.sin(a);
      nrm.setY(i, ny * c - nz * n); nrm.setZ(i, ny * n + nz * c);
    }
  }
  p.needsUpdate = true;
  if (nrm) nrm.needsUpdate = true;
  g.computeBoundingBox();
  g.computeBoundingSphere();
}

// ---- วางมือบนตัก: งอศอกไปข้างหน้า (หมุนปลายแขน+มือรอบข้อศอกในระนาบ y-z) แล้วเบนเข้าหาต้นขา
// ทำหลังหุบแขนแล้ว · จุดไหนเป็นปลายแขนดูจากพิกัดท่ายืนเดิม (attribute 'rest')
// มือวางบนเข่า: ยกต้นแขนไปหน้า (หมุนรอบหัวไหล่ sdeg) + งอศอกเพิ่ม (deg) → ฝ่ามือพักบนต้นขาใกล้เข่า
const ANAT_LAP = { deg: 10, ey: 1.064, ez: 0.0, len: 0.46, inX: 0.11, sdeg: 32, sy: 1.40, sz: 0.0 };
// หมุนทั้งแขน (ใต้หัวไหล่) ไปข้างหน้ารอบหัวไหล่ ตามน้ำหนัก w
function anatShoulderMove(Y, Z, w) {
  const a = ANAT_LAP.sdeg * Math.PI / 180 * w, c = Math.cos(a), n = Math.sin(a);
  const dy = Y - ANAT_LAP.sy, dz = Z - ANAT_LAP.sz;
  return [ANAT_LAP.sy + dy * c + dz * n, ANAT_LAP.sz - dy * n + dz * c];
}
// ย้ายจุด (X, Y, Z พิกัด LANDMARK หลังหุบแขน) ตามน้ำหนัก w
function anatLapMove(X, Y, Z, w) {
  if (w <= 0) return [X, Y, Z];
  const a = ANAT_LAP.deg * Math.PI / 180 * w, c = Math.cos(a), n = Math.sin(a);
  const dy = Y - ANAT_LAP.ey, dz = Z - ANAT_LAP.ez;
  const t = Math.min(1, Math.max(0, (ANAT_LAP.ey - Y) / ANAT_LAP.len));
  return [X - (X >= 0 ? 1 : -1) * ANAT_LAP.inX * t * w,
      ANAT_LAP.ey + dy * c + dz * n, ANAT_LAP.ez - dy * n + dz * c];
}
function anatPoseLap(g, set, info) {
  const p = g.attributes.position, nrm = g.attributes.normal, r0 = g.attributes.rest;
  const ky = info.h / ANAT_REF_H;
  for (let i = 0; i < p.count; i++) {
    const X0 = r0.getX(i) / set.wx, Y0 = (r0.getY(i) - info.feetY) / ky;
    // เฉพาะแขน (น้ำหนักแขนจากท่ายืน) ใต้ข้อศอก (เดิม y 1.08) ไล่น้ำหนักรอบข้อศอก 8 ซม.
    const aw = anatArmWeight(X0, Y0);
    const w = aw * anatSmooth((1.12 - Y0) / 0.08);
    // ต้นแขนทั้งท่อน (ใต้หัวไหล่) ไล่น้ำหนักรอบหัวไหล่ 6 ซม.
    const ws = aw * anatSmooth((1.36 - Y0) / 0.06);
    if (w <= 0 && ws <= 0) continue;
    const q = anatLapMove(p.getX(i) / set.wx, (p.getY(i) - info.feetY) / ky, p.getZ(i), w);
    const sh = ws > 0 ? anatShoulderMove(q[1], q[2], ws) : [q[1], q[2]];
    p.setXYZ(i, q[0] * set.wx, sh[0] * ky + info.feetY, sh[1]);
    if (nrm) {
      const a = (ANAT_LAP.deg * w + ANAT_LAP.sdeg * ws) * Math.PI / 180, c = Math.cos(a), n = Math.sin(a);
      const ny = nrm.getY(i), nz = nrm.getZ(i);
      nrm.setY(i, ny * c + nz * n); nrm.setZ(i, -ny * n + nz * c);
    }
  }
  p.needsUpdate = true;
  if (nrm) nrm.needsUpdate = true;
  g.computeBoundingBox();
  g.computeBoundingSphere();
}

// หุ่นผิวจริงท่านั่ง (ตัวเดียวกับบนเตียง) ขนาดจริงเป็นเมตร เท้าแตะพื้น หันหน้า +Z
// ชุดผู้ป่วยจาก Blender (พิกัดเดียวกับผิวท่ายืน): pose(geo) จัดท่าให้ตรงกับผิว แล้วคืน mesh พร้อมใส่
// ผ้า = toon แสง flat แบบผิว + เส้นขอบน้ำตาล · รอยยับ (ink) = หมึกเรียบ · ซ่อนตาม uCloth (ถอดเสื้อผ้าใน studio)
const CLOTH_HEX = { shirt: 0x9ec5e3, shirt_trim: 0x9ec5e3, pants: 0x7fa6cc, pants_trim: 0x7fa6cc };
function clothDiscard(sh) {
  sh.uniforms.uCloth = clothU;
  sh.fragmentShader = sh.fragmentShader
    .replace('#include <common>', '#include <common>\nuniform float uCloth;')
    .replace('void main() {', 'void main() {\nif (uCloth < 0.5) discard;');
}
function anatDress(cl, info, pose, lineK) {
  // ความหนาเส้นขอบ (สัดส่วนความสูงหุ่น) · โถงนั่งรอกล้องใกล้กว่าหน้าเตียง/รายละเอียด จึงส่งค่าบางกว่า
  const lk = lineK || 0.0024;
  const out = [];
  cl.updateMatrixWorld(true);
  cl.traverse(function (c) {
    if (!c.isMesh) return;
    const geo = c.geometry.clone();
    geo.applyMatrix4(c.matrixWorld);
    pose(geo);
    geo.computeVertexNormals();
    // สีตามชื่อวัสดุ (hex ตรง ๆ ไม่อ่านสีจากไฟล์ ซึ่งเป็นค่า linear)
    const mn = c.material ? c.material.name : '';
    // เส้นรอยยับ (ink) ไม่ใส่แล้ว: ดูเป็นขีดแปลก ๆ บนเสื้อ
    if (mn === 'ink') return;
    const mat = new THREE.MeshToonMaterial({ color: new THREE.Color(CLOTH_HEX[mn] || 0x9ec5e3), gradientMap: anatToonRamp() });
    mat.toneMapped = false;
    // แสงทิศเดียวกับผิว (ไม่ใช้แสงห้อง ผ้าจึงไม่ขาวโพลน) แต่ไล่เฉดนุ่ม: ผิวผ้าที่ remesh มีหลุมเล็ก ๆ
    // ถ้าตัดเป็น 3 ขั้นแบบผิว หลุมจะกลายเป็นปื้นเข้มดูเหมือนรอยผิวทะลุผ้า
    mat.onBeforeCompile = function (sh) {
      clothDiscard(sh);
      sh.fragmentShader = sh.fragmentShader.replace('gl_FragColor = vec4( outgoingLight, diffuseColor.a );', ANAT_CLOTH_LIGHT);
    };
    mat.customProgramCacheKey = function () { return 'anat-cloth-soft3'; };
    const cm = new THREE.Mesh(geo, mat);
    cm.name = 'anat_cloth';
    cm.castShadow = true; cm.frustumCulled = false; cm.raycast = function () {};
    const lm = new THREE.MeshBasicMaterial({ color: 0x6B4434, side: THREE.BackSide });
    lm.onBeforeCompile = function (sh) {
      clothDiscard(sh);
      sh.vertexShader = sh.vertexShader.replace('#include <begin_vertex>', 'vec3 transformed = position + normal * ' + (info.h * lk).toFixed(6) + ';');
    };
    lm.customProgramCacheKey = function () { return 'anat-cloth-line-' + (info.h * lk).toFixed(6); };
    const line = new THREE.Mesh(geo, lm);
    line.name = 'anat_cloth_line';
    line.raycast = function () {};
    // เส้นขอบ toon ไม่ใช้แล้ว (แสงนุ่มแบบภาพหุ่นสแกนใบหน้า)
    line.visible = false;
    cm.add(line);
    out.push(cm);
  });
  return out;
}
// เส้นขอบหุ่นนั่งรอ: กล้องโถงซูมครึ่งตัว (ใกล้) · บางกว่าหน้าเตียง ให้หนาบนจอเท่าหน้ารายละเอียด
const WAIT_LINE_K = 0.0011;
function sittingAnat(female, color) {
  const key = female ? 'f' : 'm';
  const get = anatBuf[key]
      ? Promise.resolve(anatBuf[key])
      : fetch(ANAT_SET[key].glb).then(function (r) { return r.arrayBuffer(); })
          .then(function (b) { anatBuf[key] = b; return b; });
  const cloth = loadProp('clothes_' + key + '.glb').catch(function (e) { send({ type: 'error', message: 'clothes: ' + e }); return null; });
  return Promise.all([get, cloth]).then(function (got) {
    const buf = got[0], cl = got[1];
    return new Promise(function (ok) {
      new THREE.GLTFLoader().parse(buf, '', function (gltf) {
        const src = gltf.scene;
        src.updateMatrixWorld(true);
        const info = anatFrameInfo(src);
        const g = new THREE.Group();
        const meshes = [];
        src.traverse(function (m) { if (m.isMesh) meshes.push(m); });
        // ตาเป็น node แยกวางเทียบผิว (ลูกของ bp3d_frame เหมือนกัน): เก็บตำแหน่งผิวไว้ ให้ตาอยู่ที่เดิมบนหน้า
        let skinAt = new THREE.Vector3(), skinN = 0;
        meshes.forEach(function (m) {
          const n = m.geometry.attributes.position.count;
          if (!/eye/i.test(m.name) && n > skinN) { skinN = n; skinAt = m.position.clone(); }
        });
        meshes.forEach(function (m) {
          m.frustumCulled = false; m.castShadow = true;
          if (/eye/i.test(m.name)) {
            m.position.sub(skinAt);
            m.material = anatEyeMat(m); addEyelid(m, key === 'm'); g.add(m); return;
          }
          // ใช้พิกัด mesh ตรง ๆ (ทิ้ง bp3d_frame ที่แปลงไปพิกัด BodyParts3D)
          m.position.set(0, 0, 0); m.rotation.set(0, 0, 0); m.scale.set(1, 1, 1);
          const geo = m.geometry.clone();
          m.geometry = geo;
          if (geo.attributes.uv && !geo.attributes.uv2) geo.setAttribute('uv2', geo.attributes.uv);
          // พับขาก่อน (แขนยังกางแบบ A-pose อยู่นอกช่วงขา) แล้วค่อยหุบแขน
          // เดิมหุบแขนก่อน: มือ/ปลายแขนเข้ามาในช่วงขา ถูกพับตามสะโพก ผิวแขนถูกดึงเป็นเส้น
          // เก็บพิกัดท่ายืนเดิมไว้: ใช้ระบายเสื้อผ้า และแยกว่าจุดไหนเป็นปลายแขน
          geo.setAttribute('rest', geo.attributes.position.clone());
          anatPoseSit(geo, ANAT_SET[key], info);
          anatPoseArms(geo, ANAT_SET[key], info);
          anatPoseLap(geo, ANAT_SET[key], info);
          m.material = anatSkinMat(key, info, true, true);
          m.userData.anat = { wx: ANAT_SET[key].wx, feet: info.feetY, ky: info.h / ANAT_REF_H };
          // เส้นขอบน้ำตาลเข้มแบบเดียวกับผู้ป่วยบนเตียง (ผิวด้านหลังพองออกเล็กน้อย)
          const line = new THREE.Mesh(geo, new THREE.MeshBasicMaterial({ color: 0x6B4434, side: THREE.BackSide }));
          line.material.onBeforeCompile = function (sh) {
            sh.vertexShader = sh.vertexShader.replace('#include <begin_vertex>', 'vec3 transformed = position + normal * ' + (info.h * WAIT_LINE_K).toFixed(6) + ';');
          };
          // แยก cache shader จากเส้นของหุ่นบนเตียง (ข้อความฟังก์ชันเดียวกัน ค่าความหนาต่างกัน)
          line.material.customProgramCacheKey = function () { return 'anat-line-wait-' + (info.h * WAIT_LINE_K).toFixed(6); };
          line.name = 'anat_line';
        line.visible = false; // แสงนุ่มแบบภาพหุ่นสแกนใบหน้า: ไม่มีเส้นขอบ toon
          line.raycast = function () {};
          m.add(line);
          g.add(m);
        });
        // ชุดผู้ป่วยจาก Blender พับท่านั่งด้วยฟังก์ชันชุดเดียวกับผิว
        if (cl) anatDress(cl, info, function (geo) {
          geo.setAttribute('rest', geo.attributes.position.clone());
          anatPoseSit(geo, ANAT_SET[key], info);
          anatPoseArms(geo, ANAT_SET[key], info);
          anatPoseLap(geo, ANAT_SET[key], info);
        }, WAIT_LINE_K).forEach(function (m) { g.add(m); });
        // สายรัดข้อมือสี ESI ที่ข้อมือซ้าย (ตำแหน่งหลังหุบแขน)
        const ky = info.h / ANAT_REF_H;
        const w0 = anatArmMove(0.36, 0.92, 1);
        const w1 = anatLapMove(w0[0], w0[1], 0.06, 1);
        const w2 = anatShoulderMove(w1[1], w1[2], 1);
        const w = [w1[0], w2[0], w2[1]];
        const band = new THREE.Mesh(new THREE.TorusGeometry(0.034, 0.009, 8, 28),
            new THREE.MeshStandardMaterial({ color: color, roughness: 0.5 }));
        band.position.set(w[0] * ANAT_SET[key].wx, w[1] * ky + info.feetY, w[2]);
        // แกนสายรัดตามแนวปลายแขนที่งอไปข้างหน้า
        band.rotation.x = Math.PI / 2 - (ANAT_LAP.deg + ANAT_LAP.sdeg) * Math.PI / 180;
        g.add(band);
        const bb = new THREE.Box3().setFromObject(g);
        // ฐานเดิมนับรวมตาที่เคยกองอยู่ที่ (0,0,0) · คงฐาน 0 ไว้ ค่าท่านั่ง WAIT.sitY ตั้งจากฐานนี้
        g.position.y = -Math.min(bb.min.y, 0);
        g.position.z = -0.12;
        const root = new THREE.Group(); root.add(g);
        ok(root);
      }, function () { ok(new THREE.Group()); });
    });
  }, function () { return new THREE.Group(); });
}

// ระยะห่างระหว่างเตียง (กลางถึงกลาง) = ความกว้างช่องนั่งรอหนึ่งช่อง
function bayWidth() {
  if (order.length > 1 && beds[order[0]] && beds[order[1]]) {
    const c0 = beds[order[0]].userData.center || new THREE.Box3().setFromObject(beds[order[0]]).getCenter(new THREE.Vector3());
    const c1 = beds[order[1]].userData.center || new THREE.Box3().setFromObject(beds[order[1]]).getCenter(new THREE.Vector3());
    return c0.distanceTo(c1);
  }
  return 2.6;
}
function waitAnchor() {
  if (!order.length || !beds[order[0]]) return null;
  // ช่องแรกต่อจากเตียงแรก ระยะเท่าเตียงถัดกัน (เรียงเป็นช่องเหมือนเตียง)
  const first = beds[order[0]];
  const c = (first.userData.center || new THREE.Box3().setFromObject(first).getCenter(new THREE.Vector3())).clone();
  // ทิศแถว = เตียงแรกไปเตียงถัดไป (ไม่ใช้ rowDir ที่ลากถึงเตียงสุดท้าย
  // ซึ่งอยู่อีกแถว ทำให้ช่องนั่งรอเอียงไม่ขนานผนัง)
  let dir = rowDir ? rowDir.clone() : new THREE.Vector3(1, 0, 0);
  if (order.length > 1 && beds[order[1]]) {
    const c1 = beds[order[1]].userData.center;
    if (c1) dir = c1.clone().sub(first.userData.center).setY(0).normalize();
  }
  return { at: c.add(dir.clone().multiplyScalar(-bayWidth())).add(new THREE.Vector3(0, 0, WAIT.front)), dir: dir };
}
// gap = ระยะคนถัดกัน (นั่งเรียงกันเว้นที่ว่างพอดี ไม่ใช่ช่องละเตียง)
// seatLen: เก้าอี้แถวยาว 1.84 ม. (ที่นั่งละ ~0.6 ม. เบาะ ~0.33 พนัก ~0.94 ใกล้ของจริง)
// sitY: ท่านั่งพับขาไว้ที่ความสูงสะโพกท่ายืน (ก้น ~0.72 ม.) เลื่อนลงให้ก้นแตะเบาะ เท้าแตะพื้น
const WAIT = { front: 0.6, seatLen: 1.84, wheelLen: 1.0, sitY: -0.41, sitZ: -0.12, gap: 1.15, seatK: 0.8, chairZ: -0.2,
  ptZ0: -1.75, ptZ1: 0.35, ptH: 1.95, kickY: 0.3 };
window.erWait = function (o) { Object.assign(WAIT, o); window.erSetWaiting(waitList); };

// ---- โถงนั่งรอ (หน้าผังเตียง เลือกคนที่ยังไม่มีเตียง)
// กล้องหน้าโถง เยื้องขวา: ผู้ป่วยนั่งม้านั่งฝั่งซ้ายของภาพ ขวาเว้นว่างให้ป้ายอาการ
const WSIDE = { camX: -0.44, camY: 1.4, camZ: 2.6, lookX: 0.5, lookY: 0.42, fade: 0.88 };
window.erWaitCam = function (o) { Object.assign(WSIDE, o); markDirty(8); };
let waitMix = 0;
// ทุกคนนั่งที่นั่งเดียวกันในโถง (สลับคน = จางเข้า/ออก ไม่เลื่อนกล้อง)
// มารถนั่ง = รถเข็นจอดตำแหน่งเดียวกับที่นั่ง (กรอบภาพเท่ากัน) · ม้านั่งเลื่อนไปซ้ายหลบให้
const WAIT_WHEEL_X = 0;
const WAIT_WHEEL_Z = WAIT.sitZ + 0.05;
const WAIT_BENCH_SHIFT = 0.62;
let waitBench = null;
// เบาะรถเข็นสูงกว่าม้านั่ง ~0.16 ม. → ยกกล้องตาม (ค่อย ๆ เลื่อน) ให้กรอบครึ่งตัวเท่ากัน
const WAIT_WHEEL_LIFT = 0.16;
let waitLift = 0;
function waitX(i) { return waitList[i] && waitList[i].wheel ? WAIT_WHEEL_X : 0; }
function waitSelIdx() {
  return String(selected).indexOf('WAIT') === 0
      ? (parseInt(String(selected).split(':')[1] || '0', 10) || 0) : -1;
}
// วัสดุของแต่ละชิ้นเป็นของตัวเอง (โมเดลที่ clone ใช้วัสดุร่วมกัน) จางทีละคนได้
// หุ่น (own=false): วัสดุสร้างใหม่ทุกตัวอยู่แล้ว ห้าม clone (clone ทิ้ง shader ผิว/กางเกง)
function waitOwn(obj, i, own) {
  obj.userData.waitIdx = i;
  if (own === false) return;
  obj.traverse(function (m) {
    if (!m.isMesh || !m.material) return;
    m.material = Array.isArray(m.material)
        ? m.material.map(function (x) { return x.clone(); }) : m.material.clone();
  });
}
// คืน true ถ้ายังเปลี่ยนอยู่ · เปลี่ยนคน = คนเดิมจางออก คนใหม่จางเข้า (นั่งที่เดียวกัน)
function stepWait() {
  const want = (waitSelIdx() >= 0 && topWant < 0.5 && waitRoot.parent) ? 1 : 0;
  let moving = false;
  if (waitMix !== want) {
    waitMix += (want - waitMix) * 0.1;
    if (Math.abs(want - waitMix) < 0.002) waitMix = want;
    moving = true;
  }
  const n = waitSelIdx();
  // ม้านั่งหลบไปซ้ายตอนดูคนมารถเข็น (รถเข็นจอดที่นั่งเดิม)
  if (waitBench && waitBench.parent) {
    const bx = WAIT_BENCH_X - (n >= 0 && waitList[n] && waitList[n].wheel ? WAIT_BENCH_SHIFT : 0);
    const px = waitBench.position.x;
    if (Math.abs(bx - px) > 0.001) {
      waitBench.position.x = px + (bx - px) * 0.16;
      if (Math.abs(bx - waitBench.position.x) < 0.002) waitBench.position.x = bx;
      moving = true;
    }
  }
  const lw = n >= 0 && waitList[n] && waitList[n].wheel ? WAIT_WHEEL_LIFT : 0;
  if (Math.abs(lw - waitLift) > 0.0005) {
    waitLift += (lw - waitLift) * 0.12;
    if (Math.abs(lw - waitLift) < 0.001) waitLift = lw;
    moving = true;
  }
  waitRoot.children.forEach(function (c) {
    if (c.userData.waitIdx === undefined) return;
    const t = c.userData.waitIdx === n ? 1 : 0;
    const op0 = c.userData.op === undefined ? -1 : c.userData.op;
    let op = op0 < 0 ? t : op0 + (t - op0) * 0.16;
    if (Math.abs(t - op) < 0.01) op = t;
    if (op === op0) return;
    c.userData.op = op;
    c.visible = op > 0.005;
    c.traverse(function (m) {
      if (!m.isMesh || !m.material) return;
      (Array.isArray(m.material) ? m.material : [m.material]).forEach(function (mat) {
        mat.transparent = op < 0.999;
        mat.opacity = op;
        mat.depthWrite = op > 0.5;
      });
    });
    moving = true;
  });
  if (moving) renderer.shadowMap.needsUpdate = true;
  return moving;
}
function waitE() {
  const t = waitMix;
  const te = topMix * topMix * (3 - 2 * topMix);
  return t * t * (3 - 2 * t) * (1 - te);
}
// หน้ารายละเอียด (ห้องจาง) ซ่อนจอ monitor และป้ายเตียง · กลับหน้าผังเตียงคืนให้
// (คนไม่มีเตียงยืมเตียงแรกในหน้ารายละเอียด erSelect จึงเปิดจอของเตียงนั้นขึ้นมา)
let monDetailHid = false;
function applyMonDetail() {
  if (!mon) return;
  const hide = envFade() > 0.5 || topWant > 0.5;
  if (!hide && !monDetailHid) return;
  const show = !hide && waitSelIdx() < 0 && waitE() < 0.5;
  mon.g.visible = show;
  if (mon.sign) mon.sign.visible = show;
  monDetailHid = hide;
}
let waitHid = false;
const LOBBY_BG = new THREE.Color(0xf2f3f6);
// แสงโถงนั่งรอ (2026-11-26 "แสงยังไม่เลิศ"): ไฟหลักแดดอุ่นเฉียงจากหน้าซ้ายบน เล็งที่โถงโดยตรง
// กรอบเงาแคบ (±4.5 ม.) = เงาคน/เก้าอี้ตกบนผนังระแนงและพื้นชัด นุ่ม · แสงรอบตัวลดลง ฟ้าอมเย็น = มีทิศแสง
// กลับห้องเตียง = คืนค่าไฟเดิม
const keyHome = { pos: key.position.clone(), tgt: new THREE.Vector3(), color: key.color.clone(), i: key.intensity,
  cam: { l: key.shadow.camera.left, r: key.shadow.camera.right, t: key.shadow.camera.top, b: key.shadow.camera.bottom },
  hi: hemi.intensity, hs: hemi.color.clone(), hg: hemi.groundColor.clone(), fi: fill.intensity };
function lobbyLight(on) {
  const sc = key.shadow.camera;
  if (on && waitRoot.parent) {
    waitRoot.updateMatrixWorld(true);
    const at = waitRoot.localToWorld(new THREE.Vector3(-0.5, 0.6, -0.4));
    key.target.position.copy(at);
    key.position.copy(waitRoot.localToWorld(new THREE.Vector3(-2.6, 4.6, 3.4)));
    key.color.setHex(0xfff1df);
    key.intensity = 1.75;
    sc.left = -4.5; sc.right = 4.5; sc.top = 4.5; sc.bottom = -4.5;
    hemi.intensity = 0.48; hemi.color.setHex(0xeef3ff); hemi.groundColor.setHex(0xb9b2a6);
    fill.intensity = 0.32;
    renderer.toneMappingExposure = 1.1;
  } else {
    key.position.copy(keyHome.pos);
    key.target.position.copy(keyHome.tgt);
    key.color.copy(keyHome.color);
    key.intensity = keyHome.i;
    sc.left = keyHome.cam.l; sc.right = keyHome.cam.r; sc.top = keyHome.cam.t; sc.bottom = keyHome.cam.b;
    hemi.intensity = keyHome.hi; hemi.color.copy(keyHome.hs); hemi.groundColor.copy(keyHome.hg);
    fill.intensity = keyHome.fi;
    renderer.toneMappingExposure = 1.0;
  }
  key.target.updateMatrixWorld();
  sc.updateProjectionMatrix();
}
function applyWaitFade() {
  const e = waitE();
  // โถงนั่งรอแสดงเฉพาะตอนเลือกคนไม่มีเตียง · ห้องเตียงซ่อนตอนผสมเกินครึ่ง
  waitRoot.visible = e > 0.01;
  const hide = e > 0.5;
  if (hide || waitHid) {
    if (roomRoot) roomRoot.visible = !hide;
    Object.keys(figures).forEach(function (c) {
      const f = figures[c];
      if (f && f !== 'loading' && hide) f.visible = false;
    });
    // จอ monitor: ซ่อนตอนโถงนั่งรอ · กลับมุมเตียงคืนให้ (erSelect เปิดไว้ก่อนการจางจบ)
    if (mon && (hide || waitSelIdx() < 0)) {
      mon.g.visible = !hide;
      if (mon.sign) mon.sign.visible = !hide;
    }
    if (waitHid !== hide) {
      lobbyLight(hide);
      renderer.shadowMap.needsUpdate = true;
    }
    waitHid = hide;
  }
  if (e > 0) scene.background.lerp(LOBBY_BG, e);
}

// ห้องจริงมีที่พอสำหรับเตียงเท่านั้น ช่องนั่งรอที่ต่อออกไปจึงต่อพื้น/ผนังให้
// ใช้วัสดุเดียวกับห้อง (ยิง ray หาพื้นหน้าเตียงแรกและผนังหลังเตียงแรก)
function roomMatAt(origin, dir) {
  const rc = new THREE.Raycaster(origin, dir.clone().normalize(), 0.05, 12);
  const hits = rc.intersectObjects(scene.children, true);
  for (let k = 0; k < hits.length; k++) {
    let o = hits[k].object, mine = false;
    while (o) { if (o === waitRoot || o.userData.isBed) { mine = true; break; } o = o.parent; }
    if (mine || !hits[k].object.material) continue;
    const m = hits[k].object.material;
    return Array.isArray(m) ? m[0] : m;
  }
  return null;
}
function tiledMat(src, fallback, w, h, tile) {
  if (!src) return new THREE.MeshStandardMaterial({ color: fallback, roughness: 0.9 });
  const m = src.clone();
  if (m.map) {
    m.map = m.map.clone();
    m.map.wrapS = m.map.wrapT = THREE.RepeatWrapping;
    m.map.repeat.set(w / tile, h / tile);
    m.map.needsUpdate = true;
  }
  return m;
}
// ลายไม้โอ๊ค (วาดเอง ไม่ใช้ไฟล์): ลายเสี้ยนตามแนวตั้ง · slats > 0 = ระแนงไม้มีร่องเงาระหว่างแผ่น
const woodTexCache = {};
function woodTex(slats) {
  const key = 'w' + (slats || 0);
  if (woodTexCache[key]) return woodTexCache[key];
  const W = 256, H = 512;
  const c = document.createElement('canvas'); c.width = W; c.height = H;
  const x = c.getContext('2d'), img = x.createImageData(W, H);
  let seed = 7;
  function rnd() { seed = (seed * 16807) % 2147483647; return seed / 2147483647; }
  const ph = [], fq = [];
  for (let i = 0; i < 9; i++) { ph.push(rnd() * 6.28); fq.push(8 + rnd() * 30); }
  for (let r = 0; r < H; r++) {
    for (let q = 0; q < W; q++) {
      const u = q / W, v = r / H;
      // เสี้ยนไม้: เส้นถี่ตามแนวตั้ง โค้งเล็กน้อย + จุดด่างอ่อน
      let g = 0;
      for (let i = 0; i < 9; i++) g += Math.sin((u + 0.012 * Math.sin(v * 6 + ph[i])) * fq[i] * 6.28 + ph[i]);
      g = g / 9;
      // ไม้โอ๊คธรรมชาติ (ผู้ใช้ 2026-11-26 "สีไม้เอา oak"): น้ำตาลทองอุ่น เสี้ยนชัดกว่าเดิม
      // + ลายเส้นเสี้ยนเข้มยาว (rays/flecks) แบบไม้โอ๊ค
      const streak = Math.pow(Math.max(0, Math.sin((u + 0.02 * Math.sin(v * 3 + ph[2])) * 61.0 + ph[4])), 18);
      let k = (0.90 + 0.10 * g) * (1 - 0.16 * streak);
      let R = 196 * k, G = 148 * k, B = 98 * k;
      if (slats) {
        const p = (u * slats) % 1;
        if (p > 0.82) { R *= 0.42; G *= 0.40; B *= 0.40; }          // ร่องเงาระหว่างระแนง
        else if (p > 0.76) { R *= 0.86; G *= 0.85; B *= 0.84; }     // ขอบระแนงรับแสงน้อย
      }
      const i4 = (r * W + q) * 4;
      img.data[i4] = R; img.data[i4 + 1] = G; img.data[i4 + 2] = B; img.data[i4 + 3] = 255;
    }
  }
  x.putImageData(img, 0, 0);
  const t = new THREE.CanvasTexture(c);
  t.encoding = THREE.sRGBEncoding;
  t.wrapS = t.wrapT = THREE.RepeatWrapping;
  t.anisotropy = 4;
  woodTexCache[key] = t;
  return t;
}
const WOOD_HEX = 0xc49a6c;   // ไม้โอ๊ค (เบาะเก้าอี้/ของชิ้นเล็ก ที่ไม่มี UV ลายไม้)

// ---- โถงนั่งรอ (2026-11-26 โรงพยาบาลขาว + ไม้): ผนังขาว ผนังระแนงไม้หลังเก้าอี้ แถบกันชนไม้ พื้นกระเบื้องห้อง
// จอคิว ต้นไม้กระถาง เก้าอี้แถวเดิม ทางเดินด้านขวา
// ของทั้งหมดอยู่ซ้ายของภาพ ขวาเว้นว่างไว้วางป้ายอาการ · พิกัด waitRoot (ผนังที่ z = -0.62)
// กลางเก้าอี้แถว: ถอยซ้ายหนึ่งที่นั่ง (ที่นั่งละ seatLen × seatK / 3) ผู้ป่วยจึงนั่งที่ขวาสุด
const WAIT_BENCH_X = -WAIT.seatLen * WAIT.seatK / 3;
// ความกว้างทางเดินด้านขวาของโถง
const WAIT_CORR_W = 3.4;
function waitLobby() {
  const g = new THREE.Group();
  g.name = 'lobby';
  function M(c, o) { return new THREE.MeshStandardMaterial(Object.assign({ color: c, roughness: 0.9 }, o || {})); }
  function add(geo, mat, x, y, z, ry) {
    const m = new THREE.Mesh(geo, mat);
    m.position.set(x, y, z);
    if (ry) m.rotation.y = ry;
    m.receiveShadow = true;
    g.add(m);
    return m;
  }
  // ---- มิติแสงเงาแบบอบไว้ในพื้นผิว (2026-11-26 "ฉากหลังดู flat"): ไม่เพิ่มไฟในฉาก (ไม่เพิ่มต้นทุน shader)
  // shadeTex(fn) = ภาพเทา 128² (fn(u, t) → ความสว่าง 0–1 · u ตามแนวยาว · t ตามความสูง 0 = ล่าง) คูณสีวัสดุ
  // aoTex(fn) = ความทึบ (alphaMap) สำหรับแผ่นเงาสีดำโปร่งวางชิดผิว
  function shadeTex(fn, alpha) {
    const c = document.createElement('canvas'); c.width = c.height = 128;
    const cx = c.getContext('2d'), img = cx.createImageData(128, 128);
    for (let r = 0; r < 128; r++) {
      for (let q = 0; q < 128; q++) {
        const v = Math.round(255 * Math.max(0, Math.min(1, fn(q / 127, 1 - r / 127))));
        const i = (r * 128 + q) * 4;
        img.data[i] = img.data[i + 1] = img.data[i + 2] = v; img.data[i + 3] = 255;
      }
    }
    cx.putImageData(img, 0, 0);
    const t = new THREE.CanvasTexture(c);
    if (!alpha) t.encoding = THREE.sRGBEncoding;
    return t;
  }
  // ผนัง: เงาสัมผัสที่โคนผนัง (AO) + ขอบบนหม่นลงนิด · far(u) = ความสว่างตามแนวยาว (ลึกเข้าทางเดิน = มืดลง)
  function wallShade(far) {
    return shadeTex(function (u, t) {
      const h = t * 3.2;
      const ao = 1 - 0.30 * Math.exp(-h / 0.28) - 0.10 * Math.max(0, (h - 2.0) / 1.2);
      return ao * far(u);
    });
  }
  const aoStrip = shadeTex(function (u, t) { return 0.34 * Math.exp(-t * 3.6); }, true);
  // ผู้ป่วยอยู่ที่ x = 0 (ที่นั่งขวาสุดของเก้าอี้แถว) · เก้าอี้ชิดมุมขวาของผนัง แล้วเป็นทางเดิน
  const BX = WAIT_BENCH_X, WZ = -0.62, WL = -6.0, WR = 0.42;
  // สีชุดเดิมของห้อง: พื้นใช้วัสดุพื้นห้องจริง (ปูซ้ำ) · ผนังเทาม่วง · แถบกันชนกรมท่า
  const kickTex = woodTex(0).clone(); kickTex.needsUpdate = true; kickTex.repeat.set(8, 0.1);
  const kickM = M(0xffffff, { roughness: 0.55, map: kickTex });
  // พื้น: ใช้แผ่นพื้นจริงของห้อง (ground_*) ปูเป็นตาราง สี/ลายเหมือนห้องเดิมทุกอย่าง
  const tile = roomRoot && roomRoot.getObjectByName('ground_0_0');
  if (tile) {
    tile.updateMatrixWorld(true);
    const ts = new THREE.Box3().setFromObject(tile).getSize(new THREE.Vector3());
    const ws = tile.getWorldScale(new THREE.Vector3());
    for (let tx = -4.5; tx < 10; tx += ts.x) {
      for (let tz = -9; tz < 6; tz += ts.z) {
        const t = tile.clone();
        t.scale.copy(ws);
        t.rotation.set(0, 0, 0);
        t.position.set(tx, 0, tz);
        t.receiveShadow = true;
        g.add(t);
      }
    }
  } else {
    const fl = add(new THREE.PlaneGeometry(18, 18), M(0xdfe1e4), 1.5, 0.003, -2);
    fl.rotation.x = -Math.PI / 2;
  }
  // ผนังเรียบแบบภาพอ้างอิง (ไม่มีเสา) สีจูนให้ออกมาเท่าผนังห้องเตียง (#b4b2b6 บนจอ) + แถบกันชนกรมท่า
  // แนวผนังสร้างตามแกน x หน้าผนังหันไป +z แล้วหมุนวางตามตำแหน่ง
  function wallRun(len, px, pz, ry, far) {
    const G0 = new THREE.Group();
    const pl = new THREE.Mesh(new THREE.PlaneGeometry(len, 3.2),
        M(0xffffff, { roughness: 0.92, emissive: 0xffffff, emissiveIntensity: 0.04,
          map: wallShade(far || function () { return 1; }) }));
    pl.position.set(len / 2, 1.6, 0);
    pl.receiveShadow = true;
    // เงาสัมผัสบนพื้นชิดโคนผนัง (ผนังกับพื้นไม่ลอยแยกกัน)
    const fa = new THREE.Mesh(new THREE.PlaneGeometry(len, 0.55), new THREE.MeshBasicMaterial({
      color: 0x000000, transparent: true, alphaMap: aoStrip, depthWrite: false, toneMapped: false }));
    fa.rotation.x = -Math.PI / 2; fa.rotation.z = Math.PI;
    fa.position.set(len / 2, 0.006, 0.275);
    fa.renderOrder = 1;
    G0.add(fa);
    const k = new THREE.Mesh(new THREE.BoxGeometry(len, 0.12, 0.02), kickM);
    k.position.set(len / 2, WAIT.kickY, 0.012);
    G0.add(pl); G0.add(k);
    G0.position.set(px, 0, pz);
    G0.rotation.y = ry || 0;
    g.add(G0);
  }
  // ผนังหลังม้านั่ง: จบที่มุมทางเดินพอดี · ไกลจากผู้ป่วย (ซ้าย) หม่นลง
  // แสงตกเป็นวงรอบผู้ป่วย (x ≈ -0.3) แล้วค่อย ๆ หม่นออกไปทางซ้าย = ผนังมีระยะ ไม่เรียบเท่ากันทั้งแผ่น
  wallRun(WR - WL, WL, WZ, 0, function (u) {
    const x = WL + u * (WR - WL);
    return 0.80 + 0.20 * Math.exp(-Math.pow((x + 0.3) / 1.7, 2));
  });
  // ทางเดินด้านขวา: ผนังซ้าย (หันไปทาง +x) ลึกเข้าไป (u → 1) มืดลง + ผนังปลายทาง
  wallRun(7.6, WR, WZ, Math.PI / 2, function (u) { return 0.96 - 0.30 * u; });
  // ทางเดิน (แบบภาพอ้างอิง): ผนังขวา + ประตู · เพดาน + ไฟแขวนแบบเส้นเรียงลึกเข้าไป
  const CW = WAIT_CORR_W, RX = WR + CW;
  wallRun(CW, WR, WZ - 7.6, 0, function (u) { return 0.70 + 0.05 * Math.sin(Math.PI * u); });
  // ผนังขวาของทางเดิน (หันไปทาง -x) · เริ่มที่ปลายลึก (u = 0) = มืด
  wallRun(7.6, RX, WZ - 7.6, -Math.PI / 2, function (u) { return 0.70 + 0.30 * u; });
  // ผนังระแนงไม้หลังเก้าอี้แถว (feature wall) สูง 2.4 ม. กว้างคลุมแถวเก้าอี้ + ผู้ป่วย
  {
    const fx0 = BX - WAIT.seatLen * WAIT.seatK / 2 - 0.55, fx1 = WR - 0.06, fw = fx1 - fx0;
    const st = woodTex(1).clone(); st.needsUpdate = true; st.repeat.set(fw / 0.11, 1);
    const fwm = add(new THREE.PlaneGeometry(fw, 2.4), M(0xffffff, { roughness: 0.7, map: st }),
        (fx0 + fx1) / 2, 1.2, WZ + 0.008);
    fwm.receiveShadow = true;
    // ขอบบนระแนง: เงาสันไม้บนผนังขาว
    const lip = add(new THREE.BoxGeometry(fw, 0.03, 0.03), M(0xffffff, { roughness: 0.6, map: woodTex(0) }),
        (fx0 + fx1) / 2, 2.415, WZ + 0.02);
    lip.castShadow = true;
  }
  // เงานุ่มของคนนั่ง + เก้าอี้แถว (ไฟหลักจากหน้าซ้ายบน → เงาตกบนผนังเยื้องขวาล่าง · ใต้เก้าอี้บนพื้น)
  const blobTex = shadeTex(function (u, t) {
    const dx = (u - 0.5) * 2, dy = (t - 0.5) * 2;
    return Math.pow(Math.max(0, 1 - Math.sqrt(dx * dx + dy * dy)), 1.6);
  }, true);
  function blob(w, h, a, col) {
    return new THREE.Mesh(new THREE.PlaneGeometry(w, h), new THREE.MeshBasicMaterial({
      color: col || 0x141a2a, transparent: true, opacity: a, alphaMap: blobTex, depthWrite: false, toneMapped: false }));
  }
  // เงาจริงจากไฟหลักโถงแล้ว: เงานุ่มนี้เหลือเป็นแสงบดบังรอบตัว (AO) เบา ๆ
  const ws1 = blob(1.3, 2.0, 0.14); ws1.position.set(0.28, 0.95, WZ + 0.014); ws1.renderOrder = 1; g.add(ws1);
  const ws2 = blob(WAIT.seatLen * WAIT.seatK + 0.6, 1.1, 0.12); ws2.position.set(BX + 0.1, 0.55, WZ + 0.013); ws2.renderOrder = 1; g.add(ws2);
  const fs1 = blob(WAIT.seatLen * WAIT.seatK + 0.5, 1.0, 0.34); fs1.rotation.x = -Math.PI / 2;
  fs1.position.set(BX + 0.05, 0.007, WAIT.chairZ - 0.05); fs1.renderOrder = 1; g.add(fs1);
  // พื้นทางเดินช่วงลึกมืดลง (ระยะลึกของภาพ)
  const deep = add(new THREE.PlaneGeometry(CW, 7.6), new THREE.MeshBasicMaterial({
    color: 0x0b1020, transparent: true, depthWrite: false, toneMapped: false,
    alphaMap: shadeTex(function (u, t) { return 0.14 * Math.pow(t, 1.6); }, true) }), WR + CW / 2, 0.005, WZ - 3.8);
  deep.rotation.x = -Math.PI / 2; deep.receiveShadow = false; deep.renderOrder = 1;
  const doorTex = woodTex(0).clone(); doorTex.needsUpdate = true; doorTex.repeat.set(1, 1);
  const doorM = M(0xffffff, { roughness: 0.6, map: doorTex }), frameM = M(0xffffff, { roughness: 0.6 });
  [-3.3, -6.2].forEach(function (dz) {
    add(new THREE.BoxGeometry(0.03, 2.15, 1.0), frameM, RX - 0.015, 1.075, dz);
    add(new THREE.BoxGeometry(0.03, 2.05, 0.9), doorM, RX - 0.03, 1.025, dz);
    add(new THREE.BoxGeometry(0.04, 0.03, 0.14), kickM, RX - 0.06, 1.0, dz + 0.32);
  });
  const ceil = add(new THREE.PlaneGeometry(CW + 0.02, 11), M(0xffffff, { emissive: 0xffffff, emissiveIntensity: 0.08,
    map: shadeTex(function (u, t) { return 0.86 + 0.14 * t; }) }), WR + CW / 2, 2.75, WZ - 3.0);
  ceil.rotation.x = Math.PI / 2;
  const lampM = M(0x2a2d33, { roughness: 0.5 });
  const glowM = new THREE.MeshBasicMaterial({ color: 0xfdfcf6, toneMapped: false });
  for (let lz = WZ + 0.2; lz > -8; lz -= 1.35) {
    add(new THREE.BoxGeometry(1.5, 0.05, 0.08), lampM, WR + CW / 2, 2.4, lz);
    add(new THREE.PlaneGeometry(1.44, 0.05), glowM, WR + CW / 2, 2.374, lz).rotation.x = Math.PI / 2;
    [-0.6, 0.6].forEach(function (cx) {
      add(new THREE.CylinderGeometry(0.004, 0.004, 0.35, 4), lampM, WR + CW / 2 + cx, 2.575, lz);
    });
  }
  // จอคิวบนผนัง
  add(new THREE.BoxGeometry(1.35, 0.78, 0.05), M(0x23262b, { roughness: 0.4 }), BX, 1.66, WZ + 0.04);
  const cv = document.createElement('canvas');
  cv.width = 640; cv.height = 360;
  const x = cv.getContext('2d');
  x.fillStyle = '#ffffff'; x.fillRect(0, 0, 640, 360);
  x.fillStyle = '#1f2f6e'; x.fillRect(0, 0, 640, 64);
  x.fillStyle = '#ffffff'; x.font = '600 30px sans-serif';
  x.fillText('ห้องฉุกเฉิน  คิวรอตรวจ', 28, 43);
  for (let r = 0; r < 6; r++) {
    const y = 96 + r * 42;
    x.fillStyle = '#e3e6ea'; x.fillRect(28, y, 380, 22);
    x.fillStyle = r < 2 ? '#1f2f6e' : '#9aa3ad'; x.fillRect(560, y, 52, 22);
  }
  const tex = new THREE.CanvasTexture(cv);
  tex.encoding = THREE.sRGBEncoding;
  add(new THREE.PlaneGeometry(1.27, 0.71), new THREE.MeshBasicMaterial({ map: tex, toneMapped: false }), BX, 1.66, WZ + 0.067);
  // ต้นไม้กระถาง (ซ้ายของม้านั่ง + ในทางเดิน)
  // ต้นไม้กระถางแบบภาพอ้างอิง: กระถางกลมขาวปากกว้าง + ลำต้นเรียวแตกกิ่ง + พุ่มใบกลมแน่น
  // พุ่ม = ก้อนใบเล็กหลายสิบก้อนสุ่มในทรงรี (seed คงที่ หน้าตาเหมือนเดิมทุกครั้ง) เขียว 3 เฉด
  const potM = M(0xe4e4e2, { roughness: 0.45 }), soilM = M(0x3b2f27), barkM = M(0x5e4634, { roughness: 0.8 });
  // เขียวเข้มอิ่มขึ้น: ใบบางสองหน้ารับแสงจากบนเต็ม ๆ สีอ่อนเกินจะดูซีดขาว
  const leafMs = [0x2c6a2a, 0x3a7f34, 0x4f9443].map(function (c) {
    const m = M(c, { roughness: 0.9 }); m.side = THREE.DoubleSide; return m;
  });
  // ใบไม้แบบใบยางอินเดีย: ใบรีปลายแหลม ยาวตามแกน +Z แบนในระนาบ XZ · โค้งห่อกลางใบ + ปลายใบโน้มลง
  const leafGeo = (function () {
    const sh = new THREE.Shape();
    const N = 14, pts = [];
    for (let i = 0; i <= N; i++) {
      const t = i / N, w = 0.36 * Math.pow(Math.sin(Math.PI * t), 0.8) * (1.0 - 0.25 * t);
      pts.push([w, t]);
    }
    sh.moveTo(0, 0);
    pts.forEach(function (q) { sh.lineTo(q[0], q[1]); });
    for (let i = N; i >= 0; i--) sh.lineTo(-pts[i][0], pts[i][1]);
    const g0 = new THREE.ShapeGeometry(sh, 6);
    const p = g0.attributes.position;
    for (let i = 0; i < p.count; i++) {
      const x = p.getX(i), t = p.getY(i);
      // ระนาบ XY → XZ (ยาวไป +Z) · ห่อกลางใบ (ขอบยกขึ้น) · ปลายใบโค้งลง
      p.setXYZ(i, x, 0.55 * x * x - 0.22 * t * t, t);
    }
    g0.computeVertexNormals();
    return g0;
  })();
  const potGeo = new THREE.LatheGeometry([
    new THREE.Vector2(0.0, 0.0), new THREE.Vector2(0.15, 0.0), new THREE.Vector2(0.19, 0.06),
    new THREE.Vector2(0.215, 0.2), new THREE.Vector2(0.225, 0.36), new THREE.Vector2(0.235, 0.44),
    new THREE.Vector2(0.215, 0.445), new THREE.Vector2(0.2, 0.42),
  ], 32);
  function plant(px, pz, k) {
    let seed = Math.round(px * 977 + pz * 131) | 0;
    function rnd() { seed = (seed * 16807 + 11) % 2147483647; return (seed & 0xffff) / 0xffff; }
    const P = new THREE.Group();
    const pot = new THREE.Mesh(potGeo, potM);
    pot.castShadow = true; pot.receiveShadow = true;
    P.add(pot);
    const soil = new THREE.Mesh(new THREE.CircleGeometry(0.2, 24), soilM);
    soil.rotation.x = -Math.PI / 2; soil.position.y = 0.41;
    P.add(soil);
    // ลำต้น + กิ่งสั้น 2 กิ่งเข้าพุ่ม
    const trunk = new THREE.Mesh(new THREE.CylinderGeometry(0.014, 0.026, 1.2, 8), barkM);
    trunk.position.y = 1.0; trunk.castShadow = true;
    P.add(trunk);
    [[0.6, 0.5], [-0.7, -0.3]].forEach(function (b) {
      const br = new THREE.Mesh(new THREE.CylinderGeometry(0.008, 0.012, 0.28, 6), barkM);
      br.position.set(Math.sin(b[1]) * 0.06, 1.12, Math.cos(b[1]) * 0.03);
      br.rotation.z = b[0]; br.castShadow = true;
      P.add(br);
    });
    // พุ่มใบ: ใบรีชี้ออกรอบลำต้นเป็นชั้น ๆ (ล่างกางกว้าง บนชี้ขึ้น) สีเข้มด้านล่าง อ่อนด้านบน
    for (let i = 0; i < 54; i++) {
      const h = rnd();                        // 0 = ล่างพุ่ม · 1 = ยอด
      const y = 1.0 + h * 0.72;
      const az = rnd() * Math.PI * 2 + i * 2.39996;
      const out = 0.03 + (1 - Math.abs(h - 0.4)) * 0.07 * rnd();
      const leaf = new THREE.Mesh(leafGeo, leafMs[h > 0.62 ? 2 : h > 0.3 ? 1 : 0]);
      const len = 0.17 + rnd() * 0.08 - h * 0.04;
      leaf.scale.set(len, len, len);
      leaf.position.set(Math.cos(az) * out, y, Math.sin(az) * out);
      leaf.rotation.order = 'YXZ';
      leaf.rotation.y = Math.PI / 2 - az;     // ชี้ออกจากลำต้นตามทิศ az
      leaf.rotation.x = -(0.15 + h * 0.9 + rnd() * 0.25);   // ยิ่งสูงยิ่งเชิดขึ้น
      leaf.rotation.z = (rnd() - 0.5) * 0.7;
      leaf.castShadow = true;
      P.add(leaf);
    }
    P.scale.setScalar(k);
    P.position.set(px, 0, pz);
    g.add(P);
  }
  plant(BX - 1.25, -0.3, 1);
  // ต้นไม้ตามทางเดิน: ข้างเก้าอี้ฝั่งซ้าย + ฝั่งขวา
  // ต้นที่เคยอยู่หลังการ์ดสรุป ย้ายไปมุมขวาบนของภาพ (มุมผนังขวาของทางเดินช่วงลึก)
  plant(RX - 0.4, -6.4, 0.95);
  // (ต้นไม้ข้างเก้าอี้ฝั่งซ้ายเอาออก: อยู่หลังหรือหน้าแถวเก้าอี้ก็ซ้อนกันในภาพ ดูรก)
  plant(RX - 0.4, -1.6, 0.9);
  return g;
}

// จุดยึดป้ายอาการบนหุ่นนั่งรอ: พิกัดท่ายืน (เมตร เท้าที่ y=0 · +x = ซ้ายผู้ป่วย · +z = หน้า)
// ตรงกับรหัสจาก er_body_map (อวัยวะ · bone:<ส่วน>_<l|r> · zone:<id>) · ยื่นออกหน้าผิวนิด
// หาจุดยอดผิวที่ใกล้สุดตามพิกัด rest (ท่ายืน) แล้วใช้ตำแหน่งท่านั่งจริงของจุดนั้น
const WAIT_SPOT = {
  brain: [0, 1.6, 0.1], skull: [0, 1.6, 0.1], head: [0, 1.6, 0.1],
  throat: [0, 1.47, 0.08], trachea: [0, 1.47, 0.08], esophagus: [0, 1.47, 0.08], cspine: [0, 1.48, -0.1],
  chest: [0.06, 1.3, 0.14], lungs: [0.06, 1.3, 0.14], heart: [0.05, 1.28, 0.14],
  ribs: [0.13, 1.22, 0.08], clavicle: [0.08, 1.42, 0.08], tspine: [0, 1.3, -0.15],
  epigastric: [0.02, 1.16, 0.14], stomach: [0.04, 1.15, 0.14], pancreas: [0, 1.12, 0.13],
  liver: [-0.08, 1.14, 0.13], ruq: [-0.08, 1.14, 0.13], luq: [0.08, 1.14, 0.13],
  abdomen: [0, 1.04, 0.15], intestine: [0, 1.04, 0.15], rlq: [-0.07, 0.98, 0.14], llq: [0.07, 0.98, 0.14],
  suprapubic: [0, 0.92, 0.13], bladder: [0, 0.92, 0.13], pelvis: [0, 0.9, 0.1],
  kidneys: [-0.15, 1.07, 0], flank_r: [-0.15, 1.07, 0], flank_l: [0.15, 1.07, 0],
  lowback: [0, 1.04, -0.15], lspine: [0, 1.04, -0.15],
  humerus: [0.24, 1.24, 0], forearm: [0.32, 0.98, 0.03], hand: [0.38, 0.82, 0.07],
  femur: [0.1, 0.72, 0.1], knee: [0.11, 0.48, 0.08], tibia: [0.12, 0.3, 0.06],
  ankle: [0.14, 0.08, 0.02], foot: [0.16, 0.03, 0.12],
};
const SIDED = ['ribs', 'clavicle', 'humerus', 'forearm', 'hand', 'femur', 'knee', 'tibia', 'ankle', 'foot'];
function waitSpotKeys() {
  const out = [];
  Object.keys(WAIT_SPOT).forEach(function (k) {
    if (SIDED.indexOf(k) >= 0) {
      out.push(['bone:' + k + '_l', k, 1], ['bone:' + k + '_r', k, -1]);
      return;
    }
    out.push([k, k, 1], ['bone:' + k, k, 1], ['zone:' + k, k, 1]);
  });
  return out;
}
// คืน [mesh, index] ของจุดผิวที่ใกล้จุดท่ายืน p ที่สุด (แคชต่อหุ่น)
function waitNearest(fig, key, p) {
  const cache = fig.userData.spotIdx || (fig.userData.spotIdx = {});
  if (cache[key]) return cache[key];
  let best = null, bd = 1e9;
  fig.traverse(function (m) {
    if (!m.isMesh || !m.userData.anat || !m.geometry.attributes.rest) return;
    const r = m.geometry.attributes.rest, a = m.userData.anat;
    for (let i = 0; i < r.count; i += 2) {
      const dx = r.getX(i) - p[0], dy = (r.getY(i) - a.feet) / a.ky - p[1], dz = r.getZ(i) - p[2];
      const d = dx * dx + dy * dy + dz * dz;
      if (d < bd) { bd = d; best = [m, i]; }
    }
  });
  cache[key] = best;
  return best;
}
function waitHotspots() {
  const out = [];
  if (waitE() < 0.5) return out;
  const n = waitSelIdx();
  let fig = null;
  waitRoot.children.forEach(function (c) { if (c.userData.isFig && c.userData.waitIdx === n) fig = c; });
  if (!fig) return out;
  fig.updateMatrixWorld(true);
  const q = new THREE.Vector3(), nm = new THREE.Vector3();
  waitSpotKeys().forEach(function (e) {
    const base = WAIT_SPOT[e[1]];
    const hit = waitNearest(fig, e[0], [base[0] * e[2], base[1], base[2]]);
    if (!hit) return;
    const m = hit[0], i = hit[1];
    q.fromBufferAttribute(m.geometry.attributes.position, i);
    m.localToWorld(q);
    // ผิวหันหนีกล้อง (อีกฝั่งตัว) = ซ่อน
    let facing = true;
    if (m.geometry.attributes.normal) {
      nm.fromBufferAttribute(m.geometry.attributes.normal, i).transformDirection(m.matrixWorld);
      facing = camera.position.clone().sub(q).normalize().dot(nm) > -0.1;
    }
    q.project(camera);
    out.push({
      key: e[0],
      x: (q.x + 1) / 2 * window.innerWidth,
      y: (-q.y + 1) / 2 * window.innerHeight,
      visible: q.z < 1 && facing,
    });
  });
  return out;
}
// เลื่อนกล้อง/จุดเล็งไปมุมข้างของช่องที่เลือก (ผสมตาม waitMix)
function waitCam(target) {
  const e = waitE();
  if (e < 0.0005 || iso || !waitRoot.parent) return;
  waitRoot.updateMatrixWorld(true);
  // ตามตำแหน่งกล้องที่กำลังเลื่อน (currentPos) ไม่กระโดดตอนเปลี่ยนคน
  const xn = waitRoot.worldToLocal(currentPos.clone().setY(floorY)).x;
  const cp = waitRoot.localToWorld(new THREE.Vector3(xn - WSIDE.camX, WSIDE.camY + waitLift, WSIDE.camZ));
  const ct = waitRoot.localToWorld(new THREE.Vector3(xn + WSIDE.lookX, WSIDE.lookY + waitLift, 0));
  camera.position.lerp(cp, e);
  target.lerp(ct, e);
}

let waitSeq = 0;
window.erSetWaiting = function (list) {
  waitList = list || [];
  const seq = ++waitSeq;
  while (waitRoot.children.length) waitRoot.remove(waitRoot.children[0]);
  if (!waitRoot.parent) scene.add(waitRoot);
  const a = waitAnchor();
  if (!a || !waitList.length) { markDirty(4); return; }
  const yaw = Math.atan2(a.dir.x, a.dir.z);
  waitRoot.position.set(a.at.x, floorY, a.at.z);
  waitRoot.rotation.set(0, yaw - Math.PI / 2, 0);
  waitRoot.updateMatrixWorld(true);
  waitRoot.add(waitLobby());
  // สร้างโถงใหม่ระหว่างแสดงอยู่: จัดไฟโถงตามตำแหน่งใหม่
  if (waitHid) { lobbyLight(true); renderer.shadowMap.needsUpdate = true; }
  const jobs = [];
  // เก้าอี้แถวเดิม (สีเดิม) ผู้ป่วยนั่งที่กลาง
  jobs.push(loadProp('tandem.glb').then(function (s) {
    const g = woodBench(fitProp(s.clone(true), WAIT.seatLen));
    // โมเดลหันพนักไปทางกล้อง: กลับหน้าให้ที่นั่งหันเข้ากล้อง (หุ่นหันหน้าทาง +Z)
    g.rotation.y = Math.PI;
    // แคบ/ตื้นลง ความสูงเบาะคงเดิม: ที่นั่งกว้าง ~0.49 ม. ขอบหน้าเบาะถอยเข้าใต้ต้นขา หน้าแข้งไม่ทะลุ
    g.scale.set(WAIT.seatK, 1, WAIT.seatK);
    // ถอยไปทางผนัง: พนักอยู่หลังก้นพอดี ขอบหน้าเบาะอยู่ใต้ข้อพับเข่า (วัดจากมุมข้าง)
    g.position.set(WAIT_BENCH_X, 0, WAIT.chairZ);
    waitBench = g;
    waitRoot.add(g);
    // เก้าอี้แถวตามทางเดิน: แถวเดียวชิดผนังซ้าย หันเข้าทางเดิน (ฝั่งขวาเอาออก 2026-11-26 ให้ทางเดินโล่ง เป็นระเบียบ)
    const wr = 0.42;
    // ตั้งตรงแนวผนังพอดี: พนักชิดผนัง มุม 90° พอดี · ห่างต้นไม้ปลายแถวพอ ไม่ซ้อนกันในภาพ
    [[wr + 0.36, -2.9, -Math.PI / 2]].forEach(function (c) {
      const b = woodBench(fitProp(s.clone(true), WAIT.seatLen));
      b.scale.set(WAIT.seatK, 1, WAIT.seatK);
      b.rotation.y = c[2];
      b.position.set(c[0], 0, c[1]);
      waitRoot.add(b);
    });
  }));
  // ทุกคนนั่งที่เดียวกัน แสดงทีละคน (คนที่เลือก) · มารถนั่ง = รถเข็นข้างม้านั่ง
  waitList.forEach(function (w, i) {
    if (w.wheel) {
      jobs.push(loadProp('wheelchair.glb').then(function (s) {
        const g = fitProp(s.clone(true), WAIT.wheelLen);
        g.position.set(WAIT_WHEEL_X, 0, WAIT_WHEEL_Z);
        waitOwn(g, i);
        waitRoot.add(g);
      }));
      jobs.push(sittingAnat(!!w.female, w.color).then(function (f) {
        // ก้นท่านั่งอยู่ ~0.72 ม. เหนือฐานหุ่น · เบาะรถเข็น ~0.47 ม.
        f.position.set(WAIT_WHEEL_X, -0.25, WAIT_WHEEL_Z - 0.05);
        f.userData.isFig = true;
        waitOwn(f, i, false);
        waitRoot.add(f);
      }));
      return;
    }
    jobs.push(sittingAnat(!!w.female, w.color).then(function (f) {
      f.position.set(0, WAIT.sitY, WAIT.sitZ);
      f.userData.isFig = true;
      waitOwn(f, i, false);
      waitRoot.add(f);
    }));
  });
  Promise.all(jobs).then(function () {
    if (seq !== waitSeq) return;
    if (String(selected).indexOf('WAIT') === 0) window.erSelect(selected);
    renderer.shadowMap.needsUpdate = true;
    markDirty(8);
  }, function (err) { send({ type: 'error', message: 'waiting: ' + String(err) }); });
};

// เครื่องหมายชี้เตียงที่กำลังดู: ลำแสงตั้งขึ้นจากพื้น + วงแหวนรอบเตียง
let pin = null;
function ensurePin(color) {
  // ไม่แสดงลำแสง/วงแหวนชี้เตียงแล้ว (ผู้ใช้ให้เอาแสงแดงออก)
  // pin = null ตลอด ฉากจึงหยุด render ได้เมื่อนิ่ง (เดิมวงแหวนหมุนบังคับ render ทุกเฟรม)
  if (pin) { scene.remove(pin); pin = null; }
  void color;
  return new THREE.Group();
}

window.erSelect = function (code) {
  // 'WAIT' = ผู้ป่วยที่เลือกยังไม่ได้เตียง: กล้องไปที่จุดนั่งรอ (เก้าอี้แถว/รถเข็น) ไม่มีจอ monitor
  // 'WAIT:n' = ช่องที่ n (ลำดับในรายการนั่งรอ) · กล้องเลื่อนไปช่องนั้นเหมือนเตียง
  if (String(code).indexOf('WAIT') === 0) {
    selected = code;
    markDirty(180);
    focusY = null;
    const n = parseInt(String(code).split(':')[1] || '0', 10) || 0;
    if (waitRoot.parent) {
      waitRoot.updateMatrixWorld(true);
      const p = waitRoot.localToWorld(new THREE.Vector3(waitX(n), 0, -WAIT.front));
      targetPos.set(p.x, 0, p.z);
    }
    if (mon) { mon.g.visible = false; if (mon.sign) mon.sign.visible = false; }
    return;
  }
  if (mon) { mon.g.visible = true; if (mon.sign) mon.sign.visible = true; }
  selected = code;
  markDirty(180);
  // ไม่แสดงวงแสงใต้เตียงที่เลือก (ผู้ใช้ให้เอาแสงแดงออก)
  Object.keys(glows).forEach(function (c) { glows[c].visible = false; });
  const bed = beds[code];
  if (!bed) return;
  // กลางตัวเตียงแท้ (วัดตอนโหลดฉาก ก่อนมีหุ่นกางแขนมาเกาะ) วงแสงจึงตรงเตียงพอดี
  const p = bed.userData.center
      ? bed.userData.center.clone()
      : new THREE.Box3().setFromObject(bed).getCenter(new THREE.Vector3());
  const color = (glows[code] && glows[code].material.color.getHex()) || 0x2397ff;
  ensurePin(color).position.set(p.x, floorY + 0.01, p.z);
  const f = focusOf(code) || p;
  focusY = focusOf(code) ? f.y : null;
  targetPos.set(f.x, 0, f.z);
  placeMonitor();
};

// ---------------------------------------------- จอ monitor ติดกำแพงเหนือหัวเตียงที่เลือก
// จอเป็น mesh ในฉากจริง (บังกัน/มุมกล้องตามฉาก) หน้าจอวาดด้วย canvas: ECG + pleth + ตัวเลข
function ensureMonitor() {
  if (mon) return mon;
  const g = new THREE.Group();
  const W = 0.80, H = 0.50, D = 0.06;
  const body = new THREE.Mesh(new THREE.BoxGeometry(W + 0.05, H + 0.05, D),
    new THREE.MeshStandardMaterial({ color: 0xd9dde3, roughness: 0.55 }));
  g.add(body);
  const cv = document.createElement('canvas'); cv.width = 1024; cv.height = 640;
  const tex = new THREE.CanvasTexture(cv);
  tex.encoding = THREE.sRGBEncoding;
  const screen = new THREE.Mesh(new THREE.PlaneGeometry(W, H),
    new THREE.MeshBasicMaterial({ map: tex, toneMapped: false }));
  screen.position.z = D / 2 + 0.002;
  g.add(screen);
  // ขายึดกำแพง
  const arm = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.08, 0.12),
    new THREE.MeshStandardMaterial({ color: 0x9aa1ab, roughness: 0.5 }));
  arm.position.z = -D / 2 - 0.06;
  g.add(arm);
  // ป้ายเลขเตียงที่ราวปลายเตียง (แผ่นกรมท่า ตัวขาว) วาดใหม่เมื่อเปลี่ยนเตียง
  const sc = document.createElement('canvas'); sc.width = 512; sc.height = 192;
  const stex = new THREE.CanvasTexture(sc);
  stex.encoding = THREE.sRGBEncoding;
  const sign = new THREE.Mesh(new THREE.PlaneGeometry(0.42, 0.1575),
    new THREE.MeshBasicMaterial({ map: stex, toneMapped: false, transparent: true }));
  // ป้ายอยู่ที่ราวปลายเตียง (ไม่ใช่ในกลุ่มจอ) วางตำแหน่งใน placeMonitor
  sign.visible = false;
  scene.add(sign);
  g.visible = false;
  scene.add(g);
  mon = { g: g, cv: cv, ctx: cv.getContext('2d'), tex: tex,
    sign: sign, sctx: sc.getContext('2d'), stex: stex, bed: null };
  return mon;
}
function placeMonitor() {
  if (!mon || !selected || !beds[selected]) return;
  const bed = beds[selected];
  const p = bed.userData.center
      ? bed.userData.center.clone()
      : new THREE.Box3().setFromObject(bed).getCenter(new THREE.Vector3());
  // ระยะกลางเตียง→หัวเตียงคงที่ (กล่องของเตียงรวมหุ่น/ของข้างเคียง ทำให้บางเตียงดันจอไปหลังกำแพง)
  const HEAD = 0.93;
  // ปลายเท้าหันเข้ากล้อง = หัวเตียงอยู่ฝั่งตรงข้ามกล้อง
  const a = yaw * Math.PI / 180;
  const hx = -Math.sin(a), hz = -Math.cos(a);
  mon.g.position.set(p.x + hx * HEAD, floorY + 1.42, p.z + hz * HEAD);
  mon.g.rotation.set(-0.08, a, 0);
  // ใหญ่ขึ้นให้อ่านตัวเลขออกจากมุมกล้องปกติ
  mon.g.scale.setScalar(1.35);
  // ป้ายเลขเตียง: ราวปลายเท้า (ฝั่งกล้อง) สูงระดับขอบบนราว หันเข้ากล้อง ลอยหน้าราวเล็กน้อย
  // ติดหน้าราวปลายเตียง (ยื่นพ้นราว ไม่จมหลังราว) วาดทับราวเสมอ
  const FOOT = 1.18;
  mon.sign.position.set(p.x - hx * FOOT, floorY + 0.705, p.z - hz * FOOT);
  mon.sign.renderOrder = 10;
  mon.sign.material.depthTest = false;
  mon.sign.rotation.set(0, a, 0);
  mon.sign.scale.setScalar(1.25);
}
function ecg(ph) {
  const g = function (c, w, k) { return k * Math.exp(-Math.pow((ph - c) / w, 2)); };
  return g(0.18, 0.035, 0.12) - g(0.30, 0.012, 0.15) + g(0.33, 0.014, 1) - g(0.36, 0.014, 0.25) + g(0.58, 0.06, 0.25);
}
function pleth(ph) {
  return Math.exp(-Math.pow((ph - 0.35) / 0.12, 2)) + 0.35 * Math.exp(-Math.pow((ph - 0.62) / 0.06, 2));
}
function drawMonitor() {
  if (!mon || !monData) return;
  // อ่านจากมุมกล้องปกติ: ตัวเลขใหญ่มาก ฉลากหนา คลื่น ECG เส้นเดียว
  const c = mon.ctx, d = monData, W = 1024, H = 640;
  const bad = function (k) { return (d.bad || []).indexOf(k) >= 0; };
  const col = function (k, base) { return bad(k) ? '#ff5a5a' : base; };
  c.fillStyle = '#05080c'; c.fillRect(0, 0, W, H);
  const alarm = (d.alarms || []).length > 0;
  const blink = Math.floor(monT * 2) % 2 === 0;
  c.fillStyle = alarm && blink ? '#e53935' : '#141a22'; c.fillRect(0, 0, W, 78);
  c.fillStyle = '#fff'; c.font = '800 46px sans-serif'; c.textBaseline = 'middle';
  c.fillText(alarm ? '! ' + d.alarms.join('  ') : 'NORMAL', 24, 40);
  c.textAlign = 'right'; c.fillText(d.time || '', W - 24, 40); c.textAlign = 'left';
  // ECG กวาดซ้าย
  const bpm = Math.max(30, Math.min(200, d.hrN || 80)), beats = bpm / 60, secs = 4;
  const ww = 560, head = (monT % secs) / secs * ww;
  c.strokeStyle = '#3ddc84'; c.lineWidth = 7; c.lineJoin = 'round'; c.beginPath();
  let pen = false;
  for (let x = 0; x <= ww; x += 3) {
    if (x > head && x < head + 26) { pen = false; continue; }
    const y = 280 - ecg((x / ww * secs * beats) % 1) * 150;
    if (!pen) { c.moveTo(24 + x, y); pen = true; } else c.lineTo(24 + x, y);
  }
  c.stroke();
  function num(label, val, x, y, size, color) {
    c.fillStyle = color; c.textBaseline = 'alphabetic';
    c.font = '800 38px sans-serif'; c.fillText(label, x, y);
    c.font = '800 ' + size + 'px sans-serif'; c.fillText(val, x, y + size * 0.9);
  }
  num('HR', d.hr || '--', 620, 130, 170, col('HR', '#3ddc84'));
  c.fillStyle = '#1f2833'; c.fillRect(0, 400, W, 4);
  num('BP', d.bp || '--', 24, 448, 130, col('BP', '#f2f2f2'));
  num('SpO2', d.spo2 || '--', 620, 448, 130, col('SpO₂', '#4fc3f7'));
  mon.tex.needsUpdate = true;
}
function drawSign(bed) {
  const m = mon; if (!m) return;
  m.bed = bed || null;
  m.sign.visible = !!bed && m.g.visible;
  if (!bed) return;
  const c = m.sctx, W = 512, H = 192, r = 36;
  c.clearRect(0, 0, W, H);
  c.fillStyle = '#001B7C';
  c.beginPath();
  c.moveTo(r, 0); c.lineTo(W - r, 0); c.quadraticCurveTo(W, 0, W, r);
  c.lineTo(W, H - r); c.quadraticCurveTo(W, H, W - r, H);
  c.lineTo(r, H); c.quadraticCurveTo(0, H, 0, H - r);
  c.lineTo(0, r); c.quadraticCurveTo(0, 0, r, 0); c.fill();
  c.fillStyle = '#ffffff'; c.textAlign = 'center'; c.textBaseline = 'middle';
  c.font = '800 120px sans-serif';
  c.fillText(bed, W / 2, H / 2 + 6);
  m.stex.needsUpdate = true;
}
window.erVitals = function (o) {
  monData = o;
  const m = ensureMonitor();
  m.g.visible = !!o;
  if (!o) m.sign.visible = false;
  if (o && o.bed !== m.bed) drawSign(o.bed);
  else if (o) m.sign.visible = !!m.bed;
  placeMonitor();
  drawMonitor();
  markDirty(4);
};
// คลื่นวิ่ง ~15 fps เฉพาะตอนจอแสดงอยู่ (ไม่ render ฉากถี่เกินจำเป็น)
setInterval(function () {
  if (!mon || !mon.g.visible || !monData) return;
  monT += 1 / 15;
  drawMonitor();
  markDirty(1);
}, 1000 / 15);

// จุดกึ่งกลางของหุ่นผู้ป่วยบนเตียง (กล้องเล็งตรงนี้ หุ่นจึงอยู่กลางฉากพอดี)
// ยังโหลดหุ่นไม่เสร็จ = null ใช้กลางเตียงไปก่อน แล้วค่อยขยับเมื่อหุ่นมา
function focusOf(code) {
  const fig = figures[code];
  if (!fig || fig === 'loading') return null;
  const box = boneCloud(fig.userData.body || fig);
  if (box.isEmpty()) return null;
  return box.getCenter(new THREE.Vector3());
}

// ---------------------------------------------------------------- แตะเลือก
const ray = new THREE.Raycaster();
const ndc = new THREE.Vector2();
let downAt = null;
let lastTap = 0;

renderer.domElement.addEventListener('pointerdown', function (e) {
  // นิ้วค้าง (ไม่ได้รับ pointerup) จะทำให้แตะครั้งถัดไปกลายเป็นหุบสองนิ้ว
  if (e.isPrimary) pointers.clear();
  downAt = { x: e.clientX, y: e.clientY };
  pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
  if (drawDown(e)) downAt = null;   // เริ่มวาดบนผิว ไม่นับเป็นแตะ/หมุน
});

function dropPointer(e) {
  pointers.delete(e.pointerId);
  if (pointers.size === 0) dragging = false;
  if (pointers.size < 2) pinchBase = null;
  if (pointers.size === 0) { dragX = null; dragY = null; }
}
// iOS ยกเลิก pointer ตอนกดค้างนาน (ไม่ส่ง pointerup) = จบรูปทรง/เส้นที่กำลังวาดตรงนั้น
renderer.domElement.addEventListener('pointercancel', function (e) {
  dropPointer(e);
  drawUp();
});
renderer.domElement.addEventListener('pointerleave', dropPointer);

renderer.domElement.addEventListener('pointerup', function (e) {
  dropPointer(e);
  if (drawUp()) { downAt = null; return; }
  if (!downAt) return;
  const moved = Math.abs(e.clientX - downAt.x) + Math.abs(e.clientY - downAt.y);
  downAt = null;
  if (moved > 12) return;           // ลากจอ ไม่ใช่การแตะเลือก (ผังเตียงไม่เลื่อนตามนิ้วแล้ว)
  if (detailMode() && drawCfg && drawCfg.tool === 'pin' && plotPin(e)) return;
  if (detailMode() && drawCfg && drawCfg.tool === 'region' && pickRegion(e)) return;
  // โหมดระบุตำแหน่ง: แตะบนตัวหุ่น = ปักหมุดแผล แล้วบอกแอปว่าโดนส่วนไหน
  if (detailMode() && pickMode && pickBody(e)) return;
  // แตะสองครั้งเร็ว ๆ ในโหมดรายละเอียด = คืนมุมมองเป็นค่าตั้งต้น
  if (detailMode()) {
    const now = performance.now();
    if (now - lastTap < 320) {
      if (focusAim) { window.erFocus(null); lastTap = 0; return; }
      spinWant = 0; tiltWant = 0; zoomWant = 1; spinVel = 0;
      markDirty(30);
      lastTap = 0;
      return;
    }
    lastTap = now;
    return;
  }
  ndc.x = (e.clientX / window.innerWidth) * 2 - 1;
  ndc.y = -(e.clientY / window.innerHeight) * 2 + 1;
  ray.setFromCamera(ndc, camera);
  const targets = order.map(function (c) { return beds[c]; })
                       .filter(function (b) { return b && b.visible; });
  const hit = ray.intersectObjects(targets, true)[0];
  if (!hit) return;
  let o = hit.object;
  while (o && o.name.indexOf('bed_') !== 0) o = o.parent;
  if (o) send({ type: 'tap', code: o.name.slice(4) });
});

// ---------------------------------------------- ระบุตำแหน่งบนตัวหุ่น (บาดแผล)
let pickMode = false;
window.erPickMode = function (on) {
  pickMode = !!on;
  if (!pickMode) clearWoundPins();
};
// ลบหมุดแผลทั้งหมด (ออกจากขั้นบาดแผลแล้วไม่ค้างบนหุ่น)
function clearWoundPins() {
  const gone = [];
  scene.traverse(function (o) { if (o.name === 'wound_pin') gone.push(o); });
  gone.forEach(function (o) { if (o.parent) o.parent.remove(o); });
  if (gone.length) markDirty(4);
}
// วัตถุที่มองเห็นจริง (Raycaster ไม่สนค่า visible เอง)
function shownChain(o) {
  for (let x = o; x; x = x.parent) if (x.visible === false) return false;
  return true;
}
// กระดูก rig ที่ใช้บอกส่วนของร่างกาย (ไม่มีในหุ่นก็ข้าม)
const PICK_BONES = ['Head', 'Neck', 'Chest', 'Belly', 'Pelvis',
  'Collar.L', 'Collar.R', 'UpperArm.L', 'UpperArm.R', 'Forearm.L', 'Forearm.R',
  'Palm.L', 'Palm.R', 'Hip.L', 'Hip.R', 'Shin.L', 'Shin.R',
  'Foot.L', 'Foot.R', 'Toes.L', 'Toes.R'];
// จุดบนแกนกลางกระดูกท่อนที่ใกล้จุด p (พิกัดโลก) ที่สุด
function boneAxisPoint(body, p) {
  let best = p.clone(), bestD = Infinity;
  PICK_BONES.forEach(function (name) {
    const b = findNode(body, name);
    if (!b) return;
    const a = b.getWorldPosition(new THREE.Vector3());
    const ch = b.children.filter(function (c) { return c.isBone; })[0];
    const e = ch ? ch.getWorldPosition(new THREE.Vector3()) : a.clone();
    const ab = e.clone().sub(a);
    const t = Math.max(0, Math.min(1, p.clone().sub(a).dot(ab) / (ab.lengthSq() || 1)));
    const q = a.clone().add(ab.multiplyScalar(t));
    const d = q.distanceTo(p);
    if (d < bestD) { bestD = d; best = q; }
  });
  return best;
}
function segDist(p, a, b) {
  const ab = b.clone().sub(a);
  const t = Math.max(0, Math.min(1, p.clone().sub(a).dot(ab) / (ab.lengthSq() || 1)));
  return p.distanceTo(a.clone().add(ab.multiplyScalar(t)));
}
function pickBody(e) {
  const pivot = bodies[selected];
  if (!pivot || pivot === 'loading') return false;
  const fig = skinOf(pivot);
  if (!fig) return false;
  const body = fig.userData.body || fig;
  ndc.x = (e.clientX / window.innerWidth) * 2 - 1;
  ndc.y = -(e.clientY / window.innerHeight) * 2 + 1;
  ray.setFromCamera(ndc, camera);
  fig.updateMatrixWorld(true);
  const hit = ray.intersectObject(fig, true).filter(function (h) {
    const n = String(h.object.name);
    return shownChain(h.object) && n.indexOf('mark_') !== 0 &&
        n.indexOf('bone_') !== 0 && n.indexOf('heat_') !== 0 &&
        n.indexOf('wound_') !== 0 && !h.object.userData.piece &&
        h.object.parent && String(h.object.parent.name).indexOf('layer_') !== 0;
  })[0];
  if (!hit) return false;
  let best = null, bestD = Infinity;
  PICK_BONES.forEach(function (name) {
    const b = findNode(body, name);
    if (!b) return;
    const a = b.getWorldPosition(new THREE.Vector3());
    const child = b.children.filter(function (c) { return c.isBone; })[0];
    const d = child
        ? segDist(hit.point, a, child.getWorldPosition(new THREE.Vector3()))
        : hit.point.distanceTo(a);
    if (d < bestD) { bestD = d; best = name; }
  });
  if (!best) return false;
  // หมุดแผลสีแดงติดกับตัวหุ่น (หมุนตามตัว) มีวงจางรอบ
  const ws = fig.getWorldScale(new THREE.Vector3()).x || 1;
  clearWoundPins();
  const pin = new THREE.Group();
  pin.name = 'wound_pin';
  const core = new THREE.Mesh(new THREE.SphereGeometry(0.011 / ws, 16, 12),
      new THREE.MeshBasicMaterial({ color: 0xE0241B, depthTest: false, toneMapped: false }));
  const halo = new THREE.Mesh(new THREE.SphereGeometry(0.024 / ws, 16, 12),
      new THREE.MeshBasicMaterial({ color: 0xE0241B, transparent: true, opacity: 0.28,
        depthTest: false, depthWrite: false, toneMapped: false }));
  core.name = 'wound_core'; halo.name = 'wound_halo';
  core.renderOrder = 31; halo.renderOrder = 30;
  pin.add(halo); pin.add(core);
  pin.position.copy(fig.worldToLocal(hit.point.clone()));
  fig.add(pin);
  markDirty(10);
  send({ type: 'bodyPick', bone: best });
  return true;
}

// ---------------------------------------------- วาดบนตัวหุ่น (studio ภาพการตรวจร่างกาย)
// นิ้วเดียวเริ่มบนผิวหุ่น = วาดเส้นติดผิว (หมุนตามตัว) · เริ่มนอกตัว = หมุนหุ่นตามเดิม
// สองนิ้ว = ซูม (ยกเลิกเส้นที่กำลังวาด) · ยางลบ = แตะใกล้เส้นเพื่อลบทั้งเส้น
let drawCfg = null;        // null = ปิด · {tool:'pen'|'eraser', color:'#rrggbb', r: รัศมีเส้น ม.}
let curStroke = null;      // เส้นที่กำลังวาด
let strokes = [];          // {id, color, r, pts:[Vector3 ในพิกัดหุ่น], mesh, fig}
window.erDrawMode = function (cfg) { drawCfg = cfg || null; };

function skinHit(e) {
  const pivot = bodies[selected];
  if (!pivot || pivot === 'loading') return null;
  const fig = skinOf(pivot);
  if (!fig) return null;
  ndc.x = (e.clientX / window.innerWidth) * 2 - 1;
  ndc.y = -(e.clientY / window.innerHeight) * 2 + 1;
  ray.setFromCamera(ndc, camera);
  fig.updateMatrixWorld(true);
  const hit = ray.intersectObject(fig, true).filter(function (h) {
    const n = String(h.object.name);
    return shownChain(h.object) && n.indexOf('mark_') !== 0 &&
        n.indexOf('bone_') !== 0 && n.indexOf('heat_') !== 0 &&
        n.indexOf('wound_') !== 0 && n.indexOf('draw_') !== 0 &&
        !h.object.userData.piece &&
        h.object.parent && String(h.object.parent.name).indexOf('layer_') !== 0 &&
        String(h.object.parent.name).indexOf('draw_') !== 0;
  })[0];
  if (!hit) return null;
  return { hit: hit, fig: fig, body: fig.userData.body || fig };
}

// จุดบนผิว (ยกขึ้นตามแนวตั้งฉากผิวเล็กน้อย ไม่จมผิว) ในพิกัดของหุ่น
function skinLocal(h) {
  const n = h.hit.face
      ? h.hit.face.normal.clone().transformDirection(h.hit.object.matrixWorld)
      : new THREE.Vector3(0, 1, 0);
  return h.fig.worldToLocal(h.hit.point.clone().add(n.multiplyScalar(0.003)));
}

function drawGroup(fig) {
  let g = fig.userData.drawG;
  if (!g || !g.parent) {
    g = new THREE.Group();
    g.name = 'draw_layer';
    fig.add(g);
    fig.userData.drawG = g;
  }
  return g;
}

// ระบาย: แผ่นวงกลมแนบผิวทุกจุดที่นิ้วผ่าน รวมเป็น mesh เดียว
// stencil เฉพาะเส้นนี้ = แต่ละพิกเซลระบายครั้งเดียว สีจางเรียบเท่ากันทั้งแผ่น ไม่ซ้อนเข้ม
let stencilSeq = 0;
function nextStencil() { stencilSeq = stencilSeq % 250 + 1; return stencilSeq; }
function skinNormal(h) {
  const nw = h.hit.face
      ? h.hit.face.normal.clone().transformDirection(h.hit.object.matrixWorld)
      : new THREE.Vector3(0, 0, 1);
  return nw.applyQuaternion(h.fig.getWorldQuaternion(new THREE.Quaternion()).invert()).normalize();
}
function paintBuild(st, r) {
  const seg = 18;
  const pos = [], idx = [];
  const z = new THREE.Vector3(0, 0, 1), qq = new THREE.Quaternion();
  st.pts.forEach(function (p, i) {
    const n = st.nrm[i] || st.nrm[st.nrm.length - 1];
    qq.setFromUnitVectors(z, n);
    const base = pos.length / 3;
    const c = p.clone().addScaledVector(n, -0.001 / 1);
    pos.push(c.x, c.y, c.z);
    for (let k = 0; k <= seg; k++) {
      const a = k / seg * Math.PI * 2;
      const v = new THREE.Vector3(Math.cos(a) * r, Math.sin(a) * r, 0)
          .applyQuaternion(qq).add(c);
      pos.push(v.x, v.y, v.z);
      if (k > 0) idx.push(base, base + k, base + k + 1);
    }
  });
  const geo = new THREE.BufferGeometry();
  geo.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
  geo.setIndex(idx);
  const mat = new THREE.MeshBasicMaterial({
    color: new THREE.Color(st.color), transparent: true, opacity: 0.42,
    depthWrite: false, side: THREE.DoubleSide, toneMapped: false,
    polygonOffset: true, polygonOffsetFactor: -4, polygonOffsetUnits: -4,
    stencilWrite: true, stencilRef: st.stencil || 1,
    stencilFunc: THREE.NotEqualStencilFunc,
    stencilZPass: THREE.ReplaceStencilOp,
  });
  const m = new THREE.Mesh(geo, mat);
  m.name = 'draw_' + st.id;
  m.renderOrder = 25;
  drawGroup(st.fig).add(m);
  st.mesh = m;
  markDirty(2);
}

function strokeBuild(st) {
  if (st.mesh) {
    if (st.mesh.parent) st.mesh.parent.remove(st.mesh);
    st.mesh.geometry.dispose();
    st.mesh.material.dispose();
  }
  const ws = st.fig.getWorldScale(new THREE.Vector3()).x || 1;
  const r = st.r / ws;
  if (st.paint) { paintBuild(st, r); return; }
  const mat = new THREE.MeshBasicMaterial({ color: new THREE.Color(st.color), toneMapped: false });
  if (st.pts.length < 2) {
    // หมุดตำแหน่ง: จุดทึบ + วงจาง มองเห็นทะลุผิว
    const g = new THREE.Group();
    const core = new THREE.Mesh(new THREE.SphereGeometry(r, 16, 12),
        new THREE.MeshBasicMaterial({ color: new THREE.Color(st.color),
          depthTest: false, toneMapped: false }));
    const halo = new THREE.Mesh(new THREE.SphereGeometry(r * 2.2, 16, 12),
        new THREE.MeshBasicMaterial({ color: new THREE.Color(st.color),
          transparent: true, opacity: 0.25, depthTest: false,
          depthWrite: false, toneMapped: false }));
    core.renderOrder = 31; halo.renderOrder = 30;
    g.add(halo); g.add(core);
    g.position.copy(st.pts[0]);
    g.name = 'draw_' + st.id;
    g.geometry = { dispose: function () {} };
    g.material = { dispose: function () {} };
    drawGroup(st.fig).add(g);
    st.mesh = g;
    markDirty(4);
    return;
  }
  const geo = st.pts.length < 2
      ? new THREE.SphereGeometry(r * 1.2, 10, 8)
      : new THREE.TubeGeometry(new THREE.CatmullRomCurve3(st.pts),
          Math.min(400, st.pts.length * 3), r, 6, false);
  const m = new THREE.Mesh(geo, mat);
  if (st.pts.length < 2) m.position.copy(st.pts[0]);
  m.name = 'draw_' + st.id;
  m.renderOrder = 26;
  drawGroup(st.fig).add(m);
  st.mesh = m;
  markDirty(2);
}

function strokeRemove(st) {
  if (st.mesh) {
    if (st.mesh.parent) st.mesh.parent.remove(st.mesh);
    st.mesh.geometry.dispose();
    st.mesh.material.dispose();
    st.mesh = null;
  }
  markDirty(4);
}

// กระดูก rig ที่ใกล้จุดนั้นที่สุด (บอกส่วนของร่างกาย)
function boneNear(body, p) {
  let best = null, bestD = Infinity;
  PICK_BONES.forEach(function (name) {
    const b = findNode(body, name);
    if (!b) return;
    const a = b.getWorldPosition(new THREE.Vector3());
    const child = b.children.filter(function (c) { return c.isBone; })[0];
    const d = child
        ? segDist(p, a, child.getWorldPosition(new THREE.Vector3()))
        : p.distanceTo(a);
    if (d < bestD) { bestD = d; best = name; }
  });
  return best;
}

// ปักตำแหน่ง (tool 'pin'): แตะบนผิวหุ่น = หมุดติดผิว · ลาก = หมุนหุ่นตามเดิม
// ---------------------------------------------- บริเวณร่างกาย (taxonomy แบบ CIS body map)
// แบ่งจากข้อต่อ rig: ลำตัว = ตาราง (อก 3 · ท้อง 9 ช่อง · เชิงกราน/ขาหนีบ) · แขนขา = ตามท่อน
// หน้า/หลัง = ทิศแนวตั้งฉากผิวเทียบด้านหน้าลำตัว · ซ้าย/ขวา = ของผู้ป่วย
function bodyAxes(body) {
  const pel = bonePos(body, 'Pelvis'), neck = bonePos(body, 'Neck');
  const up = neck.clone().sub(pel).normalize();
  const cl = findNode(body, 'Collar.L') ? bonePos(body, 'Collar.L') : null;
  const cr = findNode(body, 'Collar.R') ? bonePos(body, 'Collar.R') : null;
  const left = cl && cr ? cl.clone().sub(cr) : new THREE.Vector3(1, 0, 0);
  const half = left.length() / 2 || 0.18;
  left.normalize();
  const front = new THREE.Vector3().crossVectors(left, up).normalize();
  return { pel: pel, neck: neck, up: up, left: left, front: front, half: half };
}
function segT(p, a, b) {
  const ab = b.clone().sub(a);
  return p.clone().sub(a).dot(ab) / (ab.lengthSq() || 1);
}
// ข้อต่อที่ใช้แบ่งบริเวณ (ตำแหน่งโลก) เก็บครั้งเดียว ใช้ทั้งแตะเลือกและวาดเส้นแบ่ง
function regionCtx(body) {
  const bones = {};
  PICK_BONES.forEach(function (name) {
    const b = findNode(body, name);
    if (!b) return;
    const child = b.children.filter(function (c) { return c.isBone; })[0];
    bones[name] = {
      a: b.getWorldPosition(new THREE.Vector3()),
      c: child ? child.getWorldPosition(new THREE.Vector3()) : null,
    };
  });
  return { ax: bodyAxes(body), bones: bones };
}
// กฎแบ่งบริเวณ (ต้องตรงกับ region() ใน mannShader ทุกบรรทัด)
// ความสูงตามแกนลำตัว · หน้า/หลัง = ด้านของจุดเทียบแกนกลาง (ลำตัว/ศีรษะ) หรือเทียบกระดูกท่อนนั้น (แขนขา)
// ลำตัวแบ่งแบบ CIS: อก 3 ช่อง · ท้อง 9 ช่อง (คอลัมน์กลางกว้างเท่ากันทั้งอกและท้อง)
const REG_MID = 0.6;   // ครึ่งความกว้างคอลัมน์กลาง (หน่วย = ครึ่งระยะไหล่ซ้าย-ขวา)
const REG_ARM = 0.62;  // รัศมีท่อนแขน (หน่วยเดียวกัน) ใกล้กระดูกแขนกว่านี้ = แขน
function regionAt(ctx, p, n) {
  let bone = null, bestD = Infinity, near = null;
  Object.keys(ctx.bones).forEach(function (name) {
    const b = ctx.bones[name];
    let q;
    if (b.c) {
      const ab = b.c.clone().sub(b.a);
      const t = Math.max(0, Math.min(1, p.clone().sub(b.a).dot(ab) / (ab.lengthSq() || 1)));
      q = b.a.clone().add(ab.multiplyScalar(t));
    } else q = b.a.clone();
    const d = p.distanceTo(q);
    if (d < bestD) { bestD = d; bone = name; near = q; }
  });
  if (!bone) return null;
  const ax = ctx.ax, B = ctx.bones;
  const H = function (v) { return v.clone().sub(ax.pel).dot(ax.up); };
  const hp = H(p);
  const lat = p.clone().sub(ax.pel).dot(ax.left);   // + = ซ้ายผู้ป่วย
  const w = Math.abs(lat) / ax.half;
  const sL = lat >= 0;
  const axisQ = ax.pel.clone().add(ax.up.clone().multiplyScalar(hp));
  const backT = p.clone().sub(axisQ).dot(ax.front) < 0;
  const hNeck = B.Neck ? H(B.Neck.a) : 0.6, hHead = B.Head ? H(B.Head.a) : 0.67;
  const hCol = B['Collar.L'] ? H(B['Collar.L'].a) : 0.56;
  const base = bone.replace(/\.[LR]$/, '');
  // ศีรษะ / คอ: ตามความสูง (ไม่ใช้กระดูกที่ใกล้สุด) เส้นแบ่งจึงเป็นวงรอบคอเรียบ
  if (hp > hNeck - 0.015 && w < 1.2) return backT ? 'b-head' : 'head';
  if (hp > hCol && w < 0.75) return backT ? 'b-nape' : 'neck';
  const L = hp < (B['Collar.L'] ? H(B['Collar.L'].a) : 0.56) - 0.02 ? sL
      : bone.slice(-2) === '.L' ? true : bone.slice(-2) === '.R' ? false : sL;
  const backL = p.clone().sub(near).dot(ax.front) < 0;
  const side = L ? 'l' : 'r';
  const limb = function (id) { return (backL ? 'b' + side : side) + '-' + id; };
  const ch = function (a, c) {
    const A = B[a + (L ? '.L' : '.R')], C = B[c + (L ? '.L' : '.R')];
    if (!A || !C) return 0.5;
    return segT(p, A.a, C.a);
  };
  let trunk = false;
  // แขนต้องอยู่นอกแนวลำตัว (กันผิวด้านในแขน/รักแร้ถูกนับเป็นลำตัว และกลับกัน)
  const armB = base === 'UpperArm' || base === 'Forearm' || base === 'Palm';
  const depth = p.clone().sub(axisQ).dot(ax.front);
  const radial = Math.sqrt(lat * lat + depth * depth) / ax.half;
  // ใต้ไหล่: ห่างแกนลำตัวเกิน 1.05 เท่าครึ่งไหล่ = แขน · ใกล้กว่า = ลำตัว (ไม่ดูกระดูกที่ใกล้สุด)
  let useB = base;
  if (hp < hCol - 0.02 && (armB || base === 'Chest' || base === 'Belly' || base === 'Collar')) {
    // แขน = อยู่ในรัศมีท่อนแขน (ใกล้กระดูกแขนพอ) · ไม่ใช่ = ลำตัว
    let bb = null, bd2 = Infinity;
    ['UpperArm', 'Forearm', 'Palm'].forEach(function (k) {
      const bn = B[k + (sL ? '.L' : '.R')];
      if (!bn || !bn.c) return;
      const d = segDist(p, bn.a, bn.c);
      if (d < bd2) { bd2 = d; bb = k; }
    });
    useB = bb && bd2 < REG_ARM * ax.half ? bb : 'Chest';
  }
  switch (useB) {
    case 'Collar':
      if (w < 1.3) { trunk = true; break; }
      return limb('shoulder');
    case 'UpperArm': {
      const t = ch('UpperArm', 'Forearm');
      return limb(t < 0.15 ? 'shoulder' : t > 0.88 ? 'elbow' : 'arm');
    }
    case 'Forearm': {
      const t = ch('Forearm', 'Palm');
      return limb(t < 0.1 ? 'elbow' : t > 0.85 ? 'wrist' : 'forearm');
    }
    case 'Palm': return limb('hand');
    case 'Hip': {
      const t = ch('Hip', 'Shin');
      if (t < 0.12) { if (backL) return limb('buttock'); trunk = true; break; }
      return limb(t > 0.94 ? 'knee' : 'thigh');
    }
    case 'Shin': {
      const t = ch('Shin', 'Foot');
      if (t < -0.06) return limb('thigh');
      if (t < 0.06) return limb('knee');
      return limb(t > 0.88 ? 'ankle' : 'leg');
    }
    case 'Foot': return backL ? limb('heel') : side + '-foot';
    case 'Toes': return backL ? limb('midfoot') : side + '-foot';
    default: trunk = true;
  }
  // ลำตัว: v = ความสูงเทียบเชิงกราน (0) → คอ (1)
  const v = hp / (hNeck || 1);
  const sd = sL ? 'l' : 'r';
  if (backT) {
    if (v > 0.53) return sL ? 'bul' : 'bur';
    if (v > 0.0) return w < REG_MID ? 'blc' : (sL ? 'bll' : 'blr');
    return sL ? 'bl-buttock' : 'br-buttock';
  }
  if (v > 0.53) return w < REG_MID ? 'chest' : sd + '-chest';
  if (v < 0.0) return w > 0.9 ? 'groin' : 'pelvis';
  const mid = w < REG_MID;
  if (v > 0.36) return mid ? 'epigastric' : sd + '-hypochondriac';
  if (v > 0.17) return mid ? 'umbilical' : sd + '-lumbar';
  return mid ? 'hypogastric' : sd + '-iliac';
}
function regionOf(h) {
  // หุ่นผิวจริง: ใช้พิกัด LANDMARK (ตรงกับสี/เส้นแบ่งบนหุ่นเทา)
  if (h.hit.object.userData.anat) {
    const q = lmOf(h.hit.object, h.hit.point);
    const ny = h.hit.face ? h.hit.face.normal.y : 0;
    return lmRegion(q[0], q[1], q[2], ny);
  }
  const n = h.hit.face
      ? h.hit.face.normal.clone().transformDirection(h.hit.object.matrixWorld)
      : bodyAxes(h.body).front;
  return regionAt(regionCtx(h.body), h.hit.point, n);
}

// เส้นแบ่งบริเวณบนผิวหุ่น: จัดแต่ละสามเหลี่ยม (ท่าปัจจุบัน) เข้าบริเวณ
// ขอบที่สองหน้าอยู่คนละบริเวณ = เส้นแบ่ง · คำนวณครั้งเดียวต่อหุ่น แล้วติดไปกับหุ่น
function skinMeshes(fig) {
  const out = [];
  fig.traverse(function (o) {
    const n = String(o.name);
    if (!o.isMesh || !shownChain(o) || o.userData.piece) return;
    if (n.indexOf('mark_') === 0 || n.indexOf('bone_') === 0 || n.indexOf('heat_') === 0 ||
        n.indexOf('wound_') === 0 || n.indexOf('draw_') === 0 || n === 'mannequin') return;
    for (let x = o.parent; x && x !== fig; x = x.parent) {
      const pn = String(x.name);
      if (pn.indexOf('layer_') === 0 || pn.indexOf('draw_') === 0) return;
    }
    out.push(o);
  });
  return out;
}
function buildRegionLines(fig) {
  const body = fig.userData.body || fig;
  fig.updateMatrixWorld(true);
  const ctx = regionCtx(body);
  const segs = [];
  const va = new THREE.Vector3(), vb = new THREE.Vector3(), vc = new THREE.Vector3();
  skinMeshes(fig).forEach(function (m) {
    const g = m.geometry;
    const pos = g.attributes.position;
    if (!pos) return;
    if (m.isSkinnedMesh && m.skeleton) m.skeleton.update();
    const P = new Array(pos.count);
    for (let i = 0; i < pos.count; i++) {
      const v = new THREE.Vector3().fromBufferAttribute(pos, i);
      if (m.isSkinnedMesh) m.boneTransform(i, v);
      P[i] = v.applyMatrix4(m.matrixWorld);
    }
    const idx = g.index ? g.index.array : null;
    const nf = (idx ? idx.length : pos.count) / 3;
    const key = function (v) {
      return Math.round(v.x * 2000) + ',' + Math.round(v.y * 2000) + ',' + Math.round(v.z * 2000);
    };
    const edges = new Map();
    const nrm = new THREE.Vector3(), e1 = new THREE.Vector3(), e2 = new THREE.Vector3();
    for (let f = 0; f < nf; f++) {
      const i0 = idx ? idx[f * 3] : f * 3, i1 = idx ? idx[f * 3 + 1] : f * 3 + 1,
          i2 = idx ? idx[f * 3 + 2] : f * 3 + 2;
      va.copy(P[i0]); vb.copy(P[i1]); vc.copy(P[i2]);
      e1.subVectors(vb, va); e2.subVectors(vc, va);
      nrm.crossVectors(e1, e2);
      if (nrm.lengthSq() === 0) continue;
      nrm.normalize();
      const cen = va.clone().add(vb).add(vc).multiplyScalar(1 / 3);
      const r = regionAt(ctx, cen, nrm);
      const tri = [i0, i1, i2];
      for (let k = 0; k < 3; k++) {
        const A = P[tri[k]], B = P[tri[(k + 1) % 3]];
        const ka = key(A), kb = key(B);
        const ek = ka < kb ? ka + '|' + kb : kb + '|' + ka;
        const prev = edges.get(ek);
        if (prev === undefined) {
          edges.set(ek, { r: r, n: nrm.clone() });
        } else if (prev && prev.r !== r) {
          // ยกเส้นขึ้นจากผิวเล็กน้อย (ไม่จมผิว)
          const lift = prev.n.clone().add(nrm).normalize().multiplyScalar(0.0025);
          segs.push(A.clone().add(lift), B.clone().add(lift));
          edges.set(ek, null);
        } else {
          edges.set(ek, null);
        }
      }
    }
  });
  const local = segs.map(function (v) { return fig.worldToLocal(v); });
  const geo = new THREE.BufferGeometry().setFromPoints(local);
  const lines = new THREE.LineSegments(geo, new THREE.LineBasicMaterial({
    color: 0x8A93A3, transparent: true, opacity: 0.6, toneMapped: false,
  }));
  lines.name = 'draw_regions';
  lines.renderOrder = 25;
  lines.raycast = function () {};
  fig.add(lines);
  return lines;
}
// หุ่นแบบ body map (CIS): ผิวเทาอ่อนเรียบ แต่ละบริเวณเป็นโทนเทาสลับกัน เห็นขอบชัด
// สำเนารูปทรงของหุ่นท่าปัจจุบัน (ไม่ skin) สีต่อจุดตามบริเวณ · บริเวณที่เลือก = ฟ้าอ่อน
// รหัสบริเวณ (ลำดับคงที่ ใช้ทั้ง shader และ JS)
const RIDS = ['head', 'neck', 'chest', 'r-chest', 'l-chest', 'r-hypochondriac',
  'epigastric', 'l-hypochondriac', 'r-lumbar', 'umbilical', 'l-lumbar', 'r-iliac',
  'hypogastric', 'l-iliac', 'pelvis', 'groin', 'r-hip', 'l-hip', 'r-foot', 'l-foot',
  'b-head', 'b-nape', 'bul', 'bur', 'bll', 'blc', 'blr'];
['shoulder', 'arm', 'elbow', 'forearm', 'wrist', 'hand', 'thigh', 'knee', 'leg',
  'ankle', 'buttock', 'heel', 'midfoot'].forEach(function (id) {
  ['r-', 'l-', 'br-', 'bl-'].forEach(function (pre) { RIDS.push(pre + id); });
});
function ri(n) { const i = RIDS.indexOf(n); return (i < 0 ? 0 : i).toFixed(1); }
function limbG(id) {
  return '(back ? (L ? ' + ri('bl-' + id) + ' : ' + ri('br-' + id) + ') : (L ? ' +
      ri('l-' + id) + ' : ' + ri('r-' + id) + '))';
}

// shader บริเวณ: คำนวณบริเวณต่อพิกเซลด้วยกฎเดียวกับ regionAt → ขอบโค้งเรียบตามรูปร่างจริง
// ไม่หยักตามสามเหลี่ยม · โทนเทาสลับ 3 ระดับ · บริเวณที่เลือก = ฟ้า · เส้นแบ่งบาง (fwidth ของรหัส)
const JOINT_IDS = [];
['elbow', 'wrist', 'knee', 'ankle'].forEach(function (j) {
  ['r-', 'l-', 'br-', 'bl-'].forEach(function (p) { JOINT_IDS.push(p + j); });
});
const CHECK_IDS = ['epigastric', 'r-lumbar', 'l-lumbar', 'hypogastric', 'r-chest', 'l-chest'];
function mannShader() {
  const NB = PICK_BONES.length;
  // ข้อต่อ: ดัชนีใน PICK_BONES (.L = คี่, .R = คู่ ตั้งแต่ 5)
  const B = function (n) { return PICK_BONES.indexOf(n); };
  // GLSL ES 1.0: อ่านอาร์เรย์ uniform ด้วยดัชนีแปรผันผ่านลูปคงที่
  const tVar = function (name, a, c) {
    return '    int ia = ' + B(a + '.R') + '; int ic = ' + B(c + '.R') + ';\n' +
        '    if (L) { ia = ' + B(a + '.L') + '; ic = ' + B(c + '.L') + '; }\n' +
        '    vec3 A = uA[0]; vec3 C = uA[0];\n' +
        '    for (int k = 0; k < ' + NB + '; k++) { if (k == ia) A = uA[k]; if (k == ic) C = uA[k]; }\n' +
        '    float ' + name + ' = segT(p, A, C);\n';
  };
  const isB = function (base) {
    if (base === 'Head' || base === 'Neck' || base === 'Chest' || base === 'Belly' || base === 'Pelvis') {
      return 'bi == ' + B(base);
    }
    return '(bi == ' + B(base + '.L') + ' || bi == ' + B(base + '.R') + ')';
  };
  const fs = [
    'uniform vec3 uA[' + NB + ']; uniform vec3 uC[' + NB + ']; uniform float uHasC[' + NB + '];',
    'uniform vec3 uPel; uniform vec3 uNeck; uniform vec3 uUp; uniform vec3 uLeft; uniform vec3 uFront;',
    'uniform float uHalf; uniform float uSel;',
    'varying vec3 vPos; varying vec3 vNrm; varying vec3 vVN;',
    'float segD(vec3 p, vec3 a, vec3 c) { vec3 ab = c - a; float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-9), 0.0, 1.0); return length(p - (a + ab * t)); }',
    'float segT(vec3 p, vec3 a, vec3 c) { vec3 ab = c - a; return dot(p - a, ab) / max(dot(ab, ab), 1e-9); }',
    'float region(vec3 p, vec3 n) {',
    '  float bd = 1e9; int bi = -1; vec3 near = uA[0];',
    '  for (int i = 0; i < ' + NB + '; i++) {',
    '    vec3 q = uA[i];',
    '    if (uHasC[i] > 0.5) { vec3 ab = uC[i] - uA[i]; q = uA[i] + ab * clamp(dot(p - uA[i], ab) / max(dot(ab, ab), 1e-9), 0.0, 1.0); }',
    '    float d = length(p - q);',
    '    if (d < bd) { bd = d; bi = i; near = q; }',
    '  }',
    '  float hp = dot(p - uPel, uUp);',
    '  float lat = dot(p - uPel, uLeft);',
    '  float w = abs(lat) / uHalf;',
    '  bool sL = lat >= 0.0;',
    '  bool backT = dot(p - (uPel + uUp * hp), uFront) < 0.0;',
    '  float hNeck = dot(uA[' + B('Neck') + '] - uPel, uUp);',
    '  float hHead = dot(uA[' + B('Head') + '] - uPel, uUp);',
    '  float hCol = dot(uA[' + B('Collar.L') + '] - uPel, uUp);',
    '  if (hp > hNeck - 0.015 && w < 1.2) return backT ? ' + ri('b-head') + ' : ' + ri('head') + ';',
    '  if (hp > hCol && w < 0.75) return backT ? ' + ri('b-nape') + ' : ' + ri('neck') + ';',
    '  bool L = bi >= 5 ? (mod(float(bi), 2.0) > 0.5) : sL;',
    '  bool back = dot(p - near, uFront) < 0.0;',
    '  bool trunk = false;',
    '  float depth = dot(p - (uPel + uUp * hp), uFront);',
    '  float radial = length(vec2(lat, depth)) / uHalf;',
    '  bool armB = ' + isB('UpperArm') + ' || ' + isB('Forearm') + ' || ' + isB('Palm') + ';',
    '  if (hp < hCol - 0.02 && (armB || bi == ' + B('Chest') + ' || bi == ' + B('Belly') + ' || ' + isB('Collar') + ')) {',
    '    float b2 = 1e9; int k2 = ' + B('Chest') + ';',
    '    for (int i = 7; i <= 12; i++) {',
    '      bool sameSide = (mod(float(i), 2.0) > 0.5) == sL;',
    '      if (sameSide && uHasC[i] > 0.5) { float d = segD(p, uA[i], uC[i]); if (d < b2) { b2 = d; k2 = i; } }',
    '    }',
    '    bi = b2 < ' + REG_ARM.toFixed(3) + ' * uHalf ? k2 : ' + B('Chest') + ';',
    '    L = sL;',
    '  }',
    '  if (' + isB('Collar') + ') { if (w < 1.3) trunk = true; else return ' + limbG('shoulder') + '; }',
    '  if (' + isB('UpperArm') + ') {\n' + tVar('t', 'UpperArm', 'Forearm') +
      '    return t < 0.15 ? ' + limbG('shoulder') + ' : (t > 0.88 ? ' + limbG('elbow') + ' : ' + limbG('arm') + ');\n  }',
    '  if (' + isB('Forearm') + ') {\n' + tVar('t', 'Forearm', 'Palm') +
      '    return t < 0.1 ? ' + limbG('elbow') + ' : (t > 0.85 ? ' + limbG('wrist') + ' : ' + limbG('forearm') + ');\n  }',
    '  if (' + isB('Palm') + ') return ' + limbG('hand') + ';',
    '  if (' + isB('Hip') + ') {\n' + tVar('t', 'Hip', 'Shin') +
      '    if (t < 0.12) { if (back) return ' + limbG('buttock') + '; trunk = true; }\n' +
      '    else return t > 0.94 ? ' + limbG('knee') + ' : ' + limbG('thigh') + ';\n  }',
    '  if (' + isB('Shin') + ') {\n' + tVar('t', 'Shin', 'Foot') +
      '    if (t < -0.06) return ' + limbG('thigh') + ';\n' +
      '    if (t < 0.06) return ' + limbG('knee') + ';\n' +
      '    return t > 0.88 ? ' + limbG('ankle') + ' : ' + limbG('leg') + ';\n  }',
    '  if (' + isB('Foot') + ') return back ? ' + limbG('heel') + ' : (L ? ' + ri('l-foot') + ' : ' + ri('r-foot') + ');',
    '  if (' + isB('Toes') + ') return back ? ' + limbG('midfoot') + ' : (L ? ' + ri('l-foot') + ' : ' + ri('r-foot') + ');',
    '  float v = hp / max(hNeck, 1e-6);',
    '  if (backT) {',
    '    if (v > 0.53) return sL ? ' + ri('bul') + ' : ' + ri('bur') + ';',
    '    if (v > 0.0) return w < ' + REG_MID.toFixed(3) + ' ? ' + ri('blc') + ' : (sL ? ' + ri('bll') + ' : ' + ri('blr') + ');',
    '    return sL ? ' + ri('bl-buttock') + ' : ' + ri('br-buttock') + ';',
    '  }',
    '  if (v > 0.53) return w < ' + REG_MID.toFixed(3) + ' ? ' + ri('chest') + ' : (sL ? ' + ri('l-chest') + ' : ' + ri('r-chest') + ');',
    '  if (v < 0.0) return w > 0.9 ? ' + ri('groin') + ' : ' + ri('pelvis') + ';',
    '  bool mid = w < ' + REG_MID.toFixed(3) + ';',
    '  if (v > 0.36) return mid ? ' + ri('epigastric') + ' : (sL ? ' + ri('l-hypochondriac') + ' : ' + ri('r-hypochondriac') + ');',
    '  if (v > 0.17) return mid ? ' + ri('umbilical') + ' : (sL ? ' + ri('l-lumbar') + ' : ' + ri('r-lumbar') + ');',
    '  return mid ? ' + ri('hypogastric') + ' : (sL ? ' + ri('l-iliac') + ' : ' + ri('r-iliac') + ');',
    '}',
    'void main() {',
    '  float id = region(vPos, normalize(vNrm));',
    // โทนตามรหัส: เทาอ่อน 3 ระดับสลับกัน
    '  vec3 base = vec3(0.886, 0.890, 0.902);',
    // ข้อต่อ (ข้อศอก ข้อมือ เข่า ข้อเท้า) + ขาหนีบ = แถบขาว · ท้อง 9 ช่องสลับโทน (แบบ CIS)
    '  if (' + JOINT_IDS.map(function (n) { return 'abs(id - ' + ri(n) + ') < 0.5'; }).join(' || ') + ') base = vec3(0.965, 0.968, 0.973);',
    '  if (' + CHECK_IDS.map(function (n) { return 'abs(id - ' + ri(n) + ') < 0.5'; }).join(' || ') + ') base = vec3(0.855, 0.859, 0.875);',
    '  if (abs(id - uSel) < 0.5) base = vec3(0.643, 0.761, 0.957);',
    // แสงนุ่ม: ไล่เงาตามมุมผิว (ไม่ toon แข็ง)
    '  vec3 vn = normalize(vVN);',
    '  float ndl = dot(vn, normalize(vec3(0.3, 0.55, 0.78)));',
    '  float sh = 0.80 + 0.20 * smoothstep(-0.4, 0.9, ndl);',
    '  float rim = pow(1.0 - max(vn.z, 0.0), 3.0);',
    '  vec3 col = base * sh - rim * 0.10;',
    // เส้นแบ่งบริเวณ: รหัสต่างกันในพิกเซลข้างเคียง
    '  vec3 nn = normalize(vNrm);',
    '  float e = step(0.5, abs(region(vPos + dFdx(vPos), nn) - id) + abs(region(vPos + dFdy(vPos), nn) - id));',
    '  col = mix(col, vec3(0.66, 0.68, 0.72), e);',
    '  gl_FragColor = vec4(col, 1.0);',
    '}'];
  const vs = [
    'varying vec3 vPos; varying vec3 vNrm; varying vec3 vVN;',
    'void main() {',
    '  vPos = position; vNrm = normal; vVN = normalize(normalMatrix * normal);',
    '  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);',
    '}'].join('\n');
  return { vs: vs, fs: fs.join('\n') };
}

function buildMannequin(fig) {
  const body = fig.userData.body || fig;
  fig.updateMatrixWorld(true);
  // ข้อต่อ/แกนลำตัวในพิกัดหุ่น (mesh หุ่นเทาอยู่ในพิกัดเดียวกัน)
  const ws = fig.getWorldScale(new THREE.Vector3()).x || 1;
  const fqi = fig.getWorldQuaternion(new THREE.Quaternion()).invert();
  const toL = function (v) { return fig.worldToLocal(v.clone()); };
  const dirL = function (v) { return v.clone().applyQuaternion(fqi).normalize(); };
  const ax = bodyAxes(body);
  const far = new THREE.Vector3(1e4, 1e4, 1e4);
  const uA = [], uC = [], uHasC = [];
  PICK_BONES.forEach(function (name) {
    const b = findNode(body, name);
    if (!b) { uA.push(far.clone()); uC.push(far.clone()); uHasC.push(0); return; }
    const child = b.children.filter(function (c) { return c.isBone; })[0];
    uA.push(toL(b.getWorldPosition(new THREE.Vector3())));
    uC.push(child ? toL(child.getWorldPosition(new THREE.Vector3())) : far.clone());
    uHasC.push(child ? 1 : 0);
  });
  const sh = mannShader();
  const uniforms = {
    uA: { value: uA }, uC: { value: uC }, uHasC: { value: uHasC },
    uPel: { value: toL(ax.pel) }, uNeck: { value: toL(ax.neck) },
    uUp: { value: dirL(ax.up) }, uLeft: { value: dirL(ax.left) }, uFront: { value: dirL(ax.front) },
    uHalf: { value: ax.half / ws }, uSel: { value: -1 },
  };
  const mat = new THREE.ShaderMaterial({
    uniforms: uniforms, vertexShader: sh.vs, fragmentShader: sh.fs,
  });
  mat.extensions.derivatives = true;
  const g = new THREE.Group();
  g.name = 'mannequin_g';
  g.userData.mat = mat;
  skinMeshes(fig).forEach(function (m) {
    const src = m.geometry;
    const pos = src.attributes.position;
    if (!pos) return;
    if (m.isSkinnedMesh && m.skeleton) m.skeleton.update();
    const geo = new THREE.BufferGeometry();
    const arr = new Float32Array(pos.count * 3);
    for (let i = 0; i < pos.count; i++) {
      const v = new THREE.Vector3().fromBufferAttribute(pos, i);
      if (m.isSkinnedMesh) m.boneTransform(i, v);
      v.applyMatrix4(m.matrixWorld);
      const q = fig.worldToLocal(v);
      arr[i * 3] = q.x; arr[i * 3 + 1] = q.y; arr[i * 3 + 2] = q.z;
    }
    geo.setAttribute('position', new THREE.BufferAttribute(arr, 3));
    if (src.index) geo.setIndex(src.index.clone());
    geo.computeVertexNormals();
    const mesh = new THREE.Mesh(geo, mat);
    mesh.name = 'mannequin';
    mesh.renderOrder = 2;
    g.add(mesh);
    // เส้นขอบรอบตัว (inverted hull)
    const hull = geo.clone();
    const hp = hull.attributes.position, hn = hull.attributes.normal;
    const k = 0.003 / ws;
    for (let i = 0; i < hp.count; i++) {
      hp.setXYZ(i, hp.getX(i) + hn.getX(i) * k, hp.getY(i) + hn.getY(i) * k,
          hp.getZ(i) + hn.getZ(i) * k);
    }
    const outline = new THREE.Mesh(hull, new THREE.MeshBasicMaterial({
      color: 0xA4AAB3, side: THREE.BackSide, toneMapped: false,
    }));
    outline.name = 'mannequin_hull';
    outline.visible = false; // แสงนุ่มแบบภาพหุ่นสแกนใบหน้า: ไม่มีเส้นขอบ
    outline.raycast = function () {};
    g.add(outline);
  });
  fig.add(g);
  return g;
}
// บริเวณคู่หน้า-หลังของแขนขา/ศีรษะ/คอ: บนหุ่น 3D ไฮไลต์รอบท่อนทั้งวง (ไม่ใช่ครึ่งหน้า)
function regionPair(r) {
  if (!r) return null;
  const fixed = { head: 'b-head', 'b-head': 'head', neck: 'b-nape', 'b-nape': 'neck' };
  if (fixed[r]) return fixed[r];
  let m = /^b([lr])-(.+)$/.exec(r);
  if (m) return m[1] + '-' + m[2];
  m = /^([lr])-(shoulder|arm|elbow|forearm|wrist|hand|thigh|knee|leg|ankle)$/.exec(r);
  if (m) return 'b' + m[1] + '-' + m[2];
  return null;
}
function mannPaint(g, sel) {
  const v = sel ? RIDS.indexOf(sel) : -1;
  const p2 = regionPair(sel);
  const v2 = p2 ? RIDS.indexOf(p2) : -1;
  (g.mats || [g.userData.mat]).forEach(function (m) {
    m.uniforms.uSel.value = v;
    if (m.uniforms.uSel2) m.uniforms.uSel2.value = v2;
  });
  markDirty(4);
}
// ---------------------------------------------- บริเวณร่างกายบนหุ่นผิวจริง (พิกัด LANDMARK)
// หุ่นหน้ารายละเอียดหุบแขนที่จุดยอด (ไม่ใช่กระดูก rig) กระดูก rig จึงไม่ตรงผิว
// แบ่งบริเวณด้วยพิกัด LANDMARK ของหุ่นเอง (เมตร หุ่นชายสูง 1.69 · +x = ซ้ายผู้ป่วย · +z = ด้านหน้า)
// กฎชุดเดียวใช้ทั้งแตะ (JS) และวาดสี/เส้นแบ่ง (GLSL ใน lmShaderFn) — แก้ต้องแก้ทั้งคู่
const LM = (function () {
  const mv = function (k) {
    const j = ANAT_JOINT[k + '.L'];
    const q = anatArmMove(j[0], j[1], 1);
    return [q[0], q[1], j[2]];
  };
  return {
    S: mv('UpperArm'), E: mv('Forearm'), W: mv('Palm'), T: mv('Middle3'),
    H: ANAT_JOINT['Hip.L'], K: ANAT_JOINT['Shin.L'], A: ANAT_JOINT['Foot.L'],
    O: ANAT_JOINT['Toes.L'],
  };
})();
// ความสูงแบ่งลำตัว (หุ่นชาย 1.69 ม.) · คอลัมน์กลาง ±MID
const LMY = { head: 1.465, headB: 1.52, neck: 1.40, chest: 1.17, epi: 1.08, umb: 0.98, hypo: 0.88,
  groin: 0.82, back1: 1.15, back2: 0.92 };
const LM_MID = 0.055;
function lmSeg(p, a, b) {
  const ab = [b[0] - a[0], b[1] - a[1], b[2] - a[2]];
  const l2 = ab[0] * ab[0] + ab[1] * ab[1] + ab[2] * ab[2] || 1e-9;
  const t = ((p[0] - a[0]) * ab[0] + (p[1] - a[1]) * ab[1] + (p[2] - a[2]) * ab[2]) / l2;
  const c = Math.max(0, Math.min(1, t));
  const q = [a[0] + ab[0] * c, a[1] + ab[1] * c, a[2] + ab[2] * c];
  const d = Math.hypot(p[0] - q[0], p[1] - q[1], p[2] - q[2]);
  return { t: t, d: d, z: q[2] };
}
function lmRegion(x, y, z, ny) {
  const L = x >= 0, ax = Math.abs(x), sd = L ? 'l' : 'r';
  const P = [ax, y, z];   // ใช้ข้างซ้ายเสมอ (สมมาตร)
  // ศีรษะ / คอ
  // ศีรษะรวมคาง (หน้า) · ด้านหลังท้ายทอยต่ำกว่าแนวผม = ต้นคอ
  if (z >= 0 ? y > LMY.head : y > LMY.headB) return z < 0 ? 'b-head' : 'head';
  if (y > LMY.neck && ax < 0.075) return z < -0.01 ? 'b-nape' : 'neck';
  // แขน: ใกล้แนวกระดูกแขน (หลังหุบ) และอยู่นอกลำตัว
  const se = lmSeg(P, LM.S, LM.E), ew = lmSeg(P, LM.E, LM.W), wt = lmSeg(P, LM.W, LM.T);
  const dArm = Math.min(se.d, ew.d, wt.d);
  if (y < LMY.neck + 0.02 && ax > 0.125 && dArm < 0.075) {
    const lb = function (id) { return (back3(P, se, ew, wt) ? 'b' + sd : sd) + '-' + id; };
    if (wt.d <= dArm + 1e-6 && wt.t > 0.05) return lb('hand');
    // ข้อมือ/ข้อศอก = แถบขวางท่อนแขน (ตามแนวกระดูก)
    if (ew.d <= se.d) {
      if (ew.t > 0.88) return lb('wrist');
      if (ew.t < 0.1) return lb('elbow');
      return lb('forearm');
    }
    if (se.t > 0.88) return lb('elbow');
    return se.t < 0.18 ? lb('shoulder') : lb('arm');
  }
  // ไหล่ด้านบน (เหนือรักแร้ นอกคอ)
  if (y > 1.30 && ax > 0.13) return (z < 0 ? 'b' + sd : sd) + '-shoulder';
  // ขา
  // แนวขาหนีบเฉียง (รูปตัว V แบบ CIS)
  const legT = y < LMY.groin + 0.7 * Math.max(0, ax - 0.04);
  if (legT) {
    const hk = lmSeg(P, LM.H, LM.K), ka = lmSeg(P, LM.K, LM.A);
    const back = z < (y > LM.K[1] ? hk.z : ka.z);
    const lb = function (id) { return (back ? 'b' + sd : sd) + '-' + id; };
    if (y < LM.A[1] - 0.03) {
      if (ny < -0.5) return 'b' + sd + '-midfoot';
      return z < LM.A[2] ? 'b' + sd + '-heel' : sd + '-foot';
    }
    if (Math.abs(y - LM.A[1]) <= 0.03) return lb('ankle');
    if (Math.abs(y - LM.K[1]) < 0.05) return lb('knee');
    if (y > LM.K[1]) return lb('thigh');
    return lb('leg');
  }
  // ลำตัว
  const mid = ax < LM_MID;
  if (z < 0) {
    if (y > LMY.back1) return L ? 'bul' : 'bur';
    if (y > LMY.back2) return mid ? 'blc' : (L ? 'bll' : 'blr');
    return 'b' + sd + '-buttock';
  }
  if (y > LMY.chest) return mid ? 'chest' : sd + '-chest';
  if (y > LMY.epi) return mid ? 'epigastric' : sd + '-hypochondriac';
  if (y > LMY.umb) return mid ? 'umbilical' : sd + '-lumbar';
  if (y > LMY.hypo) return mid ? 'hypogastric' : sd + '-iliac';
  return ax > 0.045 ? 'groin' : 'pelvis';
}
function back3(P, se, ew, wt) {
  const s = se.d <= ew.d && se.d <= wt.d ? se : (ew.d <= wt.d ? ew : wt);
  return P[2] < s.z;
}
// พิกัด LANDMARK ของจุดบน mesh หุ่นผิวจริง (ต้องมี userData.anat จากตอนโหลด)
function lmOf(mesh, worldP) {
  const a = mesh.userData.anat;
  const q = mesh.worldToLocal(worldP.clone());
  return [q.x / a.wx, (q.y - a.feet) / a.ky, q.z];
}

// GLSL ของ lmRegion (ตรงกันทุกเงื่อนไข) คืนดัชนีใน RIDS
function lmShaderFn() {
  const v3 = function (a) { return 'vec3(' + a.map(function (x) { return (+x).toFixed(4); }).join(', ') + ')'; };
  const f = function (x) { return (+x).toFixed(4); };
  const lim = function (id) {
    return '(bk ? (Lf ? ' + ri('bl-' + id) + ' : ' + ri('br-' + id) + ') : (Lf ? ' + ri('l-' + id) + ' : ' + ri('r-' + id) + '))';
  };
  return [
    'vec3 lmSeg(vec3 p, vec3 a, vec3 b) { vec3 ab = b - a; float t = dot(p - a, ab) / max(dot(ab, ab), 1e-9);',
    '  vec3 q = a + ab * clamp(t, 0.0, 1.0); return vec3(t, length(p - q), q.z); }',
    'float lmRegion(vec3 p0, float ny) {',
    '  float x = p0.x, y = p0.y, z = p0.z;',
    '  bool Lf = x >= 0.0; float ax = abs(x); vec3 P = vec3(ax, y, z); bool bk = false;',
    '  if (z >= 0.0 ? y > ' + f(LMY.head) + ' : y > ' + f(LMY.headB) + ') return z < 0.0 ? ' + ri('b-head') + ' : ' + ri('head') + ';',
    '  if (y > ' + f(LMY.neck) + ' && ax < 0.075) return z < -0.01 ? ' + ri('b-nape') + ' : ' + ri('neck') + ';',
    '  vec3 se = lmSeg(P, ' + v3(LM.S) + ', ' + v3(LM.E) + ');',
    '  vec3 ew = lmSeg(P, ' + v3(LM.E) + ', ' + v3(LM.W) + ');',
    '  vec3 wt = lmSeg(P, ' + v3(LM.W) + ', ' + v3(LM.T) + ');',
    '  float dArm = min(se.y, min(ew.y, wt.y));',
    '  if (y < ' + f(LMY.neck + 0.02) + ' && ax > 0.125 && dArm < 0.075) {',
    '    vec3 s = (se.y <= ew.y && se.y <= wt.y) ? se : (ew.y <= wt.y ? ew : wt);',
    '    bk = z < s.z;',
    '    if (wt.y <= dArm + 1e-6 && wt.x > 0.05) return ' + lim('hand') + ';',
    '    if (ew.y <= se.y) return ew.x > 0.88 ? ' + lim('wrist') + ' : (ew.x < 0.1 ? ' + lim('elbow') + ' : ' + lim('forearm') + ');',
    '    if (se.x > 0.88) return ' + lim('elbow') + ';',
    '    return se.x < 0.18 ? ' + lim('shoulder') + ' : ' + lim('arm') + ';',
    '  }',
    '  if (y > 1.30 && ax > 0.13) { bk = z < 0.0; return ' + lim('shoulder') + '; }',
    '  if (y < ' + f(LMY.groin) + ' + 0.7 * max(0.0, ax - 0.04)) {',
    '    vec3 hk = lmSeg(P, ' + v3(LM.H) + ', ' + v3(LM.K) + ');',
    '    vec3 ka = lmSeg(P, ' + v3(LM.K) + ', ' + v3(LM.A) + ');',
    '    bk = z < (y > ' + f(LM.K[1]) + ' ? hk.z : ka.z);',
    '    if (y < ' + f(LM.A[1] - 0.03) + ') {',
    '      if (ny < -0.5) return Lf ? ' + ri('bl-midfoot') + ' : ' + ri('br-midfoot') + ';',
    '      return z < ' + f(LM.A[2]) + ' ? (Lf ? ' + ri('bl-heel') + ' : ' + ri('br-heel') + ') : (Lf ? ' + ri('l-foot') + ' : ' + ri('r-foot') + ');',
    '    }',
    '    if (abs(y - ' + f(LM.A[1]) + ') <= 0.03) return ' + lim('ankle') + ';',
    '    if (abs(y - ' + f(LM.K[1]) + ') < 0.05) return ' + lim('knee') + ';',
    '    if (y > ' + f(LM.K[1]) + ') return ' + lim('thigh') + ';',
    '    return ' + lim('leg') + ';',
    '  }',
    '  bool mid = ax < ' + f(LM_MID) + ';',
    '  if (z < 0.0) {',
    '    if (y > ' + f(LMY.back1) + ') return Lf ? ' + ri('bul') + ' : ' + ri('bur') + ';',
    '    if (y > ' + f(LMY.back2) + ') return mid ? ' + ri('blc') + ' : (Lf ? ' + ri('bll') + ' : ' + ri('blr') + ');',
    '    return Lf ? ' + ri('bl-buttock') + ' : ' + ri('br-buttock') + ';',
    '  }',
    '  if (y > ' + f(LMY.chest) + ') return mid ? ' + ri('chest') + ' : (Lf ? ' + ri('l-chest') + ' : ' + ri('r-chest') + ');',
    '  if (y > ' + f(LMY.epi) + ') return mid ? ' + ri('epigastric') + ' : (Lf ? ' + ri('l-hypochondriac') + ' : ' + ri('r-hypochondriac') + ');',
    '  if (y > ' + f(LMY.umb) + ') return mid ? ' + ri('umbilical') + ' : (Lf ? ' + ri('l-lumbar') + ' : ' + ri('r-lumbar') + ');',
    '  if (y > ' + f(LMY.hypo) + ') return mid ? ' + ri('hypogastric') + ' : (Lf ? ' + ri('l-iliac') + ' : ' + ri('r-iliac') + ');',
    '  return ax > 0.045 ? ' + ri('groin') + ' : ' + ri('pelvis') + ';',
    '}',
  ].join('\n');
}

function lmMannMat(a) {
  const fs = [
    'uniform float uAlpha;',
    'uniform float uSel; uniform float uSel2; uniform float uWx; uniform float uFeet; uniform float uKy;',
    'varying vec3 vP; varying vec3 vN; varying vec3 vVN;',
    lmShaderFn(),
    'vec3 lmOfP(vec3 p) { return vec3(p.x / uWx, (p.y - uFeet) / uKy, p.z); }',
    'void main() {',
    '  vec3 nn = normalize(vN);',
    '  float id = lmRegion(lmOfP(vP), nn.y);',
    '  vec3 base = vec3(1.0);',
    '  if (abs(id - uSel) < 0.5 || abs(id - uSel2) < 0.5) base = vec3(0.776, 0.855, 0.988);',
    '  vec3 vn = normalize(vVN);',
    '  float ndl = dot(vn, normalize(vec3(0.3, 0.55, 0.78)));',
    // แสงนุ่มแบบภาพหุ่นสแกนใบหน้า (2026-11-26 แทนลายเส้นหมึก): หลัก + เติม + ขอบ บนพื้นขาว
    '  float sk = max(ndl, 0.0);',
    '  float sf = max(dot(vn, normalize(vec3(-0.7, 0.15, 0.55))), 0.0);',
    '  float sr = pow(1.0 - max(vn.z, 0.0), 3.0);',
    '  vec3 col = base * (0.62 + 0.30 * sk + 0.10 * sf) + 0.08 * sr;',
    // เส้นขอบด้านใน (ผิวหันข้างเข้าหาผู้ดู เช่น ขอบอก แขนทับลำตัว) = หมึกบาง
    // ใบหน้าไม่มีลายเส้น (แบบภาพสำเร็จรูป) เหลือแค่เส้นขอบศีรษะ
    '  vec3 lq = lmOfP(vP);',
    '  float onHead = step(' + LMY.neck.toFixed(3) + ', lq.y);',
    // ใบหน้า (ส่วนหน้าตรงกลาง): ไม่มีเส้น
    '  float faceZone = onHead * step(abs(lq.x), 0.06) * step(0.0, lq.z);',
    // เส้นบางแบบภาพสำเร็จรูป: ขอบด้านใน + ใบหน้า (ตา จมูก ปาก) เส้นเบากว่า
    // ไม่มีเส้นหมึกแล้ว (แสงนุ่มแบบภาพหุ่นสแกนใบหน้า)
    // ไม่แบ่งบริเวณให้เห็น (ผู้ใช้ไม่เอาเส้นแบ่ง/โทนสลับ) · เหลือไฮไลต์บริเวณที่เลือก
    '  gl_FragColor = vec4(col, uAlpha);',
    '}'].join('\n');
  const vs = [
    'varying vec3 vP; varying vec3 vN; varying vec3 vVN;',
    'void main() {',
    '  vP = position; vN = normal; vVN = normalize(normalMatrix * normal);',
    '  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);',
    '}'].join('\n');
  const m = new THREE.ShaderMaterial({
    uniforms: { uAlpha: { value: 1 }, uSel: { value: -1 }, uSel2: { value: -1 }, uWx: { value: a.wx }, uFeet: { value: a.feet }, uKy: { value: a.ky } },
    vertexShader: vs, fragmentShader: fs,
  });
  m.extensions.derivatives = true;
  return m;
}
const LM_JOINT_IDS = [];
['elbow', 'wrist', 'knee', 'ankle'].forEach(function (j) {
  ['r-', 'l-', 'br-', 'bl-'].forEach(function (p) { LM_JOINT_IDS.push(p + j); });
});

// หุ่นเทาแบบ body map บนหุ่นผิวจริง: ใช้ geometry เดิม (ท่าเดียวกัน) วัสดุ shader บริเวณ
function buildMannequinLm(fig) {
  const g = { mats: [], meshes: [] };
  const list = [];
  fig.traverse(function (o) {
    if (o.isMesh && o.userData.anat && !/eye/i.test(o.name)) list.push(o);
  });
  if (!list.length) return null;
  // ตา (วัสดุแยก) ซ่อนในโหมดลายเส้น
  fig.traverse(function (o) { if (o.isMesh && /eye/i.test(o.name)) list.push(o); });
  // สายรัดข้อมือ ESI และชิ้นอื่นข้างผิว (ไม่ใช่ผิว) ซ่อนในโหมดลายเส้น
  const parents = new Set(list.map(function (o) { return o.parent; }));
  fig.traverse(function (o) {
    if (o.name === 'wristband') o.traverse(function (k) { if (k.isMesh) list.push(k); });
  });
  parents.forEach(function (pa) {
    pa.children.forEach(function (o) {
      if (o.isMesh && !o.userData.anat && list.indexOf(o) < 0) list.push(o);
    });
  });
  const skins = list.filter(function (o) { return o.userData.anat && !/eye/i.test(o.name); });
  skins.forEach(function (m) {
    const mat = lmMannMat(m.userData.anat);
    const mm = new THREE.Mesh(m.geometry, mat);
    mm.name = 'mannequin';
    mm.userData.anat = m.userData.anat;
    mm.position.copy(m.position); mm.quaternion.copy(m.quaternion); mm.scale.copy(m.scale);
    mm.frustumCulled = false;
    m.parent.add(mm);
    // เส้นขอบรอบตัว (inverted hull)
    const hull = m.geometry.clone();
    if (!hull.attributes.normal) hull.computeVertexNormals();
    const hp = hull.attributes.position, hn = hull.attributes.normal;
    const an = m.userData.anat;
    for (let i = 0; i < hp.count; i++) {
      // ใบหน้า: ไม่ขยายขอบ (เส้นขอบโผล่ตามร่องตา/จมูก ดูน่ากลัว) ใช้ขอบจาก shader แทน
      // เฉพาะผิวหน้าตรง (หันหน้า) ไม่ขยาย · ขอบศีรษะด้านข้าง/หลังยังเป็นเส้นหมึก
      // ศีรษะเส้นบางกว่า (ไม่ให้เส้นโผล่ตามร่องตา/จมูกหนา)
      const k = (hp.getY(i) - an.feet) / an.ky > LMY.neck ? 0.0012 : 0.0022;
      hp.setXYZ(i, hp.getX(i) + hn.getX(i) * k, hp.getY(i) + hn.getY(i) * k,
          hp.getZ(i) + hn.getZ(i) * k);
    }
    // เส้นขอบหมึกเข้ม (แบบภาพสำเร็จรูป HOSxP)
    const ol = new THREE.Mesh(hull, new THREE.MeshBasicMaterial({
      color: 0x2B3245, side: THREE.BackSide, toneMapped: false,
    }));
    ol.name = 'mannequin_hull';
    ol.visible = false; // แสงนุ่มแบบภาพหุ่นสแกนใบหน้า: ไม่มีเส้นขอบหมึก
    ol.raycast = function () {};
    ol.position.copy(m.position); ol.quaternion.copy(m.quaternion); ol.scale.copy(m.scale);
    m.parent.add(ol);
    g.mats.push(mat);
    g.meshes.push(mm, ol);
    m.userData.mannHidden = true;
  });
  g.orig = list;
  return g;
}

let regionSel = null;
window.erRegionSel = function (id) {
  regionSel = id || null;
  const pivot = bodies[selected];
  const fig = pivot && pivot !== 'loading' ? skinOf(pivot) : null;
  if (fig && fig.userData.mann) mannPaint(fig.userData.mann, regionSel);
};

let regionLinesOn = false;
window.erRegionLines = function (on) {
  regionLinesOn = !!on;
  regionLinesApply();
};
function regionLinesApply() {
  const pivot = bodies[selected];
  const fig = pivot && pivot !== 'loading' ? skinOf(pivot) : null;
  if (!fig) { if (regionLinesOn) setTimeout(regionLinesApply, 500); return; }
  let mn = fig.userData.mann;
  if (regionLinesOn && !mn) {
    try {
      // หุ่นเทาแบบ body map: บริเวณ/เส้นแบ่งคำนวณใน shader จากพิกัด LANDMARK (เรียบ ตรงรูปร่าง)
      mn = buildMannequinLm(fig);
      if (!mn) { setTimeout(regionLinesApply, 500); return; }
      fig.userData.mann = mn;
      if (regionSel) mannPaint(mn, regionSel);
      mannAlpha();
    } catch (err) { send({ type: 'error', message: 'regionLines: ' + err }); return; }
  }
  if (mn) {
    // เส้นขอบหมึก (mannequin_hull) ไม่แสดงแล้ว: แสงนุ่มแบบภาพหุ่นสแกนใบหน้า
    mn.meshes.forEach(function (o) { o.visible = regionLinesOn && o.name !== 'mannequin_hull'; });
    // โหมด body map: ซ่อนผิวจริง (หุ่นเทาแทน) · ปิด = คืนผิวจริง
    mn.orig.forEach(function (o) { o.visible = !regionLinesOn; });
  }
  markDirty(6);
}

// เลือกบริเวณ (tool 'region'): แตะบนผิว = บอกแอปว่าบริเวณไหน + จุดในพิกัดหุ่น (ให้กล้องเล็ง)
function pickRegion(e) {
  const h = skinHit(e);
  if (!h) return false;
  const q = skinLocal(h);
  let reg = null;
  try { reg = regionOf(h); } catch (err) { send({ type: 'error', message: 'regionOf: ' + err }); }
  send({ type: 'regionPick', region: reg,
    pt: [+q.x.toFixed(4), +q.y.toFixed(4), +q.z.toFixed(4)] });
  return true;
}

function plotPin(e) {
  const h = skinHit(e);
  if (!h) return false;
  const st = {
    id: 'p' + Date.now().toString(36),
    color: drawCfg.color || '#d93025',
    r: drawCfg.r || 0.009,
    pts: [skinLocal(h)],
    fig: h.fig,
    body: h.body,
  };
  // แนวตั้งฉากผิว (พิกัดหุ่น) ไว้ซ่อนป้ายเมื่อหมุดหันหนีกล้อง
  if (h.hit.face) {
    const nw = h.hit.face.normal.clone().transformDirection(h.hit.object.matrixWorld);
    st.n = nw.applyQuaternion(h.fig.getWorldQuaternion(new THREE.Quaternion()).invert());
  }
  strokeBuild(st);
  strokes.push(st);
  send({
    type: 'drawStroke', id: st.id, color: st.color, r: st.r,
    bone: boneNear(st.body, h.hit.point),
    region: regionOf(h),
    pts: [[+st.pts[0].x.toFixed(4), +st.pts[0].y.toFixed(4), +st.pts[0].z.toFixed(4)]],
  });
  return true;
}

// ---------------------------------------------- ระบายบนผิว (แผล ผื่น ไฟไหม้)
function skinRay(fig, origin, dir, only) {
  ray.set(origin, dir);
  const hit = ray.intersectObject(only || fig, !only).filter(function (h) {
    const n = String(h.object.name);
    return shownChain(h.object) && n.indexOf('mark_') !== 0 &&
        n.indexOf('bone_') !== 0 && n.indexOf('heat_') !== 0 &&
        n.indexOf('wound_') !== 0 && n.indexOf('draw_') !== 0 &&
        !h.object.userData.piece &&
        h.object.parent && String(h.object.parent.name).indexOf('layer_') !== 0 &&
        String(h.object.parent.name).indexOf('draw_') !== 0;
  })[0];
  return hit || null;
}
// ระยะในโลก 3D ต่อ 1 ซม. จริง: ข้อต่อศีรษะถึงข้อเท้า ≈ 150 ซม. ของคนสูง 170 ซม.
function worldPerCm(fig, body) {
  if (!fig.userData.wpc) {
    const b = body || fig.userData.body || fig;
    const hd = findNode(b, 'Head'), ft = findNode(b, 'Foot.L') || findNode(b, 'Foot.R');
    const d = hd && ft
        ? hd.getWorldPosition(new THREE.Vector3())
            .distanceTo(ft.getWorldPosition(new THREE.Vector3()))
        : 0;
    fig.userData.wpc = d > 0 ? d / 150 : 0.01;
  }
  return fig.userData.wpc;
}
function drawDown(e) {
  if (!detailMode() || !drawCfg || !e.isPrimary) return false;
  // ปักหมุด/เลือกบริเวณทำตอนยกนิ้ว · ลาก = หมุน/ซูมอย่างเดียว ไม่ปัก ไม่วาด
  if (drawCfg.tool === 'pin' || drawCfg.tool === 'region' || drawCfg.tool === 'move') return false;
  const h = skinHit(e);
  if (!h) return false;
  if (drawCfg.tool === 'eraser') {
    // ลบเส้นที่ใกล้จุดแตะที่สุด (ภายใน 3 ซม.)
    const p = h.hit.point;
    let hitSt = null, bestD = 0.03;
    strokes.forEach(function (st) {
      st.pts.forEach(function (q) {
        const d = st.fig.localToWorld(q.clone()).distanceTo(p);
        if (d < bestD) { bestD = d; hitSt = st; }
      });
    });
    if (hitSt) {
      strokeRemove(hitSt);
      strokes = strokes.filter(function (s) { return s !== hitSt; });
      send({ type: 'drawErase', id: hitSt.id });
    }
    return true;
  }
  let reg0 = null;
  try { reg0 = regionOf(h); } catch (err) {}
  curStroke = {
    region: reg0,
    id: 's' + Date.now().toString(36),
    color: drawCfg.color || '#d93025',
    r: drawCfg.r || 0.004,
    pts: [skinLocal(h)],
    fig: h.fig,
    body: h.body,
  };
  // ระบาย: พู่กันขนาดจริง (ซม.) แต้มเป็นแผ่นแนบผิวตามแนวตั้งฉากผิว
  if (drawCfg.brush) {
    curStroke.paint = true;
    curStroke.r = drawCfg.brush * worldPerCm(h.fig, h.body);
    curStroke.nrm = [skinNormal(h)];
    curStroke.stencil = nextStencil();
  }
  strokeBuild(curStroke);
  return true;
}

function drawMove(e) {
  if (!curStroke) return false;
  if (pointers.size > 1) {        // นิ้วที่สองลง = ซูม ยกเลิกเส้นนี้
    strokeRemove(curStroke);
    curStroke = null;
    return false;
  }
  const h = skinHit(e);
  if (h && h.fig === curStroke.fig) {
    const p = skinLocal(h);
    const last = curStroke.pts[curStroke.pts.length - 1];
    const ws = curStroke.fig.getWorldScale(new THREE.Vector3()).x || 1;
    const step = curStroke.paint ? curStroke.r * 0.35 : 0.003;
    if (p.distanceTo(last) * ws > step) {
      curStroke.pts.push(p);
      if (curStroke.paint) curStroke.nrm.push(skinNormal(h));
      strokeBuild(curStroke);
    }
  }
  return true;
}

function drawUp() {
  if (!curStroke) return false;
  const st = curStroke;
  curStroke = null;
  strokes.push(st);
  const mid = st.fig.localToWorld(st.pts[Math.floor(st.pts.length / 2)].clone());
  send({
    type: 'drawStroke',
    id: st.id,
    color: st.color,
    r: st.r,
    bone: boneNear(st.body, mid),
    region: st.region,
    paint: st.paint || undefined,
    nrm: st.nrm ? st.nrm.map(function (q) {
      return [+q.x.toFixed(3), +q.y.toFixed(3), +q.z.toFixed(3)];
    }) : undefined,
    pts: st.pts.map(function (q) {
      return [+q.x.toFixed(4), +q.y.toFixed(4), +q.z.toFixed(4)];
    }),
  });
  return true;
}

// มุมมองสำเร็จรูป: เลื่อนกล้องไปที่บริเวณหนึ่งบนหุ่น (จุดระหว่างข้อต่อ a→b ที่สัดส่วน t)
// แล้วหมุน/เอียง/ซูมตามที่ระบุ · กล้องตามจุดนั้นทุกเฟรมระหว่างหุ่นหมุน · null = กลับทั้งตัว
let focusAim = null;
window.erFocus = function (f) {
  spinVel = 0;
  if (!f) {
    focusAim = null;
    spinWant = 0; tiltWant = 0; zoomWant = 1;
    const c = focusOf(selected);
    if (c) { targetPos.set(c.x, 0, c.z); focusY = c.y; }
    markDirty(60);
    return;
  }
  focusAim = f;
  // เล็งจุดบนผิว: คงมุมหมุนที่ผู้ใช้หมุนไว้ (เห็นด้านเดิมที่แตะ)
  if (!f.pt) {
    spinWant = f.spin || 0;
    tiltWant = f.tilt || 0;
  }
  zoomWant = Math.min(2.0, Math.max(0.3, f.zoom || 1));
  markDirty(90);
};
function aimFollow() {
  if (!focusAim || !detailMode()) return;
  const pivot = bodies[selected];
  const fig = pivot && pivot !== 'loading' ? skinOf(pivot) : null;
  if (!fig) return;
  const body = fig.userData.body || fig;
  fig.updateMatrixWorld(true);
  if (focusAim.pt) {
    // จุดบนผิวที่แตะอยู่นอกแกนหมุน: หมุนแล้วจุดวนรอบตัว กล้องไล่ตามจนหุ่นแกว่ง
    // เล็งแกนกลางของส่วนนั้นแทน (จุดใกล้สุดบนกระดูกท่อนที่ใกล้จุดแตะ) หุ่นจะหมุนอยู่กับที่
    if (!focusAim.c) {
      const s = fig.localToWorld(new THREE.Vector3(focusAim.pt[0], focusAim.pt[1], focusAim.pt[2]));
      // แกนที่ได้ไกลจากผิวเกิน (เช่นมือแนบต้นขา ได้แกนต้นขา) = เล็งจุดบนผิวตามเดิม
      const ax = boneAxisPoint(body, s);
      focusAim.c = fig.worldToLocal(ax.distanceTo(s) < 0.05 ? ax : s.clone());
    }
    const w = fig.localToWorld(focusAim.c.clone());
    targetPos.set(w.x, 0, w.z);
    focusY = w.y;
    // ระหว่างหมุน กล้องตามทันที ไม่ไล่หลัง (ไล่หลัง = หุ่นส่ายไปมา)
    if (Math.abs(spinWant - bodySpin) > 0.001 || Math.abs(tiltWant - bodyTilt) > 0.001) {
      currentPos.x = targetPos.x; currentPos.z = targetPos.z;
    }
    return;
  }
  if (!findNode(body, focusAim.a)) return;
  const a = bonePos(body, focusAim.a);
  const p = focusAim.b && findNode(body, focusAim.b)
      ? a.clone().lerp(bonePos(body, focusAim.b), focusAim.t || 0)
      : a;
  targetPos.set(p.x, 0, p.z);
  focusY = p.y;
  if (Math.abs(spinWant - bodySpin) > 0.001 || Math.abs(tiltWant - bodyTilt) > 0.001) {
    currentPos.x = targetPos.x; currentPos.z = targetPos.z;
  }
}

window.erDrawUndo = function () {
  const st = strokes.pop();
  if (st) strokeRemove(st);
};
window.erDrawErase = function (id) {
  const st = strokes.filter(function (s) { return s.id === id; })[0];
  if (!st) return;
  strokeRemove(st);
  strokes = strokes.filter(function (s) { return s !== st; });
};
window.erDrawClear = function () {
  strokes.forEach(strokeRemove);
  strokes = [];
};
// เส้นที่บันทึกแล้วจากแอป: แสดงบนหุ่นของเตียงที่เลือก (รอหุ่นโหลดเสร็จก่อน)
let drawPending = null;
window.erDrawLoad = function (list) {
  drawPending = list || [];
  drawApply();
};
function drawApply() {
  if (!drawPending) return;
  const pivot = bodies[selected];
  const fig = pivot && pivot !== 'loading' ? skinOf(pivot) : null;
  if (!fig) { setTimeout(drawApply, 500); return; }
  const list = drawPending;
  drawPending = null;
  window.erDrawClear();
  list.forEach(function (s) {
    if (!s.pts || !s.pts.length) return;
    const st = {
      id: s.id, color: s.color, r: s.r || 0.004, fig: fig,
      body: fig.userData.body || fig,
      pts: s.pts.map(function (a) { return new THREE.Vector3(a[0], a[1], a[2]); }),
    };
    if (s.paint && s.nrm) {
      st.paint = true;
      st.nrm = s.nrm.map(function (a) { return new THREE.Vector3(a[0], a[1], a[2]); });
      st.stencil = nextStencil();
    }
    strokeBuild(st);
    strokes.push(st);
  });
}
// ภาพหน้าจอฉากตอนนี้ (ใช้เป็นภาพย่อของภาพการตรวจร่างกาย)
window.erDrawSnap = function () {
  try {
    renderer.render(scene, camera);
    send({ type: 'drawSnap', data: renderer.domElement.toDataURL('image/jpeg', 0.82) });
  } catch (err) {
    send({ type: 'drawSnap', data: '' });
  }
};

function snapToNearestBed() {
  let best = null, bestD = Infinity;
  for (let i = 0; i < order.length; i++) {
    const code = order[i];
    const bed = beds[code];
    if (!bed || !bed.visible || !bed.userData.center) continue;
    if (!bodies[code] || bodies[code] === 'loading') continue;
    const c = bed.userData.center;
    const d = (c.x - targetPos.x) * (c.x - targetPos.x) +
        (c.z - targetPos.z) * (c.z - targetPos.z);
    if (d < bestD) { bestD = d; best = code; }
  }
  if (!best) return;
  window.erSelect(best);
  send({ type: 'tap', code: best });
}

// ลากนิ้ว
// โหมดห้อง = เลื่อนดูเตียงอื่นตามแนวแถว
// โหมดรายละเอียด = ล็อกอยู่กับผู้ป่วยรายเดียว
//   ลากหนึ่งนิ้ว = หมุนตัว · หุบ/กางสองนิ้ว = ซูม
let dragX = null;
let dragY = null;
// ค่าที่วาดจริง (ไล่ตามอย่างนุ่มนวล) กับค่าที่นิ้วสั่ง
let bodySpin = 0;
let bodyTilt = 0;
let zoomK = 1;
let spinWant = 0;
let tiltWant = 0;
let zoomWant = 1;
window.erSetZoom = function (k) {
  zoomWant = Math.min(2.0, Math.max(0.42, k));
  markDirty(30);
};
let spinVel = 0;          // แรงเฉื่อยหลังสะบัดนิ้ว
let dragging = false;
const pointers = new Map();
let pinchBase = null;
function detailMode() { return topWant === 1; }

function pinchDist() {
  const pts = Array.from(pointers.values());
  if (pts.length < 2) return null;
  const dx = pts[0].x - pts[1].x;
  const dy = pts[0].y - pts[1].y;
  return Math.hypot(dx, dy);
}

renderer.domElement.addEventListener('pointermove', function (e) {
  if (pointers.has(e.pointerId)) {
    pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
  }
  if (drawMove(e)) { dragX = null; dragY = null; return; }
  if (e.buttons === 0 && pointers.size === 0) {
    dragX = null; dragY = null; return;
  }

  // สองนิ้ว = ซูม ระยะห่างระหว่างนิ้วเทียบกับตอนเริ่มหุบ
  const d = pinchDist();
  if (detailMode() && d !== null) {
    if (pinchBase === null) pinchBase = { d: d, k: zoomWant };
    else {
      zoomWant = Math.min(2.0, Math.max(0.42, pinchBase.k * (pinchBase.d / d)));
      markDirty(20);
    }
    dragX = null; dragY = null;
    return;
  }
  pinchBase = null;

  if (e.buttons === 0) { dragX = null; dragY = null; return; }
  if (dragX === null) { dragX = e.clientX; dragY = e.clientY; return; }
  const dxPix = e.clientX - dragX;
  const dyPix = e.clientY - (dragY === null ? e.clientY : dragY);
  dragX = e.clientX;
  dragY = e.clientY;
  if (detailMode()) {
    // ลากซ้าย-ขวา = หมุนรอบแกนหัว-เท้า · ลากขึ้น-ลง = เอียงเข้า-ออกหาคนดู
    // เก็บเป็นค่าเป้าหมาย แล้วให้ลูปวาดไล่ตาม ภาพจะได้ไม่กระตุกตามนิ้ว
    // ลากไปทางไหน หุ่นหมุนตามนิ้วทางนั้น (ผู้ใช้ขอกลับทิศจากเดิม)
    const dSpin = -(dxPix / window.innerWidth) * Math.PI * 2.2;
    spinWant += dSpin;
    spinVel = spinVel * 0.5 + dSpin * 0.5;
    const lim = Math.PI * 0.22;
    tiltWant += (dyPix / window.innerHeight) * Math.PI * 1.2;
    tiltWant = Math.max(-lim, Math.min(lim, tiltWant));
    dragging = true;
    markDirty(4);
    return;
  }
  // ผังเตียง: ไม่ให้ปัดเลื่อนเตียง (เลือกผู้ป่วยจากรายชื่อฝั่งซ้ายแทน)
  return;
});

// หมุนรอบแกนหัว-เท้า จึงเห็นด้านหน้า ด้านข้าง ด้านหลังได้ครบ
function applyBodySpin() {
  Object.keys(bodies).forEach(function (c) {
    const b = bodies[c];
    if (b && b !== 'loading') {
      b.rotation.set(bodyTilt, 0, bodySpin);
    }
  });
}

// ------------------------------------------------- ส่งตำแหน่งเตียงบนจอกลับแอป
let lastSent = 0;
function reportPositions(moving) {
  const now = performance.now();
  // ขยับอยู่ส่งถี่หน่อย นิ่งแล้วส่งนาน ๆ ครั้งพอ ลดงานฝั่ง Flutter
  if (now - lastSent < (moving ? 40 : 400)) return;
  lastSent = now;
  const items = [];
  for (let i = 0; i < order.length; i++) {
    const code = order[i];
    const bed = beds[code];
    if (!bed || !bed.visible || !bed.userData.center) continue;
    const c = bed.userData.center;
    const nearZ = camera.position.z >= bed.userData.nearZ
      ? bed.userData.nearZ : bed.userData.farZ;
    const p = new THREE.Vector3(c.x, bed.userData.top + tagLift, nearZ);
    p.project(camera);
    items.push({
      code: code,
      x: (p.x + 1) / 2 * window.innerWidth,
      y: (-p.y + 1) / 2 * window.innerHeight,
      visible: p.z < 1 && p.x > -1.25 && p.x < 1.25,
    });
  }
  // จุดสำคัญบนตัวหุ่นของเตียงที่เลือก ไว้วางเครื่องหมายอาการทับ
  const hotspots = [];
  // โหมดรายละเอียดใช้หมุดที่ติดอยู่กับร่าง (หมุน/ซูมแล้วตาม)
  const bodyPivot = bodies[selected];
  if (bodyPivot && bodyPivot !== 'loading' && envFade() > 0.55) {
    const q0 = new THREE.Vector3();
    bodyPivot.children.forEach(function (c) {
      if (c.name.indexOf('mark_') !== 0) return;
      c.getWorldPosition(q0);
      // หันไปอยู่อีกฝั่งของตัวแล้วต้องซ่อน ไม่ใช่ลอยทับหลัง
      const toCam = camera.position.clone().sub(q0).normalize();
      const outward = new THREE.Vector3(0, 1, 0)
          .applyQuaternion(bodyPivot.getWorldQuaternion(new THREE.Quaternion()));
      const facing = toCam.dot(outward) > -0.15;
      q0.project(camera);
      hotspots.push({
        key: c.name.slice(5),
        x: (q0.x + 1) / 2 * window.innerWidth,
        y: (-q0.y + 1) / 2 * window.innerHeight,
        visible: q0.z < 1 && facing,
      });
    });
    // ตำแหน่งจริงของสิ่งที่เน้น (อวัยวะ · ชิ้นกระดูก · โซนความร้อน) ไว้วางป้ายชี้อาการ
    const _bb = new THREE.Box3();
    const hiPts = [];
    const lay = bodyPivot.userData.layers || {};
    hiSet.forEach(function (n) {
      const o = lay[n];
      if (o && o !== 'loading') hiPts.push([n, o]);
    });
    const skel = lay.bone;
    if (skel && skel !== 'loading') {
      boneHi.forEach(function (id) {
        const o = skel.getObjectByName('bone_' + id);
        if (o) hiPts.push(['bone:' + id, o]);
      });
    }
    const zfx = bodyPivot.userData.zoneFx || {};
    Object.keys(zfx).forEach(function (id) { hiPts.push(['zone:' + id, zfx[id]]); });
    hiPts.forEach(function (e) {
      e[1].updateMatrixWorld(true);
      if (e[0].indexOf('zone:') === 0) e[1].getWorldPosition(q0);
      else _bb.setFromObject(e[1]).getCenter(q0);
      q0.project(camera);
      hotspots.push({
        key: e[0],
        x: (q0.x + 1) / 2 * window.innerWidth,
        y: (-q0.y + 1) / 2 * window.innerHeight,
        visible: q0.z < 1,
      });
    });
    // หมุดที่ปัก (studio): ตำแหน่งบนจอ ไว้วางป้ายสิ่งที่พบแบบป้าย CC
    strokes.forEach(function (st) {
      if (st.pts.length !== 1 || !st.fig) return;
      const w = st.fig.localToWorld(st.pts[0].clone());
      let facing = true;
      // ทิศพุ่งออกจากผิว (พิกัดหุ่น): จากแกนกระดูกไปยังหมุด · หมุนไปด้านหลังแล้วซ่อนป้าย
      if (!st.n && st.body) {
        const ax = boneAxisPoint(st.body, w);
        const qi = st.fig.getWorldQuaternion(new THREE.Quaternion()).invert();
        st.n = w.clone().sub(ax).normalize().applyQuaternion(qi);
      }
      if (st.n) {
        const nw = st.n.clone().applyQuaternion(st.fig.getWorldQuaternion(new THREE.Quaternion()));
        facing = camera.position.clone().sub(w).normalize().dot(nw) > -0.05;
      }
      w.project(camera);
      hotspots.push({
        key: 'pin:' + st.id,
        x: (w.x + 1) / 2 * window.innerWidth,
        y: (-w.y + 1) / 2 * window.innerHeight,
        visible: w.z < 1 && facing,
      });
    });
    send({ type: 'positions', items: items, hotspots: hotspots });
    return;
  }
  // คนนั่งรอ (มุมข้าง): จุดยึดป้ายอาการบนหุ่นท่านั่ง
  waitHotspots().forEach(function (h) { hotspots.push(h); });
  const fig = figures[selected];
  if (fig && fig !== 'loading' && fig.userData.body) {
    const spots = { head: 'Head', arm: 'Forearm.L', belly: 'Belly', ankle: 'Shin.R' };
    const q = new THREE.Vector3();
    Object.keys(spots).forEach(function (k) {
      const n = findNode(fig.userData.body, spots[k]);
      if (!n) return;
      n.getWorldPosition(q);
      q.project(camera);
      hotspots.push({
        key: k,
        x: (q.x + 1) / 2 * window.innerWidth,
        y: (-q.y + 1) / 2 * window.innerHeight,
        visible: q.z < 1,
      });
    });
  }
  send({ type: 'positions', items: items, hotspots: hotspots });
}

let dirty = true;         // มีอะไรเปลี่ยนจนต้องวาดใหม่ไหม
let settleFrames = 0;     // จำนวนเฟรมที่ยังต้องวาดต่อหลังหยุดขยับ

function markDirty(frames) {
  dirty = true;
  settleFrames = Math.max(settleFrames, frames || 1);
}

function stepBeds() {
  let moving = false;
  for (let i = 0; i < order.length; i++) {
    const c = order[i];
    const b = beds[c];
    if (!b) continue;
    const on = (c === selected);
    const base = b.userData.baseScale || 1;
    const wantScale = base * (on ? 1.1 : 0.94);
    const k = b.scale.x + (wantScale - b.scale.x) * 0.18;
    if (Math.abs(k - wantScale) > base * 0.002) moving = true;
    b.scale.set(k, k, k);

    const wantOpacity = (on ? 1.0 : 0.32) * (1 - envFade());
    const mats = b.userData.mats || [];
    for (let m = 0; m < mats.length; m++) {
      const mat = mats[m];
      if (mat.opacity === undefined) continue;
      if (!mat.transparent) mat.transparent = true;
      mat.depthWrite = on;
      const o = mat.opacity + (wantOpacity - mat.opacity) * 0.18;
      if (Math.abs(o - wantOpacity) > 0.004) moving = true;
      mat.opacity = o;
      mat.visible = o > 0.005;
    }
  }
  return moving;
}

// ไล่ค่าที่วาดจริงเข้าหาค่าที่นิ้วสั่ง + ปล่อยแรงเฉื่อยหลังยกนิ้ว
function stepBody() {
  // เรืองแสงจุดที่เน้น = ค่าคงที่ (ไม่เต้น): ฉากนิ่งแล้วหยุด render ได้
  // เดิมเต้นตลอด = WebView วาด ~15 fps ไม่หยุด ทุกเฟรมบังคับ Flutter composite ทั้งจอ (กระตุกทั้งแอป)
  if (!dragging && Math.abs(spinVel) > 0.0004) {
    spinWant += spinVel;
    spinVel *= 0.90;
  } else if (!dragging) {
    spinVel = 0;
  }
  const ds = (spinWant - bodySpin) * 0.22;
  const dt = (tiltWant - bodyTilt) * 0.22;
  const dz = (zoomWant - zoomK) * 0.20;
  const moving = Math.abs(ds) > 0.00015 || Math.abs(dt) > 0.00015 ||
      Math.abs(dz) > 0.0004 || Math.abs(spinVel) > 0.0004;
  if (!moving) {
    bodySpin = spinWant; bodyTilt = tiltWant; zoomK = zoomWant;
    return false;
  }
  bodySpin += ds;
  bodyTilt += dt;
  zoomK += dz;
  applyBodySpin();
  return true;
}

let lastAmbient = 0;

let lastW = window.innerWidth, lastH = window.innerHeight;
function animate() {
  requestAnimationFrame(animate);
  // WebView เปลี่ยนขนาด (กรอบฉากบินระหว่างหน้าเตียง ↔ หน้าผู้ป่วย) บางครั้งไม่ยิง resize
  // เช็กเองทุกเฟรม (ถูกมาก) ไม่งั้นภาพค้างขนาดเดิม เหลือพื้นขาวครึ่งกรอบ
  if (window.innerWidth !== lastW || window.innerHeight !== lastH) {
    lastW = window.innerWidth; lastH = window.innerHeight;
    renderer.setSize(lastW, lastH);
    applyFrustum();
    renderer.shadowMap.needsUpdate = true;
    markDirty(4);
  }

  aimFollow();
  const before = currentPos.clone();
  currentPos.lerp(targetPos, 0.14);
  const topBefore = topMix;
  topMix += (topWant - topMix) * 0.085;
  if (Math.abs(topWant - topMix) < 0.0008) topMix = topWant;
  const camMoving = before.distanceToSquared(currentPos) > 1e-8 ||
      Math.abs(topMix - topBefore) > 1e-6;
  const waitMoving = stepWait();
  const bedsMoving = stepBeds() || waitMoving;
  const bodyMoving = stepBody();
  if (stepEnv()) markDirty(2);

  if (pin) {
    // ลำแสงตั้งบังตัวผู้ป่วยตอนมองจากบน ซ่อนไว้ เหลือวงแหวนที่พื้น
    pin.children[0].visible = topMix < 0.5;
    pin.children[1].rotation.z += 0.012;
    pin.children[0].material.opacity =
        0.18 + 0.07 * Math.sin(performance.now() / 500);
  }

  if (!dirty && !camMoving && !bedsMoving && !bodyMoving &&
      settleFrames <= 0 && !pin) {
    return;
  }
  // นิ่งแล้ว เหลือแค่แอนิเมชันบรรยากาศ (วงแหวนหมุด/เรืองแสงเต้น): วาด ~30 fps พอ
  // ลดงาน GPU ครึ่งหนึ่งตอนผู้ใช้อ่านหน้าจอเฉย ๆ
  const idle = !camMoving && !bedsMoving && !bodyMoving;
  const tNow = performance.now();
  // ~15 fps พอสำหรับเรืองแสงเต้น/วงแหวนหมุน: ทุกเฟรมของ WebView ทำให้ Flutter
  // ต้อง composite ใหม่ทั้งจอ (raster ~10 ms บนจอ 120 Hz) ลดเฟรมตรงนี้ = ลื่นทั้งแอป
  if (idle && settleFrames <= 1 && tNow - lastAmbient < 66) return;
  lastAmbient = tNow;
  if (idle) settleFrames -= 1;
  dirty = false;

  // ความละเอียดตามการขยับ: หมุน/ลาก/กล้องเคลื่อน = วาดที่ 0.85 (เบาลง ~half) ลื่นกว่า
  // นิ่งแล้ว = กลับความละเอียดเต็มแล้ววาดคมอีกครั้ง (ตาไม่ทันเห็นความต่างระหว่างหมุน)
  const want = (camMoving || bodyMoving || dragging) ? PR_MOVE : PR_FULL;
  if (renderer.getPixelRatio() !== want) {
    // setPixelRatio ปรับขนาด buffer ให้เอง (ไม่เปลี่ยนขนาดบนจอ)
    renderer.setPixelRatio(want);
  }

  frame();
  applyEnvFade();
  applyBodySwap();
  applyWaitFade();
  applyMonDetail();
  renderer.render(scene, camera);
  reportPositions(camMoving || bedsMoving || bodyMoving || topMix > 0.01);
}

window.addEventListener('resize', function () {
  renderer.setSize(window.innerWidth, window.innerHeight);
  applyFrustum();
  renderer.shadowMap.needsUpdate = true;
  markDirty(4);
});
</script>
</body>
</html>
''';
