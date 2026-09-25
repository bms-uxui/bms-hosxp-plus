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
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

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
  });

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

class _ErRoom3DState extends State<ErRoom3D> {
  WebViewController? _web;
  HttpServer? _server;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
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
    _server?.close(force: true);
    super.dispose();
  }

  Future<void> _boot() async {
    final server = await _startServer();
    if (!mounted) return;
    _server = server;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('ErRoom', onMessageReceived: _onMessage)
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    setState(() => _web = controller);
  }

  void _onMessage(JavaScriptMessage message) {
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
        _pushDark();
        _pushBg();
        if (widget.zoomTick > 0) _pushZoom();
        _pushPick();
        break;
      case 'bodyPick':
        widget.onBodyPick?.call(data['bone'] as String);
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

  void _pushBeds() {
    if (!_ready || _web == null) return;
    final payload = jsonEncode(widget.beds.map((b) => b.toJson()).toList());
    _web!.runJavaScript('window.erSetBeds($payload)');
  }

  void _pushCam() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript('window.erSetCam(${widget.cam.js})');
  }

  void _pushView() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript('window.erSetView(${widget.topView})');
  }

  void _pushLayer() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript("window.erSetLayer('${widget.layer}')");
  }

  void _pushDark() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript('window.erSetDark && window.erSetDark(${widget.dark})');
  }

  void _pushBg() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript(
        'window.erSetPageBg && window.erSetPageBg(${widget.pageBg})');
  }

  void _pushZoom() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript('window.erSetZoom && window.erSetZoom(${widget.zoom})');
  }

  void _pushPick() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript(
        'window.erPickMode && window.erPickMode(${widget.pickMode})');
  }

  void _pushHighlight() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript('window.erHighlight(${jsonEncode(widget.highlight)})');
  }

  void _pushSelection() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript("window.erSelect('${widget.selectedCode}')");
  }

  /// เสิร์ฟไฟล์ฉากและไลบรารีจาก asset ให้ WebView บนเครื่องเท่านั้น
  Future<HttpServer> _startServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      String path = req.uri.path;
      if (path == '/' || path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
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
      final bytes = await rootBundle.load(entry[0]);
      req.response.headers.set('content-type', entry[1]);
      req.response.add(bytes.buffer.asUint8List());
      await req.response.close();
    });
    return server;
  }

  @override
  Widget build(BuildContext context) {
    if (_web == null) return const SizedBox.shrink();
    return WebViewWidget(controller: _web!);
  }
}

