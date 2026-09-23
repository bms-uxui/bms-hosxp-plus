/// ฉากขั้นบันไดสามมิติของกระแสงาน ER
///
/// แท่นสี่ขั้นไล่ระดับสูงขึ้นจากซ้ายไปขวา แต่ละแท่นมีลำแสงพุ่งขึ้นและลูกศร
/// เชื่อมไปขั้นถัดไป ทุกอย่างสร้างด้วยโค้ดใน three.js ไม่ต้องโหลดโมเดล
/// จึงเบากว่าฉากห้องจริงมาก และเปลี่ยนสี/ความสูงตามข้อมูลได้ทันที
///
/// ความสูงของแท่น = จำนวนคนค้างในขั้นนั้น ดูแวบเดียวรู้ว่าขั้นไหนคือคอขวด
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'er_flow_3d_types.dart';

/// หนึ่งแท่นในฉาก
class ErStair {
  const ErStair({
    required this.key,
    required this.color,
    required this.value,
    this.alert = false,
  });

  final String key;
  final Color color;

  /// จำนวนคน ใช้กำหนดความสูงของแท่น
  final int value;

  /// ขั้นที่มีคนค้างเกินเกณฑ์ ลำแสงจะเป็นสีเตือน
  final bool alert;

  Map<String, dynamic> toJson() => {
        'key': key,
        'color':
            '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        'value': value,
        'alert': alert,
      };
}

class ErStair3D extends StatefulWidget {
  const ErStair3D({
    super.key,
    required this.stairs,
    this.selected,
    this.onTap,
    this.onPositions,
  });

  final List<ErStair> stairs;

  /// ขั้นที่เลือกอยู่ ขั้นอื่นจะจางลง
  final String? selected;

  final void Function(String key)? onTap;

  /// ตำแหน่งบนจอของยอดแท่นแต่ละขั้น ใช้วางไอคอนกับตัวเลขทับ
  final void Function(List<ErFlowStagePos> positions)? onPositions;

  @override
  State<ErStair3D> createState() => _ErStair3DState();
}

class _ErStair3DState extends State<ErStair3D> {
  WebViewController? _web;
  HttpServer? _server;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void didUpdateWidget(covariant ErStair3D old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.stairs.map((s) => s.toJson().toString()).toList(),
        widget.stairs.map((s) => s.toJson().toString()).toList())) {
      _pushStairs();
    }
    if (old.selected != widget.selected) _pushSelected();
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
      ..addJavaScriptChannel('ErStair', onMessageReceived: _onMessage)
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    setState(() => _web = controller);
  }

  void _pushStairs() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript(
        'window.stairSet(${jsonEncode(widget.stairs.map((s) => s.toJson()).toList())})');
  }

  void _pushSelected() {
    if (!_ready || _web == null) return;
    _web!.runJavaScript("window.stairSelect('${widget.selected ?? ''}')");
  }

  void _onMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        _ready = true;
        _pushStairs();
        _pushSelected();
        break;
      case 'tap':
        widget.onTap?.call(data['key'] as String);
        break;
      case 'error':
        debugPrint('ErStair3D ผิดพลาด: ${data['message']}');
        break;
      case 'positions':
        widget.onPositions?.call([
          for (final e in data['items'] as List)
            ErFlowStagePos(
              e['key'] as String,
              (e['x'] as num).toDouble(),
              (e['y'] as num).toDouble(),
              e['visible'] as bool,
            ),
        ]);
        break;
    }
  }

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
        final bytes = await rootBundle.load('assets/web/three.min.js');
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
  html, body { margin:0; height:100%; overflow:hidden; background:transparent; }
  canvas { display:block; touch-action:none; }
</style>
<script src="three.min.js"></script>
</head>
<body>
<script>
function send(o) { try { ErStair.postMessage(JSON.stringify(o)); } catch (e) {} }
window.onerror = function (m) { send({type:'error', message:String(m)}); };

