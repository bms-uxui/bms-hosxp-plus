/// ฉากสามมิติหน้าภาพรวมห้องฉุกเฉิน (three.js ใน WebView / iframe บนเว็บ)
///
/// ห้องแบบ diorama ตัดผนัง: โซนพื้นเรืองแสงตามระดับ ESI 1–5 (เตียง จอ เสาน้ำเกลือ)
/// ป้ายลอยบอกจำนวนผู้ป่วยแต่ละระดับ วงโดนัทยอดรวมกลางห้อง และเคาน์เตอร์ ER
/// ปั้นจาก geometry ในโค้ดทั้งหมด (ไม่โหลด .glb) เบาและเปลี่ยนตามข้อมูลจริงได้ทันที
///
/// แตะป้าย/โซน = ส่งระดับ ESI กลับมา (ใช้กรองรายชื่อผู้ป่วย)
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import '../er_shared/er_web_alive.dart';
import '../er_shared/er_web_frame.dart';

class ErOverview3D extends StatefulWidget {
  const ErOverview3D({
    super.key,
    required this.counts,
    required this.colors,
    this.total,
    this.selected,
    this.onZoneTap,
  });

  /// จำนวนผู้ป่วย ESI 1–5 (ตำแหน่ง 0 = ESI 1)
  final List<int> counts;

  /// สีของแต่ละระดับ (ตามโหมดสี/เทาของแอป)
  final List<Color> colors;

  /// ยอดผู้ป่วยทั้งหมดกลางวง (รวมที่ยังไม่คัดกรอง) · null = ผลรวมของ counts
  final int? total;

  /// ระดับที่กรองอยู่ (null = ทั้งหมด) โซนอื่นจางลง
  final int? selected;

  /// แตะโซน/ป้าย: ระดับ ESI 1–5
  final ValueChanged<int>? onZoneTap;

  @override
  State<ErOverview3D> createState() => _ErOverview3DState();
}

class _ErOverview3DState extends State<ErOverview3D> {
  WebViewController? _web;
  ErWebFrame? _frame;
  bool _ready = false;

  /// heartbeat กัน WKWebView ล่มตอน hot restart (ดู ErWebAlive)
  late final ErWebAlive _alive = ErWebAlive((js) => _web?.runJavaScript(js));

  static Future<HttpServer>? _shared;
  static final Map<String, Uint8List> _bytes = {};

  @override
  void initState() {
    super.initState();
    _boot();
  }

  /// debug: hot reload แล้วโหลดหน้าใหม่ ให้ JS ที่แก้มีผลทันที
  @override
  void reassemble() {
    super.reassemble();
    _ready = false;
    _shared?.then((s) => _web?.loadRequest(Uri.parse(
        'http://127.0.0.1:${s.port}/index.html?v=${DateTime.now().millisecondsSinceEpoch}')));
  }

