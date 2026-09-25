// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

const Color _cyBgTop = Color(0xFFF1F3F4);
const Color _cyBgBottom = Color(0xFFF1F3F4);
const Color _cyGlass = _panel;
const Color _cyEdge = _line;
const Color _cySlate = _blue;

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

  /// อาการสำคัญของผู้บันทึกที่เลือกดู: HN → ลำดับ (ไม่มี = ล่าสุด)
  final Map<String, int> _ccPick = {};

  /// visit ที่เลือกดูผล Lab: HN → ลำดับ (0 = วันนี้)
  final Map<String, int> _labVisit = {};

  /// visit ที่เลือกดู HPI ในการ์ด CC: HN → ลำดับ (0 = วันนี้)
  final Map<String, int> _hpiVisit = {};

  /// ผล Lab ที่เลือกไว้เปรียบเทียบข้าม visit (ชื่อรายการ)
  final Set<String> _labSel = {};
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
      for (final l in c.labs)
        if (l.isNumeric) (l.name, f(l.value), '', l.value, l.lo, l.hi),
    ];
  }

  // ---- แผงขวา

  Widget _clyPanel() {
    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: _clyTabs(),
          ),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(
                  'cly$_detailTab$_tableView${_orderEditing ?? ''}${_tplOn ? 'tpl' : ''}'),
              // เลือกรายการใน Order Set แล้ว: แผงขวาเป็นฟอร์มกรอกรายละเอียดของรายการนั้น
              child: (_tplOn ? _tplOrders() : null) ??
                  (_orderEditing != null && _speechOpen
                      ? ListView(
                          padding: const EdgeInsets.all(12.0),
                          children: [_orderEditorCard()],
                        )
                      : null) ??
                  _clyTabBody() ??
                  _clyBento(),
            ),
          ),
        ],
      ),
    );
  }

  /// เนื้อหาการ์ดขวาของแท็บอื่นนอกจากภาพรวม (null = ภาพรวม)
  Widget? _clyTabBody() {
    // แท็บแล็บ: เลือกรายการเปรียบเทียบข้าม visit ก่อน แล้วตามด้วยตารางผลเต็ม
    if (_detailTab == 6) {
      return ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          _labTabCompare(),
          const SizedBox(height: 10.0),
          ErDetailTable(hn: _caseP().hn, tab: ErTab.labs),
        ],
      );
    }
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
      9 => _emrTab(),
      10 => _progressTab(),
      _ => null,
    };
  }

  /// แท็บของหน้าผู้ป่วย ย้ายจากแถบบนมาอยู่หัวการ์ดขวา
  Widget _clyTabs() => Container(
        padding: const EdgeInsets.all(3.0),
        decoration: _clyCardDeco,
        foregroundDecoration: const _InnerGloss(12.0),
        // ทุกปุ่มกว้างเท่ากัน เต็มแถบ
        child: Row(children: [
          for (var i = 0; i < _barTabs; i++) Expanded(child: _detailTabItem(i)),
        ]),
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
  /// อาการสำคัญ (บันทึกได้หลายคน เลือกดูของแต่ละคน) + HPI
  Widget _clyCc() {
    final c = _case;
    final recs = erCcRecords(c);
    // -1 = สรุปโดย AI (เปรียบเทียบทุกผู้บันทึก)
    // ค่าเริ่ม = สรุป AI (-1) เมื่อมีผู้บันทึกหลายคน
    final ai = recs.length > 1 && (_ccPick[c.hn] ?? -1) == -1;
    final at = recs.isEmpty
        ? 0
        : (_ccPick[c.hn] ?? recs.length - 1).clamp(0, recs.length - 1);
    // HPI ที่แพทย์บันทึกใน workflow ก่อน · ไม่มีใช้ของเดิมในแฟ้ม
    String hpi = c.hpi;
    if (_speechHn == c.hn) {
      for (final m in _filled) {
        final v = (m['HPI'] ?? '').trim();
        // ยังเป็น template ที่มีช่อง [ ] ค้าง = ยังเขียนไม่เสร็จ ใช้ของในแฟ้มก่อน
        if (v.isNotEmpty && (!v.contains('[') || c.hpi.isEmpty)) {
          hpi = v;
          break;
        }
      }
    }
    // ตัวเลือกผู้บันทึกเป็น avatar · วงกรมท่า = กำลังดู
    Widget sel(bool on, Widget child, VoidCallback onTap) => _Press(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: on ? _blue : _line, width: 2.0),
              ),
              child: child,
            ),
          ),
        );
    Widget aiChip() => sel(
        ai,
        Container(
          width: 26.0,
          height: 26.0,
          decoration: BoxDecoration(
            gradient: _glossGrad(_blue),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              size: 13.0, color: Colors.white),
        ),
        () => setState(() => _ccPick[c.hn] = -1));
    Widget pick(int i) => sel(!ai && i == at, _ccAvatar(recs[i], 26.0),
        () => setState(() => _ccPick[c.hn] = i));

    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('อาการสำคัญ',
                maxLines: 1,
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
            const SizedBox(width: 6.0),
            _copyBtn('CC + HPI',
                () => 'CC: ${recs.isEmpty ? c.cc : recs[at].text}\nHPI: $hpi'),
            const Spacer(),
            // ผู้บันทึกหลายคน: แตะ avatar เพื่อดูของแต่ละคน · ✦ = สรุป AI
            if (recs.length > 1) ...[
              aiChip(),
              const SizedBox(width: 4.0),
              // avatar ซ้อนกัน · คนที่กำลังดูอยู่บนสุด
              SizedBox(
                width: 34.0 + (recs.length - 1) * 20.0,
                height: 34.0,
                child: Stack(children: [
                  for (final i in [
                    for (var k = 0; k < recs.length; k++)
                      if (ai || k != at) k,
                    if (!ai) at,
                  ])
                    Positioned(left: i * 20.0, top: 0.0, child: pick(i)),
                ]),
              ),
            ],
          ]),
          const SizedBox(height: 6.0),
          if (ai)
            _ccAiView(c.hn, recs)
          else ...[
            if (recs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(children: [
                  _ccAvatar(recs[at], 18.0),
                  const SizedBox(width: 6.0),
                  Text(
                      '${recs[at].who} · ${recs[at].role} · ${recs[at].time} น.',
                      style: _t(10.0, color: _ink2, weight: FontWeight.w600)),
                ]),
              ),
            _copyable(
                'CC',
                recs.isEmpty ? c.cc : recs[at].text,
                Text(recs.isEmpty ? '—' : recs[at].text,
                    style: _t(12.5,
                        color: _inkTitle,
                        weight: FontWeight.w600,
                        height: 1.4))),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _progressInsert(
                  'CC: ${recs.isEmpty ? c.cc : (ai ? recs.last.text : recs[at].text)}\nHPI: $hpi'),
              icon: const Icon(Icons.post_add_rounded, size: 15.0),
              label: Text('ใส่ CC + HPI ใน progress note',
                  style: _t(10.0, color: _blue, weight: FontWeight.w700)),
            ),
          ),
          const Divider(height: 10.0, color: _line),
          // HPI แยกตาม visit: วันนี้ + visit ก่อนหน้า (แสดง CC ของ visit นั้นด้วย)
          Builder(builder: (context) {
            final hv = erHpiVisits(c);
            final hi = (_hpiVisit[c.hn] ?? 0).clamp(0, hv.length - 1);
            String short(String d) {
              const m = [
                'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
                'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
              ];
              final p = d.split('/');
              if (p.length != 3) return d;
              return '${int.parse(p[0])} ${m[int.parse(p[1]) - 1]} ${p[2].substring(2)}';
            }

            final text = hi == 0 ? hpi : hv[hi].hpi;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                      spacing: 5.0,
                      runSpacing: 5.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('ประวัติปัจจุบัน (HPI)',
                            style: _t(11.0,
                                color: _ink2, weight: FontWeight.w600)),
                        _copyBtn('HPI', () => text),
                        if (hv.length > 1)
                          for (var i = 0; i < hv.length; i++)
                            _chip(
                                i == 0 ? 'วันนี้' : short(hv[i].date),
                                i == hi,
                                () => setState(() => _hpiVisit[c.hn] = i)),
                      ]),
                  const SizedBox(height: 4.0),
                  if (hi > 0) ...[
                    Text('${hv[hi].place} · ${hv[hi].date}',
                        style: _t(9.5, color: _ink3)),
                    const SizedBox(height: 2.0),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: 'CC  ',
                          style:
                              _t(10.5, color: _ink2, weight: FontWeight.w700)),
                      TextSpan(
                          text: hv[hi].cc,
                          style: _t(11.5,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ])),
                    const SizedBox(height: 2.0),
                  ],
                  _copyable(
                      'HPI',
                      text,
                      Text(text.isEmpty ? 'ยังไม่ได้บันทึก' : text,
                          style: _t(11.5,
                              color: text.isEmpty ? _ink3 : _ink,
                              height: 1.45))),
                ]);
          }),
        ],
      ),
    );
  }

  Widget _clyVitals() {
    // Pulse (ชีพจรคลำ) ต่อจาก HR · ข้อมูลจำลองยังไม่มีค่า PR แยก ใช้ค่าชุดเดียวกับ HR
    final base = _caseVitals();
    final hr = _case.hr;
    final vs = [
      ...base.take(1),
      if (hr.isNotEmpty)
        ErVital(
            icon: Icons.back_hand_rounded,
            label: 'Pulse',
            unit: 'bpm',
            series: hr,
            color: (hr.last < 60 || hr.last > 100) ? _red : _ink),
      ...base.skip(1),
    ];
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
            _vsRecheckBtn(),
            const SizedBox(width: 6.0),
            _copyBtn('V/S', _vsText),
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
          // ค่าร่างกาย (น้ำหนัก ส่วนสูง BMI BSA) อยู่บน stat card
          _bodyRow(),
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

  /// สัดส่วนร่างกายใต้สัญญาณชีพ: น้ำหนัก · ส่วนสูง · BMI · BSA (มีหน่วยทุกค่า)
  /// ปุ่มขอวัดสัญญาณชีพซ้ำ · ขอแล้ว = ป้ายสถานะ "ขอวัดซ้ำแล้ว hh:mm" (รอพยาบาล)
  Widget _vsRecheckBtn() {
    final req = _vsRecheck;
    return _Press(
      child: GestureDetector(
        // เปิดลิ้นชักกรอกค่า (ขอให้พยาบาลวัดได้จากในลิ้นชัก)
        onTap: _openVsDrawer,
        child: Container(
          height: 26.0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            gradient: req == null ? _glossGrad(_blue) : null,
            color: req == null ? null : _blue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7.0),
            boxShadow: req == null ? _glossLift(_blue) : null,
          ),
          foregroundDecoration:
              req == null ? const _InnerGloss(7.0, dark: true) : null,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(req == null ? Icons.replay_rounded : Icons.schedule_rounded,
                size: 13.0, color: req == null ? Colors.white : _blue),
            const SizedBox(width: 4.0),
            Text(req == null ? 'วัดซ้ำ' : 'ขอวัดซ้ำแล้ว ${req.time} น.',
                style: _t(10.0,
                    color: req == null ? Colors.white : _blue,
                    weight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  /// icon ของ HOSxP+ (glyph ขาวพื้นโปร่ง ย้อมสีได้) ตามชื่อค่าสัญญาณชีพ/ร่างกาย
  static const Map<String, String> _vsGlyph = {
    'HR': 'assets/images/heart-rate_(1).png',
    'Pulse': 'assets/images/pulse-rate.png',
    'BP': 'assets/images/blood-pressure_(1).png',
    'SpO₂': 'assets/images/o2.png',
    'RR': 'assets/images/lungs_(1).png',
    'BT': 'assets/images/thermometer.png',
    'น้ำหนัก': 'assets/images/weight-scale_(1).png',
    'ส่วนสูง': 'assets/images/height_(1).png',
    'BMI': 'assets/images/bmi.png',
  };

  Widget _vsIcon(String label, IconData fallback, double size, Color color) {
    final a = _vsGlyph[label];
    if (a == null) return Icon(fallback, size: size, color: color);
    return Image.asset(a,
        width: size,
        height: size,
        color: color,
        colorBlendMode: BlendMode.srcIn,
        errorBuilder: (_, __, ___) => Icon(fallback, size: size, color: color));
  }

  Widget _bodyRow() {
    final b = erBody(_case);
    String n1(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    final bt = _case.bt.last;
    // ค่าผิดปกติเป็นแดง: BT นอก 36.0–37.5 °C · BMI นอก 18.5–24.9 (WHO)
    // น้ำหนัก / ส่วนสูง / BSA ไม่มีช่วงปกติตายตัว
    final items = [
      ('น้ำหนัก', n1(b.kg), 'kg', false),
      ('ส่วนสูง', '${b.cm}', 'cm', false),
      // อุณหภูมิล่าสุด ต่อจากส่วนสูง
      ('BT', n1(bt), '°C', bt < 36.0 || bt > 37.5),
      ('BMI', b.bmi.toStringAsFixed(1), 'kg/m²', b.bmi < 18.5 || b.bmi >= 25.0),
      ('BSA', b.bsa.toStringAsFixed(2), 'm²', false),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
                width: 1.0,
                height: 18.0,
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                color: _line),
          Expanded(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: _vsIcon(items[i].$1, Icons.straighten_rounded, 13.0,
                        items[i].$4 ? _red : _ink3),
                  ),
                  Text(items[i].$1,
                      style: _t(10.5, color: items[i].$4 ? _red : _ink3)),
                  const SizedBox(width: 5.0),
                  Text(items[i].$2,
                      style: _num(14.0,
                          color: items[i].$4 ? _red : _inkTitle,
                          weight: FontWeight.w600)),
                  const SizedBox(width: 2.0),
                  Text(items[i].$3, style: _t(9.5, color: _ink3)),
                ]),
          ),
        ],
      ]),
    );
  }

  /// การ์ดผลแล็บล่าสุด: ค่า · H/L · ช่วงอ้างอิง · ตำแหน่งเทียบช่วงปกติ
  Widget _clyLabs() {
    final visits = erLabVisits(_case);
    final vi = (_labVisit[_case.hn] ?? 0).clamp(0, visits.length - 1);
    // toggle eGFR: แสดงเฉพาะ lab ใน profile ไต (eGFR คำนวณจาก Cr + BUN Cr Na K Cl HCO₃)
    final labs =
        _sortLabs(_egfrOn ? _egfrProfile(visits[vi].labs) : visits[vi].labs);
    const per = 5;
    // วันที่ 23/09/2569 → 23 ก.ย. 69
    String short(String d) {
      const m = [
        'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
      ];
      final p = d.split('/');
      if (p.length != 3) return d;
      return '${int.parse(p[0])} ${m[int.parse(p[1]) - 1]} ${p[2].substring(2)}';
    }

    Widget visitChip(int i) {
      final on = i == vi;
      return Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: _Press(
          child: Material(
            color: on ? _blue : _panelSoft,
            borderRadius: BorderRadius.circular(100.0),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _labVisit[_case.hn] = i),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
                child: Text(i == 0 ? 'วันนี้' : short(visits[i].date),
                    style: _t(9.5,
                        color: on ? Colors.white : _ink2,
                        weight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Text('ผลแล็บ',
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
            const SizedBox(width: 8.0),
            // eGFR เป็น profile ที่ดูประจำ: เปิด/ปิดแถวได้
            _egfrToggle(),
            const SizedBox(width: 10.0),
            // เลือกดูตามวันที่มา visit (วันนี้ = visit นี้)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (var i = 0; i < visits.length; i++) visitChip(i),
                ]),
              ),
            ),
            if (labs.isNotEmpty) ...[
              _copyBtn(_egfrOn ? 'Lab (eGFR)' : 'Lab',
                  () => labs.map(_labCopy).join(', ')),
              const SizedBox(width: 6.0),
              Text(
                  'ผิดปกติ ${labs.where((l) => l.abnormal).length}/${labs.length}',
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
          if (vi > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('${visits[vi].place} · ${visits[vi].date}',
                  style: _t(9.5, color: _ink3)),
            ),
          const SizedBox(height: 8.0),
          if (labs.isEmpty)
            Text('ยังไม่มีผลแล็บ', style: _t(11.0, color: _ink3))
          else
            for (var i = 0; i < labs.length; i += per)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0.0 : 6.0),
                child: IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var j = i; j < i + per; j++) ...[
                          if (j > i) const SizedBox(width: 6.0),
                          Expanded(
                              child: j < labs.length
                                  ? _clyLabTile(labs[j])
                                  : const SizedBox.shrink()),
                        ],
                      ]),
                ),
              ),
        ],
      ),
    );
  }

  /// การ์ดผล Lab หนึ่งรายการ ตามชนิด: ตัวเลข (H/L + แถบจุด) · ข้อความ · ภาพ
  /// แตะ = เลือก/เอาออกจากการเปรียบเทียบ (วงกรมท่า = เลือกอยู่)
  Widget _clyLabTile(ErLab l, {bool pick = false}) {
    // pick = โหมดเลือกเปรียบเทียบ (แท็บแล็บ) · ภาพรวม: แตะแล้วไปเทียบที่แท็บแล็บ
    final on = pick && _labSel.contains(l.name);
    final hi = l.isNumeric && l.value > l.hi,
        lo = l.isNumeric && l.value < l.lo;
    final bad = l.abnormal;
    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
    Widget flag(String t) => Container(
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
          child: Text(t,
              style: _t(8.5, color: Colors.white, weight: FontWeight.w800)),
        );
    final body = switch (l.type) {
      ErLabType.numeric => [
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
                  // eGFR เกณฑ์ปกติเป็นขั้นต่ำ (≥ 60) ไม่ใช่เพดาน
                  Text(l.name == 'eGFR' ? '≥${f(l.lo)}' : f(l.hi),
                      style: _num(9.5, color: _ink3)),
                ]),
          ),
          const SizedBox(height: 6.0),
          _labDots(l.value, l.hi, bad, dots: 10),
        ],
      ErLabType.text => [
          Text(l.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _t(12.5,
                  color: bad ? _red : _inkTitle, weight: FontWeight.w600)),
        ],
      ErLabType.image => [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: Image.asset(l.image,
                height: 34.0, width: double.infinity, fit: BoxFit.cover),
          ),
          if (l.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3.0),
              child: Text(l.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(9.5,
                      color: bad ? _red : _ink2, weight: FontWeight.w600)),
            ),
        ],
    };
    return _Press(
      child: GestureDetector(
        onLongPress: () => _copyText(l.name, _labCopy(l)),
        onTap: () => setState(() {
          if (!pick) {
            _labSel
              ..clear()
              ..add(l.name);
            _detailTab = 6;
          } else if (on) {
            _labSel.remove(l.name);
          } else {
            _labSel.add(l.name);
          }
        }),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 8.0),
          decoration: _clyTileDeco(edge: on ? _blue : _line).copyWith(
              border:
                  Border.all(color: on ? _blue : _line, width: on ? 1.6 : 1.0)),
          foregroundDecoration: const _InnerGloss(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                if (l.type != ErLabType.numeric) ...[
                  Icon(
                      l.type == ErLabType.image
                          ? Icons.image_rounded
                          : Icons.notes_rounded,
                      size: 11.0,
                      color: _ink3),
                  const SizedBox(width: 3.0),
                ],
                Expanded(
                  child: Text(l.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(9.5, color: _ink2)),
                ),
                // ป้าย H/L แบบรายงานแล็บ · ข้อความ/ภาพที่ผิดปกติ = !
                if (hi || lo) flag(hi ? 'H' : 'L') else if (bad) flag('!'),
                // ผลใหม่ที่ยังไม่เปิดดู
                if (_labNewOf(_case.hn).contains(l.name)) ...[
                  const SizedBox(width: 4.0),
                  _newDot(8.0),
                ],
              ]),
              const SizedBox(height: 2.0),
              ...body,
            ],
          ),
        ),
      ),
    );
  }

  /// การ์ดเปรียบเทียบในแท็บแล็บ: กริดผลล่าสุด (แตะเลือกได้หลายรายการ) + ตารางข้าม visit
  Widget _labTabCompare() {
    final visits = erLabVisits(_case);
    final names = <String>{};
    final latest = <ErLab>[
      for (final v in visits)
        for (final l in v.labs)
          if (names.add(l.name)) l
    ];
    const per = 5;
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('เปรียบเทียบผล Lab',
            style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        for (var i = 0; i < latest.length; i += per)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0.0 : 6.0),
            child: IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = i; j < i + per; j++) ...[
                      if (j > i) const SizedBox(width: 6.0),
                      Expanded(
                          child: j < latest.length
                              ? _clyLabTile(latest[j], pick: true)
                              : const SizedBox.shrink()),
                    ],
                  ]),
            ),
          ),
        if (_labSel.isNotEmpty) _labCompare(visits),
      ]),
    );
  }

  /// ตารางเปรียบเทียบผล Lab ที่เลือก ข้าม visit (เก่า → ใหม่) + การเปลี่ยนแปลงล่าสุด
  Widget _labCompare(
      List<({String date, String place, List<ErLab> labs})> visits) {
    final cols = visits.reversed.toList(); // เก่า → ใหม่
    String short(String d) {
      const m = [
        'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
        'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
      ];
      final p = d.split('/');
      if (p.length != 3) return d;
      return '${int.parse(p[0])} ${m[int.parse(p[1]) - 1]} ${p[2].substring(2)}';
    }

    ErLab? at(int c, String name) {
      for (final l in cols[c].labs) {
        if (l.name == name) return l;
      }
      return null;
    }

    String f(double x) =>
        x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);

    Widget cell(ErLab? l) {
      if (l == null) return Text('—', style: _t(11.0, color: _ink3));
      if (l.type == ErLabType.image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: Image.asset(l.image, height: 56.0, fit: BoxFit.cover),
        );
      }
      return Text(l.resultText,
          style: _num(12.0,
              color: l.abnormal ? _red : _inkTitle, weight: FontWeight.w600));
    }

    // การเปลี่ยนแปลง: ครั้งล่าสุดเทียบครั้งก่อนหน้าที่มีผล
    Widget change(String name) {
      final seq = [
        for (var c = 0; c < cols.length; c++)
          if (at(c, name) case final l?) l
      ];
      if (seq.length < 2) {
        return Text('ครั้งแรก', style: _t(10.0, color: _ink3));
      }
      final a = seq[seq.length - 2], b = seq.last;
      if (b.isNumeric && a.isNumeric) {
        final d = b.value - a.value;
        if (d == 0) return Text('คงเดิม', style: _t(10.0, color: _ink3));
        final pct = a.value == 0 ? 0 : (d / a.value * 100).round();
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
              d > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 12.0,
              color: b.abnormal ? _red : _ink2),
          Text('${f(d.abs())} (${pct.abs()}%)',
              style: _num(10.5,
                  color: b.abnormal ? _red : _ink2, weight: FontWeight.w600)),
        ]);
      }
      final same = a.resultText == b.resultText;
      return Text(same ? 'คงเดิม' : 'เปลี่ยน',
          style: _t(10.0,
              color: same ? _ink3 : (b.abnormal ? _red : _ink2),
              weight: FontWeight.w600));
    }

    final names = [
      for (final v in visits)
        for (final l in v.labs)
          if (_labSel.contains(l.name)) l.name
    ].toSet().toList();

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.compare_arrows_rounded, size: 14.0, color: _ink2),
          const SizedBox(width: 5.0),
          Expanded(
            child: Text('เปรียบเทียบการเปลี่ยนแปลง',
                style: _t(10.5, color: _ink2, weight: FontWeight.w700)),
          ),
          InkWell(
            onTap: () => setState(_labSel.clear),
            child: Text('ล้าง',
                style: _t(10.0, color: _blue, weight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 6.0),
        Table(
          columnWidths: {
            0: const FlexColumnWidth(1.6),
            for (var c = 0; c < cols.length; c++)
              c + 1: const FlexColumnWidth(),
            cols.length + 1: const FlexColumnWidth(1.3),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              Text('รายการ', style: _t(9.5, color: _ink3)),
              for (var c = 0; c < cols.length; c++)
                Text(c == cols.length - 1 ? 'วันนี้' : short(cols[c].date),
                    style: _t(9.5,
                        color: c == cols.length - 1 ? _blue : _ink3,
                        weight: FontWeight.w600)),
              Text('เปลี่ยนแปลง', style: _t(9.5, color: _ink3)),
            ]),
            for (final n in names)
              TableRow(
                decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: _line))),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Text(n,
                        style: _t(10.5,
                            color: _inkTitle, weight: FontWeight.w600)),
                  ),
                  for (var c = 0; c < cols.length; c++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: cell(at(c, n)),
                    ),
                  change(n),
                ],
              ),
          ],
        ),
      ]),
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

  /// stat card สัญญาณชีพ: แตะ/ลากบนแท่งเพื่อเลือกรอบการวัด · แตะสองครั้ง = กลับล่าสุด
  /// หัวการ์ดแสดงค่าและเวลาของรอบที่เลือก · ใต้แท่งมีเวลาวัดทุกรอบ
  /// การ์ดค่าสัญญาณชีพหนึ่งค่า · of = เคสอื่น (การ์ดรายเตียง) ไม่ใส่ = เคสที่เปิดอยู่
  Widget _clyVitalTile(ErVital v, {ErCase? of, bool big = false}) {
    final n = v.series.length;
    final ts = (of ?? _case).times;
    final pick = (_vsPick[v.label] ?? n - 1).clamp(0, n - 1);
    final latest = pick == n - 1;
    final bad = v.color == _red;
    String timeAt(int i) => i < ts.length ? ts[i] : '';
    void choose(double dx, double w) {
      final i = (dx / w * n).floor().clamp(0, n - 1);
      if (i != _vsPick[v.label]) setState(() => _vsPick[v.label] = i);
    }

    // ค่าล่าสุดผิดปกติ: การ์ดพื้นแดงไล่เฉด ตัวอักษร/กราฟเป็นขาว
    const w1 = Colors.white;
    final dim = Colors.white.withValues(alpha: 0.8);
    final fillC = bad
        ? Colors.white.withValues(alpha: 0.38)
        : _blue.withValues(alpha: 0.22);
    // กราฟเต็มการ์ด: หัว/ค่ามี padding · กราฟ + เวลาชิดขอบซ้ายขวาล่าง
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: bad
          ? BoxDecoration(
              gradient: _glossGrad(_red),
              borderRadius: BorderRadius.circular(10.0),
              border: latest ? null : Border.all(color: w1, width: 1.5),
              boxShadow: _glossLift(_red),
            )
          : _clyTileDeco(edge: latest ? _line : _blue.withValues(alpha: 0.4)),
      foregroundDecoration: _InnerGloss(10.0, dark: bad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 7.0, 8.0, 0.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _vsIcon(v.label, v.icon, 13.0, bad ? w1 : _blue),
                const SizedBox(width: 3.0),
                Text(v.label,
                    maxLines: 1,
                    softWrap: false,
                    style: _t(9.5, color: bad ? w1 : _ink2)),
                const SizedBox(width: 4.0),
                // เวลาสัมพัทธ์ของรอบที่ดูอยู่ (เวลาจริงอยู่ใต้กราฟ) · ย่อเองถ้าที่ไม่พอ
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(_ago(timeAt(pick)),
                        style: _t(9.0,
                            color: bad ? dim : (latest ? _ink3 : _blue),
                            weight: FontWeight.w600)),
                  ),
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
                      Text(
                          latest
                              ? (v.display ?? _vsValue(v, pick, of))
                              : _vsValue(v, pick, of),
                          style: _num(15.0,
                              color: bad ? w1 : _inkTitle,
                              weight: FontWeight.w600)),
                      const SizedBox(width: 2.0),
                      Text(v.unit, style: _t(8.0, color: bad ? dim : _ink3)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 2.0),
          LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => choose(d.localPosition.dx, w),
              onHorizontalDragUpdate: (d) => choose(d.localPosition.dx, w),
              onDoubleTap: () => setState(() => _vsPick.remove(v.label)),
              child: Column(children: [
                // กราฟเส้น: จุดทุกรอบ + ค่ากำกับ · รอบที่เลือก = จุดใหญ่
                SizedBox(
                  height: big ? 80.0 : 46.0,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _VsSpark(
                      values: v.series,
                      // BP: เส้นตัวล่าง (diastolic) คู่กับตัวบน
                      values2: v.unit == 'mmHg' ? (of ?? _case).dbp : null,
                      labels: [
                        for (var i = 0; i < n; i++)
                          v.unit == 'mmHg'
                              ? v.series[i].round().toString()
                              : _vsValue(v, i, of),
                      ],
                      pick: pick,
                      ink: bad ? w1 : _blue,
                      faint: bad ? Colors.white.withValues(alpha: 0.55) : _ink3,
                      fill: fillC,
                    ),
                  ),
                ),
                // เวลาวัดของแต่ละรอบ
                Container(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 5.0),
                  child: Row(children: [
                    for (var i = 0; i < n; i++) ...[
                      if (i > 0) const SizedBox(width: 2.0),
                      Expanded(
                        // จุดเยอะ (การ์ดแคบ): แสดงแค่เวลาแรก · ล่าสุด · ที่เลือก ขนาดเต็ม
                        // ล้นเข้าช่องว่างข้าง ๆ ได้ ไม่ย่อจนอ่านไม่ออก
                        child: Align(
                          alignment: n > 3 && i == 0
                              ? Alignment.centerLeft
                              : n > 3 && i == n - 1
                                  ? Alignment.centerRight
                                  : Alignment.center,
                          child: Text(
                              n <= 3 ||
                                      i == pick ||
                                      (i == 0 && pick != 1) ||
                                      (i == n - 1 && pick != n - 2)
                                  ? timeAt(i)
                                  : '',
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: _num(8.0,
                                  color: bad
                                      ? (i == pick ? w1 : dim)
                                      : (i == pick ? _blue : _ink3),
                                  weight: i == pick
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                        ),
                      ),
                    ],
                  ]),
                ),
              ]),
            );
          }),
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

