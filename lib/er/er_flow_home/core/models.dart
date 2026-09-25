part of '../er_flow_home_widget.dart';

/// ระดับความเร่งด่วน ใช้ชุดสีเดียวกับวิดเจ็ต ESI ที่มีอยู่ในโค้ดเบส
enum _Esi {
  one(1, 'กู้ชีพ', Color(0xFFBE1E2D), _g1),
  two(2, 'ฉุกเฉิน', Color(0xFFAF1EBE), _g2),
  three(3, 'เร่งด่วน', Color(0xFFDC8610), _g3),
  four(4, 'กึ่งเร่งด่วน', Color(0xFF006838), _g4),
  five(5, 'ไม่เร่งด่วน', Color(0xFF465054), _g5);

  const _Esi(this.level, this.label, this.hue, this.grey);

  final int level;
  final String label;

  /// สีจริงของระดับ ใช้เมื่อเลิกโหมดยังไม่ลงสี
  final Color hue;

  /// ระดับเทาแทนสีจริง ยังไล่เข้มอ่อนตามความเร่งด่วนอยู่
  final Color grey;

  Color get color => _mono ? grey : hue;
}

/// ตัวกรองรายชื่อผู้ป่วยในแผงซ้ายตอนเลือกช่วงงาน
/// วิธีเรียงการ์ดในแถบล่างของหน้าภาพรวม
enum _FootSort {
  esi('ความเร่งด่วน'),
  wait('เวลารอ'),
  bed('รหัสเตียง');

  const _FootSort(this.label);
  final String label;
}

enum _ListFilter {
  all('ทั้งหมด'),
  onBed('บนเตียง'),
  noBed('ยังไม่ได้เตียง'),
  over('เกินเกณฑ์');

  const _ListFilter(this.label);

  final String label;
}

/// ชนิดผู้ป่วยตามทางด่วนเฉพาะโรค (fast track)
/// ใช้สีเฉพาะตัวเพราะแต่ละทางด่วนมีทีมและนาฬิกาจับเวลาของตัวเอง
enum _Ptype {
  stroke('Stroke', _blue),
  trauma('Trauma', Color(0xFFC62828)),
  stemi('STEMI', Color(0xFFAD1457)),
  sepsis('Sepsis', Color(0xFFEF6C00));

  const _Ptype(this.label, this.color);

  final String label;
  final Color color;
}

/// ระดับความสำคัญของการแจ้งเตือน กำหนดสีจุดท้ายการ์ด
enum _Level {
  // 60-30-10: แดง = ต้องทำทันที · น้ำเงิน = รอง · เทา = ทั่วไป
  critical('วิกฤต', _redHue, _g1),
  urgent('เร่งด่วน', _blueHue, _g2),
  watch('เฝ้าระวัง', _blue3, _g4),
  normal('ปกติ', _g5, _g5);

  const _Level(this.label, this.hue, this.grey);

  final String label;
  final Color hue;
  final Color grey;

  Color get color => _mono ? grey : hue;
}

/// การแจ้งเตือนหนึ่งรายการ — เหตุการณ์ที่เพิ่งเกิด ไม่ใช่สถานะสะสม
class _Alert {
  const _Alert(this.time, this.title, this.detail, this.level,
      {this.id, this.hn});

  final String time;
  final String title;
  final String detail;
  final _Level level;

  /// รหัสเฉพาะ (การเตือนที่ตั้งเองอาจเวลาเดียวกัน) ไม่มี = ใช้เวลา
  final String? id;

  /// ผู้ป่วยที่เกี่ยวข้อง แตะแล้วไปหน้าผู้ป่วย (การเตือนคำสั่ง/หัตถการ)
  final String? hn;

  String get key => id ?? time;
}

