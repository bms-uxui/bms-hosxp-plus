/// ไฟไซเรนฉุกเฉินแบบสามมิติ (ปุ่มส่งเข้า RESUS)
///
/// ปั้นใน three.js ตรง ๆ ไม่ใช้ไฟล์โมเดล: ฐานโลหะ · โดมแก้วแดงโปร่งแสง ·
/// ตัวสะท้อนแสงหมุนด้านใน + ลำแสงสองข้าง + แสงเรืองกระพริบ
/// มือถือเปิดใน WebView ผ่าน HttpServer ในเครื่อง · เว็บใช้ iframe ([ErWebFrame])
/// แบบเดียวกับ [ErDrNote3D]
library;

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'er_web_frame.dart';

class ErSiren3D extends StatefulWidget {
  const ErSiren3D({super.key, this.pose, this.glow = true});

  /// แสงเรืองรอบโดม · ไอคอนเล็กบนพื้นสี (แถวงาน) ปิดไว้ ไม่ให้เห็นเป็นกล่องจาง
  final bool glow;

  /// มุมเอียง x, หัน y, เอียง z (เรเดียน) + ขนาด · null = ค่าตั้งต้นในฉาก
  final (double, double, double, double)? pose;

  @override
  State<ErSiren3D> createState() => _ErSiren3DState();
}

class _ErSiren3DState extends State<ErSiren3D> {
  WebViewController? _web;
  HttpServer? _server;
  ErWebFrame? _frame;

  static const _files = {
    '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
  };

  @override
  void initState() {
    super.initState();
    _boot();
  }

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
  void didUpdateWidget(covariant ErSiren3D old) {
    super.didUpdateWidget(old);
    if (old.pose != widget.pose) _pushPose();
  }

