// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientOrdersTabState on State<ErFlowHomeWidget> {
  String _template = 'Sepsis';
  final Set<String> _orderPicked = {
    'Piperacillin + Tazobactam 4.5 g',
    '0.9% NSS 1,000 mL',
    'Blood culture ×2',
    'CBC',
    'BUN / Cr',
    'Lactate',
    'Chest X-ray',
    'Oxygen cannula 3 L/min',
  };
  int _followTab = 0;

  /// ใบคำสั่ง (generative task list): รายการที่ติ๊ก (ชุด|ข้อความ) + ค่าในช่องเว้นว่าง
  final Set<String> _soTick = {};
  final Map<String, String> _soBlank = {};

  /// สลับแผงซ้ายไปแท็บคำสั่งแพทย์แล้วของเคสไหน (เข้าขั้นสั่งการรักษาครั้งแรก)
  String? _soTabAuto;

  /// แถวชุดที่ใช้บ่อย (เลื่อนแนวนอน) · ปุ่มถัดไปเลื่อนทีละใบ
  final ScrollController _recentScroll = ScrollController();
}

extension _FeaturesPatientOrdersTabPart on _ErFlowHomeWidgetState {
  // ---------------------------------------------- คำสั่งแพทย์ (Order set)

  /// คอลัมน์ซ้าย: เลือกชุดคำสั่ง แล้วติ๊กรายการ
  Widget _orderLeft() => SizedBox(
        width: 400.0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 6.0, 12.0),
          children: _orderLeftItems(),
        ),
      );

  /// เนื้อหาคอลัมน์ซ้ายของคำสั่งแพทย์ (ใช้ทั้งแบบลอยและในการ์ดขวา)
  List<Widget> _orderLeftItems() => [
        _orderSetPicker(),
        ..._orderGroupsAndSave(),
      ];

  /// รายการคำสั่งตามกลุ่ม (ยา/เลือด/แล็บ/...) + ปุ่มบันทึกคำสั่ง
  List<Widget> _orderGroupsAndSave({bool save = true}) => [
        // ประเภทที่มี template แบบ progress note ไม่ใช้ชุดติ๊กในหน้านี้
        if ((_orderTemplatesOf[_template] ?? const [])
            .every((t) => t.$1 == 'inline')) ...[
          for (final g in _orderGroups) _orderGroupCard(g),
          if (save) _orderSaveBtn(),
        ],
      ];

  /// การ์ดซ้อน (stacked card) แบบการ์ดคำสั่งแพทย์: แถบสีหัวการ์ด + แผ่นขาวทับ
  /// มุมโค้งบนของแผ่นขาวเผยสีแถบด้านหลัง · หัวซ้าย = ชื่อ ขวา = ข้อมูลรอง/ปุ่ม
  Widget _stackCard({
    required String title,
    IconData? icon,
    String? count,
    Widget? trailing,
    Color band = _blue,
    EdgeInsets pad = const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
    required Widget child,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: band,
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.antiAlias,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 9.0, 12.0, 9.0),
            child: Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 15.0, color: Colors.white),
                const SizedBox(width: 6.0),
              ],
              // ชื่อยาวได้เต็มที่ เหลือที่ให้ปุ่มขวา (ไม่แบ่งครึ่งกับ Spacer)
              Expanded(
                child: Row(children: [
                  Flexible(
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 6.0),
                    Text(count,
                        style: _num(11.0,
                            color: const Color(0xB3FFFFFF),
                            weight: FontWeight.w600)),
                  ],
                ]),
              ),
              if (trailing != null) trailing,
            ]),
          ),
          Container(
            padding: pad,
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: child,
          ),
        ]),
      );

  /// การ์ดเลือก Order Set แบบ preset: ชื่อชุดที่ใช้อยู่ + ภาพแฟ้มซ้อนขวา
  /// action เดียว = แตะเพื่อเปิด sheet เลือกชุด (P9 หนึ่งแผงหนึ่ง action)
  Widget _orderSetPicker() => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 6.0),
              child: Text('ORDER SET',
                  style: _t(10.5, color: _ink3, weight: FontWeight.w600)
                      .copyWith(letterSpacing: 0.8)),
            ),
            _Press(
              scale: 0.98,
              child: GestureDetector(
                onTap: _orderSetSheet,
                child: Container(
                  height: 84.0,
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: _line),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(children: [
                    const Positioned(
                      right: 14.0,
                      top: 10.0,
                      bottom: -18.0,
                      width: 132.0,
                      child: _PresetStack(),
                    ),
                    Positioned(
                      left: 18.0,
                      top: 0.0,
                      bottom: 0.0,
                      right: 150.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_template,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(17.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          const SizedBox(height: 2.0),
                          Text('ดูและเลือกชุดคำสั่ง',
                              style: _t(12.0,
                                  color: _ink3, weight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      );

  /// sheet เลือก Order Set: การ์ดทุกชุด แตะแล้วปิด sheet
  void _orderSetSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
          maxWidth: 580.0,
          maxHeight: MediaQuery.of(context).size.height * 0.85),
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 28.0),
        decoration: const BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('เลือก Order Set',
                style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 2.0),
            Text('ชุดคำสั่งตามโรค เลือกแล้วติ๊กเฉพาะรายการที่ต้องการ',
                style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            const SizedBox(height: 6.0),
            Flexible(
              child: StatefulBuilder(
                builder: (ctx2, set) => SingleChildScrollView(
                  child: GestureDetector(
                    // แตะเลือกชุดในตารางแล้วปิด sheet
                    onTapUp: (_) =>
                        Future.delayed(const Duration(milliseconds: 160), () {
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _orderSetGrid().skip(2).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// หน้า Order Set ใน workflow (Figma 330-2): การ์ดใหญ่เลือกชุด · ที่ใช้บ่อย · ชุดทั้งหมด
  /// การติ๊กรายการจริงอยู่ในหน้าย่อยของ stepper (ยา / Lab / X-ray / หัตถการ)
  /// ขั้นสั่งการรักษา (Figma 331-350): เลือกชุด standing order + ลำดับคำสั่งที่หยิบมา
  /// ใบคำสั่งแสดงในแท็บคำสั่งแพทย์ฝั่งซ้าย แตะรายการที่นั่นเพื่อหยิบมาเรียงที่นี่
  List<Widget> _orderSetPage() {
    // เข้าขั้นนี้: สลับแผงซ้ายไปแท็บคำสั่งแพทย์ (ใบคำสั่งให้หยิบ) ครั้งเดียวต่อการเข้า
    if (_detailTab != 3 && _soTabAuto != _caseP().hn) {
      _soTabAuto = _caseP().hn;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _detailTab = 3);
      });
    }
    final picked = [
      for (final k in _soTick)
        if (k.startsWith('$_template|')) k
    ];
    return [
      _soSetRow(),
      const SizedBox(height: 18.0),
      Row(children: [
        Expanded(
          child: Text('ลำดับคำสั่งแพทย์',
              style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
        ),
        if (picked.isNotEmpty)
          Text('${picked.length} รายการ', style: _t(11.0, color: _ink3)),
      ]),
      const SizedBox(height: 8.0),
      if (picked.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: _line),
          ),
          child: Column(children: [
            const Icon(Icons.touch_app_rounded, size: 26.0, color: _ink3),
            const SizedBox(height: 8.0),
            Text('แตะรายการในใบคำสั่งทางซ้ายเพื่อหยิบมาสั่ง',
                textAlign: TextAlign.center, style: _t(12.0, color: _ink2)),
            Text('เรียงตามลำดับที่หยิบ', style: _t(10.5, color: _ink3)),
          ]),
        )
      else
        for (var i = 0; i < picked.length; i++) _soQueueRow(i + 1, picked[i]),
    ];
  }

  /// แถว "Standing order | ชื่อชุด" แตะเพื่อเปลี่ยนชุด (sheet การ์ดทุกชุด)
  Widget _soSetRow() => _Press(
        scale: 0.98,
        child: GestureDetector(
          onTap: _orderSetSheet,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 12.0, 14.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: _line),
            ),
            child: Row(children: [
              Text('Standing order', style: _t(12.0, color: _ink3)),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(_soDocOf(_template)?.title ?? _setName(_template),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _t(13.5, color: _inkTitle, weight: FontWeight.w600)),
              ),
              const SizedBox(width: 6.0),
              const Icon(Icons.unfold_more_rounded, size: 18.0, color: _ink3),
            ]),
          ),
        ),
      );

  /// คำสั่งที่หยิบมาหนึ่งแถว: ลำดับ · ข้อความ (ช่องเว้นว่างที่กรอกแล้ว) · เอาออก
  Widget _soQueueRow(int no, String key) {
    var text = key.substring(key.indexOf('|') + 1);
    var n = 0;
    text = text.replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) {
      final v = _soBlank['$key#${n++}'];
      return (v == null || v.isEmpty) ? '…… ${m.group(1)}' : '$v ${m.group(1)}';
    });
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 6.0, 10.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _line),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 22.0,
          height: 22.0,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
          child: Text('$no',
              style: _num(11.0, color: Colors.white, weight: FontWeight.w600)),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(text, style: _t(12.0, color: _inkTitle, height: 1.4)),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _soTick.remove(key)),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.close_rounded, size: 16.0, color: _ink3),
          ),
        ),
      ]),
    );
  }

  /// เดิม: การ์ดใหญ่ + ที่ใช้บ่อย + ตารางทุกชุด (ตอนนี้อยู่ใน sheet เปลี่ยนชุด)
  List<Widget> _orderSetGrid() => [
        _orderSetHero(),
        const SizedBox(height: 12.0),
        Row(children: [
          Expanded(
            child: Text('ที่ใช้บ่อย',
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
          Text('7 วันล่าสุด', style: _t(11.0, color: _ink3)),
        ]),
        const SizedBox(height: 6.0),
        // ล้นออกถึงขอบแผงทั้งสองข้าง (เห็นใบถัดไปโผล่ = เลื่อนได้)
        // ปุ่มย้อน/ถัดไปลอยซ้ายขวา โผล่เฉพาะเมื่อเลื่อนไปทางนั้นได้
        LayoutBuilder(
          builder: (context, box) => SizedBox(
            height: 54.0,
            child: OverflowBox(
              minWidth: box.maxWidth + 32.0,
              maxWidth: box.maxWidth + 32.0,
              child: Stack(children: [
                ListView(
                  controller: _recentScroll,
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 56.0, 0.0),
                  children: [
                    for (final cat in const [
                      'Sepsis',
                      'Chest Pain',
                      'Trauma',
                      'Stroke Fast Tract',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: _orderSetRecent(cat),
                      ),
                  ],
                ),
                Positioned(
                    left: 10.0,
                    top: 0.0,
                    bottom: 0.0,
                    child: Center(child: _recentArrow(-1))),
                Positioned(
                    right: 10.0,
                    top: 0.0,
                    bottom: 0.0,
                    child: Center(child: _recentArrow(1))),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 14.0),
        Row(children: [
          Expanded(
            child: Text('ชุดคำสั่งทั้งหมด',
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
          Text('พบ ${_setCats.length} ชุด', style: _t(11.0, color: _ink3)),
        ]),
        const SizedBox(height: 6.0),
        for (var i = 0; i < _setCats.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _orderSetCard(_setCats[i])),
                    const SizedBox(width: 8.0),
                    Expanded(
                        child: i + 1 < _setCats.length
                            ? _orderSetCard(_setCats[i + 1])
                            : const SizedBox.shrink()),
                  ]),
            ),
          ),
      ];

  /// รายการชุดในหน้า Order Set: Stroke แยกเป็น Fast Tract (rt-PA) กับ Non Fast Tract
  List<String> get _setCats => [
        for (final c in _templates)
          if (c == 'Stroke') ...const [
            'Stroke Fast Tract',
            'Stroke Non Fast Tract'
          ] else
            c
      ];

  /// ชื่อชุดคำสั่งที่แสดง: "ใช้บ่อย" เป็นหมวด ไม่ใช่ชื่อชุด จึงแสดงเป็นชุดทั่วไป
  /// ชุดแบบ template ใช้ชื่อ template (เช่น Standing order Snake bite)
  String _setName(String cat) {
    if (cat == 'ใช้บ่อย') return 'General Emergency';
    final tpl = _orderTemplatesOf[cat];
    return tpl != null && tpl.first.$1 != 'inline' ? tpl.first.$2 : cat;
  }

  /// ปุ่มวงกลมเลื่อนแถวที่ใช้บ่อยทีละใบ · dir -1 = ย้อน 1 = ถัดไป
  /// ซ่อนเมื่อสุดทางด้านนั้นแล้ว
  Widget _recentArrow(int dir) => ListenableBuilder(
        listenable: _recentScroll,
        builder: (context, _) {
          final c = _recentScroll;
          final ready = c.hasClients && c.position.hasContentDimensions;
          final show = ready &&
              (dir < 0
                  ? c.offset > 4.0
                  : c.offset < c.position.maxScrollExtent - 4.0);
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: show ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !show,
              child: _Press(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    c.animateTo(
                        (c.offset + 150.0 * dir)
                            .clamp(0.0, c.position.maxScrollExtent),
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic);
                  },
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: _panel,
                      shape: BoxShape.circle,
                      border: Border.all(color: _line),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 10.0,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: Icon(
                        dir < 0
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        size: 22.0,
                        color: _inkTitle),
                  ),
                ),
              ),
            ),
          );
        },
      );

  /// เลือกชุด: ชุดในหน้า (inline) = ตั้งเป็นชุดปัจจุบัน · ชุดแบบ template = เปิด template
  void _orderSetPick(String cat) {
    HapticFeedback.selectionClick();
    final tpl = _orderTemplatesOf[cat];
    if (tpl != null && tpl.first.$1 != 'inline') {
      _tplEnter(tpl.first.$1);
      return;
    }
    setState(() {
      _template = cat;
      _orderEditing = null;
    });
  }

  /// การ์ดใหญ่หัวหน้า: ชื่อชุดที่ใช้อยู่ + จำนวนชุดที่มี · แตะเปิด sheet เลือกชุด
  Widget _orderSetHero() => _Press(
        scale: 0.98,
        child: GestureDetector(
          onTap: _orderSetSheet,
          child: Container(
            height: 108.0,
            margin: const EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(color: _line),
            ),
            child: Stack(clipBehavior: Clip.none, children: [
              // ภาพแฟ้มเอกสาร: แผ่นหลัง + กระดาษโผล่ + กระเป๋าหน้าโปร่งแสง
              const Positioned(
                right: 14.0,
                top: 10.0,
                width: 104.0,
                height: 88.0,
                child: _FolderArt(),
              ),
              Positioned(
                left: 16.0,
                top: 14.0,
                right: 120.0,
                bottom: 14.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('เลือก ORDER SET',
                        maxLines: 1,
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                    const SizedBox(height: 2.0),
                    Text('ชุดคำสั่งตามโรค สั่งครบในครั้งเดียว',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0, color: _ink3)),
                    const Spacer(),
                    _aiFillBtn(),
                  ],
                ),
              ),
            ]),
          ),
        ),
      );

  /// การ์ดชุดที่ใช้บ่อย: ป้าย "ชื่อชุดคำสั่ง" + ชื่อ + ไอคอนเอกสาร
  Widget _orderSetRecent(String cat) {
    final on = cat == _template;
    return _Press(
      child: GestureDetector(
        onTap: () => _orderSetPick(cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          // กว้างตามชื่อชุด (ไม่ fix ความกว้าง) · ยาวสุด 200
          constraints: const BoxConstraints(maxWidth: 200.0),
          padding: const EdgeInsets.fromLTRB(12.0, 7.0, 12.0, 7.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(14.0),
            border:
                Border.all(color: on ? _blue : _line, width: on ? 1.5 : 1.0),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ชื่อชุดคำสั่ง', style: _t(9.5, color: _ink3)),
                  Text(_setName(cat),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 14.0),
            Icon(
                on
                    ? Icons.check_circle_rounded
                    : Icons.insert_drive_file_outlined,
                size: 20.0,
                color: on ? _blue : _inkTitle),
          ]),
        ),
      ),
    );
  }

  /// หน้าของการ์ดชุดคำสั่ง (หมวด, รายการ) · Sepsis ใช้รายการจริงของชุด
  List<(String, List<String>)> _orderSetPages(String cat) => switch (cat) {
        _ when _soDocs.containsKey(cat) => [
            for (final (code, title) in _soGroupTitles)
              if (_soDocs[cat]!.any((o) => o.$3 == code))
                (
                  title,
                  [
                    for (final o in _soDocs[cat]!)
                      if (o.$3 == code) o.$1
                  ]
                ),
          ],
        'Chest Pain' => const [
            (
              'ยา / เวชภัณฑ์',
              [
                'Aspirin 300 mg เคี้ยว',
                'Clopidogrel 300 mg',
                'Nitroglycerin 0.4 mg SL'
              ]
            ),
            ('แล็บ', ['Troponin T', 'CK-MB', 'Electrolytes']),
            ('ภาพถ่าย', ['EKG 12 leads', 'Chest X-ray']),
          ],
        'Stroke' => const [
            (
              'ยา / เวชภัณฑ์',
              [
                'Alteplase 0.9 mg/kg IV',
                'Labetalol 10 mg IV',
                '0.9% NSS 1,000 mL'
              ]
            ),
            ('แล็บ', ['CBC', 'PT / INR', 'Glucose']),
            ('ภาพถ่าย', ['CT brain non-contrast']),
          ],
        'Trauma' => const [
            (
              'ยา / เวชภัณฑ์',
              [
                'Tranexamic acid 1 g IV',
                "Ringer's lactate 1,000 mL",
                'Morphine 3 mg IV'
              ]
            ),
            ('แล็บ', ['CBC', 'G/M 2 units', 'Coagulation']),
            ('ภาพถ่าย', ['FAST', 'Chest X-ray', 'Pelvis X-ray']),
          ],
        'งูกัด' => const [
            (
              'ยา / เวชภัณฑ์',
              [
                'Antivenom ตามชนิดงู',
                'Tetanus toxoid 0.5 mL IM',
                'Paracetamol 500 mg'
              ]
            ),
            ('แล็บ', ['VCT 20 นาที', 'CBC', 'PT / INR']),
            ('หัตถการ', ['ล้างแผล', 'ดามแขนขาส่วนที่ถูกกัด']),
          ],
        _ => const [
            (
              'ยา / เวชภัณฑ์',
              ['Paracetamol 500 mg', 'Ondansetron 4 mg IV', '0.9% NSS 1,000 mL']
            ),
            ('แล็บ', ['CBC', 'Electrolytes', 'BUN / Cr']),
            ('ภาพถ่าย', ['Chest X-ray']),
          ],
      };

  /// การ์ดซ้อนของชุดคำสั่ง: หัว = ชื่อชุด + จุดบอกหน้า · แผ่นขาวทับ = รายการของหมวด
  /// เลื่อนหมวดเองทุก ~3 วินาที แบบการ์ดแจ้งเตือนหน้าภาพรวม · ชุดที่ใช้อยู่ หัวเป็นแถบกรมท่า
  Widget _orderSetCard(String cat) {
    final name = _setName(cat);
    return _Press(
      scale: 0.98,
      child: GestureDetector(
        onTap: () => _orderSetPick(cat),
        child: _SetCarousel(
          key: ValueKey('set-$cat'),
          name: name,
          on: cat == _template,
          pages: _orderSetPages(cat),
          // แต่ละใบเริ่มเลื่อนไม่พร้อมกัน ไม่กระพริบทั้งตาราง
          delay: Duration(milliseconds: 500 * _setCats.indexOf(cat)),
          label: _t(10.5, color: _ink3),
          item: _t(11.5, color: _ink2, weight: FontWeight.w500),
          title: _t(12.5, weight: FontWeight.w600),
        ),
      ),
    );
  }

  /// กลุ่มคำสั่งของหน้าย่อยใน stepper (จับคู่จากชื่อช่อง)
  List<_OrderGroup> _orderGroupsFor(String field) {
    final f = field.toLowerCase();
    // ชุด Sepsis ตามเอกสารจริง: แยกการ์ด One Day กับ Continuation ของหมวดนั้น
    final doc = _soDocs[_template];
    if (doc != null) {
      final code = f.contains('ยา')
          ? 'M'
          : f.contains('lab') || f.contains('แล็บ')
              ? 'L'
              : f.contains('x-ray') || f.contains('ภาพ')
                  ? 'X'
                  : f.contains('หัตถการ')
                      ? 'ห'
                      : f.contains('อื่น')
                          ? 'oth'
                          : null;
      if (code == null) return const [];
      _OrderGroup part(bool oneDay) => _OrderGroup(
            oneDay ? 'One Day' : 'Continuation',
            oneDay ? Icons.today_rounded : Icons.repeat_rounded,
            _blue,
            [
              for (final o in doc)
                if (o.$3 == code && o.$4 == oneDay)
                  _OrderItem(o.$1, o.$2, _OrderStatus.pending, '')
            ],
          );
      return [
        for (final g in [part(true), part(false)])
          if (g.items.isNotEmpty) g
      ];
    }
    bool has(String t) => _orderGroups.any((g) => g.title == t);
    final titles = f.contains('ยา')
        ? ['ยา / เวชภัณฑ์']
        : f.contains('lab') || f.contains('แล็บ')
            ? ['เลือด', 'แล็บ']
            : f.contains('x-ray') || f.contains('ภาพ')
                ? ['ภาพถ่าย']
                : f.contains('หัตถการ')
                    ? ['หัตถการ', 'Set OR (ผ่าตัด)']
                    : const <String>[];
    if (f.contains('อื่น')) return const [_otherOrders];
    return [
      for (final t in titles)
        if (has(t)) _orderGroups.firstWhere((g) => g.title == t)
    ];
  }

  /// รายการที่ AI แนะนำจากข้อมูลเคส: ทุกรายการในชุด ยกเว้นยาที่ผู้ป่วยแพ้
  /// (แพ้ Penicillin = ข้ามยากลุ่ม penicillin เช่น Piperacillin)
  List<String> _aiFillWant() {
    final allergy = _case.allergies.join(' ').toLowerCase();
    const penicillins = [
      'piperacillin',
      'amoxicillin',
      'ampicillin',
      'cloxacillin'
    ];
    bool skip(String name) {
      final n = name.toLowerCase();
      return allergy.contains('penicillin') && penicillins.any(n.contains);
    }

    return [
      for (final (_, items) in _orderSetPages(_template))
        for (final name in items)
          if (!skip(name)) name
    ];
  }

  /// ปุ่ม AI ในการ์ดเลือกชุด: เลือกชุดตามประเภทผู้ป่วย แล้วติ๊กรายการตามข้อมูลเคส
  Widget _aiFillBtn() => _Press(
        child: GestureDetector(
          onTap: _aiFillStart,
          child: _AiPill(
              label: 'AI แนะนำชุดคำสั่ง',
              style: _t(12.0, color: Colors.white, weight: FontWeight.w500)),
        ),
      );

  void _aiFillStart() {
    HapticFeedback.lightImpact();
    final byType = switch (_caseP().type) {
      _Ptype.sepsis => 'Sepsis',
      _Ptype.stemi => 'Chest Pain',
      _Ptype.stroke => 'Stroke Fast Tract',
      _Ptype.trauma => 'Trauma',
      _ => null,
    };
    setState(() {
      if (byType != null) _template = byType;
      // ล้างทั้งชุด (รวมยาที่แพ้ซึ่ง AI จะไม่เติมกลับ) แล้วติ๊กตามที่ AI แนะนำ
      for (final (_, items) in _orderSetPages(_template)) {
        _orderPicked.removeAll(items);
      }
      _orderEditing = null;
      _orderPicked.addAll(_aiFillWant());
    });
  }

  Widget _orderSaveBtn() => Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Material(
          color: _blue,
          borderRadius: BorderRadius.circular(12.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded,
                      size: 15.0, color: Colors.white),
                  const SizedBox(width: 7.0),
                  Text(
                      'บันทึกคำสั่งแพทย์ · เลือกแล้ว ${_orderPicked.length} รายการ',
                      style: _t(11.5,
                          color: Colors.white, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _chip(String label, bool on, VoidCallback onTap) => _Press(
          child: Material(
        color: on ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
            child: Text(label,
                style: _t(10.0,
                    color: on ? Colors.white : _ink2, weight: FontWeight.w600)),
          ),
        ),
      ));

  /// กลุ่มคำสั่งหนึ่งหมวด (ยา / เลือด / แล็บ / X-ray / หัตถการ)
  Widget _orderGroupCard(_OrderGroup g, {_OrderKind? kind}) {
    final picked = g.items.where((i) => _orderPicked.contains(i.name)).length;
    return _stackCard(
      title: g.title,
      icon: g.icon,
      count: '$picked/${g.items.length}',
      pad: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < g.items.length; i++) ...[
            _orderRow(g.items[i], kind ?? _orderKindOf(g)),
            if (i < g.items.length - 1)
              const Divider(height: 1.0, thickness: 1.0, color: _line),
          ],
        ],
      ),
    );
  }

  Widget _orderRow(_OrderItem it, [_OrderKind kind = _OrderKind.other]) {
    final on = _orderPicked.contains(it.name);
    final editing = _orderEditing == it.name;
    return InkWell(
      onTap: () {
        setState(() {
          if (on) {
            _orderPicked.remove(it.name);
            if (editing) _orderEditing = null;
          } else {
            _orderPicked.add(it.name);
          }
        });
        // เลือกแล้วกรอกรายละเอียดต่อที่แผงขวาทันที
        if (!on) _orderOpen(kind, it.name);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        // รายการที่กำลังกรอกอยู่ในแผงขวา: พื้นฟ้าจาง
        color: editing ? _blue.withValues(alpha: 0.05) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16.0,
              height: 16.0,
              margin: const EdgeInsets.only(top: 1.0, right: 8.0),
              decoration: BoxDecoration(
                color: on ? _blue : Colors.transparent,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: on ? _blue : _g5, width: 1.5),
              ),
              child: on
                  ? const Icon(Icons.check_rounded,
                      size: 12.0, color: Colors.white)
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(it.name,
                          style: _t(10.5,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ),
                    if (on && _orderDetail[it.name]?['stat'] == '1') ...[
                      const SizedBox(width: 6.0),
                      _statBadge(),
                    ],
                  ]),
                  Text(it.detail, style: _t(9.5, color: _ink3)),
                  if (on && kind != _OrderKind.other)
                    _orderDetailPill(kind, it.name),
                ],
              ),
            ),
            const SizedBox(width: 6.0),
            _orderStatus(it.status, it.time),
          ],
        ),
      ),
    );
  }

  /// ป้าย STAT ของยาที่ต้องให้ทันที
  Widget _statBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
        decoration: BoxDecoration(
          gradient: _glossGrad(_red),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Text('STAT',
            style: _t(8.5, color: Colors.white, weight: FontWeight.w700)),
      );

  Widget _orderStatus(_OrderStatus s, String time) {
    final (label, color) = switch (s) {
      _OrderStatus.pending => ('ยังไม่รับ', _g4),
      _OrderStatus.accepted => ('รับแล้ว', _blue),
      _OrderStatus.working => ('กำลังทำ', _blue),
      _OrderStatus.done => ('ทำแล้ว', _blue),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text(label,
              style: _t(9.0, color: color, weight: FontWeight.w700)),
        ),
        if (time.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(_clock(time), style: _num(8.5, color: _ink3)),
          ),
      ],
    );
  }

  /// แท็บคำสั่งแพทย์: ประวัติการบันทึก standing order ครั้งก่อน ๆ (อ่านอย่างเดียว)
  /// การบันทึกครั้งปัจจุบันทำใน workflow ขั้น "สั่งการรักษา" (แผงขวา)
  /// รอบใหม่อยู่บน · แต่ละรอบแยก One Day / Continuation + สถานะการทำ
  Widget _orderRecord() {
    // กำลังสั่งการรักษาใน workflow: แผงซ้ายเป็นใบคำสั่งให้แตะหยิบ
    if (_speechOpen && _steps[_speechStep].$2 == 'สั่งการรักษา') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0.0),
        child: _soSheet(scroll: false),
      );
    }
    final rounds = _soHistory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 8.0),
          child: Row(children: [
            Expanded(
              child: Text('ประวัติการบันทึก Standing order',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
            Text('${rounds.length} ครั้ง', style: _t(11.0, color: _ink3)),
          ]),
        ),
        for (var i = 0; i < rounds.length; i++)
          _soRoundCard(rounds[i], latest: i == 0),
      ],
    );
  }

  /// การ์ดหนึ่งรอบการบันทึก: หัว = ครั้งที่ เวลา ผู้สั่ง ชื่อชุด · เนื้อ = รายการแยกส่วน
  Widget _soRoundCard(_SoRound r, {bool latest = false}) {
    Widget part(
            String title, IconData icon, List<(String, String, String)> xs) =>
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 4.0),
            child: Row(children: [
              Icon(icon, size: 13.0, color: _ink3),
              const SizedBox(width: 5.0),
              Text('$title (${xs.length})',
                  style: _t(10.5, color: _ink3, weight: FontWeight.w600)),
            ]),
          ),
          for (final (name, detail, status) in xs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: _t(11.5,
                              color: _inkTitle, weight: FontWeight.w500)),
                      if (detail.isNotEmpty)
                        Text(detail, style: _t(9.5, color: _ink3)),
                    ],
                  ),
                ),
                _soStatus(status),
              ]),
            ),
        ]);
    final oneDay = [
      for (final o in r.items)
        if (o.$4) (o.$1, o.$2, o.$3)
    ];
    final cont = [
      for (final o in r.items)
        if (!o.$4) (o.$1, o.$2, o.$3)
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: latest ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: latest ? _blue : _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14.0, 9.0, 14.0, 9.0),
          child: Row(children: [
            Text('ครั้งที่ ${r.no}',
                style: _t(12.0,
                    color: latest ? Colors.white : _inkTitle,
                    weight: FontWeight.w600)),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text('${r.set} โดย ${r.by}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(11.0,
                      color: latest ? const Color(0xCCFFFFFF) : _ink3)),
            ),
            Text(_clock(r.time),
                style: _num(11.0,
                    color: latest ? Colors.white : _ink2,
                    weight: FontWeight.w600)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 10.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (oneDay.isNotEmpty) part('One Day', Icons.today_rounded, oneDay),
            if (cont.isNotEmpty)
              part('Continuation', Icons.repeat_rounded, cont),
          ]),
        ),
      ]),
    );
  }

  /// ป้ายสถานะการทำของคำสั่งที่บันทึกแล้ว: ทำแล้ว = เขียว · กำลังทำ = ฟ้า · รอรับ = เทา
  Widget _soStatus(String s) {
    final c = switch (s) {
      'ทำแล้ว' => _green,
      'กำลังทำ' => _blue,
      _ => _ink3,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Text(s, style: _t(9.5, color: c, weight: FontWeight.w600)),
    );
  }

  /// คอลัมน์ขวา: งานที่ต้องติดตาม (พยาบาลรอรับ / แพทย์ตรวจซ้ำ)
  Widget _orderRight() => SizedBox(
        width: 330.0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(6.0, 12.0, 12.0, 12.0),
          children: _orderRightItems(),
        ),
      );

  List<Widget> _orderRightItems() {
    final tasks = _sortTasks(_followTab == 0
        ? _allTasks.where((t) => !t.doctor)
        : _allTasks.where((t) => t.doctor));
    final nNurse = _allTasks.where((t) => !t.doctor).length;
    final nDoc = _allTasks.where((t) => t.doctor).length;
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist_rounded, size: 15.0, color: _blue),
                const SizedBox(width: 6.0),
                Text('งานที่ต้องติดตาม',
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8.0),
            _segmented(
              ['พยาบาลรอรับ $nNurse', 'แพทย์ตรวจซ้ำ $nDoc'],
              _followTab,
              (i) => setState(() => _followTab = i),
            ),
          ],
        ),
      ),
      _remListCard(),
      _todoCard(tasks),
    ];
  }
}

