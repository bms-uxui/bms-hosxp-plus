/// ใบหน้าผู้ป่วยแบบสามมิติ สำหรับประเมินรูม่านตา (หน้าคัดกรอง)
///
/// ใช้หุ่นผิวจริงตัวเดียวกับหน้ารายละเอียดผู้ป่วย (ThaiWellAI body_male/body_female)
/// กล้องจับเฉพาะใบหน้า · ตาระบายสีด้วยสีจุดยอด รูม่านตาขนาดตามมิลลิเมตรที่ส่งมา
/// วาดเฉพาะตอนค่าเปลี่ยน (ไม่มีลูปเรนเดอร์) เพื่อไม่ให้หนักเครื่อง
/// มือถือเปิดใน WebView ผ่าน HttpServer ในเครื่อง · เว็บใช้ iframe ([ErWebFrame])
library;

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'er_web_frame.dart';

class ErFace3D extends StatefulWidget {
  const ErFace3D({
    super.key,
    this.mmR,
    this.mmL,
    this.female = false,
  });

  /// ขนาดรูม่านตา (มม.) ขวา/ซ้ายของผู้ป่วย · null = ยังไม่ประเมิน (แสดง 3 มม. จาง ๆ)
  final double? mmR, mmL;
  final bool female;

  @override
  State<ErFace3D> createState() => _ErFace3DState();
}

class _ErFace3DState extends State<ErFace3D> {
  WebViewController? _web;
  HttpServer? _server;
  ErWebFrame? _frame;
  bool _ready = false;

  static const _files = {
    '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
    '/GLTFLoader.js': ['assets/web/GLTFLoader.js', 'application/javascript'],
    '/m.glb': ['assets/models/er_body_realistic.glb', 'model/gltf-binary'],
    '/m_n.jpg': ['assets/models/er_body_realistic_normal.jpg', 'image/jpeg'],
    '/m_ao.jpg': ['assets/models/er_body_realistic_ao.jpg', 'image/jpeg'],
    '/f.glb': ['assets/models/er_body_realistic_f.glb', 'model/gltf-binary'],
    '/f_n.jpg': ['assets/models/er_body_realistic_f_normal.jpg', 'image/jpeg'],
    '/f_ao.jpg': ['assets/models/er_body_realistic_f_ao.jpg', 'image/jpeg'],
  };

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void didUpdateWidget(covariant ErFace3D old) {
    super.didUpdateWidget(old);
    if (old.mmR != widget.mmR ||
        old.mmL != widget.mmL ||
        old.female != widget.female) {
      _push();
    }
  }

  void _push() {
    if (!_ready) return;
    String v(double? x) => x == null ? 'null' : x.toStringAsFixed(2);
    final js = 'window.faceSet(${widget.female ? "'f'" : "'m'"}, '
        '${v(widget.mmR)}, ${v(widget.mmL)})';
    if (_frame != null) {
      _frame!.run(js);
    } else {
      _web?.runJavaScript(js);
    }
  }

  // hot reload: โหลดหน้าใหม่ให้ได้ HTML ล่าสุด
  @override
  void reassemble() {
    super.reassemble();
    _ready = false;
    _web?.reload();
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
            channel: 'ErFace',
            routes: [
              for (final e in _files.entries)
                ('^${RegExp.escape(e.key)}\$', e.value[0], e.value[1]),
            ],
            onMessage: (_) {
              _ready = true;
              _push();
            },
          ));
      return;
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path == '/' || req.uri.path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
        // ไม่ให้ WebView เก็บ cache หน้า (แก้ HTML แล้วเห็นผลทันที)
        req.response.headers.set('cache-control', 'no-store');
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
        _push();
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
    // ภาพประกอบ: ให้แตะ/ลากผ่านไปถึงตัวควบคุมของ Flutter
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
<script src="GLTFLoader.js"></script>
</head>
<body>
<script>
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 3));
renderer.setClearColor(0x000000, 0);
renderer.outputEncoding = THREE.sRGBEncoding;
document.body.appendChild(renderer.domElement);

