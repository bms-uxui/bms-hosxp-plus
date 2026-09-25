// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// กันหลุด: แปลงคำลงท้ายผู้ชายเป็นผู้หญิง ก่อนแสดงและอ่านออกเสียง
String _femaleVoice(String t) => t
    .replaceAll(RegExp(r'นะครับ'), 'นะคะ')
    .replaceAll(RegExp(r'ไหมครับ|มั้ยครับ'), 'ไหมคะ')
    .replaceAll(RegExp(r'หรือครับ|เหรอครับ'), 'หรือคะ')
    .replaceAll(RegExp(r'อะไรครับ'), 'อะไรคะ')
    .replaceAll(RegExp(r'ครับ'), 'ค่ะ')
    .replaceAll(RegExp(r'(^|\s)ผม(\s|$)'), r'$1น้องช่วย$2');

/// กันผู้ช่วยพูดยาว: เก็บแค่ 2 ประโยคแรก (ข้อมูลอื่นอยู่บนจอแล้ว)
String _brief(String text) {
  final parts = _sentences(text);
  return parts.length <= 2 ? text : parts.take(2).join(' ');
}

/// แบ่งข้อความไทยเป็นประโยคสั้น ๆ ตามคำลงท้าย/เครื่องหมาย รวมท่อนสั้นเกินเข้าด้วยกัน
List<String> _sentences(String text) {
  final raw = text
      .replaceAllMapped(RegExp(r'(ค่ะ|คะ|ครับ|นะคะ|นะครับ|[.!?])\s+'),
          (m) => '${m.group(1)}\n')
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  final out = <String>[];
  for (final r in raw) {
    if (out.isNotEmpty && out.last.length < 18) {
      out[out.length - 1] = '${out.last} $r';
    } else {
      out.add(r);
    }
  }
  return out.isEmpty ? [text] : out;
}

/// ชื่อประเภทผู้ป่วยตามตัวเลือกจริงในหน้าคัดกรองของ HOSxP
String _kbType(_Ptype? t) => switch (t) {
      _Ptype.trauma => 'ผู้ป่วยอุบัติเหตุ (Trauma)',
      _Ptype.sepsis => 'ผู้ป่วย Sepsis',
      _Ptype.stroke => 'ผู้ป่วย Stroke',
      _Ptype.stemi => 'ผู้ป่วย STEMI',
      _ => 'ผู้ป่วยฉุกเฉิน',
    };

Color _levelColor(ErLevel l) => switch (l) {
      ErLevel.critical => _redHue,
      ErLevel.urgent => _blue,
      ErLevel.normal => _blue,
    };

(String, double, double, double) _labTuple(ErLab l) =>
    (l.name, l.value, l.lo, l.hi);

List<ErVital> _vitalsFor(ErCase c) {
  Color tone(double v, double lo, double hi) =>
      (v < lo || v > hi) ? _red : _ink;
  return [
    ErVital(
        icon: Icons.favorite_rounded,
        label: 'HR',
        unit: 'bpm',
        series: c.hr,
        color: tone(c.hr.last, 60, 100)),
    ErVital(
        icon: Icons.monitor_heart_rounded,
        label: 'BP',
        unit: 'mmHg',
        series: c.sbp,
        color: tone(c.sbp.last, 90, 140),
        display: c.bp),
    ErVital(
        icon: Icons.bubble_chart_rounded,
        label: 'SpO₂',
        unit: '%',
        series: c.spo2,
        color: tone(c.spo2.last, 94, 100)),
    ErVital(
        icon: Icons.air_rounded,
        label: 'RR',
        unit: '/min',
        series: c.rr,
        color: tone(c.rr.last, 12, 20)),
    ErVital(
        icon: Icons.thermostat_rounded,
        label: 'BT',
        unit: '°C',
        series: c.bt,
        color: tone(c.bt.last, 36.0, 37.5)),
  ];
}

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesSpeechAgentState on State<ErFlowHomeWidget> {
  int _diffGen = 0;

  /// กันคำตอบเก่ามาทับหลังปิดหรือเปลี่ยนขั้น
  int _agentGen = 0;

  /// โหมดเงียบ: ไม่อ่านออกเสียง แสดงข้อความ + สั่น (ใช้ใน ER ที่เสียงรบกวน)
  bool _silent = false;

  /// คำทบทวนเคส (ขั้น 1) เตรียมไว้ล่วงหน้าตั้งแต่เปิดหน้าคนไข้: JSON + คลิปเสียงทีละประโยค
  Map<String, dynamic>? _reviewJson;
  List<Uint8List>? _reviewClips;
  Future<void>? _reviewJob;

  /// ยาที่ลงช่องคำสั่ง/ยา ตรงกับประวัติแพ้ของผู้ป่วยหรือไม่ (เทียบชื่อแบบหยาบ)
  String? _allergyWarn;
}

