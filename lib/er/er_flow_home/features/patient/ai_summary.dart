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
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
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

  /// พยาบาล: แถวเดียวบอกจำนวนคำสั่งที่รอทำ (ด่วนแดง) แตะ = เลื่อนลงไปการ์ดคำสั่งแพทย์
  /// (ไม่แสดงรายการซ้ำกับการ์ดคำสั่งด้านล่าง)
  Widget _aovOrdersBlock() {
    final list = _aovPendingOrders();
    if (list.isEmpty) return const SizedBox.shrink();
    final urgent = list.where((t) => t.urgent).length;
    return _Press(
      child: Material(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            final ctx = _bentoTasksKey.currentContext;
            if (ctx == null) {
              setState(() => _detailTab = 3);
              return;
            }
            Scrollable.ensureVisible(ctx,
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                alignment: 0.05);
          },
          child: Container(
            height: 44.0,
            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 8.0, 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Row(children: [
              const Icon(Icons.assignment_outlined, size: 18.0, color: _blue),
              const SizedBox(width: 8.0),
              Text('คำสั่งแพทย์รอทำ ${list.length} รายการ',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
              if (urgent > 0) ...[
                const SizedBox(width: 8.0),
                Text('ด่วน $urgent',
                    style: _t(13.0, color: _red, weight: FontWeight.w700)),
              ],
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
            ]),
          ),
        ),
      ),
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

  /// ปุ่มขอ AI Overview (ใช้การ์ดขอ AI ร่วมกับ Dr.Note ช่วยคิด)
  Widget _aovAskBtn(String key) => _aiAskCard(
        title: 'AI Overview',
        sub:
            'ให้ Dr.Note สรุปเคสนี้สำหรับ${ErSession.instance.user?.roleLabel ?? 'แพทย์'}',
        btn: 'สรุปเคส',
        onTap: () => setState(() => _aovAsked.add(key)),
        art: const _FolderHuntArt(),
      );

  /// การ์ดขอให้ AI ช่วย (ภาษาเดียวกันทุกจุด): พื้นไล่ฟ้าอ่อน + Dr.Note 3D (ท่า generate)
  /// ชื่อ + คำอธิบาย · ปุ่มรองขาวขอบเทาชิดขวา (ปุ่มหลักกรมท่าของหน้าคือปุ่มส่งต่อ P9)
  /// AI ไม่ทำงานเองจนกว่าจะกด · compact = แผงแคบ (workflow) ตัวการ์ตูนเล็กลง คำอธิบาย 2 บรรทัด
  Widget _aiAskCard({
    required String title,
    required String sub,
    required String btn,
    required VoidCallback onTap,
    bool compact = false,
    // ท่าของ Dr.Note: สรุป = ดาว sparkle · วินิจฉัย = แว่นขยายส่องกวาด
    ErDrNoteMode mode = ErDrNoteMode.generate,
    // ภาพประกอบแทนตัวละคร 3D (เช่น แว่นขยายของวินิจฉัย)
    Widget? art,
  }) {
    void ask() {
      HapticFeedback.selectionClick();
      onTap();
    }

    return _Press(
      child: GestureDetector(
        onTap: ask,
        child: Container(
          padding: compact
              ? const EdgeInsets.fromLTRB(8.0, 10.0, 10.0, 10.0)
              : const EdgeInsets.fromLTRB(4.0, 2.0, 14.0, 2.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEEF3FE), Color(0xFFF7F4FD)],
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          // แคบ (< 300) = ซ่อนภาพประกอบ ให้ข้อความกับปุ่มไม่เบียด
          child: LayoutBuilder(builder: (context, box) {
            final showArt = box.maxWidth >= 300.0;
            return Row(children: [
              if (!showArt) const SizedBox(width: 12.0),
              // กรอบ 4:3 ตามที่ฉากจัดตัว · ย่อ 0.8 ให้เห็นเต็มตัว (หัว/เท้าไม่ขาด)
              if (showArt)
                SizedBox(
                  width: compact ? 52.0 : 112.0,
                  height: compact ? 52.0 : 84.0,
                  child: IgnorePointer(
                    child: art ??
                        RepaintBoundary(
                            child: ErDrNote3D(
                                mode: mode,
                                intro: true,
                                pose: const (-0.35, 0.42, 0.24, 0.8))),
                  ),
                ),
              if (showArt) SizedBox(width: compact ? 10.0 : 4.0),
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(15.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                      const SizedBox(height: 2.0),
                      Text(sub,
                          maxLines: compact ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(compact ? 12.0 : 12.5,
                              color: _ink2, weight: FontWeight.w500)),
                    ]),
              ),
              SizedBox(width: compact ? 8.0 : 12.0),
              // แผงแคบ: ปุ่มวงกลมไอคอนอย่างเดียว (การ์ดทั้งใบแตะได้) ไม่เบียดข้อความ
              // แผงแคบ: pill สั้น ไอคอน + คำ (บอกว่าจะเกิดอะไร) ไม่ใช่ไอคอนลอย ๆ
              if (compact)
                Container(
                  height: 36.0,
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 12.0, 0.0),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border:
                        Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 15.0, color: _blue),
                    const SizedBox(width: 5.0),
                    Text(btn,
                        style: _t(13.0, color: _blue, weight: FontWeight.w600)),
                  ]),
                )
              else
                Container(
                  height: 40.0,
                  padding: EdgeInsets.fromLTRB(
                      compact ? 12.0 : 14.0, 0.0, compact ? 14.0 : 18.0, 0.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border:
                        Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 16.0, color: _blue),
                    const SizedBox(width: 6.0),
                    Text(btn,
                        style: _t(13.5, color: _blue, weight: FontWeight.w600)),
                  ]),
                ),
            ]);
          }),
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
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
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
                    fontFamily: _fontFam,
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

