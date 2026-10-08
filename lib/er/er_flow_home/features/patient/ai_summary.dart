// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

List<String> _strList(Object? v) => [
      for (final x in (v is List ? v : const []))
        if (x is String && x.trim().isNotEmpty) x
    ];

Color _sevColor(Object? s) => switch (s) {
      'critical' => _dRed,
      'urgent' => _dAccent,
      _ => _dAccent,
    };

String _sevLabel(Object? s) => switch (s) {
      'critical' => 'วิกฤต',
      'urgent' => 'เร่งด่วน',
      _ => 'คงที่',
    };

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientAiSummaryState on State<ErFlowHomeWidget> {
  /// หน้าสรุปเคสด้วย AI (ทับหน้ารายละเอียด หุ่นเป็นเอกซเรย์พื้นมืด)
  bool _summaryOpen = false;
  bool _summaryBusy = false;
  String? _summaryErr;
  final Map<String, Map<String, dynamic>> _summaryCache = {};

  /// AI Overview บนภาพรวม: กำลังสรุปของ HN ไหน (กันเรียกซ้ำ) · ขยายดูต่อ
  final Set<String> _aovLoading = {};
  final Set<String> _aovOpen = {};

  /// AI Overview ที่พิมพ์ข้อความจบแล้ว (เปิดซ้ำไม่พิมพ์ใหม่)
  final Set<String> _aovTyped = {};
}

extension _FeaturesPatientAiSummaryPart on _ErFlowHomeWidgetState {
  // ------------------------------------------------ AI Overview (แบบ Google Search)
  /// เข้าเคสครั้งแรก: skeleton ระหว่างรวมข้อมูล แล้วสรุปสั้น + ที่มาจากแต่ละแท็บ
  /// ใช้ผลชุดเดียวกับหน้าสรุปเคส (AI · ไม่ได้ = สรุปจากข้อมูลในระบบ)
  /// คีย์แคชของ AI Overview: แยกตามบทบาท (แพทย์/พยาบาลสรุปคนละมุม)
  /// เคสที่กดขอ AI Overview แล้วในรอบใช้งานนี้ (key = _aovKey)
  static final Set<String> _aovAsked = {};

  /// ประวัติการสรุปของแต่ละ key: (เวลา, ผล) เก่าไปใหม่ · เลือกดูย้อนหลังได้จากเมนู ⋮
  static final Map<String, List<(DateTime, Map<String, dynamic>)>> _aovHist =
      {};

  String _aovKey() => '${_caseP().hn}|${ErSession.instance.role.name}|v4';

  /// มุมมองตามบทบาท ใส่ใน prompt
  String _aovRoleBrief() => switch (ErSession.instance.role) {
        ErRole.doctor =>
          'ผู้อ่านคือแพทย์ ER: เน้นปัญหา/วินิจฉัยแยกโรค ผลแล็บ-ภาพถ่ายที่ผิดปกติ สิ่งที่ต้องตัดสินใจ/สั่งต่อ และ disposition',
        ErRole.nurse =>
          'ผู้อ่านคือพยาบาล ER: headline/summary ต้องเริ่มจาก "คำสั่งแพทย์ที่ต้องทำตอนนี้" (ด่วนก่อน ครบรอบก่อน) '
              'แล้วจึงสิ่งที่ต้องเฝ้าระวังจากสัญญาณชีพ แพ้ยา ตกเตียง ปวด ไม่ต้องอธิบายพยาธิสภาพหรือวินิจฉัยแยกโรค',
        ErRole.triage =>
          'ผู้อ่านคือพยาบาลคัดกรอง: เน้นอาการสำคัญ red flag ระดับ ESI และสิ่งที่ต้องส่งต่อทันที',
      };

  /// เข้าเคสครั้งแรก: skeleton ระหว่างรวมข้อมูล แล้วสรุปตามบทบาท + บล็อก UI ตามเคส
  Future<void> _aovLoad() async {
    final key = _aovKey();
    if (_summaryCache.containsKey(key) || _aovLoading.contains(key)) return;
    _aovLoading.add(key);
    final t0 = DateTime.now();
    Map<String, dynamic>? data;
    try {
      final out = await ErAi.chat([
        {
          'role': 'system',
          'content': 'สรุปเคสผู้ป่วยห้องฉุกเฉินให้อ่านใน 10 วินาที ใช้เฉพาะข้อมูลที่ให้มา ห้ามแต่ง\n'
              '${_aovRoleBrief()}\n'
              'ตอบ JSON: {"headline":"<1 บรรทัด>","summary":"<2-3 ประโยค>","red_flags":["..."],"pending":["..."],'
              '"ui":[<บล็อก 1-2 ชิ้นที่ช่วยผู้อ่านบทบาทนี้มากที่สุด>],'
              '"vs_notes":{"hr":"<ความหมายทางคลินิกของแนวโน้ม 1 ประโยค>","bp":"...","spo2":"...","rr":"...","bt":"..."}}\n'
              'vs_notes ใส่เฉพาะค่าที่ผิดปกติหรือเปลี่ยนชัด อธิบายว่าแปลว่าอะไร/ต้องทำอะไร ไม่ต้องทวนตัวเลข\n'
              'เลือกบล็อกตามเคส เช่น ช็อก = vitals [bp,hr] · sepsis = checklist bundle + timer 60 นาที · '
              'stroke = timer จากเวลาเริ่มอาการ · trauma = imaging · แพ้ยา = alert\n$erUiCatalogPrompt',
        },
        {
          'role': 'user',
          'content': 'ข้อมูลเคส:\n${_caseContext()}'
              '${ErSession.instance.role == ErRole.doctor ? '' : '\nคำสั่งแพทย์ที่ยังไม่ได้ทำ:\n${_aovPendingOrders().map((t) => '- ${t.title}${t.urgent ? ' (ด่วน)' : ''} สั่ง ${t.time} ${t.detail}').join('\n')}'}',
        },
      ], json: true, fast: true, maxTokens: 800, temperature: 0.2);
      data = ErAi.extractJson(out);
    } catch (_) {}
    final left = 900 - DateTime.now().difference(t0).inMilliseconds;
    if (left > 0) await Future.delayed(Duration(milliseconds: left));
    if (!mounted) return;
    setState(() {
      _aovLoading.remove(key);
      if (!_summaryCache.containsKey(key)) {
        final r = data ?? _fallbackSummary();
        _summaryCache[key] = r;
        _aovHist.putIfAbsent(key, () => []).add((DateTime.now(), r));
      }
    });
  }

