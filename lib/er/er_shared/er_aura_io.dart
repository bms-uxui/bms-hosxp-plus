/// Aura ของผู้ช่วย AI รอบปุ่มไมค์ (canvas ใน WebView โปร่งใส)
///
/// วงแสงนุ่ม ๆ หลายชั้นหมุนช้า ๆ สีเปลี่ยนตามสถานะ
/// ตอนพูดจะเต้นตามความดังจริงของเสียง TTS ที่เล่นในหน้าเว็บ
/// ผ่าน Web Audio AnalyserNode
///
/// ไฟล์เสียงส่งจาก Dart มาเป็นไบต์ แล้วเสิร์ฟผ่าน HttpServer ในเครื่อง
/// ที่ /tts/<id>.mp3 จึงเป็น same-origin เล่นได้โดยไม่ติด CORS
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'er_aura_types.dart';

class ErAiAura extends StatefulWidget {
  const ErAiAura({super.key, required this.controller, this.hidden = false});

  final ErAuraController controller;

  /// ซ่อนอยู่ (วอร์มไว้เพื่อเล่นเสียง): หยุดวาดแสง ไม่ให้ WebView ส่งเฟรมมาเรื่อย ๆ
  /// ตัวนี้ทำให้ Flutter ต้อง composite ใหม่ทุกเฟรมแม้หน้าจอนิ่ง (raster ~11 ms ที่ 120 Hz)
  final bool hidden;

  @override
  State<ErAiAura> createState() => _ErAiAuraState();
}

class _ErAiAuraState extends State<ErAiAura> {
  WebViewController? _web;
  HttpServer? _server;
  bool _ready = false;
  final Map<String, Uint8List> _clips = {};
  int _clipSeq = 0;

  @override
  void initState() {
    super.initState();
    _bind(widget.controller);
    _boot();
  }

