/// ฉากวงแหวนสามมิติของหน้าภาพรวม — กระแสงาน ER เป็นวงแหวนสามท่อน
///
/// ปั้นด้วยโค้ดใน three.js ทั้งหมด ไม่ต้องโหลดโมเดล (แบบเดียวกับ [ErPlatform3D])
/// ท่อนละหนึ่งช่วงงาน สูงไล่ลงตามลำดับงานรอบวง มีเส้นวงโคจรบนพื้น
/// หมุดลอยเหนือแต่ละท่อน (จุดยึดการ์ดฝั่ง Flutter) คนตัวเล็กตามจำนวนผู้ป่วย
/// และชุดอุปกรณ์ของแต่ละช่วงงานจาก er_flow.glb (โต๊ะคัดกรอง · เตียงตรวจรักษา · ประตูจำหน่าย)
/// มือถือเปิดใน WebView ผ่าน HttpServer ในเครื่อง · เว็บใช้ iframe ([ErWebFrame])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import '../er_shared/er_web_frame.dart';

import 'er_flow_3d_types.dart';

/// หนึ่งท่อนของวงแหวน = หนึ่งช่วงงาน
class ErRingStage {
  const ErRingStage({
    required this.key,
    required this.color,
    required this.value,
    this.alert = false,
  });

  /// รหัสช่วงงาน ใช้ผูกกับการ์ดฝั่ง Flutter
  final String key;

  /// สีประจำช่วงงาน
  final Color color;

  /// จำนวนผู้ป่วย ใช้กำหนดจำนวนคนตัวเล็กบนท่อน
  final int value;

  /// มีคนค้างเกินเกณฑ์ = หมุดเป็นสีเตือน
  final bool alert;

  String get _hex =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  Map<String, dynamic> toJson() =>
      {'key': key, 'color': _hex, 'value': value, 'alert': alert};
}

class ErRing3D extends StatefulWidget {
  const ErRing3D({
    super.key,
    required this.stages,
    this.highlight,
    this.onStageTap,
    this.onPositions,
    this.intro = false,
    this.onIntro,
  });

  /// เปิดฉากด้วย intro: กล้องเริ่มชิดโลโก้ ER กลางวง แล้วซูมออก
  final bool intro;

  /// ฉากเริ่มซูมออกแล้ว (ฝั่ง Flutter เฟดโลโก้เต็มจอออกพร้อมกัน)
  final VoidCallback? onIntro;

  /// ท่อนทั้งหมด เรียงตามลำดับของกระแสงาน (วนตามเข็มนาฬิกาจากด้านหลัง)
  final List<ErRingStage> stages;

  /// ช่วงงานที่เลือกอยู่ ท่อนอื่นจางลง
  final String? highlight;

  final void Function(String key)? onStageTap;

  /// ตำแหน่งหมุดของแต่ละท่อนบนจอ (พิกเซล logical ในกรอบฉาก)
  final void Function(List<ErFlowStagePos> positions)? onPositions;

  @override
  State<ErRing3D> createState() => _ErRing3DState();
}

class _ErRing3DState extends State<ErRing3D> {
  WebViewController? _web;
  HttpServer? _server;

  /// เว็บ: ฉากเดียวกันใน iframe แทน WebView + HttpServer
  ErWebFrame? _frame;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void didUpdateWidget(covariant ErRing3D old) {
    super.didUpdateWidget(old);
    if (old.highlight != widget.highlight) _pushHighlight();
    if (_encoded(old.stages) != _encoded(widget.stages)) _pushData();
  }

  String _encoded(List<ErRingStage> list) =>
      jsonEncode([for (final s in list) s.toJson()]);