/// ภาพ AI Overview (2026-10-22) สไตล์ 3D เดียวกับ asset อื่นในแอป (ไม่มีเส้นขอบ ไล่สีนุ่ม น้ำเงิน/ขาว/แดง)
/// กล่องแฟ้มไอโซเมตริก
/// แว่นขยายควานหาในแฟ้ม → แฟ้มสุขภาพ (เขียว) ยกขึ้น กล่องจมหาย → พื้นฟ้าม่วงขยาย
/// ข้อมูลระเบิดออก: กระดาษเส้นคลื่นเขียว ลูกบาศก์คนเขียว เครื่องสีม่วงเข้ม @ # ▲ หัวใจ
/// แว่นขยายใหญ่ส่องกระดาษ · เล่นครั้งเดียว แล้วลอยเบา ๆ · วาดด้วย painter ไม่มีรูป ไม่มีเงา
class _FolderHuntArt extends StatefulWidget {
  const _FolderHuntArt();
  @override
  State<_FolderHuntArt> createState() => _FolderHuntArtState();
}

class _FolderHuntArtState extends State<_FolderHuntArt>
    with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4800))
    ..forward();
  late final AnimationController _idle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4000))
    ..repeat();

  @override
  void dispose() {
    _in.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_in, _idle]),
          // ขยับภาพลงเล็กน้อย
          builder: (context, _) => Transform.translate(
              offset: const Offset(0.0, 5.0),
              child: Stack(children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: _HuntPainter(_in.value, _idle.value),
                ),
                // ดาว + aura ของจริงจาก Dr.Note 3D (ซ่อนตัวสมุด) วางหน้าแฟ้ม (ดาวลอยเหนือกระดาษ)
                // เปลี่ยนเป็นท่า generate เมื่อแฟ้มมาถึงกลาง = เรื่องดาวหมุนรอบเริ่ม
                // ฉากอยู่ที่เดิม (aura ใต้แฟ้ม) · เลื่อนเฉพาะจุดลงของดาวไปมุมขวาล่างแฟ้มแดง
                Positioned.fill(
                  child: IgnorePointer(
                    child: ErDrNote3D(
                      starsOnly: true,
                      starQuiet: true,
                      // เอียงรับมุมแฟ้ม (กล้องฉากแฟ้ม yaw -0.38 pitch 0.3)
                      starTilt: const Offset(0.38, -0.3),
                      starShift: const Offset(0.0 / 84.0, 16.0 / 84.0),
                      mode: _in.value >= 0.76
                          ? ErDrNoteMode.generate
                          : ErDrNoteMode.idle,
                    ),
                  ),
                ),
              ])),
        ),
      );
}