/// ข้อมูลจำลอง รอต่อกับคิวเหตุการณ์จริงของ HOSxP
const List<_Alert> _alerts = [
  _Alert('10:22', 'ESI 1 ยังไม่ได้พบแพทย์เกิน 5 นาที',
      'นายกิตติพงษ์ รัตน์ · เตียง A3 · รอตรวจ', _Level.critical),
  _Alert('10:19', 'ผู้ป่วยรอตรวจเกินเกณฑ์ 7 ราย', 'ขั้นรอตรวจเป็นคอขวดของกะนี้',
      _Level.critical),
  _Alert('10:18', 'เตียงสังเกตอาการเหลือ 2 จาก 10',
      'รอเตียง 5 ราย · คาดเต็มใน 20 นาที', _Level.urgent),
  _Alert('10:12', 'ผู้ป่วยค้างขั้นตรวจแล้วเกิน 2 ชม.',
      'นายปรีชา ดำรงค์ · เตียง A5 · รอเตียงวอร์ด', _Level.urgent),
  _Alert('10:08', 'คิวคัดกรองเกิน 10 นาที 2 ราย',
      'นายสมชาย แสงชัย · นางอารยา ธนกิจ', _Level.urgent),
  _Alert('10:05', 'ผลแล็บค้างเกิน 60 นาที',
      'นางอรสา ลิ้มเจริญ · เตียง A2 · รอผลเพาะเชื้อ', _Level.watch),
  _Alert('09:58', 'รอรถส่งต่อเกิน 45 นาที',
      'นางวารุณี เพ็ญศรี · เตียง B5 · ขั้นรอออก', _Level.watch),
  _Alert('09:47', 'ผลภาพสมองออกแล้ว',
      'นางสุดา กมลรัตน์ · เตียง A4 · รอแพทย์อ่านผล', _Level.watch),
  _Alert('09:54', 'ส่งต่อผู้ป่วยไปวอร์ดอายุรกรรมสำเร็จ',
      'นายปรีชา ดำรงค์ · ย้ายออกจากเตียง A5', _Level.normal),
  _Alert('09:41', 'คัดกรองครบทุกรายในคิวเช้า',
      'คัดกรอง 18 ราย · เฉลี่ย 6 นาทีต่อราย', _Level.normal),
  _Alert('09:30', 'รับเวรกะเช้าเรียบร้อย', 'พยาบาล 6 คน · แพทย์เวร 2 คน',
      _Level.normal),
  _Alert('09:12', 'จำหน่ายผู้ป่วยกลับบ้าน 3 ราย', 'เตียง B1 · B3 · B4 ว่างแล้ว',
      _Level.normal),
];

/// สี่ขั้นของกระแสงานใน ER ตรงกับแท็บใน e_r_homepage_copy
/// เพิ่ม "รอออก" เพราะคนกลุ่มนี้ยังครองเตียงอยู่ ต้องนับเป็นภาระงาน
enum _Stage {
  triage('รอคัดกรอง', 'Waiting for triage', 'triage'),
  waitDoctor('รอตรวจ', 'Waiting for doctor', 'wait_doctor'),
  treatment('ตรวจแล้ว', 'In treatment', 'treatment'),
  discharge('รอออก', 'Waiting for discharge', 'discharge'),
  observe('สังเกตอาการ', 'Under observation', 'observe');

  const _Stage(this.label, this.en, this.asset);

  final String label;
  final String en;
  final String asset;

  String get image => 'assets/images/flow/stage_$asset.png';

  /// รหัสที่ใช้คุยกับฝั่งสามมิติ ตรงกับชื่อปีกใน er_ward.glb
  String get key => switch (this) {
        _Stage.triage => 'zone_triage',
        _Stage.waitDoctor => 'zone_waitdoctor',
        _Stage.treatment => 'zone_treatment',
        _Stage.discharge => 'zone_discharge',
        _Stage.observe => 'zone_observe',
      };
}

/// ช่วงงานที่ใช้เป็นแท็บฝั่งขวา ตามแบบ Figma node 96-1345
///
/// หนึ่งช่วงครอบได้หลายขั้น — "ตรวจรักษา" กินทั้งรอตรวจและตรวจแล้ว
/// เพราะในสายตาคนทำงานมันคือช่วงเดียวกัน ต่างกันแค่แพทย์มาถึงหรือยัง
enum _Phase {
  triage('คัดกรอง', [_Stage.triage]),
  treatment('ตรวจรักษา', [_Stage.waitDoctor, _Stage.treatment]),
  after('หลังการตรวจ', [_Stage.discharge]),
  observe('สังเกตอาการ', [_Stage.observe]);

  const _Phase(this.label, this.stages);

  final String label;
  final List<_Stage> stages;

