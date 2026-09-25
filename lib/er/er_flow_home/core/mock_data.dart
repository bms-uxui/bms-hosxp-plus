part of '../er_flow_home_widget.dart';

/// รายการเหตุการณ์ในเส้นเวลาของผู้ป่วย (ข้อมูลจำลอง)
/// ข้อความหนึ่งรายการในประวัติการคุยกับผู้ช่วย
class _ChatTurn {
  const _ChatTurn(this.user, this.text, this.step, this.at);
  final bool user;
  final String text;
  final int step;
  final DateTime at;
}

class _Ev {
  const _Ev(this.time, this.text, {this.byDoctor = false});
  final String time;
  final String text;
  final bool byDoctor;
}

// ------------------------------------------------ ข้อมูลจำลองของแพทย์
enum _Finding { none, normal, abnormal, notDone }

class _System {
  const _System(this.key, this.icon, this.th, this.en, this.note, this.spot);
  final String key;
  final IconData icon;
  final String th;
  final String en;
  final String note;
  final String spot; // จุดบนหุ่นที่เกี่ยวข้อง
}

/// ทบทวนอาการตามระบบ (ROS) — ตามหน้าจอ 165:2618
const List<_System> _rosSystems = [
  _System('ros_const', Icons.person_rounded, 'อาการทั่วไป', 'Constitutional',
      'ไม่มีไข้ ไม่อ่อนเพลีย', 'belly'),
  _System('ros_eyes', Icons.visibility_rounded, 'ตาและการมองเห็น', 'Eyes',
      'ไม่ตามัว ไม่ปวดตา', 'head'),
  _System('ros_ent', Icons.hearing_rounded, 'หู จมูก คอ ช่องปาก', 'ENT-Mouth',
      'ไม่เจ็บคอ ไม่มีน้ำมูก', 'neck'),
  _System('ros_cv', Icons.favorite_rounded, 'หัวใจและหลอดเลือด',
      'Cardiovascular', 'ใจสั่น ไม่มีเจ็บหน้าอก', 'heart'),
  _System('ros_resp', Icons.air_rounded, 'ระบบทางเดินหายใจ', 'Respiratory',
      'ไอมีเสมหะ หอบเหนื่อย 2 วัน', 'chest'),
  _System('ros_gi', Icons.restaurant_rounded, 'ระบบทางเดินอาหาร',
      'Gastrointestinal', 'ไม่คลื่นไส้ ไม่ปวดท้อง', 'abdomen'),
  _System('ros_heme', Icons.water_drop_rounded, 'เลือดและต่อมน้ำเหลือง',
      'Hemato-Lymphatic', '', 'arm'),
  _System('ros_msk', Icons.accessibility_new_rounded, 'กล้ามเนื้อและกระดูก',
      'Musculoskeletal', 'ปวดเข่าขวาเวลาเดิน', 'knee'),
];

/// ตรวจร่างกาย (PE) — ตามหน้าจอ 165:2615
const List<_System> _peSystems = [
  _System('pe_ga', Icons.person_rounded, 'GA', 'General Appearance',
      'รู้สึกตัวดี', 'neck'),
  _System('pe_heent', Icons.visibility_rounded, 'HEENT', 'Head, Eye, ENT',
      'ไม่ซีด ไม่เหลือง', 'head'),
  _System('pe_heart', Icons.favorite_rounded, 'Heart', 'Cardiovascular',
      'Tachycardia 124/min', 'heart'),
  _System('pe_chest', Icons.air_rounded, 'Chest / Lung', 'Respiratory',
      'Wheezing RLL', 'chest'),
  _System('pe_abd', Icons.restaurant_rounded, 'Abdomen', 'Abdomen',
      'ท้องนุ่ม กดเจ็บบริเวณลิ้นปี่เล็กน้อย ไม่พบ guarding', 'abdomen'),
  _System('pe_ext', Icons.accessibility_new_rounded, 'Extremities',
      'Musculoskeletal', 'No edema', 'ankle'),
  _System('pe_neuro', Icons.psychology_rounded, 'Neurological', 'Neurological',
      'GCS E4V4M5', 'head'),
];

/// ทิศทางการเปลี่ยนแปลงระหว่างครั้ง
enum _Change { none, same, newAbn, worse, better }

