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
  String _qArrive = 'เดินมา';
  final Set<String> _qCc = {};
  String _qInformant = 'ผู้ป่วยเอง';
  bool _qFound = false;

  /// กำลังอ่านบัตร (เล่นเส้นสแกนบนบัตรจำลอง)
  bool _qReading = false;

  /// โหมดปกติ: layout เดียวกับลงทะเบียนด่วน + ฟอร์มละเอียด (แพ้ยา ข้อมูลทั่วไป ที่อยู่ อาชีพ)
  bool _qNormal = false;

  /// เคสอุบัติเหตุ: เป็นอุบัติเหตุหมู่ (MCI) ไหม · null = ยังไม่ตอบ
  bool? _qMci;

  /// รูปหน้าผู้ป่วยที่ถ่ายตอนรับ (กรณีด่วน ยังไม่รู้ตัวตน) เก็บไว้ในเคส
  String? _qShot;

  /// debugger ไซเรน 3D (debug build): ท่า (x, y, z, scale) + กรอบ (right, bottom, size)
  bool _srDebug = false;
  (double, double, double, double) _srPose = (-0.13, -1.98, -0.38, 0.63);
  (double, double, double) _srBox = (2.0, -10.0, 116.0);
  DateTime _qAt = DateTime.now();

  // ---------------------------------------------- หน้าคัดกรอง (triage_page.dart)
  /// ผู้ป่วยที่กำลังคัดกรอง (null = ไม่ได้เปิดหน้าคัดกรอง)
  _P? _triP;
  final Map<String, TextEditingController> _triIn = {};
  final Map<String, FocusNode> _triFocus = {};
  bool _triOcrBusy = false;

  /// กลุ่มอายุสำหรับ V/S dangerous zone (null = ยังไม่ได้เลือก)
  String? _triBand;
  int? _triPain;

  /// ข้อที่ติ๊กในขั้น "จะเสียชีวิต" และ "เสี่ยง ซึม ปวด"
  final Set<String> _triRisk = {};

  /// กิจกรรม/ทรัพยากรที่คาดว่าต้องใช้ ('ไม่มี' = ไม่มีกิจกรรม)
  final Set<String> _triAct = {};

  /// NEWS: ได้ออกซิเจน / ผู้ป่วย COPD (ใช้เกณฑ์ SpO₂ แถว COPD)
  bool _triO2 = false;
  bool _triCopd = false;

  /// พยาบาลยืนยันว่าไม่ยกเป็น ESI 2: 'pain' = ปวดจากกระดูก/กล้ามเนื้อ รอได้
  /// 'vs' = วัด V/S ซ้ำแล้วกลับมาปกติ (ESI v5: reassess ก่อน uptriage)
  final Set<String> _triWaive = {};

  /// แท็บข้างซ้าย (Figma 356-178): ประวัติ | คัดกรอง | สรุป
  String _qTab = 'ประวัติ';

  /// แท็บย่อยแนวนอนของแต่ละหน้า (card sorting แบบ AdSense): หน้า → แท็บย่อยที่เลือก
  final Map<String, String> _qSubOf = {};

  final Map<String, GlobalKey> _qFieldKeys = {};
  final Map<String, FocusNode> _qFieldFocus = {};

  /// key ของแต่ละหัวข้อ ใช้เลื่อนไปจากสารบัญ
  final Map<String, GlobalKey> _qSecKeys = {};

  /// ผู้ป่วยใหม่: อ่านบัตรได้แต่ไม่พบใน HOSxP → ต้องกรอกข้อมูลเพิ่ม (ออก HN ใหม่)
  bool _qNew = false;

  /// หน้าแรกตอนกดลงทะเบียน: 1 ดึงข้อมูลผู้ป่วย → 2 เข้าสู่การคัดกรอง
  bool _qIntro = true;

  /// ระหว่างสร้างการ์ดของขั้นปัจจุบัน: การ์ดแสดงแบบเปิดเต็ม ไม่มีหัว accordion
  bool _qFlat = false;

  /// จากหน้าคัดกรองเดิม (add_screening): เวร ข้อมูลการมา GCS รูม่านตา ความรู้สึกตัว
  String? _qShift;
  String? _qArrType;
  String? _qFrom;
  String? _qBringer;
  String? _triE, _triV, _triM;
  final Map<String, String> _triPupil = {};
  String? _triLoc;

  /// ประเภทผู้ป่วย (เลือกได้หลายอย่าง) เช่น Trauma, Stroke, Sepsis
  final Set<String> _triType = {};

  /// ข้อมูลรับเข้าห้องฉุกเฉิน (ตามฟอร์ม HOSxP): ธง
  final Set<String> _qFlags = {};

  /// ประวัติการคัดแยก: hn → [(เวลา, ระดับเดิม, ระดับใหม่, ครั้ง, เหตุผล, ผู้บันทึก)]
  final Map<String, List<(DateTime, int?, int, String, String, String)>>
      _triLog = {};

  /// ระดับที่พยาบาลเลือกเอง (null = ใช้ระดับที่ระบบแนะนำ)
  int? _triPick;

  /// ข้อมูลที่ได้จากหน้าลงทะเบียน: hn → (มาโดย, อาการสำคัญ, แพ้ยา)
  final Map<String, (String, List<String>, List<String>)> _regSent = {};
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
      _qIntro = true;
      _qNew = false;
      _qArrive = 'เดินมา';
      _qCc.clear();
      _qInformant = 'ผู้ป่วยเอง';
      _qFound = false;
      _qAt = DateTime.now();
      _qMci = null;
      _qShot = null;
      _qFlags.clear();
      _qTab = 'ประวัติ';
      _qSubOf.clear();
      final h = DateTime.now().hour;
      _qShift = h >= 8 && h < 16 ? 'เวรเช้า' : (h >= 16 ? 'เวรบ่าย' : 'เวรดึก');
      _qArrType = null;
      _qFrom = null;
      _qBringer = null;
      _triReset();
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
    if (_regUnknown) return _regUnknownName;
    final n = _regCtl('name').text.trim();
    return n.isEmpty ? '' : '${_regPick['prefix'] ?? ''}$n';
  }

  /// ชื่อชั่วคราวผู้ป่วยไม่ทราบชื่อ: อาการสำคัญ + วันเวลาที่บันทึก
  /// เช่น "เจ็บหน้าอก 2 ต.ค. 16:58 น." (ไม่เลือกอาการ = "ไม่ทราบชื่อ ...")
  String get _regUnknownName {
    final typed = _regCtl('cc').text.trim();
    final cc = _qCc.isNotEmpty
        ? _qCc.first
        : typed.isNotEmpty
            ? typed
            : 'ไม่ทราบชื่อ';
    return '$cc ${_qAt.day} ${_thMonths[_qAt.month - 1]} ${_clock(_qClock(_qAt))}';
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
        fillColor: _panel,
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

  /// ช่องกรอกแบบ outlined + floating label ของ Google (Material 3)
  /// ป้ายอยู่ในช่องตอนว่าง ลอยขึ้นขอบบนเมื่อพิมพ์/มีค่า · helper = คำอธิบายใต้ช่อง
  InputDecoration _qFloat(String label, {IconData? icon, String? helper}) =>
      InputDecoration(
        labelText: label,
        labelStyle: _t(14.0, color: _ink2, weight: FontWeight.w500),
        floatingLabelStyle: _t(13.0, color: _blue, weight: FontWeight.w600),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        helperText: helper,
        helperStyle: _t(12.0, color: _ink3, weight: FontWeight.w500),
        prefixIcon: icon == null ? null : Icon(icon, size: 20.0, color: _ink3),
        filled: true,
        fillColor: _panel,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF80868B))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: _blue, width: 2.0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
    if (_triP != null) return _triagePage();
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
/// สภาพผู้ป่วยตอนมาถึง ตาม app เดิม (master er_patient_condition)
const List<(String, IconData)> _qArrivals = [
  ('เดินมา', Icons.directions_walk_rounded),
  ('อุ้มมา', Icons.child_care_rounded),
  ('รถนั่ง', Icons.accessible_rounded),
  ('เปลนอน', Icons.airline_seat_flat_rounded),
  ('ญาติมาแทน', Icons.family_restroom_rounded),
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
      // ได้ข้อมูลผู้ป่วยแล้ว = ออกจากหน้าแรก เข้าสู่การคัดกรอง
      _qIntro = false;
      _regUnknown = false;
      _qNew = false;
      _qFound = true;
      _regHn = '00012345';
      _regPick['prefix'] = 'นาย';
      _regCtl('name').text = 'สมชาย ใจดี';
      _regCtl('cid').text = '3 4001 00123 45 6';
      _regCtl('phone').text = '081-234-5678';
      _regCtl('addr').text = '123 ม.1 ต.ในเมือง อ.เมือง จ.ขอนแก่น';
      _regDob = DateTime(1962, 1, 1);
      _triBand = _triBandOf(DateTime.now().year - 1962);
      _regSex = 'ชาย';
      _regAllergy
        ..clear()
        ..add('Penicillin');
      // รูปจากบัตร (จำลอง: ใช้ใบหน้าชายให้ตรงกับเพศในบัตร)
      _regPhoto = _faceUrl('670123456');
    });
  }

  /// อ่านบัตรผู้ป่วยใหม่ (จำลอง): มีข้อมูลบนบัตร แต่ไม่มีประวัติใน HOSxP
  Future<void> _qReadNew() async {
    if (_qReading) return;
    HapticFeedback.mediumImpact();
    setState(() => _qReading = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _qReading = false;
      _qIntro = false;
      _qNew = true;
      _qFound = false;
      _regUnknown = false;
      _regHn = '';
      _regPick['prefix'] = 'นางสาว';
      _regCtl('name').text = 'พิมพ์ชนก แสงทอง';
      _regCtl('cid').text = '1 1037 00456 78 9';
      _regCtl('phone').clear();
      _regCtl('addr').text = '45/12 ม.3';
      _regCtl('addr_prov').text = 'ขอนแก่น';
      _regCtl('addr_amp').text = 'เมืองขอนแก่น';
      _regCtl('addr_tam').text = 'ศิลา';
      _regCtl('addr_zip').text = '40000';
      _regPick['nation'] = 'ไทย';
      _regPick['ethnic'] = 'ไทย';
      _regDob = DateTime(1998, 6, 14);
      _regSex = 'หญิง';
      _regAllergy.clear();
      _regPhoto = _faceUrl('670123459');
      _triBand = _triBandOf(DateTime.now().year - 1998);
    });
  }

  /// ส่งเข้า Triage (หรือ RESUS ทันที): เข้ารายชื่อขั้นคัดกรองพร้อมอาการสำคัญ
  /// esi = คัดกรองในหน้าลงทะเบียนแล้ว → ส่งรอตรวจพร้อมระดับ
  void _qSend({bool resus = false, int? esi}) {
    if (!resus && !_regReady) return;
    final name = _regName.isEmpty ? 'ไม่ทราบชื่อ #${_regCount + 1}' : _regName;
    final cc = _qCc.isEmpty ? '' : ' ${_qCc.join(', ')}';
    // ผู้ป่วยใหม่: ออก HN ใหม่
    if (_qNew) {
      if (_regHn.isEmpty) {
        _regHn = '${(DateTime.now().year + 543) % 100}'
            '${(DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}';
      }
    }
    _regSent[_regHn] = (_qArrive, _qCc.toList(), _regAllergy.toList());
    if (resus || esi != null) {
      _triLogAdd(_regHn, null, resus ? 1 : esi!,
          resus ? 'ส่ง RESUS ทันที' : _triAdvise().$2.join(', '));
    }
    _patients.insert(
        0,
        _P(_regHn, name,
            esi != null && !resus ? _Stage.waitDoctor : _Stage.triage, 0,
            esi: resus
                ? _Esi.one
                : esi == null
                    ? null
                    : _Esi.values[esi - 1],
            type: _triPtype(),
            note: resus ? 'ส่งเข้า RESUS$cc' : '$_qArrive$cc'));
    _regCount++;
    ErFeedback.confirm();
    setState(() {
      _regOpen = false;
      _regQuick = false;
      _open =
          esi != null && !resus ? _Phase.of(_Stage.waitDoctor) : _Phase.triage;
      _listFilter = _ListFilter.all;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            resus
                ? 'ส่ง $name เข้า RESUS แล้ว'
                : esi != null
                    ? 'ลงทะเบียน $name เป็น ESI $esi แล้ว ส่ง${_triZoneOf(esi).$1} ${_triZoneOf(esi).$2}'
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
            // แบบชิปของ Google: เลือกแล้ว = พื้นฟ้าอ่อน ขอบน้ำเงิน ตัวน้ำเงิน + ✓
            decoration: BoxDecoration(
              color: on ? const Color(0xFFE8F0FE) : _panel,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: on ? _blue : const Color(0xFFDADCE0),
                  width: on ? 1.5 : 1.0),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (on) ...[
                const Icon(Icons.check_rounded, size: 18.0, color: _blue),
                const SizedBox(width: 6.0),
              ] else if (icon != null) ...[
                Icon(icon, size: 20.0, color: _ink2),
                const SizedBox(width: 7.0),
              ],
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(13.0,
                        color: on ? _blue : _inkTitle,
                        weight: on ? FontWeight.w600 : FontWeight.w500)),
              ),
            ]),
          ),
        ),
      );

  // focus ต่อช่อง: rebuild ตอนเข้า/ออกช่อง ให้ข้อความเตือนขึ้นหลังกรอกเสร็จ
  FocusNode _qFocusOf(String k) => _qFieldFocus.putIfAbsent(k,
      () => FocusNode()..addListener(() => mounted ? setState(() {}) : null));

  /// เบอร์โทรไทย: มือถือ 06/08/09 = 10 หลัก, บ้าน 02-07 = 9 หลัก
  static String? _phoneIssue(String text) {
    final d = text.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return null;
    if (!RegExp(r'^0[2-9]').hasMatch(d) && d.length > 1) {
      return 'เบอร์ต้องขึ้นต้นด้วย 02 ถึง 09';
    }
    final need = _PhoneMask.lenOf(d);
    if (d.length < need) return 'เบอร์ยังไม่ครบ ต้องมี $need หลัก';
    return null;
  }

  bool get _qPhoneOk {
    final t = _regCtl('phone').text;
    return t.trim().isNotEmpty && _phoneIssue(t) == null;
  }

  /// เตือนเฉพาะช่องเบอร์ ตอนไม่ได้พิมพ์อยู่ (ไม่กวนระหว่างพิมพ์)
  String? _qPhoneErr(String k, TextInputType? kb) {
    if (kb != TextInputType.phone) return null;
    if (_qFieldFocus[k]?.hasFocus ?? false) return null;
    return _phoneIssue(_regCtl(k).text);
  }

  // key + focus ต่อช่อง ใช้กับปุ่ม "ไปที่ช่องที่ยังว่าง"
  Widget _qField(String k, String label,
          {IconData? icon, TextInputType? kb, String? helper}) =>
      KeyedSubtree(
        key: _qFieldKeys.putIfAbsent(k, GlobalKey.new),
        child: TextField(
          controller: _regCtl(k),
          focusNode: _qFocusOf(k),
          keyboardType: kb,
          inputFormatters: kb == TextInputType.phone ? [_PhoneMask()] : null,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: (_) => setState(() {}),
          style: _t(15.0, color: _inkTitle, weight: FontWeight.w500),
          decoration: _qFloat(label, icon: icon, helper: helper)
              .copyWith(errorText: _qPhoneErr(k, kb)),
        ),
      );

  /// แถวกรอกข้อความแบบเดียวกับแถวข้อมูล: ชื่อซ้าย (180) | ช่องพิมพ์ไร้กรอบขวา
  Widget _qEditRow(String k, String label, String hint,
      {TextInputType? kb, bool last = false}) {
    final node = _qFocusOf(k);
    return KeyedSubtree(
      key: _qFieldKeys.putIfAbsent(k, GlobalKey.new),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: node.requestFocus,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56.0),
          decoration: BoxDecoration(
            border: last
                ? null
                : const Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
          ),
          child: Row(children: [
            SizedBox(
              width: 180.0,
              child: Text(label,
                  style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
            ),
            Expanded(
              child: TextField(
                controller: _regCtl(k),
                focusNode: node,
                keyboardType: kb,
                inputFormatters:
                    kb == TextInputType.phone ? [_PhoneMask()] : null,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: (_) => setState(() {}),
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w500),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  errorText: _qPhoneErr(k, kb),
                  errorStyle: _t(12.0, color: _red, weight: FontWeight.w500),
                  hintText: hint,
                  hintStyle: _t(14.0, color: _g5, weight: FontWeight.w500),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
            const Icon(Icons.edit_outlined, size: 18.0, color: _blue),
          ]),
        ),
      ),
    );
  }

  /// รายการจาก master data (โหลดตอนเปิดแอป) ถ้ายังไม่มีตารางใช้รายการสำรอง
  List<String> _qMaster(String id) {
    final m = _masterNames(id);
    if (m.isNotEmpty) return m;
    return switch (id) {
      'er_nationality' => const [
          'ไทย',
          'จีน',
          'ลาว',
          'กัมพูชา',
          'เมียนมา',
          'เวียดนาม',
          'มาเลเซีย',
          'สิงคโปร์',
          'อินโดนีเซีย',
          'ฟิลิปปินส์',
          'อินเดีย',
          'ญี่ปุ่น',
          'เกาหลีใต้',
          'อเมริกัน',
          'อังกฤษ',
          'เยอรมัน',
          'ฝรั่งเศส',
          'รัสเซีย',
          'ออสเตรเลีย',
          'ไม่ทราบสัญชาติ',
          'ไร้สัญชาติ',
          'อื่น ๆ'
        ],
      'er_occupation' => const [
          'ไม่มีอาชีพ / ว่างงาน',
          'เด็กยังไม่เข้าเรียน',
          'นักเรียน',
          'นักศึกษา',
          'เกษตรกร (ทำนา ทำไร่ ทำสวน)',
          'ประมง',
          'เลี้ยงสัตว์',
          'รับจ้างทั่วไป',
          'ผู้ใช้แรงงาน',
          'ขับรถรับจ้าง',
          'ช่างฝีมือ',
          'ค้าขาย',
          'ธุรกิจส่วนตัว',
          'รับราชการ',
          'ทหาร',
          'ตำรวจ',
          'ครู / อาจารย์',
          'บุคลากรสาธารณสุข',
          'พนักงานรัฐวิสาหกิจ',
          'ลูกจ้างหน่วยงานรัฐ',
          'พนักงานบริษัท',
          'แม่บ้าน / พ่อบ้าน',
          'พระภิกษุ / นักบวช',
          'ข้าราชการบำนาญ',
          'อื่น ๆ'
        ],
      'er_drug_allergy' => const [
          'Penicillin',
          'Amoxicillin',
          'Ampicillin',
          'Cloxacillin',
          'Ceftriaxone',
          'Cephalexin',
          'Cefazolin',
          'Sulfonamide (Co-trimoxazole)',
          'Erythromycin',
          'Azithromycin',
          'Ciprofloxacin',
          'Levofloxacin',
          'Vancomycin',
          'Metronidazole',
          'Tetracycline',
          'Aspirin',
          'Ibuprofen',
          'Diclofenac',
          'Naproxen',
          'Mefenamic acid',
          'Paracetamol',
          'Tramadol',
          'Morphine',
          'Pethidine',
          'Codeine',
          'Allopurinol',
          'Carbamazepine',
          'Phenytoin',
          'Lamotrigine',
          'Iodinated contrast media',
          'Lidocaine',
          'Heparin',
          'Chlorpheniramine',
          'Metoclopramide',
          'Latex'
        ],
      _ => const [],
    };
  }

  /// แถวตัวเลือกแบบชิป: ชื่อซ้าย | ชิปเลือกได้ 1 ค่า (แตะซ้ำ = ยกเลิก)
  Widget _qChipRow(String k, String label, List<String> opts,
      {bool last = false}) {
    final v = _regPick[k];
    return KeyedSubtree(
      key: _qFieldKeys.putIfAbsent(k, GlobalKey.new),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
        ),
        child: Row(children: [
          SizedBox(
            width: 180.0,
            child: Text(label,
                style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
          ),
          Expanded(
            child: Wrap(spacing: 8.0, runSpacing: 8.0, children: [
              for (final o in opts)
                SizedBox(
                  width: 96.0,
                  child: _qOpt(
                      o,
                      null,
                      v == o,
                      () => setState(
                          () => v == o ? _regPick.remove(k) : _regPick[k] = o),
                      h: 40.0),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  /// ประวัติแพ้ยา: เลือกได้หลายตัวจาก master รายชื่อยา ว่าง = ไม่มีประวัติแพ้
  Widget _qAllergyRow() => KeyedSubtree(
        key: _qFieldKeys.putIfAbsent('allergy', GlobalKey.new),
        child: _Press(
          scale: 0.99,
          radius: 4.0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _qAllergySheet,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56.0),
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
              ),
              child: Row(children: [
                SizedBox(
                  width: 180.0,
                  child: Text('ประวัติแพ้ยา',
                      style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                ),
                Expanded(
                  child: _regAllergy.isEmpty
                      ? Text('ไม่มีประวัติแพ้ แตะเพื่อเลือกยา',
                          style: _t(14.0, color: _g5, weight: FontWeight.w500))
                      : Wrap(spacing: 6.0, runSpacing: 6.0, children: [
                          for (final a in _regAllergy)
                            _regChip(a,
                                onDel: () =>
                                    setState(() => _regAllergy.remove(a))),
                        ]),
                ),
                const Icon(Icons.add_rounded, size: 20.0, color: _blue),
              ]),
            ),
          ),
        ),
      );

  /// sheet แพ้ยา หน้าตาเดียวกับ _qSheetPick (กว้าง 560 มีที่จับ) แต่เลือกได้หลายตัว
  void _qAllergySheet() {
    HapticFeedback.selectionClick();
    var q = '';
    final all = _qMaster('er_drug_allergy');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final hits = [
          for (final d in all)
            if (q.isEmpty || d.toLowerCase().contains(q.toLowerCase())) d,
        ];
        final custom = q.trim().isNotEmpty &&
            !all.any((d) => d.toLowerCase() == q.trim().toLowerCase());
        void toggle(String d) {
          setState(() => _regAllergy.contains(d)
              ? _regAllergy.remove(d)
              : _regAllergy.add(d));
          set(() {});
        }

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(ctx).height * 0.5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: _line,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Text('ประวัติแพ้ยา',
                        style: _t(16.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text('เลือกได้หลายตัว ถ้าไม่มีในรายการพิมพ์ชื่อแล้วกดเพิ่ม',
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                    const SizedBox(height: 10.0),
                    TextField(
                      onChanged: (v) => set(() => q = v),
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w500),
                      decoration:
                          _qFloat('ค้นหาชื่อยา', icon: Icons.search_rounded),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: ListView(children: [
                        if (custom)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: _qOpt(
                                'เพิ่ม "${q.trim()}"',
                                Icons.add_rounded,
                                false,
                                () => toggle(q.trim())),
                          ),
                        for (final d in [
                          ..._regAllergy.where((a) => !all.contains(a)),
                          ...hits,
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: _qOpt(d, null, _regAllergy.contains(d),
                                () => toggle(d)),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 8.0),
                    _navBtn(
                        'เสร็จ', Icons.check_rounded, () => Navigator.pop(ctx)),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// แถวเลือกค่าแบบเดียวกับแถวข้อมูล: ชื่อซ้าย | ค่า (หรือ "เลือก") | ลูกศร
  Widget _qPickRow(String k, String label, List<String> opts,
      {bool last = false}) {
    final v = _regPick[k];
    return KeyedSubtree(
      key: _qFieldKeys.putIfAbsent(k, GlobalKey.new),
      child: _Press(
        scale: 0.99,
        radius: 4.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _qSheetPick(
              label, v, opts, (x) => setState(() => _regPick[k] = x)),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56.0),
            decoration: BoxDecoration(
              border: last
                  ? null
                  : const Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
            ),
            child: Row(children: [
              SizedBox(
                width: 180.0,
                child: Text(label,
                    style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
              ),
              Expanded(
                child: Text(v ?? 'เลือก',
                    style: _t(14.0,
                        color: v == null ? _g5 : _inkTitle,
                        weight: FontWeight.w500)),
              ),
              const Icon(Icons.expand_more_rounded, size: 20.0, color: _blue),
            ]),
          ),
        ),
      ),
    );
  }

  /// ช่องของผู้ป่วยใหม่ที่ยังว่าง: (key ช่อง, ชื่อ, เป็นช่องพิมพ์)
  List<(String, String, bool)> _qNewMissing() => [
        if (!_qPhoneOk) ('phone', 'เบอร์โทรศัพท์', true),
        for (final (k, l) in const [
          ('job', 'อาชีพ'),
          ('blood', 'หมู่เลือด'),
          ('ethnic', 'เชื้อชาติ'),
          ('nation', 'สัญชาติ'),
          ('religion', 'ศาสนา'),
          ('marital', 'สถานภาพ'),
        ])
          if (_regPick[k] == null) (k, l, false),
        for (final (k, l) in const [
          ('addr_prov', 'จังหวัด'),
          ('addr_amp', 'อำเภอ'),
          ('addr_tam', 'ตำบล'),
          ('addr_zip', 'รหัสไปรษณีย์'),
        ])
          if (_regCtl(k).text.trim().isEmpty) (k, l, true),
      ];

  /// เลื่อนไปช่องว่างช่องแรก · ช่องพิมพ์ = เปิดคีย์บอร์ดให้
  void _qGoMissing() {
    final m = _qNewMissing();
    if (m.isEmpty) return;
    final (k, _, typed) = m.first;
    final c = _qFieldKeys[k]?.currentContext;
    if (c == null) return;
    Scrollable.ensureVisible(c,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            alignment: 0.3)
        .then((_) {
      if (typed) _qFieldFocus[k]?.requestFocus();
    });
  }

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
  /// การ์ดหัวข้อ · ส่ง sum มา = เป็น accordion (เปิดทีละหัวข้อ แบบ workflow อุบัติเหตุ)
  /// ย่อแล้วเห็นสรุปสั้น + วงสถานะ ✓ ครบ
  Widget _qCard(String title, Widget child,
      {String? count,
      Widget? trailing,
      EdgeInsets? pad,
      String? sum,
      bool done = false,
      bool keepTitle = false}) {
    // แบบหน้าตั้งค่า Google (AdSense): section ขอบเส้นเทาบาง มุม 8 ไม่มีเงา
    // หัวข้อ + คำอธิบายเล็กใต้หัวข้อ · เปิดทุกหัวข้อ ไม่พับ
    final showTitle = !_qFlat || keepTitle;
    count ??= _qCardSub[title];
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: pad == null
          ? const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 22.0)
          : pad.copyWith(left: 24.0, right: 24.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showTitle || trailing != null)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTitle)
                      Text(title,
                          style: _t(16.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    if (count != null) ...[
                      const SizedBox(height: 2.0),
                      Text(count,
                          style:
                              _t(12.5, color: _ink3, weight: FontWeight.w500)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ]),
          const SizedBox(height: 16.0),
          child,
        ],
      ),
    );
  }

  /// header แบบโปรไฟล์ผู้ป่วย (เหมือนหน้ารายละเอียดผู้ป่วย): รูป + เพศ
  /// ชื่อ อายุ HN | แพ้ยา โรคประจำตัว · ยังไม่ระบุตัวตน = รูปว่าง + คำแนะนำ
  Widget _qProfileHeader() {
    final known = _regName.isNotEmpty;
    final photo = _regUnknown ? null : _regPhoto;
    // อายุแบบหน้ารายละเอียดผู้ป่วย: x ปี y เดือน
    final meta = [
      if (_regDob != null) _regAge(_regDob!),
      if (_regSex != null && _regSex != 'ไม่ระบุ') _regSex!,
      if (_qFound) 'HN $_regHn',
      if (_qFound) 'หมู่เลือด O',
    ];
    final (sug, _) = _triAdvise();
    final level = _triPick ?? sug;
    final esi = level == null ? null : _Esi.values[level - 1];
    final gcs = _triVal('gcs');
    final waited = DateTime.now().difference(_qAt).inMinutes.clamp(0, 99999);
    // ข้อมูลสำคัญชุดเดียวกับหน้ารายละเอียด: แพ้ยา โรคประจำตัว GCS สภาพ อยู่ใน ER
    final facts = [
      (
        'แพ้ยา / อาหาร',
        _regAllergy.isEmpty
            ? (_qFound ? 'ไม่มี' : '-')
            : _regAllergy.join(', ').toUpperCase(),
        _regAllergy.isNotEmpty
      ),
      ('โรคประจำตัว', _qFound ? 'DM, HT' : '-', false),
      (
        'GCS',
        gcs == null
            ? '-'
            : (gcs == gcs.roundToDouble() ? '${gcs.toInt()}' : '$gcs'),
        gcs != null && gcs <= 12
      ),
      ('สภาพ', _qArrive, false),
      ('อยู่ใน ER', _hm(waited), false),
    ];
    Widget fact((String, String, bool) f) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(f.$1, style: _t(9.0, color: f.$3 ? _red : _ink3)),
            Text(f.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(11.0,
                    color: f.$3 ? _red : _inkTitle, weight: FontWeight.w600)),
          ],
        );
    return Row(children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 38.0,
          height: 38.0,
          decoration: const BoxDecoration(
            color: _panelSoft,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: photo != null
              ? Image.asset(photo, fit: BoxFit.cover)
              : Icon(
                  _regUnknown
                      ? Icons.person_off_outlined
                      : Icons.person_rounded,
                  size: 22.0,
                  color: _ink3),
        ),
        if (_regSex == 'ชาย' || _regSex == 'หญิง')
          Positioned(
            right: -3.0,
            bottom: -3.0,
            child: Container(
              width: 17.0,
              height: 17.0,
              decoration: BoxDecoration(
                gradient: _glossGrad(_blue),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              foregroundDecoration: const _InnerGloss(100.0, dark: true),
              child: Icon(
                  _regSex == 'หญิง' ? Icons.female_rounded : Icons.male_rounded,
                  size: 11.0,
                  color: Colors.white),
            ),
          ),
      ]),
      const SizedBox(width: 10.0),
      Expanded(
        flex: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Flexible(
                child: Text(known ? _regName : 'ยังไม่ระบุตัวตน',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(13.5,
                        color: known ? _inkTitle : _ink3,
                        weight: FontWeight.w600)),
              ),
              // ESI ตามที่คัดกรองอยู่ + pain score แบบหน้ารายละเอียด
              if (esi != null) ...[
                const SizedBox(width: 8.0),
                Container(
                  height: 21.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                  decoration: BoxDecoration(
                    gradient: _glossGrad(esi.color),
                    borderRadius: BorderRadius.circular(100.0),
                    boxShadow: _glossLift(esi.color),
                  ),
                  foregroundDecoration: const _InnerGloss(100.0, dark: true),
                  child: Text(esi.en,
                      style: _t(9.5,
                          color: Colors.white, weight: FontWeight.w600)),
                ),
              ],
              if (_triPain case final ps?) ...[
                const SizedBox(width: 6.0),
                _painPill(ps),
              ],
            ]),
            const SizedBox(height: 1.0),
            Text(meta.isEmpty ? 'อ่านบัตรหรือค้นหาผู้ป่วย' : meta.join('   '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(10.0, color: _ink2)),
          ],
        ),
      ),
      Container(
        width: 1.0,
        height: 30.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        color: _line,
      ),
      Expanded(
        flex: 8,
        child: Row(children: [
          for (var k = 0; k < facts.length; k++) ...[
            if (k > 0) const SizedBox(width: 12.0),
            Expanded(flex: k < 2 ? 3 : 2, child: fact(facts[k])),
          ],
        ]),
      ),
    ]);
  }

  void _qSearchSheet() {
    final ctl = _regCtl('q');
    void go(BuildContext ctx) {
      Navigator.of(ctx).pop();
      if (ctl.text.trim().isNotEmpty) _qRead();
    }

    showDialog<void>(
      context: context,
      barrierColor: const Color(0x66101828),
      builder: (ctx) => Dialog(
        backgroundColor: _panel,
        insetPadding: const EdgeInsets.all(24.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        child: SizedBox(
          width: 460.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('ค้นหาผู้ป่วย',
                        style: _t(16.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ),
                  _Press(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(ctx).pop(),
                      child: const SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child:
                            Icon(Icons.close_rounded, size: 22.0, color: _ink3),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 4.0),
                Text('ใช้เลขบัตรประชาชน HN หรือเบอร์โทรที่เคยลงไว้',
                    style: _t(12.0, color: _ink3)),
                const SizedBox(height: 14.0),
                SizedBox(
                  height: 48.0,
                  child: TextField(
                    controller: ctl,
                    autofocus: true,
                    onSubmitted: (_) => go(ctx),
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w500),
                    decoration: _regDeco('เลขบัตร HN หรือเบอร์โทร',
                        prefix: const Icon(Icons.search_rounded,
                            size: 20.0, color: _ink3)),
                  ),
                ),
                const SizedBox(height: 14.0),
                _Press(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => go(ctx),
                    child: Container(
                      height: 48.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text('ค้นหา',
                          style: _t(14.0,
                              color: Colors.white, weight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// คำอธิบายใต้ชื่อแท็บ (หัวหน้า)
  static const Map<String, String> _qTabSub = {
    'ประวัติ': 'ข้อมูลจากบัตรประชาชนและ HOSxP ตรวจทาน แล้วกรอกส่วนที่ยังขาด',
    'คัดกรอง': 'อาการ สัญญาณชีพ และข้อบ่งชี้ เพื่อหาระดับความเร่งด่วน (ESI)',
    'สรุป': 'ระดับที่ระบบแนะนำ ตรวจทานก่อนยืนยันและส่งต่อ',
  };

  /// คำอธิบายใต้หัวข้อการ์ด (ใช้เมื่อการ์ดไม่ได้ส่ง count มาเอง)
  static const Map<String, String> _qCardSub = {
    'ข้อมูลผู้ป่วย': 'ข้อมูลจากบัตรประชาชนและประวัติใน HOSxP',
    'การเข้าห้องฉุกเฉิน': 'วันเวลาที่มาถึง เวร และสภาพผู้ป่วยตอนมาถึง',
    'ข้อมูลการมา': 'วิธีที่ผู้ป่วยมาถึง และผู้นำส่ง',
    'ผู้แจ้งข้อมูล': 'ใครเป็นผู้ให้ข้อมูลอาการและประวัติ',
    'อาการสำคัญ': 'เลือกได้หลายอาการ อาการวิกฤตขอบแดง',
    'สัญญาณชีพ': 'ค่าที่เกินเกณฑ์จะเป็นสีแดง',
    'ความรู้สึกตัว GCS และรูม่านตา': 'เลือก E V M ระบบรวมคะแนน GCS ให้',
    'NEWS2': 'คำนวณจากสัญญาณชีพที่กรอก',
    '1  จะเสียชีวิต ต้องช่วยทันที': 'ใช่ข้อใดข้อหนึ่ง = ESI 1',
    '2  เสี่ยง ซึม ปวด': 'ใช่ข้อใดข้อหนึ่ง = ESI 2',
    '3  กิจกรรมที่คาดว่าต้องทำ': 'มากกว่า 1 = ESI 3, 1 = ESI 4, ไม่มี = ESI 5',
    'ระบุตัวตน': 'อ่านบัตรประชาชน หรือค้นหาผู้ป่วย',
  };

  /// เนื้อหาแบบแท็บแนวตั้ง (Figma 356-178): ซ้าย = แท็บไอคอน · ขวา = แผงหัวข้อ
  /// ประวัติ = ผู้ป่วย เข้าห้อง การมา ผู้แจ้ง รับเข้า
  /// คัดกรอง = ประเภท อาการ V/S GCS NEWS2 ขั้น 1-3 · สรุป = ESI + ส่ง RESUS
  Widget _qTabsBody(Widget who, Widget cc, Widget arrive, Widget idCard,
      Widget informant, Widget esi) {
    const tabs = [
      ('ประวัติ', Icons.auto_stories_outlined, 'ข้อมูลผู้ป่วย'),
      ('คัดกรอง', Icons.zoom_in_rounded, 'ประเภทผู้ป่วย'),
      ('สรุป', Icons.format_list_bulleted_rounded, ''),
    ];
    // ค่าเก่าที่ไม่ตรงแท็บใด = แท็บแรก
    if (!tabs.any((t) => t.$1 == _qTab)) _qTab = tabs.first.$1;
    // หัวข้อของแท็บ: (ชื่อ, กรอกครบ, การ์ด) · ใช้ทั้งเนื้อหาและสารบัญขวา
    final ccDone = _qCc.isNotEmpty || _regCtl('cc').text.trim().isNotEmpty;
    final adv = _triAdvise().$1;
    final tri = _qTab == 'คัดกรอง' ? _triAssessCards() : const <Widget>[];
    final secs = <(String, bool, Widget)>[
      if (_qTab == 'ประวัติ') ...[
        (
          'ข้อมูลผู้ป่วย',
          // ผู้ป่วยใหม่: ครบเมื่อกรอกช่องที่ขาดครบ
          _regReady && (!_qNew || _qNewMissing().isEmpty),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!_qFound && !_qNew) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420.0),
                    child: idCard),
              ),
              const SizedBox(height: 10.0),
            ],
            who,
          ])
        ),
        ('การเข้าห้องฉุกเฉิน', _qShift != null, _qVisitInCard(arrive)),
        (
          'ข้อมูลการมา',
          _qArrType != null && _qBringer != null,
          _qArrivalCard()
        ),
        ('ผู้แจ้งข้อมูล', true, informant),
        ('การรับเข้าห้องฉุกเฉิน', true, _qAdmitCard()),
      ],
      if (_qTab == 'คัดกรอง') ...[
        ('ประเภทผู้ป่วย', _triType.isNotEmpty, _triTypeCard()),
        ('อาการสำคัญ', ccDone, cc),
        (
          'สัญญาณชีพ',
          _triVal('hr') != null &&
              _triVal('rr') != null &&
              _triVal('sbp') != null,
          tri[0]
        ),
        ('ความรู้สึกตัว GCS', _triVal('gcs') != null, tri[1]),
        ('NEWS2', _triNews() != null, tri[2]),
        ('ต้องช่วยชีวิตทันที', adv != null, tri[3]),
        ('เสี่ยง ซึม ปวด', adv != null, tri[4]),
        ('กิจกรรมที่ต้องทำ', _triAct.isNotEmpty || (adv ?? 9) <= 2, tri[5]),
      ],
    ];
    // หน้าประวัติ: จัดหัวข้อเป็นกลุ่ม แสดงทีละกลุ่มตามแท็บย่อย
    const groups = {
      'ข้อมูลผู้ป่วย': 'ผู้ป่วย',
      'การเข้าห้องฉุกเฉิน': 'การมาถึง',
      'ข้อมูลการมา': 'การมาถึง',
      'ผู้แจ้งข้อมูล': 'การมาถึง',
      'การรับเข้าห้องฉุกเฉิน': 'การรับบริการ',
      // คัดกรอง: อาการ → สัญญาณชีพ → ระดับ ESI
      'ประเภทผู้ป่วย': 'อาการ',
      'อาการสำคัญ': 'อาการ',
      'สัญญาณชีพ': 'สัญญาณชีพ',
      'ความรู้สึกตัว GCS': 'สัญญาณชีพ',
      'NEWS2': 'สัญญาณชีพ',
      'ต้องช่วยชีวิตทันที': 'ระดับ ESI',
      'เสี่ยง ซึม ปวด': 'ระดับ ESI',
      'กิจกรรมที่ต้องทำ': 'ระดับ ESI',
    };
    final subTabs = switch (_qTab) {
      'ประวัติ' => const ['ผู้ป่วย', 'การมาถึง', 'การรับบริการ'],
      'คัดกรอง' => const ['อาการ', 'สัญญาณชีพ', 'ระดับ ESI'],
      _ => const <String>[],
    };
    final hasSub = subTabs.isNotEmpty;
    final sub = _qSubOf[_qTab] ?? (hasSub ? subTabs.first : '');
    // สารบัญใช้ทุกหัวข้อของแท็บ (จัดตามกลุ่ม) · เนื้อหาแสดงเฉพาะกลุ่มที่เลือก
    final allSecs = [...secs];
    if (hasSub) {
      secs.retainWhere((x) => groups[x.$1] == sub);
    }
    Widget subBar() => Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFDADCE0))),
          ),
          child: Row(children: [
            for (final t in subTabs)
              _Press(
                scale: 0.98,
                radius: 4.0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (sub == t) return;
                    HapticFeedback.selectionClick();
                    setState(() => _qSubOf[_qTab] = t);
                  },
                  child: Container(
                    height: 48.0,
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color:
                                sub == t ? _blue : _blue.withValues(alpha: 0.0),
                            width: 3.0),
                      ),
                    ),
                    child: Text(t,
                        style: _t(14.0,
                            color: sub == t ? _blue : _ink2,
                            weight:
                                sub == t ? FontWeight.w600 : FontWeight.w500)),
                  ),
                ),
              ),
          ]),
        );
    final cards = [
      for (final (k, _, w) in secs)
        KeyedSubtree(
            key: _qSecKeys.putIfAbsent('$_qTab|$k', GlobalKey.new), child: w),
    ];
    // สารบัญขวา (On this page): จุดสถานะ ✓ + ชื่อหัวข้อ แตะเพื่อเลื่อนไป
    // รายการย่อยในสารบัญ: (ชื่อ, ครบ, key ช่องที่จะเลื่อนไป)
    bool has(String k) => _regCtl(k).text.trim().isNotEmpty;
    bool vs(String k) => _triVal(k) != null;
    List<(String, bool, String?)> subsOf(String sec) => switch (sec) {
          'ข้อมูลผู้ป่วย' when _qNew => [
              ('ข้อมูลจากบัตร', true, null),
              ('ที่อยู่ปัจจุบัน', has('addr_prov') && has('addr_zip'), 'addr'),
              ('เบอร์โทรศัพท์', _qPhoneOk, 'phone'),
              ('ประวัติแพ้ยา', true, 'allergy'),
              ('อาชีพ', _regPick['job'] != null, 'job'),
              ('หมู่เลือด', _regPick['blood'] != null, 'blood'),
              ('เชื้อชาติ', _regPick['ethnic'] != null, 'ethnic'),
              ('สัญชาติ', _regPick['nation'] != null, 'nation'),
              ('ศาสนา', _regPick['religion'] != null, 'religion'),
              ('สถานภาพ', _regPick['marital'] != null, 'marital'),
            ],
          'ข้อมูลผู้ป่วย' => [
              ('ข้อมูลจากบัตร / HOSxP', _qFound, null),
              if (_qFound) ('ประวัติแพ้ยา', true, 'allergy'),
              ('เบอร์โทรศัพท์', _qPhoneOk, 'phone'),
            ],
          'การเข้าห้องฉุกเฉิน' => [
              ('วันเวลาเข้าห้อง', true, null),
              ('เวร', _qShift != null, null),
              ('สภาพผู้ป่วย', true, null),
            ],
          'ข้อมูลการมา' => [
              ('ประเภทการมา', _qArrType != null, 'pick:ประเภทการมา'),
              ('ผู้นำส่ง', _qBringer != null, 'pick:ผู้นำส่ง'),
            ],
          'การรับเข้าห้องฉุกเฉิน' => [
              ('แผนก', true, null),
              ('UCEP คดี DOA', true, null),
            ],
          'สัญญาณชีพ' => [
              ('ความดัน', vs('sbp') && vs('dbp'), 'vs:sbp'),
              ('ชีพจร', vs('hr'), 'vs:hr'),
              ('หายใจ', vs('rr'), 'vs:rr'),
              ('SpO₂', vs('spo2'), 'vs:spo2'),
              ('อุณหภูมิ', vs('bt'), 'vs:bt'),
              ('น้ำหนัก ส่วนสูง', vs('wt') && vs('ht'), 'vs:wt'),
            ],
          'ความรู้สึกตัว GCS' => [
              ('ความรู้สึกตัว', _triLoc != null, null),
              ('GCS', vs('gcs'), 'pick:การลืมตา'),
              ('รูม่านตา', _triPupil.isNotEmpty, null),
            ],
          _ => const [],
        };
    void jumpTo(String sec, String? field) {
      void go() {
        final c = (field == null ? null : _qFieldKeys[field]?.currentContext) ??
            _qSecKeys['$_qTab|$sec']?.currentContext;
        if (c != null) {
          Scrollable.ensureVisible(c,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              alignment: field == null ? 0.02 : 0.3);
        }
      }

      final g = groups[sec];
      if (hasSub && g != null && g != sub) {
        setState(() => _qSubOf[_qTab] = g);
        WidgetsBinding.instance.addPostFrameCallback((_) => go());
      } else {
        go();
      }
    }

    Widget toc() {
      final done = allSecs.where((x) => x.$2).length;
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 28.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ในหน้านี้',
                style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
            const SizedBox(height: 4.0),
            Text('กรอกแล้ว $done จาก ${allSecs.length}',
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
            const SizedBox(height: 8.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(3.0),
              child: TweenAnimationBuilder<double>(
                tween:
                    Tween(end: allSecs.isEmpty ? 0.0 : done / allSecs.length),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (_, x, __) => LinearProgressIndicator(
                  value: x,
                  minHeight: 4.0,
                  backgroundColor: _panelSoft,
                  color: done == allSecs.length ? _green : _blue,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Container(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Color(0xFFDADCE0))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < allSecs.length; i++) ...[
                    if (hasSub &&
                        (i == 0 ||
                            groups[allSecs[i].$1] != groups[allSecs[i - 1].$1]))
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            12.0, i == 0 ? 0.0 : 10.0, 4.0, 2.0),
                        child: Text(groups[allSecs[i].$1] ?? '',
                            style: _t(11.0,
                                color: groups[allSecs[i].$1] == sub
                                    ? _blue
                                    : _ink3,
                                weight: FontWeight.w700)),
                      ),
                    () {
                      final (k, ok, _) = allSecs[i];
                      // แสดงรายการย่อยเฉพาะหัวข้อในแท็บย่อยที่เปิดอยู่
                      final subs = !hasSub || groups[k] == sub
                          ? subsOf(k)
                          : const <(String, bool, String?)>[];
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Press(
                              scale: 0.99,
                              radius: 6.0,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => jumpTo(k, null),
                                child: Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 40.0),
                                  padding: const EdgeInsets.fromLTRB(
                                      12.0, 6.0, 4.0, 6.0),
                                  child: Row(children: [
                                    Icon(
                                        ok
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                .radio_button_unchecked_rounded,
                                        size: 16.0,
                                        color: ok ? _green : _g5),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(k,
                                          style: _t(12.5,
                                              color: ok ? _ink2 : _inkTitle,
                                              weight: FontWeight.w500)),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                            // รายการย่อย: เยื้องใต้หัวข้อ จุดเขียว = ครบ
                            // ขยายแบบยืดความสูง + ไล่จางเข้าทีละแถว
                            AnimatedSize(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topCenter,
                              child: subs.isEmpty
                                  ? const SizedBox(width: double.infinity)
                                  : TweenAnimationBuilder<double>(
                                      key: ValueKey('toc:$k'),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: Duration(
                                          milliseconds: 220 + 40 * subs.length),
                                      builder: (_, t, __) {
                                        // แถวที่ n เริ่มช้ากว่าแถวก่อนเล็กน้อย
                                        Widget appear(int n, Widget w) {
                                          final x =
                                              ((t * (subs.length + 3) - n) / 3)
                                                  .clamp(0.0, 1.0);
                                          final e =
                                              Curves.easeOutCubic.transform(x);
                                          return Opacity(
                                            opacity: e,
                                            child: Transform.translate(
                                                offset:
                                                    Offset(0.0, (1 - e) * -6.0),
                                                child: w),
                                          );
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            for (final (n, (sl, sok, sf))
                                                in subs.indexed)
                                              appear(
                                                  n,
                                                  _Press(
                                                    scale: 0.99,
                                                    radius: 6.0,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      onTap: () =>
                                                          jumpTo(k, sf),
                                                      child: Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                                minHeight:
                                                                    30.0),
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(36.0,
                                                                4.0, 4.0, 4.0),
                                                        child: Row(children: [
                                                          Container(
                                                            width: 6.0,
                                                            height: 6.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: sok
                                                                  ? _green
                                                                  : _g5,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8.0),
                                                          Expanded(
                                                            child: Text(sl,
                                                                style: _t(11.5,
                                                                    color: sok
                                                                        ? _ink3
                                                                        : _ink2,
                                                                    weight: FontWeight
                                                                        .w500)),
                                                          ),
                                                        ]),
                                                      ),
                                                    ),
                                                  )),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ]);
                    }(),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    // แท็บแนวตั้ง (Figma 356-178): แท็บที่เลือกพื้นขาวต่อเนื่องกับหน้าเนื้อหา
    // มุมเว้าตรงรอยต่อแท็บกับการ์ด (ขาวเติมมุม เทาเจาะโค้ง)
    Widget fillet({required bool top}) => SizedBox(
          width: 16.0,
          height: 16.0,
          child: ColoredBox(
            color: _panel,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: top
                    ? const BorderRadius.only(
                        bottomRight: Radius.circular(16.0))
                    : const BorderRadius.only(topRight: Radius.circular(16.0)),
              ),
            ),
          ),
        );
    final firstOn = tabs.isNotEmpty && _qTab == tabs.first.$1;
    final onIdx = tabs.indexWhere((t) => t.$1 == _qTab);
    const tabH = 78.0, tabGap = 4.0, slide = Duration(milliseconds: 260);
    // ตัวแท็บโปร่ง พื้นขาวเป็นแผ่นเดียวที่เลื่อนไปหาแท็บที่เลือก (ด้านล่าง)
    Widget tab((String, IconData, String) t) {
      final on = _qTab == t.$1;
      return _Press(
        radius: 16.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _qTab = t.$1);
          },
          child: SizedBox(
            height: tabH,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(t.$2, size: 26.0, color: on ? _blue : _ink3),
              const SizedBox(height: 4.0),
              AnimatedDefaultTextStyle(
                duration: slide,
                style: _t(10.5,
                    color: on ? _inkTitle : _ink3,
                    weight: on ? FontWeight.w700 : FontWeight.w500),
                child: Text(t.$1, textAlign: TextAlign.center),
              ),
            ]),
          ),
        ),
      );
    }

    // แผ่นขาวของแท็บที่เลือก + มุมเว้าบน/ล่าง เลื่อนไปพร้อมกัน
    Widget blob() => AnimatedPositioned(
          duration: slide,
          curve: Curves.easeOutCubic,
          top: onIdx * (tabH + tabGap),
          left: 0.0,
          right: 0.0,
          height: tabH,
          child: IgnorePointer(
            child: Stack(clipBehavior: Clip.none, children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(16.0)),
                  ),
                ),
              ),
              // แท็บแรกชิดขอบบนการ์ด ไม่ต้องมีมุมเว้าด้านบน
              Positioned(
                right: 0.0,
                top: -16.0,
                child: AnimatedOpacity(
                    opacity: onIdx == 0 ? 0.0 : 1.0,
                    duration: slide,
                    child: fillet(top: true)),
              ),
              Positioned(right: 0.0, bottom: -16.0, child: fillet(top: false)),
            ]),
          ),
        );

    // หน้าโล่งแบบ AdSense: พื้นขาวทั้งหน้า เนื้อหากว้างไม่เกิน 880 กึ่งกลาง
    // แผงใหญ่เป็นการ์ดขาวมุมโค้งบนพื้นเทา (แท็บที่เลือกต่อกับการ์ด)
    return Container(
      color: _panelSoft,
      padding: const EdgeInsets.fromLTRB(0.0, 12.0, 12.0, 12.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          width: 104.0,
          color: _panelSoft,
          padding: const EdgeInsets.only(left: 8.0),
          child: Stack(clipBehavior: Clip.none, children: [
            if (onIdx >= 0) blob(),
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (final t in tabs) ...[
                tab(t),
                const SizedBox(height: tabGap),
              ],
            ]),
          ]),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: slide,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: _panel,
              // แท็บแรกเลือกอยู่: มุมบนซ้ายเหลี่ยม ต่อกับแท็บเป็นแผ่นเดียว
              borderRadius: BorderRadius.circular(20.0).copyWith(
                  topLeft: firstOn ? Radius.zero : const Radius.circular(20.0)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _qTab == 'สรุป'
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 880.0),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                        child: esi,
                      ),
                    ),
                  )
                : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(24.0, 28.0, 24.0, 32.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 880.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // หัวหน้าแบบ AdSense: ชื่อ + คำอธิบายซ้าย (ชิดบน) · รูปประกอบชิดขวา
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_qTab,
                                                style: _t(26.0,
                                                    color: _inkTitle,
                                                    weight: FontWeight.w500)),
                                            const SizedBox(height: 6.0),
                                            Text(_qTabSub[_qTab] ?? '',
                                                style: _t(14.0,
                                                    color: _ink2,
                                                    weight: FontWeight.w500)),
                                            // แพ้ยา: banner แดงใต้คำอธิบายหน้า (ข้อมูลอันตราย ต้องเห็นก่อน)
                                            if (_qTab == 'ประวัติ' &&
                                                _regAllergy.isNotEmpty) ...[
                                              const SizedBox(height: 16.0),
                                              _qBanner(
                                                  Icons.warning_rounded,
                                                  'แพ้ยา ${_regAllergy.join(', ').toUpperCase()}',
                                                  _red,
                                                  sub: _qFound
                                                      ? 'จากประวัติใน HOSxP ตรวจสอบกับผู้ป่วยอีกครั้ง'
                                                      : 'ตรวจสอบกับผู้ป่วยอีกครั้ง'),
                                            ],
                                            // ผู้ป่วยใหม่: ช่องที่ยังขาด + ปุ่มไปที่ช่องว่าง
                                            if (_qTab == 'ประวัติ' &&
                                                _qNew) ...[
                                              const SizedBox(height: 12.0),
                                              () {
                                                final miss = _qNewMissing();
                                                return _qBanner(
                                                    miss.isEmpty
                                                        ? Icons
                                                            .check_circle_rounded
                                                        : Icons
                                                            .person_add_alt_1_rounded,
                                                    miss.isEmpty
                                                        ? 'ข้อมูลผู้ป่วยใหม่ครบแล้ว'
                                                        : 'ผู้ป่วยใหม่ กรอกอีก ${miss.length} ช่องให้ครบ',
                                                    _blue,
                                                    sub: miss.isEmpty
                                                        ? 'ระบบจะออก HN ให้เมื่อส่งต่อ'
                                                        : 'ไม่พบประวัติใน HOSxP',
                                                    action: miss.isEmpty
                                                        ? null
                                                        : 'ไปที่ช่องที่ยังว่าง',
                                                    onAction: _qGoMissing);
                                              }(),
                                            ],
                                          ],
                                        ),
                                      ),
                                      // รูปประกอบต่อหน้า (Figma 357-263, 357-301)
                                      if (const {
                                        'ประวัติ': 'personal',
                                        'คัดกรอง': 'triage',
                                      }[_qTab]
                                          case final hero?) ...[
                                        const SizedBox(width: 16.0),
                                        Image.asset(
                                            'assets/images/er_hero_$hero.png',
                                            height: 130.0,
                                            fit: BoxFit.contain),
                                      ],
                                    ]),
                                const SizedBox(height: 4.0),
                                if (hasSub) ...[
                                  subBar(),
                                  const SizedBox(height: 20.0),
                                ],
                                ...cards,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // สารบัญยาว (มีรายการย่อย) เลื่อนในตัว
                    SizedBox(
                        width: 220.0,
                        child: SingleChildScrollView(child: toc())),
                  ]),
          ),
        ),
      ]),
    );
  }

  /// panel หนึ่งคอลัมน์: พื้นโปร่งบนภาพพื้นหลัง หัวข้อเล็ก เนื้อหาเลื่อนในตัว
  Widget _qPanel(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      );

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
          // 44 = ขนาดแตะขั้นต่ำ · ไอคอนข้างชื่อ (เตี้ยกว่าแบบซ้อนบนล่าง)
          height: 44.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: on ? c.withValues(alpha: 0.08) : _panel,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
                color: on
                    ? c
                    : (crit
                        ? c.withValues(alpha: 0.35)
                        : const Color(0xFFDADCE0)),
                width: on ? 1.6 : 1.0),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_qCcIcon(l), size: 18.0, color: on || crit ? c : _ink2),
            const SizedBox(width: 6.0),
            Text(l,
                maxLines: 1,
                style: _t(12.5,
                    color: on ? c : _inkTitle,
                    weight: on ? FontWeight.w700 : FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  /// หน้าแรก (Figma 356-162): ซ้าย = ชื่อหน้า · ขวา = bento วิธีดึงข้อมูลผู้ป่วย
  /// อ่านบัตร (ช่องใหญ่) · ถ่ายภาพบัตร · สแกนใบหน้า · ค้นหาโดย HN
  /// ได้ข้อมูลแล้ว (_qLookup) เข้าหน้าคัดกรอง 3 panel ทันที
  Widget _qIntroPage() {
    Widget tile(IconData ic, String label, String sub, VoidCallback onTap,
        {bool big = false, bool busy = false, bool row = false}) {
      return _Press(
        scale: 0.98,
        radius: 20.0,
        child: GestureDetector(
          onTap: busy
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          child: Container(
            padding: EdgeInsets.all(big ? 24.0 : 18.0),
            decoration: BoxDecoration(
              color: big ? _blue : _panel,
              borderRadius: BorderRadius.circular(20.0),
              border: big ? null : Border.all(color: _line),
              boxShadow: big ? _glossLift(_blue) : null,
            ),
            // ช่องเตี้ย (row) = ไอคอนซ้าย ข้อความขวา
            child: row
                ? Row(children: [
                    Icon(ic, size: 30.0, color: _blue),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(label,
                              style: _t(16.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          Text(sub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(12.0,
                                  color: _ink3, weight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: _ink3),
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: _t(big ? 22.0 : 16.0,
                              color: big ? Colors.white : _inkTitle,
                              weight: FontWeight.w700)),
                      const SizedBox(height: 2.0),
                      Text(sub,
                          style: _t(12.0,
                              color: big ? const Color(0xCCFFFFFF) : _ink3,
                              weight: FontWeight.w500)),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: busy
                            ? const SizedBox(
                                width: 36.0,
                                height: 36.0,
                                child: CircularProgressIndicator(
                                    strokeWidth: 3.0, color: Colors.white),
                              )
                            : Icon(ic,
                                size: big ? 64.0 : 36.0,
                                color: big
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : _blue),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    return Material(
      color: _panel,
      child: SafeArea(
        child: Stack(children: [
          Positioned(
            left: 16.0,
            top: 12.0,
            child: _topIcon(Icons.arrow_back_rounded, false, _closeRegister),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040.0),
                child: Row(children: [
                  // ซ้าย: ชื่อหน้า
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('ลงทะเบียนผู้ป่วยใหม่',
                            style: _t(34.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        const SizedBox(height: 6.0),
                        Text('เลือกวิธีดึงข้อมูลผู้ป่วย แล้วเข้าสู่การคัดกรอง',
                            style: _t(16.0,
                                color: _ink2, weight: FontWeight.w500)),
                        const SizedBox(height: 24.0),
                        // ทางลัดผู้ป่วยไม่ทราบชื่อ (เคสวิกฤตมาก่อน)
                        _Press(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _regUnknown = true;
                              _qFound = false;
                              _regSex ??= 'ไม่ระบุ';
                              _qIntro = false;
                            }),
                            child: Container(
                              height: 48.0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100.0),
                                border: Border.all(color: _line),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.person_off_outlined,
                                        size: 20.0, color: _ink2),
                                    const SizedBox(width: 8.0),
                                    Text('ไม่ทราบชื่อ ลงทะเบียนก่อน',
                                        style: _t(14.0,
                                            color: _inkTitle,
                                            weight: FontWeight.w600)),
                                  ]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        // จำลองอ่านบัตรผู้ป่วยที่ไม่มีใน HOSxP (สาธิตหน้าผู้ป่วยใหม่)
                        _Press(
                          radius: 100.0,
                          child: GestureDetector(
                            onTap: _qReadNew,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 10.0),
                              child: Text(
                                  'ทดลอง: อ่านบัตรผู้ป่วยใหม่ (ไม่มีใน HOSxP)',
                                  style: _t(12.5,
                                      color: _blue, weight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32.0),
                  // ขวา: bento ตาม Figma
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 230.0,
                          child: tile(
                              Icons.credit_card_rounded,
                              _qReading ? 'กำลังอ่านบัตร' : 'อ่านบัตรประชาชน',
                              'เสียบบัตรที่เครื่องอ่าน แล้วแตะที่นี่',
                              _qRead,
                              big: true,
                              busy: _qReading),
                        ),
                        const SizedBox(height: 12.0),
                        SizedBox(
                          height: 180.0,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: tile(
                                      Icons.photo_camera_rounded,
                                      'ถ่ายภาพบัตร',
                                      'ไม่มีเครื่องอ่านบัตร',
                                      _qRead),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: tile(
                                            Icons
                                                .face_retouching_natural_rounded,
                                            'สแกนใบหน้า',
                                            'ผู้ป่วยเคยมา รพ.',
                                            _startFaceScan,
                                            row: true),
                                      ),
                                      const SizedBox(height: 12.0),
                                      Expanded(
                                        child: tile(
                                            Icons.search_rounded,
                                            'ค้นหาโดย HN',
                                            'HN เลขบัตร หรือเบอร์โทร',
                                            _qSearchSheet,
                                            row: true),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _quickRegisterPage() {
    if (_qIntro) return _qIntroPage();
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final crit = _qCcOpts.where((o) => o.$2 && _qCc.contains(o.$1)).length;
    final (sug, why) = _triAdvise();
    final level = _triPick ?? sug;

    // -------------------------------------------- ปุ่มส่ง (โหมดเร่งด่วน)
    // ปุ่มแดงไล่เฉด + ไฟไซเรน 3D ลอยล้นขอบขวา
    final resus = Stack(clipBehavior: Clip.none, children: [
      AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: 1.0,
        child: _Press(
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
                  colors: [
                    Color(0xFFB3121B),
                    Color(0xFFE53935),
                    Color(0xFFFF5A47)
                  ],
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
                                    color: Colors.white,
                                    weight: FontWeight.w700)),
                            const SizedBox(width: 4.0),
                            const Icon(
                                Icons.keyboard_double_arrow_right_rounded,
                                size: 20.0,
                                color: Colors.white),
                          ]),
                          Text('ลงทะเบียนทีหลังได้',
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
        ),
      ),
      Positioned(
        right: _srBox.$1,
        bottom: _srBox.$2,
        width: _srBox.$3,
        height: _srBox.$3,
        child: ErSiren3D(pose: _srPose),
      ),
    ]);

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // อ่านบัตรแล้วซ่อนบัตร (ชื่อ เลขบัตร อยู่ใน header แล้ว)
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _qFound ? const SizedBox(width: double.infinity) : _qIdCard(),
        ),
      ],
    );

    // -------------------------------------------- ขวา: stacked cards ตามลำดับงาน
    // bento: ช่องแคบข้างข้อมูลผู้ป่วย ตัวเลือกเรียงลง
    // สภาพผู้ป่วย: แถวเดียว 5 ช่อง (อยู่ในการ์ดการเข้าห้องฉุกเฉิน)
    final arrive = _qGrid(
        5,
        [
          // ชื่อเต็มไม่ตัดคำ: ไม่ใส่ไอคอนในแถวนี้
          for (final (l, _) in _qArrivals)
            _qOpt(l, null, _qArrive == l, () => setState(() => _qArrive = l),
                h: 44.0),
        ],
        gap: 6.0);

    final who = _qCard(
      'ข้อมูลผู้ป่วย',
      sum: [
        if (_regName.isNotEmpty) _regName,
        if (_qFound) 'HN $_regHn',
        if (_regAllergy.isNotEmpty) 'แพ้ ${_regAllergy.join(', ')}',
      ].join('  '),
      done: _regReady,
      count: _qFound
          ? 'พบใน HOSxP  HN $_regHn'
          : _qNew
              ? 'ผู้ป่วยใหม่ ไม่มีประวัติใน HOSxP'
              : null,
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
          // ข้อมูลที่มีอยู่แล้ว (บัตร/HIS): แถวอ่านอย่างเดียว แตะ ✎ เพื่อแก้
          if (_qFound) ...[
            _qRow('ชื่อ-สกุล', _regName, src: 'จากบัตรประชาชน'),
            _qRow('เลขประจำตัวประชาชน', _qMaskCid(_regCtl('cid').text)),
            _qRow(
                'วันเกิด',
                _regDob == null
                    ? ''
                    : '${_thDate(_regDob!)}  (${_regAge(_regDob!)})'),
            _qRow('เพศ', _regSex ?? ''),
            _qRow('HN', _regHn, src: 'จาก HOSxP'),
            // แพ้ยาจาก HOSxP: แก้/เพิ่มได้ ตรวจสอบกับผู้ป่วยอีกครั้ง
            _qAllergyRow(),
            _qRow('สิทธิการรักษา', 'UC (บัตรทอง)'),
            _qRow('โรคประจำตัว', 'DM, HT'),
            _qRow('มาล่าสุด', '12 ส.ค. 2567  OPD', last: true),
            const SizedBox(height: 16.0),
          ],
          // อ่านบัตรแล้ว: ชื่อ วันเกิด เพศ อยู่บนบัตรแล้ว ไม่กรอกซ้ำ เหลือเบอร์โทร
          // ข้อมูลที่ต้องกรอก/ยืนยัน: ป้ายชื่อเหนือช่อง + ช่องกรอก
          if (_qFound)
            _qField('phone', 'เบอร์โทรศัพท์ที่ติดต่อได้',
                icon: Icons.phone_rounded,
                kb: TextInputType.phone,
                helper: 'ยืนยันกับผู้ป่วยหรือญาติ แก้ได้ถ้าเปลี่ยนเบอร์')
          // ผู้ป่วยใหม่ (มีบัตร ไม่มีใน HOSxP): ข้อมูลบนบัตร = แถวอ่าน · ที่เหลือกรอก
          else if (_qNew) ...[
            _qRow('ชื่อ-สกุล', _regName, src: 'จากบัตรประชาชน'),
            _qRow('เลขประจำตัวประชาชน', _qMaskCid(_regCtl('cid').text)),
            _qRow(
                'วันเกิด',
                _regDob == null
                    ? ''
                    : '${_thDate(_regDob!)}  (${_regAge(_regDob!)})'),
            _qRow('เพศ', _regSex ?? ''),
            _qRow(
                'ที่อยู่ตามบัตร',
                '${_regCtl('addr').text} ต.${_regCtl('addr_tam').text} '
                    'อ.${_regCtl('addr_amp').text} จ.${_regCtl('addr_prov').text}'),
            const SizedBox(height: 20.0),
            Text('ที่อยู่ปัจจุบัน',
                style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
            Padding(
              padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
              child: Text('เติมจากที่อยู่ตามบัตรให้แล้ว แก้ได้ถ้าย้ายที่อยู่',
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ),
            _qEditRow('addr', 'บ้านเลขที่ หมู่ ซอย ถนน', 'กรอกที่อยู่'),
            _qEditRow('addr_tam', 'ตำบล / แขวง', 'กรอกตำบล'),
            _qEditRow('addr_amp', 'อำเภอ / เขต', 'กรอกอำเภอ'),
            _qEditRow('addr_prov', 'จังหวัด', 'กรอกจังหวัด'),
            _qEditRow('addr_zip', 'รหัสไปรษณีย์', 'กรอกรหัส',
                kb: TextInputType.number),
            // ข้อมูลที่ต้องกรอกเพิ่ม: ชื่อซ้าย | ช่องกรอกขวา
            const SizedBox(height: 20.0),
            _qEditRow('phone', 'เบอร์โทรศัพท์ *', 'กรอกเบอร์โทร',
                kb: TextInputType.phone),
            _qAllergyRow(),
            _qPickRow('job', 'อาชีพ', _qMaster('er_occupation')),
            _qChipRow(
                'blood', 'หมู่เลือด', const ['A', 'B', 'AB', 'O', 'ไม่ทราบ']),
            _qPickRow('ethnic', 'เชื้อชาติ', _qMaster('er_nationality')),
            _qPickRow('nation', 'สัญชาติ', _qMaster('er_nationality')),
            _qPickRow('religion', 'ศาสนา',
                _FeaturesRegisterRegisterPagePart._regChoices['religion']!),
            _qChipRow('marital', 'สถานภาพ',
                _FeaturesRegisterRegisterPagePart._regChoices['marital']!,
                last: true),
          ]
          // ไม่มีบัตร: กรอกเองทั้งหมด (floating label)
          else ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: _qField('name', 'ชื่อ-สกุล *')),
              const SizedBox(width: 12.0),
              Expanded(
                flex: 2,
                child: _qField('phone', 'เบอร์โทรศัพท์',
                    icon: Icons.phone_rounded, kb: TextInputType.phone),
              ),
            ]),
            const SizedBox(height: 14.0),
            _qRow(
                'วันเกิด',
                _regDob == null
                    ? 'แตะเพื่อเลือก'
                    : '${_thDate(_regDob!)}  (${_regAge(_regDob!)})',
                onEdit: _regPickDob),
            const SizedBox(height: 12.0),
            Text('เพศ *',
                style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
            const SizedBox(height: 6.0),
            _regSeg(const ['ชาย', 'หญิง', 'ไม่ระบุ'], _regSex,
                (v) => setState(() => _regSex = v)),
          ],
        ],
      ),
    );

    final cc = _qCard(
      'อาการสำคัญ',
      sum: [..._qCc, _regCtl('cc').text.trim()]
          .where((x) => x.isNotEmpty)
          .join(', '),
      done: _qCc.isNotEmpty || _regCtl('cc').text.trim().isNotEmpty,
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ชิปกว้างตามชื่อ เรียงต่อกัน (วิกฤตก่อน ขอบแดง) ไม่แยกหัวข้อ ประหยัดที่
          Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            for (final o in _qCcOpts) _qCcTile(o.$1, o.$2),
          ]),
          const SizedBox(height: 8.0),
          // อุบัติเหตุ: ถามต่อว่าเป็นอุบัติเหตุหมู่ไหม (MCI ใช้ขั้นตอนต่างออกไป)
          if (_qCc.contains('อุบัติเหตุรุนแรง')) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(12.0, 10.0, 10.0, 10.0),
              margin: const EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                color:
                    _qMci == true ? _red.withValues(alpha: 0.06) : _panelSoft,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                    color: _qMci == true
                        ? _red.withValues(alpha: 0.4)
                        : _red.withValues(alpha: 0.0)),
              ),
              child: Row(children: [
                Icon(Icons.groups_rounded,
                    size: 18.0, color: _qMci == true ? _red : _ink2),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text('เป็นอุบัติเหตุหมู่ (MCI) ไหม',
                      style:
                          _t(12.5, color: _inkTitle, weight: FontWeight.w600)),
                ),
                for (final (l, v) in const [('ไม่ใช่', false), ('ใช่', true)])
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: _Press(
                        radius: 100.0,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _qMci = v);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: _qMci == v ? (v ? _red : _blue) : _panel,
                              borderRadius: BorderRadius.circular(100.0),
                              border: Border.all(
                                  color:
                                      _qMci == v ? (v ? _red : _blue) : _line),
                            ),
                            child: Text(l,
                                style: _t(12.0,
                                    color: _qMci == v ? Colors.white : _ink2,
                                    weight: FontWeight.w600)),
                          ),
                        )),
                  ),
              ]),
            ),
          ],
          TextField(
            controller: _regCtl('cc'),
            maxLength: 200,
            onChanged: (_) => setState(() {}),
            style: _t(15.0, color: _inkTitle, weight: FontWeight.w500),
            decoration: _qFloat('อาการเพิ่มเติม (ถ้ามี)',
                    helper: 'พิมพ์อาการที่ไม่มีในรายการด้านบน')
                .copyWith(counterText: ''),
          ),
          const SizedBox(height: 8.0),
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
      color: _panel,
      child: Column(children: [
        Container(
          height: 58.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: const BoxDecoration(
            color: _panel,
            border: Border(bottom: BorderSide(color: _line)),
          ),
          // ซ้าย: กลับ + โปรไฟล์ผู้ป่วย · ขวา: ทางลัดระบุตัวตน
          child: Stack(alignment: Alignment.center, children: [
            Row(children: [
              _topIcon(Icons.arrow_back_rounded, false, _closeRegister),
              const SizedBox(width: 12.0),
              // โปรไฟล์ผู้ป่วยใช้พื้นที่ที่เหลือทั้งหมด
              Expanded(child: _qProfileHeader()),
              const SizedBox(width: 12.0),
              // ปุ่มหลักขวาบน (แคปซูลกรมท่า): ยืนยัน ESI และส่งต่อ / ส่งเข้าคิวคัดกรอง
              _Press(
                radius: 100.0,
                child: GestureDetector(
                  onTap: _regReady ? () => _qSend(esi: level) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 40.0,
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _regReady ? _blue : _line,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                          level == null
                              ? 'ส่งเข้าคิวคัดกรอง'
                              : 'ยืนยัน ESI $level และส่งต่อ',
                          style: _t(13.5,
                              color: _regReady ? Colors.white : _ink3,
                              weight: FontWeight.w700)),
                      const SizedBox(width: 6.0),
                      Icon(Icons.arrow_forward_rounded,
                          size: 18.0, color: _regReady ? Colors.white : _ink3),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
            ]),
          ]),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: const BoxDecoration(color: _panel),
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
              child: KeyedSubtree(
                key: const ValueKey('form'),
                child: Padding(
                  padding: EdgeInsets.only(bottom: kb),
                  // Figma 356-178: แท็บแนวตั้งซ้าย + แผงเนื้อหาเดียว
                  child: _qTabsBody(
                      who,
                      cc,
                      arrive,
                      left,
                      informant,
                      _triEsiPanel(sug, why, level,
                          // ปุ่มส่งหลักอยู่ขวาบนแล้ว ในแผงเหลือแค่ RESUS
                          footer: _qNormal ? const SizedBox.shrink() : resus)),
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
                      _srBox = (2.0, -10.0, 116.0);
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

/// mask เบอร์โทรไทย: 081-234-5678 (มือถือ) 02-123-4567 (กทม.) 053-123-456 (ภูมิภาค)
class _PhoneMask extends TextInputFormatter {
  static int lenOf(String d) => d.length >= 2 && '689'.contains(d[1]) ? 10 : 9;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var d = newValue.text.replaceAll(RegExp(r'\D'), '');
    final old = oldValue.text.replaceAll(RegExp(r'\D'), '');
    // ลบโดนขีด: ตัวเลขเท่าเดิม → ลบตัวเลขก่อนขีดไปด้วย
    if (newValue.text.length < oldValue.text.length &&
        d == old &&
        d.isNotEmpty) {
      d = d.substring(0, d.length - 1);
    }
    if (d.isNotEmpty && d[0] != '0') d = '0$d';
    // หลักที่ 2 ต้องเป็น 2-9 (ไม่มีเบอร์ 00x / 01x)
    if (d.length >= 2 && '01'.contains(d[1])) d = d.substring(0, 1);
    if (d.length > lenOf(d)) d = d.substring(0, lenOf(d));
    final cuts = d.length <= 2 || lenOf(d) == 10
        ? [3, 6]
        : d.startsWith('02')
            ? [2, 5]
            : [3, 6];
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (cuts.contains(i)) b.write('-');
      b.write(d[i]);
    }
    final t = b.toString();
    return TextEditingValue(
        text: t, selection: TextSelection.collapsed(offset: t.length));
  }
}