  /// บล็อก UI ของ AI Overview: ของ AI ถ้ามี · ไม่มี = เลือกจากข้อมูลเคสตามบทบาท
  List<ErUiBlock> _aovBlocks(Map<String, dynamic> data) {
    final ai = erParseUi(data['ui'])
        .where((b) => const {
              ErUiType.vitals,
              ErUiType.labs,
              ErUiType.imaging,
              ErUiType.alert,
              ErUiType.checklist,
              ErUiType.timer,
            }.contains(b.type))
        .take(2)
        .toList();
    // มีค่าผิดปกติเสมอ = บล็อกสัญญาณชีพขึ้นก่อน (AI ไม่ได้เลือกก็ใส่ให้)
    final vsBad = _caseVitals().any((v) => v.color == _red);
    if (vsBad && !ai.any((b) => b.type == ErUiType.vitals)) {
      ai.insert(0, const ErUiBlock(ErUiType.vitals, {}));
    }
    if (ai.isNotEmpty) return ai.take(3).toList();
    final c = _case;
    final doctor = ErSession.instance.role == ErRole.doctor;
    final shock = c.sbp.isNotEmpty && c.sbp.last < 90;
    final text = '${c.cc} ${c.dx.map((d) => d.text).join(' ')}'.toLowerCase();
    return [
      if (shock)
        const ErUiBlock(ErUiType.vitals, {
          'keys': ['bp', 'hr', 'spo2'],
          'note': 'ความดันต่ำ เฝ้าระวังภาวะช็อก',
        }),
      if (text.contains('sepsis') || text.contains('ติดเชื้อ'))
        ErUiBlock(ErUiType.checklist, {
          'title': 'Sepsis bundle 1 ชม.',
          'items': const [
            'เจาะ lactate',
            'H/C ก่อนให้ยา',
            'ยาปฏิชีวนะ',
            'IV fluid 30 mL/kg'
          ],
        }),
      if (doctor && c.imaging.isNotEmpty)
        ErUiBlock(ErUiType.imaging, {
          'names': [for (final i in c.imaging.take(3)) i.name],
        }),
      if (!doctor && c.allergies.isNotEmpty)
        ErUiBlock(ErUiType.alert, {
          'level': 'critical',
          'title': 'แพ้ยา',
          'text': c.allergies.join(', '),
        }),
    ].take(2).toList();
  }

  /// ค่าที่ผิดปกติหรือน่าจับตา (เปลี่ยนจากแรกรับ ≥ 15%) ตาม keys ของบล็อก
  List<ErVital> _aovWatch(List<String> keys) {
    const map = {
      'hr': 'HR',
      'bp': 'BP',
      'spo2': 'SpO₂',
      'rr': 'RR',
      'bt': 'BT',
      'pr': 'Pulse',
    };
    final want = [
      for (final k in keys)
        if (map[k.toLowerCase()] != null) map[k.toLowerCase()]!
    ];
    final all = _caseVitals();
    final vs = [
      for (final l in want.isEmpty ? map.values : want)
        ...all.where((v) => v.label == l),
    ];
    bool watch(ErVital v) {
      if (v.color == _red) return true;
      final s0 = v.series.isEmpty ? 0.0 : v.series.first;
      final s1 = v.series.isEmpty ? 0.0 : v.series.last;
      return s0 != 0 && ((s1 - s0).abs() / s0) >= 0.15;
    }

    return vs.where(watch).toList();
  }