/// ผลตรวจหนึ่งครั้ง: เวลา ผู้บันทึก และผลของแต่ละระบบ (ผล, บันทึกย่อ)
class _ExamRound {
  const _ExamRound(this.time, this.by, this.findings);
  final String time;
  final String by;
  final Map<String, (_Finding, String)> findings;
  (_Finding, String) of(String key) => findings[key] ?? (_Finding.none, '');
}

/// ทบทวนระบบ 3 Record เก่า → ใหม่ (ตามหน้าจอ 165:2618)
const List<_ExamRound> _rosRounds = [
  _ExamRound('22:10', 'นพ.ธนกร สุขใจ', {
    'ros_const': (_Finding.abnormal, 'ไข้ต่ำ ๆ อ่อนเพลีย 1 วัน'),
    'ros_eyes': (_Finding.normal, 'ไม่ตามัว ไม่ปวดตา'),
    'ros_ent': (_Finding.abnormal, 'เจ็บคอเล็กน้อย'),
    'ros_cv': (_Finding.normal, 'ไม่ใจสั่น ไม่เจ็บหน้าอก'),
    'ros_resp': (_Finding.abnormal, 'ไอแห้ง ไม่หอบ'),
    'ros_gi': (_Finding.normal, 'ไม่คลื่นไส้ ไม่ปวดท้อง'),
    'ros_heme': (_Finding.notDone, ''),
    'ros_msk': (_Finding.normal, 'ไม่ปวดกล้ามเนื้อหรือข้อ'),
  }),
  _ExamRound('13:40', 'พญ.สุภาวดี พรชัย', {
    'ros_const': (_Finding.normal, 'ไม่มีไข้ ไม่อ่อนเพลีย'),
    'ros_eyes': (_Finding.normal, 'ไม่ตามัว ไม่ปวดตา'),
    'ros_ent': (_Finding.normal, 'ไม่เจ็บคอ'),
    'ros_cv': (_Finding.normal, 'ไม่ใจสั่น ไม่เจ็บหน้าอก'),
    'ros_resp': (_Finding.abnormal, 'ไอมีเสมหะ หอบเหนื่อย'),
    'ros_gi': (_Finding.abnormal, 'คลื่นไส้ ไม่อาเจียน'),
    'ros_heme': (_Finding.notDone, ''),
    'ros_msk': (_Finding.abnormal, 'ปวดเข่าขวาเวลาเดิน'),
  }),
  _ExamRound('14:23', 'นพ.กิตติศักดิ์ วัฒนา', {
    'ros_const': (_Finding.normal, 'ไม่มีไข้ ไม่อ่อนเพลีย'),
    'ros_eyes': (_Finding.normal, 'ไม่ตามัว ไม่ปวดตา'),
    'ros_ent': (_Finding.normal, 'ไม่เจ็บคอ ไม่มีน้ำมูก'),
    'ros_cv': (_Finding.abnormal, 'ใจสั่น ไม่มีเจ็บหน้าอก'),
    'ros_resp': (_Finding.abnormal, 'ไอมีเสมหะ หอบเหนื่อย 2 วัน'),
    'ros_gi': (_Finding.normal, 'ไม่คลื่นไส้ ไม่ปวดท้อง'),
    'ros_heme': (_Finding.notDone, ''),
    'ros_msk': (_Finding.abnormal, 'ปวดเข่าขวาเวลาเดิน'),
  }),
];