/// กราฟเส้นสัญญาณชีพในการ์ด: แบ่งช่องเท่ากันตามจำนวนรอบ (ตรงกับแถวเวลาใต้กราฟ)
/// พื้นใต้เส้นไล่จาง · จุดทุกรอบ + ค่ากำกับเหนือจุด · รอบที่เลือกจุดใหญ่ตัวหนา
/// values2 = เส้นที่สอง (BP ตัวล่าง) ค่ากำกับอยู่ใต้จุด
class _VsSpark extends CustomPainter {
  _VsSpark({
    required this.values,
    required this.labels,
    required this.pick,
    required this.ink,
    required this.faint,
    required this.fill,
    this.values2,
  });

  final List<double> values;
  final List<String> labels;
  final int pick;
  final Color ink;
  final Color faint;
  final Color fill;
  final List<double>? values2;

  /// เส้นโค้ง monotone (Fritsch–Carlson) ผ่านทุกจุด ต่อปลายถึงขอบตามความชัน
  static (Path, List<Offset>) _curve(List<Offset> pts, Size size, double top) {
    final n = pts.length;
    double edgeY(Offset a, Offset b, double x) {
      if ((b.dx - a.dx).abs() < 0.01) return a.dy;
      final y = a.dy + (b.dy - a.dy) * (x - a.dx) / (b.dx - a.dx);
      return y.clamp(top, size.height - 1.0);
    }

    final left = Offset(0.0, n > 1 ? edgeY(pts[0], pts[1], 0.0) : pts[0].dy);
    final right = Offset(size.width,
        n > 1 ? edgeY(pts[n - 2], pts[n - 1], size.width) : pts[0].dy);
    final c = [left, ...pts, right];
    final m = c.length;
    final d = [
      for (var i = 0; i < m - 1; i++)
        (c[i + 1].dy - c[i].dy) / (c[i + 1].dx - c[i].dx)
    ];
    final t = List<double>.filled(m, 0.0);
    t[0] = d[0];
    t[m - 1] = d[m - 2];
    for (var i = 1; i < m - 1; i++) {
      t[i] = d[i - 1] * d[i] <= 0 ? 0.0 : (d[i - 1] + d[i]) / 2;
    }
    for (var i = 0; i < m - 1; i++) {
      if (d[i] == 0) {
        t[i] = 0.0;
        t[i + 1] = 0.0;
        continue;
      }
      final a0 = t[i] / d[i], b0 = t[i + 1] / d[i];
      final h = a0 * a0 + b0 * b0;
      if (h > 9.0) {
        final k = 3.0 / math.sqrt(h);
        t[i] = k * a0 * d[i];
        t[i + 1] = k * b0 * d[i];
      }
    }
    final line = Path()..moveTo(c[0].dx, c[0].dy);
    for (var i = 0; i < m - 1; i++) {
      final dx = (c[i + 1].dx - c[i].dx) / 3;
      line.cubicTo(c[i].dx + dx, c[i].dy + t[i] * dx, c[i + 1].dx - dx,
          c[i + 1].dy - t[i + 1] * dx, c[i + 1].dx, c[i + 1].dy);
    }
    return (line, c);
  }

