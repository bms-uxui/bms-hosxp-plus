/// ข้อมูลเคสจำลองรายคนของห้องฉุกเฉิน อิงโครงฟอร์ม HOSxP Plus (er_form_kb.json)
///
/// ทุกคนใน `_patients` ของหน้า ER flow มีเคสของตัวเองที่นี่ (key = HN)
/// ค่าต่าง ๆ ตั้งใจให้หลากหลายตามขั้นงาน: คนรอคัดกรองยังไม่มี GCS/แล็บ
/// คนตรวจแล้วมีคำสั่งแพทย์ ผลแล็บ ภาพถ่าย และแผนขั้นถัดไป
library;

// master data fast track ใช้คู่กับเคส (ผูกตามประเภท/อาการสำคัญ)
export 'er_fast_track.dart';

enum ErLevel { critical, urgent, normal }

class ErDx {
  const ErDx(this.text, this.level, {this.icd10});
  final String text;
  final ErLevel level;
  final String? icd10;
}

class ErMed {
  const ErMed(this.name, this.route, this.time);
  final String name;
  final String route;
  final String time;
}

/// ชนิดผล Lab: ตัวเลข (มีช่วงปกติ) · ข้อความ · ภาพ
enum ErLabType { numeric, text, image }

class ErLab {
  /// ผลตัวเลข + ช่วงปกติ lo-hi
  const ErLab(this.name, this.value, this.lo, this.hi)
      : type = ErLabType.numeric,
        text = '',
        image = '',
        flagged = false;

  /// ผลเป็นข้อความ เช่น Negative / O Rh+ · flagged = ผิดปกติ
  const ErLab.text(this.name, this.text, {this.flagged = false})
      : type = ErLabType.text,
        value = 0,
        lo = 0,
        hi = 0,
        image = '';

  /// ผลเป็นภาพ (asset) + คำอ่านผล (ถ้ามี)
  const ErLab.image(this.name, this.image,
      {this.text = '', this.flagged = false})
      : type = ErLabType.image,
        value = 0,
        lo = 0,
        hi = 0;

  final String name;
  final ErLabType type;
  final double value;
  final double lo;
  final double hi;
  final String text;
  final String image;
  final bool flagged;

  bool get isNumeric => type == ErLabType.numeric;
  bool get abnormal => isNumeric ? (value < lo || value > hi) : flagged;

  /// ผลแบบข้อความสั้น ใช้ได้ทุกชนิด
  String get resultText {
    if (!isNumeric) return text.isEmpty ? 'ดูภาพ' : text;
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
  }
}

class ErImage {
  const ErImage(this.name, this.result, this.asset);
  final String name;
  final String result;
  final String asset;
}

class ErEvent {
  const ErEvent(this.time, this.text, {this.byDoctor = false, this.kind});
  final String time;
  final String text;
  final bool byDoctor;

  /// หมวดกิจกรรมพยาบาล = ชื่อขั้นในเมนู workflow ของพยาบาล (null = การพยาบาล)
  final String? kind;
}

class ErNote {
  const ErNote(this.time, this.by, this.text, {this.kind});
  final String time;
  final String by;
  final String text;

  /// หมวดกิจกรรมพยาบาล = ชื่อขั้นในเมนู workflow ของพยาบาล (null = การพยาบาล)
  final String? kind;
}

class ErCase {
  const ErCase({
    required this.hn,
    required this.age,
    required this.sex,
    required this.bloodGroup,
    required this.right,
    required this.arrival,
    required this.condition,
    required this.cc,
    this.onset,
    this.hpi = '',
    this.painScore,
    this.gcs,
    this.consciousness = 'ตื่นดี',
    this.dx = const [],
    this.allergies = const [],
    this.underlying = const [],
    this.meds = const [],
    this.labs = const [],
    this.imaging = const [],
    required this.times,
    required this.hr,
    required this.sbp,
    required this.dbp,
    required this.spo2,
    required this.rr,
    required this.bt,
    this.team = const [],
    this.lastNote,
    this.nurseNotes = const [],
    this.nextStep = '',
    this.nextDetail = '',
    this.advice = const [],
    this.events = const [],
    this.disposition = '',
  });

  final String hn;
  final int age;

  /// อายุแบบ ปี เดือน วัน (รูปแบบที่ต้องใช้แสดงผลเสมอ)
  /// ข้อมูลจำลองมีแค่ปี · เดือนและวันคำนวณจาก HN ให้คงที่ต่อผู้ป่วย (รอวันเกิดจริง)
  String get ageText {
    final h = hn.codeUnits.fold<int>(0, (a, c) => (a * 31 + c) & 0x7fffffff);
    return '$age ปี ${h % 12} เดือน ${(h ~/ 12) % 28 + 1} วัน';
  }

  final String sex;
  final String bloodGroup;

  /// สิทธิการรักษา (ช่อง "สิทธิ" ในข้อมูลผู้ป่วย)
  final String right;

  /// ประเภทการมา / สภาพผู้ป่วย ตามตัวเลือกหน้าคัดกรอง
  final String arrival;
  final String condition;
  final String cc;

  /// เวลาเริ่มอาการ (HH:mm) สำหรับเคส time-critical (stroke/STEMI/sepsis/trauma)
  final String? onset;
  final String hpi;
  final int? painScore;

  /// GCS เป็นข้อความตามตัวเลือก E/V/M ของหน้าคัดกรอง เช่น "E4 V5 M6"
  final String? gcs;
  final String consciousness;
  final List<ErDx> dx;
  final List<String> allergies;
  final List<String> underlying;
  final List<ErMed> meds;
  final List<ErLab> labs;
  final List<ErImage> imaging;

  /// เวลาที่วัดสัญญาณชีพ เรียงเก่า → ใหม่ ความยาวเท่ากับ series
  final List<String> times;
  final List<double> hr;
  final List<double> sbp;
  final List<double> dbp;
  final List<double> spo2;
  final List<double> rr;
  final List<double> bt;

  final List<(String, String)> team;
  final ErNote? lastNote;

  /// บันทึกทางการพยาบาล (ข้อความอิสระ + เวลา) เรียงใหม่ → เก่า
  /// ใช้มากในช่วงสังเกตอาการ: ประเมินซ้ำ ให้การพยาบาล ผลตอบสนอง
  final List<ErNote> nurseNotes;
  final String nextStep;
  final String nextDetail;
  final List<String> advice;
  final List<ErEvent> events;

  /// สภาพผู้ป่วยออกจากห้อง ER (ตัวเลือกจริง 9 แบบ) ว่าง = ยังไม่ตัดสิน
  final String disposition;

  String get bp => '${sbp.last.round()}/${dbp.last.round()}';
  String get gcsScore {
    final g = gcs;
    if (g == null) return '-';
    final m = RegExp(r'E(\d).*V(\d).*M(\d)').firstMatch(g);
    if (m == null) return g;
    final sum = int.parse(m.group(1)!) +
        int.parse(m.group(2)!) +
        int.parse(m.group(3)!);
    return '$sum';
  }
}

// ---------------------------------------------------------------- ทีมประจำเวร
const List<(String, String)> _teamDoc1 = [
  ('พญ. ศิริพร ก.', 'แพทย์เจ้าของไข้'),
  ('พย. วราภรณ์ ส.', 'พยาบาลประจำเตียง'),
  ('ภก. ธนกร ว.', 'เภสัชกร'),
];
const List<(String, String)> _teamDoc2 = [
  ('นพ. ธีรภัทร อ.', 'แพทย์เจ้าของไข้'),
  ('พย. ณัฐพร ล.', 'พยาบาลประจำเตียง'),
];
const List<(String, String)> _teamTriage = [
  ('พย. ณัฐพร ล.', 'พยาบาลคัดกรอง'),
];

const _ctBrain = 'assets/images/xray/ct_brain.png';
const _cxr = 'assets/images/xray/cxr.jpg';
const _cxrLat = 'assets/images/xray/cxr_lat.jpg';

