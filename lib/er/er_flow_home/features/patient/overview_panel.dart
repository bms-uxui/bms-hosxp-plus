// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

const Color _cyBgTop = Color(0xFFF1F3F4);
const Color _cyBgBottom = Color(0xFFF1F3F4);
const Color _cyGlass = _panel;
const Color _cyEdge = _line;
const Color _cySlate = _blue;
const Color _cyInsight = _pBg;
const Color _cyBtnLight = _panel;
const Color _cyBtnGrey = _pSoft;

/// ระบบร่างกายบนราง: ไอคอน · ชื่อ · อวัยวะที่ไฮไลต์ · ค่าที่เกี่ยวข้อง
const List<(IconData, String, List<String>, List<String>)> _clySystems = [
  (Icons.person_search_outlined, 'ภาพรวม', [], []),
  (
    Icons.favorite_border_rounded,
    'หัวใจและหลอดเลือด',
    ['heart'],
    ['HR', 'BP', 'Lactate', 'Trop', 'K']
  ),
  (
    Icons.air_rounded,
    'ระบบหายใจ',
    ['lungs', 'trachea'],
    ['SpO₂', 'RR', 'pCO2', 'pO2']
  ),
  (
    Icons.psychology_outlined,
    'สมองและระบบประสาท',
    ['brain'],
    ['DTX', 'Glucose', 'Na', 'BT']
  ),
  (
    Icons.lunch_dining_outlined,
    'ทางเดินอาหาร',
    ['stomach', 'liver', 'intestine', 'pancreas', 'esophagus'],
    ['AST', 'ALT', 'Lipase', 'Amylase', 'Bili', 'Hb']
  ),
  (
    Icons.water_drop_outlined,
    'ไตและทางเดินปัสสาวะ',
    ['kidneys', 'bladder'],
    ['Cr', 'BUN', 'Na', 'K']
  ),
  (
    Icons.accessibility_new_rounded,
    'กระดูกและกล้ามเนื้อ',
    [],
    ['Hb', 'CK', 'Pain']
  ),
  (
    Icons.bloodtype_outlined,
    'เลือดและการติดเชื้อ',
    [],
    ['Hb', 'WBC', 'Plt', 'Lactate', 'BT']
  ),
];

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientOverviewPanelState on State<ErFlowHomeWidget> {
  /// แท็บของการ์ดแผนการดูแล
  int _clyPlanTab = 0;

  /// ปิดการ์ดแจ้งเตือนมุมซ้ายล่างแล้ว
  bool _clyInsightHidden = false;
}

extension _FeaturesPatientOverviewPanelPart on _ErFlowHomeWidgetState {
  /// ค่าหนึ่งตัวสำหรับการ์ดค่าที่ต้องจับตา: ชื่อ ค่าแสดง หน่วย ค่าจริง ต่ำ สูง
  List<(String, String, String, double, double, double)> _clyValues() {
    final c = _case;
    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    return [
      ('HR', f(c.hr.last), 'bpm', c.hr.last, 60, 100),
      ('BP', c.bp, 'mmHg', c.sbp.last, 90, 140),
      ('SpO₂', f(c.spo2.last), '%', c.spo2.last, 94, 100),
      ('RR', f(c.rr.last), '/min', c.rr.last, 12, 20),
      ('BT', f(c.bt.last), '°C', c.bt.last, 36.0, 37.5),
      for (final l in c.labs) (l.name, f(l.value), '', l.value, l.lo, l.hi),
    ];
  }