  /// คีย์ห้องในฉากสามมิติ คั่นด้วยจุลภาคเมื่อครอบหลายห้อง
  String get keys => stages.map((s) => s.key).join(',');

  static _Phase of(_Stage stage) =>
      _Phase.values.firstWhere((p) => p.stages.contains(stage));
}

/// เกณฑ์เวลาของแต่ละขั้น (นาที) เกินแล้วถือว่าค้างผิดปกติ
/// ขั้นรอตรวจใช้เกณฑ์ตามระดับความเร่งด่วน ที่เหลือใช้ค่าเดียวทั้งขั้น
int _limitFor(_Stage stage, _Esi? esi) {
  switch (stage) {
    case _Stage.triage:
      return 10;
    case _Stage.waitDoctor:
      return const {1: 0, 2: 10, 3: 30, 4: 60, 5: 120}[esi?.level ?? 3] ?? 30;
    case _Stage.treatment:
      return 120;
    case _Stage.discharge:
      return 45;
    // สังเกตอาการใน ER ไม่ควรเกิน 6 ชม. (เกินแล้วต้องตัดสินใจ admit/จำหน่าย)
    case _Stage.observe:
      return 360;
  }
}

/// รูปหน้าจำลองสำหรับผู้ป่วยที่ปักหมุด ชุดเดียวกับหน้าผังเตียง
const List<String> _facePhotos = [
  'photo-1500648767791-00dcc994a43e',
  'photo-1544005313-94ddf0286df2',
  'photo-1528892952291-009c663ce843',
  'photo-1633332755192-727a05c4013d',
  'photo-1573497019940-1c28c88b4f3e',
  'photo-1521119989659-a83eee488004',
];

/// รูปหน้าประจำ HN
///
/// เดิมดึงจาก Unsplash ตรง ๆ แต่เครือข่ายในโรงพยาบาลบล็อกปลายทาง
/// รูปจึงหายทั้งหน้า ย้ายมาเก็บเป็นไฟล์ในแอปแทน ได้ภาพชุดเดิมและไม่พึ่งเน็ต
String _faceUrl(String hn) {
  final i = hn.hashCode.abs() % _facePhotos.length;
  return 'assets/images/faces/face$i.jpg';
}

/// เวลานาฬิกาแบบไทย ลงท้ายด้วย "น." เสมอ เช่น 10:22 น.
String _clock(String hhmm) => '$hhmm น.';

String _hm(int minutes) => minutes < 60
    ? '$minutes นาที'
    : '${minutes ~/ 60} ชม. ${(minutes % 60).toString().padLeft(2, '0')} น.';

/// ผู้ป่วยหนึ่งคนที่อยู่ในห้องตอนนี้
class _P {
  const _P(this.hn, this.name, this.stage, this.waitMin,
      {this.esi, this.bed, this.note = '', this.type});

  final String hn;
  final String name;
  final _Stage stage;

  /// เวลาที่ค้างอยู่ในขั้นนี้ หน่วยนาที
  final int waitMin;

  /// คนที่ยังไม่ถูกคัดกรองจะยังไม่มีระดับความเร่งด่วน
  final _Esi? esi;

  /// เตียงที่ครองอยู่ ถ้าไม่มีคือยังไม่ได้เตียง
  final String? bed;

  /// ข้อความสั้น ๆ บอกว่าค้างเพราะอะไร
  final String note;

  /// ทางด่วนเฉพาะโรคที่ผู้ป่วยรายนี้เข้าเกณฑ์ ถ้าไม่มีคือเคสทั่วไป
  final _Ptype? type;

  bool get over => waitMin > _limitFor(stage, esi);
}

/// รหัสเตียงในห้อง ชุดเดียวกับหน้าผังเตียง
const List<String> _roomBeds = [
  'A1',
  'A2',
  'A3',
  'A4',
  'A5',
  'B1',
  'B2',
  'B3',
  'B4',
  'B5',
];