/// ตรวจร่างกาย 3 ครั้ง — ครั้งล่าสุดคือค่าที่แสดงตั้งต้น
const List<_ExamRound> _peRounds = [
  _ExamRound('09:35', 'นพ.กิตติศักดิ์', {
    'pe_ga': (_Finding.abnormal, 'ซึมเล็กน้อย ตอบคำถามช้า'),
    'pe_heent': (_Finding.normal, 'ไม่ซีด ไม่เหลือง'),
    'pe_heart': (_Finding.abnormal, 'Tachycardia 132/min'),
    'pe_chest': (_Finding.abnormal, 'Wheezing both lungs'),
    'pe_abd': (_Finding.normal, 'ท้องนุ่ม กดไม่เจ็บ'),
    'pe_ext': (_Finding.normal, 'No edema'),
    'pe_neuro': (_Finding.abnormal, 'GCS E3V4M5'),
  }),
  _ExamRound('11:40', 'พญ.ศิริพร', {
    'pe_ga': (_Finding.normal, 'รู้สึกตัวดี'),
    'pe_heent': (_Finding.normal, 'ไม่ซีด ไม่เหลือง'),
    'pe_heart': (_Finding.abnormal, 'Tachycardia 128/min'),
    'pe_chest': (_Finding.abnormal, 'Wheezing RLL'),
    'pe_abd': (_Finding.normal, 'ท้องนุ่ม กดไม่เจ็บ'),
    'pe_ext': (_Finding.normal, 'No edema'),
    'pe_neuro': (_Finding.abnormal, 'GCS E4V4M5'),
  }),
  _ExamRound('14:25', 'นพ.กิตติศักดิ์', {
    'pe_ga': (_Finding.normal, 'รู้สึกตัวดี'),
    'pe_heent': (_Finding.normal, 'ไม่ซีด ไม่เหลือง'),
    'pe_heart': (_Finding.abnormal, 'Tachycardia 124/min'),
    'pe_chest': (_Finding.abnormal, 'Wheezing RLL'),
    'pe_abd': (
      _Finding.abnormal,
      'ท้องนุ่ม กดเจ็บบริเวณลิ้นปี่เล็กน้อย ไม่พบ guarding'
    ),
    'pe_ext': (_Finding.normal, 'No edema'),
    'pe_neuro': (_Finding.abnormal, 'GCS E4V4M5'),
  }),
];

enum _OrderStatus { pending, accepted, working, done }

class _OrderItem {
  const _OrderItem(this.name, this.detail, this.status, this.time);
  final String name;
  final String detail;
  final _OrderStatus status;
  final String time;
}

class _OrderGroup {
  const _OrderGroup(this.title, this.icon, this.color, this.items);
  final String title;
  final IconData icon;
  final Color color;
  final List<_OrderItem> items;
}

const List<String> _templates = [
  'ใช้บ่อย',
  'Sepsis',
  'Chest Pain',
  'Stroke',
  'Trauma',
  'งูกัด',
];

/// ชุดคำสั่งของ Sepsis — ตามหน้าจอ 169:2801
const List<_OrderGroup> _orderGroups = [
  _OrderGroup('ยา / เวชภัณฑ์', Icons.medication_rounded, _blue, [
    _OrderItem('Piperacillin + Tazobactam 4.5 g',
        'IV ทุก 8 ชม. · หลังเจาะ culture', _OrderStatus.done, '10:40'),
    _OrderItem('Ceftriaxone 1 g', 'IV วันละครั้ง · ยังไม่แพ้ยา',
        _OrderStatus.pending, ''),
    _OrderItem('0.9% NSS 1,000 mL', 'IV drip 30 mL/kg ใน 3 ชม.',
        _OrderStatus.working, '10:34'),
  ]),
  _OrderGroup('เลือด', Icons.water_drop_rounded, _redHue, [
    _OrderItem('Blood culture ×2', 'aerobic + anaerobic ก่อนให้ยาปฏิชีวนะ',
        _OrderStatus.working, '10:32'),
  ]),
  _OrderGroup('แล็บ', Icons.science_rounded, _blueHue, [
    _OrderItem('CBC', 'complete blood count', _OrderStatus.done, '10:48'),
    _OrderItem('BUN / Cr', 'serum', _OrderStatus.accepted, '10:35'),
    _OrderItem(
        'Lactate', 'ซ้ำที่ 2 ชม. ถ้า > 2', _OrderStatus.accepted, '10:35'),
  ]),
  _OrderGroup('ภาพถ่าย', Icons.radio_button_checked_rounded, _blue, [
    _OrderItem('Chest X-ray', 'CXR AP/Portable', _OrderStatus.done, '10:50'),
  ]),
  _OrderGroup('Set OR (ผ่าตัด)', Icons.local_hospital_rounded, _blue, [
    _OrderItem(
        'จองห้องผ่าตัด', 'ส่งผ่าตัดจากห้องฉุกเฉิน', _OrderStatus.pending, ''),
  ]),
  _OrderGroup('หัตถการ', Icons.healing_rounded, _blue, [
    _OrderItem('Oxygen cannula 3 L/min', 'เป้าหมาย SpO₂ > 94%',
        _OrderStatus.working, '10:34'),
    _OrderItem(
        'On ET tube', 'เตรียมพร้อมถ้าหายใจล้มเหลว', _OrderStatus.pending, ''),
  ]),
];