  /// การ์ดแจ้งเตือนมุมซ้ายล่าง (แบบ "New insights")
  Widget _clyInsight() {
    final n = _followTasks.where((t) => !_taskDone.contains(t.title)).length;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C3AA3), _cyInsight, Color(0xFF00135A)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        foregroundDecoration: const _InnerGloss(14.0, dark: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const Icon(Icons.checklist_rounded,
                  size: 18.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text('$n',
                  style:
                      _num(24.0, color: Colors.white, weight: FontWeight.w500)),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text('งานที่ต้องติดตาม',
                    style: _t(12.0, color: Colors.white)),
              ),
              _Press(
                child: GestureDetector(
                  onTap: () => setState(() => _clyInsightHidden = true),
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: const BoxDecoration(
                        color: Color(0x33FFFFFF), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        size: 12.0, color: Colors.white),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 4.0),
            Text(
                'คำสั่งแพทย์และหัตถการที่รอติดตาม ตั้งเตือนเพื่อกลับมาดูผู้ป่วย',
                style: _t(10.0, color: const Color(0xE6FFFFFF), height: 1.35)),
            const SizedBox(height: 10.0),
            _clyInsightBtn('ดูงานทั้งหมด', Icons.arrow_forward_rounded,
                _cyBtnLight, () => setState(() => _detailTab = 3)),
            const SizedBox(height: 6.0),
            _clyInsightBtn('ปิด', Icons.close_rounded, _cyBtnGrey,
                () => setState(() => _clyInsightHidden = true)),
          ],
        ),
      ),
    );
  }

  Widget _clyInsightBtn(
          String label, IconData icon, Color bg, VoidCallback onTap) =>
      _Press(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 32.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: bg == _panel ? null : bg,
              gradient: bg == _panel ? _glossWhite : null,
              borderRadius: BorderRadius.circular(8.0),
            ),
            foregroundDecoration: _InnerGloss(8.0, dark: bg != _panel),
            child: Row(children: [
              Expanded(
                  child: Text(label,
                      style: _t(11.5,
                          color: bg == _panel ? _blue : _pInk,
                          weight: FontWeight.w600))),
              Icon(icon, size: 14.0, color: bg == _panel ? _blue : _pInk),
            ]),
          ),
        ),
      );

  // ---- แผงขวา

  Widget _clyPanel() {
    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: _clyTabs(),
          ),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey('cly$_detailTab$_tableView'),
              child: _clyTabBody() ??
                  ListView(
                    padding: const EdgeInsets.all(12.0),
                    children: [
                      _clyCc(),
                      const SizedBox(height: 10.0),
                      _clyVitals(),
                      const SizedBox(height: 10.0),
                      _clyLabs(),
                      const SizedBox(height: 10.0),
                      _clyPlan(),
                      const SizedBox(height: 10.0),
                      _clyBanner(),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// เนื้อหาการ์ดขวาของแท็บอื่นนอกจากภาพรวม (null = ภาพรวม)
  Widget? _clyTabBody() {
    final table = _tabTables[_detailTab];
    if (table != null && (_tableOnly || (_hasToggle && _tableView))) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: ErDetailTable(hn: _caseP().hn, tab: table),
      );
    }
    return switch (_detailTab) {
      2 => ListView(
          padding: const EdgeInsets.all(12.0),
          children: _examPanelItems(),
        ),
      3 => ListView(
          padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 12.0),
          // เลือก Order Set / ติ๊กสั่ง ย้ายไปอยู่ใน workflow ขั้น "วินิจฉัย/สั่ง"
          // แท็บนี้เหลือดูสถานะคำสั่ง + งานที่ต้องติดตาม
          children: [_orderRecord()],
        ),
      8 => _kbPanel(),
      _ => null,
    };
  }

  /// แท็บของหน้าผู้ป่วย ย้ายจากแถบบนมาอยู่หัวการ์ดขวา
  Widget _clyTabs() => Container(
        padding: const EdgeInsets.all(3.0),
        decoration: _clyCardDeco,
        foregroundDecoration: const _InnerGloss(12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < _detailTabs.length; i++) _detailTabItem(i),
          ]),
        ),
      );

  /// พื้นการ์ดแบบมีมิติ: แสงจากซ้ายบนไล่ลงขวาล่าง + เงาลอยนุ่ม
  BoxDecoration get _clyCardDeco => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFF4F6F9),
            Color(0xFFEBEEF3),
          ],
          stops: [0.0, 0.18, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0B1B3F).withValues(alpha: 0.06),
              blurRadius: 18.0,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: const Color(0xFF0B1B3F).withValues(alpha: 0.05),
              blurRadius: 2.0,
              offset: const Offset(0, 1)),
        ],
      );

  /// พื้นการ์ดย่อย (ค่าแต่ละตัว) นูนน้อยกว่าการ์ดใหญ่
  BoxDecoration _clyTileDeco({Color edge = _line}) => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFF3F5F8)],
        ),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: edge),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0B1B3F).withValues(alpha: 0.06),
              blurRadius: 6.0,
              offset: const Offset(0, 2)),
        ],
      );

  /// การ์ด "แผนการดูแล" แท็บ: ข้อมูลเดิมของเคสเท่านั้น
  Widget _clyPlan() {
    final c = _case;
    final todo = [
      if (c.nextStep.isNotEmpty) (c.nextStep, c.nextDetail, 'ขั้นถัดไป'),
      for (final a in c.advice) (a, '', 'คำแนะนำ'),
    ];
    final cautions = [
      for (final a in c.allergies) (a, 'แพ้ยา / แพ้อาหาร', true),
      for (final u in c.underlying) (u, 'โรคประจำตัว', false),
    ];
    final labs = [
      for (final v in _clyValues())
        if (c.labs.any((l) => l.name == v.$1)) v,
    ];
    final tabs = [
      ('สิ่งที่ต้องทำ', todo.length),
      ('วินิจฉัย', c.dx.length),
      ('ยา', c.meds.length),
      ('แล็บ', labs.length),
      ('ภาพถ่าย', c.imaging.length),
      ('กิจกรรม', c.events.length),
      ('ข้อควรระวัง', cautions.length),
    ];
    final tab = _clyPlanTab.clamp(0, tabs.length - 1);
    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    final List<Widget> cards;
    final String empty;
    switch (tab) {
      case 0:
        empty = 'ยังไม่มีแผน';
        cards = [
          for (final t in todo)
            _clyPlanCard(Icons.task_alt_rounded, t.$1, t.$2, t.$3),
        ];
      case 1:
        empty = 'ยังไม่มีการวินิจฉัย';
        cards = [
          for (final d in c.dx)
            _clyPlanCard(
                Icons.assignment_outlined, d.text, '', d.icd10 ?? 'ไม่ระบุรหัส',
                mark: _levelColor(d.level)),
        ];
      case 2:
        empty = 'ยังไม่ได้ให้ยา';
        cards = [
          for (final m in c.meds)
            _clyPlanCard(
                Icons.medication_outlined, m.name, m.route, '${m.time} น.'),
        ];
      case 3:
        empty = 'ยังไม่มีผลแล็บ';
        cards = [
          for (final v in labs)
            _clyPlanCard(
              Icons.science_outlined,
              '${v.$1}  ${v.$2}',
              'ค่าอ้างอิง ${f(v.$5)}–${f(v.$6)}',
              v.$4 > v.$6 ? 'สูง (H)' : (v.$4 < v.$5 ? 'ต่ำ (L)' : 'ปกติ'),
              alert: v.$4 > v.$6 || v.$4 < v.$5,
            ),
        ];
      case 4:
        empty = 'ยังไม่ได้ส่งภาพถ่าย';
        cards = [
          for (final img in c.imaging)
            _clyPlanCard(Icons.image_outlined, img.name, img.result, 'ภาพถ่าย',
                image: img.asset),
        ];
      case 5:
        empty = 'ยังไม่มีกิจกรรม';
        cards = [
          for (final e in c.events.reversed)
            _clyPlanCard(Icons.history_rounded, e.text, '${e.time} น.',
                e.byDoctor ? 'แพทย์' : 'พยาบาล'),
        ];
      default:
        empty = 'ไม่มีข้อควรระวัง';
        cards = [
          for (final x in cautions)
            _clyPlanCard(
                x.$3 ? Icons.block_rounded : Icons.monitor_heart_outlined,
                x.$1,
                '',
                x.$2,
                alert: x.$3),
        ];
    }
    final body = cards.isEmpty ? _clyEmpty(empty) : _clyCardGrid(cards);
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 12.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('แผนการดูแล',
              style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(9.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (var i = 0; i < tabs.length; i++)
                  _Press(
                    child: GestureDetector(
                      onTap: () => setState(() => _clyPlanTab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 26.0,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          gradient: tab == i ? _glossWhite : null,
                          borderRadius: BorderRadius.circular(7.0),
                          boxShadow: tab == i
                              ? _glossLift(const Color(0xFF0B1B3F))
                              : null,
                        ),
                        foregroundDecoration:
                            tab == i ? const _InnerGloss(7.0) : null,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(tabs[i].$1,
                              style: _t(10.5,
                                  color: tab == i ? _inkTitle : _ink2)),
                          if (tabs[i].$2 > 0) ...[
                            const SizedBox(width: 4.0),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: tab == i ? _panelSoft : Colors.white,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: Text('${tabs[i].$2}',
                                  style: _num(9.0, color: _ink2)),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 10.0),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(key: ValueKey(tab), child: body),
          ),
        ],
      ),
    );
  }

  /// การ์ดสัญญาณชีพ: ค่าล่าสุด + แท่งย้อนหลังเล็ก ๆ ต่อค่า
  /// อาการสำคัญ (CC) ตัวเต็ม ย้ายจากแถบบนมาไว้บนสุดของภาพรวม
  Widget _clyCc() {
    final c = _case;
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('อาการสำคัญ (CC)',
              style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
          const SizedBox(height: 6.0),
          Text(c.cc.isEmpty ? '—' : c.cc,
              style: _t(12.5,
                  color: _inkTitle, weight: FontWeight.w600, height: 1.4)),
        ],
      ),
    );
  }

  Widget _clyVitals() {
    final vs = _caseVitals();
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text('สัญญาณชีพ',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
            ),
            Text('ล่าสุด ${_case.times.last} น.', style: _t(9.5, color: _ink3)),
            const SizedBox(width: 6.0),
            _Press(
              child: GestureDetector(
                onTap: () => setState(() => _detailTab = 4),
                child: Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    gradient: _glossWhite,
                    borderRadius: BorderRadius.circular(7.0),
                    border: Border.all(color: _line),
                    boxShadow: _glossLift(const Color(0xFF0B1B3F)),
                  ),
                  foregroundDecoration: const _InnerGloss(7.0),
                  child: const Icon(Icons.north_east_rounded,
                      size: 14.0, color: _inkTitle),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8.0),
          Row(children: [
            for (var i = 0; i < vs.length; i++) ...[
              if (i > 0) const SizedBox(width: 6.0),
              Expanded(child: _clyVitalTile(vs[i])),
            ],
          ]),
        ],
      ),
    );
  }

  /// การ์ดผลแล็บล่าสุด: ค่า · H/L · ช่วงอ้างอิง · ตำแหน่งเทียบช่วงปกติ
  Widget _clyLabs() {
    final labs = _case.labs;
    const per = 5;
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text('ผลแล็บ',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
            ),
            if (labs.isNotEmpty) ...[
              Text(
                  'ผิดปกติ ${labs.where((l) => l.value < l.lo || l.value > l.hi).length}/${labs.length}',
                  style: _t(9.5, color: _ink3)),
              const SizedBox(width: 6.0),
            ],
            _Press(
              child: GestureDetector(
                onTap: () => setState(() => _detailTab = 6),
                child: Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    gradient: _glossWhite,
                    borderRadius: BorderRadius.circular(7.0),
                    border: Border.all(color: _line),
                    boxShadow: _glossLift(const Color(0xFF0B1B3F)),
                  ),
                  foregroundDecoration: const _InnerGloss(7.0),
                  child: const Icon(Icons.north_east_rounded,
                      size: 14.0, color: _inkTitle),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8.0),
          if (labs.isEmpty)
            Text('ยังไม่มีผลแล็บ', style: _t(11.0, color: _ink3))
          else
            for (var i = 0; i < labs.length; i += per)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0.0 : 6.0),
                child: Row(children: [
                  for (var j = i; j < i + per; j++) ...[
                    if (j > i) const SizedBox(width: 6.0),
                    Expanded(
                        child: j < labs.length
                            ? _clyLabTile(labs[j])
                            : const SizedBox.shrink()),
                  ],
                ]),
              ),
        ],
      ),
    );
  }

  Widget _clyLabTile(ErLab l) {
    final hi = l.value > l.hi, lo = l.value < l.lo;
    final bad = hi || lo;
    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 8.0),
      decoration: _clyTileDeco(),
      foregroundDecoration: const _InnerGloss(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(l.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(9.5, color: _ink2)),
            ),
            // ป้าย H/L แบบรายงานแล็บ (เหมือนการ์ดแล็บเดิม)
            if (bad)
              Container(
                width: 15.0,
                height: 15.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: _glossGrad(_red),
                  borderRadius: BorderRadius.circular(4.0),
                  boxShadow: _glossLift(_red),
                ),
                foregroundDecoration: const _InnerGloss(4.0, dark: true),
                child: Text(hi ? 'H' : 'L',
                    style:
                        _t(8.5, color: Colors.white, weight: FontWeight.w800)),
              ),
          ]),
          const SizedBox(height: 2.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(f(l.value),
                      style: _num(15.0,
                          color: bad ? _red : _inkTitle,
                          weight: FontWeight.w600)),
                  Text(' | ', style: _t(9.0, color: _ink3)),
                  Text(f(l.hi), style: _num(9.5, color: _ink3)),
                ]),
          ),
          const SizedBox(height: 6.0),
          _labDots(l.value, l.hi, bad, dots: 10),
        ],
      ),
    );
  }

  /// แถบจุดของค่าแล็บ (แบบเดิมจากการ์ดแล็บ ผัง 181:3803)
  /// จุดถี่ ๆ บอกระดับ ขีดคั่นคือเพดานปกติ จุดที่เลยขีดคือส่วนที่ผิดปกติ
  Widget _labDots(double value, double hi, bool bad, {int dots = 16}) {
    final tone = bad ? _red : _blue;
    final scale = hi * 1.45;
    final filled = ((value / scale) * dots).round().clamp(0, dots);
    final markAt = ((hi / scale) * dots).round().clamp(1, dots - 1);
    return Container(
      height: 12.0,
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(children: [
        for (var i = 0; i < dots; i++) ...[
          if (i == markAt)
            Container(
              width: 1.2,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              color: _ink3,
            ),
          Expanded(
            child: Center(
              child: Container(
                width: 3.0,
                height: 3.0,
                decoration: BoxDecoration(
                  color: i < filled ? tone : _ink3.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _clyVitalTile(ErVital v) {
    final bad = v.color == _red;
    final hi = v.series.reduce((a, b) => a > b ? a : b);
    final lo = v.series.reduce((a, b) => a < b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 7.0),
      decoration: _clyTileDeco(),
      foregroundDecoration: const _InnerGloss(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(v.icon, size: 11.0, color: bad ? _red : _ink3),
            const SizedBox(width: 3.0),
            Text(v.label, style: _t(9.5, color: _ink2)),
          ]),
          const SizedBox(height: 2.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(v.display ?? _vsValue(v, v.series.length - 1),
                      style: _num(15.0,
                          color: bad ? _red : _inkTitle,
                          weight: FontWeight.w600)),
                  const SizedBox(width: 2.0),
                  Text(v.unit, style: _t(8.0, color: _ink3)),
                ]),
          ),
          const SizedBox(height: 5.0),
          SizedBox(
            height: 16.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < v.series.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2.0),
                  Expanded(
                    child: Container(
                      height: 4.0 +
                          12.0 *
                              (hi == lo ? 0.5 : (v.series[i] - lo) / (hi - lo)),
                      decoration: BoxDecoration(
                        color: i == v.series.length - 1
                            ? (bad ? _red : _blue)
                            : _g5.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _clyEmpty(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(text, style: _t(11.0, color: _ink3)),
      );

  /// กริด 3 คอลัมน์ การ์ดในแถวเดียวกันสูงเท่ากัน
  Widget _clyCardGrid(List<Widget> items) => Column(children: [
        for (var i = 0; i < items.length; i += 3)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0.0 : 8.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = i; j < i + 3; j++) ...[
                    if (j > i) const SizedBox(width: 8.0),
                    Expanded(
                        child: j < items.length
                            ? items[j]
                            : const SizedBox.shrink()),
                  ],
                ],
              ),
            ),
          ),
      ]);

  /// การ์ดมาตรฐานของแผงแท็บ: ไอคอน (หรือภาพ) · หัวข้อ · รายละเอียด · ชิป
  Widget _clyPlanCard(IconData icon, String title, String desc, String chip,
          {bool alert = false, Color? mark, String? image}) =>
      Container(
        padding: const EdgeInsets.all(10.0),
        decoration:
            _clyTileDeco(edge: alert ? _red.withValues(alpha: 0.35) : _line),
        foregroundDecoration: const _InnerGloss(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(7.0),
                child: Container(
                  height: 64.0,
                  width: double.infinity,
                  color: Colors.black,
                  child: Image.asset(image, fit: BoxFit.cover),
                ),
              )
            else
              Row(children: [
                Icon(icon, size: 15.0, color: alert ? _red : _ink2),
                if (mark != null) ...[
                  const SizedBox(width: 6.0),
                  Container(
                    width: 7.0,
                    height: 7.0,
                    decoration:
                        BoxDecoration(color: mark, shape: BoxShape.circle),
                  ),
                ],
              ]),
            const SizedBox(height: 6.0),
            Text(title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: _t(11.0,
                    color: alert ? _red : _inkTitle,
                    weight: FontWeight.w600,
                    height: 1.3)),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text(desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(9.5, color: _ink3, height: 1.3)),
            ],
            const Spacer(),
            const SizedBox(height: 8.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
              decoration: BoxDecoration(
                gradient: _glossWhite,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(
                    color: alert ? _red.withValues(alpha: 0.35) : _line),
              ),
              foregroundDecoration: const _InnerGloss(100.0),
              child: Text(chip, style: _t(9.0, color: alert ? _red : _ink2)),
            ),
          ],
        ),
      );

  /// แถบล่างของแผง: ขั้นถัดไป + ปุ่มไปคำสั่งแพทย์
  Widget _clyBanner() {
    final c = _case;
    if (c.nextStep.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _cyEdge),
      ),
      child: Row(children: [
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child:
              const Icon(Icons.event_note_rounded, size: 20.0, color: _cySlate),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ขั้นถัดไป: ${c.nextStep}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(11.5, color: _inkTitle, weight: FontWeight.w600)),
              if (c.nextDetail.isNotEmpty)
                Text(c.nextDetail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(9.5, color: _ink2)),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        _Press(
          child: GestureDetector(
            onTap: () => setState(() => _detailTab = 3),
            child: Container(
              height: 28.0,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                gradient: _glossGrad(_cySlate),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: _glossLift(_cySlate),
              ),
              foregroundDecoration: const _InnerGloss(8.0, dark: true),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('ไปที่คำสั่งแพทย์',
                    style:
                        _t(10.5, color: Colors.white, weight: FontWeight.w600)),
                const SizedBox(width: 4.0),
                const Icon(Icons.chevron_right_rounded,
                    size: 14.0, color: Colors.white),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