/// รายชื่อผู้ป่วยจำลอง — ยังไม่ได้ต่อกับฐานข้อมูลจริง
/// ลงทะเบียนใหม่จะแทรกหัวรายการ (features/register)
final List<_P> _patients = [
  // รอคัดกรอง ยังไม่มี ESI จัดลำดับด้วยเวลารออย่างเดียว
  _P('670123456', 'นายสมชาย แสงชัย', _Stage.triage, 14,
      note: 'เดินมาเอง', type: _Ptype.stroke),
  _P('670123457', 'นางอารยา ธนกิจ', _Stage.triage, 11, note: 'ญาตินำส่ง'),
  _P('670123458', 'นายบริรักษ์ คงทน', _Stage.triage, 8, note: 'นั่งรถเข็น'),
  _P('670123459', 'นางสาวณัฐมน พงศ์ดี', _Stage.triage, 5, note: 'เดินมาเอง'),
  _P('670123460', 'นายวีระชัย ลาภมี', _Stage.triage, 3,
      note: 'ส่งตัวโดย BLS', type: _Ptype.trauma),

  // รอตรวจ บางคนได้เตียง บางคนนั่งรอ
  _P('670123461', 'นายกิตติพงษ์ รัตน์', _Stage.waitDoctor, 22,
      esi: _Esi.one, bed: 'A3', note: 'รอแพทย์เวรกู้ชีพ', type: _Ptype.stemi),
  _P('670123462', 'นางสุดา กมลรัตน์', _Stage.waitDoctor, 34,
      esi: _Esi.two, bed: 'A4', note: 'รอผลภาพสมอง', type: _Ptype.stroke),
  _P('670123463', 'นางสาวจุฑามาศ ไชย', _Stage.waitDoctor, 45,
      esi: _Esi.two, bed: 'B1', type: _Ptype.sepsis),
  _P('670123464', 'นายนิติพนธ์ สุขสม', _Stage.waitDoctor, 52, esi: _Esi.three),
  _P('670123465', 'นางลลิตา ภู่ทอง', _Stage.waitDoctor, 65, esi: _Esi.three),
  _P('670123466', 'นายอนันต์ มีทรัพย์', _Stage.waitDoctor, 78, esi: _Esi.four),
  _P('670123467', 'นางกัญญารัตน์ ทองดี', _Stage.waitDoctor, 96, esi: _Esi.four),
  _P('670123468', 'นายวัชระ นาคสุข', _Stage.waitDoctor, 41,
      esi: _Esi.four, note: 'ข้อมือขวาผิดรูป'),

  // ตรวจแล้ว ครองเตียงระหว่างรอผลหรือรอตัดสินใจ
  _P('670123469', 'นางสาวสุภาพร ว่องไว', _Stage.treatment, 80,
      esi: _Esi.one, bed: 'A1', note: 'รอผล CT ด่วน', type: _Ptype.trauma),
  _P('670123470', 'นางอรสา ลิ้มเจริญ', _Stage.treatment, 105,
      esi: _Esi.two, bed: 'A2', note: 'รอผลเพาะเชื้อ', type: _Ptype.sepsis),
  _P('670123471', 'นายปรีชา ดำรงค์', _Stage.treatment, 155,
      esi: _Esi.two, bed: 'A5', note: 'รอเตียงวอร์ดอายุรกรรม'),
  _P('670123472', 'นางพิมพ์ชนก ศรีวิไล', _Stage.observe, 62,
      esi: _Esi.three, bed: 'B2', note: 'สังเกตอาการหลังพ่นยา 2 รอบ'),

  // รอออก ปลายทางตัดสินแล้วแต่ยังไม่ได้ออกจริง
  _P('670123473', 'นางพรทิพย์ ก้องเกียรติ', _Stage.discharge, 15,
      esi: _Esi.three, bed: 'B3', note: 'รอใบสั่งยา'),
  _P('670123474', 'นายจิระ สินสมบูรณ์', _Stage.discharge, 28,
      esi: _Esi.four, bed: 'B4', note: 'รอญาติมารับ'),
  _P('670123475', 'นางวารุณี เพ็ญศรี', _Stage.discharge, 58,
      esi: _Esi.two, bed: 'B5', note: 'รอรถส่งต่อ'),
];

/// การเตือนให้กลับไปดูผู้ป่วยตามคำสั่ง/หัตถการ
class _Reminder {
  _Reminder(this.hn, this.title, this.due);
  final String hn;
  final String title;
  DateTime due;

  /// ถึงเวลาแล้ว (เด้งเตือนแล้ว)
  bool fired = false;

  /// รับทราบ/ยกเลิกแล้ว
  bool done = false;
}
