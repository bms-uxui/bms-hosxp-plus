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
enum ErDrNoteMode { idle, listen, write }

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
  cam.aspect = w / h; cam.updateProjectionMatrix();
}
size(); window.addEventListener('resize', size);

let mixer = null, clips = {}, current = null, want = 'idle', root = null, base = null;
// มุมท่า (เรเดียน) + ขนาด · ปรับสดได้จาก debugger ผ่าน window.drPose
const POSE = { x: -0.35, y: 0.42, z: 0.24, s: 1.1 };
window.drPose = function (x, y, z, s) {
  POSE.x = x; POSE.y = y; POSE.z = z; POSE.s = s;
  if (root) { root.rotation.set(x, y, z); root.scale.setScalar(s); }
};
window.drMode = function (name) {
  want = name;
  if (!mixer || !clips[name]) return;
  const next = mixer.clipAction(clips[name]);
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
  // หมุนรอบจุดกึ่งกลางตัว (ไม่ใช่ที่เท้า) ตัวจึงอยู่ในกรอบเสมอไม่ว่าจะหมุนแกนไหน
  gltf.scene.updateMatrixWorld(true);
  const box0 = new THREE.Box3();
  gltf.scene.traverse(function (o) { if (o.isMesh && !/^(pen|ink)/.test(o.name)) box0.expandByObject(o); });
  const c0 = box0.getCenter(new THREE.Vector3());
  const pivot = new THREE.Group();
  scene.remove(gltf.scene);
  pivot.add(gltf.scene);
  gltf.scene.position.sub(c0);
  scene.add(pivot);
  root = pivot;
  pivot.rotation.set(POSE.x, POSE.y, POSE.z);
  pivot.scale.setScalar(POSE.s);
  // กล้องพอดีทรงกลมที่ครอบตัว (หมุนแล้วก็ยังพอดี)
  const sph = box0.getBoundingSphere(new THREE.Sphere());
  const half = THREE.MathUtils.degToRad(cam.fov / 2);
  const rFit = sph.radius * 0.92;
  const dist = Math.max(rFit / Math.sin(half), rFit / Math.sin(Math.atan(Math.tan(half) * cam.aspect)));
  const look = new THREE.Vector3(0, 0, 0);
  cam.position.set(0, 0, dist);
  cam.lookAt(look);
  post({ type: 'ready', gl: !!renderer.getContext(), w: innerWidth, h: innerHeight,
    box: [box0.min.x, box0.min.y, box0.min.z, box0.max.x, box0.max.y, box0.max.z].map(function (v) { return +v.toFixed(2); }),
    anims: Object.keys(clips) });
}, undefined, function (e) { post({ type: 'error', message: String(e) }); });

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