class _Task {
  const _Task(
      this.title, this.detail, this.icon, this.color, this.time, this.waitMin,
      {this.urgent = false, this.doctor = false, this.by = 'พญ. ศิริพร ก.'});
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final String time;
  final int waitMin;
  final bool urgent;
  final bool doctor;

  /// ผู้สั่งงานนี้ (time = เวลาที่สั่ง)
  final String by;
}

const List<_Task> _followTasks = [
  _Task('เก็บ Blood culture ×2', 'พยาบาลรอรับ', Icons.water_drop_rounded,
      _redHue, '10:32', 6,
      urgent: true),
  _Task('ให้ Piperacillin + Tazobactam', 'รอผล culture',
      Icons.medication_rounded, _blue, '10:34', 6,
      by: 'นพ. ธีรภัทร อ.'),
  _Task('ให้ออกซิเจน 3 L/min', 'กำลังติดตาม SpO₂', Icons.air_rounded, _blue,
      '10:34', 4),
  _Task('ประเมินซ้ำหลังให้ยา 15 นาที', 'เหลือ 4 นาที', Icons.timer_rounded,
      _blue, '10:45', 11,
      urgent: true, doctor: true),
  _Task('ทบทวนผล CBC / Lactate', 'Lactate 4.1', Icons.science_rounded, _redHue,
      '10:48', 3,
      doctor: true, by: 'นพ. ธีรภัทร อ.'),
  _Task('ประเมินการหายใจซ้ำ', 'หลังให้การรักษา 1 ชม.',
      Icons.person_search_rounded, _blueHue, '11:30', 0,
      doctor: true),
];

/// ขั้นตอนของโหมดพูด เรียงตามลำดับที่แพทย์ทำงานจริง
/// ขั้นของโหมดพูด ตาม workflow แพทย์ ER (Figma 130-5: Single-View → HPI →
/// Systemic Review → Wound → Diagnosis & Orders → Disposition)
const List<(IconData, String)> _doctorSteps = [
  (Icons.visibility_outlined, 'ทบทวนเคส'),
  (Icons.history_edu_rounded, 'ประวัติ HPI'),
  (Icons.accessibility_new_rounded, 'ตรวจร่างกาย'),
  (Icons.healing_rounded, 'บาดแผล/หัตถการ'),
  (Icons.assignment_rounded, 'วินิจฉัย/สั่ง'),
  (Icons.logout_rounded, 'จำหน่าย'),
];

/// ช่องของฟอร์มที่แต่ละขั้นของโหมดพูดต้องกรอก (ชื่อช่อง, ตัวอย่างสั้น)
///
/// แพทย์กรอกเฉพาะฟอร์ม role = doctor ใน er_form_kb.json
/// (physical_examination · treatment · diagnosis · คำสั่งแพทย์ · admit/refer)
/// ข้อมูลคัดกรอง/อุบัติเหตุ พยาบาลคัดกรองเป็นคนบันทึก แพทย์แค่ทบทวนและยืนยัน
const List<List<(String, String)>> _doctorForm = [
  [
    ('ยืนยันข้อมูลคัดกรอง', 'ถูกต้อง / ขอแก้ไข'),
    ('ยืนยันประวัติแพ้ยา', 'ถูกต้อง / ขอแก้ไข'),
  ],
  [
    ('HPI', 'ประวัติอาการปัจจุบัน'),
  ],
  [
    ('GA', 'ปกติ / ผิดปกติ'),
    ('HEENT', 'ปกติ / ผิดปกติ'),
    ('Heart', 'ปกติ / ผิดปกติ'),
    ('Chest', 'ปกติ / ผิดปกติ'),
    ('Abdomen', 'ปกติ / ผิดปกติ'),
    ('PR', 'ปกติ / ไม่ได้ตรวจ'),
    ('PV', 'ปกติ / ไม่ได้ตรวจ'),
    ('Genitalia', 'ปกติ / ไม่ได้ตรวจ'),
    ('Neurological', 'GCS pupils'),
    ('Extremities', 'ปกติ / ผิดปกติ'),
    ('บันทึกการตรวจแบบละเอียด', 'บันทึกผลตรวจเพิ่มเติม (ข้อความยาวได้)'),
  ],
  [
    ('ตำแหน่ง ชนิด ขนาดแผล', 'ฉีกขาด 3 ซม.'),
    ('หัตถการที่ทำ', 'ทำแผล / เย็บแผล'),
    ('รหัสหัตถการ ICD-9-CM', ''),
    ('ถ่ายภาพแผล', 'ถ่าย / ข้าม'),
  ],
  [
    ('Diagnosis ICD-10', 'S06.0'),
    ('Diagnosis Text', ''),
    ('Template คำสั่งแพทย์', 'ตามประเภทผู้ป่วย'),
    ('ยา/เวชภัณฑ์', 'จาก template'),
    ('Lab', 'CBC Coag'),
    ('X-ray', 'CT Brain'),
    ('หัตถการ', 'IV Line'),
  ],
  [
    ('สภาพผู้ป่วยออกจากห้อง ER', 'Admit / Refer / Observe'),
    ('ตึกผู้ป่วยใน / สถานพยาบาลที่ส่งไป', ''),
    ('อาการสำคัญ (ใบ Admit/Refer)', ''),
    ('ยืนยันแพทย์ผู้บันทึก', ''),
  ],
];

