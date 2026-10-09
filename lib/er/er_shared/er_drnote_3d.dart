/// มาสคอต Dr.Note แบบสามมิติ (สมุดโน้ตใส่แว่น + ปากกาลอย)
///
/// โมเดล assets/models/drnote.glb ปั้นใน Blender มี rig + 3 ท่า
/// idle = ลอยหายใจ · listen = โน้มฟัง ปากกายกเตรียมเขียน · write = ปากกาเขียนลงตัวตอนผู้ใช้พูด
/// มือถือเปิดใน WebView ผ่าน HttpServer ในเครื่อง · เว็บใช้ iframe ([ErWebFrame])
/// แบบเดียวกับฉากสามมิติอื่นของ ER (ErRing3D)
library;

import 'dart:convert';
import 'er_web_alive.dart';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'er_web_frame.dart';

/// ท่าของ Dr.Note (ชื่อตรงกับ action ในไฟล์ glb)
/// generate = กำลังสร้าง/สรุปด้วย AI: ปากกา morph เป็นดาว sparkle 3D หมุนวิบวับ
enum ErDrNoteMode { idle, listen, write, think, idea, generate }

class ErDrNote3D extends StatefulWidget {
  const ErDrNote3D(
      {super.key,
      this.mode = ErDrNoteMode.idle,
      this.pose,
      this.onReady,
      this.intro = false});

  final ErDrNoteMode mode;

  /// เข้าฉาก: โผล่ขึ้นจากขอบล่างกรอบพร้อมหมุน 1 รอบ (ease out)
  final bool intro;

  /// โมเดลโหลดเสร็จพร้อมแสดง (ใช้เริ่ม animation ที่ต้องเห็นตัวจริง)
  final VoidCallback? onReady;

  /// มุมหมุน x, y, z (เรเดียน) + ขนาด · null = ค่าตั้งต้นในฉาก (ใช้กับ debugger)
  final (double, double, double, double)? pose;

  @override
  State<ErDrNote3D> createState() => _ErDrNote3DState();
}

class _ErDrNote3DState extends State<ErDrNote3D> {
  WebViewController? _web;

  /// heartbeat กัน WKWebView ล่มตอน hot restart (ดู ErWebAlive)
  late final ErWebAlive _alive = ErWebAlive((js) => _web?.runJavaScript(js));
  HttpServer? _server;
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
    _boot();
  }

  @override
  void didUpdateWidget(covariant ErDrNote3D old) {
    super.didUpdateWidget(old);
    if (old.mode != widget.mode) _pushMode();
    if (old.pose != widget.pose) _pushPose();
  }

  @override
  void dispose() {
    _alive.stop();
    _server?.close(force: true);
    _frame?.dispose();
    super.dispose();
  }

  static const _files = {
    '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
    '/GLTFLoader.js': ['assets/web/GLTFLoader.js', 'application/javascript'],
    '/drnote.glb': ['assets/models/drnote.glb', 'model/gltf-binary'],
  };

  /// หน้า HTML ของฉาก (เปิดท่าเข้าฉากตาม [ErDrNote3D.intro])
  String get _page => widget.intro
      ? _html.replaceFirst('const INTRO = false;', 'const INTRO = true;')
      : _html;

  Future<void> _boot() async {
    if (kIsWeb) {
      setState(() => _frame = ErWebFrame(
            html: _page,
            channel: 'ErDrNote',
            routes: [
              for (final e in _files.entries)
                ('^${RegExp.escape(e.key)}\$', e.value[0], e.value[1]),
            ],
            onMessage: (m) => _onMessage(JavaScriptMessage(message: m)),
          ));
      return;
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path == '/' || req.uri.path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
        req.response.write(_page);
        await req.response.close();
        return;
      }
      final f = _files[req.uri.path];
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
    if (!mounted) {
      server.close(force: true);
      return;
    }
    _server = server;
    debugPrint('ErDrNote3D เปิด server ${server.port}');
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('ErDrNote', onMessageReceived: _onMessage)
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    setState(() => _web = controller);
    _alive.start();
  }

  void _js(String js) {
    if (!_ready) return;
    if (_frame != null) {
      _frame!.run(js);
      return;
    }
    _web?.runJavaScript(js);
  }

  void _pushMode() => _js("window.drMode('${widget.mode.name}')");

  void _pushPose() {
    final p = widget.pose;
    if (p == null) return;
    _js('window.drPose(${p.$1}, ${p.$2}, ${p.$3}, ${p.$4})');
  }

  void _onMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        debugPrint('ErDrNote3D พร้อม ${message.message}');
        _ready = true;
        _pushMode();
        _pushPose();
        widget.onReady?.call();
        break;
      case 'error':
        debugPrint('ErDrNote3D ผิดพลาด: ${data['message']}');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ไม่รับการแตะ (เป็นภาพประกอบ) ให้แตะผ่านไปถึงการ์ดด้านหลัง
    final Widget view = _frame != null
        ? _frame!.view()
        : _web == null
            ? const SizedBox.shrink()
            : WebViewWidget(controller: _web!);
    return IgnorePointer(child: view);
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
  canvas { display:block; }
</style>
<script src="three.min.js"></script>
<script src="GLTFLoader.js"></script>
</head>
<body>
<script>
function post(o) { if (window.__erDbg && Date.now() - (window.__erAlive || 0) > 700) return; if (window.ErDrNote) window.ErDrNote.postMessage(JSON.stringify(o)); }
window.onerror = function (m) { post({ type: 'error', message: String(m) }); };

const scene = new THREE.Scene();
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
// มาสคอตเล็ก: ความละเอียด 1.25 พอ
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.25));
renderer.setClearColor(0x000000, 0);
renderer.outputEncoding = THREE.sRGBEncoding;
document.body.appendChild(renderer.domElement);

// กล้องมองเฉียงเล็กน้อยจากขวาหน้า เห็นปากกาลอยข้างตัว
const cam = new THREE.PerspectiveCamera(26, 1, 0.05, 50);
cam.position.set(1.1, 1.35, 5.2);
cam.lookAt(0.12, 1.02, 0);

scene.add(new THREE.HemisphereLight(0xffffff, 0x9aa6c8, 1.05));
const key = new THREE.DirectionalLight(0xffffff, 1.35); key.position.set(3, 5, 4); scene.add(key);
const rim = new THREE.DirectionalLight(0xd6deff, 0.7); rim.position.set(-4, 3, -3); scene.add(rim);

function size() {
  const w = window.innerWidth, h = window.innerHeight;
  renderer.setSize(w, h); // ตั้ง CSS size ด้วย (dpr 2 ไม่งั้น canvas ใหญ่เกินกรอบ)
  cam.aspect = w / h;
  // กรอบกว้างกว่า 4:3 = ที่ว่างสำหรับ bubble ทางขวา: ตัวยังชิดซ้ายเหมือนกรอบ 4:3
  const w0 = Math.min(w, h * 4 / 3);
  cam.userData.shift = w > w0 + 1 ? (w - w0) / 2 : 0;
  cam.updateProjectionMatrix();
}
size(); window.addEventListener('resize', size);