/// เคสทั้งหมด key = HN
const Map<String, ErCase> erCases = {
  // ------------------------------------------------------------ รอคัดกรอง
  '670123456': ErCase(
    hn: '670123456',
    age: 62,
    sex: 'ชาย',
    bloodGroup: 'O',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'มาเอง',
    condition: 'เดินมา',
    cc: 'ญาติพบพูดไม่ชัด ปากเบี้ยวไปทางซ้าย แขนขาขวายกไม่ขึ้น เดินเซ ขณะนั่งกินข้าวเช้า เริ่มเป็น 40 นาทีก่อนมา รพ. ไม่ชัก ไม่ปวดศีรษะ',
    onset: '09:28',
    hpi:
        'ญาติสังเกตว่าพูดไม่ชัดขณะกินข้าวเช้า ยกแขนขวาไม่ขึ้น ไม่ปวดศีรษะ ไม่ชัก',
    underlying: ['ความดันโลหิตสูง', 'เบาหวานชนิดที่ 2', 'ไขมันในเลือดสูง'],
    times: ['09:38', '09:53', '10:08'],
    hr: [86, 90, 88],
    sbp: [180, 172, 176],
    dbp: [100, 96, 98],
    spo2: [97, 98, 97],
    rr: [18, 18, 18],
    bt: [36.8, 36.7, 36.8],
    team: _teamTriage,
    nextStep: 'คัดกรอง Stroke fast track',
    nextDetail: 'เข้าเกณฑ์ FAST · แจ้งแพทย์เวรทันที',
    advice: [
      'ประเมิน FAST และเวลาเริ่มอาการให้ชัด',
      'เตรียม CT brain ด่วนภายใน 25 นาที'
    ],
    events: [
      ErEvent('10:08', 'ลงทะเบียนมาถึงห้องฉุกเฉิน · มาเอง', kind: 'คัดกรอง')
    ],
  ),
  '670123457': ErCase(
    hn: '670123457',
    age: 71,
    sex: 'หญิง',
    bloodGroup: 'A',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'มาเอง',
    condition: 'อุ้มมา',
    cc: 'ไข้สูงต่อเนื่อง ไอมีเสมหะเขียว กินได้น้อยลง 2 วัน วันนี้ญาติปลุกตื่นยาก ตอบช้า ปัสสาวะออกน้อยลง ก่อนมา รพ.',
    hpi: 'ญาติเล่าว่าไข้ต่ำ ๆ ปัสสาวะขุ่น 2 วัน วันนี้เรียกแล้วตอบช้า',
    underlying: ['เบาหวานชนิดที่ 2', 'ไตเรื้อรังระยะ 3'],
    times: ['09:41', '09:56', '10:11'],
    hr: [108, 102, 104],
    sbp: [92, 98, 96],
    dbp: [56, 60, 58],
    spo2: [94, 95, 95],
    rr: [26, 24, 24],
    bt: [38.9, 38.6, 38.4],
    team: _teamTriage,
    nextStep: 'คัดกรอง · เฝ้าระวัง Sepsis',
    nextDetail: 'qSOFA 2 · ต้องได้ ESI 2 ขึ้นไป',
    advice: ['วัดสัญญาณชีพครบ วัด GCS', 'เจาะ Lactate ทันทีหลังคัดกรอง'],
    events: [
      ErEvent('10:11', 'ลงทะเบียนมาถึงห้องฉุกเฉิน · ญาตินำส่ง', kind: 'คัดกรอง')
    ],
  ),
  '670123458': ErCase(
    hn: '670123458',
    age: 45,
    sex: 'ชาย',
    bloodGroup: 'B',
    right: 'ประกันสังคม',
    arrival: 'มาเอง',
    condition: 'รถนั่ง',
    cc: 'ตกบันไดบ้าน 3 ขั้น ข้อเท้าขวาพลิกเข้าด้านใน ปวดบวมทันที ลงน้ำหนักไม่ได้ เดินต้องมีคนพยุง 1 ชั่วโมงก่อนมา รพ. ศีรษะไม่กระแทก',
    hpi: 'พลาดขั้นบันได 3 ขั้น ข้อเท้าพลิก ลงน้ำหนักไม่ได้ ไม่ปวดศีรษะ',
    painScore: 6,
    times: ['09:44', '10:14'],
    hr: [98, 92],
    sbp: [142, 138],
    dbp: [86, 84],
    spo2: [98, 98],
    rr: [20, 18],
    bt: [36.7, 36.7],
    team: _teamTriage,
    nextStep: 'คัดกรอง',
    nextDetail: 'Ottawa ankle rule · น่าจะ ESI 4',
    advice: ['ประคบเย็น ยกสูง ระหว่างรอ'],
    events: [
      ErEvent('10:14', 'ลงทะเบียนมาถึงห้องฉุกเฉิน · นั่งรถเข็น',
          kind: 'คัดกรอง')
    ],
  ),
  '670123459': ErCase(
    hn: '670123459',
    age: 27,
    sex: 'หญิง',
    bloodGroup: 'AB',
    right: 'จ่ายเอง',
    arrival: 'มาเอง',
    condition: 'เดินมา',
    cc: 'กินกุ้งเผาที่งานเลี้ยง 30 นาทีต่อมามีผื่นลมพิษนูนแดงขึ้นทั้งตัว คันมาก ริมฝีปากบวม รู้สึกแน่นคอเล็กน้อย ยังหายใจได้ ก่อนมา รพ.',
    hpi:
        'กินกุ้งเผา 30 นาทีก่อน ผื่นนูนแดงทั้งตัว ไม่แน่นหน้าอก ไม่หายใจลำบาก ริมฝีปากไม่บวม',
    allergies: ['กุ้ง', 'ปู'],
    times: ['09:47', '10:02', '10:17'],
    hr: [112, 104, 98],
    sbp: [108, 114, 118],
    dbp: [66, 70, 74],
    spo2: [97, 98, 98],
    rr: [20, 18, 18],
    bt: [36.9, 36.9, 36.9],
    team: _teamTriage,
    nextStep: 'คัดกรอง',
    nextDetail: 'เฝ้าระวัง anaphylaxis · ESI 3',
    advice: ['ถ้าเสียงแหบ หายใจลำบาก แจ้งแพทย์ทันที'],
    events: [
      ErEvent('10:17', 'ลงทะเบียนมาถึงห้องฉุกเฉิน · เดินมาเอง', kind: 'คัดกรอง')
    ],
  ),
  '670123460': ErCase(
    hn: '670123460',
    age: 34,
    sex: 'ชาย',
    bloodGroup: 'O',
    right: 'พ.ร.บ. รถ',
    arrival: 'ส่งตัวโดย BLS',
    condition: 'เปลนอน',
    cc: 'ขับรถจักรยานยนต์ล้มเองบนถนนลื่น สวมหมวกนิรภัย ศีรษะกระแทกพื้น จำเหตุการณ์ได้ ปวดไหล่ซ้าย ไหปลาร้าผิดรูป ยกแขนไม่ขึ้น 30 นาทีก่อนมา รพ.',
    hpi:
        'กู้ชีพแจ้ง ล้มเองบนถนนสายรอง หมดสติ ~2 นาที ณ ที่เกิดเหตุ อาเจียน 1 ครั้ง ดื่มสุรา',
    painScore: 5,
    gcs: 'E3 ลืมตาเมื่อถูกเรียก V4 พูดคุยได้แต่สับสน M6 ทำตามคำสั่งได้',
    consciousness: 'สับสน',
    times: ['09:49', '10:04', '10:19'],
    hr: [108, 112, 110],
    sbp: [130, 126, 128],
    dbp: [82, 78, 80],
    spo2: [96, 96, 96],
    rr: [20, 20, 20],
    bt: [36.5, 36.5, 36.5],
    team: _teamTriage,
    nextStep: 'คัดกรอง Trauma',
    nextDetail: 'Immobilize C-spine ไว้แล้ว · GCS 13',
    advice: [
      'ห้ามถอด C-collar จนกว่าแพทย์ประเมิน',
      'บันทึกข้อมูลอุบัติเหตุ: ไม่สวมหมวก · ดื่ม'
    ],
    events: [
      ErEvent('10:19', 'ลงทะเบียนมาถึงห้องฉุกเฉิน · ส่งตัวโดย BLS',
          kind: 'คัดกรอง'),
      ErEvent('10:19', 'รับตัวจากรถกู้ชีพ C-collar + long spinal board',
          kind: 'คัดกรอง'),
    ],
  ),

  // ------------------------------------------------------------ รอตรวจ
  '670123461': ErCase(
    hn: '670123461',
    age: 58,
    sex: 'ชาย',
    bloodGroup: 'A',
    right: 'ข้าราชการ',
    arrival: 'ส่งตัวโดย ALS',
    condition: 'เปลนอน',
    cc: 'เจ็บแน่นกลางอกเหมือนมีของหนักทับ ร้าวไปแขนซ้ายและกราม เหงื่อแตก ใจสั่น คลื่นไส้ ขณะยกของ นั่งพักไม่ดีขึ้น เป็นต่อเนื่อง 1 ชั่วโมงก่อนมา รพ.',
    onset: '08:55',
    hpi:
        'เจ็บแน่นกลางอกขณะพัก 1 ชม. ร้าวแขนซ้าย เหงื่อออก คลื่นไส้ ไม่เคยเป็นมาก่อน',
    painScore: 8,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [ErDx('STEMI anterior wall', ErLevel.critical, icd10: 'I21.0')],
    allergies: [],
    underlying: ['ความดันโลหิตสูง', 'สูบบุหรี่ 20 มวน/วัน'],
    meds: [
      ErMed('Aspirin 300 mg', 'เคี้ยว · ครั้งเดียว', '10:02'),
      ErMed('O2 mask with reservoir', '10 L/min', '10:00'),
    ],
    labs: [ErLab('Troponin I', 1.8, 0, 0.04), ErLab('K', 4.1, 3.5, 5.1)],
    imaging: [ErImage('ECG 12 lead', 'ST elevation V1–V4', _cxr)],
    times: ['10:00', '10:10', '10:20'],
    hr: [102, 98, 96],
    sbp: [148, 142, 138],
    dbp: [92, 90, 88],
    spo2: [94, 97, 98],
    rr: [22, 20, 20],
    bt: [36.7, 36.7, 36.8],
    team: _teamDoc2,
    lastNote: ErNote('10:15', 'พย. วราภรณ์',
        'ให้ Aspirin แล้ว ยังแน่นอก 6/10 แจ้งแพทย์เวรแล้ว รอ Cath lab ตอบกลับ',
        kind: 'สังเกตอาการ'),
    nextStep: 'แพทย์ตรวจ · เปิด STEMI fast track',
    nextDetail: 'Door-to-balloon เป้าหมาย 90 นาที · เหลือ 68 นาที',
    advice: [
      'Consult Cardiologist ตาม template STEMI',
      'เตรียม Clopidogrel 300 mg รอคำสั่ง'
    ],
    events: [
      ErEvent('10:20', 'วัดสัญญาณชีพซ้ำ BP 138/88', kind: 'สังเกตอาการ'),
      ErEvent('10:02', 'ให้ Aspirin 300 mg เคี้ยว', kind: 'รับคำสั่งแพทย์'),
      ErEvent('10:00', 'รับเข้าเตียง A3 · ต่อ monitor ECG', kind: 'คัดกรอง'),
      ErEvent('09:58', 'ลงทะเบียนมาถึงห้องฉุกเฉิน · ส่งตัวโดย ALS',
          kind: 'คัดกรอง'),
    ],
  ),
  '670123462': ErCase(
    hn: '670123462',
    age: 66,
    sex: 'หญิง',
    bloodGroup: 'B',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'ส่งต่อจากสถานพยาบาลอื่นๆ',
    condition: 'เปลนอน',
    cc: 'ตื่นนอนตอนเช้าพบแขนขาซ้ายอ่อนแรง หยิบแก้วน้ำไม่ได้ พูดไม่ชัด หน้าซ้ายชา เห็นปกติครั้งสุดท้ายก่อนนอน 2 ชั่วโมงก่อนมา รพ.',
    onset: '08:20',
    hpi: 'รพ.ชุมชนส่งต่อ อาการเริ่ม 08:20 NIHSS 9 ไม่มีประวัติเลือดออกง่าย',
    gcs: 'E4 ลืมตาได้เอง V4 พูดคุยได้แต่สับสน M6 ทำตามคำสั่งได้',
    dx: [
      ErDx('Acute ischemic stroke (ซีกขวา)', ErLevel.critical, icd10: 'I63.9')
    ],
    underlying: ['หัวใจเต้นผิดจังหวะ AF', 'ความดันโลหิตสูง'],
    meds: [ErMed('0.9% NSS 1,000 mL', 'IV drip', '09:50')],
    labs: [
      ErLab('Blood sugar', 142, 70, 140),
      ErLab('INR', 1.1, 0.8, 1.2),
      ErLab('Plt', 265, 150, 400)
    ],
    imaging: [ErImage('CT brain', 'ออกผลแล้ว รอแพทย์อ่าน', _ctBrain)],
    times: ['09:48', '10:03', '10:18'],
    hr: [88, 92, 90],
    sbp: [168, 172, 165],
    dbp: [94, 96, 92],
    spo2: [97, 97, 98],
    rr: [18, 18, 18],
    bt: [36.6, 36.7, 36.7],
    team: _teamDoc1,
    lastNote: ErNote('10:05', 'พย. ณัฐพร',
        'CT brain เสร็จ 09:47 ผลอยู่ใน PACS แล้ว รอแพทย์อ่านเพื่อตัดสิน rt-PA',
        kind: 'รับคำสั่งแพทย์'),
    nextStep: 'แพทย์อ่านผล CT brain',
    nextDetail: 'ยังอยู่ใน window 4.5 ชม. · เหลือ 1 ชม. 50 น.',
    advice: [
      'ห้ามให้อาหารทางปากจนกว่าประเมินการกลืน',
      'เตรียม rt-PA ถ้า CT ไม่มีเลือดออก'
    ],
    events: [
      ErEvent('10:18', 'วัดสัญญาณชีพซ้ำ BP 165/92', kind: 'สังเกตอาการ'),
      ErEvent('09:47', 'CT brain เสร็จ · รอแพทย์อ่านผล',
          kind: 'รับคำสั่งแพทย์'),
      ErEvent('09:46', 'รับเข้าเตียง A4 · Stroke fast track', kind: 'คัดกรอง'),
    ],
  ),
  '670123463': ErCase(
    hn: '670123463',
    age: 39,
    sex: 'หญิง',
    bloodGroup: 'O',
    right: 'ประกันสังคม',
    arrival: 'มาเอง',
    condition: 'รถนั่ง',
    cc: 'ปัสสาวะแสบขัด ปวดหลังด้านขวา 3 วัน ไข้สูงหนาวสั่นเป็นพัก ๆ วันนี้ลุกจากเตียงแล้วหน้ามืด เกือบล้ม ใจสั่น 1 ชั่วโมงก่อนมา รพ.',
    onset: '09:35',
    hpi: 'ไข้ 39 หนาวสั่น ปวดเอวขวา คลื่นไส้ กินยาพาราเองไม่ดีขึ้น',
    painScore: 5,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [
      ErDx('Sepsis from acute pyelonephritis', ErLevel.critical, icd10: 'A41.9')
    ],
    allergies: ['Sulfa'],
    meds: [ErMed('0.9% NSS 1,000 mL', 'IV bolus 30 mL/kg', '09:40')],
    labs: [
      ErLab('WBC', 18.2, 4.0, 11.0),
      ErLab('Lactate', 2.8, 0.5, 2.0),
      ErLab('Cr', 1.3, 0.6, 1.2)
    ],
    times: ['09:35', '09:50', '10:05', '10:20'],
    hr: [124, 120, 114, 108],
    sbp: [86, 90, 96, 102],
    dbp: [50, 54, 58, 62],
    spo2: [95, 96, 97, 97],
    rr: [26, 24, 22, 22],
    bt: [39.2, 39.0, 38.6, 38.4],
    team: _teamDoc2,
    lastNote: ErNote('10:08', 'พย. วราภรณ์',
        'ความดันขึ้นหลัง bolus 1,000 mL เจาะ Blood culture ×2 แล้ว รอแพทย์สั่งยาฆ่าเชื้อ',
        kind: 'รับคำสั่งแพทย์'),
    nextStep: 'แพทย์ตรวจ · เริ่มยาฆ่าเชื้อภายใน 1 ชม.',
    nextDetail: 'Sepsis bundle 1 hr · Blood culture เจาะแล้ว',
    advice: [
      'แพ้ Sulfa — เลี่ยง Co-trimoxazole',
      'ติดตาม urine output ทุก 1 ชม.'
    ],
    events: [
      ErEvent('10:20', 'วัดสัญญาณชีพซ้ำ BP 102/62', kind: 'สังเกตอาการ'),
      ErEvent('09:55', 'เจาะ Blood culture ×2 · Lactate 2.8',
          kind: 'รับคำสั่งแพทย์'),
      ErEvent('09:40', 'ให้ NSS 1,000 mL bolus', kind: 'รับคำสั่งแพทย์'),
      ErEvent('09:35', 'รับเข้าเตียง B1', kind: 'คัดกรอง'),
    ],
  ),
  '670123464': ErCase(
    hn: '670123464',
    age: 52,
    sex: 'ชาย',
    bloodGroup: 'A',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'มาเอง',
    condition: 'เดินมา',
    cc: 'ปวดท้องใต้ชายโครงขวาแบบบีบ ๆ หลังกินอาหารมัน ร้าวไปสะบักขวา คลื่นไส้อาเจียน 3 ครั้ง ไม่มีไข้ เป็น 6 ชั่วโมงก่อนมา รพ.',
    hpi: 'ปวดหลังกินอาหารมัน ปวดร้าวไปสะบักขวา เคยเป็น 2 ครั้ง ไม่มีไข้',
    painScore: 7,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [ErDx('สงสัย Acute cholecystitis', ErLevel.urgent, icd10: 'K81.0')],
    underlying: ['ไขมันในเลือดสูง'],
    times: ['09:30', '10:00'],
    hr: [96, 94],
    sbp: [142, 138],
    dbp: [88, 86],
    spo2: [98, 98],
    rr: [18, 18],
    bt: [37.4, 37.5],
    team: _teamTriage,
    nextStep: 'รอแพทย์ตรวจ',
    nextDetail: 'ลำดับที่ 3 ของคิว ESI 3',
    advice: ['งดน้ำงดอาหารไว้ก่อน เผื่อต้อง ultrasound'],
    events: [
      ErEvent('09:30', 'คัดกรองเสร็จ ESI 3 · นั่งรอตรวจ', kind: 'คัดกรอง')
    ],
  ),
  '670123465': ErCase(
    hn: '670123465',
    age: 48,
    sex: 'หญิง',
    bloodGroup: 'B',
    right: 'ประกันสังคม',
    arrival: 'มาเอง',
    condition: 'เดินมา',
    cc: 'เป็นหวัด ไอมา 3 วัน เมื่อวานเริ่มหอบเหนื่อย หายใจมีเสียงวี้ด พ่นยาขยายหลอดลมเองทุก 2 ชั่วโมงไม่ดีขึ้น พูดได้เป็นคำ ๆ 1 วันก่อนมา รพ.',
    hpi:
        'หอบหืดเดิม ขาดยาพ่นควบคุม 1 เดือน มีไอ น้ำมูก 3 วันก่อน พูดเป็นประโยคได้',
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [
      ErDx('Asthma exacerbation (moderate)', ErLevel.urgent, icd10: 'J45.901')
    ],
    allergies: ['NSAIDs'],
    underlying: ['หอบหืด'],
    meds: [ErMed('Salbutamol NB', 'พ่น · ครั้งที่ 1', '09:40')],
    times: ['09:20', '09:55'],
    hr: [108, 104],
    sbp: [132, 130],
    dbp: [82, 80],
    spo2: [92, 94],
    rr: [26, 24],
    bt: [37.0, 37.0],
    team: _teamTriage,
    nextStep: 'รอแพทย์ตรวจ · พ่นยาซ้ำ',
    nextDetail: 'พ่นครั้งที่ 2 เวลา 10:00',
    advice: ['แพ้ NSAIDs — ระวังยาแก้ปวด', 'วัด SpO₂ หลังพ่นทุกครั้ง'],
    events: [
      ErEvent('09:40', 'พ่น Salbutamol ครั้งที่ 1', kind: 'รับคำสั่งแพทย์'),
      ErEvent('09:20', 'คัดกรองเสร็จ ESI 3', kind: 'คัดกรอง'),
    ],
  ),
  '670123466': ErCase(
    hn: '670123466',
    age: 29,
    sex: 'ชาย',
    bloodGroup: 'O',
    right: 'จ่ายเอง',
    arrival: 'มาเอง',
    condition: 'เดินมา',
    cc: 'ถูกมีดทำครัวบาดฝ่ามือซ้ายขณะหั่นเนื้อ แผลยาวประมาณ 4 ซม. เลือดออกมาก กดห้ามเลือดแล้วยังซึม นิ้วนางชาเล็กน้อย 2 ชั่วโมงก่อนมา รพ.',
    hpi:
        'มีดหั่นผักบาดฝ่ามือซ้ายลึกประมาณ 1 ซม. ยาว 3 ซม. ขยับนิ้วได้ครบ ชาปลายนิ้วเล็กน้อย',
    painScore: 4,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [ErDx('แผลฉีกขาดฝ่ามือซ้าย', ErLevel.normal, icd10: 'S61.4')],
    times: ['08:35', '09:05'],
    hr: [80, 78],
    sbp: [126, 124],
    dbp: [80, 78],
    spo2: [99, 99],
    rr: [16, 16],
    bt: [36.6, 36.6],
    team: _teamTriage,
    nextStep: 'รอแพทย์ตรวจ · เย็บแผล',
    nextDetail: 'ห้องหัตถการ 2 · ถาม tetanus ล่าสุด',
    advice: ['ล้างแผล NSS ระหว่างรอ', 'ตรวจ tendon/nerve ก่อนเย็บ'],
    events: [
      ErEvent('09:05', 'คัดกรองเสร็จ ESI 4 · ล้างแผลเบื้องต้น', kind: 'คัดกรอง')
    ],
  ),
  '670123467': ErCase(
    hn: '670123467',
    age: 74,
    sex: 'หญิง',
    bloodGroup: 'A',
    right: 'ข้าราชการ',
    arrival: 'มาเอง',
    condition: 'รถนั่ง',
    cc: 'ตื่นนอนพลิกตัวแล้วเวียนศีรษะบ้านหมุน ลืมตาไม่ได้ คลื่นไส้อาเจียน 4 ครั้ง เดินเซ ไม่มีแขนขาอ่อนแรง หูไม่อื้อ 3 ชั่วโมงก่อนมา รพ.',
    hpi:
        'หมุนเวลาขยับศีรษะ ครั้งละ <1 นาที ไม่มีอ่อนแรง ไม่พูดไม่ชัด หูไม่อื้อ',
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [ErDx('สงสัย BPPV', ErLevel.normal, icd10: 'H81.1')],
    underlying: ['ความดันโลหิตสูง'],
    meds: [ErMed('Dimenhydrinate 50 mg', 'IM · ครั้งเดียว', '09:15')],
    times: ['08:48', '09:30'],
    hr: [84, 80],
    sbp: [158, 150],
    dbp: [88, 86],
    spo2: [97, 98],
    rr: [18, 18],
    bt: [36.6, 36.6],
    team: _teamTriage,
    nextStep: 'รอแพทย์ตรวจ',
    nextDetail: 'รอเกิน 90 นาที · แจ้งเวรแล้ว',
    advice: ['ตรวจ HINTS ถ้าอาการยังไม่ดีขึ้น', 'ระวังหกล้มขณะลุก'],
    events: [
      ErEvent('09:15', 'ให้ Dimenhydrinate 50 mg IM', kind: 'รับคำสั่งแพทย์'),
      ErEvent('08:48', 'คัดกรองเสร็จ ESI 4', kind: 'คัดกรอง'),
    ],
  ),
  '670123468': ErCase(
    hn: '670123468',
    age: 67,
    sex: 'ชาย',
    bloodGroup: 'B',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'ญาตินำส่ง',
    condition: 'เดินมา',
    cc: 'ลื่นล้มในห้องน้ำ เอามือขวายันพื้น ปวดบวมข้อมือขวาทันที ข้อมือผิดรูปคล้ายส้อม ขยับนิ้วได้แต่ปวด 1 ชั่วโมงก่อนมา รพ.',
    onset: '08:40',
    hpi:
        'ลื่นในห้องน้ำ ล้มเอามือขวายันพื้น ข้อมือผิดรูปเป็นรูปส้อม ชาปลายนิ้วเล็กน้อย ไม่ศีรษะกระแทก',
    painScore: 8,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    underlying: ['กระดูกพรุน'],
    dx: [
      ErDx('Distal radius fracture ขวา (Colles)', ErLevel.urgent,
          icd10: 'S52.5')
    ],
    times: ['09:11', '09:41'],
    hr: [104, 96],
    sbp: [152, 148],
    dbp: [88, 86],
    spo2: [98, 98],
    rr: [20, 18],
    bt: [36.7, 36.7],
    team: _teamTriage,
    nextStep: 'รอแพทย์ตรวจ',
    nextDetail: 'ESI 4 · ใส่ splint ชั่วคราว รอ X-ray wrist',
    advice: [
      'ตรวจชีพจร radial และการรับความรู้สึกปลายนิ้วซ้ำทุก 30 นาที',
      'ถอดแหวน/นาฬิกาข้างขวาก่อนบวมมากขึ้น'
    ],
    events: [
      ErEvent('09:52', 'ใส่ splint ชั่วคราว ยกสูง ประคบเย็น',
          kind: 'การพยาบาล'),
      ErEvent('09:41', 'คัดกรองเสร็จ ESI 4', kind: 'คัดกรอง'),
    ],
  ),

  // ------------------------------------------------------------ ตรวจแล้ว
  '670123469': ErCase(
    hn: '670123469',
    age: 54,
    sex: 'หญิง',
    bloodGroup: 'O',
    right: 'พ.ร.บ. รถ',
    arrival: 'ส่งตัวโดย BLS',
    condition: 'เปลนอน',
    cc: 'ขับรถจักรยานยนต์ชนรถเก๋งที่ทางแยก ไม่สวมหมวกนิรภัย ศีรษะกระแทกพื้น สลบไปชั่วครู่ ปวดต้นขาขวามาก ต้นขาผิดรูป ขยับขาไม่ได้ อาเจียน 2 ครั้ง 1 ชั่วโมงก่อนมา รพ.',
    onset: '09:05',
    hpi:
        'ซ้อนท้ายจักรยานยนต์ล้ม สวมหมวก ศีรษะกระแทกพื้น ไม่หมดสติ ปวดศีรษะ 7/10 อาเจียน 2 ครั้ง ปวดท้องขวาล่างร่วม',
    painScore: 7,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [
      ErDx('บาดเจ็บศีรษะจากอุบัติเหตุ', ErLevel.critical, icd10: 'S06.0'),
      ErDx('กระดูกต้นขาขวาหัก (closed fracture shaft of femur)',
          ErLevel.critical,
          icd10: 'S72.3'),
      ErDx('คลื่นไส้ อาเจียน', ErLevel.urgent),
      ErDx('ความดันโลหิตสูง', ErLevel.urgent),
      ErDx('ปวดท้องด้านขวาล่าง', ErLevel.normal),
    ],
    allergies: ['Penicillin', 'ถั่วลิสง', 'Sulfa'],
    underlying: [
      'ความดันโลหิตสูง',
      'เบาหวานชนิดที่ 2',
      'ไขมันในเลือดสูง',
      'ไตเรื้อรังระยะ 3a',
    ],
    meds: [
      ErMed('0.9% NSS 1,000 mL', 'IV drip', '10:18'),
      ErMed('Paracetamol 500 mg', 'รับประทาน · ทุก 6 ชม.', '10:05'),
      ErMed('Ondansetron 4 mg', 'IV · ครั้งเดียว', '09:58'),
      ErMed('Omeprazole 40 mg', 'IV · วันละครั้ง', '09:40'),
    ],
    labs: [
      ErLab('Hb', 10.2, 12.0, 16.0),
      ErLab('WBC', 14.8, 4.0, 11.0),
      ErLab('Plt', 220, 150, 400),
      ErLab('Na', 134, 135, 145),
      ErLab('K', 3.2, 3.5, 5.1),
      ErLab('Cr', 1.6, 0.6, 1.2),
      ErLab('Lactate', 3.4, 0.5, 2.0),
      ErLab.text('Blood group', 'O Rh+'),
      ErLab.text('UA · Blood', 'Positive 2+', flagged: true),
      ErLab.image('Peripheral blood smear', 'assets/images/lab/pbs_mock.png',
          text: 'Normocytic normochromic'),
    ],
    imaging: [
      ErImage('CT brain', 'รอผลอ่าน', _ctBrain),
      ErImage('CXR (PA)', 'ปกติ', _cxr),
      ErImage('CXR (Lat)', 'ปกติ', _cxrLat),
    ],
    times: ['09:22', '09:37', '09:52', '10:07', '10:22'],
    hr: [96, 104, 112, 121, 128],
    sbp: [112, 104, 98, 92, 88],
    dbp: [70, 66, 62, 58, 56],
    spo2: [97, 93, 89, 90, 93],
    rr: [18, 22, 26, 27, 26],
    bt: [36.6, 36.7, 36.7, 36.8, 36.8],
    team: _teamDoc1,
    lastNote: ErNote('10:20', 'พย. วราภรณ์',
        'ผู้ป่วยรู้สึกตัวดี ปวดศีรษะ 7/10 คลื่นไส้ลดลง ความดันยังต่ำหลังให้สารน้ำ 1,000 mL',
        kind: 'สังเกตอาการ'),
    nextStep: 'ส่ง CT brain',
    nextDetail: 'นัดเวลา 10:40 น. · ห้องรังสี ชั้น 1',
    advice: [
      'ติดตามสัญญาณชีพทุก 15 นาที ขณะรอผล CT',
      'เตรียมจองเตียง ICU เผื่อความดันไม่ขึ้น',
      'แจ้งญาติเรื่องแผนการรักษาและผลตรวจ',
    ],
    events: [
      ErEvent('10:22', 'สั่ง CT brain ด่วน', byDoctor: true),
      ErEvent('10:18', 'ให้ NSS 1,000 mL เปิดเส้นแล้ว', kind: 'รับคำสั่งแพทย์'),
      ErEvent('10:07', 'วัดสัญญาณชีพซ้ำ BP 88/56', kind: 'สังเกตอาการ'),
      ErEvent('09:52', 'ประเมินความเจ็บปวด 7/10', kind: 'สังเกตอาการ'),
      ErEvent('09:22', 'รับเข้าเตียง เริ่มติดตามสัญญาณชีพ', kind: 'คัดกรอง'),
    ],
  ),
  '670123470': ErCase(
    hn: '670123470',
    age: 68,
    sex: 'หญิง',
    bloodGroup: 'A',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'ส่งต่อจากสถานพยาบาลอื่นๆ',
    condition: 'เปลนอน',
    cc: 'ไข้สูง ไอมีเสมหะเหลืองข้น เจ็บหน้าอกขวาเวลาหายใจลึก 3 วัน วันนี้หอบเหนื่อยมากขึ้น เดินไปห้องน้ำแล้วต้องหยุดพัก ก่อนมา รพ.',
    hpi:
        'ไข้ 39.5 ไอเสมหะเขียว หอบมากขึ้น รพ.ชุมชนให้ Ceftriaxone 1 dose แล้วส่งต่อ',
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [
      ErDx('Sepsis from pneumonia RLL', ErLevel.critical, icd10: 'A41.9'),
      ErDx('COPD', ErLevel.urgent),
    ],
    underlying: ['COPD', 'เบาหวานชนิดที่ 2'],
    meds: [
      ErMed('Piperacillin/Tazobactam 4.5 g', 'IV · ทุก 8 ชม.', '09:20'),
      ErMed('0.9% NSS 1,500 mL', 'IV bolus', '08:50'),
      ErMed('O2 nasal cannula', '3 L/min', '08:45'),
    ],
    labs: [
      ErLab('WBC', 21.4, 4.0, 11.0),
      ErLab('Lactate', 4.1, 0.5, 2.0),
      ErLab('Cr', 1.9, 0.6, 1.2),
      ErLab('Blood sugar', 268, 70, 140),
    ],
    imaging: [ErImage('CXR (PA)', 'Infiltration RLL', _cxr)],
    times: ['08:45', '09:15', '09:45', '10:15'],
    hr: [128, 122, 116, 112],
    sbp: [84, 92, 98, 104],
    dbp: [48, 54, 58, 62],
    spo2: [88, 92, 94, 95],
    rr: [30, 28, 26, 24],
    bt: [39.5, 39.2, 38.8, 38.5],
    team: _teamDoc2,
    lastNote: ErNote('10:12', 'พย. ณัฐพร',
        'ความดันขึ้นหลังสารน้ำ ยังไข้ 38.5 ปัสสาวะ 40 mL/ชม. รอผลเพาะเชื้อ',
        kind: 'สังเกตอาการ'),
    nextStep: 'รอเตียง ICU อายุรกรรม',
    nextDetail: 'จองเตียงแล้ว 09:50 · รอย้าย',
    advice: [
      'Lactate ซ้ำ 2 ชม. (11:00)',
      'คุมน้ำตาล 140–180 ด้วย insulin sliding scale'
    ],
    events: [
      ErEvent('10:15', 'วัดสัญญาณชีพซ้ำ BP 104/62', kind: 'สังเกตอาการ'),
      ErEvent('09:50', 'จองเตียง ICU อายุรกรรม', byDoctor: true),
      ErEvent('09:20', 'เริ่ม Pip/Tazo 4.5 g IV', byDoctor: true),
      ErEvent('08:50', 'NSS 1,500 mL bolus · Blood culture ×2',
          kind: 'รับคำสั่งแพทย์'),
      ErEvent('08:45', 'รับเข้าเตียง A2 จาก รพ.ชุมชน', kind: 'คัดกรอง'),
    ],
  ),
  '670123471': ErCase(
    hn: '670123471',
    age: 77,
    sex: 'ชาย',
    bloodGroup: 'B',
    right: 'ข้าราชการ',
    arrival: 'มาเอง',
    condition: 'รถนั่ง',
    cc: 'เหนื่อยง่ายขึ้นเรื่อย ๆ 1 สัปดาห์ ต้องนอนหนุนหมอน 3 ใบ ตื่นกลางคืนเพราะหอบ ขาบวม 2 ข้าง น้ำหนักขึ้น 3 กก. ขาดยาขับปัสสาวะ 2 สัปดาห์ก่อนมา รพ.',
    hpi: 'เหนื่อยเวลาเดิน ต้องหนุนหมอน 3 ใบ ตื่นมาหอบกลางคืน น้ำหนักขึ้น 3 กก.',
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [
      ErDx('Acute decompensated heart failure', ErLevel.urgent, icd10: 'I50.9'),
      ErDx('โรคไตเรื้อรังระยะ 3', ErLevel.normal),
    ],
    allergies: ['Penicillin'],
    underlying: ['หัวใจล้มเหลว EF 35%', 'ไตเรื้อรัง', 'ความดันโลหิตสูง'],
    meds: [
      ErMed('Furosemide 40 mg', 'IV · ครั้งเดียว', '08:30'),
      ErMed('O2 nasal cannula', '2 L/min', '08:20'),
    ],
    labs: [
      ErLab('NT-proBNP', 4200, 0, 300),
      ErLab('Cr', 1.8, 0.6, 1.2),
      ErLab('K', 4.8, 3.5, 5.1)
    ],
    imaging: [ErImage('CXR (PA)', 'Cardiomegaly, pulmonary congestion', _cxr)],
    times: ['08:20', '08:50', '09:20', '09:50', '10:20'],
    hr: [104, 100, 96, 92, 90],
    sbp: [162, 158, 150, 146, 142],
    dbp: [96, 94, 90, 88, 86],
    spo2: [91, 93, 95, 96, 96],
    rr: [26, 24, 22, 20, 20],
    bt: [36.6, 36.6, 36.7, 36.7, 36.7],
    team: _teamDoc1,
    lastNote: ErNote('10:10', 'พย. วราภรณ์',
        'ปัสสาวะออก 600 mL หลัง Furosemide เหนื่อยลดลง นอนหัวสูงได้',
        kind: 'สังเกตอาการ'),
    nextStep: 'รอเตียงวอร์ดอายุรกรรม',
    nextDetail: 'Admit สั่งแล้ว 09:05 · วอร์ดแจ้งเตียงว่าง 11:00',
    advice: ['บันทึก I/O ทุก 1 ชม.', 'จำกัดน้ำ 1,000 mL/วัน'],
    events: [
      ErEvent('10:20', 'วัดสัญญาณชีพซ้ำ BP 142/86', kind: 'สังเกตอาการ'),
      ErEvent('09:05', 'สั่ง Admit อายุรกรรม', byDoctor: true),
      ErEvent('08:30', 'ให้ Furosemide 40 mg IV', byDoctor: true),
      ErEvent('08:20', 'รับเข้าเตียง A5', kind: 'คัดกรอง'),
    ],
    disposition: 'Admit',
  ),
  '670123472': ErCase(
    hn: '670123472',
    age: 8,
    sex: 'หญิง',
    bloodGroup: 'O',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'มาเอง',
    condition: 'อุ้มมา',
    cc: 'ไข้ ไอมีน้ำมูก 2 วัน เมื่อคืนเริ่มหอบ หายใจมีเสียงวี้ด ซี่โครงบุ๋ม กินนมได้น้อยลง มารดาพ่นยาให้ 1 ครั้งไม่ดีขึ้น 1 วันก่อนมา รพ.',
    hpi:
        'เด็กหญิง 8 ปี หอบหืดเดิม ไข้ ไอ หอบมากขึ้นตั้งแต่เที่ยงคืน พ่นยาที่บ้าน 2 ครั้งไม่ดีขึ้น',
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [ErDx('Asthma exacerbation (เด็ก)', ErLevel.urgent, icd10: 'J45.901')],
    underlying: ['หอบหืด'],
    meds: [
      ErMed('Salbutamol NB', 'พ่น · ครั้งที่ 2', '09:50'),
      ErMed('Prednisolone 20 mg', 'รับประทาน', '09:25'),
    ],
    times: ['09:18', '09:48', '10:18'],
    hr: [132, 124, 116],
    sbp: [104, 102, 100],
    dbp: [64, 62, 62],
    spo2: [91, 94, 96],
    rr: [36, 30, 26],
    bt: [38.2, 38.0, 37.6],
    team: _teamDoc2,
    lastNote: ErNote('10:15', 'พย. ณัฐพร',
        'หลังพ่นครั้งที่ 2 เสียงวี้ดลดลง SpO₂ 96% ห้องอากาศ กินน้ำได้',
        kind: 'สังเกตอาการ'),
    nurseNotes: [
      ErNote('10:20', 'พย. ณัฐพร',
          'ประเมินซ้ำ 30 นาทีหลังพ่น: หายใจ 26/นาที ไม่มี retraction เสียงวี้ดเล็กน้อยปลายลมหายใจออก SpO₂ 96% ห้องอากาศ เด็กนั่งเล่นได้',
          kind: 'สังเกตอาการ'),
      ErNote('10:15', 'พย. ณัฐพร',
          'หลังพ่นครั้งที่ 2 เสียงวี้ดลดลง SpO₂ 96% ห้องอากาศ กินน้ำได้ 120 ml ไม่อาเจียน',
          kind: 'สังเกตอาการ'),
      ErNote('09:55', 'พย. ณัฐพร',
          'หยุด O2 cannula ทดลองห้องอากาศ SpO₂ คงที่ 94-95% ติดตามทุก 15 นาที',
          kind: 'การพยาบาล'),
      ErNote('09:50', 'พย. อรทัย',
          'พ่น Salbutamol ครั้งที่ 2 ตามแผนการรักษา ขณะพ่นเด็กร่วมมือดี มารดาอยู่ด้วย',
          kind: 'รับคำสั่งแพทย์'),
      ErNote('09:30', 'พย. อรทัย',
          'ให้ Prednisolone 20 mg รับประทานได้หมด เช็ดตัวลดไข้ BT 38.0 °C',
          kind: 'รับคำสั่งแพทย์'),
      ErNote('09:20', 'พย. อรทัย',
          'รับไว้สังเกตอาการเตียง B2 หอบ ใช้กล้ามเนื้อช่วยหายใจ SpO₂ 91% ให้ O2 cannula 2 L/min ประเมิน PRAM 7',
          kind: 'คัดกรอง'),
    ],
    nextStep: 'ประเมินซ้ำหลังพ่น 1 ชม.',
    nextDetail: 'ถ้า SpO₂ ≥ 95% ต่อเนื่อง กลับบ้านพร้อมยาพ่น',
    advice: ['สอนผู้ปกครองใช้ spacer ก่อนกลับ', 'นัด OPD กุมารฯ 1 สัปดาห์'],
    events: [
      ErEvent('09:50', 'พ่น Salbutamol ครั้งที่ 2', kind: 'รับคำสั่งแพทย์'),
      ErEvent('09:25', 'ให้ Prednisolone 20 mg', byDoctor: true),
      ErEvent('09:18', 'รับเข้าเตียง B2 · ต่อ O2', kind: 'คัดกรอง'),
    ],
  ),

  // ------------------------------------------------------------ รอออก
  '670123473': ErCase(
    hn: '670123473',
    age: 41,
    sex: 'หญิง',
    bloodGroup: 'A',
    right: 'ประกันสังคม',
    arrival: 'มาเอง',
    condition: 'เดินมา',
    cc: 'ปวดศีรษะขมับซ้ายแบบตุบ ๆ ค่อย ๆ ปวดมากขึ้น เห็นแสงวูบวาบก่อนปวด คลื่นไส้ กลัวแสงกลัวเสียง กินยาพาราเซตามอลไม่ดีขึ้น 6 ชั่วโมงก่อนมา รพ.',
    hpi:
        'ปวดตุบ ๆ ข้างซ้าย 8/10 แพ้แสง คลื่นไส้ เหมือนไมเกรนที่เคยเป็น ไม่มีอาการอ่อนแรง',
    painScore: 2,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [ErDx('Migraine without aura', ErLevel.normal, icd10: 'G43.0')],
    underlying: ['ไมเกรน'],
    meds: [
      ErMed('Metoclopramide 10 mg', 'IV · ครั้งเดียว', '09:15'),
      ErMed('Ketorolac 30 mg', 'IV · ครั้งเดียว', '09:15'),
    ],
    times: ['09:00', '09:45', '10:15'],
    hr: [88, 80, 76],
    sbp: [136, 128, 124],
    dbp: [84, 80, 78],
    spo2: [98, 99, 99],
    rr: [18, 16, 16],
    bt: [36.7, 36.7, 36.6],
    team: _teamDoc1,
    lastNote: ErNote('10:05', 'พย. วราภรณ์',
        'ปวดลดลงเหลือ 2/10 เดินได้ ไม่คลื่นไส้ รอใบสั่งยากลับบ้าน',
        kind: 'ออกจาก ER'),
    nextStep: 'กลับบ้าน · รอใบสั่งยา',
    nextDetail: 'ห้องยาแจ้งคิว 12 นาที',
    advice: [
      'ให้ใบนัด OPD อายุรกรรมประสาท 2 สัปดาห์',
      'แนะนำจดบันทึกปัจจัยกระตุ้น'
    ],
    events: [
      ErEvent('10:00', 'สั่งจำหน่ายกลับบ้าน · ยา 3 รายการ', byDoctor: true),
      ErEvent('09:15', 'ให้ Metoclopramide + Ketorolac IV', byDoctor: true),
      ErEvent('09:00', 'รับเข้าเตียง B3', kind: 'คัดกรอง'),
    ],
    disposition: 'กลับบ้าน',
  ),
  '670123474': ErCase(
    hn: '670123474',
    age: 19,
    sex: 'ชาย',
    bloodGroup: 'O',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'มาเอง',
    condition: 'รถนั่ง',
    cc: 'เล่นฟุตบอลแล้วกระโดดลงพื้นผิดท่า ข้อเท้าซ้ายพลิกเข้าด้านใน ได้ยินเสียงดัง ปวดบวมด้านนอกข้อเท้า เดินลงน้ำหนักไม่ได้ ประคบเย็นแล้ว 2 ชั่วโมงก่อนมา รพ.',
    hpi: 'พลิกเข้าใน 2 ชม.ก่อน บวมรอบตาตุ่มนอก กดเจ็บ ลงน้ำหนักไม่ได้ ไม่มีแผล',
    painScore: 3,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [ErDx('Ankle sprain grade 2', ErLevel.normal, icd10: 'S93.4')],
    imaging: [ErImage('X-ray ankle', 'ไม่พบกระดูกหัก', _cxrLat)],
    times: ['09:30', '10:00'],
    hr: [82, 76],
    sbp: [122, 120],
    dbp: [76, 74],
    spo2: [99, 99],
    rr: [16, 16],
    bt: [36.5, 36.5],
    team: _teamDoc2,
    lastNote: ErNote('09:58', 'พย. ณัฐพร',
        'ใส่ elastic bandage แล้ว สอนเดินไม้ค้ำยัน รอญาติมารับ',
        kind: 'การพยาบาล'),
    nextStep: 'กลับบ้าน · รอญาติมารับ',
    nextDetail: 'ญาติแจ้งถึง 10:30',
    advice: ['RICE 48 ชม.', 'นัดออร์โธปิดิกส์ 1 สัปดาห์ถ้ายังลงน้ำหนักไม่ได้'],
    events: [
      ErEvent('09:55', 'สั่งจำหน่าย · ยาแก้ปวด + elastic bandage',
          byDoctor: true),
      ErEvent('09:45', 'X-ray ankle ไม่พบกระดูกหัก', kind: 'รับคำสั่งแพทย์'),
      ErEvent('09:30', 'รับเข้าเตียง B4', kind: 'คัดกรอง'),
    ],
    disposition: 'กลับบ้าน',
  ),
  '670123475': ErCase(
    hn: '670123475',
    age: 60,
    sex: 'หญิง',
    bloodGroup: 'AB',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'มาเอง',
    condition: 'เปลนอน',
    cc: 'ถ่ายอุจจาระดำเหลวเหนียวเหมือนยางมะตอย วันละ 2–3 ครั้งมา 2 วัน กินยาแก้ปวดข้อเป็นประจำ วันนี้ลุกยืนแล้วหน้ามืด ใจสั่น เหงื่อออก 1 ชั่วโมงก่อนมา รพ.',
    hpi:
        'ถ่ายดำเหลว 4 ครั้ง อาเจียนเป็นเลือด 1 ครั้ง กิน NSAIDs ปวดเข่าประจำ ไม่มีโรคตับ',
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [ErDx('Upper GI bleeding', ErLevel.critical, icd10: 'K92.2')],
    underlying: ['ข้อเข่าเสื่อม'],
    meds: [
      ErMed('Omeprazole 80 mg', 'IV bolus', '08:40'),
      ErMed('PRC 1 unit', 'IV · กำลังให้', '09:30'),
      ErMed('0.9% NSS 1,000 mL', 'IV drip', '08:30'),
    ],
    labs: [
      ErLab('Hb', 7.8, 12.0, 16.0),
      ErLab('BUN', 42, 7, 20),
      ErLab('Plt', 198, 150, 400)
    ],
    times: ['08:30', '09:00', '09:30', '10:00'],
    hr: [118, 112, 104, 98],
    sbp: [88, 94, 100, 106],
    dbp: [52, 56, 60, 64],
    spo2: [96, 97, 97, 98],
    rr: [22, 20, 20, 18],
    bt: [36.4, 36.5, 36.5, 36.6],
    team: _teamDoc1,
    lastNote: ErNote('10:00', 'พย. วราภรณ์',
        'PRC unit แรกใกล้หมด ความดัน 106/64 ไม่ถ่ายดำเพิ่ม รพ.ปลายทางรับแล้ว รอรถ',
        kind: 'ออกจาก ER'),
    nextStep: 'Refer · ส่องกล้อง รพ.ศูนย์',
    nextDetail: 'รถส่งต่อถึงประมาณ 10:45 · ใบ Refer พร้อม',
    advice: ['ให้ PRC ครบก่อนออกเดินทาง', 'แนบผลแล็บและ ECG ไปกับใบส่งตัว'],
    events: [
      ErEvent('09:35', 'รพ.ศูนย์รับ Refer · ประสานรถส่งต่อ', kind: 'ออกจาก ER'),
      ErEvent('09:30', 'เริ่มให้ PRC unit 1', kind: 'รับคำสั่งแพทย์'),
      ErEvent('09:10', 'สั่ง Refer ส่องกล้อง', byDoctor: true),
      ErEvent('08:40', 'Omeprazole 80 mg IV bolus', byDoctor: true),
      ErEvent('08:30', 'รับเข้าเตียง B5', kind: 'คัดกรอง'),
    ],
    disposition: 'Refer ทางกาย',
  ),
  // เคสไม่มีตำแหน่งบนหุ่น (knowledge #41): การ์ดแสดงค่าหลักแทนหุ่น
  '670123476': ErCase(
    hn: '670123476',
    age: 58,
    sex: 'ชาย',
    bloodGroup: 'B',
    right: 'ประกันสุขภาพถ้วนหน้า',
    arrival: 'ญาตินำส่ง',
    condition: 'รถนั่ง',
    cc: 'เบาหวาน ขาดยาฉีดอินซูลิน 3 วัน กระหายน้ำ ปัสสาวะบ่อย อ่อนเพลียมาก คลื่นไส้อาเจียน หายใจหอบลึก วัดน้ำตาลที่บ้านเครื่องอ่านค่าไม่ได้ ญาติว่าซึมลง 1 วันก่อนมา รพ.',
    hpi:
        'เบาหวานชนิดที่ 2 ฉีดอินซูลินเอง ขาดยา 3 วัน กินได้น้อย ปัสสาวะบ่อย กระหายน้ำ ซึมลงเช้านี้',
    painScore: 0,
    gcs: 'E3 ลืมตาเมื่อถูกเรียก V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [
      ErDx('Diabetic ketoacidosis', ErLevel.critical, icd10: 'E11.1'),
    ],
    underlying: ['เบาหวานชนิดที่ 2', 'ความดันโลหิตสูง'],
    meds: [
      ErMed('0.9% NSS 1,000 mL', 'IV load 1 ชม.', '10:20'),
      ErMed('RI 0.1 unit/kg/hr', 'IV drip', '10:40'),
    ],
    labs: [
      ErLab('Glucose', 486, 70, 140),
      ErLab('HCO₃', 12, 22, 29),
      ErLab('K', 5.6, 3.5, 5.1),
      ErLab('Cr', 1.4, 0.7, 1.2),
      ErLab.text('Ketone', 'Positive 3+', flagged: true),
    ],
    times: ['10:15', '10:45', '11:15'],
    hr: [112, 108, 102],
    sbp: [104, 108, 112],
    dbp: [62, 64, 68],
    spo2: [97, 97, 98],
    rr: [26, 24, 22],
    bt: [36.9, 37.0, 36.9],
    team: _teamDoc1,
    lastNote: ErNote('11:15', 'พย. วราภรณ์',
        'ให้ NSS ครบ 1 ลิตร เริ่ม RI drip เจาะ DTX ทุก 1 ชม. ครั้งล่าสุด 412',
        kind: 'รับคำสั่งแพทย์'),
    nextStep: 'เจาะ DTX ซ้ำทุก 1 ชม.',
    nextDetail: 'ครั้งต่อไป 12:15 · ติดตาม K ก่อนปรับอินซูลิน',
    advice: ['ติดตาม K ทุก 2 ชม.', 'เตรียม Admit อายุรกรรม'],
    events: [
      ErEvent('10:40', 'เริ่ม RI drip', byDoctor: true),
      ErEvent('10:30', 'ผล Glucose 486 · HCO₃ 12', kind: 'รับคำสั่งแพทย์'),
      ErEvent('10:15', 'รับเข้าห้องฉุกเฉิน', kind: 'คัดกรอง'),
    ],
    disposition: 'Admit',
  ),
  '670123477': ErCase(
    hn: '670123477',
    age: 64,
    sex: 'หญิง',
    bloodGroup: 'O',
    right: 'ข้าราชการ',
    arrival: 'มาเอง',
    condition: 'เดินได้',
    cc: 'ปวดศีรษะท้ายทอย มึนงง ตาพร่ามัวเล็กน้อย วัดความดันที่บ้านได้ 210/120 ซ้ำ 2 ครั้ง ขาดยาความดัน 1 สัปดาห์ ไม่มีแขนขาอ่อนแรง ไม่เจ็บหน้าอก 2 ชั่วโมงก่อนมา รพ.',
    hpi:
        'ความดันโลหิตสูง 10 ปี ยาหมด 1 สัปดาห์ ไม่มีแขนขาอ่อนแรง ไม่เจ็บหน้าอก ไม่เหนื่อยหอบ',
    painScore: 2,
    gcs: 'E4 ลืมตาได้เอง V5 พูดคุยได้แต่ไม่สับสน M6 ทำตามคำสั่งได้',
    dx: [
      ErDx('Hypertensive urgency', ErLevel.urgent, icd10: 'I10'),
    ],
    underlying: ['ความดันโลหิตสูง', 'ไขมันในเลือดสูง'],
    meds: [ErMed('Amlodipine 10 mg', 'รับประทาน', '10:50')],
    labs: [
      ErLab('Cr', 1.0, 0.6, 1.1),
      ErLab('K', 3.9, 3.5, 5.1),
    ],
    times: ['10:30', '11:00', '11:30'],
    hr: [96, 92, 88],
    sbp: [212, 196, 178],
    dbp: [122, 114, 104],
    spo2: [98, 98, 98],
    rr: [18, 18, 16],
    bt: [36.6, 36.6, 36.5],
    team: _teamDoc2,
    lastNote: ErNote('11:30', 'พย. ณัฐพร',
        'ความดันลดลงเป็น 178/104 ไม่มีอาการทางระบบประสาท นอนพักรอวัดซ้ำ',
        kind: 'สังเกตอาการ'),
    nextStep: 'วัดความดันซ้ำทุก 30 นาที',
    nextDetail: 'เป้าหมายลดไม่เกิน 25% ใน 1 ชม.แรก',
    advice: ['ให้ยาเดิมต่อ', 'นัดคลินิกความดัน 1 สัปดาห์'],
    events: [
      ErEvent('10:50', 'Amlodipine 10 mg รับประทาน', byDoctor: true),
      ErEvent('10:30', 'รับเข้าห้องฉุกเฉิน', kind: 'คัดกรอง'),
    ],
    disposition: 'กลับบ้าน',
  ),
};

