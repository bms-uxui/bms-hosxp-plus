// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

String _shortErr(Object e) {
  final t = e.toString();
  return t.length > 60 ? '${t.substring(0, 60)}…' : t;
}

/// aura ตอนยังไม่เปิดโหมดพูด: วางตำแหน่งเดียวกับในแถบ ใช้ GlobalKey เดิม
/// พอเปิดโหมดพูด widget ย้ายไปอยู่ในแถบโดยไม่สร้าง WebView ใหม่
/// ขนาดวงล้อ (สัมพันธ์กับความกว้างจอ) ใช้ร่วมกันระหว่างแถบพูดกับ aura ที่เตรียมไว้
const double _orbitK = 1.12;

const double _micK = 74.0;

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesSpeechSpeechState on State<ErFlowHomeWidget> {
  /// สถานะเสียง→ข้อความแบบ real time
  /// 0 ว่าง · 1 กำลังฟัง · 2 ถอดเสียง · 3 ตีความ · 4 เสร็จ · -1 ไม่สำเร็จ
  int _stt = 0;
  String _sttHeard = '';
  List<String> _sttDone = const [];
  String _sttErr = '';
  Timer? _sttClear;

  bool _recording = false;
  int _recSec = 0;
  int _tick = 0;
  Timer? _recTimer;
  List<double> _wave = List.filled(28, 0.15);

  /// เฟรมของไมค์ (คลื่น/เวลา) แยกจาก setState ของทั้งหน้า
  /// ตอนกดค้างพูด อัปเดตทุก 120 ms เฉพาะคลื่นกับป้ายเวลา ไม่ rebuild ทั้งหน้า
  final ValueNotifier<int> _micFrame = ValueNotifier(0);

  /// ระดับเสียงพื้นหลังของห้อง (dBFS) ใช้แยกเสียงพูดออกจากเสียงรอบข้าง
  double _dbFloor = -45.0;

  // ---- ผู้ช่วย AI ในโหมดพูด: หุ่นยนต์ + ไมค์จริง + LLM/ASR/TTS ของ BMS Cloud
  final ErAuraController _robot = ErAuraController();
  final GlobalKey _auraKey = GlobalKey();
  final AudioRecorder _rec = AudioRecorder();

  /// ตรวจจับเสียงพูดตอนอัด: ได้ยินเสียงพูดแล้วหรือยัง
  bool _heard = false;

  /// กันเริ่ม/หยุดซ้อนกัน (ปุ่มไมค์ + เปิดฟังเองหลังผู้ช่วยพูด + ตรวจจับเงียบ)
  bool _recBusy = false;

  /// ผู้ใช้สั่งเปิดไมค์อยู่ (แตะเปิดแล้ว ยังไม่แตะปิด)
  bool _holding = false;

  /// ตีความแบบ real time: ตัดประโยคตอนหยุดพูด ส่งตีความทันทีขณะไมค์ยังเปิด
  /// ช่วงพูดสะสม / ช่วงเงียบหลังพูด (ms) ของประโยคปัจจุบัน
  int _segSpeechMs = 0;
  int _segSilMs = 0;

  /// คลิปที่รอถอดเสียง/ตีความ (ทำทีละคลิปตามลำดับ)
  final List<String> _clipQ = [];
  bool _clipQBusy = false;

  /// live caption: ไฟล์ของประโยคที่กำลังพูด · ข้อความชั่วคราว · ประโยคที่จบแล้ว
  String? _curClip;
  String _capLive = '';
  final List<String> _capLines = [];
  bool _capBusy = false;
  Timer? _capTimer;
}

extension _FeaturesSpeechSpeechPart on _ErFlowHomeWidgetState {
  /// หยุดอัด: send = ส่งไปถอดเสียง · false = ทิ้งคลิป (เปลี่ยนขั้น/ปิดโหมดพูด)
  /// ปุ่มเปลี่ยนสถานะทันที ไม่รอเครื่องอัดปิดเสร็จ
  Future<void> _stopRecord({bool send = true}) async {
    if (!_recording) return;
    _recTimer?.cancel();
    _capTimer?.cancel();
    if (mounted) setState(() => _recording = false);
    String? path;
    try {
      path = await _rec.stop();
    } catch (_) {}
    if (!mounted) return;
    if (send && path != null) {
      _enqueueClip(path);
    } else {
      _robot.setMood(ErAuraMood.idle);
    }
  }