let mixer = null, clips = {}, current = null, want = 'idle', root = null, base = null;
// เข้าฉาก (ฝั่ง Dart แทนค่า): โผล่จากขอบล่างกรอบ + หมุน 1 รอบ ease out
const INTRO = false;
const INTRO_DUR = 1.0;
let intro = null;
// มุมท่า (เรเดียน) + ขนาด · ปรับสดได้จาก debugger ผ่าน window.drPose
const POSE = { x: -0.35, y: 0.42, z: 0.24, s: 0.9 };
window.drPose = function (x, y, z, s) {
  POSE.x = x; POSE.y = y; POSE.z = z; POSE.s = s;
  if (root) { root.rotation.set(x, y, z); root.scale.setScalar(s); }
};
window.drMode = function (name) {
  want = name;
  // ท่าคิดไม่มีคลิปในโมเดล: ใช้คลิปฟัง (ปากกาลอยนิ่ง) แล้วทำท่าหน้า/ตัวเพิ่มด้วยโค้ด
  const clip = clips[name] ? name : ((name === 'think' || name === 'idea' || name === 'generate') ? 'listen' : name);
  if (!mixer || !clips[clip]) return;
  const next = mixer.clipAction(clips[clip]);
  if (current === next) return;
  next.reset().setLoop(THREE.LoopRepeat).fadeIn(0.3).play();
  if (current) current.fadeOut(0.3);
  current = next;
};

new THREE.GLTFLoader().load('drnote.glb', function (gltf) {
  scene.add(gltf.scene);
  mixer = new THREE.AnimationMixer(gltf.scene);
  gltf.animations.forEach(function (c) { clips[c.name] = c; });
  window.drMode(want);
  // ปกหน้า: เข้ามาแล้วเปิดปก (ปกเริ่มปิดทับหน้า แล้วพลิกข้ามห่วงไปด้านหลัง)
  setupCover(gltf.scene);
  // ปากกาใหญ่ขึ้น (จุดหมุนอยู่ที่หัวปากกา ขยายแล้วหัวยังแตะกระดาษเหมือนเดิม)
  const pen = gltf.scene.getObjectByName('pen');
  if (pen) pen.scale.multiplyScalar(1.9);
  // หน้า (ตา แว่น ปาก) ลอยอิสระจากตัว: รวมไว้ใต้จุดหมุนกลางหน้า ให้หันมองไปมาได้
  setupFace(gltf.scene);
  // หมุนรอบจุดกึ่งกลางตัว (ไม่ใช่ที่เท้า) ตัวจึงอยู่ในกรอบเสมอไม่ว่าจะหมุนแกนไหน
  gltf.scene.updateMatrixWorld(true);
  const box0 = new THREE.Box3();
  gltf.scene.traverse(function (o) { if (o.isMesh && !/^(pen|ink)/.test(o.name)) box0.expandByObject(o); });
  const c0 = box0.getCenter(new THREE.Vector3());
  const pivot = new THREE.Group();
  scene.remove(gltf.scene);
  pivot.add(gltf.scene);
  gltf.scene.position.sub(c0);
  // กลุ่มกดอยู่นอกท่าหมุน: เอียงรอบแกนแนวนอนของจอ ทั้งตัวยุบลงพร้อมกัน (ไม่ใช่มุมเดียว)
  press = new THREE.Group();
  press.add(pivot);
  // กลุ่มนอกสุดสำหรับท่าเข้าฉาก (เลื่อน/หมุนทั้งตัวโดยไม่ชนท่าอื่น)
  const introG = new THREE.Group();
  introG.add(press);
  scene.add(introG);
  root = pivot;
  pivot.rotation.set(POSE.x, POSE.y, POSE.z);
  pivot.scale.setScalar(POSE.s);
  // กล้องพอดีทรงกลมที่ครอบตัว (หมุนแล้วก็ยังพอดี)
  const sph = box0.getBoundingSphere(new THREE.Sphere());
  // chat bubble 3D ผูกกับกระดูกปากกา (ลอยตามปากกา) · กำลังคิด = ปากกา morph เป็น bubble
  setupBubble(gltf.scene, sph.radius);
  setupBulb(sph.radius);
  setupSpark(sph.radius);
  const half = THREE.MathUtils.degToRad(cam.fov / 2);
  const rFit = sph.radius * 0.92;
  const dist = Math.max(rFit / Math.sin(half), rFit / Math.sin(Math.atan(Math.tan(half) * cam.aspect)));
  const look = new THREE.Vector3(0, 0, 0);
  // fit ตามกรอบ 4:3 (ตัวขนาดเดิม) แล้วเลื่อนกล้องไปขวาให้ตัวชิดซ้าย เหลือที่ให้ bubble
  const a0 = Math.min(cam.aspect, 4 / 3);
  const dist0 = Math.max(rFit / Math.sin(half), rFit / Math.sin(Math.atan(Math.tan(half) * a0)));
  const pxW = 2 * dist0 * Math.tan(half) / innerHeight;  // หน่วยโลกต่อ 1 px
  cam.position.set((cam.userData.shift || 0) * pxW, 0, dist0);
  cam.lookAt(new THREE.Vector3((cam.userData.shift || 0) * pxW, 0, 0));
  void dist; void look;
  if (INTRO) {
    // เริ่มใต้ขอบล่างกรอบเต็มความสูงภาพ
    intro = { g: introG, t: 0, c: 0, h: 2 * dist0 * Math.tan(half) };
    introG.position.y = -intro.h;
  }
  post({ type: 'ready', gl: !!renderer.getContext(), w: innerWidth, h: innerHeight,
    box: [box0.min.x, box0.min.y, box0.min.z, box0.max.x, box0.max.y, box0.max.z].map(function (v) { return +v.toFixed(2); }),
    anims: Object.keys(clips) });
}, undefined, function (e) { post({ type: 'error', message: String(e) }); });

// ------------------------------------------------ คิด: ปากกา morph เป็น chat bubble 3D (มีจุด ... เด้ง)
let bub = null;
function setupBubble(root, R) {
  const bone = root.getObjectByName('pen');
  if (!bone) return;
  const penMesh = bone.children.find(function (o) { return o.isMesh; }) || bone.children[0];
  if (!penMesh) return;
  // bubble อยู่ในพิกัดโลก (ไม่ผูกกับกระดูกปากกา) จะได้วางให้อยู่ในกรอบภาพเสมอ
  const w = R * 0.7;
  const g = new THREE.Group();
  const white = new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 0.35, metalness: 0.0 });
  // ตัว bubble: แคปซูลนอน (ขอบมน) + หางกรวยชี้ลงซ้ายไปทางตัว
  // three r128 ไม่มี CapsuleGeometry: ใช้ทรงกลมยืดเป็นวงรีแบน ๆ แทน
  const body = new THREE.Mesh(new THREE.SphereGeometry(w * 0.5, 32, 20), white);
  body.scale.set(1.0, 0.62, 0.32);
  g.add(body);
  const tail = new THREE.Mesh(new THREE.ConeGeometry(w * 0.12, w * 0.28, 16), white);
  tail.position.set(-w * 0.28, -w * 0.3, 0);
  tail.rotation.z = Math.PI - 0.5;
  g.add(tail);
  const navy = new THREE.MeshStandardMaterial({ color: 0x0b2a7a, roughness: 0.4 });
  const dots = [];
  for (let i = 0; i < 3; i++) {
    const d = new THREE.Mesh(new THREE.SphereGeometry(w * 0.075, 16, 12), navy);
    d.position.set((i - 1) * w * 0.24, 0, w * 0.15);
    g.add(d);
    dots.push(d);
  }
  g.scale.setScalar(0.0001);
  scene.add(g);
  bub = { g: g, bone: bone, pen: penMesh, dots: dots, k: 0, t: 0, w: w };
}