/// ภาพแฟ้มชุดคำสั่งซ้อนกัน 3 แผ่น (หลังลาย teal · กลางไล่สีน้ำเงินม่วง · หน้ากระดาษขาว)
class _PresetStack extends StatelessWidget {
  const _PresetStack();

  Widget _sheet({
    required Gradient fill,
    required double angle,
    required Offset at,
    bool lines = false,
    bool paper = false,
  }) =>
      Positioned(
        left: at.dx,
        top: at.dy,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: 74.0,
            height: 92.0,
            padding: const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 0.0),
            decoration: BoxDecoration(
              gradient: fill,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8.0,
                    offset: Offset(0, 3)),
              ],
            ),
            child: lines
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final w in [0.55, 0.9, 0.75, 0.9, 0.6])
                        Container(
                          margin: const EdgeInsets.only(bottom: 6.0),
                          height: 4.0,
                          width: 52.0 * w,
                          decoration: BoxDecoration(
                            color: paper
                                ? const Color(0xFFD9DEE8)
                                : Colors.white.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                    ],
                  )
                : null,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) =>
      Stack(clipBehavior: Clip.none, children: [
        _sheet(
          fill: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7DD3C0), Color(0xFF2E8B8B)],
          ),
          angle: -0.16,
          at: const Offset(0.0, 10.0),
        ),
        _sheet(
          fill: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF60A5FA), Color(0xFF8B5CF6), Color(0xFFF0A3A3)],
          ),
          angle: 0.05,
          at: const Offset(46.0, 0.0),
          lines: true,
        ),
        _sheet(
          fill: const LinearGradient(colors: [Colors.white, Color(0xFFF4F6FA)]),
          angle: -0.04,
          at: const Offset(28.0, 16.0),
          lines: true,
          paper: true,
        ),
      ]);
}