  /// ตัดประโยคที่พูดจบแล้วส่งตีความ โดยไมค์ยังฟังต่อ (หยุดเครื่องอัดแล้วเริ่มไฟล์ใหม่ทันที
  /// ช่วงที่ตัดคือช่วงเงียบ จึงไม่เสียคำพูด)
  Future<void> _rotateClip() async {
    if (_recBusy || !_recording) return;
    _recBusy = true;
    String? done;
    try {
      done = await _rec.stop();
      if (!mounted || !_recording) return;
      final dir = await getTemporaryDirectory();
      final next =
          '${dir.path}/er_clip_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _rec.start(
        const RecordConfig(
            encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
        path: next,
      );
      _curClip = next;
      _heard = false;
      _segSpeechMs = 0;
      _segSilMs = 0;
    } catch (e) {
      debugPrint('ErAi ตัดประโยคไม่สำเร็จ: $e');
    } finally {
      _recBusy = false;
    }
    if (done != null) _enqueueClip(done);
  }

  /// live caption: ถอดเสียงประโยคที่กำลังพูดเป็นระยะ (ข้อความชั่วคราว)
  /// อ่านไฟล์ที่ยังอัดอยู่ แล้วแก้ขนาดในหัว WAV ให้ตรงกับข้อมูลที่มีตอนนี้
  Future<void> _captionTick() async {
    final path = _curClip;
    if (!_recording || _capBusy || path == null || _segSpeechMs < 360) return;
    _capBusy = true;
    try {
      final f = File(path);
      if (!await f.exists()) return;
      final raw = await f.readAsBytes();
      if (raw.length <= 44 + 3200) return;
      // ระหว่างอัดหัว WAV อาจยังไม่สมบูรณ์: ตัดส่วนหัวเดิม (ถ้ามี) แล้วสร้างหัวใหม่
      // จากข้อมูลเสียงดิบ PCM 16-bit mono 16 kHz ตามที่ตั้งเครื่องอัดไว้
      final hasRiff = raw[0] == 0x52 && raw[1] == 0x49 && raw[2] == 0x46;
      final pcm = hasRiff ? raw.sublist(44) : raw;
      final n = pcm.length - pcm.length % 2;
      final b = Uint8List(44 + n);
      final bd = ByteData.sublistView(b);
      void tag(int o, String t) {
        for (var i = 0; i < 4; i++) {
          b[o + i] = t.codeUnitAt(i);
        }
      }

      tag(0, 'RIFF');
      bd.setUint32(4, 36 + n, Endian.little);
      tag(8, 'WAVE');
      tag(12, 'fmt ');
      bd.setUint32(16, 16, Endian.little);
      bd.setUint16(20, 1, Endian.little);
      bd.setUint16(22, 1, Endian.little);
      bd.setUint32(24, 16000, Endian.little);
      bd.setUint32(28, 32000, Endian.little);
      bd.setUint16(32, 2, Endian.little);
      bd.setUint16(34, 16, Endian.little);
      tag(36, 'data');
      bd.setUint32(40, n, Endian.little);
      b.setRange(44, 44 + n, pcm);
      final text = await ErAi.transcribe(b);
      // ประโยคถูกตัดส่งไปแล้วระหว่างรอ = ทิ้งผลชั่วคราวนี้
      if (!mounted || !_recording || _curClip != path) return;
      if (!RegExp(r'[ก-๙A-Za-z0-9]').hasMatch(text)) return;
      setState(() => _capLive = text);
    } catch (e) {
      debugPrint('ErAi caption: $e');
    } finally {
      _capBusy = false;
    }
  }

  void _enqueueClip(String path) {
    _clipQ.add(path);
    _drainClips();
  }

  /// ถอดเสียง + ตีความทีละคลิปตามลำดับที่พูด
  Future<void> _drainClips() async {
    if (_clipQBusy) return;
    _clipQBusy = true;
    try {
      while (_clipQ.isNotEmpty && mounted) {
        // ปิดโหมดพูดแล้ว: ทิ้งประโยคที่ค้างคิว
        if (!_speechOpen) {
          _clipQ.clear();
          break;
        }
        await _processClip(_clipQ.removeAt(0));
      }
    } finally {
      _clipQBusy = false;
    }
  }

  /// เปลี่ยนขั้นของแถบสถานะ · เสร็จ/ผิดพลาด แล้วจางหายเองใน 3 วินาที
  void _sttSet(int stage, {String err = '', List<String>? done}) {
    _sttClear?.cancel();
    setState(() {
      _stt = stage;
      if (stage == 1) {
        _sttHeard = '';
        _sttDone = const [];
      }
      if (done != null) _sttDone = done;
      _sttErr = err;
    });
    if (stage == 4 || stage == -1) {
      _sttClear = Timer(const Duration(seconds: 3), () {
        if (mounted && _stt == stage) setState(() => _stt = 0);
      });
    }
  }