const _q = new THREE.Quaternion(), _v = new THREE.Vector3();
function bubbleStep(dt) {
  if (!bub) return;
  bub.t += dt;
  const target = want === 'think' ? 1 : 0;
  // เข้า = เร็วกว่าออกเล็กน้อย · ค่าระหว่าง 0..1
  bub.k += (target - bub.k) * Math.min(1, dt * (target ? 5 : 4));
  const k = bub.k;
  // ปากกาหดหมุนหายตอน bubble โผล่ (และกลับกัน) = morph
  // ปากกาหดหมุนหาย: ใช้ค่าที่มากกว่าระหว่าง bubble กับหลอดไฟ (morph ได้ทั้งสองแบบ)
  const km = Math.max(k, bulb ? bulb.k : 0, spark ? spark.k : 0);
  // ท่า generate: ไม่มีปากกาเลย (ดาวแทน) แม้ช่วงโผล่/จม
  const penS = want === 'generate' ? 0.0001 : Math.max(0.0001, 1 - Math.min(1, km * 1.6));
  bub.pen.scale.setScalar(penS);
  bub.pen.rotation.y = km * Math.PI;
  // bubble ขยายแบบเด้ง (easeOutBack) + หมุนเข้ามา
  const kb = Math.max(0, (k - 0.25) / 0.75);
  const c1 = 1.70158, c3 = c1 + 1;
  const eb = kb <= 0 ? 0 : 1 + c3 * Math.pow(kb - 1, 3) + c1 * Math.pow(kb - 1, 2);
  bub.g.scale.setScalar(Math.max(0.0001, eb));
  // มุมขวาบนของภาพ (กล้องมองตรงที่จุดกลางตัว: +x = ขวา · +y = บน) ไม่บังหน้า
  bub.g.position.set(cam.position.x + bub.w * 1.05, bub.w * 0.42, bub.w * 0.9);
  // หันหน้าเข้ากล้องเสมอ + ส่ายเบา ๆ
  bub.g.quaternion.copy(cam.quaternion);
  bub.g.rotateZ(0.06 * Math.sin(bub.t * 2.0) + (1 - eb) * 0.8);
  // จุด ... เด้งไล่กัน
  bub.dots.forEach(function (d, i) {
    const ph = (bub.t * 1.1 - i * 0.18) % 1.0;
    const up = ph < 0.45 && ph > 0 ? Math.sin(ph / 0.45 * Math.PI) : 0;
    d.position.y = up * bub.w * 0.12;
  });
}

// ------------------------------------------------ มีไอเดีย: ปากกา morph เป็นหลอดไฟ 3D ที่ติดไฟ
let bulb = null;
// ลำดับท่า "มีไอเดีย": รอโผล่จากใต้การ์ด (ฝั่ง Flutter) → หมุนตัว 1 รอบ → หลอดไฟโผล่
let ideaT = -1;
const IDEA_WAIT = 0.75, IDEA_SPIN = 0.9;
function ideaStep(dt) {
  if (!root) return;
  if (want !== 'idea') { ideaT = -1; root.rotation.y = POSE.y; return; }
  if (ideaT < 0) ideaT = 0;
  ideaT += dt;
  const k = Math.min(Math.max((ideaT - IDEA_WAIT) / IDEA_SPIN, 0), 1);
  // หมุนรอบตัวแบบเร่งแล้วผ่อน
  const e = k < 0.5 ? 4 * k * k * k : 1 - Math.pow(-2 * k + 2, 3) / 2;
  root.rotation.y = POSE.y + e * Math.PI * 2;
}
function ideaReady() { return want === 'idea' && ideaT >= IDEA_WAIT + IDEA_SPIN; }
function setupBulb(R) {
  const w = R * 0.7;
  const g = new THREE.Group();
  // กระเปาะ: โปรไฟล์หลอดไฟหมุนรอบแกน (lathe) สีเหลืองอุ่นโปร่ง
  const prof = [];
  for (let i = 0; i <= 24; i++) {
    const t = i / 24, a = Math.PI * (0.08 + 0.92 * t);
    let r = Math.sin(a) * 0.5, y = Math.cos(a) * 0.5 + 0.2;
    if (t > 0.72) { const k = (t - 0.72) / 0.28; r = r * (1 - k) + 0.2 * k; y = y * (1 - k) + (-0.34) * k; }
    prof.push(new THREE.Vector2(Math.max(r, 0.001), y));
  }
  prof.reverse();
  const glass = new THREE.MeshStandardMaterial({ color: 0xffe08a, emissive: 0xffb020,
    emissiveIntensity: 0, roughness: 0.15, transparent: true, opacity: 0.78, depthWrite: false });
  g.add(new THREE.Mesh(new THREE.LatheGeometry(prof, 40), glass));
  // ไส้: ขดลวดเรืองแสง
  const pts = [];
  for (let i = 0; i <= 60; i++) {
    const t = i / 60, a = t * Math.PI * 8;
    pts.push(new THREE.Vector3(-0.17 + 0.34 * t, 0.24 + Math.sin(a) * 0.035, Math.cos(a) * 0.035));
  }
  const glowMat = new THREE.MeshBasicMaterial({ color: 0xff8a00, depthTest: false });
  const coil = new THREE.Mesh(new THREE.TubeGeometry(new THREE.CatmullRomCurve3(pts), 120, 0.02, 6, false), glowMat);
  coil.renderOrder = 2; g.add(coil);
  // คอเกลียว + จุก
  const cap = new THREE.MeshStandardMaterial({ color: 0xb8b4c8, metalness: 0.85, roughness: 0.3 });
  for (let i = 0; i < 3; i++) {
    const ring = new THREE.Mesh(new THREE.TorusGeometry(0.205 - i * 0.008, 0.026, 10, 32), cap);
    ring.rotation.x = Math.PI / 2; ring.position.y = -0.38 - i * 0.065; g.add(ring);
  }
  const neck = new THREE.Mesh(new THREE.CylinderGeometry(0.2, 0.18, 0.26, 24), cap);
  neck.position.y = -0.46; g.add(neck);
  const tip = new THREE.Mesh(new THREE.SphereGeometry(0.11, 16, 8, 0, Math.PI * 2, Math.PI / 2, Math.PI / 2),
    new THREE.MeshStandardMaterial({ color: 0x0b2a7a, roughness: 0.4 }));
  tip.position.y = -0.59; g.add(tip);
  // ประกายรอบหลอด
  const rayMat = new THREE.MeshBasicMaterial({ color: 0xf59e0b, transparent: true, opacity: 0 });
  const rays = [];
  for (let i = 0; i < 5; i++) {
    const a = Math.PI * (0.15 + 0.7 * i / 4);
    const m = new THREE.Mesh(new THREE.CylinderGeometry(0.02, 0.02, 0.14, 6), rayMat);
    m.userData.a = a; g.add(m); rays.push(m);
  }
  const light = new THREE.PointLight(0xffc46b, 0, 2.5); light.position.y = 0.24; g.add(light);
  g.scale.setScalar(0.0001);
  scene.add(g);
  bulb = { g: g, w: w, k: 0, t: 0, on: 0, glass: glass, glow: glowMat, rays: rays, rayMat: rayMat, light: light };
}
function bulbStep(dt) {
  if (!bulb) return;
  bulb.t += dt;
  const target = ideaReady() ? 1 : 0;
  bulb.k += (target - bulb.k) * Math.min(1, dt * (target ? 5 : 4));
  // เด้งขึ้นแบบ easeOutBack หลังปากกาเริ่มหด
  const kb = Math.max(0, (bulb.k - 0.25) / 0.75);
  const c1 = 1.70158, c3 = c1 + 1;
  const eb = kb <= 0 ? 0 : 1 + c3 * Math.pow(kb - 1, 3) + c1 * Math.pow(kb - 1, 2);
  bulb.g.scale.setScalar(Math.max(0.0001, eb * bulb.w * 0.95));
  // ติดไฟหลังเด้งเสร็จ (วาบแล้วหายใจ)
  bulb.on += ((bulb.k > 0.9 ? 1 : 0) - bulb.on) * Math.min(1, dt * 3);
  const glow = bulb.on * (0.8 + 0.2 * Math.sin(bulb.t * 2.6));
  bulb.glass.emissiveIntensity = 0.9 * glow;
  bulb.glow.color.setRGB(1, 0.45 + 0.35 * glow, 0.05 + 0.2 * glow);
  bulb.light.intensity = 1.6 * glow;
  bulb.rayMat.opacity = bulb.on * (0.6 + 0.35 * Math.sin(bulb.t * 3));
  bulb.rays.forEach(function (m, i) {
    const d = 0.62 + 0.04 * Math.sin(bulb.t * 3 + i);
    m.position.set(Math.cos(m.userData.a) * d, 0.24 + Math.sin(m.userData.a) * d, 0);
    m.rotation.z = m.userData.a - Math.PI / 2;
  });
  // ตำแหน่งเดียวกับ bubble: ข้างตัวทางขวาบน หันเข้ากล้อง ลอยเบา ๆ
  bulb.g.position.set(cam.position.x + bulb.w * 1.25, bulb.w * 0.2 + Math.sin(bulb.t * 1.6) * bulb.w * 0.04, bulb.w * 0.9);
  bulb.g.quaternion.copy(cam.quaternion);
  bulb.g.rotateZ(-0.12 + 0.06 * Math.sin(bulb.t * 1.1) + (1 - eb) * 0.8);
}