class _HuntPainter extends CustomPainter {
  _HuntPainter(this.v, this.idle);
  final double v, idle;

  // พาเลตเดียวกับ asset 3D ของแอป (เครื่องวัดความดัน ปรอท คนสีน้ำเงิน)
  static const blue = Color(0xFF2F6BF0);
  static const blueLt = Color(0xFF5B9BFF);
  static const red = Color(0xFFEF5350);
  // แฟ้มสุขภาพ: ฟ้า (น้ำเงินของแอป เข้มพอให้กากบาทขาวอ่านออก)
  static const folderBlue = Color(0xFF3D7BF2);
  static const steel = Color(0xFF3C4250);

  double seg(double a, double b, [Curve c = Curves.easeInOutCubic]) =>
      c.transform(((v - a) / (b - a)).clamp(0.0, 1.0));

  void _magnifier(Canvas c, Offset ctr, double r, double handleAngle) {
    final dir = Offset(math.cos(handleAngle), math.sin(handleAngle));
    // ด้าม: เทาเข้มไล่แสง (แบบลูกบีบเครื่องวัดความดัน)
    final a = ctr + dir * (r + 0.5), b = ctr + dir * (r * 2.15);
    for (var d = 1.6; d > 0; d -= 0.4) {
      c.drawLine(
          a + Offset(d * 0.4, d),
          b + Offset(d * 0.4, d),
          Paint()
            ..color = const Color(0xFF23272F)
            ..strokeWidth = r * 0.5
            ..strokeCap = StrokeCap.round);
    }
    c.drawLine(
        a,
        b,
        Paint()
          ..shader = const LinearGradient(colors: [Color(0xFF5A6070), steel])
              .createShader(Rect.fromPoints(a, b))
          ..strokeWidth = r * 0.5
          ..strokeCap = StrokeCap.round);
    // เลนส์ใส ฟ้าอ่อน
    c.drawCircle(ctr, r, Paint()..color = const Color(0x55CFE0FF));
    // วงแหวนน้ำเงิน หนา 3D
    for (var d = 2.0; d > 0; d -= 0.5) {
      c.drawCircle(
          ctr + Offset(d * 0.4, d),
          r,
          Paint()
            ..color = const Color(0xFF1E4FC2)
            ..style = PaintingStyle.stroke
            ..strokeWidth = r * 0.26);
    }
    c.drawCircle(
        ctr,
        r,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [blueLt, blue],
          ).createShader(Rect.fromCircle(center: ctr, radius: r))
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.26);
    c.drawArc(
        Rect.fromCircle(center: ctr, radius: r * 0.6),
        math.pi * 1.1,
        math.pi * 0.42,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.15
          ..strokeCap = StrokeCap.round);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final k = math.min(size.width / 112.0, size.height / 84.0);
    canvas.save();
    canvas.translate(
        (size.width - 112.0 * k) / 2, (size.height - 84.0 * k) / 2);
    canvas.scale(k);

    final appear = seg(0.0, 0.14, Curves.easeOutCubic);
    final search = seg(0.06, 0.48, Curves.easeInOutSine);
    // ดึงแฟ้ม: เส้นทางโค้งเดียวต่อเนื่อง (ขึ้นจากกล่อง → โค้งลงมากลาง) · กล่องจมหลังแฟ้มพ้นขอบ
    final pull = seg(0.46, 0.76, Curves.easeInOutCubic);
    final magOut = seg(0.44, 0.56);

