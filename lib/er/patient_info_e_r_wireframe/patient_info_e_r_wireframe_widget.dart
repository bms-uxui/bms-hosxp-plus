import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/er/physical_examination/er_body_map.dart';
import '/er/physical_examination/er_body_region.dart';

/// โครงหน้ารายละเอียดผู้ป่วยฉุกเฉินแบบ mid-fi wireframe
///
/// แยกจากหน้าจริงเพื่อใช้คุยโครงกับทีม — ไม่มีสีแบรนด์ ไม่มีรูปประกอบ
/// เหลือโครงสร้าง ลำดับความสำคัญ และความหนาแน่นของข้อมูล
///
/// แนวทางออกแบบ: ใช้พื้นที่ให้คุ้มที่สุด
///  - คู่ป้ายกำกับ–ค่า จัดเป็นหลายคอลัมน์ตามความกว้างที่มี ไม่เรียงลงทีละบรรทัด
///  - ข้อมูลที่เป็นชุดซ้ำใช้ตาราง ไม่ใช้การ์ดซ้อนกัน
///  - ระยะขอบและช่องไฟแน่น พออ่านสบายแต่ไม่เหลือที่ว่างเปล่า
///
/// ข้อมูลเป็นเคสสมมติชุดเดียวที่สอดคล้องกันทุกแท็บ (ผู้ป่วย Sepsis)
/// เพื่อให้เห็นว่าข้อความจริงยาวแค่ไหนและกินที่เท่าไร
/// จุดตัดความกว้างใช้ค่าเดียวกับหน้าจริง จะได้ทดสอบ responsive แล้วผลตรงกัน
class PatientInfoERWireframeWidget extends StatefulWidget {
  const PatientInfoERWireframeWidget({super.key});

  static String routeName = 'Patient_Info_ER_Wireframe';
  static String routePath = 'patientInfoERWire';

  @override
  State<PatientInfoERWireframeWidget> createState() =>
      _PatientInfoERWireframeWidgetState();
}

/// หนึ่งหมวดในเนื้อหาแท็บ
class _Sec {
  final String title;

  /// คู่ [ป้ายกำกับ, ค่า] — จัดเป็นกริดหลายคอลัมน์อัตโนมัติ
  final List<List<String>> fields;

  /// ข้อความยาว เช่น HPI หรือบันทึกแพทย์
  final String? text;

  /// ตาราง: หัวคอลัมน์ + แถว
  final List<String>? cols;
  final List<List<String>>? rows;

  /// ค่าที่ควรกินเต็มความกว้าง แม้อยู่ในกริด
  final Set<int> wide;

  /// แสดงแผนที่ร่างกายให้แตะเลือกตำแหน่งที่ตรวจ
  final bool bodyMap;

  const _Sec(
    this.title, {
    this.fields = const [],
    this.text,
    this.cols,
    this.rows,
    this.wide = const {},
    this.bodyMap = false,
  });
}