  void _holdDown() {
    if (_agentBusy) return;
    HapticFeedback.mediumImpact();
    _robot.stop();
    _holding = true;
    _startRecord();
  }

  /// ปุ่มไมค์แบบสลับ: แตะเปิด · แตะอีกครั้งปิดและส่งให้ผู้ช่วยตีความ
  /// ไม่ได้ยินเสียงพูดเลยระหว่างเปิด = ยกเลิก ไม่ส่ง
  void _micToggle() {
    if (_recording || _holding) {
      HapticFeedback.lightImpact();
      _holding = false;
      if (!_recording) return; // ไมค์ยังเปิดไม่ทัน _startRecord ยกเลิกให้เอง
      if (!_heard) {
        _stopRecord(send: false);
        // ประโยคก่อนหน้าส่งตีความไปแล้ว = ปิดไมค์เฉย ๆ · ไม่เคยพูดเลย = แจ้ง
        if (_stt == 1) {
          setState(() => _agentStatus = 'ไม่ได้ยินเสียงพูด ลองใหม่อีกครั้ง');
          _sttSet(-1, err: 'ไม่ได้ยินเสียงพูด');
        }
      } else {
        _stopRecord();
      }
      return;
    }
    _holdDown();
  }

  /// เริ่มฟังจากไมค์จริง ขณะกดปุ่มค้าง (ปล่อยนิ้ว = ส่ง)
  Future<void> _startRecord() async {
    if (_recBusy || _recording || _agentBusy || !_speechOpen) return;
    _recBusy = true;
    try {
      if (!await _rec.hasPermission()) {
        if (!mounted) return;
        setState(() => _agentStatus = 'ไม่ได้รับสิทธิ์ใช้ไมโครโฟน');
        return;
      }
      // เครื่องอัดค้างจากรอบก่อน (เช่น เปลี่ยนขั้นกลางคัน) ปิดก่อนเริ่มใหม่
      if (await _rec.isRecording()) await _rec.stop();
      _robot.stop();
      _robot.setMood(ErAuraMood.listening);
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/er_clip_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );
      _curClip = path;
      if (!mounted) return;
      // ปล่อยนิ้วก่อนไมค์พร้อม = ยกเลิก
      if (!_holding) {
        await _rec.stop();
        return;
      }
      setState(() {
        _recording = true;
        _recSec = 0;
        _tick = 0;
        _heard = false;
        _dbFloor = -45.0;
        _agentStatus = '';
        _segSpeechMs = 0;
        _segSilMs = 0;
        _capLive = '';
        _capLines.clear();
      });
      _sttSet(1);
      _capTimer?.cancel();
      _capTimer = Timer.periodic(
          const Duration(milliseconds: 1200), (_) => _captionTick());
    } finally {
      _recBusy = false;
    }
    _recTimer?.cancel();
    _recTimer = Timer.periodic(const Duration(milliseconds: 120), (t) async {
      if (!mounted || !_recording) return;
      // ความดังจริงจากไมค์ (dBFS) แปลงเป็น 0..1 ให้คลื่นบนการ์ด
      double amp = 0.15;
      double db = -60.0;
      try {
        final a = await _rec.getAmplitude();
        // ช่วงเงียบสนิท/เริ่มอัด ไมค์คืน -∞ → พื้นหลังกลายเป็น NaN แล้วจับเสียงพูดไม่ได้อีกเลย
        db = a.current.isFinite ? math.max(a.current, -90.0) : _dbFloor;
        amp = ((db + 50.0) / 50.0).clamp(0.08, 1.0);
      } catch (_) {}
      if (!mounted || !_recording) return;
      // ตรวจจับพูด/เงียบเทียบกับเสียงพื้นหลังของห้อง (ห้อง ER ไม่เคยเงียบจริง)
      // พื้นหลัง = ค่าต่ำที่ค่อย ๆ ขยับขึ้น · พูด = ดังกว่าพื้นหลัง 12 dB
      // ได้ยินเสียงพูดแล้วค่อยส่งตอนแตะปิด · เปิดค้างนานสุด 60 วิ
      _dbFloor = db < _dbFloor ? db : _dbFloor + (db - _dbFloor) * 0.01;
      if (db > _dbFloor + 12.0) {
        _heard = true;
        _segSpeechMs += 120;
        _segSilMs = 0;
      } else if (_segSpeechMs > 0) {
        _segSilMs += 120;
      }
      // พูดจบประโยค (เงียบ ~0.8 วิ หลังพูด ≥ 0.5 วิ) หรือพูดยาวเกิน 20 วิ → ตีความเลย
      if (_heard &&
          ((_segSpeechMs >= 480 && _segSilMs >= 840) ||
              _segSpeechMs >= 20000)) {
        _rotateClip();
      }
      // เปิดค้างนานสุด 5 นาที
      if (_recSec >= 300) {
        _holding = false;
        _heard ? _stopRecord() : _stopRecord(send: false);
        return;
      }
      _tick += 1;
      if (_tick % 8 == 0) _recSec += 1;
      _wave = [..._wave.skip(1), amp];
      _micFrame.value++;
    });
  }

  /// ถอดเสียงคลิปแล้วส่งข้อความให้ผู้ช่วยตีความลงฟอร์ม
  Future<void> _processClip(String path) async {
    final gen = ++_agentGen;
    setState(() {
      _agentBusy = true;
      _agentStatus = 'กำลังถอดเสียง…';
      _agentChoices = null;
    });
    _sttSet(2);
    _robot.setMood(ErAuraMood.thinking);
    try {
      final bytes = await File(path).readAsBytes();
      final t0 = DateTime.now();
      final text = await ErAi.transcribe(bytes);
      debugPrint(
          'ErAi ถอดเสียง ${DateTime.now().difference(t0).inMilliseconds} ms '
          '(${bytes.length} ไบต์): "$text"');
      if (!mounted || gen != _agentGen) return;
      // ถอดเสียงได้แค่เสียงรบกวน/ภาษาอื่น (เช่น "嗯。") ถือว่าไม่ได้ยิน ไม่เก็บเป็นประโยค
      if (!RegExp(r'[ก-๙A-Za-z0-9]').hasMatch(text)) {
        setState(() {
          _agentBusy = false;
          _agentStatus = 'ไม่ได้ยินเสียงพูด ลองพูดอีกครั้ง';
        });
        _sttSet(-1, err: 'ไม่ได้ยินเสียงพูด');
        _robot.setMood(ErAuraMood.idle);
        return;
      }
      if (text.isEmpty) {
        setState(() {
          _agentBusy = false;
          _agentStatus = 'ไม่ได้ยินเสียง ลองพูดอีกครั้ง';
        });
        _robot.setMood(ErAuraMood.idle);
        return;
      }
      setState(() {
        final old = _transcripts[_speechStep];
        _transcripts[_speechStep] = old.isEmpty ? text : '$old $text';
        _utter[_speechStep].add(text);
        _logTurn(true, text);
        _sttHeard = text;
        // caption: ประโยคที่ถอดเสียงเต็มแล้วขึ้นเป็นบรรทัดถาวร
        _capLines.add(text);
        if (_capLines.length > 6) _capLines.removeAt(0);
        _capLive = '';
      });
      await _agentTurn(text, gen);
      // ตีความจบแต่ไม่มีช่องไหนเปลี่ยน (เช่น เป็นคำถาม) ก็ถือว่าเสร็จ
      if (mounted && gen == _agentGen && _stt != 0) {
        _sttSet(_stt == 3 ? 4 : _stt,
            done: _stt == 3 ? const [] : _sttDone, err: _sttErr);
      }
    } catch (e) {
      if (!mounted || gen != _agentGen) return;
      setState(() {
        _agentBusy = false;
        _agentStatus = 'ถอดเสียงไม่สำเร็จ: ${_shortErr(e)}';
      });
      _sttSet(-1, err: 'ถอดเสียงไม่สำเร็จ');
      _robot.setMood(ErAuraMood.idle);
    } finally {
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  Widget _auraWarm() => Positioned.fill(
        child: LayoutBuilder(
          builder: (context, c) {
            final k = c.maxWidth / 1366.0 * 0.5;
            final rArc = 332.0 * k * _orbitK;
            final rMic = _micK * k;
            final band = 88.0 * k;
            final h = rArc + band / 2 + 44.0;
            final cx = c.maxWidth - 64.0;
            final cy = c.maxHeight - 22.0;
            final micX = cx - rArc * 0.36;
            final micY = cy - rArc * 0.36;
            return Stack(
              children: [
                Positioned(
                  left: micX - rMic * 2.6,
                  top: micY - rMic * 2.6,
                  width: rMic * 5.2,
                  height: (rMic * 5.2).clamp(0.0, h),
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.0,
                      child: ErAiAura(
                          key: _auraKey, controller: _robot, hidden: true),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

  /// แถบสถานะเสียง→ข้อความแบบ real time (เหนือปุ่มไมค์)
  /// ฟัง → ถอดเสียง → ตีความ · ขั้นที่ทำอยู่กะพริบ · เห็นคำที่ได้ยินระหว่างตีความ
  Widget _sttStrip() {
    final st = _stt;
    final show = st != 0 || _recording;
    // ฟัง (ไมค์) กับ ถอดเสียง/ตีความ (ประโยคก่อนหน้า) ทำพร้อมกันได้
    Widget stepDot(int i, String label) {
      final active = switch (i) {
        1 => _recording,
        2 => st == 2,
        _ => st == 3,
      };
      final done = switch (i) {
        1 => !_recording && st >= 2,
        2 => st == 3 || st == 4,
        _ => st == 4,
      };
      final col = done ? _green : (active ? _blue : _g5);
      return Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 14.0,
          height: 14.0,
          child: active && st != -1
              ? (i == 1
                  ? _PulseDot(color: col)
                  : const CircularProgressIndicator(
                      strokeWidth: 2.0, color: _blue))
              : Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 14.0,
                  color: col),
        ),
        const SizedBox(width: 4.0),
        Text(label,
            style: _t(10.5,
                color: active || done ? _inkTitle : _ink3,
                weight: active ? FontWeight.w700 : FontWeight.w500)),
      ]);
    }

    Widget sep() => Container(
        width: 14.0,
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        color: _line);

    final detail = switch (st) {
      -1 => Text(
          _sttErr.isEmpty
              ? 'ไม่สำเร็จ ลองพูดอีกครั้ง'
              : '$_sttErr · ลองพูดอีกครั้ง',
          style: _t(11.0, color: _red, weight: FontWeight.w600)),
      4 => Text(
          _sttDone.isEmpty
              ? 'ตีความแล้ว · ไม่มีช่องที่เปลี่ยน'
              : 'ลงแล้ว: ${_sttDone.join(', ')}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _t(11.0, color: _green, weight: FontWeight.w700)),
      _ when _sttHeard.isNotEmpty && (st == 2 || st == 3) => Text(
          'ได้ยินว่า “$_sttHeard”',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _t(11.0, color: _ink2, height: 1.35)),
      _ when _recording => Text(
          'พูดได้เลย หยุดพูดแล้วผู้ช่วยตีความให้ทันที · แตะไมค์เมื่อพูดเสร็จทั้งหมด',
          style: _t(11.0, color: _ink3)),
      _ => const SizedBox.shrink(),
    };
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: !show
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.fromLTRB(10.0, 7.0, 10.0, 7.0),
              decoration: BoxDecoration(
                color: st == -1 ? _red.withValues(alpha: 0.06) : _panelSoft,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                    color: st == -1 ? _red.withValues(alpha: 0.35) : _line),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      stepDot(1, 'ฟัง'),
                      sep(),
                      stepDot(2, 'ถอดเสียง'),
                      sep(),
                      stepDot(3, 'ตีความ'),
                      if (_clipQ.isNotEmpty) ...[
                        const Spacer(),
                        Text('รออีก ${_clipQ.length} ประโยค',
                            style: _t(9.5, color: _ink3)),
                      ],
                    ]),
                    const SizedBox(height: 4.0),
                    detail,
                    // live caption: บรรทัดที่ถอดเสียงแล้ว (เทา) + ประโยคที่กำลังพูด (เข้ม)
                    if (_capLines.isNotEmpty || _capLive.isNotEmpty) ...[
                      const Divider(height: 12.0, color: _line),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 84.0),
                        child: SingleChildScrollView(
                          reverse: true,
                          child: Text.rich(
                            TextSpan(children: [
                              for (final l in _capLines)
                                TextSpan(
                                    text: '$l ',
                                    style:
                                        _t(12.0, color: _ink2, height: 1.45)),
                              if (_capLive.isNotEmpty)
                                TextSpan(
                                    text: _capLive,
                                    style: _t(12.0,
                                        color: _inkTitle,
                                        weight: FontWeight.w600,
                                        height: 1.45)),
                              if (_recording)
                                TextSpan(
                                    text: ' ▍',
                                    style:
                                        _t(12.0, color: _blue, height: 1.45)),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ]),
            ),
    );
  }
}

/// จุดกะพริบของขั้น "ฟัง" ขณะไมค์เปิด
class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});
  final Color color;
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
        child: Center(
          child: Container(
            width: 10.0,
            height: 10.0,
            decoration:
                BoxDecoration(color: widget.color, shape: BoxShape.circle),
          ),
        ),
      );
}