    // ── ทั้งฉากเป็น 3D จริงในโลกเดียว (กล่อง + แฟ้มทุกเล่ม + แฟ้มสุขภาพ) กล้องเดียว
    // การดึงแฟ้ม = ย้ายวัตถุชิ้นเดียวในโลกเดียวกัน จึงต่อเนื่องจริง
    final sc = _Scene3D(
        // วางแบบภาพแรก: หน้ากล่องเกือบตรง เห็นด้านขวาน้ำเงินเยื้องขึ้น มองลงนิดเดียว
        yaw: -0.38,
        pitch: 0.3,
        center: const Offset(56.0, 64.0),
        f: 170.0,
        scale: 0.92 + 0.08 * appear)
      ..phase = idle;
    // ดึงแฟ้มสุขภาพ: ขึ้นพ้นขอบกล่อง → เคลื่อนเข้าหากล้องมากลางฉาก
    final rise = Curves.easeInOut.transform((pull / 0.55).clamp(0.0, 1.0));
    final fwd =
        Curves.easeInOut.transform(((pull - 0.35) / 0.65).clamp(0.0, 1.0));
    final boxGone =
        Curves.easeIn.transform(((pull - 0.38) / 0.4).clamp(0.0, 1.0));
    final boxDy = 6.0 * (1.0 - appear) + 22.0 * boxGone;
    // แว่นขยายกวาด (จอ) → แฟ้มที่แว่นผ่านเด้งขึ้น
    final lensX = 54.4 - 18.0 * math.sin(search * math.pi * 2.0);
    final open = seg(0.74, 0.84, Curves.easeOutCubic);
    final docUp = seg(0.78, 0.92, Curves.easeOutBack);

    // กล่อง: กว้าง 46 ลึก 30 สูง 18 · ผนังหนา 1.6
    _V bx(_V p) => _V(p.x, p.y + boxDy, p.z);
    const bw = 22.0, bd = 13.0, bh = 28.0, t = 1.6;
    const white = Color(0xFFF4F6FA), inner = Color(0xFFDCE2EE);
    // ลำดับวาดตามโครงสร้าง (กล้องคงที่): หลัง → พื้น → ผนังข้างไกล → แฟ้ม หลัง→หน้า
    // → ผนังข้างใกล้ → ผนังหน้า · กันผนังยาวเรียงลึกผิดจนดูเหมือนแฟ้มทะลุ
    final rightFar = sc.yaw < 0;
    sc.order = 0;
    sc.box(-bw, bw, -bh, 0, bd - t, bd, inner, bx, layer: 0); // ผนังหลัง
    sc.order = 1;
    sc.box(-bw, bw, -t, 0, -bd, bd, inner, bx, layer: 0); // พื้น
    sc.order = rightFar ? 2 : 40;
    sc.box(bw - t, bw, -bh, 0, -bd, bd, blue, bx, layer: 0); // ขวา (น้ำเงิน)
    sc.order = rightFar ? 40 : 2;
    sc.box(-bw, -bw + t, -bh, 0, -bd, bd, inner, bx, layer: 0); // ซ้าย
    sc.order = 41;
    sc.box(-bw, bw, -bh, 0, -bd, -bd + t, white, bx, layer: 0); // ผนังหน้า
    sc.order = 42;
    // ช่องมือจับบนผนังหน้า
    sc.quad([
      bx(const _V(-7, -15.5, -bd - 0.05)),
      bx(const _V(7, -15.5, -bd - 0.05)),
      bx(const _V(7, -12.5, -bd - 0.05)),
      bx(const _V(-7, -12.5, -bd - 0.05)),
    ], const Color(0xFFB8C2D4), layer: 0, flat: true);

