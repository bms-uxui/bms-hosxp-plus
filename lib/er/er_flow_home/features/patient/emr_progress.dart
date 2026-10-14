// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ eGFR · EMR · Progress note
// สิ่งที่แพทย์ดูข้างเตียง: eGFR (profile ไตที่ดูประจำ) · ประวัติทุก visit (EMR)
// · เขียน progress note โดยคัดลอก CC / HPI / ประวัติ / V/S / Lab ลงได้ทันที

/// eGFR (mL/min/1.73m²) สูตร CKD-EPI 2021 (ไม่ใช้เชื้อชาติ)
double _egfr(double cr, int age, bool female) {
  final k = female ? 0.7 : 0.9;
  final a = female ? -0.241 : -0.302;
  final r = cr / k;
  return 142.0 *
      math.pow(math.min(r, 1.0), a) *
      math.pow(math.max(r, 1.0), -1.200) *
      math.pow(0.9938, age) *
      (female ? 1.012 : 1.0);
}

/// ระดับ CKD ตาม eGFR
String _ckdStage(double g) => g >= 90
    ? 'G1'
    : g >= 60
        ? 'G2'
        : g >= 45
            ? 'G3a'
            : g >= 30
                ? 'G3b'
                : g >= 15
                    ? 'G4'
                    : 'G5';

mixin _FeaturesPatientEmrProgressState on State<ErFlowHomeWidget> {
  /// แสดงแถว eGFR ในการ์ดแล็บ (toggle)
  bool _egfrOn = false;

  /// progress note ต่อผู้ป่วย (HN → ข้อความ)
  final Map<String, TextEditingController> _progress = {};

  /// หัวข้อที่ AI ประเมินจากเคส (HN → รายการ) · ที่แพทย์เลือกไว้ (index)
  final Map<String, List<({String sec, String title, String text})>> _pnAi = {};
  final Map<String, Set<int>> _pnAiSel = {};
  final Set<String> _pnAiBusy = {};
  final Map<String, String> _pnAiErr = {};
}

extension _FeaturesPatientEmrProgressPart on _ErFlowHomeWidgetState {
  bool get _female => _case.sex.contains('หญิง');

  // ---------------------------------------------------------------- eGFR

  /// ผล Lab ของ profile eGFR: eGFR (คำนวณจาก Cr) + รายการไต/เกลือแร่ที่มีในผล
  List<ErLab> _egfrProfile(List<ErLab> labs) {
    const keep = ['BUN', 'Cr', 'Na', 'K', 'Cl', 'HCO3', 'HCO₃'];
    final cr = labs.where((l) => l.name == 'Cr' && l.isNumeric).firstOrNull;
    return [
      if (cr != null)
        ErLab('eGFR', _egfr(cr.value, _case.age, _female).roundToDouble(), 60,
            200),
      for (final k in keep)
        for (final l in labs)
          if (l.name == k) l,
    ];
  }

  /// ปุ่มเปิด/ปิดแถว eGFR ในหัวการ์ดแล็บ
  Widget _egfrToggle() => _chip(_egfrOn ? 'eGFR ✓' : 'eGFR', _egfrOn,
      () => setState(() => _egfrOn = !_egfrOn));

  // ---------------------------------------------------------------- EMR