  void _label(Canvas canvas, String s, Offset p, bool on, double cw,
      {bool below = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: 'IBMPlexSansThaiLooped',
          fontSize: on ? 9.0 : 8.0,
          fontWeight: on ? FontWeight.w700 : FontWeight.w500,
          color: on ? ink : faint,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: cw + 6.0);
    tp.paint(
        canvas,
        Offset(p.dx - tp.width / 2,
            below ? p.dy + 4.0 : math.max(0.0, p.dy - 5.0 - tp.height)));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    final two = values2 != null && values2!.length == n;
    // สองเส้น: เว้นล่างให้ค่ากำกับใต้เส้นล่าง
    final top = 13.0, bottom = two ? 14.0 : 4.0;
    final all = [...values, if (two) ...values2!];
    final hi = all.reduce(math.max), lo = all.reduce(math.min);
    final span = hi - lo == 0 ? 1.0 : hi - lo;
    final cw = size.width / n;
    Offset at(double v, int i) => Offset(
        cw * (i + 0.5),
        hi == lo
            ? (top + size.height - bottom) / 2
            : top + (size.height - top - bottom) * (1 - (v - lo) / span));
    final pts = [for (var i = 0; i < n; i++) at(values[i], i)];
    final (line, chain) = _curve(pts, size, top);
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height)
      ..close();
    // ไล่จากสีเต็มที่จุดสูงสุดของเส้น ลงไปโปร่งใสที่ขอบล่าง
    final topY = chain.map((p) => p.dy).reduce(math.min);
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fill, fill.withValues(alpha: 0.0)],
          ).createShader(Rect.fromLTRB(0.0, topY, size.width, size.height)));
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, stroke);
    List<Offset> pts2 = const [];
    if (two) {
      pts2 = [for (var i = 0; i < n; i++) at(values2![i], i)];
      final (line2, _) = _curve(pts2, size, top);
      canvas.drawPath(
          line2,
          stroke
            ..color = ink.withValues(alpha: 0.6)
            ..strokeWidth = 1.4);
    }
    void dot(Offset p, bool on) {
      canvas.drawCircle(p, on ? 3.6 : 2.2, Paint()..color = ink);
      if (on) {
        canvas.drawCircle(
            p,
            3.6,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
      }
    }

    for (var i = 0; i < n; i++) {
      final on = i == pick;
      dot(pts[i], on);
      _label(canvas, labels[i], pts[i], on, cw);
      if (two) {
        dot(pts2[i], on);
        _label(canvas, values2![i].round().toString(), pts2[i], on, cw,
            below: true);
      }
    }
  }

  @override
  bool shouldRepaint(_VsSpark o) =>
      o.pick != pick ||
      o.ink != ink ||
      o.values.join(',') != values.join(',') ||
      o.labels.join(',') != labels.join(',') ||
      (o.values2 ?? const []).join(',') != (values2 ?? const []).join(',');
}
