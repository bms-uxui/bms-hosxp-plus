// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ รายละเอียดรายการใน Order Set
// ยา: วิธีใช้ Mode 2 (เลือก/พิมพ์วิธีใช้) หรือ Mode 3 (Dose · หน่วย · ความถี่ · เวลา)
//     + จำนวนและหน่วยบรรจุ ตามฟอร์มสั่งยาของ HOSxP (add_medicatin_order)
// เลือด: วันเวลาที่ใช้ · ความต้องการ · ความเร่งด่วน · แพทย์ผู้ขอ · จุดที่ขอ
//     · หมายเหตุ · จำนวน cc · ราคา
// Set OR: วันเวลาเข้าห้องผ่าตัด · ถึงวันเวลา · ห้องผ่าตัด (er_or_room) · รายละเอียด
//     ตามฟอร์ม item_set_o_r ของ HOSxP

/// ชนิดรายการที่มีรายละเอียดให้ระบุ (ตามหมวดของ Order Set)
enum _OrderKind { drug, blood, or, other }

_OrderKind _orderKindOf(_OrderGroup g) => g.title.startsWith('ยา')
    ? _OrderKind.drug
    : g.title.startsWith('เลือด')
        ? _OrderKind.blood
        : g.title.startsWith('Set OR')
            ? _OrderKind.or
            : _OrderKind.other;

/// ความต้องการเลือด (ค่าจำลอง รอ master จากธนาคารเลือดของ HOSxP)
const List<String> _bloodNeeds = [
  'ใช้ทันที',
  'เตรียมไว้ (Crossmatch)',
  'จองเลือด (Type & Screen)',
];

/// ราคาต่อรายการเลือด (บาท) — ค่าจำลอง
const Map<String, int> _bloodPrice = {'Blood culture ×2': 400};

mixin _FeaturesPatientOrderDetailState on State<ErFlowHomeWidget> {
  /// รายละเอียดที่ระบุแล้วของแต่ละรายการ: ชื่อรายการ → (ช่อง → ค่า)
  final Map<String, Map<String, String>> _orderDetail = {};

  /// รายการที่กำลังกรอกรายละเอียดในแผงขวา (null = แผงขวาแสดงคำสั่งที่บันทึกแล้ว)
  String? _orderEditing;
  _OrderKind _orderEditKind = _OrderKind.other;

  /// ช่องพิมพ์ของฟอร์มแผงขวา: 'ชื่อรายการ|ช่อง' → controller (คงไว้ข้ามการ rebuild)
  final Map<String, TextEditingController> _orderCtl = {};
  Timer? _orderDeb;
}

extension _FeaturesPatientOrderDetailPart on _ErFlowHomeWidgetState {
  /// สรุปรายละเอียดหนึ่งบรรทัด (ใช้ใต้ชื่อรายการ) · ว่าง = ยังไม่ระบุ
  String _orderDetailLine(_OrderKind k, String name) {
    final d = _orderDetail[name];
    if (d == null) return '';
    String v(String key) => (d[key] ?? '').trim();
    final parts = <String>[];
    if (k == _OrderKind.drug) {
      if (v('stat') == '1') parts.add('STAT');
      if (v('usage').isNotEmpty) parts.add(v('usage').replaceAll('\n', ' '));
      if (v('qty').isNotEmpty) parts.add('จำนวน ${v('qty')} ${v('pack')}');
    } else if (k == _OrderKind.blood) {
      parts.addAll([
        if (v('need').isNotEmpty) v('need'),
        if (v('priority').isNotEmpty) v('priority'),
        if (v('cc').isNotEmpty) '${v('cc')} cc',
        if (v('when').isNotEmpty) 'ใช้ ${v('when')}',
      ]);
    } else if (k == _OrderKind.or) {
      parts.addAll([
        if (v('room').isNotEmpty) v('room'),
        if (v('from').isNotEmpty)
          v('to').isEmpty ? v('from') : '${v('from')} – ${v('to')}',
      ]);
    }
    return parts.join(' · ');
  }