  @override
  void didUpdateWidget(covariant ErAiAura old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      _unbind(old.controller);
      _bind(widget.controller);
    }
    if (old.hidden != widget.hidden) _pushHidden();
  }

  @override
  void dispose() {
    _unbind(widget.controller);
    _server?.close(force: true);
    super.dispose();
  }

  void _pushHidden() {
    _web?.runJavaScript('window.robotHidden && robotHidden(${widget.hidden})');
  }

  void _bind(ErAuraController c) {
    c.speakImpl = _speak;
    c.flushImpl = _flush;
    c.moodImpl = _setMood;
    c.stopImpl = _stop;
  }

  void _unbind(ErAuraController c) {
    if (c.speakImpl == _speak) c.speakImpl = null;
    if (c.flushImpl == _flush) c.flushImpl = null;
    if (c.moodImpl == _setMood) c.moodImpl = null;
    if (c.stopImpl == _stop) c.stopImpl = null;
  }

  Future<void> _boot() async {
    final server = await _startServer();
    if (!mounted) return;
    _server = server;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('ErAura', onMessageReceived: _onMessage)
      ..loadRequest(Uri.parse('http://127.0.0.1:${server.port}/index.html'));
    // ให้เล่นเสียงได้โดยไม่ต้องรอผู้ใช้แตะในหน้าเว็บ (Dart เป็นคนสั่ง)
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      await platform.setMediaPlaybackRequiresUserGesture(false);
    }
    setState(() => _web = controller);
  }

  void _onMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        _ready = true;
        debugPrint('ErAiAura พร้อม');
        _setMood(widget.controller.mood);
        _pushHidden();
      case 'done':
        _clips.remove(data['id']);
      case 'end':
        debugPrint('ErAiAura พูดจบ ${data['id']}');
        widget.controller.mood = ErAuraMood.idle;
        widget.controller.onSpeechEnd?.call();
      case 'playing':
        debugPrint('ErAiAura กำลังเล่น ${data['id']} ctx=${data['ctx']}');
      case 'error':
        debugPrint('ErAiAura เล่นเสียงไม่ได้: ${data['msg']}');
        _clips.remove(data['id']);
    }
  }

  Future<void> _speak(Uint8List mp3) async {
    final id = 'c${_clipSeq++}';
    _clips[id] = mp3;
    debugPrint('ErAiAura เล่นเสียง $id ${mp3.length} ไบต์ ready=$_ready');
    // หน้าเว็บยังไม่พร้อม รอจนพร้อม (สูงสุด 4 วิ) ไม่งั้นคลิปจะหายเงียบ ๆ
    for (var i = 0; i < 80 && !_ready; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    await _web
        ?.runJavaScript('window.robotSpeak && robotSpeak(${jsonEncode(id)})');
  }

  /// บอกหุ่นว่าส่งประโยคครบแล้ว ให้ส่ง end เมื่อเล่นคิวหมด
  void _flush() {
    _web?.runJavaScript('window.robotFlush && robotFlush()');
  }

  void _setMood(ErAuraMood m) {
    _web?.runJavaScript('window.robotMood && robotMood(${jsonEncode(m.name)})');
  }

  void _stop() {
    _web?.runJavaScript('window.robotStop && robotStop()');
  }

  Future<HttpServer> _startServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      final path = req.uri.path;
      if (path == '/' || path == '/index.html') {
        req.response.headers.contentType = ContentType.html;
        req.response.write(_html);
        await req.response.close();
        return;
      }
      if (path.startsWith('/tts/')) {
        final id = path.substring(5).replaceAll('.mp3', '');
        final clip = _clips[id];
        if (clip != null) {
          req.response.headers.set('content-type', 'audio/mpeg');
          req.response.headers.set('content-length', clip.length.toString());
          req.response.add(clip);
          await req.response.close();
          return;
        }
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
  canvas { display:block; width:100%; height:100%; }
</style>
</head>
<body>
<canvas id="c"></canvas>
<script>
const send = (o) => { try { ErAura.postMessage(JSON.stringify(o)); } catch (e) {} };

const cv = document.getElementById('c');
const g = cv.getContext('2d');
let W = 0, H = 0, DPR = 1;
function resize() {
  DPR = Math.min(window.devicePixelRatio || 1, 2);
  W = window.innerWidth; H = window.innerHeight;
  cv.width = W * DPR; cv.height = H * DPR;
  g.setTransform(DPR, 0, 0, DPR, 0, 0);
}
window.addEventListener('resize', resize);
resize();

// สีตามสถานะ (RGB)
const MOOD = {
  idle:      [[0, 27, 124], [92, 225, 255], [120, 150, 255]],
  listening: [[217, 48, 37], [255, 138, 128], [255, 90, 60]],
  thinking:  [[249, 171, 0], [255, 214, 102], [255, 150, 40]],
  talking:   [[52, 168, 83], [92, 225, 255], [110, 230, 160]],
};
let mood = 'idle';
let cur = MOOD.idle.map(c => c.slice());

// ---- เสียงพูด: <audio> same-origin + AnalyserNode
let ctx = null, analyser = null, buf = null;
let audio = null, clipId = null;
let level = 0, levelSmooth = 0, playing = false, silentSince = 0;

function ensureAudio() {
  if (ctx) return;
  const AC = window.AudioContext || window.webkitAudioContext;
  ctx = new AC();
  analyser = ctx.createAnalyser();
  analyser.fftSize = 512;
  analyser.smoothingTimeConstant = 0.4;
  buf = new Uint8Array(analyser.fftSize);
  analyser.connect(ctx.destination);
}

// คิวคลิป: Dart ส่งมาทีละประโยค เล่นต่อกันไม่มีช่องว่าง ส่ง end เมื่อคิวหมดและ flush แล้ว
const queue = [];
let flushed = false;
window.robotSpeak = function(id) {
  ensureAudio();
  queue.push(id);
  flushed = false;
  if (!playing && !audio) next();
};
window.robotFlush = function() {
  flushed = true;
  if (!playing && !audio && queue.length === 0) send({ type: 'end', id: 'flush' });
};
function next() {
  if (queue.length === 0) {
    audio = null; clipId = null; playing = false; mood = 'idle';
    if (flushed) send({ type: 'end', id: 'queue' });
    return;
  }
  const id = queue.shift();
  clipId = id;
  audio = new Audio('/tts/' + id + '.mp3');
  audio.preload = 'auto';
  audio.playbackRate = 1.12;
  try { ctx.createMediaElementSource(audio).connect(analyser); } catch (e) {}
  audio.addEventListener('ended', () => { if (clipId === id) { playing = false; send({ type: 'done', id }); next(); } });
  audio.addEventListener('error', () => { send({ type: 'error', id, msg: 'audio error' }); if (clipId === id) { playing = false; next(); } });
  const go = () => audio.play().then(() => { playing = true; silentSince = 0; mood = 'talking'; send({ type: 'playing', id, ctx: ctx.state }); })
    .catch((e) => { send({ type: 'error', id, msg: String(e) }); if (clipId === id) { playing = false; next(); } });
  if (ctx.state === 'suspended') ctx.resume().then(go, go); else go();
}
window.robotStop = function() {
  queue.length = 0; flushed = false;
  if (audio) { try { audio.pause(); } catch (e) {} }
  playing = false; clipId = null; audio = null;
  if (mood === 'talking') mood = 'idle';
};
window.robotMood = function(m) { mood = m; };
let hidden = false;
window.robotHidden = function(h) { hidden = !!h; if (hidden) g.clearRect(0, 0, W, H); };

function measure(t) {
  if (!playing || !analyser) { level = 0; return; }
  analyser.getByteTimeDomainData(buf);
  let sum = 0;
  for (let i = 0; i < buf.length; i++) { const v = (buf[i] - 128) / 128; sum += v * v; }
  const rms = Math.sqrt(sum / buf.length);
  if (rms < 0.004) {
    if (!silentSince) silentSince = t;
    if (t - silentSince > 0.3 && audio && !audio.paused) {
      level = 0.35 + 0.35 * Math.abs(Math.sin(t * 9.1) * Math.sin(t * 3.7 + 1.2));
      return;
    }
    level = 0;
  } else { silentSince = 0; level = Math.min(1, rms * 4.2); }
}

// ---- วาด aura
const rgba = (c, a) => `rgba(${c[0]|0},${c[1]|0},${c[2]|0},${a})`;
function blob(x, y, r, c, a) {
  const gr = g.createRadialGradient(x, y, 0, x, y, r);
  gr.addColorStop(0, rgba(c, a));
  gr.addColorStop(0.55, rgba(c, a * 0.45));
  gr.addColorStop(1, rgba(c, 0));
  g.fillStyle = gr;
  g.beginPath(); g.arc(x, y, r, 0, Math.PI * 2); g.fill();
}

let t0 = performance.now();
function frame(now) {
  requestAnimationFrame(frame);
  if (hidden) return; // ซ่อนอยู่: ไม่วาด (เสียงยังเล่นได้ตามปกติ)
  const t = (now - t0) / 1000;
  measure(t);
  levelSmooth += (level - levelSmooth) * (level > levelSmooth ? 0.5 : 0.2);

  // ไล่สีไปหาสีของสถานะ
  const want = MOOD[mood] || MOOD.idle;
  for (let i = 0; i < 3; i++) for (let k = 0; k < 3; k++) cur[i][k] += (want[i][k] - cur[i][k]) * 0.08;

  g.clearRect(0, 0, W, H);
  const cx = W / 2, cy = H / 2;
  const R = Math.min(W, H) / 2;           // รัศมีสูงสุดที่วาดได้
  const base = R * 0.42;                  // ประมาณรัศมีปุ่มไมค์
  const energy = mood === 'listening' ? 0.55 + 0.45 * Math.abs(Math.sin(t * 2.6))
    : mood === 'thinking' ? 0.5 + 0.5 * Math.abs(Math.sin(t * 5))
    : mood === 'talking' ? 0.35 + 0.65 * levelSmooth
    : 0.35 + 0.15 * Math.sin(t * 1.3);
  const speed = mood === 'thinking' ? 2.4 : (mood === 'talking' ? 1.4 : 0.6);

  g.globalCompositeOperation = 'lighter';
  // แสงพื้นรอบปุ่ม
  blob(cx, cy, base * (1.55 + 0.5 * energy), cur[0], 0.28 + 0.25 * energy);
  // ก้อนแสง 3 ก้อนโคจรรอบปุ่ม
  for (let i = 0; i < 3; i++) {
    const a = t * speed * (i % 2 ? -1 : 1) + i * Math.PI * 2 / 3;
    const d = base * (0.75 + 0.35 * energy) * (0.8 + 0.2 * Math.sin(t * 1.7 + i));
    const x = cx + Math.cos(a) * d, y = cy + Math.sin(a) * d;
    blob(x, y, base * (0.95 + 0.45 * energy), cur[(i + 1) % 3], 0.30 + 0.30 * energy);
  }
  // คลื่นวงแหวนตอนพูด/ฟัง
  if (mood === 'talking' || mood === 'listening') {
    for (let k = 0; k < 3; k++) {
      const ph = ((t * (mood === 'talking' ? 0.9 : 0.5) + k / 3) % 1);
      const r = base * (1.05 + ph * 1.2);
      const al = (1 - ph) * (mood === 'talking' ? 0.22 + 0.4 * levelSmooth : 0.28);
      g.strokeStyle = rgba(cur[1], al);
      g.lineWidth = 2 + 4 * (1 - ph);
      g.beginPath(); g.arc(cx, cy, r, 0, Math.PI * 2); g.stroke();
    }
  }
  g.globalCompositeOperation = 'source-over';
}
requestAnimationFrame(frame);
send({ type: 'ready' });
</script>
</body>
</html>
''';