/// แนวทางว่าผู้ช่วยควรถามอะไรในแต่ละขั้น (ใส่ใน system prompt)
const List<String> _doctorAsk = [
  'ข้อมูลคัดกรองพยาบาลบันทึกแล้วและแสดงบนจอ ให้แพทย์ยืนยันว่าถูกต้องหรือขอแก้ไข '
      'และยืนยันประวัติแพ้ยา ห้ามถามข้อมูลคัดกรองใหม่',
  'ซักประวัติอาการปัจจุบันแบบ OLDCARTS ต่อยอดจากอาการสำคัญ (เริ่มเมื่อไร ระยะเวลา '
      'อาการร่วม ถ้าเป็น Trauma ถามกลไกการบาดเจ็บและการหมดสติ) ถามทีละ 1-2 ข้อ '
      'แล้วเรียบเรียงทั้งหมดลงช่อง HPI ช่องเดียว',
  'ให้แพทย์บอกผลตรวจร่างกายทีละระบบ ระบบที่ไม่ได้พูดถึงห้ามเดา '
      'ถ้าแพทย์บอก "ปกติหมด" ให้ใส่ปกติทุกช่องที่เหลือ '
      'ถ้าแพทย์บอก "ยังไม่ได้ตรวจ(ทั้งหมด)" ให้ใส่ "ไม่ได้ตรวจ" ทุกระบบที่ยังว่าง (รวม Neuro) แล้วจบขั้น ไม่ต้องถามต่อ '
      'ช่อง "บันทึกการตรวจแบบละเอียด" ไม่บังคับ ไม่ต้องถาม '
      'Neuro ที่ตรวจแล้วต้องได้ GCS '
      'ระบบที่ผิดปกติต้องได้รายละเอียดเสมอ ถ้ายังไม่มีให้ถามก่อนไปต่อ',
  'ถ้าไม่มีแผลให้ใส่ "ไม่มีบาดแผล" ในช่องแรก ช่องอื่นเป็น "-" แล้วบอกว่าข้ามขั้นนี้ได้ '
      'ถ้ามีแผลให้แตะบนหุ่น 3D เพื่อระบุตำแหน่ง บอกชนิดและขนาด '
      'แล้วถามหัตถการที่ทำ (ทำแผล เย็บแผล ...) ใช้ตัวเลือกจริง',
  'สรุปวินิจฉัยจากข้อมูลทั้งหมดและเสนอรหัส ICD-10 ให้แพทย์ยืนยัน '
      'เสนอชุดส่งตรวจและการรักษาที่เหมาะกับวินิจฉัยเป็นตัวเลือกให้กด '
      'ห้ามสั่งยาที่ผู้ป่วยแพ้',
  'ให้แพทย์เลือกสถานะจำหน่ายเป็นตัวเลือกจริงของระบบ '
      'ถ้า Admit/Refer ให้เลือกตึกหรือสถานพยาบาลและอาการสำคัญ แล้วสรุปเคสสั้น ๆ ก่อนยืนยัน',
];