  @override
  void dispose() {
    _server?.close(force: true);
    _frame?.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    if (kIsWeb) {
      setState(() => _frame = ErWebFrame(
            html: _html,
            channel: 'ErRing',
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
                r'^/er_flow\.glb$',
                'assets/models/er_flow.glb',
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
      ..addJavaScriptChannel('ErRing', onMessageReceived: _onMessage)
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    setState(() => _web = controller);
  }

  /// รัน JS ในฉาก: iframe บนเว็บ หรือ WebView บนมือถือ
  void _js(String js) {
    if (!_ready) return;
    if (_frame != null) {
      _frame!.run(js);
      return;
    }
    _web?.runJavaScript(js);
  }

  void _pushData() => _js('window.ringSet(${_encoded(widget.stages)})');

  void _pushHighlight() =>
      _js("window.ringHighlight('${widget.highlight ?? ''}')");

  void _onMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        _ready = true;
        _pushData();
        _pushHighlight();
        if (widget.intro) _js('window.ringIntro()');
        break;
      case 'intro':
        widget.onIntro?.call();
        break;
      case 'tap':
        widget.onStageTap?.call(data['key'] as String);
        break;
      case 'error':
        debugPrint('ErRing3D ผิดพลาด: ${data['message']}');
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
      const files = {
        '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
        '/GLTFLoader.js': [
          'assets/web/GLTFLoader.js',
          'application/javascript'
        ],
        '/er_flow.glb': ['assets/models/er_flow.glb', 'model/gltf-binary'],
      };
      final f = files[req.uri.path];
      if (f != null) {
        final bytes = await rootBundle.load(f[0]);
        req.response.headers.set('content-type', f[1]);
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
    if (_frame != null) return _frame!.view();
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
<script src="GLTFLoader.js"></script>
</head>
<body>
<script>
function post(o) { if (window.ErRing) window.ErRing.postMessage(JSON.stringify(o)); }
window.onerror = function (m) { post({ type: 'error', message: String(m) }); };

// ---------------------------------------------------------------- ฉากและกล้อง
// กล้อง orthographic มุม isometric: ภาพแบบภาพประกอบ เส้นขนานไม่ลู่
const scene = new THREE.Scene();
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
renderer.setClearColor(0x000000, 0);
renderer.outputEncoding = THREE.sRGBEncoding;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
document.body.appendChild(renderer.domElement);

const cam = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 200);
const YAW = 45 * Math.PI / 180, PITCH = 33 * Math.PI / 180;
cam.position.set(
  Math.cos(PITCH) * Math.cos(YAW) * 40,
  Math.sin(PITCH) * 40,
  Math.cos(PITCH) * Math.sin(YAW) * 40);
cam.lookAt(0, 0.6, 0);
const CAM_DIR = cam.position.clone().normalize();
const HOME = new THREE.Vector3(0, 0.6, 0);
let need = 10;          // ความสูงกรอบภาพ (เมตร) ที่เห็นทั้งวง
function applyCam(zf, target) {
  const aspect = window.innerWidth / Math.max(window.innerHeight, 1);
  const hgt = need * zf;
  cam.top = hgt / 2; cam.bottom = -hgt / 2;
  cam.left = -hgt * aspect / 2; cam.right = hgt * aspect / 2;
  cam.position.copy(target).addScaledVector(CAM_DIR, 40);
  cam.lookAt(target);
  cam.updateProjectionMatrix();
}

scene.add(new THREE.HemisphereLight(0xffffff, 0x8894b0, 0.6));
const sun = new THREE.DirectionalLight(0xffffff, 1.05);
sun.position.set(-6, 14, 8);
sun.castShadow = true;
sun.shadow.mapSize.set(1024, 1024);
sun.shadow.camera.left = -9; sun.shadow.camera.right = 9;
sun.shadow.camera.top = 9; sun.shadow.camera.bottom = -9;
sun.shadow.radius = 6;
sun.shadow.bias = -0.0008;
scene.add(sun);

// พื้นรับเงาอย่างเดียว (โปร่ง) ฉากจึงลอยบนพื้นขาวของแอป
const ground = new THREE.Mesh(new THREE.PlaneGeometry(40, 40),
  new THREE.ShadowMaterial({ opacity: 0.10 }));
ground.rotation.x = -Math.PI / 2;
ground.receiveShadow = true;
scene.add(ground);

// ---------------------------------------------------------------- วงแหวน
const R_IN = 2.3, R_OUT = 4.2;
// มุมกลางท่อน (องศาบนพื้น x=cos z=sin): หลัง → ขวา → หน้า ตามเข็มนาฬิกาบนจอ
const CENTERS = [215, 335, 95];
const SPAN = 104;
const HEIGHTS = [1.55, 1.0, 0.5];

const root = new THREE.Group();
scene.add(root);
let stages = [];        // {key, group, mats, pin, pinAt, h, theta}
let data = [];
let hi = '';

// สีจาก Flutter เป็น sRGB · ต้องแปลงเป็น linear ก่อน ไม่งั้นทั้งฉากซีด
function lin(hex) { return new THREE.Color(hex).convertSRGBToLinear(); }
function shade(hex, k) {
  const c = lin(hex);
  return k >= 0 ? c.lerp(new THREE.Color(0xffffff), k) : c.multiplyScalar(1 + k);
}

// ท่อนวงแหวน: รูปเสี้ยววงแหวน 2 มิติ อัดขึ้นเป็นแท่งหนา
function sector(theta, h, color) {
  const a0 = (theta - SPAN / 2) * Math.PI / 180;
  const a1 = (theta + SPAN / 2) * Math.PI / 180;
  const s = new THREE.Shape();
  const N = 48;
  // y ของรูป = -sin เพราะหมุนแกนแล้วแกน y ของรูปกลายเป็น -z ของโลก
  for (let i = 0; i <= N; i++) {
    const a = a0 + (a1 - a0) * i / N;
    const p = [Math.cos(a) * R_OUT, -Math.sin(a) * R_OUT];
    if (i === 0) s.moveTo(p[0], p[1]); else s.lineTo(p[0], p[1]);
  }
  for (let i = N; i >= 0; i--) {
    const a = a0 + (a1 - a0) * i / N;
    s.lineTo(Math.cos(a) * R_IN, -Math.sin(a) * R_IN);
  }
  const g = new THREE.ExtrudeGeometry(s, {
    depth: h, bevelEnabled: true, bevelThickness: 0.05, bevelSize: 0.05,
    bevelSegments: 2, curveSegments: 12,
  });
  g.rotateX(-Math.PI / 2);
  const top = new THREE.MeshStandardMaterial({
    color: shade(color, 0.12), roughness: 0.55, metalness: 0.0, transparent: true });
  const side = new THREE.MeshStandardMaterial({
    color: shade(color, -0.25), roughness: 0.6, metalness: 0.0, transparent: true });
  const m = new THREE.Mesh(g, [top, side]);
  m.castShadow = true;
  m.receiveShadow = true;
  return { mesh: m, mats: [top, side] };
}

// คนตัวเล็กแบบภาพประกอบ: ขา ลำตัว หัว
const SKIN = 0xf2c8a0;
function person(shirt) {
  const g = new THREE.Group();
  const mat = function (c) { return new THREE.MeshStandardMaterial({ color: lin(c), roughness: 0.6, transparent: true }); };
  const legs = new THREE.Mesh(new THREE.CylinderGeometry(0.075, 0.07, 0.26, 12), mat(0x24315e));
  legs.position.y = 0.13;
  const body = new THREE.Mesh(new THREE.CylinderGeometry(0.1, 0.085, 0.26, 14), mat(shirt));
  body.position.y = 0.39;
  const head = new THREE.Mesh(new THREE.SphereGeometry(0.075, 16, 12), mat(SKIN));
  head.position.y = 0.6;
  const hair = new THREE.Mesh(new THREE.SphereGeometry(0.078, 16, 8, 0, Math.PI * 2, 0, Math.PI / 2), mat(0x2a2320));
  hair.position.y = 0.61;
  [legs, body, head, hair].forEach(function (x) { x.castShadow = true; g.add(x); });
  return g;
}

// กล่องประกอบฉาก (แฟ้ม/อุปกรณ์) สีฟ้าอ่อน
function box(w, h, d, c) {
  const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d),
    new THREE.MeshStandardMaterial({ color: lin(c), roughness: 0.5, transparent: true }));
  m.castShadow = true;
  return m;
}

// หมุดลอย: วงกลมขาวขอบสี + จุดกลาง หันหาจอเสมอ
function pinTexture(color, alert) {
  const c = document.createElement('canvas');
  c.width = c.height = 128;
  const g = c.getContext('2d');
  g.fillStyle = 'rgba(0,20,60,0.18)';
  g.beginPath(); g.arc(64, 68, 54, 0, Math.PI * 2); g.fill();
  g.fillStyle = '#ffffff';
  g.beginPath(); g.arc(64, 62, 52, 0, Math.PI * 2); g.fill();
  g.lineWidth = 10;
  g.strokeStyle = color;
  g.beginPath(); g.arc(64, 62, 44, 0, Math.PI * 2); g.stroke();
  g.fillStyle = alert ? '#D93025' : color;
  g.beginPath(); g.arc(64, 62, 18, 0, Math.PI * 2); g.fill();
  const t = new THREE.CanvasTexture(c);
  t.encoding = THREE.sRGBEncoding;
  return t;
}

// เส้นวงโคจรบนพื้นรอบวงแหวน
function orbit(r, color, opacity) {
  const m = new THREE.Mesh(new THREE.RingGeometry(r, r + 0.035, 160),
    new THREE.MeshBasicMaterial({ color: lin(color), transparent: true, opacity: opacity, side: THREE.DoubleSide }));
  m.rotation.x = -Math.PI / 2;
  m.position.y = 0.01;
  return m;
}

// ---------------------------------------------------------------- ชุดอุปกรณ์จากฉากเดิม
// er_flow.glb มีแท่นและอุปกรณ์แยกตามขั้น (prop_<ขั้น>_*) · ดึงเฉพาะอุปกรณ์มาวางบนท่อน
// ขนาดคิดจากแท่นเดิมของขั้นนั้น ให้ทั้งชุดพอดีความกว้างของท่อน
let flowProps = null;
const PROPS = {
  triage: { plate: 'plate_triage', prefix: ['prop_triage_'] },
  treatment: { plate: 'plate_treatment', prefix: ['prop_treatment_'] },
  after: { plate: 'plate_discharge', prefix: ['prop_discharge_'] },
};
new THREE.GLTFLoader().load('er_flow.glb', function (g) {
  flowProps = g.scene;
  flowProps.updateMatrixWorld(true);
  build();
  startIntro();
}, undefined, function (e) { post({ type: 'error', message: 'er_flow.glb ' + e }); });

function addProps(grp, key, theta, h, mats) {
  const cfg = PROPS[key];
  if (!flowProps || !cfg) return;
  const inner = new THREE.Group();
  flowProps.children.forEach(function (n) {
    if (cfg.prefix.some(function (p) { return n.name.indexOf(p) === 0; })) inner.add(n.clone(true));
  });
  if (!inner.children.length) return;
  const plate = flowProps.getObjectByName(cfg.plate);
  const pb = new THREE.Box3().setFromObject(plate || inner);
  const c = pb.getCenter(new THREE.Vector3()), sz = pb.getSize(new THREE.Vector3());
  // ชุดอุปกรณ์วางบนผิวแท่นเดิม → ยกให้ผิวแท่นอยู่ที่ y = 0 แล้วจัดกลาง
  inner.position.set(-c.x, -pb.max.y, -c.z);
  inner.traverse(function (x) {
    if (!x.isMesh) return;
    x.castShadow = true;
    x.receiveShadow = true;
    x.material = x.material.clone();
    x.material.transparent = true;
    mats.push(x.material);
  });
  const outer = new THREE.Group();
  outer.add(inner);
  outer.scale.setScalar(1.75 / Math.max(sz.x, sz.z));
  const a = theta * Math.PI / 180, r = (R_IN + R_OUT) / 2;
  outer.position.set(Math.cos(a) * r, h + 0.04, Math.sin(a) * r);
  // หันหน้าชุดออกนอกวง ตามแนวรัศมีของท่อน
  outer.rotation.y = -a + Math.PI / 2;
  grp.add(outer);
}

function seeded(n) {
  let x = n * 9301 + 49297;
  return function () { x = (x * 9301 + 49297) % 233280; return x / 233280; };
}

function build() {
  while (root.children.length) root.remove(root.children[0]);
  stages = [];
  root.add(orbit(R_OUT + 0.75, 0x7fb6e6, 0.75));
  root.add(orbit(R_OUT + 1.35, 0x7fb6e6, 0.4));
  root.add(orbit(R_IN - 0.55, 0x7fb6e6, 0.55));
  data.forEach(function (d, i) {
    const theta = CENTERS[i % CENTERS.length];
    const h = HEIGHTS[i % HEIGHTS.length];
    const grp = new THREE.Group();
    const sec = sector(theta, h, d.color);
    sec.mesh.userData.key = d.key;
    grp.add(sec.mesh);
    const mats = sec.mats.slice();
    const rnd = seeded(i + 1);
    const at = function (dAng, r) {
      const a = (theta + dAng) * Math.PI / 180;
      return new THREE.Vector3(Math.cos(a) * r, h + 0.05, Math.sin(a) * r);
    };
    // คนตัวเล็ก: ไม่เกิน 4 คนต่อท่อน ตามจำนวนผู้ป่วย
    const n = Math.min(3, Math.max(1, Math.ceil(d.value / 4)));
    const shirts = [0xf4b942, 0x2b3f96, 0xffffff, 0x5ab4e6];
    for (let k = 0; k < n; k++) {
      const p = person(shirts[(k + i) % shirts.length]);
      // คนยืนช่วงปลายท่อน เว้นกลางท่อนให้ชุดอุปกรณ์
      const side = k % 2 ? 1 : -1;
      p.position.copy(at(side * (SPAN / 2 - 12 - Math.floor(k / 2) * 9),
        R_IN + 0.55 + rnd() * (R_OUT - R_IN - 1.1)));
      p.rotation.y = rnd() * Math.PI * 2;
      p.scale.setScalar(1.45);
      p.traverse(function (x) { if (x.material) mats.push(x.material); });
      grp.add(p);
    }
    // ชุดอุปกรณ์ของช่วงงานจากฉากเดิม (er_flow.glb) วางกลางท่อน
    addProps(grp, d.key, theta, h, mats);
    // หมุดลอยกลางท่อน + เส้นประลงถึงผิวท่อน
    const mid = at(0, (R_IN + R_OUT) / 2);
    const pinAt = new THREE.Vector3(mid.x, h + 1.25, mid.z);
    const pin = new THREE.Sprite(new THREE.SpriteMaterial({
      map: pinTexture(d.color, d.alert), transparent: true, depthTest: false }));
    pin.scale.set(0.62, 0.62, 1);
    pin.position.copy(pinAt);
    pin.renderOrder = 10;
    mats.push(pin.material);
    grp.add(pin);
    const lg = new THREE.BufferGeometry().setFromPoints([mid, pinAt]);
    const line = new THREE.Line(lg, new THREE.LineDashedMaterial({
      color: lin(d.color), dashSize: 0.08, gapSize: 0.07, transparent: true }));
    line.computeLineDistances();
    mats.push(line.material);
    grp.add(line);
    root.add(grp);
    stages.push({ key: d.key, mesh: sec.mesh, mats: mats, pin: pin, pinAt: pinAt });
  });
  applyHighlight();
  resize();
}

function applyHighlight() {
  const keys = hi ? hi.split(',') : [];
  stages.forEach(function (s) {
    const on = !keys.length || keys.indexOf(s.key) >= 0;
    s.mats.forEach(function (m) { m.opacity = on ? 1.0 : 0.28; });
  });
  dirty = true;
}

// ---------------------------------------------------------------- จุดยึดการ์ด
const _v = new THREE.Vector3();
function positions() {
  if (intro) return;
  const w = window.innerWidth, h = window.innerHeight;
  post({ type: 'positions', items: stages.map(function (s) {
    _v.copy(s.pin.position).project(cam);
    return { key: s.key, x: (_v.x + 1) / 2 * w, y: (1 - _v.y) / 2 * h,
             visible: Math.abs(_v.x) <= 1 && Math.abs(_v.y) <= 1 };
  }) });
}

function resize() {
  const w = window.innerWidth, h = Math.max(window.innerHeight, 1);
  renderer.setSize(w, h);
  // ให้วงแหวนทั้งวง (รวมวงโคจร) พอดีกรอบทั้งแนวกว้างและแนวสูง
  need = Math.max(9.2, 13.6 / (w / h));
  if (!intro) {
    applyCam(1, HOME);
    positions();
  }
  dirty = true;
}
window.addEventListener('resize', resize);

// ---------------------------------------------------------------- แตะเลือกท่อน
const ray = new THREE.Raycaster(), ndc = new THREE.Vector2();
let down = null;
renderer.domElement.addEventListener('pointerdown', function (e) {
  down = { x: e.clientX, y: e.clientY };
});
renderer.domElement.addEventListener('pointerup', function (e) {
  if (!down || Math.abs(e.clientX - down.x) + Math.abs(e.clientY - down.y) > 10) { down = null; return; }
  down = null;
  ndc.x = (e.clientX / window.innerWidth) * 2 - 1;
  ndc.y = -(e.clientY / window.innerHeight) * 2 + 1;
  ray.setFromCamera(ndc, cam);
  const hit = ray.intersectObjects(stages.map(function (s) { return s.mesh; }))[0];
  if (hit) post({ type: 'tap', key: hit.object.userData.key });
});

// ---------------------------------------------------------------- โลโก้ ER กลางวง
// แบบเดียวกับหน้า login: กล่องมุมมนสีกรมท่า (_blueHue) + กากบาทขาว ลอยหันหาจอ
const LOGO_AT = new THREE.Vector3(0, 1.7, 0);
const logo = new THREE.Group();
(function () {
  const w = 1.5, r = 0.38, s = new THREE.Shape();
  logo.scale.setScalar(1.25);
  s.moveTo(-w / 2 + r, -w / 2);
  s.lineTo(w / 2 - r, -w / 2); s.quadraticCurveTo(w / 2, -w / 2, w / 2, -w / 2 + r);
  s.lineTo(w / 2, w / 2 - r); s.quadraticCurveTo(w / 2, w / 2, w / 2 - r, w / 2);
  s.lineTo(-w / 2 + r, w / 2); s.quadraticCurveTo(-w / 2, w / 2, -w / 2, w / 2 - r);
  s.lineTo(-w / 2, -w / 2 + r); s.quadraticCurveTo(-w / 2, -w / 2, -w / 2 + r, -w / 2);
  const tile = new THREE.Mesh(
    new THREE.ExtrudeGeometry(s, { depth: 0.28, bevelEnabled: true, bevelThickness: 0.06,
      bevelSize: 0.06, bevelSegments: 3, curveSegments: 10 }),
    new THREE.MeshStandardMaterial({ color: lin('#001B7C'), roughness: 0.35, metalness: 0.1 }));
  tile.castShadow = true;
  logo.add(tile);
  const white = new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 0.3 });
  [[0.86, 0.3], [0.3, 0.86]].forEach(function (d) {
    const b = new THREE.Mesh(new THREE.BoxGeometry(d[0], d[1], 0.1), white);
    b.position.z = 0.28 + 0.06 + 0.04;
    logo.add(b);
  });
  logo.rotation.order = 'YXZ';
  logo.rotation.y = YAW;
  logo.rotation.x = -0.28;
  logo.position.copy(LOGO_AT);
  scene.add(logo);
  // เงาวงรีบนพื้นใต้โลโก้
  const sh = new THREE.Mesh(new THREE.CircleGeometry(0.75, 40),
    new THREE.MeshBasicMaterial({ color: 0x0b1b3f, transparent: true, opacity: 0.10 }));
  sh.rotation.x = -Math.PI / 2;
  sh.position.y = 0.02;
  scene.add(sh);
})();