extension _FeaturesSpeechAgentPart on _ErFlowHomeWidgetState {
  /// เตรียมคำทบทวนเคสไว้ก่อน ตอนกดเปิดโหมดพูดจะได้พูดทันทีไม่ต้องรอ LLM+TTS
  void _prefetchReview() {
    // คนไข้คนใหม่: ล้างของคนก่อน (รวมคำทบทวนที่เตรียมไว้) แล้วเตรียมใหม่
    if (_speechHn != _caseP().hn) {
      _resetSpeechCase();
      _speechHn = _caseP().hn;
    }
    if (_reviewJson != null || _reviewJob != null) return;
    _reviewJob = () async {
      try {
        await ErFormKb.load();
        final out = await ErAi.chat([
          {'role': 'system', 'content': _agentSystem(0)},
          {'role': 'user', 'content': _greetPrompt(0)},
        ], fast: true, json: true, maxTokens: 900, temperature: 0.3);
        final data = ErAi.extractJson(out);
        if (data == null) return;
        final reply =
            _brief(_femaleVoice((data['reply'] as String?)?.trim() ?? ''));
        data['reply'] = reply;
        final clips = <Uint8List>[];
        for (final part in _sentences(reply)) {
          clips.add(await ErAi.speak(part));
        }
        if (!mounted) return;
        _reviewJson = data;
        _reviewClips = clips;
        debugPrint('ErAi เตรียมคำทบทวนเคสแล้ว ${clips.length} ประโยค');
      } catch (e) {
        debugPrint('ErAi เตรียมคำทบทวนไม่สำเร็จ: $e');
      } finally {
        _reviewJob = null;
      }
    }();
  }

  String _greetPrompt(int step) {
    final items = _forms[step];
    final missing = [
      for (final (label, _) in items)
        if (!_filled[step].containsKey(label)) label
    ];
    final (_, stepName) = _steps[step];
    return step == 0
        ? 'เริ่มขั้น "$stepName" ช่องที่ยังว่าง: ${missing.join(', ')}. '
            'ระบบมีข้อมูลจากจุดคัดกรองแล้วและแสดงบนจออยู่ ให้ reply สั้นมาก '
            'ไม่เกิน 15 คำ: อาการสำคัญ 1 วลี + แพ้ยาถ้ามี แล้วถาม "ถูกไหมคะ" '
            'ห้ามอ่านสัญญาณชีพหรือแล็บ ห้ามเกริ่น '
            'และเติมช่องที่ตอบได้จากข้อมูลนั้นลง fields เลย '
            'ช่องที่ไม่มีข้อมูลให้เว้น ใส่ choices ["ถูกต้อง","ขอแก้ไข"] ตอบเป็น JSON'
        : 'เริ่มขั้น "$stepName" ช่องที่ยังว่าง: ${missing.join(', ')}. '
            'reply ไม่เกิน 10 คำ บอกแค่ให้พูดอะไรก่อน ห้ามเกริ่นหรือทักทาย '
            '(เช่น "บอกอาการปัจจุบันได้เลยค่ะ") '
            'fields ให้ว่าง ถ้าช่องแรกที่ถามมีคำตอบเป็นตัวเลือกจำกัด '
            'ให้ใส่ choices ด้วย ตอบเป็น JSON';
  }

  /// เดิมเก็บบล็อก UI จากคำตอบผู้ช่วย (generative UI) · เลิกใช้แล้ว
  /// ผู้ช่วยกรอกค่าลงช่องอย่างเดียว หน้าจอเป็นฟอร์มทีละช่องของแอปเอง
  void _takeUi(Map<String, dynamic> data, int step) {}

  /// รับ JSON ทักทาย: เติมช่อง ตั้งตัวเลือก คืนข้อความที่จะพูด
  String _applyGreet(Map<String, dynamic> data) {
    final fields = (data['fields'] as Map<String, dynamic>?) ?? const {};
    setState(() {
      _useHpiTemplate(data, _speechStep);
      _usePeTemplate(data, _speechStep);
      for (final label in _acceptLabels(_speechStep)) {
        final v = fields[label];
        if (v is String && v.trim().isNotEmpty) {
          _filled[_speechStep][label] = _fmtField(label, v.trim());
        }
      }
      _agentChoices = _parseChoices(data);
      _takeUi(data, _speechStep);
    });
    final (_, stepName) = _steps[_speechStep];
    final reply = _femaleVoice((data['reply'] as String?)?.trim() ?? '');
    return reply.isEmpty
        ? 'สวัสดีค่ะคุณหมอ เริ่มขั้น$stepNameได้เลยค่ะ'
        : reply;
  }