/// เนื้อการ์ดชุดคำสั่งแบบเลื่อนเอง: หัว (ชื่อ + จุดหน้า) + แผ่นขาว (หมวด + รายการ)
/// หน้าใหม่เลื่อนขึ้นจากล่าง หน้าเก่าเลื่อนออกด้านบน (แบบการ์ดแจ้งเตือนหน้าภาพรวม)
class _SetCarousel extends StatefulWidget {
  const _SetCarousel({
    super.key,
    required this.name,
    required this.on,
    required this.pages,
    required this.delay,
    required this.label,
    required this.item,
    required this.title,
  });

  final String name;
  final bool on;
  final List<(String, List<String>)> pages;
  final Duration delay;
  final TextStyle label;
  final TextStyle item;
  final TextStyle title;

  @override
  State<_SetCarousel> createState() => _SetCarouselState();
}

class _SetCarouselState extends State<_SetCarousel> {
  int _i = 0;
  Timer? _start;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    if (widget.pages.length > 1) {
      _start = Timer(widget.delay, () {
        _t = Timer.periodic(const Duration(milliseconds: 3200), (_) {
          if (mounted) setState(() => _i = (_i + 1) % widget.pages.length);
        });
      });
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.on;
    final n = widget.pages.length;
    final (group, items) = widget.pages[_i % n];
    final head = switch (group) {
      'ยา / เวชภัณฑ์' => 'ยาและเวชภัณฑ์',
      'Set OR (ผ่าตัด)' => 'ผ่าตัด',
      _ => group,
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: on ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: on ? _blue : _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 9.0, 10.0, 8.0),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: widget.title
                          .copyWith(color: on ? Colors.white : _inkTitle)),
                  const SizedBox(height: 5.0),
                  // จุดบอกหน้า: หน้าปัจจุบันยาวกว่า
                  Row(children: [
                    for (var k = 0; k < n; k++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: k == _i % n ? 12.0 : 5.0,
                        height: 5.0,
                        margin: const EdgeInsets.only(right: 4.0),
                        decoration: BoxDecoration(
                          color: on
                              ? Colors.white
                                  .withValues(alpha: k == _i % n ? 1.0 : 0.35)
                              : (k == _i % n ? _ink2 : _line),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
            if (on)
              const Icon(Icons.check_circle_rounded,
                  size: 18.0, color: Colors.white),
          ]),
        ),
        Container(
          // สูงคงที่ หน้าที่รายการน้อยไม่ทำให้การ์ดหด
          height: 96.0,
          padding: const EdgeInsets.fromLTRB(12.0, 9.0, 12.0, 8.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (c, prev) => Stack(
                  alignment: Alignment.topLeft,
                  children: [...prev, if (c != null) c]),
              transitionBuilder: (child, anim) {
                final incoming = child.key == ValueKey(_i % n);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, incoming ? 0.6 : -0.6),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                );
              },
              child: Column(
                key: ValueKey(_i % n),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$head (${items.length})', style: widget.label),
                  for (final m in items.take(3))
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(m,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: widget.item),
                    ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

/// ภาพแฟ้มเอกสาร (โทนกรมท่า): แผ่นหลังเข้ม · กระดาษ 3 แผ่นโผล่จากแฟ้ม
/// · กระเป๋าหน้ามีแถบ tab ซ้าย ไล่สีโปร่งแสงให้เห็นกระดาษจาง ๆ ด้านหลัง
class _FolderArt extends StatefulWidget {
  const _FolderArt();

  @override
  State<_FolderArt> createState() => _FolderArtState();
}

/// ปรากฏครั้งเดียว: แผ่นแรกโผล่ขึ้นจากแฟ้ม แล้วแผ่นหลังคลี่ออกไปทางขวา (ไม่มี idle)
class _FolderArtState extends State<_FolderArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300))
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// กระดาษหนึ่งแผ่น: เริ่มซ้อนอยู่ใต้แผ่นแรก แล้วคลี่ไปตำแหน่งของตัวเองตาม fan
  Widget _paper(double left, double top, double angle, double w,
      {bool lead = false}) {
    final rise = Curves.easeOutCubic
        .transform(const Interval(0.0, 0.5).transform(_c.value));
    final fan = Curves.easeOutBack
        .transform(const Interval(0.42, 1.0).transform(_c.value));
    const l0 = 22.0, t0 = 8.0, a0 = -0.06;
    final k = lead ? 1.0 : fan;
    return Positioned(
      left: l0 + (left - l0) * k,
      top: t0 + (top - t0) * k + 46.0 * (1.0 - rise),
      child: Transform.rotate(
        angle: a0 + (angle - a0) * k,
        child: Container(
          width: w,
          height: 56.0,
          padding: const EdgeInsets.fromLTRB(9.0, 9.0, 9.0, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000F4D),
                  blurRadius: 6.0,
                  offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final k in [0.5, 0.85, 0.7])
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  width: (w - 18.0) * k,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DBE7),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Stack(clipBehavior: Clip.none, children: [
                // แผ่นหลังแฟ้ม
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1E3A8A), Color(0xFF0B1F66)],
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                ),
                // แผ่นหลังวาดก่อน (อยู่ใต้แผ่นแรก) แล้วคลี่ออกไปขวา
                _paper(58.0, 14.0, 0.12, 34.0),
                _paper(46.0, 10.0, 0.05, 40.0),
                _paper(22.0, 8.0, -0.06, 50.0, lead: true),
                // กระเป๋าหน้า
                const Positioned.fill(
                  top: 30.0,
                  child: CustomPaint(painter: _FolderFrontPainter()),
                ),
              ])));
}