const scene = new THREE.Scene();
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 400);
const renderer = new THREE.WebGLRenderer({ antialias:true, alpha:true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.outputEncoding = THREE.sRGBEncoding;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
document.body.appendChild(renderer.domElement);

scene.add(new THREE.HemisphereLight(0xffffff, 0xdfe6ee, 0.95));
const key = new THREE.DirectionalLight(0xffffff, 0.85);
key.position.set(6, 12, 8);
key.castShadow = true;
key.shadow.mapSize.set(1024, 1024);
key.shadow.camera.left = -14; key.shadow.camera.right = 14;
key.shadow.camera.top = 12; key.shadow.camera.bottom = -12;
key.shadow.camera.far = 60; key.shadow.bias = -0.0009;
scene.add(key);

// พื้นรับเงาแบบโปร่ง เห็นเฉพาะเงาที่ตกลงมา
const floor = new THREE.Mesh(
  new THREE.PlaneGeometry(80, 80),
  new THREE.ShadowMaterial({ opacity: 0.09 })
);
floor.rotation.x = -Math.PI / 2;
floor.position.y = -0.01;
floor.receiveShadow = true;
scene.add(floor);

const GAP = 4.4;          // ระยะห่างแต่ละขั้นตามแนวทแยง
const RISE = 1.15;        // ความสูงที่เพิ่มขึ้นต่อหนึ่งขั้น
const SLAB = 3.0;         // ความกว้างของแท่น
const THICK = 0.55;       // ความหนาของแท่น

let group = new THREE.Group();
scene.add(group);
let items = [];
let lastSent = 0;
let selected = '';
let dirty = true;

/// แท่นมุมมนแบบง่าย ใช้กล่องซ้อนกับขอบโค้งจาก Cylinder ที่มุม
function slab(color) {
  const g = new THREE.Group();
  const mat = new THREE.MeshLambertMaterial({ color: color });
  const body = new THREE.Mesh(
    new THREE.BoxGeometry(SLAB, THICK, SLAB), mat);
  body.castShadow = true;
  body.receiveShadow = true;
  g.add(body);
  // ขอบบนสว่างกว่าเล็กน้อย ให้เห็นความหนา
  const top = new THREE.Mesh(
    new THREE.BoxGeometry(SLAB * 0.995, 0.03, SLAB * 0.995),
    new THREE.MeshBasicMaterial({
      color: new THREE.Color(color).lerp(new THREE.Color(0xffffff), 0.22),
    })
  );
  top.position.y = THICK / 2 + 0.015;
  g.add(top);
  return g;
}

/// ลำแสงพุ่งขึ้นจากกลางแท่น จางหายด้านบน
function beam(color) {
  const h = 2.0;
  const geo = new THREE.CylinderGeometry(0.62, 0.34, h, 24, 1, true);
  const mat = new THREE.MeshBasicMaterial({
    color: color, transparent: true, opacity: 0.16,
    side: THREE.DoubleSide, depthWrite: false,
  });
  const m = new THREE.Mesh(geo, mat);
  m.position.y = h / 2 + THICK / 2;
  return m;
}

/// ลูกศรแบนเชื่อมสองขั้น
function arrow(from, to, color) {
  const dir = new THREE.Vector3().subVectors(to, from);
  const len = dir.length();
  const g = new THREE.Group();
  const shaft = new THREE.Mesh(
    new THREE.BoxGeometry(len * 0.58, 0.06, 0.16),
    new THREE.MeshBasicMaterial({ color: color, transparent: true, opacity: 0.55 })
  );
  g.add(shaft);
  const head = new THREE.Mesh(
    new THREE.ConeGeometry(0.22, 0.5, 4),
    new THREE.MeshBasicMaterial({ color: color, transparent: true, opacity: 0.65 })
  );
  head.rotation.z = -Math.PI / 2;
  head.position.x = len * 0.29 + 0.25;
  g.add(head);
  const mid = new THREE.Vector3().addVectors(from, to).multiplyScalar(0.5);
  g.position.copy(mid);
  g.rotation.y = Math.atan2(-dir.z, dir.x);
  return g;
}

window.stairSet = function (list) {
  scene.remove(group);
  group = new THREE.Group();
  scene.add(group);
  items = [];

  const n = list.length;
  const maxV = list.reduce(function (a, b) { return Math.max(a, b.value); }, 1);

  const centers = [];
  for (let i = 0; i < n; i++) {
    const t = i - (n - 1) / 2;
    // เดินตามแนวทแยงเพื่อให้ภาพบนจอเลื่อนไปทางขวาอย่างเดียว
    const x = t * GAP;
    const z = -t * GAP;
    const y = i * RISE;
    centers.push(new THREE.Vector3(x, y, z));
  }

  for (let i = 0; i < n; i++) {
    const it = list[i];
    const c = centers[i];
    const s = slab(it.color);
    s.position.copy(c);
    // ความหนาของแท่นแปรตามจำนวนคน ขั้นที่ค้างเยอะจะดูหนักกว่า
    const k = 0.6 + (it.value / maxV) * 1.2;
    s.scale.y = k;
    s.userData.key = it.key;
    s.traverse(function (o) { o.userData.key = it.key; });
    group.add(s);

    const b = beam(it.alert ? 0xEA4335 : it.color);
    b.position.set(c.x, c.y + THICK * k * 0.5, c.z);
    group.add(b);

    items.push({ key: it.key, slab: s, beam: b,
      anchor: new THREE.Vector3(c.x, c.y + THICK * k + 0.15, c.z) });

    if (i > 0) {
      const a = centers[i - 1].clone();
      const bb = c.clone();
      a.y += 0.35; bb.y += 0.35;
      group.add(arrow(a, bb, 0x9AA0A6));
    }
  }
  fitCamera();
  applySelected();
  lastSent = 0;
  dirty = true;
};

window.stairSelect = function (k) {
  selected = k || '';
  applySelected();
  dirty = true;
};

function applySelected() {
  items.forEach(function (it) {
    const on = selected === '' || selected === it.key;
    it.slab.traverse(function (o) {
      if (o.material) {
        o.material.transparent = true;
        o.material.opacity = on ? 1.0 : 0.35;
      }
    });
    it.beam.material.opacity = on ? 0.16 : 0.05;
  });
}

function fitCamera() {
  const box = new THREE.Box3();
  items.forEach(function (it) { box.expandByObject(it.slab); });
  if (box.isEmpty()) return;
  const size = box.getSize(new THREE.Vector3());
  const center = box.getCenter(new THREE.Vector3());
  const aspect = window.innerWidth / Math.max(window.innerHeight, 1);
  const spread = (size.x + size.z) * Math.SQRT1_2;
  const h = Math.max(spread / Math.max(aspect, 0.1), size.y + spread * 0.5) * 1.22;
  camera.left = -h * aspect / 2; camera.right = h * aspect / 2;
  camera.top = h / 2; camera.bottom = -h / 2;
  camera.near = 0.1; camera.far = 400;
  camera.updateProjectionMatrix();
  const yaw = Math.PI / 4;
  const pitch = 33 * Math.PI / 180;
  const d = 90;
  camera.position.set(
    center.x + d * Math.cos(pitch) * Math.sin(yaw),
    center.y + d * Math.sin(pitch),
    center.z + d * Math.cos(pitch) * Math.cos(yaw)
  );
  camera.lookAt(center);
  camera.updateMatrixWorld();
}

const ray = new THREE.Raycaster();
const ndc = new THREE.Vector2();
renderer.domElement.addEventListener('pointerdown', function (e) {
  ndc.x = (e.clientX / window.innerWidth) * 2 - 1;
  ndc.y = -(e.clientY / window.innerHeight) * 2 + 1;
  ray.setFromCamera(ndc, camera);
  const hits = ray.intersectObjects(group.children, true);
  for (let i = 0; i < hits.length; i++) {
    const k = hits[i].object.userData && hits[i].object.userData.key;
    if (k) { send({ type:'tap', key:k }); return; }
  }
});

function report() {
  const now = performance.now();
  if (now - lastSent < 250) return;
  lastSent = now;
  const v = new THREE.Vector3();
  const out = items.map(function (it) {
    v.copy(it.anchor).project(camera);
    return {
      key: it.key,
      x: (v.x * 0.5 + 0.5) * window.innerWidth,
      y: (-v.y * 0.5 + 0.5) * window.innerHeight,
      visible: v.z > -1 && v.z < 1,
    };
  });
  if (out.length) send({ type:'positions', items: out });
}

window.addEventListener('resize', function () {
  renderer.setSize(window.innerWidth, window.innerHeight);
  fitCamera();
  dirty = true;
});

function animate() {
  requestAnimationFrame(animate);
  if (!dirty) return;
  dirty = false;
  renderer.render(scene, camera);
  report();
}
animate();
send({ type: 'ready' });
</script>
</body>
</html>
''';
