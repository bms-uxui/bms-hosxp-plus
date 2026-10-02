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

  /// โหมดลงทะเบียนด่วน (เปิดจากขั้นคัดกรอง): ระบุตัวตน + อาการสำคัญ แล้วส่ง Triage
  bool _regQuick = false;

  /// มาโดย · อาการสำคัญที่เลือก · ผู้แจ้งข้อมูล · พบในระบบ HIS แล้ว · เวลามาถึง
  String _qArrive = 'เดินมาเอง';
  final Set<String> _qCc = {};
  String _qInformant = 'ผู้ป่วยเอง';
  bool _qFound = false;

  /// กำลังอ่านบัตร (เล่นเส้นสแกนบนบัตรจำลอง)
  bool _qReading = false;

  /// โหมดปกติ: layout เดียวกับลงทะเบียนด่วน + ฟอร์มละเอียด (แพ้ยา ข้อมูลทั่วไป ที่อยู่ อาชีพ)
  bool _qNormal = false;

  /// รูปหน้าผู้ป่วยที่ถ่ายตอนรับ (กรณีด่วน ยังไม่รู้ตัวตน) เก็บไว้ในเคส
  String? _qShot;

  /// debugger ไซเรน 3D (debug build): ท่า (x, y, z, scale) + กรอบ (right, bottom, size)
  bool _srDebug = false;
  (double, double, double, double) _srPose = (-0.13, -1.98, -0.38, 0.63);
  (double, double, double) _srBox = (-60.0, -53.0, 200.0);
  DateTime _qAt = DateTime.now();
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

  /// เปิดลงทะเบียนด่วน (ขั้นคัดกรอง)
  void _openQuickRegister() {
    _openRegister();
    setState(() {
      _regQuick = true;
      _qArrive = 'เดินมาเอง';
      _qCc.clear();
      _qInformant = 'ผู้ป่วยเอง';
      _qFound = false;
      _qAt = DateTime.now();
      _qShot = null;
    });
  }

  void _closeRegister() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _regOpen = false;
      _regQuick = false;
    });
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
    ErFeedback.confirm();
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
    if (_regQuick) return _quickRegisterPage();
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
            _regModeSwitch(),
            const SizedBox(width: 12.0),
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
  /// quick = เปิดหน้าลงทะเบียนด่วน (ใช้ในขั้นคัดกรอง)
  Widget _registerButton({bool quick = false}) => _Press(
        child: GestureDetector(
          onTap: quick ? _openQuickRegister : _openRegister,
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

/// มาโดย (ตัวเลือกจริงของหน้าลงทะเบียน ER)
const List<(String, IconData)> _qArrivals = [
  ('เดินมาเอง', Icons.directions_walk_rounded),
  ('รถเข็น', Icons.accessible_rounded),
  ('EMS / 1669', Icons.airport_shuttle_rounded),
  ('Refer', Icons.local_hospital_rounded),
  ('อื่น ๆ', Icons.directions_car_rounded),
];

/// อาการสำคัญแบบแตะเลือก: (อาการ, อาการวิกฤต = กรอบแดง)
const List<(String, bool)> _qCcOpts = [
  ('หมดสติ', true),
  ('เจ็บหน้าอก', true),
  ('หายใจไม่ออก', true),
  ('แขนขาอ่อนแรง', true),
  ('ชัก', true),
  ('เลือดออกมาก', true),
  ('อุบัติเหตุรุนแรง', true),
  // งู แมงป่อง ตะขาบ ผึ้ง ต่อ: อาจต้อง antivenom (Standing order Snake bite)
  ('สัตว์มีพิษกัด', true),
  ('ไข้', false),
  ('ปวดท้อง', false),
  ('เวียนศีรษะ', false),
  ('แผล/บาดเจ็บ', false),
  ('ปวดศีรษะ', false),
  ('แพ้ยา/แพ้อาหาร', false),
  ('อื่น ๆ', false),
];

extension _QuickRegisterPart on _ErFlowHomeWidgetState {
  String _qClock(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// ค้นหา/อ่านบัตร (จำลอง): พบประวัติใน HIS แล้วเติมข้อมูลให้ตรวจทาน
  void _qLookup() {
    HapticFeedback.selectionClick();
    setState(() {
      _regUnknown = false;
      _qFound = true;
      _regHn = '00012345';
      _regPick['prefix'] = 'นาย';
      _regCtl('name').text = 'สมชาย ใจดี';
      _regCtl('cid').text = '3 4001 00123 45 6';
      _regCtl('phone').text = '0812345678';
      _regCtl('addr').text = '123 ม.1 ต.ในเมือง อ.เมือง จ.ขอนแก่น';
      _regDob = DateTime(1962, 1, 1);
      _regSex = 'ชาย';
      _regAllergy
        ..clear()
        ..add('Penicillin');
      // รูปจากบัตร (จำลอง: ใช้ใบหน้าชายให้ตรงกับเพศในบัตร)
      _regPhoto = _faceUrl('670123456');
    });
  }

  /// ถ่ายรูปหน้าผู้ป่วยด้วยกล้อง (ด่วนมาก ยังระบุตัวไม่ได้): เก็บรูปไว้ในเคส
  /// ลงทะเบียนแบบไม่ทราบชื่อ ใช้ยืนยันตัวตนภายหลัง
  Future<void> _qTakePhoto() async {
    HapticFeedback.selectionClick();
    final f = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1024,
        imageQuality: 80);
    if (f == null || !mounted) return;
    setState(() {
      _qShot = f.path;
      _regUnknown = true;
      _qFound = false;
      _regSex ??= 'ไม่ระบุ';
    });
  }

  /// ส่งเข้า Triage (หรือ RESUS ทันที): เข้ารายชื่อขั้นคัดกรองพร้อมอาการสำคัญ
  void _qSend({bool resus = false}) {
    if (!resus && !_regReady) return;
    final name = _regName.isEmpty ? 'ไม่ทราบชื่อ #${_regCount + 1}' : _regName;
    final cc = _qCc.isEmpty ? '' : ' ${_qCc.join(', ')}';
    _patients.insert(
        0,
        _P(_regHn, name, _Stage.triage, 0,
            esi: resus ? _Esi.one : null,
            note: resus ? 'ส่งเข้า RESUS$cc' : '$_qArrive$cc'));
    _regCount++;
    ErFeedback.confirm();
    setState(() {
      _regOpen = false;
      _regQuick = false;
      _open = _Phase.triage;
      _listFilter = _ListFilter.all;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            resus
                ? 'ส่ง $name เข้า RESUS แล้ว'
                : 'ลงทะเบียน $name แล้ว ส่งเข้าคิวคัดกรอง',
            style: _t(12.0, color: Colors.white))));
  }

  /// ปุ่มตัวเลือกใหญ่ (มาโดย / ผู้แจ้ง)
  Widget _qOpt(String label, IconData? icon, bool on, VoidCallback onTap,
          {double h = 52.0}) =>
      _Press(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: h,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: on ? _blue.withValues(alpha: 0.08) : _panel,
              borderRadius: BorderRadius.circular(12.0),
              border:
                  Border.all(color: on ? _blue : _line, width: on ? 1.6 : 1.0),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (icon != null) ...[
                Icon(icon, size: 20.0, color: on ? _blue : _ink2),
                const SizedBox(width: 7.0),
              ],
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(12.5,
                        color: on ? _blue : _inkTitle,
                        weight: on ? FontWeight.w700 : FontWeight.w600)),
              ),
            ]),
          ),
        ),
      );

  Widget _qField(String k, String hint, {IconData? icon, TextInputType? kb}) =>
      TextField(
        controller: _regCtl(k),
        keyboardType: kb,
        onChanged: (_) => setState(() {}),
        style: _t(13.0, color: _inkTitle, weight: FontWeight.w500),
        decoration: _regDeco(hint,
            prefix: icon == null ? null : Icon(icon, size: 18.0, color: _ink3)),
      );

  /// อ่านบัตร: เส้นสแกนวิ่งบนบัตรสักครู่ แล้วข้อมูลไหลเข้าบัตร
  Future<void> _qRead() async {
    if (_qReading) return;
    HapticFeedback.mediumImpact();
    setState(() => _qReading = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    _qLookup();
    setState(() => _qReading = false);
  }

  /// ปิดเลขบัตร (PDPA): เห็นหลักแรกกับ 3 หลักท้าย ที่เหลือเป็น x
  /// เช่น 3 4001 00123 45 6 → 3 xxxx xxxxx 45 6
  String _qMaskCid(String cid) {
    var n = 0;
    final digits = cid.replaceAll(RegExp(r'\D'), '').length;
    return cid.split('').map((ch) {
      if (!RegExp(r'\d').hasMatch(ch)) return ch;
      n++;
      return n == 1 || n > digits - 3 ? ch : 'x';
    }).join();
  }

  /// ข้อมูลหน้าบัตรจากที่อ่านได้ (ชื่อไทยแยกชื่อ/สกุล อังกฤษเป็นตัวอย่างถอดเสียง)
  _IdFace _qFace() {
    String th(DateTime d) => _thDate(d);
    const en = [
      'Jan.',
      'Feb.',
      'Mar.',
      'Apr.',
      'May',
      'Jun.',
      'Jul.',
      'Aug.',
      'Sep.',
      'Oct.',
      'Nov.',
      'Dec.'
    ];
    String eng(DateTime d) => '${d.day} ${en[d.month - 1]} ${d.year}';
    final dob = _regDob;
    final issue = DateTime(2024, 3, 28), exp = DateTime(2033, 3, 28);
    return _IdFace(
      cid: _qMaskCid(_regCtl('cid').text),
      nameTh: _regName,
      first: 'Mr. Somchai',
      last: 'Jaidee',
      dobTh: dob == null ? '-' : th(dob),
      dobEn: dob == null ? '-' : eng(dob),
      religion: _regPick['religion'] ?? 'พุทธ',
      addr1: '123 หมู่ที่ 1',
      addr2: 'ต.ในเมือง อ.เมืองขอนแก่น จ.ขอนแก่น',
      issueTh: th(issue),
      issueEn: eng(issue),
      expTh: th(exp),
      expEn: eng(exp),
    );
  }

  /// หน้าบัตรประชาชนแบบบัตรจริง (สัดส่วน 85.6 × 54 มม.)
  /// ยังไม่อ่าน = บัตรตัวอย่างค่าจาง + ป้าย "แตะเพื่ออ่านบัตร" · กำลังอ่าน = แสงสแกนกวาด
  Widget _qIdCard() {
    final filled = _qFound;
    return _Press(
      scale: 0.98,
      child: GestureDetector(
        onTap: _qRead,
        child: AspectRatio(
          aspectRatio: 480 / 303,
          child: Container(
            decoration: BoxDecoration(
              // พื้นบัตรตาม Figma 345-35: ฟ้าไล่เฉดบนลงล่าง
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD3E5F5),
                  Color(0xFFDFECF8),
                  Color(0xFFE8F2FB)
                ],
                stops: [0.0, 0.45, 1.0],
              ),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFB9D2EC), width: 1.2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1A001334),
                    blurRadius: 14.0,
                    offset: Offset(0, 6)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth, h = c.maxHeight;
              return Stack(children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _IdFacePainter(filled ? _qFace() : const _IdFace(),
                        blank: !filled),
                  ),
                ),
                // รูปถ่ายในกรอบรูปของบัตร (พิกัด 358,151 – 457,271)
                if (filled && _regPhoto != null)
                  Positioned(
                    left: w * 358 / 480,
                    top: h * 151 / 303,
                    width: w * 99 / 480,
                    height: h * 120 / 303,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: ColorFiltered(
                        // รูปบนบัตรจริงเป็นโทนจาง
                        colorFilter: const ColorFilter.matrix([
                          0.6,
                          0.3,
                          0.1,
                          0,
                          10,
                          0.3,
                          0.6,
                          0.1,
                          0,
                          10,
                          0.3,
                          0.3,
                          0.4,
                          0,
                          20,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: Image.asset(_regPhoto!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                if (!filled)
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(100.0),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x33001334),
                              blurRadius: 10.0,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                            _qReading
                                ? Icons.sync_rounded
                                : Icons.contactless_rounded,
                            size: 16.0,
                            color: Colors.white),
                        const SizedBox(width: 6.0),
                        Text(_qReading ? 'กำลังอ่านบัตร' : 'แตะเพื่ออ่านบัตร',
                            style: _t(12.0,
                                color: Colors.white, weight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                if (_qReading)
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1100),
                      curve: Curves.easeInOut,
                      builder: (context, v, _) => Align(
                        alignment: Alignment(0.0, -1.0 + 2.0 * v),
                        child: Container(
                          height: 3.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5FB2FF),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF5FB2FF)
                                      .withValues(alpha: 0.6),
                                  blurRadius: 12.0,
                                  spreadRadius: 2.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  /// การ์ดเรียบ (clean): พื้นขาว หัวข้อเล็กเทา ไม่มีแถบสี
  Widget _qCard(String title, Widget child,
          {String? count, Widget? trailing, EdgeInsets? pad}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: pad ?? const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Text(title,
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
              if (count != null) ...[
                const SizedBox(width: 8.0),
                Text(count,
                    style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
              ],
              const Spacer(),
              if (trailing != null) trailing,
            ]),
            const SizedBox(height: 8.0),
            child,
          ],
        ),
      );

  /// สลับโหมดลงทะเบียน: เร่งด่วน (ลงทะเบียนด่วน) | ปกติ (ข้อมูลประจำตัวครบ)
  Widget _regModeSwitch() {
    Widget seg(String l, IconData ic, bool on, VoidCallback onTap,
            {Widget? lead}) =>
        GestureDetector(
          onTap: on
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                EdgeInsets.fromLTRB(lead != null ? 5.0 : 14.0, 5.0, 14.0, 5.0),
            decoration: BoxDecoration(
              color: on ? (l == 'เร่งด่วน' ? _red : _blue) : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              lead ??
                  SizedBox(
                      width: 26.0,
                      height: 26.0,
                      child: Icon(ic,
                          size: 16.0, color: on ? Colors.white : _ink2)),
              const SizedBox(width: 6.0),
              Text(l,
                  style: _t(12.0,
                      color: on ? Colors.white : _ink2,
                      weight: FontWeight.w600)),
            ]),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg('เร่งด่วน', Icons.bolt_rounded, _regQuick && !_qNormal, () {
          setState(() {
            _regQuick = true;
            _qNormal = false;
          });
        },
            // ไฟไซเรน 3D ในวงขาว (ตัดกับพื้นแดง) ตั้งตรง เห็นโดมเต็ม
            lead: Container(
              width: 26.0,
              height: 26.0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: const OverflowBox(
                maxWidth: 34.0,
                maxHeight: 34.0,
                alignment: Alignment(0.0, 0.15),
                child: ErSiren3D(pose: (0.12, -0.6, 0.0, 0.62)),
              ),
            )),
        seg('ปกติ', Icons.assignment_ind_outlined, !_regQuick || _qNormal, () {
          setState(() {
            _regQuick = true;
            _qNormal = true;
          });
        }),
      ]),
    );
  }

  /// สัญญาณชีพแรกรับ (โหมดปกติ): ช่องตัวเลขพร้อมหน่วย ค่าเกินเกณฑ์ = กรอบ/ตัวแดง
  Widget _qVitalCard() {
    // (key, ชื่อ, หน่วย, ต่ำสุดปกติ, สูงสุดปกติ)
    const fields = [
      ('vs_sbp', 'SBP', 'mmHg', 90.0, 180.0),
      ('vs_dbp', 'DBP', 'mmHg', 50.0, 110.0),
      ('vs_hr', 'ชีพจร', '/min', 50.0, 120.0),
      ('vs_rr', 'หายใจ', '/min', 10.0, 24.0),
      ('vs_bt', 'อุณหภูมิ', '°C', 36.0, 38.0),
      ('vs_spo2', 'SpO₂', '%', 94.0, 100.0),
    ];
    Widget box((String, String, String, double, double) f) {
      final (k, label, unit, lo, hi) = f;
      final v = double.tryParse(_regCtl(k).text.trim());
      final bad = v != null && (v < lo || v > hi);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  _t(11.0, color: bad ? _red : _ink2, weight: FontWeight.w600)),
          const SizedBox(height: 4.0),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 44.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: bad ? _red.withValues(alpha: 0.06) : _panelSoft,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                  color:
                      bad ? _red.withValues(alpha: 0.5) : Colors.transparent),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _regCtl(k),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  style: _num(16.0,
                      color: bad ? _red : _inkTitle, weight: FontWeight.w700),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '-',
                    hintStyle: _t(14.0, color: _g5),
                  ),
                ),
              ),
              Text(unit, style: _t(11.0, color: _ink3)),
            ]),
          ),
        ],
      );
    }

    final now = DateTime.now();
    return _qCard(
      'สัญญาณชีพแรกรับ',
      count: 'วัดเวลา ${_clock(_qClock(now))}',
      LayoutBuilder(builder: (context, c) {
        final w = (c.maxWidth - 10.0 * 2) / 3;
        return Wrap(spacing: 10.0, runSpacing: 10.0, children: [
          for (final f in fields) SizedBox(width: w, child: box(f)),
        ]);
      }),
    );
  }

  /// panel หนึ่งคอลัมน์: พื้นโปร่งบนภาพพื้นหลัง หัวข้อเล็ก เนื้อหาเลื่อนในตัว
  Widget _qPanel(String title, IconData icon, List<Widget> children) =>
      Container(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 8.0),
              child: Row(children: [
                Icon(icon, size: 16.0, color: _ink2),
                const SizedBox(width: 6.0),
                Text(title,
                    style: _t(12.5, color: _ink2, weight: FontWeight.w700)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      );

  /// panel ขวาสุด: สรุปก่อนส่ง (ใคร แพ้ยา อาการวิกฤต เวลา ความครบ) + ปุ่มส่ง
  Widget _qSendPanel(Widget resus, List<(String, bool)> steps, int crit) {
    final ready = _regReady;
    Widget row(IconData ic, String k, String v, {Color? c}) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(ic, size: 15.0, color: c ?? _ink3),
            const SizedBox(width: 8.0),
            SizedBox(
              width: 64.0,
              child: Text(k,
                  style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(v,
                  style:
                      _t(12.5, color: c ?? _inkTitle, weight: FontWeight.w600)),
            ),
          ]),
        );
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14001334), blurRadius: 18.0, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ส่งผู้ป่วย',
              style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 12.0),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  row(Icons.person_rounded, 'ผู้ป่วย',
                      _regName.isEmpty ? '-' : _regName),
                  if (_qFound) row(Icons.tag_rounded, 'HN', _regHn),
                  if (_regAllergy.isNotEmpty && _qFound)
                    row(Icons.warning_rounded, 'แพ้ยา',
                        _regAllergy.join(', ').toUpperCase(),
                        c: _red),
                  row(Icons.login_rounded, 'มาโดย', _qArrive),
                  row(Icons.monitor_heart_outlined, 'อาการ',
                      _qCc.isEmpty ? 'ยังไม่ระบุ' : _qCc.join(', '),
                      c: crit > 0 ? _red : null),
                  row(Icons.schedule_rounded, 'มาถึง',
                      '${_thDate(_qAt)}  ${_clock(_qClock(_qAt))}'),
                ],
              ),
            ),
          ),
          _navBtn('ส่งเข้า Triage ทันที', Icons.arrow_forward_rounded,
              ready ? () => _qSend() : null),
        ],
      ),
    );
  }

  /// ไอคอนประจำอาการสำคัญ
  IconData _qCcIcon(String c) => switch (c) {
        'หมดสติ' => Icons.airline_seat_flat_rounded,
        'เจ็บหน้าอก' => Icons.favorite_rounded,
        'หายใจไม่ออก' => Icons.air_rounded,
        'แขนขาอ่อนแรง' => Icons.accessibility_new_rounded,
        'ชัก' => Icons.bolt_rounded,
        'เลือดออกมาก' => Icons.water_drop_rounded,
        'อุบัติเหตุรุนแรง' => Icons.car_crash_rounded,
        'สัตว์มีพิษกัด' => Icons.pest_control_rounded,
        'ไข้' => Icons.thermostat_rounded,
        'ปวดท้อง' => Icons.sick_rounded,
        'เวียนศีรษะ' => Icons.motion_photos_on_rounded,
        'แผล/บาดเจ็บ' => Icons.healing_rounded,
        'ปวดศีรษะ' => Icons.psychology_alt_rounded,
        'แพ้ยา/แพ้อาหาร' => Icons.no_food_rounded,
        _ => Icons.more_horiz_rounded,
      };

  Widget _qCcTile(String l, bool crit) {
    final on = _qCc.contains(l);
    final c = crit ? _red : _blue;
    return _Press(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => on ? _qCc.remove(l) : _qCc.add(l));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 56.0,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            color: on ? c : _panel,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: on ? c : (crit ? c.withValues(alpha: 0.35) : _line)),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_qCcIcon(l),
                size: 20.0, color: on ? Colors.white : (crit ? c : _ink2)),
            const SizedBox(height: 4.0),
            Text(l,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(11.5,
                    color: on ? Colors.white : _inkTitle,
                    weight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _quickRegisterPage() {
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final started = _qFound || _regUnknown;
    final crit = _qCcOpts.where((o) => o.$2 && _qCc.contains(o.$1)).length;
    final allergy = _qFound && _regAllergy.isNotEmpty;
    // ความครบของการลงทะเบียน (ใช้ในแถบล่าง)
    final steps = <(String, bool)>[
      ('มาโดย', true),
      ('ระบุตัวตน', _regReady),
      ('อาการ', _qCc.isNotEmpty || _regCtl('cc').text.trim().isNotEmpty),
      ('ผู้แจ้ง', true),
    ];

    // -------------------------------------------- ซ้าย: บัตร + ค้นหา + RESUS
    // ทางลัดวิกฤต: ส่ง RESUS ก่อน ลงทะเบียนทีหลัง (อยู่ใน panel ส่ง)
    final resus = _Press(
      child: GestureDetector(
        onTap: () => _qSend(resus: true),
        // debug: กดค้างเปิดตัวปรับมุม/ขนาดไซเรน
        onLongPress:
            kDebugMode ? () => setState(() => _srDebug = !_srDebug) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          height: 76.0,
          decoration: BoxDecoration(
            // แดงไล่เฉด: เข้มซ้าย สว่างขวาตรงไซเรน
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFB3121B), Color(0xFFE53935), Color(0xFFFF5A47)],
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: crit > 0
                ? [
                    BoxShadow(
                        color: _red.withValues(alpha: 0.45),
                        blurRadius: 16.0,
                        spreadRadius: 1.0),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            // แสงไซเรนสาดบนพื้นปุ่ม + เงาแสงกวาดเฉียง (กระพริบตามจังหวะ)
            const Positioned.fill(child: _ResusGlow()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('ส่งเข้า RESUS ทันที',
                            style: _t(15.0,
                                color: Colors.white, weight: FontWeight.w700)),
                        const SizedBox(width: 4.0),
                        const Icon(Icons.keyboard_double_arrow_right_rounded,
                            size: 20.0, color: Colors.white),
                      ]),
                      Text(
                          crit > 0
                              ? 'มีอาการวิกฤต $crit ข้อ ลงทะเบียนทีหลังได้'
                              : 'กรณีฉุกเฉินวิกฤต ลงทะเบียนทีหลัง',
                          style: _t(10.5,
                              color: const Color(0xE6FFFFFF),
                              weight: FontWeight.w500)),
                    ],
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _qIdCard(),
        // เครื่องมือค้นหา: หน้าอ่านบัตรอยู่ใต้บัตร · ขั้นฟอร์มย้ายไป header
        if (!started) ...[
          const SizedBox(height: 10.0),
          TextField(
            controller: _regCtl('q'),
            onSubmitted: (_) => _qRead(),
            style: _t(13.0, color: _inkTitle, weight: FontWeight.w500),
            decoration: _regDeco('เลขบัตร HN หรือเบอร์โทร',
                prefix:
                    const Icon(Icons.search_rounded, size: 20.0, color: _ink3)),
          ),
          const SizedBox(height: 8.0),
          Row(children: [
            Expanded(
              child: _qOpt(
                  'QR หมอพร้อม', Icons.qr_code_2_rounded, false, _qRead,
                  h: 44.0),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _qOpt(
                  'ไม่ทราบชื่อ',
                  _regUnknown
                      ? Icons.check_box_rounded
                      : Icons.person_off_outlined,
                  _regUnknown,
                  () => setState(() {
                        _regUnknown = !_regUnknown;
                        if (_regUnknown) {
                          _qFound = false;
                          _regSex ??= 'ไม่ระบุ';
                        }
                      }),
                  h: 44.0),
            ),
          ]),
          const SizedBox(height: 8.0),
          // ด่วนมาก ระบุตัวไม่ได้: ถ่ายรูปหน้าเก็บในเคสไว้ก่อน
          _qOpt(_qShot == null ? 'ถ่ายรูปหน้าผู้ป่วย' : 'ถ่ายรูปใหม่',
              Icons.photo_camera_rounded, _qShot != null, _qTakePhoto,
              h: 44.0),
        ],
      ],
    );

    // -------------------------------------------- ขวา: stacked cards ตามลำดับงาน
    // bento: ช่องแคบข้างข้อมูลผู้ป่วย ตัวเลือกเรียงลง
    Widget arriveTile(String l, IconData ic) => _Press(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _qArrive = l);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 40.0,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: _qArrive == l ? _blue : _panelSoft,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(children: [
                Icon(ic,
                    size: 18.0, color: _qArrive == l ? Colors.white : _ink2),
                const SizedBox(width: 6.0),
                Flexible(
                  child: Text(l,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(11.5,
                          color: _qArrive == l ? Colors.white : _inkTitle,
                          weight: FontWeight.w600)),
                ),
              ]),
            ),
          ),
        );
    // grid 2 × 2 + "อื่น ๆ" เต็มแถวล่าง
    final arrive = _qCard(
      'ผู้ป่วยมาโดย',
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final r in [0, 2]) ...[
          if (r > 0) const SizedBox(height: 6.0),
          Row(children: [
            Expanded(child: arriveTile(_qArrivals[r].$1, _qArrivals[r].$2)),
            const SizedBox(width: 6.0),
            Expanded(
                child: arriveTile(_qArrivals[r + 1].$1, _qArrivals[r + 1].$2)),
          ]),
        ],
        const SizedBox(height: 6.0),
        arriveTile(_qArrivals[4].$1, _qArrivals[4].$2),
      ]),
    );

    final who = _qCard(
      'ข้อมูลผู้ป่วย',
      count: _qFound ? 'พบใน HIS  HN $_regHn' : null,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // รูปหน้าที่ถ่ายไว้ตอนรับ (ยังไม่ทราบชื่อ)
          if (_qShot != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(File(_qShot!),
                      width: 56.0, height: 56.0, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('รูปหน้าผู้ป่วย เก็บในเคสแล้ว',
                          style: _t(12.5,
                              color: _inkTitle, weight: FontWeight.w600)),
                      Text('ใช้ยืนยันตัวตนภายหลัง เมื่อรู้ชื่อหรือญาติมาถึง',
                          style:
                              _t(11.0, color: _ink3, weight: FontWeight.w500)),
                    ],
                  ),
                ),
              ]),
            ),
          // แพ้ยา: แถบแดงบนสุดของการ์ด (ข้อมูลอันตราย ห้ามพลาด)
          if (allergy)
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: _red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(children: [
                const Icon(Icons.warning_rounded, size: 18.0, color: _red),
                const SizedBox(width: 8.0),
                Text('แพ้ยา ${_regAllergy.join(', ').toUpperCase()}',
                    style: _t(13.0, color: _red, weight: FontWeight.w700)),
              ]),
            ),
          if (_qFound) ...[
            Wrap(spacing: 6.0, runSpacing: 6.0, children: [
              for (final t in const [
                'สิทธิ UC (บัตรทอง)',
                'โรคประจำตัว DM, HT',
                'มาล่าสุด 12 ส.ค. 2567 OPD',
              ])
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(t,
                      style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
                ),
            ]),
            const SizedBox(height: 12.0),
          ],
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _regLabel('ชื่อ-สกุล', req: true),
                  _qField('name', 'ชื่อ นามสกุล'),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _regLabel('เบอร์โทรศัพท์'),
                  _qField('phone', '090-000-0000',
                      icon: Icons.phone_rounded, kb: TextInputType.phone),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10.0),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _regLabel('วันเกิด'),
                  GestureDetector(
                    onTap: _regPickDob,
                    child: InputDecorator(
                      decoration: _regDeco('เลือกวันเกิด',
                          prefix: const Icon(Icons.cake_outlined,
                              size: 18.0, color: _ink3)),
                      child: Text(
                          _regDob == null
                              ? 'เลือกวันเกิด'
                              : '${_thDate(_regDob!)}  อายุ ${_regAge(_regDob!)}',
                          style: _t(13.0,
                              color: _regDob == null ? _g5 : _inkTitle,
                              weight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _regLabel('เพศ', req: true),
                  _regSeg(const ['ชาย', 'หญิง', 'ไม่ระบุ'], _regSex,
                      (v) => setState(() => _regSex = v)),
                ],
              ),
            ),
          ]),
        ],
      ),
    );

    final cc = _qCard(
      'อาการสำคัญ',
      count: _qCc.isEmpty ? null : 'เลือก ${_qCc.length}',
      trailing: crit > 0
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text('วิกฤต $crit',
                  style:
                      _t(10.5, color: Colors.white, weight: FontWeight.w700)),
            )
          : null,
      pad: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 4.0),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final crit in [true, false]) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
              child: Text(crit ? 'อาการวิกฤต' : 'อาการทั่วไป',
                  style: _t(11.0,
                      color: crit ? _red : _ink3, weight: FontWeight.w600)),
            ),
            // grid 4 คอลัมน์ (ชื่ออาการเต็ม ไม่ถูกตัด)
            LayoutBuilder(builder: (context, c) {
              final w = (c.maxWidth - 6.0 * 3) / 4;
              return Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                for (final o in _qCcOpts.where((o) => o.$2 == crit))
                  SizedBox(width: w, child: _qCcTile(o.$1, o.$2)),
              ]);
            }),
            const SizedBox(height: 10.0),
          ],
          TextField(
            controller: _regCtl('cc'),
            maxLength: 200,
            onChanged: (_) => setState(() {}),
            style: _t(13.0, color: _inkTitle, weight: FontWeight.w500),
            decoration: _regDeco('ระบุอาการสำคัญเพิ่มเติม (ถ้ามี)'),
          ),
        ],
      ),
    );

    final informant = _qCard(
      'ผู้แจ้งข้อมูล',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 2 × 2 (อยู่คอลัมน์ซ้ายใต้บัตร)
          for (final row in const [
            [
              ('ผู้ป่วยเอง', Icons.person_rounded),
              ('ญาติ', Icons.family_restroom_rounded)
            ],
            [
              ('เจ้าหน้าที่ EMS', Icons.medical_services_rounded),
              ('อื่น ๆ', Icons.more_horiz_rounded)
            ],
          ]) ...[
            if (row !=
                const [
                  ('ผู้ป่วยเอง', Icons.person_rounded),
                  ('ญาติ', Icons.family_restroom_rounded)
                ])
              const SizedBox(height: 8.0),
            Row(children: [
              for (final (i, (l, ic)) in row.indexed) ...[
                if (i > 0) const SizedBox(width: 8.0),
                Expanded(
                    child: _qOpt(l, ic, _qInformant == l,
                        () => setState(() => _qInformant = l),
                        h: 42.0)),
              ],
            ]),
          ],
          if (_qInformant != 'ผู้ป่วยเอง') ...[
            const SizedBox(height: 10.0),
            _qField('inf_name', 'ชื่อผู้แจ้ง'),
            const SizedBox(height: 8.0),
            _qField('inf_phone', 'เบอร์โทรผู้แจ้ง',
                icon: Icons.phone_rounded, kb: TextInputType.phone),
          ],
        ],
      ),
    );

    final page = Material(
      color: _panelSoft,
      child: Column(children: [
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
                  Text(_qNormal ? 'ลงทะเบียนผู้ป่วย' : 'ลงทะเบียนด่วน',
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text(
                      _qNormal
                          ? 'ข้อมูลประจำตัวครบ ตามแบบฟอร์มเวชระเบียน'
                          : 'ER Quick Registration',
                      style: _t(10.5, color: _ink3)),
                ],
              ),
            ),
            _regModeSwitch(),
            const SizedBox(width: 12.0),
            // ขั้นฟอร์ม: ค้นหา + ทางลัดระบุตัวตนอยู่ใน header
            if (started) ...[
              SizedBox(
                width: 280.0,
                height: 40.0,
                child: TextField(
                  controller: _regCtl('q'),
                  onSubmitted: (_) => _qRead(),
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w500),
                  decoration: _regDeco('เลขบัตร HN หรือเบอร์โทร',
                      prefix: const Icon(Icons.search_rounded,
                          size: 20.0, color: _ink3)),
                ),
              ),
              const SizedBox(width: 8.0),
              SizedBox(
                  width: 140.0,
                  child: _qOpt(
                      'QR หมอพร้อม', Icons.qr_code_2_rounded, false, _qRead,
                      h: 40.0)),
              const SizedBox(width: 8.0),
              SizedBox(
                  width: 130.0,
                  child: _qOpt(
                      'ไม่ทราบชื่อ',
                      _regUnknown
                          ? Icons.check_box_rounded
                          : Icons.person_off_outlined,
                      _regUnknown,
                      () => setState(() {
                            _regUnknown = !_regUnknown;
                            if (_regUnknown) {
                              _qFound = false;
                              _regSex ??= 'ไม่ระบุ';
                            }
                          }),
                      h: 40.0)),
              const SizedBox(width: 8.0),
              SizedBox(
                  width: 120.0,
                  child: _qOpt('ถ่ายรูป', Icons.photo_camera_rounded,
                      _qShot != null, _qTakePhoto,
                      h: 40.0)),
            ],
            const SizedBox(width: 12.0),
          ]),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: const BoxDecoration(color: _panelSoft),
            // ขั้นแรก: อ่านบัตรอย่างเดียว · อ่านแล้ว (หรือไม่ทราบชื่อ) ฟอร์มค่อยเลื่อนเข้ามา
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              switchInCurve: Curves.easeOutCubic,
              // ชิดบน (ค่าเริ่มต้นจัดกลาง ทำให้มีช่องว่างเหนือฟอร์ม)
              layoutBuilder: (cur, prev) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...prev, if (cur != null) cur]),
              transitionBuilder: (c, an) => FadeTransition(
                opacity: an,
                child: SlideTransition(
                  position:
                      Tween(begin: const Offset(0.0, 0.03), end: Offset.zero)
                          .animate(an),
                  child: c,
                ),
              ),
              child: !started
                  ? SingleChildScrollView(
                      key: const ValueKey('intro'),
                      padding: EdgeInsets.fromLTRB(16.0, 28.0, 16.0, 16.0 + kb),
                      child: Center(
                        child: SizedBox(
                          width: 480.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('อ่านบัตรประชาชนผู้ป่วย',
                                  textAlign: TextAlign.center,
                                  style: _t(20.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              const SizedBox(height: 4.0),
                              Text(
                                  'เสียบบัตรหรือแตะที่บัตร ระบบจะดึงข้อมูลจาก HIS ให้',
                                  textAlign: TextAlign.center,
                                  style: _t(12.5,
                                      color: _ink3, weight: FontWeight.w500)),
                              const SizedBox(height: 20.0),
                              left,
                            ],
                          ),
                        ),
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('form'),
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0 + kb),
                        // 3 panel ตามงาน: ระบุตัวตน | ข้อมูลรับเข้า | ส่งผู้ป่วย
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 320.0,
                                child:
                                    _qPanel('ระบุตัวตน', Icons.badge_outlined, [
                                  left,
                                  const SizedBox(height: 10.0),
                                  arrive,
                                  informant,
                                ]),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: _qPanel('ข้อมูลรับเข้า',
                                    Icons.assignment_outlined, [
                                  who,
                                  cc,
                                  // โหมดปกติ: ข้อมูลประจำตัวละเอียด ต่อท้ายใน panel เดียวกัน
                                  if (_qNormal) ...[
                                    _qVitalCard(),
                                    _regAllergyCard(),
                                    const SizedBox(height: 10.0),
                                    _regCard(
                                      'อาชีพ',
                                      Icons.work_outline_rounded,
                                      _regSelect('job', 'อาชีพ'),
                                    ),
                                    const SizedBox(height: 10.0),
                                    _regGeneralCard(true),
                                    const SizedBox(height: 10.0),
                                    _regAddressCard(),
                                  ],
                                ]),
                              ),
                              const SizedBox(width: 12.0),
                              SizedBox(
                                width: 290.0,
                                child: _qSendPanel(resus, steps, crit),
                              ),
                            ]),
                      ),
                    ),
            ),
          ),
        ),
      ]),
    );
    if (!_srDebug) return page;
    return Stack(children: [
      page,
      Positioned(left: 16.0, bottom: 90.0, width: 360.0, child: _srDebugger()),
    ]);
  }

  /// ตัวปรับมุม/ขนาด/ตำแหน่งไซเรน 3D (debug)
  Widget _srDebugger() {
    final p = _srPose, b = _srBox;
    Widget sl(
            String k, double v, double min, double max, ValueChanged<double> on,
            {int dp = 2, Color? c}) =>
        Row(children: [
          SizedBox(
              width: 36.0,
              child: Text(k,
                  style: _t(11.0,
                      color: c ?? _inkTitle, weight: FontWeight.w700))),
          Expanded(
            child: Slider(
                value: v.clamp(min, max), min: min, max: max, onChanged: on),
          ),
          SizedBox(
              width: 44.0,
              child: Text(v.toStringAsFixed(dp),
                  textAlign: TextAlign.right, style: _num(10.5, color: _ink2))),
        ]);
    return Material(
      elevation: 8.0,
      borderRadius: BorderRadius.circular(12.0),
      color: _panel,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 6.0, 8.0, 8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text('Siren 3D (debug)',
                style: _t(12.0, color: _inkTitle, weight: FontWeight.w700)),
            const Spacer(),
            TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text:
                          'pose (${p.$1.toStringAsFixed(2)}, ${p.$2.toStringAsFixed(2)}, '
                          '${p.$3.toStringAsFixed(2)}, ${p.$4.toStringAsFixed(2)}) '
                          'box right ${b.$1.toStringAsFixed(0)} bottom ${b.$2.toStringAsFixed(0)} size ${b.$3.toStringAsFixed(0)}'));
                  HapticFeedback.mediumImpact();
                },
                child: Text('คัดลอกค่า', style: _t(11.0, color: _blue))),
            TextButton(
                onPressed: () => setState(() {
                      _srPose = (-0.13, -1.98, -0.38, 0.63);
                      _srBox = (-60.0, -53.0, 200.0);
                    }),
                child: Text('รีเซ็ต', style: _t(11.0, color: _ink2))),
            IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _srDebug = false),
                icon: const Icon(Icons.close_rounded, size: 18.0)),
          ]),
          sl('เอียง X', p.$1, -1.5, 1.5,
              (x) => setState(() => _srPose = (x, p.$2, p.$3, p.$4))),
          sl('หัน Y', p.$2, -3.14, 3.14,
              (x) => setState(() => _srPose = (p.$1, x, p.$3, p.$4))),
          sl('เอียง Z', p.$3, -1.5, 1.5,
              (x) => setState(() => _srPose = (p.$1, p.$2, x, p.$4))),
          sl('ขนาด', p.$4, 0.4, 2.0,
              (x) => setState(() => _srPose = (p.$1, p.$2, p.$3, x))),
          sl('ขวา', b.$1, -60, 120,
              (x) => setState(() => _srBox = (x, b.$2, b.$3)),
              dp: 0, c: _blue),
          sl('ล่าง', b.$2, -80, 40,
              (x) => setState(() => _srBox = (b.$1, x, b.$3)),
              dp: 0, c: _blue),
          sl('กรอบ', b.$3, 60, 200,
              (x) => setState(() => _srBox = (b.$1, b.$2, x)),
              dp: 0, c: _blue),
        ]),
      ),
    );
  }
}