/// กระเป๋าหน้าแฟ้ม: ขอบบนมีแถบ tab ด้านซ้าย · ไล่สีฟ้าโปร่ง → กรมท่า + เส้นไฮไลต์ขอบบน
class _FolderFrontPainter extends CustomPainter {
  const _FolderFrontPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    const r = 12.0;
    final tabW = w * 0.42;
    const step = 9.0;
    final path = Path()
      ..moveTo(0.0, r)
      ..quadraticBezierTo(0.0, 0.0, r, 0.0)
      ..lineTo(tabW - 6.0, 0.0)
      // ไหล่ tab ลาดลงไปขอบบนส่วนที่เหลือ
      ..cubicTo(tabW, 0.0, tabW + 2.0, step, tabW + 10.0, step)
      ..lineTo(w - r, step)
      ..quadraticBezierTo(w, step, w, step + r)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0.0, h, 0.0, h - r)
      ..close();
    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE6A5B8F0), Color(0xF24263C9), Color(0xFF1E3A8A)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );
    // แสงขาวนุ่มกลางกระเป๋า
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.2),
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );
    // ไฮไลต์ขอบบน
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_FolderFrontPainter old) => false;
}

/// ปุ่ม AI แบบ elegant: ไล่สีคราม → ม่วง → ชมพูอ่อน · ขอบแสงด้านใน · เงาเรืองม่วงจาง
/// แสงวาบไล่ผ่านช้า ๆ ทุก ~4 วินาที + ประกายกระพริบเบา ๆ (วาดแค่ตัวปุ่ม)
class _AiPill extends StatefulWidget {
  const _AiPill({required this.label, required this.style});