const scene = new THREE.Scene();
const cam = new THREE.PerspectiveCamera(24, 1, 0.01, 10);
// แสงแบบ flat 2D: แสงรอบตัวสูง + ไฟหลักทิศเดียว ใช้กับวัสดุ toon 3 ระดับ
scene.add(new THREE.AmbientLight(0xffffff, 0.55));
// ไล่เฉด toon: เงา / กลาง / สว่าง แบ่งเป็นขั้นชัด ๆ แบบภาพวาด
const toonTex = (function () {
  const d = new Uint8Array([150, 150, 150, 255, 215, 215, 215, 255, 255, 255, 255, 255]);
  const t = new THREE.DataTexture(d, 3, 1, THREE.RGBAFormat);
  t.minFilter = t.magFilter = THREE.NearestFilter;
  t.needsUpdate = true;
  return t;
})();
const key = new THREE.DirectionalLight(0xffffff, 0.6);
const fill = new THREE.DirectionalLight(0xffffff, 0.0);
scene.add(key, fill);

// ม่านตาราว 11 มม. → มุมขอบม่านตาบนลูกตา (cos = 0.84) · รูม่านตาย่อตามสัดส่วน
const IRIS_A = Math.acos(0.84);
const want = { key: 'm', r: null, l: null };
let introDone = false;
const loaded = {};
let cur = null;

// ตาวาดทีละพิกเซลใน shader (คมกว่าลงสีตามจุดยอด): ทิศจากกลางลูกตา → +z = มองตรง
// ตาขาว → ม่านตา (cos > 0.84 ราว 11 มม.) มีลายเส้นใย + ขอบเข้ม → รูม่านตาตามมิลลิเมตร
function eyeMat(m) {
  const u = {
    uC: { value: new THREE.Vector3() },
    uP: { value: Math.cos(IRIS_A * 3 / 11) },
    uE: { value: 0 },
  };
  const mat = new THREE.ShaderMaterial({
    uniforms: u,
    vertexShader:
      'varying vec3 vW; void main(){ vec4 w = modelMatrix * vec4(position,1.0); vW = w.xyz;' +
      ' gl_Position = projectionMatrix * viewMatrix * w; }',
    fragmentShader: [
      'uniform vec3 uC; uniform float uP; uniform float uE; varying vec3 vW;',
      'void main(){',
      ' vec3 d = normalize(vW - uC); float t = d.z;',
      ' float ci = 0.84;',
      ' vec3 sclera = vec3(0.96, 0.94, 0.92);',
      ' float a = atan(d.y, d.x);',
      ' float f = 0.5 + 0.5 * sin(a * 38.0);',
      ' float k = clamp((t - ci) / max(uP - ci, 1e-4), 0.0, 1.0);',
      ' vec3 iris = mix(vec3(0.26, 0.15, 0.08), vec3(0.55, 0.36, 0.2), k * 0.9 + f * 0.12);',
      ' float aa = fwidth(t) * 1.2;',
      ' vec3 col = mix(sclera, vec3(0.18, 0.11, 0.06), smoothstep(ci - aa, ci + aa, t));',
      ' col = mix(col, iris, smoothstep(ci + 0.012 - aa, ci + 0.012 + aa, t));',
      ' vec3 pup = mix(vec3(0.03, 0.02, 0.015), vec3(0.35, 0.27, 0.22), uE);',
      ' col = mix(col, pup, smoothstep(uP - aa, uP + aa, t));',
      // จุดสะท้อนแสงบนกระจกตา
      ' float hl = smoothstep(0.9965, 0.9985, dot(d, normalize(vec3(0.28, 0.3, 0.91))));',
      ' col = mix(col, vec3(1.0), hl);',
      ' gl_FragColor = vec4(col, 1.0);',
      '}'].join('\n'),
  });
  mat.extensions = { derivatives: true };
  mat.userData.u = u;
  return mat;
}

function eyeColors(e, mm, empty) {
  const u = e.mesh.material.userData.u;
  u.uC.value.copy(e.ctr);
  u.uP.value = Math.cos(IRIS_A * Math.max(mm, 0.8) / 11);
  u.uE.value = empty ? 1 : 0;
}

function tex(url) {
  const t = new THREE.TextureLoader().load(url, draw);
  t.flipY = false;
  return t;
}