    // แฟ้มในกล่อง (หลัง → หน้า): z, สี, มีกระดาษโผล่, เป็นแฟ้มสุขภาพ
    const folders = [
      // แฟ้มอื่นไม่ใช้โทนฟ้า ให้แฟ้มสุขภาพ (ฟ้า) เด่น
      (9.0, Color(0xFFF9D77E), false, false),
      (4.5, Color(0xFFF4B6C2), false, false),
      (0.0, folderBlue, true, true),
      (-4.5, red, true, false),
      (-9.0, Color(0xFF9ADBC5), true, false),
    ];
    for (final (fi, f) in folders.indexed) {
      sc.order = 10.0 + fi;
      // เด้งตามแว่น (ใช้ตำแหน่งจอของกลางแฟ้ม)
      final sxp = sc.project(bx(_V(0, -36, f.$1))).dx;
      final dd = ((lensX - sxp).abs() / 14.0).clamp(0.0, 1.0);
      final bob = 3.0 * (0.5 + 0.5 * math.cos(math.pi * dd)) * (1.0 - magOut);
      if (f.$4) {
        // แฟ้มสุขภาพ: ตำแหน่งในกล่อง → ยกขึ้น → เข้าหากล้องมากลาง
        final inBox = _V(0, -17.0 - bob - 30.0 * rise, 0);
        // ไม่หมุนเพิ่ม ไม่พุ่งเข้าหากล้อง (มุม perspective คงที่ทั้งเรื่อง):
        // ขยายรอบกลางแฟ้ม + เลื่อนในระนาบจอไปกลางฉาก
        final sF = 1.0 + 0.35 * fwd;
        final base = _V(inBox.x, inBox.y + (v <= 0.46 ? boxDy : 0.0), inBox.z);
        _V hf(_V p) => _V(p.x * sF + base.x, (p.y + 13.0) * sF - 13.0 + base.y,
            p.z * sF + base.z);
        final vc = sc.view(_V(base.x, base.y - 13.0, base.z));
        final kc = sc.f / (sc.f + vc.z);
        final tx = (56.0 - sc.center.dx) / (kc * sc.scale);
        final ty = (44.0 - sc.center.dy) / (kc * sc.scale);
        sc.shift = _V((tx - vc.x) * fwd, (ty - vc.y) * fwd, 0.0);

        // พ้นขอบกล่องแล้วเคลื่อนเข้าหากล้อง = วาดหน้าสุด
        if (fwd > 0.02) sc.order = 50;
        sc.folder(hf, folderBlue,
            paper: true, cross: true, open: open, doc: docUp, layer: 1);
        sc.shift = const _V(0, 0, 0);
      } else {
        // เล่มหลังสูงกว่านิด + แถบเยื้องกันทีละเล่ม = เห็นทุกเล่มแบบภาพแรก
        final step = f.$1 / 4.5; // -2 (หน้า) .. 2 (หลัง)
        _V ff(_V p) => bx(_V(p.x, p.y - 17.0 - bob - 1.6 * step, p.z + f.$1));
        sc.folder(ff, f.$2, paper: f.$3, tab: 4.5 * (step + 2), layer: 0);
      }
    }
    // กล่อง + แฟ้มอื่น จางและจมลงหลังแฟ้มสุขภาพพ้นขอบ
    sc.paint(canvas, layer0Alpha: 1.0 - boxGone, alpha: appear);

    // แว่นขยาย: ฉาก 1 กวาดเหนือแฟ้ม แล้วจางหายตอนดึงแฟ้มขึ้น
    final magOp = appear * (1.0 - magOut);
    if (magOp > 0.0) {
      final sx = 54.4 - 18.0 * math.sin(search * math.pi * 2.0);
      final pos = Offset(sx, 34.0 + 1.2 * math.sin(search * math.pi * 4.0)) +
          Offset(0.0, -6.0 * magOut);
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, magOp));
      _magnifier(canvas, pos, 8.0 * (0.6 + 0.4 * appear), math.pi * 0.28);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HuntPainter o) => o.v != v || o.idle != idle;
}

/// ฉาก 3D จริงขนาดเล็ก: รวมหน้า (polygon 3 มิติ) ของทุกวัตถุ → หมุนกล้อง yaw/pitch
/// → ฉาย perspective → เรียงไกล→ใกล้ → ลงสีตาม normal กับทิศแสง
/// layer 0 = กล่อง/แฟ้มอื่น (จางได้) · layer 1 = แฟ้มสุขภาพ (วาดรวมเรียงลึกกับ layer 0
/// ตอนยังไม่จาง · พอเริ่มจาง วาด layer 0 ในชั้นโปร่งแล้วค่อยวาดแฟ้มทับ)
class _Scene3D {
  _Scene3D(
      {required this.yaw,
      required this.pitch,
      required this.center,
      required this.f,
      this.scale = 1.0});
  final double yaw, pitch, f, scale;
  final Offset center;
  final faces = <_Face>[];

  /// ลำดับวัตถุที่กำลังเพิ่ม (ตั้งก่อนเรียก box/folder)
  double order = 0;

