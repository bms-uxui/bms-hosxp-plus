/// ฉากห้องฉุกเฉินสามมิติจริง ทำงานด้วย three.js ใน WebView
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

/// เตียงหนึ่งช่องในฉาก พร้อมสีที่จะใช้ไฮไลต์
class ErRoomBed {
  const ErRoomBed({
    required this.code,
    required this.color,
    this.vacant = false,
  });

  final String code;
  final Color color;
  final bool vacant;

  Map<String, dynamic> toJson() => {
        'code': code,
        // three.js รับสีเป็นเลขฐานสิบหก 0xRRGGBB
        'color': color.toARGB32() & 0x00FFFFFF,
        'vacant': vacant,
      };
}

/// ตำแหน่งบนจอของเตียงหนึ่งเตียง ฝั่งเว็บคำนวณให้ทุกครั้งที่กล้องขยับ
/// ใช้วางป้ายเตียงเป็นวิดเจ็ตของ Flutter ทับบนฉาก ตัวหนังสือจึงคมเสมอ
class ErBedScreenPos {
  const ErBedScreenPos(this.code, this.dx, this.dy, this.visible);

  final String code;
  final double dx;
  final double dy;
  final bool visible;
}

/// ค่ากล้องของฉาก ปรับได้ตอนรันเพื่อจูนมุมมอง
///
/// กล้องมองตรงเข้าหาเตียงที่เลือก เตียงข้างเคียงลู่ออกไปสองข้างตามระยะ
/// แบบเดียวกับภาพต้นแบบใน Figma
class ErCam {
  const ErCam({
    this.height = 3.0,
    this.distance = 6.42,
    this.fov = 40.0,
    this.yaw = 0.0,
    this.lookY = -0.45,
    this.tagLift = 0.02,
    this.shiftX = 0.0,
    this.shiftY = 0.0,
    this.bedTurn = 0.0,
    this.screenX = 0.0,
    this.iso = false,
    this.zoom = 4.2,
    this.pitch = 16.0,
  });

  /// ความสูงของกล้องจากพื้น (เมตร)
  final double height;

  /// ระยะห่างจากเตียงที่เลือก (เมตร)
  final double distance;

  /// มุมมองภาพ (องศา)
  final double fov;

  /// มุมเอียงด้านข้าง (องศา) 0 = มองตรงเข้าหาเตียง
  final double yaw;

  /// ความสูงของจุดที่กล้องเล็ง (เมตร)
  final double lookY;

  /// ระยะยกป้ายเตียงเหนือหัวเตียง (เมตร)
  final double tagLift;

  /// เลื่อนกล้องตามแนวนอน (เมตร) ใช้ดันเตียงที่เลือกให้พ้นแผงที่ลอยทับอยู่
  final double shiftX;

  /// เลื่อนฉากขึ้นลง (เมตร)
  final double shiftY;

  /// true = ฉากแบบ isometric (กล้อง orthographic), false = เพอร์สเปกทีฟ
  final bool iso;

  /// ความสูงของกรอบภาพตอนเป็น isometric (เมตร) ค่าน้อย = ซูมเข้า
  final double zoom;

  /// มุมก้มตอนเป็น isometric (องศา)
  final double pitch;

  /// หมุนตัวเตียงเทียบกับกล้อง (องศา) 90 = หัวเตียงหันไปทางแถบเมนู
  final double bedTurn;

  /// เลื่อนภาพทั้งฉากตามแนวนอนบนจอ (พิกเซล) ค่าบวก = เตียงไปอยู่ทางซ้าย
  final double screenX;

  ErCam copyWith({
    double? height,
    double? distance,
    double? fov,
    double? yaw,
    double? lookY,
    double? tagLift,
    double? shiftX,
    double? shiftY,
    bool? iso,
    double? zoom,
    double? pitch,
    double? bedTurn,
    double? screenX,
  }) =>
      ErCam(
        height: height ?? this.height,
        distance: distance ?? this.distance,
        fov: fov ?? this.fov,
        yaw: yaw ?? this.yaw,
        lookY: lookY ?? this.lookY,
        tagLift: tagLift ?? this.tagLift,
        shiftX: shiftX ?? this.shiftX,
        shiftY: shiftY ?? this.shiftY,
        iso: iso ?? this.iso,
        zoom: zoom ?? this.zoom,
        pitch: pitch ?? this.pitch,
        bedTurn: bedTurn ?? this.bedTurn,
        screenX: screenX ?? this.screenX,
      );

