/// ฉากแท่นสามมิติของหน้าภาพรวม — แท่นสี่ขั้นสลับฟันปลาไล่ระดับ
///
/// ปั้นด้วยโค้ดใน three.js ทั้งหมด ไม่ต้องโหลดโมเดล จึงเบาและเปลี่ยน
/// ความสูง/สีตามข้อมูลได้ทันที รูปทรงอิงแบบใน Figma node 96-1343
/// แท่นเป็นบล็อกหนาสีฟ้าอ่อน ผิวบนสว่างกว่าด้านข้าง มีทางลาดเชื่อมแต่ละขั้น
///
/// ใช้ API ชุดเดียวกับ [ErFlow3D] เพื่อสลับฉากได้โดยไม่ต้องแก้หน้าเรียก
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'er_flow_3d_types.dart';

/// หนึ่งแท่นในฉาก
class ErPlatform {
  const ErPlatform({
    required this.key,
    required this.color,
    required this.value,
    this.alert = false,
  });

  /// รหัสขั้น ใช้ผูกกับป้ายฝั่ง Flutter
  final String key;

  /// สีประจำขั้น ใช้ย้อมผิวบนของแท่น
  final Color color;

  /// จำนวนคนในขั้นนี้ ใช้กำหนดความหนาของแท่น
  final int value;

  /// ขั้นที่มีคนค้างเกินเกณฑ์ ขอบแท่นจะเป็นสีเตือน
  final bool alert;

  String get _hex =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  Map<String, dynamic> toJson() =>
      {'key': key, 'color': _hex, 'value': value, 'alert': alert};
}

class ErPlatform3D extends StatefulWidget {
  const ErPlatform3D({
    super.key,
    required this.platforms,
    required this.cam,
    this.highlight,
    this.onStageTap,
    this.onPositions,
  });

  /// แท่นทั้งหมด เรียงตามลำดับของกระแสงาน
  final List<ErPlatform> platforms;

  final ErFlowCam cam;

  /// ขั้นที่เลือกอยู่ ขั้นอื่นจะจางลง รับหลายคีย์คั่นด้วยจุลภาคได้
  final String? highlight;

  final void Function(String key)? onStageTap;
  final void Function(List<ErFlowStagePos> positions)? onPositions;

  @override
  State<ErPlatform3D> createState() => _ErPlatform3DState();
}

class _ErPlatform3DState extends State<ErPlatform3D> {
  WebViewController? _web;
  HttpServer? _server;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void didUpdateWidget(covariant ErPlatform3D old) {
    super.didUpdateWidget(old);
    if (old.cam.js != widget.cam.js) {
      _push('window.platSetCam(${widget.cam.js})');
    }
    if (old.highlight != widget.highlight) _pushHighlight();
    if (_encoded(old.platforms) != _encoded(widget.platforms)) _pushData();
  }

