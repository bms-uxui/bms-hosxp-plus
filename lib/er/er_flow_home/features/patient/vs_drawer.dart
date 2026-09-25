// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ ลิ้นชักวัดสัญญาณชีพซ้ำ
// ปุ่ม "วัดซ้ำ" บนการ์ดสัญญาณชีพ → ลิ้นชักขวา กรอก HR BP SpO₂ RR BT
// บันทึกแล้วต่อท้ายกราฟทันที · หรือส่งคำขอให้พยาบาลวัด (งานที่ต้องติดตาม)

mixin _FeaturesPatientVsDrawerState on State<ErFlowHomeWidget> {
  /// ลิ้นชักกรอกสัญญาณชีพเปิดอยู่
  bool _vsDrawer = false;

  /// ช่องกรอก: HR · SBP · DBP · SpO₂ · RR · BT
  final Map<String, TextEditingController> _vsIn = {};

  /// ไมค์ในลิ้นชัก: 0 ปิด · 1 เปิดฟังต่อเนื่อง · -1 ผิดพลาด
  int _vsMic = 0;

  /// ขั้นของประโยคล่าสุด (แบบแถบสถานะใน workflow): 1 ฟัง · 2 ถอดเสียง · 3 ตีความ · 4 เสร็จ
  int _vsStage = 0;
  String _vsErr = '';

  /// คำบรรยายสด: ประโยคที่ถอดแล้ว + ประโยคที่กำลังพูด (ชั่วคราว)
  final List<String> _vsLines = [];
  String _vsLive = '';

  /// ช่องที่กรอกจากเสียง (ไฮไลต์ให้ตรวจทาน)
  final Set<String> _vsFromVoice = {};

  /// แพทย์สั่งวัดซ้ำเป็นรอบ: ทุกกี่นาที (null = ครั้งเดียว) · จำนวนครั้ง
  int? _vsEvery;
  int _vsTimes = 4;

  // ตัดประโยคอัตโนมัติ (VAD) เหมือน workflow
  String? _vsClip;
  Timer? _vsAmpTimer;
  Timer? _vsCapTimer;
  double _vsFloor = -45.0;
  int _vsSpeechMs = 0;
  int _vsSilMs = 0;
  bool _vsRotating = false;
  bool _vsCapBusy = false;
  final List<String> _vsQueue = [];
  bool _vsQueueBusy = false;
}

extension _FeaturesPatientVsDrawerPart on _ErFlowHomeWidgetState {
  /// ช่องที่ต้องกรอก: (key, ชื่อ, หน่วย, ต่ำสุดปกติ, สูงสุดปกติ, ทศนิยม)
  static const List<(String, String, String, double, double, bool)> _vsFields =
      [
    ('hr', 'HR', 'bpm', 60, 100, false),
    ('sbp', 'BP ตัวบน', 'mmHg', 90, 140, false),
    ('dbp', 'BP ตัวล่าง', 'mmHg', 60, 90, false),
    ('spo2', 'SpO₂', '%', 95, 100, false),
    ('rr', 'RR', '/min', 12, 20, false),
    ('bt', 'BT', '°C', 36.0, 37.5, true),
  ];

  TextEditingController _vsCtl(String k) =>
      _vsIn.putIfAbsent(k, TextEditingController.new);

  void _openVsDrawer() {
    for (final c in _vsIn.values) {
      c.clear();
    }
    setState(() {
      _vsDrawer = true;
      _vsMic = 0;
      _vsStage = 0;
      _vsErr = '';
      _vsLines.clear();
      _vsLive = '';
      _vsFromVoice.clear();
    });
  }

