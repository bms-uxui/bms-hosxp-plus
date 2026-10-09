/// ผังห้องฉุกเฉินสามมิติ (หน้าภาพรวม) หมุน/ซูม/แตะโซนได้
///
/// โมเดลสถาปัตย์สีขาว แต่ละโซนเรืองสีตามความเร่งด่วน ผู้ป่วยเป็นหุ่นสีตาม ESI
/// นอนบนเตียง/นั่งเก้าอี้ คนที่เกินจำนวนที่มียืนรอที่ทางเดิน (เห็นความแออัดทันที)
/// ป้ายลอยเหนือโซนบอกจำนวนผู้ป่วยเทียบที่รองรับ
///
/// วาดเฉพาะตอนมีการเปลี่ยนแปลง (ลาก ซูม บินกล้อง ข้อมูลใหม่) ปล่อยนิ่ง = ไม่วาดเฟรม
/// มือถือเปิดใน WebView ผ่าน HttpServer ในเครื่อง · เว็บใช้ iframe ([ErWebFrame])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import 'er_web_alive.dart';
import 'er_web_frame.dart';

/// หนึ่งโซนในผัง
class ErFloorZone {
  const ErFloorZone({
    required this.id,
    required this.label,
    required this.color,
    required this.patients,
  });

  /// red · yellow · green · triage · after (ตรงกับผังใน JS)
  final String id;
  final String label;
  final Color color;

  /// สีของผู้ป่วยแต่ละคนในโซน (สี ESI · ยังไม่คัดกรอง = เทา)
  final List<Color> patients;

  Map<String, Object> toJson() => {
        'id': id,
        'label': label,
        'color': _hex(color),
        'patients': [for (final c in patients) _hex(c)],
      };

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

class ErFloor3D extends StatefulWidget {
  const ErFloor3D({super.key, required this.zones, this.onZone});

  final List<ErFloorZone> zones;

  /// แตะโซน (id) · null = แตะที่ว่าง กล้องกลับมุมรวม
  final ValueChanged<String?>? onZone;

  @override
  State<ErFloor3D> createState() => _ErFloor3DState();
}

class _ErFloor3DState extends State<ErFloor3D> {
  WebViewController? _web;
  late final ErWebAlive _alive = ErWebAlive((js) => _web?.runJavaScript(js));
  HttpServer? _server;
  ErWebFrame? _frame;
  bool _ready = false;

  static const _files = {
    '/three.min.js': ['assets/web/three.min.js', 'application/javascript'],
  };

  @override
  void initState() {
    super.initState();
    _boot();
  }

  /// debug: hot reload แล้วโหลดหน้าใหม่ ให้ JS ที่แก้มีผลทันที
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
  void didUpdateWidget(covariant ErFloor3D old) {
    super.didUpdateWidget(old);
    if (jsonEncode(_data(old.zones)) != jsonEncode(_data(widget.zones))) {
      _push();
    }
  }

  @override
  void dispose() {
    _alive.stop();
    _server?.close(force: true);
    _frame?.dispose();
    super.dispose();
  }

  List<Map<String, Object>> _data(List<ErFloorZone> z) =>
      [for (final e in z) e.toJson()];

  void _js(String js) {
    if (!_ready) return;
    if (_frame != null) {
      _frame!.run(js);
    } else {
      _web?.runJavaScript(js);
    }
  }

  void _push() => _js('window.flSet(${jsonEncode(_data(widget.zones))})');

  void _onMessage(String raw) {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    switch (m['type']) {
      case 'ready':
        _ready = true;
        _push();
        break;
      case 'zone':
        widget.onZone?.call(m['id'] as String?);
        break;
      case 'error':
        debugPrint('ErFloor3D ผิดพลาด: ${m['message']}');
        break;
    }
  }