// ------------------------------------------------ ภาพบัตรประชาชน
// หน้าบัตรพอร์ตจาก Kiosk-Insurance (ui/welcome/Machine.kt drawIdCard)

/// แปลง path แบบง่าย (M L V H Z และ h v แบบสัมพัทธ์) ที่ใช้ในภาพนี้
Path _svgPath(String d) {
  final p = Path();
  final re = RegExp(r'([MLVHZmlvhz])([^MLVHZmlvhz]*)');
  var x = 0.0, y = 0.0;
  for (final m in re.allMatches(d)) {
    final cmd = m.group(1)!;
    final n = RegExp(r'-?\d*\.?\d+')
        .allMatches(m.group(2)!)
        .map((e) => double.parse(e.group(0)!))
        .toList();
    switch (cmd) {
      case 'M':
        for (var i = 0; i + 1 < n.length; i += 2) {
          x = n[i];
          y = n[i + 1];
          i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
        }
      case 'L':
        for (var i = 0; i + 1 < n.length; i += 2) {
          x = n[i];
          y = n[i + 1];
          p.lineTo(x, y);
        }
      case 'V':
        y = n.first;
        p.lineTo(x, y);
      case 'H':
        x = n.first;
        p.lineTo(x, y);
      case 'h':
        x += n.first;
        p.lineTo(x, y);
      case 'v':
        y += n.first;
        p.lineTo(x, y);
      case 'Z' || 'z':
        p.close();
    }
  }
  return p;
}

