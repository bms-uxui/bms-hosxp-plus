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

  /// แท็บ EMR: ทุก visit ใหม่ → เก่า · CC · HPI · Lab ผิดปกติ · ส่งเข้า progress note
  Widget _emrTab() {
    final hv = erHpiVisits(_case);
    final lv = erLabVisits(_case);
    List<ErLab> labsOf(String date) => [
          for (final v in lv)
            if (v.date == date)
              for (final l in v.labs)
                if (l.abnormal) l
        ];
    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        for (var i = 0; i < hv.length; i++) ...[
          if (i > 0) const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 8.0, 10.0),
            decoration: _clyCardDeco,
            foregroundDecoration: const _InnerGloss(12.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(hv[i].date,
                    style:
                        _num(12.5, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(i == 0 ? 'ER · visit นี้' : hv[i].place,
                      style: _t(10.5,
                          color: i == 0 ? _blue : _ink3,
                          weight: FontWeight.w600)),
                ),
                _copyBtn('visit ${hv[i].date}',
                    () => 'CC (${hv[i].date}): ${hv[i].cc}\nHPI: ${hv[i].hpi}'),
                TextButton.icon(
                  onPressed: () => _progressInsert(
                      'CC (${hv[i].date}): ${hv[i].cc}\nHPI: ${hv[i].hpi}'),
                  icon: const Icon(Icons.post_add_rounded, size: 15.0),
                  label: Text('ใส่ progress note',
                      style: _t(10.0, color: _blue, weight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 4.0),
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: 'CC  ',
                    style: _t(10.5, color: _ink2, weight: FontWeight.w700)),
                TextSpan(
                    text: hv[i].cc,
                    style: _t(12.0, color: _inkTitle, weight: FontWeight.w600)),
              ])),
              const SizedBox(height: 3.0),
              Text(hv[i].hpi.isEmpty ? '—' : hv[i].hpi,
                  style: _t(11.5, color: _ink, height: 1.45)),
              if (labsOf(hv[i].date).isNotEmpty) ...[
                const SizedBox(height: 6.0),
                Wrap(spacing: 6.0, runSpacing: 4.0, children: [
                  for (final l in labsOf(hv[i].date))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: _red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text('${l.name} ${l.resultText}',
                          style:
                              _t(10.0, color: _red, weight: FontWeight.w600)),
                    ),
                ]),
              ],
            ]),
          ),
        ],
      ],
    );
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