  /// หุ่นทักทายเมื่อเปิดโหมดพูดหรือขึ้นขั้นใหม่ บอกว่ายังขาดช่องไหน
  Future<void> _agentGreet() async {
    final gen = ++_agentGen;
    // ขั้นทบทวนเคส: ถ้าเตรียมไว้แล้วพูดได้ทันที
    if (_speechStep == 0 && _filled[0].isEmpty) {
      if (_reviewJson == null && _reviewJob != null) {
        setState(() {
          _agentBusy = true;
          _agentStatus = 'กำลังเตรียมผู้ช่วย…';
        });
        _robot.setMood(ErAuraMood.thinking);
        await _reviewJob;
        if (!mounted || gen != _agentGen) return;
      }
      final json = _reviewJson;
      final clips = _reviewClips;
      if (json != null && clips != null) {
        final text = _applyGreet(json);
        setState(() {
          _logTurn(false, text);
          _agentSay = text;
          _agentStatus = '';
          _agentBusy = false;
        });
        _robot.onSpeechEnd = () {
          if (!mounted) return;
          _robot.setMood(ErAuraMood.idle);
        };
        if (_silent) {
          HapticFeedback.mediumImpact();
          await Future<void>.delayed(const Duration(milliseconds: 1400));
          if (!mounted || gen != _agentGen) return;
          _robot.onSpeechEnd?.call();
          return;
        }
        for (final c in clips) {
          await _robot.speak(c);
        }
        _robot.flush();
        return;
      }
    }
    setState(() {
      _agentBusy = true;
      _agentStatus = 'กำลังเตรียมผู้ช่วย…';
    });
    _robot.setMood(ErAuraMood.thinking);
    try {
      final out = await ErAi.chat([
        {'role': 'system', 'content': _agentSystem(_speechStep)},
        ..._historyMessages(max: 8),
        {'role': 'user', 'content': _greetPrompt(_speechStep)},
      ], fast: true, json: true, maxTokens: 800, temperature: 0.4);
      if (!mounted || gen != _agentGen) return;
      final data = ErAi.extractJson(out) ?? const {};
      final text = _applyGreet(data);
      await _agentSpeak(text, gen);
    } catch (e) {
      if (!mounted || gen != _agentGen) return;
      setState(() {
        _agentBusy = false;
        _agentStatus = 'ผู้ช่วยไม่ตอบ: ${_shortErr(e)}';
      });
      _robot.setMood(ErAuraMood.idle);
    }
  }