  /// visit ทั้งหมดของผู้ป่วย ใหม่ → เก่า (รายการแรก = visit นี้ จากข้อมูลเคส)
  /// visit ก่อนหน้า: CC/HPI + Lab จากประวัติเดิม + รายละเอียดจำลองตามหน้า EMR แอปเดิม
  List<_EmrVisit> _emrVisits() {
    final c = _case;
    final p = _caseP();
    final tri = erTableFor(c.hn, ErTab.triage).rows;
    String cell(String k) =>
        tri.where((r) => r[1] == k).map((r) => r[2]).firstOrNull ?? '-';
    final info = {
      for (final r in erTablesFor(c.hn, ErTab.overview).first.rows) r[0]: r[1]
    };
    final hv = erHpiVisits(c);
    final lv = erLabVisits(c);
    List<ErLab> labsOf(String date) => [
          for (final v in lv)
            if (v.date == date) ...v.labs
        ];
    String hm(String t) =>
        RegExp(r'^\d{1,2}:\d{2}$').hasMatch(t.trim()) ? '${t.trim()} น.' : t;

    // V/S แรกรับ (คัดกรอง) เรียงตามหน้า EMR เดิม + BMI ต่อจากส่วนสูง
    final vs = <(String, String)>[];
    double? wt, ht;
    for (final r in tri) {
      if (r[0] != 'Vital Sign' || r[1] == 'ความรู้สึกตัว') continue;
      vs.add((r[1], r[2]));
      if (r[1].startsWith('น้ำหนัก')) wt = double.tryParse(r[2]);
      if (r[1].startsWith('ส่วนสูง')) {
        ht = double.tryParse(r[2]);
        if (wt != null && ht != null && ht > 0) {
          vs.add(('BMI', (wt / ((ht / 100) * (ht / 100))).toStringAsFixed(1)));
        }
      }
    }
    final hx = (_hxRecs[c.hn] ?? const <Map<String, String>>[]).lastOrNull;
    final today = DateTime.now();
    final appts = [
      for (final a in _apptsOf(c.hn))
        if (!a.date.isBefore(DateTime(today.year, today.month, today.day)))
          (
            '${_apptDate(a.date)} ${a.start} น.',
            a.doctor,
            [a.clinic, if (a.note.isNotEmpty) a.note].join(' '),
          ),
    ];
    final doctor = info['แพทย์เจ้าของไข้'] ?? '-';
    final now = _EmrVisit(
      date: cell('วันที่เข้าห้องฉุกเฉิน'),
      place: 'ER',
      time: cell('เวลาที่เข้าห้องฉุกเฉิน'),
      shift: cell('เวร'),
      sender: cell('พยาบาลคัดกรอง / เวลา').split(' · ').first,
      arrival: cell('ประเภทการมา'),
      dept: 'อุบัติเหตุและฉุกเฉิน',
      status: p.stage.label,
      doctor: doctor,
      // visit นี้มีข้อมูลรับเข้าเพิ่ม (เดิมอยู่หน้าประวัติ)
      extra: [
        ('สภาพผู้ป่วย', cell('สภาพผู้ป่วย')),
        ('มาจากหน่วยบริการ', cell('มาจากหน่วยบริการ')),
        ('ผู้นำส่ง', cell('ผู้นำส่ง')),
        ('เตียง', info['เตียง'] ?? '-'),
        ('พยาบาล', info['พยาบาล'] ?? '-'),
      ],
      cc: hv.first.cc,
      hpi: hv.first.hpi,
      vitals: vs,
      smoke: hx?['การสูบบุหรี่'] ?? '-',
      alcohol: hx?['การดื่มสุรา'] ?? '-',
      labs: labsOf(hv.first.date),
      rads: [
        for (final r in erTableFor(c.hn, ErTab.imaging).rows)
          _EmrRad(
            study: [r[1], if (r[2] != '-' && r[2].isNotEmpty) r[2]].join(' '),
            ordered: '${cell('วันที่เข้าห้องฉุกเฉิน')} ${hm(r[0])}',
            orderBy: doctor,
            reported: r[6] == '-' || r[6].isEmpty
                ? r[3]
                : '${cell('วันที่เข้าห้องฉุกเฉิน')} ${hm(r[6])}',
            reporter: r[5],
            info: c.cc,
            result: r[4],
          ),
      ],
      appts: appts,
    );
    final past = _emrPast[c.hn] ?? const <String, _EmrPastInfo>{};
    return [
      now,
      for (final v in hv.skip(1))
        if (past[v.date] case final x?)
          _EmrVisit(
            date: v.date,
            place: v.place,
            time: x.time,
            shift: x.shift,
            sender: x.sender,
            arrival: x.arrival,
            dept: x.dept,
            status: 'ตรวจแล้ว',
            doctor: x.doctor,
            cc: v.cc,
            hpi: v.hpi,
            vitals: x.vitals,
            smoke: x.smoke,
            alcohol: x.alcohol,
            labs: labsOf(v.date),
            rads: x.rads,
            appts: x.appts,
          ),
    ];
  }