/// template HPI ของแพทย์ ER: (id, ชื่อ, ข้อความที่มีช่อง [ ] ให้เติม)
/// ผู้ช่วยเลือกใช้ได้ด้วย "hpi_template" และเติม [ ] จากคำบอกเล่าของแพทย์
const List<(String, String, String)> _hpiTemplates = [
  (
    'trauma',
    'อุบัติเหตุ',
    'ผู้ป่วย[เพศ/อายุ] ประสบอุบัติเหตุ[กลไก เช่น รถจักรยานยนต์ล้มเอง/ชน] '
        'เมื่อ[เวลา] ก่อนมา รพ. [ระยะเวลา] ขณะเกิดเหตุ[ผู้ขับขี่/ผู้โดยสาร] '
        'หมดสติ[มี/ไม่มี] จำเหตุการณ์ได้[ได้/ไม่ได้] ปวด[ตำแหน่ง] '
        'อาเจียน[มี/ไม่มี] ชัก[มี/ไม่มี] เลือดออก[ตำแหน่ง] '
        'ได้รับการดูแลก่อนมาถึง[ใส่เฝือก/ห้ามเลือด/C-collar]'
  ),
  (
    'chest_pain',
    'เจ็บหน้าอก',
    'เจ็บแน่นหน้าอก[ตำแหน่ง] ลักษณะ[แน่น/บีบ/แสบ] เริ่มเมื่อ[เวลา] นาน[ระยะเวลา] '
        'ร้าวไป[แขน/กราม/หลัง] เป็นขณะ[พัก/ออกแรง] อาการร่วม[เหงื่อแตก/ใจสั่น/หอบ/คลื่นไส้] '
        'ความรุนแรง[0-10] ประวัติ[HT/DM/DLP/สูบบุหรี่/โรคหัวใจ] ยาที่ทานอยู่[ ]'
  ),
  (
    'stroke',
    'Stroke',
    'แขนขาอ่อนแรงซีก[ซ้าย/ขวา] ปากเบี้ยว[มี/ไม่มี] พูดไม่ชัด[มี/ไม่มี] '
        'Last seen normal[เวลา] พบอาการเมื่อ[เวลา] ปวดศีรษะ[มี/ไม่มี] ชัก[มี/ไม่มี] '
        'ประวัติ[HT/DM/AF/stroke เดิม] ยาต้านเกล็ดเลือด/ต้านการแข็งตัวของเลือด[ ]'
  ),
  (
    'fever',
    'ไข้/ติดเชื้อ',
    'ไข้[ระยะเวลา] หนาวสั่น[มี/ไม่มี] อาการร่วม[ไอ/เสมหะ/ปัสสาวะแสบขัด/ปวดท้อง/ถ่ายเหลว] '
        'ซึมลง[มี/ไม่มี] รับประทานได้[ปกติ/น้อยลง] ปัสสาวะ[ปกติ/ออกน้อย] '
        'ประวัติ[โรคประจำตัว/ภูมิคุ้มกันต่ำ] ได้ยามาก่อน[ ]'
  ),
  (
    'abd_pain',
    'ปวดท้อง',
    'ปวดท้อง[ตำแหน่ง] ลักษณะ[บิด/แน่น/แสบ] เริ่มเมื่อ[เวลา] นาน[ระยะเวลา] '
        'ร้าวไป[ตำแหน่ง] คลื่นไส้อาเจียน[มี/ไม่มี] ถ่ายเหลว[มี/ไม่มี] ไข้[มี/ไม่มี] '
        'ถ่ายเป็นเลือด/ดำ[มี/ไม่มี] ประจำเดือนครั้งสุดท้าย[ ] ความรุนแรง[0-10]'
  ),
  (
    'dyspnea',
    'หอบเหนื่อย',
    'หอบเหนื่อย[ระยะเวลา] เป็นมากขึ้นขณะ[พัก/ออกแรง/นอนราบ] ไอ[แห้ง/มีเสมหะ] '
        'ไข้[มี/ไม่มี] เจ็บหน้าอก[มี/ไม่มี] ขาบวม[มี/ไม่มี] '
        'ประวัติ[หอบหืด/COPD/หัวใจล้มเหลว] ใช้ยาพ่น[ ]'
  ),
  (
    'general',
    'ทั่วไป (OLDCARTS)',
    'อาการ[ ] เริ่มเมื่อ[เวลา] ตำแหน่ง[ ] ระยะเวลา[ ] ลักษณะ[ ] '
        'ปัจจัยที่ทำให้ดีขึ้น/แย่ลง[ ] ร้าวไป[ ] ความรุนแรง[0-10] อาการร่วม[ ] '
        'การรักษาก่อนมา[ ]'
  ),
];

