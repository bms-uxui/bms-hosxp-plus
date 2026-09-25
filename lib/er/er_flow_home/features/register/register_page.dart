// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ ลงทะเบียนผู้ป่วยใหม่
// แทนหน้า "ลงทะเบียนข้อมูลผู้ป่วยฉุกเฉิน" ของแอปเดิม (regis_patientipd_e_r)
// เก็บเฉพาะข้อมูลประจำตัว · ข้อมูลการมา สัญญาณชีพ GCS ESI อยู่ใน workflow คัดกรองแล้ว
// ลงทะเบียนเสร็จ = เข้ารายชื่อ "รอคัดกรอง" ทันที

mixin _FeaturesRegisterRegisterPageState on State<ErFlowHomeWidget> {
  /// หน้าลงทะเบียนเปิดอยู่
  bool _regOpen = false;

  /// ช่องพิมพ์: name · cid · phone · allergy · addr
  final Map<String, TextEditingController> _regIn = {};

  /// ค่าที่เลือก: prefix · job · ethnic · nation · religion · marital
  final Map<String, String> _regPick = {};

  String? _regSex;
  String? _regBlood;
  DateTime? _regDob;

  /// รูปถ่ายผู้ป่วย (จำลอง: ใช้รูปจากชุดใบหน้า)
  String? _regPhoto;

  /// ยาที่แพ้ · ไม่มีประวัติแพ้ = ยืนยันแล้วว่าไม่มี (ต่างจากยังไม่ได้ถาม)
  final List<String> _regAllergy = [];
  bool _regNoAllergy = false;

  /// ผู้ป่วยนิรนาม (หมดสติ ไม่มีบัตร) ลงทะเบียนก่อน แก้ชื่อทีหลัง
  bool _regUnknown = false;

  /// HN ที่ออกให้ตอนเปิดหน้า
  String _regHn = '';

  /// ผู้ป่วยที่ลงทะเบียนเพิ่มในรอบนี้ (นับเลขผู้ป่วยนิรนาม)
  int _regCount = 0;
}

extension _FeaturesRegisterRegisterPagePart on _ErFlowHomeWidgetState {
  static const List<String> _regPrefixes = [
    'นาย',
    'นาง',
    'นางสาว',
    'ด.ช.',
    'ด.ญ.',
  ];
  static const Map<String, List<String>> _regChoices = {
    'job': [
      'รับจ้างทั่วไป',
      'เกษตรกร',
      'ค้าขาย',
      'รับราชการ',
      'พนักงานบริษัท',
      'นักเรียน/นักศึกษา',
      'ไม่ได้ประกอบอาชีพ',
    ],
    'ethnic': ['ไทย', 'จีน', 'ลาว', 'กัมพูชา', 'เมียนมา', 'อื่น ๆ'],
    'nation': ['ไทย', 'ลาว', 'กัมพูชา', 'เมียนมา', 'อื่น ๆ'],
    'religion': ['พุทธ', 'อิสลาม', 'คริสต์', 'อื่น ๆ', 'ไม่นับถือศาสนา'],
    'marital': ['โสด', 'สมรส', 'หม้าย', 'หย่า', 'แยกกันอยู่'],
  };

  /// ยาที่แพ้บ่อย ให้แตะเพิ่มได้เลย
  static const List<String> _regCommonAllergy = [
    'Penicillin',
    'Sulfa',
    'NSAIDs',
    'Aspirin',
    'Contrast media',
  ];

  static const List<String> _thMonths = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  TextEditingController _regCtl(String k) =>
      _regIn.putIfAbsent(k, TextEditingController.new);

  void _openRegister() {
    for (final c in _regIn.values) {
      c.clear();
    }
    final now = DateTime.now();
    setState(() {
      _regPick
        ..clear()
        ..addAll({'nation': 'ไทย', 'ethnic': 'ไทย'});
      _regSex = null;
      _regBlood = null;
      _regDob = null;
      _regPhoto = null;
      _regAllergy.clear();
      _regNoAllergy = false;
      _regUnknown = false;
      // HN ใหม่: ปี พ.ศ. 2 หลัก + ลำดับ
      _regHn = '${(now.year + 543) % 100}'
          '${(now.millisecondsSinceEpoch % 10000000).toString().padLeft(7, '0')}';
      _regOpen = true;
    });
  }