// ------------------------------------------------ generate: ปากกา morph เป็นดาว sparkle (แบบไอคอน AI)
// ดาว 4 แฉกขอบเว้า 1 ดวงใหญ่ + 2 ดวงเล็ก · หมุน วิบวับ ไล่จังหวะกัน
let spark = null, spark_big = null;
function sparkShape() {
  // ดาว 4 แฉกแบบไอคอน AI: แฉกตั้งยาวกว่าแฉกนอน ขอบเว้าโค้งนุ่ม (cubic)
  const sh = new THREE.Shape(), v = 1.0, h = 0.82, k = 0.06;
  sh.moveTo(0, v);
  sh.bezierCurveTo(k, v * 0.32, h * 0.32, k, h, 0);
  sh.bezierCurveTo(h * 0.32, -k, k, -v * 0.32, 0, -v);
  sh.bezierCurveTo(-k, -v * 0.32, -h * 0.32, -k, -h, 0);
  sh.bezierCurveTo(-h * 0.32, k, -k, v * 0.32, 0, v);
  return sh;
}
function sparkGeo(a, b) {
  const geo = new THREE.ExtrudeGeometry(sparkShape(), { depth: 0.06, bevelEnabled: true,
    bevelThickness: 0.12, bevelSize: 0.04, bevelSegments: 8, curveSegments: 40 });
  geo.center();
  // ไล่สีในดวง: สี a (บนซ้าย) → สี b (ล่างขวา)
  const p = geo.attributes.position, col = [];
  const A = new THREE.Color(a), B = new THREE.Color(b), t = new THREE.Color();
  for (let i = 0; i < p.count; i++) {
    const u = Math.min(1, Math.max(0, (p.getX(i) - p.getY(i)) / 2.4 + 0.5));
    // สีที่กำหนดเป็น sRGB: แปลงเป็น linear ก่อน ไม่งั้นออกมาซีดเกือบขาว
    t.copy(A).lerp(B, u).convertSRGBToLinear();
    col.push(t.r, t.g, t.b);
  }
  geo.setAttribute('color', new THREE.Float32BufferAttribute(col, 3));
  return geo;
}
function sparkGlow() {
  const c = document.createElement('canvas'); c.width = c.height = 128;
  const x = c.getContext('2d');
  const g = x.createRadialGradient(64, 64, 0, 64, 64, 64);
  g.addColorStop(0, 'rgba(140,160,255,0.55)'); g.addColorStop(0.4, 'rgba(155,114,203,0.2)');
  g.addColorStop(1, 'rgba(155,114,203,0)');
  x.fillStyle = g; x.fillRect(0, 0, 128, 128);
  return new THREE.CanvasTexture(c);
}
function setupSpark(R) {
  const w = R * 0.7;
  const g = new THREE.Group();
  // ผิวมันเงาแบบ clearcoat + เรืองแสงอ่อน
  const mat = new THREE.MeshPhysicalMaterial({ vertexColors: true, roughness: 0.18, metalness: 0,
    clearcoat: 1, clearcoatRoughness: 0.15 });
  const halo = new THREE.Sprite(new THREE.SpriteMaterial({ map: sparkGlow(), depthWrite: false, transparent: true }));
  halo.scale.setScalar(2.0); g.add(halo);
  const bigMat = new THREE.ShaderMaterial({
    uniforms: { uT: { value: 0 } },
    vertexShader: 'varying vec3 vP; varying vec3 vN; void main(){ vP = position; vN = normalize(normalMatrix * normal);'
      + ' gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0); }',
    fragmentShader: [
      'uniform float uT; varying vec3 vP; varying vec3 vN;',
      'vec3 lin(vec3 c){ return pow(c, vec3(2.2)); }',
      'void main(){',
      ' float a = uT * 0.6; vec2 d = vec2(cos(a), sin(a));',
      ' float u = clamp(dot(vP.xy, d) * 0.55 + 0.5, 0.0, 1.0);',
      ' vec3 A = lin(vec3(0.26,0.52,0.96)), B = lin(vec3(0.61,0.45,0.80)), C = lin(vec3(0.85,0.40,0.44));',
      ' vec3 col = u < 0.5 ? mix(A, B, u * 2.0) : mix(B, C, (u - 0.5) * 2.0);',
      ' vec3 L = normalize(vec3(-0.4, 0.6, 0.7));',
      ' float df = 0.72 + 0.4 * max(dot(vN, L), 0.0);',
      ' float sp = pow(max(dot(reflect(-L, vN), vec3(0.0,0.0,1.0)), 0.0), 24.0);',
      ' gl_FragColor = vec4(col * df + vec3(sp * 0.45), 1.0);',
      ' #include <encodings_fragment>',
      '}'].join('\n'),
  });
  spark_big = bigMat;
  // 3 ดวง 3 สี: ใหญ่ฟ้า→ม่วง · เล็กขวาบนเหลือง · จิ๋วซ้ายล่างชมพู
  const stars = [
    // ดาวใหญ่: ไล่สี 3 โทน (ฟ้า→ม่วง→ชมพู) ทิศไล่สีหมุนช้า ๆ + แสงเงาแบบ 3D
    { m: new THREE.Mesh(sparkGeo(0x4285F4, 0x9B72CB), bigMat), x: 0, y: 0, s: 0.78, ph: 0 },
    { m: new THREE.Mesh(sparkGeo(0xFFD54F, 0xF9A825), mat), x: 0.78, y: 0.72, s: 0.34, ph: 1.7 },
    { m: new THREE.Mesh(sparkGeo(0xF48FB1, 0xD96570), mat), x: -0.62, y: -0.66, s: 0.24, ph: 3.1 },
  ];
  stars.forEach(function (st) { g.add(st.m); });
  const light = new THREE.PointLight(0xb9a8ff, 0, 2.5); g.add(light);
  g.scale.setScalar(0.0001);
  scene.add(g);
  // ลำแสงแฟลชตอนดาวลงที่ (ทอง/ม่วง)
  function raysTex() {
    const c = document.createElement('canvas'); c.width = c.height = 512;
    const x = c.getContext('2d');
    x.translate(256, 256);
    const n = 14;
    for (let k = 0; k < n; k++) {
      const a = k / n * Math.PI * 2, wa = Math.PI / n * 0.55;
      const g = x.createRadialGradient(0, 0, 20, 0, 0, 256);
      g.addColorStop(0, k % 2 ? 'rgba(255,214,102,0.95)' : 'rgba(186,160,255,0.9)');
      g.addColorStop(0.55, k % 2 ? 'rgba(255,214,102,0.35)' : 'rgba(186,160,255,0.3)');
      g.addColorStop(1, 'rgba(255,255,255,0)');
      x.fillStyle = g;
      x.beginPath(); x.moveTo(0, 0);
      x.arc(0, 0, 256, a - wa, a + wa); x.closePath(); x.fill();
    }
    const core = x.createRadialGradient(0, 0, 0, 0, 0, 120);
    core.addColorStop(0, 'rgba(255,255,255,0.95)');
    core.addColorStop(0.4, 'rgba(255,240,200,0.6)');
    core.addColorStop(1, 'rgba(255,255,255,0)');
    x.fillStyle = core; x.beginPath(); x.arc(0, 0, 120, 0, Math.PI * 2); x.fill();
    return new THREE.CanvasTexture(c);
  }
  const rt = raysTex();
  // aura ไล่สีใต้ตัวละคร (ฟ้า → ม่วง → ชมพู) จุดเริ่มของดาว
  const ac = document.createElement('canvas'); ac.width = ac.height = 256;
  const ax = ac.getContext('2d');
  const ag = ax.createRadialGradient(128, 128, 0, 128, 128, 128);
  ag.addColorStop(0, 'rgba(176,120,255,0.95)');
  ag.addColorStop(0.35, 'rgba(66,133,244,0.6)');
  ag.addColorStop(0.7, 'rgba(217,101,112,0.18)');
  ag.addColorStop(1, 'rgba(217,101,112,0)');
  ax.fillStyle = ag; ax.fillRect(0, 0, 256, 256);
  const aura = new THREE.Sprite(new THREE.SpriteMaterial({ map: new THREE.CanvasTexture(ac),
    depthWrite: false, depthTest: false, transparent: true, opacity: 0 }));
  aura.renderOrder = -1;
  scene.add(aura);
  // วงคลื่นพลังบนพื้น (ขยายออกแล้วจาง) + ประกายลอยขึ้นจาก aura
  const rc = document.createElement('canvas'); rc.width = rc.height = 256;
  const rx = rc.getContext('2d');
  const rg = rx.createRadialGradient(128, 128, 70, 128, 128, 128);
  rg.addColorStop(0, 'rgba(186,160,255,0)');
  rg.addColorStop(0.55, 'rgba(186,160,255,0.95)');
  rg.addColorStop(0.75, 'rgba(120,170,255,0.6)');
  rg.addColorStop(1, 'rgba(120,170,255,0)');
  rx.fillStyle = rg; rx.fillRect(0, 0, 256, 256);
  const ringTex = new THREE.CanvasTexture(rc);
  const rings = [0, 1].map(function () {
    const m = new THREE.Sprite(new THREE.SpriteMaterial({ map: ringTex,
      depthWrite: false, depthTest: false, transparent: true, opacity: 0 }));
    m.renderOrder = -1; scene.add(m); return m;
  });
  const dc = document.createElement('canvas'); dc.width = dc.height = 64;
  const dx = dc.getContext('2d');
  const dg = dx.createRadialGradient(32, 32, 0, 32, 32, 32);
  dg.addColorStop(0, 'rgba(255,255,255,1)');
  dg.addColorStop(0.3, 'rgba(255,230,160,0.9)');
  dg.addColorStop(1, 'rgba(186,160,255,0)');
  dx.fillStyle = dg; dx.fillRect(0, 0, 64, 64);
  const dotTex = new THREE.CanvasTexture(dc);
  const motes = [];
  for (let k = 0; k < 10; k++) {
    const m = new THREE.Sprite(new THREE.SpriteMaterial({ map: dotTex,
      depthWrite: false, transparent: true, opacity: 0 }));
    m.userData = { x: (k / 9 - 0.5) * 1.8, ph: (k * 0.37) % 1, sp: 0.7 + (k % 3) * 0.2 };
    scene.add(m); motes.push(m);
  }
  // หางประกายตามดาวตอนบิน (ตำแหน่งย้อนหลัง จางลงตามลำดับ)
  const trail = [];
  for (let k = 0; k < 10; k++) {
    const m = new THREE.Sprite(new THREE.SpriteMaterial({ map: dotTex,
      depthWrite: false, transparent: true, opacity: 0,
      color: k % 2 ? 0xffe08a : 0xc9b6ff }));
    scene.add(m); trail.push(m);
  }
  // แฟลชตอนดาวลงที่ (ลำแสงเล็กหลังดาว)
  const flash = new THREE.Sprite(new THREE.SpriteMaterial({ map: rt,
    depthWrite: false, transparent: true, opacity: 0 }));
  g.add(flash);
  spark = { g: g, w: w, R: R, k: 0, t: 0, stars: stars, light: light, halo: halo, aura: aura, flash: flash, rings: rings, motes: motes, trail: trail, hist: [] };
}
function sparkStep(dt) {
  if (!spark) return;
  spark.t += dt;
  // ดาวโผล่หลังเข้าฉากเสร็จ (ลำดับ: โผล่ + หมุน → ดาว)
  const settled = (!intro || intro.t >= 1) && (!cover || cover.t >= 1);
  const target = want === 'generate' && settled ? 1 : 0;
  spark.k += (target - spark.k) * Math.min(1, dt * (target ? 5 : 4));
  const kb = Math.max(0, (spark.k - 0.25) / 0.75);
  const c1 = 1.70158, c3 = c1 + 1;
  const eb = kb <= 0 ? 0 : 1 + c3 * Math.pow(kb - 1, 3) + c1 * Math.pow(kb - 1, 2);
  spark.light.intensity = 1.2 * spark.k;
  // เรื่องของดาว (นับเวลาตั้งแต่เริ่ม):
  // 0) aura ไล่สีสว่างขึ้นใต้ตัวละคร → 1) ดาวใหญ่พุ่งออกจาก aura หมุนวนรอบตัวละคร 1 รอบครึ่ง
  // แล้วมาลงตำแหน่งข้างตัว → 2) ดวงเหลือง/ชมพูเด้งตาม → 3) ดวงใหญ่ชาร์จแล้วเปล่งประกาย
  // → 4) ดวงเล็กโคจรรอบดวงใหญ่ วิบวับ
  if (target && spark.k > 0.02) spark.st = (spark.st || 0) + dt; else if (spark.k < 0.02) spark.st = 0;
  const T = spark.st || 0;
  const clamp = function (x) { return Math.max(0, Math.min(1, x)); };
  const back = function (u) { return u <= 0 ? 0 : 1 + c3 * Math.pow(u - 1, 3) + c1 * Math.pow(u - 1, 2); };
  const out = function (u) { return 1 - Math.pow(1 - u, 3); };
  const inOut = function (u) { return u < 0.5 ? 4 * u * u * u : 1 - Math.pow(-2 * u + 2, 3) / 2; };
  const R = spark.R, w = spark.w;
  // aura แบบ minimal: แสงไล่สีนุ่ม ๆ ลอยขึ้นจากขอบล่างของ banner (ใต้กรอบ) แล้วจางเมื่อดาวลงที่
  const AURA = 0.55, FLY = 1.4;
  const land = clamp((T - AURA - FLY) / 0.6);
  const rise = out(clamp(T / 0.6));
  const auraK = target ? rise * (1 - 0.75 * land) : 0;
  spark.aura.material.opacity += (auraK - spark.aura.material.opacity) * Math.min(1, dt * 8);
  const edge = -(intro ? intro.h : R * 2.4) / 2;  // ขอบล่างของภาพ
  spark.aura.position.set(0, edge - R * 0.55 + R * 0.45 * rise, 0);
  spark.aura.scale.set(R * 3.2, R * 1.1, 1);
  spark.aura.material.rotation = 0;
  spark.rings.forEach(function (m) { m.material.opacity = 0; });
  spark.motes.forEach(function (m) { m.material.opacity = 0; });
  // เส้นทางบิน: เกลียววนรอบตัวในสามมิติ (ผ่านหลังตัวละคร ถูกบังจริง) จากใต้เท้าขึ้นไป
  // ความเร็วเร่งแล้วผ่อน · ดาวเอียงตามทิศเลี้ยว · มีหางประกาย · ช่วงท้ายร่อนลงที่ข้างตัว
  const endP = new THREE.Vector3(cam.position.x + w * 0.85, w * 0.12 + Math.sin(spark.t * 1.6) * w * 0.03, w * 0.9);
  const fu = clamp((T - AURA) / FLY);
  const fe = inOut(fu);
  const turns = 1.5;
  const ang = Math.PI / 2 + fe * Math.PI * 2 * turns;   // เริ่มด้านหน้า (z+)
  const rr = R * (1.0 - 0.2 * fe);
  const yUp = -R * 0.85 + (endP.y + R * 0.85) * out(fe) + Math.sin(fe * Math.PI) * R * 0.25;
  const orbitP = new THREE.Vector3(Math.cos(ang) * rr, yUp, Math.sin(ang) * rr * 0.9);
  const blend = clamp((fu - 0.6) / 0.4);
  spark.g.position.copy(orbitP.lerp(endP, inOut(blend)));
  // เอียงตามการเลี้ยว (bank) ระหว่างบิน แล้วค่อยตั้งตรง
  const flying = fu > 0 && fu < 1 ? 1 - blend : 0;
  spark.bank = -0.55 * Math.cos(ang) * flying;
  // หางประกาย
  const hist = spark.hist;
  if (fu > 0 && fu < 1) hist.unshift(spark.g.position.clone()); else hist.length = 0;
  if (hist.length > 30) hist.length = 30;
  spark.trail.forEach(function (m, k) {
    const p = hist[k * 3];
    if (!p || !flying) { m.material.opacity = 0; return; }
    m.position.copy(p);
    m.scale.setScalar(R * 0.12 * (1 - k / 10));
    m.material.opacity = 0.85 * (1 - k / 10) * flying;
  });
  // ระหว่างบิน: กลุ่มเล็กลงเล็กน้อย ลงที่แล้วเต็มขนาด
  spark.g.scale.setScalar(Math.max(0.0001, eb * w * 0.62 * (0.55 + 0.45 * out(fu))));
  const S = T - AURA - FLY;  // เวลาหลังดาวลงที่
  // แฟลช ta-da ตอนดาวลงที่: ลำแสงเล็กพุ่งออกแล้วจาง
  const fl = clamp(S / 0.7);
  spark.flash.material.opacity = S > 0 && S < 0.7 ? (1 - fl) * 0.95 : 0;
  spark.flash.scale.setScalar(0.4 + 2.2 * out(fl));
  spark.flash.material.rotation = -spark.t * 0.6;
  const delay = [0, 0.15, 0.4];
  const ch = clamp((S - 0.7) / 0.6);
  const charge = ch < 0.35 ? -0.18 * Math.sin(ch / 0.35 * Math.PI / 2)
      : 0.3 * Math.sin((ch - 0.35) / 0.65 * Math.PI) - 0.18 * (1 - (ch - 0.35) / 0.65);
  spark.halo.scale.setScalar(2.0 * (1 + Math.max(0, charge) * 1.6));
  spark.halo.material.opacity = clamp(S + 0.3) * (0.75 + 0.25 * Math.sin(spark.t * 2.4));
  spark.stars.forEach(function (st, i) {
    const tw = 0.88 + 0.12 * Math.sin(spark.t * 3.2 + st.ph);
    if (i === 0) {
      // ดาวใหญ่: โผล่จาก aura แล้วหมุนติ้วระหว่างบิน ช้าลงเมื่อใกล้ถึง
      const pop = back(clamp((T - AURA * 0.5) / 0.4));
      st.m.scale.setScalar(st.s * pop * (1 + charge));
      st.m.position.set(0, 0, 0);
      // ดาวใหญ่: หมุนแบบ subtle (เอียงซ้ายขวา + พลิกเล็กน้อย) · ทิศไล่สีหมุนช้า ๆ
      // idle: เอียงสามมิติชัด ๆ (ซ้ายขวา + ก้มเงย) เห็นความหนาและ perspective ของดาว
      st.m.rotation.y = 0.6 * Math.sin(spark.t * 0.7);
      st.m.rotation.x = 0.35 * Math.sin(spark.t * 0.5 + 1.0);
      st.m.rotation.z = 0.08 * Math.sin(spark.t * 0.8) + (spark.bank || 0);
      if (spark_big) spark_big.uniforms.uT.value = spark.t;
    } else {
      const u = clamp((S - delay[i]) / 0.5);
      const pop = back(u);
      const r = Math.hypot(st.x, st.y), a0 = Math.atan2(st.y, st.x);
      const a = a0 + Math.max(0, S - 1.0) * 0.9;
      st.m.scale.setScalar(st.s * pop * tw);
      st.m.position.set(Math.cos(a) * r, Math.sin(a) * r, 0.05);
      st.m.rotation.y = (1 - out(u)) * Math.PI;
      st.m.rotation.z = 0.6 * Math.sin(spark.t * 1.8 + st.ph);
    }
  });
  spark.g.quaternion.copy(cam.quaternion);
  spark.g.rotateZ((1 - eb) * 0.8);
}