function load(k) {
  if (loaded[k]) return Promise.resolve(loaded[k]);
  return new Promise(function (res) {
    new THREE.GLTFLoader().load(k + '.glb', function (gltf) {
      try {
      const root = gltf.scene;
      // ไฟล์ห่อด้วย bp3d_frame (แปลงเป็นพิกัด BodyParts3D มม. แกน Z ขึ้น)
      // หน้านี้ใช้พิกัดเดิมของหุ่น (เมตร Y ขึ้น หน้าไป +z) จึงคืนค่าเป็นศูนย์
      const frame = root.getObjectByName('bp3d_frame');
      if (frame) {
        frame.position.set(0, 0, 0);
        frame.quaternion.identity();
        frame.scale.set(1, 1, 1);
      }
      root.updateMatrixWorld(true);
      const eyes = {};
      let skin = null;
      root.traverse(function (m) {
        if (!m.isMesh) return;
        if (/eye/i.test(m.name) || /eye/i.test(m.parent && m.parent.name || '')) {
          const g = m.geometry;
          const pos = g.attributes.position;
          const v = new THREE.Vector3(), ctr = new THREE.Vector3();
          const arr = [];
          for (let i = 0; i < pos.count; i++) {
            v.fromBufferAttribute(pos, i).applyMatrix4(m.matrixWorld);
            arr.push(v.clone()); ctr.add(v);
          }
          ctr.multiplyScalar(1 / pos.count);
          const pts = arr.map(function (q) { return q.sub(ctr).normalize().z; });
          const col = new Float32Array(pos.count * 3);
          g.setAttribute('color', new THREE.BufferAttribute(col, 3));
          m.material = eyeMat(m);
          // GLTFLoader ตัดจุดในชื่อ node (eye.R → eyeR) แยกข้างตามตำแหน่งแทน (ด้านล่าง)
          (eyes.list = eyes.list || []).push({ mesh: m, pts: pts, col: col, ctr: ctr });
        } else if (!skin || m.geometry.attributes.position.count >
            skin.geometry.attributes.position.count) {
          skin = m;
        }
      });
      if (skin) {
        // ผิวแบบ toon (flat 2D) ไม่ใช้ normal/AO map ที่ทำให้ดูเหมือนรูปถ่าย
        skin.material = new THREE.MeshToonMaterial({
          color: new THREE.Color(0xE8B596).convertSRGBToLinear(),
          gradientMap: toonTex,
        });
        // เส้นขอบแบบลายเส้น: เปลือกด้านหลังขยายตาม normal เล็กน้อย
        const line = new THREE.Mesh(skin.geometry, new THREE.MeshBasicMaterial({
          color: new THREE.Color(0x6B4434).convertSRGBToLinear(), side: THREE.BackSide }));
        line.material.onBeforeCompile = function (sh) {
          sh.vertexShader = sh.vertexShader.replace('#include <begin_vertex>',
              'vec3 transformed = position + normal * 0.0012;');
        };
        skin.add(line);
      }
      // ตาขวาของผู้ป่วยอยู่ฝั่ง -x (+x = ซ้ายของผู้ป่วย)
      const list = (eyes.list || []).sort(function (a, b) { return a.ctr.x - b.ctr.x; });
      delete eyes.list;
      if (list.length >= 2) { eyes.r = list[0]; eyes.l = list[list.length - 1]; }
      // จัดกล้องที่กลางระหว่างตาสองข้าง มองตรงหน้า (+z)
      const mid = eyes.r && eyes.l
          ? eyes.r.ctr.clone().add(eyes.l.ctr).multiplyScalar(0.5)
          : new THREE.Vector3(0, 1.55, 0.1);
      loaded[k] = { root: root, eyes: eyes, mid: mid };
      res(loaded[k]);
      } catch (e) {}
    }, undefined, function () {});
  });
}

function draw() { renderer.render(scene, cam); }

// ระยะกล้องให้เห็นกว้างราว 18 ซม. (ตาสองข้าง + ดั้งจมูก) สูงอย่างน้อย 7 ซม.
function dist() {
  const t = Math.tan(cam.fov * Math.PI / 360);
  // แผงลอยสองข้างกินพื้นที่ ให้หน้าอยู่ช่วงกลางราว 40% ของความกว้าง
  return Math.max(0.15 / (t * cam.aspect), 0.035 / t);
}