const String _html = r'''
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
<style>
  html, body { margin:0; height:100%; overflow:hidden; background:#EEF2F7; }
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
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.25));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.outputEncoding = THREE.sRGBEncoding;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
// ในฉากนี้ไม่มีอะไรเคลื่อนที่ เงาจึงคำนวณครั้งเดียวพอ
renderer.shadowMap.autoUpdate = false;
renderer.toneMappingExposure = 1.0;
document.body.appendChild(renderer.domElement);

scene.add(new THREE.HemisphereLight(0xfff0dc, 0x6b7c8c, 0.55));
const key = new THREE.DirectionalLight(0xffe6c2, 1.5);
key.position.set(3.5, 6.5, 3.0);
key.castShadow = true;
key.shadow.mapSize.set(1024, 1024);
key.shadow.camera.near = 0.5;
key.shadow.camera.far = 60;
key.shadow.camera.left = -14;
key.shadow.camera.right = 14;
key.shadow.camera.top = 10;
key.shadow.camera.bottom = -10;
key.shadow.bias = -0.0006;
key.shadow.normalBias = 0.02;
scene.add(key);
// ไฟเสริมจากอีกฝั่ง ลดเงาทึบเกินไป
const fill = new THREE.DirectionalLight(0xdce8f5, 0.35);
fill.position.set(-4, 3, 4);
scene.add(fill);

// ---------------------------------------------------------------- วัสดุ
// โมเดลห้องมี texture ของตัวเองมาแล้ว จึงไม่สร้างพื้นผิวเพิ่มให้เปลืองหน่วยความจำ
function dressMaterials(root) {
  root.traverse(function (m) {
    if (!m.isMesh || !m.material) return;
    m.castShadow = true;
    m.receiveShadow = true;
    const mats = Array.isArray(m.material) ? m.material : [m.material];
    mats.forEach(function (mat) {
      mat.side = THREE.DoubleSide;
      if (mat.roughness !== undefined && mat.roughness > 0.95) {
        mat.roughness = 0.8;
      }
    });
  });
}

const envMats = [];       // วัสดุของห้อง ไว้จางตอนโชว์เฉพาะผู้ป่วย
const beds = {};          // รหัสเตียง -> object3D
const glows = {};         // รหัสเตียง -> วงไฟที่พื้น
let order = [];           // ลำดับเตียงตามข้อมูลที่ส่งมาจากแอป
let selected = null;
let roomHalfWidth = 4;
let rowDir = null;        // ทิศทางของแนวเตียง ใช้ตอนลากนิ้วเลื่อนดู

function send(payload) {
  if (window.ErRoom) window.ErRoom.postMessage(JSON.stringify(payload));
}

// ---------------------------------------------------------------- โหลดฉาก
new THREE.GLTFLoader().load('er_room.glb', function (gltf) {
  const root = gltf.scene;
  scene.add(root);
  // ชื่อโหนดจาก Blender อาจมีเลขต่อท้าย เช่น bed_A1_0 จึงตัดออกก่อนใช้เป็นรหัส
  root.traverse(function (o) {
    if (o.name && o.name.indexOf('bed_') === 0) {
      const code = o.name.slice(4).replace(/_\d+$/, '');
      if (!beds[code]) {
        beds[code] = o;
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
// ระดับการจางของห้องกับเตียง เริ่มจางหลังกล้องออกตัวไปแล้วสักพัก
// เข้าหน้ารายละเอียดจึงเห็นกล้องลอยขึ้นก่อน แล้วห้องค่อยละลายหายไปเหลือแต่ผู้ป่วย
function envFade() {
  const t = Math.min(1, Math.max(0, (topMix - 0.25) / 0.6));
  return t * t * (3 - 2 * t);
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
  mat.onBeforeCompile = function (sh) {
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
      const pulse = 0.35 + 0.35 * (0.5 + 0.5 * Math.sin(performance.now() / 420));
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
  const t = 0.5 + 0.5 * Math.sin(performance.now() / 520);
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
    const jointLocal = function (n) {
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
function applyBodySwap() {
  const detail = envFade() > 0.55;
  if (detail) {
    ensureBody(selected, femaleOf(selected));
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
  if (detail) applyLayer();
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
      fig.name = 'figure_' + code;
      // ผูกเข้ากับเตียง เตียงที่เลือกมีอนิเมชันขยาย/ยก หุ่นจะได้ขยับตาม
      scene.add(fig);
      bed.attach(fig);

      figures[code] = fig;
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
    ensureFigure(b.code, female);
  });
  Object.keys(figures).forEach(function (code) {
    if (!occupied[code]) removeFigure(code);
  });
  order = list.map(function (b) { return b.code; });
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

// เครื่องหมายชี้เตียงที่กำลังดู: ลำแสงตั้งขึ้นจากพื้น + วงแหวนรอบเตียง
let pin = null;
function ensurePin(color) {
  if (pin) { scene.remove(pin); pin = null; }
  pin = new THREE.Group();
  const beam = new THREE.Mesh(
    new THREE.CylinderGeometry(0.05, 0.22, 2.6, 24, 1, true),
    new THREE.MeshBasicMaterial({
      color: color, transparent: true, opacity: 0.22,
      side: THREE.DoubleSide, depthWrite: false,
    })
  );
  beam.position.y = 1.3;
  const ring = new THREE.Mesh(
    new THREE.RingGeometry(0.62, 0.78, 48),
    new THREE.MeshBasicMaterial({
      color: color, transparent: true, opacity: 0.85,
      side: THREE.DoubleSide, depthWrite: false,
    })
  );
  ring.rotation.x = -Math.PI / 2;
  ring.position.y = 0.02;
  pin.add(beam);
  pin.add(ring);
  scene.add(pin);
  return pin;
}

window.erSelect = function (code) {
  selected = code;
  markDirty(180);
  Object.keys(glows).forEach(function (c) {
    glows[c].visible = (c === code);
  });
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
};

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
});

function dropPointer(e) {
  pointers.delete(e.pointerId);
  if (pointers.size === 0) dragging = false;
  if (pointers.size < 2) pinchBase = null;
  if (pointers.size === 0) { dragX = null; dragY = null; }
}
renderer.domElement.addEventListener('pointercancel', dropPointer);
renderer.domElement.addEventListener('pointerleave', dropPointer);

renderer.domElement.addEventListener('pointerup', function (e) {
  dropPointer(e);
  if (!downAt) return;
  const moved = Math.abs(e.clientX - downAt.x) + Math.abs(e.clientY - downAt.y);
  downAt = null;
  if (moved > 12) {                 // ลากจอ ไม่ใช่การแตะเลือก
    // ปล่อยนิ้วแล้วดูดเข้าเตียงที่มีผู้ป่วยใกล้สุด กล้องจะได้ไม่ค้างระหว่างเตียง
    if (!detailMode()) snapToNearestBed();
    return;
  }
  // โหมดระบุตำแหน่ง: แตะบนตัวหุ่น = ปักหมุดแผล แล้วบอกแอปว่าโดนส่วนไหน
  if (detailMode() && pickMode && pickBody(e)) return;
  // แตะสองครั้งเร็ว ๆ ในโหมดรายละเอียด = คืนมุมมองเป็นค่าตั้งต้น
  if (detailMode()) {
    const now = performance.now();
    if (now - lastTap < 320) {
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
  const dx = (dxPix / window.innerWidth) * 6;
  if (!rowDir) return;
  targetPos.addScaledVector(rowDir, -dx);
  markDirty(20);
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
    send({ type: 'positions', items: items, hotspots: hotspots });
    return;
  }
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
  // เรืองแสงเต้นเป็นจังหวะต้องวาดต่อเนื่อง
  if ((hiSet.size > 0 || boneHi.size > 0 || zoneHi.size > 0) && detailMode()) markDirty(1);
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

function animate() {
  requestAnimationFrame(animate);

  const before = currentPos.clone();
  currentPos.lerp(targetPos, 0.14);
  const topBefore = topMix;
  topMix += (topWant - topMix) * 0.085;
  if (Math.abs(topWant - topMix) < 0.0008) topMix = topWant;
  const camMoving = before.distanceToSquared(currentPos) > 1e-8 ||
      Math.abs(topMix - topBefore) > 1e-6;
  const bedsMoving = stepBeds();
  const bodyMoving = stepBody();

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

  frame();
  applyEnvFade();
  applyBodySwap();
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