// ------------------------------------------------ เขียน: กระดาษโดนปากกากดเอียงลง
let press = null, pressK = 0, pressT = 0, thinkK = 0;
function pressStep(dt) {
  if (!press) return;
  pressT += dt;
  // ค่อย ๆ เข้า/ออกโหมดเขียน (ไม่กระตุก)
  const target = want === 'write' ? 1 : 0;
  pressK += (target - pressK) * Math.min(1, dt * 6);
  // ปากกากดครึ่งล่าง: ขอบล่างยุบลงไปด้านหลัง (หัวกระดกเข้าหาเรา) + ยุบเพิ่มทุกครั้งที่กด
  const beat = Math.pow(Math.abs(Math.sin(pressT * Math.PI * 2.2)), 3);
  press.rotation.x = pressK * (0.16 + 0.07 * beat);
  press.position.y = -pressK * 0.03 * beat;
  // ถอยห่างกล้องเล็กน้อยตอนโดนกด (ดูเหมือนยุบลงไปในโต๊ะ)
  press.position.z = -pressK * (0.12 + 0.06 * beat);
  // ท่าคิด: เอนตัวไปข้างช้า ๆ ซ้ายขวา + หงายหลังนิด ๆ (เหมือนเอียงคอคิด)
  thinkK += ((want === 'think' ? 1 : 0) - thinkK) * Math.min(1, dt * 4);
  press.rotation.z = thinkK * (0.1 + 0.05 * Math.sin(pressT * 1.3));
  press.rotation.x += -thinkK * 0.06;
}