  String _encoded(List<ErPlatform> list) =>
      jsonEncode([for (final p in list) p.toJson()]);

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
      ..addJavaScriptChannel('ErPlat', onMessageReceived: _onMessage)
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    setState(() => _web = controller);
  }

  void _push(String js) {
    if (!_ready || _web == null) return;
    _web!.runJavaScript(js);
  }

  void _pushData() => _push('window.platSet(${_encoded(widget.platforms)})');

  void _pushHighlight() =>
      _push("window.platHighlight('${widget.highlight ?? ''}')");

  void _onMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        _ready = true;
        _pushData();
        _push('window.platSetCam(${widget.cam.js})');
        _pushHighlight();
        break;
      case 'tap':
        widget.onStageTap?.call(data['key'] as String);
        break;
      case 'error':
        debugPrint('ErPlatform3D ผิดพลาด: ${data['message']}');
        break;
      case 'positions':
        final list = (data['items'] as List)
            .map((e) => ErFlowStagePos(
                  e['key'] as String,
                  (e['x'] as num).toDouble(),
                  (e['y'] as num).toDouble(),
                  e['visible'] as bool,
                ))
            .toList();
        widget.onPositions?.call(list);
        break;
    }
  }

  /// เสิร์ฟหน้าฉากให้ WebView เฉพาะบนเครื่อง ไม่มีไฟล์โมเดลให้โหลด
  Future<HttpServer> _startServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path == '/' || req.uri.path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
        req.response.write(_html);
        await req.response.close();
        return;
      }
      if (req.uri.path == '/three.min.js') {
        final bytes = await DefaultAssetBundle.of(context)
            .load('assets/web/three.min.js');
        req.response.headers.set('content-type', 'application/javascript');
        req.response.add(bytes.buffer.asUint8List());
        await req.response.close();
        return;
      }
      req.response.statusCode = HttpStatus.notFound;
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
  html, body { margin:0; height:100%; overflow:hidden; background:#F8F9FA; }
  canvas { display:block; touch-action:none; }
</style>
<script src="three.min.js"></script>
</head>
<body>
<script>
function send(o) { try { ErPlat.postMessage(JSON.stringify(o)); } catch (e) {} }
window.onerror = function (m) { send({type:'error', message:String(m)}); };

const scene = new THREE.Scene();
scene.background = new THREE.Color(0xF8F9FA);

// กล้อง orthographic เท่านั้น เส้นขนานจึงไม่ลู่ ได้ isometric จริง
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 400);
let cam = { zoom: 13, yaw: 45, pitch: 35.264, shiftX: 0, shiftY: 0 };
let target = new THREE.Vector3(0, 0, 0);
let autoZoom = 0;

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.outputEncoding = THREE.sRGBEncoding;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.shadowMap.autoUpdate = false;
document.body.appendChild(renderer.domElement);

// แสงนุ่มแบบสตูดิโอ ให้ผิวบนสว่างกว่าด้านข้างชัด ๆ ตามภาพต้นแบบ
scene.add(new THREE.HemisphereLight(0xffffff, 0xb9c8de, 0.45));
const key = new THREE.DirectionalLight(0xffffff, 0.65);
key.position.set(9, 16, 7);
key.castShadow = true;
key.shadow.mapSize.set(1024, 1024);
key.shadow.camera.near = 1;
key.shadow.camera.far = 80;
key.shadow.camera.left = -22;
key.shadow.camera.right = 22;
key.shadow.camera.top = 18;
key.shadow.camera.bottom = -18;
key.shadow.bias = -0.0009;
scene.add(key);
const fill = new THREE.DirectionalLight(0xdbe6f8, 0.18);
fill.position.set(-9, 7, -5);
scene.add(fill);

// พื้นรับเงา ให้แท่นดูวางอยู่บนอะไรสักอย่าง ไม่ลอยเท้งเต้ง
(function floor() {
  const f = new THREE.Mesh(
    new THREE.PlaneGeometry(90, 90),
    new THREE.ShadowMaterial({ opacity: 0.09 })
  );
  f.rotation.x = -Math.PI / 2;
  f.position.y = -0.01;
  f.receiveShadow = true;
  scene.add(f);
})();

// ---------------------------------------------------------------- รูปทรง
// แท่นสามชั้นวางสลับฟันปลาไล่ระดับ อิงรูปทรงจากโมเดล Meshy และแบบใน Figma
// ชั้นบนสุดอยู่หลังขวา ชั้นกลางเยื้องมาหน้าซ้าย ชั้นล่างสุดกลับไปหน้าขวา
// ทุกชั้นวางบนฐานเดียวกัน ผนังข้างของชั้นบนจึงสูงกว่า เห็นเป็นขั้นบันไดตัน
const BASE_Y = -3.2;   // ระดับฐานร่วมของทุกชั้น
const BEVEL = 0.22;    // ลบมุมขอบแท่น ให้ขอบรับแสงเป็นเส้นบาง ๆ

// แต่ละชั้น: ขอบเขตบนระนาบพื้น (x0,z0)-(x1,z1) และระดับผิวบน
const TIERS = [
  { x0: 1.5,  z0: -13.0, x1: 14.5, z1: -4.5, top: 5.6 },
  { x0: -6.5, z0: -4.5,  x1: 7.5,  z1: 4.5,  top: 2.8 },
  { x0: 1.5,  z0: 4.5,   x1: 15.5, z1: 13.0, top: 0.0 },
];