  /// รอบสนทนา: ข้อความที่หมอพูด → LLM แยกลงช่องฟอร์ม + ประโยคตอบกลับ → TTS
  Future<void> _agentTurn(String userText, int gen) async {
    setState(() => _agentStatus = 'กำลังตีความ…');
    final step = _speechStep;
    final known = _filled[step];
    // HPI: คำพูดต้องไปเติมใน template ที่เลือก ไม่ใช่เขียนแยกเป็นอีกก้อน
    // ยังไม่ได้เลือก → วาง template ที่ระบบแนะนำสำหรับเคสนี้ก่อน แล้วค่อยตีความลงช่อง [ ]
    if (_isHpiStep(step) && (known['HPI'] ?? '').trim().isEmpty) {
      final t = _hpiTemplates.where((x) => x.$1 == _hpiSuggest).firstOrNull ??
          _hpiTemplates.first;
      setState(() => known['HPI'] = _prettyHpi(t.$3));
    }
    final t0 = DateTime.now();
    // ส่งบทสนทนาก่อนหน้าไปด้วย ผู้ช่วยจะได้จำสิ่งที่คุยกันแล้ว ไม่ถามซ้ำ
    final history = _historyMessages();
    if (history.isNotEmpty && !history.last['content']!.contains(userText)) {
      history.removeLast();
    }
    if (history.isNotEmpty) history.removeLast();
    final out = await ErAi.chat([
      {'role': 'system', 'content': _agentSystem(step)},
      ...history,
      {
        'role': 'user',
        'content': 'ค่าที่บันทึกไว้แล้ว: ${jsonEncode(known)}\n'
            '${_utterBlock(step)}'
            'พูดว่า: "$userText"\n'
            'ตอบเป็น JSON ตามรูปแบบที่กำหนด',
      },
    ], json: true, fast: true, maxTokens: 900);
    debugPrint('ErAi LLM ${DateTime.now().difference(t0).inMilliseconds} ms');
    if (!mounted || gen != _agentGen) return;
    final data = ErAi.extractJson(out) ?? const {};
    final intent = (data['intent'] as String?) ?? 'fill';
    final reply = (data['reply'] as String?)?.trim() ?? '';

    // คำสั่งควบคุม: ข้าม / ย้อน / ยกเลิกล่าสุด / อ่านทวน — ไม่ลงฟอร์ม
    if (intent == 'command') {
      final cmd = (data['command'] as String?) ?? '';
      switch (cmd) {
        case 'skip':
        case 'next':
          _agentGen++;
          _confirmStep();
          return;
        case 'back':
          if (_speechStep > 0) {
            _agentGen++;
            setState(() => _speechStep -= 1);
            _agentGreet();
            return;
          }
        case 'undo':
          setState(() {
            for (final (st, label, prev) in _lastFilled) {
              if (prev == null) {
                _filled[st].remove(label);
              } else {
                _filled[st][label] = prev;
              }
            }
            _lastFilled = const [];
          });
          await _agentSpeak('ยกเลิกรายการล่าสุดแล้วค่ะ', gen);
          return;
        case 'read':
          final k = _filled[step];
          final text = k.isEmpty
              ? 'ขั้นนี้ยังไม่มีข้อมูลค่ะ'
              : [for (final e in k.entries) '${e.key} ${e.value}'].join(', ');
          await _agentSpeak('ที่บันทึกไว้คือ $text', gen);
          return;
      }
    }

    // คำถามกลับ ("Cr เท่าไร" "แพ้อะไร"): ตอบจากข้อมูลเคส ไม่ลงฟอร์ม
    if (intent == 'question') {
      setState(() {
        _agentChoices = null;
        _takeUi(data, step);
      });
      await _agentSpeak(
          reply.isEmpty ? 'ไม่พบข้อมูลนั้นในระบบค่ะ' : reply, gen);
      return;
    }

    final fields = (data['fields'] as Map<String, dynamic>?) ?? const {};
    final changed = <(int, String, String?)>[];
    setState(() {
      _useHpiTemplate(data, step);
      _usePeTemplate(data, step);
      for (final label in _acceptLabels(step)) {
        final v = fields[label];
        if (v is! String) continue;
        // "" = ผู้ใช้แก้ว่าไม่ใช่/ยกเลิกค่าที่เคยพูด → ล้างช่องนั้น
        if (v.trim().isEmpty) {
          if (known.containsKey(label)) {
            changed.add((step, label, known[label]));
            known.remove(label);
          }
          continue;
        }
        final nv = _fmtField(label, v.trim());
        if (known[label] != nv) {
          changed.add((step, label, known[label]));
          _diffs[label] = (known[label] ?? '', ++_diffGen);
          known[label] = nv;
        }
      }
      if (changed.isNotEmpty) {
        _lastFilled = changed;
        _flashGlow({for (final c in changed) c.$2});
      }
      if (step == _speechStep) _autoIcd9();
      _agentChoices = _parseChoices(data);
      _takeUi(data, step);
      // เตือนยาที่ชนกับประวัติแพ้ทันที (เช็คจากข้อความที่ลงในช่องยา)
      _allergyWarn = _allergyConflict();
    });
    var say = reply.isEmpty ? 'รับทราบค่ะ มีอะไรเพิ่มอีกไหมคะ' : reply;
    if (_allergyWarn != null && !say.contains('แพ้')) {
      say = 'ระวังค่ะ ${_allergyWarn!} $say';
    }
    await _agentSpeak(say, gen);
  }