  Future<void> _boot() async {
    if (kIsWeb) {
      setState(() => _frame = ErWebFrame(
            html: _html,
            channel: 'ErFloor',
            routes: [
              for (final e in _files.entries)
                ('^${RegExp.escape(e.key)}\$', e.value[0], e.value[1]),
            ],
            onMessage: _onMessage,
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
      ..addJavaScriptChannel('ErFloor',
          onMessageReceived: (m) => _onMessage(m.message))
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    setState(() => _web = controller);
    _alive.start();
  }

  @override
  Widget build(BuildContext context) {
    if (_frame != null) return _frame!.view();
    if (_web == null) return const SizedBox.shrink();
    // ลาก/บีบในฉากต้องถึง WebView ก่อน gesture ของ Flutter รอบนอก
    return WebViewWidget(
      controller: _web!,
      gestureRecognizers: {
        const Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
      },
    );
  }
}

// getter (ไม่ใช่ const) ให้ hot reload เห็น JS ที่แก้
String get _html => r'''
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
<style>
  html, body { margin:0; height:100%; overflow:hidden; background:transparent;
    touch-action:none; -webkit-user-select:none; user-select:none; }
  canvas { display:block; }
</style>
<script src="three.min.js"></script>
</head>
<body>
<script>
function __erOk(){return !window.__erDbg||Date.now()-(window.__erAlive||0)<700;}
function post(o){ if(!__erOk()) return; if(window.ErFloor) window.ErFloor.postMessage(JSON.stringify(o)); }
window.onerror = function(m){ post({type:'error', message:String(m)}); };

const renderer = new THREE.WebGLRenderer({ antialias:true, alpha:true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
renderer.setClearColor(0x000000, 0);
// ไม่แปลง sRGB: r128 ถือสี hex เป็น linear แปลงซ้ำแล้วซีดทั้งฉาก
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;
document.body.appendChild(renderer.domElement);

const scene = new THREE.Scene();
const cam = new THREE.PerspectiveCamera(30, 1, 1, 400);

scene.add(new THREE.HemisphereLight(0xffffff, 0x9aa4b2, 0.62));
const sun = new THREE.DirectionalLight(0xffffff, 0.9);
sun.position.set(-18, 40, 22);
sun.castShadow = true;
sun.shadow.mapSize.set(1024, 1024);
const sc = sun.shadow.camera; sc.left=-30; sc.right=30; sc.top=24; sc.bottom=-24; sc.near=1; sc.far=100;
sun.shadow.bias = -0.0008;
scene.add(sun);

// ---------- ผัง (เมตร) จุดกลางอาคารอยู่ที่ (0,0) · x ขวา · z เข้าหากล้อง
const OX = -17, OZ = -10;           // มุมซ้ายบนของอาคาร
const WALL_H = 1.2, T = 0.3;
const white = new THREE.MeshStandardMaterial({ color:0xf5f6f8, roughness:0.85 });
const base  = new THREE.MeshStandardMaterial({ color:0xeceef2, roughness:1 });

function box(w, h, d, x, y, z, mat){
  const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), mat || white);
  m.position.set(x, y, z); m.castShadow = true; m.receiveShadow = true;
  scene.add(m); return m;
}
// พื้นลาน + ถนน
const ground = new THREE.Mesh(new THREE.PlaneGeometry(90, 60),
  new THREE.MeshStandardMaterial({ color:0xd3d9e0, roughness:1 }));
ground.rotation.x = -Math.PI/2; ground.position.y = -0.05; ground.receiveShadow = true; scene.add(ground);
box(90, 0.04, 6, 0, -0.03, 14.5, new THREE.MeshStandardMaterial({ color:0xc5cbd3, roughness:1 }));
// พื้นอาคาร
box(36, 0.12, 21, 1, 0.06 - 0.12, 0.5, base).position.y = 0;

// โซน: x0,z0,x1,z1 (พิกัดในผัง) · ประตูออกทางเดิน · จุดวางคน
const ZONES = {
  red:    { r:[0,0,15,8.2],  door:[6.5,8.6] },
  triage: { r:[15.3,0,31,8.2], door:[23,8.6] },
  green:  { r:[0,8.5,34,11.5], door:[17,10] },
  yellow: { r:[0,11.8,15,20],  door:[6.5,11.4] },
  after:  { r:[15.3,11.8,31,20], door:[23,11.4] },
};
const P = (x, z) => [OX + x, OZ + z];

// ผนัง (ส่วนเว้นประตู)
const WALLS = [
  [0,0,31,0], [0,0,0,20], [0,20,34,20], [31,0,31,8.2], [15.15,0,15.15,8.2],
  [15.15,11.8,15.15,20], [31,11.8,31,20],
  [0,8.35,5.2,8.35], [7.8,8.35,21.7,8.35], [24.3,8.35,31,8.35],
  [0,11.65,5.2,11.65], [7.8,11.65,21.7,11.65], [24.3,11.65,31,11.65],
];
for (const [x0,z0,x1,z1] of WALLS){
  const [a,b] = P(x0,z0), [c,d] = P(x1,z1);
  const w = Math.max(Math.abs(c-a), T), dd = Math.max(Math.abs(d-b), T);
  box(w, WALL_H, dd, (a+c)/2, WALL_H/2, (b+d)/2);
}
// กันสาดทางเข้ารถพยาบาล + เสา
box(4.2, 0.18, 11.6, OX+33, 2.7, OZ+14.1);
for (const z of [8.6, 19.6]) box(0.3, 2.7, 0.3, OX+34.8, 1.35, OZ+z);

// ---------- พื้นโซนเรืองแสง
const zoneMeshes = {}, glow = {}, zoneLights = {};
const glowMat = (c) => new THREE.ShaderMaterial({
  transparent:true, depthWrite:false, blending:THREE.AdditiveBlending,
  uniforms:{ c:{ value:new THREE.Color(c) }, k:{ value:0.55 } },
  vertexShader:'varying float vy; void main(){ vy = position.y + 0.5; gl_Position = projectionMatrix*modelViewMatrix*vec4(position,1.0); }',
  fragmentShader:'uniform vec3 c; uniform float k; varying float vy; void main(){ float a = pow(1.0 - clamp(vy,0.0,1.0), 2.2) * k; gl_FragColor = vec4(c*a, a); }',
});
for (const id in ZONES){
  const [x0,z0,x1,z1] = ZONES[id].r;
  const [a,b] = P(x0,z0), [c,d] = P(x1,z1);
  const w = c-a, dd = d-b;
  const fl = new THREE.Mesh(new THREE.PlaneGeometry(w, dd),
    new THREE.MeshStandardMaterial({ color:0xffffff, roughness:0.9, emissive:0x000000 }));
  fl.rotation.x = -Math.PI/2; fl.position.set(a+w/2, 0.075, b+dd/2);
  fl.receiveShadow = true; fl.userData.zone = id; scene.add(fl);
  zoneMeshes[id] = fl;
  // ไอแสงลอยขึ้นจากพื้น (ไล่จางขึ้นบน)
  const g = new THREE.Mesh(new THREE.BoxGeometry(w-0.4, 1, dd-0.4), glowMat(0xffffff));
  g.scale.y = id === 'green' ? 1.4 : 2.2; g.position.set(a+w/2, g.scale.y/2, b+dd/2);
  g.renderOrder = 2; scene.add(g); glow[id] = g;
  const l = new THREE.PointLight(0xffffff, 0.0, 14, 2);
  l.position.set(a+w/2, 2.2, b+dd/2); scene.add(l); zoneLights[id] = l;
}

// ---------- เฟอร์นิเจอร์ + ที่วางคน (slot: x, z, ท่า)
const SLOTS = { red:[], yellow:[], green:[], triage:[], after:[] };
function bed(x, z){
  const [a,b] = P(x,z);
  box(1.1, 0.5, 2.1, a, 0.25, b);
  box(0.9, 0.12, 0.45, a, 0.56, b-0.75, new THREE.MeshStandardMaterial({ color:0xffffff }));
  return [a, b, 'lie'];
}
function chair(x, z){
  const [a,b] = P(x,z);
  box(0.6, 0.45, 0.6, a, 0.22, b);
  box(0.6, 0.5, 0.12, a, 0.7, b-0.26);
  return [a, b, 'sit'];
}
for (let i=0;i<4;i++) SLOTS.red.push(bed(2.3 + i*3.4, 2.0));
for (let i=0;i<5;i++) SLOTS.yellow.push(bed(1.9 + i*2.8, 17.6));
box(5.5, 1.0, 1.0, OX+20, 0.5, OZ+1.4);                      // เคาน์เตอร์คัดกรอง
for (let i=0;i<7;i++) SLOTS.triage.push(chair(17.6 + i*1.8, 6.6));
for (let r=0;r<2;r++) for (let i=0;i<7;i++) SLOTS.after.push(chair(17.6 + i*1.8, 15.0 + r*2.3));
for (let i=0;i<8;i++) SLOTS.green.push(chair(9.5 + i*1.4, 11.0));
// รถพยาบาล 2 คัน
function ambulance(z){
  const g = new THREE.Group();
  const b = new THREE.Mesh(new THREE.BoxGeometry(2.0, 1.8, 4.4), white); b.position.y = 1.0; b.castShadow = true; g.add(b);
  const stripe = new THREE.Mesh(new THREE.BoxGeometry(2.02, 0.25, 4.42),
    new THREE.MeshStandardMaterial({ color:0xd93025 })); stripe.position.y = 1.1; g.add(stripe);
  const lamp = new THREE.Mesh(new THREE.BoxGeometry(1.2, 0.16, 0.3),
    new THREE.MeshStandardMaterial({ color:0xff3b30, emissive:0xff2a1f, emissiveIntensity:0.8 }));
  lamp.position.set(0, 1.98, -1.6); g.add(lamp);
  g.position.set(OX+37.5, 0, OZ+z); scene.add(g);
}
ambulance(11); ambulance(16.5);

// ---------- ผู้ป่วย (หุ่นเรียบ: ตัวทรงแคปซูล + หัว)
const people = new THREE.Group(); scene.add(people);
const bodyGeo = new THREE.CylinderGeometry(0.22, 0.24, 0.8, 16);
const capGeo = new THREE.SphereGeometry(0.23, 16, 10);
const headGeo = new THREE.SphereGeometry(0.2, 18, 12);
const headMat = new THREE.MeshStandardMaterial({ color:0xf1e4da, roughness:0.7 });
function person(col, pose, x, z){
  const g = new THREE.Group();
  const m = new THREE.MeshStandardMaterial({ color:col, roughness:0.55 });
  const body = new THREE.Mesh(bodyGeo, m); g.add(body);
  const c1 = new THREE.Mesh(capGeo, m); c1.position.y = -0.4; g.add(c1);
  const c2 = new THREE.Mesh(capGeo, m); c2.position.y = 0.4; g.add(c2);
  const head = new THREE.Mesh(headGeo, headMat); head.position.y = 0.82; g.add(head);
  g.traverse(o => { o.castShadow = true; });
  if (pose === 'lie'){ g.rotation.x = Math.PI/2; g.position.set(x, 0.82, z + 0.15); }
  else if (pose === 'sit'){ g.scale.setScalar(0.85); g.position.set(x, 0.95, z - 0.05); }
  else { g.position.set(x, 0.68, z); }
  people.add(g);
}

// ---------- ป้ายลอยเหนือโซน (canvas → sprite)
const labels = {};
function labelSprite(id, name, n, cap, color){
  const cv = document.createElement('canvas'); cv.width = 520; cv.height = 200;
  const g = cv.getContext('2d');
  const over = n > cap;
  g.clearRect(0,0,520,200);
  // เงา + พื้นการ์ด
  g.fillStyle = 'rgba(11,27,63,0.16)'; round(g, 14, 24, 492, 160, 40); g.fill();
  g.fillStyle = '#ffffff'; round(g, 10, 12, 500, 164, 40); g.fill();
  g.fillStyle = color; round(g, 10, 12, 18, 164, 9); g.fill();
  // ชื่อโซน
  g.fillStyle = '#3c4043'; g.font = '600 40px -apple-system, "Noto Sans Thai", "Google Sans", sans-serif';
  g.textBaseline = 'middle'; g.fillText(name, 54, 58);
  // จำนวนใหญ่ + ที่รองรับ
  g.fillStyle = '#1f1f1f'; g.font = '700 84px -apple-system, "Google Sans", sans-serif';
  const ns = String(n); g.fillText(ns, 54, 128);
  const nw = g.measureText(ns).width;
  g.fillStyle = '#5f6368'; g.font = '600 34px -apple-system, "Noto Sans Thai", sans-serif';
  g.fillText('ราย  จาก ' + cap + ' ที่', 54 + nw + 14, 138);
  // เกินที่รองรับ = ป้ายแดง
  if (over){
    g.fillStyle = '#d93025'; round(g, 356, 34, 140, 50, 25); g.fill();
    g.fillStyle = '#ffffff'; g.font = '700 30px -apple-system, "Noto Sans Thai", sans-serif';
    g.textAlign = 'center'; g.fillText('เกิน ' + (n-cap), 426, 60); g.textAlign = 'left';
  }
  const tex = new THREE.CanvasTexture(cv); tex.anisotropy = 4;
  let s = labels[id];
  if (!s){
    s = new THREE.Sprite(new THREE.SpriteMaterial({ map:tex, depthTest:false, transparent:true }));
    s.renderOrder = 10; s.userData.zone = id; scene.add(s); labels[id] = s;
  } else { s.material.map.dispose(); s.material.map = tex; }
  const [x0,z0,x1,z1] = ZONES[id].r; const [a,b] = P((x0+x1)/2, (z0+z1)/2);
  s.position.set(a, id === 'green' ? 3.0 : 4.6, b);
  s.scale.set(7.8, 3.0, 1);
}
function round(g, x, y, w, h, r){ g.beginPath(); g.moveTo(x+r,y); g.arcTo(x+w,y,x+w,y+h,r); g.arcTo(x+w,y+h,x,y+h,r); g.arcTo(x,y+h,x,y,r); g.arcTo(x,y,x+w,y,r); g.closePath(); }

// ---------- ข้อมูลจาก Flutter
let zonesData = [];
window.flSet = function(zs){
  zonesData = zs;
  while (people.children.length){ const o = people.children.pop(); o.traverse(m => { if (m.material && m.material !== headMat) m.material.dispose(); }); }
  for (const z of zs){
    const id = z.id; if (!ZONES[id]) continue;
    const col = new THREE.Color(z.color);
    const n = z.patients.length, slots = SLOTS[id];
    // พื้นเรือง: ยิ่งแน่น ยิ่งสว่าง
    const load = Math.min(n / Math.max(slots.length,1), 1.4);
    zoneMeshes[id].material.color.copy(col).lerp(new THREE.Color(0xffffff), 0.2);
    zoneMeshes[id].material.emissive.copy(col).multiplyScalar(0.08 + 0.14*load);
    glow[id].material.uniforms.c.value.copy(col);
    glow[id].material.uniforms.k.value = 0.25 + 0.35*load;
    zoneLights[id].color.copy(col); zoneLights[id].intensity = 0.35 + 0.5*load;
    // วางคน: เต็มที่แล้วที่เหลือยืนรอหน้าประตูโซน
    z.patients.forEach((c, i) => {
      if (i < slots.length){ const [x,zz,pose] = slots[i]; person(c, pose, x, zz); }
      else {
        const k = i - slots.length, [dx,dz] = ZONES[id].door, [a,b] = P(dx,dz);
        person(c, 'stand', a - 1.6 + (k%5)*0.8, b + (Math.floor(k/5))*0.8 * (id==='yellow'||id==='after' ? -1 : 1));
      }
    });
    labelSprite(id, z.label, n, slots.length, z.color);
  }
  draw();
};

// ---------- กล้อง: ลากหมุน · บีบ/ล้อซูม · แตะโซน = บินไปดู
const HOME = { tx:1.5, ty:0, tz:1.5, r:50, th:-0.32, ph:0.82 };
let view = Object.assign({}, HOME), goal = null;
function apply(){
  const sp = Math.sin(view.ph);
  cam.position.set(view.tx + view.r*sp*Math.sin(view.th), view.ty + view.r*Math.cos(view.ph), view.tz + view.r*sp*Math.cos(view.th));
  cam.lookAt(view.tx, view.ty, view.tz);
}
let pending = false;
function draw(){ if (pending) return; pending = true; requestAnimationFrame(frame); }
function frame(){
  pending = false;
  if (goal){
    let done = true;
    for (const k in goal){ const d = goal[k] - view[k]; if (Math.abs(d) > 0.002){ view[k] += d*0.16; done = false; } else view[k] = goal[k]; }
    if (done) goal = null; else draw();
  }
  apply();
  renderer.render(scene, cam);
}
function size(){
  const w = innerWidth, h = innerHeight;
  renderer.setSize(w, h); cam.aspect = w/h;
  // จอแคบ = ถอยกล้องให้เห็นทั้งผัง
  HOME.r = 50 * Math.max(1, 1.42 / cam.aspect);
  if (!goal && !focus) view.r = HOME.r;
  cam.updateProjectionMatrix(); draw();
}
addEventListener('resize', size);

const ptrs = new Map(); let downAt = null, moved = 0, pinch0 = 0, r0 = 0;
const el = renderer.domElement;
el.addEventListener('pointerdown', e => {
  el.setPointerCapture(e.pointerId); ptrs.set(e.pointerId, [e.clientX, e.clientY]);
  if (ptrs.size === 1){ downAt = [e.clientX, e.clientY]; moved = 0; }
  if (ptrs.size === 2){ const [p,q] = [...ptrs.values()]; pinch0 = Math.hypot(p[0]-q[0], p[1]-q[1]); r0 = view.r; }
  goal = null;
});
el.addEventListener('pointermove', e => {
  const prev = ptrs.get(e.pointerId); if (!prev) return;
  const cur = [e.clientX, e.clientY]; ptrs.set(e.pointerId, cur);
  if (ptrs.size === 2){
    const [p,q] = [...ptrs.values()]; const d = Math.hypot(p[0]-q[0], p[1]-q[1]);
    view.r = Math.min(90, Math.max(18, r0 * pinch0 / Math.max(d,1))); moved += 10; draw(); return;
  }
  const dx = cur[0]-prev[0], dy = cur[1]-prev[1]; moved += Math.abs(dx)+Math.abs(dy);
  view.th -= dx * 0.006;
  view.ph = Math.min(1.25, Math.max(0.35, view.ph - dy * 0.005));
  draw();
});
function up(e){
  ptrs.delete(e.pointerId);
  if (ptrs.size === 0 && downAt && moved < 8) tap(e.clientX, e.clientY);
  if (ptrs.size === 0) downAt = null;
}
el.addEventListener('pointerup', up); el.addEventListener('pointercancel', up);
el.addEventListener('wheel', e => { e.preventDefault(); view.r = Math.min(90, Math.max(18, view.r * (1 + e.deltaY*0.0012))); draw(); }, { passive:false });

const ray = new THREE.Raycaster(), ndc = new THREE.Vector2();
let focus = null;
function tap(x, y){
  ndc.set(x/innerWidth*2-1, -(y/innerHeight)*2+1); ray.setFromCamera(ndc, cam);
  const hits = ray.intersectObjects([...Object.values(labels), ...Object.values(zoneMeshes)]);
  const id = hits.length ? hits[0].object.userData.zone : null;
  if (!id || id === focus){
    focus = null; goal = Object.assign({}, HOME, { th:view.th });
    post({ type:'zone', id:null });
  } else {
    focus = id;
    const [x0,z0,x1,z1] = ZONES[id].r; const [a,b] = P((x0+x1)/2, (z0+z1)/2);
    goal = { tx:a, ty:0, tz:b + 1.5, r: id === 'green' ? 40 : 34, th:view.th, ph:0.78 };
    post({ type:'zone', id });
  }
  draw();
}

apply(); size();
post({ type:'ready' });
</script>
</body>
</html>
''';