// ------------------------------------------------ idle: หน้าหันมองไปมา (เฉพาะหน้า ตัวอยู่นิ่ง)
let face = null;
function setupFace(root) {
  root.updateMatrixWorld(true);
  const parts = [];
  root.traverse(function (o) {
    if (o.isMesh && /^(eye|pupil|glass|bridge|smile)/.test(o.name)) parts.push(o);
  });
  if (!parts.length) return;
  const box = new THREE.Box3();
  parts.forEach(function (o) { box.expandByObject(o); });
  const parent = parts[0].parent;
  const g = new THREE.Group();
  g.position.copy(parent.worldToLocal(box.getCenter(new THREE.Vector3())));
  parent.add(g);
  g.updateMatrixWorld(true);
  parts.forEach(function (o) { g.attach(o); });
  // ทิศ "ออกจากหน้ากระดาษ" (+z โลก) ในพิกัดของ parent · ขนาดครึ่งหน้าในพิกัด parent
  const q = parent.getWorldQuaternion(new THREE.Quaternion()).invert();
  const ws = parent.getWorldScale(new THREE.Vector3());
  const size = box.getSize(new THREE.Vector3());
  // กระพิบตา: ตา + ลูกตาแต่ละข้างอยู่ในกลุ่มที่จุดหมุนกลางตา แล้วบีบตามแกน "ขึ้น" ของหน้า
  const up = new THREE.Vector3(0, 1, 0).applyQuaternion(q);
  const ax = Math.abs(up.x) > Math.abs(up.y)
      ? (Math.abs(up.x) > Math.abs(up.z) ? 'x' : 'z')
      : (Math.abs(up.y) > Math.abs(up.z) ? 'y' : 'z');
  const lids = [];
  ['L', 'R'].forEach(function (side) {
    const eye = g.getObjectByName('eye_' + side);
    const pupil = g.getObjectByName('pupil_' + side);
    if (!eye) return;
    g.updateMatrixWorld(true);
    const eb = new THREE.Box3().setFromObject(eye);
    const lid = new THREE.Group();
    lid.position.copy(g.worldToLocal(eb.getCenter(new THREE.Vector3())));
    g.add(lid);
    lid.updateMatrixWorld(true);
    lid.attach(eye);
    if (pupil) lid.attach(pupil);
    lids.push(lid);
  });
  face = {
    g: g, t: 0, base: g.position.clone(),
    fwd: new THREE.Vector3(0, 0, 1).applyQuaternion(q).normalize(),
    hw: size.x / 2 / ws.x, hh: size.y / 2 / ws.y,
    lids: lids, ax: ax, blinkAt: 2.5, dbl: false,
  };
}