/// พยาบาลห้องฉุกเฉิน: ฟอร์ม role = nurse ที่ทำระหว่างผู้ป่วยอยู่ใน ER
/// (add_vitalsignmonitor · AIS · nursing_activities · observe · nursing diagnosis)
const List<(IconData, String)> _nurseSteps = [
  (Icons.monitor_heart_rounded, 'สัญญาณชีพ'),
  (Icons.personal_injury_rounded, 'ความรุนแรง AIS'),
  (Icons.playlist_add_check_rounded, 'รับคำสั่งแพทย์'),
  (Icons.visibility_rounded, 'สังเกตอาการ'),
  (Icons.volunteer_activism_rounded, 'การพยาบาล'),
  (Icons.logout_rounded, 'ออกจาก ER'),
];

const List<List<(String, String)>> _nurseForm = [
  [
    ('ความดัน', 'mmHg'),
    ('อัตราการเต้นชีพจร', '/min'),
    ('อัตราการเต้นของหัวใจ', '/min'),
    ('ออกซิเจนในเลือด', '%'),
    ('อุณหภูมิ', '°C'),
  ],
  [
    ('HEAD/NECK', ''),
    ('FACE', ''),
    ('THORAX', ''),
    ('ABDOMEN/PELVIC CONTENTS', ''),
    ('EXTREMITIES/PELVIC GIRDLE', ''),
    ('EXTERNAL', ''),
  ],
  [
    ('รับคำสั่ง ยา/เวชภัณฑ์', 'รับคำสั่ง / ยกเลิก'),
    ('รับคำสั่ง Lab', 'รับคำสั่ง / ยกเลิก'),
    ('รับคำสั่ง X-ray', 'รับคำสั่ง / ยกเลิก'),
    ('รับคำสั่ง หัตถการ', 'รับคำสั่ง / ยกเลิก'),
    ('ดำเนินการแล้ว / ใช้เวลา', 'นาที'),
  ],
  [
    ('สถานที่สังเกตอาการ', ''),
    ('ห้อง / เตียง', ''),
    ('อาการที่สังเกตได้', ''),
  ],
  [
    ('ข้อวินิจฉัยทางการพยาบาล', ''),
    ('กิจกรรมพยาบาล', ''),
    ('ประเมินผล', ''),
  ],
  [
    ('สภาพผู้ป่วยออกจากห้อง ER', 'Admit / Refer / กลับบ้าน'),
    ('วันที่-เวลาออกจากห้อง ER', ''),
    ('ส่งต่อข้อมูลให้วอร์ด / รพ.ปลายทาง', ''),
    ('ยืนยันพยาบาลผู้บันทึก', ''),
  ],
];

const List<String> _nurseAsk = [
  'ให้พยาบาลอ่านค่าสัญญาณชีพรอบนี้ทีละค่า รับตัวเลขตามที่พูดห้ามปัดเอง '
      'ถ้าค่าผิดปกติมากหรือแย่ลงจากรอบก่อนให้เตือนสั้น ๆ',
  'เฉพาะเคสอุบัติเหตุ ให้ประเมินความรุนแรง AIS ทีละส่วนของร่างกายเป็นตัวเลือกจริง '
      'ถ้าไม่ใช่อุบัติเหตุให้บอกว่าข้ามขั้นนี้ได้',
  'ทวนคำสั่งแพทย์ที่รอรับทีละกลุ่ม (ยา Lab X-ray หัตถการ) ให้กดรับหรือยกเลิก '
      'บันทึกเวลาที่ใช้เมื่อดำเนินการเสร็จ',
  'บันทึกสถานที่ ห้อง เตียงที่สังเกตอาการ และอาการที่สังเกตได้',
  'เสนอข้อวินิจฉัยทางการพยาบาลที่สอดคล้องกับอาการให้ยืนยัน '
      'แล้วเลือกกิจกรรมพยาบาลและประเมินผล ใช้ตัวเลือกจริง',
  'ให้เลือกสภาพผู้ป่วยออกจากห้อง ER เป็นตัวเลือก บันทึกเวลาออก '
      'และสรุปสิ่งที่ต้องส่งต่อให้วอร์ดหรือ รพ.ปลายทาง',
];

