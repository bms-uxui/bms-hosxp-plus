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

  /// อาการสำคัญจากคำเล่า (knowledge ข้อ 78): ตัวเลือกที่ระบบเลือกให้ ('type:…' 'cc:…' 'pain:…')
  /// _qCcNo = ที่ผู้ใช้เอาออกเองแล้ว ไม่เลือกให้ซ้ำ · _qCcAiDone = ข้อความล่าสุดที่ส่งให้ AI แล้ว
  final Set<String> _qCcAuto = {};

  /// เวลาที่ AI เติมแต่ละช่อง ('type:…' 'pain:…') ให้ช่องนั้นเรืองแสงแวบหนึ่ง (_QAiGlow)
  final Map<String, DateTime> _qCcGlowAt = {};

  /// เวลาล่าสุดที่ AI เติมช่องในกลุ่ม [prefixes] (เช่น 'vs:' 'gcs:') ให้การ์ดนั้นเรืองแสง
  DateTime? _qGlowOf(List<String> prefixes) {
    DateTime? at;
    for (final e in _qCcGlowAt.entries) {
      if (prefixes.any(e.key.startsWith) &&
          (at == null || e.value.isAfter(at))) {
        at = e.value;
      }
    }
    return at;
  }

  final Set<String> _qCcNo = {};
  Timer? _qCcTimer;
  String _qCcAiDone = '';
  bool _qCcAiBusy = false;
  ErSpeechInput? _qCcSp;

  /// แผ่นสติกเกอร์อาการ (แตะ "+ เพิ่มอาการ" ในโน้ต) เปิดอยู่
  bool _qCcTray = false;

  /// โหมดพิมพ์คำเล่า (ปุ่มกลมคีย์บอร์ดในการ์ดอาการสำคัญ)
  bool _qCcTyping = false;
  String _qInformant = 'ผู้ป่วยเอง';
  bool _qFound = false;

  /// น้ำหนัก ส่วนสูง จาก visit ล่าสุดใน HOSxP (kg, cm, วันที่) · null = ไม่มีประวัติ
  (double, double, DateTime)? _qLastWt;

  /// กำลังอ่านบัตร (เล่นเส้นสแกนบนบัตรจำลอง)
  bool _qReading = false;

  /// หน้าจออ่านบัตร (การ์ดใหญ่กลางจอ) เปิดอยู่ · แยกจาก [_qReading] ที่เป็นสถานะ "กำลังทำงาน" ของปุ่มอื่น
  /// (ถ่ายภาพบัตร · บัตรในหน้าคัดกรอง) ไม่ให้กดถ่ายภาพบัตรแล้วไปเปิดหน้าจออ่านบัตร
  bool _qRdView = false;

  /// หน้าค้นหาผู้ป่วยด้วย HN (การ์ดใหญ่กลางจอ ขยายจากการ์ด "ค้นหาโดย HN")
  bool _qHnView = false;

  /// หน้าถ่ายภาพบัตร (การ์ดใหญ่ ขยายจากการ์ด "ถ่ายภาพบัตรประชาชน"): ช่องกล้อง + กรอบบัตรให้เล็ง
  /// [_qCamStage] 0 เล็ง · 1 ถ่ายแล้ว กำลังอ่านข้อมูลจากภาพ · 2 ผลสแกนใบหน้า (ในการ์ด)
  /// · 3 ไม่มีในรายชื่อ = เลือกวิธีลงทะเบียนผู้ป่วยใหม่ (ในการ์ด)
  bool _qCamOn = false;
  int _qCamStage = 0;

  /// ภาพที่ถ่ายจากหน้ากล้อง · '' = เครื่องไม่มีกล้อง (ภาพจำลอง)
  String? _qCamShot;

  /// การ์ดกล้องใบเดียวกันใช้ 2 แบบ: false = ถ่ายภาพบัตร · true = สแกนใบหน้า (กรอบวงรี กล้องหน้า)
  bool _qCamFace = false;

  /// สแกนใบหน้า ขั้น 2 (ผล): ผู้ป่วยที่หน้าคล้าย (HN, ความคล้าย) · [_qFaceSel] = รายที่เลือก (เริ่ม = คล้ายที่สุด)
  List<(String, double)> _qFaceHits = const [];
  int _qFaceSel = 0;

  /// ขั้นตอนอ่านบัตรจำลอง (เต็มจอ): 0 ค้นหาเครื่อง · 1 พบบัตร · 2 อ่านชิป · 3 ค้นประวัติ HOSxP · 4 เสร็จ
  int _qRdStep = -1;
  double _qRdPct = 0.0; // ความคืบหน้าอ่านชิป 0–1
  String _qRdItem = ''; // ส่วนที่กำลังอ่าน (ข้อมูลส่วนตัว ที่อยู่ รูปถ่าย)
  bool _qRdNoDev = false; // ไม่พบเครื่องอ่านบัตร
  int _qRdRun = 0; // รอบการอ่าน (กดยกเลิก = รอบเก่าหยุดเอง)
  bool _qRdOnline =
      true; // สถานะเครื่องอ่านบัตรล่าสุด (การ์ดซ้อนบนช่องอ่านบัตร)
  bool _qRdDemoNoDev =
      false; // สาธิต: เปิดจากการกดค้าง = กดเริ่มอ่านแล้วไม่พบเครื่อง

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

  /// ตำแหน่ง bottom sheet เลือกค่า V/S: left / center / right (จำใน prefs)
  String _wheelAlign = 'center';
  bool _wheelAlignLoaded = false;

  bool _triOcrBusy = false;
  // เวลาที่วัดสัญญาณชีพ: จับตอนกรอกค่าแรก (ไม่ใช่เวลาปัจจุบัน)
  DateTime? _triVsAt;

  /// กลุ่มอายุสำหรับ V/S dangerous zone (null = ยังไม่ได้เลือก)
  String? _triBand;
  int? _triPain;

  /// ข้อที่ติ๊กในขั้น "จะเสียชีวิต" และ "เสี่ยง ซึม ปวด"
  final Set<String> _triRisk = {};

  /// Red flag ที่พยาบาลติ๊ก ('โรค:เกณฑ์') และเวลา LKW ของ Stroke
  final Set<String> _triRed = {};
  TimeOfDay? _triLkw;

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

  /// การ์ด _qCard วางในพื้นที่แคบ (แผง workflow): หัวซ้อนบรรทัด ระยะขอบน้อยลง
  bool _qCardNarrow = false;

  /// การ์ด V/S แบบแถวรายการเรียบ (ชื่อซ้าย ค่าขวา ›) ไม่มีไอคอน ไม่มีน้ำหนัก/ส่วนสูง (กิจกรรมสังเกตอาการ)
  bool _qVsPlain = false;

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
  // ปรับขนาดรูม่านตาสองข้างพร้อมกัน (ส่วนใหญ่เท่ากัน) · ปิด = ปรับแยกข้าง
  bool _triPupilLink = true;
  // ตาที่กำลังเลื่อน slider ('R'/'L') กล้องซูมเข้าตานั้น · ปล่อยนิ้วแล้วถอยกลับ
  String? _triPupilFocus;
  Timer? _triPupilFocusT;
  String? _triLoc;

  /// ประเภทผู้ป่วย (เลือกได้หลายอย่าง) เช่น Trauma, Stroke, Sepsis
  final Set<String> _triType = {};

  /// แพทย์เวรที่พยาบาลคัดกรอง assign ให้เคสนี้ (เลือกได้หลายคน · พยาบาล ER เปลี่ยนต่อได้)
  final List<String> _triDoctors = [];

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

  /// พยาบาลคัดกรอง: login แล้วเข้าหน้าส่งตรวจ/คัดกรอง (ระบุตัวตนผู้ป่วย) ทันที
  void _triageLanding() {
    if (ErSession.instance.isTriage && !_regOpen) _openQuickRegister();
  }

  /// พยาบาลคัดกรองนอกหน้าส่งตรวจ/คัดกรอง = ดูอย่างเดียว (เปิดแผ่นแก้ไข/เมนูขั้นงานไม่ได้)
  bool get _viewOnly => ErSession.instance.isTriage && !_regOpen;

  /// แตะสิ่งที่แก้ไขได้ตอนดูอย่างเดียว = บอกสั้น ๆ แทนการเปิดแผ่น
  void _viewOnlyNotice() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('พยาบาลคัดกรองดูข้อมูลได้อย่างเดียว',
              style: _t(13.0, color: Colors.white))));
  }

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

  /// เลือกสภาพผู้ป่วยตอนมาถึง แล้วเติมฟอร์มที่เกี่ยวข้องให้ (แก้ทีหลังได้) · knowledge ข้อ 0
  /// เดินมา = มาเอง/มาเอง/ผู้ป่วยเอง · อุ้มมา = มาเอง/ญาติ/ญาติ · รถนั่ง = ประเภทการมามาเอง
  /// เปลนอน = ไม่เดา (ต้องเลือกระดับหน่วยกู้ชีพเอง) · ญาติมาแทน = ผู้นำส่งญาติ ผู้แจ้งข้อมูลญาติ
  void _qSetArrive(String l) {
    setState(() {
      _qArrive = l;
      switch (l) {
        case 'เดินมา':
          _qArrType = 'มาเอง';
          _qBringer = 'มาเอง';
          _qInformant = 'ผู้ป่วยเอง';
        case 'อุ้มมา':
          _qArrType = 'มาเอง';
          _qBringer = 'ญาติ';
          _qInformant = 'ญาติ';
        case 'รถนั่ง':
          _qArrType = 'มาเอง';
        case 'ญาติมาแทน':
          _qBringer = 'ญาติ';
          _qInformant = 'ญาติ';
      }
    });
  }

  /// HN ใหม่ของผู้ป่วยใหม่: ปี พ.ศ. 2 หลัก + ลำดับ 6 หลัก (mock)
  String _regNewHn() {
    final now = DateTime.now();
    return '${(now.year + 543) % 100}'
        '${(now.millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}';
  }

  /// เปิดลงทะเบียนด่วน (ขั้นคัดกรอง)
  void _openQuickRegister() {
    _openRegister();
    setState(() {
      _regQuick = true;
      _qIntro = true;
      _qReading = false;
      _qRdView = false;
      _qHnView = false;
      _qCamOn = false;
      _mci.on = false;
      _qRdStep = -1;
      _qRdRun++;
      _qNew = false;
      _qArrive = 'เดินมา';
      _qCc.clear();
      _qCcAuto.clear();
      _qCcNo.clear();
      _qCcAiDone = '';
      _qInformant = 'ผู้ป่วยเอง';
      _qFound = false;
      _qLastWt = null;
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
    // ปิดหน้าพิมพ์ที่ค้าง แล้วคืนที่วางหน้าพิมพ์ให้แผง workflow
    _wfTextClose(null);
    _ftInPage = false;
    _ftPageRebuild = null;
    setState(() {
      _regOpen = false;
      _regQuick = false;
      _triP = null;
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
    unawaited(Posthog().capture(
      eventName: 'patient_registered',
      properties: {'registration_type': 'standard'},
    ).catchError((_) {}));
    try {
      Posthog().logger.info(
        'ER patient registration completed',
        {'registration_type': 'standard'},
      );
    } catch (_) {}
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
          // พิมพ์ในช่องเลย ไม่เปิดหน้าย่อย (ผู้ใช้ 2026-11-27 "เก็บกวาดให้หมด")
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
              border: Border.all(color: _line, width: 0.5),
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
        border: Border.all(color: _line, width: 0.5),
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
            border: Border.all(
                color: on ? _red.withValues(alpha: 0.4) : _line,
                width: on ? 1.0 : 0.5),
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
                child: Icon(Icons.close_rounded, size: 15.0, color: _red),
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
                      border: Border.all(color: _line, width: 0.5),
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
            // แตะ = แผ่นพิมพ์ชื่อยาที่แพ้ · ส่ง = เพิ่มเป็นรายการ
            readOnly: true,
            showCursor: false,
            onTap: () async {
              final v = await _ftOpen(context,
                  title: 'เพิ่มประวัติแพ้ยา', hint: 'พิมพ์ชื่อยาที่แพ้');
              if (v == null || v.isEmpty || !mounted) return;
              _regAddAllergy(v);
              _regCtl('allergy').clear();
            },
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
                  Text('ส่งตรวจและคัดกรองผู้ป่วย',
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
              Text('ส่งตรวจและคัดกรองผู้ป่วย',
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

/// อาการสำคัญแบบแตะเลือก: (อาการ, อาการวิกฤต = อยู่กลุ่มวิกฤต)
/// ข้อความป้ายการ์ดอาการสำคัญ: ปกติ · กำลังฟัง · กำลังถอดเสียง (แท็บแฟ้มกว้างตามข้อความที่ยาวสุด)
/// รอยเว้าปุ่มหลักการ์ดอาการสำคัญ: ปุ่มสูง 44 + ระยะห่าง 8
const double _qCcNotchH = 52.0;

const List<String> _qCcTagLabels = [
  'AI ช่วยวิเคราะห์',
  'กำลังฟังอยู่...',
  'กำลังถอดเสียง...'
];

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
];

/// คำในคำเล่าอาการสำคัญ → ตัวเลือกที่เลือกให้เอง (knowledge ข้อ 78) · 'type:' ประเภทผู้ป่วย · 'cc:' ชิปอาการ
/// คำกว้างที่เตือนเกินจริงไม่ใส่ (เช่น "อ่อนแรง" เฉย ๆ = อ่อนเพลียทั่วไป) · ตามหลัง ไม่/ไม่มี/ไม่ได้/ปฏิเสธ = ไม่นับ
const List<(List<String>, List<String>)> _qCcRules = [
  (
    [
      'รถชน',
      'ชนกัน',
      'ชนเสา',
      'ชนท้าย',
      'ชนประสานงา',
      'ถูกรถชน',
      'รถล้ม',
      'รถคว่ำ',
      'พลิกคว่ำ',
      'มอเตอร์ไซค์',
      'จักรยานยนต์',
      'mva',
      'mca',
      'ตกจากที่สูง',
      'ตกจากหลังคา',
      'ตกจากชั้น',
      'ตกจากนั่งร้าน',
      'ตกบันได',
      'ตกต้นไม้',
      'ตกตึก',
      'ถูกแทง',
      'มีดแทง',
      'โดนแทง',
      'ถูกยิง',
      'โดนยิง',
      'ถูกทำร้าย'
    ],
    ['type:อุบัติเหตุ', 'cc:อุบัติเหตุรุนแรง']
  ),
  (
    [
      'หกล้ม',
      'ลื่นล้ม',
      'บาดเจ็บ',
      'แผล',
      'ฉีกขาด',
      'ถลอก',
      'กระดูกหัก',
      'ข้อเท้าพลิก',
      'ไฟไหม้',
      'ไหม้',
      'น้ำร้อนลวก',
      'ไฟฟ้าช็อต',
      'ไฟช็อต',
      'ไฟดูด',
      'มีดบาด',
      'โดนมีด',
      'ถูกแทง',
      'มีดแทง',
      'โดนแทง',
      'สุนัขกัด',
      'หมากัด',
      'แมวกัด',
      'ถูกตี',
      'โดนตี',
      'ทะเลาะวิวาท'
    ],
    ['type:อุบัติเหตุ', 'cc:แผล/บาดเจ็บ']
  ),
  (
    [
      'งูกัด',
      'งูเห่า',
      'งูเขียว',
      'แมงป่อง',
      'ตะขาบ',
      'ผึ้งต่อย',
      'ต่อต่อย',
      'แตนต่อย'
    ],
    ['type:อุบัติเหตุ', 'cc:สัตว์มีพิษกัด']
  ),
  (
    [
      'หมดสติ',
      'ไม่รู้สึกตัว',
      'เรียกไม่ตื่น',
      'ปลุกไม่ตื่น',
      'ปลุกตื่นยาก',
      'ไม่ตอบสนอง',
      'ซึมลง',
      'เป็นลม',
      'unconscious'
    ],
    ['type:ฉุกเฉิน', 'cc:หมดสติ']
  ),
  (
    ['เจ็บหน้าอก', 'แน่นหน้าอก', 'เจ็บอก', 'แน่นอก', 'จุกอก', 'chestpain'],
    ['type:ฉุกเฉิน', 'cc:เจ็บหน้าอก']
  ),
  (
    [
      'หายใจไม่ออก',
      'หายใจไม่อิ่ม',
      'หอบ',
      'หายใจลำบาก',
      'เหนื่อยหอบ',
      'dyspnea',
      'sob'
    ],
    ['type:ฉุกเฉิน', 'cc:หายใจไม่ออก']
  ),
  (
    [
      'แขนขาอ่อนแรง',
      'แขนอ่อนแรง',
      'ขาอ่อนแรง',
      'อ่อนแรงครึ่งซีก',
      'อ่อนแรงซีก',
      'ซีกขวาอ่อนแรง',
      'ซีกซ้ายอ่อนแรง',
      'ชาครึ่งซีก',
      'ชาซีก',
      'ปากเบี้ยว',
      'หน้าเบี้ยว',
      'มุมปากตก',
      'พูดไม่ชัด',
      'stroke'
    ],
    ['type:ฉุกเฉิน', 'cc:แขนขาอ่อนแรง']
  ),
  (['ชัก', 'seizure'], ['type:ฉุกเฉิน', 'cc:ชัก']),
  (
    [
      'เลือดออกมาก',
      'ไหลไม่หยุด',
      'ออกไม่หยุด',
      'ตกเลือด',
      'อาเจียนเป็นเลือด',
      'ถ่ายเป็นเลือด',
      'ไอเป็นเลือด',
      'ถ่ายดำ'
    ],
    ['type:ฉุกเฉิน', 'cc:เลือดออกมาก']
  ),
  // ภาวะฉุกเฉินที่ไม่มีชิปอาการ: เลือกประเภทอย่างเดียว
  (
    [
      'กินยาเกินขนาด',
      'ยาเกินขนาด',
      'overdose',
      'ยาฆ่าหญ้า',
      'ยาฆ่าแมลง',
      'ยาเบื่อ',
      'กินสารพิษ',
      'น้ำตาลต่ำ',
      'hypoglycemia'
    ],
    ['type:ฉุกเฉิน']
  ),
  (['ไข้', 'ตัวร้อน', 'หนาวสั่น', 'fever'], ['cc:ไข้']),
  (['ปวดท้อง', 'ท้องเสีย', 'จุกท้อง', 'ปวดบิด'], ['cc:ปวดท้อง']),
  (
    ['เวียนหัว', 'เวียนศีรษะ', 'บ้านหมุน', 'มึน', 'เดินเซ', 'dizzy'],
    ['cc:เวียนศีรษะ']
  ),
  (['ปวดหัว', 'ปวดศีรษะ', 'headache'], ['cc:ปวดศีรษะ']),
  (
    ['แพ้ยา', 'แพ้อาหาร', 'ผื่นขึ้น', 'ผื่นคัน', 'ลมพิษ', 'ปากบวม', 'ตาบวม'],
    ['cc:แพ้ยา/แพ้อาหาร']
  ),
];

/// คำประสมที่มีคำค้นอยู่ข้างในแต่ความหมายอื่น = ไม่นับ (พบจากชุดทดสอบความครอบคลุม)
/// คำเล่า → GCS (knowledge ข้อ 78): วลีที่บอกระดับชัด · ลำดับในแต่ละองค์ประกอบ = ค่าแรกที่เจอชนะ
const List<(String, List<String>)> _qGcsRules = [
  ('E1', ['ไม่ลืมตา', 'ไม่ลืมเลย']),
  ('E2', ['ลืมตาเมื่อเจ็บ', 'ลืมเมื่อเจ็บ']),
  ('E3', ['ลืมตาเมื่อเรียก', 'เรียกแล้วลืมตา']),
  ('E4', ['ลืมตาเอง', 'ลืมตาได้เอง']),
  ('V1', ['ไม่ส่งเสียง', 'ไม่ออกเสียง', 'ไม่มีเสียง', 'ไม่พูดเลย']),
  ('V2', ['ส่งเสียงไม่เป็นคำ', 'ร้องคราง', 'ครางอือ']),
  ('V3', ['พูดเป็นคำๆ', 'พูดเป็นคำ', 'พูดไม่เป็นประโยค']),
  ('V4', ['พูดสับสน', 'ตอบสับสน']),
  ('V5', ['พูดคุยรู้เรื่อง', 'พูดรู้เรื่อง']),
  ('M6', ['ทำตามคำสั่งได้', 'ทำตามสั่งได้']),
  ('M5', ['ปัดจุดเจ็บ', 'ปัดมือ', 'รู้ตำแหน่งเจ็บ']),
  ('M4', ['ชักแขนหนี', 'ชักขาหนี', 'ดึงแขนหนี']),
  ('M3', ['เกร็งงอ']),
  ('M2', ['เกร็งเหยียด']),
  ('M1', ['ไม่ขยับ', 'ไม่เคลื่อนไหว']),
];

/// คำเล่า → ระดับความรู้สึกตัว (หนักสุดก่อน) · "ซับสน" = พิมพ์ผิดที่เจอบ่อย
const List<(String, List<String>)> _qLocRules = [
  ('ไม่รู้สึกตัว', ['ไม่รู้สึกตัว', 'หมดสติ']),
  ('ซึมมาก', ['ซึมมาก', 'ปลุกไม่ตื่น']),
  ('ซึม', ['ซึม']),
  ('สับสน', ['สับสน', 'ซับสน']),
  ('ตื่นดี', ['ตื่นดี', 'รู้ตัวดี', 'รู้สึกตัวดี']),
];

const Map<String, List<String>> _qCcSkip = {
  'ไข้': ['คนไข้'],
  'แผล': ['แผลผ่าตัด', 'แผลกดทับ', 'แผลเบาหวาน', 'แผลเรื้อรัง'],
  'มึน': ['มึนเมา'],
  'หอบ': ['หอบของ', 'หอบหิ้ว'],
};

/// นาฬิกาเรื่องเล่าของภาพ hero: ทุกชั้นอ่านเวลาเดียวกัน · เริ่มนับใหม่เมื่อการ์ดขึ้น
final Stopwatch _qGearClock = Stopwatch()..start();
int _qStoryStart = 0;

/// ภาพ hero การ์ดอาการสำคัญ: ดาว ER เป็นประตูมิติจริง (ผู้ใช้ 2026-11-27 "shape ต้องทำหน้าที่เป็น portal จริง")
/// กรอบรูปดาวมีความหนา (ดาวแห่งชีวิต = แท่งมุมมน 3 แท่งไขว้ 60°) ข้างในทั้งรูปดาวเป็นช่องเปิด
/// มองทะลุเข้าไปเป็นอุโมงค์รูปดาวลึก ผนังด้านในไล่แสง ปลายอุโมงค์สว่าง · หมุนในอวกาศแล้วฉายแบบ perspective
/// เรื่อง (วนทุก 10 วินาที): 1 ปุ่มไมค์ลอยมาจากก้นอุโมงค์ ทะลุกรอบออกมา ถูกกด (ยุบ เปลี่ยนเป็นเปิด) แล้วเลื่อนไปซ้ายล่าง
/// 2 ฟองผู้ป่วยออกมา คลื่นเสียงขยับตอนเล่า 3 ฟอง AI ออกมา จุดสามจุดเด้ง (วิเคราะห์) แล้วขึ้นประกาย + บรรทัดผล
/// 4 ทุกชิ้นถอยกลับเข้าอุโมงค์ · ชิ้นที่ยังอยู่ข้างในเห็นได้แค่ผ่านช่องรูปดาว ตอนทะลุกรอบเผยจากบนลงล่าง
/// (แบบตัวละครหัวโผล่พ้นวงในหน้าภาพรวม) · ลอยหน้ากรอบแล้วมีเงาตกบนขอบกรอบ
/// มีคำเล่าแล้ว/ปิดแอนิเมชันในเครื่อง = ภาพนิ่งขั้นได้ผล · กำลังฟังจริง = ไมค์เปิด + คลื่นฟองผู้ป่วยตามเสียงไมค์
/// 4 ชั้น (แทรกแผงการ์ดได้): 0 เงากรอบบนฉาก · 1 ในอุโมงค์ · 3 กรอบ · 2 ชิ้นที่ออกมา + เงา + ประกาย (เหนือแผง)
class _QVoiceGear extends StatefulWidget {
  const _QVoiceGear(
      {required this.layer,
      required this.play,
      this.listening = false,
      this.floor = 1e4});
  final int layer;
  final bool play;
  final bool listening;

  /// ขอบบนของแผงการ์ด (พิกัดในกล่องภาพ) · ชั้น 2 วาดเหนือแผง จึงไม่ระบายเลยเส้นนี้ในช่องประตู
  final double floor;
  @override
  State<_QVoiceGear> createState() => _QVoiceGearState();
}

class _QVoiceGearState extends State<_QVoiceGear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tick =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  bool _still = true;

  void _sync() {
    _still = !(widget.play || widget.listening) ||
        MediaQuery.of(context).disableAnimations;
    if (_still || widget.layer != 2) {
      _tick.stop();
    } else if (!_tick.isAnimating) {
      _tick.repeat();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.layer == 2) _qStoryStart = _qGearClock.elapsedMilliseconds;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _QVoiceGear old) {
    super.didUpdateWidget(old);
    if (old.play != widget.play || old.listening != widget.listening) _sync();
  }

  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: widget.layer != 2
              // เงา อุโมงค์ กรอบ นิ่ง: วาดครั้งเดียว
              ? CustomPaint(
                  painter: _QVoiceGearPainter(
                      layer: widget.layer, t: 0.0, still: true, level: -1.0))
              : AnimatedBuilder(
                  animation: _tick,
                  builder: (context, _) => CustomPaint(
                    painter: _QVoiceGearPainter(
                      layer: 2,
                      t: (_qGearClock.elapsedMilliseconds - _qStoryStart) /
                          1000.0,
                      still: _still && !widget.listening,
                      level: widget.listening ? erMicLevel.value : -1.0,
                      floor: widget.floor,
                    ),
                  ),
                ),
        ),
      );
}

/// ไอคอนสีของแอป (ผู้ใช้ 2026-11-27 "สีไอคอนของเรานะ"): Material มน สองโทนกรมท่าแบ่งแนวทแยง
/// ซ้ายบนสว่าง #5A69B4 · ขวาล่างเข้ม #2B3F96 (สูตรเดียวกับ _McGIcon ในเมนูใบรับรองแพทย์ ไม่มีกรอบวง)
class _QDuoIcon extends StatelessWidget {
  const _QDuoIcon(this.icon, {this.size = 24.0});
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue3, _blue3, _blue2, _blue2],
          stops: [0.0, 0.5, 0.5, 1.0],
        ).createShader(r),
        child: Icon(icon, size: size, color: Colors.white),
      );
}

/// แผงขาวยกลอยในการ์ดอาการสำคัญ: มุมโค้ง 20 · มุมขวาล่างเว้า [bw]×[bh] ร่วมศูนย์กับรอยเว้าของการ์ด
/// (แผงอยู่ห่างขอบการ์ด 12 → มุมนูนปากรอยเว้า 10 · มุมเว้าด้านใน = รอยเว้าสูง − 10) · เงาขึ้นด้านบน + ขอบดำ 7%
class _QNotchPanelPaint extends CustomPainter {
  const _QNotchPanelPaint(this.bw, this.bh);
  final double bw, bh;

  Path _path(Size s) {
    const r = 20.0, rr = 10.0;
    final w = s.width, h = s.height;
    final p = Path()
      ..moveTo(0.0, r)
      ..arcToPoint(const Offset(r, 0.0), radius: const Radius.circular(r))
      ..lineTo(w - r, 0.0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(r));
    if (bw > 4.0 && bh > 4.0) {
      final x = w - bw, y = h - bh, qc = bh - rr;
      p
        ..lineTo(w, y - rr)
        ..arcToPoint(Offset(w - rr, y), radius: const Radius.circular(rr))
        ..lineTo(x + qc, y)
        ..arcToPoint(Offset(x, y + qc),
            radius: Radius.circular(qc), clockwise: false)
        ..lineTo(x, h - rr)
        ..arcToPoint(Offset(x - rr, h), radius: const Radius.circular(rr));
    } else {
      p
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r));
    }
    return p
      ..lineTo(r, h)
      ..arcToPoint(Offset(0.0, h - r), radius: const Radius.circular(r))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = _path(size);
    canvas.drawPath(
        p.shift(const Offset(0.0, -6.0)),
        Paint()
          ..color = const Color(0x14000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14.0));
    canvas.drawPath(p, Paint()..color = Colors.white);
    canvas.drawPath(
        p,
        Paint()
          ..color = const Color(0x12000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant _QNotchPanelPaint old) =>
      old.bw != bw || old.bh != bh;
}

/// พื้นการ์ดรูปแฟ้มแบบวาด (ไม่ตัดลูก): ขาว + เส้นขอบดำ 10% ตามรูปแฟ้มของแอป (_qFolderPath)
class _QFolderFill extends CustomPainter {
  const _QFolderFill(this.tab, this.bw, this.bh, {this.edge = true});
  final double tab, bw, bh;
  final bool edge;
  @override
  void paint(Canvas canvas, Size size) {
    final p = _qFolderPath(size, tab, bw: bw, bh: bh);
    canvas.drawPath(p, Paint()..color = _panel);
    if (edge) {
      canvas.drawPath(
          p,
          Paint()
            ..color = const Color(0x1A000000)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0);
    }
  }

  @override
  bool shouldRepaint(covariant _QFolderFill o) =>
      o.tab != tab || o.bw != bw || o.bh != bh || o.edge != edge;
}

/// การ์ดซ้อนเว้ามุมขวาล่าง (การ์ดพิมพ์คำเล่า): ขาว ขอบ 0.5 #DADCE0 ไม่มีเงา · มุมโค้ง 14
/// ห่างขอบการ์ดนอก 8 → มุมนูนปากรอยเว้า 14 (22 − 8) · มุมเว้าด้านใน = รอยเว้าสูง − 14 (ร่วมศูนย์กับปุ่ม)
class _QNotchNestPaint extends CustomPainter {
  const _QNotchNestPaint(this.bw, this.bh);
  final double bw, bh;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 14.0, rr = 14.0;
    final w = size.width, h = size.height;
    final x = w - bw, y = h - bh, qc = bh - rr;
    final p = Path()
      ..moveTo(0.0, r)
      ..arcToPoint(const Offset(r, 0.0), radius: const Radius.circular(r))
      ..lineTo(w - r, 0.0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
      ..lineTo(w, y - rr)
      ..arcToPoint(Offset(w - rr, y), radius: const Radius.circular(rr))
      ..lineTo(x + qc, y)
      ..arcToPoint(Offset(x, y + qc),
          radius: Radius.circular(qc), clockwise: false)
      ..lineTo(x, h - rr)
      ..arcToPoint(Offset(x - rr, h), radius: const Radius.circular(rr))
      ..lineTo(r, h)
      ..arcToPoint(Offset(0.0, h - r), radius: const Radius.circular(r))
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white);
    canvas.drawPath(
        p,
        Paint()
          ..color = const Color(0xFFDADCE0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5);
  }

  @override
  bool shouldRepaint(covariant _QNotchNestPaint old) =>
      old.bw != bw || old.bh != bh;
}

/// เรืองแสงสี AI รอบช่องที่ AI เพิ่งเติมให้ (ผู้ใช้ 2026-11-27 เลือก "ช่องที่ถูกเติมเรืองแสง"):
/// ขอบไล่สีฟ้า ม่วง ชมพูหมุนรอบช่อง + แสงฟุ้ง จางเข้า ค้าง แล้วจางออกใน 1.8 วินาที · เล่นครั้งเดียวต่อเวลาที่เติม
/// [at] = เวลาที่ AI เติมช่องนี้ (null/เก่ากว่า 2 วินาที = ไม่เล่น) · [inset] = ระยะที่หักออก (เช่น margin ใต้การ์ด)
class _QAiGlow extends StatefulWidget {
  const _QAiGlow(
      {required this.at,
      required this.child,
      this.radius = 8.0,
      this.inset = EdgeInsets.zero});
  final DateTime? at;
  final Widget child;
  final double radius;
  final EdgeInsets inset;
  @override
  State<_QAiGlow> createState() => _QAiGlowState();
}

class _QAiGlowState extends State<_QAiGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800));
  DateTime? _played;

  void _maybePlay() {
    final at = widget.at;
    if (at == null || at == _played) return;
    if (DateTime.now().difference(at).inMilliseconds > 2000) return;
    _played = at;
    _c.forward(from: 0.0);
  }

  @override
  void initState() {
    super.initState();
    _maybePlay();
  }

  @override
  void didUpdateWidget(covariant _QAiGlow old) {
    super.didUpdateWidget(old);
    _maybePlay();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          Positioned.fill(
            child: Padding(
              padding: widget.inset,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => _c.value <= 0.0 || _c.value >= 1.0
                      ? const SizedBox()
                      : CustomPaint(
                          painter: _QAiGlowPainter(_c.value, widget.radius)),
                ),
              ),
            ),
          ),
        ],
      );
}

class _QAiGlowPainter extends CustomPainter {
  const _QAiGlowPainter(this.t, this.radius);
  final double t, radius;

  @override
  void paint(Canvas canvas, Size size) {
    double ss(double a, double b, double x) {
      final k = ((x - a) / (b - a)).clamp(0.0, 1.0);
      return k * k * (3.0 - 2.0 * k);
    }

    final a = ss(0.0, 0.15, t) * (1.0 - ss(0.55, 1.0, t));
    if (a <= 0.0) return;
    final rr = RRect.fromRectAndRadius(
        (Offset.zero & size).inflate(1.5), Radius.circular(radius + 1.5));
    final shader = SweepGradient(
      transform: GradientRotation(t * math.pi * 2.0),
      colors: const [
        Color(0xFF4C8DF6),
        Color(0xFF8E6CF0),
        Color(0xFFEC6FA9),
        Color(0xFF4C8DF6),
      ],
    ).createShader(Offset.zero & size);
    // ทั้งแสงฟุ้งและขอบอยู่ในชั้นเดียว คูณความทึบ a (ชั้นกว้างกว่าช่องพอให้แสงฟุ้งไม่โดนตัด)
    canvas.saveLayer((Offset.zero & size).inflate(24.0),
        Paint()..color = Colors.black.withValues(alpha: a));
    // แสงฟุ้ง
    canvas.drawRRect(
        rr,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0));
    // ขอบไล่สีคม
    canvas.drawRRect(
        rr,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _QAiGlowPainter old) =>
      old.t != t || old.radius != radius;
}

/// คลื่นเสียงจริงในแถบอัดเสียง: แท่งมนขาว ระดับเสียงไมค์ (erMicLevel) ไหลเข้าจากขวา
class _QLiveWave extends StatefulWidget {
  const _QLiveWave({this.color = Colors.white, this.height = 28.0});
  final Color color;
  final double height;
  @override
  State<_QLiveWave> createState() => _QLiveWaveState();
}

class _QLiveWaveState extends State<_QLiveWave> {
  static const _n = 32;
  final List<double> _lv = List.filled(_n, 0.08);

  void _tick() {
    if (!mounted) return;
    setState(() {
      _lv.removeAt(0);
      _lv.add((0.1 + erMicLevel.value * 1.5).clamp(0.08, 1.0));
    });
  }

  @override
  void initState() {
    super.initState();
    erMicLevel.addListener(_tick);
  }

  @override
  void dispose() {
    erMicLevel.removeListener(_tick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(double.infinity, widget.height),
      painter: _QLiveWavePainter(List.of(_lv), widget.color));
}

class _QLiveWavePainter extends CustomPainter {
  const _QLiveWavePainter(this.v, [this.color = Colors.white]);
  final List<double> v;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final n = v.length, gap = size.width / n, bw = math.min(3.0, gap * 0.5);
    final p = Paint()
      ..strokeWidth = bw
      ..strokeCap = StrokeCap.round;
    final cy = size.height / 2;
    for (var i = 0; i < n; i++) {
      // แท่งเก่าทางซ้ายจางลง
      p.color = color.withValues(alpha: 0.35 + 0.65 * i / (n - 1));
      final hh = math.max(bw, (size.height - bw) * v[i]) / 2;
      final x = gap * (i + 0.5);
      canvas.drawLine(Offset(x, cy - hh), Offset(x, cy + hh), p);
    }
  }

  @override
  bool shouldRepaint(covariant _QLiveWavePainter old) => true;
}

/// จุด 3D (x, y, z) ของภาพ hero
typedef _QV3 = (double, double, double);

/// กล้อง 3D ของภาพ hero: หมุนวัตถุ (ในระนาบ rz → เอนหลัง rx → หันข้าง ry) แล้วฉายแบบ perspective (ระยะกล้อง f)
/// แกนวัตถุ: x ขวา · y ลง · z เข้าหากล้อง · จุดกำเนิด = กลางกล่องภาพ [c]
class _Q3 {
  _Q3(this.c, this.f, {double rx = 0.44, double ry = -0.40, double rz = 0.24}) {
    final cx = math.cos(rx), sx = math.sin(rx);
    final cy = math.cos(ry), sy = math.sin(ry);
    final cz = math.cos(rz), sz = math.sin(rz);
    // M = Ry · Rx · Rz
    m00 = cy * cz + sy * sx * sz;
    m01 = -cy * sz + sy * sx * cz;
    m02 = sy * cx;
    m10 = cx * sz;
    m11 = cx * cz;
    m12 = -sx;
    m20 = -sy * cz + cy * sx * sz;
    m21 = sy * sz + cy * sx * cz;
    m22 = cy * cx;
  }
  final Offset c;
  final double f;
  late final double m00, m01, m02, m10, m11, m12, m20, m21, m22;

  /// ทิศไฟ (ในพิกัดกล้อง): มาจากบนซ้ายด้านหน้า
  static const lx = -0.46, ly = -0.70, lz = 0.55;

  (double, double, double) rot(double x, double y, double z) => (
        m00 * x + m01 * y + m02 * z,
        m10 * x + m11 * y + m12 * z,
        m20 * x + m21 * y + m22 * z
      );

  Offset proj(double x, double y, double z) {
    final (X, Y, Z) = rot(x, y, z);
    final k = f / (f - Z);
    return c + Offset(X * k, Y * k);
  }

  /// ขนาดบนจอของความยาว 1 หน่วยที่ความลึกของจุดนี้
  double scaleAt(double x, double y, double z) => f / (f - rot(x, y, z).$3);

  /// ทิศไฟในพิกัดวัตถุ (Mᵀ · L) สำหรับฉายเงา
  (double, double, double) get lightObj {
    final n = math.sqrt(lx * lx + ly * ly + lz * lz);
    final x = lx / n, y = ly / n, z = lz / n;
    return (
      m00 * x + m10 * y + m20 * z,
      m01 * x + m11 * y + m21 * z,
      m02 * x + m12 * y + m22 * z
    );
  }
}

class _QVoiceGearPainter extends CustomPainter {
  const _QVoiceGearPainter(
      {required this.layer,
      required this.t,
      required this.still,
      required this.level,
      this.intro = 1.0,
      this.floor = 1e4});

  final int layer;
  final bool still;
  final double t;

  /// ไม่ใช้แล้ว คงไว้ให้ hot reload ได้โดยไม่ต้อง restart
  final double intro;

  /// ระดับเสียงไมค์ 0–1 ตอนกำลังฟังจริง · -1 = ไม่ได้ฟัง
  final double level;

  /// ขอบบนของแผงการ์ด (พิกัดในกล่องภาพ)
  final double floor;

  // สีกรมท่าของแอป (ผู้ใช้ 2026-11-27 "เอาสีเราสิ"): กรอบ #DBE5FC · สองโทน #5A69B4 / #2B3F96 · เข้ม #001B7C
  static const _rimHi = Color(0xFFFFFFFF);
  static const _rimLo = Color(0xFFDBE5FC);
  static const _sideLo = Color(0xFF5A69B4);
  static const _sideHi = Color(0xFFB7C3EC);
  static const _wallNear = Color(0xFF5A69B4);
  static const _wallFar = Color(0xFF1B2F7E);
  static const _b1Hi = Color(0xFF2B3F96);
  static const _b1Lo = Color(0xFF001B7C);
  static const _b1SideLo = Color(0xFF000F4A);
  static const _b1SideHi = Color(0xFF14267A);
  static const _b2Hi = Color(0xFF7B89CC);
  static const _b2Lo = Color(0xFF5A69B4);
  static const _b2SideLo = Color(0xFF2B3F96);
  static const _b2SideHi = Color(0xFF6F7EC4);
  static const _spark = Color(0xFF2B3F96);
  static const _micHi = Color(0xFFFFFFFF);
  static const _micLo = Color(0xFFDBE5FC);
  static const _micInk = Color(0xFF001B7C);
  static const _micR = 12.0, _micT = 6.0;
  static const _bars1 = [.4, .7, .5, .95, .65, .85, .5, .75, .45, .6, .35];
  static const _bars2 = [.45, .8, .55, .95, .6, .75, .4, .6, .35];

  // ขนาดในหน่วยภาพ (กล่องกว้าง 132 หน่วย)
  static const _starS = 127.0, _barW = 38.0; // ดาวยาว · แขนกว้าง
  static const _rimW = 6.0, _rimD = 10.0; // ขอบกรอบกว้าง · หนา
  static const _tunD = 46.0; // อุโมงค์ลึก
  static const _bT = 7.0; // ความหนาฟอง
  static const _b1W = 60.0, _b1H = 30.0, _b2W = 54.0, _b2H = 27.0;

  /// เส้นรอบนอก (หน่วยภาพ จุดกำเนิดกลาง) สุ่มจุดเท่ากันตามความยาว
  static List<Offset> _ring(Path p, int n) {
    final m = p.computeMetrics().first;
    return [
      for (var i = 0; i < n; i++)
        m.getTangentForOffset(m.length * i / n)!.position
    ];
  }

  /// ดาวแห่งชีวิต = แท่งมุมมน 3 แท่งไขว้ 60° (ขอบกรอบหนาเท่ากันทุกด้าน)
  static Path _bars3(double w, double l, double r) {
    Path? p;
    for (var k = 0; k < 3; k++) {
      final b = (Path()
            ..addRRect(RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset.zero, width: w, height: l),
                Radius.circular(r))))
          .transform(Matrix4.rotationZ(k * math.pi / 3.0).storage);
      p = p == null ? b : Path.combine(PathOperation.union, p, b);
    }
    return p!;
  }

  static final List<Offset> _outer = _ring(_bars3(_barW, _starS, 7.0), 320);
  static final List<Offset> _inner =
      _ring(_bars3(_barW - 2.0 * _rimW, _starS - 2.0 * _rimW, 3.0), 320);

  /// ฟองแชท: แคปซูล + หางโค้งต่อเนื่องจากขอบล่าง (ซ้าย = ผู้ป่วย · ขวา = AI)
  static Path _bubblePath(double w, double h, bool tailLeft) {
    final r = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(h / 2)));
    final sx = tailLeft ? 1.0 : -1.0;
    final x0 = tailLeft ? r.left : r.right;
    final tail = Path()
      ..moveTo(x0 + sx * w * 0.20, r.bottom - h * 0.30)
      ..quadraticBezierTo(x0 + sx * w * 0.14, r.bottom + h * 0.22,
          x0 - sx * w * 0.02, r.bottom + h * 0.34)
      ..quadraticBezierTo(x0 + sx * w * 0.24, r.bottom + h * 0.30,
          x0 + sx * w * 0.42, r.bottom - h * 0.20)
      ..close();
    return Path.combine(PathOperation.union, body, tail);
  }

  static final List<Offset> _b1Ring = _ring(_bubblePath(_b1W, _b1H, true), 96);
  static final List<Offset> _b2Ring = _ring(_bubblePath(_b2W, _b2H, false), 90);
  static final List<Offset> _micRing = [
    for (var i = 0; i < 48; i++)
      Offset(math.cos(i / 48 * math.pi * 2), math.sin(i / 48 * math.pi * 2)) *
          _micR
  ];

  /// ตัวไมค์ (แคปซูล) บนหน้าปุ่ม
  static final List<Offset> _micCap = _ring(
      Path()
        ..addRRect(RRect.fromRectAndRadius(
            const Rect.fromLTRB(-2.8, -7.5, 2.8, 1.5),
            const Radius.circular(2.8))),
      28);

  static double _ss(double a, double b, double x) {
    final k = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return k * k * (3.0 - 2.0 * k);
  }

  static double _area(List<Offset> r) {
    var a = 0.0;
    for (var i = 0; i < r.length; i++) {
      final p = r[i], q = r[(i + 1) % r.length];
      a += p.dx * q.dy - q.dx * p.dy;
    }
    return a;
  }

  static Path _poly(
          _Q3 q, double u, List<Offset> ring, Offset at, double k, double z) =>
      Path()
        ..addPolygon([
          for (final p in ring)
            q.proj((at.dx + p.dx * k) * u, (at.dy + p.dy * k) * u, z * u)
        ], true);

  /// ผนังรอบวง (หน่วยภาพ) จาก z = [za] ถึง [zb] · [inward] = หันเข้าใน (ผนังอุโมงค์) · ตัดด้านที่หันหนีกล้อง
  /// คืน (ความลึก, รูป, สี) ให้เรียงวาดไกล→ใกล้
  List<(double, Path, Color)> _walls(
      _Q3 q,
      double u,
      List<Offset> ring,
      Offset at,
      double k,
      double za,
      double zb,
      bool inward,
      Color Function(double lit) shade) {
    final n = ring.length;
    final out = (_area(ring) > 0.0) != inward;
    final pts = [for (final p in ring) (at + p * k) * u];
    final fa = [for (final p in pts) q.proj(p.dx, p.dy, za * u)];
    final fb = [for (final p in pts) q.proj(p.dx, p.dy, zb * u)];
    final ln = math.sqrt(_Q3.lx * _Q3.lx + _Q3.ly * _Q3.ly + _Q3.lz * _Q3.lz);
    final res = <(double, Path, Color)>[];
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final d = pts[j] - pts[i];
      final dl = d.distance;
      if (dl < 1e-6) continue;
      final nx = (out ? d.dy : -d.dy) / dl, ny = (out ? -d.dx : d.dx) / dl;
      final (rx, ry, rz) = q.rot(nx, ny, 0.0);
      final m = (pts[i] + pts[j]) / 2.0;
      final (mx, my, mz) = q.rot(m.dx, m.dy, (za + zb) / 2.0 * u);
      if (rx * -mx + ry * -my + rz * (q.f - mz) <= 0.0) continue;
      final lit =
          ((rx * _Q3.lx + ry * _Q3.ly + rz * _Q3.lz) / ln).clamp(0.0, 1.0);
      res.add((
        mz,
        Path()..addPolygon([fa[i], fa[j], fb[j], fb[i]], true),
        shade(lit)
      ));
    }
    return res;
  }

  void _drawWalls(Canvas canvas, List<(double, Path, Color)> w) {
    w.sort((a, b) => a.$1.compareTo(b.$1));
    for (final (_, p, col) in w) {
      canvas.drawPath(p, Paint()..color = col);
      canvas.drawPath(
          p,
          Paint()
            ..color = col
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8);
    }
  }

  /// เงาของเส้นรอบ (ที่ z = [z] หน่วยภาพ) ฉายตามแสงลงระนาบ z = [onto]
  Path _shadow(_Q3 q, double u, List<Offset> ring, Offset at, double k,
      double z, double onto) {
    final (lx, ly, lz) = q.lightObj;
    final pts = <Offset>[];
    for (final p in ring) {
      final o = (at + p * k) * u;
      final s = (z - onto) * u / lz;
      pts.add(q.proj(o.dx - lx * s, o.dy - ly * s, onto * u));
    }
    return Path()..addPolygon(pts, true);
  }

  Paint _grad(Path p, Color hi, Color lo) => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [hi, lo],
    ).createShader(p.getBounds());

  /// ท่าชิ้นที่ออกจากอุโมงค์: e 0 = ก้นอุโมงค์ (ไกล เล็ก) · 1 = ลอยตำแหน่งจริงหน้ากรอบ
  /// เคลื่อนเป็นเส้นตรงนุ่ม (ผู้ใช้ 2026-11-27 "ตอนออกมาต้องการให้มัน linear smooth"):
  /// ตำแหน่ง ความลึก ขนาด ไปพร้อมกันด้วยค่าเดียว ไม่เด้งเกิน · จังหวะเร่ง/ผ่อนนุ่มมาจาก e (smoothstep)
  (Offset, double, double) _pose(Offset to, double zTo, double e) {
    final z = -_tunD + 4.0 + (zTo + _tunD - 4.0) * e;
    final at = Offset.lerp(const Offset(0.0, 6.0), to, e)!;
    return (at, z, 0.7 + 0.3 * e);
  }

  /// แบ่งรูปหลายเหลี่ยม 3D (พิกัดวัตถุ px) ด้วยระนาบประตู z = 0 → (ส่วนที่พ้นประตู, ส่วนที่ยังอยู่หลังประตู)
  static (List<_QV3>, List<_QV3>) _split(List<_QV3> poly) {
    final f = <_QV3>[], b = <_QV3>[];
    for (var i = 0; i < poly.length; i++) {
      final p = poly[i], r = poly[(i + 1) % poly.length];
      final pf = p.$3 >= 0.0, rf = r.$3 >= 0.0;
      (pf ? f : b).add(p);
      if (pf != rf) {
        final k = p.$3 / (p.$3 - r.$3);
        final m = (p.$1 + (r.$1 - p.$1) * k, p.$2 + (r.$2 - p.$2) * k, 0.0);
        f.add(m);
        b.add(m);
      }
    }
    return (f, b);
  }

  /// วัตถุนูน 3D (ฟองแชท/ปุ่มไมค์) ที่ผ่านระนาบประตูได้จริง: เงย [pitch] รอบแกนนอนกลางชิ้น (> 0 = ขอบบนเข้าหากล้อง)
  /// ทุกหน้า (ด้านข้าง หน้าชิ้น ลายบนหน้า) ถูกตัดด้วยระนาบ z = 0 ทุกเฟรม:
  /// ส่วนหลังระนาบเห็นผ่านช่องดาวเท่านั้น · ส่วนที่พ้นแล้วเห็นเต็ม → เผยต่อเนื่องตามเส้นตัด ไม่มีรอยกวาด
  /// [content] วาดลายบนหน้าชิ้น: ให้จุดบนหน้า (หน่วยภาพ สัมพัทธ์กลางชิ้น) → เติมรูป / ลากเส้น
  void _slab3d(
      Canvas canvas,
      _Q3 q,
      double u,
      Path open,
      List<Offset> ring,
      Offset at,
      double k,
      double zf,
      double pitch,
      double thick,
      Color hi,
      Color lo,
      Color sLo,
      Color sHi,
      void Function(
              void Function(List<Offset> poly, Paint paint) fill,
              void Function(Offset a, Offset b, double width, [Color? color])
                  line)
          content) {
    final ca = math.cos(pitch), sa = math.sin(pitch);
    _QV3 loc(double x, double y, double z) =>
        (at.dx * u + x, at.dy * u + y * ca + z * sa, zf * u - y * sa + z * ca);
    _QV3 face(Offset p) => loc(p.dx * k * u, p.dy * k * u, 0.0);
    Offset pj(_QV3 v) => q.proj(v.$1, v.$2, v.$3);
    Path path(List<_QV3> poly) =>
        Path()..addPolygon([for (final v in poly) pj(v)], true);
    final n = ring.length;
    final cw = _area(ring) > 0.0;
    final fr = [for (final p in ring) face(p)];
    final bk = [
      for (final p in ring) loc(p.dx * k * u, p.dy * k * u, -thick * u)
    ];
    final ln = math.sqrt(_Q3.lx * _Q3.lx + _Q3.ly * _Q3.ly + _Q3.lz * _Q3.lz);
    bool facing(_QV3 nrm, _QV3 c) {
      final (rx, ry, rz) = q.rot(nrm.$1, nrm.$2, nrm.$3);
      final (mx, my, mz) = q.rot(c.$1, c.$2, c.$3);
      return rx * -mx + ry * -my + rz * (q.f - mz) > 0.0;
    }

    double lit(_QV3 nrm) {
      final (rx, ry, rz) = q.rot(nrm.$1, nrm.$2, nrm.$3);
      return ((rx * _Q3.lx + ry * _Q3.ly + rz * _Q3.lz) / ln).clamp(0.0, 1.0);
    }

    // (ความลึก, รูป 3D, สี, เป็นด้านข้าง)
    final faces = <(double, List<_QV3>, Paint, bool)>[];
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      final d = ring[j] - ring[i];
      final dl = d.distance;
      if (dl < 1e-6) continue;
      final nx = (cw ? d.dy : -d.dy) / dl, ny = (cw ? -d.dx : d.dx) / dl;
      final nrm = (nx, ny * ca, -ny * sa);
      final c = (
        (fr[i].$1 + bk[j].$1) / 2.0,
        (fr[i].$2 + bk[j].$2) / 2.0,
        (fr[i].$3 + bk[j].$3) / 2.0
      );
      if (!facing(nrm, c)) continue;
      faces.add((
        q.rot(c.$1, c.$2, c.$3).$3,
        [fr[i], fr[j], bk[j], bk[i]],
        Paint()..color = Color.lerp(sLo, sHi, 0.15 + 0.85 * lit(nrm))!,
        true
      ));
    }
    final fc = loc(0.0, 0.0, 0.0);
    final showFace = facing((0.0, sa, ca), fc);
    if (showFace) faces.add((1e9, fr, _grad(path(fr), hi, lo), false));
    faces.sort((a, b) => a.$1.compareTo(b.$1));
    // ส่วนหลังระนาบ / ส่วนที่พ้นแล้ว: (รูป, สี, ปิดรอยต่อ) และเส้น (จุด, จุด, สี)
    final behind = <(Path, Paint, bool)>[], ahead = <(Path, Paint, bool)>[];
    for (final (_, poly, paint, side) in faces) {
      final (fp, bp) = _split(poly);
      if (bp.length >= 3) behind.add((path(bp), paint, side));
      if (fp.length >= 3) ahead.add((path(fp), paint, side));
    }
    final lBehind = <(Offset, Offset, Paint)>[],
        lAhead = <(Offset, Offset, Paint)>[];
    if (showFace) {
      final sc = q.scaleAt(fc.$1, fc.$2, fc.$3);
      content((poly, paint) {
        final (fp, bp) = _split([for (final p in poly) face(p)]);
        if (bp.length >= 3) behind.add((path(bp), paint, false));
        if (fp.length >= 3) ahead.add((path(fp), paint, false));
      }, (a0, b0, width, [color]) {
        final a = face(a0), b = face(b0);
        final paint = Paint()
          ..color = color ?? Colors.white
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width * u * k * sc;
        if (a.$3 >= 0.0 && b.$3 >= 0.0) {
          lAhead.add((pj(a), pj(b), paint));
        } else if (a.$3 < 0.0 && b.$3 < 0.0) {
          lBehind.add((pj(a), pj(b), paint));
        } else {
          final kk = a.$3 / (a.$3 - b.$3);
          final m = (a.$1 + (b.$1 - a.$1) * kk, a.$2 + (b.$2 - a.$2) * kk, 0.0);
          final (fa, ba) = a.$3 >= 0.0 ? (a, b) : (b, a);
          lAhead.add((pj(fa), pj(m), paint));
          lBehind.add((pj(m), pj(ba), paint));
        }
      });
    }
    void draw(
        List<(Path, Paint, bool)> list, List<(Offset, Offset, Paint)> lines) {
      for (final (p, paint, side) in list) {
        canvas.drawPath(p, paint);
        if (side) {
          // ปิดรอยต่อระหว่างชิ้นด้านข้าง
          canvas.drawPath(
              p,
              Paint()
                ..color = paint.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.8);
        }
      }
      for (final (a, b, paint) in lines) {
        canvas.drawLine(a, b, paint);
      }
    }

    if (behind.isNotEmpty || lBehind.isNotEmpty) {
      canvas.save();
      canvas.clipPath(open);
      canvas.clipRect(Rect.fromLTRB(-1e4, -1e4, 1e4, floor));
      draw(behind, lBehind);
      canvas.restore();
    }
    draw(ahead, lAhead);
  }

  @override
  void paint(Canvas canvas, Size sz) {
    final u = sz.width / 132.0;
    final q = _Q3(sz.center(Offset.zero), 3.4 * sz.width);
    final open = _poly(q, u, _inner, Offset.zero, 1.0, 0.0);
    if (layer == 0) {
      // เงากรอบตกบนฉากหลัง (ฉากอยู่ลึกหลังกรอบ)
      canvas.drawPath(
          _shadow(q, u, _outer, Offset.zero, 1.0, -_rimD, -_rimD - 30.0),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.10)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6.0 * u));
      return;
    }
    if (layer == 1) {
      // ---- ในอุโมงค์ (เห็นผ่านช่องรูปดาวเท่านั้น): ผนังด้านในไล่จากเทากลาง (ใกล้) ไปเข้ม (ไกล) ไม่มีสีขาว (ผู้ใช้ "เอาสีขาว ๆ ออก")
      canvas.save();
      canvas.clipPath(open);
      final far = _poly(q, u, _inner, Offset.zero, 1.0, -_tunD);
      final fb = far.getBounds();
      canvas.drawPath(
          far,
          Paint()
            ..shader = RadialGradient(
              colors: const [
                Color(0xFF22358C),
                Color(0xFF1B2F7E),
                Color(0xFF14256C)
              ],
              stops: const [0.0, 0.55, 1.0],
            ).createShader(Rect.fromCircle(
                center: fb.center, radius: fb.longestSide * 0.55)));
      const seg = 9;
      final w = <(double, Path, Color)>[];
      for (var i = 0; i < seg; i++) {
        final za = -_tunD * i / seg, zb = -_tunD * (i + 1) / seg;
        final base = Color.lerp(_wallNear, _wallFar, (i + 0.5) / seg)!;
        w.addAll(_walls(
            q,
            u,
            _inner,
            Offset.zero,
            1.0,
            za,
            zb,
            true,
            (lit) =>
                Color.lerp(const Color(0xFF14256C), base, 0.6 + 0.4 * lit)!));
      }
      _drawWalls(canvas, w);
      canvas.restore();
      return;
    }
    if (layer == 3) {
      // ---- กรอบรูปดาว: ด้านข้างนอกไล่แสง + หน้ากรอบ (เฉพาะขอบ ช่องกลางเปิด) + ขอบสว่าง/ขอบในคม
      _drawWalls(
          canvas,
          _walls(q, u, _outer, Offset.zero, 1.0, 0.0, -_rimD, false,
              (lit) => Color.lerp(_sideLo, _sideHi, 0.15 + 0.85 * lit)!));
      final outer = _poly(q, u, _outer, Offset.zero, 1.0, 0.0);
      final rim = Path.combine(PathOperation.difference, outer, open);
      canvas.drawPath(rim, _grad(outer, _rimHi, _rimLo));
      canvas.drawPath(
          outer,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2 * u
            ..strokeJoin = StrokeJoin.round);
      canvas.drawPath(
          open,
          Paint()
            ..color = const Color(0xFF9E9E9E)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.9 * u
            ..strokeJoin = StrokeJoin.round);
      return;
    }

    // ================= ชั้นที่ออกมา: ฟองแชทโผล่จากประตูแล้ววน =================
    // (ผู้ใช้ 2026-11-27 "story ซับซ้อนไป เอาแค่ให้มันโผล่ออกมาแล้วก็ loop") วนทุก 8 วินาที:
    // ฟองผู้ป่วยโผล่ → ฟอง AI โผล่ตาม → ลอยค้าง คลื่นเสียงขยับ → กลับเข้าประตูทีละอัน → ว่างครู่หนึ่ง
    // ตอนผ่านประตูฟองเงยขอบบนนำออกมาก่อนแล้วค่อยตั้งตรง ตัดด้วยระนาบประตูจริงทุกเฟรม (ผู้ใช้ "ตอนโผล่ยังไม่เนียน")
    // นิ่ง (มีคำเล่าแล้ว/ปิดแอนิเมชัน) = ทั้งสองฟองลอยอยู่ · กำลังฟังจริง = ฟองผู้ป่วยขยับตามเสียงไมค์
    final live = level >= 0.0;
    final p = (still || live) ? 0.5 : (t % 8.0) / 8.0;
    // ไมค์ออกก่อน เข้าเป็นอันสุดท้าย (ผู้ใช้ "เอาไอคอนไมค์มาใส่ด้วย") · ฟองผู้ป่วย · ฟอง AI
    final e0 = _ss(0.0, 0.22, p) * (1.0 - _ss(0.86, 0.98, p));
    final e1 = _ss(0.08, 0.30, p) * (1.0 - _ss(0.82, 0.94, p));
    final e2 = _ss(0.18, 0.40, p) * (1.0 - _ss(0.76, 0.88, p));
    final sink = _ss(0.78, 0.95, p);
    final talk1 = live
        ? (0.25 + 1.6 * level).clamp(0.0, 1.0)
        : (still ? 0.6 : 0.5 + 0.5 * math.sin(t * 1.6));
    final talk2 = live ? 0.3 : (still ? 0.6 : 0.5 - 0.5 * math.sin(t * 1.6));
    final items = <((Offset, double, double), int, double)>[
      if (e0 > 0.001) (_pose(const Offset(-40.0, 16.0), 10.0, e0), 0, e0),
      if (e1 > 0.001) (_pose(const Offset(-8.0, -26.0), 16.0, e1), 1, e1),
      if (e2 > 0.001) (_pose(const Offset(26.0, 6.0), 11.0, e2), 2, e2),
    ]..sort((a, b) => a.$1.$2.compareTo(b.$1.$2));
    List<Offset> ringOf(int kind) =>
        kind == 0 ? _micRing : (kind == 1 ? _b1Ring : _b2Ring);

    // กำลังฟังจริง: ในประตูสว่างขึ้นตามเสียงพูด (เทาอ่อน ไม่ใช่ขาว) · ไม่ระบายลงบนแผงการ์ด
    if (live && level > 0.02) {
      final ob = open.getBounds();
      canvas.save();
      canvas.clipPath(open);
      canvas.clipRect(Rect.fromLTRB(-1e4, -1e4, 1e4, floor));
      canvas.drawRect(
          ob,
          Paint()
            ..shader = RadialGradient(colors: [
              const Color(0xFFC4C4C4)
                  .withValues(alpha: 0.8 * level.clamp(0.0, 1.0)),
              const Color(0xFFC4C4C4).withValues(alpha: 0.0),
            ]).createShader(Rect.fromCircle(
                center: ob.center + Offset(4.0 * u, 6.0 * u),
                radius: ob.shortestSide * 0.6)));
      canvas.restore();
    }

    // เงาบนขอบกรอบ: ค่อย ๆ เข้มขึ้นเมื่อชิ้นพ้นประตูหมดแล้ว
    final outer = _poly(q, u, _outer, Offset.zero, 1.0, 0.0);
    canvas.save();
    canvas.clipPath(Path.combine(PathOperation.difference, outer, open));
    for (final ((at, z, k), kind, e) in items) {
      final a = 0.20 * _ss(0.8, 1.0, e);
      if (a <= 0.001) continue;
      canvas.drawPath(
          _shadow(
              q, u, ringOf(kind), at, k, z - (kind == 0 ? _micT : _bT), 0.0),
          Paint()
            ..color = Colors.black.withValues(alpha: a)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 * u));
    }
    canvas.restore();

    for (final ((at, z, k), kind, e) in items) {
      // เงยราว 60° ตอนอยู่ก้นอุโมงค์ → ตั้งตรงเมื่อออกมาลอยแล้ว
      final pitch = 1.05 * (1.0 - e);
      // ค่อย ๆ จางเข้าตอนโผล่ / จางออกตอนกลับเข้าประตู (ผู้ใช้ "ตอน appear เอาให้มันโผล่ fade ออกมา")
      final fade = _ss(0.0, 0.6, e);
      final layered = fade < 0.999;
      if (layered) {
        canvas.saveLayer(
            null, Paint()..color = Colors.black.withValues(alpha: fade));
      }
      if (kind == 0) {
        // ---- ปุ่มไมค์ทรงกระบอก: ปกติหน้าขาวไอคอนเทาเข้ม · กำลังฟังจริง = เปิด (หน้าเทาเข้ม ไอคอนขาว)
        // + วงกระเพื่อมสองชั้นขยายตามระดับเสียง
        final inkC = live ? Colors.white : _micInk;
        if (live) {
          for (var r = 0; r < 2; r++) {
            final fr = (t * 0.9 + r * 0.5) % 1.0;
            canvas.drawPath(
                _poly(q, u, _micRing, at, k * (1.0 + 0.9 * fr), z),
                Paint()
                  ..color = Colors.black.withValues(
                      alpha: (1.0 - fr) * (0.12 + 0.3 * level.clamp(0.0, 1.0)))
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.6 * u);
          }
        }
        _slab3d(
            canvas,
            q,
            u,
            open,
            _micRing,
            at,
            k,
            z,
            pitch,
            _micT,
            live ? _b1Hi : _micHi,
            live ? _b1Lo : _micLo,
            _sideLo,
            _sideHi, (fill, line) {
          fill(_micCap, Paint()..color = inkC);
          for (var i = 0; i < 12; i++) {
            final a0 = i / 12 * math.pi, a1 = (i + 1) / 12 * math.pi;
            line(
                Offset(5.0 * math.cos(a0), -1.0 + 5.0 * math.sin(a0)),
                Offset(5.0 * math.cos(a1), -1.0 + 5.0 * math.sin(a1)),
                1.5,
                inkC);
          }
          line(const Offset(0.0, 4.0), const Offset(0.0, 6.5), 1.5, inkC);
          line(const Offset(-2.8, 6.5), const Offset(2.8, 6.5), 1.5, inkC);
        });
        if (layered) canvas.restore();
        continue;
      }
      // ---- ฟองแชท + คลื่นเสียงขาว (สองฟองคุยสลับกันเบา ๆ)
      final b1 = kind == 1;
      final w = b1 ? _b1W : _b2W, h = b1 ? _b1H : _b2H;
      final bars = b1 ? _bars1 : _bars2;
      final talk = b1 ? talk1 : talk2;
      final maxH = b1 ? 17.0 : 14.0;
      _slab3d(
          canvas,
          q,
          u,
          open,
          ringOf(kind),
          at,
          k,
          z,
          pitch,
          _bT,
          b1 ? _b1Hi : _b2Hi,
          b1 ? _b1Lo : _b2Lo,
          b1 ? _b1SideLo : _b2SideLo,
          b1 ? _b1SideHi : _b2SideHi, (fill, line) {
        final x0 = -w / 2 + h * 0.42, x1 = w / 2 - h * 0.42;
        final step = (x1 - x0) / (bars.length - 1);
        for (var i = 0; i < bars.length; i++) {
          final jj = still ? 1.0 : (0.6 + 0.4 * math.sin(t * 9.0 + i * 1.3));
          final hh = maxH * bars[i] * (0.4 + 0.6 * talk * jj);
          final x = x0 + step * i;
          line(Offset(x, -hh / 2), Offset(x, hh / 2), 2.2);
        }
      });
      if (layered) canvas.restore();
    }

    // ---- ประกาย 4 แฉกแบนรอบภาพ: ขึ้นตามฟอง หายตอนฟองกลับเข้าประตู
    final c = sz.center(Offset.zero);
    final glow = still ? 1.0 : _ss(0.05, 0.25, p) * (1.0 - sink);
    void spark(Offset o, double r) {
      if (r <= 0.0) return;
      final qq = r * 0.22;
      canvas.drawPath(
          Path()
            ..moveTo(o.dx, o.dy - r)
            ..quadraticBezierTo(o.dx + qq, o.dy - qq, o.dx + r, o.dy)
            ..quadraticBezierTo(o.dx + qq, o.dy + qq, o.dx, o.dy + r)
            ..quadraticBezierTo(o.dx - qq, o.dy + qq, o.dx - r, o.dy)
            ..quadraticBezierTo(o.dx - qq, o.dy - qq, o.dx, o.dy - r)
            ..close(),
          Paint()..color = _spark);
    }

    final tw = still ? 0.0 : math.sin(t * 2.6);
    // ประกายบนซ้ายเอาออก (ผู้ใช้ 2026-11-27 "เอาดาวบนซ้ายออก")
    spark(c + Offset(66.0 * u, -52.0 * u), 8.5 * u * glow * (1.0 - 0.16 * tw));
    spark(c + Offset(-74.0 * u, 6.0 * u), 7.0 * u * glow * (1.0 + 0.12 * tw));
  }

  @override
  bool shouldRepaint(covariant _QVoiceGearPainter o) =>
      o.t != t || o.level != level || o.still != still || o.layer != layer;
}

/// ไอคอนผู้ช่วย AI (ผู้ใช้ 2026-11-27 "วาดไอคอนนี้ เปลี่ยน nested icon เป็น spark"):
/// duotone กรมท่า: ฟองคำพูดโทนอ่อน (หางมุมซ้ายล่าง) + spark 4 แฉกโทนเข้มซ้อนมุมขวาล่าง
class _QAiBubble extends StatelessWidget {
  const _QAiBubble({this.size = 20.0});
  final double size;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _QAiBubblePainter());
}

class _QAiBubblePainter extends CustomPainter {
  const _QAiBubblePainter();

  @override
  void paint(Canvas canvas, Size sz) {
    final w = sz.width, h = sz.height;
    // duotone (ผู้ใช้ 2026-11-27 "อยากได้แบบ duotone"): สีเดียวสองโทนตามกฎไอคอนกรมท่าของแอป
    // ชั้นรอง = ฟองคำพูด กรมท่าโปร่ง 32% · ชั้นหลัก = spark กรมท่าทึบ · ช่องขาวคั่นสองชั้น
    const ink = Color(0xFF2B3F96);
    final bubble = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.04, h * 0.08, w * 0.82, h * 0.66),
          Radius.circular(w * 0.32)))
      ..moveTo(w * 0.18, h * 0.62)
      ..lineTo(w * 0.10, h * 0.92)
      ..lineTo(w * 0.42, h * 0.70)
      ..close();
    canvas.drawPath(bubble, Paint()..color = ink.withValues(alpha: 0.32));
    final c = Offset(w * 0.68, h * 0.66), r = w * 0.31, k = r * 0.16;
    final spark = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(
        spark,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.08
          ..strokeJoin = StrokeJoin.round);
    canvas.drawPath(spark, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(covariant _QAiBubblePainter old) => false;
}

/// ไอคอนอาการสำคัญ (แผ่นสติกเกอร์อาการในโน้ต)
const Map<String, IconData> _qCcIcons = {
  'หมดสติ': Icons.airline_seat_flat_rounded,
  'เจ็บหน้าอก': Icons.favorite_border_rounded,
  'หายใจไม่ออก': Icons.air_rounded,
  'แขนขาอ่อนแรง': Icons.accessibility_new_rounded,
  'ชัก': Icons.bolt_rounded,
  'เลือดออกมาก': Icons.water_drop_outlined,
  'อุบัติเหตุรุนแรง': Icons.car_crash_outlined,
  'สัตว์มีพิษกัด': Icons.pest_control_outlined,
  'ไข้': Icons.thermostat_rounded,
  'ปวดท้อง': Icons.sick_outlined,
  'เวียนศีรษะ': Icons.cyclone_rounded,
  'แผล/บาดเจ็บ': Icons.healing_outlined,
  'ปวดศีรษะ': Icons.psychology_alt_outlined,
  'แพ้ยา/แพ้อาหาร': Icons.no_food_outlined,
};

extension _QuickRegisterPart on _ErFlowHomeWidgetState {
  /// กฎคำ: คืนตัวเลือกที่พบในคำเล่า (ข้ามคำที่ถูกปฏิเสธ) + คะแนนปวด "ปวด 7/10"
  List<String> _qCcRulePicks(String text) {
    final t = text.toLowerCase().replaceAll(' ', '');
    // ปฏิเสธ = คำอยู่ถัดจาก "ไม่ / ไม่มี / ไม่ได้ / ปฏิเสธ" (+ "อาการ") ทันที · "ไม่สบาย เจ็บหน้าอก" ยังนับ
    const neg = ['ไม่', 'ไม่มี', 'ไม่ได้', 'ปฏิเสธ'];
    bool negated(String pre) => neg.any((w) =>
        pre.endsWith(w) || pre.endsWith('$wอาการ') || pre.endsWith('$wการ'));
    bool hit(String w) {
      var i = t.indexOf(w);
      while (i >= 0) {
        final skip = (_qCcSkip[w] ?? const <String>[]).any((c) {
          final o = c.indexOf(w);
          return i - o >= 0 && t.startsWith(c, i - o);
        });
        if (!skip && !negated(t.substring((i - 14).clamp(0, i), i))) {
          return true;
        }
        i = t.indexOf(w, i + w.length);
      }
      return false;
    }

    final out = <String>[
      for (final (words, picks) in _qCcRules)
        if (words.any(hit)) ...picks,
    ];
    final m = RegExp(
            r'(?:ปวด|เจ็บ|pain)\D{0,8}?(\d{1,2})\s*(?:/\s*10|เต็ม\s*10|คะแนน)')
        .firstMatch(text);
    final n = m == null ? null : int.tryParse(m.group(1)!);
    if (n != null && n <= 10) out.add('pain:$n');
    // สัญญาณชีพจากคำเล่า (ผู้ใช้ 2026-11-27 "v/s ก็ต้องเลือกให้ด้วยสิ"): ต้องมีชื่อค่าอยู่หน้าตัวเลข · ค่านอกช่วงไม่เอา
    final bp = RegExp(
            r'(?:ความดัน(?:โลหิต)?|bp)\D{0,8}?(\d{2,3})\s*/\s*(\d{2,3})',
            caseSensitive: false)
        .firstMatch(text);
    if (bp != null) {
      final sb = int.parse(bp.group(1)!), db = int.parse(bp.group(2)!);
      if (sb >= 50 && sb <= 260 && db >= 20 && db <= 160 && db < sb) {
        out
          ..add('vs:sbp:$sb')
          ..add('vs:dbp:$db');
      }
    }
    void num(String key, String re, double lo, double hi) {
      final x = RegExp(re, caseSensitive: false).firstMatch(text);
      final v = x == null ? null : double.tryParse(x.group(1)!);
      if (v != null && v >= lo && v <= hi) {
        out.add('vs:$key:${v == v.roundToDouble() ? v.round() : v}');
      }
    }

    num('hr', r'(?:ชีพจร|หัวใจเต้น|\bhr\b|\bpr\b|pulse)\D{0,8}?(\d{2,3})', 20,
        250);
    num(
        'rr',
        r'(?:หายใจ|\brr\b)\D{0,10}?(\d{1,2})\s*(?:ครั้ง|/\s*(?:นาที|min))',
        4,
        70);
    num('bt', r'(?:ไข้|อุณหภูมิ|\bbt\b|temp)\D{0,8}?(\d{2}(?:\.\d)?)', 34, 43);
    num('spo2', r'(?:spo2|spo₂|\bsat|ออกซิเจน)\D{0,8}?(\d{2,3})', 50, 100);
    num('dtx', r'(?:dtx|น้ำตาล)\D{0,8}?(\d{2,3})', 20, 700);
    // GCS: วลีที่บอกระดับชัดเท่านั้น (ทำตามคำสั่งไม่ได้เฉย ๆ ยังไม่รู้ M ไม่เดา) · องค์ประกอบละ 1 ค่า (แรกสุดชนะ)
    for (final (lv, words) in _qGcsRules) {
      if (words.any(hit)) out.add('gcs:$lv');
    }
    // ความรู้สึกตัว: หนักสุดก่อน (ซึม + สับสน = ซึม)
    for (final (lv, words) in _qLocRules) {
      if (words.any(hit)) out.add('loc:$lv');
    }
    return out;
  }

  /// เลือกให้แบบเพิ่มเท่านั้น (ไม่ถอดสิ่งที่ผู้ใช้เลือกเอง) · ข้ามสิ่งที่ผู้ใช้เคยเอาออก · จำว่าอันไหนระบบเลือก
  void _qCcApply(Iterable<String> picks) {
    final added = <String>[];
    // ประเภทผู้ป่วยตามชิปอาการ: อาการวิกฤตทางอายุรกรรม = ฉุกเฉิน · อุบัติเหตุรุนแรง/สัตว์มีพิษ = อุบัติเหตุ
    // (แผล/บาดเจ็บเฉย ๆ ไม่สรุปเป็นอุบัติเหตุ: อาจเป็นแผลกดทับ/แผลผ่าตัด)
    const med = {
      'หมดสติ',
      'เจ็บหน้าอก',
      'หายใจไม่ออก',
      'แขนขาอ่อนแรง',
      'ชัก',
      'เลือดออกมาก'
    };
    const tra = {'อุบัติเหตุรุนแรง', 'สัตว์มีพิษกัด'};
    final all = picks.toSet();
    if (all.any((p) => med.contains(p.replaceFirst('cc:', '')))) {
      all.add('type:ฉุกเฉิน');
    }
    if (all.any((p) => tra.contains(p.replaceFirst('cc:', '')))) {
      all.add('type:อุบัติเหตุ');
    }
    for (final p in all) {
      if (_qCcNo.contains(p) || _qCcAuto.contains(p)) continue;
      final i = p.indexOf(':');
      final kind = p.substring(0, i), v = p.substring(i + 1);
      switch (kind) {
        case 'type':
          if (v != 'ตรวจโรคทั่วไป' &&
              _triTypeOpts.any((o) => o.$1 == v) &&
              _triType.add(v)) {
            added.add(p);
          }
        case 'cc':
          if (_qCcOpts.any((o) => o.$1 == v) && _qCc.add(v)) added.add(p);
        case 'pain':
          final n = int.tryParse(v);
          if (n != null && _triPain == null) {
            _triPain = n;
            added.add(p);
          }
        // สัญญาณชีพ 'vs:sbp:140' · เติมเฉพาะช่องที่ยังว่าง
        case 'vs':
          final j = v.indexOf(':');
          final c = _triCtl(v.substring(0, j));
          if (c.text.trim().isEmpty) {
            c.text = v.substring(j + 1);
            added.add(p);
          }
        // GCS 'gcs:E1' → ตัวเลือกเต็มของ E/V/M · เติมเฉพาะองค์ประกอบที่ยังว่าง
        case 'gcs':
          final o = [..._triEOpts, ..._triVOpts, ..._triMOpts]
              .where((x) => x.startsWith(v))
              .firstOrNull;
          if (o == null) break;
          if (v.startsWith('E') && _triE == null) {
            _triE = o;
            added.add(p);
          } else if (v.startsWith('V') && _triV == null) {
            _triV = o;
            added.add(p);
          } else if (v.startsWith('M') && _triM == null) {
            _triM = o;
            added.add(p);
          }
        case 'loc':
          if (_triLoc == null && _triLocOpts.contains(v)) {
            _triLoc = v;
            added.add(p);
          }
      }
    }
    if (added.isEmpty) return;
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    setState(() {
      _qCcAuto.addAll(added);
      // ช่องที่ถูกเติมเรืองแสงแทนข้อความแจ้ง (ผู้ใช้ 2026-11-27 "แบบนี้เค้าไม่อ่านหรอก")
      for (final p in added) {
        _qCcGlowAt[p] = now;
      }
    });
  }

  /// พิมพ์/พูดคำเล่า: กฎคำทันที · หยุดพิมพ์ 1.4 วินาที = ให้ AI อ่านซ้ำหาสิ่งที่กฎคำไม่เจอ
  void _qCcChanged() {
    final text = _regCtl('cc').text.trim();
    // ล้างช่องคำเล่า = เริ่มเรื่องใหม่: ลืมสิ่งที่เคยยกเลิก (ไม่งั้นคำเล่าใหม่ถูกบล็อกจากเรื่องเก่า)
    if (text.isEmpty) {
      _qCcNo.clear();
      _qCcAiDone = '';
    }
    setState(() {});
    _qCcApply(_qCcRulePicks(text));
    _qCcTimer?.cancel();
    if (text.length < 6) return;
    _qCcTimer = Timer(const Duration(milliseconds: 1400), () => _qCcAi(text));
  }

  /// AI (ErAi เร็ว, JSON) เลือกจากตัวเลือกที่มีอยู่เท่านั้น · ผิดพลาด/ช้า = เงียบ (กฎคำยังทำงาน)
  Future<void> _qCcAi(String text) async {
    if (!mounted || text == _qCcAiDone || _qCcAiBusy) return;
    _qCcAiDone = text;
    setState(() => _qCcAiBusy = true);
    try {
      // ไม่ให้ AI เลือก "ตรวจโรคทั่วไป" (ลดความเร่งด่วน = พยาบาลตัดสินเอง) · ทดสอบชุดใหม่ 40 เคส: เลือกเกิน 14 → 3
      final types = [
        for (final o in _triTypeOpts)
          if (o.$1 != 'ตรวจโรคทั่วไป') o.$1
      ];
      final ccs = [for (final o in _qCcOpts) o.$1];
      final opts = [
        for (final t in types) 'type:$t',
        for (final c in ccs) 'cc:$c',
        for (final o in [..._triEOpts, ..._triVOpts, ..._triMOpts])
          if (!o.startsWith('C')) 'gcs:${o.substring(0, 2)}',
        for (final l in _triLocOpts) 'loc:$l',
      ];
      // ทุกตัวที่เลือกต้องยกคำจากคำเล่ามายืนยัน (ตรวจซ้ำในแอป) = ไม่เดาอาการที่ไม่ได้พูดถึง
      // ทดสอบ 2026-11-27 ชุดใหม่ 40 เคส: precision 96% ไม่มีอาการที่เดาขึ้นมาเอง (เดิมเดา "หมดสติ" จาก "งูกัด")
      final raw = await ErAi.chat([
        {
          'role': 'system',
          'content': 'คุณช่วยพยาบาลคัดกรองห้องฉุกเฉิน อ่านคำเล่าอาการสำคัญแล้วเลือกตัวเลือกที่คำเล่าบอกไว้ '
              'ตอบ JSON เท่านั้น รูปแบบ {"items":[{"pick":"ตัวเลือก","quote":"ข้อความที่คัดลอกจากคำเล่าตรงตัว"}],"pain":null,'
              '"vs":{"sbp":null,"dbp":null,"hr":null,"rr":null,"bt":null,"spo2":null,"dtx":null}} '
              'pick เลือกจาก ${jsonEncode(opts)} '
              'ทุกตัวต้องมี quote ที่คัดลอกจากคำเล่าตรงตัว (สั้นที่สุดที่ยืนยันได้) ห้ามเดาอาการที่คำเล่าไม่ได้พูดถึง '
              'type:อุบัติเหตุ = บาดเจ็บจากเหตุภายนอก (ชน ล้ม ตก ถูกทำร้าย สัตว์กัดต่อย ไฟไหม้ ฯลฯ) '
              'type:ฉุกเฉิน = เจ็บป่วยที่อันตราย/รอไม่ได้ '
              'pain = คะแนนปวด 0-10 ถ้าบอกเป็นตัวเลข ไม่งั้น null '
              'vs = สัญญาณชีพที่คำเล่าบอกเป็นตัวเลขเท่านั้น (ความดัน ชีพจร การหายใจ อุณหภูมิ ออกซิเจน น้ำตาล) ไม่บอก = null '
              'gcs:E/V/M = GCS เลือกเฉพาะเมื่อคำเล่าบอกระดับชัด (เช่น ไม่ลืมตา = gcs:E1) ห้ามเดาจากอาการอื่น '
              'loc: = ระดับความรู้สึกตัว (ตื่นดี สับสน ซึม ซึมมาก ไม่รู้สึกตัว) '
              'อาการที่ถูกปฏิเสธ (เช่น ไม่มีไข้) ไม่ต้องเลือก',
        },
        {'role': 'user', 'content': text},
      ], fast: true, json: true, temperature: 0.0, maxTokens: 450)
          .timeout(const Duration(seconds: 12));
      final j =
          jsonDecode(raw.substring(raw.indexOf('{'), raw.lastIndexOf('}') + 1));
      if (!mounted || _regCtl('cc').text.trim() != text) return;
      _qCcApply([
        for (final it in (j['items'] as List? ?? const []))
          if (it is Map &&
              opts.contains('${it['pick']}'.trim()) &&
              '${it['quote'] ?? ''}'.trim().isNotEmpty &&
              text.contains('${it['quote']}'.trim()) &&
              // M (การเคลื่อนไหว) จาก AI ต้องมีวลีบอกระดับชัดในคำที่ยก (กันเดา เช่น "ทำตามคำสั่งไม่ได้" ≠ M3)
              _qGcsQuoteOk('${it['pick']}'.trim(), '${it['quote']}'))
            '${it['pick']}'.trim(),
        if (j['pain'] is num) 'pain:${(j['pain'] as num).round()}',
        // ค่าสัญญาณชีพต้องมีตัวเลขนั้นอยู่ในคำเล่าจริง (กันเดาค่า)
        if (j['vs'] is Map)
          for (final e in (j['vs'] as Map).entries)
            if (e.value is num &&
                const ['sbp', 'dbp', 'hr', 'rr', 'bt', 'spo2', 'dtx']
                    .contains(e.key) &&
                text.contains(
                    (e.value as num) == (e.value as num).roundToDouble()
                        ? '${(e.value as num).round()}'
                        : '${e.value}'))
              'vs:${e.key}:${(e.value as num) == (e.value as num).roundToDouble() ? (e.value as num).round() : e.value}',
      ]);
    } catch (_) {
      // ไม่มีเน็ต/รูปแบบผิด: ใช้ผลจากกฎคำอย่างเดียว
    } finally {
      if (mounted) setState(() => _qCcAiBusy = false);
    }
  }

  /// GCS M จาก AI ใช้ได้เมื่อคำที่ยกมามีวลีของระดับนั้น (_qGcsRules) · ตัวเลือกอื่นผ่านเสมอ
  bool _qGcsQuoteOk(String pick, String quote) {
    if (!pick.startsWith('gcs:M')) return true;
    final q = quote.replaceAll(' ', '');
    final words =
        _qGcsRules.where((r) => r.$1 == pick.substring(4)).expand((r) => r.$2);
    return words.any(q.contains);
  }

  /// ผู้ใช้เอาตัวเลือกที่ระบบเลือกออกเอง = จำไว้ ไม่เลือกให้ซ้ำ
  void _qCcForget(String key) {
    if (_qCcAuto.remove(key)) _qCcNo.add(key);
  }

  /// ยกเลิกทุกอย่างที่ระบบเลือกจากคำเล่า
  void _qCcUndoAll() {
    HapticFeedback.selectionClick();
    setState(() {
      for (final p in _qCcAuto) {
        final i = p.indexOf(':');
        final kind = p.substring(0, i), v = p.substring(i + 1);
        if (kind == 'type') _triType.remove(v);
        if (kind == 'cc') _qCc.remove(v);
        if (kind == 'pain') _triPain = null;
        if (kind == 'vs') {
          final j = v.indexOf(':');
          final c = _triCtl(v.substring(0, j));
          if (c.text.trim() == v.substring(j + 1)) c.clear();
        }
        if (kind == 'gcs') {
          if (v.startsWith('E')) _triE = null;
          if (v.startsWith('V')) _triV = null;
          if (v.startsWith('M')) _triM = null;
        }
        if (kind == 'loc') _triLoc = null;
      }
      _qCcNo.addAll(_qCcAuto);
      _qCcAuto.clear();
    });
  }

  /// ไมค์ในช่องคำเล่า: แตะเพื่อพูด / แตะเพื่อส่ง (ไม่เปิดไมค์เอง) · ได้ข้อความ = ต่อท้ายแล้ววิเคราะห์ทันที
  Future<void> _qCcMic() async {
    final sp = _qCcSp ??= ErSpeechInput();
    final before = sp.state;
    await sp.toggle();
    if (!mounted) return;
    if (before == ErSpeechState.listening &&
        sp.state == ErSpeechState.success &&
        sp.transcript.trim().isNotEmpty) {
      final c = _regCtl('cc');
      final cur = c.text.trim();
      c.text =
          cur.isEmpty ? sp.transcript.trim() : '$cur ${sp.transcript.trim()}';
      _qCcChanged();
      _qCcTimer?.cancel();
      unawaited(_qCcAi(c.text.trim()));
    }
    setState(() {});
  }

  String _qClock(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// ค้นหา/อ่านบัตร (จำลอง): พบประวัติใน HIS แล้วเติมข้อมูลให้ตรวจทาน
  void _qLookup() {
    HapticFeedback.selectionClick();
    setState(() {
      // ได้ข้อมูลผู้ป่วยแล้ว = ออกจากหน้าแรก เข้าสู่การคัดกรองหน้าอาการทันที
      // (ข้อมูลจาก HOSxP ครบแล้ว ไม่ต้องผ่านหน้าประวัติ)
      _qIntro = false;
      _qTab = 'คัดกรอง';
      _qSubOf['คัดกรอง'] = 'อาการ';
      _regUnknown = false;
      _qNew = false;
      _qFound = true;
      _qLastWt = (68.0, 170.0, DateTime(2026, 8, 14));
      // น้ำหนัก ส่วนสูง เติมจาก visit ล่าสุดให้เลย (แก้ได้)
      _triCtl('wt').text = '68';
      _triCtl('ht').text = '170';
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
      _qLastWt = null;
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
    // ผู้ป่วยใหม่: ออก HN ใหม่ (ถ้ายังไม่ได้กดออกจากหน้าสรุป)
    if (_qNew && _regHn.isEmpty) _regHn = _regNewHn();
    _regSent[_regHn] = (_qArrive, _qCc.toList(), _regAllergy.toList());
    _triVsCommit(_regHn);
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
    // fast track ที่เปิดตอนคัดกรองติดไปกับผู้ป่วย (นาฬิกาเดินจากเวลาเปิด)
    _ftOpened[_regHn] = Map.of(_triFt);
    _ftReal.add(_regHn);
    _ftCriteria[_regHn] = _triFtCriteria();
    _regCount++;
    ErFeedback.confirm();
    unawaited(Posthog().capture(
      eventName: 'patient_quick_triaged',
      properties: {
        if (resus ? 1 : esi case final l?) 'triage_level': l,
        'sent_to_resuscitation': resus,
        if (_triPtype()?.name case final t?) 'patient_type': t,
      },
    ).catchError((_) {}));
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
              color: on ? const Color(0xFFE2EAF8) : _panel,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: on ? _blue : const Color(0xFFDADCE0),
                  width: on ? 1.5 : 0.5),
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
          // พิมพ์ในช่องเลย ไม่เปิดหน้าย่อย (ผู้ใช้ 2026-11-27 "ไม่เอาหน้าย่อยแบบนี้")
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
        // แตะทั้งแถว = พิมพ์ในแถวเลย (ไม่เปิดหน้าย่อย)
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

  /// แถวตัวเลือก (หน้าตาเดียวกับ [_qChipRow]) ผูกกับค่าภายนอก เช่น เพศ ([_regSex])
  Widget _qChoiceRow(
          String label, List<String> opts, String? v, ValueChanged<String> pick,
          {bool last = false}) =>
      Container(
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
                  child: _qOpt(o, null, v == o, () => pick(o), h: 40.0),
                ),
            ]),
          ),
        ]),
      );

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
  /// ประวัติแพ้ยา: แผ่นเลือกจากรายการชุดเดียวกับทั้งแอป (_listFlow) · เลือกได้หลายตัว
  /// ค้นหาไม่เจอ = แถว "เพิ่ม" พิมพ์ชื่อยาเองได้
  void _qAllergySheet() {
    HapticFeedback.selectionClick();
    _listFlow([
      _ListStep('ประวัติแพ้ยา', _qMaster('er_drug_allergy'),
          many: true,
          custom: true,
          current: () => _regAllergy.join('\n'),
          apply: (v) => setState(() {
                _regAllergy
                  ..clear()
                  ..addAll(v.split('\n').where((x) => x.trim().isNotEmpty));
                if (_regAllergy.isNotEmpty) _regNoAllergy = false;
              })),
    ]);
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
  /// หน้าสรุปก่อนส่งตรวจ: ข้อมูลทุกแท็บในหน้าเดียว แต่ละการ์ดกด "แก้ไข" กลับไปแท็บนั้น
  Widget _qSummary(Widget esi) {
    String? txt(String k) {
      final t = _regCtl(k).text.trim();
      return t.isEmpty ? null : t;
    }

    String? f(String k) {
      final v = _triVal(k);
      if (v == null) return null;
      return v == v.roundToDouble() ? '${v.toInt()}' : '$v';
    }

    final dob = _regDob;
    final age = dob == null ? null : DateTime.now().year - dob.year;
    final news = _triNews();
    final risk = _triNewsRisk();
    final gcs = _triCtl('gcs').text;
    String? pupil(String side) {
      final mm = _triPupil[side];
      if (mm == null) return null;
      final r = _triPupil['${side}r'];
      return '$mm มม.${r == null ? '' : ' $r'}';
    }

    Widget kv(String k, String? v, {bool red = false, Widget? trail}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
              crossAxisAlignment: trail == null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130.0,
                  child: Text(k,
                      style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                ),
                Expanded(
                  child: Text(v ?? 'ยังไม่ได้กรอก',
                      style: _t(14.0,
                          color: v == null
                              ? _g5
                              : red
                                  ? _red
                                  : _inkTitle,
                          weight:
                              v == null ? FontWeight.w500 : FontWeight.w600)),
                ),
                if (trail != null) trail,
              ]),
        );

    Widget card(String title, String tab, String? sub, List<Widget> rows) =>
        Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 12.0, 14.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Text(title,
                    style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _qTab = tab;
                  if (sub != null) _qSubOf[tab] = sub;
                }),
                child: Text('แก้ไข',
                    style: _t(13.0, color: _blue, weight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 4.0),
            ...rows,
          ]),
        );

    final vs = [
      (
        'BP',
        f('sbp') == null || f('dbp') == null
            ? null
            : '${f('sbp')}/${f('dbp')} mmHg'
      ),
      ('HR', f('hr') == null ? null : '${f('hr')} bpm'),
      ('RR', f('rr') == null ? null : '${f('rr')} /min'),
      ('BT', f('bt') == null ? null : '${f('bt')} °C'),
      ('SpO₂', f('spo2') == null ? null : '${f('spo2')} %'),
      ('DTX', f('dtx') == null ? null : '${f('dtx')} mg/dL'),
      ('น้ำหนัก', f('wt') == null ? null : '${f('wt')} kg'),
      ('ส่วนสูง', f('ht') == null ? null : '${f('ht')} cm'),
    ];
    final cc = [..._qCc, if (txt('cc') case final c?) c];

    // แผง ESI ชิดบนขวา · ซ้าย = หัวข้อ + การ์ดสรุปเลื่อนได้
    // (แผง ESI มี Expanded ข้างใน ใส่ใน scroll ไม่ได้)
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('สรุปก่อนส่งตรวจ',
                style: _t(28.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 4.0),
            Text('ตรวจทานข้อมูลทั้งหมด แล้วยืนยันระดับ ESI เพื่อส่งตรวจ',
                style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
            const SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      card('ผู้ป่วย', 'ประวัติ', 'ผู้ป่วย', [
                        kv(
                            'ชื่อ',
                            txt('name') == null
                                ? null
                                : '${_regPick['prefix'] ?? ''}${txt('name')}'),
                        kv(
                            'HN',
                            _regHn.isEmpty
                                ? (_qNew
                                    ? 'ผู้ป่วยใหม่ (ออก HN เมื่อส่งตรวจ)'
                                    : null)
                                : _regHn,
                            // ผู้ป่วยใหม่: ออก HN ได้เลยจากหน้าสรุป ไม่ต้องรอส่งตรวจ
                            trail: _qNew && _regHn.isEmpty
                                ? _miniBtn(Icons.badge_outlined, 'ออก HN',
                                    () => setState(() => _regHn = _regNewHn()),
                                    tooltip: 'ออก HN ใหม่ให้ผู้ป่วย')
                                : null),
                        kv(
                            'เพศ อายุ',
                            _regSex == null
                                ? null
                                : '$_regSex${age == null ? '' : ' $age ปี'}'),
                        kv('โทรศัพท์', txt('phone')),
                        kv(
                            'แพ้ยา',
                            _regAllergy.isEmpty
                                ? 'ไม่มีประวัติแพ้ยา'
                                : _regAllergy.join(', '),
                            red: _regAllergy.isNotEmpty),
                      ]),
                      card('การมาถึง', 'ประวัติ', 'การมาถึง', [
                        kv('เวลามาถึง',
                            '${_clock(_qClock(_qAt))}${_qShift == null ? '' : '  $_qShift'}'),
                        kv('มาโดย', _qArrive),
                        kv('ประเภทการมา', _qArrType),
                        kv('ผู้นำส่ง', _qBringer),
                        kv('ผู้แจ้งข้อมูล', _qInformant),
                      ]),
                      card('อาการ', 'คัดกรอง', 'อาการ', [
                        kv('ประเภทผู้ป่วย',
                            _triType.isEmpty ? null : _triType.join(', ')),
                        kv('อาการสำคัญ', cc.isEmpty ? null : cc.join(', ')),
                        kv(
                            'Red flag',
                            _triRedHits().isEmpty
                                ? 'ไม่เข้าเกณฑ์'
                                : _triRedHits()
                                    .map((h) => '${h.$1} (${h.$2.join(', ')})')
                                    .join(', '),
                            red: _triRedHits().isNotEmpty),
                      ]),
                      card('สัญญาณชีพ', 'คัดกรอง', 'สัญญาณชีพ', [
                        for (final (k, v) in vs) kv(k, v),
                        kv(
                            'NEWS2',
                            news == null || risk == null
                                ? null
                                : '${news.$1} คะแนน ${risk.$1}',
                            red: (risk?.$3 ?? 0) >= 2),
                        kv(
                            'GCS',
                            gcs.isEmpty
                                ? null
                                : '$gcs/15  ${_triE ?? ''} ${_triV ?? ''} ${_triM ?? ''}'
                                    .trim(),
                            red: (int.tryParse(gcs) ?? 15) <= 12),
                        kv(
                            'รูม่านตา',
                            pupil('R') == null && pupil('L') == null
                                ? null
                                : 'ขวา ${pupil('R') ?? '-'}  ซ้าย ${pupil('L') ?? '-'}'),
                        kv('ระดับความปวด',
                            _triPain == null ? null : '$_triPain/10',
                            red: (_triPain ?? 0) >= 7),
                      ]),
                      card('ระดับ ESI', 'คัดกรอง', 'ระดับ ESI', [
                        kv('ช่วยชีวิต / เสี่ยง',
                            _triRisk.isEmpty ? 'ไม่มี' : _triRisk.join(', '),
                            red: _triRisk.isNotEmpty),
                        kv(
                            'กิจกรรมที่ต้องทำ',
                            _triAct.isEmpty
                                ? null
                                : _triAct
                                    .map((a) =>
                                        a == 'ไม่มี' ? 'ไม่มีกิจกรรม' : a)
                                    .join(', ')),
                      ]),
                    ]),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 16.0),
        SizedBox(width: 320.0, child: esi),
      ]),
    );
  }

  /// ถ่ายภาพบัตร (จำลอง): ผู้ป่วยรายนี้ส่งตรวจไปแล้ว = เตือนก่อนเปิดซ้ำ แล้วพาไปเคสเดิม
  Future<void> _qReadDup() async {
    if (_qReading) return;
    HapticFeedback.mediumImpact();
    setState(() => _qReading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _qReading = false);
    final p = _patients.first;
    final at = DateTime.now().subtract(Duration(minutes: p.waitMin));
    const stage = {
      _Stage.triage: 'รอคัดกรอง',
      _Stage.waitDoctor: 'รอตรวจ',
    };
    HapticFeedback.heavyImpact();
    showDialog<void>(
      context: context,
      barrierColor: const Color(0x66101828),
      builder: (ctx) => Dialog(
        backgroundColor: _panel,
        insetPadding: const EdgeInsets.all(24.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        child: SizedBox(
          width: 440.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded,
                      size: 24.0, color: _blue),
                ),
                const SizedBox(height: 14.0),
                Text('ผู้ป่วยรายนี้ส่งตรวจไปแล้ว',
                    style: _t(18.0, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(height: 4.0),
                Text('ไม่ต้องลงทะเบียนซ้ำ ไปต่อที่เคสเดิมได้เลย',
                    style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                const SizedBox(height: 16.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: _t(15.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        const SizedBox(height: 2.0),
                        Text('HN ${p.hn}',
                            style: _t(12.5,
                                color: _ink2, weight: FontWeight.w500)),
                        const SizedBox(height: 10.0),
                        Text(
                            'ส่งตรวจเมื่อ ${_clock(_qClock(at))}  ${stage[p.stage] ?? ''} ${p.waitMin} นาที',
                            style: _t(12.5,
                                color: _ink2, weight: FontWeight.w600)),
                      ]),
                ),
                const SizedBox(height: 20.0),
                Row(children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.0,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFDADCE0), width: 0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('ปิด',
                            style: _t(14.0,
                                color: _ink2, weight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48.0,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _closeRegister();
                          _openPatient(p);
                        },
                        icon: const Icon(Icons.arrow_forward_rounded,
                            size: 18.0, color: Colors.white),
                        label: Text('ไปที่เคสนี้',
                            style: _t(14.0,
                                color: Colors.white, weight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// อ่านบัตรประชาชน (จำลองขั้นตอนจริง เต็มจอ): ค้นหาเครื่องอ่าน → พบบัตร → อ่านข้อมูลจากชิป (ข้อมูลส่วนตัว
  /// ที่อยู่ รูปถ่าย พร้อม %) → ค้นประวัติใน HOSxP → สำเร็จ แล้วเข้าหน้าคัดกรอง · [noDevice] = จำลองไม่พบเครื่อง
  Future<void> _qRead({bool noDevice = false}) async {
    if (_qRdStep >= 0 && !_qRdNoDev) return;
    HapticFeedback.mediumImpact();
    final run = ++_qRdRun;
    setState(() {
      _qRdView = true;
      _qRdNoDev = false;
      _qRdStep = 0;
      _qRdPct = 0.0;
      _qRdItem = '';
    });
    bool alive() => mounted && run == _qRdRun && _qRdView;
    Future<bool> wait(int ms) async {
      await Future.delayed(Duration(milliseconds: ms));
      return alive();
    }

    if (!await wait(1200)) return;
    if (noDevice) {
      HapticFeedback.heavyImpact();
      setState(() {
        _qRdNoDev = true;
        _qRdOnline = false;
      });
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _qRdStep = 1;
      _qRdOnline = true;
    });
    if (!await wait(800)) return;
    setState(() => _qRdStep = 2);
    for (final (item, to) in const [
      ('ข้อมูลส่วนตัว', 0.4),
      ('ที่อยู่', 0.65),
      ('รูปถ่าย', 1.0)
    ]) {
      setState(() => _qRdItem = item);
      while (_qRdPct < to - 1e-6) {
        if (!await wait(40)) return;
        setState(() => _qRdPct = math.min(to, _qRdPct + 0.02));
      }
      if (!await wait(160)) return;
    }
    HapticFeedback.selectionClick();
    setState(() => _qRdStep = 3);
    if (!await wait(1000)) return;
    HapticFeedback.mediumImpact();
    // เสร็จ: เติมข้อมูลผู้ป่วยจริง (ชุดเดียวกับ _qLookup) แต่ยังอยู่หน้าจออ่านบัตร
    // แสดงสรุปผู้ป่วยที่อ่านได้ + ปุ่ม "เข้าสู่การคัดกรอง" (ไปต่อเองเมื่อครบ 3 วินาที)
    _qLookup();
    setState(() {
      _qIntro = true;
      _qRdStep = 4;
    });
    if (!await wait(3200)) return;
    _qReadContinue();
  }

  /// จบการอ่านบัตร → เข้าหน้าคัดกรอง (ข้อมูลถูกเติมไว้แล้วตอนอ่านเสร็จ)
  void _qReadContinue() {
    if (_qRdStep != 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _qRdRun++;
      _qRdView = false;
      _qRdStep = -1;
      _qIntro = false;
    });
  }

  /// เปิดหน้าจออ่านบัตร (ยังไม่อ่าน): รอผู้ใช้เสียบบัตรแล้วกด "เริ่มอ่านบัตร" · [noDevice] = สาธิตไม่พบเครื่อง
  void _qReadOpen({bool noDevice = false}) {
    HapticFeedback.selectionClick();
    final rb = _qReadKey.currentContext?.findRenderObject() as RenderBox?;
    final st = _qStageKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb != null && st != null && rb.hasSize) {
      _qMorphFrom = rb.localToGlobal(Offset.zero, ancestor: st) & rb.size;
    }
    _qKind = 'read';
    setState(() {
      _qRdRun++;
      _qRdView = true;
      _qRdNoDev = false;
      _qRdDemoNoDev = noDevice;
      _qRdStep = -1;
      _qRdPct = 0.0;
      _qRdItem = '';
    });
  }

  /// บัตรในหน้าคัดกรองด่วน (ไม่มีหน้าจออ่านบัตร): อ่านเร็วแบบเดิม
  Future<void> _qReadQuick() async {
    if (_qReading) return;
    HapticFeedback.mediumImpact();
    setState(() => _qReading = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    _qLookup();
    setState(() => _qReading = false);
  }

  void _qReadCancel() {
    HapticFeedback.selectionClick();
    setState(() {
      _qRdRun++;
      _qRdView = false;
      _qRdNoDev = false;
      _qRdStep = -1;
    });
  }

  /// ป้ายในแถบแฟ้มของการ์ดวิธีดึงข้อมูล: pill เส้นขอบ ตัวเข้ม (แบบภาพอ้างอิง)
  /// ความกว้างป้าย (ใช้กำหนดความกว้างแถบแฟ้มให้พอดีป้าย)
  double _qTagW(String label, {bool lead = false}) {
    final tp = TextPainter(
        text: TextSpan(text: label, style: _t(12.0, weight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
        maxLines: 1)
      ..layout();
    return tp.width + (lead ? 6.0 + 18.0 + 5.0 : 12.0) + 12.0 + 2.0;
  }

  Widget _qTag(String label,
          {Widget? lead, Color? color, Color? fill, Color? border}) =>
      Container(
        height: 28.0,
        padding: EdgeInsets.fromLTRB(lead == null ? 12.0 : 6.0, 0.0, 12.0, 0.0),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: border ?? color ?? _ink3, width: 1.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (lead != null) ...[lead, const SizedBox(width: 5.0)],
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(12.0,
                    color: color ?? _inkTitle, weight: FontWeight.w600)),
          ),
        ]),
      );

  /// ป้ายสถานะเครื่องอ่านบัตร (การ์ดอ่านบัตร): พร้อม = เหรียญถูก · ไม่พบ (ครั้งล่าสุด) = ข้อความแดง
  Widget _qReaderTag() => _qRdOnline
      // พร้อม = ป้ายเขียวทึบ ตัวขาว + วงถูกขาว (ตามที่ผู้ใช้กำหนด)
      ? _qTag('เครื่องอ่านพร้อม',
          color: Colors.white,
          border: _green,
          fill: _green,
          lead: const Icon(Icons.check_circle_rounded,
              size: 18.0, color: Colors.white))
      : _qTag('ไม่พบเครื่องอ่าน', color: _red);

  /// การ์ดวิธีดึงข้อมูล: หัวเว้าแบบแฟ้ม (แถบซ้ายสูง ป้ายอยู่ในแถบ · ขั้นเว้าลง) ชื่อตัวใหญ่ (ทั้งการ์ดคือปุ่ม)
  /// ครึ่งล่าง = ภาพเต็มกว้างชิดขอบล่าง (ตัดตามรูปการ์ด) · ขาว ขอบเทา 0.5 ไม่มีเงา
  Widget _qMethodCard(
      {required Widget tag,
      required String title,
      required Widget image,
      required VoidCallback onTap,
      VoidCallback? onLong,
      bool compact = false,
      bool enabled = true,
      int lines = 1,
      double imageW = 118.0,
      Offset imageOut = const Offset(6.0, 10.0),
      required double tagW}) {
    final tab = 14.0 + tagW + 12.0;
    // ปิดใช้ (เช่น ไม่พบเครื่องอ่าน): จาง แตะไม่ได้ (กดค้างยังใช้ได้ถ้ามี)
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: _qMethodCardBody(
          tab, tag, title, image, enabled ? onTap : null, onLong, compact,
          lines: lines, imageW: imageW, imageOut: imageOut),
    );
  }

  Widget _qMethodCardBody(double tab, Widget tag, String title, Widget image,
      VoidCallback? onTap, VoidCallback? onLong, bool compact,
      {int lines = 1,
      double imageW = 118.0,
      Offset imageOut = const Offset(6.0, 10.0)}) {
    return _Press(
      scale: 0.98,
      radius: 22.0,
      child: GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap();
              },
        onLongPress: onLong,
        child: CustomPaint(
          foregroundPainter: _QFolderTabEdge(tab),
          child: ClipPath(
            clipper: _QFolderTabClip(tab),
            child: ColoredBox(
              color: _panel,
              // เล็ก = ภาพแท็บเล็ตทางขวา ใต้ไหล่แฟ้ม (ชิดขวาล่าง ล้นขอบได้) · ใหญ่ = ภาพครึ่งล่าง
              child: Stack(children: [
                if (compact)
                  Positioned(
                      right: -imageOut.dx,
                      bottom: -imageOut.dy,
                      top: _QFolderTabClip.notch + 10.0,
                      width: imageW,
                      child: image),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(14.0, 10.0, 12.0, 0.0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: tag)),
                            ]),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, compact ? 4.0 : 8.0,
                            compact ? 110.0 : 16.0, 0.0),
                        child: Text(title,
                            maxLines: compact ? lines : 2,
                            overflow: TextOverflow.ellipsis,
                            style: _t(compact ? 17.0 : 19.0,
                                color: _inkTitle,
                                weight: FontWeight.w500,
                                height: 1.25)),
                      ),
                      if (!compact)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: image,
                          ),
                        ),
                    ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  /// ภาพการ์ดอ่านบัตร: เครื่องอ่านบัตรขยับ (บัตรเข้าช่อง ไฟ shimmer) ไม่มีพื้นสี
  Widget _qImgReader() => const Padding(
        padding: EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 10.0),
        child: Center(child: _QReaderArt(reading: false)),
      );

  /// ภาพการ์ดถ่ายภาพบัตร: พยาบาลถือบัตรแล้วใช้แท็บเล็ตถ่าย (Figma 1318:109 ตัดพื้นหลัง เติมผมส่วนบน
  /// บัตรในมือ/บนจอวาดใหม่เป็นบัตรประชาชน: แถบหัว ตรา ชิปทอง รูปขวา แถบข้อความ)
  /// ภาพตัดขอบขวา/ล่างอยู่แล้ว = ชิดมุมขวาล่างของการ์ด (ขอบภาพจบที่ขอบการ์ดพอดี)
  // ภาพ + idle motion ในพิกัดเดียวกับ viewBox ของ SVG ต้นฉบับ ([vw]×[vh]) · ย่อพอดีกรอบ ชิดขวาล่าง
  Widget _qIdleArt(String asset, double vw, double vh, _QIdle idle) =>
      FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomRight,
        child: SizedBox(
          width: vw,
          height: vh,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(asset, fit: BoxFit.fill),
            idle,
          ]),
        ),
      );

  /// idle: ทุก ~4 วินาที แท็บเล็ตถ่ายภาพ = จอบัตรวาบขาว แล้วเหรียญถูกเด้งที่มุมบัตร (จับภาพได้)
  Widget _qImgPhoto() => _qIdleArt(
      'assets/images/er_intake_cam.png',
      512.0,
      576.0,
      const _QIdle(
          period: 4200, dur: 1700, delay: 1400, painter: _QIdlePhoto.new));

  /// ภาพการ์ดสแกนใบหน้า: มือถือแท็บเล็ต จอเป็นรูปหน้าผู้ป่วยในมุมกรอบสแกนเขียว (ชิ้นส่วนจาก Figma 1318:109)
  /// idle: เส้นสแกนเขียวกวาดบนลงล่างผ่านรูปหน้าทุก ~3.6 วินาที
  Widget _qImgFace(String face, {bool small = false}) => _qIdleArt(
      'assets/images/er_intake_face.png',
      226.0,
      240.0,
      const _QIdle(
          period: 3600, dur: 1500, delay: 900, painter: _QIdleFace.new));

  /// ภาพการ์ดค้นหา HN: มือถือแท็บเล็ต จอเป็นช่องค้นหา + แถวผลลัพธ์ที่พบผู้ป่วย
  /// idle: พิมพ์ HN ในช่องค้นหา (แถบค่อย ๆ โผล่) แล้วแถวผลลัพธ์ขึ้นทุก ~4.8 วินาที
  Widget _qImgHn(String face, {bool small = false}) => _qIdleArt(
      'assets/images/er_intake_hn.png',
      226.0,
      240.0,
      const _QIdle(
          period: 4800, dur: 2600, delay: 1800, painter: _QIdleHn.new));

  /// ผลการอ่านบัตร (ขั้นเสร็จ): การ์ดผู้ป่วย (รูปจากบัตร · ชื่อ · HN · อายุ · เลขบัตรปิดบางส่วน · แพ้ยา)
  /// + ปุ่ม "เข้าสู่การคัดกรอง" ที่ค่อย ๆ เติมเต็มใน 3 วินาทีแล้วไปต่อเอง (แตะเพื่อไปทันที) · ยกเลิกได้
  Widget _qReadResult() {
    final age = _regDob == null ? null : DateTime.now().year - _regDob!.year;
    Widget meta(String k, String v) => Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(children: [
            SizedBox(
              width: 64.0,
              child: Text(k,
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(v,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _num(13.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
          ]),
        );
    return _QRise(
      delay: 0,
      dy: 16.0,
      ms: 420,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(clipBehavior: Clip.none, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: _regPhoto == null
                    ? Container(
                        width: 72.0,
                        height: 88.0,
                        color: const Color(0xFFDBE5FC))
                    : Image.asset(_regPhoto!,
                        width: 72.0, height: 88.0, fit: BoxFit.cover),
              ),
              const Positioned(
                right: -8.0,
                bottom: -8.0,
                child: SizedBox.square(
                    dimension: 26.0,
                    child: FittedBox(child: _SoStatusCoin.done())),
              ),
            ]),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_regName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(18.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const SizedBox(height: 2.0),
                    meta('HN', _regHn),
                    if (age != null) meta('อายุ', '$age ปี'),
                    meta('เลขบัตร', _qMaskCid(_regCtl('cid').text)),
                    if (_regAllergy.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE8E6),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Text('แพ้ยา ${_regAllergy.join(', ')}',
                            style:
                                _t(12.0, color: _red, weight: FontWeight.w700)),
                      ),
                    ],
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 20.0),
        // ปุ่มหลัก: แถบเติมเต็มใน 3 วินาที = ไปต่อเอง
        _Press(
          radius: 100.0,
          child: GestureDetector(
            onTap: _qReadContinue,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: SizedBox(
                height: 48.0,
                child: Stack(fit: StackFit.expand, children: [
                  ColoredBox(color: _blue.withValues(alpha: 0.75)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 3200),
                    builder: (context, k, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: k,
                      child: const ColoredBox(color: _blue),
                    ),
                  ),
                  Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('เข้าสู่การคัดกรอง',
                          style: _t(15.0,
                              color: Colors.white, weight: FontWeight.w700)),
                      const SizedBox(width: 6.0),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 18.0, color: Colors.white),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Center(
          child: _Press(
            radius: 100.0,
            child: GestureDetector(
              onTap: _qReadCancel,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Text('ไม่ใช่ผู้ป่วยรายนี้',
                    style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  /// เปิดหน้าค้นหาด้วย HN: การ์ด "ค้นหาโดย HN" ขยายเป็นการ์ดใหญ่กลางจอ (ช่องค้นหาโฟกัสทันที)
  void _qSearchOpen() {
    HapticFeedback.selectionClick();
    final hb = _qHnKey.currentContext?.findRenderObject() as RenderBox?;
    final st = _qStageKey.currentContext?.findRenderObject() as RenderBox?;
    if (hb != null && st != null && hb.hasSize) {
      _qMorphFromHn = hb.localToGlobal(Offset.zero, ancestor: st) & hb.size;
    }
    _qKind = 'hn';
    _regCtl('q').clear();
    setState(() => _qHnView = true);
  }

  /// เปิดหน้าถ่ายภาพบัตร: ขยายจากการ์ดในเมนู (แบบการ์ดอ่านบัตร)
  void _qCamOpen({bool face = false}) {
    HapticFeedback.selectionClick();
    final cb = (face ? _qFaceKey : _qCamKey).currentContext?.findRenderObject()
        as RenderBox?;
    final st = _qStageKey.currentContext?.findRenderObject() as RenderBox?;
    if (cb != null && st != null && cb.hasSize) {
      final r = cb.localToGlobal(Offset.zero, ancestor: st) & cb.size;
      if (face) {
        _qMorphFromFace = r;
      } else {
        _qMorphFromCam = r;
      }
    }
    _qKind = face ? 'face' : 'cam';
    setState(() {
      _qCamFace = face;
      _qCamOn = true;
      _qCamStage = 0;
    });
  }

  /// สแกนใบหน้า: การ์ดใหญ่แบบเดียวกับถ่ายภาพบัตร (ขยายจากการ์ดในเมนู)
  void _qFaceOpen() => _qCamOpen(face: true);

  void _qCamClose() {
    HapticFeedback.selectionClick();
    setState(() => _qCamOn = false);
  }

  /// ถ่าย: เปิดหน้ากล้องเต็มจอ (กรอบบัตร + ชัตเตอร์) · ได้ภาพ = แสดงในช่องกล้องของการ์ด
  /// + อ่านข้อมูลจากภาพ แล้วหดกลับ ไปผลเดิมของการ์ดนี้ (พบว่าผู้ป่วยส่งตรวจไปแล้ว)
  /// สแกนใบหน้า: กล้องหน้าเต็มจอ (กรอบวงรี) → เทียบใบหน้า แล้วหดกลับ ไปหน้าผลผู้ป่วยที่หน้าตรงกัน
  Future<void> _qCamShoot() async {
    if (_qCamStage != 0) return;
    HapticFeedback.selectionClick();
    final face = _qCamFace;
    final text = _t(15.0, color: Colors.white, weight: FontWeight.w600);
    final shot = face
        ? await showFaceCamera(context, simFace: _qSimFace, text: text)
        : await showIdCardCamera(context,
            simCard: const _QIdCard(w: 290.0), text: text);
    if (shot == null || !mounted || !_qCamOn) return;
    setState(() {
      _qCamShot = shot;
      _qCamStage = 1;
    });
    if (face) {
      // เทียบใบหน้า แล้วแสดงผลในการ์ดเดิม (ไม่เปิดหน้าต่างใหม่)
      final path = shot.isEmpty ? _qSimFace : shot;
      final Uint8List bytes;
      try {
        bytes = path.startsWith('assets/')
            ? (await rootBundle.load(path)).buffer.asUint8List()
            : await XFile(path).readAsBytes();
      } catch (_) {
        return;
      }
      final hits =
          _faceRank(bytes, male: path.startsWith('assets/images/er_face3d'));
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted || !_qCamOn || _qCamStage != 1) return;
        HapticFeedback.mediumImpact();
        setState(() {
          _qFaceHits = hits;
          _qFaceSel = 0;
          _qCamStage = 2;
        });
      });
      return;
    }
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted || !_qCamOn) return;
      setState(() => _qCamOn = false);
      Future.delayed(const Duration(milliseconds: 620), () {
        if (mounted) _qReadDup();
      });
    });
  }

  /// เปิดเคสผู้ป่วยที่เลือกจากผลสแกนใบหน้า (ไม่ต้องลงทะเบียนซ้ำ)
  void _qFaceOpenSel() {
    if (_qFaceHits.isEmpty) return;
    final hn = _qFaceHits[_qFaceSel.clamp(0, _qFaceHits.length - 1)].$1;
    final p = _patients.where((x) => x.hn == hn).firstOrNull;
    if (p == null) return;
    HapticFeedback.selectionClick();
    setState(() => _qCamOn = false);
    _faceOpenPatient(p);
  }

  /// สแกนใหม่ = กลับไปเล็งกรอบในการ์ดเดิม
  void _qFaceRescan() {
    HapticFeedback.selectionClick();
    setState(() {
      _qCamStage = 0;
      _qFaceHits = const [];
    });
  }

  /// ไม่มีในรายชื่อ = ขั้นเลือกวิธีลงทะเบียนผู้ป่วยใหม่ในการ์ดเดิม (ไม่ทิ้งไปหน้าฟอร์มเปล่า)
  void _qFaceRegisterNew() {
    HapticFeedback.selectionClick();
    setState(() => _qCamStage = 3);
  }

  /// ผู้ป่วยใหม่ → อ่านบัตรประชาชน (ปิดการ์ดนี้ แล้วเปิดการ์ดอ่านบัตร)
  void _qFaceNewRead() {
    HapticFeedback.selectionClick();
    setState(() => _qCamOn = false);
    Future.delayed(const Duration(milliseconds: 620), () {
      if (mounted) _qReadOpen();
    });
  }

  /// ผู้ป่วยใหม่ → ถ่ายภาพบัตร (เปลี่ยนการ์ดนี้เป็นโหมดถ่ายภาพบัตร ไม่ต้องปิดเปิดใหม่)
  void _qFaceNewPhoto() {
    HapticFeedback.selectionClick();
    _qKind = 'cam';
    setState(() {
      _qCamFace = false;
      _qCamStage = 0;
      _qFaceHits = const [];
    });
  }

  /// ผู้ป่วยใหม่ → ไม่ทราบชื่อ ลงทะเบียนก่อน (ทางเดียวกับปุ่มในเมนู)
  void _qFaceNewUnknown() {
    HapticFeedback.selectionClick();
    setState(() => _qCamOn = false);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _regUnknown = true;
        _qFound = false;
        _regSex ??= 'ไม่ระบุ';
        if (_regHn.isEmpty) _regHn = _regNewHn();
        _qIntro = false;
      });
    });
  }

  /// ไม่มีในรายชื่อ (คอลัมน์ขวา): ยังไม่มีประวัติ = ผู้ป่วยใหม่ เลือกวิธีระบุตัวตน (แถวรายการ ไม่มีปุ่มแข่งกัน)
  Widget _qFaceNewOptions() => Column(
          key: const ValueKey('face-new'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ยังไม่มีประวัติในระบบ',
                style: _t(24.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 2.0),
            Text('ลงทะเบียนเป็นผู้ป่วยใหม่ เลือกวิธีที่สะดวก',
                style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
            const SizedBox(height: 14.0),
            _gListRow(
              first: true,
              lead: const _McGIcon(Icons.credit_card_rounded, navy: true),
              title: 'อ่านบัตรประชาชน',
              sub: 'เสียบบัตรที่เครื่องอ่าน ได้ข้อมูลครบที่สุด',
              onTap: _qFaceNewRead,
            ),
            _gListRow(
              lead: const _McGIcon(Icons.photo_camera_rounded, navy: true),
              title: 'ถ่ายภาพบัตรประชาชน',
              sub: 'ใช้กล้องของเครื่องนี้ เมื่อไม่มีเครื่องอ่านบัตร',
              onTap: _qFaceNewPhoto,
            ),
            _gListRow(
              lead: const _McGIcon(Icons.person_off_rounded, navy: true),
              title: 'ไม่ทราบชื่อ ลงทะเบียนก่อน',
              sub: 'ผู้ป่วยไม่มีบัตรหรือพูดไม่ได้ ระบุตัวตนทีหลัง',
              onTap: _qFaceNewUnknown,
            ),
            const SizedBox(height: 18.0),
            Align(
              alignment: Alignment.centerLeft,
              child: _qPill('กลับไปดูรายชื่อ', () {
                HapticFeedback.selectionClick();
                setState(() => _qCamStage = 2);
              }),
            ),
          ]);

  /// ผลสแกนใบหน้า (คอลัมน์ขวาของการ์ด): การ์ดผู้ป่วยรายที่เลือก (ภาษาเดียวกับผลอ่านบัตร) +
  /// รายอื่นที่หน้าคล้ายเป็นแถวรายการ (แตะ = เลือก) · ปุ่มหลัก "เปิดเคส" อยู่ในรอยเว้าการ์ด · "สแกนใหม่" บนช่องกล้อง
  Widget _qFaceResult() {
    final hits = [
      for (final (hn, sc) in _qFaceHits)
        for (final p in _patients)
          if (p.hn == hn) (p, sc),
    ];
    if (hits.isEmpty) return const SizedBox();
    final sel = _qFaceSel.clamp(0, hits.length - 1);
    final (p, sc) = hits[sel];
    final c = erCaseOf(p.hn);
    Widget meta(String k, String v) => Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(children: [
            SizedBox(
              width: 64.0,
              child: Text(k,
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(v,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _num(13.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
          ]),
        );
    final others = [
      for (final (i, h) in hits.indexed)
        if (i != sel) (i, h),
    ];
    return Column(
        key: ValueKey('face-res-$sel'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('พบผู้ป่วยที่หน้าตรงกัน',
              style: _t(24.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 2.0),
          Text('ถามชื่อให้ตรงกับข้อมูลก่อนเปิดเคสทุกครั้ง',
              style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
          const SizedBox(height: 12.0),
          // รายที่เลือก: การ์ดซ้อน ขาว ขอบ 0.5 (แบบผลอ่านบัตร)
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(_faceUrl(p.hn),
                    width: 60.0, height: 72.0, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(p.name,
                                  maxLines: 2,
                                  style: _t(18.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8.0),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${(sc * 100).round()}%',
                                      style: _num(20.0,
                                          color: _blue,
                                          weight: FontWeight.w700)),
                                  Text('ความคล้าย',
                                      style: _t(11.0,
                                          color: _ink3,
                                          weight: FontWeight.w500)),
                                ]),
                          ]),
                      meta('HN', p.hn),
                      meta('อายุ', c.ageText),
                      if (c.allergies.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE8E6),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text('แพ้ยา ${c.allergies.join(', ')}',
                              style: _t(12.0,
                                  color: _red, weight: FontWeight.w700)),
                        ),
                      ],
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 12.0),
          if (others.isNotEmpty) ...[
            Text('หน้าคล้ายรายอื่น แตะเพื่อเลือก',
                style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
            for (final (j, (i, (q, s2))) in others.indexed)
              _gListRow(
                first: j == 0,
                compact: true,
                lead: ClipOval(
                  child: Image.asset(_faceUrl(q.hn),
                      width: 36.0, height: 36.0, fit: BoxFit.cover),
                ),
                title: q.name,
                sub: 'HN ${q.hn}',
                trail: Text('${(s2 * 100).round()}%',
                    style: _num(14.0, color: _ink2, weight: FontWeight.w600)),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _qFaceSel = i);
                },
              ),
          ],
          // ไม่มีใครตรง = ตัวเลือกสุดท้ายของรายการ (ไม่ใช่ปุ่มแข่งกับปุ่มหลัก)
          _gListRow(
            first: others.isEmpty,
            compact: true,
            lead: const SizedBox.square(
                dimension: 36.0,
                child: FittedBox(
                    child:
                        _McGIcon(Icons.person_add_alt_1_rounded, navy: true))),
            title: 'ไม่มีในรายชื่อนี้',
            sub: 'ลงทะเบียนเป็นผู้ป่วยใหม่',
            onTap: _qFaceRegisterNew,
          ),
          // ปุ่มหลัก "เปิดเคส" อยู่ในรอยเว้ามุมขวาล่างของการ์ด · "สแกนใหม่" อยู่บนช่องกล้อง
          // เว้นที่เหนือรอยเว้า (รายการไม่ทับปุ่มหลัก)
          const SizedBox(height: 40.0),
        ]);
  }

  /// ภาพใบหน้าจำลอง (เครื่องไม่มีกล้อง) = หุ่น 3D มองตรง (ภาพเดียวกับช่องกล้อง [FaceSim])
  String get _qSimFace => FaceSim.frames.first;

  void _qSearchClose() {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _qHnView = false);
  }

  /// เปิดโหมดอุบัติเหตุหมู่ (จากหน้าส่งตรวจ หรือจากคำถาม MCI ในหน้าคัดกรอง)
  /// เปิดเป็นการ์ดใหญ่ขยายจากการ์ดในเมนู (แบบการ์ดอ่านบัตร): เหตุการณ์ที่ยังรับอยู่ หรือขั้นตอน + ปุ่มเปิดเหตุการณ์
  void _mciOpen() {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    final mb = _qMciKey.currentContext?.findRenderObject() as RenderBox?;
    final st = _qStageKey.currentContext?.findRenderObject() as RenderBox?;
    if (mb != null && st != null && mb.hasSize) {
      _qMorphFromMci = mb.localToGlobal(Offset.zero, ancestor: st) & mb.size;
    }
    _qKind = 'mci';
    final m = _mci;
    final live = m.events.lastIndexWhere((e) => e.active);
    setState(() {
      _qIntro = true;
      m.on = true;
      if (live >= 0) m.cur = live;
      m.step = 5;
    });
  }

  /// เริ่มเหตุการณ์ใหม่ = กลุ่มถัดไป (A B C …) · ร่างที่ยังไม่ได้เริ่มรับถูกทิ้ง
  void _mciNewEvent() {
    final m = _mci;
    m.events.removeWhere((e) => e.blank);
    m.events.add(_MciEvent(m.nextGroup()));
    m
      ..cur = m.events.length - 1
      ..step = 0;
    _regCtl('mciPlace').clear();
  }

  /// เปิดภาพรวมของกลุ่ม [e] (การ์ดกลุ่มในแผงรายชื่อ)
  void _mciOpenBoard(_MciEvent e) {
    _openQuickRegister();
    _qKind = 'mci';
    final m = _mci;
    setState(() => m
      ..on = true
      ..cur = m.events.indexOf(e)
      ..step = 3);
  }

  /// สลับไปดูกลุ่มอื่นในภาพรวม
  void _mciPickGroup(_MciEvent e) {
    HapticFeedback.selectionClick();
    final m = _mci;
    setState(() => m
      ..cur = m.events.indexOf(e)
      ..step = 3);
  }

  void _mciClose() {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    final m = _mci;
    setState(() {
      m.on = false;
      // ร่างที่ยังไม่ได้เริ่มรับ = ทิ้ง
      final keep = m.events.isEmpty ? null : m.ev;
      m.events.removeWhere((e) => e.blank);
      m.cur = keep == null ? 0 : math.max(0, m.events.indexOf(keep));
    });
  }

  void _mciGo(int step) {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _mci.step = step);
  }

  void _mciSetExpected(int n) {
    HapticFeedback.selectionClick();
    setState(() => _mci.expected = n.clamp(1, 99));
  }

  /// เริ่มรับ: จำสถานที่เกิดเหตุ แล้วไปหน้ารับผู้บาดเจ็บ
  void _mciStart() {
    HapticFeedback.mediumImpact();
    FocusManager.instance.primaryFocus?.unfocus();
    final m = _mci;
    setState(() {
      m.place = _regCtl('mciPlace').text.trim();
      m.active = true;
      m.openedAt = DateTime.now();
      m.step = 1;
    });
  }

  String _mciNewHn() {
    final m = _mci;
    m.hnBase ??= int.parse(_regNewHn());
    return '${m.hnBase! + m.hnSeq++}';
  }

  /// รับผู้บาดเจ็บ 1 ราย ตามสีที่คัดแยก: ได้ HN และอันดับถัดไปของสีนั้นทันที
  void _mciAdd(int tag) {
    HapticFeedback.lightImpact();
    final m = _mci;
    final c =
        _MciCase(_mciNewHn(), tag, m.nextNo(tag), DateTime.now(), m.ev.group);
    setState(() {
      m.cases.add(c);
      m.sortCases();
      m.lastHn = c.hn;
    });
  }

  /// เปลี่ยนสี (คัดแยกซ้ำ): ได้อันดับถัดไปของสีใหม่
  void _mciRetag(_MciCase c, int tag) {
    if (c.tag == tag) return;
    HapticFeedback.selectionClick();
    final m = _mci;
    setState(() {
      c
        ..tag = tag
        ..no = m.nextNo(tag);
      m.sortCases();
      m.lastHn = c.hn;
    });
  }

  Future<void> _mciRemove(_MciCase c) async {
    final ok = await _paperDialog<bool>(context,
        heading: 'ลบ ${c.name}?',
        sub: 'ลบออกจากรายการที่ยังไม่ได้ส่ง เลขอันดับนี้จะไม่ถูกใช้ซ้ำ',
        actions: const [('ยกเลิก', false, false), ('ลบ', true, true)]);
    if (ok != true || !mounted) return;
    setState(() => _mci.cases.remove(c));
  }

  /// ส่งทุกรายเข้าห้องฉุกเฉินทีเดียว: สีที่มี ESI = รอตรวจตามระดับ · ดำ = อยู่ในรายชื่อคัดกรอง (พื้นที่แยก)
  void _mciSend() {
    final m = _mci;
    final n = m.cases.length;
    if (n == 0) return;
    var colored = false;
    for (final c in m.cases.reversed) {
      final t = _mciTags[c.tag];
      final lv = t.esi;
      if (lv != null) colored = true;
      _patients.insert(
          0,
          _P(c.hn, c.name, lv != null ? _Stage.waitDoctor : _Stage.triage, 0,
              esi: lv == null ? null : _Esi.values[lv - 1],
              type: _Ptype.trauma,
              note: 'อุบัติเหตุหมู่ ${t.dest}'));
      m.sent[c.hn] = c;
    }
    m.cases.clear();
    m.lastHn = null;
    _regCount += n;
    ErFeedback.confirm();
    unawaited(Posthog().capture(
      eventName: 'mci_registered',
      properties: {'patient_count': n},
    ).catchError((_) {}));
    setState(() {
      m.on = false;
      m.listOnly = true;
      _regOpen = false;
      _regQuick = false;
      _open = colored ? _Phase.of(_Stage.waitDoctor) : _Phase.triage;
      _listFilter = _ListFilter.all;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ส่งผู้บาดเจ็บอุบัติเหตุหมู่ $n ราย เข้าห้องฉุกเฉินแล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  void _mciPrint() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            'ส่งป้ายข้อมือ ${_mci.cases.length} ใบ ไปที่เครื่องพิมพ์แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  /// รายชื่อผู้บาดเจ็บสำหรับแจ้งญาติ: ชื่อ (จริงหรือชั่วคราว) + จุดที่อยู่
  Future<void> _mciRelatives() async {
    final m = _mci;
    await _paperDialog<bool>(context,
        heading: 'รายชื่อผู้บาดเจ็บ กลุ่ม ${m.ev.group}',
        sub: 'ใช้แจ้งญาติและติดประกาศ',
        icon: Icons.groups_rounded,
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final p in _patients)
            if (m.sent.containsKey(p.hn))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(children: [
                  Expanded(
                    child: Text(p.name,
                        style: _t(14.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                  ),
                  Text(_mciTags[m.sent[p.hn]!.tag].dest,
                      style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                ]),
              ),
        ]),
        actions: const [('ปิด', true, true)]);
  }

  Future<void> _mciEnd() async {
    final ok = await _paperDialog<bool>(context,
        heading: 'จบเหตุการณ์ กลุ่ม ${_mci.ev.group}?',
        sub:
            'หยุดรับผู้บาดเจ็บของกลุ่มนี้ ผู้ที่ยังไม่ระบุตัวตนยังอยู่ในรายการรอระบุตัวตน',
        icon: Icons.flag_rounded,
        actions: const [('ยกเลิก', false, false), ('จบเหตุการณ์', true, true)]);
    if (ok != true || !mounted) return;
    final m = _mci;
    setState(() {
      final e = m.ev;
      e
        ..active = false
        ..cases.clear();
      m.on = false;
      // ระบุตัวตนครบแล้ว = ปิดกลุ่มนี้ไปเลย (การ์ดในแผงรายชื่อหายไป)
      if (e.waiting.isEmpty) m.events.remove(e);
      m.cur = math.max(0, math.min(m.cur, m.events.length - 1));
      if (m.events.every((x) => x.sent.isEmpty)) m.listOnly = false;
      if (m.events.every((x) => !x.active)) {
        m
          ..hnBase = null
          ..hnSeq = 0;
      }
    });
  }

  void _mciIdentifyOpen(String hn) {
    HapticFeedback.selectionClick();
    _regCtl('mciId').clear();
    _regCtl('mciName').clear();
    setState(() => _mci
      ..identifyHn = hn
      ..idMethod = -1
      ..idReading = false
      ..idFound = false
      ..step = 4);
  }

  /// เลือกวิธีระบุตัวตน · อ่านบัตร = จำลองอ่าน 0.9 วิ แล้วพบในระบบ
  void _mciIdMethod(int k) {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    final m = _mci;
    setState(() {
      m
        ..idMethod = k
        ..idFound = false
        ..idReading = k == 0;
    });
    if (k == 0) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted || m.idMethod != 0) return;
        setState(() => m
          ..idReading = false
          ..idFound = true);
      });
    }
  }

  /// ค้นหา: ต้องตรงทั้งค่า (HN เลขบัตร หรือเบอร์โทร) เหมือนหน้าค้นหา HN
  void _mciIdSearch(String q) {
    final d = q.replaceAll(RegExp(r'[\s-]'), '');
    setState(() => _mci.idFound =
        d == _mciRec.hn || d == _mciRec.cid || d == _mciRec.phone);
  }

  /// รวมเวชระเบียน (พบในระบบ) หรือบันทึกชื่อจริง (ผู้ป่วยใหม่): ถามยืนยันก่อน
  Future<void> _mciMerge() async {
    final m = _mci;
    final hn = m.identifyHn;
    if (hn == null) return;
    final i = _patients.indexWhere((p) => p.hn == hn);
    if (i < 0) return;
    final manual = m.idMethod == 2;
    final name = manual ? _regCtl('mciName').text.trim() : _mciRec.name;
    if (name.isEmpty) return;
    final newHn = manual ? hn : _mciRec.hn;
    if (!manual && m.isMci(newHn)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('HN $newHn รวมกับผู้บาดเจ็บรายอื่นไปแล้ว',
              style: _t(12.0, color: Colors.white))));
      return;
    }
    final old = _patients[i].name;
    final ok = await _paperDialog<bool>(context,
        heading: manual ? 'บันทึกชื่อจริง?' : 'รวมเวชระเบียน?',
        sub: manual
            ? '$old จะเปลี่ยนเป็น $name แล้วพิมพ์ป้ายข้อมือใหม่'
            : 'ประวัติของ $old ย้ายไปอยู่ $name HN $newHn',
        icon: Icons.how_to_reg_rounded,
        actions: [
          ('ยกเลิก', false, false),
          (manual ? 'บันทึก' : 'รวม', true, true)
        ]);
    if (ok != true || !mounted) return;
    final p = _patients[i];
    setState(() {
      _patients[i] = _P(newHn, name, p.stage, p.waitMin,
          esi: p.esi, bed: p.bed, note: p.note, type: p.type);
      final c = m.sent.remove(hn);
      if (c != null) m.sent[newHn] = c;
      m.identified.add(newHn);
      m.identifyHn = null;
      m.step = 3;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ระบุตัวตน $name แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  /// เลือกผู้ป่วยจากผลค้นหา → เติมข้อมูลจาก HOSxP แล้วเข้าหน้าคัดกรอง
  void _qSearchPick() {
    FocusManager.instance.primaryFocus?.unfocus();
    _qLookup();
    setState(() => _qHnView = false);
  }

  // ---------------------------------------------------------------- อุบัติเหตุหมู่: ชิ้นส่วน UI

  /// ปุ่ม pill ของการ์ดใหญ่ (หลัก = กรมท่าทึบ · รอง = ขาวขอบเทา) · onTap null = จาง กดไม่ได้
  Widget _mciPill(String label, VoidCallback? onTap, {bool primary = false}) =>
      Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: _Press(
          radius: 100.0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 46.0,
              // กว้างขั้นต่ำ: ปุ่มใน footer อยู่ตำแหน่งเดิมทุกหน้า แม้ข้อความยาวไม่เท่ากัน
              constraints: BoxConstraints(minWidth: primary ? 200.0 : 120.0),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                color: primary ? _blue : _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: primary ? null : Border.all(color: _line),
              ),
              // กว้างตามข้อความ (ไม่ยืดเต็มแผงเมื่ออยู่ใน Column stretch)
              child: Center(
                widthFactor: 1.0,
                child: Text(label,
                    style: _t(15.0,
                        color: primary ? Colors.white : _inkTitle,
                        weight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      );

  /// ลิงก์ข้อความ (การกระทำรองที่ไม่ใช่ปุ่มหลักของแผง)
  Widget _mciLink(String label, VoidCallback onTap, {Color? color}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          child: Text(label,
              style: _t(13.5, color: color ?? _blue, weight: FontWeight.w600)),
        ),
      );

  Widget _mciChip(String label, bool on, VoidCallback onTap) => _Press(
        radius: 100.0,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 36.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: on ? _blue : _panel,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: on ? _blue : _line),
            ),
            // กว้างตามข้อความ (ใน Wrap ถ้าใช้ alignment จะยืดเต็มแถว)
            child: Center(
              widthFactor: 1.0,
              child: Text(label,
                  style: _t(13.0,
                      color: on ? Colors.white : _inkTitle,
                      weight: FontWeight.w600)),
            ),
          ),
        ),
      );

  /// ตัวเลือกแบบแบ่งช่อง (เพศ วัย): แตะช่องที่เลือกอยู่ซ้ำ = ล้าง
  Widget _mciSeg(
          List<String> opts, String? value, ValueChanged<String?> pick) =>
      Container(
        height: 30.0,
        // ขอบวาดทับด้านบน (ช่องที่เลือกทาสีไม่ทับเส้นขอบ)
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: _line),
        ),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(100.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final o in opts)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                pick(value == o ? null : o);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                alignment: Alignment.center,
                color: value == o ? _blue : _panel,
                child: Text(o,
                    style: _t(12.0,
                        color: value == o ? Colors.white : _ink2,
                        weight: FontWeight.w600)),
              ),
            ),
        ]),
      );

  /// วงแทนรูปหน้าของผู้บาดเจ็บที่ยังไม่ระบุตัวตน: ขอบสีคัดแยก + เลขอันดับ
  Widget _mciAvatar(int tag, int no, double size) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _panelSoft,
          border: Border.all(color: _mciTags[tag].color, width: 3.0),
        ),
        child: Text('$no',
            style:
                _num(size * 0.36, color: _inkTitle, weight: FontWeight.w700)),
      );

  /// วงเลขอันดับ (ทึบสีคัดแยก) ใช้ในรายการรับ/ป้ายข้อมือ
  Widget _mciToken(int tag, int no, {double size = 40.0}) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: _mciTags[tag].color),
        child: Text('$no',
            style:
                _num(size * 0.38, color: _mciOn(tag), weight: FontWeight.w700)),
      );

  String _mciTime(DateTime t) => _clock(
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');

  Widget _mciLabel(String s) =>
      Text(s, style: _t(13.0, color: _ink2, weight: FontWeight.w600));

  // ---------------------------------------------------------------- 1 เริ่มรับเหตุการณ์
  Widget _mciSetupView() {
    final m = _mci;
    Widget round(IconData ic, VoidCallback? onTap) => Opacity(
          opacity: onTap == null ? 0.35 : 1.0,
          child: _Press(
            radius: 100.0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: _panel,
                  shape: BoxShape.circle,
                  border: Border.all(color: _line),
                ),
                child: Icon(ic, size: 22.0, color: _inkTitle),
              ),
            ),
          ),
        );
    return Row(
        key: const ValueKey('mci-setup'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 320.0,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // สีคัดแยกที่ใช้ในขั้นถัดไป: แต่ละสีไปจุดรักษาไหน (ไม่มีระดับแผน: แต่ละ รพ. ใช้ชื่อ/เกณฑ์ต่างกัน)
                  _mciLabel('สีคัดแยก'),
                  const SizedBox(height: 4.0),
                  Text(
                      'แตะสีตามป้ายที่คัดแยกหน้าประตู แต่ละสีไปจุดรักษาของสีนั้น',
                      style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  const SizedBox(height: 14.0),
                  for (var t = 0; t < _mciTags.length; t++) ...[
                    if (t > 0) const SizedBox(height: 8.0),
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Row(children: [
                        Container(
                            width: 14.0,
                            height: 14.0,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _mciTags[t].color)),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${_mciTags[t].name} ${_mciTags[t].meaning}',
                                    style: _t(14.0,
                                        color: _inkTitle,
                                        weight: FontWeight.w600)),
                                Text(_mciTags[t].dest,
                                    style: _t(12.0,
                                        color: _ink3, weight: FontWeight.w500)),
                              ]),
                        ),
                      ]),
                    ),
                  ],
                ]),
          ),
          const SizedBox(width: 32.0),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('อุบัติเหตุหมู่ กลุ่ม ${m.ev.group}',
                  style: _t(26.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(height: 4.0),
              Text(
                  'ผู้บาดเจ็บมาพร้อมกันหลายรายและยังไม่ทราบตัวตน ลงทะเบียนชั่วคราวตามสีที่คัดแยก',
                  style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
              const SizedBox(height: 14.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _mciLabel('จำนวนผู้บาดเจ็บที่แจ้งมา'),
                        const SizedBox(height: 6.0),
                        Row(children: [
                          round(
                              Icons.remove_rounded,
                              m.expected > 1
                                  ? () => _mciSetExpected(m.expected - 1)
                                  : null),
                          SizedBox(
                            width: 64.0,
                            child: Text('${m.expected}',
                                textAlign: TextAlign.center,
                                style: _num(34.0,
                                    color: _blue, weight: FontWeight.w700)),
                          ),
                          Text('ราย',
                              style: _t(14.0,
                                  color: _ink3, weight: FontWeight.w500)),
                          const SizedBox(width: 12.0),
                          round(
                              Icons.add_rounded,
                              m.expected < 99
                                  ? () => _mciSetExpected(m.expected + 1)
                                  : null),
                          const SizedBox(width: 12.0),
                          Flexible(
                            child: Text('จาก 1669 หรือหน่วยกู้ภัย',
                                style: _t(12.0,
                                    color: _ink3, weight: FontWeight.w500)),
                          ),
                        ]),
                        const SizedBox(height: 14.0),
                        _mciLabel('สถานที่เกิดเหตุ'),
                        const SizedBox(height: 6.0),
                        Container(
                          height: 46.0,
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(100.0),
                            border: Border.all(color: _blue, width: 1.4),
                          ),
                          child: TextField(
                            controller: _regCtl('mciPlace'),
                            style: _t(15.0,
                                color: _inkTitle, weight: FontWeight.w600),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText:
                                  'เช่น ถนนพหลโยธิน กม. 12 (ใช้เป็นที่อยู่ชั่วคราวของทุกราย)',
                              hintStyle: _t(14.0,
                                  color: _ink3, weight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        _mciLabel('ประเภทเหตุ'),
                        const SizedBox(height: 6.0),
                        Wrap(spacing: 8.0, runSpacing: 8.0, children: [
                          for (final k in _mciKinds)
                            _mciChip(k, m.kind == k, () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                m.kind = k;
                                // อุบัติเหตุจราจร = ใช้สิทธิ พ.ร.บ. ให้เอง
                                m.right = k == 'อุบัติเหตุจราจร'
                                    ? _mciRights.first
                                    : _mciRights.last;
                              });
                            }),
                        ]),
                        const SizedBox(height: 14.0),
                        _mciLabel('สิทธิการรักษาตอนส่งตรวจ'),
                        const SizedBox(height: 6.0),
                        Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              for (final r in _mciRights)
                                _mciChip(r, m.right == r, () {
                                  HapticFeedback.selectionClick();
                                  setState(() => m.right = r);
                                }),
                            ]),
                      ]),
                ),
              ),
            ]),
          ),
        ]);
  }

  // ---------------------------------------------------------------- 2 รับผู้บาดเจ็บ
  Widget _mciReceiveView() {
    final m = _mci;
    Widget colorButton(int t) {
      final c = _mciTags[t];
      final fg = _mciOn(t);
      final n = m.cases.where((x) => x.tag == t).length;
      return Expanded(
        child: _Press(
          radius: 18.0,
          scale: 0.97,
          child: GestureDetector(
            onTap: () => _mciAdd(t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: c.color,
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            style:
                                _t(20.0, color: fg, weight: FontWeight.w700)),
                        Text(c.meaning,
                            style:
                                _t(12.0, color: fg, weight: FontWeight.w500)),
                      ]),
                ),
                Text('$n',
                    style: _num(26.0, color: fg, weight: FontWeight.w700)),
                const SizedBox(width: 3.0),
                Text('ราย',
                    style: _t(12.0, color: fg, weight: FontWeight.w500)),
                const SizedBox(width: 12.0),
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fg.withValues(alpha: t == 1 ? 0.12 : 0.22),
                  ),
                  child: Icon(Icons.add_rounded, size: 22.0, color: fg),
                ),
              ]),
            ),
          ),
        ),
      );
    }

    Widget row(_MciCase c) {
      final fresh = c.hn == m.lastHn;
      return AnimatedContainer(
        key: ValueKey('mci-row-${c.hn}'),
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(10.0, 8.0, 6.0, 8.0),
        decoration: BoxDecoration(
          color: fresh ? const Color(0xFFF5F8FF) : _panel,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
              color: fresh ? _blue : _line, width: fresh ? 1.5 : 1.0),
        ),
        child: Row(children: [
          _mciToken(c.tag, c.no),
          const SizedBox(width: 12.0),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
              Text(
                  'HN ${c.hn} รับเมื่อ ${_mciTime(c.at)}${c.sex == null ? ' ยังไม่ระบุเพศ' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(width: 8.0),
          _mciSeg(const ['ชาย', 'หญิง', 'ไม่ทราบ'], c.sex,
              (v) => setState(() => c.sex = v)),
          const SizedBox(width: 8.0),
          _mciSeg(const ['เด็ก', 'ผู้ใหญ่', 'สูงอายุ'], c.age,
              (v) => setState(() => c.age = v)),
          PopupMenuButton<int>(
            tooltip: 'เปลี่ยนสีหรือลบ',
            icon: const Icon(Icons.more_horiz_rounded, color: _ink2),
            onSelected: (v) => v < 0 ? _mciRemove(c) : _mciRetag(c, v),
            itemBuilder: (_) => [
              for (var t = 0; t < _mciTags.length; t++)
                if (t != c.tag)
                  PopupMenuItem(
                    value: t,
                    child: Row(children: [
                      Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _mciTags[t].color)),
                      const SizedBox(width: 10.0),
                      Text('เปลี่ยนเป็นสี${_mciTags[t].name}',
                          style: _t(14.0,
                              color: _inkTitle, weight: FontWeight.w500)),
                    ]),
                  ),
              PopupMenuItem(
                value: -1,
                child: Text('ลบออกจากรายการ',
                    style: _t(14.0, color: _inkTitle, weight: FontWeight.w500)),
              ),
            ],
          ),
        ]),
      );
    }

    return Column(
        key: const ValueKey('mci-receive'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('รับผู้บาดเจ็บ',
                        style: _t(26.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text(
                        'แตะสีตามป้ายคัดแยกที่หน้าประตู ได้ชื่อชั่วคราวและ HN ทันที แล้วติดป้ายข้อมือเลขเดียวกัน',
                        style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
                  ]),
            ),
            const SizedBox(width: 16.0),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (m.place.isNotEmpty)
                Text(m.place,
                    style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
              Text(
                  'เริ่มรับ ${m.openedAt == null ? '' : _mciTime(m.openedAt!)} ${m.kind}',
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ]),
          ]),
          const SizedBox(height: 14.0),
          Expanded(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 250.0,
                child: Column(children: [
                  for (var t = 0; t < _mciTags.length; t++) ...[
                    if (t > 0) const SizedBox(height: 10.0),
                    colorButton(t),
                  ],
                ]),
              ),
              const SizedBox(width: 22.0),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        _mciLabel('ผู้บาดเจ็บที่รับแล้ว'),
                        const SizedBox(width: 8.0),
                        Text('เรียงตามสี แล้วตามอันดับ',
                            style: _t(12.0,
                                color: _ink3, weight: FontWeight.w500)),
                      ]),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: m.cases.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _panelSoft,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text(
                                    'ยังไม่มีผู้บาดเจ็บ แตะสีทางซ้ายเพื่อรับรายแรก',
                                    style: _t(13.0,
                                        color: _ink2, weight: FontWeight.w500)),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: m.cases.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8.0),
                                itemBuilder: (_, i) => row(m.cases[i]),
                              ),
                      ),
                    ]),
              ),
            ]),
          ),
        ]);
  }

  // ---------------------------------------------------------------- 3 ตรวจก่อนส่ง
  Widget _mciBand(_MciCase c) {
    final col = _mciTags[c.tag].color;
    final at = c.at;
    final meta = [
      'HN ${c.hn}',
      if (c.sex != null) c.sex!,
      if (c.age != null) c.age!,
      if (c.sex == null) 'ยังไม่ระบุเพศ',
    ].join(' ');
    return Container(
      height: 74.0,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        Container(width: 22.0, color: col),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text(meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
                  Text(
                      'อุบัติเหตุหมู่ ${at.day}/${at.month}/${(at.year + 543) % 100} ${_mciTime(at)}',
                      style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
                ]),
          ),
        ),
        // บาร์โค้ดจำลองจากเลข HN
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(children: [
            for (final ch in c.hn.split('')) ...[
              Container(width: 1.0 + (ch.codeUnitAt(0) % 3), color: _inkTitle),
              SizedBox(width: 1.0 + (ch.codeUnitAt(0) % 2) * 2.0),
              Container(width: 1.0, color: _inkTitle),
              const SizedBox(width: 2.0),
            ],
          ]),
        ),
        const SizedBox(width: 10.0),
        Container(width: 22.0, color: col),
      ]),
    );
  }

  Widget _mciReviewView() {
    final m = _mci;
    final n = m.cases.length;
    Widget sumRow(int t) {
      final c = _mciTags[t];
      final k = m.cases.where((x) => x.tag == t).length;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: _line),
        ),
        child: Row(children: [
          Container(
              width: 14.0,
              height: 14.0,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: c.color)),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 58.0,
            child: Text(c.name,
                style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          Text('$k',
              style: _num(16.0, color: _inkTitle, weight: FontWeight.w700)),
          Text(' ราย', style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
          const SizedBox(width: 16.0),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.dest,
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
              Text(
                  c.esi == null
                      ? 'แจ้งแพทย์เวร ไม่เข้าคิวรอตรวจ'
                      : 'เข้าคิวรอตรวจ',
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ]),
          ),
          Text(c.esi == null ? 'ไม่มี ESI' : 'ESI ${c.esi}',
              style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
        ]),
      );
    }

    return Row(
        key: const ValueKey('mci-review'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ตรวจก่อนส่ง',
                      style:
                          _t(26.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text(
                      'ผู้บาดเจ็บแต่ละสีไปยังจุดรักษาของสีนั้น เข้ารายชื่อห้องฉุกเฉินพร้อมกัน',
                      style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
                  const SizedBox(height: 12.0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var t = 0; t < _mciTags.length; t++)
                              if (m.cases.any((x) => x.tag == t)) ...[
                                sumRow(t),
                                const SizedBox(height: 8.0),
                              ],
                            const SizedBox(height: 4.0),
                            Container(
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                color: _panelSoft,
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ข้อมูลที่ใส่ให้ทุกราย',
                                        style: _t(13.0,
                                            color: _inkTitle,
                                            weight: FontWeight.w600)),
                                    const SizedBox(height: 4.0),
                                    for (final s in [
                                      'ที่อยู่ ${m.place.isEmpty ? 'โรงพยาบาล (ไม่ทราบที่เกิดเหตุ)' : m.place}',
                                      'สิทธิ ${m.right}',
                                      'วันเกิด 1 ม.ค. ปีตามวัยที่ประเมิน เลขบัตรประชาชนออกให้ชั่วคราว',
                                    ])
                                      Text(s,
                                          style: _t(13.0,
                                              color: _ink2,
                                              weight: FontWeight.w500)),
                                  ]),
                            ),
                          ]),
                    ),
                  ),
                ]),
          ),
          const SizedBox(width: 24.0),
          Expanded(
            flex: 9,
            child: Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Text('ป้ายข้อมือ',
                          style: _t(14.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      const Spacer(),
                      Text('ตัวอย่าง ${math.min(3, n)} จาก $n ใบ',
                          style:
                              _t(12.0, color: _ink3, weight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 12.0),
                    for (final c in m.cases.take(3)) ...[
                      _mciBand(c),
                      const SizedBox(height: 10.0),
                    ],
                    Text(
                        'แถบสีที่ปลายสองข้างตรงกับสีที่คัดแยก ชื่อบนป้ายใช้ตามหาตัวและรวมเวชระเบียนทีหลัง',
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
          ),
        ]);
  }

  // ---------------------------------------------------------------- 4 ภาพรวมเหตุการณ์
  // ภาษาเดียวกับแผงหน้าผู้ป่วย: การ์ด _dxCard (ชื่อ + คำอธิบาย + ภาพมุมขวา) · การ์ดซ้อนขาวขอบ 0.5 ระยะใน 8
  // · แถวรายการ _gListRow · การกระทำรอง = แผ่นปุ่ม _dxTiles (ไม่ใช้ลิงก์ข้อความ)
  Widget _mciBoardView() {
    final m = _mci;
    _P? pt(String hn) => _patients.where((p) => p.hn == hn).firstOrNull;
    final total = m.sent.length;
    final sub = [
      if (m.place.isNotEmpty) m.kind,
      if (m.openedAt != null) 'เริ่มรับ ${_mciTime(m.openedAt!)}',
      if (!m.active) 'จบเหตุการณ์แล้ว',
    ].join(' ');
    final counts = [
      for (var t = 0; t < _mciTags.length; t++)
        m.sent.values.where((c) => c.tag == t).length
    ];
    final left = _dxCard(
      m.place.isEmpty ? m.kind : m.place,
      sub,
      _mcArt('assets/images/er_ov_emergent_fig.png', whole: true, scale: 0.8),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ยอดรวม (ใหญ่) + แถบแบ่งช่องตามสี (ชุดเดียวกับการ์ดสรุปขั้นบนฉากภาพรวม) + คำอธิบายสี
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$total',
                      style: _num(34.0,
                          color: _inkTitle, weight: FontWeight.w700)),
                  Text(' ราย',
                      style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
                  const SizedBox(width: 8.0),
                  Text('จากที่แจ้ง ${m.expected} ราย',
                      style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
                  const Spacer(),
                  Text('ระบุตัวตนแล้ว ',
                      style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                  Text('${m.identified.length}',
                      style: _num(15.0,
                          color: _inkTitle, weight: FontWeight.w700)),
                  Text(' / $total ราย',
                      style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
                ]),
            const SizedBox(height: 10.0),
            _esiSegBar([
              for (var t = 0; t < _mciTags.length; t++)
                if (counts[t] > 0) (_mciTags[t].color, counts[t]),
            ]),
            const SizedBox(height: 10.0),
            Wrap(spacing: 16.0, runSpacing: 6.0, children: [
              for (var t = 0; t < _mciTags.length; t++)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _mciTags[t].color)),
                  const SizedBox(width: 6.0),
                  Text('${_mciTags[t].name} ',
                      style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                  Text('${counts[t]}',
                      style: _num(13.0,
                          color: _inkTitle, weight: FontWeight.w700)),
                ]),
            ]),
          ]),
        ),
        const SizedBox(height: 16.0),
        _dxTiles([
          (Icons.groups_rounded, 'รายชื่อแจ้งญาติ', _mciRelatives),
          (
            Icons.add_circle_outline_rounded,
            'เหตุการณ์ใหม่',
            () {
              HapticFeedback.selectionClick();
              setState(_mciNewEvent);
            }
          ),
          (Icons.flag_rounded, 'จบเหตุการณ์', m.active ? _mciEnd : null),
        ]),
      ]),
      // หลายเหตุการณ์ = สลับกลุ่มที่หัวการ์ด
      trail: m.shown.length > 1
          ? _tagSwitch([for (final e in m.shown) 'กลุ่ม ${e.group}'],
              'กลุ่ม ${m.ev.group}', (v) {
              final e = m.shown.firstWhere((x) => 'กลุ่ม ${x.group}' == v);
              _mciPickGroup(e);
            })
          : null,
    );
    final right = _dxCard(
      'รอระบุตัวตน ${m.waiting.length} ราย',
      'ถามชื่อให้ตรงกับป้ายข้อมือก่อนทุกครั้ง',
      _mcArt('assets/images/er_hero_personal.png', whole: true),
      m.waiting.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 16.0),
              child: Text('ระบุตัวตนครบทุกรายแล้ว',
                  style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
            )
          : Column(children: [
              for (final (i, hn) in m.waiting.indexed)
                _gListRow(
                  first: i == 0,
                  inset: 8.0,
                  lead: _mciAvatar(m.sent[hn]!.tag, m.sent[hn]!.no, 40.0),
                  title: pt(hn)?.name ?? m.sent[hn]!.name,
                  sub: 'HN $hn ${_mciTags[m.sent[hn]!.tag].dest}',
                  onTap: () => _mciIdentifyOpen(hn),
                ),
            ]),
    );
    return Row(
        key: const ValueKey('mci-board'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 11, child: SingleChildScrollView(child: left)),
          const SizedBox(width: 16.0),
          Expanded(flex: 9, child: SingleChildScrollView(child: right)),
        ]);
  }

  // ---------------------------------------------------------------- 5 ระบุตัวตน
  Widget _mciIdentifyView() {
    final m = _mci;
    final hn = m.identifyHn;
    final c = hn == null ? null : m.sent[hn];
    if (hn == null || c == null) return const SizedBox(key: ValueKey('mci-id'));
    final p = _patients.where((x) => x.hn == hn).firstOrNull;
    final manual = m.idMethod == 2;
    final name = _regCtl('mciName').text.trim();
    final ready = manual ? name.isNotEmpty : m.idFound;
    Widget method(int k, String title, String sub) {
      final on = m.idMethod == k;
      return _Press(
        radius: 16.0,
        scale: 0.98,
        child: GestureDetector(
          onTap: () => _mciIdMethod(k),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: on ? const Color(0xFFF5F8FF) : _panel,
              borderRadius: BorderRadius.circular(16.0),
              border:
                  Border.all(color: on ? _blue : _line, width: on ? 1.5 : 1.0),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
              Text(sub,
                  style: _t(12.0,
                      color: on && k != 2 && m.idFound ? _green : _ink3,
                      weight:
                          on && m.idFound ? FontWeight.w600 : FontWeight.w500)),
            ]),
          ),
        ),
      );
    }

    Widget field(String key, String hint, ValueChanged<String> onChanged) =>
        Container(
          height: 48.0,
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(color: _blue, width: 1.4),
          ),
          child: TextField(
            controller: _regCtl(key),
            autofocus: true,
            onChanged: onChanged,
            style: _t(16.0, color: _inkTitle, weight: FontWeight.w600),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: _t(15.0, color: _ink3, weight: FontWeight.w500),
            ),
          ),
        );
    Widget box(String head, List<Widget> lines, {bool strong = false}) =>
        Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
                color: strong ? _blue : _line, width: strong ? 1.5 : 1.0),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(head,
                style: _t(12.0,
                    color: strong ? _blue : _ink3, weight: FontWeight.w600)),
            const SizedBox(height: 4.0),
            ...lines,
          ]),
        );
    final cid = _mciRec.cid;
    final cidText =
        '${cid[0]}-${cid.substring(1, 5)}-${cid.substring(5, 10)}-${cid.substring(10, 12)}-${cid[12]}';
    return Row(
        key: const ValueKey('mci-id'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 270.0,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _mciAvatar(c.tag, c.no, 42.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p?.name ?? c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(15.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        Text('HN $hn ${_mciTags[c.tag].dest}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(12.0,
                                color: _ink3, weight: FontWeight.w500)),
                      ]),
                ),
              ]),
              const SizedBox(height: 16.0),
              _mciLabel('ระบุด้วย'),
              const SizedBox(height: 8.0),
              method(
                  0,
                  'อ่านบัตรประชาชน',
                  m.idMethod == 0
                      ? (m.idReading ? 'กำลังอ่านบัตร' : 'อ่านแล้ว พบในระบบ')
                      : 'เสียบบัตรที่เครื่องอ่าน'),
              const SizedBox(height: 8.0),
              method(
                  1,
                  'ค้นหาผู้ป่วยในระบบ',
                  m.idMethod == 1 && m.idFound
                      ? 'พบในระบบ'
                      : 'HN เลขบัตร หรือเบอร์โทร'),
              const SizedBox(height: 8.0),
              method(2, 'ผู้ป่วยใหม่ กรอกชื่อเอง',
                  'แก้ชื่อในเวชระเบียนเดิม แล้วพิมพ์ป้ายข้อมือใหม่'),
              const Spacer(),
              Text(
                  'ญาติมาหรือผู้ป่วยรู้สึกตัว ถามชื่อให้ตรงกับป้ายข้อมือก่อนทุกครั้ง',
                  style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(width: 24.0),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(manual ? 'บันทึกชื่อจริง' : 'รวมเวชระเบียน',
                      style:
                          _t(24.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text(
                      manual
                          ? 'ใช้เวชระเบียน HN เดิม เปลี่ยนชื่อชั่วคราวเป็นชื่อจริง'
                          : 'ประวัติการรักษาในครั้งนี้ย้ายไปอยู่ HN จริง ป้ายข้อมือต้องพิมพ์ใหม่',
                      style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
                  const SizedBox(height: 14.0),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (m.idMethod == -1)
                              Container(
                                padding: const EdgeInsets.all(18.0),
                                decoration: BoxDecoration(
                                  color: _panelSoft,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text('เลือกวิธีระบุตัวตนทางซ้าย',
                                    style: _t(13.0,
                                        color: _ink2, weight: FontWeight.w500)),
                              ),
                            if (m.idMethod == 0 && m.idReading)
                              Row(children: [
                                const SizedBox(
                                    width: 18.0,
                                    height: 18.0,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4, color: _blue)),
                                const SizedBox(width: 10.0),
                                Text('กำลังอ่านบัตรประชาชน',
                                    style: _t(14.0,
                                        color: _ink2, weight: FontWeight.w500)),
                              ]),
                            if (m.idMethod == 1) ...[
                              field(
                                  'mciId',
                                  'HN เลขบัตร หรือเบอร์โทร ให้ตรงทั้งหมด',
                                  _mciIdSearch),
                              const SizedBox(height: 12.0),
                              if (!m.idFound &&
                                  _regCtl('mciId').text.isNotEmpty)
                                Text('ยังไม่พบ พิมพ์ให้ตรงทั้งหมด',
                                    style: _t(13.0,
                                        color: _ink3, weight: FontWeight.w500)),
                            ],
                            if (manual) ...[
                              field(
                                  'mciName',
                                  'ชื่อ นามสกุล ตามที่ผู้ป่วยหรือญาติบอก',
                                  (_) => setState(() {})),
                              const SizedBox(height: 12.0),
                            ],
                            if (ready) ...[
                              IntrinsicHeight(
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: box('ชั่วคราว', [
                                          Text(p?.name ?? c.name,
                                              style: _t(16.0,
                                                  color: _inkTitle,
                                                  weight: FontWeight.w700)),
                                          Text('HN $hn',
                                              style: _t(13.0,
                                                  color: _ink2,
                                                  weight: FontWeight.w500)),
                                        ]),
                                      ),
                                      const SizedBox(
                                          width: 36.0,
                                          child: Icon(
                                              Icons.arrow_forward_rounded,
                                              color: _blue)),
                                      Expanded(
                                        child: manual
                                            ? box(
                                                'ชื่อจริง',
                                                [
                                                  Text(name,
                                                      style: _t(16.0,
                                                          color: _inkTitle,
                                                          weight:
                                                              FontWeight.w700)),
                                                  Text('HN $hn (เดิม)',
                                                      style: _t(13.0,
                                                          color: _ink2,
                                                          weight:
                                                              FontWeight.w500)),
                                                ],
                                                strong: true)
                                            : box(
                                                'ผู้ป่วยจริง',
                                                [
                                                  Text(_mciRec.name,
                                                      style: _t(16.0,
                                                          color: _inkTitle,
                                                          weight:
                                                              FontWeight.w700)),
                                                  Text(
                                                      'HN ${_mciRec.hn} อายุ ${_mciRec.age} ปี',
                                                      style: _t(13.0,
                                                          color: _ink2,
                                                          weight:
                                                              FontWeight.w500)),
                                                  Text('เลขบัตร $cidText',
                                                      style: _t(12.5,
                                                          color: _ink2,
                                                          weight:
                                                              FontWeight.w500)),
                                                  const SizedBox(height: 4.0),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 1.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      border: Border.all(
                                                          color: _red),
                                                    ),
                                                    child: Text(
                                                        'แพ้ยา ${_mciRec.allergy}',
                                                        style: _t(12.0,
                                                            color: _red,
                                                            weight: FontWeight
                                                                .w600)),
                                                  ),
                                                ],
                                                strong: true),
                                      ),
                                    ]),
                              ),
                              if (!manual) ...[
                                const SizedBox(height: 12.0),
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: _red.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('ตรวจยาที่ให้ไปแล้ว',
                                            style: _t(13.0,
                                                color: _red,
                                                weight: FontWeight.w700)),
                                        Text(
                                            'ผู้ป่วยแพ้ ${_mciRec.allergy} ตรวจคำสั่งยาที่ให้ระหว่างไม่ทราบตัวตน แล้วแจ้งแพทย์ก่อนรวม',
                                            style: _t(12.5,
                                                color: _ink2,
                                                weight: FontWeight.w500)),
                                      ]),
                                ),
                              ],
                            ],
                          ]),
                    ),
                  ),
                ]),
          ),
        ]);
  }

  /// การ์ดแฟ้มใบใหญ่โหมดอุบัติเหตุหมู่ (ภาษาเดียวกับการ์ดอ่านบัตร/ค้นหา) · เนื้อในเปลี่ยนตามขั้น
  Widget _mciView() {
    final m = _mci;
    // ปิดกลุ่มสุดท้ายแล้ว (ระหว่างการ์ดหดกลับ) = ไม่มีอะไรให้วาด
    if (m.events.isEmpty) return const SizedBox(key: ValueKey('q-mci'));
    final active = m.active;
    final label = 'อุบัติเหตุหมู่ กลุ่ม ${m.ev.group}';
    final tab = 14.0 + _qTagW(label, lead: true) + 12.0 + 6.0;
    final body = switch (m.step) {
      0 => _mciSetupView(),
      1 => _mciReceiveView(),
      2 => _mciReviewView(),
      3 => _mciBoardView(),
      _ => _mciIdentifyView(),
    };
    return Padding(
      key: const ValueKey('q-mci'),
      // dock ซ่อนระหว่างเปิดการ์ด = ใช้ความสูงจอเต็ม (ไม่เว้นล่างให้ dock)
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040.0, maxHeight: 600.0),
          child: CustomPaint(
            foregroundPainter: _QFolderTabEdge(tab),
            child: ClipPath(
              clipper: _QFolderTabClip(tab),
              child: ColoredBox(
                color: _panel,
                child: Stack(children: [
                  Positioned(
                      left: 18.0,
                      top: 12.0,
                      child: active
                          ? _qTag(label,
                              color: Colors.white,
                              fill: _blue,
                              border: _blue,
                              lead: const Icon(Icons.groups_rounded,
                                  size: 18.0, color: Colors.white))
                          : _qTag(label,
                              color: _blue,
                              border: _blue,
                              lead: const Icon(Icons.groups_rounded,
                                  size: 18.0, color: _blue))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 56.0, 28.0, 20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ขั้นลงทะเบียน (เหตุการณ์ → รับ → ตรวจก่อนส่ง) มี stepper บนสุด
                          if (m.step <= 2) ...[
                            Center(
                              child:
                                  SizedBox(width: 520.0, child: _mciStepper()),
                            ),
                            const SizedBox(height: 6.0),
                          ],
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 240),
                              child: body,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Container(height: 1.0, color: _line),
                          const SizedBox(height: 12.0),
                          _mciFooter(),
                        ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ลงทะเบียนส่งตรวจอุบัติเหตุหมู่ (ชื่อเมนูตาม HOSxP): การ์ดแฟ้มใหญ่ที่ขยายจากการ์ดในเมนู แบบเดียวกับการ์ดอ่านบัตร
  /// ซ้าย = ภาพทีมเข็นเปลผู้บาดเจ็บ · ขวา = หัวข้อ + เหตุการณ์ที่ยังรับอยู่ (แตะ = ดูภาพรวม) หรือขั้นตอน + ปุ่ม
  /// [rightOnly] = วาดเฉพาะคอลัมน์ขวา (ไม่มีกรอบ ป้าย ภาพ) ใช้ซ้อนบนการ์ดที่กำลังขยาย
  Widget _mciIntroView({bool rightOnly = false}) {
    final m = _mci;
    final live = [
      for (final e in m.events)
        if (e.active) e
    ];
    final g = m.nextGroup();
    final tab = 14.0 + _qTagW(_mciTagLabel) + 12.0 + 6.0;
    Widget stepRow(String title, String sub) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox.square(
                dimension: 30.0, child: FittedBox(child: _SoStatusCoin.wait())),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                    const SizedBox(height: 1.0),
                    Text(sub,
                        style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
          ]),
        );
    return Padding(
      key: const ValueKey('q-mci-intro'),
      padding: const EdgeInsets.fromLTRB(40.0, 24.0, 40.0, 96.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 940.0, maxHeight: 540.0),
          child: CustomPaint(
            foregroundPainter: rightOnly ? null : _QFolderTabEdge(tab),
            child: ClipPath(
              clipper: _QFolderTabClip(tab),
              child: ColoredBox(
                color: rightOnly ? const Color(0x00000000) : _panel,
                child: Stack(children: [
                  if (!rightOnly)
                    Positioned(
                        left: 18.0, top: 12.0, child: _qTag(_mciTagLabel)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28.0, 56.0, 36.0, 28.0),
                    child: Row(children: [
                      // ซ้าย: ภาพเดียวกับการ์ดในเมนู (ขยายต่อจากภาพเล็ก)
                      Expanded(
                        flex: 11,
                        child: rightOnly
                            ? const SizedBox()
                            : SizedBox.expand(
                                child: _mciArt(at: Alignment.center),
                              ),
                      ),
                      const SizedBox(width: 36.0),
                      Expanded(
                        flex: 9,
                        child: _QRise(
                          delay: 0,
                          dy: 14.0,
                          ms: 360,
                          instant: true,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    live.isEmpty
                                        ? 'ลงทะเบียนส่งตรวจอุบัติเหตุหมู่'
                                        : 'ผู้บาดเจ็บมาจากเหตุการณ์ไหน',
                                    style: _t(26.0,
                                        color: _inkTitle,
                                        weight: FontWeight.w700)),
                                const SizedBox(height: 4.0),
                                Text(
                                    live.isEmpty
                                        ? 'ลงทะเบียนชั่วคราวตามสีที่คัดแยก แล้วระบุตัวตนทีหลัง'
                                        : 'เหตุการณ์เดิม แตะเพื่อดูภาพรวม ถ้าเป็นเหตุอื่นให้เปิดเหตุการณ์ใหม่',
                                    style: _t(14.0,
                                        color: _ink2, weight: FontWeight.w500)),
                                const SizedBox(height: 18.0),
                                if (live.isEmpty) ...[
                                  stepRow('แจ้งจำนวนผู้บาดเจ็บ',
                                      'ตามที่ 1669 หรือหน่วยกู้ภัยแจ้งมา'),
                                  stepRow('ลงทะเบียนตามสีที่คัดแยก',
                                      'ชื่อชั่วคราว เช่น สีแดง อันดับ1'),
                                  stepRow('ส่งเข้าห้องฉุกเฉิน',
                                      'พิมพ์ป้ายข้อมือ แล้วส่งไปจุดรักษาตามสี'),
                                  stepRow('ระบุตัวตนทีหลัง',
                                      'รวมเวชระเบียนเมื่อรู้ชื่อจริง'),
                                ] else
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxHeight: 220.0),
                                    child: ListView(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        children: [
                                          for (final (i, e) in live.indexed)
                                            _gListRow(
                                              first: i == 0,
                                              lead: const _McGIcon(
                                                  Icons.groups_rounded,
                                                  navy: true),
                                              title:
                                                  'กลุ่ม ${e.group} ${e.place.isEmpty ? e.kind : e.place}',
                                              sub: [
                                                if (e.openedAt != null)
                                                  'เริ่มรับ ${_mciTime(e.openedAt!)}',
                                                'รับแล้ว ${e.sent.length + e.cases.length} จาก ${e.expected} ราย',
                                              ].join(' '),
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                setState(() => m
                                                  ..cur = m.events.indexOf(e)
                                                  ..step = 3);
                                              },
                                            ),
                                        ]),
                                  ),
                                // ปุ่มหลักนำหน้า ปุ่มรองตามใต้ (แบบการ์ดอ่านบัตร)
                                const SizedBox(height: 26.0),
                                Wrap(
                                    spacing: 10.0,
                                    runSpacing: 10.0,
                                    children: [
                                      _qPill(
                                          live.isEmpty
                                              ? 'เปิดเหตุการณ์ กลุ่ม $g'
                                              : 'เปิดเหตุการณ์ใหม่ กลุ่ม $g',
                                          () {
                                        HapticFeedback.selectionClick();
                                        setState(_mciNewEvent);
                                      }, primary: true, shimmer: true),
                                      _qPill('ยกเลิก', _mciClose),
                                    ]),
                              ]),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// หน้าถ่ายภาพบัตรประชาชน (การ์ดแฟ้มใหญ่แบบการ์ดอ่านบัตร): ซ้าย = ช่องกล้องพร้อมกรอบบัตรให้เล็ง
  /// ขวา = หัวข้อ ขั้นตอน ปุ่มถ่าย · [rightOnly] = วาดเฉพาะคอลัมน์ขวา ใช้ซ้อนบนการ์ดที่กำลังขยาย
  Widget _qCamPage({bool rightOnly = false}) {
    final face = _qCamFace;
    final tagLabel =
        face ? 'สำหรับผู้ป่วยที่มีในระบบ' : 'ใช้กล้องของเครื่องนี้';
    final tab = 14.0 + _qTagW(tagLabel) + 12.0 + 6.0;
    final shot = _qCamStage >= 1;
    final notched = face && _qCamStage == 2;
    // รอยเว้าพอดีปุ่มหลัก "เปิดเคสผู้ป่วยรายนี้" (สูง 44 + ระยะห่าง 8 · กว้างตามข้อความ + ขอบใน + 8)
    final nw = (TextPainter(
                text: TextSpan(
                    text: 'เปิดเคสผู้ป่วยรายนี้',
                    style: _t(14.0, weight: FontWeight.w700)),
                textDirection: TextDirection.ltr,
                maxLines: 1)
              ..layout())
            .width +
        44.0 +
        40.0 +
        8.0;
    const nh = 52.0;
    // ข้อความตามแบบ: บัตร = ถ่ายภาพบัตรแล้วอ่านข้อมูล · ใบหน้า = สแกนแล้วเทียบกับรูปในระบบ
    final (title, sub, steps, cta) = face
        ? (
            shot ? 'กำลังเทียบใบหน้า' : 'สแกนใบหน้า',
            shot
                ? 'เทียบกับรูปผู้ป่วย ${_patients.length} รายในห้องฉุกเฉิน'
                : 'ให้ใบหน้าผู้ป่วยอยู่ในกรอบ แล้วกดสแกนใบหน้า',
            [
              ('ให้ใบหน้าอยู่ในกรอบ', 'มองตรงที่กล้อง ใบหน้าเต็มวงรี'),
              ('ถอดแมสก์และแว่นดำ', 'เห็นตา จมูก และปากชัด'),
              ('เทียบกับรูปในระบบ', 'ผู้ป่วยที่มีประวัติใน HOSxP'),
              ('ยืนยันชื่อและ HN', 'ตรวจกับผู้ป่วยก่อนเปิดทุกครั้ง'),
            ],
            'สแกนใบหน้า',
          )
        : (
            shot ? 'กำลังอ่านบัตรจากภาพ' : 'ถ่ายภาพบัตรประชาชน',
            shot
                ? 'ถือเครื่องไว้ก่อน อีกสักครู่'
                : 'วางบัตรด้านหน้าให้พอดีกรอบ แล้วกดถ่ายภาพ',
            [
              ('วางบัตรให้พอดีกรอบ', 'ขอบบัตรชิดมุมกรอบทั้ง 4 มุม'),
              ('ถือให้นิ่ง ไม่มีแสงสะท้อน', 'เห็นเลขบัตรและรูปชัด'),
              ('อ่านข้อมูลจากภาพ', 'เลขบัตร ชื่อ วันเกิด ที่อยู่'),
              ('ค้นหาประวัติใน HOSxP', 'จับคู่เลขบัตรกับ HN'),
            ],
            'ถ่ายภาพ',
          );
    Widget coin(int i) => SizedBox.square(
          dimension: 30.0,
          child: FittedBox(
            child: shot && i < 2
                ? const _SoStatusCoin.done()
                : (shot ? i == 2 : i == 0)
                    ? const _SoStatusCoin.next()
                    : const _SoStatusCoin.wait(),
          ),
        );
    Widget row(int i, String title, String sub) {
      final on = shot ? i == 2 : i == 0;
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        opacity: on || (shot && i < 2) || (!shot && i == 1) ? 1.0 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            coin(i),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: _t(15.0,
                            color: _inkTitle,
                            weight: on ? FontWeight.w700 : FontWeight.w600)),
                    const SizedBox(height: 1.0),
                    Text(sub,
                        style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
          ]),
        ),
      );
    }

    return Padding(
      key: const ValueKey('q-cam'),
      padding: const EdgeInsets.fromLTRB(40.0, 24.0, 40.0, 96.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 940.0, maxHeight: 540.0),
          // ผลสแกนใบหน้า: รอยเว้ามุมขวาล่างของการ์ด วางปุ่มหลัก "เปิดเคส" (โตขึ้นนุ่ม ๆ ตอนผลขึ้น)
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: notched ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            builder: (context, k, _) => Stack(children: [
              Positioned.fill(
                child: CustomPaint(
                  foregroundPainter: rightOnly
                      ? null
                      : _QFolderTabEdge(tab, bw: nw * k, bh: nh * k),
                  child: ClipPath(
                    clipper: _QFolderTabClip(tab, bw: nw * k, bh: nh * k),
                    child: ColoredBox(
                      color: rightOnly ? const Color(0x00000000) : _panel,
                      child: Stack(children: [
                        if (!rightOnly)
                          Positioned(
                              left: 18.0, top: 12.0, child: _qTag(tagLabel)),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(28.0, 56.0, 36.0, 28.0),
                          child: Row(children: [
                            // ซ้าย: ช่องกล้อง + กรอบบัตร (ภาพจำลองจนกว่าจะต่อกล้องจริง)
                            Expanded(
                              flex: 11,
                              child: rightOnly
                                  ? const SizedBox()
                                  : Stack(fit: StackFit.expand, children: [
                                      _QCamFinder(
                                          shot: shot,
                                          done: _qCamStage >= 2,
                                          noMatch: _qCamStage == 3,
                                          photo: shot ? _qCamShot : null,
                                          face: face ? _qSimFace : null),
                                      // สแกนใหม่ = ปุ่มบนช่องกล้อง (สแกนหน้าซ้ำ) ไม่แข่งกับปุ่มหลัก
                                      if (face && _qCamStage >= 2)
                                        Positioned(
                                          left: 0.0,
                                          right: 0.0,
                                          bottom: 16.0,
                                          child: Center(
                                            child: _Press(
                                              radius: 100.0,
                                              child: GestureDetector(
                                                onTap: _qFaceRescan,
                                                child: Container(
                                                  height: 40.0,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0),
                                                  ),
                                                  child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .refresh_rounded,
                                                            size: 18.0,
                                                            color:
                                                                Colors.white),
                                                        const SizedBox(
                                                            width: 6.0),
                                                        Text('สแกนใหม่',
                                                            style: _t(14.0,
                                                                color: Colors
                                                                    .white,
                                                                weight:
                                                                    FontWeight
                                                                        .w600)),
                                                      ]),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ]),
                            ),
                            const SizedBox(width: 36.0),
                            Expanded(
                              flex: 9,
                              child: _QRise(
                                delay: 0,
                                dy: 14.0,
                                ms: 360,
                                instant: true,
                                child: face && _qCamStage >= 2
                                    ? Center(
                                        child: SingleChildScrollView(
                                            child: AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 240),
                                                child: _qCamStage == 3
                                                    ? _qFaceNewOptions()
                                                    : _qFaceResult())))
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                            Text(title,
                                                style: _t(26.0,
                                                    color: _inkTitle,
                                                    weight: FontWeight.w700)),
                                            const SizedBox(height: 4.0),
                                            Text(sub,
                                                style: _t(14.0,
                                                    color: _ink2,
                                                    weight: FontWeight.w500)),
                                            const SizedBox(height: 22.0),
                                            for (final (i, (a, b))
                                                in steps.indexed)
                                              row(i, a, b),
                                            const SizedBox(height: 26.0),
                                            if (!shot)
                                              Wrap(
                                                  spacing: 10.0,
                                                  runSpacing: 10.0,
                                                  children: [
                                                    _qPill(cta, _qCamShoot,
                                                        primary: true,
                                                        shimmer: true),
                                                    _qPill(
                                                        'ยกเลิก', _qCamClose),
                                                  ]),
                                          ]),
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              if (!rightOnly && k > 0.0)
                Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  width: nw,
                  height: nh,
                  child: Opacity(
                    opacity: _qc((k - 0.4) / 0.6),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                      child: _qPill('เปิดเคสผู้ป่วยรายนี้', _qFaceOpenSel,
                          primary: true),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  /// การ์ดถ่ายภาพบัตร (เมนู) → การ์ดใหญ่ แบบต่อเนื่อง: กล้องซูมเข้าไปที่จอแท็บเล็ตในภาพพยาบาล
  /// (หมุนจอให้ตรง) จอแท็บเล็ตกลายเป็นช่องกล้องของการ์ดใหญ่ ซึ่งเริ่มที่ท่าบัตรพอดีกรอบเหมือนบนจอ
  /// ภาพพยาบาลจางออกระหว่างซูม · ชื่อการ์ดเดิมจาง · ป้ายเลื่อนเข้าที่
  Widget _qMorphCam(Rect src, Rect dst, double e) {
    final face = _qCamFace;
    final tagLabel =
        face ? 'สำหรับผู้ป่วยที่มีในระบบ' : 'ใช้กล้องของเครื่องนี้';
    // ภาพในเมนู: viewBox · กลางจอแท็บเล็ต · ความกว้างจอ · มุมหมุนให้จอตั้งตรง
    final (vw, vh, sc, sw, rot) = face
        ? (226.0, 240.0, const Offset(110.0, 118.0), 120.0, 0.27)
        : (512.0, 576.0, const Offset(223.0, 342.0), 117.0, 0.16);
    double ss(double a, double b, double x) {
      final t = _qc((x - a) / (b - a));
      return t * t * (3.0 - 2.0 * t);
    }

    final r = Rect.lerp(src, dst, e)!;
    final tab = (14.0 + _qTagW(tagLabel) + 12.0) + 6.0 * e;
    // ภาพในการ์ดเล็ก (contain ชิดขวาล่าง)
    final box = Rect.fromLTRB(src.width - 112.0, _QFolderTabClip.notch + 10.0,
        src.width + 6.0, src.height + 10.0);
    final ia = vw / vh;
    final iw = box.width / box.height > ia ? box.height * ia : box.width;
    final ih = iw / ia;
    final img = Rect.fromLTWH(box.right - iw, box.bottom - ih, iw, ih);
    final k = iw / vw;
    final p0 = sc * k;
    final dFin = Rect.fromLTRB(28.0, 56.0,
        28.0 + (dst.width - 100.0) * 11.0 / 20.0, dst.height - 28.0);
    final w0 = sw * k;
    final scr0 = Rect.fromCenter(
        center: img.topLeft + p0,
        width: w0,
        height: w0 * dFin.height / dFin.width);
    final fin = Rect.lerp(scr0, dFin, e)!;
    final zoom = fin.width / w0;
    final ang = rot * e;
    final m = Matrix4.identity()
      ..translateByDouble(
          fin.center.dx - img.left, fin.center.dy - img.top, 0.0, 1.0)
      ..rotateZ(ang)
      ..scaleByDouble(zoom, zoom, 1.0, 1.0)
      ..translateByDouble(-p0.dx, -p0.dy, 0.0, 1.0);
    return Positioned.fromRect(
      rect: r,
      child: CustomPaint(
        foregroundPainter: _QFolderTabEdge(tab),
        child: ClipPath(
          clipper: _QFolderTabClip(tab),
          child: ColoredBox(
            color: _panel,
            child: Stack(children: [
              // ภาพพยาบาลถือแท็บเล็ต: ซูมเข้าที่จอ แล้วจางออก
              Positioned.fromRect(
                rect: img,
                child: Opacity(
                  opacity: 1.0 - ss(0.2, 0.62, e),
                  child: Transform(
                      transform: m,
                      child: face
                          ? _qImgFace(_qSimFace, small: true)
                          : _qImgPhoto()),
                ),
              ),
              // ช่องกล้อง (วาดที่ขนาดจริงแล้วย่อ) โตจากตำแหน่งจอแท็บเล็ต
              Positioned.fromRect(
                rect: fin,
                child: Opacity(
                  opacity: ss(0.04, 0.42, e),
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: dFin.width,
                      height: dFin.height,
                      child: _QCamFinder(
                          shot: false,
                          still: true,
                          face: face ? _qSimFace : null),
                    ),
                  ),
                ),
              ),
              Positioned(
                  left: 14.0 + 4.0 * e,
                  top: 10.0 + 2.0 * e,
                  child: _qTag(tagLabel)),
              Positioned(
                left: 16.0,
                top: 42.0,
                child: Opacity(
                  opacity: _qc(1.0 - e * 2.5),
                  child: Text(face ? 'สแกนใบหน้า' : 'ถ่ายภาพบัตรประชาชน',
                      style: _t(17.0,
                          color: _inkTitle,
                          weight: FontWeight.w500,
                          height: 1.25)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /// ภาพอุบัติเหตุหมู่ (ไม่มีพื้นหลัง) · การ์ดเล็ก = ชิดขวาล่าง · การ์ดใหญ่ = กลางคอลัมน์ซ้าย
  Widget _mciArt({Alignment at = Alignment.bottomRight}) => Align(
        alignment: at,
        child: AspectRatio(
          aspectRatio: _mciArtAspect,
          // idle: ไฟไซเรนกะพริบ แดง 2 ครั้ง สลับน้ำเงิน 2 ครั้ง (หลังคาเก๋ง + ไฟท้ายรถ) วนต่อเนื่อง
          child: _qIdleArt(
              _mciArtAsset,
              _mciArtW,
              _mciArtH,
              const _QIdle(
                  period: 1400,
                  dur: 1400,
                  delay: 200,
                  painter: _QIdleSiren.new)),
        ),
      );

  /// การ์ดอุบัติเหตุหมู่ในเมนู → การ์ดใหญ่: กรอบโตจากตำแหน่งเดิม ภาพเลื่อนจากมุมขวาล่างไปซ้าย ชื่อเดิมจาง
  Widget _qMorphMci(Rect src, Rect dst, double e) {
    final r = Rect.lerp(src, dst, e)!;
    final tab = (14.0 + _qTagW(_mciTagLabel) + 12.0) + 6.0 * e;
    const asp = _mciArtAspect;
    Rect fit(Rect a, {bool corner = false}) {
      final w = a.width / a.height > asp ? a.height * asp : a.width;
      final h = w / asp;
      return corner
          ? Rect.fromLTWH(a.right - w, a.bottom - h, w, h)
          : Rect.fromCenter(center: a.center, width: w, height: h);
    }

    // ตำแหน่งภาพเล็ก = ช่องภาพของการ์ดเล็ก (_qMethodCardBody compact) · ภาพใหญ่ = คอลัมน์ซ้ายของ _mciIntroView
    final sImg = fit(
        Rect.fromLTRB(
            src.width + _mciCardArtOut.dx - _mciCardArtW,
            _QFolderTabClip.notch + 10.0,
            src.width + _mciCardArtOut.dx,
            src.height + _mciCardArtOut.dy),
        corner: true);
    final dImg = fit(Rect.fromLTRB(28.0, 56.0,
        28.0 + (dst.width - 100.0) * 11.0 / 20.0, dst.height - 28.0));
    return Positioned.fromRect(
      rect: r,
      child: CustomPaint(
        foregroundPainter: _QFolderTabEdge(tab),
        child: ClipPath(
          clipper: _QFolderTabClip(tab),
          child: ColoredBox(
            color: _panel,
            child: Stack(children: [
              Positioned.fromRect(
                rect: Rect.lerp(sImg, dImg, e)!,
                child: _mciArt(),
              ),
              Positioned(
                  left: 14.0 + 4.0 * e,
                  top: 10.0 + 2.0 * e,
                  child: _qTag(_mciTagLabel)),
              Positioned(
                left: 16.0,
                top: 42.0,
                width: math.max(0.0, src.width - 126.0),
                child: Opacity(
                  opacity: (1.0 - e * 2.5).clamp(0.0, 1.0),
                  child: Text('อุบัติเหตุหมู่',
                      maxLines: 1,
                      style: _t(17.0,
                          color: _inkTitle,
                          weight: FontWeight.w500,
                          height: 1.25)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /// stepper ขั้นลงทะเบียน (ชุดเดียวกับแผง workflow หน้าผู้ป่วย) · แตะกระโดดได้
  Widget _mciStepper() {
    final m = _mci;
    return _hxStepper([
      ('เหตุการณ์', m.active),
      ('รับผู้บาดเจ็บ', m.cases.isNotEmpty),
      ('ตรวจก่อนส่ง', false),
    ], m.step, onTap: (i) {
      if (i == m.step) return;
      if (i >= 1 && !m.active) {
        _mciStart();
        return;
      }
      if (i == 2 && m.cases.isEmpty) return;
      _mciGo(i);
    });
  }

  /// footer เดียวกันทุกหน้า: ซ้าย = ข้อมูล/ลิงก์รอง · ขวาสุด = ปุ่มรอง แล้วปุ่มหลัก (ตำแหน่งเดิมทุกหน้า)
  Widget _mciFooter() {
    final m = _mci;
    final n = m.cases.length;
    final (
      Widget? left,
      String? sec,
      VoidCallback? secTap,
      String main,
      VoidCallback? mainTap
    ) = switch (m.step) {
      0 => (
          null,
          m.active ? 'ปิด' : 'ยกเลิก',
          _mciClose,
          m.active ? 'ถัดไป' : 'เริ่มรับผู้บาดเจ็บ',
          m.active ? () => _mciGo(1) : _mciStart,
        ),
      1 => (
          Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('รับแล้ว ',
                    style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
                Text('$n',
                    style: _num(22.0, color: _blue, weight: FontWeight.w700)),
                Text(' ราย จากที่แจ้ง ${m.expected} ราย',
                    style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
              ]),
          'ย้อนกลับ',
          () => _mciGo(0),
          'ถัดไป',
          n == 0 ? null : () => _mciGo(2),
        ),
      2 => (
          Align(
              alignment: Alignment.centerLeft,
              child: _mciLink('พิมพ์ป้ายข้อมือ $n ใบ', _mciPrint)),
          'ย้อนกลับ',
          () => _mciGo(1),
          'ส่งเข้าห้องฉุกเฉิน $n ราย',
          n == 0 ? null : _mciSend,
        ),
      // การกระทำรอง (แจ้งญาติ เหตุการณ์ใหม่ จบเหตุการณ์) อยู่ในการ์ดเป็นแผ่นปุ่ม ไม่ใช่ลิงก์ใน footer
      3 => (
          null,
          m.active ? 'ปิด' : null,
          m.active ? _mciClose : null,
          m.active ? 'รับผู้บาดเจ็บเพิ่ม' : 'ปิด',
          m.active ? () => _mciGo(1) : _mciClose,
        ),
      _ => (
          null,
          'ย้อนกลับ',
          () => _mciGo(3),
          m.idMethod == 2 ? 'บันทึกชื่อ' : 'รวมเวชระเบียน',
          (m.idMethod == 2
                  ? _regCtl('mciName').text.trim().isNotEmpty
                  : m.idFound)
              ? _mciMerge
              : null,
        ),
    };
    return SizedBox(
      height: 46.0,
      child: Row(children: [
        Expanded(child: left ?? const SizedBox.shrink()),
        if (sec != null) ...[
          _mciPill(sec, secTap),
          const SizedBox(width: 10.0),
        ],
        _mciPill(main, mainTap, primary: true),
      ]),
    );
  }

  /// การ์ดกลุ่มในแผงรายชื่อ (พื้นกรมท่า) 1 ใบต่อเหตุการณ์: ยอดแต่ละสี + จำนวนรอระบุตัวตน · แตะ = ภาพรวมของกลุ่มนั้น
  Widget _mciPlanCard(_MciEvent m) {
    const dots = [
      Color(0xFFFF8A8A),
      Color(0xFFF5C542),
      Color(0xFF5FD39A),
      Color(0xB3FFFFFF),
    ];
    return _Press(
      radius: 16.0,
      scale: 0.98,
      child: GestureDetector(
        onTap: () => _mciOpenBoard(m),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 10.0, 12.0),
          decoration: BoxDecoration(
            color: const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0x38FFFFFF)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(
                            m.active
                                ? 'อุบัติเหตุหมู่ กลุ่ม ${m.group}'
                                : 'กลุ่ม ${m.group} จบเหตุการณ์แล้ว',
                            style: _t(14.0,
                                color: _lpInk, weight: FontWeight.w700)),
                      ),
                      if (m.active && m.openedAt != null)
                        Text('เริ่ม ${_mciTime(m.openedAt!)}',
                            style: _t(11.5,
                                color: _lpInk2, weight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 6.0),
                    Wrap(spacing: 12.0, runSpacing: 4.0, children: [
                      for (var t = 0; t < _mciTags.length; t++)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: dots[t])),
                          const SizedBox(width: 4.0),
                          Text(
                              '${_mciTags[t].name} ${m.sent.values.where((c) => c.tag == t).length}',
                              style: _t(12.5,
                                  color: _lpInk, weight: FontWeight.w600)),
                        ]),
                    ]),
                    const SizedBox(height: 4.0),
                    Text('ยังไม่ระบุตัวตน ${m.waiting.length} ราย',
                        style:
                            _t(12.0, color: _lpInk2, weight: FontWeight.w500)),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: _lpInk2),
          ]),
        ),
      ),
    );
  }

  /// ชิปตัวกรอง "อุบัติเหตุหมู่" ในแผงรายชื่อ (แบบเดียวกับชิป Fast track)
  Widget _mciListChip(int n) {
    final on = _mci.listOnly;
    return _Press(
      child: GestureDetector(
        onTap: () => setState(() {
          _mci.listOnly = !_mci.listOnly;
          _ftOnly = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 32.0,
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 12.0, 0.0),
          decoration: BoxDecoration(
            color: on ? Colors.white : const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(8.0),
            border:
                Border.all(color: on ? Colors.white : const Color(0x1FFFFFFF)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(on ? Icons.check_rounded : Icons.groups_rounded,
                size: 16.0, color: on ? _blue : _lpInk),
            const SizedBox(width: 4.0),
            Text('อุบัติเหตุหมู่',
                style: _t(12.5,
                    color: on ? _blue : _lpInk, weight: FontWeight.w600)),
            const SizedBox(width: 6.0),
            Text('$n',
                style: _num(12.5,
                    color: on ? _blue : _lpInk2, weight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  /// การ์ดค้นหา HN ระหว่างขยาย/หด: กรอบแฟ้ม ป้าย ชื่อ ภาพแท็บเล็ต เลื่อน/ขยายจากตำแหน่งเดิม
  Widget _qMorphHn(Rect src, Rect dst, double e) {
    final r = Rect.lerp(src, dst, e)!;
    final tw = _qTagW('พิมพ์ค้นหา');
    final tab = (14.0 + tw + 12.0) + 6.0 * e;
    Rect fit(Rect a) {
      const asp = 226.0 / 240.0;
      final h = a.width / a.height > asp ? a.height : a.width / asp;
      return Rect.fromLTWH(a.right - h * asp, a.bottom - h, h * asp, h);
    }

    final sImg = Rect.fromLTRB(src.width - 124.0, _QFolderTabClip.notch + 10.0,
        src.width + 6.0, src.height + 10.0);
    final da = Rect.fromLTRB(28.0, 70.0, dst.width * 0.42, dst.height - 10.0);
    final dsz = math.min(da.width, da.height);
    final dImg = Rect.fromCenter(center: da.center, width: dsz, height: dsz);
    // ภาพเต็ม (viewBox 106,152 กว้าง 268) วางให้ทับภาพเล็ก (viewBox 111,160 ขนาด 226×240) พอดี
    // แล้วค่อยขยายไปตำแหน่งในการ์ดใหญ่ = ภาพเดียวตลอดทาง ไม่มีเงาซ้อนจากการสลับภาพ
    final sm = fit(sImg);
    final k = sm.width / 226.0;
    final sFull = Rect.fromLTWH(
        sm.left - 5.0 * k, sm.top - 8.0 * k, 268.0 * k, 268.0 * k);
    final img = Rect.lerp(sFull, dImg, e)!;
    return Positioned.fromRect(
      rect: r,
      child: CustomPaint(
        foregroundPainter: _QFolderTabEdge(tab),
        child: ClipPath(
          clipper: _QFolderTabClip(tab),
          child: ColoredBox(
            color: _panel,
            child: Stack(children: [
              Positioned.fromRect(
                rect: img,
                child: Image.asset('assets/images/er_intake_hn_full.png',
                    fit: BoxFit.fill),
              ),
              Positioned(
                  left: 14.0 + 4.0 * e,
                  top: 10.0 + 2.0 * e,
                  child: _qTag('พิมพ์ค้นหา')),
              Positioned(
                left: 16.0,
                top: 46.0,
                child: Opacity(
                  opacity: (1.0 - e * 2.5).clamp(0.0, 1.0),
                  child: Text('ค้นหาโดย HN',
                      style: _t(17.0,
                          color: _inkTitle,
                          weight: FontWeight.w500,
                          height: 1.25)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /// หน้าค้นหาผู้ป่วยด้วย HN (การ์ดแฟ้มใหญ่กลางจอ): ซ้าย = ภาพแท็บเล็ตค้นหา · ขวา = หัวข้อ ช่องค้นหา ผลลัพธ์
  /// พบเมื่อพิมพ์ตรงทั้งค่า (exact match: HN เลขบัตร เบอร์โทร หรือชื่อเต็ม ในข้อมูล HOSxP จำลอง) · แตะผลลัพธ์ = เข้าคัดกรอง
  /// [rightOnly] = วาดเฉพาะคอลัมน์ขวา (ไม่มีกรอบ ป้าย ภาพ · ช่องค้นหาเป็นภาพนิ่ง) ใช้ซ้อนบนการ์ดที่กำลังขยาย
  Widget _qSearchView({bool rightOnly = false}) {
    final ctl = _regCtl('q');
    final q = ctl.text.trim();
    final digits = q.replaceAll(RegExp(r'\D'), '');
    // ระเบียนใน HOSxP (จำลอง ชุดเดียวกับ _qLookup)
    const rec = (
      name: 'นายสมชาย ใจดี',
      hn: '00012345',
      cid: '3400100123456',
      phone: '0812345678',
      age: 64,
      allergy: 'Penicillin',
    );
    // ต้องตรงทั้งค่า (exact match) จึงพบ: HN 8 หลัก · เลขบัตร 13 หลัก · เบอร์โทร 10 หลัก · หรือชื่อเต็ม
    final hit = (digits.isNotEmpty &&
            digits.length == q.replaceAll(RegExp(r'[\s-]'), '').length &&
            (digits == rec.hn || digits == rec.cid || digits == rec.phone)) ||
        (digits.isEmpty &&
            (q == rec.name || q == rec.name.replaceFirst('นาย', '')));
    // ครบหลักแล้วแต่ไม่ตรง = ไม่พบ · ยังไม่ครบ = บอกให้พิมพ์ให้ครบ
    final full = digits.length == 8 ||
        digits.length == 10 ||
        digits.length == 13 ||
        (digits.isEmpty && q.length >= 4);
    final tw = _qTagW('พิมพ์ค้นหา');
    final tab = 14.0 + tw + 12.0 + 6.0;
    Widget hint(IconData ic, String t) => Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Row(children: [
            Icon(ic, size: 18.0, color: _ink3),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(t,
                  style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
            ),
          ]),
        );
    return Padding(
      key: const ValueKey('q-search'),
      padding: const EdgeInsets.fromLTRB(40.0, 24.0, 40.0, 96.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 940.0, maxHeight: 540.0),
          child: CustomPaint(
            foregroundPainter: rightOnly ? null : _QFolderTabEdge(tab),
            child: ClipPath(
              clipper: _QFolderTabClip(tab),
              child: ColoredBox(
                color: rightOnly ? const Color(0x00000000) : _panel,
                child: Stack(children: [
                  if (!rightOnly)
                    Positioned(
                        left: 18.0, top: 12.0, child: _qTag('พิมพ์ค้นหา')),
                  LayoutBuilder(builder: (context, b) {
                    return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ซ้าย: ภาพแท็บเล็ตค้นหา ชิดล่าง (ต่อจากภาพในการ์ดเล็ก)
                          SizedBox(
                            width: b.maxWidth * 0.42,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  28.0, 70.0, 0.0, 10.0),
                              // ภาพเต็มใบ (แท็บเล็ตครบ + มือมีแขนเสื้อ) ไม่โดนตัดกลางการ์ด
                              child: rightOnly
                                  ? const SizedBox()
                                  : Image.asset(
                                      'assets/images/er_intake_hn_full.png',
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center),
                            ),
                          ),
                          const SizedBox(width: 36.0),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  0.0, 64.0, 36.0, 28.0),
                              child: _QRise(
                                delay: 0,
                                dy: 14.0,
                                ms: 360,
                                instant: true,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('ค้นหาผู้ป่วย',
                                          style: _t(26.0,
                                              color: _inkTitle,
                                              weight: FontWeight.w700)),
                                      const SizedBox(height: 4.0),
                                      Text(
                                          'พิมพ์ HN เลขบัตรประชาชน หรือเบอร์โทรให้ตรงทั้งหมด',
                                          style: _t(14.0,
                                              color: _ink2,
                                              weight: FontWeight.w500)),
                                      const SizedBox(height: 18.0),
                                      // ช่องค้นหา pill ขอบกรมท่า (แบบในภาพประกอบ)
                                      Container(
                                        height: 52.0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        decoration: BoxDecoration(
                                          color: _panel,
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                              color: _blue, width: 1.4),
                                        ),
                                        child: Row(children: [
                                          const Icon(Icons.search_rounded,
                                              size: 22.0, color: _blue),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            // ภาพนิ่งตอนการ์ดกำลังขยาย/หด (ไม่ autofocus ซ้อน)
                                            child: rightOnly
                                                ? Text(
                                                    q.isEmpty
                                                        ? 'HN เลขบัตร หรือเบอร์โทร'
                                                        : q,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.clip,
                                                    style: q.isEmpty
                                                        ? _t(15.0,
                                                            color: _ink3,
                                                            weight:
                                                                FontWeight.w500)
                                                        : _t(16.0,
                                                            color: _inkTitle,
                                                            weight: FontWeight
                                                                .w600))
                                                : TextField(
                                                    controller: ctl,
                                                    autofocus: true,
                                                    onChanged: (_) =>
                                                        setState(() {}),
                                                    onSubmitted: (_) {
                                                      if (hit) _qSearchPick();
                                                    },
                                                    style: _t(16.0,
                                                        color: _inkTitle,
                                                        weight:
                                                            FontWeight.w600),
                                                    decoration: InputDecoration(
                                                      isCollapsed: true,
                                                      border: InputBorder.none,
                                                      hintText:
                                                          'HN เลขบัตร หรือเบอร์โทร',
                                                      hintStyle: _t(15.0,
                                                          color: _ink3,
                                                          weight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                          ),
                                          if (q.isNotEmpty)
                                            GestureDetector(
                                              onTap: () =>
                                                  setState(() => ctl.clear()),
                                              child: const Icon(
                                                  Icons.cancel_rounded,
                                                  size: 20.0,
                                                  color: _ink3),
                                            ),
                                        ]),
                                      ),
                                      if (!hit && !full)
                                        hint(
                                            Icons.info_outline_rounded,
                                            q.isEmpty
                                                ? 'พิมพ์ให้ครบ HN 8 หลัก เลขบัตร 13 หลัก หรือเบอร์โทร 10 หลัก'
                                                : 'พิมพ์ต่อให้ครบ (ตอนนี้ ${digits.length} หลัก)')
                                      else if (!hit)
                                        hint(Icons.search_off_rounded,
                                            'ไม่พบผู้ป่วยที่ตรงกัน ตรวจตัวเลขอีกครั้ง')
                                      else ...[
                                        const SizedBox(height: 16.0),
                                        Text('พบ 1 ราย',
                                            style: _t(12.0,
                                                color: _ink3,
                                                weight: FontWeight.w600)),
                                        const SizedBox(height: 8.0),
                                        _Press(
                                          scale: 0.98,
                                          radius: 16.0,
                                          child: GestureDetector(
                                            onTap: _qSearchPick,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              decoration: BoxDecoration(
                                                color: _panel,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFFDADCE0),
                                                    width: 0.5),
                                              ),
                                              child: Row(children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: Image.asset(
                                                      _faceUrl('670123456'),
                                                      width: 52.0,
                                                      height: 60.0,
                                                      fit: BoxFit.cover),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(rec.name,
                                                            style: _t(16.0,
                                                                color:
                                                                    _inkTitle,
                                                                weight:
                                                                    FontWeight
                                                                        .w700)),
                                                        const SizedBox(
                                                            height: 2.0),
                                                        Text(
                                                            'HN ${rec.hn}  อายุ ${rec.age} ปี',
                                                            style: _num(12.5,
                                                                color: _ink2,
                                                                weight:
                                                                    FontWeight
                                                                        .w600)),
                                                        const SizedBox(
                                                            height: 6.0),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      9.0,
                                                                  vertical:
                                                                      2.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFFCE8E6),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                          ),
                                                          child: Text(
                                                              'แพ้ยา ${rec.allergy}',
                                                              style: _t(11.5,
                                                                  color: _red,
                                                                  weight:
                                                                      FontWeight
                                                                          .w700)),
                                                        ),
                                                      ]),
                                                ),
                                                const Icon(
                                                    Icons.chevron_right_rounded,
                                                    color: _ink3),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      _Press(
                                        radius: 100.0,
                                        child: GestureDetector(
                                          onTap: _qSearchClose,
                                          child: Container(
                                            height: 44.0,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: _panel,
                                              borderRadius:
                                                  BorderRadius.circular(100.0),
                                              border: Border.all(color: _line),
                                            ),
                                            child: Text('ยกเลิก',
                                                style: _t(14.0,
                                                    color: _inkTitle,
                                                    weight: FontWeight.w700)),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ]);
                  }),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// การ์ดอ่านบัตรระหว่างขยาย/หด ([e] 0 = ในเมนู · 1 = การ์ดใหญ่): กรอบ แถบแฟ้ม ป้าย เครื่องอ่าน
  /// เลื่อน/ขยายต่อเนื่องจากตำแหน่งเดิม · ชื่อการ์ดเดิมจางออกช่วงแรก
  Widget _qMorphCard(Rect src, Rect dst, double e) {
    final r = Rect.lerp(src, dst, e)!;
    final online = _qRdOnline;
    final label = online ? 'เครื่องอ่านพร้อม' : 'ไม่พบเครื่องอ่าน';
    final tw = _qTagW(label, lead: online);
    final tab = (14.0 + tw + 12.0) + 6.0 * e;
    Rect fit(Rect a) {
      const asp = 834.0 / 558.0;
      final w = a.width / a.height > asp ? a.height * asp : a.width;
      return Rect.fromCenter(center: a.center, width: w, height: w / asp);
    }

    final sArt =
        fit(Rect.fromLTRB(14.0, 78.0, src.width - 14.0, src.height - 10.0));
    final aw = (dst.width - 100.0) * 11.0 / 20.0;
    final dArt = fit(Rect.fromLTRB(28.0, 56.0, 28.0 + aw, dst.height - 28.0));
    final art = Rect.lerp(sArt, dArt, e)!;
    return Positioned.fromRect(
      rect: r,
      child: CustomPaint(
        foregroundPainter: _QFolderTabEdge(tab),
        child: ClipPath(
          clipper: _QFolderTabClip(tab),
          child: ColoredBox(
            color: _panel,
            child: Stack(children: [
              Positioned(
                left: 14.0 + 4.0 * e,
                top: 10.0 + 2.0 * e,
                child: _qReaderTag(),
              ),
              Positioned(
                left: 16.0,
                top: 46.0,
                child: Opacity(
                  opacity: (1.0 - e * 2.5).clamp(0.0, 1.0),
                  child: Text('อ่านบัตรประชาชน',
                      style: _t(19.0,
                          color: _inkTitle,
                          weight: FontWeight.w500,
                          height: 1.25)),
                ),
              ),
              Positioned.fromRect(
                rect: art,
                child: const _QReaderArt(
                    view: _qIsoView, intro: false, stage: -1, reading: false),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /// หน้าจออ่านบัตรเต็มจอ (ทับหน้าแรกการส่งตรวจ): ซ้าย = เครื่องอ่าน + บัตรบนแผงกรมท่าลายบัตรจิ๋ว (สแกนวน)
  /// ขวา = หัวข้อสถานะ + ขั้นตอน 4 ข้อ (เหรียญสถานะ) · อ่านชิปมีแถบ % · ใต้ขั้นตอน = ปุ่ม (เริ่มอ่าน / ยกเลิก / ลองใหม่ ถ่ายภาพแทน)
  /// [rightOnly] = วาดเฉพาะคอลัมน์ขวา (ไม่มีกรอบ ป้าย ภาพ) ใช้ซ้อนบนการ์ดที่กำลังขยาย
  Widget _qReadingView({bool rightOnly = false}) {
    final noDev = _qRdNoDev, step = _qRdStep;
    final done = step >= 4;
    Widget coin(int i) => SizedBox.square(
          dimension: 30.0,
          child: FittedBox(
            child: noDev && i == 0
                ? const _SoStatusCoin.wait(icon: 'ph-scan')
                : step > i || done
                    ? const _SoStatusCoin.done()
                    : step == i
                        ? const _SoStatusCoin.next()
                        : const _SoStatusCoin.wait(),
          ),
        );
    Widget row(int i, String title, String sub, {Widget? extra}) {
      final on = step == i && !noDev;
      final past = step > i || done;
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        opacity: past || on || (noDev && i == 0) ? 1.0 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            coin(i),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: _t(15.0,
                            color: _inkTitle,
                            weight: on ? FontWeight.w700 : FontWeight.w600)),
                    const SizedBox(height: 1.0),
                    Text(sub,
                        style: _t(12.5,
                            color: noDev && i == 0 ? _red : _ink3,
                            weight: FontWeight.w500)),
                    if (extra != null) ...[const SizedBox(height: 8.0), extra],
                  ]),
            ),
          ]),
        ),
      );
    }

    final pct = (_qRdPct * 100).round();
    final ready = step < 0 && !noDev;
    final title = ready
        ? 'อ่านบัตรประชาชน'
        : noDev
            ? 'ไม่พบเครื่องอ่านบัตร'
            : done
                ? 'อ่านบัตรเรียบร้อย'
                : 'กำลังอ่านบัตรประชาชน';
    final sub = ready
        ? 'เสียบบัตรที่เครื่องอ่านให้สุด แล้วกดเริ่มอ่านบัตร'
        : noDev
            ? 'ตรวจสาย USB ของเครื่องอ่านบัตร แล้วลองใหม่อีกครั้ง'
            : done
                ? 'กำลังเข้าสู่การคัดกรอง'
                : 'อย่าดึงบัตรออกระหว่างอ่านข้อมูล';
    Widget pill(String label, VoidCallback onTap,
            {bool primary = false, bool shimmer = false}) =>
        _qPill(label, onTap, primary: primary, shimmer: shimmer);
    // การ์ดแฟ้มใบใหญ่กลางจอ (ภาษาเดียวกับหน้าเมนู): ป้ายสถานะเครื่องอ่านในแถบแฟ้ม
    // ซ้าย = เครื่องอ่าน + บัตรบนพื้นขาว (ล้อตามขั้นตอน) · ขวา = หัวข้อ ขั้นตอน ปุ่ม · พื้นหลัง/dock ของหน้าเมนูยังอยู่
    final tagLabel = noDev ? 'ไม่พบเครื่องอ่าน' : 'เครื่องอ่านพร้อม';
    final tag = noDev
        ? _qTag(tagLabel, color: _red)
        : _qTag(tagLabel,
            color: Colors.white,
            border: _green,
            fill: _green,
            lead: const Icon(Icons.check_circle_rounded,
                size: 18.0, color: Colors.white));
    final tab = 14.0 + _qTagW(tagLabel, lead: !noDev) + 12.0 + 6.0;
    return Padding(
      key: const ValueKey('q-reading'),
      padding: const EdgeInsets.fromLTRB(40.0, 24.0, 40.0, 96.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 940.0, maxHeight: 540.0),
          child: CustomPaint(
            foregroundPainter: rightOnly ? null : _QFolderTabEdge(tab),
            child: ClipPath(
              clipper: _QFolderTabClip(tab),
              child: ColoredBox(
                color: rightOnly ? const Color(0x00000000) : _panel,
                child: Stack(children: [
                  if (!rightOnly) Positioned(left: 18.0, top: 12.0, child: tag),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28.0, 56.0, 36.0, 28.0),
                    child: Row(children: [
                      // ซ้าย: เครื่องอ่าน + บัตร ล้อตามขั้นตอน (รอเสียบ → ค้นหาเครื่อง → บัตรเข้าช่อง → อ่านชิป → ค้นประวัติ → เสร็จ)
                      Expanded(
                        flex: 11,
                        child: Center(
                          child: rightOnly
                              ? const SizedBox()
                              : _QReaderArt(
                                  view: _qIsoView,
                                  intro: false,
                                  stage: step,
                                  noDevice: noDev,
                                  reading: !noDev && step == 2),
                        ),
                      ),
                      const SizedBox(width: 36.0),
                      // ขวา: สถานะ + ขั้นตอน + ปุ่ม (จางเข้าต่อจากการ์ดที่ขยายเสร็จ)
                      Expanded(
                        flex: 9,
                        child: _QRise(
                          delay: 0,
                          dy: 14.0,
                          ms: 360,
                          instant: true,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Text(title,
                                      key: ValueKey(title),
                                      style: _t(26.0,
                                          color: _inkTitle,
                                          weight: FontWeight.w700)),
                                ),
                                const SizedBox(height: 4.0),
                                Text(sub,
                                    style: _t(14.0,
                                        color: _ink2, weight: FontWeight.w500)),
                                const SizedBox(height: 22.0),
                                if (done) _qReadResult(),
                                if (!done) ...[
                                  row(
                                      0,
                                      'เชื่อมต่อเครื่องอ่านบัตร',
                                      noDev
                                          ? 'ไม่พบเครื่องที่ช่อง USB'
                                          : step < 0
                                              ? 'ตรวจหาเครื่องที่ช่อง USB'
                                              : step == 0
                                                  ? 'กำลังค้นหาเครื่อง'
                                                  : 'พบเครื่อง Smart Card Reader (USB)'),
                                  row(
                                      1,
                                      'ตรวจพบบัตรประชาชน',
                                      step > 1 || done
                                          ? 'ชิปพร้อมอ่าน'
                                          : 'รอเสียบบัตร'),
                                  row(
                                      2,
                                      'อ่านข้อมูลจากชิป',
                                      step < 2
                                          ? 'ข้อมูลส่วนตัว ที่อยู่ รูปถ่าย'
                                          : step == 2
                                              ? 'กำลังอ่าน$_qRdItem $pct%'
                                              : 'อ่านครบ 100%',
                                      extra: step == 2
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              child: SizedBox(
                                                height: 8.0,
                                                child: Stack(children: [
                                                  const Positioned.fill(
                                                      child: ColoredBox(
                                                          color: Color(
                                                              0xFFE6EAF2))),
                                                  Positioned.fill(
                                                    child: FractionallySizedBox(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      widthFactor: _qRdPct,
                                                      heightFactor: 1.0,
                                                      child: const ColoredBox(
                                                          color: _blue),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            )
                                          : null),
                                  row(
                                      3,
                                      'ค้นหาประวัติใน HOSxP',
                                      step < 3
                                          ? 'จับคู่เลขบัตรกับ HN'
                                          : step == 3
                                              ? 'กำลังค้นหา'
                                              : 'พบประวัติผู้ป่วย'),
                                ],
                                // ปุ่มอยู่ใต้ขั้นตอน (ต่อจากสิ่งที่อ่าน) · ปุ่มหลักนำหน้า · อ่านอยู่ = เหลือยกเลิก · เสร็จ = ไม่มีปุ่ม
                                if (!done) ...[
                                  const SizedBox(height: 26.0),
                                  Wrap(
                                      spacing: 10.0,
                                      runSpacing: 10.0,
                                      children: [
                                        if (ready)
                                          pill(
                                              'เริ่มอ่านบัตร',
                                              () => _qRead(
                                                  noDevice: _qRdDemoNoDev),
                                              primary: true,
                                              shimmer: true),
                                        if (noDev) ...[
                                          pill('ลองใหม่', () => _qRead(),
                                              primary: true),
                                          pill('ถ่ายภาพบัตรแทน', () {
                                            _qReadCancel();
                                            _qReadDup();
                                          }),
                                        ],
                                        pill(noDev ? 'ปิด' : 'ยกเลิก',
                                            _qReadCancel),
                                      ]),
                                ],
                              ]),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ปุ่ม pill ของการ์ดใหญ่ (อ่านบัตร อุบัติเหตุหมู่): กว้างเต็มคอลัมน์ · หลัก = กรมท่า (shimmer ได้) · รอง = ขาวขอบเทา
  Widget _qPill(String label, VoidCallback onTap,
          {bool primary = false, bool shimmer = false}) =>
      _Press(
        radius: 100.0,
        child: GestureDetector(
          onTap: onTap,
          child: _QShimmer(
            on: shimmer,
            child: Container(
              height: 44.0,
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary ? _blue : _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: primary ? null : Border.all(color: _line),
              ),
              child: Text(label,
                  style: _t(14.0,
                      color: primary ? Colors.white : _inkTitle,
                      weight: FontWeight.w700)),
            ),
          ),
        ),
      );

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
        onTap: _qReadQuick,
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
      Widget? action,
      EdgeInsets? pad,
      String? sum,
      bool done = false,
      bool keepTitle = false,
      Gradient? gradient}) {
    // แบบหน้าตั้งค่า Google (AdSense): section ขอบเส้นเทาบาง มุม 8 ไม่มีเงา
    // หัวข้อ + คำอธิบายเล็กใต้หัวข้อ · เปิดทุกหัวข้อ ไม่พับ
    final showTitle = !_qFlat || keepTitle;
    count ??= _qCardSub[title];
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      // แผงแคบ: ไม่มีขอบและไม่มีระยะในการ์ด ระยะข้างมาจากรายการของแผง
      padding: _qCardNarrow
          ? EdgeInsets.zero
          : pad == null
              ? const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 22.0)
              : pad.copyWith(left: 24.0, right: 24.0),
      decoration: BoxDecoration(
        color: _panel,
        // ไล่สีจางจากขอบบน (เช่นการ์ด Fast track = แดงอ่อน)
        gradient: gradient,
        borderRadius: BorderRadius.circular(8.0),
        // แผงแคบ (workflow): ไม่มีเส้นขอบ วางบนแผงขาวตรง ๆ ไม่เป็นกรอบซ้อนกรอบ
        border: _qCardNarrow
            ? null
            : Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // แผงแคบ (เช่นในแผง workflow): ปุ่มท้ายหัวลงบรรทัดใหม่ ไม่บีบชื่อหัวข้อ
          if ((showTitle || trailing != null) && _qCardNarrow)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // action = ปุ่มขวามือ กึ่งกลางแนวตั้งของหัวข้อ + คำอธิบาย
              Row(children: [
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
                              style: _t(12.5,
                                  color: _ink3, weight: FontWeight.w500)),
                        ],
                      ]),
                ),
                if (action != null) action,
              ]),
              if (trailing != null) ...[
                const SizedBox(height: 10.0),
                trailing,
              ],
            ])
          else if (showTitle || trailing != null)
            Row(
                crossAxisAlignment: action != null
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
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
                              style: _t(12.5,
                                  color: _ink3, weight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  ),
                  if (action != null) action,
                  if (trailing != null) trailing,
                ]),
          // ระยะใต้หัวการ์ด: ไม่มีหัว (ซ่อนชื่อในแผงแคบ) = ไม่เว้น
          if (showTitle || trailing != null) const SizedBox(height: 16.0),
          child,
        ],
      ),
    );
  }

  /// การ์ดอาการสำคัญ ใช้ทั้งหน้าคัดกรองและแผง workflow
  /// บนสุด = อาการจากจุดส่งตรวจ แล้วช่องพิมพ์อาการเพิ่มเติม
  /// ชิปข้อความแยกกลุ่ม วิกฤต (จุดแดงที่หัวกลุ่ม) กับ ทั่วไป · [fromTriage] = อาการจากจุดส่งตรวจ
  /// แตะเลือก/เอาออกอาการสำคัญ · เอาออกตัวที่ระบบเลือกจากคำเล่า = ไม่เลือกให้ซ้ำ
  void _qCcToggle(String l) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_qCc.remove(l)) {
        _qCcForget('cc:$l');
      } else {
        _qCc.add(l);
      }
    });
  }

  /// การ์ดอาการสำคัญตาม Figma 1372:128 (ยังไม่พูด) / 1372:151 (กำลังฟัง) (ผู้ใช้ 2026-11-27)
  /// ป้าย #F3F3F3 "AI ช่วยวิเคราะห์" · หัวข้อ 20 Medium "ลงบันทึกอาการสำคัญ" (มีคำเล่า = คำเล่าแทนหัวข้อ)
  /// วงกลม hero 496 ล้นขวา 151 (ไล่ #D9D9D9→#737373 ทึบ 10%) + ไอคอนผู้ช่วย AI ตรงจุด "Hero Image"
  /// ล่าง: ปุ่มยาว "บันทึกด้วยเสียงพูด" (ไอคอนไมค์ Figma) | ปุ่มกลมคีย์บอร์ด = โหมดพิมพ์ · ขอบดำ 19% สูง 48
  /// กำลังฟัง = ป้าย "กำลังฟังอยู่..." + คำเล่า + ส่วนที่รอ (ดำ 20%) ไม่มีปุ่ม (ตามเฟรม) · แตะการ์ด = หยุดและบันทึก
  Widget _qCcNote(int crit,
      {bool notched = true, double? tab, double notchK = 1.0}) {
    final sp = _qCcSp;
    return AnimatedBuilder(
      animation: sp ?? const AlwaysStoppedAnimation(0),
      builder: (context, _) {
        final st = sp?.state ?? ErSpeechState.idle;
        final rec = st == ErSpeechState.listening;
        final busy =
            st == ErSpeechState.processing || st == ErSpeechState.permission;
        final live = rec || busy;
        final text = _regCtl('cc').text.trim();
        final big = _t(20.0, color: Colors.black, weight: FontWeight.w500);
        final faint = big.copyWith(color: Colors.black.withValues(alpha: 0.2));
        // ป้ายในแท็บแฟ้ม (แบบการ์ดอื่นของหน้า) · กำลังฟัง/ถอดเสียง = เปลี่ยนข้อความ
        final tag = _qTag(rec
            ? _qCcTagLabels[1]
            : busy
                ? _qCcTagLabels[2]
                : _qCcTagLabels[0]);
        final critBadge = crit <= 0
            ? null
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: _red,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text('วิกฤต $crit',
                    style:
                        _t(12.0, color: Colors.white, weight: FontWeight.w700)),
              );
        final Widget body;
        if (_qCcTyping && !live) {
          body = TextField(
            controller: _regCtl('cc'),
            autofocus: true,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            minLines: 2,
            maxLines: 8,
            maxLength: 300,
            // เล่าอาการ = เลือกประเภทผู้ป่วย/อาการ/คะแนนปวดให้ (knowledge ข้อ 78)
            onChanged: (_) => _qCcChanged(),
            style: big,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              counterText: '',
              hintText: 'พิมพ์คำเล่าอาการ',
              hintStyle: faint,
              contentPadding: EdgeInsets.zero,
            ),
          );
        } else if (text.isEmpty && !live) {
          body = Text('แตะ "บันทึกด้วยเสียงพูด" แล้วให้ผู้ป่วยเล่าได้เลย',
              style: _t(16.0, color: _ink3, weight: FontWeight.w500));
        } else {
          // คำเล่า (ดำ) + ส่วนที่กำลังฟัง/ถอด (ดำ 20%) แบบเฟรมกำลังฟัง
          body = Text.rich(
              TextSpan(children: [
                TextSpan(text: text, style: big),
                if (live)
                  TextSpan(
                      text: text.isEmpty
                          ? (rec ? 'พูดได้เลย…' : 'กำลังถอดเสียง…')
                          : (rec ? ' พูดต่อได้…' : ' …'),
                      style: faint),
              ]),
              // คำเล่าในช่องไม่เกิน 3 บรรทัด (ผู้ใช้ 2026-11-27 "max 3 lines") แตะเพื่อดู/แก้ทั้งหมด
              maxLines: 3,
              overflow: TextOverflow.ellipsis);
        }
        // รอยเว้าค่อย ๆ ปิดตอนอัดเสียง (notchK 1 → 0 ตามการ์ด)
        final nw = notched ? _qCcNotchW * notchK : 0.0;
        final nh = notched ? _qCcNotchH * notchK : 0.0;
        final showPicked = text.isNotEmpty || _qCc.isNotEmpty || _qCcTray;
        final showField = text.isNotEmpty ||
            _qCcTyping ||
            live ||
            _qCc.isNotEmpty ||
            _qCcTray;
        // จัดวางใหม่แบบมีมิติ (ผู้ใช้ 2026-11-27 "ไม่มีมิติ เปลี่ยนการจัดวางการ์ดใหม่"):
        // ชั้น 1 ฉากหลังไล่เทาอ่อน + เฟืองโผล่ขึ้นจากหลังแผง · ชั้น 2 ป้าย + หัวข้อซ้าย
        // ชั้น 3 แผงขาวยกลอยทับขอบล่างฉาก (คำเล่าจริง สติกเกอร์ ปุ่มพูด/พิมพ์)
        // ชั้น 4 ฟองเสียงลอยอยู่หน้าแผง (ฟองล่างล้ำขอบแผงลงมา = มีความลึก)
        const stageH = 180.0, panelTop = stageH - 34.0, gearD = 150.0;
        final play = !live && text.isEmpty && !_qCcTyping;
        return GestureDetector(
          // กำลังฟัง: แตะที่การ์ด = หยุดและบันทึก (เฟรมกำลังฟังไม่มีปุ่ม)
          behavior: HitTestBehavior.translucent,
          onTap: rec ? _qCcMic : null,
          child: LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth;
            // ชิดขวา ใหญ่ขึ้น ล้นขอบบน (ผู้ใช้ "make it bigger" "move right")
            final gx = w - gearD - 24.0, gy = 62.0 - gearD / 2;
            return Stack(clipBehavior: Clip.none, children: [
              // ฉากหลัง: ไล่ขาว→ม่วงอ่อน + แสงนวลหลังเฟือง
              // ตัดเฉพาะพื้นฉากตามรูปแฟ้ม (แท็บ + รอยเว้า) แล้ววาดเส้นขอบแฟ้มทับ · ภาพ hero ไม่ถูกตัด
              Positioned.fill(
                child: CustomPaint(
                  foregroundPainter: (tab == null || _qCardNarrow)
                      ? null
                      : _QFolderTabEdge(tab, bw: nw, bh: nh),
                  child: ClipPath(
                    clipper: tab == null
                        ? null
                        : _QFolderTabClip(tab, bw: nw, bh: nh),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(
                              ((gx + gearD / 2) / w) * 2.0 - 1.0, 0.25),
                          radius: 1.1,
                          colors: const [Color(0xFFE6ECFB), Color(0xFFF8FAFE)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: gx,
                top: gy,
                width: gearD,
                height: gearD,
                child: _QVoiceGear(layer: 0, play: play, listening: rec),
              ),
              Positioned(
                left: gx,
                top: gy,
                width: gearD,
                height: gearD,
                child: _QVoiceGear(layer: 1, play: play, listening: rec),
              ),
              Positioned(
                left: gx,
                top: gy,
                width: gearD,
                height: gearD,
                child: _QVoiceGear(layer: 3, play: play, listening: rec),
              ),
              // ป้ายอยู่ในแท็บแฟ้ม (18, 12) · หัวข้อชิดบนใต้แท็บ (28, 56) แบบการ์ดแฟ้มอื่นของหน้า
              Positioned(left: 18.0, top: 12.0, child: tag),
              Positioned(
                left: 28.0,
                top: 56.0,
                width: w * 0.46,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(
                          child: Text('ลงบันทึกอาการสำคัญ',
                              style: _t(26.0,
                                  color: Colors.black,
                                  weight: FontWeight.w700,
                                  height: 1.2)),
                        ),
                        if (critBadge != null) ...[
                          const SizedBox(width: 10.0),
                          critBadge,
                        ],
                      ]),
                      const SizedBox(height: 8.0),
                      Text('พูดหรือพิมพ์ตามที่ผู้ป่วยเล่า AI เลือกอาการให้',
                          style:
                              _t(14.0, color: _ink2, weight: FontWeight.w500)),
                    ]),
              ),
              // แผงขาวยกลอยแบบช่องพิมพ์แชท (ผู้ใช้ 2026-11-27 "card height is too much"):
              // คำเล่าอยู่ซ้าย ปุ่มพิมพ์ + ปุ่มหลักอยู่ในรอยเว้าขวาล่าง (มุมเว้าร่วมศูนย์ ห่างเท่ากัน 12)
              // กำลังฟัง = คลื่นเสียงจริง + เวลาที่อัดใต้คำเล่า
              // ยังไม่มีคำเล่า = ไม่ต้องมีช่อง (ผู้ใช้ 2026-11-27 "ตอนก็ยังไม่ต้องมี field สิ") มีแค่ปุ่มในรอยเว้า
              // เริ่มพิมพ์/พูด/มีอาการที่เลือก = ช่องค่อย ๆ ขยายออกมา
              Positioned(
                left: gx,
                top: gy,
                width: gearD,
                height: gearD,
                child: _QVoiceGear(
                    layer: 2,
                    play: play,
                    listening: rec,
                    floor: (showField
                            ? panelTop - (live ? 10.0 : 0.0)
                            : stageH + 16.0) -
                        gy),
              ),
              // การ์ดอัดเสียงขึ้นบังหัวข้อ (ผู้ใช้ 2026-11-27 "ให้มันขึ้นบัง headline ไปเลย") อยู่ชั้นบนสุดเหนือภาพ hero
              // ช่อง/การ์ดอัดเสียงเปลี่ยนแบบนุ่ม (ผู้ใช้ 2026-11-27 "appear bottom sheet ไม่ smooth เลย"):
              // ความสูงขยาย 320 ms พร้อมเนื้อหาจางเข้าและเลื่อนขึ้นเล็กน้อย · รอยเว้าปิด/เปิดจังหวะเดียวกัน
              AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (cur, prev) => Stack(
                      alignment: Alignment.topCenter,
                      children: [...prev, if (cur != null) cur]),
                  transitionBuilder: (child, an) => FadeTransition(
                    opacity: an,
                    child: SlideTransition(
                      position: Tween(
                              begin: const Offset(0.0, 0.05), end: Offset.zero)
                          .animate(an),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(
                        !showField ? 0 : (live ? 1 : (_qCcTyping ? 3 : 2))),
                    child: !showField
                        ? const SizedBox(
                            width: double.infinity, height: stageH + 16.0)
                        : live
                            ? _qCcSheet(rec, busy, text, 60.0)
                            // โหมดพิมพ์ = การ์ดซ้อนบังหัวข้อแบบโหมดอัดเสียง (ผู้ใช้ 2026-11-27 เลือก "ทำแบบโหมดอัดเสียง")
                            : _qCcTyping
                                ? _qCcTypeCard(60.0)
                                : Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12.0, panelTop, 12.0, 12.0),
                                    child: CustomPaint(
                                      painter: _QNotchPanelPaint(nw, nh),
                                      child: ConstrainedBox(
                                        // ป้าย AI มุมขวาบนต้องอยู่เหนือรอยเว้า: แผงสูงพอ (รอยเว้า 52 + ป้าย)
                                        constraints: BoxConstraints(
                                            minHeight: (_qCcAiBusy ||
                                                    _qCcFilledCount > 0)
                                                ? 104.0
                                                : 68.0),
                                        child: Stack(children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                22.0,
                                                20.0,
                                                notched ? nw + 6.0 : 20.0,
                                                16.0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  // แตะคำเล่า = กลับไปพิมพ์แก้
                                                  GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap: () => setState(() =>
                                                        _qCcTyping = true),
                                                    child: body,
                                                  ),
                                                ]),
                                          ),
                                          // มุมขวาบนของช่อง: AI กรอกให้กี่ช่อง / กำลังกรอก (ผู้ใช้ 2026-11-27)
                                          Positioned(
                                            top: 14.0,
                                            right: 14.0,
                                            child: _qCcFillBadge(),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                  ),
                ),
              ),
            ]);
          }),
        );
      },
    );
  }

  Widget _qCcCard({String? fromTriage}) {
    final crit = _qCcOpts.where((o) => o.$2 && _qCc.contains(o.$1)).length;
    final tri = (fromTriage ?? '').isEmpty ? null : fromTriage!;
    final act = tri == null
        ? null
        : TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: _blue,
              // ปุ่มรองแบบ tonal: พื้นฟ้าอ่อน สูง 40 มุม 10
              backgroundColor: const Color(0xFFE2EAF8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0.0, 40.0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              final i = _detailTabs.indexOf('การส่งตรวจ');
              setState(() {
                FocusManager.instance.primaryFocus?.unfocus();
                _tabDir = _tabOrder(i) >= _tabOrder(_detailTab) ? 1 : -1;
                _detailTab = i;
                _markSeen(_caseP().hn, i);
              });
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16.0),
            label: Text('ดูการส่งตรวจ',
                style: _t(12.5, color: _blue, weight: FontWeight.w600)),
          );
    // การ์ดเดียว (ผู้ใช้ 2026-11-27 "เอาเป็นการ์ดเดียวสิ ไม่ต้องมีการ์ดนอกอาการสำคัญ"):
    // banner = หัวการ์ดอาการสำคัญเอง · ใต้ banner = สติกเกอร์อาการ คำถาม MCI · อาการจากจุดส่งตรวจอยู่บนสุด
    // หัวการ์ดแบบแฟ้ม (ผู้ใช้ 2026-11-27 "ทำหัวการ์ดเป็น Folder style"): ใช้แฟ้มเดียวกับการ์ดอื่นของหน้า
    // แท็บซ้ายพอดีป้าย (กว้างตามป้ายที่ยาวสุดของทุกสถานะ ไม่กระดิกตอนเริ่ม/หยุดฟัง) ไหล่โค้งลงไปทางขวา
    final tab = 14.0 +
        [for (final l in _qCcTagLabels) _qTagW(l)].reduce(math.max) +
        12.0 +
        6.0;
    // ปุ่มหลัก "บันทึกด้วยเสียงพูด" ในรอยเว้ามุมขวาล่าง (ผู้ใช้ 2026-11-27 "ทำปุ่มบันทึกด้วยเสียงเป็นปุ่ม มุมเว้าขวาล่าง")
    // แบบปุ่ม "เปิดเคสผู้ป่วยรายนี้": รอยเว้าสูง 52 = ปุ่ม 44 + ระยะห่าง 8 · กว้างตามข้อความที่ยาวสุด + 8
    final nw = _qCcNotchW;
    final sp0 = _qCcSp;
    return AnimatedBuilder(
      animation: sp0 ?? const AlwaysStoppedAnimation(0),
      builder: (context, _) {
        final st0 = sp0?.state ?? ErSpeechState.idle;
        final live0 = st0 == ErSpeechState.listening ||
            st0 == ErSpeechState.processing ||
            st0 == ErSpeechState.permission;
        // อัดเสียง = รอยเว้าค่อย ๆ ปิด ปุ่มในรอยเว้าจางหาย (ปุ่มหยุดอยู่ในแผ่นล่างแทน)
        return TweenAnimationBuilder<double>(
          tween: Tween(end: live0 ? 0.0 : 1.0),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          builder: (context, k, _) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            // ไม่ตัดเนื้อหาตามรูปแฟ้ม: ภาพ hero ล้นขอบบนของการ์ดได้ (ผู้ใช้ 2026-11-27 "allow overflow top")
            child: Stack(clipBehavior: Clip.none, children: [
              CustomPaint(
                painter: _QFolderFill(tab, nw * k, _qCcNotchH * k,
                    edge: !_qCardNarrow),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (tri != null)
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(22.0, 18.0, 22.0, 0.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (act != null)
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: act),
                                const SizedBox(height: 8.0),
                                // อาการจากจุดส่งตรวจ: ข้อความอ้างอิงให้ทวน (มักเป็นประโยคยาว ไม่ใช่ชิป)
                                if (tri != null)
                                  Container(
                                    margin: EdgeInsets.zero,
                                    padding: const EdgeInsets.fromLTRB(
                                        14.0, 10.0, 14.0, 12.0),
                                    decoration: BoxDecoration(
                                      color: _panelSoft,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('จากจุดส่งตรวจ',
                                              style: _t(12.0,
                                                  color: _ink2,
                                                  weight: FontWeight.w600)),
                                          const SizedBox(height: 4.0),
                                          Text(tri,
                                              style: _t(13.0,
                                                  color: _inkTitle,
                                                  weight: FontWeight.w500,
                                                  height: 1.45)),
                                        ]),
                                  ),
                                // เส้นคั่นระหว่างอาการจากจุดส่งตรวจกับช่องพิมพ์ ปุ่ม "คัดลอกมาแก้ไข" วางทับกลางเส้น
                                // กดแล้วคัดข้อความจากจุดส่งตรวจลงช่องอาการเพิ่มเติม (แก้ต่อได้)
                                if (tri != null)
                                  SizedBox(
                                    height: 56.0,
                                    child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                              height: 1.0,
                                              color: const Color(0xFFE3E8F2)),
                                          Container(
                                            color: _panel,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: _blue,
                                                backgroundColor: _panel,
                                                side: const BorderSide(
                                                    color: Color(0xFFDADCE0),
                                                    width: 0.5),
                                                shape: const StadiumBorder(),
                                                minimumSize:
                                                    const Size(0.0, 36.0),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14.0),
                                              ),
                                              onPressed: () {
                                                HapticFeedback.selectionClick();
                                                setState(() =>
                                                    _regCtl('cc').text = tri);
                                              },
                                              icon: const Icon(
                                                  Icons.arrow_downward_rounded,
                                                  size: 16.0),
                                              label: Text('คัดลอกมาแก้ไข',
                                                  style: _t(12.5,
                                                      color: _blue,
                                                      weight: FontWeight.w600)),
                                            ),
                                          ),
                                        ]),
                                  ),
                              ]),
                        ),
                      _qCcNote(crit,
                          notched: true,
                          tab: tri == null ? tab : null,
                          notchK: k),
                      // คำถาม MCI เอาออกจากการ์ดอาการสำคัญ (ผู้ใช้ 2026-11-27 "เอาออก") · โหมดอุบัติเหตุหมู่เปิดจากการ์ด MCI ของหน้าแรก
                    ]),
              ),
              Positioned(
                right: 0.0,
                bottom: 0.0,
                width: nw,
                height: _qCcNotchH,
                child: IgnorePointer(
                  ignoring: k < 0.5,
                  child: Opacity(
                    opacity: _qc((k - 0.4) / 0.6),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                      // โหมดพิมพ์ = ปุ่ม "บันทึก" ในรอยเว้า (ผู้ใช้ 2026-11-27 "ปุ่มเสร็จเปลี่ยนเป็น บันทึก และเอาเว้า")
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _qCcTyping
                            ? KeyedSubtree(
                                key: const ValueKey('save'),
                                child: _qCcSaveBtn())
                            : Row(key: const ValueKey('idle'), children: [
                                _qCcKb(),
                                const SizedBox(width: 8.0),
                                Expanded(child: _qCcCta()),
                              ]),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  /// ความกว้างรอยเว้าปุ่มหลักการ์ดอาการสำคัญ: ข้อความที่ยาวสุดของทุกสถานะ + ไอคอน 22 + 8 + ขอบใน 44 + ระยะห่าง 8
  double get _qCcNotchW =>
      [
        for (final l in const [
          'บันทึกด้วยเสียงพูด',
          'หยุดและบันทึก',
          'กำลังถอดเสียง…'
        ])
          (TextPainter(
                  text: TextSpan(
                      text: l, style: _t(14.0, weight: FontWeight.w700)),
                  textDirection: TextDirection.ltr,
                  maxLines: 1)
                ..layout())
              .width
      ].reduce(math.max) +
      22.0 +
      8.0 +
      44.0 +
      8.0 +
      // ปุ่มพิมพ์วงกลม 44 + ระยะห่าง 8 (อยู่ในรอยเว้าข้างปุ่มหลัก)
      44.0 +
      8.0;

  /// การ์ดพิมพ์คำเล่า (ผู้ใช้ 2026-11-27 เลือก "ทำแบบโหมดอัดเสียง"): การ์ดซ้อนบังหัวข้อ แบบเดียวกับการ์ดอัดเสียง
  /// ป้ายไอคอนคีย์บอร์ด "พิมพ์คำเล่า" + ตัวนับ · ช่องพิมพ์ตัวใหญ่หลายบรรทัด · อาการที่ระบบเลือกให้ · ปุ่มหลัก "เสร็จ"
  Widget _qCcTypeCard(double top) {
    final big = _t(20.0, color: Colors.black, weight: FontWeight.w500);
    final n = _regCtl('cc').text.characters.length;
    final nw = _qCcNotchW;
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, top - 10.0, 8.0, 8.0),
      // การ์ดซ้อนเว้ามุมขวาล่างร่วมศูนย์กับรอยเว้าของการ์ด (ปุ่ม "บันทึก" อยู่ในรอยเว้า)
      child: CustomPaint(
        painter: _QNotchNestPaint(nw, _qCcNotchH),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 0.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const _QDuoIcon(Icons.keyboard_alt_rounded, size: 20.0),
              const SizedBox(width: 8.0),
              Text('พิมพ์คำเล่า',
                  style: _t(14.0, color: _blue, weight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12.0),
            TextField(
              controller: _regCtl('cc'),
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              maxLength: 300,
              // เล่าอาการ = เลือกประเภทผู้ป่วย/อาการ/คะแนนปวดให้ (knowledge ข้อ 78)
              onChanged: (_) => _qCcChanged(),
              style: big,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                counterText: '',
                hintText:
                    'พิมพ์คำเล่าอาการ เช่น ขี่มอเตอร์ไซค์ล้ม แผลที่ขา ปวด 7/10',
                hintMaxLines: 2,
                hintStyle:
                    big.copyWith(color: Colors.black.withValues(alpha: 0.25)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16.0),
            // แถวล่างซ้ายของรอยเว้า: ตัวนับตัวอักษร
            SizedBox(
              height: 36.0,
              child: Padding(
                padding: EdgeInsets.only(right: nw - 20.0 + 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('$n/300 ตัวอักษร',
                      style: _num(13.0, color: _ink3, weight: FontWeight.w500)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  /// การ์ดอัดเสียง (ผู้ใช้ 2026-11-27 "เพิ่ม bottom sheet inside this card" → "เอาเป็น nested card") ขยายขึ้นในการ์ด
  /// ป้าย "กำลังฟังอยู่" (จุดเต้นตามเสียง) + เวลา · คำเล่าตัวใหญ่
  /// คลื่นเสียงจริงแถวใหญ่ · ปุ่มหลักเต็มกว้าง "หยุดและบันทึก" (ถอดเสียง = ปุ่มเทา วงหมุน กดไม่ได้)
  Widget _qCcSheet(bool rec, bool busy, String text, double top) {
    final secs = _qCcSp?.seconds ?? 0;
    final big = _t(20.0, color: Colors.black, weight: FontWeight.w500);
    // การ์ดซ้อนในการ์ด (ผู้ใช้ 2026-11-27 "bottom sheet recording เอาเป็น nested card"):
    // พื้นขาว ขอบ 0.5 #DADCE0 ไม่มีเงา · ห่างขอบการ์ดนอก 8 (น้อยกว่าระยะหัวข้อ) · มุม 14 ร่วมศูนย์กับการ์ดนอก 22
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, top - 10.0, 8.0, 8.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            // จุดบอกว่ากำลังฟัง: โตตามระดับเสียงจริง
            ValueListenableBuilder<double>(
              valueListenable: erMicLevel,
              builder: (context, v, _) => Container(
                width: 10.0,
                height: 10.0,
                alignment: Alignment.center,
                child: Container(
                  width: rec ? 6.0 + 4.0 * v.clamp(0.0, 1.0) : 6.0,
                  height: rec ? 6.0 + 4.0 * v.clamp(0.0, 1.0) : 6.0,
                  decoration: BoxDecoration(
                    color: rec ? _blue : _ink3,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Text(rec ? 'กำลังฟังอยู่' : 'กำลังถอดเสียง',
                style: _t(14.0,
                    color: rec ? _blue : _ink2, weight: FontWeight.w600)),
            const Spacer(),
            if (rec)
              Text('${secs ~/ 60}:${(secs % 60).toString().padLeft(2, '0')}',
                  style: _num(16.0, color: _ink2, weight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12.0),
          Text.rich(TextSpan(children: [
            TextSpan(text: text, style: big),
            TextSpan(
                text: text.isEmpty
                    ? (rec ? 'พูดได้เลย…' : 'กำลังถอดเสียง…')
                    : (rec ? ' พูดต่อได้…' : ' …'),
                style:
                    big.copyWith(color: Colors.black.withValues(alpha: 0.25))),
          ])),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 56.0,
            child: rec
                ? const _QLiveWave(color: _blue, height: 56.0)
                : const SizedBox(),
          ),
          const SizedBox(height: 18.0),
          _Press(
            radius: 100.0,
            child: GestureDetector(
              onTap: busy ? null : _qCcMic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48.0,
                decoration: BoxDecoration(
                  color: busy ? const Color(0xFFF1F3F4) : _blue,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (busy)
                    const SizedBox(
                        width: 18.0,
                        height: 18.0,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.0, color: _blue))
                  else
                    Container(
                      width: 13.0,
                      height: 13.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                  const SizedBox(width: 10.0),
                  Text(busy ? 'กำลังถอดเสียง…' : 'หยุดและบันทึก',
                      style: _t(15.0,
                          color: busy ? _ink2 : Colors.white,
                          weight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /// จำนวนช่องที่ AI กรอกให้จากคำเล่า (นับเป็นช่อง: ความดันบน/ล่าง = 1 ช่อง · อาการทั้งหมด = 1 ช่อง)
  int get _qCcFilledCount => {
        for (final p in _qCcAuto)
          if (p.startsWith('type:'))
            'type'
          else if (p.startsWith('cc:'))
            'cc'
          else if (p.startsWith('vs:sbp') || p.startsWith('vs:dbp'))
            'bp'
          else if (p.startsWith('vs:'))
            p.substring(0, p.lastIndexOf(':'))
          else if (p.startsWith('gcs:'))
            'gcs${p[4]}'
          else
            p.substring(0, p.indexOf(':'))
      }.length;

  /// ป้ายมุมขวาบนของช่องคำเล่า: กำลังอ่าน = วงหมุน "AI กำลังกรอก…" · เสร็จ = ประกายสองโทน "AI กรอกให้ n ช่อง"
  /// พื้นไล่สีแบบ AI อ่อน ๆ · เปลี่ยนแบบจางเข้า
  Widget _qCcFillBadge() {
    final n = _qCcFilledCount;
    final busy = _qCcAiBusy;
    if (!busy && n == 0) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey(busy ? -1 : n),
        height: 28.0,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: const Color(0xFFE2DCF8), width: 0.8),
          gradient: const LinearGradient(colors: [
            Color(0xFFF1F4FF),
            Color(0xFFF5F0FF),
            Color(0xFFFFF2F8),
          ]),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (busy)
            const SizedBox(
                width: 13.0,
                height: 13.0,
                child:
                    CircularProgressIndicator(strokeWidth: 1.8, color: _blue))
          else
            const _QDuoIcon(Icons.auto_awesome_rounded, size: 15.0),
          const SizedBox(width: 6.0),
          Text(busy ? 'AI กำลังกรอก…' : 'AI กรอกให้ $n ช่อง',
              style: _t(12.5, color: _blue, weight: FontWeight.w600)),
        ]),
      ),
    );
  }

  /// ปุ่ม "บันทึก" ในรอยเว้าตอนพิมพ์: ทึบกรมท่า เครื่องหมายถูกขาว · บันทึกคำเล่า = ปิดคีย์บอร์ด ออกจากโหมดพิมพ์
  Widget _qCcSaveBtn() => _Press(
        radius: 100.0,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _qCcTyping = false);
            // บันทึก = ให้ AI อ่านคำเล่าทันที (ไม่รอหยุดพิมพ์) · ระหว่างอ่านแผงขึ้น loading
            final text = _regCtl('cc').text.trim();
            if (text.isNotEmpty) {
              _qCcTimer?.cancel();
              // กฎคำรอบสุดท้าย (รวมสัญญาณชีพ/GCS) แล้วให้ AI อ่านซ้ำแม้ข้อความเดิม (ผู้ใช้กดบันทึก = อยากให้กรอก)
              _qCcApply(_qCcRulePicks(text));
              _qCcAiDone = '';
              unawaited(_qCcAi(text));
            }
          },
          child: Container(
            height: 44.0,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_rounded, size: 20.0, color: Colors.white),
              const SizedBox(width: 8.0),
              Text('บันทึก',
                  style:
                      _t(14.0, color: Colors.white, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  /// ปุ่มพิมพ์ (รอง) ในรอยเว้าข้างปุ่มหลัก: วงกลมขาวขอบเทา ไอคอนสองโทนกรมท่าของแอป
  /// เปิดโหมดพิมพ์ = ฟ้าอ่อนขอบกรมท่า (ตัวเลือกที่เลือกอยู่) · กำลังฟัง/ถอดเสียง = จาง กดไม่ได้
  Widget _qCcKb() {
    final sp = _qCcSp;
    return AnimatedBuilder(
      animation: sp ?? const AlwaysStoppedAnimation(0),
      builder: (context, _) {
        final st = sp?.state ?? ErSpeechState.idle;
        final live = st == ErSpeechState.listening ||
            st == ErSpeechState.processing ||
            st == ErSpeechState.permission;
        return _Press(
          radius: 1000.0,
          child: GestureDetector(
            onTap: live
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    setState(() => _qCcTyping = !_qCcTyping);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: _qCcTyping ? const Color(0xFFE2EAF8) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: _qCcTyping ? _blue : const Color(0xFFDADCE0),
                    width: _qCcTyping ? 1.4 : 1.0),
              ),
              alignment: Alignment.center,
              child: Opacity(
                  opacity: live ? 0.4 : 1.0,
                  child:
                      const _QDuoIcon(Icons.keyboard_alt_rounded, size: 22.0)),
            ),
          ),
        );
      },
    );
  }

  /// ปุ่มหลักในรอยเว้า: บันทึกด้วยเสียงพูด (ไมค์ขาว) → กำลังฟัง = หยุดและบันทึก (สี่เหลี่ยมขาว)
  /// → กำลังถอดเสียง = ปุ่มเทา วงหมุน กดไม่ได้
  Widget _qCcCta() {
    final sp = _qCcSp;
    return AnimatedBuilder(
      animation: sp ?? const AlwaysStoppedAnimation(0),
      builder: (context, _) {
        final st = sp?.state ?? ErSpeechState.idle;
        final rec = st == ErSpeechState.listening;
        final busy =
            st == ErSpeechState.processing || st == ErSpeechState.permission;
        return _Press(
          radius: 100.0,
          child: GestureDetector(
            onTap: busy ? null : _qCcMic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44.0,
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              decoration: BoxDecoration(
                color: busy ? const Color(0xFFF1F3F4) : _blue,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 22.0,
                  height: 22.0,
                  child: Center(
                    child: busy
                        ? const SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.0, color: _blue))
                        : rec
                            ? Container(
                                width: 13.0,
                                height: 13.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              )
                            : const Icon(Icons.mic_rounded,
                                size: 22.0, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                    rec
                        ? 'หยุดและบันทึก'
                        : busy
                            ? 'กำลังถอดเสียง…'
                            : 'บันทึกด้วยเสียงพูด',
                    style: _t(14.0,
                        color: busy ? _ink2 : Colors.white,
                        weight: FontWeight.w700)),
              ]),
            ),
          ),
        );
      },
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
      if (_qFound || ((_qNew || _regUnknown) && _regHn.isNotEmpty))
        'HN $_regHn',
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
                // สายรัดข้อมือ ESI ชุดเดียวกับหน้ารายละเอียด/การ์ดเตียง
                // เปลี่ยนระดับ = คลี่ม้วนใหม่
                TweenAnimationBuilder<double>(
                  key: ValueKey('tri-band-${esi.level}'),
                  tween: Tween(begin: 0.24, end: 1.0),
                  duration: const Duration(milliseconds: 1100),
                  builder: (context, v, _) =>
                      _esiBand(null, esi.color, t: v, esi: esi),
                ),
              ],
              if (_triPain case final ps?) ...[
                const SizedBox(width: 6.0),
                _painPill(ps),
              ],
            ]),
            const SizedBox(height: 1.0),
            Text(
                meta.isNotEmpty
                    ? meta.join('   ')
                    : _regUnknown
                        ? 'ชื่อชั่วคราว ระบุตัวตนทีหลังได้'
                        : 'อ่านบัตรหรือค้นหาผู้ป่วย',
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

  /// คำอธิบายใต้ชื่อแท็บ (หัวหน้า)
  static const Map<String, String> _qTabSub = {
    'ประวัติ': 'ข้อมูลจากบัตรประชาชนและ HOSxP ตรวจทาน แล้วกรอกส่วนที่ยังขาด',
    'คัดกรอง': 'อาการ สัญญาณชีพ และข้อบ่งชี้ เพื่อหาระดับความเร่งด่วน (ESI)',
    'สรุป': 'ระดับที่ระบบแนะนำ ตรวจทานก่อนส่งตรวจ',
  };

  /// คำอธิบายใต้หัวข้อการ์ด (ใช้เมื่อการ์ดไม่ได้ส่ง count มาเอง)
  static const Map<String, String> _qCardSub = {
    'ข้อมูลผู้ป่วย': 'ข้อมูลจากบัตรประชาชนและประวัติใน HOSxP',
    'การเข้าห้องฉุกเฉิน': 'วันเวลาที่มาถึง เวร และสภาพผู้ป่วยตอนมาถึง',
    'ข้อมูลการมา': 'วิธีที่ผู้ป่วยมาถึง และผู้นำส่ง',
    'ผู้แจ้งข้อมูล': 'ใครเป็นผู้ให้ข้อมูลอาการและประวัติ',
    'อาการสำคัญ': 'อาการหลักที่ทำให้ผู้ป่วยมาห้องฉุกเฉิน',
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
    // หน้านี้เป็นที่วางหน้าพิมพ์ (ช่องข้อความเปิดเป็นหน้าย่อยในแผงขวา แบบเมนูอุบัติเหตุ ไม่ใช่แผ่นลอย)
    _ftInPage = true;
    _ftPageRebuild = () {
      if (mounted) setState(() {});
    };
    const tabs = [
      ('ประวัติ', Icons.person_outline_rounded, 'ข้อมูลผู้ป่วย'),
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
        ('Fast track', _triFt.isNotEmpty, tri[7]),
        (
          'สัญญาณชีพ',
          _triVal('hr') != null &&
              _triVal('rr') != null &&
              _triVal('sbp') != null,
          tri[0]
        ),
        ('ความรู้สึกตัว GCS', _triVal('gcs') != null, tri[1]),
        ('ระดับความปวด', _triPain != null, tri[6]),
        // NEWS2: แสดงเป็น banner ใต้การ์ดสัญญาณชีพแล้ว ไม่มีการ์ดแยก (tri[2])
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
      'Fast track': 'อาการ',
      'สัญญาณชีพ': 'สัญญาณชีพ',
      'ความรู้สึกตัว GCS': 'สัญญาณชีพ',
      'ระดับความปวด': 'สัญญาณชีพ',
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
    // การ์ดค่อย ๆ ปรากฏไล่ทีละใบ (เล่นใหม่ทุกครั้งที่เปลี่ยนเมนู เพราะ scroll view มี key ตามเมนู)
    final cards = [
      for (final (i, (k, _, w)) in secs.indexed)
        KeyedSubtree(
            key: _qSecKeys.putIfAbsent('$_qTab|$k', GlobalKey.new),
            child: _Appear(index: i + 1, child: w)),
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
          'ข้อมูลผู้ป่วย' when _regUnknown => [
              ('ชื่อชั่วคราว', true, null),
              ('เพศ', _regSex != null && _regSex != 'ไม่ระบุ', null),
              ('เบอร์ผู้นำส่งหรือญาติ', _qPhoneOk, 'phone'),
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
              ('BP', vs('sbp') && vs('dbp'), 'vs:sbp'),
              ('HR', vs('hr'), 'vs:hr'),
              ('RR', vs('rr'), 'vs:rr'),
              ('BT', vs('bt'), 'vs:bt'),
              ('SpO₂', vs('spo2'), 'vs:spo2'),
              ('DTX', true, 'vs:dtx'),
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
            // หัวสารบัญ: ชื่อ + จำนวนที่กรอก · donut ความคืบหน้าสีเขียวด้านขวา
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ในหน้านี้',
                          style:
                              _t(12.0, color: _ink3, weight: FontWeight.w600)),
                      const SizedBox(height: 2.0),
                      Text('กรอกแล้ว $done จาก ${allSecs.length}',
                          style: _t(13.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ]),
              ),
              TweenAnimationBuilder<double>(
                tween:
                    Tween(end: allSecs.isEmpty ? 0.0 : done / allSecs.length),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (_, x, __) => SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: x,
                        strokeWidth: 5.0,
                        strokeCap: StrokeCap.round,
                        backgroundColor: _panelSoft,
                        color: _green,
                      ),
                    ),
                    Text('${(x * 100).round()}%',
                        style: _num(10.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 12.0),
            Container(
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
    // เมนูย่อย (เดิมเป็นแท็บแนวนอนในการ์ด) กางใต้แท็บที่เลือก
    // สูง 56 กดง่ายบนแท็บเล็ต (ปุ่มจริง 52 เว้นระยะ 4)
    const subH = 56.0;
    final openH = tabH + (hasSub ? subTabs.length * subH + 10.0 : 0.0);
    Widget subItem(String t) {
      final on = sub == t;
      return _Press(
        scale: 0.98,
        radius: 8.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _qSubOf[_qTab] = t);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: subH - 4.0,
            margin: const EdgeInsets.fromLTRB(8.0, 0.0, 6.0, 4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  on ? const Color(0xFFE2EAF8) : _panel.withValues(alpha: 0.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(t,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0,
                    color: on ? _blue : _ink2,
                    weight: on ? FontWeight.w700 : FontWeight.w500)),
          ),
        ),
      );
    }

    // ตัวแท็บโปร่ง พื้นขาวเป็นแผ่นเดียวที่เลื่อนไปหาแท็บที่เลือก (ด้านล่าง)
    Widget tab((String, IconData, String) t) {
      final on = _qTab == t.$1;
      final head = _Press(
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
      // กาง/หุบเมนูย่อยพร้อมกับแผ่นขาวที่ยืดตาม (ใช้เวลาเดียวกัน)
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        head,
        AnimatedSize(
          duration: slide,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: on && hasSub
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final st in subTabs) subItem(st),
                    const SizedBox(height: 10.0),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ]);
    }

    // แผ่นขาวของแท็บที่เลือก + มุมเว้าบน/ล่าง เลื่อนไปพร้อมกัน
    Widget blob() => AnimatedPositioned(
          duration: slide,
          curve: Curves.easeOutCubic,
          top: onIdx * (tabH + tabGap),
          left: 0.0,
          right: 0.0,
          height: openH,
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
          width: 124.0,
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
            child: _wfText != null
                // หน้าพิมพ์: breadcrumb กลับหน้าเดิม + กล่องพิมพ์ เต็มแผง (ชุดเดียวกับ Doctor Note)
                ? ColoredBox(
                    key: ObjectKey(_wfText),
                    color: _panel,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                24.0, 16.0, 16.0, 6.0),
                            child: Row(children: [
                              _CrumbPrev(_qTab,
                                  onTap: () => _wfTextClose(null)),
                              const _CrumbSep(),
                              Expanded(
                                child: Text(_wfText!.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(14.0,
                                        color: _inkTitle,
                                        weight: FontWeight.w600)),
                              ),
                            ]),
                          ),
                          Expanded(child: _FtPage(req: _wfText!)),
                        ]),
                  )
                : _qTab == 'สรุป'
                    // สรุปทุกอย่างในหน้าเดียวก่อนส่งตรวจ + ระดับ ESI ด้านขวา
                    ? _qSummary(esi)
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Expanded(
                              child: Stack(children: [
                                Positioned.fill(
                                  child: SingleChildScrollView(
                                    // เปลี่ยนเมนู/เมนูย่อย = scroll view ใหม่ เริ่มบนสุดเสมอ
                                    key: ValueKey('qscroll|$_qTab|$sub'),
                                    padding: EdgeInsets.fromLTRB(
                                        24.0, 28.0, 24.0, 32.0),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxWidth: 880.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // หัวหน้าแบบ AdSense: ชื่อ + คำอธิบายซ้าย (ชิดบน) · รูปประกอบชิดขวา
                                            _Appear(
                                                index: 0,
                                                // ไม่ใช้ IntrinsicHeight: วัดความสูงข้อความไทยขาดไป 3 px = ล้นใต้การ์ด ESI
                                                // ชิดล่าง: รูปประกอบยืนบนขอบการ์ดแรกทุกหน้า แม้หัวข้อสูงไม่เท่ากัน (ผู้ใช้ 2026-11-27)
                                                // กรอบรูปเตี้ยกว่าข้อความทุกหน้า (56) ความสูงแถว = ข้อความ ข้อความจึงยังชิดบน
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(_qTab,
                                                                style: _t(26.0,
                                                                    color:
                                                                        _inkTitle,
                                                                    weight: FontWeight
                                                                        .w500)),
                                                            const SizedBox(
                                                                height: 6.0),
                                                            Text(
                                                                (_regUnknown &&
                                                                        _qTab ==
                                                                            'ประวัติ'
                                                                    ? 'ยังไม่ทราบตัวตน กรอกเท่าที่รู้ ระบุชื่อจริงทีหลังได้'
                                                                    : _qTabSub[
                                                                            _qTab] ??
                                                                        ''),
                                                                style: _t(14.0,
                                                                    color:
                                                                        _ink2,
                                                                    weight: FontWeight
                                                                        .w500)),
                                                            // ระดับ ESI แบบ real time ใต้คำอธิบายหน้าคัดกรอง
                                                            if (_qTab ==
                                                                'คัดกรอง') ...[
                                                              const SizedBox(
                                                                  height: 16.0),
                                                              _triEsiDock(),
                                                            ],
                                                            // แพ้ยา: banner แดงใต้คำอธิบายหน้า (ข้อมูลอันตราย ต้องเห็นก่อน)
                                                            if (_qTab ==
                                                                    'ประวัติ' &&
                                                                _regAllergy
                                                                    .isNotEmpty) ...[
                                                              const SizedBox(
                                                                  height: 16.0),
                                                              _qBanner(
                                                                  Icons
                                                                      .warning_rounded,
                                                                  'แพ้ยา ${_regAllergy.join(', ').toUpperCase()}',
                                                                  _red,
                                                                  sub: _qFound
                                                                      ? 'จากประวัติใน HOSxP ตรวจสอบกับผู้ป่วยอีกครั้ง'
                                                                      : 'ตรวจสอบกับผู้ป่วยอีกครั้ง'),
                                                            ],
                                                            // ผู้ป่วยใหม่: ช่องที่ยังขาด + ปุ่มไปที่ช่องว่าง
                                                            if (_qTab ==
                                                                    'ประวัติ' &&
                                                                _qNew) ...[
                                                              const SizedBox(
                                                                  height: 12.0),
                                                              () {
                                                                final miss =
                                                                    _qNewMissing();
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
                                                                    sub: _regHn
                                                                            .isNotEmpty
                                                                        ? 'ออก HN $_regHn แล้ว'
                                                                        : miss
                                                                                .isEmpty
                                                                            ? 'ระบบจะออก HN ให้เมื่อส่งต่อ'
                                                                            : 'ไม่พบประวัติใน HOSxP',
                                                                    action: miss
                                                                            .isEmpty
                                                                        ? null
                                                                        : 'ไปที่ช่องที่ยังว่าง',
                                                                    onAction:
                                                                        _qGoMissing,
                                                                    // ออก HN ได้เลย แสดงที่ header ทันที
                                                                    action2: _regHn
                                                                            .isEmpty
                                                                        ? 'ออก HN'
                                                                        : null,
                                                                    onAction2: () =>
                                                                        setState(() =>
                                                                            _regHn =
                                                                                _regNewHn()));
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
                                                        const SizedBox(
                                                            width: 16.0),
                                                        // รูปยืนบนขอบบนการ์ดแรก ปลายรูปจมใต้การ์ด · กินที่แถวหัวแค่ 56 (รูปสูง 112 ล้นกรอบขึ้นบน)
                                                        // แถวหัวไม่สูงตามรูป = การ์ดแรกขึ้นมาชิดหัวข้อ ไม่มีที่ว่างใต้คำอธิบาย (ผู้ใช้ 2026-11-27 "ยกการ์ดขึ้น")
                                                        SizedBox(
                                                          width: 260.0,
                                                          height: 56.0,
                                                          child: OverflowBox(
                                                            alignment: Alignment
                                                                .bottomRight,
                                                            maxHeight: 112.0,
                                                            child: Transform
                                                                .translate(
                                                              offset:
                                                                  const Offset(
                                                                      0.0,
                                                                      32.0),
                                                              child: Image.asset(
                                                                  'assets/images/er_hero_$hero.png',
                                                                  height: 112.0,
                                                                  fit: BoxFit
                                                                      .contain),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ])),
                                            const SizedBox(height: 4.0),
                                            const SizedBox(height: 16.0),
                                            ...cards,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
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

  /// ชิปอาการแบบ Google filter chip: ข้อความล้วน เลือกแล้วมีเครื่องหมายถูก
  /// เลือกอาการวิกฤต = แดง (ผิดปกติ) · อาการอื่น = กรมท่า
  Widget _qCcTile(String l, bool crit) {
    final on = _qCc.contains(l);
    final c = crit ? _red : _blue;
    return _Press(
      radius: 8.0,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (on) {
              _qCc.remove(l);
              _qCcForget('cc:$l');
            } else {
              _qCc.add(l);
            }
          });
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.only(
                left: on ? 8.0 : 14.0, right: 14.0, top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: on ? c.withValues(alpha: 0.08) : _panel,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: on ? c : const Color(0xFFDADCE0),
                  width: on ? 1.0 : 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (on) ...[
                // ✦ = ระบบเลือกให้จากคำเล่า · ✓ = ผู้ใช้เลือกเอง
                Icon(
                    _qCcAuto.contains('cc:$l')
                        ? Icons.auto_awesome_rounded
                        : Icons.check_rounded,
                    size: 18.0,
                    color: c),
                const SizedBox(width: 4.0),
              ],
              Flexible(
                child: Text(l,
                    style: _t(13.0,
                        color: on ? c : _inkTitle, weight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  /// หน้าแรกของการส่งตรวจ: โครงมินิมอล (ทักทาย + การ์ด 2 ใหญ่ 2 เล็ก) ในภาษาของแอป
  /// พื้น _bg · การ์ดขาว _clyCardDeco · ทางหลัก (อ่านบัตร) = การ์ดกรมท่าทึบ · ไอคอนแบบเมนูใบรับรองแพทย์
  /// ป้ายทาง = pill (ปัจจุบัน = ฟ้าอ่อนตัวกรมท่าหนา) · ปุ่มรอง = pill ขาวขอบเทา · ได้ข้อมูลแล้ว (_qLookup) เข้าหน้าคัดกรองทันที
  Widget _qIntroPage() {
    final user = ErSession.instance.user;
    final who = (user?.name ?? '').split(' ').take(2).join(' ');
    final waitN = _patients.where((p) => p.stage == _Stage.triage).length;

    // การ์ดวิธีดึงข้อมูล: ชื่อ + คำอธิบาย (คงที่) บนซ้าย · ไอคอนวงล่างซ้าย · ทางหลัก = กรมท่า ตัวขาว
    // รายการใน dock (ภาษาเดียวกับรางเมนูซ้ายของแอป): ช่องเท่ากัน ไอคอน + ชื่อ
    // ไม่เลือก = ไอคอนเส้น + ชื่อเทา · เลือกอยู่ = แผ่นกรมท่าทึบ ไอคอนทึบ/ชื่อขาวหนา
    Widget side(IconData icon, String label,
            {bool on = false, IconData? onIcon, VoidCallback? onTap}) =>
        _Press(
          radius: 16.0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: 80.0,
              height: 58.0,
              decoration: BoxDecoration(
                color: on ? _blue : null,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(on ? (onIcon ?? icon) : icon,
                        size: 22.0, color: on ? Colors.white : _ink3),
                    const SizedBox(height: 3.0),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label,
                          maxLines: 1,
                          style: _t(10.5,
                              color: on ? Colors.white : _ink3,
                              weight: on ? FontWeight.w700 : FontWeight.w500)),
                    ),
                  ]),
            ),
          ),
        );

    return Material(
      color: _bg,
      child: Stack(children: [
        // พื้นหลัง: ภาพทางเดินโรงพยาบาล (ภาพชุดเดียวกับแอป) เต็มจอ ชิดขวา
        // ทับด้วยสีพื้น _bg ไล่จากทึบซ้าย → โปร่งขวา ตัวหนังสือ/การ์ดยังอ่านชัด ฉากลึกโผล่ฝั่งขวา
        // พื้นหลัง = ภาพทางเดินเดิมขยายละเอียดไว้ในไฟล์ (lanczos 2048 + เพิ่มความคมเล็กน้อย ไม่เบลอ)
        // ภาพต้นฉบับ 768 px ให้ Flutter ขยายเต็มจอเองแล้วแตกเป็นขั้น
        Positioned.fill(
          child: _QRise(
              delay: 0,
              dy: 0.0,
              scale: 1.06,
              ms: 900,
              child: Image.asset('assets/images/er_intake_bg.jpg',
                  fit: BoxFit.cover, alignment: const Alignment(0.7, 0.0))),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _bg.withValues(alpha: 0.97),
                  _bg.withValues(alpha: 0.86),
                  _bg.withValues(alpha: 0.4),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Stack(children: [
            // dock ล่างกลาง (ลอย): ปุ่มเดียว "หน้าหลัก"
            // (รูปผู้ใช้ย้ายไปขวาบนเหนือ bento)
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 16.0,
              // การ์ดใหญ่เปิดอยู่ (อ่านบัตร ค้นหา อุบัติเหตุหมู่) มี footer ของตัวเอง = ซ่อน dock
              // (ไม่ให้มีปุ่ม "ย้อนกลับ" สองชุดบนจอเดียว)
              child: IgnorePointer(
                ignoring: _qRdView || _qHnView || _mci.on || _qCamOn,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  offset: Offset(0.0,
                      _qRdView || _qHnView || _mci.on || _qCamOn ? 1.6 : 0.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 240),
                    opacity:
                        _qRdView || _qHnView || _mci.on || _qCamOn ? 0.0 : 1.0,
                    child: _QRise(
                      delay: 480,
                      dy: 80.0,
                      ms: 620,
                      curve: Curves.easeOutBack,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(22.0),
                            border: Border.all(color: _line),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x1A0B1B3F),
                                  blurRadius: 20.0,
                                  offset: Offset(0.0, 6.0)),
                            ],
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            // ปุ่มเดียว: กลับหน้าหลัก (ย้อนกลับ / ห้องฉุกเฉิน / ส่งตรวจ ซ้ำกันหมด)
                            side(Icons.home_outlined, 'หน้าหลัก',
                                onTap: _closeRegister),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // เนื้อหา: เมนู ↔ การ์ดอ่านบัตร แบบต่อเนื่อง: การ์ด "อ่านบัตรประชาชน" ขยายจากตำแหน่งในเมนูเป็นการ์ดใหญ่กลางจอ
            // (เครื่องอ่าน/ป้ายเลื่อนไปที่ใหม่ ชื่อเดิมจาง · การ์ดอื่นจางออก) ปิด = หดกลับที่เดิม · พื้นหลัง/dock คงอยู่
            LayoutBuilder(builder: (context, box) {
              final dw = math.min(940.0, box.maxWidth - 80.0);
              final dh = math.min(540.0, box.maxHeight - 120.0);
              final dst = Rect.fromLTWH(40.0 + (box.maxWidth - 80.0 - dw) / 2,
                  24.0 + (box.maxHeight - 120.0 - dh) / 2, dw, dh);
              return KeyedSubtree(
                key: _qStageKey,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                      end: _qRdView || _qHnView || _mci.on || _qCamOn
                          ? 1.0
                          : 0.0),
                  duration: const Duration(milliseconds: 560),
                  curve: Curves.easeInOutCubic,
                  builder: (context, e, _) {
                    // เมนูนิ่งอยู่ = จำตำแหน่งการ์ดอ่านบัตรไว้ (ใช้เป็นจุดเริ่ม/จุดจบของการขยาย)
                    if (e == 0.0) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final rb = _qReadKey.currentContext?.findRenderObject()
                            as RenderBox?;
                        final st = _qStageKey.currentContext?.findRenderObject()
                            as RenderBox?;
                        if (rb != null &&
                            st != null &&
                            rb.hasSize &&
                            st.attached) {
                          _qMorphFrom =
                              rb.localToGlobal(Offset.zero, ancestor: st) &
                                  rb.size;
                        }
                        final hb = _qHnKey.currentContext?.findRenderObject()
                            as RenderBox?;
                        if (hb != null &&
                            st != null &&
                            hb.hasSize &&
                            st.attached) {
                          _qMorphFromHn =
                              hb.localToGlobal(Offset.zero, ancestor: st) &
                                  hb.size;
                        }
                        final fb = _qFaceKey.currentContext?.findRenderObject()
                            as RenderBox?;
                        if (fb != null &&
                            st != null &&
                            fb.hasSize &&
                            st.attached) {
                          _qMorphFromFace =
                              fb.localToGlobal(Offset.zero, ancestor: st) &
                                  fb.size;
                        }
                        final cb = _qCamKey.currentContext?.findRenderObject()
                            as RenderBox?;
                        if (cb != null &&
                            st != null &&
                            cb.hasSize &&
                            st.attached) {
                          _qMorphFromCam =
                              cb.localToGlobal(Offset.zero, ancestor: st) &
                                  cb.size;
                        }
                        final mb = _qMciKey.currentContext?.findRenderObject()
                            as RenderBox?;
                        if (mb != null &&
                            st != null &&
                            mb.hasSize &&
                            st.attached) {
                          _qMorphFromMci =
                              mb.localToGlobal(Offset.zero, ancestor: st) &
                                  mb.size;
                        }
                      });
                    }
                    // การ์ดต้นทางของการขยาย (อุบัติเหตุหมู่ขยายจากเมนูเฉพาะหน้าแรก · กลุ่มที่เปิดจากแผงรายชื่อ = จางเข้า)
                    final from = switch (_qKind) {
                      'hn' => _qMorphFromHn,
                      'cam' => _qMorphFromCam,
                      'face' => _qMorphFromFace,
                      'mci' => _mci.step == 5 ? _qMorphFromMci : null,
                      _ => _qMorphFrom,
                    };
                    return Stack(children: [
                      // เมนูคงอยู่ตลอด (ซ่อนเมื่อขยายเต็ม) = ไม่เล่น motion เปิดหน้าซ้ำตอนหดกลับ
                      TickerMode(
                        enabled: e < 1.0,
                        child: Offstage(
                          offstage: e >= 1.0,
                          child: IgnorePointer(
                            ignoring: e > 0.0,
                            child: Opacity(
                              opacity: (1.0 - e * 1.8).clamp(0.0, 1.0),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 70.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 820.0,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ทักทาย: ชื่อ (รอง) · จำนวนรอคัดกรอง (หลัก ตัวเลขกรมท่า)
                                        // รูปผู้ใช้อยู่ขวาสุด ชิดขอบขวาของ bento (ย้ายออกจาก dock)
                                        Row(children: [
                                          Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _QRise(
                                                    delay: 120,
                                                    child: Text('สวัสดี $who',
                                                        style: _t(20.0,
                                                            color: _ink2,
                                                            weight: FontWeight
                                                                .w500)),
                                                  ),
                                                  const SizedBox(height: 2.0),
                                                  _QRise(
                                                    delay: 200,
                                                    child: Text.rich(
                                                        waitN > 0
                                                            ? TextSpan(
                                                                children: [
                                                                    const TextSpan(
                                                                        text:
                                                                            'มีผู้ป่วยรอคัดกรอง '),
                                                                    TextSpan(
                                                                        text:
                                                                            '$waitN',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                _blue)),
                                                                    const TextSpan(
                                                                        text:
                                                                            ' ราย'),
                                                                  ])
                                                            : const TextSpan(
                                                                text:
                                                                    'ยังไม่มีผู้ป่วยรอคัดกรอง'),
                                                        style: _t(28.0,
                                                            color: _inkTitle,
                                                            weight: FontWeight
                                                                .w700)),
                                                  ),
                                                ]),
                                          ),
                                          if (user != null)
                                            _QRise(
                                              delay: 200,
                                              child: Tooltip(
                                                message: user.name,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  decoration: BoxDecoration(
                                                    color: _panel,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: _line),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                          color:
                                                              Color(0x140B1B3F),
                                                          blurRadius: 12.0,
                                                          offset:
                                                              Offset(0.0, 4.0)),
                                                    ],
                                                  ),
                                                  child: CircleAvatar(
                                                      radius: 24.0,
                                                      backgroundImage:
                                                          AssetImage(
                                                              user.face)),
                                                ),
                                              ),
                                            ),
                                        ]),
                                        const SizedBox(height: 28.0),
                                        // วิธีดึงข้อมูล 4 ทาง แบบ bento (อ่านบัตร · ถ่ายภาพบัตร ใหญ่ | สแกนหน้า / ค้นหา HN เล็กซ้อน)
                                        // ทุกใบ = การ์ดหัวเว้าแบบแฟ้ม (ป้ายในแถบแฟ้ม · ปุ่ม › · ชื่อ) ภาพประกอบไม่มีพื้นสี
                                        SizedBox(
                                          height: 330.0,
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: _QRise(
                                                    delay: 320,
                                                    dy: 26.0,
                                                    scale: 0.96,
                                                    // ระหว่างขยาย = ซ่อนตัวจริง (การ์ดที่ขยายวาดแทน)
                                                    child: Opacity(
                                                      key: _qReadKey,
                                                      opacity: e > 0.0 &&
                                                              _qKind == 'read'
                                                          ? 0.0
                                                          : 1.0,
                                                      child: _qMethodCard(
                                                          tag: _qReaderTag(),
                                                          tagW: _qRdOnline
                                                              ? _qTagW(
                                                                  'เครื่องอ่านพร้อม',
                                                                  lead: true)
                                                              : _qTagW(
                                                                  'ไม่พบเครื่องอ่าน'),
                                                          title:
                                                              'อ่านบัตรประชาชน',
                                                          image: _qImgReader(),
                                                          onTap: _qReadOpen,
                                                          // ไม่พบเครื่องอ่าน = ปิดใช้ช่องนี้ (ไปใช้กล้องหรือค้นหาแทน)
                                                          enabled: _qRdOnline,
                                                          // กดค้าง (สาธิต): พร้อม = จำลองไม่พบเครื่อง · ปิดอยู่ = ตรวจพบเครื่องอีกครั้ง
                                                          onLong: () => _qRdOnline
                                                              ? _qReadOpen(
                                                                  noDevice:
                                                                      true)
                                                              : setState(() =>
                                                                  _qRdOnline =
                                                                      true)),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  flex: 5,
                                                  // ถ่ายภาพบัตร (บน) · ลงทะเบียนส่งตรวจอุบัติเหตุหมู่ (ล่าง) = bento ย่อยแบบคอลัมน์ขวา
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Expanded(
                                                          child: _QRise(
                                                            delay: 400,
                                                            dy: 26.0,
                                                            scale: 0.96,
                                                            // ระหว่างขยาย = ซ่อนตัวจริง (การ์ดที่ขยายวาดแทน)
                                                            child: Opacity(
                                                                key: _qCamKey,
                                                                opacity: e >
                                                                            0.0 &&
                                                                        _qKind ==
                                                                            'cam'
                                                                    ? 0.0
                                                                    : 1.0,
                                                                child: _qMethodCard(
                                                                    compact:
                                                                        true,
                                                                    lines: 2,
                                                                    tag: _qTag(
                                                                        'ใช้กล้องของเครื่องนี้'),
                                                                    tagW: _qTagW(
                                                                        'ใช้กล้องของเครื่องนี้'),
                                                                    title:
                                                                        'ถ่ายภาพบัตรประชาชน',
                                                                    image:
                                                                        _qImgPhoto(),
                                                                    onTap:
                                                                        _qCamOpen)),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12.0),
                                                        Expanded(
                                                          child: _QRise(
                                                            delay: 440,
                                                            dy: 26.0,
                                                            scale: 0.96,
                                                            // ชื่อเมนูตาม HOSxP: ลงทะเบียนส่งตรวจอุบัติเหตุหมู่
                                                            // ระหว่างขยาย = ซ่อนตัวจริง (การ์ดที่ขยายวาดแทน)
                                                            child: Opacity(
                                                                key: _qMciKey,
                                                                opacity: e >
                                                                            0.0 &&
                                                                        _qKind ==
                                                                            'mci' &&
                                                                        _mci.step ==
                                                                            5
                                                                    ? 0.0
                                                                    : 1.0,
                                                                child: _qMethodCard(
                                                                    compact:
                                                                        true,
                                                                    tag: _qTag(
                                                                        _mciTagLabel),
                                                                    tagW: _qTagW(
                                                                        _mciTagLabel),
                                                                    title:
                                                                        'อุบัติเหตุหมู่',
                                                                    image:
                                                                        _mciArt(),
                                                                    imageW:
                                                                        _mciCardArtW,
                                                                    imageOut:
                                                                        _mciCardArtOut,
                                                                    onTap:
                                                                        _mciOpen)),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Expanded(
                                                          child: _QRise(
                                                            delay: 480,
                                                            dy: 26.0,
                                                            scale: 0.96,
                                                            // ระหว่างขยาย = ซ่อนตัวจริง (การ์ดที่ขยายวาดแทน)
                                                            child: Opacity(
                                                                key: _qFaceKey,
                                                                opacity: e >
                                                                            0.0 &&
                                                                        _qKind ==
                                                                            'face'
                                                                    ? 0.0
                                                                    : 1.0,
                                                                child: _qMethodCard(
                                                                    compact:
                                                                        true,
                                                                    tag: _qTag(
                                                                        'สำหรับผู้ป่วยที่มีในระบบ'),
                                                                    tagW: _qTagW(
                                                                        'สำหรับผู้ป่วยที่มีในระบบ'),
                                                                    title:
                                                                        'สแกนใบหน้า',
                                                                    image: _qImgFace(
                                                                        _faceUrl(_patients
                                                                            .first
                                                                            .hn),
                                                                        small:
                                                                            true),
                                                                    onTap:
                                                                        _qFaceOpen)),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12.0),
                                                        Expanded(
                                                          child: _QRise(
                                                            delay: 560,
                                                            dy: 26.0,
                                                            scale: 0.96,
                                                            child: Opacity(
                                                                key: _qHnKey,
                                                                opacity: e >
                                                                            0.0 &&
                                                                        _qKind ==
                                                                            'hn'
                                                                    ? 0.0
                                                                    : 1.0,
                                                                child: _qMethodCard(
                                                                    compact:
                                                                        true,
                                                                    tag: _qTag(
                                                                        'พิมพ์ค้นหา'),
                                                                    tagW: _qTagW(
                                                                        'พิมพ์ค้นหา'),
                                                                    title:
                                                                        'ค้นหาโดย HN',
                                                                    image: _qImgHn(
                                                                        _faceUrl(_patients
                                                                            .first
                                                                            .hn),
                                                                        small:
                                                                            true),
                                                                    onTap:
                                                                        _qSearchOpen)),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              ]),
                                        ),
                                        const SizedBox(height: 16.0),
                                        // ทางลัดผู้ป่วยไม่ทราบชื่อ (ปุ่มรอง pill ขาวขอบเทา)
                                        _QRise(
                                            delay: 640,
                                            child: Row(children: [
                                              _Press(
                                                radius: 100.0,
                                                child: GestureDetector(
                                                  onTap: () => setState(() {
                                                    _regUnknown = true;
                                                    _qFound = false;
                                                    _regSex ??= 'ไม่ระบุ';
                                                    if (_regHn.isEmpty) {
                                                      _regHn = _regNewHn();
                                                    }
                                                    _qIntro = false;
                                                  }),
                                                  child: Container(
                                                    height: 40.0,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16.0),
                                                    decoration: BoxDecoration(
                                                      color: _panel,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                      border: Border.all(
                                                          color: _line),
                                                    ),
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                              Icons
                                                                  .person_off_outlined,
                                                              size: 18.0,
                                                              color: _ink2),
                                                          const SizedBox(
                                                              width: 6.0),
                                                          Text(
                                                              'ไม่ทราบชื่อ ลงทะเบียนก่อน',
                                                              style: _t(13.0,
                                                                  color:
                                                                      _inkTitle,
                                                                  weight:
                                                                      FontWeight
                                                                          .w600)),
                                                        ]),
                                                  ),
                                                ),
                                              ),
                                            ])),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ยังไม่รู้ตำแหน่งการ์ดในเมนู (เช่น เปิดค้างไว้ก่อน reload) = จางสลับแทนการขยาย
                      if (e > 0.0 && e < 1.0)
                        _qKind == 'mci'
                            ? (from != null
                                ? _qMorphMci(from, dst, e)
                                // เปิดกลุ่มจากแผงรายชื่อ (ไม่มีการ์ดต้นทาง) = จางเข้าพร้อมขยายนิด
                                : Opacity(
                                    opacity: e,
                                    child: Transform.scale(
                                        scale: 0.96 + 0.04 * e,
                                        child: _mci.step == 5
                                            ? _mciIntroView()
                                            : _mciView())))
                            : _qKind == 'cam' || _qKind == 'face'
                                ? (from == null
                                    ? Opacity(opacity: e, child: _qCamPage())
                                    : _qMorphCam(from, dst, e))
                                : _qKind == 'hn'
                                    ? (_qMorphFromHn == null
                                        ? Opacity(
                                            opacity: e, child: _qSearchView())
                                        : _qMorphHn(_qMorphFromHn!, dst, e))
                                    : (_qMorphFrom == null
                                        ? Opacity(
                                            opacity: e, child: _qReadingView())
                                        : _qMorphCard(_qMorphFrom!, dst, e)),
                      // คอลัมน์ขวาของการ์ดใหญ่ จางเข้า/ออกครึ่งหลังของการขยาย ตัดตามขอบการ์ดที่กำลังโต
                      // (ตอนเปิดเสร็จ = หน้าจริงตรงตำแหน่งเดิม ไม่มีเนื้อหาโผล่ทีหลัง · ตอนปิด = ค่อย ๆ จางออก ไม่หายวับ)
                      if (e > 0.0 && e < 1.0 && from != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ClipRect(
                              clipper: _QRectClip(Rect.lerp(from, dst, e)!),
                              child: Opacity(
                                opacity: ((e - 0.5) / 0.5).clamp(0.0, 1.0),
                                child: switch (_qKind) {
                                  'hn' => _qSearchView(rightOnly: true),
                                  'mci' => _mciIntroView(rightOnly: true),
                                  'cam' || 'face' => _qCamPage(rightOnly: true),
                                  _ => _qReadingView(rightOnly: true),
                                },
                              ),
                            ),
                          ),
                        ),
                      if (e >= 1.0)
                        _qKind == 'mci'
                            // หน้าแรก (การ์ดแบบอ่านบัตร) ↔ การ์ดกลุ่ม = จางสลับ
                            ? AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                child: _mci.step == 5
                                    ? _mciIntroView()
                                    : _mciView())
                            : _qKind == 'cam' || _qKind == 'face'
                                ? _qCamPage()
                                : _qKind == 'hn'
                                    ? _qSearchView()
                                    : _qReadingView(),
                    ]);
                  },
                ),
              );
            }),
          ]),
        ),
      ]),
    );
  }

  Widget _quickRegisterPage() {
    if (_qIntro) return _qIntroPage();
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    final (sug, why) = _triAdvise();
    final level = _triPick ?? sug;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // อ่านบัตรแล้วซ่อนบัตร (ชื่อ เลขบัตร อยู่ใน header แล้ว)
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          // ไม่ทราบชื่อ = ไม่มีบัตรให้แสดง (ชื่อชั่วคราวอยู่ใน header และข้อมูลผู้ป่วยแล้ว)
          child: _qFound || _regUnknown
              ? const SizedBox(width: double.infinity)
              : _qIdCard(),
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
            _qOpt(l, null, _qArrive == l, () => _qSetArrive(l), h: 44.0),
        ],
        gap: 6.0);

    final who = _qCard(
      'ข้อมูลผู้ป่วย',
      sum: [
        if (_regName.isNotEmpty) _regName,
        if (_qFound || ((_qNew || _regUnknown) && _regHn.isNotEmpty))
          'HN $_regHn',
        if (_regAllergy.isNotEmpty) 'แพ้ ${_regAllergy.join(', ')}',
      ].join('  '),
      done: _regReady,
      count: _qFound
          ? 'พบใน HOSxP  HN $_regHn'
          : _qNew
              ? 'ผู้ป่วยใหม่ ไม่มีประวัติใน HOSxP'
              : _regUnknown
                  ? 'ไม่ทราบตัวตน ลงทะเบียนด้วยชื่อชั่วคราว'
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
            // ไม่ทราบชื่อ: แถวแบบเดียวกันทั้งการ์ด (ชื่อซ้าย | ค่าขวา เส้นคั่น) ไม่ปนช่องกรอกหลายแบบ
            // อายุ = ช่วงวัย (ไม่รู้วันเกิด) · ไม่มีช่องชื่อ-สกุล
            if (_regUnknown) ...[
              _qRow('ชื่อชั่วคราว', _regName, src: 'แก้ได้เมื่อทราบตัวตน'),
              // HN ออกให้อัตโนมัติตั้งแต่เปิดลงทะเบียน (ผู้ใช้ 2026-11-27 "เจนมาเองโดย default ไม่ต้องมีปุ่ม")
              _qRow('HN', _regHn,
                  src: 'ออกให้อัตโนมัติ ใช้สั่งการรักษาได้ทันที'),
              _qChoiceRow('เพศ *', const ['ชาย', 'หญิง', 'ไม่ระบุ'], _regSex,
                  (v) => setState(() => _regSex = v)),
              _qChipRow('age_band', 'อายุโดยประมาณ',
                  const ['เด็ก', 'ผู้ใหญ่', 'สูงอายุ']),
              _qEditRow('phone', 'เบอร์ผู้นำส่งหรือญาติ', 'กรอกเบอร์โทร',
                  kb: TextInputType.phone, last: true),
            ] else ...[
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
        ],
      ),
    );

    final cc = _qCcCard();

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
          // ผู้แจ้งไม่ใช่ผู้ป่วย: แถวแบบเดียวกับการ์ดอื่น (ชื่อซ้าย | พิมพ์ในแถวขวา)
          if (_qInformant != 'ผู้ป่วยเอง') ...[
            const SizedBox(height: 6.0),
            _qEditRow('inf_name', 'ชื่อผู้แจ้ง', 'กรอกชื่อผู้แจ้ง'),
            _qEditRow('inf_phone', 'เบอร์โทรผู้แจ้ง', 'กรอกเบอร์โทร',
                kb: TextInputType.phone, last: true),
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
              // ปุ่มหลักขวาบน (แคปซูลกรมท่า): ตรวจทานก่อนส่ง / ส่งเข้าคิวคัดกรอง
              // หน้าสรุป = ปุ่มส่งตรวจอยู่ล่างแผง ESI ขวา (ไม่ซ้ำขวาบน)
              if (_qTab != 'สรุป')
                _Press(
                  radius: 100.0,
                  child: GestureDetector(
                    // นอกหน้าสรุป = ไปตรวจทานที่หน้าสรุปก่อน · ในหน้าสรุป = ส่งจริง
                    onTap: !_regReady
                        ? null
                        : _qTab == 'สรุป'
                            // ผู้ป่วยในคิว = อัปเดตรายเดิม · ลงทะเบียนใหม่ = ส่งเข้าระบบ
                            ? () => _triP != null && level != null
                                ? _triSend(level)
                                : _qSend(esi: level)
                            : () {
                                HapticFeedback.selectionClick();
                                setState(() => _qTab = 'สรุป');
                              },
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
                            _qTab != 'สรุป'
                                ? 'ตรวจทานก่อนส่ง'
                                : level == null
                                    ? 'ส่งเข้าคิวคัดกรอง'
                                    : 'ส่งตรวจ',
                            style: _t(13.5,
                                color: _regReady ? Colors.white : _ink3,
                                weight: FontWeight.w700)),
                        const SizedBox(width: 6.0),
                        Icon(Icons.arrow_forward_rounded,
                            size: 18.0,
                            color: _regReady ? Colors.white : _ink3),
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
                          // ปุ่มส่งตรวจล่างแผงขวา: ส่งหลังเลือกแพทย์เวรเสร็จ
                          footer: SizedBox(
                            width: double.infinity,
                            height: 48.0,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: _blue,
                                disabledBackgroundColor: _line,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: !_regReady
                                  ? null
                                  : () => _triP != null && level != null
                                      ? _triSend(level)
                                      : _qSend(esi: level),
                              icon: const Icon(Icons.check_rounded,
                                  size: 20.0, color: Colors.white),
                              label: Text(
                                  level == null
                                      ? 'ส่งเข้าคิวคัดกรอง'
                                      : 'ส่งตรวจ',
                                  style: _t(15.0,
                                      color: Colors.white,
                                      weight: FontWeight.w700)),
                            ),
                          ),
                          // เปลี่ยนระดับเองอยู่บนสุดแล้ว การ์ดเริ่มต่อจากนั้น
                          cardTop: 0.0)),
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

/// บัตรประชาชน (ภาพประกอบ ตาม Figma 345:35 "Thai National ID Card"): พื้นฟ้าอ่อน ขอบฟ้า · ตราวงกลม · หัวไทย/อังกฤษ
/// เลขบัตร · ชื่อ · ชิปทอง · แถบโฮโลแกรมซ้าย · ช่องรูป · ที่อยู่ · วันออก/หมดอายุ · ข้อมูลเป็นตัวอย่าง (XXXXX)
/// วาดด้วยวิดเจ็ตบนผืน 290×184 แล้วย่อ/ขยายตาม [w] (ไม่ใช้ไฟล์ภาพ = hot reload ได้)
// ignore: unused_element
class _QIdCard extends StatelessWidget {
  const _QIdCard({this.w = 104.0});
  final double w;

  static const _ink = Color(0xFF1E2A5A), _en = Color(0xFF1F6FD8);

  TextStyle _s(double size, {bool bold = false, Color c = _ink}) => TextStyle(
      fontFamily: _fontFam,
      fontFamilyFallback: _fontFb,
      fontSize: size,
      height: 1.15,
      color: c,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    Widget at(double x, double y, Widget c) =>
        Positioned(left: x, top: y, child: c);
    Widget tx(double x, double y, String t, double size,
            {bool bold = false, Color c = _ink}) =>
        at(x, y, Text(t, style: _s(size, bold: bold, c: c)));
    return SizedBox(
      width: w,
      height: w / 290.0 * 184.0,
      child: FittedBox(
        child: Container(
          width: 290.0,
          height: 184.0,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F1FB), Color(0xFFD3E4F7)],
            ),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFF9DBCE4), width: 1.2),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000A2E),
                  blurRadius: 14.0,
                  offset: Offset(0.0, 6.0)),
            ],
          ),
          child: Stack(clipBehavior: Clip.none, children: [
            // ตราวงกลม
            at(
                10.0,
                10.0,
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFCFE0F5),
                    border:
                        Border.all(color: const Color(0xFF9DBCE4), width: 1.0),
                  ),
                )),
            tx(50.0, 9.0, 'บัตรประจำตัวประชาชน', 11.0, bold: true),
            tx(170.0, 10.5, 'Thai National ID Card', 9.2, bold: true, c: _en),
            tx(50.0, 25.0, 'เลขประจำตัวประชาชน', 5.5),
            tx(50.0, 31.5, 'Identification Number', 4.6, c: _en),
            tx(124.0, 24.0, '0 0000 00000 00 0', 9.8, bold: true),
            // เส้นใต้หัวบัตร
            at(
                48.0,
                41.0,
                Container(
                    width: 232.0, height: 0.9, color: const Color(0xFF7FA6DA))),
            tx(44.0, 50.0, 'ชื่อตัวและชื่อสกุล', 5.5),
            tx(110.0, 46.0, 'XXXXX XXXXXXXXX', 8.6, bold: true),
            tx(100.0, 62.0, 'Name', 5.2, c: _en),
            tx(118.0, 59.5, 'XXXXX', 8.0, bold: true),
            tx(94.0, 74.0, 'Last name', 5.2, c: _en),
            tx(122.0, 71.5, 'XXXXX', 8.0, bold: true),
            // แถบโฮโลแกรมซ้าย
            at(
                14.0,
                52.0,
                Container(
                  width: 10.0,
                  height: 106.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC6DAF3),
                    borderRadius: BorderRadius.circular(5.0),
                    border:
                        Border.all(color: const Color(0xFF9DBCE4), width: 0.8),
                  ),
                )),
            // ชิปทอง
            at(
                44.0,
                66.0,
                Container(
                  width: 38.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF2CF63), Color(0xFFD9A93A)],
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                    border:
                        Border.all(color: const Color(0xFFB98A24), width: 0.8),
                  ),
                  child: CustomPaint(painter: _QChipLines()),
                )),
            tx(110.0, 88.0, 'เกิดวันที่ 28 มี.ค. 2537', 6.4),
            tx(110.0, 97.0, 'Date of Birth 28 Mar. 1994', 5.5, c: _en),
            tx(110.0, 108.0, 'ศาสนา พุทธ', 6.4),
            // ช่องรูป
            at(
                218.0,
                84.0,
                Container(
                  width: 60.0,
                  height: 74.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FD),
                    borderRadius: BorderRadius.circular(4.0),
                    border:
                        Border.all(color: const Color(0xFF9DBCE4), width: 0.9),
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Positioned(
                      top: 12.0,
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFFC6DAF3)),
                      ),
                    ),
                    Positioned(
                      bottom: -10.0,
                      child: Container(
                        width: 44.0,
                        height: 38.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC6DAF3),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(22.0)),
                        ),
                      ),
                    ),
                  ]),
                )),
            tx(44.0, 122.0, 'ที่อยู่ xx/xx หมู่ที่ xx ถนน xxxxx', 6.4,
                bold: true),
            tx(44.0, 131.5, 'แขวง xxxxx อ.xxxx จ.xxxxx', 6.4),
            tx(44.0, 146.0, '28 มี.ค. 2567', 5.2, bold: true),
            tx(44.0, 152.5, 'วันออกบัตร', 4.9),
            tx(44.0, 158.5, '28 Mar. 2024', 4.9, c: _en),
            tx(44.0, 164.5, 'Date of Issue', 4.9, c: _en),
            // ตราเจ้าพนักงาน + ลายมือชื่อ
            at(
                112.0,
                146.0,
                Container(
                  width: 15.0,
                  height: 15.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF9DBCE4), width: 0.9),
                  ),
                )),
            at(
                130.0,
                151.0,
                Container(
                  width: 22.0,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC6DAF3),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                )),
            tx(108.0, 165.0, 'เจ้าพนักงานออกบัตร', 4.6),
            tx(176.0, 140.0, '28 มี.ค. 2576', 5.2, bold: true),
            tx(176.0, 146.5, 'วันหมดอายุ', 4.9),
            tx(176.0, 152.5, '28 Mar. 2033', 4.9, c: _en),
            tx(176.0, 158.5, 'Date of Expiry', 4.9, c: _en),
            tx(222.0, 165.0, '0000-00-00000000', 4.6),
          ]),
        ),
      ),
    );
  }
}

/// เส้นแบ่งช่องบนชิปทอง (แบบชิปสมาร์ทการ์ด)
class _QChipLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFB98A24)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    canvas.drawLine(Offset(w * 0.34, 0), Offset(w * 0.34, h), p);
    canvas.drawLine(Offset(w * 0.66, 0), Offset(w * 0.66, h), p);
    canvas.drawLine(Offset(0, h * 0.5), Offset(w * 0.34, h * 0.5), p);
    canvas.drawLine(Offset(w * 0.66, h * 0.5), Offset(w, h * 0.5), p);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.34, h * 0.22, w * 0.32, h * 0.56),
            const Radius.circular(2.0)),
        p);
  }

  @override
  bool shouldRepaint(_QChipLines old) => false;
}

/// มุมกล้องของภาพเครื่องอ่าน isometric (Blender toon 3 ชั้นกล้องเดียวกัน ortho): ไฟล์ · สัดส่วนภาพ · ตำแหน่งในภาพ (สัดส่วน)
/// ระยะดึงบัตรออก · ไฟสถานะ · ปากช่อง → ปลายบัตร (แนวแสงสแกน)
class _QView {
  const _QView(this.pre, this.aspect, this.out, this.led, this.slot, this.tip,
      {required this.a,
      required this.b,
      required this.c,
      required this.d,
      required this.chip,
      required this.ex,
      required this.ey});
  final String pre;
  final double aspect;
  final Offset out, led, slot, tip;

  /// หน้าบัตรส่วนที่โผล่: a/b = ปากช่อง (ซ้าย/ขวาบัตร) · d/c = ปลายบัตร · ชิปบนหลังเครื่อง + แกน x/y ของผิวบน (รัศมีชิป)
  final Offset a, b, c, d, chip, ex, ey;
}

/// การ์ดอ่านบัตรในเมนู + กรอบเวที (หาตำแหน่งเริ่มของการ์ดที่ขยาย) · ตำแหน่งเริ่มที่จับไว้ตอนกด
final _qReadKey = GlobalKey();
final _qHnKey = GlobalKey();
final _qStageKey = GlobalKey();
Rect? _qMorphFrom; // ตำแหน่งการ์ดอ่านบัตรในเมนู
Rect? _qMorphFromHn; // ตำแหน่งการ์ดค้นหา HN ในเมนู
final _qMciKey = GlobalKey();
final _qCamKey = GlobalKey();
Rect? _qMorphFromCam; // ตำแหน่งการ์ดถ่ายภาพบัตรในเมนู
final _qFaceKey = GlobalKey();
Rect? _qMorphFromFace; // ตำแหน่งการ์ดสแกนใบหน้าในเมนู
Rect? _qMorphFromMci; // ตำแหน่งการ์ดอุบัติเหตุหมู่ในเมนู
const _mciTagLabel = 'ผู้บาดเจ็บหลายราย';

/// ภาพรับผู้บาดเจ็บหมู่ (Figma 1342:333 ตัดพื้นหลังออก เหลือรถพยาบาล ทีมเข็นเปล ป้ายคัดแยก + เงานุ่ม)
/// รถต่อยาวตามเส้น perspective เดิม + วาดเก๋งหน้า ไฟไซเรน ล้อหน้า (ต้นฉบับโดนขอบภาพตัด) · เงาแบบ vector (สีอ่อนสีเดียว ขอบคม ทอดลงขวาทิศเดียวกันทั้งภาพ) · ภาพ 1285×899
const _mciArtAsset = 'assets/images/er_mci_scene.png';
const _mciArtW = 1285.0, _mciArtH = 899.0;
const _mciArtAspect = _mciArtW / _mciArtH;

/// ภาพในการ์ดเมนู: ใหญ่กว่าการ์ดเล็กอื่น (ฉากมีหลายคน) ล้นขอบขวาล่าง
const _mciCardArtW = 176.0;
const _mciCardArtOut = Offset(14.0, 14.0);
String _qKind = 'read'; // การ์ดที่กำลังขยาย/เปิดอยู่: 'read' | 'hn' | 'mci'

/// โหมดอุบัติเหตุหมู่ (MCI) ตามแผนรับอุบัติเหตุหมู่ของโรงพยาบาลจริง (รพ.โคกเจริญ รพ.ระนอง) + HOSxP:
/// เริ่มรับ (จำนวนที่แจ้ง สถานที่ ประเภทเหตุ · ไม่มีระดับแผน: ชื่อ/เกณฑ์ต่างกันทุก รพ. ผู้ใช้ไม่เข้าใจ) → รับผู้บาดเจ็บทีละรายตามสีที่คัดแยกหน้าประตู ได้ชื่อชั่วคราว + HN ทันที
/// ("นาย สีแดง อันดับ1 กลุ่ม A": คำนำหน้าตามเพศที่เห็น · ชื่อ = สีโซน · นามสกุล = อันดับบนป้ายข้อมือ นับแยกแต่ละสี
///  · กลุ่ม = เหตุการณ์ (แบบ Group A ของ HOSxP) แต่ละกลุ่มนับอันดับแยกกัน)
/// → ตรวจก่อนส่ง + ป้ายข้อมือ → ระหว่างเหตุการณ์ (ภาพรวมเหตุการณ์) → ระบุตัวตน/รวมเวชระเบียนทีหลัง
/// docs/knowledge.md ข้อ 50 · wireframe: claude.ai/artifact/9xuEZKupLpkXbmgWinivyy
class _MciCase {
  _MciCase(this.hn, this.tag, this.no, this.at, this.group);
  final String hn;
  int tag;
  int no;

  /// กลุ่มของเหตุการณ์ (A B C … แบบ Group A ของ HOSxP)
  final String group;

  /// 'ชาย' | 'หญิง' | null (ยังไม่ระบุ)
  String? sex;

  /// 'เด็ก' | 'ผู้ใหญ่' | 'สูงอายุ' | null
  String? age;
  final DateTime at;

  String get prefix => switch ((sex, age)) {
        ('ชาย', 'เด็ก') => 'ด.ช. ',
        ('หญิง', 'เด็ก') => 'ด.ญ. ',
        ('ชาย', _) => 'นาย ',
        ('หญิง', _) => 'นาง ',
        _ => '',
      };

  /// "นาย สีแดง อันดับ1 กลุ่ม A": กลุ่มต่อท้าย = ชื่อไม่ชนกันเมื่อมีหลายเหตุการณ์พร้อมกัน
  String get name => '${prefix}สี${_mciTags[tag].name} อันดับ$no กลุ่ม $group';
}

/// เหตุการณ์อุบัติเหตุหมู่ 1 กลุ่ม: ผู้บาดเจ็บ เลขอันดับ และสถานะแยกกันต่อกลุ่ม
/// (เกิดหลายเหตุพร้อมกันได้ เช่น รถชนบนถนน = กลุ่ม A · ไฟไหม้โรงงาน = กลุ่ม B)
class _MciEvent {
  _MciEvent(this.group);
  final String group;
  int expected = 8;
  String place = '';
  String kind = 'อุบัติเหตุจราจร';
  String right = 'พ.ร.บ. ผู้ประสบภัยจากรถ';

  /// เหตุการณ์ยังดำเนินอยู่ (ยังไม่กดจบเหตุการณ์)
  bool active = false;
  DateTime? openedAt;

  /// รับแล้วแต่ยังไม่ส่ง (เรียงตามสี แล้วตามอันดับ)
  final List<_MciCase> cases = [];
  String? lastHn;

  /// ส่งเข้าห้องฉุกเฉินแล้ว: HN → ข้อมูลตอนรับ (สี อันดับ เพศ วัย เวลา)
  final Map<String, _MciCase> sent = {};
  final Set<String> identified = {};

  /// อันดับที่ออกไปแล้วของแต่ละสีในกลุ่มนี้ (ไม่ใช้ซ้ำแม้ลบ = เลขบนป้ายข้อมือไม่ชนกัน)
  final Map<int, int> issued = {};

  int nextNo(int tag) => issued[tag] = (issued[tag] ?? 0) + 1;

  void sortCases() => cases.sort(
      (a, b) => a.tag != b.tag ? a.tag.compareTo(b.tag) : a.no.compareTo(b.no));

  /// ยังไม่ระบุตัวตน เรียงตามสี แล้วตามอันดับ (แดงก่อน)
  List<String> get waiting {
    final l = [
      for (final h in sent.keys)
        if (!identified.contains(h)) h
    ];
    l.sort((a, b) {
      final x = sent[a]!, y = sent[b]!;
      return x.tag != y.tag ? x.tag.compareTo(y.tag) : x.no.compareTo(y.no);
    });
    return l;
  }

  /// แสดงการ์ดในแผงรายชื่อ: ยังรับอยู่ หรือยังมีคนรอระบุตัวตน
  bool get visible => active || waiting.isNotEmpty;

  /// ยังไม่ได้เริ่มรับและไม่มีใครเลย (ร่างที่ยกเลิกได้)
  bool get blank => !active && cases.isEmpty && sent.isEmpty;
}

class _MciForm {
  /// การ์ดอุบัติเหตุหมู่เปิดอยู่บนหน้าส่งตรวจ
  bool on = false;

  /// 0 เริ่มรับ · 1 รับผู้บาดเจ็บ · 2 ตรวจก่อนส่ง · 3 ภาพรวมเหตุการณ์ · 4 ระบุตัวตน
  int step = 0;

  /// ทุกเหตุการณ์ (กลุ่ม) · [cur] = กลุ่มที่กำลังดู
  final List<_MciEvent> events = [];
  int cur = 0;
  _MciEvent get ev => events[cur.clamp(0, events.length - 1)];

  // ค่าของกลุ่มที่กำลังดู (หน้าจอทุกขั้นอ่าน/เขียนผ่านตัวนี้)
  int get expected => ev.expected;
  set expected(int v) => ev.expected = v;
  String get place => ev.place;
  set place(String v) => ev.place = v;
  String get kind => ev.kind;
  set kind(String v) => ev.kind = v;
  String get right => ev.right;
  set right(String v) => ev.right = v;
  bool get active => ev.active;
  set active(bool v) => ev.active = v;
  DateTime? get openedAt => ev.openedAt;
  set openedAt(DateTime? v) => ev.openedAt = v;
  List<_MciCase> get cases => ev.cases;
  String? get lastHn => ev.lastHn;
  set lastHn(String? v) => ev.lastHn = v;
  Map<String, _MciCase> get sent => ev.sent;
  Set<String> get identified => ev.identified;
  List<String> get waiting => ev.waiting;
  int nextNo(int tag) => ev.nextNo(tag);
  void sortCases() => ev.sortCases();

  /// HN ชั่วคราวเรียงกันทั้งโรงพยาบาล (ไม่ชนกันข้ามกลุ่ม)
  int? hnBase;
  int hnSeq = 0;

  /// ตัวกรอง "อุบัติเหตุหมู่" ในแผงรายชื่อ
  bool listOnly = false;

  /// ระบุตัวตน: HN ชั่วคราวที่กำลังระบุ · วิธี (-1 ยังไม่เลือก · 0 อ่านบัตร · 1 ค้นหา · 2 กรอกชื่อเอง)
  String? identifyHn;
  int idMethod = -1;
  bool idReading = false;
  bool idFound = false;

  /// ผู้ป่วยรายนี้มาจากอุบัติเหตุหมู่กลุ่มใดก็ได้
  bool isMci(String hn) => events.any((e) => e.sent.containsKey(hn));

  /// กลุ่มที่ยังแสดงอยู่ (รับอยู่ หรือมีคนรอระบุตัวตน)
  List<_MciEvent> get shown => [
        for (final e in events)
          if (e.visible) e
      ];

  /// ตัวอักษรกลุ่มถัดไปที่ยังไม่ถูกใช้
  String nextGroup() {
    final used = {for (final e in events) e.group};
    for (var i = 0; i < 26; i++) {
      final g = String.fromCharCode(65 + i);
      if (!used.contains(g)) return g;
    }
    return 'Z';
  }
}

final _mci = _MciForm();

/// สีคัดแยก: สี ชื่อ ความหมาย ระดับ ESI ที่ส่งต่อ (null = ไม่เข้าคิวรอตรวจ) จุดรักษา (แผน รพ.ระนอง)
/// ESI ต่อสียังรอทีมคลินิกยืนยัน
const List<({Color color, String name, String meaning, int? esi, String dest})>
    _mciTags = [
  (
    color: Color(0xFFBE1E2D),
    name: 'แดง',
    meaning: 'ต้องช่วยทันที',
    esi: 1,
    dest: 'ห้องกู้ชีพ'
  ),
  (
    color: Color(0xFFE8B10C),
    name: 'เหลือง',
    meaning: 'รอได้ไม่นาน',
    esi: 3,
    dest: 'ห้องสังเกตอาการ'
  ),
  (
    color: Color(0xFF006838),
    name: 'เขียว',
    meaning: 'เดินได้ บาดเจ็บน้อย',
    esi: 4,
    dest: 'ที่นั่งรอตรวจหน้า ER'
  ),
  (
    color: Color(0xFF2B2F36),
    name: 'ดำ',
    meaning: 'ไม่มีสัญญาณชีพ',
    esi: null,
    dest: 'พื้นที่แยก'
  ),
];

/// สีตัวอักษรบนพื้นสีคัดแยก (เหลือง = ตัวเข้ม)
Color _mciOn(int tag) => tag == 1 ? _inkTitle : Colors.white;

/// ชื่อชั่วคราว → (สี, อันดับ) ใช้วาดรูปแทนหน้าในรายชื่อ · null = ไม่ใช่ชื่อชั่วคราวอุบัติเหตุหมู่
(int, int)? _mciParse(String name) {
  final m = RegExp(r'สี(แดง|เหลือง|เขียว|ดำ) อันดับ(\d+)').firstMatch(name);
  if (m == null) return null;
  final t = _mciTags.indexWhere((x) => x.name == m.group(1));
  return t < 0 ? null : (t, int.parse(m.group(2)!));
}

const List<String> _mciKinds = [
  'อุบัติเหตุจราจร',
  'ไฟไหม้ ระเบิด',
  'อาคารถล่ม',
  'สารเคมี',
  'อื่น ๆ',
];

const List<String> _mciRights = ['พ.ร.บ. ผู้ประสบภัยจากรถ', 'ชำระเงินเอง'];

/// ผู้ป่วยในระบบที่ใช้จำลองการระบุตัวตน (อ่านบัตร / ค้นหา) ชุดเดียวกับหน้าค้นหา HN
const _mciRec = (
  name: 'นายสมชาย ใจดี',
  hn: '00012345',
  cid: '3400100123456',
  phone: '0812345678',
  age: 64,
  allergy: 'Penicillin',
);

const _qIsoView = _QView(
    'assets/images/er_id_reader_',
    834.0 / 558.0,
    Offset(0.1653, 0.1159),
    Offset(0.3342, 0.5726),
    Offset(0.5033, 0.5217),
    Offset(0.8396, 0.7576),
    a: Offset(0.3728, 0.6517),
    b: Offset(0.6338, 0.3917),
    c: Offset(0.9702, 0.6276),
    d: Offset(0.7091, 0.8876),
    chip: Offset(0.1614, 0.3685),
    ex: Offset(0.2127, 0.4045),
    ey: Offset(0.2044, 0.3256));

/// [stage] (หน้าจออ่านบัตร) = ภาพล้อตามขั้นตอนทางขวา: −1 รอเสียบ (บัตรอยู่นอกเครื่อง ขยับชี้เข้าช่องเป็นระยะ)
/// 0 ค้นหาเครื่อง (ไฟเครื่องกะพริบ + วงสัญญาณ) · 1 พบบัตร (บัตรเลื่อนเข้าช่อง) · 2 อ่านชิป (shimmer วน ไฟกะพริบถี่)
/// 3 ค้นประวัติ HOSxP (ป้ายค้นหาหมุนเหนือบัตร) · 4 เสร็จ (เหรียญเครื่องหมายถูกเด้งขึ้น) · [noDevice] = เครื่องจาง ไฟดับ ป้าย USB
class _QReaderArt extends StatefulWidget {
  const _QReaderArt(
      {required this.reading,
      this.view = _qIsoView,
      this.intro = true,
      this.stage,
      this.noDevice = false});
  final bool reading, intro, noDevice;
  final _QView view;
  final int? stage;

  @override
  State<_QReaderArt> createState() => _QReaderArtState();
}

class _QReaderArtState extends State<_QReaderArt>
    with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
      value: widget.intro ? 0.0 : 1.0);
  late final AnimationController _scan = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));
  // บัตรเข้าช่อง (หน้าจออ่านบัตร): 0 = อยู่นอก · 1 = เสียบแล้ว
  late final AnimationController _ins = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1.0); // บัตรเสียบอยู่แล้ว (ต่อจากภาพในเมนู)
  // ชี้เข้าช่องตอนรอเสียบ (เล่นเป็นระยะ)
  late final AnimationController _nudge = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  Timer? _t;

  bool get _staged => widget.stage != null;
  bool get _searching => widget.stage == 0 && !widget.noDevice;
  bool get _loop => widget.reading || _searching;

  @override
  void initState() {
    super.initState();
    if (widget.intro) {
      Future.delayed(const Duration(milliseconds: 620), () {
        if (mounted) _in.forward();
      });
    }
    Future.delayed(Duration(milliseconds: widget.intro ? 1650 : 150), () {
      if (!mounted) return;
      if (_loop) {
        _scan.repeat();
      } else if (!_staged) {
        _scan.forward(from: 0.0);
      }
    });
    _t = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (!_staged) {
        if (!widget.reading) _scan.forward(from: 0.0);
      } else if (widget.stage! < 0 && !widget.noDevice) {
        _nudge.forward(from: 0.0);
      }
    });
    // เปิดมาเป็น "รอเสียบบัตร": บัตรเริ่มเสียบอยู่ (ต่อจากภาพในเมนู) แล้วดึงออกจากช่องให้ตรงสถานะ
    // จากนั้นขยับชี้เข้าช่องเป็นระยะ · กดเริ่มอ่าน (พบบัตร) = เลื่อนกลับเข้าช่อง
    if (_staged && widget.stage! < 1) {
      Future.delayed(const Duration(milliseconds: 380), () {
        if (mounted && (widget.stage ?? 9) < 1) _ins.reverse();
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && (widget.stage ?? 0) < 0) _nudge.forward(from: 0.0);
      });
    }
  }

  @override
  void didUpdateWidget(_QReaderArt old) {
    super.didUpdateWidget(old);
    final was = old.reading || (old.stage == 0 && !old.noDevice);
    if (_loop && !was) _scan.repeat();
    if (!_loop && was) {
      _staged ? (_scan..stop()).value = 0.0 : _scan.forward();
    }
    final st = widget.stage ?? 9, os = old.stage ?? 9;
    if (st >= 1 && os < 1 && st < 4) _ins.forward();
    // อ่านเสร็จ = บัตรเลื่อนออกจากช่อง (คืนบัตรให้ผู้ป่วย)
    if (st >= 4 && os < 4) _ins.reverse();
    if (st < 1 && os >= 1) _ins.reverse();
  }

  @override
  void dispose() {
    _t?.cancel();
    _in.dispose();
    _scan.dispose();
    _ins.dispose();
    _nudge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vw = widget.view;
    final stage = widget.stage;
    return AspectRatio(
      aspectRatio: vw.aspect,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        Offset px(Offset q) => Offset(q.dx * w, q.dy * h);
        return AnimatedBuilder(
          animation: Listenable.merge([_in, _scan, _ins, _nudge]),
          builder: (context, _) {
            final v = _in.value;
            final appear =
                Curves.easeOutCubic.transform((v / 0.35).clamp(0.0, 1.0));
            final drop = _staged
                ? Curves.easeOutBack.transform(_ins.value)
                : Curves.easeOutBack
                    .transform(((v - 0.25) / 0.6).clamp(0.0, 1.0));
            // ชี้เข้าช่อง: ขยับเข้าหาช่อง 18% ของระยะ แล้วถอยกลับ
            final nudge = math.sin(_nudge.value * math.pi) * 0.18;
            final lift = (1.0 - drop - (drop < 0.01 ? nudge : 0.0));
            final s = _scan.value;
            final on = _scan.isAnimating;
            final led = widget.noDevice
                ? 0.0
                : widget.reading
                    ? (0.5 + 0.5 * math.sin(s * math.pi * 6)).abs()
                    : _searching
                        ? 0.25 + 0.75 * (0.5 + 0.5 * math.sin(s * math.pi * 4))
                        : (stage ?? -9) >= 3
                            ? 0.9
                            : on && !_staged
                                ? math.sin(s * math.pi)
                                : 0.0;
            // shimmer บนบัตร: อ่านชิป = วน · เมนู = 1 รอบเป็นระยะ
            final flow = widget.reading
                ? 1.0
                : on && !_staged
                    ? math.sin(s * math.pi)
                    : 0.0;
            final cardOpacity =
                _staged ? 1.0 : (drop * 3.0).clamp(0.0, 1.0).toDouble();
            return Opacity(
              opacity: appear,
              child: Transform.translate(
                offset: Offset(0.0, 14.0 * (1.0 - appear)),
                child: Stack(clipBehavior: Clip.none, children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: widget.noDevice ? 0.5 : 1.0,
                      child: Stack(children: [
                        Positioned.fill(child: Image.asset('${vw.pre}l.png')),
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(
                                vw.out.dx * w * lift, vw.out.dy * h * lift),
                            child: Opacity(
                              opacity: cardOpacity,
                              // shimmer: แถบแสงขาวนุ่มกว้าง ทแยงวิ่งซ้าย → ขวาบนเนื้อบัตร (ท่าเดียวกับ _Shimmer ของแอป)
                              child: ShaderMask(
                                blendMode: BlendMode.srcATop,
                                shaderCallback: (r) => LinearGradient(
                                  begin: Alignment(-2.6 + 4.0 * s, -0.3),
                                  end: Alignment(-0.6 + 4.0 * s, 0.3),
                                  colors: [
                                    const Color(0x00FFFFFF),
                                    Color.fromRGBO(255, 255, 255, 0.6 * flow),
                                    const Color(0x00FFFFFF),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ).createShader(r),
                                child: Image.asset('${vw.pre}c.png'),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(child: Image.asset('${vw.pre}u.png')),
                      ]),
                    ),
                  ),
                  // ค้นหาเครื่อง: วงสัญญาณกระจายจากไฟเครื่อง
                  if (_searching)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                            painter: _QPing(center: px(vw.led), t: s)),
                      ),
                    ),
                  if (led > 0.01)
                    Positioned(
                      left: vw.led.dx * w - 9.0,
                      top: vw.led.dy * h - 9.0,
                      child: Container(
                        width: 18.0,
                        height: 18.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            Color.fromRGBO(255, 255, 255, led),
                            (stage ?? -9) >= 4
                                ? Color.fromRGBO(92, 216, 144, 0.9 * led)
                                : Color.fromRGBO(111, 168, 255, 0.85 * led),
                            (stage ?? -9) >= 4
                                ? const Color(0x005CD890)
                                : const Color(0x006FA8FF),
                          ], stops: const [
                            0.0,
                            0.35,
                            1.0
                          ]),
                        ),
                      ),
                    ),
                  // ไม่พบเครื่อง: ป้าย USB ขาดบนตัวเครื่อง
                  if (widget.noDevice)
                    Positioned(
                      left: px(vw.chip).dx - 26.0,
                      top: px(vw.chip).dy - 26.0,
                      child: Container(
                        width: 52.0,
                        height: 52.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x33000A2E),
                                blurRadius: 12.0,
                                offset: Offset(0.0, 4.0)),
                          ],
                        ),
                        child: Icon(Icons.usb_off_rounded,
                            size: 26.0, color: _red),
                      ),
                    ),
                  // เสร็จ: ไฟเครื่องเขียวค้าง + วงแสงเขียวกระจายจากไฟ 1 ครั้ง (อ่านสำเร็จ)
                  if ((stage ?? -9) >= 4)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, k, _) => CustomPaint(
                              painter: _QDoneRing(center: px(vw.led), t: k)),
                        ),
                      ),
                    ),
                ]),
              ),
            );
          },
        );
      }),
    );
  }
}

/// วงสัญญาณกระจายจากจุด [center] (ค้นหาเครื่องอ่านบัตร): 2 วงสลับกัน ขยายแล้วจาง
class _QPing extends CustomPainter {
  const _QPing({required this.center, required this.t});
  final Offset center;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var r = 0; r < 2; r++) {
      final p = (t * 2 + r * 0.5) % 1.0;
      canvas.drawCircle(
          center,
          8.0 + 30.0 * p,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..color = Color.fromRGBO(143, 184, 255, 0.9 * (1.0 - p)));
    }
  }

  @override
  bool shouldRepaint(_QPing old) => old.t != t || old.center != center;
}

/// motion ตอนเปิดหน้าส่งตรวจ: เลื่อนขึ้น [dy] + จางเข้า (+ ขยายจาก [scale]) หลังรอ [delay] ms
/// ใช้เรียงลำดับ: พื้นหลังค่อย ๆ นิ่ง → ทักทาย 2 บรรทัด → การ์ดทีละใบ → ปุ่มล่าง · dock เด้งขึ้นจากขอบล่าง
class _QRise extends StatefulWidget {
  const _QRise(
      {required this.delay,
      required this.child,
      this.dy = 18.0,
      this.scale = 1.0,
      this.ms = 520,
      this.curve = Curves.easeOutCubic,
      this.instant = false});
  final int delay, ms;

  /// แสดงทันที (ไม่เล่น) · ใช้เมื่อมีการจางเข้าจากภายนอกแล้ว (เช่น การ์ดขยาย)
  final bool instant;
  final double dy, scale;
  final Curve curve;
  final Widget child;

  @override
  State<_QRise> createState() => _QRiseState();
}

class _QRiseState extends State<_QRise> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.ms),
      value: widget.instant ? 1.0 : 0.0);

  @override
  void initState() {
    super.initState();
    if (widget.instant) return;
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: widget.curve);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final k = a.value;
        return Opacity(
          opacity: Curves.easeOut.transform(_c.value),
          child: Transform.translate(
            offset: Offset(0.0, widget.dy * (1.0 - k)),
            child: Transform.scale(
                scale: widget.scale + (1.0 - widget.scale) * k, child: child),
          ),
        );
      },
      child: RepaintBoundary(child: widget.child),
    );
  }
}

/// รูปการ์ดหัวเว้าแบบแฟ้ม: แถบซ้ายพอดีป้าย (กว้าง [tab] px) สูงเต็ม แล้วไหล่โค้ง S นุ่มลง [notch] ไปทางขวา
/// มุมนอกโค้ง 22 ทุกมุม (รวมมุมขวาบนของส่วนที่เตี้ยลง)
/// [bw]×[bh] > 0 = รอยเว้ามุมขวาล่าง (วางปุ่มรองในรอยเว้า แบบการ์ดคำสั่งแพทย์)
/// สัดส่วน: มุมนูนสองมุมที่ปากรอยเว้า = รัศมีเดียวกับมุมการ์ด (22) · มุมเว้าด้านใน = รัศมีปุ่มแคปซูล + ระยะห่าง 8
/// (โค้งร่วมศูนย์กับปุ่ม ระยะห่างรอบปุ่มเท่ากันตลอด) · รอยเว้าสูง 52 = ปุ่มสูง 44 + ระยะห่าง 8
Path _qFolderPath(Size s, double tab, {double bw = 0.0, double bh = 0.0}) {
  const r = 22.0, n = _QFolderTabClip.notch, c = 18.0;
  final t = tab.clamp(r + c + 8.0, s.width - r - c - 8.0);
  final p = Path()
    ..moveTo(0.0, r)
    ..quadraticBezierTo(0.0, 0.0, r, 0.0)
    ..lineTo(t - c, 0.0)
    ..cubicTo(t - c * 0.25, 0.0, t - c * 0.15, n, t + c * 0.6, n)
    ..lineTo(s.width - r, n)
    ..quadraticBezierTo(s.width, n, s.width, n + r);
  if (bw > 4.0 && bh > 4.0) {
    final x = s.width - bw, y = s.height - bh;
    // ระหว่างรอยเว้ากำลังโต: ย่อรัศมีตามความสูง (มุมนูน + มุมเว้า = ความสูงรอยเว้าพอดี)
    final rr = math.min(r, bh * 22.0 / 52.0), qc = bh - rr;
    p
      ..lineTo(s.width, y - rr)
      ..arcToPoint(Offset(s.width - rr, y),
          radius: Radius.circular(rr), clockwise: true)
      ..lineTo(x + qc, y)
      ..arcToPoint(Offset(x, y + qc),
          radius: Radius.circular(qc), clockwise: false)
      ..lineTo(x, s.height - rr)
      ..arcToPoint(Offset(x - rr, s.height),
          radius: Radius.circular(rr), clockwise: true);
  } else {
    p
      ..lineTo(s.width, s.height - r)
      ..quadraticBezierTo(s.width, s.height, s.width - r, s.height);
  }
  return p
    ..lineTo(r, s.height)
    ..quadraticBezierTo(0.0, s.height, 0.0, s.height - r)
    ..close();
}

class _QFolderTabClip extends CustomClipper<Path> {
  const _QFolderTabClip(this.tab, {this.bw = 0.0, this.bh = 0.0});
  final double tab, bw, bh;
  static const notch = 18.0;

  @override
  Path getClip(Size size) => _qFolderPath(size, tab, bw: bw, bh: bh);

  @override
  bool shouldReclip(_QFolderTabClip old) =>
      old.tab != tab || old.bw != bw || old.bh != bh;
}

/// เส้นขอบบางของการ์ดแฟ้ม (ทับภาพล่างด้วย = ขอบต่อเนื่องรอบรูปทรง)
/// ตัดเป็นสี่เหลี่ยมตามกรอบที่กำหนด (ใช้ตัดเนื้อหาให้อยู่ในการ์ดที่กำลังขยาย)
class _QRectClip extends CustomClipper<Rect> {
  const _QRectClip(this.rect);
  final Rect rect;
  @override
  Rect getClip(Size size) => rect;
  @override
  bool shouldReclip(_QRectClip old) => old.rect != rect;
}

class _QFolderTabEdge extends CustomPainter {
  const _QFolderTabEdge(this.tab, {this.bw = 0.0, this.bh = 0.0});
  final double tab, bw, bh;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
      _qFolderPath(size, tab, bw: bw, bh: bh),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFFDADCE0));

  @override
  bool shouldRepaint(_QFolderTabEdge old) =>
      old.tab != tab || old.bw != bw || old.bh != bh;
}

/// idle motion ของภาพประกอบหน้าส่งตรวจ: เล่น [dur] ms ทุก [period] ms (Timer สั่งทีละรอบ ระหว่างพักไม่วาดเฟรม)
/// [painter] วาดทับภาพตามค่า t (0–1 ระหว่างเล่น · พัก = 1 = สถานะจบรอบ)
class _QIdle extends StatefulWidget {
  const _QIdle(
      {required this.period,
      required this.dur,
      required this.delay,
      required this.painter});
  final int period, dur, delay;
  final CustomPainter Function(double t) painter;

  @override
  State<_QIdle> createState() => _QIdleState();
}

class _QIdleState extends State<_QIdle> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: Duration(milliseconds: widget.dur), value: 1.0);
  Timer? _t, _d;

  @override
  void initState() {
    super.initState();
    _d = Timer(Duration(milliseconds: widget.delay), () {
      if (!mounted) return;
      _c.forward(from: 0.0);
      _t = Timer.periodic(Duration(milliseconds: widget.period), (_) {
        if (mounted) _c.forward(from: 0.0);
      });
    });
  }

  @override
  void dispose() {
    _d?.cancel();
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              CustomPaint(painter: widget.painter(_c.value)),
        ),
      );
}

double _qc(double x) => x.clamp(0.0, 1.0).toDouble();

/// ช่องกล้องถ่ายภาพบัตร: กรอบบัตร (สัดส่วนบัตรประชาชน) ตรงกลาง นอกกรอบมืดลง · มุมกรอบขาว → เขียวเมื่อบัตรพอดี
/// ยังไม่ต่อกล้องจริง (ต้องเพิ่มแพ็กเกจ camera) = ภาพจำลอง: บัตรค่อย ๆ เลื่อนเข้ากรอบ พอดี แล้วเลื่อนออก วนไป
/// [shot] = ถ่ายแล้ว: วาบขาว ภาพนิ่งที่ตำแหน่งพอดีกรอบ เส้นสแกนวิ่งระหว่างอ่าน
class _QCamFinder extends StatefulWidget {
  const _QCamFinder(
      {required this.shot,
      this.photo,
      this.still = false,
      this.face,
      this.done = false,
      this.noMatch = false});
  final bool shot;

  /// เทียบเสร็จแล้ว (แสดงผลอยู่): ไม่มีเส้นสแกน ป้ายบอกผล
  final bool done;

  /// ผู้ใช้เลือกว่าไม่มีในรายชื่อ: ป้ายบอก "ยังไม่มีประวัติในระบบ" (สีกลาง ไม่ใช่เขียว)
  final bool noMatch;

  /// สแกนใบหน้า: กรอบวงรี + รูปใบหน้าจำลอง (asset) · null = ถ่ายภาพบัตร
  final String? face;

  /// ภาพนิ่งท่าพอดีกรอบ (ใช้ระหว่างการ์ดขยายจากเมนู)
  final bool still;

  /// ภาพที่ถ่ายจริง (path) · ว่าง/null = ใช้บัตรจำลอง
  final String? photo;

  @override
  State<_QCamFinder> createState() => _QCamFinderState();
}

class _QCamFinderState extends State<_QCamFinder>
    with TickerProviderStateMixin {
  // เริ่มที่จังหวะล็อกกรอบ (ต่อจากภาพบนจอแท็บเล็ตในเมนูที่บัตรพอดีกรอบอยู่แล้ว) แล้วเล่าเรื่องวนต่อ
  late final AnimationController _aim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 6000), value: 0.54);

  @override
  void initState() {
    super.initState();
    if (!widget.still) _aim.repeat();
  }

  late final AnimationController _flash = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didUpdateWidget(_QCamFinder old) {
    super.didUpdateWidget(old);
    if (widget.shot && !old.shot) {
      _aim.stop();
      _flash.forward(from: 0.0);
    } else if (!widget.shot && old.shot) {
      _flash.value = 0.0;
      _aim.repeat();
    }
  }

  @override
  void dispose() {
    _aim.dispose();
    _flash.dispose();
    super.dispose();
  }

  // ท่าบัตรจำลองตามเวลา (หมุนแบบ 3D): 0–0.34 พลิกเข้า (หมุนแกน Y จากเกือบตั้งฉาก + เอียงแกน X แล้ววางราบ
  // เกินนิดแล้วนิ่ง) · 0.34–0.82 พอดีกรอบ · 0.82–1 พลิกออกอีกทางแล้วจาง (วนใหม่)
  static IdCardPose _pose(double t) => IdCardPose.at(t);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.0),
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth, h = box.maxHeight;
        final face = widget.face;
        // กรอบบัตร: กว้าง 78% ของช่อง สัดส่วน 290:184 (บัตรประชาชน) · ใบหน้า = วงรีตั้ง สูงเกือบเต็มช่อง
        final fw = math.min(w * 0.78, (h - 96.0) * 290.0 / 184.0);
        final oh = h - 120.0;
        final frame = face != null
            ? Rect.fromCenter(
                center: Offset(w / 2, h / 2 + 12.0),
                width: oh * 0.78,
                height: oh)
            : Rect.fromCenter(
                center: Offset(w / 2, h / 2 + 8.0),
                width: fw,
                height: fw * 184.0 / 290.0);
        return AnimatedBuilder(
          animation: Listenable.merge([_aim, _flash]),
          builder: (context, _) {
            final tt = widget.shot || widget.still ? 0.7 : _aim.value;
            final p = _pose(tt);
            final fp = FacePose.at(tt);
            final fit = widget.shot || (face != null ? fp.fit : p.fit);
            final f = _flash.value;
            final real = (widget.photo ?? '').isNotEmpty;
            return Stack(children: [
              if (real)
                Positioned.fill(
                  child: kIsWeb
                      ? Image.network(widget.photo!, fit: BoxFit.cover)
                      : Image.file(File(widget.photo!), fit: BoxFit.cover),
                ),
              // พื้นโต๊ะใต้กล้อง (จำลอง)
              if (!real)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.0, -0.2),
                        radius: 1.1,
                        colors: [Color(0xFF5A6478), Color(0xFF2A303A)],
                      ),
                    ),
                  ),
                ),
              // ใบหน้า: ภาพจากกล้องจำลอง เลื่อน/ซูมจนหน้าอยู่กลางวงรี
              if (!real && face != null)
                Positioned.fill(child: FaceSim(pose: fp, frame: frame)),
              // บัตร (หมุนแบบ 3D มี perspective)
              if (!real && face == null)
                Positioned.fromRect(
                  rect: frame,
                  child: Transform.translate(
                    offset: Offset(p.dx * w, p.dy * h),
                    child: IdCard3D(pose: p, face: const _QIdCard(w: 290.0)),
                  ),
                ),
              // กรอบ: นอกกรอบมืด + มุมกรอบ
              Positioned.fill(
                child: CustomPaint(
                    painter: IdCardFramePainter(
                        frame: frame,
                        fit: fit,
                        snap: face != null ? fp.snap : p.snap,
                        oval: face != null)),
              ),
              // คำแนะนำเหนือกรอบ
              Positioned(
                left: 0.0,
                right: 0.0,
                top: face != null ? 12.0 : frame.top - 46.0,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Container(
                      key: ValueKey(fit),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 7.0),
                      decoration: BoxDecoration(
                        color: fit && !widget.noMatch
                            ? _green
                            : Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(
                          widget.noMatch
                              ? 'ยังไม่มีประวัติในระบบ'
                              : widget.done
                                  ? 'พบผู้ป่วยที่หน้าตรงกัน'
                                  : widget.shot
                                      ? face != null
                                          ? 'สแกนแล้ว กำลังเทียบใบหน้า'
                                          : 'ถ่ายแล้ว กำลังอ่านข้อมูล'
                                      : fit
                                          ? face != null
                                              ? 'พอดีกรอบแล้ว กดสแกนได้เลย'
                                              : 'พอดีกรอบแล้ว กดถ่ายภาพได้เลย'
                                          : face != null
                                              ? 'ให้ใบหน้าอยู่ในกรอบ'
                                              : 'วางบัตรด้านหน้าให้พอดีกรอบ',
                          style: TextStyle(
                              fontFamily: _fontFam,
                              fontFamilyFallback: _fontFb,
                              fontSize: 13.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
              // ถ่ายแล้ว: เส้นสแกนวิ่งบนบัตร
              if (widget.shot && !widget.done && f > 0.15)
                Positioned(
                  left: frame.left + 10.0,
                  width: frame.width - 20.0,
                  top: frame.top +
                      frame.height * ((f - 0.15) / 0.85 * 2.0 % 1.0),
                  height: 3.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: _green.withValues(alpha: 0.9),
                            blurRadius: 12.0,
                            spreadRadius: 2.0),
                      ],
                    ),
                  ),
                ),
              // วาบขาวตอนกดถ่าย
              if (f > 0.0 && f < 0.25)
                Positioned.fill(
                  child: ColoredBox(
                      color: Colors.white
                          .withValues(alpha: 0.9 * (1.0 - f / 0.25))),
                ),
            ]);
          },
        );
      }),
    );
  }
}

/// อุบัติเหตุหมู่: ไฟไซเรนกะพริบ (พิกัดภาพ 1285×899) · แดงกะพริบคู่ครึ่งรอบแรก น้ำเงินกะพริบคู่ครึ่งหลัง
/// แสงฟุ้งเป็นวงไล่สีรอบดวงไฟ + แกนขาวที่ดวงไฟ (ดวงไฟติด) · ไฟเหลืองหายใจช้า
class _QIdleSiren extends CustomPainter {
  const _QIdleSiren(this.t);
  final double t;

  static const _barRed = Offset(128.6, 129.7), _barBlue = Offset(144.8, 137.6);
  static const _reds = [
    Offset(383.8, 178.4),
    Offset(452.2, 184.4),
    Offset(727.6, 134.0)
  ];
  static const _blues = [Offset(532.2, 171.2), Offset(661.8, 146.4)];
  static const _amber = Offset(599.2, 158.2);

  // กะพริบคู่: ติด [a, a+0.1] และ [a+0.16, a+0.26]
  static double _blink(double t, double a) {
    double bump(double s, double e) =>
        t < s || t > e ? 0.0 : math.sin(math.pi * (t - s) / (e - s));
    return math.max(bump(a, a + 0.1), bump(a + 0.16, a + 0.26));
  }

  void _glow(Canvas canvas, Offset c, Color col, double k, double r) {
    if (k <= 0.0) return;
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            col.withValues(alpha: 0.8 * k),
            col.withValues(alpha: 0.3 * k),
            col.withValues(alpha: 0.0),
          ], stops: const [
            0.0,
            0.35,
            1.0
          ]).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(
        c, r * 0.14, Paint()..color = Colors.white.withValues(alpha: 0.7 * k));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const red = Color(0xFFFF4B3E), blue = Color(0xFF3D8BFF);
    final kr = _blink(t, 0.0), kb = _blink(t, 0.5);
    _glow(canvas, _barRed, red, kr, 96.0);
    _glow(canvas, _barBlue, blue, kb, 96.0);
    for (final p in _reds) {
      _glow(canvas, p, red, kr * 0.9, 62.0);
    }
    for (final p in _blues) {
      _glow(canvas, p, blue, kb * 0.9, 62.0);
    }
    _glow(canvas, _amber, const Color(0xFFFFB020),
        0.35 * (0.5 - 0.5 * math.cos(2.0 * math.pi * t)), 34.0);
  }

  @override
  bool shouldRepaint(_QIdleSiren old) => old.t != t;
}

/// ถ่ายภาพบัตร: วาบขาวบนบัตรในจอ (พิกัด SVG 512×576 เลื่อนลง 64) แล้วเหรียญถูกเขียวเด้งที่มุมขวาบนของบัตร
class _QIdlePhoto extends CustomPainter {
  const _QIdlePhoto(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1.0) return;
    canvas.save();
    canvas.translate(0.0, 64.0);
    const tl = Offset(182.6, 254.5), tr = Offset(263.2, 240.2);
    const br = Offset(279.8, 285.9), bl = Offset(200.4, 304.4);
    const c = Offset(231.5, 271.3);
    Offset ex(Offset p) => c + (p - c) * 1.06;
    final flash = t < 0.12 ? t / 0.12 : _qc(1.0 - (t - 0.12) / 0.3);
    if (flash > 0.0) {
      canvas.drawPath(
          Path()
            ..moveTo(ex(tl).dx, ex(tl).dy)
            ..lineTo(ex(tr).dx, ex(tr).dy)
            ..lineTo(ex(br).dx, ex(br).dy)
            ..lineTo(ex(bl).dx, ex(bl).dy)
            ..close(),
          Paint()..color = Color.fromRGBO(255, 255, 255, 0.9 * flash));
    }
    // เหรียญถูก: เด้งหลังวาบ แล้วจางก่อนจบรอบ
    final pop = Curves.easeOutBack.transform(_qc((t - 0.3) / 0.25));
    final fade = _qc((1.0 - t) / 0.15);
    if (pop > 0.0) {
      final p = tr + const Offset(-2.0, -2.0);
      final r = 9.0 * pop;
      canvas.drawCircle(
          p, r, Paint()..color = Color.fromRGBO(92, 216, 144, fade));
      final ck = Path()
        ..moveTo(p.dx - r * 0.42, p.dy)
        ..lineTo(p.dx - r * 0.1, p.dy + r * 0.32)
        ..lineTo(p.dx + r * 0.45, p.dy - r * 0.3);
      canvas.drawPath(
          ck,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2 * pop
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = Color.fromRGBO(255, 255, 255, fade));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_QIdlePhoto old) => old.t != t;
}

/// สแกนหน้า: เส้นสแกนเขียวเรืองกวาดบนลงล่างในช่องรูปหน้าบนจอ (พิกัด SVG viewBox 118,160 226×240)
class _QIdleFace extends CustomPainter {
  const _QIdleFace(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1.0) return;
    canvas.save();
    canvas.translate(-118.0, -160.0);
    const tl = Offset(191.9, 248.7), tr = Offset(245.5, 235.7);
    const br = Offset(271.7, 304.4), bl = Offset(217.1, 316.1);
    canvas.clipPath(Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy)
      ..lineTo(bl.dx, bl.dy)
      ..close());
    final e = Curves.easeInOutSine.transform(t);
    final env = math.sin(t * math.pi);
    for (var k = 0; k < 6; k++) {
      final q = _qc(e - k * 0.03);
      final a = Offset.lerp(tl, bl, q)!, b = Offset.lerp(tr, br, q)!;
      canvas.drawLine(
          a,
          b,
          Paint()
            ..strokeWidth = k == 0 ? 2.0 : 4.0
            ..color = k == 0
                ? Color.fromRGBO(92, 216, 144, env)
                : Color.fromRGBO(92, 216, 144, 0.16 * env * (1.0 - k / 6.0)));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_QIdleFace old) => old.t != t;
}

/// ค้นหา HN: บนจอแท็บเล็ต (ระนาบจอเอียงตามมุมมอง = matrix เดียวกับ SVG) พิมพ์ = แผ่นขาวทับแถบข้อความค่อย ๆ หด
/// แล้วแถวผลลัพธ์ปรากฏ (แผ่นสีจอทับจางหาย) · พัก = แสดงครบ
class _QIdleHn extends CustomPainter {
  const _QIdleHn(this.t);
  final double t;

  static final Float64List _m = Float64List.fromList([
    0.972123, -0.234473, 0, 0, //
    0.387425, 0.921901, 0, 0, //
    0, 0, 1, 0, //
    141.900, 203.700, 0, 1,
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1.0) return;
    canvas.save();
    canvas.translate(-118.0, -160.0);
    canvas.transform(_m);
    const x = 9.349, y = 60.115, ry = 89.115, bw = 98.160, tw = 49.080;
    final inA = _qc(t / 0.06);
    final type = _qc((t - 0.08) / 0.42);
    final found = _qc((t - 0.58) / 0.1);
    final x0 = x + 25.0 + tw * type;
    if (type < 1.0) {
      canvas.drawRect(Rect.fromLTRB(x0, y + 5.0, x + 25.0 + tw + 6.0, y + 17.0),
          Paint()..color = Color.fromRGBO(255, 255, 255, inA));
    }
    if (found < 1.0) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(x - 0.6, ry - 0.6, bw + 1.2, 31.2),
              const Radius.circular(8.0)),
          Paint()..color = Color.fromRGBO(65, 74, 96, inA * (1.0 - found)));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_QIdleHn old) => old.t != t;
}

/// อ่านบัตรสำเร็จ: วงแสงเขียว 2 วงกระจายจากไฟเครื่องแล้วจาง (เล่นครั้งเดียว)
class _QDoneRing extends CustomPainter {
  const _QDoneRing({required this.center, required this.t});
  final Offset center;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var r = 0; r < 2; r++) {
      final p = ((t - r * 0.25) / 0.75).clamp(0.0, 1.0);
      if (p <= 0.0 || p >= 1.0) continue;
      canvas.drawCircle(
          center,
          8.0 + 46.0 * p,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 * (1.0 - p) + 0.5
            ..color = Color.fromRGBO(92, 216, 144, 0.9 * (1.0 - p)));
    }
  }

  @override
  bool shouldRepaint(_QDoneRing old) => old.t != t || old.center != center;
}

/// shimmer บนปุ่มหลัก: แถบแสงขาวนุ่มทแยงวิ่งซ้าย → ขวาเฉพาะบนเนื้อปุ่ม ทุก ~2.6 วินาที
/// (Timer สั่งทีละรอบ ระหว่างพักไม่วาดเฟรม) · [on] = false = ไม่มีผล
class _QShimmer extends StatefulWidget {
  const _QShimmer({required this.child, this.on = true});
  final Widget child;
  final bool on;

  @override
  State<_QShimmer> createState() => _QShimmerState();
}

class _QShimmerState extends State<_QShimmer>
    with SingleTickerProviderStateMixin {
  // สร้างตอนเริ่มเลย (ไม่ lazy): ปุ่มที่ไม่เคยแสดงประกาย ถ้าสร้างใน dispose จะ assert (ancestor ถูกถอดแล้ว)
  late final AnimationController _c;
  Timer? _t, _d;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100), value: 1.0);
    if (!widget.on) return;
    _d = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _c.forward(from: 0.0);
      _t = Timer.periodic(const Duration(milliseconds: 2600), (_) {
        if (mounted) _c.forward(from: 0.0);
      });
    });
  }

  @override
  void dispose() {
    _d?.cancel();
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.on) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final v = Curves.easeInOutSine.transform(_c.value);
        if (_c.value >= 1.0) return child!;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment(-2.4 + 4.4 * v, -0.6),
            end: Alignment(-1.4 + 4.4 * v, 0.6),
            colors: const [
              Color(0x00FFFFFF),
              Color(0x59FFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(r),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
