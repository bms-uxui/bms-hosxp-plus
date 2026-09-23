/// ฉากสามมิติของหน้าภาพรวม ER — แท่นสี่ขั้นบนพื้นกริด isometric
///
/// โหลด assets/models/er_flow.glb ซึ่งมีแท่นชื่อ plate_<ขั้น> และของประกอบ
/// ชื่อ prop_<ขั้น>_<ชื่อของ> ฝั่งเว็บจับกลุ่มตามชื่อ แล้วส่งตำแหน่งบนจอ
/// ของแต่ละขั้นกลับมาให้ Flutter วางตัวเลขและป้ายทับได้ตรงตำแหน่ง
///
/// พื้นกริดวาดในฉากเป็นเส้นจริง ไม่ใช่ลายที่วาดทับบนจอ เมื่อกล้องเป็น
/// orthographic มุม isometric เส้นกริดจึงเอียงตามฉากโดยอัตโนมัติ
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'er_flow_3d_types.dart';

class ErFlow3D extends StatefulWidget {
  const ErFlow3D({
    super.key,
    required this.stages,
    required this.cam,
    this.model = 'assets/models/er_flow.glb',
    this.highlight,
    this.onStageTap,
    this.onPositions,
  });

  /// รหัสขั้นที่ต้องแสดง เรียงตามลำดับของกระแสงาน
  final List<String> stages;

  final ErFlowCam cam;

  /// ไฟล์ฉากที่จะโหลด ใช้สลับระหว่างฉากกระแสงานกับผังห้องได้
  final String model;

  /// ขั้นที่เป็นคอขวด จะถูกเน้นในฉาก
  final String? highlight;

  final void Function(String key)? onStageTap;
  final void Function(List<ErFlowStagePos> positions)? onPositions;

  @override
  State<ErFlow3D> createState() => _ErFlow3DState();
}

class _ErFlow3DState extends State<ErFlow3D> {
  WebViewController? _web;
  HttpServer? _server;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void didUpdateWidget(covariant ErFlow3D old) {
    super.didUpdateWidget(old);
    if (old.cam.js != widget.cam.js)
      _push('window.flowSetCam(${widget.cam.js})');
    if (old.highlight != widget.highlight) _pushHighlight();
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
      ..addJavaScriptChannel('ErFlow', onMessageReceived: _onMessage)
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    setState(() => _web = controller);
  }

  void _push(String js) {
    if (!_ready || _web == null) return;
    _web!.runJavaScript(js);
  }

  void _pushHighlight() =>
      _push("window.flowHighlight('${widget.highlight ?? ''}')");

  void _onMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        _ready = true;
        debugPrint('ErFlow3D พร้อม ขั้นในฉาก: ${data['stages']}');
        _push('window.flowSetCam(${widget.cam.js})');
        _pushHighlight();
        break;
      case 'tap':
        widget.onStageTap?.call(data['key'] as String);
        break;
      case 'error':
        debugPrint('ErFlow3D ผิดพลาด: ${data['message']}');
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