  /// บล็อกสัญญาณชีพใน AI Overview: ไม่แสดงการ์ดซ้ำกับ section สัญญาณชีพ
  /// = ข้อความตีความ + ชิปอ้างอิง (แตะ = เลื่อนไปการ์ดค่านั้นแล้วไฮไลต์)
  Widget _aovVitals(ErUiBlock b, Map<String, dynamic> data) {
    final vs = _aovWatch(b.strs('keys'));
    if (vs.isEmpty) return const SizedBox.shrink();
    final note = b.str('note');
    // เทียบกับการวัดครั้งก่อน: ลูกศร + ผลต่าง + ค่าครั้งก่อน
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    Widget chip(ErVital v) {
      final n = v.series.length;
      final prev = n > 1 ? v.series[n - 2] : null;
      final d = prev == null ? 0.0 : v.series.last - prev;
      final flat = prev == null || d.abs() < 0.05;
      // BP: ค่าครั้งก่อนแสดงคู่ตัวบน/ล่าง
      final dbp = _case.dbp;
      final prevText = prev == null
          ? null
          : v.unit == 'mmHg' && dbp.length > 1
              ? '${f(prev)}/${f(dbp[dbp.length - 2])}'
              : f(prev);
      // ดีขึ้น = เข้าใกล้ค่ากลางปกติกว่าครั้งก่อน (ลูกศรเขียว) · แย่ลง = แดง
      const mid = {
        'HR': 80.0,
        'Pulse': 80.0,
        'BP': 120.0,
        'SpO₂': 98.0,
        'RR': 16.0,
        'BT': 37.0,
      };
      final m = mid[v.label];
      final better = prev != null &&
          m != null &&
          (v.series.last - m).abs() < (prev - m).abs();
      return _aovChip(v.label == 'Pulse' ? 'PR' : v.label,
          v.display ?? _vsValue(v, n - 1, null),
          trendInk: flat ? null : (better ? _green : _red),
          unit: v.unit,
          bad: v.color == _red,
          up: flat ? null : d > 0,
          delta: flat ? null : f(d.abs()),
          from: flat ? null : prevText,
          // วัดล่าสุดเมื่อไหร่ (เทียบเวลาปัจจุบัน)
          when: _case.times.isEmpty ? null : _ago(_case.times.last),
          onTap: () => _vsJump(v.label));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (note.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child:
              Text(note, style: _t(13.0, color: _ink, weight: FontWeight.w500)),
        ),
      Wrap(spacing: 6.0, runSpacing: 6.0, children: [
        for (final v in vs) chip(v),
      ]),
      // ความหมายของแต่ละค่าจาก AI (vs_notes) ใต้ชิป
      for (final v in vs)
        if (_aovVsNote(data, v) case final n?)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: '${v.label}  ',
                    style: _t(12.5,
                        color: v.color == _red ? _red : _inkTitle,
                        weight: FontWeight.w700)),
                TextSpan(text: n),
              ]),
              style:
                  _t(12.5, color: _ink, weight: FontWeight.w500, height: 1.45),
            ),
          ),
    ]);
  }

  /// ชิปอ้างอิงใน AI Overview: ชื่อ + ค่า + ลูกศร (up null = ไม่มีลูกศร)
  /// แตะ = เลื่อนไปการ์ดต้นทางแล้วไฮไลต์ · ผิดปกติ = ค่าสีแดง
  Widget _aovChip(String name, String value,
      {required bool bad,
      bool? up,
      String? unit,
      Color? trendInk,
      String? delta,
      String? from,
      String? when,
      String? flag,
      required VoidCallback onTap}) {
    final ink = bad ? _red : _blue;
    return _Press(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(name,
                style: _t(12.0, color: _inkTitle, weight: FontWeight.w600)),
            const SizedBox(width: 4.0),
            Text(value, style: _num(12.0, color: ink, weight: FontWeight.w700)),
            if (unit != null && unit.isNotEmpty)
              Text(' $unit',
                  style: _t(10.5, color: _ink3, weight: FontWeight.w500)),
            if (up != null) const SizedBox(width: 6.0),
            if (up != null)
              Icon(
                  up
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14.0,
                  color: trendInk ?? ink),
            // ผลต่างจากครั้งก่อน + ค่าครั้งก่อน
            if (delta != null)
              Text(delta,
                  style: _num(11.5,
                      color: trendInk ?? ink, weight: FontWeight.w700)),
            if (from != null)
              Text('  จาก $from',
                  style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
            if (when != null)
              Text('  $when',
                  style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
            // แล็บ: ป้าย L/H แบบการ์ดผลแล็บ
            if (flag != null) ...[
              const SizedBox(width: 4.0),
              Container(
                constraints: const BoxConstraints(minWidth: 15.0),
                height: 15.0,
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: _glossGrad(_red),
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: _glossLift(_red),
                ),
                foregroundDecoration: const _InnerGloss(4.0, dark: true),
                child: Text(flag,
                    style:
                        _t(8.5, color: Colors.white, weight: FontWeight.w800)),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  /// หน่วยของแล็บตามชื่อ (ErLab ไม่มีหน่วย · ตรงกับตารางผลแล็บ)
  static String _labUnit(String name) {
    final n = name.toLowerCase();
    const m = {
      'hb': 'g/dL',
      'hct': '%',
      'wbc': '×10³/µL',
      'plt': '×10³/µL',
      'na': 'mmol/L',
      'k': 'mmol/L',
      'cl': 'mmol/L',
      'hco': 'mmol/L',
      'bun': 'mg/dL',
      'cr': 'mg/dL',
      'egfr': 'mL/min',
      'lactate': 'mmol/L',
      'dtx': 'mg/dL',
      'glucose': 'mg/dL',
      'trop': 'ng/L',
      'inr': '',
    };
    for (final e in m.entries) {
      if (n == e.key || n.startsWith('${e.key} ') || n.startsWith(e.key)) {
        return e.value;
      }
    }
    return '';
  }

  /// บล็อกแล็บใน AI Overview: ไม่ซ้ำการ์ดผลแล็บ = หัวข้อ + ชิปค่าผิดปกติ + หมายเหตุ
  Widget _aovLabs(ErUiBlock b) {
    final want = b.strs('names').map((e) => e.toLowerCase()).toList();
    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    final labs = [
      for (final l in _case.labs)
        if (l.isNumeric &&
            (want.isEmpty
                ? l.abnormal
                : want.any((w) =>
                    l.name.toLowerCase().contains(w) ||
                    w.contains(l.name.toLowerCase()))))
          l
    ];
    if (labs.isEmpty) return const SizedBox.shrink();
    final note = b.str('note');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(b.str('title', 'ผลแล็บที่ต้องดู'),
          style: _t(13.0, color: _ink, weight: FontWeight.w500)),
      const SizedBox(height: 8.0),
      Wrap(spacing: 6.0, runSpacing: 6.0, children: [
        for (final l in labs)
          _aovChip(l.name, f(l.value),
              unit: _labUnit(l.name),
              bad: l.abnormal,
              // สูง/ต่ำกว่าเกณฑ์ = ป้าย H/L แบบการ์ดผลแล็บ
              flag: l.value > l.hi ? 'H' : (l.value < l.lo ? 'L' : null),
              onTap: () => _vsJump('lab:${l.name}')),
      ]),
      if (note.isNotEmpty) ...[
        const SizedBox(height: 6.0),
        Text(note, style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
      ],
    ]);
  }

  /// แนวโน้มของค่า: "112 bpm ลดลงจาก 128 (แรกรับ) ยังสูงกว่าเกณฑ์"
  String _aovVsTrend(ErVital v) {
    if (v.series.isEmpty) return '';
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    final a = v.series.first, b = v.series.last;
    final now = v.display ?? f(b);
    final dir = (b - a).abs() < 0.05
        ? 'คงที่'
        : (b > a ? 'เพิ่มขึ้นจาก ${f(a)}' : 'ลดลงจาก ${f(a)}');
    final state = v.color == _red ? ' ยังผิดปกติ' : ' อยู่ในเกณฑ์';
    return '$now ${v.unit} $dir (แรกรับ)$state';
  }

  /// ความหมายของค่าจาก AI (vs_notes) · ไม่มี = null
  String? _aovVsNote(Map<String, dynamic> data, ErVital v) {
    final m = data['vs_notes'];
    if (m is! Map) return null;
    const keys = {
      'HR': 'hr',
      'Pulse': 'hr',
      'BP': 'bp',
      'SpO₂': 'spo2',
      'RR': 'rr',
      'BT': 'bt',
    };
    final t = m[keys[v.label]];
    return t is String && t.trim().isNotEmpty ? t.trim() : null;
  }

  /// คำสั่งแพทย์ที่ยังไม่ได้ทำ เรียงด่วน/เวลา (ชุดเดียวกับการ์ดคำสั่งแพทย์)
  List<_Task> _aovPendingOrders() => [
        for (final t in _sortTasks(_allTasks))
          if (!_taskDone.contains(t.title)) t
      ];

  /// พยาบาล: บล็อก "ต้องทำตอนนี้" จากคำสั่งแพทย์ (ด่วนก่อน) แตะ = รับคำสั่ง
  Widget _aovOrdersBlock() {
    final list = _aovPendingOrders();
    if (list.isEmpty) return const SizedBox.shrink();
    final urgent = list.where((t) => t.urgent).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 8.0, 6.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.assignment_outlined, size: 16.0, color: _blue),
          const SizedBox(width: 6.0),
          Text('คำสั่งแพทย์ที่ต้องทำ ${list.length} รายการ',
              style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
          if (urgent > 0) ...[
            const SizedBox(width: 6.0),
            Text('ด่วน $urgent',
                style: _t(12.0, color: _red, weight: FontWeight.w700)),
          ],
        ]),
        const SizedBox(height: 4.0),
        for (final t in list.take(4))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(12.5,
                              color: t.urgent ? _red : _inkTitle,
                              weight: FontWeight.w600)),
                      Text('สั่ง ${_clock(t.time)}${t.urgent ? '  ด่วน' : ''}',
                          style: _t(11.0,
                              color: t.urgent ? _red : _ink3,
                              weight: FontWeight.w500)),
                    ]),
              ),
              _Press(
                child: GestureDetector(
                  onTap: () => _taskAcceptSheet(t),
                  child: Container(
                    height: 30.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Text('รับคำสั่ง',
                        style: _t(12.0, color: _blue, weight: FontWeight.w600)),
                  ),
                ),
              ),
            ]),
          ),
        if (list.length > 4)
          TextButton(
            onPressed: () => setState(() => _detailTab = 3),
            child: Text('ดูทั้งหมด ${list.length} รายการ ›',
                style: _t(12.0, color: _blue, weight: FontWeight.w600)),
          ),
      ]),
    );
  }

  /// เมนู ⋮ ของ AI Overview: สรุปใหม่ + ประวัติการสรุป (แตะ = ดูผลครั้งนั้น)
  Widget _aovMenu(String key) {
    final cur = _summaryCache[key];
    // ผลที่มีก่อนเริ่มเก็บประวัติ (เช่นแคชจากหน้าสรุปเคส) = ใส่เป็นรายการแรก
    final hist = _aovHist.putIfAbsent(key, () => []);
    if (cur != null && !hist.any((h) => identical(h.$2, cur))) {
      hist.add((DateTime.now(), cur));
    }
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} น.';
    return PopupMenuButton<int>(
      tooltip: 'ตัวเลือก AI Overview',
      position: PopupMenuPosition.under,
      color: _panel,
      // ปุ่มเล็ก 32 (icon: ของ PopupMenuButton กินสูง 48 ทำหัวการ์ดสูงขึ้น)
      child: const SizedBox(
        width: 32.0,
        height: 32.0,
        child: Icon(Icons.more_vert_rounded, size: 20.0, color: _ink2),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      onSelected: (i) => setState(() {
        if (i < 0) {
          // สรุปใหม่: ล้างผลปัจจุบัน แล้วให้ build เรียก AI ใหม่ (skeleton + พิมพ์ใหม่)
          _summaryCache.remove(key);
          _aovTyped.remove(key);
        } else {
          _summaryCache[key] = hist[i].$2;
          _aovTyped.add(key);
        }
      }),
      itemBuilder: (_) => [
        PopupMenuItem<int>(
          value: -1,
          height: 44.0,
          child: Row(children: [
            const Icon(Icons.refresh_rounded, size: 18.0, color: _blue),
            const SizedBox(width: 10.0),
            Text('สรุปใหม่',
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
          ]),
        ),
        if (hist.isNotEmpty) ...[
          const PopupMenuDivider(),
          PopupMenuItem<int>(
            enabled: false,
            height: 28.0,
            child: Text('ประวัติการสรุป',
                style: _t(11.5, color: _ink3, weight: FontWeight.w600)),
          ),
          for (var i = hist.length - 1; i >= 0; i--)
            PopupMenuItem<int>(
              value: i,
              height: 40.0,
              child: Row(children: [
                SizedBox(
                  width: 18.0,
                  child: identical(hist[i].$2, cur)
                      ? const Icon(Icons.check_rounded,
                          size: 16.0, color: _blue)
                      : null,
                ),
                const SizedBox(width: 10.0),
                Text('สรุปเมื่อ ${hm(hist[i].$1)}',
                    style: _t(13.0,
                        color: _inkTitle,
                        weight: identical(hist[i].$2, cur)
                            ? FontWeight.w700
                            : FontWeight.w500)),
                if (i == hist.length - 1) ...[
                  const SizedBox(width: 6.0),
                  Text('ล่าสุด',
                      style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
                ],
              ]),
            ),
        ],
      ],
    );
  }

  /// ปุ่มขอ AI Overview: การ์ดพื้นไล่ฟ้าอ่อนแบบการ์ด AI Overview
  /// Dr.Note 3D (ท่า generate) อยู่ในการ์ดเต็มตัว ไม่ล้นขอบ · ปุ่มหลักชิดขวา
  Widget _aovAskBtn(String key) {
    void ask() {
      HapticFeedback.selectionClick();
      setState(() => _aovAsked.add(key));
    }

    return _Press(
      child: GestureDetector(
        onTap: ask,
        child: Container(
          padding: const EdgeInsets.fromLTRB(4.0, 2.0, 14.0, 2.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEEF3FE), Color(0xFFF7F4FD)],
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(children: [
            // กรอบ 4:3 ตามที่ฉากจัดตัว · ย่อ 0.8 ให้เห็นเต็มตัว (หัว/เท้าไม่ขาด)
            const SizedBox(
              width: 112.0,
              height: 84.0,
              child: IgnorePointer(
                child: RepaintBoundary(
                    child: ErDrNote3D(
                        mode: ErDrNoteMode.generate,
                        intro: true,
                        pose: (-0.35, 0.42, 0.24, 0.8))),
              ),
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Overview',
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                    const SizedBox(height: 2.0),
                    Text(
                        'ให้ Dr.Note สรุปเคสนี้สำหรับ${ErSession.instance.user?.roleLabel ?? 'แพทย์'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
                  ]),
            ),
            const SizedBox(width: 12.0),
            Container(
              height: 40.0,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text('สรุปเคส',
                  style:
                      _t(13.5, color: Colors.white, weight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _aiOverview() {
    final hn = _aovKey();
    // ยังไม่ได้ขอ = ปุ่มให้กดสรุป (ไม่เรียก AI เองตอนเปิดเคส)
    if (!_aovAsked.contains(hn)) return _aovAskBtn(hn);
    final data = _summaryCache[hn];
    if (data == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _aovLoad());
    }
    final c = _case;
    // ที่มา: แท็บที่มีข้อมูลจริงในเคสนี้ (แตะ = ไปแท็บนั้น)
    final sources = <(IconData, String, int?)>[
      (Icons.chat_bubble_outline_rounded, 'อาการสำคัญ', null),
      (Icons.monitor_heart_outlined, 'สัญญาณชีพ', 4),
      if (c.labs.isNotEmpty) (Icons.science_outlined, 'Lab', 6),
      if (c.imaging.isNotEmpty) (Icons.image_outlined, 'X-ray', _xrayTab),
      if (c.meds.isNotEmpty) (Icons.medication_outlined, 'ยา', 5),
      (Icons.assignment_outlined, 'คำสั่งแพทย์', 3),
    ];
    Widget chip((IconData, String, int?) src) => _Press(
          child: GestureDetector(
            onTap: src.$3 == null
                ? null
                : () => setState(() {
                      _tabDir = 1;
                      _detailTab = src.$3!;
                    }),
            child: Container(
              height: 30.0,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(src.$1, size: 15.0, color: _ink2),
                const SizedBox(width: 5.0),
                Text(src.$2,
                    style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
              ]),
            ),
          ),
        );
    Widget bar(double w) => Container(
          height: 12.0,
          margin: const EdgeInsets.only(bottom: 8.0),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: w,
            child: const _AovShimmer(),
          ),
        );
    final open = _aovOpen.contains(hn);
    final typed = _aovTyped.contains(hn);
    final flags = _strList(data?['red_flags']);
    final pending = _strList(data?['pending']);
    void toggle() =>
        setState(() => open ? _aovOpen.remove(hn) : _aovOpen.add(hn));
    // แตะที่ใดก็ได้บนการ์ด = ขยาย/ยุบ (ปุ่มข้างในยังทำงานของมันเอง)
    return Container(
        decoration: BoxDecoration(
          // พื้นไล่ฟ้าอ่อนแบบ AI Overview
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEEF3FE), Color(0xFFF7F4FD)],
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Material(
            type: MaterialType.transparency,
            child: InkWell(
                borderRadius: BorderRadius.circular(16.0),
                // ไม่มี ripple: แตะการ์ด = ขยาย/ยุบเฉย ๆ
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: data == null ? null : toggle,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 4.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 18.0, color: _blue),
                          const SizedBox(width: 8.0),
                          Text('AI Overview',
                              style: _t(15.0,
                                  color: _inkTitle, weight: FontWeight.w600)),
                          const SizedBox(width: 8.0),
                          // สรุปสำหรับบทบาทไหน
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: _blue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text(
                                'สำหรับ${ErSession.instance.user?.roleLabel ?? 'แพทย์'}',
                                style: _t(10.5,
                                    color: _blue, weight: FontWeight.w600)),
                          ),
                          const Spacer(),
                          // แหล่งข้อมูลซ้อนกันแบบ Google: กำลังสรุป = ไอคอนแท็บทยอยเด้งเข้ามาทีละอัน
                          _AovSources(
                            icons: [for (final src in sources) src.$1],
                            loading: data == null,
                            ink: _blue,
                          ),
                          if (data != null) _aovMenu(hn),
                        ]),
                        const SizedBox(height: 8.0),
                        // ยุบ = เห็นบางส่วนแล้วจางลงล่าง (แบบ Google) · ขยาย = เต็ม
                        AnimatedSize(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: open || data == null
                                    ? double.infinity
                                    : 170.0),
                            child: ShaderMask(
                              blendMode: BlendMode.dstIn,
                              shaderCallback: (r) => LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: open || data == null
                                    ? const [Colors.black, Colors.black]
                                    : const [
                                        Colors.black,
                                        Colors.black,
                                        Colors.transparent
                                      ],
                                stops: open || data == null
                                    ? null
                                    : const [0.0, 0.78, 1.0],
                              ).createShader(r),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 320),
                                  child: data == null
                                      ? Column(
                                          key: const ValueKey('sk'),
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [bar(0.92), bar(0.6)])
                                      : Column(
                                          key: const ValueKey('ok'),
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                              // ข้อความพิมพ์ทีละตัวแบบ AI · หัวก่อน แล้วสรุป · จบแล้วบล็อกค่อยลอยขึ้นทีละชิ้น
                                              if ((data['headline'] ?? '')
                                                  .toString()
                                                  .isNotEmpty)
                                                _TypeText('${data['headline']}',
                                                    key: ValueKey('h$hn'),
                                                    animate: !typed,
                                                    style: _t(14.5,
                                                        color: _inkTitle,
                                                        weight:
                                                            FontWeight.w700)),
                                              const SizedBox(height: 4.0),
                                              _TypeText(
                                                  '${data['summary'] ?? ''}',
                                                  key: ValueKey('s$hn'),
                                                  animate: !typed,
                                                  delay: Duration(
                                                      milliseconds: typed
                                                          ? 0
                                                          : 18 *
                                                              '${data['headline'] ?? ''}'
                                                                  .length),
                                                  maxLines: null, onDone: () {
                                                if (!_aovTyped.contains(hn)) {
                                                  setState(
                                                      () => _aovTyped.add(hn));
                                                }
                                              },
                                                  style: _t(13.0,
                                                      color: _ink,
                                                      weight: FontWeight.w500,
                                                      height: 1.5)),
                                              // generative UI: บล็อกตามเคส (ค่าจริงดึงจากแฟ้มเคส)
                                              if (typed &&
                                                  ErSession.instance.role !=
                                                      ErRole.doctor) ...[
                                                const SizedBox(height: 12.0),
                                                _Appear(
                                                    index: 0,
                                                    child: _aovOrdersBlock()),
                                              ],
                                              if (typed)
                                                for (final (i, b)
                                                    in _aovBlocks(data)
                                                        .indexed) ...[
                                                  const SizedBox(height: 12.0),
                                                  _Appear(
                                                    index: i,
                                                    child: switch (b.type) {
                                                      ErUiType.vitals =>
                                                        _aovVitals(b, data),
                                                      ErUiType.labs =>
                                                        _aovLabs(b),
                                                      _ => _uiBlock(b),
                                                    },
                                                  ),
                                                ],
                                              if (open) ...[
                                                for (final (h, l) in [
                                                  ('สิ่งที่ต้องจับตา', flags),
                                                  ('รอผล', pending),
                                                ])
                                                  if (l.isNotEmpty) ...[
                                                    const SizedBox(
                                                        height: 10.0),
                                                    Text(h,
                                                        style: _t(12.0,
                                                            color: _ink2,
                                                            weight: FontWeight
                                                                .w700)),
                                                    for (final x in l)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 4.0),
                                                        child: Text('•  $x',
                                                            style: _t(12.5,
                                                                color: _ink,
                                                                weight:
                                                                    FontWeight
                                                                        .w500)),
                                                      ),
                                                  ],
                                              ],
                                            ]),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // ที่มาของข้อมูล (แท็บที่ใช้สรุป) แสดงหลังพิมพ์จบ
                        if (data != null && typed && open)
                          _Appear(
                            index: 2,
                            child:
                                Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                              for (final src in sources) chip(src),
                            ]),
                          ),
                        if (data != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 8.0),
                            child: _Press(
                              child: GestureDetector(
                                onTap: toggle,
                                child: Container(
                                  height: 36.0,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100.0),
                                    border: Border.all(
                                        color: const Color(0xFFC4C7CC)),
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(open ? 'แสดงน้อยลง' : 'แสดงเพิ่ม',
                                            style: _t(13.0,
                                                color: _inkTitle,
                                                weight: FontWeight.w600)),
                                        const SizedBox(width: 6.0),
                                        Icon(
                                            open
                                                ? Icons
                                                    .keyboard_arrow_up_rounded
                                                : Icons
                                                    .keyboard_arrow_down_rounded,
                                            size: 18.0,
                                            color: _inkTitle),
                                      ]),
                                ),
                              ),
                            ),
                          ),
                      ]),
                ))));
  }

  // ------------------------------------------------ หน้าสรุปเคสด้วย AI
  /// เปิดหน้าสรุป: หุ่นเปลี่ยนเป็นเอกซเรย์พื้นมืด แล้วให้ LLM สรุปจากข้อมูลเคสทั้งหมด
  Future<void> _openSummary({bool refresh = false}) async {
    final hn = _caseP().hn;
    setState(() {
      _summaryOpen = true;
      _timelineOpen = false;
      _summaryErr = null;
    });
    if (!refresh && _summaryCache.containsKey(hn)) return;
    setState(() => _summaryBusy = true);
    final t0 = DateTime.now();
    try {
      final out = await ErAi.chat([
        {
          'role': 'system',
          'content': '''
คุณคือแพทย์เวชศาสตร์ฉุกเฉินอาวุโส สรุปเคสผู้ป่วยห้องฉุกเฉินให้ทีมอ่านใน 10 วินาที
ใช้เฉพาะข้อมูลที่ให้มา ห้ามแต่งผลตรวจหรือยาที่ไม่มี ภาษาไทยปนศัพท์แพทย์อังกฤษได้
ทุกช่องเขียนภาษาไทยเป็นหลัก ใช้อังกฤษเฉพาะศัพท์แพทย์/ชื่อยา/ชื่อแล็บ
ตอบ JSON เท่านั้น รูปแบบ:
{"headline":"<สรุป 1 บรรทัดภาษาไทย (ศัพท์แพทย์อังกฤษได้) ไม่เกิน 14 คำ>",
 "severity":"critical|urgent|stable",
 "summary":"<ย่อหน้าเดียว 2-3 ประโยค: ใคร มาด้วยอะไร ตอนนี้เป็นอย่างไร>",
 "problems":[{"title":"<ปัญหา>","organ":"brain|heart|lungs|liver|stomach|kidneys|intestine|bladder","status":"critical|urgent|stable","detail":"<หลักฐานสั้น ๆ เช่น ค่าแล็บ/สัญญาณชีพ>"}],
 "red_flags":["<สิ่งอันตรายที่ต้องจับตา>"],
 "done":["<สิ่งที่ทำไปแล้ว>"],
 "pending":["<ผล/งานที่ค้าง>"],
 "next_actions":[{"text":"<สิ่งที่ควรทำต่อ>","owner":"แพทย์|พยาบาล","urgent":true}],
 "disposition":"<แนวทางจำหน่ายที่เหมาะ พร้อมเหตุผลสั้น>"}
problems ไม่เกิน 4 ข้อ organ ต้องเป็นหนึ่งในรายการที่กำหนด red_flags/pending/done ไม่เกิน 4 ข้อ next_actions ไม่เกิน 4 ข้อ''',
        },
        {'role': 'user', 'content': 'ข้อมูลเคส:\n${_caseContext()}'},
      ], json: true, fast: true, maxTokens: 900, temperature: 0.2);
      debugPrint(
          'ErAi สรุปเคส ${DateTime.now().difference(t0).inMilliseconds} ms');
      final data = ErAi.extractJson(out);
      if (!mounted) return;
      setState(() {
        _summaryCache[hn] = data ?? _fallbackSummary();
        if (data == null)
          _summaryErr = 'AI ตอบไม่เป็นรูปแบบ ใช้สรุปจากข้อมูลในระบบแทน';
        _summaryBusy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _summaryCache[hn] = _fallbackSummary();
        _summaryErr = 'เชื่อมต่อ AI ไม่ได้ ใช้สรุปจากข้อมูลในระบบแทน';
        _summaryBusy = false;
      });
    }
  }

  /// สรุปสำรองจากข้อมูลเคสตรง ๆ เมื่อ AI ใช้ไม่ได้
  Map<String, dynamic> _fallbackSummary() {
    final c = _case;
    final p = _caseP();
    final organs = _organsOfCase(c);
    return {
      'headline': c.dx.isNotEmpty ? c.dx.first.text : c.cc,
      'severity': (p.esi?.level ?? 3) <= 1
          ? 'critical'
          : ((p.esi?.level ?? 3) <= 2 ? 'urgent' : 'stable'),
      'summary': '${c.sex} ${c.ageText} ${c.cc}',
      'problems': [
        for (var i = 0; i < c.dx.length && i < 4; i++)
          {
            'title': c.dx[i].text,
            'organ': organs.isEmpty ? 'heart' : organs[i % organs.length],
            'status':
                c.dx[i].level.name == 'normal' ? 'stable' : c.dx[i].level.name,
            'detail': c.dx[i].icd10 ?? '',
          }
      ],
      'red_flags': c.advice,
      'done': [for (final m in c.meds) '${m.name} ${m.time}'],
      'pending': [
        for (final i in c.imaging)
          if (i.result.contains('รอ')) i.name
      ],
      'next_actions': [
        {'text': c.nextStep, 'owner': 'แพทย์', 'urgent': true}
      ],
      'disposition': c.disposition.isEmpty ? c.nextDetail : c.disposition,
    };
  }

  Map<String, dynamic>? get _summary => _summaryCache[_caseP().hn];

  /// อวัยวะที่ให้หุ่นเรืองแสงในหน้าสรุป
  List<String> _summaryOrgans() {
    const ok = {
      'brain',
      'heart',
      'lungs',
      'liver',
      'stomach',
      'kidneys',
      'intestine',
      'bladder'
    };
    final list = [
      for (final pr in (_summary?['problems'] as List? ?? const []))
        if (pr is Map && ok.contains(pr['organ'])) pr['organ'] as String
    ];
    // กระดูกที่หักมาจากตัว map เสมอ (LLM สรุปเฉพาะอวัยวะ)
    final bones = [
      for (final c in _bodyCodesOfCase(_case))
        if (c.startsWith('bone:')) c,
    ];
    return [
      ...(list.isEmpty ? _organsOfCase(_case) : list.toSet().toList()),
      ...bones,
    ];
  }

  Widget _dCard(Widget child, {EdgeInsets? pad, Color? glow}) => Container(
        padding: pad ?? const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
        decoration: BoxDecoration(
          color: _dPanel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: glow?.withValues(alpha: 0.55) ?? _dLine),
          boxShadow: [
            if (glow != null)
              BoxShadow(
                  color: glow.withValues(alpha: 0.12),
                  blurRadius: 18.0,
                  spreadRadius: 1.0),
          ],
        ),
        child: child,
      );

  Widget _dHead(IconData icon, String text, {Color color = _dInk2}) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(children: [
          Icon(icon, size: 13.0, color: color),
          const SizedBox(width: 6.0),
          Text(text, style: _t(10.5, color: color, weight: FontWeight.w700)),
        ]),
      );

  Widget _dBullet(String text, {Color dot = _dInk2}) => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5.0,
              height: 5.0,
              margin: const EdgeInsets.only(top: 6.0, right: 8.0),
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            Expanded(
                child: Text(text, style: _t(10.5, color: _dInk, height: 1.35))),
          ],
        ),
      );

  /// ตัวเลขใหญ่แบบภาพอ้างอิง: ค่าผิดปกติเป็นสีแดงเรืองแสง
  Widget _dMetric(String label, String value, String unit, bool bad,
          {IconData? icon}) =>
      _dCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 12.0, color: bad ? _dRed : _dInk2),
                const SizedBox(width: 5.0),
              ],
              Text(label, style: _t(9.5, color: _dInk2)),
            ]),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: _num(26.0,
                            color: bad ? _dRed : _dInk, weight: FontWeight.w700)
                        .copyWith(shadows: [
                      if (bad)
                        Shadow(
                            color: _dRed.withValues(alpha: 0.6),
                            blurRadius: 14.0),
                    ])),
                const SizedBox(width: 4.0),
                Text(unit, style: _t(9.5, color: _dInk2)),
              ],
            ),
          ],
        ),
        pad: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 8.0),
        glow: bad ? _dRed : null,
      );

  List<Widget> _summaryOverlays() {
    final c = _case;
    final p = _caseP();
    final s = _summary;
    final sev = s?['severity'];
    bool out(double v, double lo, double hi) => v < lo || v > hi;
    final gcs = int.tryParse(c.gcsScore);
    final left = ListView(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
      children: [
        // ตัวตนผู้ป่วย + ความรุนแรงรวม
        _dCard(
          Row(children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: _sevColor(sev).withValues(alpha: 0.2),
              child: Icon(Icons.person_rounded, color: _sevColor(sev)),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: _t(14.0, color: _dInk, weight: FontWeight.w700)),
                  Text(
                      '${c.sex} ${c.ageText} · HN ${p.hn} · เตียง ${p.bed ?? '—'}',
                      style: _t(9.5, color: _dInk2)),
                  const SizedBox(height: 4.0),
                  Wrap(spacing: 5.0, runSpacing: 4.0, children: [
                    _dChip(
                        p.esi == null ? 'ยังไม่คัดกรอง' : 'ESI ${p.esi!.level}',
                        p.esi?.hue ?? _dInk2),
                    _dChip('${p.stage.label} · ${_clockWait(p.waitMin)}',
                        _dAccent),
                    if (c.onset != null)
                      _dChip(
                          'เริ่มอาการ ${_clockWait(_minutesSince(c.onset!))}',
                          _dRed),
                  ]),
                ],
              ),
            ),
          ]),
          glow: _sevColor(sev),
        ),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 14.0, color: _dAccent),
              const SizedBox(width: 6.0),
              Text('AI สรุปเคส',
                  style: _t(10.5, color: _dAccent, weight: FontWeight.w700)),
              const Spacer(),
              if (s != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: _sevColor(sev).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(_sevLabel(sev),
                      style: _t(9.0,
                          color: _sevColor(sev), weight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 8.0),
            if (_summaryBusy || s == null)
              Row(children: [
                const SizedBox(
                    width: 14.0,
                    height: 14.0,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0, color: _dAccent)),
                const SizedBox(width: 8.0),
                Text('กำลังอ่านข้อมูลทั้งเคสและสรุป…',
                    style: _t(10.5, color: _dInk2)),
              ])
            else ...[
              Text(s['headline']?.toString() ?? '',
                  style: _t(15.0,
                      color: _dInk, weight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 6.0),
              Text(s['summary']?.toString() ?? '',
                  style: _t(11.0, color: _dInk, height: 1.45)),
              if (_summaryErr != null) ...[
                const SizedBox(height: 6.0),
                Text(_summaryErr!, style: _t(9.0, color: _dAccent)),
              ],
            ],
          ],
        )),
        if (s != null && _strList(s['red_flags']).isNotEmpty) ...[
          const SizedBox(height: 10.0),
          _dCard(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dHead(Icons.warning_amber_rounded, 'ต้องจับตา', color: _dRed),
                for (final f in _strList(s['red_flags']))
                  _dBullet(f, dot: _dRed),
              ],
            ),
            glow: _dRed,
          ),
        ],
        if (c.allergies.isNotEmpty) ...[
          const SizedBox(height: 10.0),
          _dCard(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dHead(Icons.block_rounded, 'แพ้ยา / แพ้อาหาร', color: _dRed),
              Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                for (final a in c.allergies) _dChip(a, _dRed),
              ]),
            ],
          )),
        ],
      ],
    );

    final problems = [
      for (final pr in (s?['problems'] as List? ?? const []))
        if (pr is Map) pr
    ];
    final actions = [
      for (final a in (s?['next_actions'] as List? ?? const []))
        if (a is Map) a
    ];
    final right = ListView(
      padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
      children: [
        // ตัวเลขใหญ่: สัญญาณชีพล่าสุด
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 1.9,
          children: [
            _dMetric(
                'ชีพจร', '${c.hr.last.round()}', 'bpm', out(c.hr.last, 60, 100),
                icon: Icons.favorite_rounded),
            _dMetric('ความดัน', c.bp, 'mmHg', out(c.sbp.last, 90, 140),
                icon: Icons.monitor_heart_rounded),
            _dMetric('SpO₂', '${c.spo2.last.round()}', '%',
                out(c.spo2.last, 94, 100),
                icon: Icons.bubble_chart_rounded),
            _dMetric('GCS', c.gcsScore, '/15', gcs != null && gcs < 15,
                icon: Icons.psychology_rounded),
          ],
        ),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dHead(Icons.biotech_rounded, 'ปัญหาหลัก · ตำแหน่งบนร่างกาย'),
            if (problems.isEmpty)
              Text(_summaryBusy ? '…' : 'ไม่มีปัญหาเร่งด่วน',
                  style: _t(10.5, color: _dInk2)),
            for (final pr in problems)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.only(top: 5.0, right: 8.0),
                      decoration: BoxDecoration(
                        color: _sevColor(pr['status']),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _sevColor(pr['status'])
                                  .withValues(alpha: 0.7),
                              blurRadius: 8.0),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pr['title']?.toString() ?? '',
                              style: _t(11.0,
                                  color: _dInk, weight: FontWeight.w700)),
                          if ((pr['detail']?.toString() ?? '').isNotEmpty)
                            Text(pr['detail'].toString(),
                                style: _t(9.5, color: _dInk2, height: 1.3)),
                        ],
                      ),
                    ),
                    Text(_organTh(pr['organ']),
                        style: _t(9.0, color: _dAccent)),
                  ],
                ),
              ),
          ],
        )),
        const SizedBox(height: 10.0),
        _dCard(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dHead(Icons.bolt_rounded, 'ควรทำต่อ', color: _dAccent),
            if (actions.isEmpty)
              Text(_summaryBusy ? '…' : '-', style: _t(10.5, color: _dInk2)),
            for (final a in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                        a['urgent'] == true
                            ? Icons.priority_high_rounded
                            : Icons.arrow_right_rounded,
                        size: 14.0,
                        color: a['urgent'] == true ? _dRed : _dInk2),
                    const SizedBox(width: 4.0),
                    Expanded(
                        child: Text(a['text']?.toString() ?? '',
                            style: _t(10.5, color: _dInk, height: 1.3))),
                    const SizedBox(width: 6.0),
                    _dChip(a['owner']?.toString() ?? 'แพทย์', _dInk2),
                  ],
                ),
              ),
          ],
        )),
        if (s != null) ...[
          const SizedBox(height: 10.0),
          _dCard(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dHead(Icons.task_alt_rounded, 'ทำไปแล้ว', color: _dAccent),
              for (final d in _strList(s['done'])) _dBullet(d, dot: _dAccent),
              const SizedBox(height: 4.0),
              _dHead(Icons.hourglass_top_rounded, 'รอผล / ค้าง',
                  color: _dAccent),
              if (_strList(s['pending']).isEmpty)
                Text('ไม่มี', style: _t(10.5, color: _dInk2)),
              for (final d in _strList(s['pending']))
                _dBullet(d, dot: _dAccent),
            ],
          )),
        ],
      ],
    );

    return [
      Positioned(left: 0.0, top: 0.0, bottom: 0.0, width: 360.0, child: left),
      Positioned(right: 0.0, top: 0.0, bottom: 0.0, width: 360.0, child: right),
      // แถบล่างกลาง: แนวทางจำหน่าย + ปุ่ม
      Positioned(
        left: 372.0,
        right: 372.0,
        bottom: 14.0,
        child: _dCard(
          Row(children: [
            const Icon(Icons.logout_rounded, size: 16.0, color: _dAccent),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('แนวทางจำหน่าย', style: _t(9.0, color: _dInk2)),
                  Text(
                      s?['disposition']?.toString() ??
                          (_summaryBusy ? 'กำลังประเมิน…' : '-'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.0,
                          color: _dInk, weight: FontWeight.w600, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            _dButton(Icons.copy_rounded, 'คัดลอก', () {
              final sm = _summary;
              if (sm == null) return;
              Clipboard.setData(ClipboardData(
                  text:
                      '${p.name} HN ${p.hn}\n${sm['headline']}\n${sm['summary']}\n'
                      'แผน: ${sm['disposition']}'));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('คัดลอกสรุปแล้ว')));
            }),
            const SizedBox(width: 6.0),
            _dButton(Icons.refresh_rounded, 'สรุปใหม่',
                _summaryBusy ? null : () => _openSummary(refresh: true)),
            const SizedBox(width: 6.0),
            _dButton(Icons.close_rounded, 'ปิด',
                () => setState(() => _summaryOpen = false)),
          ]),
          pad: const EdgeInsets.fromLTRB(14.0, 10.0, 10.0, 10.0),
        ),
      ),
    ];
  }

  Widget _dChip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child:
            Text(text, style: _t(9.0, color: color, weight: FontWeight.w700)),
      );

  Widget _dButton(IconData icon, String label, VoidCallback? onTap) => _Press(
          child: Material(
        color: _blue.withValues(alpha: onTap == null ? 0.03 : 0.07),
        borderRadius: BorderRadius.circular(10.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
            child: Row(children: [
              Icon(icon, size: 14.0, color: _dInk),
              const SizedBox(width: 5.0),
              Text(label,
                  style: _t(10.0, color: _dInk, weight: FontWeight.w600)),
            ]),
          ),
        ),
      ));
}