  /// ปุ่มใต้รายการที่เลือกแล้ว: บอกรายละเอียดที่ระบุ หรือชวนให้ระบุ
  Widget _orderDetailPill(_OrderKind k, String name) {
    final d = _orderDetail[name];
    final miss = d == null ? 0 : _orderMissing(k, d).length;
    final sum = _orderDetailLine(k, name);
    // มีรายละเอียดบางส่วนแล้วแต่ยังขาดช่องบังคับ: บอกจำนวนที่ขาดต่อท้าย
    final line = sum.isEmpty
        ? ''
        : miss > 0
            ? '$sum · ขาด $miss ช่อง'
            : sum;
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: _Press(
        child: Material(
          color: _orderEditing == name
              ? _blue.withValues(alpha: 0.12)
              : line.isEmpty
                  ? _blue
                  : _panelSoft,
          borderRadius: BorderRadius.circular(8.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _orderOpen(k, name),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(line.isEmpty ? Icons.add_rounded : Icons.edit_rounded,
                    size: 12.0,
                    color: line.isEmpty && _orderEditing != name
                        ? Colors.white
                        : _blue),
                const SizedBox(width: 5.0),
                Flexible(
                  child: Text(
                    line.isEmpty
                        ? switch (k) {
                            _OrderKind.drug => 'ระบุวิธีใช้ · จำนวน',
                            _OrderKind.blood => 'ระบุรายละเอียดการขอเลือด',
                            _ => 'ระบุวันเวลาและห้องผ่าตัด',
                          }
                        : line,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _t(9.5,
                        color: line.isEmpty && _orderEditing != name
                            ? Colors.white
                            : _ink,
                        weight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  /// ค่าตั้งต้นของรายการเลือด: แพทย์ผู้ขอ = ผู้ใช้ปัจจุบัน · จุดที่ขอ = ห้อง/เตียงผู้ป่วย
  Map<String, String> _bloodDefaults(String name) {
    final p = _caseP();
    final now = DateTime.now();
    return {
      'when': _fmtWhen(now),
      'need': _bloodNeeds.first,
      'priority': 'ด่วน (Urgent)',
      'doctor': ErSession.instance.user?.name ?? '',
      'place': 'ห้องฉุกเฉิน${p.bed == null ? '' : ' · เตียง ${p.bed}'}',
      'price': '${_bloodPrice[name] ?? ''}',
    };
  }

  String _fmtWhen(DateTime t) {
    const m = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.day} ${m[t.month - 1]} ${two(t.hour)}:${two(t.minute)} น.';
  }

  String _orderItemDetail(String name) {
    for (final g in _orderGroups) {
      for (final i in g.items) {
        if (i.name == name) return i.detail;
      }
    }
    return '';
  }

  /// เปิดฟอร์มรายละเอียดของรายการในแผงขวา (ตั้งค่าตั้งต้นครั้งแรก)
  void _orderOpen(_OrderKind k, String name) {
    if (k == _OrderKind.other) return;
    setState(() {
      _orderDetail.putIfAbsent(
          name,
          () => {
                if (k == _OrderKind.blood) ..._bloodDefaults(name),
                if (k == _OrderKind.drug) 'mode': '2',
                if (k == _OrderKind.drug) 'usage': _orderItemDetail(name),
                if (k == _OrderKind.or) 'from': _fmtWhen(DateTime.now()),
              });
      // แพทย์ผู้ขอผูกกับ account ที่ login เสมอ
      if (k == _OrderKind.blood) {
        _orderDetail[name]!['doctor'] = ErSession.instance.user?.name ?? '';
      }
      _orderEditing = name;
      _orderEditKind = k;
    });
  }

  void _orderClose() => setState(() => _orderEditing = null);

  /// ช่องบังคับที่ยังไม่ได้กรอก
  List<String> _orderMissing(_OrderKind k, Map<String, String> d) {
    bool has(String key) => (d[key] ?? '').trim().isNotEmpty;
    return switch (k) {
      _OrderKind.drug => [
          if (!has('usage')) 'วิธีใช้',
          if (!has('qty')) 'จำนวน',
          if (!has('pack')) 'หน่วยบรรจุ',
        ],
      _OrderKind.blood => [
          if (!has('when')) 'วันเวลาที่ใช้',
          if (!has('need')) 'ความต้องการ',
          if (!has('priority')) 'ความเร่งด่วน',
          if (!has('cc')) 'จำนวน cc',
        ],
      _OrderKind.or => [
          if (!has('from')) 'วันเวลาเข้าห้องผ่าตัด',
          if (!has('room')) 'ห้องผ่าตัด',
        ],
      _ => const [],
    };
  }

  /// การ์ดกรอกรายละเอียดในแผงขวา — แก้แล้วบันทึกทันที ไม่มีหน้าซ้อน
  Widget _orderEditorCard() {
    final name = _orderEditing!;
    final k = _orderEditKind;
    final d = _orderDetail[name]!;
    bool has(String key) => (d[key] ?? '').trim().isNotEmpty;
    final missing = _orderMissing(k, d);

    TextEditingController ctl(String key) => _orderCtl.putIfAbsent(
        '$name|$key', () => TextEditingController(text: d[key] ?? ''));
    void setCtl(String key, String v) {
      final c = _orderCtl['$name|$key'];
      if (c != null && c.text != v) c.text = v;
    }

    // Mode 3: ประกอบข้อความวิธีใช้จาก Dose · หน่วย · ความถี่ · เวลา แล้วแก้ต่อได้
    void compose() {
      if (k != _OrderKind.drug || d['mode'] != '3') return;
      String v(String key) => (d[key] ?? '').trim();
      final t = [
        if (v('dose').isNotEmpty) 'ครั้งละ ${v('dose')} ${v('unit')}'.trim(),
        v('freq'),
        v('time'),
      ].where((e) => e.isNotEmpty).join(' ');
      if (t.isEmpty) return;
      d['usage'] = t;
      setCtl('usage', t);
    }

    void put(String key, String v) => setState(() {
          d[key] = v;
          compose();
        });

    Widget label(String s, {bool req = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text.rich(
              TextSpan(children: [
                TextSpan(text: s),
                if (req)
                  const TextSpan(text: ' *', style: TextStyle(color: _red)),
              ]),
              style: _t(10.5, color: _ink2, weight: FontWeight.w600)),
        );
    BoxDecoration box([bool on = false]) => BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: on ? _blue.withValues(alpha: 0.5) : _line),
        );

    // ตัวเลือกสั้น = ชิปแตะเลือกในที่ · ยาว = เมนูลงมาจากช่อง (ไม่เปิดหน้าใหม่)
    Widget pick(String title, String key, List<String> opts,
        {bool req = false, String? target}) {
      final cur = d[target ?? key] ?? '';
      void choose(String o) {
        setCtl(target ?? key, o);
        put(target ?? key, o);
      }

      final short = opts.length <= 6 && opts.every((o) => o.length <= 24);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label(title, req: req),
        if (short)
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            for (final o in opts) _chip(o, o == cur, () => choose(o)),
          ])
        else
          PopupMenuButton<String>(
            tooltip: '',
            position: PopupMenuPosition.under,
            constraints:
                const BoxConstraints(maxHeight: 320.0, minWidth: 220.0),
            color: _panel,
            onSelected: choose,
            itemBuilder: (_) => [
              for (final o in opts)
                PopupMenuItem(
                  value: o,
                  height: 40.0,
                  child: Row(children: [
                    Expanded(
                        child: Text(o,
                            style: _t(12.0,
                                color: o == cur ? _blue : _ink,
                                weight: o == cur
                                    ? FontWeight.w700
                                    : FontWeight.w500))),
                    if (o == cur)
                      const Icon(Icons.check_rounded, size: 16.0, color: _blue),
                  ]),
                ),
            ],
            child: Container(
              height: 40.0,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: box(cur.isNotEmpty && target == null),
              child: Row(children: [
                Expanded(
                  child: Text(
                      cur.isEmpty || target != null
                          ? (title.startsWith('เลือก') ? title : 'เลือก$title')
                          : cur,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0,
                          color: cur.isEmpty || target != null ? _ink3 : _ink)),
                ),
                const Icon(Icons.expand_more_rounded, size: 18.0, color: _ink3),
              ]),
            ),
          ),
      ]);
    }

    Widget text(String title, String key,
            {bool num = false,
            bool req = false,
            String? suffix,
            int lines = 1}) =>
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          label(title, req: req),
          TextField(
            controller: ctl(key),
            minLines: lines,
            maxLines: lines,
            keyboardType: num
                ? const TextInputType.numberWithOptions(decimal: true)
                : lines > 1
                    ? TextInputType.multiline
                    : TextInputType.text,
            inputFormatters: num
                ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                // หลายบรรทัด: ไม่เกินจำนวนบรรทัดที่เปิดไว้
                : [
                    TextInputFormatter.withFunction((o, n) =>
                        '\n'.allMatches(n.text).length >= lines ? o : n)
                  ],
            // เก็บค่าทันที แต่ rebuild หน้าแบบหน่วง กันพิมพ์แล้วหน่วง
            onChanged: (v) {
              d[key] = v;
              if (key == 'dose') compose();
              _orderDeb?.cancel();
              _orderDeb = Timer(const Duration(milliseconds: 350), () {
                if (mounted) setState(() {});
              });
            },
            style: _t(12.0),
            decoration: InputDecoration(
              isDense: true,
              hintText: title,
              hintStyle: _t(12.0, color: _ink3),
              suffixText: suffix,
              suffixStyle: _t(11.0, color: _ink3),
              filled: true,
              fillColor: _panelSoft,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 11.0),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                      color: has(key) ? _blue.withValues(alpha: 0.5) : _line)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: _blue)),
            ),
          ),
        ]);

    Widget fixed(String title, String value, IconData icon) =>
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          label(title),
          Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(children: [
              Icon(icon, size: 15.0, color: _ink3),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(value.isEmpty ? '—' : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(12.0, color: _ink2)),
              ),
            ]),
          ),
        ]);

    // วันเวลาแบบกรอกในที่: ชิปวัน (วันนี้ / พรุ่งนี้ / มะรืน) + เวลา HH:MM
    Widget when(String title, String key, {bool req = true}) {
      final now = DateTime.now();
      final day = int.tryParse(d['${key}_day'] ?? '') ?? 0;
      String hm() =>
          d['${key}_hm'] ??
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      void apply(int dd, String t) {
        d['${key}_day'] = '$dd';
        d['${key}_hm'] = t;
        final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(t);
        if (m == null) return;
        final base = DateTime(now.year, now.month, now.day + dd,
            int.parse(m[1]!).clamp(0, 23), int.parse(m[2]!).clamp(0, 59));
        d[key] = _fmtWhen(base);
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        label(title, req: req),
        Row(children: [
          for (final (i, l) in const [
            (0, 'วันนี้'),
            (1, 'พรุ่งนี้'),
            (2, 'มะรืน')
          ])
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: _chip(l, has(key) && day == i,
                  () => setState(() => apply(i, hm()))),
            ),
          SizedBox(
            width: 76.0,
            child: TextField(
              controller: _orderCtl.putIfAbsent(
                  '$name|${key}_hm', () => TextEditingController(text: hm())),
              keyboardType: TextInputType.datetime,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                LengthLimitingTextInputFormatter(5),
              ],
              onChanged: (v) => setState(() => apply(day, v)),
              textAlign: TextAlign.center,
              style: _num(12.0, weight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: _panelSoft,
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100.0),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          if (!req && has(key)) ...[
            const SizedBox(width: 4.0),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => d.remove(key)),
              icon: const Icon(Icons.close_rounded, size: 16.0, color: _ink3),
            ),
          ],
        ]),
      ]);
    }

    Widget row(List<Widget> cs) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 0; i < cs.length; i++) ...[
              if (i > 0) const SizedBox(width: 12.0),
              Expanded(child: cs[i]),
            ],
          ]),
        );

    final fields = <Widget>[
      if (k == _OrderKind.drug) ...[
        // ยา STAT = ให้ทันทีครั้งเดียว · ติ๊กแล้วเป็นสีแดง (ผู้ใช้กำหนด)
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _Press(
              child: Material(
                color: d['stat'] == '1' ? _red : _panelSoft,
                borderRadius: BorderRadius.circular(100.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => put('stat', d['stat'] == '1' ? '' : '1'),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 4.0, 11.0, 4.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                          d['stat'] == '1'
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 15.0,
                          color: d['stat'] == '1' ? Colors.white : _ink3),
                      const SizedBox(width: 5.0),
                      Text('ยา STAT',
                          style: _t(10.5,
                              color: d['stat'] == '1' ? Colors.white : _ink2,
                              weight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
        label('วิธีใช้'),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _segmented(
            const ['Mode 2 · วิธีใช้', 'Mode 3 · Dose / ความถี่'],
            d['mode'] == '3' ? 1 : 0,
            (i) => put('mode', i == 1 ? '3' : '2'),
          ),
        ),
        if (d['mode'] != '3')
          row([
            pick('เลือกจากฉลากช่วย', 'label', _masterNames('er_drugusage'),
                target: 'usage')
          ])
        else ...[
          row([
            text('Dose', 'dose', num: true),
            pick('หน่วย', 'unit', _masterNames('er_drug_unit')),
          ]),
          row([
            pick('ความถี่', 'freq', _masterNames('er_drug_frequency')),
            pick('เวลา', 'time', _masterNames('er_drug_time')),
          ]),
        ],
        // ข้อความวิธีใช้บนฉลาก 3 บรรทัด แก้ได้เสมอ
        row([
          text('วิธีใช้ (แก้ไขได้ · 3 บรรทัด)', 'usage', lines: 3, req: true)
        ]),
        row([
          text('จำนวน', 'qty', num: true, req: true),
          pick('หน่วยบรรจุ', 'pack', _masterNames('er_drug_package_unit'),
              req: true),
        ]),
      ] else if (k == _OrderKind.or) ...[
        row([when('วันเวลาเข้าห้องผ่าตัด', 'from')]),
        row([when('ถึงวันเวลา', 'to', req: false)]),
        row([
          pick('ห้องผ่าตัด', 'room', _masterNames('er_or_room'), req: true)
        ]),
        row([text('รายละเอียด', 'desc', lines: 2)]),
      ] else ...[
        row([when('วันเวลาที่ใช้', 'when')]),
        row([pick('ความต้องการ', 'need', _bloodNeeds, req: true)]),
        row([
          pick('ความเร่งด่วน', 'priority', _masterNames('er_order_priority'),
              req: true),
        ]),
        row([
          text('จำนวน', 'cc', num: true, req: true, suffix: 'cc'),
          text('ราคา', 'price', num: true, suffix: 'บาท'),
        ]),
        row([
          fixed('แพทย์ผู้ขอ', d['doctor'] ?? '', Icons.person_rounded),
          pick(
              'จุดที่ขอ',
              'place',
              [d['place'] ?? '', ..._masterNames('er_room')]
                  .where((e) => e.isNotEmpty)
                  .toSet()
                  .toList()),
        ]),
        row([text('หมายเหตุ', 'note', lines: 2)]),
      ],
    ];

    return Container(
      key: ValueKey('order-edit-$name'),
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 4.0),
      decoration: _clyCardDeco,
      foregroundDecoration: const _InnerGloss(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                gradient: _glossGrad(_blue),
                borderRadius: BorderRadius.circular(9.0),
              ),
              child: Icon(
                  switch (k) {
                    _OrderKind.drug => Icons.medication_rounded,
                    _OrderKind.blood => Icons.water_drop_rounded,
                    _ => Icons.local_hospital_rounded,
                  },
                  size: 16.0,
                  color: Colors.white),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text(
                      switch (k) {
                        _OrderKind.drug => 'วิธีใช้และจำนวนยา',
                        _OrderKind.blood => 'รายละเอียดการขอเลือด',
                        _ => 'จองห้องผ่าตัด (Set OR)',
                      },
                      style: _t(10.0, color: _ink3)),
                ],
              ),
            ),
            // สถานะความครบ: เขียว = ครบ (เฉพาะสิ่งที่ทำเสร็จ) · เทา = ยังขาด
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: missing.isEmpty
                    ? _green.withValues(alpha: 0.12)
                    : _panelSoft,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text(
                  missing.isEmpty ? 'ครบแล้ว' : 'ขาด ${missing.length} ช่อง',
                  style: _t(9.5,
                      color: missing.isEmpty ? _green : _ink2,
                      weight: FontWeight.w700)),
            ),
            IconButton(
              tooltip: 'ปิด',
              onPressed: _orderClose,
              icon: const Icon(Icons.keyboard_double_arrow_right_rounded,
                  size: 20.0, color: _ink3),
            ),
          ]),
          const Divider(height: 18.0, color: _line),
          ...fields,
        ],
      ),
    );
  }
}