// ลำดับการมอง: [yaw, pitch, วินาทีที่ค้าง] · เปลี่ยนท่าแบบ ease ช้า ๆ เหมือนเหลือบมอง
const LOOKS = [[0, 0, 1.6], [0.3, 0.05, 1.2], [0.3, -0.07, 0.6], [0, 0, 1.4],
               [-0.28, 0.04, 1.3], [-0.16, -0.08, 0.7], [0, 0, 1.2]];
function faceStep(dt) {
  if (!face) return;
  // ปกยังปิดทับหน้าอยู่ (รอเข้าฉาก/ช่วงแรกของการพลิก): ซ่อนหน้า ไม่ให้ตา/แว่นทะลุปก
  face.g.visible = !cover || cover.t > 0.25;
  face.t += dt;
  const move = 0.45;  // วินาทีที่ใช้หันไปท่าใหม่
  let total = 0;
  LOOKS.forEach(function (l) { total += move + l[2]; });
  let t = face.t % total;
  let i = 0;
  for (; i < LOOKS.length; i++) {
    const seg = move + LOOKS[i][2];
    if (t < seg) break;
    t -= seg;
  }
  const to = LOOKS[i % LOOKS.length];
  const from = LOOKS[(i + LOOKS.length - 1) % LOOKS.length];
  const k = Math.min(1, t / move);
  const e = k < 0.5 ? 4 * k * k * k : 1 - Math.pow(-2 * k + 2, 3) / 2;  // easeInOutCubic
  // หันเบาลงเมื่อไม่ใช่ท่าพัก (กำลังเขียน/ฟัง = มองกระดาษ/ผู้พูดมากกว่า)
  const amp = want === 'idle' ? 1 : 0.35;
  let ty = (from[0] + (to[0] - from[0]) * e) * amp;
  let tp = (from[1] + (to[1] - from[1]) * e) * amp;
  // ท่าคิด: เหลือบมองขึ้นเฉียงขวา ค้างไว้ แกว่งเล็กน้อยเหมือนนึกอยู่
  // ฟัง (bubble อยู่): มองตรงมาที่ผู้พูด ไม่เหลือบไปไหน
  if (want === 'think' || want === 'idea' || want === 'generate') { ty = 0; tp = 0; }
  // เข้า/ออกท่าแบบนุ่ม (ไม่กระโดด)
  const sm = Math.min(1, dt * 7);
  face.cy = (face.cy || 0) + (ty - (face.cy || 0)) * sm;
  face.cp = (face.cp || 0) + (tp - (face.cp || 0)) * sm;
  const yaw = face.cy, pitch = face.cp;
  face.g.rotation.y = yaw;
  face.g.rotation.x = pitch;
  // หันแล้วขอบหน้าด้านหนึ่งจมลงกระดาษ: ยกหน้าออกมาเท่าที่จม (+เผื่อเล็กน้อย) ไม่ให้ทะลุ
  const lift = face.hw * Math.sin(Math.abs(yaw)) + face.hh * Math.sin(Math.abs(pitch));
  face.g.position.copy(face.base).addScaledVector(face.fwd, lift * 1.1);
  // กระพิบตา: ปิด-เปิด 0.16 วิ ทุก 2.5–5 วิ บางครั้งกระพิบสองที
  const bt = face.t - face.blinkAt;
  let open = 1;
  if (bt >= 0 && bt < 0.16) {
    open = Math.max(0.08, Math.abs(1 - bt / 0.08));
  } else if (bt >= 0.16) {
    if (!face.dbl && Math.random() < 0.25) {
      face.dbl = true;
      face.blinkAt = face.t + 0.12;
    } else {
      face.dbl = false;
      face.blinkAt = face.t + 2.5 + Math.random() * 2.5;
    }
  }
  face.lids.forEach(function (l) { l.scale[face.ax] = open; });
}