function apply() {
  load(want.key).then(function (m) {
    try {
    if (cur !== m) {
      if (cur) scene.remove(cur.root);
      scene.add(m.root);
      cur = m;
    }
    for (const s of ['r', 'l']) {
      const e = m.eyes[s];
      if (e) eyeColors(e, want[s] == null ? 3 : want[s], want[s] == null);
    }
    const mid = m.mid;
    // ใกล้หน้าพอเห็นตาและจมูก เยื้องลงเล็กน้อยให้เห็นปลายจมูก
    // ตาอยู่กลางกรอบ เห็นดั้งจมูกด้านล่าง
    key.position.set(mid.x + 0.6, mid.y + 0.8, mid.z + 1.2);
    fill.position.set(mid.x - 0.8, mid.y + 0.2, mid.z + 0.6);
    const look = new THREE.Vector3(mid.x, mid.y - 0.004, mid.z);
    const end = new THREE.Vector3(mid.x, mid.y - 0.004, mid.z + dist());
    if (!introDone) {
      // เปิดหน้ามาครั้งแรก: กล้องเลื่อนเข้าจากมุมเฉียงไกล ๆ มาหยุดที่ตา (1.4 วิ)
      introDone = true;
      const startOff = new THREE.Vector3(0.35, 0.12, 0.9);
      const t0 = performance.now();
      const step = function () {
        const k = Math.min(1, (performance.now() - t0) / 1400);
        const e = 1 - Math.pow(1 - k, 3);
        cam.position.copy(end).addScaledVector(startOff, 1 - e);
        cam.lookAt(look.x, look.y - 0.05 * (1 - e), look.z);
        draw();
        if (k < 1) requestAnimationFrame(step);
      };
      step();
      return;
    }
    cam.position.copy(end);
    cam.lookAt(look);
    draw();
    } catch (e) {}
  });
}

window.faceSet = function (k, r, l) {
  want.key = k; want.r = r; want.l = l;
  apply();
};

function size() {
  const w = innerWidth, h = innerHeight;
  renderer.setSize(w, h);
  cam.aspect = w / h;
  cam.updateProjectionMatrix();
  if (cur) apply(); else draw();
}
size(); addEventListener('resize', size);
apply();
if (window.ErFace) window.ErFace.postMessage('ready');
</script>
</body>
</html>
''';

/// ป้ายข้อมือผู้ป่วย (ESI) แบบสามมิติ: สายสี + แผ่น QR/บาร์โค้ด บนข้อมือหุ่นตัวเดียวกับหน้าผู้ป่วย กำมือ
/// (toon + เส้นขอบ แบบภาพ GCS) สีสายตามระดับ
///
/// กล้องมองเฉียงจากด้านขวา · ระดับเปลี่ยน = สายไล่สีและเด้งเล็กน้อย
/// วาดเฉพาะช่วงที่กำลังเคลื่อนไหว (ไม่มีลูปค้าง) เพื่อไม่ให้หนักเครื่อง
class ErEsiGauge3D extends StatefulWidget {
  const ErEsiGauge3D({super.key, required this.level});

  /// 1–5 (1 = เร่งด่วนสุด เข็มชี้ขวาสุด)
  final int level;

  @override
  State<ErEsiGauge3D> createState() => _ErEsiGauge3DState();
}

class _ErEsiGauge3DState extends State<ErEsiGauge3D> {
  WebViewController? _web;
  HttpServer? _server;
  ErWebFrame? _frame;
  bool _ready = false;

  static const _files = {
    '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
    '/GLTFLoader.js': ['assets/web/GLTFLoader.js', 'application/javascript'],
    '/m.glb': ['assets/models/er_body_realistic.glb', 'model/gltf-binary'],
  };

  @override
  void initState() {
    super.initState();
    _boot();
  }

  // hot reload: โหลดฉากใหม่ (HTML อาจเปลี่ยน)
  @override
  void reassemble() {
    super.reassemble();
    _ready = false;
    _web?.reload();
  }

  @override
  void didUpdateWidget(covariant ErEsiGauge3D old) {
    super.didUpdateWidget(old);
    if (old.level != widget.level) _push();
  }

  void _push() {
    if (!_ready) return;
    final js = 'window.gSet(${widget.level})';
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
            html: _gaugeHtml,
            channel: 'ErGauge',
            routes: [
              for (final e in _files.entries)
                ('^${RegExp.escape(e.key)}\$', e.value[0], e.value[1]),
            ],
            onMessage: (_) {
              _ready = true;
              _push();
            },
          ));
      return;
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path == '/' || req.uri.path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
        req.response.headers.set('cache-control', 'no-store');
        req.response.write(_gaugeHtml);
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
        _push();
      }))
      ..loadRequest(Uri.parse(
          'http://127.0.0.1:${server.port}/index.html?v=${DateTime.now().millisecondsSinceEpoch}'));
    setState(() => _web = controller);
  }

  @override
  Widget build(BuildContext context) {
    final Widget view = _frame != null
        ? _frame!.view()
        : _web == null
            ? const SizedBox.shrink()
            : WebViewWidget(controller: _web!);
    return IgnorePointer(child: RepaintBoundary(child: view));
  }
}

const String _gaugeHtml = r'''