  final String label;
  final TextStyle style;

  @override
  State<_AiPill> createState() => _AiPillState();
}

class _AiPillState extends State<_AiPill> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const r = BorderRadius.all(Radius.circular(100.0));
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: r,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
              blurRadius: 14.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: r,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              // แสงวาบ: วิ่งช่วง 0–30% ของรอบ ที่เหลือพัก
              final k = (_c.value / 0.3).clamp(0.0, 1.0);
              final sweep = -1.6 + 3.2 * Curves.easeInOutSine.transform(k);
              final twinkle =
                  0.75 + 0.25 * math.sin(_c.value * math.pi * 2 * 2);
              return Stack(children: [
                child!,
                if (k > 0.0 && k < 1.0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(sweep - 0.5, -1.0),
                            end: Alignment(sweep + 0.5, 1.0),
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.32),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 11.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Center(
                    child: Opacity(
                      opacity: twinkle,
                      child: Transform.scale(
                        scale: 0.92 + 0.08 * twinkle,
                        child: const Icon(Icons.auto_awesome_rounded,
                            size: 15.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ]);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(33.0, 8.0, 15.0, 8.0),
              decoration: BoxDecoration(
                borderRadius: r,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF7C3AED),
                    Color(0xFFC026D3),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28), width: 1.0),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: r,
                // แสงบนครึ่งบน ให้ดูมีผิวมัน
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.55],
                ),
              ),
              child: Text(widget.label,
                  style: widget.style.copyWith(letterSpacing: 0.2)),
            ),
          ),
        ),
      ),
    );
  }
}

