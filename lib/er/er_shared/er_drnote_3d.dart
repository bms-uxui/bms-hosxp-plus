/// มาสคอต Dr.Note แบบสามมิติ (สมุดโน้ตใส่แว่น + ปากกาลอย)
///
/// โมเดล assets/models/drnote.glb ปั้นใน Blender มี rig + 3 ท่า
/// idle = ลอยหายใจ · listen = โน้มฟัง ปากกายกเตรียมเขียน · write = ปากกาเขียนลงตัวตอนผู้ใช้พูด
/// มือถือเปิดใน WebView ผ่าน HttpServer ในเครื่อง · เว็บใช้ iframe ([ErWebFrame])
/// แบบเดียวกับฉากสามมิติอื่นของ ER (ErRing3D)
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'er_web_frame.dart';

/// ท่าของ Dr.Note (ชื่อตรงกับ action ในไฟล์ glb)
enum ErDrNoteMode { idle, listen, write, think }

class ErDrNote3D extends StatefulWidget {
  const ErDrNote3D({super.key, this.mode = ErDrNoteMode.idle, this.pose});

  final ErDrNoteMode mode;

  /// มุมหมุน x, y, z (เรเดียน) + ขนาด · null = ค่าตั้งต้นในฉาก (ใช้กับ debugger)
  final (double, double, double, double)? pose;

  @override
  State<ErDrNote3D> createState() => _ErDrNote3DState();
}

class _ErDrNote3DState extends State<ErDrNote3D> {
  WebViewController? _web;
  HttpServer? _server;
  ErWebFrame? _frame;
  bool _ready = false;

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
    _server?.close(force: true);
    _frame?.dispose();
    super.dispose();
  }

  static const _files = {
    '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
    '/GLTFLoader.js': ['assets/web/GLTFLoader.js', 'application/javascript'],
    '/drnote.glb': ['assets/models/drnote.glb', 'model/gltf-binary'],
  };

  Future<void> _boot() async {
    if (kIsWeb) {
      setState(() => _frame = ErWebFrame(
            html: _html,
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
        req.response.write(_html);
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
function post(o) { if (window.ErDrNote) window.ErDrNote.postMessage(JSON.stringify(o)); }
window.onerror = function (m) { post({ type: 'error', message: String(m) }); };

const scene = new THREE.Scene();
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
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
// มุมท่า (เรเดียน) + ขนาด · ปรับสดได้จาก debugger ผ่าน window.drPose
const POSE = { x: -0.35, y: 0.42, z: 0.24, s: 0.9 };
window.drPose = function (x, y, z, s) {
  POSE.x = x; POSE.y = y; POSE.z = z; POSE.s = s;
  if (root) { root.rotation.set(x, y, z); root.scale.setScalar(s); }
};
window.drMode = function (name) {
  want = name;
  // ท่าคิดไม่มีคลิปในโมเดล: ใช้คลิปฟัง (ปากกาลอยนิ่ง) แล้วทำท่าหน้า/ตัวเพิ่มด้วยโค้ด
  const clip = clips[name] ? name : (name === 'think' ? 'listen' : name);
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
  scene.add(press);
  root = pivot;
  pivot.rotation.set(POSE.x, POSE.y, POSE.z);
  pivot.scale.setScalar(POSE.s);
  // กล้องพอดีทรงกลมที่ครอบตัว (หมุนแล้วก็ยังพอดี)
  const sph = box0.getBoundingSphere(new THREE.Sphere());
  // chat bubble 3D ผูกกับกระดูกปากกา (ลอยตามปากกา) · กำลังคิด = ปากกา morph เป็น bubble
  setupBubble(gltf.scene, sph.radius);
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
  const penS = Math.max(0.0001, 1 - Math.min(1, k * 1.6));
  bub.pen.scale.setScalar(penS);
  bub.pen.rotation.y = k * Math.PI;
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
  if (want === 'think') { ty = 0; tp = 0; }
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
  cover = { hinge: hinge, back: back, front: front, axis: axis, t: -0.25, mats: mats };
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
  coverStep(acc);
  faceStep(acc);
  pressStep(acc);
  bubbleStep(acc);
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