let cover = null;
function setupCover(root) {
  const c = root.getObjectByName('cover_front');
  if (!c || !c.parent) return;
  root.updateMatrixWorld(true);
  const bb = new THREE.Box3().setFromObject(c);
  const pages = new THREE.Box3();
  root.traverse(function (o) { if (o.isMesh && /^body/.test(o.name)) pages.expandByObject(o); });
  const parent = c.parent;
  // บานพับอยู่ที่ห่วงด้านบน (กลางความหนาของตัว)
  const hingeW = new THREE.Vector3((bb.min.x + bb.max.x) / 2, bb.max.y, (pages.min.z + pages.max.z) / 2);
  const hinge = new THREE.Group();
  parent.add(hinge);
  hinge.position.copy(parent.worldToLocal(hingeW.clone()));
  hinge.attach(c);
  const back = hinge.position.clone();
  // ตำแหน่งปิด: ย้ายบานพับไปหน้าสุดของหน้ากระดาษ
  // ปิดทับหน้าให้พ้นตา/แว่นที่นูนออกมา
  const face = new THREE.Box3();
  root.traverse(function (o) { if (o.isMesh && !/^(pen|ink|cover)/.test(o.name)) face.expandByObject(o); });
  const frontW = hingeW.clone(); frontW.z = face.max.z + (bb.max.z - bb.min.z) / 2 + 0.02;
  const front = parent.worldToLocal(frontW.clone());
  const inv = new THREE.Matrix4().copy(parent.matrixWorld).invert();
  const axis = new THREE.Vector3(1, 0, 0).transformDirection(inv).normalize();
  // วัสดุปกแยกของตัวเอง (จางได้โดยไม่กระทบชิ้นอื่นที่ใช้สีเดียวกัน)
  const mats = [];
  c.traverse(function (o) {
    if (o.isMesh) { o.material = o.material.clone(); mats.push(o.material); }
  });
  // ไม่เล่นท่าเปิดปก: ปกอยู่ที่พักด้านหลังตั้งแต่แรก
  cover = { hinge: hinge, back: back, front: front, axis: axis, t: 1, mats: mats };
  hinge.position.copy(back);
  hinge.quaternion.identity();
}
// วนท่าเข้าฉาก: โผล่+หมุน → ดาวบินมา แล้วยืนค้างพร้อมดาว ~10 วิ → ดาวหด → จมลงล่าง → เริ่มใหม่
// ไม่ยืนนิ่งค้างนาน ๆ
// idle = ยืนค้างพร้อมดาว (ไม่กลับเป็นปากกา) · ดาวหดก่อนจมลงเท่านั้น
const INTRO_HOLD = 4.2 + 10.0, INTRO_FADE = 0.45, INTRO_IDLE = 0.0, INTRO_OUT = 0.55;
function introStep(dt) {
  if (!intro) return;
  intro.c = (intro.c || 0) + dt;
  const total = INTRO_DUR + INTRO_HOLD + INTRO_FADE + INTRO_IDLE + INTRO_OUT;
  if (intro.c >= total) intro.c -= total;
  const c = intro.c;
  let y = 0, rot = 0;
  if (c < INTRO_DUR) {
    const e = 1 - Math.pow(1 - c / INTRO_DUR, 3);  // easeOutCubic
    y = -intro.h * (1 - e);
    rot = -Math.PI * 2 * (1 - e);
  } else if (c > INTRO_DUR + INTRO_HOLD + INTRO_FADE + INTRO_IDLE) {
    const u = (c - INTRO_DUR - INTRO_HOLD - INTRO_FADE - INTRO_IDLE) / INTRO_OUT;
    y = -intro.h * u * u * u;  // easeInCubic จมลง
  }
  intro.g.position.y = y;
  intro.g.rotation.y = rot;
  // ดาวแสดงเฉพาะช่วงโชว์ (ก่อนจมลง ดาวหดหายก่อน)
  intro.t = c >= INTRO_DUR && c < INTRO_DUR + INTRO_HOLD ? 1 : 0;
}
function coverStep(dt) {
  if (!cover || cover.t >= 1) return;
  cover.t = Math.min(1, cover.t + dt / 1.1);
  const t = Math.max(0, cover.t);
  // ช่วง 1 (0–0.7): ปกพลิกขึ้นจากด้านล่าง (บานพับที่ห่วง) แล้วจางหาย ไม่หมุนรอบเต็มวง (หลุดกรอบ/กระตุก)
  // ช่วง 2 (0.7–1): ปกค่อย ๆ ปรากฏที่ตำแหน่งหลังตัว (ที่พักจริง)
  if (t < 0.7) {
    const u = t / 0.7;
    const e = 1 - Math.pow(1 - u, 3);
    cover.hinge.position.copy(cover.front);
    cover.hinge.quaternion.setFromAxisAngle(cover.axis, -1.9 * e);
    setCoverOpacity(u < 0.55 ? 1 : 1 - (u - 0.55) / 0.45);
  } else {
    const u = (t - 0.7) / 0.3;
    cover.hinge.position.copy(cover.back);
    cover.hinge.quaternion.identity();
    setCoverOpacity(u);
  }
  if (cover.t >= 1) setCoverOpacity(1, true);
}
function setCoverOpacity(o, done) {
  cover.mats.forEach(function (m) {
    m.transparent = !done;
    m.opacity = Math.max(0, Math.min(1, o));
    m.depthWrite = !!done || o > 0.95;
  });
}

// 30 fps พอสำหรับมาสคอตเล็ก (ลดงาน GPU ของ WebView)
const clock = new THREE.Clock();
let acc = 0;
function loop() {
  requestAnimationFrame(loop);
  const dt = clock.getDelta();
  acc += dt;
  // ช่วงเปิดปกวาด 60 fps ให้ลื่น · ปกติ 30 fps ประหยัดเครื่อง
  if (acc < (cover && cover.t < 1 ? 1 / 60 : 1 / 30)) return;
  if (mixer) mixer.update(acc);
  introStep(acc);
  coverStep(acc);
  faceStep(acc);
  pressStep(acc);
  bubbleStep(acc);
  ideaStep(acc);
  bulbStep(acc);
  sparkStep(acc);
  acc = 0;
  // WebView อาจเริ่มที่ขนาด 0 แล้วไม่ยิง resize: เช็กขนาดทุกเฟรม
  const c = renderer.domElement;
  if (c.width !== Math.round(innerWidth * renderer.getPixelRatio()) ||
      c.height !== Math.round(innerHeight * renderer.getPixelRatio())) size();
  renderer.render(scene, cam);
}
loop();
</script>
</body>
</html>
''';