class _PatientInfoERWireframeWidgetState
    extends State<PatientInfoERWireframeWidget> {
  // จุดตัดเดียวกับ PatientInfoERWidget
  static const double splitMinWidth = 1000.0;
  static const double railWidth = 288.0;
  static const double timelineMinWidth = 1000.0;
  static const double timelineWithCompareMinWidth = 1400.0;

  static const List<String> tabNames = [
    'ข้อมูลผู้ป่วย',
    'EMR',
    'คัดกรอง',
    'ตรวจร่างกาย',
    'กิจกรรมพยาบาล',
    'อุบัติเหตุ',
    'สังเกตอาการ',
    'หัตถการ',
    'Lab/X-Ray',
    'การวินิจฉัย',
    'ยา/ค่าบริการ',
    'นัดหมาย',
    'ใบรับรองแพทย์',
    'สรุปการรักษา',
  ];

  // เฉดเทาของ wireframe — ไม่มีสีแบรนด์ ไม่มีสีสถานะ
  static const Color ink = Color(0xFF1F2328);
  static const Color ink2 = Color(0xFF5A6472);
  static const Color ink3 = Color(0xFF98A1B0);
  static const Color line = Color(0xFFD9DDE4);
  static const Color fill = Color(0xFFEDEFF3);
  static const Color paper = Color(0xFFF6F7F9);

  // ---------------------------------------------------------------------------
  // เคสสมมติ — ผู้ป่วย Sepsis รับไว้ 10:22 น. ใช้ชุดเดียวกันทุกแท็บ
  // ---------------------------------------------------------------------------
  static const String ptName = 'นายสมชาย ใจดี';
  static const String ptSub = 'อายุ 58 ปี · ชาย · กรุ๊ปเลือด O';
  static const List<String> ptChips = [
    'คิว 6',
    'HN 009012777',
    'Sepsis',
    'Urgent (ESI 3)',
  ];

  static const List<List<String>> allergy = [
    ['Penicillin', 'ผื่นลมพิษ, หายใจลำบาก'],
    ['Sulfa', 'ผื่นแดงทั้งตัว'],
  ];

  /// [ชื่อค่า, ค่าที่วัดได้, ช่วงปกติ, ทิศทาง]
  static const List<List<String>> abnormalVital = [
    ['อุณหภูมิ', '38.9 °C', '36.5–37.5', 'high'],
    ['ความดัน', '92/58', '90/60–140/90', 'low'],
    ['ชีพจร', '118 /นาที', '60–100', 'high'],
    ['การหายใจ', '24 /นาที', '12–20', 'high'],
    ['SpO₂', '93 %', '95–100', 'low'],
  ];

  static const List<List<String>> abnormalLab = [
    ['Lactate', '3.4 mmol/L', '0.5–2.2', 'high'],
    ['WBC', '16,800 /µL', '4,000–11,000', 'high'],
    ['Creatinine', '1.68 mg/dL', '0.67–1.17', 'high'],
    ['Platelet', '98,000 /µL', '150,000–450,000', 'low'],
  ];

  /// [เวลา, หัวข้อ, สถานะ] — รอบตรวจซ้ำของ ESI 3 คือทุก 30 นาที
  static const List<List<String>> recheck = [
    ['10:22', 'คัดกรองแรกรับ', 'done'],
    ['10:52', 'ตรวจซ้ำรอบที่ 1', 'done'],
    ['11:22', 'ตรวจซ้ำรอบที่ 2', 'done'],
    ['11:52', 'ตรวจซ้ำรอบที่ 3', 'due'],
    ['12:22', 'ตรวจซ้ำรอบที่ 4', 'next'],
  ];

  static const List<List<String>> activities = [
    ['11:25', 'บันทึกอาการ — ผู้ป่วยรู้สึกตัวดีขึ้น ตอบคำถามตรง'],
    ['11:20', 'ให้สารน้ำครบขนาด NSS 1,000 mL'],
    ['10:55', 'ให้ยาปฏิชีวนะครบขนาด สังเกตอาการแพ้ 15 นาที ไม่พบผื่น'],
    ['10:43', 'ส่งเลือดเข้าห้องปฏิบัติการ'],
    ['10:35', 'เปิดเส้นให้สารน้ำที่แขนซ้าย เข็มเบอร์ 20'],
  ];

  static const Map<int, List<_Sec>> tabContent = {
    1: [
      _Sec('ข้อมูลทะเบียน', fields: [
        ['HN', '009012777'],
        ['วัน เดือน ปีเกิด', '14 มี.ค. 2511'],
        ['เลขบัตรประชาชน', 'x-xxxx-xxxxx-45-2'],
        ['หมู่เลือด', 'O'],
        ['เบอร์โทรศัพท์', 'xxx-xxx-7841'],
        ['ผู้ติดต่อฉุกเฉิน', 'นางมาลี ใจดี (ภรรยา)'],
      ]),
      _Sec('ประวัติสุขภาพ', wide: {
        3
      }, fields: [
        ['โรคประจำตัว', 'เบาหวานชนิดที่ 2, ความดันโลหิตสูง'],
        ['โรคเรื้อรัง', 'ไตเรื้อรังระยะที่ 2'],
        ['ประวัติผ่าตัด', 'ผ่าตัดไส้ติ่ง พ.ศ. 2562'],
        [
          'แพ้ยา',
          'Penicillin — ผื่นลมพิษ, หายใจลำบาก · Sulfa — ผื่นแดงทั้งตัว'
        ],
      ]),
      _Sec('สิทธิการรักษา', fields: [
        ['สิทธิ', '34 ประกันสังคม'],
        ['สถานพยาบาลหลัก', 'โรงพยาบาลทดสอบ'],
        ['วันเริ่มใช้สิทธิ', '1 ต.ค. 2568'],
        ['สถานะการเงิน', 'ค่าใช้จ่ายเกิดขึ้นแล้ว'],
      ]),
    ],
    2: [
      _Sec('ประวัติการมารับบริการ', cols: [
        'วันที่',
        'แผนก',
        'อาการสำคัญ',
        'ผลวินิจฉัย'
      ], rows: [
        ['16 ก.ย. 2569', 'ฉุกเฉิน', 'ไข้สูง หนาวสั่น 2 วัน', 'กำลังรักษา'],
        ['3 ส.ค. 2569', 'อายุรกรรม', 'ตรวจตามนัดเบาหวาน', 'E11.9'],
        ['12 พ.ค. 2569', 'อายุรกรรม', 'ความดันสูง ปวดศีรษะ', 'I10'],
        ['28 ก.พ. 2569', 'ฉุกเฉิน', 'ท้องเสีย อ่อนเพลีย', 'A09'],
        ['9 ธ.ค. 2568', 'ศัลยกรรม', 'แผลที่เท้าขวา', 'L03.1'],
      ]),
      _Sec('รายละเอียดการมาครั้งนี้', fields: [
        ['VN', '690916001842'],
        ['วัน-เวลารับบริการ', '16 ก.ย. 2569 10:22 น.'],
        ['ผู้ส่งตรวจ', 'พยาบาล ศิริพร มั่นคง'],
        ['แผนก', 'ห้องฉุกเฉิน'],
      ]),
    ],
    3: [
      _Sec('คัดกรองอาการผู้ป่วย', fields: [
        ['วัน-เวลาเข้าห้องฉุกเฉิน', '16 ก.ย. 2569 10:22 น.'],
        ['เวร', 'เวรเช้า'],
        ['สภาพผู้ป่วย', 'นั่งรถเข็น'],
        ['ประเภทการมา', 'ญาตินำส่ง'],
        ['ประเภทผู้ป่วย', 'ผู้ป่วย Sepsis'],
        ['ความเร่งด่วน', 'Level 3 — Urgent'],
        ['จุดบริการปัจจุบัน', '256 จุดซักประวัติ'],
        ['ผู้คัดกรอง', 'พยาบาล ศิริพร มั่นคง'],
      ]),
      _Sec('อาการสำคัญ',
          text: 'ไข้สูง หนาวสั่น 2 วันก่อนมาโรงพยาบาล ปัสสาวะแสบขัด '
              'กินได้น้อย อ่อนเพลียมากขึ้น ญาติสังเกตว่าซึมลงตั้งแต่เช้าวันนี้'),
      _Sec('สัญญาณชีพแรกรับ', fields: [
        ['น้ำหนัก', '68.0 kg'],
        ['ส่วนสูง', '170.0 cm'],
        ['BMI', '23.5'],
        ['อุณหภูมิ', '38.9 °C'],
        ['ความดันโลหิต', '92/58 mmHg'],
        ['ชีพจร', '118 ครั้ง/นาที'],
        ['อัตราการหายใจ', '24 ครั้ง/นาที'],
        ['ออกซิเจนในเลือด', '93 %'],
      ]),
      _Sec('ระดับความรู้สึกตัวและความปวด', wide: {
        5
      }, fields: [
        ['การลืมตา (E)', '4 — ลืมตาได้เอง'],
        ['การตอบสนองการพูด (V)', '4 — สับสน'],
        ['การเคลื่อนไหว (M)', '6 — ทำตามสั่งได้'],
        ['GCS รวม', '14 คะแนน'],
        ['ระดับความเจ็บปวด', '6 / 10'],
        ['รูม่านตา', 'ซ้าย 3 มม. / ขวา 3 มม. ตอบสนองดีทั้งสองข้าง'],
      ]),
    ],
    4: [
      _Sec('แนวโน้มสัญญาณชีพ', cols: [
        'เวลา',
        'อุณหภูมิ',
        'ความดัน',
        'ชีพจร',
        'หายใจ',
        'SpO₂'
      ], rows: [
        ['10:22', '38.9 °C', '92/58', '118', '24', '93 %'],
        ['10:52', '38.6 °C', '96/60', '112', '22', '94 %'],
        ['11:22', '38.1 °C', '104/64', '104', '20', '96 %'],
      ]),
      _Sec('ประวัติการเจ็บป่วยปัจจุบัน (HPI)',
          text: 'ผู้ป่วยชายไทยอายุ 58 ปี มีไข้สูงหนาวสั่น 2 วันก่อนมาโรงพยาบาล '
              'ร่วมกับปัสสาวะแสบขัดและปัสสาวะบ่อย กินอาหารได้น้อยลง '
              'วันนี้ญาติสังเกตว่าซึมลงและพูดสับสนเป็นบางครั้ง จึงนำส่งโรงพยาบาล '
              'ปฏิเสธอาการเจ็บหน้าอก หอบเหนื่อย หรือถ่ายเหลว'),
      _Sec('ตำแหน่งที่ตรวจพบความผิดปกติ', bodyMap: true),
    ],
    5: [
      _Sec('คำสั่งที่ต้องปฏิบัติ', cols: [
        'เวลา',
        'รายการ',
        'ผู้ปฏิบัติ',
        'สถานะ'
      ], rows: [
        ['10:35', 'เปิดเส้นให้สารน้ำ NSS 1,000 mL', 'ศิริพร', 'ดำเนินการแล้ว'],
        [
          '10:38',
          'เจาะ Lactate, CBC, Blood culture',
          'ศิริพร',
          'ดำเนินการแล้ว'
        ],
        [
          '10:52',
          'ให้ Piperacillin/Tazobactam 4.5 g',
          'ศิริพร',
          'ดำเนินการแล้ว'
        ],
        [
          '11:05',
          'ติด Monitor วัดสัญญาณชีพต่อเนื่อง',
          'ศิริพร',
          'ดำเนินการแล้ว'
        ],
        ['11:52', 'ประเมินซ้ำและบันทึกสัญญาณชีพ', '—', 'รอปฏิบัติ'],
      ]),
      _Sec('บันทึกกิจกรรมพยาบาล', cols: [
        'เวลา',
        'บันทึก'
      ], rows: [
        ['10:35', 'เปิดเส้นเลือดดำแขนซ้าย เข็มเบอร์ 20 สำเร็จครั้งแรก'],
        ['10:40', 'เจาะเลือดส่งตรวจครบตามคำสั่ง ส่งห้องแล็บ 10:43 น.'],
        ['10:55', 'ให้ยาปฏิชีวนะครบขนาด สังเกตอาการแพ้ 15 นาที ไม่พบผื่น'],
        ['11:25', 'ผู้ป่วยรู้สึกตัวดีขึ้น ตอบคำถามได้ตรงคำถาม'],
      ]),
    ],
    6: [
      _Sec('ข้อมูลอุบัติเหตุ', wide: {
        1
      }, fields: [
        ['สถานะ', 'ไม่ใช่เคสอุบัติเหตุ'],
        ['หมายเหตุ', 'ผู้ป่วยมาด้วยอาการติดเชื้อ ไม่มีประวัติบาดเจ็บ'],
      ]),
    ],
    7: [
      _Sec('การสังเกตอาการ', fields: [
        ['วัน-เวลาเริ่ม', '16 ก.ย. 2569 11:30 น.'],
        ['สถานที่', 'เตียงสังเกตอาการ ER-04'],
        ['ผู้สั่ง', 'นพ. ธนภัทร วงศ์สุวรรณ'],
        ['สถานะปัจจุบัน', 'รอผลเพาะเชื้อ พิจารณา Admit'],
      ]),
      _Sec('รอบการบันทึกอาการ', cols: [
        'เวลา',
        'ความรู้สึกตัว',
        'ปัสสาวะ',
        'ผู้บันทึก'
      ], rows: [
        ['10:52', 'สับสนเป็นบางครั้ง', '—', 'ศิริพร'],
        ['11:22', 'รู้สึกตัวดีขึ้น', '150 mL', 'ศิริพร'],
        ['11:52', 'รอบันทึก', 'รอบันทึก', '—'],
      ]),
      _Sec('วินิจฉัยทางการพยาบาล', cols: [
        'ลำดับ',
        'ข้อวินิจฉัย'
      ], rows: [
        ['1', 'เสี่ยงต่อภาวะช็อกจากการติดเชื้อในกระแสเลือด'],
        ['2', 'อุณหภูมิร่างกายสูงกว่าปกติจากกระบวนการติดเชื้อ'],
      ]),
    ],
    8: [
      _Sec('รายการหัตถการ', cols: [
        'เวลา',
        'รายการ',
        'ผู้ทำ',
        'สถานะ'
      ], rows: [
        ['10:35', 'เปิดหลอดเลือดดำส่วนปลาย', 'ศิริพร', 'เสร็จสิ้น'],
        ['10:40', 'เจาะเลือดส่งเพาะเชื้อ 2 ตำแหน่ง', 'ศิริพร', 'เสร็จสิ้น'],
        ['11:05', 'ติดเครื่องติดตามสัญญาณชีพ', 'ศิริพร', 'เสร็จสิ้น'],
        ['11:10', 'ใส่สายสวนปัสสาวะเพื่อวัดปริมาณ', 'ศิริพร', 'เสร็จสิ้น'],
      ]),
    ],
    9: [
      _Sec('ผลแล็บ', cols: [
        'รายการ',
        'ผลที่รายงาน',
        'ช่วงปกติ',
        'สถานะ'
      ], rows: [
        ['Lactate', '3.4 mmol/L', '0.5–2.2', 'สูงกว่าเกณฑ์'],
        ['WBC', '16,800 /µL', '4,000–11,000', 'สูงกว่าเกณฑ์'],
        ['Neutrophil', '88 %', '40–75', 'สูงกว่าเกณฑ์'],
        ['Creatinine', '1.68 mg/dL', '0.67–1.17', 'สูงกว่าเกณฑ์'],
        ['Platelet', '98,000 /µL', '150,000–450,000', 'ต่ำกว่าเกณฑ์'],
        ['Sodium', '138 mmol/L', '136–145', 'ปกติ'],
        ['Potassium', '4.1 mmol/L', '3.4–4.5', 'ปกติ'],
        ['Blood culture', 'รอผล 48 ชม.', '—', 'รอผล'],
      ]),
      _Sec('ผลเอกซเรย์', cols: [
        'รายการ',
        'เวลาสั่ง',
        'สถานะ'
      ], rows: [
        ['Chest X-ray (PA upright)', '10:38', 'อ่านผลแล้ว — ไม่พบรอยโรค'],
        ['Ultrasound KUB', '11:15', 'รอฉายภาพ'],
      ]),
    ],
    10: [
      _Sec('ผลการวินิจฉัย', fields: [
        ['ผู้วินิจฉัย', 'นพ. ธนภัทร วงศ์สุวรรณ'],
        ['วัน-เวลา', '16 ก.ย. 2569 11:10 น.'],
        ['ประเภทการวินิจฉัย', 'วินิจฉัยแรกรับ'],
      ]),
      _Sec('รหัสวินิจฉัย', cols: [
        'ประเภท',
        'รหัส',
        'คำอธิบาย'
      ], rows: [
        ['ICD-10 หลัก', 'A41.9', 'Sepsis, unspecified organism'],
        ['ICD-10 รอง', 'N39.0', 'Urinary tract infection, site not specified'],
        [
          'ICD-10 รอง',
          'E11.9',
          'Type 2 diabetes mellitus without complications'
        ],
        [
          'ICD-9-CM',
          '38.93',
          'Venous catheterization, not elsewhere classified'
        ],
      ]),
      _Sec('บันทึกแพทย์',
          text: 'สงสัยภาวะติดเชื้อในกระแสเลือดจากทางเดินปัสสาวะ '
              'ให้สารน้ำและยาปฏิชีวนะตามแนวทาง Sepsis bundle ภายในชั่วโมงแรก '
              'ติดตามสัญญาณชีพทุก 30 นาที หากความดันยังต่ำหลังให้สารน้ำครบ '
              'พิจารณาให้ยากระตุ้นความดันและรับไว้ในหอผู้ป่วย'),
    ],
    11: [
      _Sec('รายการแพ้ยา', cols: [
        'ชื่อยา',
        'อาการ',
        'วันที่บันทึก'
      ], rows: [
        ['Penicillin', 'ผื่นลมพิษ (Urticaria), หายใจลำบาก', '12 พ.ค. 2569'],
        ['Sulfa', 'ผื่นแดงทั้งตัว', '28 ก.พ. 2569'],
      ]),
      _Sec('รายการสั่งยา', cols: [
        'รายการ',
        'วิธีใช้',
        'จำนวน',
        'สถานะ'
      ], rows: [
        [
          'Piperacillin/Tazobactam 4.5 g',
          'IV ทุก 6 ชั่วโมง',
          '4 vial',
          'จ่ายยาแล้ว'
        ],
        ['NSS 1,000 mL', 'IV load ใน 30 นาที', '2 ถุง', 'จ่ายยาแล้ว'],
        [
          'Paracetamol 500 mg',
          'รับประทานทุก 6 ชม. เมื่อมีไข้',
          '10 เม็ด',
          'จ่ายยาแล้ว'
        ],
        [
          'Norepinephrine 4 mg',
          'หยดทางหลอดเลือดดำ ปรับตามความดัน',
          '1 amp',
          'รอรับคำสั่ง'
        ],
      ]),
      _Sec('ค่ารักษาพยาบาล', cols: [
        'หมวด',
        'จำนวนเงิน'
      ], rows: [
        ['ค่ายาและเวชภัณฑ์', '2,480 บาท'],
        ['ค่าตรวจทางห้องปฏิบัติการ', '1,950 บาท'],
        ['ค่าเอกซเรย์', '850 บาท'],
        ['ค่าบริการทางการแพทย์', '600 บาท'],
        ['รวมทั้งสิ้น', '5,880 บาท'],
      ]),
    ],
    12: [
      _Sec('การนัดหมาย', wide: {
        1
      }, fields: [
        ['สถานะ', 'ยังไม่มีการนัดหมาย'],
        ['หมายเหตุ', 'รอผลเพาะเชื้อและผลการรับไว้ในหอผู้ป่วยก่อนนัดติดตาม'],
      ]),
    ],
    13: [
      _Sec('ใบรับรองแพทย์', fields: [
        ['สถานะ', 'ยังไม่ออกใบรับรองแพทย์'],
        ['ผู้มีสิทธิออก', 'นพ. ธนภัทร วงศ์สุวรรณ'],
      ]),
    ],
    14: [
      _Sec('สรุปการรักษา Fast Track — Sepsis', fields: [
        ['โรงพยาบาล', 'โรงพยาบาลทดสอบ'],
        ['HN', '009012777'],
        ['ประเภท', 'ผู้ป่วย Sepsis'],
        ['แพทย์ผู้รักษา', 'นพ. ธนภัทร วงศ์สุวรรณ'],
      ]),
      _Sec('ไทม์ไลน์ตามมาตรฐาน Sepsis 1 ชั่วโมง', cols: [
        'ขั้นตอน',
        'เวลา',
        'นับจากแรกรับ',
        'เกณฑ์'
      ], rows: [
        ['คัดกรองแรกรับ', '10:22', '0 นาที', '—'],
        ['เจาะ Lactate', '10:40', '18 นาที', 'ภายใน 60 นาที'],
        ['เจาะ Blood culture', '10:40', '18 นาที', 'ก่อนให้ยาปฏิชีวนะ'],
        ['ให้ยาปฏิชีวนะ', '10:52', '30 นาที', 'ภายใน 60 นาที'],
        ['ให้สารน้ำครบขนาด', '11:20', '58 นาที', 'ภายใน 180 นาที'],
        ['ประเมินซ้ำหลังให้สารน้ำ', '11:52', 'รอบันทึก', 'ทุก 30 นาที'],
      ]),
      _Sec('สถานะออกจากห้องฉุกเฉิน', fields: [
        ['แผนการรักษา', 'รับไว้ในหอผู้ป่วยอายุรกรรม'],
        ['เวลาออกจากห้องฉุกเฉิน', 'รอยืนยัน'],
      ]),
    ],
  };

  int _tab = 3;
  int? _compare;

  final ScrollController _railScroll = ScrollController();
  final ScrollController _leftScroll = ScrollController();
  final ScrollController _rightScroll = ScrollController();
  final ScrollController _timelineScroll = ScrollController();

  @override
  void dispose() {
    _railScroll.dispose();
    _leftScroll.dispose();
    _rightScroll.dispose();
    _timelineScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // ชิ้นส่วนพื้นฐาน
  // ---------------------------------------------------------------------------

  /// ฟอนต์ของหน้า wireframe — Sarabun ทั้งหน้า
  static TextStyle _font(
          {double size = 12.0,
          Color color = ink2,
          FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.sarabun(
          fontSize: size, color: color, fontWeight: weight, height: 1.35);

  Widget _label(String text,
          {double size = 12.0,
          Color color = ink2,
          FontWeight weight = FontWeight.w400,
          int? maxLines}) =>
      Text(text,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
          style: _font(size: size, color: color, weight: weight));

  /// หัวข้อหมวด — ข้อความอย่างเดียว ไม่มีไอคอนนำหน้า
  Widget _sectionHeading(String title) => Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: _label(title, size: 12.5, weight: FontWeight.w600, color: ink),
      );

  Widget _card(List<Widget> children) => Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: line),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  /// คู่ป้ายกำกับ–ค่า วางบรรทัดเดียวกัน ป้ายนำหน้าค่า
  /// วางแบบนี้เพื่อไม่ให้ทุกช่องกินความสูง 2 บรรทัดเท่ากันหมด
  /// แม้ค่าจะสั้นแค่ไม่กี่ตัวอักษร
  Widget _field(String label, String value) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          _label(label, size: 11.0, color: ink3),
          SizedBox(width: 5.0),
          Flexible(
            child:
                _label(value, size: 12.5, color: ink, weight: FontWeight.w500),
          ),
        ],
      );

  /// คู่ป้ายกำกับ–ค่าหลายชุด ไหลต่อกันตามความกว้างจริงของเนื้อหา
  /// ไม่ล็อกความกว้างช่องเท่ากัน เพราะ "เวรเช้า" ไม่ควรกินที่เท่า
  /// "16 ก.ย. 2569 10:22 น." แล้วเหลือที่ว่างด้านขวา
  Widget _fieldGrid(List<List<String>> fields, Set<int> wide) =>
      LayoutBuilder(builder: (context, box) {
        return Wrap(
          spacing: 20.0,
          runSpacing: 7.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (int i = 0; i < fields.length; i++)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: box.maxWidth,
                  minWidth: wide.contains(i) ? box.maxWidth : 0.0,
                ),
                child: _field(fields[i][0], fields[i][1]),
              ),
          ],
        );
      });

  /// แถวค่าผิดปกติ — ลูกศรและคำกำกับ ไม่ใช้สีบอกอย่างเดียว
  Widget _abnormalRow(List<String> v, {bool last = false}) {
    final isHigh = v[3] == 'high';
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: line)),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _label(v[0], size: 12.0, color: ink, weight: FontWeight.w500),
                _label('ปกติ ${v[2]}', size: 10.0, color: ink3),
              ],
            ),
          ),
          SizedBox(width: 6.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      isHigh
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 13.0,
                      color: ink),
                  SizedBox(width: 1.0),
                  _label(v[1], size: 12.5, color: ink, weight: FontWeight.w600),
                ],
              ),
              _label(isHigh ? 'สูงกว่าเกณฑ์' : 'ต่ำกว่าเกณฑ์',
                  size: 10.0, color: ink3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timelineRow(List<String> r, {bool last = false}) {
    final status = r[2];
    final label = status == 'due'
        ? 'ถึงรอบแล้ว'
        : status == 'next'
            ? 'รอบถัดไป'
            : 'บันทึกแล้ว';
    final icon = status == 'due'
        ? Icons.notifications_active_rounded
        : status == 'next'
            ? Icons.schedule_rounded
            : Icons.check_circle_rounded;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0.0 : 9.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 9.0,
            height: 9.0,
            decoration: BoxDecoration(
              color: status == 'next' ? Colors.white : ink3,
              shape: BoxShape.circle,
              border:
                  Border.all(color: status == 'next' ? line : ink3, width: 1.5),
            ),
          ),
          SizedBox(width: 8.0),
          _label(r[0], size: 11.0, color: ink2, weight: FontWeight.w600),
          SizedBox(width: 8.0),
          Expanded(
            child: _label(r[1], size: 12.0, color: ink, maxLines: 1),
          ),
          SizedBox(width: 4.0),
          Icon(icon, size: 13.0, color: ink2),
          SizedBox(width: 3.0),
          _label(label, size: 10.0, color: ink2),
        ],
      ),
    );
  }

  /// ตาราง — คอลัมน์แรกแคบ คอลัมน์ข้อความยืดเต็มที่เหลือ
  Widget _table(List<String> cols, List<List<String>> rows) {
    TableRow build(List<String> cells, {required bool head}) => TableRow(
          decoration: BoxDecoration(
            color: head ? fill : null,
            border: head ? null : Border(top: BorderSide(color: line)),
          ),
          children: [
            for (int i = 0; i < cells.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: Align(
                  alignment: i > 0 && i == cells.length - 1 && cells.length > 2
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: _label(cells[i],
                      size: head ? 10.5 : 12.0,
                      color: head ? ink2 : ink,
                      weight: head ? FontWeight.w600 : FontWeight.w400),
                ),
              ),
          ],
        );

    // คอลัมน์ที่เป็นข้อความยาวให้กินที่มากกว่า คอลัมน์เวลา/รหัสให้แคบ
    final widths = <int, TableColumnWidth>{};
    for (int i = 0; i < cols.length; i++) {
      final c = cols[i];
      final narrow = c == 'เวลา' ||
          c == 'ลำดับ' ||
          c == 'วันที่' ||
          c == 'รหัส' ||
          c == 'ระบบ' ||
          c == 'จำนวน';
      widths[i] = FlexColumnWidth(narrow ? 0.6 : 1.0);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(6.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: widths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          build(cols, head: true),
          for (final r in rows) build(r, head: false),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // แผงประกอบหน้าจอ
  // ---------------------------------------------------------------------------

  Widget _profileRail({required bool withTimeline}) => Container(
        width: railWidth,
        decoration: BoxDecoration(
          color: paper,
          border: Border(right: BorderSide(color: line)),
        ),
        child: ListView(
          controller: _railScroll,
          primary: false,
          padding: EdgeInsets.all(12.0),
          children: [
            _card([
              Row(
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: fill,
                      shape: BoxShape.circle,
                      border: Border.all(color: line),
                    ),
                    child: Icon(Icons.person_rounded, size: 21.0, color: ink3),
                  ),
                  SizedBox(width: 9.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _label(ptName,
                            size: 13.5, color: ink, weight: FontWeight.w600),
                        _label(ptSub, size: 10.5, color: ink3),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final c in ptChips)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: _label(c, size: 10.5, color: ink2),
                    ),
                ],
              ),
            ]),
            _sectionHeading('แพ้ยา'),
            _card([
              for (int i = 0; i < allergy.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: i == allergy.length - 1 ? 0.0 : 7.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14.0, color: ink),
                      SizedBox(width: 6.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _label(allergy[i][0],
                                size: 12.5,
                                color: ink,
                                weight: FontWeight.w600),
                            _label(allergy[i][1], size: 10.5, color: ink3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ]),
            _sectionHeading('สัญญาณชีพที่ผิดปกติ'),
            _card([
              for (int i = 0; i < abnormalVital.length; i++)
                _abnormalRow(abnormalVital[i],
                    last: i == abnormalVital.length - 1),
            ]),
            _sectionHeading('ผลแล็บที่ผิดปกติ'),
            _card([
              for (int i = 0; i < abnormalLab.length; i++)
                _abnormalRow(abnormalLab[i], last: i == abnormalLab.length - 1),
            ]),
            if (withTimeline) ...[
              _sectionHeading('ไทม์ไลน์การตรวจซ้ำ'),
              _card([
                for (int i = 0; i < recheck.length; i++)
                  _timelineRow(recheck[i], last: i == recheck.length - 1),
              ]),
            ],
          ],
        ),
      );

  Widget _timelineRail() => Container(
        width: railWidth,
        decoration: BoxDecoration(
          color: paper,
          border: Border(left: BorderSide(color: line)),
        ),
        child: ListView(
          controller: _timelineScroll,
          primary: false,
          padding: EdgeInsets.all(12.0),
          children: [
            _sectionHeading('ไทม์ไลน์การตรวจซ้ำ'),
            _card([
              _label('ระดับ Urgent — ตรวจซ้ำทุก 30 นาที',
                  size: 10.5, color: ink3),
              SizedBox(height: 8.0),
              for (int i = 0; i < recheck.length; i++)
                _timelineRow(recheck[i], last: i == recheck.length - 1),
            ]),
            _sectionHeading('กิจกรรมล่าสุด'),
            _card([
              for (int i = 0; i < activities.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: i == activities.length - 1 ? 0.0 : 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(activities[i][0],
                          size: 10.5, color: ink2, weight: FontWeight.w600),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: _label(activities[i][1], size: 11.5, color: ink),
                      ),
                    ],
                  ),
                ),
            ]),
          ],
        ),
      );

  Widget _paneHeader(int tab, {required bool closable}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: line)),
        ),
        padding: EdgeInsets.fromLTRB(12.0, 4.0, 4.0, 4.0),
        child: Row(
          children: [
            Expanded(
              child: _label(tabNames[tab - 1],
                  size: 12.5, color: ink, weight: FontWeight.w600, maxLines: 1),
            ),
            if (!closable && _compare == null)
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  minimumSize: Size(0, 30.0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  final picked = await showDialog<int>(
                    context: context,
                    builder: (_) => SimpleDialog(
                      title: Text('เทียบกับหน้าจอ',
                          style: _font(
                              size: 14.0, color: ink, weight: FontWeight.w600)),
                      children: [
                        for (int t = 1; t <= tabNames.length; t++)
                          if (t != _tab)
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, t),
                              child: Text(tabNames[t - 1],
                                  style: _font(size: 13.0, color: ink)),
                            ),
                      ],
                    ),
                  );
                  if (picked != null) setState(() => _compare = picked);
                },
                icon:
                    Icon(Icons.vertical_split_rounded, size: 15.0, color: ink2),
                label: _label('เทียบ', size: 11.5),
              ),
            if (closable)
              IconButton(
                tooltip: 'ปิดการเทียบ',
                iconSize: 16.0,
                padding: EdgeInsets.all(6.0),
                constraints: BoxConstraints(),
                icon: Icon(Icons.close_rounded, color: ink2),
                onPressed: () => setState(() => _compare = null),
              ),
          ],
        ),
      );

  // ---- แผนที่ร่างกาย ----
  ErBodyView _bodyView = ErBodyView.front;
  String? _bodyPicked;

  /// ผลตรวจจำลองของเคส sepsis: กดเจ็บท้อง เคาะเจ็บบั้นเอว ปลายมือเท้าอุ่นช้า
  static const Map<String, ErBodyFinding> _bodyFindings = {
    'head': ErBodyFinding.normal,
    'neck': ErBodyFinding.normal,
    'chestFront': ErBodyFinding.normal,
    'chestBack': ErBodyFinding.abnormal,
    'abdomen': ErBodyFinding.abnormal,
    'handRight': ErBodyFinding.abnormal,
    'handLeft': ErBodyFinding.abnormal,
    'footRight': ErBodyFinding.abnormal,
    'footLeft': ErBodyFinding.abnormal,
  };

  /// ผลตรวจรายระบบของเคสจำลอง คีย์ตรงกับ ErExamSystem.stateKey
  static const Map<String, String> _examBySystem = {
    'GA': 'ผู้ป่วยซึม ตอบสนองช้า ผิวหนังอุ่นและชื้น',
    'Constitutional': 'อ่อนเพลียมาก น้ำหนักลด 2 กก. ใน 2 สัปดาห์',
    'HEENT': 'ไม่ซีด ไม่เหลือง ต่อมน้ำเหลืองไม่โต',
    'Eyes': 'รูม่านตา 3 มม. เท่ากัน ตอบสนองต่อแสงดี',
    'ENTMounth': 'เยื่อบุช่องปากแห้ง ไม่มีแผล ต่อมทอนซิลไม่โต',
    'Chest': 'เสียงหายใจเท่ากันสองข้าง ไม่มี crepitation เคาะเจ็บบั้นเอวขวา',
    'Heart': 'เสียงหัวใจเร็วสม่ำเสมอ ไม่มี murmur',
    'Abdomen': 'นิ่ม กดเจ็บเหนือหัวหน่าว ไม่มี guarding',
    'Genitalia': 'ไม่ได้ตรวจ',
    'PR': 'ไม่ได้ตรวจ',
    'PV': 'ไม่ได้ตรวจ',
    'Extremities': 'ปลายมือปลายเท้าอุ่น capillary refill 3 วินาที',
    'Neurological': 'รู้สึกตัวแต่สับสนเป็นบางครั้ง ไม่มีอ่อนแรงเฉพาะที่',
  };

  Widget _miniButton(String label, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(100.0),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: _label(label, size: 11.5, color: ink2),
        ),
      );

  Widget _bodyLegendDot(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9.0,
            height: 9.0,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.0),
          _label(label, size: 11.5, color: ink2),
        ],
      );

  Widget _bodyMapBlock() {
    final picked = _bodyPicked == null ? null : erBodyRegionById(_bodyPicked!);
    final finding = _bodyPicked == null
        ? null
        : (_bodyFindings[_bodyPicked!] ?? ErBodyFinding.pending);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150.0,
          child: Column(
            children: [
              ErBodyViewToggle(
                view: _bodyView,
                onChanged: (v) => setState(() => _bodyView = v),
              ),
              SizedBox(height: 8.0),
              ErBodyMap(
                view: _bodyView,
                findings: _bodyFindings,
                selectedRegionId: _bodyPicked,
                onRegionTap: (r) => setState(() => _bodyPicked = r.id),
              ),
              SizedBox(height: 6.0),
              // สัญญาอนุญาต CC BY 4.0 กำหนดให้ต้องแสดงที่มาของภาพ
              _label(
                'ภาพร่างกาย: BodyParts3D © The Database Center for Life Science '
                '(CC BY 4.0)',
                size: 9.5,
                color: ink3,
              ),
            ],
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _label(
                      picked == null
                          ? 'ผลตรวจร่างกายรายระบบ — แตะบริเวณบนภาพเพื่อกรองเฉพาะระบบของส่วนนั้น'
                          : '${picked.th} · ${picked.fmaId} · '
                              '${finding == ErBodyFinding.abnormal ? 'พบความผิดปกติ' : finding == ErBodyFinding.normal ? 'ตรวจแล้วปกติ' : 'ยังไม่ได้ตรวจ'}',
                      size: 12.5,
                      color: ink,
                      weight: FontWeight.w600,
                    ),
                  ),
                  if (picked != null)
                    _miniButton(
                        'ดูทุกระบบ', () => setState(() => _bodyPicked = null)),
                ],
              ),
              SizedBox(height: 6.0),
              Wrap(
                spacing: 14.0,
                runSpacing: 6.0,
                children: [
                  _bodyLegendDot(Color(0xFF37E974), 'ตรวจแล้วปกติ'),
                  _bodyLegendDot(Color(0xFFBE1E2D), 'พบความผิดปกติ'),
                  _bodyLegendDot(line, 'ยังไม่ได้ตรวจ'),
                ],
              ),
              SizedBox(height: 8.0),
              _table(const [
                'ระบบ',
                'ผลการตรวจ'
              ], [
                for (final sys in (picked?.systems ?? ErExamSystem.values))
                  [sys.th, _examBySystem[sys.stateKey] ?? 'ยังไม่ได้บันทึก'],
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBody(int tab) {
    final secs = tabContent[tab] ?? const <_Sec>[];
    return ListView(
      primary: false,
      padding: EdgeInsets.all(12.0),
      children: [
        for (final s in secs) ...[
          _sectionHeading(s.title),
          _card([
            if (s.bodyMap) _bodyMapBlock(),
            if (s.text != null) _label(s.text!, size: 12.5, color: ink),
            if (s.cols != null && s.rows != null) _table(s.cols!, s.rows!),
            if (s.fields.isNotEmpty) _fieldGrid(s.fields, s.wide),
          ]),
        ],
        SizedBox(height: 32.0),
      ],
    );
  }

  Widget _pane(int tab,
          {required bool closable, required ScrollController controller}) =>
      Column(
        children: [
          _paneHeader(tab, closable: closable),
          Expanded(
            child: PrimaryScrollController(
              controller: controller,
              child: _tabBody(tab),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0.0,
        titleSpacing: 16.0,
        toolbarHeight: 46.0,
        shape: Border(bottom: BorderSide(color: line)),
        title: _label('รายละเอียดผู้ป่วยฉุกเฉิน',
            size: 14.0, color: ink, weight: FontWeight.w700),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Container(
            height: 40.0,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: line)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              children: [
                for (int t = 1; t <= tabNames.length; t++)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.5),
                    child: InkWell(
                      onTap: () => setState(() {
                        _tab = t;
                        if (_compare == t) _compare = null;
                      }),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 11.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: t == _tab ? fill : Colors.white,
                          border: Border.all(color: t == _tab ? ink3 : line),
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: _label(tabNames[t - 1],
                            size: 11.5,
                            color: t == _tab ? ink : ink2,
                            weight:
                                t == _tab ? FontWeight.w600 : FontWeight.w400),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          if (box.maxWidth < splitMinWidth) {
            return _pane(_tab, closable: false, controller: _leftScroll);
          }
          final hasCompare = _compare != null && _compare != _tab;
          final showTimeline = box.maxWidth >=
              (hasCompare ? timelineWithCompareMinWidth : timelineMinWidth);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _profileRail(withTimeline: !showTimeline),
              Expanded(
                  child: _pane(_tab, closable: false, controller: _leftScroll)),
              if (hasCompare) ...[
                VerticalDivider(width: 1.0, thickness: 1.0, color: line),
                Expanded(
                    child: _pane(_compare!,
                        closable: true, controller: _rightScroll)),
              ],
              if (showTimeline) _timelineRail(),
            ],
          );
        },
      ),
    );
  }
}
