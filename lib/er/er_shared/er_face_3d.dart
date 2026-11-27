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
    this.span = 0.15,
    this.focus,
  });

  /// ขนาดรูม่านตา (มม.) ขวา/ซ้ายของผู้ป่วย · null = ยังไม่ประเมิน (แสดง 3 มม. จาง ๆ)
  final double? mmR, mmL;
  final bool female;

  /// ความกว้างที่กล้องเห็น (เมตร) · 0.15 = ตาสองข้าง + ดั้งจมูก เผื่อแผงลอยสองข้าง
  /// ค่าน้อย = ซูมเข้าใกล้ตา (แผงแคบที่ slider อยู่นอกภาพ)
  final double span;

  /// เน้นตาข้างเดียว ('R' / 'L' ของผู้ป่วย) กล้องซูมเข้าหาลูกตานั้น · null = มุมปกติ
  final String? focus;

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
        old.female != widget.female ||
        old.span != widget.span ||
        old.focus != widget.focus) {
      _push();
    }
  }

  void _push() {
    if (!_ready) return;
    String v(double? x) => x == null ? 'null' : x.toStringAsFixed(2);
    final js = 'window.faceSet(${widget.female ? "'f'" : "'m'"}, '
        '${v(widget.mmR)}, ${v(widget.mmL)}, ${widget.span}, '
        '${widget.focus == null ? 'null' : "'${widget.focus!.toLowerCase()}'"})';
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
// preserveDrawingBuffer: วาดเฉพาะตอนค่าเปลี่ยน (ไม่มีลูป) = ต้องเก็บภาพเฟรมล่าสุดไว้
// ไม่งั้น WebView ที่ถูกซ่อนแล้วกลับมาแสดง (สลับแท็บ เลื่อนพ้นจอ) จะว่างจนกว่าค่าจะเปลี่ยน
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, preserveDrawingBuffer: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 3));
renderer.setClearColor(0x000000, 0);
renderer.outputEncoding = THREE.sRGBEncoding;
document.body.appendChild(renderer.domElement);

const scene = new THREE.Scene();
const cam = new THREE.PerspectiveCamera(24, 1, 0.01, 10);
// แสงชุดเดียวกับภาพหุ่นสแกนใบหน้า (Blender): ไฟหลักนุ่มเฉียงบน + ไฟเติมฝั่งตรงข้าม + ไฟขอบหลัง
// + แสงรอบตัวเทาอมฟ้า · ผิว PBR มี normal/AO ของหุ่น (ไม่ใช่ toon แบ่งเฉด)
scene.add(new THREE.HemisphereLight(0xffffff, 0xb8bfcc, 0.62));
const key = new THREE.DirectionalLight(0xffffff, 1.55);
const fill = new THREE.DirectionalLight(0xffffff, 0.5);
const rim = new THREE.DirectionalLight(0xffffff, 0.75);
const lightAt = new THREE.Object3D();
key.target = fill.target = rim.target = lightAt;
scene.add(key, fill, rim, lightAt);

// ม่านตาราว 11 มม. → มุมขอบม่านตาบนลูกตา (cos = 0.84) · รูม่านตาย่อตามสัดส่วน
const IRIS_A = Math.acos(0.84);
const want = { key: 'm', r: null, l: null, span: 0.15, focus: null };
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
        // ผิวแบบเดียวกับภาพหุ่นสแกนใบหน้า: PBR นุ่ม + normal map + AO ของหุ่น (ไม่มีเส้นขอบ)
        const g = skin.geometry;
        if (g.attributes.uv && !g.attributes.uv2) g.setAttribute('uv2', g.attributes.uv);
        skin.material = new THREE.MeshStandardMaterial({
          color: new THREE.Color(0xE9A27C).convertSRGBToLinear(),
          roughness: 0.55,
          metalness: 0.0,
          normalMap: tex(k + '_n.jpg'),
          normalScale: new THREE.Vector2(0.8, 0.8),
          aoMap: tex(k + '_ao.jpg'),
          aoMapIntensity: 0.85,
        });
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
  return Math.max(want.span / (t * cam.aspect), 0.035 / t);
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
    // ทิศแสงแบบภาพสแกนใบหน้า: หลักเฉียงบนจากฝั่งขวาจอ · เติมซ้าย · ขอบจากด้านหลังเฉียงบน
    lightAt.position.copy(mid);
    key.position.set(mid.x + 0.8, mid.y + 0.9, mid.z + 1.0);
    fill.position.set(mid.x - 0.8, mid.y + 0.2, mid.z + 0.6);
    rim.position.set(mid.x - 0.4, mid.y + 0.6, mid.z - 1.0);
    let look = new THREE.Vector3(mid.x, mid.y - 0.004, mid.z);
    let end = new THREE.Vector3(mid.x, mid.y - 0.004, mid.z + dist());
    // เน้นตาข้างเดียว (กำลังเลื่อน slider): เห็นกว้างราว 3.5 ซม. ลูกตา + เปลือกตา
    const fe = want.focus === 'r' ? m.eyes.r : want.focus === 'l' ? m.eyes.l : null;
    if (fe) {
      const t = Math.tan(cam.fov * Math.PI / 360);
      look = fe.ctr.clone();
      end = fe.ctr.clone().add(new THREE.Vector3(0, 0,
          Math.max(0.035 / (t * cam.aspect), 0.026 / t)));
    }
    if (!introDone) {
      // เปิดหน้ามาครั้งแรก: กล้องเลื่อนเข้าจากมุมเฉียงไกล ๆ มาหยุดที่ตา (1.4 วิ)
      introDone = true;
      lookNow.copy(look);
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
    camGo(look, end);
    } catch (e) {}
  });
}