  void _pushPose() {
    final p = widget.pose;
    if (!_ready || p == null) return;
    final js = 'window.srPose(${p.$1}, ${p.$2}, ${p.$3}, ${p.$4});'
        'window.srGlow(${widget.glow})';
    if (_frame != null) {
      _frame!.run(js);
    } else {
      _web?.runJavaScript(js);
    }
  }

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
            channel: 'ErSiren',
            routes: [
              for (final e in _files.entries)
                ('^${RegExp.escape(e.key)}\$', e.value[0], e.value[1]),
            ],
            onMessage: (_) {
              _ready = true;
              _pushPose();
            },
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
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) {
        _ready = true;
        _pushPose();
      }))
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    setState(() => _web = controller);
  }

  @override
  Widget build(BuildContext context) {
    final Widget view = _frame != null
        ? _frame!.view()
        : _web == null
            ? const SizedBox.shrink()
            : WebViewWidget(controller: _web!);
    // ภาพประกอบ: ให้แตะผ่านไปถึงปุ่ม
    return IgnorePointer(child: RepaintBoundary(child: view));
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
</head>
<body>
<script>
const scene = new THREE.Scene();
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
// ไอคอนเล็ก: ความละเอียด 1.25 พอ (GPU fill น้อยลง)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.25));
renderer.setClearColor(0x000000, 0);
renderer.outputEncoding = THREE.sRGBEncoding;
document.body.appendChild(renderer.domElement);

const cam = new THREE.PerspectiveCamera(30, 1, 0.1, 50);
cam.position.set(0, 1.2, 4.8);
cam.lookAt(0, 0.62, 0);

scene.add(new THREE.HemisphereLight(0xffffff, 0x8890a8, 0.9));
const key = new THREE.DirectionalLight(0xffffff, 1.2); key.position.set(2, 4, 3); scene.add(key);
const rim = new THREE.DirectionalLight(0xffd0c8, 0.6); rim.position.set(-3, 2, -2); scene.add(rim);

const siren = new THREE.Group(); scene.add(siren);

// ฐานโลหะ: แผ่นล่าง + คอ
const metal = new THREE.MeshStandardMaterial({ color: 0x3b4150, metalness: 0.7, roughness: 0.35 });
const base = new THREE.Mesh(new THREE.CylinderGeometry(0.78, 0.86, 0.22, 48), metal);
base.position.y = 0.11; siren.add(base);
const ring = new THREE.Mesh(new THREE.CylinderGeometry(0.66, 0.70, 0.08, 48),
  new THREE.MeshStandardMaterial({ color: 0x9aa3b2, metalness: 0.9, roughness: 0.2 }));
ring.position.y = 0.26; siren.add(ring);

// โดมแก้วแดงโปร่งแสง: ทรงกระบอก + ครึ่งทรงกลม
const glass = new THREE.MeshPhysicalMaterial({
  color: 0xff2a1f, emissive: 0x7a0000, emissiveIntensity: 0.5,
  roughness: 0.12, metalness: 0.0, transparent: true, opacity: 0.78,
  clearcoat: 1.0, clearcoatRoughness: 0.08,
});
const body = new THREE.Mesh(new THREE.CylinderGeometry(0.6, 0.62, 0.55, 48, 1, true), glass);
body.position.y = 0.575; siren.add(body);
const cap = new THREE.Mesh(new THREE.SphereGeometry(0.6, 48, 24, 0, Math.PI * 2, 0, Math.PI / 2), glass);
cap.position.y = 0.85; siren.add(cap);

// ด้านใน: หลอด + แผ่นสะท้อนหมุน
const bulb = new THREE.Mesh(new THREE.SphereGeometry(0.16, 24, 16),
  new THREE.MeshBasicMaterial({ color: 0xfff2e8 }));
bulb.position.y = 0.68; siren.add(bulb);
const spin = new THREE.Group(); spin.position.y = 0.68; siren.add(spin);
const refl = new THREE.Mesh(new THREE.CylinderGeometry(0.34, 0.34, 0.5, 32, 1, true, 0, Math.PI),
  new THREE.MeshStandardMaterial({ color: 0xffe7a0, metalness: 1, roughness: 0.15, side: THREE.DoubleSide }));
spin.add(refl);

// ลำแสงกรวยสองข้าง (additive) + ไฟจริงหมุนตาม
const beamMat = new THREE.MeshBasicMaterial({ color: 0xff6b5a, transparent: true, opacity: 0.22,
  blending: THREE.AdditiveBlending, depthWrite: false, side: THREE.DoubleSide });
const beams = [];
for (const s of [1, -1]) {
  const cone = new THREE.Mesh(new THREE.ConeGeometry(0.32, 1.0, 32, 1, true), beamMat);
  cone.rotation.z = s * Math.PI / 2;
  cone.position.x = s * 0.82;
  spin.add(cone);
  beams.push(cone);
}
const spot = new THREE.PointLight(0xff3b2f, 2.2, 4); spot.position.set(0.45, 0, 0); spin.add(spot);

// แสงเรืองรอบโดม (sprite)
const gc = document.createElement('canvas'); gc.width = gc.height = 128;
const g = gc.getContext('2d');
const grd = g.createRadialGradient(64, 64, 0, 64, 64, 64);
grd.addColorStop(0, 'rgba(255,120,100,0.9)'); grd.addColorStop(1, 'rgba(255,60,40,0)');
g.fillStyle = grd; g.fillRect(0, 0, 128, 128);
const glow = new THREE.Sprite(new THREE.SpriteMaterial({ map: new THREE.CanvasTexture(gc),
  blending: THREE.AdditiveBlending, depthWrite: false, transparent: true }));
glow.position.y = 0.7; glow.scale.set(2.4, 2.4, 1); siren.add(glow);

// เอียงเฉียงมีมุมมอง: เทหัวไปซ้าย หันข้างให้เห็นทรง
let TILT_X = -0.13, ROT_Y = -1.98, TILT_Z = -0.38, SCALE = 0.63;
siren.rotation.set(TILT_X, ROT_Y, TILT_Z);
// ตั้งท่าจาก Flutter (debugger)
window.srPose = function (x, y, z, s) { TILT_X = x; ROT_Y = y; TILT_Z = z; SCALE = s; };
window.srGlow = function (on) { glow.visible = on; beams.forEach(function (b) { b.visible = on; }); };
if (window.ErSiren) window.ErSiren.postMessage('ready');

function size() {
  const w = innerWidth, h = innerHeight;
  renderer.setSize(w, h);
  cam.aspect = w / h; cam.updateProjectionMatrix();
}
size(); addEventListener('resize', size);

const t0 = performance.now();
// วาด ~20fps พอสำหรับไฟหมุน (60fps ต่อแถว = platform view ส่งเฟรมไม่หยุด)
let last = 0;
function tick(now) {
  requestAnimationFrame(tick);
  if (now - last < 50) return;
  last = now;
  const t = (performance.now() - t0) / 1000;
  spin.rotation.y = t * 5.2;
  // หันลำแสงเข้าหากล้อง = สว่างสุด
  const face = (Math.cos(spin.rotation.y) + 1) / 2;
  glass.emissiveIntensity = 0.35 + 0.9 * face;
  glow.material.opacity = 0.35 + 0.6 * face;
  // ลอยบนน้ำ: ขึ้นลง + โยกสองแกนคนละจังหวะ
  siren.position.y = Math.sin(t * 1.3) * 0.07;
  siren.rotation.x = TILT_X + Math.sin(t * 1.1) * 0.07;
  siren.rotation.z = TILT_Z + Math.sin(t * 0.8 + 1.2) * 0.09;
  siren.rotation.y = ROT_Y + Math.sin(t * 0.5) * 0.12;
  siren.scale.setScalar(SCALE);
  renderer.render(scene, cam);
}
requestAnimationFrame(tick);
</script>
</body>
</html>
''';
