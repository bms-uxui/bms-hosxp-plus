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
}

extension _FeaturesSpeechSpeechPart on _ErFlowHomeWidgetState {
  /// หยุดอัด: send = ส่งไปถอดเสียง · false = ทิ้งคลิป (เปลี่ยนขั้น/ปิดโหมดพูด)
  /// ปุ่มเปลี่ยนสถานะทันที ไม่รอเครื่องอัดปิดเสร็จ
  Future<void> _stopRecord({bool send = true}) async {
    if (!_recording) return;
    _recTimer?.cancel();
    if (mounted) setState(() => _recording = false);
    String? path;
    try {
      path = await _rec.stop();
    } catch (_) {}
    if (!mounted) return;
    if (send && path != null) {
      _processClip(path);
    } else {
      _robot.setMood(ErAuraMood.idle);
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
        setState(() => _agentStatus = 'ไม่ได้ยินเสียงพูด ลองใหม่อีกครั้ง');
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
      });
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
        db = a.current;
        amp = ((db + 50.0) / 50.0).clamp(0.08, 1.0);
      } catch (_) {}
      if (!mounted || !_recording) return;
      // ตรวจจับพูด/เงียบเทียบกับเสียงพื้นหลังของห้อง (ห้อง ER ไม่เคยเงียบจริง)
      // พื้นหลัง = ค่าต่ำที่ค่อย ๆ ขยับขึ้น · พูด = ดังกว่าพื้นหลัง 12 dB
      // ได้ยินเสียงพูดแล้วค่อยส่งตอนแตะปิด · เปิดค้างนานสุด 60 วิ
      _dbFloor = db < _dbFloor ? db : _dbFloor + (db - _dbFloor) * 0.01;
      if (db > _dbFloor + 12.0) {
        _heard = true;
      }
      if (_recSec >= 60) {
        _holding = false;
        _heard ? _stopRecord() : _stopRecord(send: false);
        return;
      }
      _tick += 1;
      if (_tick % 8 == 0) _recSec += 1;
      _wave = [..._wave.skip(1), amp];
      _micFrame.value++;
      // แตะปิดเมื่อไรค่อยส่ง (ไม่ตัดเองตอนเงียบ)
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
      });
      await _agentTurn(text, gen);
    } catch (e) {
      if (!mounted || gen != _agentGen) return;
      setState(() {
        _agentBusy = false;
        _agentStatus = 'ถอดเสียงไม่สำเร็จ: ${_shortErr(e)}';
      });
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
}