// เลื่อนกล้องนุ่ม ๆ ไปยังเป้า (เข้า/ออกจากตาที่เน้น) · ค่าเปลี่ยนระหว่างทาง = ต่อจากตำแหน่งปัจจุบัน
const lookNow = new THREE.Vector3();
let camTok = null;
function camGo(look, end) {
  if (cam.position.distanceTo(end) < 1e-5 && lookNow.distanceTo(look) < 1e-5) {
    draw();
    return;
  }
  const p0 = cam.position.clone(), l0 = lookNow.clone(), t0 = performance.now();
  const tok = {};
  camTok = tok;
  const step = function () {
    if (camTok !== tok) return;
    const k = Math.min(1, (performance.now() - t0) / 420);
    const e = 1 - Math.pow(1 - k, 3);
    cam.position.lerpVectors(p0, end, e);
    lookNow.lerpVectors(l0, look, e);
    cam.lookAt(lookNow);
    draw();
    if (k < 1) requestAnimationFrame(step);
  };
  step();
}

window.faceSet = function (k, r, l, span, focus) {
  want.key = k; want.r = r; want.l = l;
  if (span) want.span = span;
  want.focus = focus || null;
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
// กลับมาแสดง / GPU คืน context = วาดใหม่ทันที (ภาพไม่หายหลังสลับแท็บ)
document.addEventListener('visibilitychange', function () { if (!document.hidden) draw(); });
addEventListener('pageshow', draw);
renderer.domElement.addEventListener('webglcontextrestored', function () { draw(); });
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
  const ErEsiGauge3D({super.key, required this.level, this.pose});

  /// 1–5 (1 = เร่งด่วนสุด)
  final int level;

  /// ท่าแขน/กล้อง (debugger): roll tz d ax ay lx ly · null = ค่าเริ่มต้นในฉาก
  final Map<String, double>? pose;

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
    // แขนแบบภาพหน้า KPI (er_patient_figure มือผ่อนคลาย) จัดวางในพิกัดเดียวกับแขนหุ่นผิวจริงแล้ว
    '/arm.glb': ['assets/models/er_esi_arm.glb', 'model/gltf-binary'],
  };

  @override
  void initState() {
    super.initState();
    _boot();
  }

  // hot reload: เปิด server ใหม่ (closure ของ server เก่าถือ HTML ชุดเดิมไว้ reload หน้าอย่างเดียวได้ฉากเก่า)
  @override
  void reassemble() {
    super.reassemble();
    _ready = false;
    if (kIsWeb) {
      _web?.reload();
      return;
    }
    _server?.close(force: true);
    _server = null;
    _boot();
  }

  @override
  void didUpdateWidget(covariant ErEsiGauge3D old) {
    super.didUpdateWidget(old);
    if (old.level != widget.level) _push();
    if (old.pose != widget.pose) _pushPose();
  }

  void _pushPose() {
    final p = widget.pose;
    if (!_ready || p == null) return;
    final js =
        'window.bandPose({${p.entries.map((e) => '${e.key}:${e.value}').join(',')}})';
    if (_frame != null) {
      _frame!.run(js);
    } else {
      _web?.runJavaScript(js);
    }
  }

  void _push() {
    if (!_ready) return;
    _pushPose();
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
// สายรัดข้อมือ ESI บนแขนหุ่น 3D ตัวเดียวกับหน้าผู้ป่วย
// แสงนุ่มแบบภาพหุ่นสแกนใบหน้า (2026-11-26 แทน toon + เส้นขอบ): ผิว PBR + normal/AO · ไฟหลัก/เติม/ขอบ
const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setClearColor(0x000000, 0);
renderer.outputEncoding = THREE.sRGBEncoding;
document.body.appendChild(renderer.domElement);
const scene = new THREE.Scene();
// แสงแบบภาพหน้า KPI: ผิวมีน้ำหนัก ไม่ซีด (ลดแสงรอบตัว/ไฟหลักจากเดิม)
scene.add(new THREE.HemisphereLight(0xffffff, 0xc9ced8, 0.34));
const key = new THREE.DirectionalLight(0xffffff, 0.95); key.position.set(-1.6, 2.4, 2.2); scene.add(key);
const fillL = new THREE.DirectionalLight(0xffffff, 0.26); fillL.position.set(2.0, 0.4, 1.6); scene.add(fillL);
const rimL = new THREE.DirectionalLight(0xffffff, 0.3); rimL.position.set(0.8, 1.5, -2.5); scene.add(rimL);
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
const bandMat = new THREE.MeshStandardMaterial({ color: C(HUE[2]), roughness: 0.6, metalness: 0.0 });
// ตัวสายสีขาว (แบบป้ายข้อมือโรงพยาบาล) · แถบสีระดับที่ขอบสาย
const strapMat = new THREE.MeshStandardMaterial({ color: C(0xFAFAF7), roughness: 0.6, metalness: 0.0 });
const cv = document.createElement('canvas'); cv.width = 512; cv.height = 200;
const ctx = cv.getContext('2d');
const tex = new THREE.CanvasTexture(cv); tex.encoding = THREE.sRGBEncoding;
// bandFit = สเกลวงรีที่พอดีข้อมือ (แอนิเมชันเปลี่ยนสีต้องคูณจากค่านี้ ไม่ใช่ตั้งเป็น 1)
let bandFit = null;
let band = null, plate = null, studPivot = null, ready = false, bandHome = null, bandDir = null, halves = null, buildHalves = null, wrapK = null, wrapGroup = null;
// texture สายทั้งเส้น (แบบสายรัดข้อมือโรงพยาบาล): หัวกว้าง + ช่องป้ายขาว + แป๊ก · หางแคบมีรู ปลายแหลม
const scv = document.createElement('canvas'); scv.width = 2048; scv.height = 160;
const sctx = scv.getContext('2d');
const stex = new THREE.CanvasTexture(scv); stex.encoding = THREE.sRGBEncoding; stex.minFilter = THREE.LinearFilter; stex.generateMipmaps = false;
const HEAD = 0.30; // สัดส่วนความยาวส่วนหัว
function label(level) {
  const W = 2048, H = 160, col = '#' + HUE[level - 1].toString(16).padStart(6, '0');
  const c = sctx; c.clearRect(0, 0, W, H);
  const hx = W * HEAD;
  c.fillStyle = col;
  // หัว (เต็มความกว้าง มุมมน) + หาง (แคบ 58%) ปลายแหลม
  const rr = 18; c.beginPath(); c.moveTo(rr, 0); c.lineTo(hx, 0); c.lineTo(hx + 40, H * 0.21); c.lineTo(W - 70, H * 0.21);
  c.lineTo(W - 4, H * 0.5); c.lineTo(W - 70, H * 0.79); c.lineTo(hx + 40, H * 0.79); c.lineTo(hx, H); c.lineTo(rr, H);
  c.arcTo(0, H, 0, H - rr, rr); c.lineTo(0, rr); c.arcTo(0, 0, rr, 0, rr); c.fill();
  // แป๊กสองวงที่ปลายหัว
  for (const cy of [H * 0.3, H * 0.72]) {
    c.fillStyle = 'rgba(255,255,255,0.55)'; c.beginPath(); c.arc(70, cy, 26, 0, Math.PI * 2); c.fill();
    c.fillStyle = 'rgba(255,255,255,0.9)'; c.beginPath(); c.arc(70, cy, 12, 0, Math.PI * 2); c.fill();
  }
  // ช่องป้ายขาว: ระดับ ESI + บรรทัดข้อมูล
  const lx = 130, lw = hx - 170, ly = 14, lh = H - 28;
  c.fillStyle = '#ffffff'; c.beginPath(); c.moveTo(lx + 10, ly); c.arcTo(lx + lw, ly, lx + lw, ly + lh, 10); c.arcTo(lx + lw, ly + lh, lx, ly + lh, 10); c.arcTo(lx, ly + lh, lx, ly, 10); c.arcTo(lx, ly, lx + lw, ly, 10); c.fill();
  c.fillStyle = col; c.font = 'bold 56px sans-serif'; c.textBaseline = 'middle';
  c.fillText('ESI ' + level, lx + 18, ly + 38);
  c.fillStyle = '#4A4F57'; c.font = '600 22px sans-serif';
  c.fillText(EN[level - 1], lx + 190, ly + 40);
  c.fillStyle = '#9AA0A6';
  for (let k = 0; k < 3; k++) c.fillRect(lx + 18, ly + 78 + k * 18, lw - 36, 3);
  // รูตามหาง
  c.globalCompositeOperation = 'destination-out';
  for (let x = hx + 160; x < W - 120; x += 110) { c.beginPath(); c.arc(x, H / 2, 13, 0, Math.PI * 2); c.fill(); }
  c.globalCompositeOperation = 'source-over';
  stex.needsUpdate = true;
}
// ชั้นนอกสุดสำหรับ motion ตอนปรากฏ (แขนยกขึ้นจากขอบล่าง) แยกจากท่าที่ applyPose ตั้ง
const introG = new THREE.Group(); scene.add(introG);
const outer = new THREE.Group(); introG.add(outer);
const rig = new THREE.Group(); outer.add(rig);
// จางขอบบนภาพ (ปลายนิ้วค่อย ๆ หาย ไม่ถูกตัดตรง): tf = สัดส่วนความสูงจากขอบบน · vh = ความสูง buffer (px)
var uTF = { value: 0.0 }, uVH = { value: 1.0 }, uEF = { value: 1.0 }, uBH = { value: 0.0 };
// แขนเดียวกับภาพหน้า KPI (2026-11-26): er_esi_arm.glb ส่งออกจาก Blender ในพิกัดนี้แล้ว (ข้อศอก E ข้อมือ W)
// มือผ่อนคลาย (ไม่ต้องงอนิ้วเอง) · สายรัดชุดเดิม
new THREE.GLTFLoader().load('arm.glb', function (g) {
  g.scene.updateMatrixWorld(true);
  let skin = null;
  g.scene.traverse(m => { if (m.isMesh && (!skin || m.geometry.attributes.position.count > skin.geometry.attributes.position.count)) skin = m; });
  const geo = skin.geometry.clone(); geo.applyMatrix4(skin.matrixWorld);
  geo.computeVertexNormals();

  const qs0 = new URLSearchParams(location.search);
  if (false) {
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

  // ตำแหน่งสายตามแนวแขน (0 = ข้อมือ … 1 = ข้อศอก)
  const BAND_T = 0.12;
  const AT = W.clone().lerp(E, BAND_T);
  const keep = m => { m.onBeforeCompile = sh => {
    sh.uniforms.uA = { value: AT };
    sh.uniforms.uE = { value: E.clone() };
    sh.uniforms.uTF = uTF; sh.uniforms.uVH = uVH; sh.uniforms.uEF = uEF; sh.uniforms.uBH = uBH;
    sh.vertexShader = sh.vertexShader.replace('#include <common>', '#include <common>\nvarying vec3 vP;').replace('#include <begin_vertex>', '#include <begin_vertex>\nvP = position;');
    sh.fragmentShader = sh.fragmentShader.replace('#include <common>', '#include <common>\nvarying vec3 vP; uniform vec3 uA; uniform vec3 uE; uniform float uTF; uniform float uVH; uniform float uEF; uniform float uBH;').replace('void main() {', 'void main() {\n if (distance(vP, uA) > 0.42 || vP.x < 0.24) discard;')
      // แขนท่อนล่างจางหายไปทางข้อศอก (แบบภาพหน้า KPI)
      .replace('#include <dithering_fragment>', '#include <dithering_fragment>\n float tA = dot(vP - uA, normalize(uE - uA));\n if (uBH > 0.0) gl_FragColor.rgb *= mix(0.86, 1.0, smoothstep(uBH - 0.002, uBH + 0.009, abs(tA)));\n gl_FragColor.a *= mix(1.0, 1.0 - smoothstep(0.03, 0.12, tA), uEF);\n if (uTF > 0.0) gl_FragColor.a *= 1.0 - smoothstep(1.0 - uTF, 1.0, gl_FragCoord.y / uVH);');
  }; m.transparent = true; };
  // ผิวสีเดียวกับภาพหน้า KPI (#EFA77A) แสงนุ่ม (ไม่มีเส้นขอบ)
  const body = new THREE.Mesh(geo, new THREE.MeshStandardMaterial({
    color: C(0xEFA77A), roughness: 0.55, metalness: 0.0 }));
  keep(body.material); rig.add(body);
  // สาย: วงแหวนหนา รอบข้อมือ แกนตามแนวแขนท่อนปลาย
  const axis = W.clone().sub(E).normalize();
  const at = W.clone().lerp(E, BAND_T);
  const R = +(new URLSearchParams(location.search).get('r') || 0.034);
  const prof = []; const Hh = 0.017, T = 0.0022;
  for (let i = 0; i <= 12; i++) { const a = -Math.PI / 2 + i * Math.PI / 12; prof.push(new THREE.Vector2(R + T * Math.cos(a), Hh * Math.sin(a))); }
  // สายสองซีกประกบกัน (บานพับอยู่ด้านหลังข้อมือ) · สร้างซีกหลังรู้ทิศกล้อง
  band = new THREE.Group();
  const q = new THREE.Quaternion().setFromUnitVectors(V(0, 1, 0), axis);
  band.quaternion.copy(q); band.position.copy(at); rig.add(band);
  // สายพอดีข้อมือแขน KPI (ผู้ใช้ 2026-11-26 "สายรัดขนาดยังไม่สมส่วนกับแขน"): วัดหน้าตัดข้อมือจริงตรงตำแหน่งสาย
  // แล้วทำวงเป็นวงรีที่ครอบข้อมือทั้งความกว้างสาย (ไม่ทะลุ) + เผื่อหลวม · ความกว้างสายปรับตามสัดส่วนเดียวกัน ป้ายไม่เพี้ยน
  {
    const pos = geo.attributes.position, idx = geo.index, p = V(0, 0, 0), pa = V(0, 0, 0), pb = V(0, 0, 0);
    const u1 = V(1, 0, 0).sub(axis.clone().multiplyScalar(axis.x)).normalize();
    const u2 = axis.clone().cross(u1).normalize();
    // หน้าตัดข้อมือ = จุดที่ขอบสามเหลี่ยมตัดระนาบตั้งฉากแขน (ท่อนแขนมีจุดห่าง ใช้จุดยอดตรง ๆ ไม่ได้)
    // เก็บ 5 ระนาบตลอดความกว้างสาย: ข้อมือเปลี่ยนรูปตามแนวแขน สายต้องครอบทุกระนาบ
    const hh = new Float32Array(pos.count);
    const pts = [];
    const cut = (a, b) => {
      if ((hh[a] < 0) === (hh[b] < 0)) return;
      pa.fromBufferAttribute(pos, a); pb.fromBufferAttribute(pos, b);
      p.copy(pa).lerp(pb, hh[a] / (hh[a] - hh[b])).sub(at);
      pts.push([p.dot(u1), p.dot(u2)]);
    };
    const nIdx = idx ? idx.count : pos.count;
    for (const dz of [-1, -0.5, 0, 0.5, 1]) {
      const o = at.clone().addScaledVector(axis, dz * Hh * 1.15);
      for (let i = 0; i < pos.count; i++) hh[i] = p.fromBufferAttribute(pos, i).sub(o).dot(axis);
      for (let k = 0; k + 2 < nIdx; k += 3) {
        const a = idx ? idx.getX(k) : k, b = idx ? idx.getX(k + 1) : k + 1, c = idx ? idx.getX(k + 2) : k + 2;
        cut(a, b); cut(b, c); cut(c, a);
      }
    }
    if (pts.length > 24) {
      let mx = 0, my = 0;
      for (const t of pts) { mx += t[0]; my += t[1]; }
      mx /= pts.length; my /= pts.length;
      let sxx = 0, syy = 0, sxy = 0;
      for (const t of pts) { const x = t[0] - mx, y = t[1] - my; sxx += x * x; syy += y * y; sxy += x * y; }
      const phi = 0.5 * Math.atan2(2 * sxy, sxx - syy), ca = Math.cos(phi), sa = Math.sin(phi);
      // แกนหลัก: ศูนย์กลาง = กึ่งกลางระยะสุดขอบ (ไม่ใช่ค่าเฉลี่ยจุด ที่เอียงตามความหนาแน่นของ mesh)
      let x0 = 1e9, x1 = -1e9, y0 = 1e9, y1 = -1e9;
      const pr = pts.map(t => { const x = t[0] * ca + t[1] * sa, y = -t[0] * sa + t[1] * ca;
        x0 = Math.min(x0, x); x1 = Math.max(x1, x); y0 = Math.min(y0, y); y1 = Math.max(y1, y); return [x, y]; });
      const cx = (x0 + x1) / 2, cy = (y0 + y1) / 2, ea = (x1 - x0) / 2, eb = (y1 - y0) / 2;
      // ข้อมือเป็นสี่เหลี่ยมมุมมน: มุมเฉียงยื่นพ้นวงรีที่วัดจากขอบ → ขยายวงรีจนครอบทุกจุด (ไม่ทะลุ)
      let sc = 1.0;
      for (const t of pr) sc = Math.max(sc, Math.hypot((t[0] - cx) / ea, (t[1] - cy) / eb));
      const major = u1.clone().multiplyScalar(ca).add(u2.clone().multiplyScalar(sa)).normalize();
      const minor = axis.clone().cross(major).normalize();
      const m4 = new THREE.Matrix4().makeBasis(major, axis, major.clone().cross(axis).normalize());
      band.quaternion.setFromRotationMatrix(m4);
      band.position.copy(at).add(major.clone().multiplyScalar(cx)).add(minor.clone().multiplyScalar(cy));
      // หลวมแบบสายจริง: เผื่อข้าง 3 มม. หน้า-หลัง 5 มม. รอบวงที่ครอบข้อมือแล้ว
      const ka = (ea * sc + 0.003) / R, kb = (eb * sc + 0.005) / R;
      band.scale.set(ka, ka, kb);
      bandFit = band.scale.clone();
      // เงาสัมผัสบนผิวตรงขอบสาย (สายแนบผิว ไม่ลอย)
      uBH.value = Hh * ka;
    }
  }
  bandHome = band.position.clone(); bandDir = axis.clone();
  plate = new THREE.Mesh(new THREE.CylinderGeometry(R + T + 0.0012, R + T + 0.0012, 0.027, 48, 1, true, -0.62, 1.24),
    new THREE.MeshBasicMaterial({ map: tex }));
  const stud = new THREE.Mesh(new THREE.CylinderGeometry(0.0032, 0.0032, 0.003, 24), new THREE.MeshStandardMaterial({ color: C(0xF4F4F4), roughness: 0.4, metalness: 0.1 }));
  stud.rotation.x = Math.PI / 2; stud.position.set(0, 0, R + T + 0.0012);
  studPivot = new THREE.Group(); studPivot.add(stud);
  // สายแบนเส้นเดียว: พันจากกลางป้าย (หน้า) ปลายสองข้างไปบรรจบด้านหลัง
  // k = 0 สายตรง · k = 1 ปิดเป็นวงรอบข้อมือ (ความโค้ง = k / R)
  const L = 2 * Math.PI * R;
  const ribbons = [];
  function ribbon(u0, u1, y0, y1, off, mat, nu) {
    const n = nu || 96;
    const g = new THREE.BufferGeometry();
    const pos = new Float32Array((n + 1) * 2 * 3), uv = new Float32Array((n + 1) * 2 * 2), idx = [];
    for (let i = 0; i <= n; i++) {
      uv.set([i / n, 0, i / n, 1], i * 4);
      if (i < n) { const a = i * 2; idx.push(a, a + 1, a + 2, a + 1, a + 3, a + 2); }
    }
    g.setAttribute('position', new THREE.BufferAttribute(pos, 3));
    g.setAttribute('uv', new THREE.BufferAttribute(uv, 2));
    g.setIndex(idx);
    const m = new THREE.Mesh(g, mat);
    m.userData = { u0, u1, y0, y1, off, n };
    ribbons.push(m); wrapGroup.add(m);
    return m;
  }
  function bend(u, off, k) {
    const kap = k / R;
    if (kap < 1e-5) return [u, R + off];
    const a = kap * u, rr = 1 / kap;
    return [Math.sin(a) * (rr + off), R - rr + Math.cos(a) * (rr + off)];
  }
  wrapK = function (k) {
    for (const m of ribbons) {
      const d = m.userData, p = m.geometry.attributes.position;
      for (let i = 0; i <= d.n; i++) {
        const u = d.u0 + (d.u1 - d.u0) * i / d.n;
        const over = Math.max(0, u - (L - (d.u1 - d.u0 - L) - 0.004 + d.u0 + (d.u1 - d.u0 - L)));
        const [x, z] = bend(u, d.off - (u > L / 2 ? 0.0012 * (u - L / 2) / (d.u1 - L / 2) : 0), k);
        p.setXYZ(i * 2, x, d.y0, z); p.setXYZ(i * 2 + 1, x, d.y1, z);
      }
      p.needsUpdate = true; m.geometry.computeVertexNormals(); m.geometry.computeBoundingSphere();
    }
    const su = L / 2 - 0.006, [sx, sz] = bend(su, T + 0.0015, k);
    stud.position.set(sx, 0, sz);
    stud.rotation.set(Math.PI / 2, 0, 0); stud.rotateOnWorldAxis(V(0, 1, 0), (k / R) * su);
  };
  buildHalves = function (face) {
    wrapGroup = new THREE.Group(); wrapGroup.rotation.y = face; band.add(wrapGroup);
    ribbons.length = 0;
    const sm = new THREE.MeshStandardMaterial({ map: stex, roughness: 0.6, metalness: 0.0, alphaTest: 0.5, side: THREE.DoubleSide });
    // ยาวกว่ารอบข้อมือ 22% ให้หางพันซ้อนใต้หัว · กลางช่องป้ายอยู่ด้านหน้า (u = 0)
    const LL = L * 1.22, u0 = -LL * HEAD * 0.55;
    ribbon(u0, u0 + LL, -Hh, Hh, 0, sm, 220);
    stud.visible = false;
    halves = true;
    wrapK(putting ? 0 : 1);
  };
  // แขนนอน: แนวแขนท่อนปลาย (ข้อศอก→ข้อมือ) ชี้ไปซ้าย · หมุนรอบแขนให้หลังมือหันขึ้น
  rig.position.copy(at).multiplyScalar(-1);
  armAxis = axis;
  applyPose();
  ready = true;
  size(); label(cur);
  intro();
});
// เรื่องตอนปรากฏ (ผู้ใช้ 2026-11-27 "appear story motion"): แขนยกขึ้นจากใต้ขอบการ์ด เอียงนิดแล้วตั้งตรง
// พอแขนเข้าที่ สายค่อยโผล่แล้วพันรอบข้อมือ + กดแป๊ก (putOn เดิม)
function intro() {
  if (band) band.visible = false;
  // เงาขอบสายบนผิวซ่อนไว้จนกว่าสายจะมา
  const bh = uBH.value; uBH.value = 0.0;
  const t0 = performance.now(), D = 900;
  introG.position.y = -0.34; introG.rotation.z = 0.16;
  function f(now) {
    const t = Math.min(1, (now - t0) / D);
    const c1 = 1.25, c3 = c1 + 1, x = t - 1;
    const e = 1 + c3 * x * x * x + c1 * x * x;          // easeOutBack (เลยนิดแล้วเข้าที่)
    introG.position.y = -0.34 * (1 - e);
    introG.rotation.z = 0.16 * (1 - Math.min(1, t * 1.15)) * (1 - Math.min(1, t * 1.15));
    draw();
    if (t < 1) { requestAnimationFrame(f); return; }
    introG.position.y = 0; introG.rotation.z = 0;
    if (band) band.visible = true;
    uBH.value = bh;
    putOn();
  }
  requestAnimationFrame(f);
}
// ท่าแขน + กล้อง (ค่าเริ่มต้นจาก query · debugger ใน Flutter ส่ง window.bandPose มาแทน)
const qsP = new URLSearchParams(location.search);
const POSE = {
  // ท่าแบบภาพหน้า KPI: แขนตั้งขึ้น มือชี้ฟ้า หลังมือหันเข้ากล้อง สายอยู่ครึ่งล่าง
  roll: +(qsP.get('roll') || 0.0), tz: +(qsP.get('tz') || -1.42),
  d: +(qsP.get('d') || 0.62), ax: +(qsP.get('ax') || 0.0), ay: +(qsP.get('ay') || 0.12),
  lx: +(qsP.get('lx') || 0.0), ly: +(qsP.get('ly') || -0.07),
  tf: +(qsP.get('tf') || 0.0),
  // ef = จางท่อนแขนไปทางข้อศอก (1 แบบภาพ KPI · 0 = ไม่จาง ให้ขอบกรอบตัดแทน)
  ef: qsP.has('ef') ? +qsP.get('ef') : 1.0,
};
let armAxis = null;
function applyPose() {
  if (uTF) { uTF.value = POSE.tf || 0.0; uEF.value = POSE.ef; uVH.value = renderer.domElement.height || 1.0; }
  if (!armAxis) return;
  const qa = new THREE.Quaternion().setFromUnitVectors(armAxis, V(-1, 0, 0));
  const roll = new THREE.Quaternion().setFromAxisAngle(V(1, 0, 0), POSE.roll);
  const tilt = new THREE.Quaternion().setFromAxisAngle(V(0, 0, 1), POSE.tz);
  outer.quaternion.copy(tilt).multiply(roll).multiply(qa);
  // วงโคจรกล้องรอบข้อมือ แล้วเลื่อนภาพตามแกนจอ (ซ้ายขวา/ขึ้นลง) ไม่ว่ากล้องอยู่มุมไหน
  const base = V(Math.sin(POSE.ax) * POSE.d, POSE.ay * POSE.d, Math.cos(POSE.ax) * POSE.d);
  const dir = base.clone().negate().normalize();
  const right = dir.clone().cross(V(0, 1, 0)).normalize();
  const up = right.clone().cross(dir).normalize();
  const pan = right.multiplyScalar(POSE.lx).add(up.multiplyScalar(-POSE.ly));
  cam.position.copy(base).add(pan);
  cam.lookAt(pan.x, pan.y, pan.z);
  // ไฟหลักตามกล้อง: เฉียงซ้ายบนของภาพ (แบบภาพหน้า KPI)
  key.position.copy(cam.position).add(dir.clone().cross(V(0, 1, 0)).normalize().multiplyScalar(-1.4)).add(V(0, 2.2, 0));
  scene.updateMatrixWorld(true);
  // สร้างสายครั้งแรกครั้งเดียว (ป้ายหันเข้ากล้องตามท่าเริ่มต้น)
  // ปรับท่าทีหลังไม่สร้างใหม่ ไม่งั้นการหมุนจะถูกหักล้าง
  if (!halves) {
    const lc = band.worldToLocal(cam.position.clone());
    buildHalves(Math.atan2(lc.x, lc.z));
  }
}
window.bandPose = function (p) { Object.assign(POSE, p); applyPose(); draw(); };
function size() {
  const w = innerWidth, h = innerHeight;
  renderer.setSize(w, h); cam.aspect = w / h; cam.updateProjectionMatrix();
  if (uVH) uVH.value = renderer.domElement.height || 1.0;
}
addEventListener('resize', () => { size(); draw(); });
// กรอบ WebView เปลี่ยนขนาดแต่บางครั้งไม่มี resize (การ์ดสูงขึ้น/ลดลงตามเนื้อหา) = ภาพยืดผิดสัดส่วน
// ตรวจขนาดจริงทุก 250 ms ถ้าต่างจาก canvas ให้ตั้งขนาด/กล้องใหม่แล้ววาดใหม่
setInterval(function () {
  const c = renderer.domElement, pr = renderer.getPixelRatio();
  if (Math.floor(innerWidth * pr) !== c.width || Math.floor(innerHeight * pr) !== c.height) { size(); applyPose(); draw(); }
}, 250);
function draw() { if (ready) renderer.render(scene, cam); }
let cur = 3, from = C(HUE[2]), to = from.clone(), t0 = 0, anim = false;
// ใส่สาย: แถบตรงค่อย ๆ พันรอบข้อมือจนปลายบรรจบ แล้วกดแป๊ก
let putT0 = 0, putting = false;
function putOn() { putT0 = performance.now(); if (!putting) { putting = true; requestAnimationFrame(putStep); } }
function putStep(now) {
  if (!halves) { requestAnimationFrame(putStep); return; }
  const t = Math.min(1, (now - putT0) / 1150);
  // พัน 0–80% ของเวลา (เร่งแล้วชะลอ) · 80–100% กดแป๊ก: บีบเข้าเล็กน้อยแล้วคืน
  const w = Math.min(1, t / 0.8);
  const k = w < 0.5 ? 4 * w * w * w : 1 - Math.pow(-2 * w + 2, 3) / 2;
  wrapK(k);
  const snap = t > 0.8 ? Math.sin((t - 0.8) / 0.2 * Math.PI) : 0;
  if (wrapGroup) wrapGroup.scale.set(1 - 0.05 * snap, 1, 1 - 0.05 * snap);
  draw();
  if (t < 1) requestAnimationFrame(putStep); else { putting = false; wrapK(1); if (wrapGroup) wrapGroup.scale.set(1, 1, 1); draw(); }
}
function step(now) {
  const t = Math.min(1, (now - t0) / 700);
  const e = 1 - Math.pow(1 - t, 3);
  bandMat.color.copy(from).lerp(to, e);
  const s = 1 + Math.sin(Math.PI * t) * 0.08;
  if (band && !putting) { if (bandFit) band.scale.copy(bandFit).multiplyScalar(s); else band.scale.setScalar(s); }
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