/// พยาบาลจุดคัดกรอง: ฟอร์ม patient_screening + accident + การดูแลก่อนมาถึง
/// (ข้อมูลเหตุการณ์อย่างหมวกนิรภัย/แอลกอฮอล์ ได้จากผู้ป่วย ญาติ หรือผู้นำส่งตอนรับเข้า)
const List<(IconData, String)> _triageSteps = [
  (Icons.how_to_reg_rounded, 'รับเข้า'),
  (Icons.record_voice_over_rounded, 'อาการสำคัญ'),
  (Icons.monitor_heart_rounded, 'สัญญาณชีพ'),
  (Icons.psychology_alt_rounded, 'GCS/รูม่านตา'),
  (Icons.car_crash_rounded, 'อุบัติเหตุ'),
  (Icons.priority_high_rounded, 'ระดับ ESI'),
];

const List<List<(String, String)>> _triageForm = [
  [
    ('ประเภทการมา', 'มาเอง / BLS / ALS'),
    ('สภาพผู้ป่วย', 'เดินมา / เปลนอน'),
    ('ผู้นำส่ง', ''),
    ('ประเภทผู้ป่วย', 'Trauma / Sepsis / …'),
  ],
  [
    ('อาการสำคัญ', ''),
    ('ระดับความเจ็บปวด', '0–10'),
  ],
  [
    ('ความดัน', 'mmHg'),
    ('อัตราการเต้นชีพจร', '/min'),
    ('อัตราการหายใจ', '/min'),
    ('ออกซิเจนในเลือด', '%'),
    ('อุณหภูมิ', '°C'),
    ('ความรู้สึกตัว', 'ตื่นดี / ซึม'),
  ],
  [
    ('การลืมตา / ตอบสนองการพูด / การเคลื่อนไหว', 'E4 V5 M6'),
    ('ปฏิกิริยารูม่านตา ซ้าย / ขวา', ''),
  ],
  [
    ('มีอุบัติเหตุหรือไม่', 'มี / ไม่มี'),
    ('สถานที่เกิดเหตุ', 'บนถนนสายรอง'),
    ('ประเภทอุบัติเหตุ', 'การขนส่ง V01-V89'),
    ('ยานพาหนะ / ประเภทผู้บาดเจ็บ', ''),
    ('หมวกนิรภัย / เข็มขัดนิรภัย', ''),
    ('แอลกอฮอล์ / สารเสพติด', ''),
    ('การดูแลก่อนมาถึง', ''),
  ],
  [
    ('ระดับความเร่งด่วน (ESI)', 'ภาวะวิกฤต…'),
    ('ห้อง / โซนห้องฉุกเฉิน', ''),
  ],
];

const List<String> _triageAsk = [
  'เก็บข้อมูลแรกรับ ถามประเภทการมา สภาพผู้ป่วย ผู้นำส่ง '
      'แล้วให้เลือกประเภทผู้ป่วยเป็นตัวเลือกจริงของระบบ',
  'บันทึกอาการสำคัญตามคำบอกเล่าของผู้ป่วยหรือญาติ และระดับความเจ็บปวด 0-10',
  'ให้พยาบาลอ่านค่าสัญญาณชีพทีละค่า รับตัวเลขตามที่พูดห้ามปัดเอง '
      'ถ้าค่าผิดปกติมากให้เตือนสั้น ๆ',
  'ประเมิน GCS แยก E V M และปฏิกิริยารูม่านตาซ้ายขวา ใช้ตัวเลือกจริงของระบบ',
  'ถ้าไม่ใช่อุบัติเหตุให้ใส่ "ไม่มี" ช่องแรกและข้ามขั้น ถ้ามีให้ถามจากผู้ป่วย ญาติ '
      'หรือผู้นำส่ง: สถานที่ ประเภท ยานพาหนะ อุปกรณ์นิรภัย แอลกอฮอล์ และการดูแลก่อนมาถึง',
  'เสนอระดับ ESI จากอาการและสัญญาณชีพให้ยืนยัน แล้วเลือกโซนห้องฉุกเฉิน',
];