/// คำสั่งหมวด "อื่น ๆ" (oth) ของ standing order: Admit · บันทึก · อาหาร
/// จากใบ sepsis / open fracture (knowledge หัวข้อ 10)
const _OrderGroup _otherOrders =
    _OrderGroup('อื่น ๆ', Icons.more_horiz_rounded, _blue, [
  _OrderItem('Admit ward', 'ระบุหอผู้ป่วย', _OrderStatus.pending, ''),
  _OrderItem(
      'Record V/S, I/O', 'ทุก 15 นาที ถึง 1 ชม.', _OrderStatus.pending, ''),
  _OrderItem(
      'Record SOS score', 'Search Out Severity', _OrderStatus.pending, ''),
  _OrderItem('NPO', 'งดน้ำงดอาหาร', _OrderStatus.pending, ''),
  _OrderItem('Soft / regular diet', 'อาหารอ่อน หรือ อาหารธรรมดา',
      _OrderStatus.pending, ''),
]);

/// หมวดคำสั่งตามรหัสที่ทีมกำกับในเอกสาร standing order (knowledge ข้อ 48)
const List<(String, String)> _soGroupTitles = [
  ('M', 'ยา / เวชภัณฑ์'),
  ('L', 'แล็บ'),
  ('X', 'ภาพถ่าย'),
  ('ห', 'หัตถการ'),
  ('oth', 'อื่น ๆ'),
];

/// Standing order for sepsis / severe sepsis / septic shock (รพ.ปากเกร็ด)
/// (ชื่อคำสั่ง, รายละเอียด, หมวด, One Day?) · ตามภาพเอกสาร Figma 332-483 (knowledge 10.2)
/// ชื่อห้ามซ้ำกันในชุด (ใช้เป็น key ของรายการที่ติ๊ก)
const List<(String, String, String, bool)> _sepsisOrders = [
  // One Day
  ('Admit ward', 'ระบุหอผู้ป่วย', 'oth', true),
  ('CBC, BUN, Cr, Electrolyte', 'เจาะพร้อมกัน', 'L', true),
  ('DTX', 'mg/dl', 'L', true),
  ('LFT', 'การทำงานของตับ', 'L', true),
  ('PT, PTT, INR', 'พิจารณาส่งบางราย', 'L', true),
  ('Hemoculture × 2', 'ระบุเวลาเจาะ ก่อนให้ยาปฏิชีวนะ', 'L', true),
  ('Sputum gram, culture', 'เสมหะ', 'L', true),
  ('UA, U/C', 'ปัสสาวะ', 'L', true),
  ('Pus gram, C/S', 'ระบุตำแหน่งแผล', 'L', true),
  ('CXR', 'Chest X-ray', 'X', true),
  ('On oxygen', 'cannula หรือ mask ระบุ LPM', 'ห', true),
  ('On ETT', 'ระบุเบอร์ท่อ และตำแหน่ง mark (cm)', 'ห', true),
  (
    '0.9% NSS load 30 ml/kg',
    'severe sepsis หรือ septic shock ให้ทันที ครบภายใน 3 ชม.',
    'M',
    true
  ),
  ('0.9% NSS 1,000 ml iv load', 'ระบุ ml แล้ว iv drip ml/hr', 'M', true),
  (
    'Levophed (4:250) iv drip',
    'เริ่ม 5–10 ml/hr titrate ทีละ 3–5 ml/hr ทุก 5 นาที keep MAP ≥ 65',
    'M',
    true
  ),
  ('NG tube', 'ใส่สายให้อาหาร', 'ห', true),
  ('Foley catheter', 'เทปัสสาวะที่ค้างใน bladder ออกก่อน', 'ห', true),
  // Continuation
  ('Record V/S, I/O', 'ทุก 15 นาที', 'oth', false),
  ('Record SOS score', 'Search Out Severity', 'oth', false),
  ('Soft / regular diet', 'อาหารอ่อน หรือ อาหารธรรมดา', 'oth', false),
  ('BD (1:1)', 'ระบุ ml × 4 feeds', 'oth', false),
  ('NPO', 'งดน้ำงดอาหาร', 'oth', false),
  ('Dressing wound', 'ทำแผล', 'ห', false),
  ('DTX ติดตาม', 'ตามรอบที่กำหนด', 'ห', false),
  ('Antibiotic', 'ระบุชื่อยา ขนาด และเวลาให้', 'M', false),
];

/// รอบการบันทึก standing order หนึ่งครั้ง
/// items = (ชื่อคำสั่ง, รายละเอียด, สถานะ, One Day?)
class _SoRound {
  const _SoRound(this.no, this.time, this.by, this.set, this.items);
  final int no;
  final String time;
  final String by;
  final String set;
  final List<(String, String, String, bool)> items;
}

/// ประวัติการบันทึก standing order ของเคส (ค่าจำลอง ใหม่ → เก่า)
/// ครั้งแรกตอนรับเคส · ครั้งที่ 2 หลังประเมินซ้ำ (septic shock)
const List<_SoRound> _soHistory = [
  _SoRound(2, '10:40', 'พญ. ศิริพร กิตติวงศ์', 'Sepsis', [
    (
      'Levophed (4:250) iv drip',
      'เริ่ม 5 ml/hr keep MAP ≥ 65',
      'กำลังทำ',
      true
    ),
    ('0.9% NSS 1,000 ml iv load', '500 ml แล้ว drip 100 ml/hr', 'ทำแล้ว', true),
    ('Hemoculture × 2', 'เจาะ 10:32 น. ก่อนให้ยา', 'ทำแล้ว', true),
    (
      'Antibiotic',
      'Piperacillin + Tazobactam 4.5 g IV q 8 hr',
      'ทำแล้ว',
      false
    ),
    ('Record SOS score', 'ทุก 1 ชม.', 'กำลังทำ', false),
  ]),
  _SoRound(1, '10:05', 'พญ. ศิริพร กิตติวงศ์', 'Sepsis', [
    ('0.9% NSS load 30 ml/kg', '1,900 ml ครบใน 3 ชม.', 'ทำแล้ว', true),
    ('CBC, BUN, Cr, Electrolyte', '', 'ทำแล้ว', true),
    ('DTX', '128 mg/dl', 'ทำแล้ว', true),
    ('UA, U/C', '', 'รอรับ', true),
    ('CXR', 'AP portable', 'ทำแล้ว', true),
    ('On oxygen', 'cannula 3 LPM', 'กำลังทำ', true),
    ('Record V/S, I/O', 'ทุก 15 นาที', 'กำลังทำ', false),
    ('NPO', '', 'กำลังทำ', false),
  ]),
];

/// standing order ที่ถอดจากเอกสารจริง: ชื่อชุด → (ชื่อคำสั่ง, รายละเอียด, หมวด, One Day?)
const Map<String, List<(String, String, String, bool)>> _soDocs = {
  'Sepsis': _sepsisOrders,
  'Stroke Fast Tract': _strokeFastOrders,
  'Stroke Non Fast Tract': _strokeNonFastOrders,
};

