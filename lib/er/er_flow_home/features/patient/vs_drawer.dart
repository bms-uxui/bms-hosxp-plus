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
              border: Border.all(color: _line, width: 0.5),
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
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _line, width: 0.5),
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
    ErFeedback.confirm();
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
        _markDone(req.title);
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
      // คีย์บอร์ดขึ้น: เว้นเท่าคีย์บอร์ด (ไม่บวก 14 ซ้อน กันล้นล่างตอนจอเตี้ย)
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 12.0, kb > 0 ? kb : 14.0),
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

/// ไอคอนสัญญาณชีพชุด Figma (HOSXP V6 ER node 893:668) · PNG 120px ฝังใน Dart (เพิ่มได้ด้วย hot reload)
/// คีย์ = คีย์ช่อง V/S ของหน้าคัดกรอง (wt ht sbp hr rr bt spo2 dtx) · ไม่มีในชุด = null
const Map<String, String> _vsFigmaB64 = {
  // สแกนจอ (OCR) ชุดเดียวกัน · Figma 898:2316 สี CI (กรมท่า #001B7C)
  'ocr': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAIR5JREFUeAHtXQmcFMXVfz3XLuzN7gK7yyng'
      'gYLgbUw8MHhrEo+YRMXkF48v0ehn8gkeqBgloiZ+JlGjJp/xiBghGqNRYy5i1BgU5AaRQ64FlmvZ'
      '+5ijv/+/Znq6Z6bn2p1jMVsw293VVa+q3r/eq1evqrtF+kM/B/o5cOByQEu56tWzisXTPVa0wFAJ'
      'uMtFD7iT53XoSdM4Al2iS71s/2ShyHx/0vQHQoLaawaKVJ8u4hgJPrnEoTlF1504ahLAPxV0XTQH'
      'zv26ilPnuKGLQ9124KjyIJ9oOs694pdGcbjqxd+9QRrmbAzSSfw3OcDVM8eJR76FgqeKJmNEc1aI'
      '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',
  'wt': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAHV1JREFUeAHtXWuQHFd1Pre757kv7UqyZAnb'
      '2NhItrFNIYJJCEYmQBEKVwKUIIQUlSqSP6kklaIIhuLhtTGvpFKh4BdQlSKPqhCgEhKSEIyJnUAI'
      'ZVuAX7Jly7Kst6xdaV+z8+y++b7b09LsTndPz+zs9CrMlWZ7+vbte8893znnnvsckWEYcmDIgSEH'
      'hhwYcmDIgSEHhhwYcmDIgSEHhhwYcuAXhwPqF6Kq39D2jQfEnh8/bk+dzFju6DbVWBYlm1tqPzsj'
      'TlFre8TT5+xtXt4RbyIn3v5J8eTdym1JeUl9vWQA3jGtiwVZGnVsZ8TVVtGSBj5W0dMKV1X0bFxd'
      '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',
  'ht': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAGbJJREFUeAHtXQuQHMV57u6Z2cfdnh4gCRAP'
      'QzjuDp2hSATBEJMEx4aiEqfsVEnlOHZIlcsmxDZOUrFNWRIMJx62yyZ2wHYwoVzBL7BCTBUJECgH'
      'bAeweRgKkCUdJyEkEEjocSfpdnde3fn+2d2729fd3uz0zgLX0t7M9PT8/Xf/3X///ffffzO2EBZq'
      'YKEGFmpgoQYWamChBpKoAZ5EplHyPO6f3ujN5ZacIJifEyY3GbMY48rlnlN0M1YxWwzcI+lex3eY'
      '8webmbNpEw/mzGfNT4zVS9eIAyuZkc7ut1LSMgvKMC2VM13FTMN3LMGY6TNuGrgGzDdF6V4oxoRk'
      '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'
      'efIXk8hrAAAAAElFTkSuQmCC',
  'sbp': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAIQRJREFUeAHtXQmcFNWZf6+u7p5hZmC4hktR'
      'btAYo4agAQbRGMyqyRrcxCXGI9FNOBSPNeYwrXjkZ9YLiUZjotEYo2Td9TZBBBGMMSYYRTkVlGFg'
      'gGFgzu6u4+3/q56e6aqunu7qYxjXflpM1at3fPV97zve9773mrFSKmGghIESBkoYKGGghIESBkoY'
      'KGGghIESBkoYKGGghIESBkoYKGGghIESBkoYKGGghIESBkoYKGEgHQZ4uhelfCcGfr1WVLQKfbwq'
      'xCiL8WFciCrGpH4Ws2RJsHYhRIuQ+F5mWfWCBbctmsXrnC0cnqcSgXvA+7LXIuO5kGYyxs9kQhzH'
      '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'
      'AAAASUVORK5CYII=',
  'hr': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAGKhJREFUeAHtXQuYFMW1ruru2YUFeQmCigKC'
      'L6KiwlUTfJD4RIQFdteIXowSX1eiXvXLd/W7iZcvIUaj1+TefHqN70hi0IVZHiriE5UENWpQoygQ'
      'wPB+yXNfM9Nd9/+rp3dmZ2d2h9nZmZ5l6tvZ7qmurj7n/HVOnTpVXSNEMRUlUJRAUQJFCRQlUJRA'
      'UQJFCRQlUJRAUQJFCRQlUJRAUQJFCRQlUJRAUQJ5l4DMFwWqqqqkVtT26WaU9o8o2V0YThcRMhxh'
      'qrATEbtLLGur2L9/rzjzzLCcMcPJF50H8lw1Y4Yh1i0pqd/Vs1/AMAZKS/bD/V1N4ZTYwggJpWpN'
      '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',
  'rr': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAHqdJREFUeAHtXQmUXFWZvvdt1Xt3ku5OJyEB'
      'EkhIAgHFARxAbIKyryqKKDIu4wxLBA+OgyOcZjkOjApjFp3IYVxmzsyxZ/QoKLImBBgYUUCRhCUh'
      'QAIJSYd00kl31/Leu/N9r7rS9apeVb1aujrdUxcq/Za7/Pf/7v3vf//73/uEqIUaB2ocqHGgxoEa'
      'B2ocqHGgxoEaB2ocqHGgxoEaB2ocqHGgxoGJx4El31aNC+7sa554lJdOsSw96cRIOb9n4CjDjFyh'
      'lPgIKjtFSCWVK/YLTTwk3Ng9L9/UunFi1KQ0Kic1wEfdOvRBzbB+LnV9hnBdIYCyFySqrWlCOfbb'
      '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',
  'bt': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAFIdJREFUeAHtXXtsZNdZ/859z9i7a3vt7Hrr'
      '3az30WyzXRoqCk2TAu2qhRCgNGpVHlkeLUFI+StSBaiBsKoQgqoqUukfhYqoASH1j7ZIkEoooG5b'
      'EtSGKDSkado6xPbam/VjvWt77Xndx+H33fHsjsdzZ+bc9XjuWXys8cw97/v9zved73znRbTrdimw'
      'S4FdCuxSYJcCvaPA+fPSmJyc9F6am+t74w2Zn5iYcHtXm50tWexscTtX2uWl63dHoXmGhDglZXQM'
      'L3qATCMvIxkRyTUyaFZI+TpJ8ao0xH+P7c/P7lztdq6k2wrgycmFg05f34PCMM4B2NOmaQ67rkVh'
      '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'
      'TkSuQmCC',
  'spo2': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAJstJREFUeAHtfQmYFdWZ9ld3v317oemGhgYa'
      'lFUkYERBjQbMoNFEx8yoiXGbJ/NPYqLjZDGTMTP/zKNPZv78iZksGjOTZNQkJsYliUbjgltAxQVF'
      'BGRfBOkGmqb37a5V876nbnXX3W/f7upufDhwu6rOfr73fN/5zndOnRI54U5Q4AQFTlDgBAXGKQW0'
      'cVqv4qq11PBeeFWzb9ZMnyckbnfAo2l+r2g+tzbQrmjCMCIxMcJxwwjHDMMfNYy+0ASjvb1dfKFq'
      'I9Tbrkk1i1N/cG2XXsSJdk7UGyOSeO1xickaLV5chcZfrAFCjL+qpdbotj9FFtUGE3OnlhsTJ5XH'
      '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'
      'SUVORK5CYII=',
  'dtx': 'iVBORw0KGgoAAAANSUhEUgAAAHgAAAB4CAYAAAA5ZDbSAAAABGdBTUEAALGPC/xhBQAAACBjSFJN'
      'AAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAARGVYSWZNTQAqAAAACAABh2kA'
      'BAAAAAEAAAAaAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAB4oAMABAAAAAEAAAB4AAAAAAji'
      'Ve4AAAGdaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2Jl'
      'Om5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJk'
      'Zj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxy'
      'ZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOmV4aWY9Imh0dHA6'
      'Ly9ucy5hZG9iZS5jb20vZXhpZi8xLjAvIj4KICAgICAgICAgPGV4aWY6UGl4ZWxYRGltZW5zaW9u'
      'PjE5MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWURpbWVuc2lv'
      'bj4xOTI8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAg'
      'PC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KQzMQBAAAG+hJREFUeAHtXQuUXEWZrqp7u3ueyeQdQhIC'
      'RkgYNEAEXXeFkAUUlQCBCQSW1dUF9BzhuOpRwceOoLB4cOXsS1119exqFhkhMawg0QPZVRFUECSR'
      'AAIx4Rnyzsz0dPe9Vft91XN7unu6+3b3dM90J1Nn7tx769bz/6r++uuvv6qFmHSTFJikwCQFJikw'
      'SYFJCkwEBeREZFpNnmb16mO0Ehep3Xv/RW7e7FWTxpEYx22GSpueHkfr1M0qEr1cz5zOIt/eDOVu'
      'hDKqRihEWBm0SV6jHOdy4ftCKfnF1JoL3hkWZ/J7mgINz6KTl753mWNiP1FSzjVaC6nQJrV+SjjR'
      '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'
      'RgsAAAAASUVORK5CYII=',
};

/// ไอคอน V/S ชุด Figma ขนาด [size] · ไม่มีในชุด = null (ใช้ไอคอนเดิม)
/// แปลงแล้วเก็บไว้ (คีย์ = ข้อความ base64 · แก้ภาพแล้ว hot reload ได้ภาพใหม่)
final Map<String, Uint8List> _vsFigmaCache = {};

Widget? _vsFigmaIcon(String k, {double size = 36.0}) =>
    switch (_vsFigmaB64[k]) {
      final b64? => Image.memory(
          _vsFigmaCache.putIfAbsent(b64, () => base64Decode(b64)),
          width: size,
          height: size,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium),
      null => null,
    };