  String get js => '{height:$height,distance:$distance,fov:$fov,'
      'yaw:$yaw,lookY:$lookY,tagLift:$tagLift,shiftX:$shiftX,'
      'shiftY:$shiftY,iso:$iso,zoom:$zoom,pitch:$pitch,bedTurn:$bedTurn,'
      'screenX:$screenX}';
}

class ErRoom3D extends StatefulWidget {
  const ErRoom3D({
    super.key,
    required this.beds,
    required this.selectedCode,
    this.cam = const ErCam(),
    this.onBedTap,
    this.onPositions,
  });

  final List<ErRoomBed> beds;
  final String selectedCode;
  final ErCam cam;
  final ValueChanged<String>? onBedTap;
  final ValueChanged<List<ErBedScreenPos>>? onPositions;

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
    if (!listEquals(old.beds.map((b) => b.code).toList(),
        widget.beds.map((b) => b.code).toList())) {
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
        break;
      case 'tap':
        widget.onBedTap?.call(data['code'] as String);
        break;
      case 'error':
        debugPrint('ErRoom3D ผิดพลาด: ${data['message']}');
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
      };
      final entry = assets[path];
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
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
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

let lastBedAngle = null;

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
  camera.lookAt(target);
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

window.erSetBeds = function (list) {
  markDirty(8);
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
    const p = new THREE.Box3().setFromObject(bed).getCenter(new THREE.Vector3());
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
  const box = new THREE.Box3().setFromObject(bed);
  const p = box.getCenter(new THREE.Vector3());
  const color = (glows[code] && glows[code].material.color.getHex()) || 0x2397ff;
  ensurePin(color).position.set(p.x, floorY + 0.01, p.z);
  targetPos.set(p.x, 0, p.z);
};

// ---------------------------------------------------------------- แตะเลือก
const ray = new THREE.Raycaster();
const ndc = new THREE.Vector2();
let downAt = null;

renderer.domElement.addEventListener('pointerdown', function (e) {
  downAt = { x: e.clientX, y: e.clientY };
});

renderer.domElement.addEventListener('pointerup', function (e) {
  if (!downAt) return;
  const moved = Math.abs(e.clientX - downAt.x) + Math.abs(e.clientY - downAt.y);
  downAt = null;
  if (moved > 12) return;           // ลากจอ ไม่ใช่การแตะเลือก
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

// ลากนิ้วเพื่อเลื่อนดูห้องเอง
let dragX = null;
renderer.domElement.addEventListener('pointermove', function (e) {
  if (e.buttons === 0) { dragX = null; return; }
  if (dragX === null) { dragX = e.clientX; return; }
  const dx = (e.clientX - dragX) / window.innerWidth * 6;
  dragX = e.clientX;
  if (!rowDir) return;
  targetPos.addScaledVector(rowDir, -dx);
  markDirty(20);
});

// ------------------------------------------------- ส่งตำแหน่งเตียงบนจอกลับแอป
let lastSent = 0;
function reportPositions(moving) {
  const now = performance.now();
  // ขยับอยู่ส่งถี่หน่อย นิ่งแล้วส่งนาน ๆ ครั้งพอ ลดงานฝั่ง Flutter
  if (now - lastSent < (moving ? 70 : 400)) return;
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
  send({ type: 'positions', items: items });
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

    const wantOpacity = on ? 1.0 : 0.32;
    const mats = b.userData.mats || [];
    for (let m = 0; m < mats.length; m++) {
      const mat = mats[m];
      if (mat.opacity === undefined) continue;
      if (!mat.transparent) mat.transparent = true;
      mat.depthWrite = on;
      const o = mat.opacity + (wantOpacity - mat.opacity) * 0.18;
      if (Math.abs(o - wantOpacity) > 0.004) moving = true;
      mat.opacity = o;
    }
  }
  return moving;
}

function animate() {
  requestAnimationFrame(animate);

  const before = currentPos.clone();
  currentPos.lerp(targetPos, 0.14);
  const camMoving = before.distanceToSquared(currentPos) > 1e-8;
  const bedsMoving = stepBeds();

  if (pin) {
    pin.children[1].rotation.z += 0.012;
    pin.children[0].material.opacity =
        0.18 + 0.07 * Math.sin(performance.now() / 500);
  }

  if (!dirty && !camMoving && !bedsMoving && settleFrames <= 0 && !pin) return;
  if (!camMoving && !bedsMoving) settleFrames -= 1;
  dirty = false;

  frame();
  renderer.render(scene, camera);
  reportPositions(camMoving || bedsMoving);
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