  /// เลื่อนในพิกัดกล้อง (ระนาบจอ) ของวัตถุที่กำลังเพิ่ม · ไม่เปลี่ยนมุมมอง
  _V shift = const _V(0, 0, 0);

  /// ลำดับย่อยภายในวัตถุ (แฟ้ม: หลัง → กระดาษ → ปก → กากบาท)
  double _sub = 0;

  /// เฟสไหลของไล่สี aura (0..1)
  double phase = 0;

  _V view(_V v) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final x1 = v.x * cy + v.z * sy, z1 = -v.x * sy + v.z * cy;
    final cp = math.cos(pitch), sp = math.sin(pitch);
    return _V(x1, v.y * cp - z1 * sp, v.y * sp + z1 * cp);
  }

  Offset _proj(_V w) {
    final k = f / (f + w.z);
    return center + Offset(w.x * k, w.y * k) * scale;
  }

  Offset project(_V p) => _proj(view(p));

  void quad(List<_V> pts, Color col, {int layer = 0, bool flat = false}) =>
      faces.add(_Face(pts, col,
          flat: flat, group: layer, order: order + _sub, shift: shift));

  /// กล่องสี่เหลี่ยมทึบ (x0..x1, y0..y1, z0..z1)
  void box(double x0, double x1, double y0, double y1, double z0, double z1,
      Color col, _V Function(_V) tf,
      {int layer = 0}) {
    _V p(double x, double y, double z) => tf(_V(x, y, z));
    final c = [
      [p(x0, y0, z0), p(x1, y0, z0), p(x1, y1, z0), p(x0, y1, z0)], // หน้า z0
      [p(x1, y0, z1), p(x0, y0, z1), p(x0, y1, z1), p(x1, y1, z1)], // หลัง z1
      [p(x0, y0, z1), p(x0, y0, z0), p(x0, y1, z0), p(x0, y1, z1)], // ซ้าย
      [p(x1, y0, z0), p(x1, y0, z1), p(x1, y1, z1), p(x1, y1, z0)], // ขวา
      [p(x0, y0, z1), p(x1, y0, z1), p(x1, y0, z0), p(x0, y0, z0)], // บน
      [p(x0, y1, z0), p(x1, y1, z0), p(x1, y1, z1), p(x0, y1, z1)], // ล่าง
    ];
    for (final q in c) {
      faces.add(_Face(q, col, group: layer, order: order + _sub, shift: shift));
    }
  }

  /// แผ่นหนาจาก polygon ใน xy ช่วง z0..z1
  void slab(
      List<Offset> poly, double z0, double z1, Color col, _V Function(_V) tf,
      {int layer = 0}) {
    final a = [for (final q in poly) tf(_V(q.dx, q.dy, z0))];
    final b = [for (final q in poly) tf(_V(q.dx, q.dy, z1))];
    faces.add(_Face(a, col, group: layer, order: order + _sub, shift: shift));
    faces.add(_Face(b.reversed.toList(), col,
        group: layer, order: order + _sub, shift: shift));
    for (var i = 0; i < poly.length; i++) {
      final j = (i + 1) % poly.length;
      faces.add(_Face([a[i], b[i], b[j], a[j]], col,
          group: layer, order: order + _sub, shift: shift));
    }
  }

  static Color _shade(Color c, double dl) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + dl).clamp(0.0, 1.0)).toColor();
  }

  /// แฟ้ม (จุดกำเนิด = กลางขอบล่าง y ลบ = ขึ้น z ลบ = ด้านหน้า): หลังแฟ้มมีแถบ · กระดาษ ·
  /// (แฟ้มสุขภาพ) ปกหน้าบานพับขอบล่าง + กากบาท · open = ปกพับลง · doc = กระดาษเลื่อนขึ้น
  void folder(_V Function(_V) tf, Color col,
      {bool paper = false,
      bool cross = false,
      double open = 0.0,
      double doc = 0.0,
      double tab = 0.0,
      int layer = 0}) {
    // ลำดับย่อยคงที่ในแฟ้ม: หลังแฟ้ม → กระดาษหลัง → กระดาษหน้า → ปก → กากบาท
    // (กล้องมองจากหน้าเสมอ) กันกระดาษทะลุปก/หลังแฟ้มจากการเรียงลึกรายผิว
    _sub = 0.0;
    slab([
      const Offset(-17, 0),
      const Offset(-17, -26),
      Offset(-15.5 + tab, -26),
      Offset(-14 + tab, -29),
      Offset(-5 + tab, -29),
      Offset(-3.5 + tab, -26),
      const Offset(17, -26),
      const Offset(17, 0),
    ], 0.6, 1.6, _shade(col, -0.03), tf, layer: layer);
    if (paper) {
      final up = 13.0 * doc;
      _sub = 0.2;
      slab([
        const Offset(-14, 0),
        Offset(-14, -24.5 - up * 0.7),
        Offset(12, -24.5 - up * 0.7),
        const Offset(12, 0)
      ], -0.3, 0.1, const Color(0xFFEFF3FA), tf, layer: layer);
      if (doc > 0) {
        _sub = 0.4;
        slab([
          const Offset(-12, 0),
          Offset(-12, -23 - up),
          Offset(14, -23 - up),
          const Offset(14, 0)
        ], -1.2, -0.8, Colors.white, tf, layer: layer);
        // skeleton เนื้อหาบนกระดาษ ไล่สี aura AI (ฟ้า → ม่วง → ชมพู) ไหลช้า ๆ
        _sub = 0.5;
        final top = -23 - up;
        for (final (row, wd0) in const [
          (0, 18.0),
          (1, 22.0),
          (2, 14.0),
          (3, 20.0)
        ]) {
          // idle อยู่ที่ skeleton: ความยาวแถวหายใจไล่จังหวะกันทีละแถว (เหมือนกำลังเขียน)
          final wd = wd0 *
              (0.82 +
                  0.18 *
                      (0.5 +
                          0.5 * math.sin(phase * 2 * math.pi * 2 - row * 0.9)));
          final y0 = top + 4.0 + row * 4.2;
          if (y0 + 2.2 > -6.0) continue; // ใต้ขอบปก ไม่ต้องวาด
          faces.add(_Face(
              [
                tf(_V(-9, y0 + 2.2, -1.3)),
                tf(_V(-9, y0, -1.3)),
                tf(_V(-9 + wd, y0, -1.3)),
                tf(_V(-9 + wd, y0 + 2.2, -1.3)),
              ],
              const Color(0xFFB9A8F5),
              flat: true,
              group: layer,
              order: order + _sub,
              shift: shift,
              grad: const [
                Color(0xCC4285F4),
                Color(0xCC9B72CB),
                Color(0xCCD96570),
              ]));
        }
      }
    }
    if (!cross) {
      _sub = 0.0;
      return;
    }
    _sub = 0.6;
    // ปกหน้า บานพับที่ขอบล่าง (z = -2.2) พับเข้าหากล้องตาม open
    final ang = 0.62 * open;
    _V hinge(_V v) {
      final dz = v.z + 2.2;
      return tf(_V(v.x, v.y * math.cos(ang) - dz * math.sin(ang),
          v.y * math.sin(ang) + dz * math.cos(ang) - 2.2));
    }

    slab(const [
      Offset(-17, 0),
      Offset(-17, -22.5),
      Offset(17, -22.5),
      Offset(17, 0)
    ], -2.8, -1.8, col, hinge, layer: layer);
    _sub = 0.8;
    for (final r in const [
      Rect.fromLTWH(-4.5, -12.5, 9, 3),
      Rect.fromLTWH(-1.5, -15.5, 3, 9),
    ]) {
      faces.add(_Face([
        hinge(_V(r.left, r.bottom, -2.9)),
        hinge(_V(r.left, r.top, -2.9)),
        hinge(_V(r.right, r.top, -2.9)),
        hinge(_V(r.right, r.bottom, -2.9)),
      ], Colors.white,
          flat: true, group: layer, order: order + _sub, shift: shift));
    }
    _sub = 0.0;
  }

  /// layer0Alpha = ความทึบกล่อง/แฟ้มอื่น (จางตอนดึงแฟ้ม) · alpha = ทั้งฉาก (ตอนเข้า)
  void paint(Canvas canvas, {double layer0Alpha = 1.0, double alpha = 1.0}) {
    const light = _V(-0.45, -0.7, -0.55);
    final lw = light.norm();
    final out = <(int, double, Path, Color, double, List<Color>?)>[];
    for (final fc in faces) {
      final w = [
        for (final p in fc.pts)
          () {
            final q = view(p);
            return _V(q.x + fc.shift.x, q.y + fc.shift.y, q.z + fc.shift.z);
          }()
      ];
      final n = (w[1] - w[0]).cross(w[2] - w[0]).norm();
      var zMin = double.infinity, zMax = -double.infinity;
      for (final p in w) {
        zMin = math.min(zMin, p.z);
        zMax = math.max(zMax, p.z);
      }
      // กากบาท/ช่องจับ: ดันมาหน้าสุดของระนาบเดียวกัน
      final depth = (zMin + zMax) / 2 - (fc.flat ? 0.6 : 0.0);
      final lit = fc.flat ? 1.0 : (0.9 + 0.2 * n.dot(lw).abs());
      final path = Path()..addPolygon([for (final p in w) _proj(p)], true);
      out.add((fc.group, depth, path, _lit(fc.col, lit), fc.order, fc.grad));
    }
    void draw(
        Iterable<(int, double, Path, Color, double, List<Color>?)> items) {
      final l = items.toList()
        ..sort((a, b) =>
            a.$5 != b.$5 ? a.$5.compareTo(b.$5) : b.$2.compareTo(a.$2));
      for (final d in l) {
        final g = d.$6;
        if (g == null) {
          canvas.drawPath(d.$3, Paint()..color = d.$4);
        } else {
          // ไล่สี aura ไหลช้า ๆ (shimmer) ตาม phase
          final b = d.$3.getBounds();
          final ph = phase * 2.0 - 1.0;
          canvas.drawPath(
              d.$3,
              Paint()
                ..shader = LinearGradient(
                  begin: Alignment(-1.0 + ph * 2.0, 0),
                  end: Alignment(1.0 + ph * 2.0, 0),
                  colors: g,
                  tileMode: TileMode.mirror,
                ).createShader(b.inflate(b.width)));
        }
      }
    }

    if (layer0Alpha >= 0.999) {
      // ยังไม่จาง: เรียงลึกรวมทุกวัตถุ (แฟ้มอยู่ในกล่องจริง ผนังหน้าบัง)
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
      draw(out);
      canvas.restore();
      return;
    }
    if (layer0Alpha > 0.0) {
      canvas.saveLayer(
          null, Paint()..color = Color.fromRGBO(0, 0, 0, layer0Alpha));
      draw(out.where((d) => d.$1 == 0));
      canvas.restore();
    }
    draw(out.where((d) => d.$1 == 1));
  }

  static Color _lit(Color c, double k) => Color.fromARGB(
      255,
      (c.r * 255 * k).round().clamp(0, 255),
      (c.g * 255 * k).round().clamp(0, 255),
      (c.b * 255 * k).round().clamp(0, 255));
}

class _Face {
  _Face(this.pts, this.col,
      {this.flat = false,
      this.group = 0,
      this.order = 0,
      this.shift = const _V(0, 0, 0),
      this.grad});
  final _V shift;

  /// ไล่สีบนหน้า (เช่น skeleton aura AI) แทนสีเดียว
  final List<Color>? grad;
  final List<_V> pts;
  final Color col;
  final bool flat;
  final int group;

  /// ลำดับวาดของวัตถุ (น้อย = วาดก่อน) แล้วค่อยเรียงลึกในวัตถุเดียวกัน
  final double order;
}

class _V {
  const _V(this.x, this.y, this.z);
  final double x, y, z;
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V cross(_V o) => _V(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
  double dot(_V o) => x * o.x + y * o.y + z * o.z;
  _V norm() {
    final l = math.sqrt(x * x + y * y + z * z);
    return l == 0 ? this : _V(x / l, y / l, z / l);
  }
}