class _IdGeo {
  static final chipLines =
      _svgPath('M84 111.6 h64 M103.2 90 v60 M128.8 90 v60');
}

/// ข้อมูลบนหน้าบัตร (ว่าง = ตัวอย่าง XXXX แบบบัตรตัวอย่าง)
class _IdFace {
  const _IdFace({
    this.cid = '0 0000 00000 00 0',
    this.nameTh = 'XXXXX XXXXXXXXX',
    this.first = 'XXXXX',
    this.last = 'XXXXX',
    this.dobTh = 'xx xxx xxxx',
    this.dobEn = 'xx xxx. xxxx',
    this.religion = 'xxxx',
    this.addr1 = 'xx/xx หมู่ที่ xx ถนน xxxxx',
    this.addr2 = 'ต.xxxxx อ.xxxx จ.xxxxx',
    this.issueTh = 'xx xxx xxxx',
    this.issueEn = 'xx xxx. xxxx',
    this.expTh = 'xx xxx xxxx',
    this.expEn = 'xx xxx. xxxx',
  });
  final String cid, nameTh, first, last, dobTh, dobEn, religion;
  final String addr1, addr2, issueTh, issueEn, expTh, expEn;
}

/// หน้าบัตรประชาชนแบบเดียวกับบัตรจริง (พิกัดบัตร 480 × 303 ยืดเต็มพื้นที่)
/// พื้นลายบัตรวาดด้วยรูปด้านหลัง painter นี้วาดตรา ชิป ข้อความ และกรอบรูป
class _IdFacePainter extends CustomPainter {
  const _IdFacePainter(this.d, {this.blank = false});