/// DOCTOR'S ORDER SHEET Stroke Unit Admission (Stroke Fast Tract/Rt-PA)
/// F-NUR-008 R/01 (17/05/67) · knowledge 10.4
const List<(String, String, String, bool)> _strokeFastOrders = [
  // One Day
  ('Admit Stroke Unit', '', 'oth', true),
  (
    'CBC, PT, PTT, INR, BUN, Cr, Electrolyte, Blood glucose, Anti-HIV',
    '',
    'L',
    true
  ),
  ('DTX', 'ระบุ mg/dL และน้ำหนักตัว (kg)', 'L', true),
  ('Tomorrow HbA1C, Lipid profile, FBS', 'เจาะพรุ่งนี้เช้า', 'L', true),
  ('CT Brain Non-Contrast Emergency', '', 'X', true),
  ('Chest X-Ray', '', 'X', true),
  ('EKG 12 leads', '', 'ห', true),
  (
    '0.9% NSS 1,000 ml IV drip',
    'ระบุ ml/hr keep SBP < 185 และ DBP < 110',
    'M',
    true
  ),
  (
    'Nicardipine 2.5 mg IV stat',
    'ถ้า BP > 185/110 แล้ว 2.5 mg/hr titrate q 5 min',
    'M',
    true
  ),
  ('Labetalol 10 mg IV', 'over 1–2 minutes', 'M', true),
  (
    'rtPA 0.9 mg/kg (max 90 mg)',
    '10% slow push ใน 1 นาที ที่เหลือหยดใน 60 นาที',
    'M',
    true
  ),
  (
    'Check V/S, N/S หลัง rtPA',
    'q 15 min × 2 hr แล้ว q 30 min × 6 hr แล้ว q 1 hr จนครบ 24 hr',
    'oth',
    true
  ),
  ('Monitor EKG 24 hours', '', 'ห', true),
  (
    'Avoid Foley, NG, central line, arterial puncture, IM',
    'ภายใน 24 ชม. หลังให้ rtPA',
    'oth',
    true
  ),
  ('CT Brain NC 24 hours after rt-PA', '', 'X', true),
  (
    'Consult IMC swallowing evaluation',
    'และ rehabilitation หลัง 24 ชม.',
    'oth',
    true
  ),
  // สงสัยเลือดออกในสมอง (ICH)
  ('Stop rtPA infusion', 'ถ้าสงสัย intracranial hemorrhage', 'M', true),
  ('Repeat CBC, Coagulogram', 'ถ้าสงสัย intracranial hemorrhage', 'L', true),
  ('Emergency CT Brain NC', 'ถ้าสงสัย intracranial hemorrhage', 'X', true),
  (
    'Cryoprecipitate 10 U in 30 min',
    'ถ้าสงสัย intracranial hemorrhage',
    'M',
    true
  ),
  ('Consult Neurosurgeon', 'ถ้าสงสัย intracranial hemorrhage', 'oth', true),
  // Continuation
  ('NPO เว้นยา', '', 'oth', false),
  ('Bedrest, fall precaution', '', 'oth', false),
  ('Record V/S, N/S, I/O', '', 'oth', false),
  ('DTX monitoring', 'premeal, hs', 'ห', false),
  ('Omeprazole 40 mg IV OD', '', 'M', false),
  (
    'ASA (300) 1 tab po pc',
    'หลังได้ rtPA 24 ชม. และ CT ไม่มี hemorrhage',
    'M',
    false
  ),
  ('Atorvastatin (40) 1 tab po hs', '', 'M', false),
  ('Paracetamol (500) 1 tab po prn', 'ไข้ ≥ 37.5 °C และแจ้งแพทย์', 'M', false),
];

/// DOCTOR'S ORDER SHEET Stroke Unit Admission (Stroke Non-Fast Tract/Rt-PA)
/// F-NUR-008 R/00 (13/02/66) · knowledge 10.5
const List<(String, String, String, bool)> _strokeNonFastOrders = [
  // One Day
  ('Admit Stroke Unit ward', 'ระบุหอผู้ป่วย', 'oth', true),
  ('CBC, BUN, Cr, E\'lyte, Blood glucose', '', 'L', true),
  ('PT, PTT, INR', '', 'L', true),
  ('Tomorrow HbA1C, Lipid profile, FBS', 'เจาะพรุ่งนี้เช้า', 'L', true),
  (
    'Thrombophilia work-up (อายุ < 45 ปี)',
    'ANA, Lupus anticoagulant, Protein C, Protein S, Antithrombin III, '
        'Anticardiolipin IgG, Anti-HIV, VDRL',
    'L',
    true
  ),
  ('CT Brain Non-Contrast', '', 'X', true),
  ('Chest X Ray', '', 'X', true),
  ('EKG 12 leads', '', 'ห', true),
  ('Keep Oxygen Saturation > 94%', '', 'ห', true),
  ('Monitor EKG 24 hours', '', 'ห', true),
  (
    '0.9% NSS 1,000 ml IV drip',
    'ระบุ ml/hr keep SBP ≤ 220 และ DBP ≤ 120',
    'M',
    true
  ),
  (
    'Nicardipine 5 mg IV stat',
    'ถ้า BP > 220/120 ลด MAP 15% แล้ว 2.5 mg/hr titrate q 5 min',
    'M',
    true
  ),
  ('Labetalol 10 mg IV', 'over 1–2 minutes', 'M', true),
  ('ASA (300) 1 tab po stat', 'Anticoagulant', 'M', true),
  ('Clopidogrel (75) 4 tab po stat', 'Anticoagulant', 'M', true),
  (
    'Consult IMC swallowing evaluation',
    'และ rehabilitation หลัง 24 ชม.',
    'oth',
    true
  ),
  (
    'Consider Neurosurgery consultation',
    'Malignant MCA, cerebellar infarction, acute hydrocephalus, ซึมลง',
    'oth',
    true
  ),
  (
    'GCS drop ≥ 2 แจ้งแพทย์',
    'หาสาเหตุ เช่น ขาดน้ำ ความดัน ไข้ น้ำตาล ติดเชื้อ stroke ซ้ำ สมองบวม ชัก',
    'oth',
    true
  ),
  // Continuation
  ('NPO เว้นยา', '', 'oth', false),
  ('Soft diet, low salt', '', 'oth', false),
  ('Regular diet, low salt', '', 'oth', false),
  ('Diabetic diet, low salt', '', 'oth', false),
  ('BD', 'ระบุสูตร ml × 4 feeds', 'oth', false),
  ('Bed rest, fall precaution, aspiration precaution', '', 'oth', false),
  ('พลิกตะแคงตัวทุก 2 ชม.', '', 'oth', false),
  ('Record V/S, N/S, I/O', '', 'oth', false),
  ('Retain NG tube', '', 'ห', false),
  ('Retain Foley\'s catheter', '', 'ห', false),
  ('DTX monitoring', 'premeal, hs', 'ห', false),
  ('ASA (81) 1 tab po pc เช้า', '', 'M', false),
  ('ASA (300) 1 tab po pc เช้า', '', 'M', false),
  ('Clopidogrel (75) 1 tab po pc เช้า', '', 'M', false),
  ('Atorvastatin (40) 1 tab po hs', '', 'M', false),
  ('Omeprazole (20) 1 × 1 po ac เช้า', '', 'M', false),
  ('Paracetamol (500) 1 tab po prn', 'ไข้ ≥ 37.5 °C และแจ้งแพทย์', 'M', false),
  ('If seizure consider AED', 'ระบุยากันชัก', 'M', false),
  (
    '20% Mannitol 1 g/kg IV in 30 min',
    'แล้ว 0.5 g/kg ใน 10 min (4–6 ครั้งต่อวัน)',
    'M',
    false
  ),
  ('10% Glycerol 1 g/kg IV', 'วันละ 4 ครั้ง max rate 125 ml/hr', 'M', false),
];

/// ชิ้นส่วนของใบ standing order (ใช้สร้าง task list ตามรูปแบบเอกสาร)
/// h = หัวข้อย่อยในคอลัมน์ (ตัวหนาในใบ เช่น "Fibrinolytic")
/// t = รายการติ๊ก · ข้อความ [หน่วย] = ช่องเว้นว่างให้กรอก (…… ในใบ)
/// n = หมายเหตุ/คำอธิบายต่อจากรายการก่อนหน้า (ไม่มีช่องติ๊ก)
/// alert = หัวข้อกรณีพิเศษ (เช่น สงสัยเลือดออกในสมอง) แสดงเป็นแถบแดงจาง
typedef _SoLine = (String kind, String text);

/// ใบคำสั่งหนึ่งใบ: หัวเอกสาร + 2 คอลัมน์ One Day / Continuation
class _SoDoc {
  const _SoDoc(this.title, this.code, this.oneDay, this.cont);
  final String title;
  final String code;
  final List<_SoLine> oneDay;
  final List<_SoLine> cont;
}