/// รอบสัญญาณชีพที่บันทึกเพิ่มระหว่างใช้งาน (ต่อ HN) · ยังไม่ส่งเข้า HOSxP
/// (เวลา, HR, SBP, DBP, SpO₂, RR, BT)
final Map<String,
        List<(String, double, double, double, double, double, double)>>
    erVsAdded = {};

/// บันทึกสัญญาณชีพรอบใหม่ของ HN (ต่อท้าย series ของเคส)
void erVsAdd(String hn, String time, double hr, double sbp, double dbp,
        double spo2, double rr, double bt) =>
    erVsAdded.putIfAbsent(hn, () => []).add((time, hr, sbp, dbp, spo2, rr, bt));

/// เคสของ HN นี้ ถ้าไม่มีให้เคสตั้งต้น (กันหน้าพัง) · รวมรอบ V/S ที่บันทึกเพิ่ม
ErCase erCaseOf(String hn) {
  final c = erCases[hn] ?? erCases.values.first;
  final add = erVsAdded[c.hn];
  if (add == null || add.isEmpty) return c;
  return ErCase(
    hn: c.hn,
    age: c.age,
    sex: c.sex,
    bloodGroup: c.bloodGroup,
    right: c.right,
    arrival: c.arrival,
    condition: c.condition,
    cc: c.cc,
    onset: c.onset,
    hpi: c.hpi,
    painScore: c.painScore,
    gcs: c.gcs,
    consciousness: c.consciousness,
    dx: c.dx,
    allergies: c.allergies,
    underlying: c.underlying,
    meds: c.meds,
    labs: c.labs,
    imaging: c.imaging,
    times: [...c.times, for (final r in add) r.$1],
    hr: [...c.hr, for (final r in add) r.$2],
    sbp: [...c.sbp, for (final r in add) r.$3],
    dbp: [...c.dbp, for (final r in add) r.$4],
    spo2: [...c.spo2, for (final r in add) r.$5],
    rr: [...c.rr, for (final r in add) r.$6],
    bt: [...c.bt, for (final r in add) r.$7],
    team: c.team,
    lastNote: c.lastNote,
    nurseNotes: c.nurseNotes,
    nextStep: c.nextStep,
    nextDetail: c.nextDetail,
    advice: c.advice,
    events: c.events,
    disposition: c.disposition,
  );
}