<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
<style>html,body{margin:0;height:100%;overflow:hidden;background:transparent}canvas{display:block}</style>
<script src="three.min.js"></script><script src="GLTFLoader.js"></script>
</head>
<body>
<script>
// สายรัดข้อมือ ESI บนแขนหุ่น 3D ตัวเดียวกับหน้าผู้ป่วย (toon + เส้นขอบ แบบรูป GCS)
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setClearColor(0x000000, 0);
renderer.outputEncoding = THREE.sRGBEncoding;
document.body.appendChild(renderer.domElement);
const scene = new THREE.Scene();
scene.add(new THREE.AmbientLight(0xffffff, 0.55));
const key = new THREE.DirectionalLight(0xffffff, 0.7); key.position.set(1.5, 2.5, 2.5); scene.add(key);
const toon = (function () {
  const d = new Uint8Array([150,150,150,255, 215,215,215,255, 255,255,255,255]);
  const t = new THREE.DataTexture(d, 3, 1, THREE.RGBAFormat);
  t.minFilter = t.magFilter = THREE.NearestFilter; t.needsUpdate = true; return t; })();
const C = h => new THREE.Color(h).convertSRGBToLinear();
const V = (x, y, z) => new THREE.Vector3(x, y, z);
const HUE = [0xBE1E2D, 0xAF1EBE, 0xDC8610, 0x006838, 0x465054];
const EN = ['Resuscitation', 'Emergent', 'Urgent', 'Less Urgent', 'Non-Urgent'];
// ข้อต่อแขนซ้ายของหุ่น (พิกัดหลังจัดเท้าแตะพื้น กลางตัว x = 0)
const E = V(0.3, 1.08, 0), W = V(0.375, 0.88, 0.067), H = V(0.42, 0.77, 0.11);
const cam = new THREE.PerspectiveCamera(24, 1, 0.01, 20);
const bandMat = new THREE.MeshToonMaterial({ color: C(HUE[2]), gradientMap: toon });
const cv = document.createElement('canvas'); cv.width = 512; cv.height = 200;
const ctx = cv.getContext('2d');
const tex = new THREE.CanvasTexture(cv); tex.encoding = THREE.sRGBEncoding;
let band = null, plate = null, studPivot = null, ready = false, bandHome = null, bandDir = null, halves = null, buildHalves = null;
function label(level) {
  const w = 512, h = 160;
  ctx.clearRect(0, 0, w, 200);
  ctx.fillStyle = '#ffffff'; ctx.fillRect(0, 0, w, 200);
  // QR จำลอง: finder 3 มุม + จุดสุ่มคงที่
  const qx = 24, qy = 22, qs = 156, n = 21, c = qs / n;
  let seed = 7; const rnd = () => (seed = (seed * 9301 + 49297) % 233280) / 233280;
  ctx.fillStyle = '#111';
  for (let y = 0; y < n; y++) for (let x = 0; x < n; x++) if (rnd() > 0.55) ctx.fillRect(qx + x * c, qy + y * c, c, c);
  for (const [fx, fy] of [[0, 0], [n - 7, 0], [0, n - 7]]) {
    ctx.fillStyle = '#fff'; ctx.fillRect(qx + fx * c - 2, qy + fy * c - 2, 7 * c + 4, 7 * c + 4);
    ctx.fillStyle = '#111'; ctx.fillRect(qx + fx * c, qy + fy * c, 7 * c, 7 * c);
    ctx.fillStyle = '#fff'; ctx.fillRect(qx + (fx + 1) * c, qy + (fy + 1) * c, 5 * c, 5 * c);
    ctx.fillStyle = '#111'; ctx.fillRect(qx + (fx + 2) * c, qy + (fy + 2) * c, 3 * c, 3 * c);
  }
  // บาร์โค้ดแนวตั้ง
  let bx = 206; seed = 3;
  while (bx < 300) { const bw = 2 + Math.floor(rnd() * 5); if (rnd() > 0.4) { ctx.fillRect(bx, 22, bw, 156); } bx += bw + 2; }
  // ตัวหนังสือ: ระดับ ESI (สีตามระดับ) + HN
  ctx.fillStyle = '#' + HUE[level - 1].toString(16).padStart(6, '0');
  ctx.font = 'bold 64px sans-serif'; ctx.textBaseline = 'top';
  ctx.fillText('ESI ' + level, 316, 30);
  ctx.fillStyle = '#333'; ctx.font = '600 30px sans-serif';
  ctx.fillText(EN[level - 1], 316, 104);
  ctx.fillStyle = '#777'; ctx.font = '500 26px sans-serif';
  ctx.fillText('HN 00012345', 316, 146);
  tex.needsUpdate = true;
}
const outer = new THREE.Group(); scene.add(outer);
const rig = new THREE.Group(); outer.add(rig);
new THREE.GLTFLoader().load('m.glb', function (g) {
  const fr = g.scene.getObjectByName('bp3d_frame');
  if (fr) { fr.position.set(0, 0, 0); fr.quaternion.identity(); fr.scale.set(1, 1, 1); }
  g.scene.updateMatrixWorld(true);
  let skin = null;
  g.scene.traverse(m => { if (m.isMesh && !/eye/i.test(m.name) && (!skin || m.geometry.attributes.position.count > skin.geometry.attributes.position.count)) skin = m; });
  const geo = skin.geometry.clone(); geo.applyMatrix4(skin.matrixWorld);
  geo.computeBoundingBox(); const bb = geo.boundingBox;
  geo.translate(-(bb.min.x + bb.max.x) / 2, -bb.min.y, 0);

  const qs0 = new URLSearchParams(location.search);
  // กำมือ: งอนิ้วรอบข้อนิ้ว (โค้ง) รวมนิ้วโป้ง · แขนซ้าย (+x)
  {
    const pos = geo.attributes.position;
    const Wr = W, ax = H.clone().sub(W).normalize();
    const nP = V(-1, 0, 0).sub(ax.clone().multiplyScalar(-ax.x)).normalize();
    const KN = 0.085, RR = +(qs0.get('rr') || 0.03);
    // ด้านนิ้วโป้ง: ไม่งอนิ้วโป้ง (มือกำหลวม ๆ แบบรูปอ้างอิง)
    const th = V(0, 0, 1).sub(ax.clone().multiplyScalar(ax.z)).sub(nP.clone().multiplyScalar(nP.z)).normalize();
    const q = V(0, 0, 0);
    for (let i = 0; i < pos.count; i++) {
      q.fromBufferAttribute(pos, i);
      if (q.x < 0.3 || q.y > 0.95) continue;
      const d = q.clone().sub(Wr), s = d.dot(ax), off = d.dot(nP);
      if (s <= KN || (d.dot(th) > 0.018 && s < 0.105)) continue;
      const phi = Math.min((s - KN) / RR, Math.PI * +(qs0.get('curl') || 0.6));
      const lat = d.clone().sub(ax.clone().multiplyScalar(s)).sub(nP.clone().multiplyScalar(off));
      const rr = RR - off;
      const np = Wr.clone().add(ax.clone().multiplyScalar(KN + rr * Math.sin(phi))).add(nP.clone().multiplyScalar(RR - rr * Math.cos(phi))).add(lat);
      pos.setXYZ(i, np.x, np.y, np.z);
    }
    pos.needsUpdate = true; geo.computeVertexNormals();
  }

  const AT = W.clone().lerp(E, 0.12);
  const keep = m => { m.onBeforeCompile = sh => {
    sh.uniforms.uA = { value: AT };
    sh.vertexShader = sh.vertexShader.replace('#include <common>', '#include <common>\nvarying vec3 vP;').replace('#include <begin_vertex>', '#include <begin_vertex>\nvP = position;');
    sh.fragmentShader = sh.fragmentShader.replace('#include <common>', '#include <common>\nvarying vec3 vP; uniform vec3 uA;').replace('void main() {', 'void main() {\n if (distance(vP, uA) > 0.42 || vP.x < 0.24) discard;');
  }; };
  const body = new THREE.Mesh(geo, new THREE.MeshToonMaterial({ color: C(0xE8B596), gradientMap: toon }));
  keep(body.material); rig.add(body);
  const line = new THREE.Mesh(geo, new THREE.MeshBasicMaterial({ color: C(0x6B4434), side: THREE.BackSide }));
  line.material.onBeforeCompile = sh => {
    sh.uniforms.uA = { value: AT };
    sh.vertexShader = sh.vertexShader.replace('#include <common>', '#include <common>\nvarying vec3 vP;').replace('#include <begin_vertex>', 'vec3 transformed = position + normal * 0.0016; vP = position;');
    sh.fragmentShader = sh.fragmentShader.replace('#include <common>', '#include <common>\nvarying vec3 vP; uniform vec3 uA;').replace('void main() {', 'void main() {\n if (distance(vP, uA) > 0.42 || vP.x < 0.24) discard;');
  };
  rig.add(line);
  // สาย: วงแหวนหนา รอบข้อมือ แกนตามแนวแขนท่อนปลาย
  const axis = W.clone().sub(E).normalize();
  const at = W.clone().lerp(E, 0.12);
  const R = +(new URLSearchParams(location.search).get('r') || 0.034);
  const prof = []; const Hh = 0.016, T = 0.0022;
  for (let i = 0; i <= 12; i++) { const a = -Math.PI / 2 + i * Math.PI / 12; prof.push(new THREE.Vector2(R + T * Math.cos(a), Hh * Math.sin(a))); }
  // สายสองซีกประกบกัน (บานพับอยู่ด้านหลังข้อมือ) · สร้างซีกหลังรู้ทิศกล้อง
  band = new THREE.Group();
  const q = new THREE.Quaternion().setFromUnitVectors(V(0, 1, 0), axis);
  band.quaternion.copy(q); band.position.copy(at); rig.add(band);
  bandHome = at.clone(); bandDir = axis.clone();
  plate = new THREE.Mesh(new THREE.CylinderGeometry(R + T + 0.0012, R + T + 0.0012, 0.027, 48, 1, true, -0.62, 1.24),
    new THREE.MeshBasicMaterial({ map: tex }));
  const stud = new THREE.Mesh(new THREE.CylinderGeometry(0.0032, 0.0032, 0.003, 24), new THREE.MeshToonMaterial({ color: C(0xF4F4F4), gradientMap: toon }));
  stud.rotation.x = Math.PI / 2; stud.position.set(0, 0, R + T + 0.0012);
  studPivot = new THREE.Group(); studPivot.add(stud);
  buildHalves = function (face) {
    const back = face + Math.PI;
    const hp = V(Math.sin(back) * R, 0, Math.cos(back) * R);
    const mk = (start) => {
      const g = new THREE.LatheGeometry(prof, 40, start, Math.PI);
      g.translate(-hp.x, 0, -hp.z);
      const m = new THREE.Mesh(g, bandMat);
      const o = new THREE.Mesh(g, new THREE.MeshBasicMaterial({ color: C(0x2a2a2a), side: THREE.BackSide }));
      o.scale.setScalar(1.04); m.add(o);
      const pv = new THREE.Group(); pv.position.copy(hp); pv.add(m); band.add(pv);
      return [pv, m];
    };
    // ซีก A: จากบานพับวนผ่านด้านหน้า (มีแผ่นป้าย) · ซีก B: อีกครึ่ง (มีกระดุม)
    const [pa, ma] = mk(back);
    const [pb, mb] = mk(back - Math.PI);
    plate.position.set(-hp.x, 0, -hp.z); plate.rotation.y = face; pa.add(plate);
    studPivot.position.set(-hp.x, 0, -hp.z); studPivot.rotation.y = face - 0.95; pb.add(studPivot);
    halves = [pa, pb];
  };
  // แขนนอน: แนวแขนท่อนปลาย (ข้อศอก→ข้อมือ) ชี้ไปซ้าย · หมุนรอบแขนให้หลังมือหันขึ้น
  const qs = new URLSearchParams(location.search);
  rig.position.copy(at).multiplyScalar(-1);
  const qa = new THREE.Quaternion().setFromUnitVectors(axis, V(-1, 0, 0));
  const roll = new THREE.Quaternion().setFromAxisAngle(V(1, 0, 0), +(qs.get('roll') || -0.9));
  const tilt = new THREE.Quaternion().setFromAxisAngle(V(0, 0, 1), +(qs.get('tz') || -0.12));
  outer.quaternion.copy(tilt).multiply(roll).multiply(qa);
  const d = +(qs.get('d') || 0.42), ay = +(qs.get('ay') || 0.35), ax = +(qs.get('ax') || 0.3);
  cam.position.set(Math.sin(ax) * d, ay * d, Math.cos(ax) * d);
  cam.lookAt(+(qs.get('lx') || -0.035), +(qs.get('ly') || 0.0), 0);
  key.position.set(1, 2, 2);
  scene.updateMatrixWorld(true);
  const lc = band.worldToLocal(cam.position.clone());
  const face = Math.atan2(lc.x, lc.z);
  buildHalves(face);
  ready = true;
  putOn();
  size(); label(cur); draw();
});
function size() {
  const w = innerWidth, h = innerHeight;
  renderer.setSize(w, h); cam.aspect = w / h; cam.updateProjectionMatrix();
}
addEventListener('resize', () => { size(); draw(); });
function draw() { if (ready) renderer.render(scene, cam); }
let cur = 3, from = C(HUE[2]), to = from.clone(), t0 = 0, anim = false;
// ประกบสาย: สองซีกกางออกจากบานพับด้านหลัง แล้วหุบเข้าหากันรอบข้อมือ (easeOutBack)
let putT0 = 0, putting = false;
function putOn() { putT0 = performance.now(); if (!putting) { putting = true; requestAnimationFrame(putStep); } }
function putStep(now) {
  if (!halves) { requestAnimationFrame(putStep); return; }
  const t = Math.min(1, (now - putT0) / 850);
  const k = 1 + 2.4 * Math.pow(t - 1, 3) + 1.4 * Math.pow(t - 1, 2);
  const open = 0.85 * (1 - k);
  halves[0].rotation.y = open; halves[1].rotation.y = -open;
  draw();
  if (t < 1) requestAnimationFrame(putStep); else { putting = false; halves[0].rotation.y = 0; halves[1].rotation.y = 0; draw(); }
}
function step(now) {
  const t = Math.min(1, (now - t0) / 700);
  const e = 1 - Math.pow(1 - t, 3);
  bandMat.color.copy(from).lerp(to, e);
  const s = 1 + Math.sin(Math.PI * t) * 0.08;
  if (band && !putting) band.scale.setScalar(s);
  draw();
  if (t < 1) requestAnimationFrame(step); else anim = false;
}
window.gSet = function (level) {
  if (ready && level !== cur) putOn();
  cur = level; label(level);
  from = bandMat.color.clone(); to = C(HUE[level - 1]);
  t0 = performance.now();
  if (!anim) { anim = true; requestAnimationFrame(step); }
};
const L0 = +(new URLSearchParams(location.search).get('l') || 0);
if (L0) { cur = L0; bandMat.color.copy(C(HUE[L0 - 1])); }
if (window.ErGauge) window.ErGauge.postMessage('ready');
</script>
</body>
</html>
''';