  /// "12/08/2569" → "12 ส.ค. 69"
  String _emrShort(String d) {
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(d.trim());
    if (m == null) return d;
    final mon = int.parse(m.group(2)!);
    return '${int.parse(m.group(1)!)} ${_thMon[(mon - 1).clamp(0, 11)]} '
        '${m.group(3)!.substring(2)}';
  }

  /// แท็บ EMR (รวมหน้าประวัติเดิม): ข้อมูลผู้ป่วย + การรับบริการทุก visit (ตามหน้า EMR แอปเดิม)
  /// แถบ tab = visit ใหม่ → เก่า · การ์ด = ผู้รับบริการ การเข้ารับบริการ อาการสำคัญ
  /// สัญญาณชีพ ประวัติ ผลแล็บ ผลรังสีวิทยา นัดหมาย
  Widget _emrTab() {
    final c = _case;
    final p = _caseP();
    final visits = _emrVisits();
    final sel = (_emrSel[c.hn] ?? 0).clamp(0, visits.length - 1);
    final v = visits[sel];

    Widget tab(int i, _EmrVisit x) {
      final on = i == sel;
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() => _emrSel[c.hn] = i);
          },
          child: IntrinsicWidth(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // บรรทัดเดียวแบบ tab อื่น: วันที่ (หลัก) + จุดบริการ (รอง) baseline เดียวกัน
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 9.0),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: i == 0 ? 'visit นี้' : _emrShort(x.date),
                          style: _t(14.0,
                              color: on ? _blue : _ink2,
                              weight: on ? FontWeight.w600 : FontWeight.w500)),
                      TextSpan(
                          text: '  ${x.place}',
                          style: _t(12.5,
                              color: on ? _blue.withValues(alpha: 0.75) : _ink3,
                              weight: FontWeight.w500)),
                    ])),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: on ? _blue : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3.0)),
                    ),
                  ),
                ]),
          ),
        ),
      );
    }

    final tabs = Transform.translate(
      offset: const Offset(-12.0, 0.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (i, x) in visits.indexed) tab(i, x),
        ]),
      ),
    );

    String or(String s) => s.trim().isEmpty ? '-' : s;
    final allergic = c.allergies.isNotEmpty;
    final cards = <(String, List<(String, String, bool)>)>[
      // ข้อมูลผู้ป่วย (ไม่ขึ้นกับ visit) จากบัตรประชาชนและ HOSxP
      (
        'ผู้รับบริการ',
        [
          ('ชื่อ-นามสกุล', p.name, false),
          ('HN', c.hn, false),
          ('เพศ อายุ', '${c.sex} ${c.ageText}', false),
          ('หมู่เลือด', or(c.bloodGroup), false),
          ('สิทธิการรักษา', or(c.right), false),
          // แพ้ยาใช้ข้อมูลแพ้ยาของผู้ป่วยเสมอ (ไม่ใช่ค่าที่เลือกในซักประวัติแต่ละครั้ง)
          (
            'แพ้ยา / อาหาร',
            allergic ? c.allergies.join(', ') : 'ปฏิเสธการแพ้',
            allergic
          ),
          (
            'โรคประจำตัว',
            c.underlying.isEmpty ? 'ไม่มี' : c.underlying.join(', '),
            false
          ),
        ]
      ),
      (
        'การเข้ารับบริการ',
        [
          ('วันที่รับตัว', or(v.date), false),
          ('เวลา', or(v.time), false),
          ('เวร', or(v.shift), false),
          ('ผู้ส่งตรวจ', or(v.sender), false),
          ('ประเภทการมา', or(v.arrival), false),
          ('แผนก', or(v.dept), false),
          ('แพทย์ผู้ตรวจ', or(v.doctor), false),
          ('สถานะ', or(v.status), false),
          for (final (k, x) in v.extra) (k, or(x), false),
        ]
      ),
      (
        'อาการสำคัญ',
        [
          ('อาการสำคัญ', or(v.cc), false),
          ('ประวัติปัจจุบัน', or(v.hpi), false),
        ]
      ),
      ('สัญญาณชีพ', [for (final (k, x) in v.vitals) (k, or(x), _vsBad(k, x))]),
      (
        // แพ้ยาอยู่การ์ดผู้รับบริการแล้ว (ข้อมูลผู้ป่วย ไม่ใช่ของ visit)
        'บุหรี่และสุรา',
        [
          ('การสูบบุหรี่', or(v.smoke), false),
          ('การดื่มสุรา', or(v.alcohol), false),
        ]
      ),
      if (v.labs.isNotEmpty)
        (
          'ผลแล็บ',
          v.labs.any((l) => l.abnormal)
              ? [
                  for (final l in v.labs)
                    if (l.abnormal) (l.name, l.resultText, true)
                ]
              : [('สรุปผล', 'ปกติทุกรายการ (${v.labs.length} รายการ)', false)]
        ),
      for (final r in v.rads)
        (
          'ผลรังสีวิทยา',
          [
            ('รายการตรวจ', r.study, false),
            ('วัน-เวลาที่สั่ง', or(r.ordered), false),
            ('ผู้สั่ง', or(r.orderBy), false),
            if (r.position.isNotEmpty) ('ท่า', r.position, false),
            if (r.side.isNotEmpty) ('ด้าน', r.side, false),
            ('วัน-เวลาที่รายงาน', or(r.reported), false),
            ('ผู้รายงาน', or(r.reporter), false),
            ('Clinical information', or(r.info), false),
            if (r.dx.isNotEmpty) ('Clinical diagnosis', r.dx, false),
            ('ผลอ่าน', or(r.result), false),
          ]
        ),
      if (v.appts.isNotEmpty)
        (
          'นัดหมาย',
          [
            for (final (d, doc, note) in v.appts) ...[
              ('วันนัด', d, false),
              ('แพทย์', or(doc), false),
              ('รายละเอียด', or(note), false),
            ],
          ]
        ),
    ];
    return _clyInfoPage(
        'EMR', 'ข้อมูลผู้ป่วยและการรับบริการทุก visit', 'personal', cards,
        by: or(v.doctor),
        at: [_emrShort(v.date), if (v.time != '-') v.time].join(' '),
        below: tabs);
  }

  // ---------------------------------------------------------------- Progress

  TextEditingController get _progressCtl =>
      _progress.putIfAbsent(_case.hn, TextEditingController.new);

  /// แทรกข้อความที่ตำแหน่ง cursor (ไม่มี cursor = ต่อท้าย) แล้วเปิดแท็บ progress note
  void _progressInsert(String text) {
    final c = _progressCtl;
    final sel = c.selection;
    final at = sel.isValid ? sel.start : c.text.length;
    final before = c.text.substring(0, at);
    final after = c.text.substring(at);
    final pad = before.isEmpty || before.endsWith('\n') ? '' : '\n';
    final ins = '$pad$text\n';
    c.value = TextEditingValue(
      text: '$before$ins$after',
      selection: TextSelection.collapsed(offset: before.length + ins.length),
    );
    setState(() => _detailTab = 10);
  }

  String _vsText() {
    final c = _case;
    if (c.times.isEmpty) return 'V/S: —';
    String n(List<double> s) => s.isEmpty
        ? '-'
        : (s.last % 1 == 0 ? s.last.toStringAsFixed(0) : s.last.toString());
    return 'V/S (${c.times.last} น.): BP ${c.bp} mmHg · HR ${n(c.hr)} bpm · '
        'RR ${n(c.rr)} /min · BT ${n(c.bt)} °C · SpO₂ ${n(c.spo2)} %';
  }

  static const String _pnAiPrompt =
      'คุณเป็นผู้ช่วยแพทย์ห้องฉุกเฉิน อ่านข้อมูลเคสแล้วประเมินหัวข้อสำหรับเขียน progress note แบบ SOAP\n'
      'ตอบ JSON เท่านั้น: {"items":[{"sec":"S|O|A|P","title":"หัวข้อสั้น","text":"ข้อความพร้อมใส่ progress note 1-2 ประโยค"}]}\n'
      '- 5-8 หัวข้อ เรียง S → O → A → P\n'
      '- S = อาการ/ประวัติสำคัญ · O = V/S แนวโน้ม, lab/ภาพที่ผิดปกติ (ใส่ตัวเลขจริง) · '
      'A = ปัญหา/วินิจฉัย/ความรุนแรง · P = แผนที่ควรทำต่อ (ติดตาม lab, ยา, consult, disposition)\n'
      '- ใช้เฉพาะข้อมูลที่ให้มา ห้ามแต่งค่าใหม่ ภาษาไทยปนศัพท์แพทย์อังกฤษ กระชับ';

  /// ให้ AI อ่านเคสแล้วเสนอหัวข้อ progress note (แพทย์เลือกเองก่อนบันทึก)
  Future<void> _pnAiRun() async {
    final hn = _case.hn;
    if (_pnAiBusy.contains(hn)) return;
    setState(() {
      _pnAiBusy.add(hn);
      _pnAiErr.remove(hn);
    });
    try {
      final raw = await ErAi.chat([
        {'role': 'system', 'content': _pnAiPrompt},
        {
          'role': 'user',
          'content': '${_caseContext()}\n${_vsText()}\nงานที่ค้าง: '
              '${_allTasks.where((t) => !_taskDone.contains(t.title)).map((t) => t.title).join(', ')}'
        },
      ], fast: true, json: true, maxTokens: 900);
      final a = raw.indexOf('{'), b = raw.lastIndexOf('}');
      final j = jsonDecode(raw.substring(a, b + 1)) as Map<String, dynamic>;
      final items = [
        for (final e in (j['items'] as List? ?? const []))
          if (e is Map && (e['text'] ?? '').toString().trim().isNotEmpty)
            (
              sec: (e['sec'] ?? '').toString().trim(),
              title: (e['title'] ?? '').toString().trim(),
              text: (e['text'] ?? '').toString().trim(),
            ),
      ];
      if (!mounted) return;
      setState(() {
        _pnAi[hn] = items;
        // ค่าเริ่ม: เลือกทุกหัวข้อ แพทย์ติ๊กออกเฉพาะที่ไม่ต้องการ
        _pnAiSel[hn] = {for (var i = 0; i < items.length; i++) i};
        if (items.isEmpty) _pnAiErr[hn] = 'AI ไม่ได้เสนอหัวข้อ ลองใหม่อีกครั้ง';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _pnAiErr[hn] = 'ประเมินไม่สำเร็จ ลองใหม่อีกครั้ง');
      }
    } finally {
      if (mounted) setState(() => _pnAiBusy.remove(hn));
    }
  }

  /// ใส่หัวข้อที่เลือกลง progress note (จัดกลุ่มตาม S/O/A/P)
  void _pnAiInsert() {
    final hn = _case.hn;
    final items = _pnAi[hn] ?? const [];
    final sel = _pnAiSel[hn] ?? const {};
    final chosen = [
      for (var i = 0; i < items.length; i++)
        if (sel.contains(i)) items[i]
    ];
    if (chosen.isEmpty) return;
    final buf = StringBuffer();
    for (final sec in ['S', 'O', 'A', 'P']) {
      final g = chosen.where((e) => e.sec.toUpperCase().startsWith(sec));
      if (g.isEmpty) continue;
      buf.writeln('$sec:');
      for (final e in g) {
        buf.writeln('- ${e.text}');
      }
    }
    final other = chosen
        .where((e) =>
            !['S', 'O', 'A', 'P'].any((x) => e.sec.toUpperCase().startsWith(x)))
        .map((e) => '- ${e.text}');
    for (final l in other) {
      buf.writeln(l);
    }
    _progressInsert(buf.toString().trimRight());
    setState(() {
      _pnAi.remove(hn);
      _pnAiSel.remove(hn);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ใส่ ${chosen.length} หัวข้อลง progress note แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  /// การ์ด AI ประเมินเคส: ปุ่มเริ่ม · รายการหัวข้อให้ติ๊ก · ปุ่มบันทึก
  Widget _pnAiCard() {
    final hn = _case.hn;
    final busy = _pnAiBusy.contains(hn);
    final items = _pnAi[hn];
    final sel = _pnAiSel.putIfAbsent(hn, () => {});
    final err = _pnAiErr[hn];
    Widget secBadge(String s) => Container(
          width: 22.0,
          height: 22.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: _glossGrad(_blue),
            borderRadius: BorderRadius.circular(6.0),
          ),
          foregroundDecoration: const _InnerGloss(6.0, dark: true),
          child: Text(s.isEmpty ? '·' : s.substring(0, 1).toUpperCase(),
              style: _t(10.5, color: Colors.white, weight: FontWeight.w800)),
        );
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, size: 16.0, color: _blue),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text('AI ประเมินเคส',
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
          if (items != null && !busy)
            TextButton(
              onPressed: _pnAiRun,
              child: Text('ประเมินใหม่',
                  style: _t(10.5, color: _blue, weight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 6.0),
        if (busy)
          Row(children: [
            const SizedBox(
                width: 14.0,
                height: 14.0,
                child:
                    CircularProgressIndicator(strokeWidth: 2.0, color: _blue)),
            const SizedBox(width: 8.0),
            Text('AI กำลังอ่านเคส (V/S · Lab · ภาพ · ยา · งานค้าง)…',
                style: _t(11.0, color: _ink3)),
          ])
        else if (items == null) ...[
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(err, style: _t(10.5, color: _red)),
            ),
          _navBtn('ให้ AI ประเมินหัวข้อ', Icons.auto_awesome_rounded, _pnAiRun),
        ] else ...[
          for (var i = 0; i < items.length; i++)
            _Press(
              child: GestureDetector(
                onTap: () => setState(
                    () => sel.contains(i) ? sel.remove(i) : sel.add(i)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.only(bottom: 6.0),
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 10.0, 8.0),
                  decoration: BoxDecoration(
                    color: sel.contains(i)
                        ? _blue.withValues(alpha: 0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                        color: sel.contains(i)
                            ? _blue.withValues(alpha: 0.5)
                            : _line),
                  ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            sel.contains(i)
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            size: 19.0,
                            color: sel.contains(i) ? _blue : _g5),
                        const SizedBox(width: 8.0),
                        secBadge(items[i].sec),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(items[i].title,
                                    style: _t(11.5,
                                        color: _inkTitle,
                                        weight: FontWeight.w700)),
                                Text(items[i].text,
                                    style: _t(11.0, color: _ink, height: 1.4)),
                              ]),
                        ),
                      ]),
                ),
              ),
            ),
          const SizedBox(height: 4.0),
          Row(children: [
            Text('AI สรุปจากข้อมูลในเคส · ตรวจทานก่อนบันทึก',
                style: _t(9.5, color: _ink3)),
            const Spacer(),
          ]),
          const SizedBox(height: 6.0),
          _navBtn(
              sel.isEmpty
                  ? 'เลือกหัวข้อที่จะบันทึก'
                  : 'บันทึกลง progress note (${sel.length})',
              Icons.post_add_rounded,
              sel.isEmpty ? null : _pnAiInsert),
        ],
      ]),
    );
  }

  /// แท็บ Progress note: ช่องเขียน + ปุ่มแทรกข้อมูลของเคส + คัดลอกทั้งหมด
  Widget _progressTab() {
    final c = _case;
    final recs = erCcRecords(c);
    final bad = [
      for (final l in c.labs)
        if (l.abnormal) '${l.name} ${l.resultText}'
    ];
    final crs = [
      for (final l in c.labs)
        if (l.name == 'Cr' && l.isNumeric) l
    ];
    final inserts = <(String, String)>[
      ('CC', 'CC: ${recs.isEmpty ? c.cc : recs.last.text}'),
      ('HPI', 'HPI: ${c.hpi}'),
      (
        'ประวัติ',
        'U/D: ${c.underlying.isEmpty ? 'ไม่มี' : c.underlying.join(', ')}\n'
            'แพ้ยา/อาหาร: ${c.allergies.isEmpty ? 'ไม่มี' : c.allergies.join(', ')}'
      ),
      ('V/S ล่าสุด', _vsText()),
      ('Lab ผิดปกติ', 'Lab: ${bad.isEmpty ? 'ปกติ' : bad.join(', ')}'),
      if (crs.isNotEmpty)
        (
          'eGFR',
          'eGFR ${_egfr(crs.first.value, c.age, _female).round()} mL/min/1.73m² '
              '(${_ckdStage(_egfr(crs.first.value, c.age, _female))})'
        ),
      if (c.dx.isNotEmpty)
        ('วินิจฉัย', 'Dx: ${c.dx.map((d) => d.text).join(', ')}'),
    ];
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        _pnAiCard(),
        Container(
          padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
          decoration: _clyCardDeco,
          foregroundDecoration: const _InnerGloss(12.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text('Progress note',
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
              ),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _progressCtl.text));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('คัดลอก progress note แล้ว',
                          style: _t(12.0, color: Colors.white))));
                },
                icon: const Icon(Icons.copy_rounded, size: 15.0),
                label: Text('คัดลอกทั้งหมด',
                    style: _t(10.5, color: _blue, weight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 6.0),
            Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              for (final (label, text) in inserts)
                _chip('+ $label', false, () => _progressInsert(text)),
            ]),
            const SizedBox(height: 10.0),
            TextField(
              controller: _progressCtl,
              minLines: 14,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: _t(12.5, height: 1.5),
              decoration: InputDecoration(
                hintText: 'S: …\nO: …\nA: …\nP: …',
                hintStyle: _t(12.5, color: _ink3, height: 1.5),
                filled: true,
                fillColor: _panelSoft,
                contentPadding: const EdgeInsets.all(12.0),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: _line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: _blue)),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