  final _IdFace d;

  /// ยังไม่อ่านบัตร: ค่าเป็นตัวจาง
  final bool blank;

  static const _ink = Color(0xFF1E2A5A), _blueT = Color(0xFF1F6FD8);

  void _tx(Canvas c, double x, double y, double size, String s,
      {bool blue = false,
      bool bold = false,
      bool value = false,
      double ls = 0}) {
    final col = blue ? _blueT : _ink;
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              fontFamily: 'NotoSansThai',
              fontSize: size,
              letterSpacing: ls,
              color: value && blank ? col.withValues(alpha: 0.35) : col,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        c,
        Offset(x,
            y - tp.computeDistanceToActualBaseline(TextBaseline.alphabetic)));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = canvas;
    c.save();
    c.scale(size.width / 480, size.height / 303);
    const ph = Color(0xFFC9DCF0), phLine = Color(0xFF8FB4DC);
    final fill = Paint()..color = ph.withValues(alpha: 0.6);
    final line = Paint()
      ..color = phLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    // ตราครุฑ (วงกลมซ้ายบน) · แถบไมโครเท็กซ์ซ้าย · ลายเซ็น
    c.drawCircle(const Offset(47, 34), 27.25, fill);
    c.drawCircle(const Offset(47, 34), 27.25, line);
    final band =
        RRect.fromLTRBR(21.75, 88.75, 40.25, 263.25, const Radius.circular(8));
    c.drawRRect(band, fill);
    c.drawRRect(band, line);
    // ชิปทอง
    final chip =
        RRect.fromLTRBR(84.6, 90.6, 147.4, 149.4, const Radius.circular(9));
    c.drawRRect(
        chip,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFF8D67A), Color(0xFFF2C14E), Color(0xFFD9A63A)],
            stops: [0, .6, 1],
          ).createShader(const Rect.fromLTRB(84.6, 90.6, 147.4, 149.4)));
    final chipLine = Paint()
      ..color = const Color(0xFF8A6A20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    c.drawRRect(chip, chipLine);
    c.drawPath(_IdGeo.chipLines, chipLine);
    c.drawLine(
        const Offset(75, 58.5),
        const Offset(470, 58.5),
        Paint()
          ..color = const Color(0xFF7FB2E5)
          ..strokeWidth = 1.5);
    // หัวบัตร
    _tx(c, 89, 30.6, 18, 'บัตรประจำตัวประชาชน', bold: true);
    _tx(c, 274, 29.8, 15, 'Thai National ID Card', blue: true, bold: true);
    _tx(c, 89, 45.3, 9, 'เลขประจำตัวประชาชน');
    _tx(c, 89, 54.9, 7.5, 'Identification Number', blue: true);
    _tx(c, 209, 53.7, 16, d.cid, bold: true, value: true, ls: 1.2);
    // ชื่อ
    _tx(c, 75, 77.3, 9, 'ชื่อตัวและชื่อสกุล');
    _tx(c, 181, 79.9, 14, d.nameTh, bold: true, value: true);
    _tx(c, 176, 104.8, 8.5, 'Name', blue: true);
    _tx(c, 219, 106, 13, d.first, bold: true, value: true);
    _tx(c, 176, 125.8, 8.5, 'Last name', blue: true);
    _tx(c, 219, 127, 13, d.last, bold: true, value: true);
    // เกิด ศาสนา ที่อยู่
    _tx(c, 195, 152.7, 10.5, 'เกิดวันที่ ${d.dobTh}', value: true);
    _tx(c, 195, 170.3, 9, 'Date of Birth ${d.dobEn}', blue: true, value: true);
    _tx(c, 195, 191.7, 10.5, 'ศาสนา ${d.religion}', value: true);
    _tx(c, 75, 211.7, 10.5, 'ที่อยู่ ${d.addr1}', bold: true, value: true);
    _tx(c, 75, 228.7, 10.5, d.addr2, value: true);
    // วันออกบัตร · ลายเซ็น · วันหมดอายุ
    _tx(c, 75, 248.8, 8.5, d.issueTh, bold: true, value: true);
    _tx(c, 75, 259.4, 8, 'วันออกบัตร');
    _tx(c, 75, 270.4, 8, d.issueEn, blue: true, value: true);
    _tx(c, 75, 281.4, 8, 'Date of Issue', blue: true);
    c.drawCircle(const Offset(195, 253), 16.25, fill);
    c.drawCircle(const Offset(195, 253), 16.25, line);
    _tx(c, 165, 285.9, 7.5, 'เจ้าพนักงานออกบัตร');
    _tx(c, 287, 248.8, 8.5, d.expTh, bold: true, value: true);
    _tx(c, 287, 259.4, 8, 'วันหมดอายุ');
    _tx(c, 287, 270.4, 8, d.expEn, blue: true, value: true);
    _tx(c, 287, 281.4, 8, 'Date of Expiry', blue: true);
    // เลขหลังบัตร (laser) มุมขวาล่าง ตาม Figma 345-35
    _tx(c, 358, 292.9, 7.5, '0000-00-00000000', value: true);
    // กรอบรูป (รูปจริงวางทับจากภายนอก)
    final photo = RRect.fromLTRBR(358, 151, 457, 271, const Radius.circular(6));
    c.drawRRect(photo, Paint()..color = Colors.white);
    if (blank) {
      c.save();
      c.clipRRect(photo);
      c.drawOval(
          Rect.fromCircle(center: const Offset(407.5, 187), radius: 16.8),
          fill);
      c.drawOval(
          Rect.fromCenter(
              center: const Offset(407.5, 255.4), width: 75.2, height: 84),
          fill);
      c.restore();
    }
    c.drawRRect(photo, line);
    c.restore();
  }

  @override
  bool shouldRepaint(_IdFacePainter old) => old.d != d || old.blank != blank;
}