  /// ประโยคทั้งหมดของขั้น (มีลำดับ) ส่งให้ผู้ช่วยตีความรวม
  String _utterBlock(int step) {
    final u = _utter[step];
    if (u.isEmpty) return '';
    return 'ประโยคทั้งหมดที่พูดในขั้นนี้ (เรียงตามเวลา ใช้ตีความรวมกัน):\n'
        '${[
      for (var i = 0; i < u.length; i++) '${i + 1}. ${u[i]}'
    ].join('\n')}\n';
  }

  /// ไฮไลต์ช่องที่เพิ่งเปลี่ยนสักครู่ (AI glow)
  void _flashGlow(Set<String> labels) {
    _glow = labels;
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted && identical(_glow, labels)) setState(() => _glow = const {});
    });
  }

  String? _allergyConflict() {
    final meds = [
      for (final m in _filled)
        for (final e in m.entries)
          if (e.key.contains('ยา') || e.key.contains('การรักษา')) e.value
    ].join(' ').toLowerCase();
    if (meds.isEmpty) return null;
    const alias = {
      'penicillin': [
        'penicillin',
        'amoxicillin',
        'ampicillin',
        'เพนิซิลลิน',
        'อะม็อกซี',
        'pip/tazo',
        'piperacillin',
        'augmentin'
      ],
      'sulfa': ['sulfa', 'co-trimoxazole', 'bactrim', 'ซัลฟา'],
      'nsaids': [
        'nsaid',
        'ibuprofen',
        'ketorolac',
        'diclofenac',
        'naproxen',
        'ไอบูโพรเฟน'
      ],
    };
    for (final a in _case.allergies) {
      final key = a.toLowerCase();
      final hits = alias.entries
          .where((e) => key.contains(e.key) || e.value.any(key.contains))
          .expand((e) => e.value)
          .toList()
        ..add(key);
      final hit = hits.firstWhere(meds.contains, orElse: () => '');
      if (hit.isNotEmpty) return 'ผู้ป่วยแพ้ $a แต่มีการสั่ง $hit';
    }
    return null;
  }

  /// อ่าน choices จากคำตอบผู้ช่วย ต้องเป็นช่องที่มีในฟอร์มขั้นนี้และมี 2 ตัวเลือกขึ้นไป
  (String, List<String>)? _parseChoices(Map<String, dynamic> data) {
    final c = data['choices'];
    if (c is! Map) return null;
    final field = c['field'];
    final opts = c['options'];
    if (field is! String || opts is! List) return null;
    final labels = [for (final (l, _) in _forms[_speechStep]) l];
    // field ว่าง = ปุ่มยืนยัน/โต้ตอบทั่วไป ไม่ผูกกับช่องใด
    if (field.isNotEmpty && !labels.contains(field)) return null;
    final list = [
      for (final o in opts)
        if (o is String && o.trim().isNotEmpty) o.trim()
    ].take(6).toList();
    return list.length < 2 ? null : (field, list);
  }

  /// หมอกดตัวเลือกที่ผู้ช่วยสร้างให้ → ลงช่องทันที แล้วให้ผู้ช่วยถามข้อถัดไป
  void _pickChoice(String field, String option) {
    if (_agentBusy || _recording) return;
    _robot.stop();
    setState(() {
      if (field.isNotEmpty) _filled[_speechStep][field] = option;
      _agentChoices = null;
      _logTurn(true, field.isEmpty ? option : '$field: $option');
      _agentBusy = true;
      _agentStatus = field.isEmpty ? 'เลือก "$option"' : 'บันทึก $field แล้ว';
    });
    _robot.setMood(ErAuraMood.thinking);
    final gen = ++_agentGen;
    _agentTurn(
            field.isEmpty
                ? '(กดเลือก) $option'
                : '(กดเลือกจากตัวเลือก) $field = $option',
            gen)
        .catchError((e) {
      if (!mounted || gen != _agentGen) return;
      setState(() {
        _agentBusy = false;
        _agentStatus = 'ผู้ช่วยไม่ตอบ: ${_shortErr(e)}';
      });
      _robot.setMood(ErAuraMood.idle);
    });
  }

  /// ให้หุ่นพูดข้อความนี้: แยกเป็นประโยค สังเคราะห์ทีละประโยคแล้วส่งเข้าคิว
  /// ประโยคแรกสั้น ๆ มาถึงใน ~1 วิ หุ่นเริ่มพูดทันที ระหว่างนั้นประโยคถัดไปค่อยตามมา
  Future<void> _agentSpeak(String raw, int gen) async {
    final text = _brief(_femaleVoice(raw));
    setState(() {
      _logTurn(false, text);
      _agentSay = text;
      _agentStatus = '';
      _agentBusy = false;
    });
    _robot.onSpeechEnd = () {
      if (!mounted) return;
      _robot.setMood(ErAuraMood.idle);
      // ไมค์เปิดด้วยการแตะเท่านั้น: ไม่เปิดเอง กันเสียงรอบห้องเข้าระบบ
    };
    if (_silent) {
      // โหมดเงียบ: สั่นเตือน แสดงข้อความ แล้วเปิดไมค์หลังให้เวลาอ่านสั้น ๆ
      HapticFeedback.mediumImpact();
      _robot.setMood(ErAuraMood.talking);
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (!mounted || gen != _agentGen) return;
      _robot.onSpeechEnd?.call();
      return;
    }
    final t0 = DateTime.now();
    var first = true;
    for (final part in _sentences(text)) {
      try {
        final mp3 = await ErAi.speak(part);
        if (!mounted || gen != _agentGen) return;
        if (first) {
          debugPrint(
              'ErAi TTS ประโยคแรก ${DateTime.now().difference(t0).inMilliseconds} ms');
          first = false;
        }
        await _robot.speak(mp3);
      } catch (e) {
        debugPrint('ErAi TTS ล้มเหลว: $e');
        if (!mounted || gen != _agentGen) return;
        setState(() => _agentStatus = 'เสียงไม่มา แต่อ่านคำตอบได้จากการ์ด');
      }
    }
    if (!mounted || gen != _agentGen) return;
    _robot.flush();
  }

  /// ข้อมูลเคสปัจจุบันจากจุดคัดกรอง/แฟ้ม (จำลอง) ให้ผู้ช่วยทบทวนได้โดยไม่ต้องถามซ้ำ
  /// ยังไม่ส่งชื่อ-HN ออกไป ส่งเฉพาะข้อมูลทางคลินิก
  /// ผู้ป่วยที่กำลังดูอยู่ (หน้ารายละเอียด) หรือคนแรกของช่วงงาน
  _P _caseP() => _sceneSelected(_open ?? _Phase.treatment);

  /// เคสจำลองของผู้ป่วยที่กำลังดู
  ErCase get _case => erCaseOf(_caseP().hn);

  /// แปลงสัญญาณชีพของเคสเป็นการ์ดกราฟ สีแดงเมื่อค่าล่าสุดผิดปกติ
  List<ErVital> _caseVitals() => _vitalsFor(_case);

  String _caseContext() {
    final p = _caseP();
    final c = _case;
    final esi = p.esi == null
        ? 'ยังไม่คัดกรอง'
        : 'ESI ${p.esi!.level} (${p.esi!.label})';
    String list(List<String> l) => l.isEmpty ? 'ไม่มี' : l.join(', ');
    return [
      'ผู้ป่วย${c.sex} อายุ ${c.age} ปี เตียง ${p.bed ?? 'ยังไม่มีเตียง'} ขั้นงาน: ${p.stage.label} '
          'ระดับ $esi ประเภทผู้ป่วย: ${_kbType(p.type)} สถานะ: ${p.note}',
      'ประเภทการมา: ${c.arrival} สภาพผู้ป่วย: ${c.condition} สิทธิ: ${c.right}',
      'อาการสำคัญจากจุดคัดกรอง: ${c.cc}',
      if (c.hpi.isNotEmpty) 'HPI: ${c.hpi}',
      if (c.painScore != null) 'ระดับความเจ็บปวด: ${c.painScore}/10',
      if (c.gcs != null)
        'GCS: ${c.gcs} (รวม ${c.gcsScore}) ความรู้สึกตัว: ${c.consciousness}',
      'ปัญหา/วินิจฉัยที่บันทึกแล้ว: ${list([
            for (final d in c.dx)
              d.icd10 == null ? d.text : '${d.text} (${d.icd10})'
          ])}',
      'ประวัติแพ้: ${list(c.allergies)}',
      'โรคประจำตัว: ${list(c.underlying)}',
      'ยาที่ให้แล้ว: ${list([
            for (final m in c.meds) '${m.name} (${m.route} ${m.time})'
          ])}',
      'แล็บ: ${list([
            for (final l in c.labs)
              '${l.name} ${l.value}${l.abnormal ? ' ผิดปกติ' : ''}'
          ])}',
      'ภาพถ่าย: ${list([for (final i in c.imaging) '${i.name}: ${i.result}'])}',
      'สัญญาณชีพล่าสุด (${c.times.last}): HR ${c.hr.last.round()} BP ${c.bp} SpO2 ${c.spo2.last.round()}% '
          'RR ${c.rr.last.round()} BT ${c.bt.last}',
      if (c.lastNote != null)
        'บันทึกพยาบาลล่าสุด ${c.lastNote!.time} ${c.lastNote!.by}: ${c.lastNote!.text}',
      'ขั้นถัดไปที่วางแผนไว้: ${c.nextStep} ${c.nextDetail}',
      if (c.disposition.isNotEmpty)
        'สภาพผู้ป่วยออกจากห้อง ER ที่สั่งแล้ว: ${c.disposition}',
    ].join('\n');
  }

  /// ส่วนของฟอร์ม HOSxP ที่เกี่ยวกับขั้นนี้ (จาก er_form_kb.json)
  String _kbForStep(int step) {
    final kb = ErFormKb.maybe;
    if (kb == null) return '(ยังโหลดฐานความรู้ไม่เสร็จ)';
    final p = _caseP();
    final template = switch (p.type) {
      _Ptype.trauma => 'template_trauma',
      _Ptype.sepsis => 'template_sepsis',
      _Ptype.stroke => 'template_stroke',
      _Ptype.stemi => 'template_stemi',
      _ => 'template_general_emergency',
    };
    if (ErSession.instance.isTriage) {
      return switch (step) {
        0 => kb.describe('patient_screening', sections: const [
            'ข้อมูลรับเข้า',
            'ข้อมูลการมา',
            'ประเภทผู้ป่วย',
          ]),
        1 => kb.describe('patient_screening',
            sections: const ['อาการสำคัญ', 'ระดับความเจ็บปวด']),
        2 => kb.describe('patient_screening', sections: const ['Vital Sign']),
        3 => kb.describe('patient_screening', sections: const [
            'การประเมินระดับความรู้สึกตัว (GCS)',
            'รูม่านตา (Pupils)',
          ]),
        4 => kb.describe('accident') + kb.describe('add_accident_basic_care'),
        _ => kb.describe('patient_screening',
            sections: const ['ระดับความเร่งด่วน (ESI)']),
      };
    }
    if (ErSession.instance.isNurse) {
      return switch (step) {
        0 => kb.describe('add_vitalsignmonitor'),
        1 => kb.describe('add_accident_vital_signs'),
        2 => kb.describe('nursing_activities'),
        3 => kb.describe('observe'),
        4 => kb.describe('add_nursing_diagnosis'),
        _ => kb.describe('e_r_admission_edit'),
      };
    }
    return switch (step) {
      // แพทย์ทบทวนข้อมูลที่จุดคัดกรองบันทึกไว้ (ยืนยัน ไม่กรอกแทน)
      0 => kb.describe('patient_screening', sections: const [
          'ประเภทผู้ป่วย',
          'อาการสำคัญ',
          'ระดับความเร่งด่วน (ESI)',
          'การประเมินระดับความรู้สึกตัว (GCS)',
          'ระดับความเจ็บปวด',
        ]),
      1 => kb.describe('physical_examination',
          sections: const ['HPI', 'ข้อมูลการซักประวัติและการตรวจรักษา']),
      2 => kb.describe('physical_examination',
          sections: const ['ตรวจร่างกาย', 'Review of System']),
      3 => kb.describe('treatment'),
      4 => kb.describe('diagnosis') +
          kb.describe('add_doctorsorders') +
          kb.describe(template) +
          kb.describe('add_medicatin_order',
              sections: const ['Medication', 'ฉลากช่วย']) +
          kb.describe('treatment'),
      _ => kb.describe('e_r_admission_edit') +
          kb.describe('add_admit') +
          kb.describe('add_refer'),
    };
  }

  /// ฐานความรู้ของผู้ช่วย: ฟอร์มที่ต้องกรอกในขั้นนี้และกติกาการตอบ
  String _agentSystem(int step) {
    final (_, stepName) = _steps[step];
    final form = [
      for (final (label, hint) in _forms[step])
        '- "$label"${hint.isEmpty ? '' : ' (ตัวอย่าง: $hint)'}',
      for (final l in _detailLabels(step))
        '- "$l" (ข้อความอิสระ ยาวได้หลายประโยค ใส่รายละเอียดผลตรวจตามที่แพทย์พูดครบถ้วน ไม่ย่อ)',
      if (_isHpiStep(step)) _hpiTemplatePrompt(),
      if (_isPeStep(step)) _peTemplatePrompt(),
      if (_forms[step].any((f) => f.$1 == _icd9Label)) _icd9Prompt(),
    ].join('\n');
    final outline = [
      for (var i = 0; i < _steps.length; i++) '${i + 1}. ${_steps[i].$2}'
    ].join(' → ');
    return '''
คุณคือ "น้องช่วย" ผู้ช่วยห้องฉุกเฉิน เป็นผู้หญิง กำลังคุยกับ${ErSession.instance.isNurse ? '${ErSession.instance.isTriage ? 'พยาบาลจุดคัดกรอง' : 'พยาบาลห้องฉุกเฉิน'} เรียกว่า "คุณพยาบาล"' : 'แพทย์ เรียกว่า "คุณหมอ"'} เพื่อเก็บข้อมูลลงเวชระเบียนผ่านเสียง
ใช้ภาษาผู้หญิงสุภาพเสมอ: ลงท้ายประโยคบอกเล่าด้วย "ค่ะ" ประโยคคำถามด้วย "คะ" เรียกตัวเองว่า "น้องช่วย"
ห้ามใช้ "ครับ" หรือ "ผม" เด็ดขาด
ขั้นตอนทั้งหมด: $outline
ตอนนี้อยู่ขั้น "$stepName" ฟอร์มขั้นนี้มีช่องดังนี้ (ชื่อช่องต้องใช้ตรงตามนี้เป๊ะ):
$form

ข้อมูลเคสปัจจุบันที่มีอยู่แล้วในระบบ (จากจุดคัดกรองและแฟ้ม):
${_caseContext()}

ฟอร์มจริงใน HOSxP Plus ที่ขั้นนี้ต้องบันทึก (ชื่อช่อง ประเภท และตัวเลือกที่ระบบมีจริง):
${_kbForStep(step)}

แนวทางขั้นนี้: ${_asks[step]}

หน้าที่:
1. ผู้ใช้มักพูดเป็น narrative ก้อนเดียวปนอังกฤษ (เช่น "หญิงห้าสิบสี่ ซ้อนมอไซค์ล้ม ใส่หมวก LOC ไม่มี อาเจียนสองครั้ง ปวดหัวเจ็ดเต็มสิบ underlying HT")
   ต้องแตกทุกข้อมูลในประโยคลง "หลายช่อง" พร้อมกันในรอบเดียว ห้ามแต่งข้อมูลที่ไม่ได้พูด
2. ถ้าบอกว่าปกติ/ไม่มี ให้บันทึกได้ เช่น "ปกติ" "ไม่มี" "ไม่แพ้ยา"
   ถ้าพูดว่า "ที่เหลือปกติหมด" / "อื่น ๆ ปกติ" ให้ใส่ "ปกติ" ทุกช่องที่ยังว่างของขั้นนี้
1.1 ตีความจาก "ประโยคทั้งหมดที่พูดในขั้นนี้" (ส่งมาเป็นรายการลำดับ) ไม่ใช่แค่ประโยคล่าสุด
   ถ้าประโยคหลังแก้/ขัดกับประโยคก่อน ("ไม่ใช่" "แก้เป็น" "เมื่อกี้ผิด" "ขอแก้") ให้ใช้ค่าล่าสุด
   แล้วส่งช่องนั้นกลับใน fields ด้วยค่าที่แก้แล้ว · ถ้าบอกว่าไม่มี/ยกเลิกค่าเดิมให้ส่ง "" เพื่อล้างช่อง
   ช่องข้อความยาว (เช่น HPI) แก้แบบผ่าตัด: คงถ้อยคำเดิมทุกส่วนที่ไม่เกี่ยว แก้เฉพาะวลีที่เปลี่ยน
2.1 ถามกลับเฉพาะช่องที่ "ยังว่างและสำคัญต่อการตัดสินใจ" (เช่น LOC, ยาละลายลิ่มเลือด, GCS, แพ้ยา)
   ช่องเสริมที่ว่างให้ปล่อยได้ ไม่ต้องไล่ถามครบทุกช่อง
2.2 intent: ถ้าผู้ใช้สั่งควบคุม ("ข้าม" "ขั้นต่อไป" "ย้อนกลับ" "ยกเลิกอันล่าสุด" "อ่านที่บันทึกให้ฟัง")
   ให้ตอบ {"intent":"command","command":"skip|next|back|undo|read","reply":"..."} ไม่ต้องมี fields
   ถ้าผู้ใช้ "ถาม" ข้อมูลเคส ("Cr เท่าไร" "แพ้อะไรบ้าง" "ให้ยาอะไรไปแล้ว" "รอ CT นานแค่ไหน")
   ให้ตอบจากข้อมูลเคสด้านบนใน reply สั้น ๆ พร้อม {"intent":"question"} ไม่ลงฟอร์ม
   กรณีอื่นใช้ {"intent":"fill"}
3. ตอบสั้นแบบวิทยุสื่อสารในห้องฉุกเฉิน ไม่เกิน 12 คำ ไม่เกิน 2 ประโยค ไม่ทวนสิ่งที่รับได้
   ห้ามเกริ่น ("น้องช่วยพร้อม…" "ได้เลยค่ะ คุณหมอ…") ข้อมูลอยู่บนจอแล้ว ไม่ต้องอ่านซ้ำ
   แค่ "รับทราบ" แล้วถามช่องถัดไป 1 ช่อง ถ้าครบแล้วพูดว่า "ครบแล้ว กดยืนยันได้"
   ประโยคแรกต้องสั้นมาก (ไม่เกิน 6 คำ) เพราะจะถูกอ่านออกเสียงก่อน
4. คำตอบจะถูกอ่านออกเสียงด้วย TTS ภาษาไทย จึงเลี่ยงตัวย่อและอักษรอังกฤษ
   ใช้คำอ่านไทยแทน เช่น หัวใจ ปอด ท้อง ระบบประสาท ไม่ต้องใส่หัวข้อหรืออีโมจิ

รูปแบบ JSON ที่ต้องตอบ (เมื่อถูกขอให้ตอบ JSON):
{"intent": "fill|command|question",
 "command": "<เฉพาะ intent=command>",
 "fields": {"<ชื่อช่อง>": "<ค่าที่ได้>"},
 "reply": "<ประโยคตอบกลับ>",
 "complete": <true|false>,
 "choices": {"field": "<ชื่อช่องที่กำลังถาม>", "options": ["<ตัวเลือก>", ...]}}
ใส่เฉพาะช่องที่ได้ข้อมูลใหม่หรือแก้ไขใน fields
choices = ปุ่มให้แพทย์กดเลือกแทนการพูด ใส่เมื่อช่องที่กำลังถามมีคำตอบเป็นชุดจำกัด
ถ้าฟอร์ม HOSxP ด้านบนมีตัวเลือกของช่องนั้นอยู่แล้ว ต้องใช้ข้อความตัวเลือกตรงตามนั้น
และค่าที่ใส่ใน fields ต้องเป็นหนึ่งในตัวเลือกจริง (เช่น GCS ใช้ "E4 ลืมตาได้เอง")
2-6 ตัวเลือกสั้น ๆ เช่น ระดับความรุนแรง → ["ESI 1","ESI 2","ESI 3","ESI 4","ESI 5"],
ผลตรวจ → ["ปกติ","ผิดปกติ"], ประวัติแพ้ยา → ["ไม่แพ้ยา","แพ้ยา (ระบุ)"],
ระยะเวลา → ["ไม่กี่ชั่วโมง","1-2 วัน","3-7 วัน","มากกว่า 1 สัปดาห์"]
ถ้าคำตอบเป็นข้อความอิสระ ให้ละ choices

เป้าหมาย: พาแพทย์กรอกฟอร์มของขั้นนี้ให้ครบด้วยเสียง ถามทีละช่องที่ยังว่าง''';
  }
}