/// แถบ skeleton เคลื่อนแสงแบบ AI Overview (ไล่สีฟ้า-ม่วงอ่อนวิ่งซ้ายไปขวา)
class _AovShimmer extends StatefulWidget {
  const _AovShimmer();

  @override
  State<_AovShimmer> createState() => _AovShimmerState();
}

class _AovShimmerState extends State<_AovShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value * 2 - 0.5;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + t * 2, 0),
                end: Alignment(1.0 + t * 2, 0),
                colors: const [
                  Color(0xFFDCE6FB),
                  Color(0xFFC9D7F7),
                  Color(0xFFE4DDF8),
                  Color(0xFFDCE6FB),
                ],
              ),
            ),
          );
        },
      );
}

/// ไอคอนแหล่งข้อมูลซ้อนกัน (วงกลมขาวขอบ) + "+N"
/// loading = ไอคอนเด้งเข้าทีละอันวนซ้ำ (กำลังอ่านแต่ละแท็บ) · เสร็จ = นิ่ง
class _AovSources extends StatefulWidget {
  const _AovSources(
      {required this.icons, required this.loading, required this.ink});

  final List<IconData> icons;
  final bool loading;
  final Color ink;

  @override
  State<_AovSources> createState() => _AovSourcesState();
}

class _AovSourcesState extends State<_AovSources>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void initState() {
    super.initState();
    if (widget.loading) _c.repeat();
  }

  @override
  void didUpdateWidget(_AovSources old) {
    super.didUpdateWidget(old);
    if (widget.loading && !_c.isAnimating) _c.repeat();
    if (!widget.loading && _c.isAnimating) {
      _c.stop();
      _c.value = 1.0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const show = 3, d = 26.0, step = 16.0;
    final n = widget.icons.length;
    final vis = widget.icons.take(show).toList();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // ระหว่างโหลด: ไอคอนที่ i โผล่ตามจังหวะ (วนทุก 2.4 วิ) · นับ +N ไล่ขึ้น
        double k(int i) {
          if (!widget.loading) return 1.0;
          final t = (_c.value * (show + 1) - i).clamp(0.0, 1.0);
          return Curves.easeOutBack.transform(t);
        }

        final shown =
            widget.loading ? (_c.value * (n + 1)).floor().clamp(0, n) : n;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: d + step * (vis.length - 1),
            height: d,
            child: Stack(children: [
              for (var i = 0; i < vis.length; i++)
                Positioned(
                  left: step * i,
                  child: Transform.scale(
                    scale: k(i),
                    child: Opacity(
                      opacity: k(i).clamp(0.0, 1.0),
                      child: Container(
                        width: d,
                        height: d,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFDADCE0), width: 1.0),
                        ),
                        child: Icon(vis[i], size: 14.0, color: widget.ink),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
          if (n > show) ...[
            const SizedBox(width: 6.0),
            Text('+${math.max(0, shown - show)}',
                style: TextStyle(
                    fontFamily: 'GoogleSans',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: widget.ink.withValues(alpha: 0.7))),
          ],
        ]);
      },
    );
  }
}