const root = new THREE.Group();
scene.add(root);

const stages = {};   // key -> { meshes, mats, anchor, box }
let highlight = '';
let dirty = true;

/// วัสดุของแท่นหนึ่งชั้น
///
/// ExtrudeGeometry แบ่งกลุ่มหน้าเป็นสองชุด ชุดแรกคือฝาบน-ล่าง ชุดที่สองคือผนังข้าง
/// จึงย้อมฝาบนให้ฟ้าเข้มกว่าผนัง ได้ภาพแบบเดียวกับต้นแบบ
function tierMaterials(hex) {
  const cap = new THREE.MeshStandardMaterial({
    color: new THREE.Color(0x9FC0F8).lerp(new THREE.Color(hex), 0.14),
    roughness: 0.45,
    metalness: 0.0,
  });
  const wall = new THREE.MeshStandardMaterial({
    color: new THREE.Color(0xE4EDFD),
    roughness: 0.68,
    metalness: 0.0,
  });
  return [cap, wall];
}

/// สร้างแท่นหนึ่งชั้นจากรูปสี่เหลี่ยมบนพื้น แล้วดันขึ้นเป็นก้อนหนา
function buildTier(t, hex) {
  // Shape อยู่บนระนาบ XY เมื่อหมุน -90 รอบแกน X แกน Y ของรูปจะกลายเป็น -Z
  // จึงป้อนพิกัดเป็น (x, -z) เพื่อให้ได้ขอบเขตตามที่กำหนดไว้ด้านบน
  const shape = new THREE.Shape();
  shape.moveTo(t.x0, -t.z0);
  shape.lineTo(t.x1, -t.z0);
  shape.lineTo(t.x1, -t.z1);
  shape.lineTo(t.x0, -t.z1);
  shape.closePath();

  const thick = t.top - BASE_Y;
  const geo = new THREE.ExtrudeGeometry(shape, {
    depth: thick - BEVEL * 2,
    bevelEnabled: true,
    bevelThickness: BEVEL,
    bevelSize: BEVEL,
    bevelSegments: 2,
    curveSegments: 1,
  });
  geo.rotateX(-Math.PI / 2);
  geo.translate(0, BASE_Y + BEVEL, 0);

  const mats = tierMaterials(hex);
  const mesh = new THREE.Mesh(geo, mats);
  mesh.castShadow = true;
  mesh.receiveShadow = true;
  return { mesh: mesh, mats: mats };
}

function clearScene() {
  Object.keys(stages).forEach(function (k) { delete stages[k]; });
  while (root.children.length) {
    const c = root.children.pop();
    c.traverse(function (o) {
      if (o.geometry) o.geometry.dispose();
      if (o.material) {
        const mm = Array.isArray(o.material) ? o.material : [o.material];
        mm.forEach(function (m) { m.dispose(); });
      }
    });
  }
}

/// สร้างแท่นทั้งชุดจากข้อมูลที่ฝั่ง Flutter ส่งมา
/// จำนวนชั้นยึดตาม TIERS ถ้าข้อมูลมาเกินจะใช้แค่สามชั้นแรก
window.platSet = function (items) {
  clearScene();
  items.slice(0, TIERS.length).forEach(function (p, i) {
    const t = TIERS[i];
    const built = buildTier(t, p.color);
    built.mesh.userData.stageKey = p.key;
    root.add(built.mesh);

    // เส้นขอบบาง ๆ ช่วยให้เห็นรอยต่อระหว่างชั้นตอนแท่นจาง
    const edge = new THREE.LineSegments(
      new THREE.EdgesGeometry(built.mesh.geometry, 35),
      new THREE.LineBasicMaterial({
        color: 0x86ACF0, transparent: true, opacity: 0.35,
      })
    );
    edge.userData.stageKey = p.key;
    root.add(edge);

    const box = new THREE.Box3().setFromObject(built.mesh);
    stages[p.key] = {
      meshes: [built.mesh, edge],
      mats: built.mats.concat([edge.material]),
      anchor: new THREE.Vector3(
        (t.x0 + t.x1) / 2, t.top, (t.z0 + t.z1) / 2),
      box: box,
    };
  });

  const all = new THREE.Box3();
  Object.keys(stages).forEach(function (k) { all.union(stages[k].box); });
  if (!all.isEmpty()) {
    target = all.getCenter(new THREE.Vector3());
    const size = all.getSize(new THREE.Vector3());
    const aspect = window.innerWidth / Math.max(window.innerHeight, 1);
    const spread = (size.x + size.z) * Math.SQRT1_2;
    autoZoom = Math.max(spread / Math.max(aspect, 0.1),
        size.y + spread * 0.55) * 1.18;
  }
  applyCam();
  window.platHighlight(highlight);
  renderer.shadowMap.needsUpdate = true;
  lastSent = 0;
  dirty = true;
};