  void _closeVsDrawer() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_vsMic == 1) _vsStopMic(send: false);
    setState(() {
      _vsDrawer = false;
      _vsMic = 0;
    });
  }

  /// แตะไมค์: เปิดฟังต่อเนื่อง (ตัดประโยคและตีความเองทุกครั้งที่หยุดพูด) · แตะอีกครั้ง = ปิด
  Future<void> _vsMicToggle() async {
    if (_vsMic == 1) {
      await _vsStopMic();
      return;
    }
    if (!await _rec.hasPermission()) {
      setState(() {
        _vsMic = -1;
        _vsStage = -1;
        _vsErr = 'ไม่ได้รับสิทธิ์ใช้ไมโครโฟน';
      });
      return;
    }
    if (await _rec.isRecording()) await _rec.stop();
    await _vsStartClip();
    HapticFeedback.selectionClick();
    setState(() {
      _vsMic = 1;
      _vsStage = 1;
      _vsErr = '';
      _vsLive = '';
      _vsFloor = -45.0;
      _vsSpeechMs = 0;
      _vsSilMs = 0;
    });
    _vsCapTimer?.cancel();
    _vsCapTimer =
        Timer.periodic(const Duration(milliseconds: 1200), (_) => _vsCaption());
    _vsAmpTimer?.cancel();
    _vsAmpTimer = Timer.periodic(const Duration(milliseconds: 120), (_) async {
      if (!mounted || _vsMic != 1) return;
      double db = -60.0;
      try {
        final a = (await _rec.getAmplitude()).current;
        // ไมค์คืน -∞ ตอนเงียบสนิท: ข้าม ไม่งั้นพื้นหลังเป็น NaN จับเสียงพูดไม่ได้
        db = a.isFinite ? math.max(a, -90.0) : _vsFloor;
      } catch (_) {}
      // พื้นหลังค่อย ๆ ขยับ · พูด = ดังกว่าพื้นหลัง 12 dB
      _vsFloor = db < _vsFloor ? db : _vsFloor + (db - _vsFloor) * 0.01;
      if (db > _vsFloor + 12.0) {
        _vsSpeechMs += 120;
        _vsSilMs = 0;
      } else if (_vsSpeechMs > 0) {
        _vsSilMs += 120;
      }
      // พูดจบประโยค (เงียบ ~0.8 วิ หลังพูด ≥ 0.5 วิ) หรือยาวเกิน 20 วิ → ตีความทันที
      if ((_vsSpeechMs >= 480 && _vsSilMs >= 840) || _vsSpeechMs >= 20000) {
        _vsRotate();
      }
    });
  }

  Future<void> _vsStartClip() async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/er_vs_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _rec.start(
      const RecordConfig(
          encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: path,
    );
    _vsClip = path;
  }

  /// ตัดประโยคที่พูดจบส่งตีความ ไมค์ฟังต่อด้วยไฟล์ใหม่
  Future<void> _vsRotate() async {
    if (_vsRotating || _vsMic != 1) return;
    _vsRotating = true;
    String? done;
    try {
      done = await _rec.stop();
      if (!mounted || _vsMic != 1) return;
      await _vsStartClip();
      _vsSpeechMs = 0;
      _vsSilMs = 0;
    } catch (_) {
    } finally {
      _vsRotating = false;
    }
    if (done != null) _vsEnqueue(done);
  }

  /// ปิดไมค์ · send = ตีความประโยคสุดท้ายที่พูดค้างไว้
  Future<void> _vsStopMic({bool send = true}) async {
    _vsAmpTimer?.cancel();
    _vsCapTimer?.cancel();
    final had = _vsSpeechMs >= 360;
    final path = await _rec.stop();
    if (!mounted) return;
    setState(() {
      _vsMic = 0;
      if (_vsQueue.isEmpty && !_vsQueueBusy && !(send && had)) {
        _vsStage = _vsFromVoice.isEmpty ? 0 : 4;
        _vsLive = '';
      }
    });
    if (send && had && path != null) _vsEnqueue(path);
  }

  void _vsEnqueue(String path) {
    _vsQueue.add(path);
    setState(() {});
    _vsDrain();
  }

  /// ตีความทีละประโยคตามลำดับ (ถอดเสียง → ดึงค่า → ลงช่อง)
  Future<void> _vsDrain() async {
    if (_vsQueueBusy) return;
    _vsQueueBusy = true;
    while (_vsQueue.isNotEmpty && mounted && _vsDrawer) {
      await _vsProcess(_vsQueue.removeAt(0));
    }
    _vsQueue.clear();
    _vsQueueBusy = false;
    if (mounted) {
      setState(() {
        if (_vsMic == 1) {
          _vsStage = 1;
        } else if (_vsStage != -1) {
          _vsStage = _vsFromVoice.isEmpty ? 0 : 4;
          _vsLive = '';
        }
      });
    }
  }

  static const String _vsPrompt =
      'ดึงค่าสัญญาณชีพจากคำพูดภาษาไทยของพยาบาล/แพทย์ ตอบ JSON เท่านั้น\n'
      '{"hr":ตัวเลข,"sbp":ตัวเลข,"dbp":ตัวเลข,"spo2":ตัวเลข,"rr":ตัวเลข,"bt":ตัวเลข}\n'
      '- ใส่เฉพาะค่าที่พูดถึง ค่าที่ไม่ได้พูดให้เป็น null ห้ามเดา\n'
      '- ชีพจร/หัวใจเต้น/พัลส์ = hr · ความดัน 120/80 หรือ "ร้อยยี่สิบ ทับ แปดสิบ" = sbp/dbp\n'
      '- ออกซิเจน/แซท/SpO2 = spo2 · หายใจ = rr · ไข้/อุณหภูมิ = bt (องศา เช่น 37.8)\n'
      '- แปลงตัวเลขที่พูดเป็นคำไทยให้เป็นตัวเลข';

  Future<void> _vsProcess(String path) async {
    setState(() => _vsStage = 2);
    try {
      final text = await ErAi.transcribe(await File(path).readAsBytes());
      if (!mounted) return;
      if (!RegExp(r'[0-9ก-๙]').hasMatch(text)) {
        setState(() => _vsLive = '');
        return;
      }
      setState(() {
        _vsLines.add(text);
        if (_vsLines.length > 4) _vsLines.removeAt(0);
        _vsLive = '';
        _vsStage = 3;
      });
      final raw = await ErAi.chat([
        {'role': 'system', 'content': _vsPrompt},
        {'role': 'user', 'content': text},
      ], fast: true, json: true, maxTokens: 120);
      final m = raw.indexOf('{'), e = raw.lastIndexOf('}');
      final j = jsonDecode(raw.substring(m, e + 1)) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        // ประโยคใหม่ทับเฉพาะค่าที่พูดถึง ค่าอื่นคงเดิม
        for (final f in _vsFields) {
          final v = j[f.$1];
          if (v is num) {
            _vsCtl(f.$1).text =
                f.$6 ? v.toStringAsFixed(1) : v.round().toString();
            _vsFromVoice.add(f.$1);
          }
        }
      });
      HapticFeedback.selectionClick();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _vsStage = -1;
        _vsErr = 'ตีความประโยคนี้ไม่สำเร็จ พูดใหม่ได้เลย';
      });
    }
  }

  /// คำบรรยายสด: ถอดเสียงไฟล์ที่กำลังอัดเป็นระยะ (สร้างหัว WAV ใหม่จาก PCM)
  Future<void> _vsCaption() async {
    final path = _vsClip;
    if (_vsMic != 1 || _vsCapBusy || path == null || _vsSpeechMs < 360) {
      return;
    }
    _vsCapBusy = true;
    try {
      final raw = await File(path).readAsBytes();
      if (raw.length <= 44 + 3200) return;
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
      if (!mounted || _vsMic != 1 || _vsClip != path) return;
      if (!RegExp(r'[0-9ก-๙]').hasMatch(text)) return;
      setState(() => _vsLive = text);
    } catch (_) {
    } finally {
      _vsCapBusy = false;
    }
  }

  /// แถบไมค์: ปุ่ม + จุดขั้น ฟัง → ถอดเสียง → ตีความ + คำบรรยายสด
  Widget _vsMicBar() {
    final on = _vsMic == 1;
    final waiting = _vsQueue.length;
    Widget step(int i, String label) {
      final st = _vsStage;
      final active = st == i || (i == 1 && on && st != 2 && st != 3);
      final done = !active && (st > i || st == 4);
      final col = active || done ? _blue : _g5;
      return Row(mainAxisSize: MainAxisSize.min, children: [
        active
            ? _PulseDot(color: col)
            : Container(
                width: 7.0,
                height: 7.0,
                decoration: BoxDecoration(
                    color: done ? col : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: col, width: 1.4)),
              ),
        const SizedBox(width: 4.0),
        Text(label,
            style: _t(10.0,
                color: active ? _blue : (done ? _ink2 : _ink3),
                weight: active ? FontWeight.w700 : FontWeight.w500)),
      ]);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 10.0, 8.0),
      decoration: BoxDecoration(
        color: on ? _blue.withValues(alpha: 0.06) : _panelSoft,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: on ? _blue.withValues(alpha: 0.4) : _line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          _Press(
            child: GestureDetector(
              onTap: _vsMicToggle,
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  gradient: _glossGrad(on ? _red : _blue),
                  shape: BoxShape.circle,
                  boxShadow: _glossLift(on ? _red : _blue),
                ),
                foregroundDecoration: const _InnerGloss(100.0, dark: true),
                child: Icon(on ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 20.0, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: _vsStage == 0 && !on
                ? Text('แตะแล้วพูดต่อเนื่องได้ เช่น "ชีพจร 110 ความดัน 100/60"',
                    style: _t(10.5, color: _ink2, weight: FontWeight.w600))
                : Wrap(spacing: 10.0, runSpacing: 4.0, children: [
                    step(1, 'ฟัง'),
                    step(2, 'ถอดเสียง'),
                    step(3, 'ตีความ'),
                    if (waiting > 0)
                      Text('รออีก $waiting ประโยค',
                          style: _t(10.0, color: _ink3)),
                  ]),
          ),
        ]),
        if (_vsStage == -1 && _vsErr.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(_vsErr, style: _t(10.0, color: _red)),
          ),
        // คำบรรยายสด: ประโยคที่ถอดแล้ว + ที่กำลังพูด (จาง)
        if (_vsLines.isNotEmpty || _vsLive.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: _line),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final l in _vsLines)
                Text(l, style: _t(11.0, color: _ink, weight: FontWeight.w500)),
              if (_vsLive.isNotEmpty)
                Text('$_vsLive…',
                    style: _t(11.0, color: _ink3, weight: FontWeight.w500)
                        .copyWith(fontStyle: FontStyle.italic)),
            ]),
          ),
      ]),
    );
  }

  /// แพทย์: ตั้งวัดซ้ำเป็นรอบ ทุก n นาที × จำนวนครั้ง → สร้างงานให้พยาบาลตามเวลา
  Widget _vsScheduleCard() {
    const opts = [null, 15, 30, 60, 120, 240];
    String lb(int? m) => m == null
        ? 'ครั้งเดียว'
        : m < 60
            ? 'ทุก $m นาที'
            : 'ทุก ${m ~/ 60} ชม.';
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.update_rounded, size: 15.0, color: _blue),
          const SizedBox(width: 6.0),
          Text('สั่งวัดซ้ำ',
              style: _t(11.5, color: _inkTitle, weight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6.0),
        Wrap(spacing: 5.0, runSpacing: 5.0, children: [
          for (final m in opts)
            _chip(lb(m), _vsEvery == m, () => setState(() => _vsEvery = m)),
        ]),
        if (_vsEvery != null) ...[
          const SizedBox(height: 8.0),
          Row(children: [
            Text('จำนวน', style: _t(10.5, color: _ink2)),
            const SizedBox(width: 6.0),
            for (final n in [2, 4, 6, 8])
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: _chip('$n ครั้ง', _vsTimes == n,
                    () => setState(() => _vsTimes = n)),
              ),
          ]),
        ],
      ]),
    );
  }

  /// ส่งคำสั่งวัดซ้ำให้พยาบาล: ครั้งเดียว หรือเป็นรอบตามเวลาที่ตั้ง
  void _sendVsSchedule() {
    final every = _vsEvery;
    if (every == null) {
      _closeVsDrawer();
      _requestVsRecheck();
      return;
    }
    final now = DateTime.now();
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final me = ErSession.instance.user?.name ?? 'แพทย์';
    setState(() {
      final list = _taskExtra.putIfAbsent(_caseP().hn, () => []);
      for (var i = 1; i <= _vsTimes; i++) {
        final at = now.add(Duration(minutes: every * i));
        list.add(_Task('วัดสัญญาณชีพซ้ำ (${hm(at)})', 'รอบที่ $i/$_vsTimes',
            Icons.monitor_heart_rounded, _blue, hm(at), 0,
            urgent: i == 1, by: me));
      }
    });
    _closeVsDrawer();
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            'สั่งวัดสัญญาณชีพทุก ${every < 60 ? '$every นาที' : '${every ~/ 60} ชม.'} × $_vsTimes ครั้ง แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  double? _vsNum(String k) => double.tryParse(_vsCtl(k).text.trim());

  /// บันทึกรอบใหม่ · ช่องที่เว้นว่างใช้ค่าล่าสุดเดิม · ปิดคำขอวัดซ้ำที่ค้าง
  void _saveVs() {
    final c = _case;
    final now = DateTime.now();
    final hm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    erVsAdd(
      c.hn,
      hm,
      _vsNum('hr') ?? c.hr.last,
      _vsNum('sbp') ?? c.sbp.last,
      _vsNum('dbp') ?? c.dbp.last,
      _vsNum('spo2') ?? c.spo2.last,
      _vsNum('rr') ?? c.rr.last,
      _vsNum('bt') ?? c.bt.last,
    );
    final req = _vsRecheck;
    setState(() {
      if (req != null) {
        _taskDone.add(req.title);
        _taskDoneAt[req.title] = now;
      }
      _vsPick.clear();
    });
    _closeVsDrawer();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('บันทึกสัญญาณชีพ $hm น. แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  /// ลิ้นชักขวา (แบบเดียวกับลิ้นชักประวัติการบันทึก)
  Widget _vsDrawerPanel() {
    final c = _case;
    final filled = _vsFields.where((f) => _vsCtl(f.$1).text.isNotEmpty).length;
    String last(String k) => switch (k) {
          'hr' => c.hr.last.round().toString(),
          'sbp' => c.sbp.last.round().toString(),
          'dbp' => c.dbp.last.round().toString(),
          'spo2' => c.spo2.last.round().toString(),
          'rr' => c.rr.last.round().toString(),
          _ => c.bt.last.toString(),
        };

    Widget field((String, String, String, double, double, bool) f) {
      final (k, label, unit, lo, hi, dec) = f;
      final v = _vsNum(k);
      final bad = v != null && (v < lo || v > hi);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(children: [
          SizedBox(
            width: 30.0,
            child: _vsIcon(
                k == 'sbp' || k == 'dbp'
                    ? 'BP'
                    : k == 'spo2'
                        ? 'SpO₂'
                        : label,
                Icons.monitor_heart_rounded,
                18.0,
                bad ? _red : _blue),
          ),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
              Text('ครั้งก่อน ${last(k)} $unit', style: _t(9.5, color: _ink3)),
            ]),
          ),
          SizedBox(
            width: 120.0,
            child: TextField(
              controller: _vsCtl(k),
              keyboardType: TextInputType.numberWithOptions(decimal: dec),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(dec ? r'[0-9.]' : r'[0-9]')),
              ],
              onChanged: (_) => setState(() => _vsFromVoice.remove(k)),
              // ปุ่ม ✓ บนคีย์บอร์ด = ไปช่องถัดไป · ช่องสุดท้าย = ปิดคีย์บอร์ด
              textInputAction:
                  k == 'bt' ? TextInputAction.done : TextInputAction.next,
              textAlign: TextAlign.right,
              style: _num(16.0,
                  color: bad ? _red : _inkTitle, weight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                hintText: last(k),
                hintStyle: _num(16.0, color: _g5),
                suffixText: unit,
                suffixStyle: _t(10.0, color: _ink3),
                filled: true,
                fillColor: bad
                    ? _red.withValues(alpha: 0.06)
                    : _vsFromVoice.contains(k)
                        ? _blue.withValues(alpha: 0.08)
                        : _panelSoft,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9.0),
                    borderSide: BorderSide(
                        color: bad ? _red.withValues(alpha: 0.5) : _line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9.0),
                    borderSide: BorderSide(color: bad ? _red : _blue)),
              ),
            ),
          ),
        ]),
      );
    }

    // คีย์บอร์ดเปิด: ดันเนื้อหาขึ้นพ้นคีย์บอร์ด (ช่องที่กรอกไม่ถูกบัง)
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      width: 340.0,
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 14.0 + kb),
      decoration: BoxDecoration(
        color: _panel,
        border: const Border(left: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24.0,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text('วัดสัญญาณชีพซ้ำ',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          IconButton(
            onPressed: _closeVsDrawer,
            icon: const Icon(Icons.close_rounded, size: 18.0),
            color: _ink2,
          ),
        ]),
        Text('ล่าสุด ${c.times.last} น. · เว้นว่าง = ใช้ค่าเดิม',
            style: _t(10.0, color: _ink3)),
        const SizedBox(height: 12.0),
        _vsMicBar(),
        Expanded(
          child: ListView(children: [for (final f in _vsFields) field(f)]),
        ),
        // แพทย์: สั่งวัดซ้ำเป็นรอบให้พยาบาล · พยาบาล: ส่งคำขอครั้งเดียว
        if (!ErSession.instance.isNurse) _vsScheduleCard(),
        if (_vsRecheck != null && _vsEvery == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text('ขอให้พยาบาลวัดแล้ว ${_vsRecheck!.time} น.',
                textAlign: TextAlign.center,
                style: _t(10.5, color: _blue, weight: FontWeight.w600)),
          )
        else
          TextButton.icon(
            onPressed: _sendVsSchedule,
            icon: const Icon(Icons.send_rounded, size: 15.0),
            label: Text(
                _vsEvery == null
                    ? 'ส่งให้พยาบาลวัด'
                    : 'ส่งคำสั่งวัดซ้ำ $_vsTimes รอบ',
                style: _t(11.5, color: _blue, weight: FontWeight.w700)),
          ),
        const SizedBox(height: 4.0),
        _navBtn(filled == 0 ? 'บันทึก' : 'บันทึก ($filled ค่า)',
            Icons.check_rounded, filled == 0 ? null : _saveVs),
      ]),
    );
  }
}