/// ข้อความพิมพ์ทีละตัว (เคอร์เซอร์กะพริบท้าย) · animate = false แสดงเต็มทันที
class _TypeText extends StatefulWidget {
  const _TypeText(this.text,
      {super.key,
      required this.style,
      this.animate = true,
      this.delay = Duration.zero,
      this.maxLines,
      this.onDone});

  final String text;
  final TextStyle style;
  final bool animate;
  final Duration delay;
  final int? maxLines;
  final VoidCallback? onDone;

  @override
  State<_TypeText> createState() => _TypeTextState();
}

class _TypeTextState extends State<_TypeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: (widget.text.length * 18).clamp(300, 2600)));

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      _c.value = 1.0;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onDone?.call());
      return;
    }
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward().whenComplete(() => widget.onDone?.call());
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final n = (widget.text.length * _c.value).round();
          final typing = _c.value > 0 && _c.value < 1;
          return Text.rich(
            TextSpan(children: [
              TextSpan(text: widget.text.substring(0, n)),
              if (typing)
                TextSpan(
                    text: ' ▍',
                    style: widget.style.copyWith(
                        color: widget.style.color?.withValues(alpha: 0.5))),
            ]),
            style: widget.style,
            maxLines: widget.maxLines,
            overflow: widget.maxLines == null ? null : TextOverflow.ellipsis,
          );
        },
      );
}