/// EMR: visit ที่เลือกดูต่อ HN (0 = visit นี้)
final Map<String, int> _emrSel = {};

/// หนึ่ง visit ในหน้า EMR (ช่องตามหน้า EMR ของแอปเดิม)
class _EmrVisit {
  const _EmrVisit({
    required this.date,
    required this.place,
    required this.time,
    required this.shift,
    required this.sender,
    required this.arrival,
    required this.dept,
    required this.status,
    required this.doctor,
    required this.cc,
    required this.hpi,
    required this.vitals,
    required this.smoke,
    required this.alcohol,
    required this.labs,
    required this.rads,
    required this.appts,
    this.extra = const [],
  });
  final String date, place, time, shift, sender, arrival, dept, status, doctor;

  /// แถวเพิ่มท้ายการ์ดการเข้ารับบริการ (visit นี้: สภาพ ผู้นำส่ง เตียง พยาบาล)
  final List<(String, String)> extra;
  final String cc, hpi, smoke, alcohol;
  final List<(String, String)> vitals;
  final List<ErLab> labs;
  final List<_EmrRad> rads;

  /// (วันเวลานัด, แพทย์, รายละเอียด)
  final List<(String, String, String)> appts;
}

/// Radiology Report หนึ่งรายการ
class _EmrRad {
  const _EmrRad({
    required this.study,
    required this.ordered,
    required this.orderBy,
    required this.reported,
    required this.reporter,
    required this.info,
    required this.result,
    this.position = '',
    this.side = '',
    this.dx = '',
  });
  final String study, ordered, orderBy, position, side;
  final String reported, reporter, info, dx, result;
}

