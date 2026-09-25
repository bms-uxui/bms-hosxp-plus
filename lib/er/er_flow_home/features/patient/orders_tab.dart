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

  /// การ์ดเลือก Order Set: ทุกชุดเป็นการ์ดให้แตะเลือก (ไม่มีค้นหา/ชิปประเภทผู้ป่วย)
  Widget _orderSetPicker() => Container(
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
                Text('เลือก Order Set',
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                const Spacer(),
                _orderKey('ยังไม่รับ', _g5),
                _orderKey('รับแล้ว', _blue),
                _orderKey('ทำแล้ว', _blue),
              ],
            ),
            _tplPicker(),
          ],
        ),
      );

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

  Widget _orderKey(String label, Color color) => Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            Container(
              width: 7.0,
              height: 7.0,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4.0),
            Text(label, style: _t(9.0, color: _ink3)),
          ],
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
  Widget _orderGroupCard(_OrderGroup g) {
    final picked = g.items.where((i) => _orderPicked.contains(i.name)).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 6.0),
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
              Icon(g.icon, size: 14.0, color: g.color),
              const SizedBox(width: 6.0),
              Text(g.title,
                  style: _t(11.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 6.0),
              Text('($picked/${g.items.length})',
                  style: _num(10.0, color: _ink3)),
              const Spacer(),
              InkWell(
                onTap: () => setState(() {
                  for (final i in g.items) {
                    _orderPicked.add(i.name);
                  }
                }),
                child: Text('เลือกทั้งหมด',
                    style: _t(9.5, color: _blue, weight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          for (var i = 0; i < g.items.length; i++) ...[
            _orderRow(g.items[i], _orderKindOf(g)),
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
            if (it.status != _OrderStatus.done) ...[
              _remBell(it.name),
              const SizedBox(width: 6.0),
            ],
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

  /// แท็บคำสั่งแพทย์ (แผงขวา): อ่านอย่างเดียว เฉพาะคำสั่งที่บันทึกไปแล้ว
  /// การเลือก/ติ๊กสั่งทำใน workflow ขั้น "วินิจฉัย/สั่ง" ที่นี่ไม่มีปุ่มให้แก้
  Widget _orderRecord() {
    final groups = [
      for (final g in _orderGroups)
        (
          g,
          [
            for (final i in g.items)
              if (_orderPicked.contains(i.name)) i
          ]
        ),
    ].where((x) => x.$2.isNotEmpty).toList();
    final n = groups.fold<int>(0, (a, x) => a + x.$2.length) + _tplSaved.length;
    if (n == 0) return _clyEmpty('ยังไม่มีคำสั่งที่บันทึก');
    return Container(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 6.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text('คำสั่งที่บันทึกแล้ว',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w500)),
            ),
            Text('$n รายการ · Order Set $_template',
                style: _t(9.5, color: _ink3)),
          ]),
          if (_tplSaved.isNotEmpty) ...[
            const SizedBox(height: 10.0),
            Row(children: [
              const Icon(Icons.description_rounded, size: 13.0, color: _ink2),
              const SizedBox(width: 5.0),
              Text('Standing order Snake bite',
                  style: _t(10.5, color: _ink2, weight: FontWeight.w600)),
            ]),
            for (final l in _tplSaved)
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 6.0, 0.0, 0.0),
                child: Text(l,
                    style: _t(11.0, color: _inkTitle, weight: FontWeight.w600)),
              ),
          ],
          for (final (g, items) in groups) ...[
            const SizedBox(height: 10.0),
            Row(children: [
              Icon(g.icon, size: 13.0, color: _ink2),
              const SizedBox(width: 5.0),
              Text(g.title,
                  style: _t(10.5, color: _ink2, weight: FontWeight.w600)),
            ]),
            for (var k = 0; k < items.length; k++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 7.0),
                decoration: BoxDecoration(
                  border: k == items.length - 1
                      ? null
                      : const Border(bottom: BorderSide(color: _line)),
                ),
                child: Row(children: [
                  const SizedBox(width: 18.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[k].name,
                            style: _t(11.5,
                                color: _inkTitle, weight: FontWeight.w600)),
                        if (items[k].detail.isNotEmpty)
                          Text(items[k].detail, style: _t(9.5, color: _ink3)),
                        if (_orderDetailLine(_orderKindOf(g), items[k].name)
                            .isNotEmpty)
                          Text(_orderDetailLine(_orderKindOf(g), items[k].name),
                              style: _t(10.0,
                                  color: _blue, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  _orderStatus(items[k].status, items[k].time),
                ]),
              ),
          ],
        ],
      ),
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