  void _closeRegister() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _regOpen = false);
  }

  /// อ่านบัตรประชาชน (จำลอง): เติมข้อมูลจากบัตรให้ตรวจทาน
  void _regReadCard() {
    HapticFeedback.selectionClick();
    setState(() {
      _regUnknown = false;
      _regPick['prefix'] = 'นาย';
      _regCtl('name').text = 'ทดลอง ทดสอบ';
      _regCtl('cid').text = '1 1037 00123 45 6';
      _regCtl('addr').text =
          '99/1 หมู่ 3 ถ.เจริญนคร แขวงคลองสาน เขตคลองสาน กรุงเทพมหานคร 10600';
      _regDob = DateTime(1985, 3, 12);
      _regSex = 'ชาย';
      _regPick['religion'] = 'พุทธ';
      _regPhoto ??= _faceUrl(_regHn);
    });
  }

  String get _regName {
    if (_regUnknown) return 'ไม่ทราบชื่อ #${_regCount + 1}';
    final n = _regCtl('name').text.trim();
    return n.isEmpty ? '' : '${_regPick['prefix'] ?? ''}$n';
  }

  bool get _regReady => _regName.isNotEmpty && _regSex != null;

  String _regAge(DateTime d) {
    final now = DateTime.now();
    var y = now.year - d.year;
    var m = now.month - d.month;
    if (now.day < d.day) m--;
    if (m < 0) {
      y--;
      m += 12;
    }
    return y > 0 ? '$y ปี $m เดือน' : '$m เดือน';
  }

  String _thDate(DateTime d) =>
      '${d.day} ${_thMonths[d.month - 1]} ${d.year + 543}';

  Future<void> _regPickDob() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _regDob ?? DateTime(now.year - 40),
      firstDate: DateTime(1900),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.input,
      helpText: 'วัน เดือน ปี เกิด (ค.ศ.)',
    );
    if (d != null) setState(() => _regDob = d);
  }

  void _regAddAllergy(String a) {
    final v = a.trim();
    if (v.isEmpty || _regAllergy.contains(v)) return;
    setState(() {
      _regAllergy.add(v);
      _regNoAllergy = false;
    });
  }

  /// ลงทะเบียน: เข้าคิวรอคัดกรอง แล้วกางรายชื่อช่วงคัดกรองให้เห็นทันที
  void _saveRegister() {
    if (!_regReady) return;
    final name = _regName;
    _patients.insert(
        0, _P(_regHn, name, _Stage.triage, 0, note: 'ลงทะเบียนใหม่'));
    _regCount++;
    HapticFeedback.mediumImpact();
    setState(() {
      _regOpen = false;
      _open = _Phase.triage;
      _listFilter = _ListFilter.all;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ลงทะเบียน $name (HN $_regHn) แล้ว · รอคัดกรอง',
            style: _t(12.0, color: Colors.white))));
  }

  // ------------------------------------------------------------ ชิ้นส่วน UI

  Widget _regCard(String title, IconData icon, Widget child,
      {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
      decoration: _clyCardDeco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(icon, size: 16.0, color: _blue),
            const SizedBox(width: 6.0),
            Expanded(
              child: Text(title,
                  style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
            ),
            if (trailing != null) trailing,
          ]),
          const SizedBox(height: 12.0),
          child,
        ],
      ),
    );
  }

  Widget _regLabel(String l, {bool req = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text.rich(
            TextSpan(children: [
              TextSpan(text: l),
              if (req) TextSpan(text: ' *', style: _t(11.0, color: _red)),
            ]),
            style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
      );

  InputDecoration _regDeco(String hint, {Widget? prefix}) => InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: _t(12.5, color: _g5),
        prefixIcon: prefix,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 36.0, minHeight: 20.0),
        filled: true,
        fillColor: _panelSoft,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: _line)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: _blue, width: 1.4)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: _line)),
      );

  Widget _regText(String k, String label, String hint,
      {bool req = false,
      TextInputType? type,
      IconData? icon,
      bool enabled = true,
      int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _regLabel(label, req: req),
        TextField(
          controller: _regCtl(k),
          enabled: enabled,
          keyboardType: type,
          minLines: lines,
          maxLines: lines,
          textInputAction:
              lines > 1 ? TextInputAction.newline : TextInputAction.next,
          onChanged: (_) => setState(() {}),
          style: _t(13.0, color: _inkTitle, weight: FontWeight.w500),
          decoration: _regDeco(hint,
              prefix:
                  icon == null ? null : Icon(icon, size: 16.0, color: _ink3)),
        ),
      ],
    );
  }

  /// ช่องเลือกจากรายการ (หน้าตาเหมือนช่องพิมพ์ + ลูกศร)
  Widget _regSelect(String k, String label, {List<String>? items}) {
    final opts = items ?? _regChoices[k]!;
    final v = _regPick[k];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _regLabel(label),
        PopupMenuButton<String>(
          tooltip: label,
          position: PopupMenuPosition.under,
          color: _panel,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          onSelected: (s) => setState(() => _regPick[k] = s),
          itemBuilder: (_) => [
            for (final o in opts)
              PopupMenuItem(
                value: o,
                height: 40.0,
                child: Row(children: [
                  Expanded(
                      child: Text(o,
                          style: _t(12.5,
                              color: o == v ? _blue : _ink,
                              weight:
                                  o == v ? FontWeight.w700 : FontWeight.w500))),
                  if (o == v)
                    const Icon(Icons.check_rounded, size: 16.0, color: _blue),
                ]),
              ),
          ],
          child: Container(
            height: 44.0,
            padding: const EdgeInsets.only(left: 12.0, right: 8.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: _line),
            ),
            child: Row(children: [
              Expanded(
                child: Text(v ?? 'เลือก',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(13.0, color: v == null ? _g5 : _inkTitle)),
              ),
              const Icon(Icons.expand_more_rounded, size: 18.0, color: _ink3),
            ]),
          ),
        ),
      ],
    );
  }

  /// ปุ่มเลือกแบบเม็ดยาเรียงกัน (เพศ · หมู่เลือด) ที่เลือก = กรมท่านูน
  Widget _regSeg(List<String> opts, String? v, ValueChanged<String> on) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(11.0),
        border: Border.all(color: _line),
      ),
      child: Row(children: [
        for (final o in opts)
          Expanded(
            child: _Press(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  on(o);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 36.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: o == v ? _glossGrad(_blue) : null,
                    borderRadius: BorderRadius.circular(9.0),
                    boxShadow: o == v ? _glossLift(_blue) : null,
                  ),
                  foregroundDecoration:
                      o == v ? const _InnerGloss(9.0, dark: true) : null,
                  child: Text(o,
                      style: _t(12.5,
                          color: o == v ? Colors.white : _ink2,
                          weight: o == v ? FontWeight.w700 : FontWeight.w500)),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _regChip(String t, {VoidCallback? onTap, VoidCallback? onDel}) {
    final on = onDel != null;
    return _Press(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 5.0, on ? 5.0 : 10.0, 5.0),
          decoration: BoxDecoration(
            color: on ? _red.withValues(alpha: 0.08) : _panel,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: on ? _red.withValues(alpha: 0.4) : _line),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (!on) ...[
              const Icon(Icons.add_rounded, size: 14.0, color: _ink3),
              const SizedBox(width: 3.0),
            ],
            Text(t,
                style: _t(11.5,
                    color: on ? _red : _ink2,
                    weight: on ? FontWeight.w700 : FontWeight.w500)),
            if (on) ...[
              const SizedBox(width: 2.0),
              GestureDetector(
                onTap: onDel,
                child: const Icon(Icons.close_rounded, size: 15.0, color: _red),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ การ์ดแต่ละใบ

  /// การ์ดตัวตน: รูป · HN · เพศ · หมู่เลือด
  Widget _regIdCard() {
    final photo = _regPhoto;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 16.0),
      decoration: _clyCardDeco,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _Press(
              child: GestureDetector(
                // ถ่ายรูป (จำลอง): ใช้รูปจากชุดใบหน้า
                onTap: () =>
                    setState(() => _regPhoto = photo ?? _faceUrl(_regHn)),
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    width: 104.0,
                    height: 104.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDCE6F5),
                      border: Border.all(color: _panel, width: 3.0),
                      boxShadow: _glossLift(const Color(0xFF0B1B3F)),
                    ),
                    child: ClipOval(
                      child: photo == null
                          ? const Icon(Icons.person_rounded,
                              size: 56.0, color: _blue4)
                          : Image.asset(photo, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    right: 0.0,
                    bottom: 2.0,
                    child: Container(
                      width: 30.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _glossGrad(_blue),
                        border: Border.all(color: _panel, width: 2.0),
                      ),
                      child: const Icon(Icons.photo_camera_rounded,
                          size: 15.0, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Center(
            child: Text(_regName.isEmpty ? 'ผู้ป่วยใหม่' : _regName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(15.0,
                    color: _regName.isEmpty ? _g5 : _inkTitle,
                    weight: FontWeight.w700)),
          ),
          const SizedBox(height: 2.0),
          Center(
            child: Text(
                _regDob == null
                    ? 'HN $_regHn'
                    : 'HN $_regHn · ${_regAge(_regDob!)}',
                style: _num(11.5, color: _ink3)),
          ),
          const SizedBox(height: 16.0),
          _regLabel('เพศ', req: true),
          _regSeg(const ['ชาย', 'หญิง', 'ไม่ระบุ'], _regSex,
              (s) => setState(() => _regSex = s)),
          const SizedBox(height: 14.0),
          _regLabel('หมู่เลือด'),
          _regSeg(const ['A', 'B', 'AB', 'O', '?'], _regBlood,
              (s) => setState(() => _regBlood = s)),
        ],
      ),
    );
  }

  Widget _regPersonCard(bool wide) {
    Widget pair(Widget a, Widget b) => wide
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: a),
            const SizedBox(width: 12.0),
            Expanded(child: b),
          ])
        : Column(children: [a, const SizedBox(height: 12.0), b]);
    return _regCard(
      'ข้อมูลส่วนตัว',
      Icons.badge_rounded,
      Column(children: [
        if (_regUnknown)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
                'ลงทะเบียนเป็น "$_regName" ก่อน แก้ชื่อได้เมื่อทราบตัวตน',
                style: _t(12.0, color: _ink2)),
          )
        else
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 120.0,
              child: _regSelect('prefix', 'คำนำหน้า', items: _regPrefixes),
            ),
            const SizedBox(width: 12.0),
            Expanded(
                child: _regText('name', 'ชื่อ-นามสกุล', 'ชื่อ นามสกุล',
                    req: true)),
          ]),
        const SizedBox(height: 12.0),
        pair(
          _regText('cid', 'เลขบัตรประชาชน', '0 0000 00000 00 0',
              type: TextInputType.number,
              icon: Icons.credit_card_rounded,
              enabled: !_regUnknown),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _regLabel('วัน เดือน ปี เกิด'),
              _Press(
                child: GestureDetector(
                  onTap: _regPickDob,
                  child: Container(
                    height: 44.0,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: _line),
                    ),
                    child: Row(children: [
                      const Icon(Icons.cake_rounded, size: 16.0, color: _ink3),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                            _regDob == null
                                ? 'เลือกวันเกิด'
                                : _thDate(_regDob!),
                            style: _t(13.0,
                                color: _regDob == null ? _g5 : _inkTitle)),
                      ),
                      if (_regDob != null)
                        Text(_regAge(_regDob!),
                            style: _t(11.0,
                                color: _blue, weight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        pair(
          _regText('phone', 'เบอร์โทรศัพท์', '090-000-0000',
              type: TextInputType.phone, icon: Icons.call_rounded),
          _regSelect('job', 'อาชีพ'),
        ),
      ]),
      trailing: _Press(
        child: GestureDetector(
          onTap: () => setState(() => _regUnknown = !_regUnknown),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
                _regUnknown
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 18.0,
                color: _regUnknown ? _blue : _ink3),
            const SizedBox(width: 4.0),
            Text('ไม่ทราบชื่อ', style: _t(11.5, color: _ink2)),
          ]),
        ),
      ),
    );
  }

  Widget _regGeneralCard(bool wide) {
    final items = [
      _regSelect('ethnic', 'เชื้อชาติ'),
      _regSelect('nation', 'สัญชาติ'),
      _regSelect('religion', 'ศาสนา'),
      _regSelect('marital', 'สถานภาพ'),
    ];
    return _regCard(
      'ข้อมูลทั่วไป',
      Icons.people_alt_rounded,
      wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 12.0),
                Expanded(child: items[i]),
              ],
            ])
          : Wrap(runSpacing: 12.0, children: items),
    );
  }

  /// การแพ้ยา: ข้อมูลความปลอดภัย แพ้ = ชิปแดง · ยืนยันไม่มี = ติ๊ก
  Widget _regAllergyCard() {
    return _regCard(
      'ประวัติการแพ้ยา',
      Icons.medication_rounded,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _regCtl('allergy'),
            enabled: !_regNoAllergy,
            textInputAction: TextInputAction.done,
            onSubmitted: (s) {
              _regAddAllergy(s);
              _regCtl('allergy').clear();
            },
            style: _t(13.0, color: _inkTitle),
            decoration: _regDeco(
                _regNoAllergy
                    ? 'ยืนยันแล้วว่าไม่มีประวัติแพ้'
                    : 'พิมพ์ชื่อยาแล้วกด ✓',
                prefix:
                    const Icon(Icons.search_rounded, size: 16.0, color: _ink3)),
          ),
          const SizedBox(height: 10.0),
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            for (final a in _regAllergy)
              _regChip(a, onDel: () => setState(() => _regAllergy.remove(a))),
            if (!_regNoAllergy)
              for (final a in _regCommonAllergy)
                if (!_regAllergy.contains(a))
                  _regChip(a, onTap: () => _regAddAllergy(a)),
          ]),
        ],
      ),
      trailing: _Press(
        child: GestureDetector(
          onTap: () => setState(() {
            _regNoAllergy = !_regNoAllergy;
            if (_regNoAllergy) _regAllergy.clear();
          }),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
                _regNoAllergy
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 18.0,
                color: _regNoAllergy ? _blue : _ink3),
            const SizedBox(width: 4.0),
            Text('ไม่มีประวัติแพ้', style: _t(11.5, color: _ink2)),
          ]),
        ),
      ),
    );
  }

  Widget _regAddressCard() => _regCard(
        'ที่อยู่',
        Icons.location_on_rounded,
        _regText('addr', 'ที่อยู่ปัจจุบัน',
            'บ้านเลขที่ หมู่ ซอย ถนน ตำบล อำเภอ จังหวัด รหัสไปรษณีย์',
            lines: 2),
      );

  // ------------------------------------------------------------ ทั้งหน้า

  Widget _registerPage() {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 760.0;
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final now = TimeOfDay.now();
    final hhmm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _regPersonCard(wide),
        const SizedBox(height: 12.0),
        _regAllergyCard(),
        const SizedBox(height: 12.0),
        _regGeneralCard(wide),
        const SizedBox(height: 12.0),
        _regAddressCard(),
      ],
    );

    return Material(
      color: _panelSoft,
      child: Column(children: [
        // แถบบน: กลับ · ชื่อหน้า · อ่านบัตรประชาชน
        Container(
          height: 58.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: const BoxDecoration(
            color: _panel,
            border: Border(bottom: BorderSide(color: _line)),
          ),
          child: Row(children: [
            _topIcon(Icons.arrow_back_rounded, false, _closeRegister),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ลงทะเบียนผู้ป่วยใหม่',
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text('เข้าห้องฉุกเฉิน $hhmm น.',
                      style: _t(10.5, color: _ink3)),
                ],
              ),
            ),
            SizedBox(
              width: 170.0,
              child: _navBtn(
                  'อ่านบัตรประชาชน', Icons.contact_mail_rounded, _regReadCard,
                  primary: false),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0 + kb),
            child: wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 250.0, child: _regIdCard()),
                    const SizedBox(width: 12.0),
                    Expanded(child: right),
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _regIdCard(),
                      const SizedBox(height: 12.0),
                      right,
                    ],
                  ),
          ),
        ),
        // แถบล่าง: ยกเลิก · ลงทะเบียน (ต้องมีชื่อ + เพศ)
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 12.0),
          decoration: const BoxDecoration(
            color: _panel,
            border: Border(top: BorderSide(color: _line)),
          ),
          child: Row(children: [
            Expanded(
              child: Text(
                  _regReady
                      ? 'ลงทะเบียนแล้วจะเข้าคิว "รอคัดกรอง" ทันที'
                      : 'กรอกชื่อ (หรือเลือกไม่ทราบชื่อ) และเพศ',
                  style: _t(11.0, color: _ink3)),
            ),
            SizedBox(
              width: 120.0,
              child: _navBtn('ยกเลิก', Icons.close_rounded, _closeRegister,
                  primary: false),
            ),
            const SizedBox(width: 10.0),
            SizedBox(
              width: 220.0,
              child: _navBtn('ลงทะเบียน', Icons.how_to_reg_rounded,
                  _regReady ? _saveRegister : null),
            ),
          ]),
        ),
      ]),
    );
  }

  /// ปุ่มเปิดหน้าลงทะเบียน บนสุดของแผงซ้ายหน้าภาพรวม (พื้นกรมท่า)
  Widget _registerButton() => _Press(
        child: GestureDetector(
          onTap: _openRegister,
          child: Container(
            height: 40.0,
            decoration: BoxDecoration(
              gradient: _glossWhite,
              borderRadius: BorderRadius.circular(11.0),
              boxShadow: _glossLift(const Color(0xFF000A2E)),
            ),
            foregroundDecoration: const _InnerGloss(11.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.person_add_alt_1_rounded,
                  size: 18.0, color: _blue),
              const SizedBox(width: 6.0),
              Text('ลงทะเบียนผู้ป่วยใหม่',
                  style: _t(12.5, color: _blue, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );
}