/// พื้นปุ่ม RESUS: แสงเรืองแดงส้มจากไซเรนเต้นเป็นจังหวะ + แถบแสงเฉียงกวาดผ่านช้า ๆ
class _ResusGlow extends StatefulWidget {
  const _ResusGlow();

  @override
  State<_ResusGlow> createState() => _ResusGlowState();
}

class _ResusGlowState extends State<_ResusGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            // เต้นเร็ว 3 ครั้งต่อรอบ (จังหวะไฟหมุน)
            final pulse = (math.sin(t * math.pi * 6) + 1) / 2;
            // แสงเฉียงกวาดช่วงต้นรอบ แล้วพัก
            final sweep = (t / 0.4).clamp(0.0, 1.0);
            final c = -0.2 + 1.4 * Curves.easeInOut.transform(sweep);
            return Stack(children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.85, 0.6),
                      radius: 1.1,
                      colors: [
                        const Color(0xFFFFB199)
                            .withValues(alpha: 0.35 + 0.35 * pulse),
                        const Color(0x00FF5A47),
                      ],
                    ),
                  ),
                ),
              ),
              // shimmer: แถบแสงเฉียงกว้างกวาดทั้งปุ่ม
              if (sweep < 1.0)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-1.0, -0.6),
                        end: const Alignment(1.0, 0.6),
                        colors: const [
                          Color(0x00FFFFFF),
                          Color(0x00FFFFFF),
                          Color(0x8CFFFFFF),
                          Color(0x00FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                        stops: [
                          0.0,
                          (c - 0.14).clamp(0.0, 1.0),
                          c.clamp(0.0, 1.0),
                          (c + 0.14).clamp(0.0, 1.0),
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
            ]);
          },
        ),
      );
}