// ---------------------------------------------------------------- intro หลัง login
// เริ่มจากกล้องชิดโลโก้ (โลโก้เต็มจอ) แล้วซูมออกจนเห็นทั้งวง
// รอชุดอุปกรณ์โหลดเสร็จก่อน (ไม่เกิน 2.5 วิ) ของในฉากจะได้ไม่โผล่กลางทาง
let intro = null, introWant = false;
const INTRO_MS = 1900;
function startIntro() {
  if (!introWant || intro) return;
  introWant = false;
  intro = { t0: performance.now() };
  post({ type: 'intro' });
}
window.ringIntro = function () {
  introWant = true;
  applyCam(0.16, LOGO_AT);
  if (flowProps) startIntro(); else setTimeout(startIntro, 2500);
};

// ---------------------------------------------------------------- วาด
// หมุดลอยขึ้นลงเบา ๆ · ฉากนิ่งนอกนั้น (วาดใหม่เฉพาะตอนมีการเปลี่ยน + หมุด)
let dirty = true;
function frame(t) {
  stages.forEach(function (s, i) {
    s.pin.position.y = s.pinAt.y + Math.sin(t / 700 + i * 1.7) * 0.06;
  });
  logo.position.y = LOGO_AT.y + Math.sin(t / 900) * 0.05;
  if (intro) {
    const k = Math.min(1, (t - intro.t0) / INTRO_MS);
    const e = 1 - Math.pow(1 - k, 3);
    applyCam(0.16 + 0.84 * e, LOGO_AT.clone().lerp(HOME, e));
    if (k >= 1) { intro = null; positions(); }
  }
  renderer.render(scene, cam);
  dirty = false;
  requestAnimationFrame(frame);
}

window.ringSet = function (list) { data = list || []; build(); };
window.ringHighlight = function (k) { hi = k || ''; applyHighlight(); };

resize();
requestAnimationFrame(frame);
post({ type: 'ready' });
</script>
</body>
</html>
''';