// ---------------------------------------------------------------- กล้อง
function applyCam() {
  const aspect = window.innerWidth / Math.max(window.innerHeight, 1);
  const h = autoZoom > 0 ? autoZoom : cam.zoom;
  camera.left = -h * aspect / 2;
  camera.right = h * aspect / 2;
  camera.top = h / 2;
  camera.bottom = -h / 2;
  camera.updateProjectionMatrix();

  const yaw = cam.yaw * Math.PI / 180;
  const pitch = cam.pitch * Math.PI / 180;
  const d = 90;
  camera.position.set(
    target.x + d * Math.cos(pitch) * Math.sin(yaw),
    target.y + d * Math.sin(pitch),
    target.z + d * Math.cos(pitch) * Math.cos(yaw)
  );
  camera.lookAt(target);
  const right = new THREE.Vector3();
  const up = new THREE.Vector3();
  camera.matrixWorld.extractBasis(right, up, new THREE.Vector3());
  camera.position.addScaledVector(right, -cam.shiftX);
  camera.position.addScaledVector(up, -cam.shiftY);
  camera.updateMatrixWorld();
  dirty = true;
}

window.platSetCam = function (c) {
  cam = Object.assign(cam, c);
  applyCam();
};

window.platHighlight = function (k) {
  highlight = k || '';
  const keys = highlight.split(',').filter(function (s) { return s; });
  Object.keys(stages).forEach(function (key) {
    const on = keys.length === 0 || keys.indexOf(key) >= 0;
    stages[key].mats.forEach(function (mat) {
      const line = mat.isLineBasicMaterial;
      mat.transparent = !on || line;
      mat.opacity = on ? (line ? 0.38 : 1.0) : 0.3;
    });
  });
  dirty = true;
};

// ---------------------------------------------------------------- แตะเลือก
const ray = new THREE.Raycaster();
const ndc = new THREE.Vector2();
renderer.domElement.addEventListener('pointerdown', function (e) {
  ndc.x = (e.clientX / window.innerWidth) * 2 - 1;
  ndc.y = -(e.clientY / window.innerHeight) * 2 + 1;
  ray.setFromCamera(ndc, camera);
  const hits = ray.intersectObjects(root.children, true);
  for (let i = 0; i < hits.length; i++) {
    const k = hits[i].object.userData && hits[i].object.userData.stageKey;
    if (k) { send({ type: 'tap', key: k }); return; }
  }
});

// ---------------------------------------------------------------- ส่งตำแหน่ง
let lastSent = 0;
function reportPositions() {
  const now = performance.now();
  if (now - lastSent < 250) return;
  lastSent = now;
  const items = [];
  const v = new THREE.Vector3();
  Object.keys(stages).forEach(function (k) {
    v.copy(stages[k].anchor).project(camera);
    items.push({
      key: k,
      x: (v.x * 0.5 + 0.5) * window.innerWidth,
      y: (-v.y * 0.5 + 0.5) * window.innerHeight,
      visible: v.z > -1 && v.z < 1,
    });
  });
  if (items.length) send({ type: 'positions', items: items });
}

window.addEventListener('resize', function () {
  renderer.setSize(window.innerWidth, window.innerHeight);
  applyCam();
});

applyCam();
function animate() {
  requestAnimationFrame(animate);
  if (!dirty) return;
  dirty = false;
  renderer.render(scene, camera);
  reportPositions();
}
animate();
send({ type: 'ready' });
</script>
</body>
</html>
''';