/// ใบที่ถอดโครงเอกสารครบ (หัวข้อ · ช่องเว้นว่าง · หมายเหตุ) · knowledge 10.4
const Map<String, _SoDoc> _soSheets = {
  'Stroke Fast Tract': _SoDoc(
    'Stroke Unit Admission (Stroke Fast Tract/Rt-PA)',
    'F-NUR-008 R/01 (17/05/67)',
    [
      ('t', 'Admit Stroke Unit'),
      ('t', 'CBC, PT, PTT, INR, BUN, Cr, Electrolyte, Blood glucose, Anti-HIV'),
      ('t', 'CT Brain Non-Contrast Emergency'),
      ('t', 'Chest X-Ray'),
      ('t', 'EKG 12 leads'),
      ('t', 'DTX [mg/dL] BW [kg]'),
      ('t', 'Tomorrow HbA1C, Lipid profile, FBS'),
      ('t', '0.9% NSS 1000 ml IV drip [ml/hr]'),
      ('h', 'Keep SBP < 185 และ DBP < 110 mmHg'),
      ('t', 'If BP > 185/110 mmHg give Nicardipine 2.5 mg IV stat'),
      ('n', 'then 2.5 mg/hr and titrate q 5 min'),
      ('t', 'Labetalol 10 mg IV over 1–2 minutes'),
      ('h', 'Fibrinolytic'),
      ('t', 'rtPA (0.9 mg/kg, max 90 mg) Total dose [mg]'),
      ('n', '10% slow push in 1 min then remaining in 60 minutes'),
      ('t', 'Check V/S, N/S and complication after rtPA'),
      ('n', 'q 15 min × 2 hr → q 30 min × 6 hr → q 1 hr until 24 hr'),
      ('n', 'Notify if BP > 180/105 or < 90/60 mmHg or GCS drop ≥ 2'),
      ('t', 'Monitor EKG 24 hours'),
      (
        't',
        'Avoid Foley, NG, central line, arterial puncture, IM within 24 hr of rtPA'
      ),
      ('alert', 'If suspecting intracranial hemorrhage'),
      ('t', 'Stop rtPA infusion'),
      ('t', 'Repeat CBC, Coagulogram'),
      ('t', 'Emergency CT Brain NC'),
      ('t', 'Cryoprecipitate 10 U in 30 min'),
      ('t', 'Consult Neurosurgeon'),
      ('h', 'หลัง 24 ชม.'),
      ('t', 'CT Brain NC 24 hours after rt-PA'),
      ('t', 'Consult IMC for swallowing evaluation and rehabilitation'),
    ],
    [
      ('t', 'NPO เว้นยา'),
      ('t', 'Bedrest, fall precaution'),
      ('t', 'Record V/S, N/S, I/O'),
      ('t', 'DTX monitoring premeal, hs'),
      ('t', 'Other [ระบุ]'),
      ('h', 'Medication'),
      ('t', 'Omeprazole 40 mg IV OD'),
      ('t', 'ASA (300) 1 tab po pc'),
      ('n', 'หลังได้ rtPA 24 ชม. และ CT ไม่มี hemorrhage'),
      ('t', 'Atorvastatin (40) 1 tab po hs'),
      ('t', 'Paracetamol (500) 1 tab po prn for fever ≥ 37.5 °C'),
      ('n', 'and please notify the doctor'),
    ],
  ),
};

extension _FeaturesPatientSoSheetPart on _ErFlowHomeWidgetState {
  /// ใบของชุดที่เลือก: ถอดโครงครบ = ใช้ใบนั้น · ไม่งั้นสร้างจากรายการคำสั่ง (ไม่มีหัวข้อย่อย)
  _SoDoc? _soDocOf(String cat) {
    final full = _soSheets[cat];
    if (full != null) return full;
    final rows = _soDocs[cat];
    if (rows == null) return null;
    List<_SoLine> col(bool oneDay) => [
          for (final r in rows)
            if (r.$4 == oneDay) ...[
              ('t', r.$1),
              if (r.$2.isNotEmpty) ('n', r.$2),
            ],
        ];
    return _SoDoc('Standing order $cat', '', col(true), col(false));
  }

  /// generative task list: วาดใบคำสั่งตามรูปแบบเอกสาร จากข้อมูลโครงใบ
  Widget _soSheet({bool scroll = true}) {
    final doc = _soDocOf(_template);
    if (doc == null) {
      return Center(
          child: Text('ชุดนี้ยังไม่มีใบคำสั่ง', style: _t(12.0, color: _ink3)));
    }
    final ticks = [
      for (final l in [...doc.oneDay, ...doc.cont])
        if (l.$1 == 't') l.$2
    ];
    final done = ticks.where((t) => _soTick.contains('$_template|$t')).length;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // หัวเอกสาร: ชื่อใบ + รหัสฟอร์ม/รุ่น + ความคืบหน้า
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title,
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
                if (doc.code.isNotEmpty)
                  Text(doc.code, style: _t(10.5, color: _ink3)),
              ],
            ),
          ),
          Text('$done/${ticks.length}',
              style: _num(12.0, color: _ink2, weight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10.0),
        _soColumn('Order One Day', Icons.today_rounded, doc.oneDay),
        const SizedBox(height: 10.0),
        _soColumn('Order for Continuation', Icons.repeat_rounded, doc.cont),
      ],
    );
    return scroll ? SingleChildScrollView(child: body) : body;
  }

  /// คอลัมน์หนึ่งของใบ: การ์ดซ้อน หัวกรมท่า + แผ่นขาวรายการตามลำดับเอกสาร
  Widget _soColumn(String title, IconData icon, List<_SoLine> lines) {
    final rows = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      final (kind, text) = lines[i];
      switch (kind) {
        case 'h':
          rows.add(Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
            child: Text(text,
                style: _t(11.5, color: _inkTitle, weight: FontWeight.w600)),
          ));
        case 'alert':
          rows.add(Container(
            margin: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 14.0, color: _red),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(text,
                    style: _t(11.5, color: _red, weight: FontWeight.w600)),
              ),
            ]),
          ));
        case 'n':
          rows.add(Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 4.0),
            child: Text(text, style: _t(10.5, color: _ink3, height: 1.3)),
          ));
        default:
          rows.add(_soTask(text));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: _blue,
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14.0, 9.0, 14.0, 9.0),
          child: Row(children: [
            Icon(icon, size: 14.0, color: Colors.white),
            const SizedBox(width: 6.0),
            Text(title,
                style: _t(12.0, color: Colors.white, weight: FontWeight.w600)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 10.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ),
      ]),
    );
  }

  /// รายการติ๊กหนึ่งบรรทัด · [หน่วย] ในข้อความ = ช่องกรอกในบรรทัด
  Widget _soTask(String text) {
    final key = '$_template|$text';
    final on = _soTick.contains(key);
    final parts = <InlineSpan>[];
    final re = RegExp(r'\[([^\]]+)\]');
    var last = 0;
    var n = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        parts.add(TextSpan(text: text.substring(last, m.start)));
      }
      final bk = '$key#${n++}';
      parts.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: _soBlankField(bk, m.group(1)!),
      ));
      last = m.end;
    }
    if (last < text.length) parts.add(TextSpan(text: text.substring(last)));
    return InkWell(
      onTap: () => setState(() => on ? _soTick.remove(key) : _soTick.add(key)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 18.0,
            height: 18.0,
            margin: const EdgeInsets.only(top: 1.0, right: 12.0),
            decoration: BoxDecoration(
              color: on ? _blue : Colors.transparent,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: on ? _blue : _g5, width: 1.5),
            ),
            child: on
                ? const Icon(Icons.check_rounded,
                    size: 13.0, color: Colors.white)
                : null,
          ),
          Expanded(
            child: Text.rich(
              TextSpan(children: parts),
              style: _t(12.0,
                  color: on ? _inkTitle : _ink2,
                  weight: FontWeight.w500,
                  height: 1.45),
            ),
          ),
        ]),
      ),
    );
  }

  /// ช่องเว้นว่างในบรรทัด (…… ในใบ): กล่องเล็ก + หน่วยจาง ๆ เป็น hint
  Widget _soBlankField(String key, String unit) => Container(
        width: unit.length > 4 ? 120.0 : 72.0,
        height: 26.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: _line),
        ),
        alignment: Alignment.centerLeft,
        child: TextFormField(
          initialValue: _soBlank[key],
          onChanged: (v) => _soBlank[key] = v,
          style: _num(11.5, color: _inkTitle, weight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: unit,
            hintStyle: _t(10.5, color: _ink3),
          ),
        ),
      );
}