  @override
  void didUpdateWidget(covariant ErOverview3D old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.counts, widget.counts) ||
        !listEquals(old.colors, widget.colors) ||
        old.total != widget.total ||
        old.selected != widget.selected) {
      _push();
    }
  }

  @override
  void dispose() {
    _alive.stop();
    _frame?.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    if (kIsWeb) {
      setState(() => _frame = ErWebFrame(
            html: _html,
            channel: 'ErOverview',
            routes: [
              (
                r'^/three\.min\.js$',
                'assets/web/three.min.js',
                'application/javascript'
              ),
            ],
            onMessage: (m) => _onMessage(JavaScriptMessage(message: m)),
          ));
      return;
    }
    final server = await (_shared ??= _bind());
    if (!mounted) return;
    final c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('ErOverview', onMessageReceived: _onMessage)
      ..loadRequest(Uri.parse(
          'http://127.0.0.1:${server.port}/index.html?v=${DateTime.now().millisecondsSinceEpoch}'));
    setState(() => _web = c);
    _alive.start();
  }

  /// เสิร์ฟหน้า + three.js จาก asset เฉพาะ 127.0.0.1
  static Future<HttpServer> _bind() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final path = req.uri.path;
      if (path == '/' || path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
        req.response.headers.set('cache-control', 'no-store');
        req.response.write(_html);
        await req.response.close();
        return;
      }
      if (path != '/three.min.js') {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
        return;
      }
      const a = 'assets/web/three.min.js';
      final bytes =
          _bytes[a] ??= (await rootBundle.load(a)).buffer.asUint8List();
      req.response.headers.set('content-type', 'application/javascript');
      req.response.headers.set('cache-control', 'public, max-age=86400');
      req.response.add(bytes);
      await req.response.close();
    });
    return server;
  }

  void _js(String js) {
    if (_frame != null) {
      _frame!.run(js);
      return;
    }
    _web?.runJavaScript(js);
  }

  void _push() {
    if (!_ready) return;
    String hex(Color c) =>
        '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    _js('window.erOvSet && window.erOvSet(${jsonEncode({
          'counts': widget.counts,
          'total': widget.total,
          'colors': [for (final c in widget.colors) hex(c)],
          'sel': widget.selected,
        })})');
  }

  void _onMessage(JavaScriptMessage m) {
    // ข้อความอาจมาหลังปิดหน้า: ห้ามโยน exception กลับเข้า WKScriptMessageHandler
    if (!mounted) return;
    try {
      final d = jsonDecode(m.message) as Map<String, dynamic>;
      switch (d['type']) {
        case 'ready':
          _ready = true;
          _push();
        case 'tap':
          widget.onZoneTap?.call((d['esi'] as num).toInt());
        case 'error':
          debugPrint('ErOverview3D ผิดพลาด: ${d['message']}');
      }
    } catch (e) {
      debugPrint('ErOverview3D message error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_frame != null) return _frame!.view();
    if (_web == null) return const SizedBox.shrink();
    return WebViewWidget(controller: _web!);
  }
}

// getter (ไม่ใช่ const): hot reload เห็น JS ที่แก้
String get _html => '''
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
<style>
  html, body { margin:0; height:100%; overflow:hidden; background:transparent; }
  * { -webkit-user-select:none; user-select:none; -webkit-touch-callout:none; -webkit-tap-highlight-color:transparent; }
  canvas { display:block; touch-action:none; }
</style>
<script src="three.min.js"></script>
</head>
<body>
<script>
${ErWebAlive.js}
function send(p) {
  if (!__erOk()) return;
  try { (window.ErOverview || window.parent.ErOverview).postMessage(JSON.stringify(p)); } catch (e) {}
}
window.addEventListener('error', function (e) { send({ type: 'error', message: String(e.message) }); });
$_sceneJs
</script>
</body>
</html>
''';

/// ตัวฉาก: แยกเป็น raw string (มี \$ ใน JS ได้โดยไม่ต้อง escape)
const String _sceneJs = r'''
// ---- โหมด clay: ทุกอย่างขาว/เทาอ่อน ยังไม่ลงสี (ใช้ปั้นรูปทรง/องค์ประกอบให้ตรง ref ก่อน)
const CLAY = true;
const W = () => window.innerWidth, H = () => Math.max(window.innerHeight, 1);
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(30, W() / H(), 0.5, 200);
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'high-performance' });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
renderer.setSize(W(), H());
renderer.setClearColor(0x000000, 0);
renderer.outputEncoding = THREE.sRGBEncoding;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 0.82;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
renderer.shadowMap.autoUpdate = false;
document.body.appendChild(renderer.domElement);

// ---- แสง clay: ท้องฟ้าสว่างทั่ว + แดดเฉียงซ้ายบน เงานุ่ม + ไฟเติมขวา
scene.add(new THREE.HemisphereLight(0xffffff, 0x8e9bb0, 0.62));
const sun = new THREE.DirectionalLight(0xffffff, 1.15);
sun.position.set(-7, 15, 9);
sun.castShadow = true;
sun.shadow.mapSize.set(2048, 2048);
Object.assign(sun.shadow.camera, { left: -14, right: 14, top: 11, bottom: -11, near: 1, far: 50 });
sun.shadow.bias = -0.0005;
sun.shadow.radius = 8;
scene.add(sun);
const fill = new THREE.DirectionalLight(0xe8f0ff, 0.3);
fill.position.set(10, 7, 6);
scene.add(fill);

const CL = { base: 0xeef1f5, wall: 0xf3f5f8, light: 0xe2e6ec, mid: 0xd2d8e1, dark: 0xb7bfcb, deep: 0x8f99a8 };
const M = (c, o) => new THREE.MeshStandardMaterial(Object.assign({ color: c, roughness: 0.62, metalness: 0.0 }, o || {}));
const clay = M(CL.base), clayW = M(0xfafbfd, { roughness: 0.7 }), clayL = M(CL.light), clayM = M(CL.mid), clayD = M(CL.dark), clayX = M(CL.deep);
const glass = new THREE.MeshPhysicalMaterial({ color: 0xffffff, roughness: 0.08, transparent: true, opacity: 0.35, depthWrite: false });

function roundedShape(w, d, r) {
  r = Math.min(r, w / 2, d / 2);
  const s = new THREE.Shape(), x = -w / 2, y = -d / 2;
  s.moveTo(x + r, y);
  s.lineTo(x + w - r, y); s.quadraticCurveTo(x + w, y, x + w, y + r);
  s.lineTo(x + w, y + d - r); s.quadraticCurveTo(x + w, y + d, x + w - r, y + d);
  s.lineTo(x + r, y + d); s.quadraticCurveTo(x, y + d, x, y + d - r);
  s.lineTo(x, y + r); s.quadraticCurveTo(x, y, x + r, y);
  return s;
}
// กล่องมุมมน + ขอบลบมน (bevel) ทุกด้าน ให้ผิวรับแสงนุ่มแบบดินปั้น
function roundedBox(w, h, d, r, bev) {
  const b = bev == null ? Math.min(0.05, h / 4, r / 2, w / 4, d / 4) : bev;
  const g = new THREE.ExtrudeGeometry(roundedShape(Math.max(w - b * 2, 0.01), Math.max(d - b * 2, 0.01), Math.max(r - b, 0.001)),
    { depth: Math.max(h - b * 2, 0.001), bevelEnabled: b > 0, bevelThickness: b, bevelSize: b, bevelSegments: 4, curveSegments: 10 });
  g.rotateX(-Math.PI / 2); g.translate(0, -h / 2 + b, 0);
  g.computeVertexNormals();
  return g;
}
function box(w, h, d, mat, x, y, z, r, bev) {
  const m = new THREE.Mesh(r ? roundedBox(w, h, d, r, bev) : new THREE.BoxGeometry(w, h, d), mat);
  m.position.set(x || 0, y || 0, z || 0); m.castShadow = true; m.receiveShadow = true; return m;
}
function cyl(rt, rb, h, mat, x, y, z, seg) {
  const m = new THREE.Mesh(new THREE.CylinderGeometry(rt, rb, h, seg || 28), mat);
  m.position.set(x || 0, y || 0, z || 0); m.castShadow = true; m.receiveShadow = true; return m;
}
function sphere(r, mat, x, y, z, sx, sy, sz) {
  const m = new THREE.Mesh(new THREE.SphereGeometry(r, 24, 18), mat);
  m.position.set(x || 0, y || 0, z || 0); m.scale.set(sx || 1, sy || 1, sz || 1); m.castShadow = true; m.receiveShadow = true; return m;
}
function capsule(r, len, mat, x, y, z) {
  const g = new THREE.Group();
  g.add(cyl(r, r, len, mat, 0, 0, 0, 16)); g.add(sphere(r, mat, 0, len / 2, 0)); g.add(sphere(r, mat, 0, -len / 2, 0));
  g.position.set(x || 0, y || 0, z || 0); return g;
}
function rr(x, a, b, w, h, r) {
  x.beginPath(); x.moveTo(a + r, b); x.arcTo(a + w, b, a + w, b + h, r); x.arcTo(a + w, b + h, a, b + h, r);
  x.arcTo(a, b + h, a, b, r); x.arcTo(a, b, a + w, b, r); x.closePath();
}
// ผนังโค้งบนแบบ ref: แผ่นหนา มุมบนมน
function wall(w, h, t, mat) {
  const s = new THREE.Shape(), r = Math.min(0.25, w / 4);
  s.moveTo(-w / 2, 0); s.lineTo(w / 2, 0); s.lineTo(w / 2, h - r); s.quadraticCurveTo(w / 2, h, w / 2 - r, h);
  s.lineTo(-w / 2 + r, h); s.quadraticCurveTo(-w / 2, h, -w / 2, h - r); s.closePath();
  const g = new THREE.ExtrudeGeometry(s, { depth: t, bevelEnabled: true, bevelThickness: 0.03, bevelSize: 0.03, bevelSegments: 3, curveSegments: 8 });
  g.translate(0, 0, -t / 2);
  const m = new THREE.Mesh(g, mat); m.castShadow = true; m.receiveShadow = true; return m;
}

// ================================================================ ห้อง
const room = new THREE.Group(); scene.add(room);
// แท่นพื้น diorama หนา มุมมน (เห็นขอบหน้าแบบ ref)
room.add(box(21, 0.5, 12.2, M(0xe4e9f0, { roughness: 0.8 }), 0, -0.25, 0.2, 0.9, 0.12));
room.add(box(21.2, 0.12, 12.4, clayM, 0, -0.52, 0.2, 0.95, 0.04));
// ผนังรอบ U: หลังยาว + ปีกซ้าย/ขวาเฉียงเข้า
const backW = wall(13.2, 2.9, 0.3, clayW); backW.position.set(0, 0, -5.6); room.add(backW);
const leftW = wall(6.4, 2.9, 0.3, clayW); leftW.position.set(-8.6, 0, -2.9); leftW.rotation.y = 0.78; room.add(leftW);
const rightW = wall(6.4, 2.9, 0.3, clayW); rightW.position.set(8.6, 0, -2.9); rightW.rotation.y = -0.78; room.add(rightW);
// เส้นแบ่งกระเบื้องบนพื้น (ร่องตื้น)
for (let i = -4; i <= 4; i++) { const l = box(0.02, 0.005, 10, clayL, i * 2.2, 0.003, 0.4); l.castShadow = false; room.add(l); }

// ---- ของในห้อง
function makeBed() {
  const g = new THREE.Group();
  g.add(box(1.05, 0.12, 2.15, clayW, 0, 0.52, 0, 0.1));
  const mat = box(0.98, 0.2, 2.0, clayW, 0, 0.69, 0.03, 0.14, 0.07); g.add(mat);
  g.add(box(0.72, 0.16, 0.4, clay, 0, 0.86, -0.72, 0.14, 0.07));
  g.add(box(1.1, 0.7, 0.1, clay, 0, 0.88, -1.08, 0.08));
  g.add(box(1.1, 0.4, 0.1, clay, 0, 0.72, 1.08, 0.08));
  [-0.57, 0.57].forEach(function (sx) { g.add(box(0.05, 0.18, 1.0, clayD, sx, 0.86, -0.15, 0.02)); });
  [[-0.43, -0.9], [0.43, -0.9], [-0.43, 0.9], [0.43, 0.9]].forEach(function (p) {
    g.add(cyl(0.03, 0.03, 0.45, clayD, p[0], 0.25, p[1], 8));
    g.add(sphere(0.06, clayX, p[0], 0.05, p[1]));
  });
  g.userData.mat = mat;
  return g;
}
function makePatient() {
  const g = new THREE.Group();
  const blanket = box(0.88, 0.24, 1.3, clayM, 0, 0.88, 0.3, 0.16, 0.08); g.add(blanket);
  g.add(box(0.66, 0.2, 0.42, clayL, 0, 0.88, -0.36, 0.12, 0.06));
  g.add(sphere(0.18, clay, 0, 1.02, -0.72));
  g.userData.blanket = blanket;
  return g;
}
// monitor บนรถเข็น (ref: จอบนเสา + ฐานล้อ)
function makeMonitorCart() {
  const g = new THREE.Group();
  g.add(box(0.5, 0.06, 0.5, clayM, 0, 0.06, 0, 0.1));
  g.add(cyl(0.035, 0.035, 1.1, clayD, 0, 0.62, 0, 10));
  g.add(box(0.46, 0.28, 0.36, clay, 0, 0.55, 0, 0.06));
  const scr = box(0.62, 0.46, 0.1, clay, 0, 1.38, 0, 0.06); g.add(scr);
  const face = box(0.52, 0.36, 0.02, clayX, 0, 1.39, 0.05); face.castShadow = false; g.add(face);
  g.userData.face = face;
  return g;
}
function makeIV() {
  const g = new THREE.Group();
  g.add(cyl(0.022, 0.022, 1.95, clayD, 0, 0.98, 0, 8));
  for (let i = 0; i < 4; i++) { const a = i / 4 * Math.PI * 2; const leg = box(0.3, 0.03, 0.04, clayD, Math.cos(a) * 0.14, 0.04, Math.sin(a) * 0.14); leg.rotation.y = -a; g.add(leg); }
  g.add(box(0.36, 0.03, 0.03, clayD, 0, 1.92, 0));
  g.add(box(0.15, 0.24, 0.07, clayL, 0.13, 1.74, 0, 0.04));
  return g;
}
// คนแบบ chibi นุ่ม (ref): ขา ลำตัวทรงกระบอกมน แขน หัวกลมใหญ่ ผม
function makePerson(kind) {
  const g = new THREE.Group();
  const top = kind === 'doc' ? clay : clayL;
  [-0.09, 0.09].forEach(function (sx) { g.add(capsule(0.075, 0.6, clayM, sx, 0.42, 0)); g.add(box(0.14, 0.08, 0.24, clayD, sx, 0.05, 0.04, 0.04)); });
  g.add(box(0.44, 0.62, 0.3, top, 0, 1.1, 0, 0.14, 0.08));
  if (kind === 'doc') g.add(box(0.48, 0.42, 0.34, top, 0, 0.78, 0, 0.14, 0.08));
  [-0.27, 0.27].forEach(function (sx) { const a = capsule(0.065, 0.42, top, sx, 1.08, 0.02); a.rotation.z = sx > 0 ? 0.1 : -0.1; g.add(a); g.add(sphere(0.06, clay, sx * 1.05, 0.8, 0.04)); });
  g.add(cyl(0.06, 0.07, 0.1, clay, 0, 1.46, 0, 10));
  g.add(sphere(0.19, clay, 0, 1.66, 0));
  g.add(sphere(0.2, clayD, 0, 1.72, -0.03, 1, 0.75, 1));
  return g;
}
function makeSeated() {
  const g = new THREE.Group();
  g.add(box(0.5, 0.08, 0.5, clayD, 0, 0.5, 0, 0.1)); g.add(cyl(0.04, 0.04, 0.45, clayD, 0, 0.25, 0, 8));
  g.add(box(0.42, 0.55, 0.28, clayL, 0, 0.88, 0, 0.14, 0.08));
  [-0.25, 0.25].forEach(function (sx) { const a = capsule(0.06, 0.32, clayL, sx, 0.9, 0.12); a.rotation.x = -1.0; g.add(a); });
  g.add(sphere(0.18, clay, 0, 1.36, 0)); g.add(sphere(0.19, clayD, 0, 1.42, -0.03, 1, 0.75, 1));
  return g;
}

// ป้าย ESI: แผ่นการ์ดหนามุมมน หน้าเป็น texture (clay = ขาว ตัวอักษรเทาเข้ม)
function badgeFace(level, count, hex) {
  const c = document.createElement('canvas'); c.width = 256; c.height = 220;
  const x = c.getContext('2d');
  if (CLAY) {
    const g = x.createLinearGradient(0, 0, 0, 220); g.addColorStop(0, '#ffffff'); g.addColorStop(1, '#e6eaf0');
    x.fillStyle = g; x.fillRect(0, 0, 256, 220);
    x.fillStyle = '#3f4a5c';
  } else {
    x.fillStyle = hex; x.fillRect(0, 0, 256, 220); x.fillStyle = '#fff';
  }
  x.textAlign = 'center';
  x.font = '700 50px -apple-system, "Helvetica Neue", sans-serif'; x.fillText('ESI ' + level, 128, 78);
  x.font = '800 110px -apple-system, "Helvetica Neue", sans-serif'; x.fillText(String(count), 128, 192);
  const t = new THREE.CanvasTexture(c); t.encoding = THREE.sRGBEncoding; t.anisotropy = 4; return t;
}
function makeBadge() {
  const g = new THREE.Group();
  const bw = 1.55, bh = 1.32, bd = 0.22;
  const body = new THREE.Mesh(roundedBox(bw, bd, bh, 0.2, 0.06), clay);
  body.rotation.x = Math.PI / 2; body.castShadow = true; g.add(body);
  const fw = bw - 0.1, fh = bh - 0.1;
  const faceGeo = new THREE.ShapeGeometry(roundedShape(fw, fh, 0.16));
  const pos = faceGeo.attributes.position, uv = faceGeo.attributes.uv;
  for (let i = 0; i < pos.count; i++) uv.setXY(i, pos.getX(i) / fw + 0.5, pos.getY(i) / fh + 0.5);
  const face = new THREE.Mesh(faceGeo, new THREE.MeshBasicMaterial({ toneMapped: false }));
  face.position.z = bd / 2 + 0.004; g.add(face);
  g.userData = { body: body, face: face };
  return g;
}

// ---- ห้องย่อย ESI: พื้นยกนิด + ผนังหลัง + ฉากข้างสองด้าน + เตียงหันหน้าเข้าหากลาง
//   x,z = กลางพื้นห้อง · rot = หมุนทั้งห้อง (ผนังหลังอยู่ -z ของห้อง)
const ZONES = [
  { x: -7.3, z: 0.2, rot: 0.78, bx: -6.9, by: 2.95, bz: 0.9 },
  { x: -3.9, z: -3.7, rot: 0.12, bx: -3.9, by: 3.35, bz: -3.2 },
  { x: 0.2, z: -4.1, rot: 0.0, bx: 0.2, by: 3.55, bz: -3.7 },
  { x: 4.3, z: -3.7, rot: -0.12, bx: 4.3, by: 3.35, bz: -3.2 },
  { x: 7.6, z: 0.2, rot: -0.78, bx: 7.2, by: 2.95, bz: 0.9 },
];
const zoneObjs = [], tapTargets = [];
ZONES.forEach(function (z, i) {
  const grp = new THREE.Group(); grp.position.set(z.x, 0, z.z); grp.rotation.y = z.rot; room.add(grp);
  const fl = box(3.5, 0.05, 3.2, clayM, 0, 0.025, 0, 0.12, 0.02); grp.add(fl);
  fl.userData.esi = i + 1; tapTargets.push(fl);
  // ฉากข้าง: ผนังเตี้ยมุมบนมน
  const sL = wall(2.6, 1.7, 0.12, clayW); sL.rotation.y = Math.PI / 2; sL.position.set(-1.78, 0, -0.25); grp.add(sL);
  const sR = wall(2.6, 1.7, 0.12, clayW); sR.rotation.y = Math.PI / 2; sR.position.set(1.78, 0, -0.25); grp.add(sR);
  // ชั้นวางของ/ตู้บนผนังหลัง + ปลั๊กหัวเตียง
  grp.add(box(1.2, 0.18, 0.12, clayM, 0, 1.5, -1.45, 0.05));
  const bed = makeBed(); bed.position.set(-0.15, 0.05, -0.15); grp.add(bed);
  const pt = makePatient(); pt.position.set(-0.15, 0.05, -0.15); grp.add(pt);
  const mon = makeMonitorCart(); mon.position.set(1.05, 0.05, -0.75); mon.rotation.y = -0.4; grp.add(mon);
  const iv = makeIV(); iv.position.set(-1.1, 0.05, -0.9); grp.add(iv);
  const bd = makeBadge(); bd.scale.setScalar(1.6); bd.position.set(z.bx, z.by, z.bz); scene.add(bd);
  bd.traverse(function (o) { if (o.isMesh) { o.userData.esi = i + 1; tapTargets.push(o); } });
  zoneObjs.push({ fl: fl, bed: bed, pt: pt, mon: mon, bd: bd, baseY: z.by, phase: i * 1.2 });
});

// ---- เจ้าหน้าที่ (ตำแหน่งตาม ref)
[[-4.4, -1.2, 0.3, 'doc'], [1.9, -1.9, -0.4, 'nurse'], [3.0, -1.4, -0.2, 'doc'], [4.9, 1.9, -0.5, 'nurse'], [-7.6, 2.7, 0.9, 'doc']].forEach(function (p) {
  const s = makePerson(p[3]); s.position.set(p[0], 0, p[1]); s.rotation.y = p[2]; room.add(s);
});

// ---- เคาน์เตอร์ ER หน้าซ้าย: ทรงโค้ง (ส่วนของวงแหวน) ท็อปยื่น + ป้าย ER + จอ + คนนั่ง
const desk = new THREE.Group(); desk.position.set(-4.5, 0, 4.0); desk.rotation.y = -0.45; desk.scale.setScalar(1.2); room.add(desk);
(function () {
  const s = new THREE.Shape();
  const R1 = 4.2, R2 = 3.1, a0 = -0.42, a1 = 0.42;
  s.absarc(0, 0, R1, a0, a1, false); s.absarc(0, 0, R2, a1, a0, true); s.closePath();
  const geo = (h, bev) => { const g = new THREE.ExtrudeGeometry(s, { depth: h, bevelEnabled: true, bevelThickness: bev, bevelSize: bev, bevelSegments: 4, curveSegments: 24 }); g.rotateX(-Math.PI / 2); return g; };
  const body = new THREE.Mesh(geo(1.0, 0.08), clay); body.position.set(0, 0.08, 0); body.castShadow = body.receiveShadow = true;
  const topp = new THREE.Mesh(geo(0.08, 0.05), clayL); topp.position.set(0, 1.18, 0); topp.scale.set(1.02, 1, 1.02); topp.castShadow = true;
  const baseB = new THREE.Mesh(geo(0.08, 0.02), clayM); baseB.position.set(0, 0.0, 0);
  [body, topp, baseB].forEach(function (m) { m.rotation.y = -Math.PI / 2; m.position.z -= 3.65; desk.add(m); });
})();
(function () {
  const c = document.createElement('canvas'); c.width = 512; c.height = 220;
  const x = c.getContext('2d');
  x.fillStyle = CLAY ? '#9aa4b4' : '#1d4fb8';
  rr(x, 20, 40, 130, 140, 34); x.fill();
  x.fillStyle = '#fff'; x.font = '800 100px -apple-system, sans-serif'; x.textAlign = 'center'; x.fillText('', 85, 150);
  x.fillStyle = CLAY ? '#6d7789' : '#1d4fb8'; x.textAlign = 'left'; x.font = '900 150px -apple-system, "Helvetica Neue", sans-serif'; x.fillText('ER', 175, 170);
  const t = new THREE.CanvasTexture(c); t.encoding = THREE.sRGBEncoding; t.anisotropy = 4;
  const p = new THREE.Mesh(new THREE.PlaneGeometry(1.5, 0.64), new THREE.MeshBasicMaterial({ map: t, transparent: true, toneMapped: false }));
  p.position.set(-0.3, 0.62, 0.68); p.rotation.y = -0.07; desk.add(p);
})();
desk.add(box(0.85, 0.55, 0.06, clay, 0.5, 1.75, -0.35, 0.04));
desk.add(box(0.75, 0.45, 0.02, clayX, 0.5, 1.75, -0.39));
desk.add(cyl(0.035, 0.035, 0.3, clayD, 0.5, 1.37, -0.38, 8));
desk.add(box(0.3, 0.03, 0.2, clayD, 0.5, 1.23, -0.38, 0.03));
const clerk = makeSeated(); clerk.position.set(0.6, 0, -1.25); clerk.rotation.y = 0.0; desk.add(clerk);

// ---- ต้นไม้กระถางหน้าซ้าย
(function () {
  const g = new THREE.Group(); g.position.set(-9.0, 0, 3.4); room.add(g);
  g.add(cyl(0.34, 0.26, 0.55, clayD, 0, 0.28, 0, 24));
  for (let i = 0; i < 16; i++) {
    const a = i / 16 * Math.PI * 2, k = i % 2 ? 0.7 : 1;
    const l = sphere(0.22, clayM, Math.cos(a) * 0.22, 1.0 + k * 0.15, Math.sin(a) * 0.22, 0.42, 1.5 * k, 0.2);
    l.rotation.set(Math.sin(a) * 0.65, a, -Math.cos(a) * 0.65); g.add(l);
  }
})();

// ---- แท่นกลาง + วงโดนัทตั้ง
const hub = new THREE.Group(); hub.position.set(0.0, 0, 3.3); room.add(hub);
hub.add(cyl(2.35, 2.45, 0.18, clay, 0, 0.09, 0, 72));
hub.add(cyl(2.05, 2.1, 0.1, clayL, 0, 0.23, 0, 72));
const glassRing = new THREE.Mesh(new THREE.TorusGeometry(2.0, 0.07, 12, 96), glass);
glassRing.rotation.x = Math.PI / 2; glassRing.position.y = 0.32; hub.add(glassRing);
hub.add(cyl(0.5, 0.65, 0.35, clayL, 0, 0.45, 0, 40));
const ring = new THREE.Group(); ring.position.y = 1.85; ring.scale.setScalar(1.05); hub.add(ring);
const disc = cyl(1.12, 1.12, 0.3, clay, 0, 0, 0, 72); disc.rotation.x = Math.PI / 2; ring.add(disc);
const lip = new THREE.Mesh(new THREE.TorusGeometry(1.12, 0.06, 12, 72), clayL); lip.position.z = 0.15; ring.add(lip);
let segs = [];
const centerTex = (function () {
  const c = document.createElement('canvas'); c.width = c.height = 256;
  const t = new THREE.CanvasTexture(c); t.encoding = THREE.sRGBEncoding; t.userData = { c: c }; return t;
})();
const centerFace = new THREE.Mesh(new THREE.CircleGeometry(1.08, 72), new THREE.MeshBasicMaterial({ map: centerTex, transparent: true, toneMapped: false }));
centerFace.position.z = 0.155; ring.add(centerFace);
function drawCenter(total) {
  const c = centerTex.userData.c, x = c.getContext('2d');
  x.clearRect(0, 0, 256, 256);
  x.fillStyle = '#2b3445'; x.textAlign = 'center';
  x.font = '800 108px -apple-system, "Helvetica Neue", sans-serif'; x.fillText(String(total), 128, 140);
  x.fillStyle = '#4b5563'; x.font = '700 38px -apple-system, "Sukhumvit Set", sans-serif'; x.fillText('ผู้ป่วย', 128, 192);
  centerTex.needsUpdate = true;
}
function buildRing(counts, colors, totalShown) {
  segs.forEach(function (s) { ring.remove(s); s.geometry.dispose(); });
  segs = [];
  const total = counts.reduce(function (a, b) { return a + b; }, 0);
  const live = counts.map(function (n, i) { return { n: n, i: i }; }).filter(function (o) { return o.n > 0; });
  const gap = live.length > 1 ? 0.035 : 0;
  // clay: ไล่เฉดเทาสลับ ให้เห็นรอยแบ่งสัดส่วน
  const greys = [0xffffff, 0xe7eaf0, 0xf6f7fa, 0xdfe3ea, 0xeef1f5];
  let a0 = Math.PI / 2;
  live.forEach(function (o, k) {
    const arc = (o.n / Math.max(total, 1)) * Math.PI * 2 - gap;
    const g = new THREE.TorusGeometry(1.62, 0.42, 24, Math.max(12, Math.round(arc * 28)), Math.max(arc, 0.01));
    const m = new THREE.Mesh(g, CLAY ? M(greys[k % greys.length], { roughness: 0.45 }) : M(colors[o.i], { roughness: 0.35 }));
    m.rotation.z = a0 - arc; m.castShadow = true; m.scale.z = 0.75;
    ring.add(m); segs.push(m);
    a0 -= arc + gap;
  });
  drawCenter(totalShown != null ? totalShown : total);
}

// ---- สถานะจากแอป
let state = { total: null, counts: [0, 0, 0, 0, 0], colors: ['#BE1E2D', '#AF1EBE', '#DC8610', '#006838', '#465054'], sel: null };
window.erOvSet = function (s) {
  state = Object.assign(state, s);
  zoneObjs.forEach(function (z, i) {
    const n = state.counts[i];
    z.pt.visible = n > 0;
    const u = z.bd.userData;
    u.face.material.map && u.face.material.map.dispose();
    u.face.material.map = badgeFace(i + 1, n, state.colors[i]); u.face.material.needsUpdate = true;
    const dim = state.sel != null && state.sel !== i + 1;
    u.face.material.transparent = dim; u.face.material.opacity = dim ? 0.45 : 1;
  });
  buildRing(state.counts, state.colors, state.total);
  renderer.shadowMap.needsUpdate = true;
};

// ---- กล้อง: หน้าตรง สูงเฉียงลง ~32° (ตาม ref)
const target = new THREE.Vector3(0.0, -0.6, -0.6);
const CAM = { az: 0.0, r: 18.2, h: 11.0 };
function placeCam(t) {
  const az = CAM.az + Math.sin(t * 0.00011) * 0.03;
  camera.position.set(target.x + Math.sin(az) * CAM.r, CAM.h, target.z + Math.cos(az) * CAM.r);
  camera.lookAt(target);
}
window.erOvCam = function (o) { Object.assign(CAM, o); if (o.tx != null) target.x = o.tx; if (o.ty != null) target.y = o.ty; if (o.tz != null) target.z = o.tz; if (o.fov) { camera.fov = o.fov; camera.updateProjectionMatrix(); } };
function fit() {
  renderer.setSize(W(), H());
  camera.aspect = W() / H();
  const need = 2.1;
  camera.fov = camera.aspect < need ? 30 * need / camera.aspect : 30;
  camera.updateProjectionMatrix();
}
window.addEventListener('resize', fit);
fit();

const ray = new THREE.Raycaster(), ptr = new THREE.Vector2();
renderer.domElement.addEventListener('pointerup', function (e) {
  ptr.set(e.clientX / W() * 2 - 1, -(e.clientY / H()) * 2 + 1);
  ray.setFromCamera(ptr, camera);
  const hit = ray.intersectObjects(tapTargets, false)[0];
  if (hit) send({ type: 'tap', esi: hit.object.userData.esi });
});

let last = 0;
const tmp = new THREE.Vector3();
function loop(t) {
  requestAnimationFrame(loop);
  if (t - last < 33) return;
  last = t;
  placeCam(t);
  zoneObjs.forEach(function (z) {
    z.bd.position.y = z.baseY + Math.sin(t * 0.0015 + z.phase) * 0.06;
    tmp.set(camera.position.x, z.bd.position.y, camera.position.z);
    z.bd.lookAt(tmp);
  });
  tmp.set(camera.position.x, ring.getWorldPosition(new THREE.Vector3()).y + 2.5, camera.position.z);
  ring.lookAt(tmp);
  renderer.render(scene, camera);
}
window.erOvSet({});
requestAnimationFrame(loop);
send({ type: 'ready' });
''';