  /// เสิร์ฟไฟล์ฉากจาก asset ให้ WebView เฉพาะบนเครื่อง
  Future<HttpServer> _startServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final path = req.uri.path;
      if (path == '/' || path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
        req.response.write(_html);
        await req.response.close();
        return;
      }
      final assets = {
        '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
        '/GLTFLoader.js': [
          'assets/web/GLTFLoader.js',
          'application/javascript'
        ],
        '/scene.glb': [widget.model, 'model/gltf-binary'],
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
  html, body { margin:0; height:100%; overflow:hidden; background:#F8F9FA; }
  canvas { display:block; touch-action:none; }
</style>
<script src="three.min.js"></script>
<script src="GLTFLoader.js"></script>
</head>
<body>
<script>
function send(o) { try { ErFlow.postMessage(JSON.stringify(o)); } catch (e) {} }
window.onerror = function (m) { send({type:'error', message:String(m)}); };

const scene = new THREE.Scene();
scene.background = new THREE.Color(0xF8F9FA);

// กล้อง orthographic เท่านั้น เส้นขนานจะไม่ลู่ ได้ภาพ isometric จริง
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 400);
let cam = { zoom: 13, yaw: 45, pitch: 35.264, shiftX: 0, shiftY: 0 };
// จุดที่กล้องเล็ง กับขนาดฉาก คำนวณหลังโหลดไฟล์เสร็จ
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

scene.add(new THREE.HemisphereLight(0xffffff, 0x9fb2ce, 0.55));
const key = new THREE.DirectionalLight(0xffffff, 0.95);
key.position.set(8, 12, 6);
key.castShadow = true;
key.shadow.mapSize.set(1024, 1024);
key.shadow.camera.near = 1;
key.shadow.camera.far = 60;
key.shadow.camera.left = -18;
key.shadow.camera.right = 18;
key.shadow.camera.top = 14;
key.shadow.camera.bottom = -14;
key.shadow.bias = -0.0008;
scene.add(key);
const fill = new THREE.DirectionalLight(0xeef2f7, 0.35);
fill.position.set(-8, 6, -4);
scene.add(fill);

// ---------------------------------------------------------------- พื้นกริด
// เส้นกริดเป็นวัตถุจริงในฉาก จึงเอียงตามมุมกล้องเองโดยไม่ต้องคำนวณบนจอ
const GRID_HALF = 26;
const GRID_STEP = 1.6;
(function buildGrid() {
  const pts = [];
  for (let v = -GRID_HALF; v <= GRID_HALF; v += GRID_STEP) {
    pts.push(-GRID_HALF, 0, v, GRID_HALF, 0, v);
    pts.push(v, 0, -GRID_HALF, v, 0, GRID_HALF);
  }
  const geo = new THREE.BufferGeometry();
  geo.setAttribute('position', new THREE.Float32BufferAttribute(pts, 3));
  const mat = new THREE.LineBasicMaterial({
    color: 0x202124, transparent: true, opacity: 0.075,
  });
  const grid = new THREE.LineSegments(geo, mat);
  grid.position.y = -0.002;
  scene.add(grid);

  // พื้นทึบบาง ๆ ไว้รับเงา ให้แท่นดูวางอยู่บนอะไรสักอย่าง
  const floor = new THREE.Mesh(
    new THREE.PlaneGeometry(GRID_HALF * 2, GRID_HALF * 2),
    new THREE.ShadowMaterial({ opacity: 0.10 })
  );
  floor.rotation.x = -Math.PI / 2;
  floor.receiveShadow = true;
  scene.add(floor);
})();

// ---------------------------------------------------------------- ฉาก
const stages = {};        // key -> { group, anchor }
let highlight = '';
let dirty = true;

function dressMaterials(root) {
  root.traverse(function (m) {
    if (!m.isMesh || !m.material) return;
    m.castShadow = true;
    m.receiveShadow = true;
    const mats = Array.isArray(m.material) ? m.material : [m.material];
    mats.forEach(function (mat) {
      mat.side = THREE.DoubleSide;
      // โมเดลที่ไม่มีสีของตัวเอง (เช่นที่เจนมาจาก Meshy) จะขาวจนดูไม่ออกว่าเป็นรูปอะไร
      // ย้อมเป็นฟ้าอมเทาและเพิ่มความหยาบผิว ให้แสงเงาช่วยขับรูปทรง
      const plain = !mat.map && mat.color &&
          mat.color.r > 0.92 && mat.color.g > 0.92 && mat.color.b > 0.92;
      if (plain) {
        mat.color.setHex(0xD6E1F2);
        if ('roughness' in mat) mat.roughness = 0.85;
        if ('metalness' in mat) mat.metalness = 0.0;
        mat.flatShading = true;
        mat.needsUpdate = true;
      }
    });
  });
}

new THREE.GLTFLoader().load('scene.glb', function (gltf) {
  const root = gltf.scene;
  dressMaterials(root);
  // จัดวัตถุเข้ากลุ่มตามชื่อ plate_<ขั้น> / prop_<ขั้น>_<ของ>
  const buckets = {};
  root.traverse(function (o) {
    if (!o.isMesh) return;
    const n = (o.name || '').split('.')[0];
    let key = null;
    // เตียงเป็นกลุ่มของตัวเอง ส่วนโซนรวมของทุกชิ้นในโซนนั้นเข้าด้วยกัน
    if (n.indexOf('bed_') === 0) {
      key = n;
    } else if (n.indexOf('zone_') === 0) {
      key = n.split('_').slice(0, 2).join('_');
    } else {
      ['wait_doctor', 'triage', 'treatment', 'discharge'].forEach(function (t) {
        if (n.indexOf(t) >= 0 && (n.indexOf('plate_') === 0 ||
            n.indexOf('prop_') === 0)) key = t;
      });
    }
    if (!key) return;
    (buckets[key] = buckets[key] || []).push(o);
  });

  Object.keys(buckets).forEach(function (k) {
    // ไม่ย้าย parent เพราะการ re-parent ระหว่างโหลดทำให้บางชิ้นหลุดหายไป
    // เก็บเป็นรายชื่อ mesh พอ แล้วคำนวณจุดยึดจากขอบเขตรวมของกลุ่ม
    const meshes = buckets[k];
    const box = new THREE.Box3();
    const mats = [];
    meshes.forEach(function (m) {
      m.userData.stageKey = k;
      box.expandByObject(m);
      const mm = Array.isArray(m.material) ? m.material : [m.material];
      mm.forEach(function (mat) { if (mats.indexOf(mat) < 0) mats.push(mat); });
    });
    const center = box.getCenter(new THREE.Vector3());
    stages[k] = {
      meshes: meshes,
      box: box,
      anchor: new THREE.Vector3(center.x, box.min.y, center.z),
      mats: mats,
    };
  });

  scene.add(root);

  // โมเดลที่เจนมามักวางคร่อมจุดกำเนิด ครึ่งล่างจึงจมอยู่ใต้พื้น
  // ยกขึ้นให้ฐานแตะพื้นพอดี เงาจะได้ตกบนพื้นจริง
  (function seat() {
    const b = new THREE.Box3().setFromObject(root);
    if (!b.isEmpty()) root.position.y -= b.min.y;
  })();

  // เล็งกลางฉากจริงและซูมให้เห็นครบทุกแท่น ไม่ต้องจูนด้วยมือ
  const all = new THREE.Box3();
  Object.keys(stages).forEach(function (k) { all.union(stages[k].box); });
  // โมเดลที่ไม่มีการตั้งชื่อกลุ่มตามขั้น ให้เล็งจากขอบเขตของทั้งฉากแทน
  if (all.isEmpty()) all.setFromObject(root);
  if (!all.isEmpty()) {
    target = all.getCenter(new THREE.Vector3());
    const size = all.getSize(new THREE.Vector3());
    const aspect = window.innerWidth / Math.max(window.innerHeight, 1);
    // กว้างที่สุดตามแนวทแยงของฉากเมื่อหมุน 45 องศา
    const spread = (size.x + size.z) * Math.SQRT1_2;
    autoZoom = Math.max(spread / Math.max(aspect, 0.1), size.y + spread * 0.55);
    autoZoom *= 0.92;
  }
  applyCam();

  renderer.shadowMap.needsUpdate = true;
  dirty = true;
  send({ type: 'ready', stages: Object.keys(stages) });
});

// ---------------------------------------------------------------- กล้อง
function applyCam() {
  const aspect = window.innerWidth / Math.max(window.innerHeight, 1);
  const h = autoZoom > 0 ? autoZoom : cam.zoom;
  camera.left = -h * aspect / 2;
  camera.right = h * aspect / 2;
  camera.top = h / 2;
  camera.bottom = -h / 2;
  camera.near = 0.1;
  camera.far = 400;
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
  // เลื่อนฉากบนจอโดยขยับกล้องในระนาบของกล้องเอง
  const right = new THREE.Vector3();
  const up = new THREE.Vector3();
  camera.matrixWorld.extractBasis(right, up, new THREE.Vector3());
  camera.position.addScaledVector(right, -cam.shiftX);
  camera.position.addScaledVector(up, -cam.shiftY);
  camera.updateMatrixWorld();
  dirty = true;
}

window.flowSetCam = function (c) {
  cam = Object.assign(cam, c);
  applyCam();
};

window.flowHighlight = function (k) {
  highlight = k || '';
  // รับได้หลายคีย์คั่นด้วยจุลภาค เพราะหนึ่งแท็บอาจครอบหลายห้อง
  const keys = highlight.split(',').filter(function (s) { return s; });
  Object.keys(stages).forEach(function (key) {
    const on = keys.length === 0 || keys.indexOf(key) >= 0;
    stages[key].mats.forEach(function (mat) {
      mat.transparent = true;
      mat.opacity = on ? 1.0 : 0.55;
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
  const hits = ray.intersectObjects(scene.children, true);
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
</script>
</body>
</html>
''';