/// รายละเอียด visit ก่อนหน้า (นอกจาก CC/HPI/Lab ที่มีอยู่แล้ว)
class _EmrPastInfo {
  const _EmrPastInfo({
    required this.time,
    required this.shift,
    required this.sender,
    required this.arrival,
    required this.dept,
    required this.doctor,
    required this.vitals,
    required this.smoke,
    required this.alcohol,
    this.rads = const [],
    this.appts = const [],
  });
  final String time, shift, sender, arrival, dept, doctor, smoke, alcohol;
  final List<(String, String)> vitals;
  final List<_EmrRad> rads;
  final List<(String, String, String)> appts;
}

/// visit ก่อนหน้า (HN → วันที่) ข้อมูลจำลองตามหน้า EMR แอปเดิม · รอดึงจริงจาก HOSxP
const Map<String, Map<String, _EmrPastInfo>> _emrPast = {
  '670123469': {
    '12/08/2569': _EmrPastInfo(
      time: '10:00 น.',
      shift: 'ในเวลา',
      sender: 'พว. กัลยา ม.',
      arrival: 'มาเอง',
      dept: 'อายุรกรรม',
      doctor: 'นพ. ธีรภัทร อ.',
      vitals: [
        ('น้ำหนัก (kg)', '63.0'),
        ('ส่วนสูง (cm)', '164'),
        ('BMI', '23.4'),
        ('อุณหภูมิ (°C)', '36.6'),
        ('ความดัน (mmHg)', '138/86'),
        ('อัตราการเต้นชีพจร (/min)', '76'),
        ('อัตราการหายใจ (/min)', '16'),
        ('ออกซิเจนในเลือด (%)', '98'),
      ],
      smoke: 'ไม่เคยสูบ',
      alcohol: 'ดื่มนาน ๆ ครั้ง',
      rads: [
        _EmrRad(
          study: 'Chest X-ray PA upright',
          ordered: '12/08/2569 10:20 น.',
          orderBy: 'นพ. ธีรภัทร อ.',
          position: 'PA upright',
          side: '-',
          reported: '12/08/2569 11:05 น.',
          reporter: 'นพ. รังสี ส.',
          info: 'ความดันโลหิตสูง ตรวจติดตามประจำปี',
          dx: 'Essential hypertension',
          result: 'Normal heart size. No active pulmonary lesion.',
        ),
      ],
      appts: [
        (
          '11 พ.ย. 2569 09:00 น.',
          'นพ. ธีรภัทร อ.',
          'ติดตามความดันโลหิตสูง นำยาโรคประจำตัวทั้งหมดมาด้วย'
        ),
      ],
    ),
    '03/05/2569': _EmrPastInfo(
      time: '08:30 น.',
      shift: 'ในเวลา',
      sender: 'พว. สุดา ร.',
      arrival: 'มาเอง',
      dept: 'ตรวจสุขภาพ',
      doctor: 'พญ. ศิริพร ก.',
      vitals: [
        ('น้ำหนัก (kg)', '62.5'),
        ('ส่วนสูง (cm)', '164'),
        ('BMI', '23.2'),
        ('อุณหภูมิ (°C)', '36.5'),
        ('ความดัน (mmHg)', '132/84'),
        ('อัตราการเต้นชีพจร (/min)', '72'),
        ('อัตราการหายใจ (/min)', '16'),
        ('ออกซิเจนในเลือด (%)', '99'),
      ],
      smoke: 'ไม่เคยสูบ',
      alcohol: 'ดื่มนาน ๆ ครั้ง',
      rads: [
        _EmrRad(
          study: 'EKG 12 leads',
          ordered: '03/05/2569 08:45 น.',
          orderBy: 'พญ. ศิริพร ก.',
          reported: '03/05/2569 09:10 น.',
          reporter: 'พญ. ศิริพร ก.',
          info: 'ตรวจสุขภาพประจำปี',
          result: 'Normal sinus rhythm, rate 72/min. No ST-T change.',
        ),
      ],
    ),
  },
};
