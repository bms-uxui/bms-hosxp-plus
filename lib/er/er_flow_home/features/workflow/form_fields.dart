// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ตัวเลือกของช่อง: master data (ผูกด้วยชื่อช่อง) → ตัวเลือกในฟอร์ม KB → คำใบ้ "A / B"
/// ช่องในโหมดพูดที่รวมหลายช่องของฟอร์มจริงไว้ด้วยกัน → ตาราง master ของแต่ละช่องย่อย
/// (ชื่อช่องในโหมดพูดไม่ตรงกับ used_by ของ master จึงต้องจับคู่ด้วย id ตาราง)
const Map<String, List<String>> _fieldTables = {
  'GCS (E / V / M)': ['gcs_eye', 'gcs_verbal', 'gcs_motor'],
  'การลืมตา / ตอบสนองการพูด / การเคลื่อนไหว': [
    'gcs_eye',
    'gcs_verbal',
    'gcs_motor'
  ],
  'ยานพาหนะ / ประเภทผู้บาดเจ็บ': [
    'accident_vehicle_type',
    'accident_person_type'
  ],
  'หมวกนิรภัย / เข็มขัดนิรภัย': ['accident_helmet_type', 'accident_belt_type'],
  'แอลกอฮอล์ / สารเสพติด': ['accident_alcohol_type', 'accident_drug_type'],
  'การดูแลก่อนมาถึง': [
    'accident_airway_type',
    'accident_bleed_type',
    'accident_fluid_type',
    'accident_splint_type',
    'accident_cspine_type',
  ],
  'ตึกผู้ป่วยใน / สถานพยาบาลที่ส่งไป': ['er_ipd_ward', 'er_refer_hospital'],
  'รับคำสั่ง ยา/เวชภัณฑ์': ['er_order_receive_action'],
  'รับคำสั่ง Lab': ['er_order_receive_action'],
  'รับคำสั่ง X-ray': ['er_order_receive_action'],
  'รับคำสั่ง หัตถการ': ['er_order_receive_action'],
  'ยืนยันแพทย์ผู้บันทึก': ['er_doctor'],
  'หัตถการที่ทำ': ['er_procedure'],
  'รหัสหัตถการ ICD-9-CM': ['er_icd9cm'],
  'ปฏิกิริยารูม่านตา ซ้าย / ขวา': [
    'er_pupil_reaction|ด้านซ้าย (L)',
    'er_pupil_reaction|ด้านขวา (R)'
  ],
  'สถานที่สังเกตอาการ': ['er_observe_place'],
  'ห้อง / เตียง': ['er_room', 'er_bed'],
  'ห้อง / โซนห้องฉุกเฉิน': ['er_room'],
  'ยืนยันพยาบาลผู้บันทึก': ['er_staff'],
};

/// ช่องวินิจฉัยที่ลงได้หลายรายการ (เก็บในค่าเดียว คั่นด้วยขึ้นบรรทัดใหม่)
const String _dxTextLabel = 'Diagnosis Text';
const String _icd10Label = 'Diagnosis ICD-10';

/// หน้าแรกของขั้นคัดกรอง (แทน "ยืนยันข้อมูลคัดกรอง" เดิม)
const String _erInLabel = 'ข้อมูลรับเข้าห้องฉุกเฉิน';

/// วันที่/เวลาที่ผู้ป่วยออกจากห้องฉุกเฉิน (อยู่หน้าเดียวกับสภาพผู้ป่วยออกจาก ER)
const String _outTimeLabel = 'วันที่/เวลา ออกจากห้อง ER';

/// ส่วนเสริมในหน้าวินิจฉัย (ไม่บังคับ ไม่นับเป็นช่องที่ขาด): ICD-9-CM หลายรหัส + Doctor Note
/// ชื่อตามฟอร์ม HOSxP diagnosis ("Diagnosis ICD-9-CM") · ต่างจาก _icd9Label ของขั้นหัตถการ
const String _icd9DxLabel = 'Diagnosis ICD-9-CM';
const String _noteLabel = 'Doctor Note';

/// Template Doctor Note ของแพทย์ (รหัสแพทย์, ชื่อ, ข้อความ) · ข้อมูลจำลองสำหรับเดโม
const List<(String, String, String)> _noteTemplates = [
  (
    'D001',
    'Head injury สังเกตอาการ',
    'Mild head injury, GCS 15, no LOC, no focal neurological deficit.\n'
        'Plan: observe neuro signs q 1 hr x 6 hr, analgesic PRN.\n'
        'Advise: return if headache worse, vomiting, drowsiness or seizure.'
  ),
  (
    'D001',
    'Sepsis bundle',
    'Suspected sepsis. Hemoculture x2 before antibiotic, lactate sent.\n'
        'IV fluid 30 ml/kg, start empirical antibiotic within 1 hr.\n'
        'Monitor V/S, urine output; reassess after fluid.'
  ),
  (
    'D001',
    'Fracture รอ Ortho',
    'Closed fracture, neurovascular intact distal to injury.\n'
        'Splint applied, pain control, film done.\nConsult orthopedics.'
  ),
  (
    'D002',
    'Chest pain rule out ACS',
    'Chest pain, EKG within 10 min, troponin sent.\n'
        'ASA 300 mg chewed if no contraindication.\nRepeat EKG / troponin as protocol.'
  ),
  (
    'D002',
    'COPD exacerbation',
    'Acute exacerbation of COPD. Nebulized bronchodilator x3, steroid given.\n'
        'Keep SpO2 88-92%. Reassess after treatment.'
  ),
];

/// ช่องเก็บประเภทการวินิจฉัยของแต่ละรหัส ICD-10 (ไม่ใช่ช่องที่ต้องกรอก)
const String _diagTypeKey = 'Diagnosis ICD-10 - diagtype';

/// ประเภทการวินิจฉัย (HOSxP diagtype) ของรหัส ICD-10: (รหัส, ชื่อ, คำอธิบาย)
/// รหัสแรก = 1 Principal เสมอและมีตัวเดียว · a/b/c (Operating) เป็นของหัตถการ ไม่ใช้กับ ICD-10
const List<(String, String, String)> _diagTypes = [
  ('1', 'Principal Diagnosis', 'โรคหลักที่เป็นสาเหตุให้มารับการรักษา'),
  ('2', 'Comorbidity', 'โรคอื่นที่เป็นร่วมด้วย'),
  ('3', 'Complication', 'โรคที่เกิดขึ้นเมื่อเข้านอนในโรงพยาบาลแล้ว'),
  ('4', 'Other', 'สาเหตุภายนอกอื่น ๆ'),
  ('5', 'External Cause', 'สาเหตุภายนอก'),
  ('6', 'Additional code', 'รหัสเสริม'),
  ('7', 'Morphology Code', 'รหัสเกี่ยวกับเนื้องอก'),
];

/// Template วินิจฉัยที่แพทย์สร้างไว้: ชื่อโรค (คำค้น) → Diagnosis Text + รหัส ICD-10
class _DxTemplate {
  const _DxTemplate(this.doctor, this.name, this.text, this.icd10);

  /// รหัสแพทย์เจ้าของ template (ErUser.id)
  final String doctor;
  final String name;
  final String text;

  /// ต้องมีอยู่ใน master er_icd10
  final String icd10;
}

/// ข้อมูลจำลองสำหรับเดโม: template ของแพทย์ในกะ (D001, D002)
const List<_DxTemplate> _dxTemplates = [
  _DxTemplate(
      'D001', 'Head injury', 'Mild head injury, GCS 15, no LOC', 'S06.0'),
  _DxTemplate('D001', 'Stroke ตีบ', 'Acute ischemic stroke', 'I63.9'),
  _DxTemplate('D001', 'STEMI inferior', 'Acute inferior wall STEMI', 'I21.1'),
  _DxTemplate('D001', 'Sepsis', 'Sepsis, source to be identified', 'A41.9'),
  _DxTemplate('D001', 'แผลหนังศีรษะ', 'Laceration wound at scalp', 'S01.0'),
  _DxTemplate('D001', 'หอบหืด', 'Acute asthmatic attack', 'J45.9'),
  _DxTemplate('D002', 'เจ็บหน้าอก', 'Chest pain, rule out ACS', 'R07.4'),
  _DxTemplate('D002', 'NSTEMI', 'NSTEMI', 'I21.4'),
  _DxTemplate('D002', 'COPD กำเริบ', 'Acute exacerbation of COPD', 'J44.1'),
  _DxTemplate('D002', 'ไส้ติ่งอักเสบ', 'Suspected acute appendicitis', 'K35.8'),
  _DxTemplate('D002', 'ท้องเสีย', 'Acute gastroenteritis', 'A09'),
  _DxTemplate('D002', 'น้ำตาลต่ำ', 'Hypoglycemia', 'E16.2'),
];

/// หน่วยของช่องตัวเลข (ว่าง = ไม่ใช่ช่องตัวเลข)
String _fieldUnit(String hint) =>
    const {'mmHg', '/min', '%', '°C', 'cm'}.contains(hint) ? hint : '';

/// ช่องซักประวัติพยาบาลที่ HOSxP เป็น checkbox/dropdown หลายตัวในแถวเดียว
/// รวมเป็นหน้าเดียว ช่องย่อยละกลุ่มตัวเลือก (ค่าเริ่มต้นของ HOSxP อยู่ตัวแรก)
const Map<String, List<(String, List<String>)>> _localGroups = {
  'ตั้งครรภ์ / ให้นมบุตร / G6PD': [
    ('ตั้งครรภ์', ['ไม่ตั้งครรภ์', 'ตั้งครรภ์']),
    ('ให้นมบุตร', ['ไม่ให้นมบุตร', 'ให้นมบุตร']),
    ('G6PD', ['ไม่พร่อง G6PD', 'พร่อง G6PD']),
  ],
  'FP': [
    (
      'วางแผนครอบครัว',
      [
        'ไม่คุมกำเนิด',
        'ยาเม็ดคุมกำเนิด',
        'ยาฉีดคุมกำเนิด',
        'ห่วงอนามัย',
        'ยาฝังคุมกำเนิด',
        'ถุงยางอนามัย',
        'ทำหมัน',
      ]
    ),
  ],
  'การแพ้ยา / การสูบบุหรี่ / การดื่มสุรา': [
    ('การแพ้ยา', ['ไม่มีประวัติการแพ้ยา', 'มีประวัติการแพ้ยา', 'ไม่ทราบ']),
    (
      'การสูบบุหรี่',
      ['ไม่เคยสูบ', 'สูบเป็นครั้งคราว', 'สูบประจำ', 'เคยสูบแต่เลิกแล้ว']
    ),
    (
      'การดื่มสุรา',
      ['ไม่ดื่ม', 'ดื่มนาน ๆ ครั้ง', 'ดื่มประจำ', 'เคยดื่มแต่เลิกแล้ว']
    ),
  ],
};

/// คำอธิบายใต้ชื่อช่องที่เป็นคำย่อ/ศัพท์เฉพาะ กันผู้ใช้ลืมความหมาย
const Map<String, String> _terms = {
  'HPI': 'ประวัติเจ็บป่วยปัจจุบัน',
  'FP': 'วางแผนครอบครัว',
  'GA': 'ลักษณะทั่วไป',
  'HEENT': 'ศีรษะ ตา หู จมูก คอ',
  'Heart': 'หัวใจ',
  'Chest': 'ทรวงอก ปอด',
  'Chest / Lung': 'ทรวงอก ปอด',
  'Abdomen': 'ช่องท้อง',
  'PR': 'ตรวจทางทวารหนัก',
  'PV': 'ตรวจภายใน',
  'Genitalia': 'อวัยวะเพศ',
  'Neurological': 'ระบบประสาท',
  'Extremities': 'แขนขา',
  'Constitutional': 'อาการทั่วไป',
  'Eyes': 'ตา',
  'ENT/Mouth': 'หู คอ จมูก ปาก',
  'GCS (E / V / M)': 'ระดับความรู้สึกตัว',
  'ระดับความเร่งด่วน (ESI)': 'ระดับ 1–5',
  'Diagnosis Text': 'ข้อความวินิจฉัย เพิ่มได้หลายรายการ หรือเลือกจาก Template',
  'ตำแหน่ง ชนิด ขนาดแผล': 'แตะบนหุ่น 3D เพื่อระบุตำแหน่ง',
  'บันทึกการตรวจแบบละเอียด': 'ผลตรวจเพิ่มเติม ยาวได้หลายประโยค',
  'HEAD/NECK': 'ศีรษะและคอ',
  'FACE': 'ใบหน้า',
  'THORAX': 'ทรวงอก',
  'ABDOMEN/PELVIC CONTENTS': 'ช่องท้องและอวัยวะในอุ้งเชิงกราน',
  'EXTREMITIES/PELVIC GIRDLE': 'แขนขาและกระดูกเชิงกราน',
  'EXTERNAL': 'ผิวหนัง แผลภายนอก',
  'หัตถการที่ทำ': 'บันทึกการทำหัตถการ',
  'รหัสหัตถการ ICD-9-CM': 'รหัสหัตถการ',
};

/// หน้าย่อยแก้ Diagnosis Text ที่เปิดอยู่ (null = ไม่เปิด · -1 = เพิ่มใหม่ · n = แก้รายการ n)
int? _dxEdit;

/// หน้าย่อยเขียน Doctor Note (หน้าเพิ่มเติมของขั้นวินิจฉัย) · ร่างที่กำลังพิมพ์
bool _noteEdit = false;
String _noteDraft = '';

/// แท็บ Re-Diag: visit ที่ดู · รายการที่ติ๊ก ('i|รหัส' / 'd|ข้อความ' → ประเภท)
int _reDiagAt = 0;
bool _reDiagOpen = false;
final Map<String, String> _reDiagPicked = {};

/// หน้าย่อยแก้รหัส ICD-10 แถวที่ i: ร่างรหัส (ชื่อในคลัง) + ประเภท
String _dxDraft = '';

/// รหัส ICD-10 ที่เลือกในหน้าพิมพ์ Diagnosis Text (ผูกตอนบันทึก)
List<String> _dxDraftCodes = [];

/// ประเภทรหัส (diagtype) ที่เลือกในหน้าพิมพ์ (รหัส → '1'..'7') · ใช้ตอนบันทึก
Map<String, String> _dxDraftTypes = {};

/// หน้าพิมพ์ Diagnosis Text เปิดอยู่ (Re-Diag แสดงปุ่มเพิ่มเฉพาะตอนนี้)
bool _dxTextOpen = false;

/// รหัสในร่าง → คำวินิจฉัยที่มากับรหัสนั้น (Re-Diag เพิ่มหลายข้อ = ผูกตามข้อเดิม)
Map<String, String> _dxDraftLink = {};

/// รหัส ICD-9-CM จากขั้นหัตถการที่ผู้ใช้เอาออกเอง ('HN|ชื่อ') = ไม่ลงให้อีก
final Set<String> _icd9ProcDismissed = {};

/// เพิ่มทุกครั้งที่กลับจากข้อเสนอ AI มาหน้าพิมพ์ = เล่น appear ใหม่
int _dxAppearTick = 0;

/// พยาบาลคีย์ Diagnosis Text แทนแพทย์: แพทย์ผู้สั่ง (บังคับเลือกก่อนบันทึก)
String? _dxOrderBy;

/// กดบันทึกโดยยังไม่เลือกแพทย์ผู้สั่ง: แสดงเตือนใต้ช่อง
bool _dxOrderMiss = false;

/// ประวัติการบันทึก HPI ต่อ HN: (เวลา HH:MM, แพทย์, ข้อความ) เก่า → ใหม่
final Map<String, List<(String, String, String)>> _hpiLog = {};

/// ปุ่มเลื่อนรายการในหน้าแก้ Diagnosis Text: วงพื้นฟ้าจาง ไอคอนกรมท่า (ปิด = เทา)
final ButtonStyle _dxNavStyle = IconButton.styleFrom(
  backgroundColor: const Color(0xFFE2EAF8),
  foregroundColor: _blue,
  disabledBackgroundColor: const Color(0xFFF1F3F4),
  disabledForegroundColor: _g5,
  minimumSize: const Size(44.0, 44.0),
);

/// หน้าย่อยเขียน/แก้ HPI
bool _hpiEdit = false;
String _hpiDraft = '';

extension _FeaturesWorkflowFormFieldsPart on _ErFlowHomeWidgetState {
  /// ขั้นของโหมดพูดตามบทบาทที่ login (แพทย์ / พยาบาล)
  /// แต่ละบทบาทกรอกเฉพาะฟอร์ม HOSxP ของตัวเอง (role ใน er_form_kb.json)
  List<(IconData, String)> get _steps {
    final s = switch (ErSession.instance.role) {
      ErRole.doctor => _doctorSteps,
      ErRole.nurse => _nurseSteps,
      ErRole.triage => _triageSteps,
    };
    _ensureStepSlots(s.length);
    return s;
  }

  /// ที่เก็บค่าต่อขั้นต้องมีครบทุกขั้น (เพิ่มขั้นใหม่ระหว่างใช้งาน = ขยายต่อท้าย)
  void _ensureStepSlots(int n) {
    while (_filled.length < n) {
      _filled.add(<String, String>{});
    }
    while (_utter.length < n) {
      _utter.add(<String>[]);
    }
    if (_transcripts.length < n) {
      _transcripts = [
        ..._transcripts,
        for (var i = _transcripts.length; i < n; i++) '',
      ];
    }
  }

  List<List<(String, String)>> get _forms => switch (ErSession.instance.role) {
        ErRole.doctor => _doctorForm,
        ErRole.nurse => _nurseForm,
        ErRole.triage => _triageForm,
      };
  List<String> get _asks => switch (ErSession.instance.role) {
        ErRole.doctor => _doctorAsk,
        ErRole.nurse => _nurseAsk,
        ErRole.triage => _triageAsk,
      };

  /// กลุ่มตัวเลือกจาก master ของช่องที่รวมหลายช่องย่อย: (ชื่อช่องย่อย, ตัวเลือก)
  List<(String, List<String>)> _fieldGroups(String label) {
    // ปลายทาง: แสดงเฉพาะรายการที่ตรงกับสภาพผู้ป่วยออกจาก ER (ตึก หรือ สถานพยาบาล)
    if (label == _destLabel) {
      final opts = _destOptions();
      if (opts.isEmpty) return const [];
      return [
        (
          _disp.startsWith('Refer') ? 'สถานพยาบาลที่ส่งต่อ' : 'ตึกผู้ป่วยใน',
          opts
        )
      ];
    }
    if (_localGroups[label] case final g?) return g;
    final m = ErMaster.maybe;
    final ids = _fieldTables[label];
    if (m == null || ids == null) return const [];
    return [
      // "id|ชื่อ" = ใช้ตารางเดียวกันซ้ำ (เช่น รูม่านตาซ้าย/ขวา) ด้วยชื่อกลุ่มของตัวเอง
      for (final ref in ids)
        if (m.table(ref.split('|').first) case final t?)
          (
            ref.contains('|') ? ref.split('|').last : t.nameTh,
            [for (final it in t.activeItems) it.name]
          ),
    ];
  }

  List<String> _fieldOptions(String label, String hint) {
    if (hint == '0–10') return [for (var i = 0; i <= 10; i++) '$i'];
    // ปลายทางตามสภาพผู้ป่วยออกจาก ER: Admit = ตึก · Refer = สถานพยาบาล
    if (label == _destLabel) return _destOptions();
    final g = _fieldGroups(label);
    if (g.length == 1) return g.first.$2;
    final m = ErMaster.maybe;
    if (m != null) {
      for (final t in m.tables) {
        if (t.usedBy.any((u) => u.field == label) || t.nameTh == label) {
          return [for (final it in t.activeItems) it.name];
        }
      }
    }
    final kb = ErFormKb.maybe;
    if (kb != null) {
      for (final f in kb.forms) {
        final o = kb.options(f['id'] as String, label);
        if (o.isNotEmpty) return o;
      }
    }
    if (hint.contains(' / ') && !hint.contains('…')) {
      final parts = hint.split(' / ').map((e) => e.trim()).toList();
      if (parts.every((e) => e.length <= 14)) return parts;
    }
    return const [];
  }

  /// การ์ดฟอร์มจริงของขั้นนี้ แต่ละช่องวาดตามชนิด: ชิปตัวเลือก / ช่องตัวเลข / ช่องข้อความ
  /// ค่าที่ผู้ช่วยกรอกจากเสียงไฮไลต์อยู่ในช่องจริง แตะเพื่อเลือก/แก้เองได้
  /// ฟอร์มแบบ flipbook: ทีละช่อง การ์ดหน้าใหญ่ การ์ดถัดไปซ้อนอยู่ด้านหลัง
  /// เลือกตัวเลือกแล้วพลิกไปช่องถัดไปเอง ปัด/กดย้อน-ถัดไปได้
  /// ช่องของบล็อกฟอร์มที่มีจริงในฟอร์มขั้นนี้
  /// ช่องของขั้นที่ต้องกรอก: ขั้นตรวจร่างกายที่เลือก template แล้ว
  /// เหลือเฉพาะระบบในขอบเขตของ template (แพทย์เฉพาะทางไม่ได้ตรวจทุกระบบ)
  List<String> _stepLabels(int st) => [
        for (final (l, _) in _forms[st])
          // เทมเพลต PE จำกัดเฉพาะระบบของ PE · ROS ไม่อยู่ในเทมเพลต = แสดงเสมอ (หน้า ROS ไม่หาย)
          if (!_isPeStep(st) ||
              _peScope == null ||
              !_peHasDetail(l) ||
              _isRos(l) ||
              _peScope!.contains(l))
            if (!_dxMerged(st, l)) l
      ];

  /// ช่องไม่บังคับ: เว้นว่างได้ ไม่นับเป็นช่องที่ขาด (ไม่ขวางการไปหน้าสรุป)
  static const Set<String> _optionalFields = {'บันทึกการตรวจแบบละเอียด'};

  /// ช่องนี้ครบหรือยัง: ผลตรวจ "ผิดปกติ" ต้องมีรายละเอียดเสมอ
  bool _fieldDone(int st, String l) {
    final v = _filled[st][l];
    // ตรวจร่างกาย: ไม่บังคับกรอกทุกช่อง (2026-10-19) · ที่กรอกแล้วยังตรวจรายละเอียดตามเดิม
    if (v == null || v.trim().isEmpty) {
      return _optionalFields.contains(l) || _isPeStep(st);
    }
    // template ที่ยังมีช่องว่าง [ ] = ยังเล่าไม่ครบ ไม่นับว่ากรอกแล้ว
    if (RegExp(r'\[[^\]]*\]').hasMatch(v)) return false;
    // หลายช่องย่อย: ครบเมื่อเลือกทุกกลุ่ม (กลุ่มที่ยังไม่เลือกเก็บเป็น "-")
    if (_fieldGroups(l).length > 1 && v.split(' · ').contains('-')) {
      return false;
    }
    // หน้ารวม ICD-10 + Diagnosis Text: ครบเมื่อมีทั้งรหัสและข้อความวินิจฉัย
    if (l == _icd10Label &&
        _hasDxText(st) &&
        (_filled[st][_dxTextLabel] ?? '').trim().isEmpty) {
      return false;
    }
    // หน้าสภาพผู้ป่วยออกจาก ER: ครบเมื่อระบุวันที่/เวลาออกจากห้องด้วย
    if (l == _dispLabel &&
        _hasOutTime(st) &&
        (_filled[st][_outTimeLabel] ?? '').trim().isEmpty) {
      return false;
    }
    return !_needsDetail(st, l);
  }

  bool _needsDetail(int st, String l) =>
      _isPeStep(st) &&
      _filled[st][l] == 'ผิดปกติ' &&
      (_filled[st]['$l - รายละเอียด'] ?? '').trim().isEmpty;

  List<String> _formFields(ErUiBlock b) {
    final have = {..._stepLabels(_speechStep)};
    return [
      for (final f in b.strs('fields'))
        if (have.contains(f)) f
    ];
  }

  /// พลิก flipbook ไป d หน้า (ใช้ทั้งปุ่มบนหัวแผง แถบ stepper และการปัด)
  void _formGo(int d, int n) {
    final at = _formAt.clamp(0, n - 1);
    final to = (at + d).clamp(0, n - 1);
    if (to != at) {
      setState(() {
        _formFwd = d > 0;
        _formAt = to;
      });
    }
  }

  String? _termOf(String label) => _terms[label];

  // ------------------------------------------------ HPI template + ช่องข้อความอิสระ

  /// ส่วนเสริมใต้ช่องกรอกใน flipbook: HPI มีแถบ template · ผลตรวจมีช่องรายละเอียด
  Widget _fieldWithExtras(String label, Widget field,
      {bool fill = false, bool scroll = true}) {
    // หน้าแรกของขั้นคัดกรอง: อุบัติเหตุ · รับเข้าห้องฉุกเฉิน · การรับบริการ
    if (label == _erInLabel) return _screeningPage();
    // ขั้นวินิจฉัย/สั่ง: หน้าย่อย ยา / Lab / X-ray / หัตถการ มีการ์ดติ๊กรายการของชุดที่เลือกอยู่บนสุด
    if (_steps[_speechStep].$2 == 'สั่งการรักษา') {
      final groups = _orderGroupsFor(label);
      if (groups.isNotEmpty) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final g in groups)
                _orderGroupCard(g,
                    kind: label.contains('ยา') ? _OrderKind.drug : null),
              // ช่องพิมพ์อิสระยืดเต็มความสูง: ในรายการเลื่อนต้องจำกัดความสูงเอง
              ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160.0),
                  child: field),
            ],
          ),
        );
      }
    }
    // ช่องยืนยัน (ทบทวนเคส): แสดงข้อมูลที่กำลังยืนยันใต้ปุ่ม ไม่ต้องไปหาเองที่แผงขวา
    final ctx = _confirmContext(label);
    if (ctx != null) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [field, const SizedBox(height: 14.0), ctx],
        ),
      );
    }
    if (fill) {
      final hpi = _isHpiStep(_speechStep) && label == 'HPI';
      if (hpi) {
        // เปิดมาเป็นช่องเปล่าเลย (ไม่มีหน้าเลือก template) ในการ์ดตาม Figma 220-412:
        // หัวมีแท็บเลือกเทมเพลต · ท้ายมีปุ่มดูประวัติ HPI
        _hpiAutoPretty();
        // Dr.Note แนะนำ template: แพทย์กดเองจากการ์ด AI บนหน้า HPI (ไม่เรียกอัตโนมัติ)
        // design language เดียวกับหน้าวินิจฉัย: การ์ดหัวข้อ + Dr.Note มุมขวา
        // แผ่นปุ่มลัด (เทมเพลต / ประวัติ) · ช่องพิมพ์เต็มที่เหลือ · ไมค์อยู่ footer
        return _hpiPage(label);
      }
      if (!scroll) return field;
      return SingleChildScrollView(child: _fieldWithExtras(label, field));
    }
    if (label == _icd9Label) {
      final sug = _icd9Suggest();
      if (sug.isEmpty) return field;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [field, const SizedBox(height: 8.0), _icd9Bar(sug)],
      );
    }
    if (label == _destLabel) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [field, const SizedBox(height: 8.0), _destSuggest()],
      );
    }
    // พยาบาล (ฟอร์มรวมหน้าเดียว ไม่มีช่องเวลาคู่): Admit = SBAR ใต้การ์ดสภาพผู้ป่วย
    if (label == _dispLabel &&
        !_hasOutTime(_speechStep) &&
        ErSession.instance.isNurse &&
        (_filled[_speechStep][_dispLabel] ?? '').startsWith('Admit')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [field, _handoverSbar()],
      );
    }
    // สภาพผู้ป่วยออกจาก ER: วันที่/เวลาออกจากห้องอยู่หน้าเดียวกัน ใต้การ์ดสภาพผู้ป่วย
    if (label == _dispLabel && _hasOutTime(_speechStep)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          field,
          const SizedBox(height: 14.0),
          Text(_outTimeLabel,
              style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(height: 6.0),
          _dateTimeField(
              _outTimeLabel, _filled[_speechStep][_outTimeLabel], null),
          // พยาบาล + Admit: เขียนการส่งต่อให้วอร์ด (SBAR) แบบ TERHandoverForm
          if (ErSession.instance.isNurse &&
              (_filled[_speechStep][_dispLabel] ?? '').startsWith('Admit'))
            _handoverSbar(),
          // เลือกสภาพแล้ว: Dr.Note ร่างเอกสารตามสภาพ (ใบส่งต่อ / รับไว้ / สรุปจำหน่าย)
          if ((_filled[_speechStep][_dispLabel] ?? '').isNotEmpty) _dcCard(),
        ],
      );
    }
    final hpi = _isHpiStep(_speechStep) && label == 'HPI';
    final detail = _isPeStep(_speechStep) && _peHasDetail(label);
    if (!hpi && !detail) return field;
    if (hpi) _hpiAutoPretty();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hpi) ...[_hpiTemplateBar(), const SizedBox(height: 8.0)],
        // HPI: ปุ่มดูประวัติ HPI ซ้อนบนช่องกรอก มุมขวาล่าง
        if (hpi)
          Stack(children: [
            field,
            Positioned(right: 10.0, bottom: 10.0, child: _hpiHistoryBtn()),
          ])
        else ...[
          field,
          const SizedBox(height: 8.0),
          _detailBox(label),
        ],
      ],
    );
  }

  /// ส่งต่อผู้ป่วยไป Ward (SBAR): Ward ที่รับ + S B A R + งานค้าง
  /// เก็บใน _filled ของขั้นนี้ ใต้ชื่อช่องเดียวกับฟอร์ม HOSxP
  Widget _handoverSbar() {
    const ward = 'Ward ที่รับ';
    const parts = [
      ('S : สถานการณ์', 'สถานการณ์ปัจจุบันของผู้ป่วย'),
      ('B : ความเป็นมา', 'ประวัติ อาการสำคัญ การรักษาที่ได้รับ'),
      ('A : การประเมิน', 'ผลประเมิน สัญญาณชีพ ปัญหาที่พบ'),
      ('R : ข้อเสนอแนะ', 'สิ่งที่วอร์ดควรทำต่อ'),
      ('งานค้าง', 'เช่น ผล Lab ที่ยังไม่ได้ดู ยาที่ยังไม่ได้ให้'),
    ];
    final cur = _filled[_speechStep][ward];
    Widget head(String t) => Padding(
          padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
          child: Text(t,
              style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
        );
    BoxDecoration box() => BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10.0),
        Text('เขียนการส่งต่อ (SBAR)',
            style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
        head(ward),
        _Press(
          child: GestureDetector(
            onTap: () async {
              final v = await _listSheet(ward, _wardRanked(), current: cur);
              if (v == null || !mounted) return;
              setState(() => _filled[_speechStep][ward] = v);
            },
            child: Container(
              height: 48.0,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              decoration: box(),
              child: Row(children: [
                Expanded(
                  child: Text(cur ?? 'เลือก Ward ที่รับ',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(14.0,
                          color: cur == null ? _ink3 : _inkTitle,
                          weight: FontWeight.w500)),
                ),
                const Icon(Icons.expand_more_rounded, color: _ink3),
              ]),
            ),
          ),
        ),
        for (final (l, hint) in parts) ...[
          head(l),
          Container(
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
            constraints: const BoxConstraints(minHeight: 72.0),
            decoration: box(),
            child: _inlineInput(l, _filled[_speechStep][l],
                hint: hint,
                maxLines: 5,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w500),
                hintStyle: _t(14.0, color: _ink3, weight: FontWeight.w500)),
          ),
        ],
        const SizedBox(height: 6.0),
      ],
    );
  }

  /// ช่องรายละเอียดแบบข้อความอิสระของผลตรวจแต่ละระบบ (ตามฟอร์ม HOSxP "<ระบบ> - รายละเอียด")
  List<String> _detailLabels(int step) => _isPeStep(step)
      ? [
          for (final (l, _) in _forms[step])
            if (_peHasDetail(l)) '$l - รายละเอียด'
        ]
      : const [];

  /// ชื่อช่องที่ผู้ช่วยเติมได้ในขั้นนี้ (ช่องในฟอร์ม + ช่องรายละเอียด)
  List<String> _acceptLabels(int step) =>
      [for (final (l, _) in _forms[step]) l, ..._detailLabels(step)];

  /// ช่องรายละเอียดอิสระใต้ผลตรวจของแต่ละระบบ (พิมพ์/พูดยาว ๆ ได้)
  Widget _detailBox(String label) {
    final step = _speechStep;
    final key = '$label - รายละเอียด';
    final v = (_filled[step][key] ?? '').trim();
    final must = _needsDetail(step, label);
    Future<void> open() async {
      final t = await _ftOpen(context,
          title: '$label ผิดปกติ',
          sub: 'รายละเอียดความผิดปกติ',
          initial: v,
          hint: 'เช่น pale conjunctivae, ซึมลง ปลุกตื่น',
          inWorkflow: true);
      if (t == null || !mounted) return;
      setState(() {
        if (t.trim().isEmpty) {
          _filled[step].remove(key);
        } else {
          _filled[step][key] = _fmtField(key, t.trim());
        }
        _inlineCtl['$step|$key']?.text = t.trim();
      });
    }

    // แถวรายการแบบ "หมายเหตุ  ค่า >": เส้นคั่นบน · ชื่อซ้าย · ค่าที่กรอกชิดขวา · ลูกศร
    // แตะ = หน้าย่อยพิมพ์ใน workflow · ว่าง = "ระบุ" สีเทา
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Divider(height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
      InkWell(
        onTap: open,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(children: [
            Text(must ? 'รายละเอียด' : 'หมายเหตุ',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w500)),
            const SizedBox(width: 16.0),
            if (v.isEmpty && must) const Spacer(),
            // ยังว่าง + จำเป็น = ป้ายพื้นขาวเส้นเทา "ต้องระบุ"
            if (v.isEmpty && must)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 1.0),
                ),
                child: Text('ต้องระบุ',
                    style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
              )
            else
              Expanded(
                child: Text(v.isEmpty ? 'ระบุ' : v,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: _t(14.0,
                        color: v.isEmpty ? _ink3 : _inkTitle,
                        weight: v.isEmpty ? FontWeight.w500 : FontWeight.w600)),
              ),
            const SizedBox(width: 4.0),
            const Icon(Icons.chevron_right_rounded, size: 22.0, color: _ink2),
          ]),
        ),
      ),
    ]);
  }

  // ------------------------------------------------ ข้อมูลประกอบช่องยืนยัน (ทบทวนเคส)

  /// การ์ดข้อมูลที่แพทย์กำลังยืนยัน (ข้อมูลจริงของเคส) · ช่องอื่น = null
  Widget? _confirmContext(String label) {
    final c = _case;
    Widget row(String k, String v, {bool alert = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 92.0,
              child: Text(k, style: _t(11.0, color: _ink3)),
            ),
            Expanded(
              child: Text(v,
                  style: _t(12.0,
                      color: alert ? _red : _inkTitle,
                      weight: FontWeight.w600,
                      height: 1.35)),
            ),
          ]),
        );
    Widget card(String title, List<Widget> rows) => Container(
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 10.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: _t(11.0, color: _ink2, weight: FontWeight.w700)),
              const SizedBox(height: 4.0),
              ...rows,
            ],
          ),
        );
    switch (label) {
      case 'ยืนยันข้อมูลคัดกรอง':
        final esi = _caseP().esi;
        final vs = <String>[
          if (c.hr.isNotEmpty) 'HR ${c.hr.last.round()}',
          if (c.sbp.isNotEmpty) 'BP ${c.bp}',
          if (c.spo2.isNotEmpty) 'SpO₂ ${c.spo2.last.round()}%',
          if (c.rr.isNotEmpty) 'RR ${c.rr.last.round()}',
          if (c.bt.isNotEmpty) 'BT ${c.bt.last}',
        ];
        return card('ข้อมูลคัดกรองที่บันทึกไว้', [
          row('อาการสำคัญ', c.cc),
          if (esi != null) row('ระดับ ESI', esi.en),
          if (c.arrival.isNotEmpty) row('มาถึงโดย', c.arrival),
          if (vs.isNotEmpty) row('สัญญาณชีพ', vs.join('  ')),
          if (c.gcs != null) row('GCS', c.gcsScore),
          if (c.painScore != null) row('Pain', '${c.painScore}/10'),
        ]);
      case 'ยืนยันประวัติแพ้ยา':
        return card('ประวัติที่บันทึกไว้', [
          row('แพ้ยา/อาหาร',
              c.allergies.isEmpty ? 'ไม่มีประวัติแพ้' : c.allergies.join(', '),
              alert: c.allergies.isNotEmpty),
          if (c.underlying.isNotEmpty)
            row('โรคประจำตัว', c.underlying.join(', ')),
        ]);
    }
    return null;
  }

  // ------------------------------------------------ ช่องพิมพ์ในฟอร์ม (ไม่เปิด dialog)

  /// focus ของช่อง · ออกจากช่อง = จัดรูปแบบค่า (HPI จัดบรรทัด) + ตรวจแพ้ยาซ้ำ
  FocusNode _inlineFocusOf(String label) {
    final step = _speechStep;
    return _inlineFocus.putIfAbsent('$step|$label', () {
      final f = FocusNode();
      f.addListener(() {
        if (!f.hasFocus && mounted) _inlineCommit(step, label);
      });
      return f;
    });
  }

  void _inlineCommit(int step, String label) {
    final v = (_filled[step][label] ?? '').trim();
    setState(() {
      if (v.isEmpty) {
        _filled[step].remove(label);
      } else {
        _filled[step][label] = _fmtField(label, v);
      }
      _allergyWarn = _allergyConflict();
    });
  }

  /// ช่องพิมพ์ตรงในฟอร์ม: ค่าลง `_filled` ทุกตัวอักษร (ช่องครบ/สรุปอัปเดตทันที)
  /// ค่าที่ผู้ช่วย/template ใส่มาตอนไม่ได้พิมพ์อยู่ = อัปเดตในช่องให้
  Widget _inlineInput(String label, String? value,
      {required String hint,
      required TextStyle style,
      required TextStyle hintStyle,
      bool fill = false,
      int? maxLines = 3,
      bool numeric = false,
      bool rich = false}) {
    final step = _speechStep;
    final key = '$step|$label';
    final focus = _inlineFocusOf(label);
    // ช่อง rich text (HPI / ตรวจแบบละเอียด): ตัวควบคุมที่แสดง **หนา** # หัวข้อ • bullet
    if (rich && _inlineCtl[key] is! _RichNoteController) {
      _inlineCtl[key]?.dispose();
      _inlineCtl[key] = _RichNoteController(text: value ?? '');
    }
    final ctl = _inlineCtl.putIfAbsent(
        key, () => TextEditingController(text: value ?? ''));
    if (!focus.hasFocus && ctl.text != (value ?? '')) ctl.text = value ?? '';
    return TextField(
      controller: ctl,
      focusNode: focus,
      // ข้อความอิสระ: แตะ = แผ่นพิมพ์ลอย (ตัวเลขยังพิมพ์ในช่อง)
      readOnly: !numeric,
      showCursor: numeric,
      onTap: numeric
          ? null
          : () => _ftEditCtl(context, ctl,
              title: label,
              hint: hint,
              then: (v) => setState(() {
                    if (label == 'HPI') _hpiManual = true;
                    if (v.trim().isEmpty) {
                      _filled[step].remove(label);
                    } else {
                      _filled[step][label] = v;
                    }
                  })),
      expands: fill,
      minLines: fill ? null : 1,
      maxLines: fill ? null : (numeric ? 1 : maxLines),
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.multiline,
      textAlignVertical: TextAlignVertical.top,
      style: style,
      cursorColor: _blue,
      decoration:
          InputDecoration.collapsed(hintText: hint, hintStyle: hintStyle),
      onTapOutside: (_) => focus.unfocus(),
      onChanged: (v) => setState(() {
        // พิมพ์เองในช่อง HPI = ไม่ให้ตัวจัดบรรทัดอัตโนมัติมายุบบรรทัดที่ขึ้นเอง
        if (label == 'HPI') _hpiManual = true;
        if (v.trim().isEmpty) {
          _filled[step].remove(label);
        } else {
          _filled[step][label] = v;
        }
      }),
    );
  }

  // ------------------------------------------------ Diagnosis หลายรายการ + Template ของแพทย์

  /// ช่องที่ลงได้หลายรายการ: Diagnosis Text และ ICD-10
  bool _isMultiField(String label) =>
      label == _dxTextLabel || label == _icd10Label;

  /// ค่าหลายรายการของช่อง (หนึ่งบรรทัด = หนึ่งรายการ)
  /// icd = แยกรหัสที่ถูกเขียนรวมกันในบรรทัดเดียวออกเป็นบรรทัดละรหัส
  List<String> _multiItems(String? value, {bool icd = false}) {
    final lines = [
      for (final s in (value ?? '').split('\n'))
        if (s.trim().isNotEmpty) s.trim()
    ];
    if (!icd) return lines;
    final out = <String>[];
    for (final l in lines) {
      for (final n in _icd10Split(l)) {
        if (!out.contains(n)) out.add(n);
      }
    }
    return out;
  }

  /// ICD-10 จาก master: ชื่อ → รหัส (ค่าที่เก็บในช่องเป็นชื่อตาม master)
  Map<String, String> _icd10Codes() => {
        for (final it in ErMaster.maybe?.table('er_icd10')?.activeItems ??
            const <ErMasterItem>[])
          it.name: it.code
      };

  /// แถว ICD-10: (รหัส, ชื่อ) · อยู่ใน master = รหัสจาก master
  /// ข้อความอิสระที่ขึ้นต้นด้วยรหัส (เช่น "S72.3 Hemorrhagic…" จาก AI) = ตัดรหัสไปชิดขวา
  (String, String) _icdRowSplit(String item, Map<String, String> codes) {
    final c = codes[item];
    if (c != null) return (c, item);
    final m =
        RegExp(r'^([A-Z]\d{2}(?:\.\d{1,2})?)\s+(.+)$').firstMatch(item.trim());
    return m == null ? ('', item) : (m.group(1)!, m.group(2)!);
  }

  /// แยกข้อความหนึ่งบรรทัดที่มีหลายรหัส/หลายชื่อโรค (เช่น "S06.0, A41.9"
  /// หรือ "Concussion และ Sepsis") เป็นชื่อตาม master ทีละรายการ เรียงตามตำแหน่งที่พบ
  /// ไม่พบใน master = คงข้อความเดิมไว้ ไม่เดารหัสเอง
  List<String> _icd10Split(String line) {
    final low = line.toLowerCase();
    final hits = <(int, String)>[];
    _icd10Codes().forEach((name, code) {
      final byCode = RegExp('(?<![A-Za-z0-9.])${RegExp.escape(code)}(?![0-9])',
              caseSensitive: false)
          .firstMatch(line)
          ?.start;
      final byName = low.indexOf(name.toLowerCase());
      final at = [if (byCode != null) byCode, if (byName >= 0) byName];
      if (at.isNotEmpty) hits.add((at.reduce(math.min), name));
    });
    if (hits.isEmpty) return [line];
    hits.sort((a, b) => a.$1.compareTo(b.$1));
    return [for (final h in hits) h.$2];
  }

  /// ICD-10 สำหรับแสดง: บรรทัดละรหัส "Type n · รหัส ชื่อโรค"
  String _icd10Lines(String? value) {
    final codes = _icd10Codes();
    final items = _multiItems(value, icd: true);
    return [
      for (var i = 0; i < items.length; i++)
        'Type ${_diagTypeOf(items, i)} · '
            '${codes[items[i]] == null ? '' : '${codes[items[i]]} '}${items[i]}'
    ].join('\n');
  }

  /// ขั้นที่มีทั้ง ICD-10 และ Diagnosis Text รวมเป็นหน้าเดียว (ICD-10 บน · Diagnosis Text ล่าง)
  /// ช่อง Diagnosis Text จึงไม่นับเป็นหน้าแยก แต่ยังเป็นช่องที่ผู้ช่วยเติมได้
  /// ขั้นหัตถการก็เช่นกัน: ICD-9-CM อยู่ในหน้าเดียวกับชื่อหัตถการ (Figma 227-595)
  bool _dxMerged(int st, String l) =>
      (l == _dxTextLabel && _forms[st].any((f) => f.$1 == _icd10Label)) ||
      (l == _icd9Label && _forms[st].any((f) => f.$1 == _procLabel)) ||
      (l == _outTimeLabel && _forms[st].any((f) => f.$1 == _dispLabel));

  /// ขั้นนี้มีช่อง "วันที่/เวลา ออกจากห้อง ER" (แสดงรวมในหน้าสภาพผู้ป่วยออกจาก ER)
  bool _hasOutTime(int st) => _forms[st].any((f) => f.$1 == _outTimeLabel);

  bool _hasDxText(int st) => _forms[st].any((f) => f.$1 == _dxTextLabel);

  // ------------------------------------------------ หน้าย่อยของขั้นวินิจฉัย (UX แบบซักประวัติพยาบาล)
  // หน้าละเรื่อง + stepper วงกลม: Diagnosis Text (+ Dr.Note) → รหัสโรค → Doctor Note → สรุป
  // แต่ละหน้า: หัวข้อ + คำอธิบาย + ปุ่ม tonal ขวา · เนื้อหาลอยขึ้นทีละชิ้น · เปลี่ยนหน้าเริ่มบนสุด

  /// ขั้นวินิจฉัยของแพทย์: ฟอร์มมีทั้ง ICD-10 และ Diagnosis Text
  bool _isDxStep(int st) =>
      _hasDxText(st) && _forms[st].any((f) => f.$1 == _icd10Label);

  List<String> get _dxPages => const ['dx', 'more'];

  /// หน้าย่อยที่ช่องนี้อยู่ (ใช้ตอนแตะแก้จากหน้าสรุป / ไปช่องที่ขาด)
  int _dxPageOf(String label) =>
      label == _noteLabel || label == _icd9DxLabel ? 1 : 0;

  /// บันทึกหน้าย่อย Diagnosis Text (บรรทัดเดียวต่อรายการ · ว่าง = ลบรายการที่แก้)
  void _dxEditSave() {
    final items = _multiItems(_filled[_speechStep][_dxTextLabel]);
    final i = _dxEdit;
    final text = _dxDraft.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim();
    if (i == null) return;
    // พยาบาลคีย์แทน: ต้องระบุแพทย์ผู้สั่งก่อนบันทึก (ลบรายการไม่ต้อง)
    final nurse = ErSession.instance.isNurse;
    if (nurse && text.isNotEmpty && _dxOrderBy == null) {
      HapticFeedback.heavyImpact();
      setState(() => _dxOrderMiss = true);
      _wfToast('เลือกแพทย์ผู้สั่งก่อนบันทึก', error: true);
      return;
    }
    if (i < 0) {
      if (text.isNotEmpty) _setMulti(_dxTextLabel, [...items, text]);
    } else if (text.isEmpty) {
      _setMulti(_dxTextLabel, items..removeAt(i));
    } else {
      _setMulti(_dxTextLabel, items..[i] = text);
    }
    // ผู้วินิจฉัย = แพทย์ผู้สั่ง · คอลัมน์ที่ 4 = พยาบาลผู้คีย์แทน
    if (nurse && text.isNotEmpty && _dxOrderBy != null) {
      final now = DateTime.now();
      final hhmm = '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
      final rows = {for (final p in _byRows(_dxTextLabel)) p[0]: p};
      rows[text] = [
        text,
        _dxOrderBy!,
        hhmm,
        ErSession.instance.user?.name ?? 'พยาบาล'
      ];
      _filled[_speechStep]['$_dxTextLabel - by'] =
          [for (final p in rows.values) p.join('\t')].join('\n');
    }
    setState(() {
      _dxEdit = null;
      _dxOrderMiss = false;
    });
  }

  /// พยาบาลคีย์แทน: ชื่อพยาบาลผู้คีย์ของแต่ละรายการ (คอลัมน์ที่ 4)
  Map<String, String> _keyedByMap(String label) => {
        for (final p in _byRows(label))
          if (p.length >= 4 && p[3].isNotEmpty) p[0]: p[3]
      };

  /// ชื่อแพทย์ + ตำแหน่งในวงเล็บท้ายชื่อ (เช่น "(รังสีแพทย์)") แยกเป็นบรรทัดรอง
  /// ชื่อในรายชื่อตรงกับผู้ใช้ที่ล็อกอินไหม: คำนำหน้า + ชื่อต้นตรงกัน
  /// (รายชื่อมักย่อนามสกุล เช่น "พญ. ศิริพร ก." กับ "พญ. ศิริพร กิตติวงศ์")
  bool _isMe(String name) {
    final me = ErSession.instance.user?.name;
    if (me == null) return false;
    List<String> head(String n) =>
        n.replaceAll('.', '').split(RegExp(r'\s+')).take(2).toList();
    final a = head(me), b = head(name);
    return a.length == 2 && b.length == 2 && a[0] == b[0] && a[1] == b[1];
  }

  Widget _docName(String d, {double size = 14.5, bool bold = false}) {
    final m = RegExp(r'^(.*?)\s*\(([^)]*)\)\s*$').firstMatch(d);
    final name = m?.group(1) ?? d;
    final sub = m?.group(2);
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ผู้ใช้ที่ล็อกอินอยู่: ป้าย "ฉัน" ต่อท้ายชื่อ (หาตัวเองในรายชื่อได้ทันที)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(size,
                      color: _inkTitle,
                      weight: bold ? FontWeight.w600 : FontWeight.w500)),
            ),
            if (_isMe(name)) ...[
              const SizedBox(width: 8.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.0),
                // พื้นขาวขอบเทา: เห็นชัดทั้งแถวปกติและแถวที่เลือก (พื้นเทา)
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: const Color(0xFFC4C7CC)),
                ),
                child: Text('ฉัน',
                    style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
              ),
            ],
          ]),
          if (sub != null && sub.isNotEmpty)
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
        ]);
  }

  /// รูปหน้าแพทย์จากบุคลากรในระบบ (จับคู่ชื่อต้น) แบบ avatar หน้าสรุปอาการ
  /// ไม่พบ = อักษรต้นบนวงฟ้าอ่อน
  Widget _docAvatar(String name, double size,
      {Alignment align = Alignment.center}) {
    final first = name.split(' ').length > 1 ? name.split(' ')[1] : name;
    String? face;
    for (final u in erStaff) {
      if (u.name.contains(first)) face = u.face;
    }
    return Container(
      width: size,
      height: size,
      // ตัวอักษรต้น: ขยับได้ (วงที่ถูกวงซ้ายทับใน avatar ซ้อน ให้อักษรอยู่ส่วนที่มองเห็น)
      alignment: align,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: face == null
            ? _blue.withValues(alpha: 0.10)
            : const Color(0xFFDCE6F5),
      ),
      child: face != null
          // ขยายเน้นใบหน้า-ไหล่ ให้คนเต็มวง
          ? Transform.scale(
              scale: 1.35,
              alignment: const Alignment(0.0, -0.55),
              child: Image.asset(face,
                  width: size, height: size, fit: BoxFit.cover))
          : Text(first.characters.first,
              style: _t(size * 0.42, color: _blue, weight: FontWeight.w700)),
    );
  }

  /// แพทย์ที่เลือกเป็นผู้สั่งได้ (master er_doctor + แพทย์ในระบบ)
  /// ใช้ชื่อเต็มจากบุคลากรในระบบก่อน · ชื่อย่อใน master ที่ชื่อต้นซ้ำกันไม่แสดงซ้ำ
  List<String> get _dxDoctors {
    final staff = [
      for (final u in erStaff)
        if (u.role == ErRole.doctor) u.name,
    ];
    String first(String n) => n.split(' ').length > 1 ? n.split(' ')[1] : n;
    final firsts = {for (final n in staff) first(n)};
    return [
      ...staff,
      for (final it in ErMaster.maybe?.table('er_doctor')?.activeItems ??
          const <ErMasterItem>[])
        if (!firsts.contains(first(it.name))) it.name,
    ].toSet().toList();
  }

  /// ไปแก้รายการก่อน/ถัดไป: บันทึกข้อความรายการนี้ก่อน (ว่าง = คงของเดิม)
  void _dxEditGo(int d) {
    final i = _dxEdit;
    if (i == null || i < 0) return;
    final items = _multiItems(_filled[_speechStep][_dxTextLabel]);
    final text = _dxDraft.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim();
    if (text.isNotEmpty && i < items.length && items[i] != text) {
      _setMulti(_dxTextLabel, [...items]..[i] = text);
    }
    final next = _multiItems(_filled[_speechStep][_dxTextLabel]);
    final j = (i + d).clamp(0, next.length - 1);
    HapticFeedback.selectionClick();
    setState(() {
      _formFwd = d > 0;
      _dxEdit = j;
      _dxDraft = next[j];
    });
  }

  /// เปิดหน้าย่อยของขั้นวินิจฉัยอยู่ (หัวแผงเป็น breadcrumb · footer เป็นปุ่มของหน้าย่อย)
  bool get _dxNested =>
      _isDxStep(_speechStep) &&
      (((_dxEdit != null || _reDiagOpen) && _formAt == 0) ||
          (_noteEdit && _formAt == 1));

  /// เปิดหน้าย่อย Doctor Note (แบบหน้าย่อย Diagnosis Text)
  /// Doctor Note: แผ่นพิมพ์ลอยทันที (ไม่มีหน้าย่อยแล้ว)
  Future<void> _openNoteEdit() async {
    final v = await _ftOpen(context,
        title: 'Doctor Note',
        sub: 'บันทึกเพิ่มเติมของแพทย์',
        inWorkflow: true,
        initial: _filled[_speechStep][_noteLabel] ?? '',
        hint: 'บันทึกเพิ่มเติม เช่น แผนการรักษา สิ่งที่ต้องติดตาม');
    if (v == null || !mounted) return;
    _setNote(v.trim());
    setState(() {});
  }

  /// บันทึก Doctor Note จากหน้าย่อย แล้วกลับหน้าเพิ่มเติม
  void _noteEditSave() {
    _setNote(_noteDraft.trim());
    setState(() => _noteEdit = false);
  }

  /// หน้าย่อย Doctor Note: ช่องพิมพ์ยาว (ไมค์อยู่ footer)
  Widget _noteEditPage() => ListView(
        key: const ValueKey('dx-edit-note'),
        padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 96.0),
        children: [
          _FtTapBox(
            style: _t(15.0,
                color: _inkTitle, weight: FontWeight.w500, height: 1.45),
            hintStyle:
                _t(15.0, color: _ink3, weight: FontWeight.w500, height: 1.45),
            title: 'Doctor Note',
            value: _noteDraft,
            hint: 'บันทึกเพิ่มเติม เช่น แผนการรักษา สิ่งที่ต้องติดตาม',
            minHeight: 110.0,
            onSaved: (v) => setState(() => _noteDraft = v),
          ),
        ],
      );

  /// แตะรหัส ICD-10: แก้ในหน้าพิมพ์ Diagnosis Text ที่รหัสนี้ผูกอยู่ (ประเภท/เอาออก อยู่ในหน้านั้น)
  /// รหัสที่ไม่ได้ผูก = เปิดหน้าพิมพ์รายการใหม่พร้อมรหัสนี้ (พิมพ์คำวินิจฉัยแล้วผูกให้)
  void _openIcdEdit(int i) {
    final items = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    if (i >= items.length) return;
    final dx = _multiItems(_filled[_speechStep][_dxTextLabel]);
    final at = dx.indexOf(_icdSrcMap()[items[i]] ?? '');
    _editDxText(at < 0 ? null : at, codes: at < 0 ? [items[i]] : const []);
  }

  /// breadcrumb (ไม่มีปุ่มย้อนกลับ): โรคและรหัส › เพิ่ม/แก้ Diagnosis Text · แตะส่วนแรก = กลับหน้ารายการ
  Widget _dxCrumb() {
    final i = _dxEdit ?? -1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 16.0, 6.0),
      child: Row(children: [
        _CrumbPrev(_noteEdit ? 'ข้อมูลเพิ่มเติม' : 'บันทึกคำวินิจฉัยและรหัสโรค',
            onTap: () => setState(() {
                  _dxEdit = null;
                  _reDiagOpen = false;
                  _noteEdit = false;
                })),
        const _CrumbSep(),
        Expanded(
          child: Text(
              _noteEdit
                  ? 'Doctor Note'
                  : _reDiagOpen
                      ? 'Re-Diag'
                      : i < 0
                          ? 'เพิ่ม Diagnosis Text'
                          : 'แก้ Diagnosis Text',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
        ),
      ]),
    );
  }

  /// หน้าย่อย: เพิ่ม/แก้ Diagnosis Text · หัว = ย้อนกลับ + ชื่อ · ช่องพิมพ์+ไมค์ · ยกเลิก/บันทึก
  /// ลบ Diagnosis Text หลังยืนยัน (กันลบพลาด) แล้วกลับหน้ารายการ
  Future<void> _dxDeleteAsk(int i) async {
    final items = _multiItems(_filled[_speechStep][_dxTextLabel]);
    if (i >= items.length) return;
    HapticFeedback.mediumImpact();
    // dialog กระดาษชุดเดียวกับการลบทุกจุด
    final ok = await _askDelete('ลบ Diagnosis Text นี้?',
        '${items[i]}\nรหัส ICD-10 ที่ผูกกับคำวินิจฉัยนี้จะถูกลบด้วย', 'ลบ');
    if (ok != true || !mounted) return;
    final now = _multiItems(_filled[_speechStep][_dxTextLabel]);
    if (i < now.length) _setMulti(_dxTextLabel, now..removeAt(i));
    setState(() => _dxEdit = null);
  }

  Widget _dxEditPage() {
    final i = _dxEdit!;
    final n = _multiItems(_filled[_speechStep][_dxTextLabel]).length;
    return ListView(
      key: ValueKey('dx-edit-$i'),
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 96.0),
      children: [
        // แก้หลายรายการ: ตัวเลื่อนรายการก่อน/ถัดไป (บันทึกรายการนี้ให้ก่อนเลื่อน)
        if (i >= 0 && n > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 8.0),
            child: Row(children: [
              Expanded(
                child: Text('รายการที่ ${i + 1} จาก $n',
                    style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
              ),
              IconButton(
                onPressed: i > 0 ? () => _dxEditGo(-1) : null,
                style: _dxNavStyle,
                tooltip: 'รายการก่อนหน้า',
                icon: const Icon(Icons.chevron_left_rounded, size: 24.0),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: i < n - 1 ? () => _dxEditGo(1) : null,
                style: _dxNavStyle,
                tooltip: 'รายการถัดไป',
                icon: const Icon(Icons.chevron_right_rounded, size: 24.0),
              ),
            ]),
          )
        else
          const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: _FtTapBox(
            style: _t(15.0,
                color: _inkTitle, weight: FontWeight.w500, height: 1.45),
            hintStyle:
                _t(15.0, color: _ink3, weight: FontWeight.w500, height: 1.45),
            title: 'การวินิจฉัย',
            value: _dxDraft,
            hint: 'เช่น Hemorrhagic shock from femur fracture',
            maxLines: 12,
            onSaved: (v) => setState(() => _dxDraft = v),
          ),
        ),
        // พยาบาลคีย์แทน: แพทย์ผู้สั่ง (บังคับ) · ช่องเลือกแถวเดียว กะทัดรัด
        if (ErSession.instance.isNurse) ...[
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 6.0),
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: 'รับคำสั่งจากแพทย์',
                  style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
              TextSpan(
                  text: ' *',
                  style: _t(13.0, color: _red, weight: FontWeight.w700)),
            ])),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: LayoutBuilder(
              builder: (context, box) => PopupMenuButton<String>(
                tooltip: 'รับคำสั่งจากแพทย์',
                position: PopupMenuPosition.under,
                // เมนูกว้างเท่าช่อง ชิดซ้ายตรงกับช่อง
                constraints: BoxConstraints(
                    minWidth: box.maxWidth, maxWidth: box.maxWidth),
                color: _panel,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                onSelected: (d) => setState(() {
                  _dxOrderBy = d;
                  _dxOrderMiss = false;
                }),
                itemBuilder: (context) => [
                  for (final d in _dxDoctors)
                    PopupMenuItem<String>(
                      value: d,
                      height: 52.0,
                      child: Row(children: [
                        _docAvatar(d, 32.0),
                        const SizedBox(width: 12.0),
                        Expanded(child: _docName(d)),
                        if (_dxOrderBy == d)
                          const Icon(Icons.check_rounded,
                              size: 18.0, color: _blue),
                      ]),
                    ),
                ],
                // ช่องเลือกแบบช่องกรอกฟอร์ม: พื้นขาว ขอบเทา มุม 12 · วงชื่อย่อแพทย์ + ชื่อ + ลูกศร
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 56.0,
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 12.0, 0.0),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                        color: _dxOrderMiss && _dxOrderBy == null
                            ? _red
                            : const Color(0xFFDADCE0),
                        width: _dxOrderMiss && _dxOrderBy == null ? 1.5 : 1.0),
                  ),
                  child: Row(children: [
                    _dxOrderBy == null
                        ? Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: _panelSoft),
                            child: const Icon(Icons.person_outline_rounded,
                                size: 20.0, color: _ink3),
                          )
                        : _docAvatar(_dxOrderBy!, 36.0),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: _dxOrderBy == null
                          ? Text('เลือกแพทย์ผู้สั่ง',
                              style: _t(15.0,
                                  color: _ink3, weight: FontWeight.w500))
                          : _docName(_dxOrderBy!, size: 15.0, bold: true),
                    ),
                    const Icon(Icons.unfold_more_rounded,
                        size: 20.0, color: _ink3),
                  ]),
                ),
              ),
            ),
          ),
          if (_dxOrderMiss && _dxOrderBy == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 6.0, 0.0, 0.0),
              child: Text('ต้องเลือกแพทย์ผู้สั่งก่อนบันทึก',
                  style: _t(12.5, color: _red, weight: FontWeight.w600)),
            ),
        ],
        // แก้รายการเดิม: ปุ่มลบใต้ช่อง (ปุ่มรอง สีแดง ไม่แย่งปุ่มบันทึก)
        if (i >= 0)
          Padding(
            // เต็มกว้างเท่าช่องข้อความ
            padding: const EdgeInsets.only(left: 4.0, top: 12.0),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _dxDeleteAsk(i),
                // ปุ่ม tonal แดงจาง (มีพื้น) เต็มกว้าง
                style: TextButton.styleFrom(
                  foregroundColor: _red,
                  backgroundColor: _red.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  minimumSize: const Size(0.0, 48.0),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20.0),
                label: Text('ลบรายการนี้',
                    style: _t(14.0, color: _red, weight: FontWeight.w600)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _dxPage(String pg) {
    final st = _speechStep;
    final dx = _filled[st][_dxTextLabel];
    final icd = _filled[st][_icd10Label];
    final icd9 = _filled[st][_icd9DxLabel];
    // ICD-10 ที่ถูกเขียนรวมบรรทัด (ผู้ช่วย/ตัวเลือก) → เก็บใหม่เป็นบรรทัดละรหัส
    if (icd != null) {
      final split = _multiItems(icd, icd: true).join('\n');
      if (split != icd.trim()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _filled[st][_icd10Label] == icd) {
            setState(() => _filled[st][_icd10Label] = split);
          }
        });
      }
    }
    // AI แนะนำรหัส: แพทย์เลือกกดเอง (ไม่เรียกอัตโนมัติ)
    final lists = <Widget>[
      // Diagnosis Text (Figma 425:67): หัวการ์ด + คำอธิบาย · ภาพแพทย์มุมขวาบน
      // การ์ดและแผ่นด้านในมุมโค้ง 16 ทั้งหน้า
      _dxCard(
        'Diagnosis Text',
        'คำวินิจฉัยของแพทย์ ลงได้หลายรายการ',
        // ขอบล่างจางหาย + หูฟัง 3D ทับวงหูฟังในภาพ (shimmer)
        // วงในภาพ: กลาง (195, 233) รัศมี ~34 ของภาพ 512 · ภาพ cover กว้าง 150 = ×0.293
        Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: _dxArtFade(Image.asset('assets/images/er_dx_doctor_t.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium)),
          ),
          const Positioned(
            left: 57.1 - 32.0,
            top: 68.3 - 32.0,
            width: 64.0,
            height: 64.0,
            child: IgnorePointer(child: _StethoBeat()),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _multiSection(_dxTextLabel, dx, true, tiles: true, tileActions: [
            (Icons.post_add_rounded, 'เทมเพลต', _pickDxTemplate),
            (Icons.history_rounded, 'Re-Diag', _openReDiag),
          ]),
          // ICD-10 ในการ์ดเดียวกัน: รหัสที่ผูกอยู่ใต้คำวินิจฉัยแล้ว · ที่นี่ = รหัสที่ไม่ผูก + เพิ่มรหัส
          _icdLooseSection(),
        ]),
        nudge: const {_dxTextLabel, _icd10Label},
      ),
    ];
    // ไม่มีหัวหน้าซ้ำ: ชื่อแผง + stepper บอกอยู่แล้วว่าอยู่หน้าไหน
    // เหลือแค่หัวส่วนบรรทัดเดียว (Dr.Note / Diagnosis Text / ICD-10 ...) ปุ่มอยู่ท้ายส่วน
    final kids = pg == 'more'
        ? <Widget>[
            // Doctor Note ขึ้นก่อน (แพทย์เขียนบ่อยกว่า) แล้วจึง ICD-9-CM
            _dxCard(
              'Doctor Note',
              'บันทึกเพิ่มเติมของแพทย์ ไม่บังคับ',
              // Figma 477:101 มือเขียนบนคลิปบอร์ด (เคลื่อนไหว)
              // ชิดขอบบนการ์ด: แขนเสื้อยื่นลงมาจากขอบ
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 10.0, 0.0),
                child: _dxArtFade(const _NoteArt()),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _dxTiles([
                  // เพิ่ม = หน้าย่อย Doctor Note (พูดได้จากไมค์ที่ footer) · ไอคอน Phosphor ชุดเดียวกับการ์ดอื่น
                  (Icons.add_rounded, 'เพิ่ม', _openNoteEdit),
                  (Icons.post_add_rounded, 'เทมเพลต', _pickNoteTemplate),
                ]),
                // บันทึกแล้ว: แถวแบบรายการ Diagnosis Text (ข้อความ ≤ 3 บรรทัด ·
                // ผู้เขียน + เวลา · ปุ่มแก้ขวา · แตะแถว = หน้าย่อยแก้)
                if (_filled[_speechStep][_noteLabel] case final note?)
                  _gListRow(
                    first: true,
                    inset: 8.0,
                    titleLines: 3,
                    title: note,
                    sub: [
                      if (_byMap(_noteLabel)['note'] case final who?) who,
                      if (_atMap(_noteLabel)['note'] case final t?) _clock(t),
                    ].join('  '),
                    onTap: _openNoteEdit,
                    trail: IconButton(
                      onPressed: _openNoteEdit,
                      tooltip: 'แก้ Doctor Note',
                      iconSize: 20.0,
                      constraints:
                          const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                      icon: const Icon(Icons.edit_outlined, color: _ink3),
                    ),
                  ),
                // ระยะล่าง = ขอบข้าง (แผ่นปุ่มมี margin ล่าง 8 อยู่แล้ว) · มีแถวบันทึก = เว้นเพิ่ม
                if (_filled[_speechStep][_noteLabel] != null)
                  const SizedBox(height: 8.0),
              ]),
              nudge: const {_noteLabel, _icd9DxLabel},
            ),
            const SizedBox(height: 12.0),
            // การ์ดแบบหน้าโรคและรหัส: หัว + คำอธิบาย · แผ่นปุ่มลัด · รายการที่ลงแล้ว
            _dxCard(
              'ICD-9-CM',
              'รหัสหัตถการ ไม่บังคับ ลงได้หลายรายการ',
              // ภาพประกอบชุดเดียวกับการ์ด ICD-10
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 10.0, 16.0, 0.0),
                child: _dxArtFade(const _IcdPaperArt(label: 'ICD-9-CM')),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // รหัสจากขั้นหัตถการลงให้เอง (ไม่มีปุ่มดึง) · เอาออกแล้วไม่ลงซ้ำ
                Builder(builder: (_) {
                  _icd9AutoFromProc();
                  return _multiSection(_icd9DxLabel, icd9, true, tiles: true);
                }),
              ]),
              nudge: const {_noteLabel, _icd9DxLabel},
            ),
          ]
        // ข้อเสนอ Dr.Note อยู่บนสุดเสมอ (ไม่สลับตำแหน่งตามข้อมูล = ไม่กระโดดใต้นิ้ว)
        // ไม่มีเส้นคั่นระหว่างการ์ด AI กับการ์ด Diagnosis Text (เว้นระยะแทน)
        // AI ช่วยวินิจฉัยย้ายไปเป็นปุ่ม "กรอกอัตโนมัติ" ในหน้าพิมพ์ Diagnosis Text
        : <Widget>[...lists];
    // หน้าย่อย Diagnosis Text: เลื่อนเข้าจากขวาทับหน้ารายการ (กลับ = เลื่อนออก)
    final main = ListView(
      // key ตามหน้า: เปลี่ยนหน้า = เริ่มบนสุดเสมอ (design rule)
      key: ValueKey('dx-page-$st-$pg'),
      // เผื่อที่ใต้ปุ่มลอย: เลื่อนเนื้อหาสุดท้ายขึ้นพ้นปุ่มได้ (แบบซักประวัติ)
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 96.0),
      children: [
        // เนื้อหาลอยขึ้นทีละชิ้นเมื่อเข้าหน้า (แบบซักประวัติ)
        for (final (i, w) in kids.indexed)
          _Appear(key: ValueKey('dx-$pg-$i'), index: i, child: w),
      ],
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (cur, prev) =>
          Stack(children: [...prev, if (cur != null) cur]),
      transitionBuilder: (child, anim) {
        final isEdit = child.key is ValueKey &&
            '${(child.key as ValueKey).value}'.startsWith('dx-edit');
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: Offset(isEdit ? 0.18 : -0.18, 0.0), end: Offset.zero)
                .animate(anim),
            child: child,
          ),
        );
      },
      child: _noteEdit && pg == 'more'
          ? _noteEditPage()
          : _reDiagOpen && pg == 'dx'
              ? _reDiagPage(pick: true)
              : _dxEdit != null && pg == 'dx'
                  ? _dxEditPage()
                  : main,
    );
  }

  /// ไอคอน Diagnosis Text: ภาพประกอบในวงฟ้าอ่อน (ขนาดเท่า _gLead) · add = ป้าย + มุมขวาล่าง
  Widget _dxTextArt(double size, {bool add = false}) => SizedBox(
        width: size,
        height: size,
        child: Stack(clipBehavior: Clip.none, children: [
          // ไม่มีวงพื้นหลัง (แบบแฟ้มหนีบการ์ดคำสั่ง) ภาพเต็มช่อง ขยายเกินขอบเล็กน้อย
          Positioned(
            left: -size * 0.12,
            top: -size * 0.12,
            width: size * 1.24,
            height: size * 1.24,
            child: const _DxDocIcon(),
          ),
          if (add)
            Positioned(
              right: -2.0,
              bottom: -2.0,
              child: Container(
                width: size * 0.36,
                height: size * 0.36,
                decoration: BoxDecoration(
                  color: _blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: _panel, width: 2.0),
                ),
                child: Icon(Icons.add_rounded,
                    size: size * 0.26, color: Colors.white),
              ),
            ),
        ]),
      );

  /// รายการของช่องหลายค่า: แตะแถวเพื่อแก้ · ถังขยะลบ · ปุ่มล่างเพิ่ม
  /// Diagnosis Text มีปุ่ม "เลือกจาก Template" ของแพทย์ที่ login อยู่
  Widget _multiList(String label, String? value,
      {bool big = false, bool fill = false}) {
    // ICD-10 ที่ถูกเขียนรวมบรรทัด (ผู้ช่วย/ตัวเลือก) → เก็บใหม่เป็นบรรทัดละรหัส
    if (label == _icd10Label && value != null) {
      final split = _multiItems(value, icd: true).join('\n');
      if (split != value.trim()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _filled[_speechStep][_icd10Label] == value) {
            setState(() => _filled[_speechStep][_icd10Label] = split);
          }
        });
      }
    }
    final Widget list;
    if (label == _icd10Label && _hasDxText(_speechStep)) {
      // หัวข้อส่วน (Google style): ชื่อ + จำนวนรายการชิดขวา · ปุ่มของส่วนอยู่ท้ายรายการ
      Widget head(String t, int n) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(children: [
              Expanded(
                child: Text(t,
                    style: _t(big ? 15.0 : 11.0,
                        color: _inkTitle, weight: FontWeight.w600)),
              ),
              if (n > 0)
                Text('$n รายการ',
                    style: _t(big ? 12.5 : 9.0,
                        color: _ink3, weight: FontWeight.w500)),
            ]),
          );
      Widget gap() => Padding(
            padding: EdgeInsets.symmetric(vertical: big ? 16.0 : 8.0),
            child: const Divider(height: 1.0, color: _line),
          );
      final dx = _filled[_speechStep][_dxTextLabel];
      final aiIcd =
          !(_icdAi[_icdAiKey] == null && _icdAi.containsKey(_icdAiKey));
      list = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        // ลำดับหัวข้อ: Dr.Note ช่วยคิด, 1 Diagnosis Text, 2 ICD-10, 3 ICD-9-CM, 4 Doctor Note
        children: [
          // Template ลง Diagnosis Text + ICD-10 พร้อมกัน · Re-Diag ดึงวินิจฉัยจาก visit ก่อนหน้า
          head('Diagnosis Text', _multiItems(dx).length),
          _multiSection(_dxTextLabel, dx, big, extra: [
            _miniBtn(Icons.bookmarks_rounded, 'Template', _pickDxTemplate,
                tooltip: 'เลือกจาก Template (Diagnosis Text + ICD-10)'),
            _reDiagBtn(),
          ]),
          gap(),
          head('รหัส ICD-10', _multiItems(value, icd: true).length),
          _multiSection(_icd10Label, value, big, extra: [
            if (aiIcd)
              _miniBtn(Icons.auto_awesome_rounded, 'AI แนะนำ', _icdSuggest,
                  tooltip: 'ให้ AI (Gemma) แนะนำรหัสจาก Diagnosis Text'),
          ]),
          // ผล AI แนะนำอยู่ใต้ปุ่ม (ต่อจากที่กด)
          Padding(
            padding: EdgeInsets.only(top: big ? 8.0 : 4.0),
            child: _icdAiChips(big),
          ),
          gap(),
          // ICD-9-CM หัตถการ (ไม่บังคับ) · มีชิปรหัสที่ลงไว้ในขั้นหัตถการให้แตะเพิ่ม
          head('รหัส ICD-9-CM',
              _multiItems(_filled[_speechStep][_icd9DxLabel]).length),
          _multiSection(_icd9DxLabel, _filled[_speechStep][_icd9DxLabel], big),
          _icd9FromProcChips(big),
          gap(),
          // Doctor Note: พิมพ์เอง พูด (แปลงเสียง) หรือ Template
          head('Doctor Note', 0),
          _noteSection(big),
          SizedBox(height: big ? 8.0 : 5.0),
          Wrap(spacing: 8.0, runSpacing: 0.0, children: [
            _miniBtn(Icons.mic_rounded, 'พูด', () => _editNote(autoMic: true),
                tooltip: 'พูดแล้วแปลงเป็นข้อความ'),
            _miniBtn(Icons.bookmarks_rounded, 'Template', _pickNoteTemplate,
                tooltip: 'เลือกจาก Template Doctor Note'),
          ]),
          SizedBox(height: big ? 16.0 : 8.0),
        ],
      );
    } else {
      list = _multiSection(label, value, big, template: true);
    }
    return fill ? SingleChildScrollView(child: list) : list;
  }

  /// การ์ดหน้าวินิจฉัย (Figma 425:67): หัวข้อ + คำอธิบายซ้าย · รูปประกอบมุมขวาบน
  /// เนื้อหา (แผ่นปุ่มลัด + รายการ) ชิดขอบการ์ด 8 วางทับรูปได้
  /// แผ่นปุ่มลัดแบบการ์ดวินิจฉัย (ขาว ขอบ 0.5 มุม 16 · ไอคอนบน ชื่อล่าง แบ่งช่องเท่ากัน)
  /// แคบ (ช่องละ < 96) = เรียงเป็นแถว: ไอคอนซ้าย ชื่อขวา มีเส้นคั่น
  /// tap = null: ปุ่มจาง กดไม่ได้
  Widget _dxTiles(List<(IconData, String, VoidCallback?)> actions) {
    // ปิดอยู่ = ไอคอน/ข้อความสีเทา (ไม่ใช่จางทั้งปุ่ม)
    Widget ic(IconData icon, String text, double size, {bool off = false}) =>
        _solarIcons.containsKey(text)
            ? _SolarIcon(text,
                size: size + 2.0, stroke: 1.5, color: off ? _g5 : _blue)
            : Icon(icon, size: size, color: off ? _g5 : _blue);
    return LayoutBuilder(builder: (context, box) {
      final rows = box.maxWidth / actions.length < 96.0;
      return Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: rows
            ? const EdgeInsets.symmetric(horizontal: 4.0)
            : const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: rows
            ? Column(children: [
                for (final (k, (icon, text, tap)) in actions.indexed)
                  SizedBox(
                      child: _Press(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: tap,
                      child: Container(
                        height: 52.0,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          border: k == 0
                              ? null
                              : const Border(
                                  top: BorderSide(
                                      color: Color(0xFFE8EAED), width: 0.5)),
                        ),
                        child: Row(children: [
                          SizedBox(
                              width: 28.0,
                              child: Center(
                                  child:
                                      ic(icon, text, 22.0, off: tap == null))),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(13.5,
                                    color: _inkTitle, weight: FontWeight.w600)),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 20.0, color: _ink3),
                        ]),
                      ),
                    ),
                  )),
              ])
            : Row(children: [
                for (final (icon, text, tap) in actions)
                  Expanded(
                      child: SizedBox(
                    child: _Press(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: tap,
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          SizedBox(
                            width: 36.0,
                            height: 36.0,
                            child: Center(
                                child: ic(icon, text, 22.0, off: tap == null)),
                          ),
                          const SizedBox(height: 2.0),
                          Text(text,
                              style: _t(13.0,
                                  color: tap == null ? _g5 : _inkTitle,
                                  weight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  )),
              ]),
      );
    });
  }

  // แคบ (< 280) = ซ่อนภาพประกอบ คำอธิบายใช้ความกว้างเต็ม
  /// trail = ปุ่มรองท้ายแถวหัวการ์ด (เช่น "ที่มาของคะแนน") · ไม่ใส่ในช่องภาพเพราะหัวข้อทับรับแตะ
  /// nudge = ช่องของการ์ดนี้ (ไปช่องที่ขาดแล้วกวาดแสงแดงเฉพาะการ์ดที่ขาด · ว่าง = ทุกการ์ดของหน้า)
  Widget _dxCard(String title, String sub, Widget art, Widget body,
          {Widget? trail, Set<String> nudge = const {}}) =>
      _wfNudgeOn(_dxCardBody(title, sub, art, body, trail: trail), nudge);

  Widget _dxCardBody(String title, String sub, Widget art, Widget body,
          {Widget? trail}) =>
      LayoutBuilder(builder: (context, box) {
        // ไม่มีภาพ (SizedBox.shrink) = คำอธิบายใช้ความกว้างเต็ม
        final showArt = box.maxWidth >= 280.0 &&
            !(art is SizedBox && art.width == 0.0 && art.height == 0.0);
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child: Stack(children: [
            if (showArt)
              Positioned(
                  right: -8.0,
                  top: 0.0,
                  width: 150.0,
                  height: 110.0,
                  child: art),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(children: [
                        Expanded(
                          child: Text(title,
                              style: _t(17.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                        ),
                        if (trail != null) trail,
                      ]),
                    ),
                    // ไม่มีคำอธิบาย = ไม่เว้นบรรทัดว่าง
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, right: showArt ? 130.0 : 8.0),
                        child: Text(sub,
                            style: _t(12.5,
                                color: _ink3, weight: FontWeight.w500)),
                      ),
                    ],
                    SizedBox(height: sub.isEmpty ? 12.0 : 16.0),
                    body,
                  ]),
            ),
          ]),
        );
      });

  /// รูปประกอบการ์ด: ขอบล่างจางหาย
  Widget _dxArtFade(Widget child) => ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
          stops: [0.0, 0.45, 1.0],
        ).createShader(r),
        child: child,
      );

  /// รายการของช่องหลายค่าหนึ่งช่อง + ปุ่มเพิ่ม (template = แสดงปุ่ม Template ต่อท้าย)
  Widget _multiSection(String label, String? value, bool big,
      {bool template = false,
      List<Widget> extra = const [],
      bool tiles = false,
      List<(IconData, String, VoidCallback?)> tileActions = const []}) {
    // โหมด tiles + ปุ่มลัด: "เพิ่ม" รวมเป็นช่องแรกของแผ่นปุ่ม (ไม่มีแถวเพิ่มแยก)
    final addInGrid = tiles;
    // tiles = แถวละแผ่นทึบมุมโค้ง (Figma 425:67) วางทับภาพประกอบในการ์ดได้ · ไม่มีเส้นคั่น
    Widget tile(Widget w) => !tiles
        ? w
        : Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            // แผ่นขาวขอบบาง ให้ปุ่มวงกลมสี surface (_bg) เด่นบนพื้น
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: w,
          );
    final icd = label == _icd10Label;
    final icd9 = label == _icd9DxLabel;
    final items = _multiItems(value, icd: icd);
    final codes =
        icd ? _icd10Codes() : (icd9 ? _icd9Codes() : const <String, String>{});
    final by = _byMap(label);
    final keyed = _keyedByMap(label);
    final at = _atMap(label);
    // รายการที่ยังไม่มีผู้บันทึก (เช่น ผู้ช่วยเติมจากเสียง) = แพทย์ที่ login อยู่
    if (ErSession.instance.user != null &&
        items.any((x) => by[x] == null || at[x] == null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _stampBy(label, items));
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // แผ่นปุ่มลัดอยู่บน · รายการที่ลงแล้วแสดงด้านล่าง
        // Figma 425:78: แผ่นปุ่มลัด แบ่งช่องเท่ากัน วงไอคอนบน + ชื่อล่าง
        if (tiles)
          // แผ่นปุ่มชุดเดียวกับการ์ดอื่น (แคบ = เรียงเป็นแถว)
          _dxTiles([
            (
              Icons.add_rounded,
              'เพิ่ม',
              () => icd
                  ? _pickIcd10(null)
                  : (icd9 ? _pickIcd9(null) : _editDxText(null))
            ),
            ...tileActions,
          ]),
        // แถวแบบ V/S ในซักประวัติ: เลข/ประเภทหน้าแถว · รหัส + ชื่อ · ผู้วินิจฉัย · ถังขยะขวา
        // ICD-10 ที่ลงแล้ว (แบบ cis-redesign-2026 DxRow ยืนยันแล้ว): พื้นเขียวจาง · เช็กเขียว
        // รหัสตัวหนา + ชื่อ · เลข Type (แตะเปลี่ยนได้) · ✕ ลบ · แตะแถว = แก้
        if (icd && big)
          // กดค้างแล้วลากเพื่อเรียงลำดับ (ตัวแรก = วินิจฉัยหลัก Type 1)
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, _, anim) => Material(
              color: Colors.transparent,
              elevation: 6.0 * anim.value,
              shadowColor: const Color(0x330B1B3F),
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            ),
            onReorder: (from, to) {
              if (to > from) to--;
              final next = [...items];
              next.insert(to, next.removeAt(from));
              _setMulti(label, next);
            },
            // แถวแบบรายการ Diagnosis Text: รหัส + ชื่อ (2 บรรทัด) · ผู้วินิจฉัย + เวลา
            // หน้า = เลข Type (แตะเปลี่ยน) · ขวา = รหัส · แตะแถว = แก้ · กดค้างที่แถวแล้วลาก = เรียงลำดับ
            children: [
              for (var i = 0; i < items.length; i++)
                ReorderableDelayedDragStartListener(
                  key: ValueKey('icd-${items[i]}'),
                  index: i,
                  child: Material(
                    color: _panel,
                    child: _gListRow(
                      first: i == 0,
                      inset: 8.0,
                      titleLines: 2,
                      title: _icdRowSplit(items[i], codes).$2,
                      // ที่มา: Diagnosis Text ที่ผูกอยู่ (ไม่มี = เพิ่มเอง)
                      // ชื่อรหัสตรงกับคำวินิจฉัยอยู่แล้ว = ไม่ต้องซ้ำ
                      sub: switch (_icdSrcMap()[items[i]]) {
                        final d?
                            when d.toLowerCase() !=
                                _icdRowSplit(items[i], codes)
                                    .$2
                                    .toLowerCase() =>
                          'จาก: $d',
                        _ => '',
                      },
                      lead: _diagTypePill(items, i, big),
                      onTap: () => _openIcdEdit(i),
                      // รหัสตัวหนาชิดขวา (แตะทั้งแถวเพื่อแก้ ไม่มีดินสอ)
                      trail: Text(_icdRowSplit(items[i], codes).$1,
                          style: _num(15.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                  ),
                )
            ],
          )
        else if (icd9 && tiles)
          // ICD-9-CM: การ์ดละรหัสแบบเดียวกับ ICD-10 ในหน้าพิมพ์ Diagnosis Text
          for (var i = 0; i < items.length; i++)
            _icd9Card(i, items, codes, by, at)
        else
          for (var i = 0; i < items.length; i++)
            // โหมด tiles (การ์ด Diagnosis Text): แถวแบบรายการคำสั่งแพทย์
            // ไม่มีไอคอนหน้า ไม่มีแผ่นพื้น · เส้นคั่นระหว่างแถว ขอบใน 8
            // Diagnosis Text (การ์ดรวม): ใต้แถว = รหัส ICD-10 ที่ผูกอยู่ (กติกาข้อ 69)
            _dxWithCodes(
                label,
                items[i],
                tiles,
                (tiles ? (Widget w) => w : tile)(_gListRow(
                  first: i == 0,
                  compact: !big,
                  inset: tiles ? 8.0 : 0.0,
                  // ข้อความยาว: ไม่เกิน 2 บรรทัด (แตะเพื่อดู/แก้เต็ม)
                  titleLines: tiles ? 2 : null,
                  lead: tiles
                      ? null
                      : icd
                          ? _diagTypePill(items, i, big)
                          : icd9
                              ? _gLead(Icons.assignment_outlined,
                                  size: big ? 40.0 : 32.0)
                              : _dxTextArt(big ? 40.0 : 32.0),
                  title: [
                    if (codes[items[i]] case final code?) code,
                    items[i],
                  ].join('  '),
                  // tiles: ผู้วินิจฉัย + เวลาวินิจฉัยเสมอ · แบบอื่น: แสดงเฉพาะแพทย์คนอื่น
                  sub: tiles && by[items[i]] != null
                      ? [
                          by[items[i]]!,
                          if (at[items[i]] case final t?) _clock(t),
                          // พยาบาลคีย์แทน
                          if (keyed[items[i]] case final k?) 'คีย์แทนโดย $k',
                        ].join('  ')
                      : by[items[i]] == null ||
                              by[items[i]] == ErSession.instance.user?.name
                          ? 'แตะเพื่อแก้'
                          : 'วินิจฉัยโดย ${by[items[i]]}',
                  onTap: () => icd
                      ? _pickIcd10(i)
                      : (icd9 ? _pickIcd9(i) : _editDxText(i)),
                  // tiles: ปุ่มขวา = แก้ (ลบได้ในหน้าแก้ โดยลบข้อความทั้งหมด)
                  trail: tiles
                      ? IconButton(
                          onPressed: () => icd
                              ? _pickIcd10(i)
                              : (icd9 ? _pickIcd9(i) : _editDxText(i)),
                          tooltip: 'แก้รายการนี้',
                          iconSize: big ? 20.0 : 16.0,
                          constraints: const BoxConstraints(
                              minWidth: 40.0, minHeight: 40.0),
                          icon: const Icon(Icons.edit_outlined, color: _ink3),
                        )
                      : IconButton(
                          onPressed: () async {
                            final name = items[i];
                            if (!await _askDelete('ลบรายการนี้?',
                                '$name จะถูกลบออกจาก$label', 'ลบรายการ')) {
                              return;
                            }
                            _setMulti(label, items..remove(name));
                          },
                          tooltip: 'ลบรายการนี้',
                          iconSize: big ? 20.0 : 16.0,
                          constraints: const BoxConstraints(
                              minWidth: 40.0, minHeight: 40.0),
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: _ink3),
                        ),
                ))),
        // เพิ่ม = แถวเต็มกว้างท้ายรายการ (แตะง่ายกว่าปุ่มเล็ก) ภาษาเดียวกับแถวรายการ
        if (!addInGrid)
          // แผ่นเพิ่มรายการ: ปุ่มเทมเพลต/Re-Diag อยู่ในแผ่นเดียวกัน (โหมด tiles)
          tile(
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _gListRow(
              first: tiles || items.isEmpty,
              compact: !big,
              // Diagnosis Text: ภาพเอกสาร + ดินสอ (Figma 425:56) ไม่มีป้าย + · อื่น ๆ = วง +
              lead: !icd && !icd9
                  ? _dxTextArt(big ? 40.0 : 32.0)
                  : _gLead(Icons.add_rounded, size: big ? 40.0 : 32.0),
              title: icd
                  ? 'เพิ่มรหัส ICD-10'
                  : (icd9 ? 'เพิ่มรหัส ICD-9-CM' : 'เพิ่ม Diagnosis Text'),
              sub: icd
                  ? 'ค้นจากชื่อโรคหรือรหัส'
                  : (icd9
                      ? 'ค้นจากชื่อหัตถการหรือรหัส'
                      : 'พิมพ์หรือพูดคำวินิจฉัย'),
              onTap: () => icd
                  ? _pickIcd10(null)
                  : (icd9 ? _pickIcd9(null) : _editDxText(null)),
              trail: const SizedBox.shrink(),
            ),
          ])),
        if (((template && !icd) || extra.isNotEmpty) && !tiles)
          Wrap(spacing: 8.0, runSpacing: 0.0, children: [
            if (template && !icd)
              _multiAddBtn(Icons.bookmarks_rounded, 'เลือกจาก Template', big,
                  _pickDxTemplate),
            ...extra,
          ]),
      ],
    );
  }

  Widget _multiAddBtn(
          IconData icon, String text, bool big, VoidCallback onTap) =>
      _Press(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100.0),
          child: Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: _blue.withValues(alpha: 0.5)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16.0, color: _blue),
              const SizedBox(width: 5.0),
              Text(text,
                  style: _t(big ? 12.0 : 10.0,
                      color: _blue, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  /// ปุ่มรองเล็ก (Google tonal): พื้นฟ้าอ่อน ตัวกรมท่า ไม่มีขอบ มุม pill
  /// ตัวปุ่มสูง 32 แต่พื้นที่แตะสูง 40 (กดง่ายตามกติกา)
  Widget _miniBtn(IconData icon, String text, VoidCallback onTap,
          {String? tooltip}) =>
      Tooltip(
        message: tooltip ?? text,
        child: _Press(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(100.0),
            child: SizedBox(
              height: 40.0,
              child: Center(
                widthFactor: 1.0,
                child: Container(
                  height: 32.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EAF8),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 16.0, color: _blue),
                    const SizedBox(width: 6.0),
                    Text(text,
                        style: _t(12.5, color: _blue, weight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );

  void _setMulti(String label, List<String> items) {
    final old = _filled[_speechStep][label];
    setState(() {
      _lastFilled = [(_speechStep, label, old)];
      if (items.isEmpty) {
        _filled[_speechStep].remove(label);
      } else {
        _filled[_speechStep][label] = items.join('\n');
      }
      _stampBy(label, items);
    });
    // ICD-10 ผูกกับ Diagnosis Text แบบหลวม (กติกาข้อ 69)
    if (label == _dxTextLabel) _icdSrcFollow(_multiItems(old), items);
    if (label == _icd10Label) {
      // รหัสที่ถูกลบออก = ลบที่มาทิ้ง
      final src = _icdSrcMap()..removeWhere((k, _) => !items.contains(k));
      _icdSrcSave(src);
    }
  }

  // ------------------------------------------------ ICD-10 ↔ Diagnosis Text (ผูกหลวม)

  /// แถว Diagnosis Text + pill รหัส ICD-10 ที่ผูกอยู่ (แตะ pill = แก้รหัสนั้น)
  Widget _dxWithCodes(String label, String dx, bool tiles, Widget row) {
    if (label != _dxTextLabel || !tiles) return row;
    final icd = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    final src = _icdSrcMap();
    final codes = _icd10Codes();
    final mine = [
      for (final (i, e) in icd.indexed)
        if (src[e] == dx) (i, e)
    ];
    if (mine.isEmpty) return row;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      row,
      Transform.translate(
        offset: const Offset(0.0, -6.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 6.0),
          child: Wrap(spacing: 6.0, runSpacing: 6.0, children: [
            for (final (i, e) in mine)
              _icdPill(i, codes[e] ?? _icdRowSplit(e, codes).$1, icd),
          ]),
        ),
      ),
    ]);
  }

  /// เลือกรหัส ICD-10 แบบ filter bottom sheet (หมวดซ้ายตามกลุ่มใน master · ค้นหา + รายการขวา)
  /// [exclude] = รหัสที่ไม่ให้เลือกซ้ำ · คืนค่ารายการ (ชื่อ master) ที่เลือก
  Future<String?> _icd10PickSheet(
      {Set<String> exclude = const {}, String? current, String? title}) async {
    const groups = [
      ('trauma', 'อุบัติเหตุ / บาดเจ็บ'),
      ('stroke', 'หลอดเลือดสมอง'),
      ('stemi', 'กล้ามเนื้อหัวใจขาดเลือด'),
      ('cardiac', 'หัวใจ'),
      ('resp', 'ระบบหายใจ'),
      ('sepsis', 'ติดเชื้อในกระแสเลือด'),
      ('infection', 'ติดเชื้อ'),
      ('gi', 'ทางเดินอาหาร'),
      ('metabolic', 'เมตาบอลิก'),
      ('allergy', 'แพ้'),
      ('symptom', 'อาการ / อาการแสดง'),
    ];
    // รหัสที่เลือกแล้วยังแสดง (จาง + "เลือกแล้ว") แต่เลือกซ้ำไม่ได้
    final items = [
      for (final it in ErMaster.maybe?.table('er_icd10')?.activeItems ??
          const <ErMasterItem>[])
        it
    ];
    String g(ErMasterItem it) => '${it.extra['group'] ?? ''}';
    final code = {for (final it in items) it.name: it.code};
    final cats = <(String, List<String>)>[
      ('ทั้งหมด', [for (final it in items) it.name]),
      for (final (k, th) in groups)
        if (items.any((it) => g(it) == k))
          (
            th,
            [
              for (final it in items)
                if (g(it) == k) it.name
            ]
          ),
      if (items.any((it) => !groups.any((x) => x.$1 == g(it))))
        (
          'อื่น ๆ',
          [
            for (final it in items)
              if (!groups.any((x) => x.$1 == g(it))) it.name
          ]
        ),
    ];
    String? picked;
    await _soFilterSheet(
      title: title ?? 'Diagnosis ICD-10',
      sub: '${items.length} รายการ',
      cats: cats,
      current: current,
      // รหัสนำ · ชื่อบรรทัดรอง
      label: (o) => code[o] ?? o,
      note: (o) => o,
      taken: exclude,
      onPick: (o) => picked = o,
    );
    return picked;
  }

  /// เลขประเภทรหัสเป็นเหรียญ: ตัวเดียวกับเหรียญสถานะคำสั่งแพทย์ (_SoStatusCoin)
  /// 1 หลัก = ฟ้า (แบบรอผล) · 2 โรคร่วม = ม่วงคราม · 3 = ม่วงอ่อน · อื่น = เทาเข้ม
  Widget _typeDot(String t, double d, {double tilt = 0.55}) {
    final (face, side) = switch (t) {
      '1' => (
          const [Color(0xFF8DB4FF), Color(0xFF3E73E6)],
          const [Color(0xFF2F5CC4), Color(0xFF1E3F94)]
        ),
      '2' => (
          const [Color(0xFFA9B4F5), Color(0xFF5C6BC0)],
          const [Color(0xFF4A57A8), Color(0xFF333E80)]
        ),
      '3' => (
          const [Color(0xFFC8CDF5), Color(0xFF8E99D6)],
          const [Color(0xFF6F7AB8), Color(0xFF545E96)]
        ),
      _ => (
          const [Color(0xFFB9BEC6), Color(0xFF6B7280)],
          const [Color(0xFF575E69), Color(0xFF3E444D)]
        ),
    };
    // เหรียญต้นแบบ 36 · ย่อตามขนาดที่ต้องการ
    return SizedBox.square(
      dimension: d,
      child: FittedBox(
          child: _SoStatusCoin.label(t, face: face, side: side, tilt: tilt)),
    );
  }

  /// แถวเลือกรหัส ICD-10 ในหน้าพิมพ์ Diagnosis Text: pill รหัสที่เลือก (แตะ = เอาออก) + เลือกรหัส
  Widget _dxCodeRow(VoidCallback rebuild) {
    final codes = _icd10Codes();
    Future<void> add() async {
      final name = await _icd10PickSheet(exclude: {..._dxDraftCodes});
      if (name == null || !mounted) return;
      _dxDraftCodes = [..._dxDraftCodes, name];
      rebuild();
    }

    // ประเภทรหัสตามลำดับในช่อง ICD-10 ทั้งเคส (รหัสใหม่ต่อท้าย · กติกาข้อ 44)
    final all = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    final sim0 = [
      ...all,
      for (final e in _dxDraftCodes)
        if (!all.contains(e)) e
    ];
    // เลือก Principal (1) ในหน้านี้ = ขึ้นเป็นรหัสแรก (รหัสแรกเดิมลงเป็น 2)
    final p1 = _dxDraftTypes.entries
        .where((x) => x.value == '1' && sim0.contains(x.key))
        .map((x) => x.key)
        .firstOrNull;
    final sim = p1 == null ? sim0 : [p1, ...sim0.where((x) => x != p1)];
    String typeOf(String e) {
      final i = sim.indexOf(e);
      if (i == 0) return '1';
      final d = _dxDraftTypes[e];
      return d != null && d != '1' ? d : _diagTypeOf(sim, i);
    }

    // ชื่อมาตรฐานจากข้อเสนอ AI (รหัสที่ไม่มีใน master)
    String aiName(String code) {
      for (final x in _dxAi[_dxKey]?.ideas ?? const <_DxIdea>[]) {
        if (x.icd.trim().toUpperCase() == code.toUpperCase() &&
            _dxIcdNameOf(x).isNotEmpty) {
          return _dxIcdNameOf(x);
        }
      }
      return '';
    }

    Future<void> pickType(String e) async {
      final cur = typeOf(e);
      // รหัสเดียวในเคส = ต้องเป็น Principal (กติกาข้อ 44) · ประเภทอื่นเลือกไม่ได้
      final only = sim.length == 1;
      // sheet กลางของ ER (_placedSheet): กว้างจำกัด ย้ายซ้าย/กลาง/ขวาได้ · เนื้อหาเลื่อนได้ (ไม่ล้น)
      final t = await _placedSheet<String>(
        context: context,
        constraints: const BoxConstraints(maxWidth: 560.0),
        builder: (ctx) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 10.0),
                    child: Text(
                        'ประเภทการวินิจฉัย ${codes[e] ?? _icdRowSplit(e, codes).$1}',
                        style: _t(17.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ),
                  if (only)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: Text(
                          'รหัสเดียวของเคสเป็น Principal Diagnosis เสมอ เพิ่มรหัสอื่นก่อนจึงเปลี่ยนได้',
                          style:
                              _t(12.5, color: _ink3, weight: FontWeight.w500)),
                    ),
                  for (final (n, en, th) in [
                    ..._diagTypes,
                    ('x', 'เอารหัสนี้ออก', 'ไม่ผูกรหัสนี้กับคำวินิจฉัยนี้'),
                  ])
                    Opacity(
                      opacity: only && n != '1' && n != 'x' ? 0.4 : 1.0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: only && n != '1' && n != 'x'
                            ? null
                            : () => Navigator.pop(ctx, n),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
                          child: Row(children: [
                            n == 'x'
                                ? const SizedBox.square(
                                    dimension: 26.0,
                                    child: Icon(Icons.delete_outline_rounded,
                                        size: 22.0, color: _ink2))
                                : _typeDot(n, 26.0),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(en,
                                        style: _t(14.5,
                                            color: _inkTitle,
                                            weight: FontWeight.w600)),
                                    Text(th,
                                        style: _t(12.5,
                                            color: _ink3,
                                            weight: FontWeight.w500)),
                                  ]),
                            ),
                            if (n == cur)
                              const Icon(Icons.check_rounded,
                                  size: 22.0, color: _blue),
                          ]),
                        ),
                      ),
                    ),
                ]),
          ),
        ),
      );
      if (t == null || !mounted) return;
      if (t == 'x') {
        if (!await _askDelete('เอารหัสนี้ออก?',
            '${codes[e] ?? e} จะไม่ผูกกับคำวินิจฉัยนี้', 'เอาออก')) {
          return;
        }
        _dxDraftCodes = [..._dxDraftCodes]..remove(e);
        _dxDraftTypes = {..._dxDraftTypes}..remove(e);
        rebuild();
        return;
      }
      // รอ sheet ปิดก่อนค่อยสลับ ให้เห็นแถวเลื่อนสลับที่ (ไม่โดน sheet บัง)
      if (t == cur) return;
      await Future.delayed(const Duration(milliseconds: 240));
      if (!mounted) return;
      // เปลี่ยนรหัสแรก (Principal) เป็นประเภทอื่น = รหัสถัดไปขึ้นเป็น Principal แทน
      final promote =
          sim.first == e && t != '1' && sim.length > 1 ? sim[1] : null;
      _dxDraftTypes = {
        for (final x in _dxDraftTypes.entries)
          if (!((t == '1' || promote != null) && x.value == '1'))
            x.key: x.value,
        e: t,
        if (promote != null) promote: '1',
      };
      rebuild();
    }

    // หัวข้อ ICD-10 + ปุ่มเพิ่มรหัสขวา · ใต้หัวข้อ = แถวละรหัส (มีได้หลายรหัส)
    // แถว: วงเลขประเภท · รหัสหนา · ชื่อเต็ม · ✕ เอาออก (ยืนยัน) · คั่นเส้นบาง
    // ชื่อที่เป็นคำวินิจฉัยเอง (รหัสที่ลงก่อนมีชื่อมาตรฐาน) = ไม่แสดงซ้ำ ให้เห็นแค่ชื่อมาตรฐานของรหัส
    final dxTexts = {
      for (final d in _multiItems(_filled[_speechStep][_dxTextLabel]))
        d.trim().toLowerCase(),
      _dxDraft.trim().toLowerCase(),
    };
    // การ์ดละรหัส (การ์ดในการ์ด: ขาว + เส้น 0.5) · เหรียญประเภทคร่อมมุมขวาบน (top offset)
    // บรรทัดบน = รหัสหนา + ชื่อ · ล่าง = ประเภท ⌄ (แตะการ์ด = เปลี่ยน) · ✕ เอาออก ขวาล่าง
    Widget row(String e, bool first) {
      final (code0, raw) = _icdRowSplit(e, codes);
      final code = codes[e] ?? code0;
      var name = dxTexts.contains(raw.trim().toLowerCase()) ? '' : raw;
      if (name.isEmpty) name = aiName(code);
      final t = typeOf(e);
      final tName = _diagTypes.firstWhere((d) => d.$1 == t).$2;
      return Padding(
        padding: EdgeInsets.only(top: first ? 8.0 : 8.0),
        child: Stack(clipBehavior: Clip.none, children: [
          Material(
            color: _panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: Color(0xFFDADCE0), width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            // แตะการ์ด = แผ่นประเภท (เปลี่ยนประเภท / เอารหัสออก)
            child: InkWell(
              onTap: () => pickType(e),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 8.0, 12.0),
                child: Row(children: [
                  // เหรียญประเภทซ้ายของข้อความ · เปลี่ยนเลข = เหรียญหมุนพลิก (เห็นความหนาขอบ)
                  _CoinFlip(
                      value: t,
                      builder: (v, tilt) => _typeDot(v, 36.0, tilt: tilt)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // บน = ประเภท · รหัส (เล็ก) · ล่าง = ชื่อโรค (หลัก)
                          Row(children: [
                            Text(tName,
                                style: _t(12.5,
                                    color: t == '1' ? _blue : _ink3,
                                    weight: FontWeight.w600)),
                            const SizedBox(width: 8.0),
                            // รหัส = ป้ายพื้นเทาจาง
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0, vertical: 1.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F4),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(code,
                                  style: _num(11.5,
                                      color: _ink2, weight: FontWeight.w700)),
                            ),
                          ]),
                          const SizedBox(height: 2.0),
                          if (name.isNotEmpty)
                            Text(name,
                                style: _t(14.5,
                                    color: _inkTitle,
                                    height: 1.3,
                                    weight: FontWeight.w600)),
                        ]),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 22.0, color: _ink3),
                ]),
              ),
            ),
          ),
        ]),
      );
    }

    // ปุ่มเพิ่มรหัส = แถวเต็มกว้างท้ายรายการ (เส้นบาง)
    final addRow = Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Material(
        color: _panel,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xFFDADCE0))),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: add,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_rounded, size: 20.0, color: _blue),
              const SizedBox(width: 6.0),
              Text('เพิ่มรหัส ICD-10',
                  style: _t(14.0, color: _blue, weight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text('ICD-10',
            style: _t(14.5, color: _inkTitle, weight: FontWeight.w700)),
      ),
      if (_dxDraftCodes.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6.0, left: 8.0),
          child: Text('ยังไม่ได้ผูกรหัสกับคำวินิจฉัยนี้',
              style: _t(13.0, color: _ink3, weight: FontWeight.w500)),
        )
      else
        for (final (k, e) in [
          for (final x in sim)
            if (_dxDraftCodes.contains(x)) x
        ].indexed)
          // เปลี่ยนเลขแล้วลำดับสลับ = แถวเลื่อนจากที่เดิมไปที่ใหม่ (ไม่กระโดด)
          _SwapSlide(
            key: ValueKey('icd-swap-$e'),
            child: _Appear(
                key: ValueKey('icd-row-$_dxAppearTick-$e'),
                index: k + 2,
                child: row(e, k == 0)),
          ),
      addRow,
    ]);
  }

  /// ส่วน ICD-10 ท้ายการ์ด Diagnosis Text: รหัสที่ไม่ผูกคำวินิจฉัย + ปุ่มเพิ่ม/AI แนะนำ
  Widget _icdLooseSection() {
    // ไม่มีแถวหัว/ปุ่มแยก (เพิ่มรหัสในหน้าพิมพ์คำวินิจฉัยแทน)
    // แสดงเฉพาะเมื่อมีรหัสที่ไม่ผูกคำวินิจฉัย (เช่น ลบคำวินิจฉัยแต่เก็บรหัสไว้) ให้ยังเห็นและแก้ได้
    final icd = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    final src = _icdSrcMap();
    final dx = _multiItems(_filled[_speechStep][_dxTextLabel]);
    final codes = _icd10Codes();
    final loose = [
      for (final (i, e) in icd.indexed)
        if (src[e] == null || !dx.contains(src[e])) (i, e)
    ];
    if (loose.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Divider(height: 1.0, thickness: 1.0, color: Color(0xFFE8EAED)),
        const SizedBox(height: 10.0),
        Text('รหัสที่ไม่ได้ผูกคำวินิจฉัย',
            style: _t(13.0, color: _ink2, weight: FontWeight.w700)),
        const SizedBox(height: 6.0),
        Wrap(spacing: 6.0, runSpacing: 6.0, children: [
          for (final (i, e) in loose)
            _icdPill(i, codes[e] ?? _icdRowSplit(e, codes).$1, icd),
        ]),
      ]),
    );
  }

  /// pill รหัส ICD-10: รหัสตัวหนา · Principal (Type 1) = พื้นกรมท่าอ่อน
  Widget _icdPill(int i, String code, List<String> icd) {
    // ทุกประเภทหน้าตาเดียวกัน: พื้นเทาจาง ไม่มีเส้น · เหรียญประเภท (ชุดเดียวกับหน้าพิมพ์) + รหัส + ชื่อประเภท
    final t = _diagTypeOf(icd, i);
    final tName = _diagTypes.firstWhere((d) => d.$1 == t).$2;
    return Material(
      color: const Color(0xFFF1F3F4),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openIcdEdit(i),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 12.0, 4.0),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _typeDot(t, 20.0),
            const SizedBox(width: 6.0),
            Text(code,
                style: _num(13.0, color: _blue, weight: FontWeight.w700)),
            const SizedBox(width: 6.0),
            Text(tName, style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  /// รหัส ICD-10 (ข้อความรายการ) → Diagnosis Text ที่เป็นที่มา
  Map<String, String> _icdSrcMap() => {
        for (final l
            in (_filled[_speechStep]['$_icd10Label - src'] ?? '').split('\n'))
          if (l.split('\t') case [final k, final v] when k.isNotEmpty) k: v
      };

  void _icdSrcSave(Map<String, String> m) {
    if (m.isEmpty) {
      _filled[_speechStep].remove('$_icd10Label - src');
    } else {
      _filled[_speechStep]['$_icd10Label - src'] =
          [for (final e in m.entries) '${e.key}\t${e.value}'].join('\n');
    }
  }

  /// ผูกรหัสกับคำวินิจฉัย (AI / Template ลงคู่กัน)
  void _icdLink(String entry, String dx) =>
      _icdSrcSave(_icdSrcMap()..[entry] = dx);

  /// Diagnosis Text เปลี่ยน: แก้ข้อความ (ตำแหน่งเดิม) = ผูกต่อกับข้อความใหม่
  /// ลบ = ลบรหัสที่ผูกอยู่ไปด้วย (ยืนยันลบคำวินิจฉัยแล้ว ไม่ถามซ้ำ)
  void _icdSrcFollow(List<String> before, List<String> after) {
    final src = _icdSrcMap();
    if (src.isEmpty) return;
    final gone = [
      for (final d in before)
        if (!after.contains(d)) d
    ];
    if (gone.isEmpty) return;
    final added = [
      for (final d in after)
        if (!before.contains(d)) d
    ];
    // แก้ข้อความ 1 รายการ = ย้ายการผูกไปข้อความใหม่
    if (gone.length == 1 && added.length == 1) {
      _icdSrcSave({
        for (final e in src.entries)
          e.key: e.value == gone.first ? added.first : e.value
      });
      return;
    }
    final linked = [
      for (final e in src.entries)
        if (gone.contains(e.value)) e.key
    ];
    // ลบคำวินิจฉัย = รหัสที่ผูกหายไปด้วย (ทำหลังเฟรมนี้ ไม่ซ้อน _setMulti)
    _icdSrcSave(src..removeWhere((_, v) => gone.contains(v)));
    final icd = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    final still = [
      for (final k in linked)
        if (icd.contains(k)) k
    ];
    if (still.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final now = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
      _setMulti(_icd10Label, now..removeWhere(still.contains));
    });
  }

  /// เลือกรหัส ICD-10 จาก master: แก้รายการที่ i หรือเพิ่มใหม่ (i = null)
  /// รหัสที่เลือกไว้แล้วไม่แสดงซ้ำ
  Future<void> _pickIcd10(int? i) async {
    final items = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    // เพิ่มรหัสใหม่ = filter bottom sheet แบ่งหมวด
    if (i == null) {
      final name = await _icd10PickSheet(exclude: {...items});
      if (name == null || !mounted) return;
      _setMulti(_icd10Label, [...items, name]);
      return;
    }
    final codes = _icd10Codes();
    final shown = {
      for (final e in codes.entries)
        if (!items.contains(e.key) || (i != null && items[i] == e.key))
          '${e.value} · ${e.key}': e.key
    };
    final cur = i == null ? null : items[i];
    // แก้รหัสเดิม: ตัวเลือกแรก = ลบรหัสนี้ (ยืนยันก่อน) · แถวไม่มีปุ่มลบแยก (แบบ Diagnosis Text)
    const del = 'ลบรหัสนี้ออก';
    final picked = await _listSheet(
        i == null ? _icd10Label : 'แก้ ${codes[cur] ?? ''} $cur',
        [if (i != null) del, ...shown.keys],
        current: cur == null ? null : '${codes[cur]} · $cur');
    if (picked == del && i != null && mounted) {
      final ok = await _askDelete(
          'ลบรหัส ICD-10 นี้?', '${codes[cur] ?? ''}  $cur', 'ลบรหัส');
      if (ok == true && mounted) _setMulti(_icd10Label, items..removeAt(i));
      return;
    }
    final name = shown[picked];
    if (name == null || !mounted) return;
    // เปลี่ยนรหัสในแถวเดิม: คงประเภท (diagtype) ของแถวนั้นไว้
    if (i != null) _storeDiagType(name, _diagTypeOf(items, i));
    _setMulti(_icd10Label, i == null ? [...items, name] : (items..[i] = name));
  }

  // ------------------------------------------------ ประเภทการวินิจฉัย (diagtype) ของ ICD-10

  /// ประเภทที่เก็บไว้: บรรทัดละ "ชื่อโรค<TAB>diagtype" (ไม่เก็บ Type 1 · คำนวณจากลำดับ)
  Map<String, String> _storedDiagTypes() => {
        for (final l in (_filled[_speechStep][_diagTypeKey] ?? '').split('\n'))
          if (l.split('\t') case [final n, final t]) n: t
      };

  void _storeDiagType(String name, String type) {
    final m = _storedDiagTypes()..[name] = type;
    _filled[_speechStep][_diagTypeKey] =
        [for (final e in m.entries) '${e.key}\t${e.value}'].join('\n');
  }

  /// รหัสแรกเป็น Principal (Type 1) เสมอและมีได้ตัวเดียว
  /// รหัสอื่นใช้ประเภทที่เลือกไว้ (ห้ามเป็น 1) ยังไม่เลือก = 2 Comorbidity
  String _diagTypeOf(List<String> items, int i) {
    if (i == 0) return '1';
    final t = _storedDiagTypes()[items[i]];
    return t == null || t == '1' || !_diagTypes.any((d) => d.$1 == t) ? '2' : t;
  }

  /// เลข Type หน้ารหัส (วงกลมเล็ก) · แสดงอย่างเดียว
  Widget _diagTypePill(List<String> items, int i, bool big) {
    final t = _diagTypeOf(items, i);
    final main = t == '1';
    final name = _diagTypes.firstWhere((d) => d.$1 == t).$2;
    final (bg, fg) = _diagTypeTone(t);
    // ขนาดใกล้ไอคอนวงของแถวอื่น (40) ให้ชื่อเรียงแนวเดียวกัน
    final d = big ? 30.0 : 16.0;
    // วงกลมตัวเลขอย่างเดียว · ชื่อประเภทดูได้จาก tooltip และรายการตอนแตะเปลี่ยน
    final badge = Container(
      width: d,
      height: d,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: bg == null ? null : _glossGrad(bg),
        color: bg == null ? _panel : null,
        border: bg == null ? Border.all(color: fg, width: 1.5) : null,
        boxShadow: bg == null ? null : _glossLift(bg),
      ),
      child: Text(t,
          style: _num(big ? 13.0 : 8.5, color: fg, weight: FontWeight.w700)),
    );
    // แสดงอย่างเดียว (2026-10-20): แตะทั้งแถว = หน้าแก้รหัส (เปลี่ยนประเภทในหน้านั้น)
    // ไม่เปิดแผ่นเลือกประเภทแยกอีก
    return Tooltip(
      message: 'Type $t · $name${main ? ' (รหัสแรก)' : ''}',
      child: SizedBox(
        width: big ? 40.0 : 32.0,
        height: 40.0,
        child: Center(child: badge),
      ),
    );
  }

  // ------------------------------------------------ แพทย์ผู้วินิจฉัยของแต่ละรายการ

  /// ผู้บันทึกของแต่ละรายการ: บรรทัดละ "รายการ<TAB>ชื่อแพทย์<TAB>เวลา" ในช่อง "<ช่อง> - by"
  Map<String, String> _byMap(String label) => {
        for (final p in _byRows(label))
          if (p.length >= 2) p[0]: p[1]
      };

  /// เวลาวินิจฉัยของแต่ละรายการ ("HH:MM")
  Map<String, String> _atMap(String label) => {
        for (final p in _byRows(label))
          if (p.length >= 3 && p[2].isNotEmpty) p[0]: p[2]
      };

  List<List<String>> _byRows(String label) => [
        for (final l in (_filled[_speechStep]['$label - by'] ?? '').split('\n'))
          if (l.contains('\t')) l.split('\t')
      ];

  /// ลงชื่อแพทย์ที่ login อยู่ + เวลาตอนนี้ ให้รายการที่ยังไม่มี (เรียกใน setState)
  void _stampBy(String label, Iterable<String> items) {
    final who = ErSession.instance.user?.name;
    if (who == null) return;
    final now = DateTime.now();
    final hhmm = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    final rows = {for (final p in _byRows(label)) p[0]: p};
    var changed = false;
    for (final it in items) {
      final p = rows[it];
      if (p == null || p.length < 2) {
        rows[it] = [it, who, hhmm];
        changed = true;
      } else if (p.length < 3 || p[2].isEmpty) {
        rows[it] = [p[0], p[1], hhmm];
        changed = true;
      }
    }
    if (changed) {
      _filled[_speechStep]['$label - by'] =
          [for (final p in rows.values) p.join('\t')].join('\n');
    }
  }

  /// บรรทัดเล็กใต้รายการ: แพทย์ผู้วินิจฉัย
  /// แสดงเฉพาะเมื่อผู้บันทึกไม่ใช่คนที่ login อยู่ (ของตัวเองไม่ต้องบอก ลดความรก)
  Widget _byLine(String? who, bool big) => who == null ||
          who == ErSession.instance.user?.name
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Row(children: [
            Icon(Icons.person_rounded, size: big ? 13.0 : 9.0, color: _ink3),
            const SizedBox(width: 3.0),
            Flexible(
              child: Text('วินิจฉัยโดย $who',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(big ? 11.5 : 8.0,
                      color: _ink3, weight: FontWeight.w500)),
            ),
          ]),
        );

  /// สีของเลข Type: ไล่เฉดตระกูล navy ตามกติกาสี (ห้ามเพิ่มสีใหม่) แยกกันด้วยความเข้ม
  /// 1 navy เข้มสุด · 2 navy กลาง · 3 navy อ่อน · 4 เทาเข้ม · 5 เทา · 6–7 วงโปร่ง (bg = null)
  (Color?, Color) _diagTypeTone(String t) => switch (t) {
        '1' => (_blue, Colors.white),
        '2' => (_blue3, Colors.white),
        '3' => (_blue4, _blueHue),
        '4' => (_ink2, Colors.white),
        '5' => (_ink3, Colors.white),
        '6' => (null, _blue),
        _ => (null, _ink2),
      };

  /// แก้ Diagnosis Text รายการที่ i หรือเพิ่มใหม่ (i = null) · บันทึกค่าว่าง = ลบรายการนั้น
  Future<void> _editDxText(int? i, {List<String> codes = const []}) async {
    final items = _multiItems(_filled[_speechStep][_dxTextLabel]);
    // ขั้นวินิจฉัย: เปิดเป็นหน้าย่อยในแผง (ไม่ใช่หน้าต่างลอย)
    // แพทย์: เข้าหน้าพิมพ์ใน workflow ทันที (แบบ HPI) ไม่ผ่านหน้าย่อยที่มีกล่องให้แตะอีกชั้น
    // พยาบาลคีย์แทน: ยังใช้หน้าย่อย (ต้องเลือกแพทย์ผู้สั่ง)
    if (_isDxStep(_speechStep) && !ErSession.instance.isNurse) {
      // รหัสที่ผูกกับรายการนี้อยู่แล้ว = ค่าเริ่มของแถวเลือกรหัส
      final src0 = _icdSrcMap();
      _dxDraftCodes = i == null
          ? [...codes]
          : [
              for (final e
                  in _multiItems(_filled[_speechStep][_icd10Label], icd: true))
                if (src0[e] == items[i]) e
            ];
      final before = [..._dxDraftCodes];
      _dxDraftTypes = {};
      _dxDraftLink = {};
      setState(() => _dxTextOpen = true);
      final t = await _ftOpen(context,
          title: 'Diagnosis Text',
          sub: i == null
              ? 'การวินิจฉัย รายการที่ ${items.length + 1}'
              : 'การวินิจฉัย รายการที่ ${i + 1}',
          initial: i == null ? '' : items[i],
          hint: 'เช่น Hemorrhagic shock from femur fracture',
          // AI ช่วยวินิจฉัย: ข้อเสนอ Dr.Note แสดงแทนที่ในการ์ดข้อความ (ไม่ใช่ bottom sheet)
          // ปุ่มรอผลวิเคราะห์ (เล่นแอนิเมชันบนปุ่ม) แล้วค่อยเปิดข้อเสนอ
          aiFill: (_) async {
        await _dxEnsure();
        return null;
      },
          aiPanel: _dxAiPanel,
          aiLabel: 'AI ช่วยวินิจฉัย',
          // เลือกรหัส ICD-10 ของคำวินิจฉัยนี้ในหน้าเดียวกัน (ผูกตอนบันทึก · กติกาข้อ 69)
          extra: _dxCodeRow,
          inWorkflow: true);
      if (mounted) setState(() => _dxTextOpen = false);
      if (t == null || !mounted) return;
      // หลายบรรทัด (เลือกหลายโรคจาก AI) = หลายรายการ · บรรทัดแรกแทนรายการที่แก้
      final lines = [
        for (final x in t.split('\n'))
          if (x.trim().isNotEmpty) x.trim()
      ];
      setState(() {
        _dxEdit = i ?? -1;
        _dxDraft = lines.isEmpty ? '' : lines.first;
      });
      _dxEditSave();
      // รหัสที่เลือกในหน้าพิมพ์: เพิ่มที่ยังไม่มี + ผูกกับข้อความที่บันทึก · เอาออก = ลบรหัสนั้น
      if (lines.isNotEmpty) {
        var icd = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
        icd = [
          for (final e in icd)
            if (!before.contains(e) || _dxDraftCodes.contains(e)) e,
          for (final e in _dxDraftCodes)
            if (!icd.contains(e)) e,
        ];
        // ประเภทที่เลือก: 1 = ย้ายขึ้นเป็นรหัสแรก · อื่น = เก็บประเภท
        for (final x in _dxDraftTypes.entries) {
          if (!icd.contains(x.key)) continue;
          if (x.value == '1') {
            icd = [x.key, ...icd.where((y) => y != x.key)];
          } else {
            _storeDiagType(x.key, x.value);
          }
        }
        _setMulti(_icd10Label, icd);
        for (final e in _dxDraftCodes) {
          final d = _dxDraftLink[e];
          _icdLink(e, d != null && lines.contains(d) ? d : lines.first);
        }
      }
      if (lines.length > 1) {
        final now = _multiItems(_filled[_speechStep][_dxTextLabel]);
        final at = i == null ? now.length : i + 1;
        _setMulti(_dxTextLabel, [
          ...now.take(at),
          for (final x in lines.skip(1))
            if (!now.contains(x)) x,
          ...now.skip(at),
        ]);
      }
      return;
    }
    if (_isDxStep(_speechStep)) {
      setState(() {
        _dxEdit = i ?? -1;
        _dxDraft = i == null ? '' : items[i];
        _dxOrderMiss = false;
        // แก้รายการเดิมที่พยาบาลคีย์แทน: ใช้แพทย์ผู้สั่งเดิม
        _dxOrderBy =
            i != null && _keyedByMap(_dxTextLabel).containsKey(items[i])
                ? _byMap(_dxTextLabel)[items[i]]
                : null;
      });
      return;
    }
    final v = await _voiceTextDialog(
      title: i == null
          ? 'เพิ่ม Diagnosis Text (รายการที่ ${items.length + 1})'
          : 'แก้ Diagnosis Text รายการที่ ${i + 1}',
      initial: i == null ? '' : items[i],
      hint: 'พิมพ์หรือแตะไมค์เพื่อพูด (1 รายการ)',
      okText: i == null ? 'เพิ่มรายการ' : 'บันทึก',
    );
    if (v == null || !mounted) return;
    // หนึ่งรายการต้องอยู่บรรทัดเดียว (ขึ้นบรรทัดใหม่ใช้คั่นรายการ)
    final text = v.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim();
    if (i == null) {
      if (text.isNotEmpty) _setMulti(_dxTextLabel, [...items, text]);
    } else if (text.isEmpty) {
      _setMulti(_dxTextLabel, items..removeAt(i));
    } else {
      _setMulti(_dxTextLabel, items..[i] = text);
    }
  }

  /// หน้าต่างพิมพ์ข้อความ + ไมค์เล็กมุมขวาบน (แตะเพื่อพูด / แตะเพื่อส่ง → ถอดเสียงต่อท้าย)
  /// autoMic = ผู้ใช้กดปุ่ม "พูด" มาเอง เริ่มฟังทันทีที่เปิดหน้าต่าง · ยกเลิก = null
  Future<String?> _voiceTextDialog({
    required String title,
    required String initial,
    required String hint,
    required String okText,
    bool multiline = false,
    bool autoMic = false,
  }) async {
    if (_recording) {
      _wfToast('หยุดไมค์ของผู้ช่วยก่อน แล้วค่อยพูดในช่องนี้', error: true);
      return null;
    }
    _robot.stop();
    return showDialog<String>(
      context: context,
      builder: (ctx) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: _blue),
          textTheme: Theme.of(ctx)
              .textTheme
              .apply(fontFamily: _fontFam, fontFamilyFallback: _fontFb),
        ),
        child: ErSpeechDialog(
            title: title,
            initial: initial,
            hint: hint,
            okText: okText,
            multiline: multiline,
            autoStart: autoMic),
      ),
    );
  }
  // ------------------------------------------------ ICD-9-CM (หัตถการ) ในขั้นวินิจฉัย

  /// ICD-9-CM จาก master: ชื่อ → รหัส
  Map<String, String> _icd9Codes() => {
        for (final it in ErMaster.maybe?.table('er_icd9cm')?.activeItems ??
            const <ErMasterItem>[])
          it.name: it.code
      };

  /// ICD-9-CM ที่ลงไว้แล้วในขั้น "หัตถการ" แต่ยังไม่อยู่ในรายการนี้ (แตะเพื่อเพิ่ม)
  List<String> _icd9FromProcedure() {
    final have = _multiItems(_filled[_speechStep][_icd9DxLabel]);
    return [
      for (var st = 0; st < _forms.length; st++)
        if (st != _speechStep && _forms[st].any((f) => f.$1 == _icd9Label))
          for (final n in _multiItems(_filled[st][_icd9Label]))
            if (!have.contains(n)) n
    ];
  }

  /// การ์ดรหัส ICD-9-CM (การ์ดในการ์ด: ขาว + เส้น 0.5) แบบเดียวกับแถว ICD-10 ในหน้าพิมพ์
  /// บน = รหัส (ป้ายเล็ก) · กลาง = ชื่อหัตถการ · ล่าง = ผู้บันทึก เวลา · แตะ = filter sheet (เปลี่ยน / เอาออก)
  Widget _icd9Card(int i, List<String> items, Map<String, String> codes,
      Map<String, String> by, Map<String, String> at) {
    final name = items[i];
    // ผู้บันทึก + เวลา (บรรทัดล่างสุด เทาเล็ก แบบรายการ Diagnosis Text)
    final who = [
      if (by[name] case final b?) b,
      if (at[name] case final t?) _clock(t),
    ].join('  ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: _panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: const BorderSide(color: Color(0xFFDADCE0), width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _pickIcd9(i),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 8.0, 12.0),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // บน = รหัส (ป้ายเล็ก) · กลาง = ชื่อหัตถการ · ล่าง = ผู้บันทึก เวลา
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7.0, vertical: 1.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F4),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(codes[name] ?? '-',
                              style: _num(11.5,
                                  color: _ink2, weight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 2.0),
                      Text(name,
                          style: _t(14.5,
                              color: _inkTitle,
                              height: 1.3,
                              weight: FontWeight.w600)),
                      if (who.isNotEmpty) ...[
                        const SizedBox(height: 2.0),
                        Text(who,
                            style: _t(12.5,
                                color: _ink3, weight: FontWeight.w500)),
                      ],
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22.0, color: _ink3),
            ]),
          ),
        ),
      ),
    );
  }

  /// รหัส ICD-9-CM จากขั้นหัตถการที่ยังไม่อยู่ในรายการ = ลงให้เอง (หลังเฟรมนี้)
  /// ยกเว้นรหัสที่ผู้ใช้เอาออกเอง (ไม่ดึงกลับมาซ้ำ)
  void _icd9AutoFromProc() {
    final add = [
      for (final n in _icd9FromProcedure())
        if (!_icd9ProcDismissed.contains('${_caseP().hn}|$n')) n
    ];
    if (add.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cur = _multiItems(_filled[_speechStep][_icd9DxLabel]);
      final more = [
        for (final n in add)
          if (!cur.contains(n)) n
      ];
      if (more.isNotEmpty) _setMulti(_icd9DxLabel, [...cur, ...more]);
    });
  }

  /// เลือกรหัส ICD-9-CM จาก master: แก้รายการที่ i หรือเพิ่มใหม่ (i = null)
  Future<void> _pickIcd9(int? i) async {
    final items = _multiItems(_filled[_speechStep][_icd9DxLabel]);
    final codes = _icd9Codes();
    final cur = i == null ? null : items[i];
    // filter bottom sheet แบบเดียวกับขั้นหัตถการ · แนะนำ = รหัสที่ลงไว้ในขั้นหัตถการ
    // รหัสที่ลงไว้แล้ว = จาง "เลือกแล้ว" (ไม่ลงซ้ำ)
    String? name;
    var remove = false;
    await _soFilterSheet(
      title: 'รหัสหัตถการ ICD-9-CM',
      // แก้รหัสเดิม = มีปุ่มเอาออกใน sheet (ยืนยันก่อนลบ)
      removeLabel: cur == null ? null : 'เอารหัสนี้ออก',
      onRemove: () => remove = true,
      sub: '${codes.length} รายการ',
      cats: _icd9Cats(_icd9FromProcedure()),
      current: cur,
      label: (o) => o,
      note: (o) => codes[o] ?? '',
      taken: {
        for (final x in items)
          if (x != cur) x
      },
      onPick: (o) => name = o,
    );
    if (remove && cur != null && mounted) {
      // ยกเลิก / แตะนอก dialog = กลับไป sheet เดิม (ไม่หลุดออกจากการแก้รหัส)
      if (!await _askDelete('เอารหัสนี้ออก?',
          '${codes[cur] ?? ''} $cur จะถูกลบออกจากรายการ', 'เอาออก')) {
        if (mounted) return _pickIcd9(i);
        return;
      }
      final now = _multiItems(_filled[_speechStep][_icd9DxLabel]);
      _icd9ProcDismissed.add('${_caseP().hn}|$cur');
      _setMulti(_icd9DxLabel, now..remove(cur));
      return;
    }
    if (name == null || !mounted) return;
    final n = name!;
    _setMulti(_icd9DxLabel, i == null ? [...items, n] : (items..[i] = n));
  }

  /// ชิป ICD-9-CM จากขั้นหัตถการ ใต้รายการ
  Widget _icd9FromProcChips(bool big) {
    final sug = _icd9FromProcedure();
    if (sug.isEmpty) return const SizedBox.shrink();
    final codes = _icd9Codes();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('จากขั้นหัตถการ แตะเพื่อเพิ่ม',
              style:
                  _t(big ? 11.5 : 9.5, color: _ink3, weight: FontWeight.w600)),
          const SizedBox(height: 4.0),
          Wrap(spacing: 5.0, runSpacing: 5.0, children: [
            for (final n in sug)
              _optChip(
                  '+ ${codes[n] == null ? '' : '${codes[n]} '}$n', false, false,
                  () {
                _setMulti(_icd9DxLabel,
                    [..._multiItems(_filled[_speechStep][_icd9DxLabel]), n]);
              }, size: big ? 10.5 : 9.0),
          ]),
        ],
      ),
    );
  }

  // ------------------------------------------------ Doctor Note

  /// ผู้เขียน Doctor Note ล่าสุด (บันทึกทุกครั้งที่แก้)
  void _stampNote() {
    final who = ErSession.instance.user?.name;
    if (who == null) return;
    // ผู้เขียน + เวลา (แบบรายการ Diagnosis Text)
    final now = DateTime.now();
    final hm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _filled[_speechStep]['$_noteLabel - by'] = 'note\t$who\t$hm';
  }

  void _setNote(String text) {
    final old = _filled[_speechStep][_noteLabel];
    setState(() {
      _lastFilled = [(_speechStep, _noteLabel, old)];
      if (text.trim().isEmpty) {
        _filled[_speechStep].remove(_noteLabel);
      } else {
        _filled[_speechStep][_noteLabel] = text.trim();
      }
      _stampNote();
    });
  }

  Future<void> _editNote({bool autoMic = false}) async {
    final v = await _voiceTextDialog(
      title: 'Doctor Note',
      initial: _filled[_speechStep][_noteLabel] ?? '',
      hint: 'พิมพ์ หรือแตะไมค์มุมขวาบนเพื่อพูด',
      okText: 'บันทึก',
      multiline: true,
      autoMic: autoMic,
    );
    if (v == null || !mounted) return;
    _setNote(v);
  }

  /// Template Doctor Note ของแพทย์ที่ login อยู่ · เลือกแล้วต่อท้าย note เดิม
  Future<void> _pickNoteTemplate() async {
    final id = ErSession.instance.user?.id;
    final mine = {
      for (final (doc, name, text) in _noteTemplates)
        if (doc == id) name: text
    };
    if (mine.isEmpty) {
      _wfToast('แพทย์ท่านนี้ยังไม่มี Template Doctor Note', error: true);
      return;
    }
    // filter bottom sheet แบบเดียวกับเทมเพลต HPI: หมวดซ้าย · ค้นหา + รายการขวา (ตัวอย่างข้อความ)
    // ของฉัน = แพทย์ที่ login · แพทย์ท่านอื่น = เทมเพลตของแพทย์อื่นในเดโม
    final others = {
      for (final (doc, name, text) in _noteTemplates)
        if (doc != id) name: text
    };
    final all = {...mine, ...others};
    String? picked;
    await _soFilterSheet(
      title: 'Template Doctor Note',
      sub: ErSession.instance.user?.name ?? '',
      cats: [
        ('ของฉัน', mine.keys.toList()),
        if (others.isNotEmpty) ('แพทย์ท่านอื่น', others.keys.toList()),
      ],
      current: null,
      label: (o) => o,
      note: (o) => (all[o] ?? '').split('\n').first,
      onPick: (o) => picked = o,
    );
    final text = all[picked];
    if (text == null || !mounted) return;
    final cur = (_filled[_speechStep][_noteLabel] ?? '').trim();
    _setNote(cur.isEmpty ? text : '$cur\n\n$text');
    setState(() => _flashGlow({_noteLabel}));
  }

  /// ส่วน Doctor Note: หัวข้อ + ปุ่มเล็ก พูด/Template · กล่องข้อความแตะเพื่อแก้
  Widget _noteSection(bool big) {
    final v = _filled[_speechStep][_noteLabel];
    final who = _byMap(_noteLabel)['note'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _editNote(),
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            constraints: BoxConstraints(minHeight: big ? 88.0 : 60.0),
            padding: EdgeInsets.all(big ? 12.0 : 8.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                  color: v != null ? _blue.withValues(alpha: 0.5) : _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    v ?? 'แตะเพื่อพิมพ์ หรือกด "พูด" เพื่อแปลงเสียงเป็นข้อความ',
                    style: _t(big ? 13.0 : 10.0,
                        color: v != null ? _inkTitle : _ink3,
                        height: 1.45,
                        weight: FontWeight.w500)),
                if (v != null) _byLine(who, big),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Template วินิจฉัยของแพทย์ที่ login อยู่
  List<_DxTemplate> _myDxTemplates() {
    final id = ErSession.instance.user?.id;
    return [
      for (final t in _dxTemplates)
        if (t.doctor == id) t
    ];
  }

  /// ค้นหา Template จากชื่อโรคที่ตั้งไว้ (รวมข้อความวินิจฉัยและรหัส ICD-10)
  Future<void> _pickDxTemplate() async {
    final mine = _myDxTemplates();
    final picked = await _placedSheet<_DxTemplate>(
      context: context,
      // bottom sheet กว้างไม่เกิน 640 และอยู่กลางจอ
      constraints: const BoxConstraints(maxWidth: 640.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) {
        var q = '';
        return StatefulBuilder(builder: (ctx, set) {
          final k = q.toLowerCase();
          final list = [
            for (final t in mine)
              if (k.isEmpty ||
                  t.name.toLowerCase().contains(k) ||
                  t.text.toLowerCase().contains(k) ||
                  t.icd10.toLowerCase().contains(k))
                t
          ];
          return SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.7,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Template วินิจฉัย',
                            style: _t(15.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        Text(ErSession.instance.user?.name ?? '',
                            style: _t(10.5, color: _ink3)),
                      ],
                    ),
                  ),
                  Text('${mine.length} รายการ', style: _t(11.0, color: _ink3)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  onChanged: (v) => set(() => q = v.trim()),
                  style: _t(13.0),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อโรค',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20.0),
                    isDense: true,
                    filled: true,
                    fillColor: _panelSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                            mine.isEmpty
                                ? 'แพทย์ท่านนี้ยังไม่มี Template วินิจฉัย'
                                : 'ไม่พบ Template "$q"',
                            style: _t(12.0, color: _ink3)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 16.0),
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1.0, color: _line),
                        itemBuilder: (_, i) => ListTile(
                          title: Text(list[i].name,
                              style: _t(12.5,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          subtitle:
                              Text(list[i].text, style: _t(11.0, color: _ink2)),
                          trailing: Text(list[i].icd10,
                              style: _num(12.0,
                                  color: _blue, weight: FontWeight.w700)),
                          onTap: () => Navigator.pop(ctx, list[i]),
                        ),
                      ),
              ),
            ]),
          );
        });
      },
    );
    if (picked == null || !mounted) return;
    _applyDxTemplate(picked);
  }

  /// ใช้ Template: เพิ่ม Diagnosis Text และลงรหัส ICD-10 ที่ผูกไว้ในช่อง ICD-10 ให้เลย
  /// รายการที่มีอยู่แล้วไม่เพิ่มซ้ำ · รหัสที่ไม่มีใน master ไม่ลง (ไม่เดารหัสเอง)
  void _applyDxTemplate(_DxTemplate t) {
    final st = _speechStep;
    final dx = _multiItems(_filled[st][_dxTextLabel]);
    final icd = _multiItems(_filled[st][_icd10Label], icd: true);
    final name =
        {for (final e in _icd10Codes().entries) e.value: e.key}[t.icd10];
    setState(() {
      _lastFilled = [
        (st, _dxTextLabel, _filled[st][_dxTextLabel]),
        (st, _icd10Label, _filled[st][_icd10Label]),
      ];
      if (!dx.contains(t.text)) {
        _filled[st][_dxTextLabel] = [...dx, t.text].join('\n');
      }
      if (name != null && !icd.contains(name)) {
        _filled[st][_icd10Label] = [...icd, name].join('\n');
      }
      _stampBy(_dxTextLabel, [t.text]);
      if (name != null) _stampBy(_icd10Label, [name]);
      if (name != null) _icdLink(name, t.text);
      _flashGlow({_dxTextLabel, if (name != null) _icd10Label});
    });
    _wfToast(name == null
        ? 'เพิ่ม "${t.name}" แล้ว แต่ไม่พบรหัส ${t.icd10} ใน master ICD-10'
        : 'เพิ่ม "${t.name}" แล้ว ลง ICD-10 ${t.icd10} ให้อัตโนมัติ');
  }

  // ------------------------------------------------ Re-Diag: ใช้วินิจฉัยจาก visit ก่อนหน้า

  /// visit ก่อนหน้าของผู้ป่วย (ข้อมูลจำลองสำหรับเดโม · รหัสต้องมีใน master er_icd10)
  List<_PastVisit> _pastVisits() {
    final t = _dayOnly(DateTime.now());
    String vn(DateTime d, int n) =>
        '${(d.year + 543) % 100}${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}${n.toString().padLeft(3, '0')}';
    final d1 = t.subtract(const Duration(days: 16));
    final d2 = t.subtract(const Duration(days: 45));
    final d3 = t.subtract(const Duration(days: 128));
    return [
      _PastVisit(
        date: d1,
        admit: false,
        dept: 'OPD อายุรกรรม',
        vn: vn(d1, 8),
        icd: const [
          ('J18.9', '1', 'นพ. ธีรภัทร อมรเลิศ'),
          ('I50.0', '2', 'นพ. ธีรภัทร อมรเลิศ'),
        ],
        dx: const [
          'ปอดอักเสบ ไข้ ไอมีเสมหะ 3 วัน',
          'หัวใจล้มเหลวเรื้อรัง ติดตามอาการ'
        ],
        link: const {'J18.9': 0, 'I50.0': 1},
      ),
      _PastVisit(
        date: d2,
        admit: true,
        dept: 'IPD อายุรกรรม',
        vn: vn(d2, 16),
        an: vn(d2, 13),
        icd: const [
          ('I50.0', '1', 'พญ. ศิริพร กิตติวงศ์'),
          ('E87.1', '2', 'พญ. ศิริพร กิตติวงศ์'),
          ('R50.9', '4', 'พญ. ศิริพร กิตติวงศ์'),
        ],
        dx: const ['หัวใจล้มเหลวกำเริบ น้ำท่วมปอด', 'โซเดียมในเลือดต่ำ'],
        link: const {'I50.0': 0, 'E87.1': 1},
      ),
      _PastVisit(
        date: d3,
        admit: false,
        dept: 'ER ห้องฉุกเฉิน',
        vn: vn(d3, 41),
        icd: const [('A09', '1', 'นพ. ธีรภัทร อมรเลิศ')],
        dx: const ['ท้องเสียเฉียบพลัน ขาดน้ำเล็กน้อย'],
        link: const {'A09': 0},
      ),
    ];
  }

  /// ปุ่ม Re-Diag: ปุ่มรอง tonal แบบเดียวกับปุ่มอื่นในหน้า (ปุ่มหลักมีแค่ "ถัดไป")
  Widget _reDiagBtn() => _miniBtn(Icons.history_rounded, 'Re-Diag', _openReDiag,
      tooltip: 'นำรหัส ICD-10 และ Diagnosis Text จาก visit ก่อนหน้ามาใช้');

  /// หน้าต่าง Re-Diag: ซ้าย = รายการ visit · ขวา = วินิจฉัยของ visit ที่เลือก ติ๊กเลือกได้
  /// เลือกข้าม visit ได้ รายการที่มีอยู่แล้วใน visit นี้ติ๊กไม่ได้ (ไม่เพิ่มซ้ำ)
  /// ปุ่ม Re-Diag: เปิดหน้า Re-Diag ที่แผงซ้าย (ดูประวัติ + กดเพิ่มทีละรายการ)
  void _openReDiag() {
    HapticFeedback.selectionClick();
    setState(() {
      _tabDir = 1;
      _detailTab = _reDiagTab;
    });
  }

  /// บันทึกหน้าย่อย Re-Diag: เพิ่มรายการที่ติ๊กลงขั้นวินิจฉัย แล้วกลับหน้ารายการ
  void _reDiagSave() {
    if (_reDiagPicked.isEmpty) return;
    final codes = {for (final e in _icd10Codes().entries) e.value: e.key};
    _applyReDiag(Map.of(_reDiagPicked), codes);
    setState(() {
      _reDiagPicked.clear();
      _reDiagOpen = false;
    });
  }

  /// แท็บ Re-Diag (แผงซ้าย) แบบหน้า EMR: หัว + แถบ tab วันที่ visit
  /// การ์ด ICD-10 / Diagnosis Text แถวติ๊กแบบ V/S · มีแล้วใน visit นี้ = จาง · ปุ่มเพิ่มท้ายหน้า
  Widget _reDiagPage({bool pick = false}) {
    final visits = _pastVisits();
    final codes = {
      for (final e in _icd10Codes().entries) e.value: e.key
    }; // รหัส → ชื่อ
    final st = _isDxStep(_speechStep)
        ? _speechStep
        : _steps.indexWhere((x) => x.$2 == 'วินิจฉัย');
    final haveIcd = _multiItems(_filled[st][_icd10Label], icd: true);
    final haveDx = _multiItems(_filled[st][_dxTextLabel]);
    final at = _reDiagAt.clamp(0, visits.length - 1);
    final v = visits[at];
    final picked = _reDiagPicked;
    String typeName(String t) =>
        _diagTypes.where((d) => d.$1 == t).firstOrNull?.$2 ?? 'Type $t';
    final icds = [
      for (final (code, type, doc) in v.icd)
        if (codes[code] != null) (code, codes[code]!, type, doc)
    ];

    // แผงซ้าย: กดเพิ่มแล้วลงขั้นวินิจฉัยทันที (ไม่ต้องติ๊กแล้วกดยืนยัน)
    void addNow(Map<String, String> m) {
      HapticFeedback.mediumImpact();
      _applyReDiag(Map.of(m), codes);
    }

    Widget tick(bool on, bool have) => Icon(
        have
            ? Icons.check_circle_rounded
            : on
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
        size: 24.0,
        color: have ? _g5 : (on ? _blue : _ink3));
    Widget row(
            {required bool first,
            required String key,
            required String type,
            required bool have,
            required String title,
            required String sub}) =>
        (Opacity(
          opacity: pick && have ? 0.55 : 1.0,
          child: _gListRow(
            first: first,
            inset: pick ? 8.0 : 0.0,
            // แผงซ้าย (ดูอย่างเดียว): ไม่มีช่องติ๊ก
            lead: !pick
                ? null
                : SizedBox(
                    width: 32.0,
                    child: Center(child: tick(picked.containsKey(key), have))),
            title: title,
            titleLines: 2,
            sub: have ? '$sub  มีใน visit นี้แล้ว' : sub,
            onTap: !pick || have
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    setState(() => picked.containsKey(key)
                        ? picked.remove(key)
                        : picked[key] = type);
                  },
            // แผงซ้าย: ปุ่มเพิ่มต่อแถว (กดแล้วลงขั้นวินิจฉัยทันที) · มีแล้ว = เช็กเขียว
            trail: pick
                ? const SizedBox.shrink()
                : have
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.check_circle_rounded,
                            size: 22.0, color: _green),
                      )
                    : FilledButton.tonal(
                        onPressed: () => addNow({key: type}),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE2EAF8),
                          foregroundColor: _blue,
                          minimumSize: const Size(0.0, 36.0),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          shape: const StadiumBorder(),
                        ),
                        child: Text('เพิ่ม',
                            style: _t(13.0,
                                color: _blue, weight: FontWeight.w600)),
                      ),
          ),
        ));
    Widget card(String title, Map<String, String> free, List<Widget> rows,
        {Widget? head}) {
      final all = free.isNotEmpty && free.keys.every(picked.containsKey);
      return Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 12.0, 4.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ข้อมูล visit บนสุดในการ์ด (ตัวเล็กเทา) + เส้นคั่น
          if (head != null) ...[
            head,
            const SizedBox(height: 10.0),
            Container(height: 1.0, color: _line),
            const SizedBox(height: 4.0),
          ],
          // หัวการ์ดสูงคงที่ (มี/ไม่มีปุ่มเพิ่มทั้งหมด สูงเท่ากัน)
          SizedBox(
            height: 40.0,
            child: Row(children: [
              Expanded(
                child: Text(title,
                    style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              // แผงซ้าย: เพิ่มทุกรายการที่ยังไม่มีในการ์ดนี้
              if (!pick && free.length > 1)
                TextButton(
                  onPressed: () => addNow(free),
                  child: Text('เพิ่มทั้งหมด (${free.length})',
                      style: _t(13.0, color: _blue, weight: FontWeight.w600)),
                ),
              if (pick && free.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => all
                      ? free.keys.forEach(picked.remove)
                      : picked.addAll(free)),
                  child: Text(all ? 'ไม่เลือกทั้งหมด' : 'เลือกทั้งหมด',
                      style: _t(13.0, color: _blue, weight: FontWeight.w600)),
                ),
            ]),
          ),
          ...rows,
        ]),
      );
    }

    Widget tab(int i) {
      final on = i == at;
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() => _reDiagAt = i);
          },
          child: IntrinsicWidth(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 9.0),
                    child: Text(_apptDate(visits[i].date),
                        style: _t(14.0,
                            color: on ? _blue : _ink2,
                            weight: on ? FontWeight.w600 : FontWeight.w500)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: on ? _blue : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3.0)),
                    ),
                  ),
                ]),
          ),
        ),
      );
    }

    final days = _dayOnly(DateTime.now()).difference(v.date).inDays;
    final tabs = Transform.translate(
      offset: const Offset(-12.0, 0.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (var i = 0; i < visits.length; i++) tab(i),
        ]),
      ),
    );
    // ข้อมูล visit มีป้ายกำกับ: ชื่อหัวข้อเทาเล็ก · ค่าเข้มด้านล่าง (แบบหัวข้อ-ค่า)
    Widget kv(String k, String val) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(k, style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
            const SizedBox(height: 2.0),
            Text(val,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ],
        );
    final info = Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 14.0),
      child: Wrap(spacing: 32.0, runSpacing: 8.0, children: [
        kv('แผนก', v.dept),
        kv(v.admit ? 'AN' : 'VN', v.admit ? '${v.an}' : v.vn),
        kv('มาเมื่อ', '$days วันก่อน'),
      ]),
    );
    // ลำดับเดียวกับแผงขวา: Diagnosis Text บน · ICD-10 ล่าง
    final cards = <Widget>[
      if (v.dx.isNotEmpty)
        card('Diagnosis Text', {
          for (final t in v.dx)
            if (!haveDx.contains(t)) 'd|$t': ''
        }, [
          for (final (n, t) in v.dx.indexed)
            row(
              first: n == 0,
              key: 'd|$t',
              type: '',
              have: haveDx.contains(t),
              title: t,
              // แพทย์ผู้วินิจฉัยของ visit (แผนกอยู่บรรทัดข้อมูล visit แล้ว)
              sub: icds.firstOrNull?.$4 ?? '-',
            ),
        ]),
      if (icds.isNotEmpty)
        card('ICD-10', {
          for (final x in icds)
            if (!haveIcd.contains(x.$2)) 'i|${x.$1}': x.$3
        }, [
          for (final (n, (code, name, type, _)) in icds.indexed)
            row(
              first: n == 0,
              key: 'i|$code',
              type: type,
              have: haveIcd.contains(name),
              // ชื่อโรคบรรทัดหลัก · รหัส + ประเภทบรรทัดรอง (แพทย์อยู่บนหัวหน้าแล้ว)
              title: name,
              sub: '$code  ${typeName(type)}',
            ),
        ]),
    ];
    // แผงขวา (หน้าย่อย): tab visit + การ์ดติ๊ก · ปุ่มเพิ่มอยู่ footer ของแผง
    if (pick) {
      return ListView(
        key: const ValueKey('rediag-pick'),
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 96.0),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 0.0, 0.0, 8.0),
            child: Text('ติ๊กรายการที่จะใช้ เลือกข้าม visit ได้',
                style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
          ),
          tabs,
          Container(height: 1.0, color: _line),
          const SizedBox(height: 12.0),
          info,
          ...cards,
        ],
      );
    }
    // แผงซ้าย: การ์ดเดียว "การวินิจฉัย" เรียงตาม flow หน้าวินิจฉัย
    // คำวินิจฉัย (Diagnosis Text) + รหัส ICD-10 ที่ผูกอยู่ใต้แต่ละข้อ · ปุ่มเพิ่มต่อคำวินิจฉัย
    final linked = <int, List<(String, String, String, String)>>{};
    final loose = <(String, String, String, String)>[];
    for (final x in icds) {
      final i = v.link[x.$1];
      i != null && i < v.dx.length ? (linked[i] ??= []).add(x) : loose.add(x);
    }
    // แถวรหัสในการ์ดคำวินิจฉัย: เหรียญประเภท · ประเภท + รหัส (ป้ายเล็ก) · ชื่อโรค
    Widget codeLine((String, String, String, String) x) {
      final (code, name, type, _) = x;
      return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Row(children: [
          _typeDot(type, 30.0),
          const SizedBox(width: 10.0),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(typeName(type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // สีเดียวกับหน้าพิมพ์: Principal = กรมท่า · อื่น = เทา
                      style: _t(12.0,
                          color: type == '1' ? _blue : _ink3,
                          weight: FontWeight.w600)),
                ),
                const SizedBox(width: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(code,
                      style: _num(11.5, color: _ink2, weight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 1.0),
              Text(name,
                  style: _t(14.0,
                      color: _inkTitle, weight: FontWeight.w500, height: 1.35)),
            ]),
          ),
        ]),
      );
    }

    Widget addBtn(bool have, VoidCallback onAdd) => have
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle_rounded, size: 18.0, color: _green),
              const SizedBox(width: 4.0),
              Text('มีแล้ว',
                  style: _t(13.0, color: _green, weight: FontWeight.w600)),
            ]),
          )
        : FilledButton.tonal(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE2EAF8),
              foregroundColor: _blue,
              minimumSize: const Size(0.0, 36.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              shape: const StadiumBorder(),
            ),
            child: Text('เพิ่ม',
                style: _t(13.0, color: _blue, weight: FontWeight.w600)),
          );
    // กลุ่ม: หัวข้อ (คำวินิจฉัย) + รหัสใต้ · เพิ่ม = ลงทั้งคำวินิจฉัยและรหัสที่ผูก
    final groups = <(String?, List<(String, String, String, String)>)>[
      for (final (i, t) in v.dx.indexed) (t, linked[i] ?? const []),
      if (loose.isNotEmpty) (null, loose),
    ];
    // ปุ่มเพิ่มขึ้นเฉพาะตอนเปิดหน้าพิมพ์ Diagnosis Text (เพิ่มลงร่างในหน้านั้น ยังไม่บันทึก)
    final canAdd = _dxTextOpen;
    final draftLines = [
      for (final l in (_wfTextValue?.call() ?? '').split('\n'))
        if (l.trim().isNotEmpty) l.trim()
    ];
    Map<String, String> groupPick(
            (String?, List<(String, String, String, String)>) g) =>
        {
          if (g.$1 case final t?
              when !haveDx.contains(t) && !draftLines.contains(t))
            'd|$t': '',
          for (final x in g.$2)
            if (!haveIcd.contains(x.$2) && !_dxDraftCodes.contains(x.$2))
              'i|${x.$1}': x.$3,
        };
    // ลงร่างหน้าพิมพ์: ข้อความต่อบรรทัดใหม่ · รหัสเข้าแถว ICD-10 (คงประเภทเดิม ยกเว้น Principal)
    void addGroups(List<(String?, List<(String, String, String, String)>)> gs) {
      HapticFeedback.mediumImpact();
      final lines = <String>[];
      for (final g in gs) {
        final m = groupPick(g);
        for (final x in g.$2) {
          final name = x.$2;
          if (!m.containsKey('i|${x.$1}')) continue;
          _dxDraftCodes = [..._dxDraftCodes, name];
          if (x.$3 != '1') _dxDraftTypes = {..._dxDraftTypes, name: x.$3};
          if (g.$1 case final t?) _dxDraftLink[name] = t;
        }
        if (g.$1 case final t? when m.containsKey('d|$t')) lines.add(t);
      }
      if (lines.isNotEmpty) {
        _ftAppendLine?.call(lines.join('\n'));
      } else {
        // มีแค่รหัส = ให้หน้าพิมพ์วาดแถวรหัสใหม่
        _ftAppendLine?.call('');
      }
      setState(() {});
    }

    void addGroup((String?, List<(String, String, String, String)>) g) =>
        addGroups([g]);

    final freeGroups = groups.where((g) => groupPick(g).isNotEmpty).toList();
    final dxCard = Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 12.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: 44.0,
          child: Row(children: [
            const SizedBox(width: 8.0),
            Expanded(
              child: Text('การวินิจฉัย',
                  style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
            ),
            if (canAdd && freeGroups.length > 1)
              TextButton(
                onPressed: () => addGroups(freeGroups),
                child: Text('เพิ่มทั้งหมด',
                    style: _t(13.0, color: _blue, weight: FontWeight.w600)),
              ),
          ]),
        ),
        // คำวินิจฉัยละการ์ด (การ์ดในการ์ด: ขาว + เส้น 0.5 · ขอบใน 8 < หัวข้อ 16)
        // หัวการ์ด = คำวินิจฉัย + ปุ่มเพิ่ม · ใต้เส้นบาง = รหัสที่ผูกอยู่
        for (final g in groups)
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 14.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(g.$1 ?? 'รหัสที่ไม่ได้ผูกคำวินิจฉัย',
                          style: g.$1 == null
                              ? _t(14.0, color: _ink2, weight: FontWeight.w600)
                              : _t(15.5,
                                  color: _inkTitle,
                                  weight: FontWeight.w600,
                                  height: 1.4)),
                    ),
                    const SizedBox(width: 8.0),
                    if (canAdd) addBtn(groupPick(g).isEmpty, () => addGroup(g)),
                  ]),
                  if (g.$2.isNotEmpty) ...[
                    const SizedBox(height: 10.0),
                    Container(height: 0.5, color: _line),
                    for (final x in g.$2) codeLine(x),
                  ],
                ]),
          ),
      ]),
    );
    // แผงซ้าย: ดูประวัติการวินิจฉัย + กดเพิ่ม (หน้าแบบ EMR)
    // ข้อมูล visit = การ์ดหัวข้อ-ค่า แบบการ์ด "การเข้ารับบริการ" ในหน้า EMR
    return _clyInfoPage(
      'การวินิจฉัย',
      'การวินิจฉัยจาก visit ก่อนหน้า กดเพิ่มเพื่อนำมาใช้ใน visit นี้',
      'personal',
      [
        (
          'การเข้ารับบริการ',
          [
            ('วันที่รับบริการ', '${_apptDate(v.date)} ($days วันก่อน)', false),
            ('แผนก', v.dept, false),
            (v.admit ? 'AN' : 'VN', v.admit ? '${v.an}' : v.vn, false),
            ('แพทย์ผู้ตรวจ', icds.firstOrNull?.$4 ?? '-', false),
          ]
        ),
      ],
      by: icds.firstOrNull?.$4 ?? '-',
      at: _apptDate(v.date),
      below: tabs,
      extra: [dxCard],
    );
  }

  /// เพิ่มรายการที่เลือกลง ICD-10 / Diagnosis Text ของ visit นี้ (ไม่ซ้ำ · คงประเภทเดิม)
  void _applyReDiag(Map<String, String> picked, Map<String, String> codes,
      {Map<String, String> links = const {}}) {
    // ลงที่ขั้นวินิจฉัยเสมอ (เปิดจากแผงซ้ายได้ขณะแผงขวาอยู่ขั้นอื่น)
    final st = _isDxStep(_speechStep)
        ? _speechStep
        : _steps.indexWhere((x) => x.$2 == 'วินิจฉัย');
    if (st < 0) return;
    final icd = _multiItems(_filled[st][_icd10Label], icd: true);
    final dx = _multiItems(_filled[st][_dxTextLabel]);
    final addIcd = <String>[];
    final addDx = <String>[];
    setState(() {
      _lastFilled = [
        (st, _icd10Label, _filled[st][_icd10Label]),
        (st, _dxTextLabel, _filled[st][_dxTextLabel]),
      ];
      for (final e in picked.entries) {
        if (e.key.startsWith('i|')) {
          final name = codes[e.key.substring(2)];
          if (name == null || icd.contains(name)) continue;
          icd.add(name);
          addIcd.add(name);
          // ประเภทเดิมจาก visit ก่อน (Type 1 ตัดสินจากลำดับ รหัสแรก = Principal)
          if (e.value != '1') _storeDiagType(name, e.value);
        } else {
          final t = e.key.substring(2);
          if (dx.contains(t)) continue;
          dx.add(t);
          addDx.add(t);
        }
      }
      if (addIcd.isNotEmpty) _filled[st][_icd10Label] = icd.join('\n');
      // ผูกรหัสกับคำวินิจฉัยเดิมของ visit ก่อน (กติกาข้อ 69) · เขียนที่ขั้นวินิจฉัยตรง ๆ
      if (links.isNotEmpty) {
        const k = '$_icd10Label - src';
        final m = {
          for (final l in (_filled[st][k] ?? '').split('\n'))
            if (l.split('\t') case [final a, final b] when a.isNotEmpty) a: b
        };
        for (final e in links.entries) {
          if (codes[e.key] case final name?) m[name] = e.value;
        }
        _filled[st][k] =
            [for (final e in m.entries) '${e.key}\t${e.value}'].join('\n');
      }
      if (addDx.isNotEmpty) _filled[st][_dxTextLabel] = dx.join('\n');
      _stampBy(_icd10Label, addIcd);
      _stampBy(_dxTextLabel, addDx);
      _flashGlow({
        if (addIcd.isNotEmpty) _icd10Label,
        if (addDx.isNotEmpty) _dxTextLabel,
      });
    });
    _wfToast(
        'Re-Diag: เพิ่ม ICD-10 ${addIcd.length} รหัส และ Diagnosis Text ${addDx.length} รายการ');
  }

  // ------------------------------------------------ หน้าคัดกรอง: อุบัติเหตุ · รับเข้า ER · การรับบริการ

  /// ช่องย่อยของหน้ารับเข้าห้องฉุกเฉิน (เก็บใน _filled ของขั้น ด้วยคีย์นำหน้า)
  static const String _erInPrefix = 'รับเข้า ER - ';

  String? _erIn(String k) => _filled[_speechStep]['$_erInPrefix$k'];

  void _setErIn(String k, String? v) {
    final key = '$_erInPrefix$k';
    if (v == null || v.isEmpty) {
      _filled[_speechStep].remove(key);
    } else {
      _filled[_speechStep][key] = v;
    }
    // หน้านี้ครบเมื่อมี เวร · วันเวลาเข้า ER · สภาพผู้ป่วย
    final ok = ['เวร', 'วัน-เวลาเข้าห้อง ER', 'สภาพผู้ป่วย']
        .every((x) => (_erIn(x) ?? '').isNotEmpty);
    if (ok) {
      _filled[_speechStep][_erInLabel] = 'บันทึกแล้ว';
    } else {
      _filled[_speechStep].remove(_erInLabel);
    }
  }

  /// สรุปสำหรับหน้าสรุปก่อนบันทึก
  String _erInSummary() {
    final parts = [
      for (final k in const [
        'เวร',
        'วัน-เวลาเข้าห้อง ER',
        'สภาพผู้ป่วย',
        'แพทย์เวร'
      ])
        if ((_erIn(k) ?? '').isNotEmpty) _erIn(k)!.split(' (').first,
    ];
    return parts.isEmpty ? 'ยังไม่ได้กรอก' : parts.join(' · ');
  }

  /// ค่าตั้งต้นจากข้อมูลคัดกรอง (ครั้งแรกที่เปิดหน้า) · แก้ได้ทุกช่อง
  void _erInPrefill() {
    if (_erIn('เวร') != null) return;
    final c = _case;
    final p = _caseP();
    final now = DateTime.now();
    final shifts = _masterNames('er_shift');
    final h = now.hour;
    final shift = shifts.firstWhere(
        (s) => s
            .startsWith(h >= 8 && h < 16 ? 'เช้า' : (h >= 16 ? 'บ่าย' : 'ดึก')),
        orElse: () => shifts.isEmpty ? '' : shifts.first);
    _setErIn('เวร', shift.split(' (').first);
    _setErIn('วัน-เวลาเข้าห้อง ER',
        _fmtDateTime(now.subtract(Duration(minutes: p.waitMin))));
    final conds = _masterNames('er_patient_condition');
    _setErIn(
        'สภาพผู้ป่วย',
        conds.contains(c.condition)
            ? c.condition
            : (conds.isEmpty ? c.condition : conds.first));
    _setErIn('ข้อบ่งชี้กรณีฉุกเฉิน', '- ไม่มี -');
    final me = ErSession.instance.user;
    if (me?.role == ErRole.doctor) _setErIn('แพทย์เวร', me!.name);
    _setErIn('เวลาเริ่มตรวจ', _fmtDateTime(now));
  }

  /// หน้าแรกของขั้นคัดกรอง (แทนหน้ายืนยันข้อมูลคัดกรองเดิม)
  Widget _screeningPage() {
    if (_erIn('เวร') == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(_erInPrefill);
      });
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _erInCard(),
          const SizedBox(height: 8.0),
          _serviceCard(),
        ],
      ),
    );
  }

  /// การ์ดหัวข้อพับได้ (ตามภาพ): ไอคอนสี่เหลี่ยม · ชื่อ · ลูกศร
  Widget _scrCard(IconData icon, String title, Widget body,
          {Widget? trailing}) =>
      Container(
        padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
        decoration: _clyCardDeco,
        foregroundDecoration: const _InnerGloss(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  gradient: _glossGrad(_blue),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Icon(icon, size: 12.0, color: Colors.white),
              ),
              const SizedBox(width: 7.0),
              Expanded(
                child: Text(title,
                    style: _t(11.5, color: _inkTitle, weight: FontWeight.w700)),
              ),
              if (trailing != null) trailing,
            ]),
            const SizedBox(height: 8.0),
            body,
          ],
        ),
      );

  /// ข้อมูลรับเข้าห้องฉุกเฉิน (ตามภาพ): เวร · วันเวลาเข้า · สภาพผู้ป่วย · ข้อบ่งชี้ ·
  /// แพทย์เวร · เวลาเริ่ม/เสร็จตรวจ · วันเวลาออก · สภาพผู้ป่วยออกจาก ER
  Widget _erInCard() {
    Widget sel(String k, List<String> opts, {bool must = false}) =>
        _apptSelect(k, _erIn(k), opts, (v) => _setErIn(k, v),
            must: must, hint: '- เลือก -');
    Widget dt(String k, {bool must = false}) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _apptLabel(k, must: must),
            _apptBox(_erIn(k) ?? 'เลือกวัน-เวลา',
                filled: _erIn(k) != null,
                must: must,
                icon: Icons.schedule_rounded, onTap: () async {
              final now = DateTime.now();
              final d = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: now.subtract(const Duration(days: 7)),
                lastDate: now.add(const Duration(days: 1)),
              );
              if (d == null || !mounted) return;
              final t = await showTimePicker(
                  context: context, initialTime: TimeOfDay.fromDateTime(now));
              if (t == null || !mounted) return;
              setState(() => _setErIn(
                  k,
                  _fmtDateTime(
                      DateTime(d.year, d.month, d.day, t.hour, t.minute))));
            }),
          ],
        );
    final doctors = [
      for (final it in ErMaster.maybe?.table('er_doctor')?.activeItems ??
          const <ErMasterItem>[])
        it.name,
      for (final u in erStaff)
        if (u.role == ErRole.doctor) u.name,
    ].toSet().toList();
    final fields = <Widget>[
      // เวรแสดงชื่อสั้น (ตัดช่วงเวลาในวงเล็บ)
      sel('เวร',
          [for (final s in _masterNames('er_shift')) s.split(' (').first],
          must: true),
      dt('วัน-เวลาเข้าห้อง ER', must: true),
      sel('สภาพผู้ป่วย', _masterNames('er_patient_condition'), must: true),
      sel('ข้อบ่งชี้กรณีฉุกเฉิน',
          ['- ไม่มี -', ..._masterNames('er_emergency_indication')]),
      sel('แพทย์เวร', doctors),
      dt('เวลาเริ่มตรวจ'),
      dt('เวลาตรวจเสร็จ'),
      dt('วัน-เวลาออกจาก ER'),
      sel('สภาพผู้ป่วยออกจาก ER', _masterNames('er_dch_type')),
    ];
    return _scrCard(
      Icons.local_hospital_rounded,
      'ข้อมูลรับเข้าห้องฉุกเฉิน',
      LayoutBuilder(builder: (_, box) {
        // จอกว้าง 3 คอลัมน์ · กลาง 2 · แคบ 1
        final cols = box.maxWidth >= 560 ? 3 : (box.maxWidth >= 340 ? 2 : 1);
        final w = (box.maxWidth - (cols - 1) * 8.0) / cols;
        return Wrap(spacing: 8.0, runSpacing: 6.0, children: [
          for (final f in fields) SizedBox(width: w, child: f),
        ]);
      }),
    );
  }

  /// การเข้ารับบริการ (ตามภาพ): แสดงอย่างเดียว
  Widget _serviceCard() {
    final c = _case;
    final p = _caseP();
    final at = DateTime.now().subtract(Duration(minutes: p.waitMin));
    final office = at.weekday <= 5 && at.hour >= 8 && at.hour < 16;
    String two(int n) => n.toString().padLeft(2, '0');
    // ประเภทการมา · เวลาทำการ: เลือกแก้ได้ (ตั้งต้นจากคัดกรอง / เวลาที่มาถึง)
    final arrivals = _masterNames('er_arrival_type');
    final arrival = _erIn('ประเภทการมา') ??
        (c.arrival.isEmpty
            ? null
            : arrivals.firstWhere((a) => a.startsWith(c.arrival),
                orElse: () => c.arrival));
    final hours = _erIn('เวลาทำการ') ?? (office ? 'ในเวลา' : 'นอกเวลา');
    return _scrCard(
      Icons.medical_services_rounded,
      'การเข้ารับบริการ',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _kvGrid([
            ('วันที่', _apptDate(at)),
            ('เวลา', '${two(at.hour)}:${two(at.minute)}:${two(at.second)} น.'),
          ]),
          const SizedBox(height: 6.0),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: _apptSelect('ประเภทการมา', arrival, arrivals,
                  (v) => _setErIn('ประเภทการมา', v),
                  hint: '- เลือก -'),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: _apptSelect('เวลาทำการ', hours,
                  const ['ในเวลา', 'นอกเวลา'], (v) => _setErIn('เวลาทำการ', v)),
            ),
          ]),
          const SizedBox(height: 6.0),
          _kvGrid([
            ('แผนก', 'ฉุกเฉิน'),
            ('จุดรับบริการปัจจุบัน', 'ห้องฉุกเฉิน (ER)'),
          ]),
        ],
      ),
    );
  }

  /// ตารางป้าย/ค่า 2 คอลัมน์ (อ่านอย่างเดียว)
  Widget _kvGrid(List<(String, String)> items) => LayoutBuilder(
        builder: (_, box) {
          final w = (box.maxWidth - 8.0) / 2;
          return Wrap(spacing: 8.0, runSpacing: 6.0, children: [
            for (final (k, v) in items)
              SizedBox(
                width: w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(k,
                        style: _t(9.0, color: _ink3, weight: FontWeight.w600)),
                    const SizedBox(height: 1.0),
                    Text(v,
                        style: _t(10.5,
                            color: _inkTitle,
                            height: 1.3,
                            weight: FontWeight.w600)),
                  ],
                ),
              ),
          ]);
        },
      );
}

/// visit ก่อนหน้า: วันที่ · Admit หรือไม่ · แผนก · VN/AN · ICD-10 (รหัส, ประเภท, แพทย์) · Diagnosis Text
class _PastVisit {
  const _PastVisit({
    required this.date,
    required this.admit,
    required this.dept,
    required this.vn,
    this.an,
    required this.icd,
    required this.dx,
    this.link = const {},
  });

  final DateTime date;
  final bool admit;
  final String dept;
  final String vn;
  final String? an;
  final List<(String, String, String)> icd;
  final List<String> dx;

  /// รหัส → ลำดับ Diagnosis Text ที่ผูกอยู่ (ไม่มี = รหัสที่ไม่ได้ผูกคำวินิจฉัย)
  final Map<String, int> link;
}

/// แสดงข้อความ rich text (# หัวข้อ · **หนา** · • / 1. รายการ) โดยไม่เห็นเครื่องหมาย
/// ใช้กับที่แสดงค่า (หน้าสรุป ฯลฯ) · ข้อความธรรมดาก็แสดงปกติ
TextSpan _richSpan(String text, TextStyle base) {
  final bold = RegExp(r'\*\*(.+?)\*\*');
  final list = RegExp(r'^(• |\d+\. )');
  final spans = <InlineSpan>[];
  final lines = text.split('\n');
  for (var li = 0; li < lines.length; li++) {
    var line = lines[li];
    var ls = base;
    if (line.startsWith('# ')) {
      line = line.substring(2);
      ls = base.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: (base.fontSize ?? 14.0) * 1.08);
    } else {
      final m = list.firstMatch(line);
      if (m != null) {
        spans.add(TextSpan(
            text: m.group(0),
            style: base.copyWith(
                color: const Color(0xFF001B7C), fontWeight: FontWeight.w700)));
        line = line.substring(m.end);
      }
    }
    var at = 0;
    for (final b in bold.allMatches(line)) {
      if (b.start > at) {
        spans.add(TextSpan(text: line.substring(at, b.start), style: ls));
      }
      spans.add(TextSpan(
          text: b.group(1), style: ls.copyWith(fontWeight: FontWeight.w800)));
      at = b.end;
    }
    if (at < line.length)
      spans.add(TextSpan(text: line.substring(at), style: ls));
    if (li < lines.length - 1) spans.add(TextSpan(text: '\n', style: base));
  }
  return TextSpan(style: base, children: spans);
}

/// ข้อความ rich text แบบไม่มีเครื่องหมาย (คัดลอก / ส่งต่อ)
String _richPlain(String text) => text
    .replaceAll(RegExp(r'^# ', multiLine: true), '')
    .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!);

/// ตัวควบคุมช่องพิมพ์แบบ rich text อย่างง่าย: เก็บเป็นข้อความธรรมดา แสดงผลตามเครื่องหมาย
/// "# " ต้นบรรทัด = หัวข้อ · **คำ** = ตัวหนา · "• " / "1. " ต้นบรรทัด = รายการ
/// เครื่องหมาย # ** ยังอยู่ในข้อความแต่ไม่แสดง (ตำแหน่งเคอร์เซอร์ตรงกับข้อความจริง)
class _RichNoteController extends TextEditingController {
  _RichNoteController({super.text});

  static final _bold = RegExp(r'\*\*(.+?)\*\*');
  static final _list = RegExp(r'^(• |\d+\. )');

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final base = style ?? const TextStyle();
    // เครื่องหมาย (# และ **) ยังอยู่ในข้อความแต่ซ่อน: ตัวเล็กมาก + โปร่งใส (ไม่กินที่)
    final faint = base.copyWith(
        color: const Color(0x00000000), fontSize: 0.1, letterSpacing: 0.0);
    final spans = <InlineSpan>[];
    final lines = text.split('\n');
    for (var li = 0; li < lines.length; li++) {
      var line = lines[li];
      var ls = base;
      if (line.startsWith('# ')) {
        spans.add(TextSpan(text: '# ', style: faint));
        line = line.substring(2);
        ls = base.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: (base.fontSize ?? 14.0) * 1.12);
      } else {
        final m = _list.firstMatch(line);
        if (m != null) {
          spans.add(TextSpan(
              text: m.group(0),
              style: base.copyWith(
                  color: const Color(0xFF001B7C),
                  fontWeight: FontWeight.w700)));
          line = line.substring(m.end);
        }
      }
      var at = 0;
      for (final b in _bold.allMatches(line)) {
        if (b.start > at) {
          spans.add(TextSpan(text: line.substring(at, b.start), style: ls));
        }
        spans.add(TextSpan(text: '**', style: faint));
        spans.add(TextSpan(
            text: b.group(1), style: ls.copyWith(fontWeight: FontWeight.w700)));
        spans.add(TextSpan(text: '**', style: faint));
        at = b.end;
      }
      if (at < line.length)
        spans.add(TextSpan(text: line.substring(at), style: ls));
      if (li < lines.length - 1) spans.add(TextSpan(text: '\n', style: base));
    }
    return TextSpan(style: base, children: spans);
  }
}

/// ไอคอน Diagnosis Text (Figma 425:56) โครงเดียวกับแฟ้มหนีบในการ์ดคำสั่ง (_ClipboardHero):
/// แผ่นรองฟ้าเข้ม (สันน้ำเงิน 6 ชั้น) + ปึกกระดาษ (3 ชั้น) + หน้ากระดาษ · มุมเอียงเท่ากัน
/// รูปทรงใหญ่ไม่กี่ชิ้น สี Google อิ่ม ๆ: กระดาษขาวมุมพับฟ้า กากบาทแดง บรรทัดเทา · ดินสอเหลืองทับ
class _DxDocIcon extends StatelessWidget {
  const _DxDocIcon();

  static Matrix4 _tilt(double z) => Matrix4.identity()
    ..setEntry(3, 2, 0.0022)
    ..rotateX(0.28)
    ..rotateY(-0.42)
    ..rotateZ(0.12)
    ..translate(0.0, 0.0, z);

  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        for (var i = 6; i >= 1; i--)
          Transform(
            alignment: Alignment.center,
            transform: _tilt(-i * 1.2),
            child: const CustomPaint(painter: _DxDocArt(layer: 1)),
          ),
        for (var i = 3; i >= 1; i--)
          Transform(
            alignment: Alignment.center,
            transform: _tilt(i * 0.9),
            child: const CustomPaint(painter: _DxDocArt(layer: 2)),
          ),
        Transform(
          alignment: Alignment.center,
          transform: _tilt(3.6),
          child: const CustomPaint(painter: _DxDocArt()),
        ),
        for (var i = 3; i >= 0; i--)
          Transform.translate(
            offset: Offset(i * 0.35, i * 0.35),
            child: CustomPaint(painter: _DxPencilArt(shade: i > 0)),
          ),
      ]);
}

class _DxDocArt extends CustomPainter {
  /// 0 = หน้าเต็ม · 1 = สันแผ่นรอง · 2 = ขอบปึกกระดาษ
  const _DxDocArt({this.layer = 0});
  final int layer;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final board = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.76, h * 0.88),
        Radius.circular(w * 0.12));
    if (layer == 1) {
      canvas.drawRRect(board, Paint()..color = const Color(0xFF1A5BC4));
      return;
    }
    canvas.drawRRect(board, Paint()..color = const Color(0xFF4285F4));
    // กระดาษ: มุมขวาบนตัดพับ
    final r = Rect.fromLTWH(w * 0.14, h * 0.13, w * 0.64, h * 0.78);
    final f = w * 0.17, rr = w * 0.06;
    final paper = Path()
      ..moveTo(r.left + rr, r.top)
      ..lineTo(r.right - f, r.top)
      ..lineTo(r.right, r.top + f)
      ..lineTo(r.right, r.bottom - rr)
      ..quadraticBezierTo(r.right, r.bottom, r.right - rr, r.bottom)
      ..lineTo(r.left + rr, r.bottom)
      ..quadraticBezierTo(r.left, r.bottom, r.left, r.bottom - rr)
      ..lineTo(r.left, r.top + rr)
      ..quadraticBezierTo(r.left, r.top, r.left + rr, r.top)
      ..close();
    if (layer == 2) {
      canvas.drawPath(paper, Paint()..color = const Color(0xFFE3E7EE));
      return;
    }
    canvas.drawPath(paper, Paint()..color = Colors.white);
    // มุมพับ (ฟ้าอ่อน)
    canvas.drawPath(
        Path()
          ..moveTo(r.right - f, r.top)
          ..lineTo(r.right - f, r.top + f)
          ..lineTo(r.right, r.top + f)
          ..close(),
        Paint()..color = const Color(0xFFAECBFA));
    // กากบาทแดง
    final c = Offset(r.left + w * 0.16, r.top + h * 0.16);
    final a = w * 0.04, b = w * 0.19;
    final red = Paint()..color = const Color(0xFFEA4335);
    for (final q in [
      Rect.fromCenter(center: c, width: a * 2, height: b),
      Rect.fromCenter(center: c, width: b, height: a * 2),
    ]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(q, Radius.circular(w * 0.012)), red);
    }
    // บรรทัด (เทาแบบแฟ้มหนีบ)
    final line = Paint()
      ..color = const Color(0xFFDADCE0)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    for (final (y, x1) in [(0.52, 0.66), (0.66, 0.6), (0.8, 0.44)]) {
      canvas.drawLine(Offset(w * 0.24, h * y), Offset(w * x1, h * y), line);
    }
  }

  @override
  bool shouldRepaint(_DxDocArt o) => o.layer != layer;
}

/// ดินสอเหลืองเฉียงขวาบน → ซ้ายล่าง · shade = ชั้นด้านข้าง (สีเข้ม) ให้ดูหนา
class _DxPencilArt extends CustomPainter {
  const _DxPencilArt({this.shade = false});
  final bool shade;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.save();
    canvas.translate(w * 0.74, h * 0.7);
    canvas.rotate(-0.85);
    final len = w * 0.5, th = w * 0.12;
    // ตัวดินสอ (แกน x: 0 = ปลายแหลม → len = ยางลบ)
    final tip = w * 0.13;
    final bodyR = Rect.fromLTWH(tip - len * 0.45, -th / 2, len * 0.62, th);
    if (shade) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              bodyR.inflate(0.5), Radius.circular(th * 0.2)),
          Paint()..color = const Color(0xFFD48A00));
      canvas.restore();
      return;
    }
    canvas.drawRect(
        bodyR,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD54F), Color(0xFFFBBC04), Color(0xFFF29900)],
          ).createShader(bodyR));
    // ปลอกเงิน + ยางลบชมพู
    final band = Rect.fromLTWH(bodyR.right, -th / 2, th * 0.45, th);
    canvas.drawRect(band, Paint()..color = const Color(0xFFBDC1C6));
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(band.right, -th / 2, th * 0.7, th),
            topRight: Radius.circular(th * 0.4),
            bottomRight: Radius.circular(th * 0.4)),
        Paint()..color = const Color(0xFFF28B82));
    // ไม้เหลา + ไส้
    final wood = Path()
      ..moveTo(bodyR.left, -th / 2)
      ..lineTo(bodyR.left - tip, 0)
      ..lineTo(bodyR.left, th / 2)
      ..close();
    canvas.drawPath(wood, Paint()..color = const Color(0xFFF6D5A8));
    canvas.drawPath(
        Path()
          ..moveTo(bodyR.left - tip * 0.6, -th * 0.2)
          ..lineTo(bodyR.left - tip, 0)
          ..lineTo(bodyR.left - tip * 0.6, th * 0.2)
          ..close(),
        Paint()..color = const Color(0xFF3C4043));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DxPencilArt o) => o.shade != shade;
}

/// หูฟัง (chest piece) 3D ทับภาพแพทย์ · แสงวิ้ง (shimmer) กวาดผ่านแผ่นโลหะทุก 3.2 วิ
class _StethoBeat extends StatefulWidget {
  const _StethoBeat();

  @override
  State<_StethoBeat> createState() => _StethoBeatState();
}

class _StethoBeatState extends State<_StethoBeat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) =>
              CustomPaint(painter: _StethoArt(_c.value), size: Size.infinite),
        ),
      );
}

class _StethoArt extends CustomPainter {
  const _StethoArt(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 10.5;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    // เงาตกด้านล่างขวา (ลอยจากเสื้อ)
    canvas.drawOval(
        Rect.fromCenter(
            center: const Offset(1.8, 3.2), width: r * 2.1, height: r * 1.9),
        Paint()
          ..color = const Color(0x330B1B3F)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6));
    // ขอบโลหะหนา (ด้านข้าง) + หน้าขอบไล่แสงซ้ายบน
    canvas.drawCircle(
        const Offset(0.6, 1.2), r, Paint()..color = const Color(0xFF0B2E7A));
    final rim = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(
        Offset.zero,
        r,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.45, -0.55),
            radius: 1.1,
            colors: [Color(0xFF8AB4F8), Color(0xFF1A73E8), Color(0xFF0D47A1)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(rim));
    // แผ่นรับเสียง (diaphragm) เงินฟ้า นูนเล็กน้อย
    final dr = r * 0.62;
    final disk = Rect.fromCircle(center: Offset.zero, radius: dr);
    canvas.drawCircle(
        Offset.zero,
        dr,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.35, -0.45),
            colors: [Colors.white, Color(0xFFDCE6F5), Color(0xFF9FB4D6)],
            stops: [0.0, 0.55, 1.0],
          ).createShader(disk));
    canvas.drawCircle(
        Offset.zero,
        dr,
        Paint()
          ..color = const Color(0x660D47A1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
    // แสงวิ้งกวาดผ่านแผ่น แล้วพัก (อย่างเดียว ไม่มีเต้น/คลื่น/หัวใจ)
    final g = (t / 0.3).clamp(0.0, 1.0);
    if (g > 0 && g < 1) {
      canvas.save();
      canvas.clipPath(Path()..addOval(disk));
      final x = -dr * 1.6 + dr * 3.2 * g;
      canvas.drawRect(Rect.fromLTWH(x - 2.5, -dr, 5.0, dr * 2),
          Paint()..color = Colors.white.withValues(alpha: 0.8));
      canvas.restore();
    }
    // ไฮไลต์โค้งบนขอบ
    canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: r * 0.82),
        math.pi * 1.05,
        math.pi * 0.45,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StethoArt o) => o.t != t;
}

/// รูปการ์ด ICD-10: กระดาษ + แว่นขยายตัวเดียวกับการ์ด AI ช่วยวินิจฉัย (reuse _MagnifierHero)
/// idle motion: แว่นลอยส่ายช้า ๆ บนกระดาษ เห็น "ICD-10" ในเลนส์ + แสงวิ้งเป็นระยะ
class _IcdPaperArt extends StatelessWidget {
  const _IcdPaperArt({this.label = 'ICD-10'});

  /// คำในเลนส์แว่นขยาย
  final String label;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(children: [
            Positioned.fill(
              child: Image.asset('assets/images/er_dx_text.png',
                  filterQuality: FilterQuality.medium),
            ),
            Positioned.fill(child: _MagnifierHero(icd: true, label: label)),
          ]),
        ),
      );
}

/// ไอคอน Phosphor (MIT) วาดจาก path SVG 24×24
/// แต่ละ path = (d, ทึบ?, evenOdd?) · เพิ่ม = Regular · อื่น = Fill
/// วาดเป็นเส้น ความหนากำหนดเป็นพิกเซลจริง ใช้ในแผ่นปุ่มลัดการ์ด Diagnosis Text และ ICD-10
const _solarIcons = <String, List<(String, bool, bool)>>{
  // Phosphor check (Bold) · ✓/ดินสอในวงสถานะ
  'ph-check': [
    (
      'M21.796 7.546L9.796 19.546C9.585 19.758 9.298 19.877 8.999 19.877C8.7 19.877 8.413 19.758 8.202 19.546L2.952 14.296C2.512 13.856 2.512 13.142 2.952 12.702C3.392 12.262 4.106 12.262 4.546 12.702L9 17.156L20.204 5.954C20.644 5.514 21.358 5.514 21.798 5.954C22.238 6.394 22.238 7.108 21.798 7.548Z',
      true,
      false
    )
  ],
  // Phosphor plus (Bold) · ปลายมน (โค้งแทน arc เพราะตัวอ่าน path ไม่รองรับ A)
  'ph-plus': [
    (
      'M10.875 3.75C10.875 3.129 11.379 2.625 12 2.625C12.621 2.625 13.125 3.129 13.125 3.75V10.875H20.25C20.871 10.875 21.375 11.379 21.375 12C21.375 12.621 20.871 13.125 20.25 13.125H13.125V20.25C13.125 20.871 12.621 21.375 12 21.375C11.379 21.375 10.875 20.871 10.875 20.25V13.125H3.75C3.129 13.125 2.625 12.621 2.625 12C2.625 11.379 3.129 10.875 3.75 10.875H10.875Z',
      true,
      false
    )
  ],
  // Phosphor pencil-simple (Bold) · ✓/ดินสอในวงสถานะ
  'ph-pencil': [
    (
      'M21.576 6.613L17.387 2.423C17.035 2.072 16.558 1.874 16.061 1.874C15.563 1.874 15.086 2.072 14.735 2.423L3.174 13.985C2.821 14.335 2.624 14.813 2.625 15.31L2.625 19.5C2.625 20.536 3.464 21.375 4.5 21.375L8.69 21.375C9.187 21.376 9.665 21.179 10.015 20.826L21.576 9.264C22.308 8.532 22.308 7.345 21.576 6.613ZM8.531 19.125L4.875 19.125L4.875 15.469L12.75 7.594L16.406 11.25ZM18 9.656L14.344 6L16.063 4.281L19.719 7.937Z',
      true,
      false
    )
  ],
  // Phosphor clock (Regular) · ป้ายยาในแบบร่าง
  'ph-clock': [
    (
      'M12 2.25C6.615 2.25 2.25 6.615 2.25 12C2.25 17.385 6.615 21.75 12 21.75C17.385 21.75 21.75 17.385 21.75 12C21.744 6.618 17.382 2.256 12 2.25ZM12 20.25C7.444 20.25 3.75 16.556 3.75 12C3.75 7.444 7.444 3.75 12 3.75C16.556 3.75 20.25 7.444 20.25 12C20.245 16.554 16.554 20.245 12 20.25ZM18 12C18 12.414 17.664 12.75 17.25 12.75L12 12.75C11.586 12.75 11.25 12.414 11.25 12L11.25 6.75C11.25 6.336 11.586 6 12 6C12.414 6 12.75 6.336 12.75 6.75L12.75 11.25L17.25 11.25C17.664 11.25 18 11.586 18 12Z',
      true,
      false
    )
  ],
  // Phosphor package (Regular) · ป้ายยาในแบบร่าง
  'ph-package': [
    (
      'M20.97 6.202L12.72 1.688C12.272 1.44 11.728 1.44 11.28 1.688L3.03 6.203C2.55 6.466 2.251 6.969 2.25 7.516L2.25 16.482C2.251 17.029 2.55 17.532 3.03 17.795L11.28 22.311C11.728 22.558 12.272 22.558 12.72 22.311L20.97 17.795C21.45 17.532 21.749 17.029 21.75 16.482L21.75 7.517C21.75 6.969 21.451 6.465 20.97 6.202ZM12 3L19.532 7.125L16.741 8.653L9.208 4.528ZM12 11.25L4.468 7.125L7.646 5.385L15.178 9.51ZM3.75 8.438L11.25 12.542L11.25 20.585L3.75 16.483ZM20.25 16.479L20.25 16.479L12.75 20.585L12.75 12.546L15.75 10.904L15.75 14.25C15.75 14.664 16.086 15 16.5 15C16.914 15 17.25 14.664 17.25 14.25L17.25 10.083L20.25 8.438L20.25 16.478Z',
      true,
      false
    )
  ],
  // Phosphor path (Regular) · ป้ายยาในแบบร่าง
  'ph-path': [
    (
      'M18.75 15.75C17.382 15.751 16.188 16.676 15.844 18L6.75 18C5.093 18 3.75 16.657 3.75 15C3.75 13.343 5.093 12 6.75 12L15.75 12C17.821 12 19.5 10.321 19.5 8.25C19.5 6.179 17.821 4.5 15.75 4.5L6.75 4.5C6.336 4.5 6 4.836 6 5.25C6 5.664 6.336 6 6.75 6L15.75 6C16.993 6 18 7.007 18 8.25C18 9.493 16.993 10.5 15.75 10.5L6.75 10.5C4.265 10.5 2.25 12.515 2.25 15C2.25 17.485 4.265 19.5 6.75 19.5L15.844 19.5C16.233 21.009 17.714 21.969 19.251 21.708C20.788 21.447 21.869 20.052 21.738 18.499C21.607 16.945 20.309 15.751 18.75 15.75ZM18.75 20.25C17.922 20.25 17.25 19.578 17.25 18.75C17.25 17.922 17.922 17.25 18.75 17.25C19.578 17.25 20.25 17.922 20.25 18.75C20.25 19.578 19.578 20.25 18.75 20.25Z',
      true,
      false
    )
  ],
  // Phosphor pill (Regular) · ป้ายยาในแบบร่าง
  'ph-syringe': [
    (
      'M22.281 6.219L17.781 1.719C17.488 1.426 17.012 1.426 16.719 1.719C16.426 2.012 16.426 2.488 16.719 2.781L18.44 4.5L15.75 7.19L12.531 3.969C12.238 3.676 11.762 3.676 11.469 3.969C11.176 4.262 11.176 4.738 11.469 5.031L12.065 5.625L4.19 13.5C3.907 13.78 3.749 14.162 3.75 14.56L3.75 19.19L1.719 21.219C1.426 21.512 1.426 21.988 1.719 22.281C2.012 22.574 2.488 22.574 2.781 22.281L4.81 20.25L9.44 20.25C9.838 20.251 10.22 20.093 10.5 19.81L18.375 11.935L18.969 12.531C19.262 12.824 19.738 12.824 20.031 12.531C20.324 12.238 20.324 11.762 20.031 11.469L16.81 8.25L19.5 5.56L21.219 7.281C21.512 7.574 21.988 7.574 22.281 7.281C22.574 6.988 22.574 6.512 22.281 6.219ZM9.44 18.75L5.25 18.75L5.25 14.56L6.938 12.873L8.844 14.781C9.137 15.074 9.613 15.074 9.906 14.781C10.199 14.488 10.199 14.012 9.906 13.719L7.998 11.812L9.188 10.623L11.094 12.531C11.387 12.824 11.863 12.824 12.156 12.531C12.449 12.238 12.449 11.762 12.156 11.469L10.248 9.562L13.125 6.685L17.315 10.875Z',
      true,
      false
    )
  ],
  'ph-lightning': [
    (
      'M20.23 11.078C20.173 10.834 19.997 10.635 19.762 10.548L14.361 8.522L15.735 1.647C15.799 1.319 15.638 0.988 15.34 0.836C15.043 0.684 14.68 0.747 14.452 0.991L3.952 12.241C3.778 12.423 3.708 12.681 3.765 12.926C3.821 13.171 3.997 13.372 4.233 13.46L9.636 15.486L8.265 22.353C8.201 22.681 8.362 23.012 8.66 23.164C8.957 23.316 9.32 23.253 9.548 23.009L20.048 11.759C20.218 11.577 20.287 11.321 20.23 11.078ZM10.253 20.062L11.235 15.152C11.308 14.792 11.109 14.433 10.766 14.303L5.812 12.442L13.746 3.942L12.765 8.853C12.692 9.212 12.891 9.572 13.234 9.702L18.184 11.558Z',
      true,
      false
    )
  ],
  'ph-hourglass': [
    (
      'M19.125 7.091L19.125 3.75C19.125 2.714 18.286 1.875 17.25 1.875L6.75 1.875C5.714 1.875 4.875 2.714 4.875 3.75L4.875 7.125C4.876 7.715 5.154 8.27 5.625 8.625L10.125 12L5.625 15.375C5.154 15.73 4.876 16.285 4.875 16.875L4.875 20.25C4.875 21.286 5.714 22.125 6.75 22.125L17.25 22.125C18.286 22.125 19.125 21.286 19.125 20.25L19.125 16.909C19.124 16.32 18.849 15.765 18.381 15.409L13.866 12L18.381 8.587C18.848 8.232 19.123 7.679 19.125 7.091ZM16.875 4.125L16.875 6.75L7.125 6.75L7.125 4.125ZM12 10.594L9.875 9L14.103 9ZM16.875 19.875L7.125 19.875L7.125 17.062L10.875 14.25L10.875 15.75C10.875 16.371 11.379 16.875 12 16.875C12.621 16.875 13.125 16.371 13.125 15.75L13.125 14.26L16.875 17.095Z',
      true,
      false
    )
  ],
  'ph-file-text': [
    (
      'M20.296 7.455L15.046 2.205C14.835 1.994 14.549 1.875 14.25 1.875L5.25 1.875C4.214 1.875 3.375 2.714 3.375 3.75L3.375 20.25C3.375 21.286 4.214 22.125 5.25 22.125L18.75 22.125C19.786 22.125 20.625 21.286 20.625 20.25L20.625 8.25C20.625 7.952 20.507 7.666 20.296 7.455ZM15 5.344L17.156 7.5L15 7.5ZM5.625 19.875L5.625 4.125L12.75 4.125L12.75 8.625C12.75 9.246 13.254 9.75 13.875 9.75L18.375 9.75L18.375 19.875ZM16.125 12.375C16.125 12.996 15.621 13.5 15 13.5L9 13.5C8.379 13.5 7.875 12.996 7.875 12.375C7.875 11.754 8.379 11.25 9 11.25L15 11.25C15.621 11.25 16.125 11.754 16.125 12.375ZM16.125 16.125C16.125 16.746 15.621 17.25 15 17.25L9 17.25C8.379 17.25 7.875 16.746 7.875 16.125C7.875 15.504 8.379 15 9 15L15 15C15.621 15 16.125 15.504 16.125 16.125Z',
      true,
      false
    )
  ],
  // Phosphor (Regular) · เหรียญขั้นงานรังสี: ส่งคำสั่ง รับตัว ฉายรังสี อ่านฟิล์ม ยืนยันผล
  'ph-paper-plane-tilt': [
    (
      'M21.311 2.689C20.927 2.305 20.366 2.159 19.843 2.306L19.829 2.306L1.835 7.766C1.237 7.939 0.807 8.462 0.755 9.083C0.703 9.703 1.04 10.291 1.601 10.56L9.562 14.438L13.434 22.394C13.68 22.919 14.209 23.253 14.788 23.25C14.831 23.25 14.874 23.248 14.918 23.244C15.537 23.194 16.061 22.764 16.23 22.165L21.686 4.171C21.686 4.166 21.686 4.162 21.686 4.157C21.836 3.636 21.692 3.074 21.311 2.689ZM14.797 21.736L14.792 21.749L14.792 21.742L11.036 14.027L15.536 9.527C15.816 9.232 15.81 8.768 15.523 8.48C15.235 8.192 14.771 8.186 14.476 8.467L9.976 12.967L2.257 9.211L2.251 9.211L2.264 9.211L20.25 3.75Z',
      true,
      false
    )
  ],
  'ph-user': [
    (
      'M21.649 19.875C20.221 17.407 18.021 15.637 15.453 14.797C18.064 13.243 19.314 10.136 18.508 7.207C17.702 4.277 15.038 2.247 12 2.247C8.962 2.247 6.298 4.277 5.492 7.207C4.686 10.136 5.936 13.243 8.547 14.797C5.979 15.636 3.779 17.406 2.351 19.875C2.209 20.107 2.204 20.399 2.338 20.636C2.472 20.874 2.724 21.019 2.997 21.017C3.27 21.015 3.52 20.865 3.65 20.625C5.416 17.572 8.538 15.75 12 15.75C15.462 15.75 18.584 17.572 20.35 20.625C20.48 20.865 20.73 21.015 21.003 21.017C21.276 21.019 21.528 20.874 21.662 20.636C21.796 20.399 21.791 20.107 21.649 19.875ZM6.75 9C6.75 6.101 9.101 3.75 12 3.75C14.899 3.75 17.25 6.101 17.25 9C17.25 11.899 14.899 14.25 12 14.25C9.102 14.247 6.753 11.898 6.75 9Z',
      true,
      false
    )
  ],
  'ph-aperture': [
    (
      'M18.894 5.106C15.087 1.298 8.913 1.298 5.106 5.106C1.298 8.913 1.298 15.087 5.106 18.894C8.913 22.702 15.087 22.702 18.894 18.894C22.702 15.087 22.702 8.913 18.894 5.106ZM17.834 6.167C18.219 6.553 18.564 6.976 18.865 7.431L15.708 11.156L13.09 3.823C14.887 4.058 16.556 4.882 17.834 6.167ZM14.587 12.469L12.884 14.472L10.297 14.003L9.413 11.531L11.116 9.528L13.703 9.997ZM6.166 6.167C7.582 4.743 9.473 3.889 11.478 3.768L13.119 8.362L5.466 6.967C5.682 6.686 5.916 6.418 6.166 6.167ZM4.373 15.144C3.473 12.946 3.56 10.467 4.611 8.336L9.412 9.213ZM6.166 17.833C5.781 17.447 5.436 17.024 5.135 16.569L8.292 12.844L10.91 20.173C9.113 19.939 7.445 19.116 6.166 17.833ZM17.834 17.833C16.418 19.257 14.527 20.111 12.522 20.232L10.881 15.638L18.534 17.036C18.318 17.317 18.084 17.583 17.834 17.833ZM14.588 14.787L19.627 8.856C20.527 11.054 20.44 13.533 19.389 15.664Z',
      true,
      false
    )
  ],
  'ph-eye': [
    (
      'M23.185 11.696C23.152 11.622 22.358 9.861 20.593 8.095C18.241 5.743 15.27 4.5 12 4.5C8.73 4.5 5.759 5.743 3.407 8.095C1.642 9.861 0.844 11.625 0.815 11.696C0.728 11.89 0.728 12.112 0.815 12.306C0.847 12.38 1.642 14.14 3.407 15.906C5.759 18.257 8.73 19.5 12 19.5C15.27 19.5 18.241 18.257 20.593 15.906C22.358 14.14 23.152 12.38 23.185 12.306C23.272 12.112 23.272 11.89 23.185 11.696ZM12 18C9.114 18 6.593 16.951 4.507 14.883C3.65 14.031 2.922 13.06 2.344 12C2.922 10.94 3.65 9.969 4.507 9.117C6.593 7.049 9.114 6 12 6C14.886 6 17.407 7.049 19.493 9.117C20.351 9.968 21.081 10.939 21.661 12C20.985 13.262 18.04 18 12 18ZM12 7.5C9.515 7.5 7.5 9.515 7.5 12C7.5 14.485 9.515 16.5 12 16.5C14.485 16.5 16.5 14.485 16.5 12C16.497 9.516 14.484 7.503 12 7.5ZM12 15C10.343 15 9 13.657 9 12C9 10.343 10.343 9 12 9C13.657 9 15 10.343 15 12C15 13.657 13.657 15 12 15Z',
      true,
      false
    )
  ],
  // Phosphor (Regular) · ไอคอนแผ่น "เมนูอื่น ๆ"
  'ph-heartbeat': [
    (
      'M6.75 13.5L3 13.5C2.586 13.5 2.25 13.164 2.25 12.75C2.25 12.336 2.586 12 3 12L6.349 12L7.626 10.084C7.765 9.875 7.999 9.749 8.25 9.749C8.501 9.749 8.735 9.875 8.874 10.084L11.25 13.646L12.126 12.334C12.265 12.125 12.499 12 12.75 12L15 12C15.414 12 15.75 12.336 15.75 12.75C15.75 13.164 15.414 13.5 15 13.5L13.151 13.5L11.874 15.416C11.735 15.625 11.501 15.751 11.25 15.751C10.999 15.751 10.765 15.625 10.626 15.416L8.25 11.852L7.374 13.164C7.236 13.374 7.001 13.5 6.75 13.5ZM16.688 3.75C14.752 3.75 13.057 4.583 12 5.99C10.943 4.583 9.248 3.75 7.312 3.75C4.104 3.754 1.504 6.354 1.5 9.562C1.5 9.633 1.5 9.703 1.5 9.773C1.513 10.188 1.859 10.513 2.273 10.5C2.688 10.487 3.013 10.141 3 9.727C3 9.672 3 9.617 3 9.562C3.003 7.182 4.932 5.253 7.312 5.25C9.136 5.25 10.667 6.221 11.306 7.781C11.422 8.063 11.696 8.246 12 8.246C12.304 8.246 12.578 8.063 12.694 7.781C13.333 6.218 14.864 5.25 16.688 5.25C19.068 5.253 20.997 7.182 21 9.562C21 14.588 13.71 19.139 12 20.138C10.985 19.546 8.003 17.7 5.749 15.243C5.568 15.045 5.295 14.959 5.033 15.017C4.771 15.076 4.56 15.269 4.48 15.525C4.399 15.78 4.461 16.06 4.643 16.257C7.565 19.445 11.48 21.571 11.645 21.66C11.867 21.779 12.133 21.779 12.355 21.66C12.77 21.437 22.5 16.125 22.5 9.562C22.496 6.354 19.896 3.754 16.688 3.75Z',
      true,
      false
    )
  ],
  'ph-calendar-blank': [
    (
      'M19.5 3L17.25 3L17.25 2.25C17.25 1.836 16.914 1.5 16.5 1.5C16.086 1.5 15.75 1.836 15.75 2.25L15.75 3L8.25 3L8.25 2.25C8.25 1.836 7.914 1.5 7.5 1.5C7.086 1.5 6.75 1.836 6.75 2.25L6.75 3L4.5 3C3.672 3 3 3.672 3 4.5L3 19.5C3 20.328 3.672 21 4.5 21L19.5 21C20.328 21 21 20.328 21 19.5L21 4.5C21 3.672 20.328 3 19.5 3ZM6.75 4.5L6.75 5.25C6.75 5.664 7.086 6 7.5 6C7.914 6 8.25 5.664 8.25 5.25L8.25 4.5L15.75 4.5L15.75 5.25C15.75 5.664 16.086 6 16.5 6C16.914 6 17.25 5.664 17.25 5.25L17.25 4.5L19.5 4.5L19.5 7.5L4.5 7.5L4.5 4.5ZM19.5 19.5L4.5 19.5L4.5 9L19.5 9L19.5 19.5Z',
      true,
      false
    )
  ],
  'ph-receipt': [
    (
      'M6.75 9.75C6.75 9.336 7.086 9 7.5 9L16.5 9C16.914 9 17.25 9.336 17.25 9.75C17.25 10.164 16.914 10.5 16.5 10.5L7.5 10.5C7.086 10.5 6.75 10.164 6.75 9.75ZM7.5 13.5L16.5 13.5C16.914 13.5 17.25 13.164 17.25 12.75C17.25 12.336 16.914 12 16.5 12L7.5 12C7.086 12 6.75 12.336 6.75 12.75C6.75 13.164 7.086 13.5 7.5 13.5ZM21.75 5.25L21.75 19.5C21.75 19.76 21.615 20.001 21.394 20.138C21.173 20.274 20.897 20.287 20.664 20.17L18 18.838L15.336 20.17C15.124 20.276 14.876 20.276 14.664 20.17L12 18.838L9.336 20.17C9.124 20.276 8.876 20.276 8.664 20.17L6 18.838L3.336 20.17C3.103 20.287 2.827 20.274 2.606 20.138C2.385 20.001 2.25 19.76 2.25 19.5L2.25 5.25C2.25 4.422 2.922 3.75 3.75 3.75L20.25 3.75C21.078 3.75 21.75 4.422 21.75 5.25ZM20.25 5.25L3.75 5.25L3.75 18.287L5.664 17.329C5.876 17.223 6.124 17.223 6.336 17.329L9 18.662L11.664 17.329C11.876 17.223 12.124 17.223 12.336 17.329L15 18.662L17.664 17.329C17.876 17.223 18.124 17.223 18.336 17.329L20.25 18.287Z',
      true,
      false
    )
  ],
  'ph-car-profile': [
    (
      'M22.5 10.5L19.81 10.5L15.75 6.44C15.47 6.157 15.088 5.999 14.69 6L4.151 6C3.651 6.001 3.184 6.251 2.906 6.668L0.126 10.834C0.044 10.957 0 11.102 0 11.25L0 15.75C0 16.578 0.672 17.25 1.5 17.25L3.094 17.25C3.434 18.577 4.63 19.506 6 19.506C7.37 19.506 8.566 18.577 8.906 17.25L15.094 17.25C15.434 18.577 16.63 19.506 18 19.506C19.37 19.506 20.566 18.577 20.906 17.25L22.5 17.25C23.328 17.25 24 16.578 24 15.75L24 12C24 11.172 23.328 10.5 22.5 10.5ZM4.151 7.5L14.69 7.5L17.69 10.5L2.156 10.5ZM6 18C5.172 18 4.5 17.328 4.5 16.5C4.5 15.672 5.172 15 6 15C6.828 15 7.5 15.672 7.5 16.5C7.5 17.328 6.828 18 6 18ZM18 18C17.172 18 16.5 17.328 16.5 16.5C16.5 15.672 17.172 15 18 15C18.828 15 19.5 15.672 19.5 16.5C19.5 17.328 18.828 18 18 18ZM22.5 15.75L20.906 15.75C20.566 14.423 19.37 13.494 18 13.494C16.63 13.494 15.434 14.423 15.094 15.75L8.906 15.75C8.566 14.423 7.37 13.494 6 13.494C4.63 13.494 3.434 14.423 3.094 15.75L1.5 15.75L1.5 12L22.5 12Z',
      true,
      false
    )
  ],
  'ph-clock-counter-clockwise': [
    (
      'M12.75 7.5L12.75 11.575L16.136 13.607C16.491 13.82 16.606 14.281 16.393 14.636C16.18 14.991 15.719 15.106 15.364 14.893L11.614 12.643C11.388 12.507 11.25 12.263 11.25 12L11.25 7.5C11.25 7.086 11.586 6.75 12 6.75C12.414 6.75 12.75 7.086 12.75 7.5ZM12 3C9.61 2.994 7.317 3.944 5.632 5.639C4.951 6.329 4.345 6.993 3.75 7.688L3.75 6C3.75 5.586 3.414 5.25 3 5.25C2.586 5.25 2.25 5.586 2.25 6L2.25 9.75C2.25 10.164 2.586 10.5 3 10.5L6.75 10.5C7.164 10.5 7.5 10.164 7.5 9.75C7.5 9.336 7.164 9 6.75 9L4.594 9C5.264 8.211 5.932 7.467 6.693 6.697C9.602 3.788 14.311 3.765 17.248 6.646C20.185 9.526 20.253 14.235 17.401 17.2C14.548 20.164 9.84 20.278 6.848 17.454C6.547 17.17 6.072 17.183 5.787 17.484C5.502 17.786 5.516 18.261 5.817 18.546C8.756 21.319 13.182 21.794 16.642 19.707C20.102 17.62 21.747 13.484 20.666 9.591C19.584 5.698 16.04 3.003 12 3Z',
      true,
      false
    )
  ],
  'ph-seal-check': [
    (
      'M21.174 9.639C20.821 9.27 20.455 8.889 20.318 8.555C20.19 8.248 20.183 7.74 20.175 7.248C20.161 6.333 20.146 5.296 19.425 4.575C18.704 3.854 17.667 3.839 16.752 3.825C16.26 3.817 15.752 3.81 15.445 3.682C15.112 3.545 14.73 3.179 14.361 2.826C13.714 2.204 12.979 1.5 12 1.5C11.021 1.5 10.287 2.204 9.639 2.826C9.27 3.179 8.889 3.545 8.555 3.683C8.25 3.81 7.74 3.817 7.248 3.825C6.333 3.839 5.296 3.854 4.575 4.575C3.854 5.296 3.844 6.333 3.825 7.248C3.817 7.74 3.81 8.248 3.682 8.555C3.545 8.888 3.179 9.27 2.826 9.639C2.204 10.286 1.5 11.021 1.5 12C1.5 12.979 2.204 13.713 2.826 14.361C3.179 14.73 3.545 15.111 3.683 15.445C3.81 15.752 3.817 16.26 3.825 16.752C3.839 17.667 3.854 18.704 4.575 19.425C5.296 20.146 6.333 20.161 7.248 20.175C7.74 20.183 8.248 20.19 8.555 20.317C8.888 20.455 9.27 20.821 9.639 21.174C10.286 21.796 11.021 22.5 12 22.5C12.979 22.5 13.713 21.796 14.361 21.174C14.73 20.821 15.111 20.455 15.445 20.318C15.752 20.19 16.26 20.183 16.752 20.175C17.667 20.161 18.704 20.146 19.425 19.425C20.146 18.704 20.161 17.667 20.175 16.752C20.183 16.26 20.19 15.752 20.317 15.445C20.455 15.112 20.821 14.73 21.174 14.361C21.796 13.714 22.5 12.979 22.5 12C22.5 11.021 21.796 10.287 21.174 9.639ZM20.092 13.323C19.643 13.792 19.178 14.276 18.931 14.872C18.695 15.443 18.684 16.097 18.675 16.73C18.666 17.386 18.655 18.073 18.364 18.364C18.072 18.654 17.39 18.666 16.73 18.675C16.097 18.684 15.443 18.695 14.872 18.931C14.276 19.177 13.792 19.642 13.323 20.092C12.854 20.541 12.375 21 12 21C11.625 21 11.142 20.539 10.677 20.092C10.212 19.644 9.724 19.178 9.128 18.931C8.557 18.695 7.903 18.684 7.27 18.675C6.614 18.666 5.927 18.655 5.636 18.364C5.346 18.072 5.334 17.39 5.325 16.73C5.316 16.097 5.305 15.443 5.069 14.872C4.823 14.276 4.358 13.792 3.908 13.323C3.459 12.854 3 12.375 3 12C3 11.625 3.461 11.142 3.908 10.677C4.356 10.212 4.822 9.724 5.069 9.128C5.305 8.557 5.316 7.903 5.325 7.27C5.334 6.614 5.345 5.927 5.636 5.636C5.928 5.346 6.61 5.334 7.27 5.325C7.903 5.316 8.557 5.305 9.128 5.069C9.724 4.822 10.208 4.357 10.677 3.908C11.146 3.459 11.625 3 12 3C12.375 3 12.858 3.461 13.323 3.908C13.788 4.356 14.276 4.822 14.872 5.069C15.443 5.305 16.097 5.316 16.73 5.325C17.386 5.334 18.073 5.345 18.364 5.636C18.654 5.928 18.666 6.61 18.675 7.27C18.684 7.903 18.695 8.557 18.931 9.128C19.178 9.724 19.643 10.208 20.092 10.677C20.541 11.146 21 11.625 21 12C21 12.375 20.539 12.858 20.092 13.323ZM16.281 9.219C16.421 9.36 16.501 9.551 16.501 9.75C16.501 9.949 16.421 10.14 16.281 10.281L11.031 15.531C10.89 15.671 10.699 15.751 10.5 15.751C10.301 15.751 10.11 15.671 9.969 15.531L7.719 13.281C7.426 12.988 7.426 12.512 7.719 12.219C8.012 11.926 8.488 11.926 8.781 12.219L10.5 13.94L15.219 9.219C15.36 9.079 15.551 8.999 15.75 8.999C15.949 8.999 16.14 9.079 16.281 9.219Z',
      true,
      false
    )
  ],
  'ph-pill': [
    (
      'M20.289 3.713C18.339 1.763 15.178 1.763 13.228 3.712L3.713 13.227C1.805 15.184 1.825 18.311 3.757 20.244C5.69 22.176 8.817 22.196 10.774 20.287L10.774 20.288L20.29 10.773C22.237 8.822 22.236 5.663 20.289 3.712ZM9.713 19.227L9.713 19.227C8.349 20.592 6.138 20.592 4.773 19.228C3.409 17.864 3.409 15.652 4.773 14.288L9 10.06L13.941 15ZM19.229 9.712L15 13.94L10.061 9L14.289 4.773C15.658 3.436 17.847 3.449 19.2 4.802C20.553 6.154 20.566 8.344 19.229 9.712ZM17.782 7.719C17.923 7.86 18.002 8.051 18.002 8.25C18.002 8.449 17.923 8.64 17.782 8.781L15.533 11.031C15.343 11.22 15.067 11.294 14.808 11.224C14.549 11.155 14.347 10.953 14.278 10.694C14.208 10.435 14.283 10.159 14.472 9.969L16.722 7.719C17.015 7.427 17.49 7.427 17.782 7.719Z',
      true,
      false
    )
  ],
  // Phosphor fork-knife (Regular) · ป้ายยาในแบบร่าง
  'ph-fork': [
    (
      'M6.75 8.25L6.75 3.75C6.75 3.336 7.086 3 7.5 3C7.914 3 8.25 3.336 8.25 3.75L8.25 8.25C8.25 8.664 7.914 9 7.5 9C7.086 9 6.75 8.664 6.75 8.25ZM20.25 3.75L20.25 21C20.25 21.414 19.914 21.75 19.5 21.75C19.086 21.75 18.75 21.414 18.75 21L18.75 16.5L14.25 16.5C13.836 16.5 13.5 16.164 13.5 15.75C13.535 13.953 13.762 12.166 14.177 10.417C15.094 6.622 16.832 4.077 19.205 3.061C19.436 2.962 19.702 2.985 19.913 3.124C20.123 3.263 20.25 3.498 20.25 3.75ZM18.75 5.053C15.734 7.357 15.143 12.967 15.028 15L18.75 15ZM11.24 3.627C11.2 3.359 11.018 3.134 10.765 3.037C10.512 2.94 10.226 2.988 10.018 3.162C9.81 3.335 9.711 3.607 9.76 3.874L10.5 8.309C10.5 9.966 9.157 11.309 7.5 11.309C5.843 11.309 4.5 9.966 4.5 8.309L5.239 3.874C5.288 3.607 5.189 3.335 4.981 3.162C4.773 2.988 4.487 2.94 4.234 3.037C3.981 3.134 3.799 3.359 3.759 3.627L3.009 8.127C3.003 8.168 3 8.209 3 8.25C3.003 10.445 4.587 12.318 6.75 12.686L6.75 21C6.75 21.414 7.086 21.75 7.5 21.75C7.914 21.75 8.25 21.414 8.25 21L8.25 12.686C10.413 12.318 11.997 10.445 12 8.25C12 8.209 11.996 8.168 11.99 8.127Z',
      true,
      false
    )
  ],
  // Phosphor pencil-simple (Fill)
  'แก้ไข': [
    (
      'M21.31 6.878L17.122 2.689C16.84 2.407 16.459 2.249 16.061 2.249C15.663 2.249 15.281 2.407 15 2.689L3.44 14.25C3.157 14.53 2.999 14.912 3 15.31L3 19.5C3 20.328 3.672 21 4.5 21L8.69 21C9.088 21.001 9.47 20.843 9.75 20.56L21.31 9C21.592 8.719 21.75 8.337 21.75 7.939C21.75 7.541 21.592 7.16 21.31 6.878ZM18 10.189L13.81 6L16.06 3.75L20.25 7.939Z',
      true,
      false
    )
  ],
  // Phosphor clock-counter-clockwise (Fill)
  'ประวัติ HPI': [
    (
      'M21 12C21 15.593 18.863 18.842 15.564 20.264C12.265 21.687 8.436 21.012 5.823 18.546C5.521 18.261 5.508 17.786 5.793 17.484C6.078 17.183 6.553 17.17 6.854 17.454C9.846 20.277 14.554 20.163 17.406 17.198C20.258 14.233 20.189 9.524 17.252 6.644C14.314 3.764 9.605 3.787 6.697 6.697C6.366 7.031 6.054 7.36 5.752 7.688L7.281 9.219C7.495 9.434 7.56 9.757 7.443 10.037C7.327 10.318 7.054 10.5 6.75 10.5L3 10.5C2.586 10.5 2.25 10.164 2.25 9.75L2.25 6C2.25 5.696 2.432 5.423 2.713 5.307C2.993 5.19 3.316 5.255 3.531 5.469L4.688 6.628C4.989 6.301 5.301 5.972 5.631 5.639C8.204 3.062 12.077 2.289 15.442 3.682C18.807 5.074 21.001 8.358 21 12ZM12 6.75C11.586 6.75 11.25 7.086 11.25 7.5L11.25 12C11.25 12.263 11.388 12.507 11.614 12.643L15.364 14.893C15.719 15.106 16.18 14.991 16.393 14.636C16.606 14.281 16.491 13.82 16.136 13.607L12.75 11.575L12.75 7.5C12.75 7.086 12.414 6.75 12 6.75Z',
      true,
      false
    )
  ],
  'เพิ่ม': [
    (
      'M21 12C21 12.132 20.965 12.261 20.9 12.375C20.834 12.489 20.739 12.584 20.625 12.65C20.511 12.715 20.382 12.75 20.25 12.75L12.75 12.75L12.75 20.25C12.75 20.408 12.7 20.563 12.607 20.691C12.514 20.819 12.382 20.914 12.232 20.963C12.081 21.012 11.919 21.012 11.768 20.963C11.618 20.914 11.486 20.819 11.393 20.691C11.3 20.563 11.25 20.408 11.25 20.25L11.25 12.75L3.75 12.75C3.592 12.75 3.437 12.7 3.309 12.607C3.181 12.514 3.086 12.382 3.037 12.232C2.988 12.081 2.988 11.919 3.037 11.768C3.086 11.618 3.181 11.486 3.309 11.393C3.437 11.3 3.592 11.25 3.75 11.25L11.25 11.25L11.25 3.75C11.25 3.592 11.3 3.437 11.393 3.309C11.486 3.181 11.618 3.086 11.768 3.037C11.919 2.988 12.081 2.988 12.232 3.037C12.382 3.086 12.514 3.181 12.607 3.309C12.7 3.437 12.75 3.592 12.75 3.75L12.75 11.25L20.25 11.25C20.382 11.25 20.511 11.285 20.625 11.35C20.739 11.416 20.834 11.511 20.9 11.625C20.965 11.739 21 11.868 21 12',
      true,
      false
    )
  ],
  'เทมเพลต': [
    (
      'M20.031 6.219L16.281 2.469C16.211 2.4 16.128 2.345 16.037 2.307C15.946 2.269 15.849 2.25 15.75 2.25L8.25 2.25C7.987 2.25 7.728 2.319 7.5 2.451C7.272 2.583 7.083 2.772 6.951 3C6.819 3.228 6.75 3.487 6.75 3.75L6.75 5.25L5.25 5.25C4.987 5.25 4.728 5.319 4.5 5.451C4.272 5.583 4.083 5.772 3.951 6C3.819 6.228 3.75 6.487 3.75 6.75L3.75 20.25C3.75 20.513 3.819 20.772 3.951 21C4.083 21.228 4.272 21.417 4.5 21.549C4.728 21.681 4.987 21.75 5.25 21.75L15.75 21.75C16.013 21.75 16.272 21.681 16.5 21.549C16.728 21.417 16.917 21.228 17.049 21C17.181 20.772 17.25 20.513 17.25 20.25L17.25 18.75L18.75 18.75C19.013 18.75 19.272 18.681 19.5 18.549C19.728 18.417 19.917 18.228 20.049 18C20.181 17.772 20.25 17.513 20.25 17.25L20.25 6.75C20.25 6.651 20.231 6.554 20.193 6.463C20.155 6.372 20.1 6.289 20.031 6.219M12.75 18L8.25 18C8.092 18 7.937 17.95 7.809 17.857C7.681 17.764 7.586 17.632 7.537 17.482C7.488 17.331 7.488 17.169 7.537 17.018C7.586 16.868 7.681 16.736 7.809 16.643C7.937 16.55 8.092 16.5 8.25 16.5L12.75 16.5C12.908 16.5 13.063 16.55 13.191 16.643C13.319 16.736 13.414 16.868 13.463 17.018C13.512 17.169 13.512 17.331 13.463 17.482C13.414 17.632 13.319 17.764 13.191 17.857C13.063 17.95 12.908 18 12.75 18M12.75 15L8.25 15C8.092 15 7.937 14.95 7.809 14.857C7.681 14.764 7.586 14.632 7.537 14.482C7.488 14.331 7.488 14.169 7.537 14.018C7.586 13.868 7.681 13.736 7.809 13.643C7.937 13.55 8.092 13.5 8.25 13.5L12.75 13.5C12.908 13.5 13.063 13.55 13.191 13.643C13.319 13.736 13.414 13.868 13.463 14.018C13.512 14.169 13.512 14.331 13.463 14.482C13.414 14.632 13.319 14.764 13.191 14.857C13.063 14.95 12.908 15 12.75 15M18.75 17.25L17.25 17.25L17.25 9.75C17.25 9.651 17.231 9.554 17.193 9.463C17.155 9.372 17.1 9.289 17.031 9.219L13.281 5.469C13.211 5.4 13.128 5.345 13.037 5.307C12.946 5.269 12.849 5.25 12.75 5.25L8.25 5.25L8.25 3.75L15.44 3.75L18.75 7.06Z',
      true,
      false
    )
  ],
  'Re-Diag': [
    (
      'M13.5 13.875C13.5 14.246 13.39 14.608 13.184 14.917C12.978 15.225 12.685 15.465 12.343 15.607C12 15.749 11.623 15.786 11.259 15.714C10.896 15.642 10.561 15.463 10.299 15.201C10.037 14.939 9.858 14.604 9.786 14.241C9.714 13.877 9.751 13.5 9.893 13.157C10.035 12.815 10.275 12.522 10.583 12.316C10.892 12.11 11.254 12 11.625 12C11.954 12 12.277 12.087 12.562 12.251C12.848 12.416 13.084 12.652 13.249 12.938C13.413 13.223 13.5 13.546 13.5 13.875M20.25 8.25L20.25 20.25C20.25 20.513 20.181 20.772 20.049 21C19.917 21.228 19.728 21.417 19.5 21.549C19.272 21.681 19.013 21.75 18.75 21.75L5.25 21.75C4.987 21.75 4.728 21.681 4.5 21.549C4.272 21.417 4.083 21.228 3.951 21C3.819 20.772 3.75 20.513 3.75 20.25L3.75 3.75C3.75 3.487 3.819 3.228 3.951 3C4.083 2.772 4.272 2.583 4.5 2.451C4.728 2.319 4.987 2.25 5.25 2.25L14.25 2.25C14.349 2.25 14.446 2.269 14.537 2.307C14.628 2.345 14.711 2.4 14.781 2.469L20.031 7.719C20.1 7.789 20.155 7.872 20.193 7.963C20.231 8.054 20.25 8.151 20.25 8.25M15.531 16.719L14.481 15.67C14.833 15.11 15.014 14.458 14.999 13.796C14.985 13.134 14.776 12.491 14.399 11.947C14.022 11.402 13.494 10.98 12.879 10.734C12.265 10.487 11.591 10.426 10.943 10.559C10.294 10.692 9.699 11.012 9.23 11.48C8.762 11.949 8.442 12.544 8.309 13.193C8.176 13.841 8.237 14.515 8.484 15.129C8.73 15.744 9.152 16.272 9.697 16.649C10.241 17.026 10.884 17.235 11.546 17.249C12.208 17.264 12.86 17.083 13.42 16.731L14.469 17.781C14.581 17.893 14.726 17.966 14.883 17.991C15.039 18.016 15.2 17.991 15.341 17.919C15.482 17.847 15.597 17.732 15.669 17.591C15.741 17.45 15.766 17.289 15.741 17.133C15.716 16.976 15.643 16.831 15.531 16.719M18.375 8.25L14.25 4.125L14.25 8.25Z',
      true,
      false
    )
  ],
  'AI แนะนำ': [
    (
      'M19.5 13.5C19.502 13.806 19.409 14.105 19.234 14.355C19.059 14.606 18.811 14.797 18.523 14.901L13.688 16.688L11.906 21.527C11.801 21.813 11.61 22.061 11.359 22.235C11.109 22.41 10.811 22.504 10.506 22.504C10.2 22.504 9.902 22.41 9.652 22.235C9.401 22.061 9.21 21.813 9.105 21.527L7.312 16.688L2.473 14.906C2.187 14.801 1.939 14.61 1.765 14.359C1.59 14.109 1.496 13.811 1.496 13.506C1.496 13.2 1.59 12.902 1.765 12.652C1.939 12.401 2.187 12.21 2.473 12.105L7.312 10.312L9.094 5.473C9.199 5.187 9.39 4.939 9.641 4.765C9.891 4.59 10.189 4.496 10.494 4.496C10.8 4.496 11.098 4.59 11.348 4.765C11.599 4.939 11.79 5.187 11.895 5.473L13.688 10.312L18.527 12.094C18.815 12.199 19.063 12.39 19.237 12.642C19.412 12.894 19.503 13.194 19.5 13.5M14.25 4.5L15.75 4.5L15.75 6C15.75 6.158 15.8 6.313 15.893 6.441C15.986 6.569 16.118 6.664 16.268 6.713C16.419 6.762 16.581 6.762 16.732 6.713C16.882 6.664 17.014 6.569 17.107 6.441C17.2 6.313 17.25 6.158 17.25 6L17.25 4.5L18.75 4.5C18.908 4.5 19.063 4.45 19.191 4.357C19.319 4.264 19.414 4.132 19.463 3.982C19.512 3.831 19.512 3.669 19.463 3.518C19.414 3.368 19.319 3.236 19.191 3.143C19.063 3.05 18.908 3 18.75 3L17.25 3L17.25 1.5C17.25 1.342 17.2 1.187 17.107 1.059C17.014 0.931 16.882 0.836 16.732 0.787C16.581 0.738 16.419 0.738 16.268 0.787C16.118 0.836 15.986 0.931 15.893 1.059C15.8 1.187 15.75 1.342 15.75 1.5L15.75 3L14.25 3C14.092 3 13.937 3.05 13.809 3.143C13.681 3.236 13.586 3.368 13.537 3.518C13.488 3.669 13.488 3.831 13.537 3.982C13.586 4.132 13.681 4.264 13.809 4.357C13.937 4.45 14.092 4.5 14.25 4.5M22.5 7.5L21.75 7.5L21.75 6.75C21.75 6.592 21.7 6.437 21.607 6.309C21.514 6.181 21.382 6.086 21.232 6.037C21.081 5.988 20.919 5.988 20.768 6.037C20.618 6.086 20.486 6.181 20.393 6.309C20.3 6.437 20.25 6.592 20.25 6.75L20.25 7.5L19.5 7.5C19.342 7.5 19.187 7.55 19.059 7.643C18.931 7.736 18.836 7.868 18.787 8.018C18.738 8.169 18.738 8.331 18.787 8.482C18.836 8.632 18.931 8.764 19.059 8.857C19.187 8.95 19.342 9 19.5 9L20.25 9L20.25 9.75C20.25 9.908 20.3 10.063 20.393 10.191C20.486 10.319 20.618 10.414 20.768 10.463C20.919 10.512 21.081 10.512 21.232 10.463C21.382 10.414 21.514 10.319 21.607 10.191C21.7 10.063 21.75 9.908 21.75 9.75L21.75 9L22.5 9C22.658 9 22.813 8.95 22.941 8.857C23.069 8.764 23.164 8.632 23.213 8.482C23.262 8.331 23.262 8.169 23.213 8.018C23.164 7.868 23.069 7.736 22.941 7.643C22.813 7.55 22.658 7.5 22.5 7.5',
      true,
      false
    )
  ],
  'กำลังคิด…': [
    (
      'M18.75 7.091L18.75 3.75C18.75 3.487 18.681 3.228 18.549 3C18.417 2.772 18.228 2.583 18 2.451C17.772 2.319 17.513 2.25 17.25 2.25L6.75 2.25C6.487 2.25 6.228 2.319 6 2.451C5.772 2.583 5.583 2.772 5.451 3C5.319 3.228 5.25 3.487 5.25 3.75L5.25 7.125C5.251 7.358 5.305 7.587 5.41 7.796C5.514 8.004 5.665 8.185 5.851 8.325L10.75 12L5.85 15.675C5.664 15.815 5.513 15.996 5.409 16.205C5.305 16.413 5.251 16.642 5.25 16.875L5.25 20.25C5.25 20.513 5.319 20.772 5.451 21C5.583 21.228 5.772 21.417 6 21.549C6.228 21.681 6.487 21.75 6.75 21.75L17.25 21.75C17.513 21.75 17.772 21.681 18 21.549C18.228 21.417 18.417 21.228 18.549 21C18.681 20.772 18.75 20.513 18.75 20.25L18.75 16.909C18.75 16.677 18.696 16.448 18.593 16.24C18.489 16.032 18.339 15.851 18.154 15.712L13.243 12L18.154 8.288C18.339 8.148 18.489 7.967 18.592 7.76C18.696 7.552 18.75 7.323 18.75 7.091',
      true,
      false
    )
  ],
  'พูด': [
    (
      'M7.5 12L7.5 6C7.5 5.05 7.801 4.124 8.359 3.355C8.918 2.586 9.706 2.014 10.609 1.72C11.513 1.427 12.487 1.427 13.391 1.72C14.294 2.014 15.082 2.586 15.641 3.355C16.199 4.124 16.5 5.05 16.5 6L16.5 12C16.5 12.95 16.199 13.876 15.641 14.645C15.082 15.414 14.294 15.986 13.391 16.28C12.487 16.573 11.513 16.573 10.609 16.28C9.706 15.986 8.918 15.414 8.359 14.645C7.801 13.876 7.5 12.95 7.5 12M19.5 12C19.5 11.842 19.45 11.687 19.357 11.559C19.264 11.431 19.132 11.336 18.982 11.287C18.831 11.238 18.669 11.238 18.518 11.287C18.368 11.336 18.236 11.431 18.143 11.559C18.05 11.687 18 11.842 18 12C18 13.267 17.599 14.502 16.854 15.527C16.109 16.552 15.059 17.315 13.854 17.706C12.649 18.098 11.351 18.098 10.146 17.706C8.941 17.315 7.891 16.552 7.146 15.527C6.401 14.502 6 13.267 6 12C6 11.842 5.95 11.687 5.857 11.559C5.764 11.431 5.632 11.336 5.482 11.287C5.331 11.238 5.169 11.238 5.018 11.287C4.868 11.336 4.736 11.431 4.643 11.559C4.55 11.687 4.5 11.842 4.5 12C4.502 13.231 4.806 14.443 5.386 15.529C5.966 16.615 6.804 17.542 7.827 18.228C8.849 18.914 10.025 19.338 11.25 19.462L11.25 22.5C11.25 22.658 11.3 22.813 11.393 22.941C11.486 23.069 11.618 23.164 11.768 23.213C11.919 23.262 12.081 23.262 12.232 23.213C12.382 23.164 12.514 23.069 12.607 22.941C12.7 22.813 12.75 22.658 12.75 22.5L12.75 19.462C13.975 19.338 15.151 18.914 16.173 18.228C17.196 17.542 18.034 16.615 18.614 15.529C19.194 14.443 19.498 13.231 19.5 12',
      true,
      false
    )
  ],
  'ดึงจากหัตถการ': [
    (
      'M20.25 5.25L16.5 5.25L16.5 4.5C16.5 4.105 16.396 3.717 16.199 3.375C16.001 3.033 15.717 2.749 15.375 2.551C15.033 2.354 14.645 2.25 14.25 2.25L9.75 2.25C9.355 2.25 8.967 2.354 8.625 2.551C8.283 2.749 7.999 3.033 7.801 3.375C7.604 3.717 7.5 4.105 7.5 4.5L7.5 5.25L3.75 5.25C3.487 5.25 3.228 5.319 3 5.451C2.772 5.583 2.583 5.772 2.451 6C2.319 6.228 2.25 6.487 2.25 6.75L2.25 18.75C2.25 19.013 2.319 19.272 2.451 19.5C2.583 19.728 2.772 19.917 3 20.049C3.228 20.181 3.487 20.25 3.75 20.25L20.25 20.25C20.513 20.25 20.772 20.181 21 20.049C21.228 19.917 21.417 19.728 21.549 19.5C21.681 19.272 21.75 19.013 21.75 18.75L21.75 6.75C21.75 6.487 21.681 6.228 21.549 6C21.417 5.772 21.228 5.583 21 5.451C20.772 5.319 20.513 5.25 20.25 5.25M14.25 13.5L12.75 13.5L12.75 15C12.75 15.158 12.7 15.313 12.607 15.441C12.514 15.569 12.382 15.664 12.232 15.713C12.081 15.762 11.919 15.762 11.768 15.713C11.618 15.664 11.486 15.569 11.393 15.441C11.3 15.313 11.25 15.158 11.25 15L11.25 13.5L9.75 13.5C9.592 13.5 9.437 13.45 9.309 13.357C9.181 13.264 9.086 13.132 9.037 12.982C8.988 12.831 8.988 12.669 9.037 12.518C9.086 12.368 9.181 12.236 9.309 12.143C9.437 12.05 9.592 12 9.75 12L11.25 12L11.25 10.5C11.25 10.342 11.3 10.187 11.393 10.059C11.486 9.931 11.618 9.836 11.768 9.787C11.919 9.738 12.081 9.738 12.232 9.787C12.382 9.836 12.514 9.931 12.607 10.059C12.7 10.187 12.75 10.342 12.75 10.5L12.75 12L14.25 12C14.408 12 14.563 12.05 14.691 12.143C14.819 12.236 14.914 12.368 14.963 12.518C15.012 12.669 15.012 12.831 14.963 12.982C14.914 13.132 14.819 13.264 14.691 13.357C14.563 13.45 14.408 13.5 14.25 13.5M15 5.25L9 5.25L9 4.5C9 4.368 9.035 4.239 9.1 4.125C9.166 4.011 9.261 3.916 9.375 3.85C9.489 3.785 9.618 3.75 9.75 3.75L14.25 3.75C14.382 3.75 14.511 3.785 14.625 3.85C14.739 3.916 14.834 4.011 14.9 4.125C14.965 4.239 15 4.368 15 4.5Z',
      true,
      false
    )
  ],
};

class _SolarIcon extends StatelessWidget {
  const _SolarIcon(this.name,
      {super.key,
      this.size = 24.0,
      this.stroke = 0.5,
      this.color = _blue,
      this.grow = 0.0,
      this.paths});
  final String name;
  final double size;

  /// ความหนาเส้นเป็นพิกเซลบนจอ (ไม่ขยายตามขนาดไอคอน)
  final double stroke;
  final Color color;

  /// ขยายเส้นของ path ทึบ (px บนจอ) ให้ไอคอนแบบเส้นที่วาดเป็นพื้นดูหนาขึ้น
  final double grow;

  /// path ที่ส่งมาตรง ๆ (เช่นไอคอนรางซ้าย) แทนการหาจากชื่อ
  final List<(String, bool, bool)>? paths;

  @override
  Widget build(BuildContext context) => Center(
      widthFactor: 1.0,
      heightFactor: 1.0,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
            painter: _SolarPainter(
                paths ?? _solarIcons[name] ?? const [], color, stroke, grow)),
      ));
}

class _SolarPainter extends CustomPainter {
  _SolarPainter(this.paths, this.color, this.stroke, [this.grow = 0.0]);
  final double grow;
  final List<(String, bool, bool)> paths;
  final Color color;
  final double stroke;

  /// path SVG แบบพิกัดสัมบูรณ์ (M L H V C Z) เป็น Path
  static Path _parse(String d) {
    final p = Path();
    final tok = RegExp(r'[MLHVCZ]|-?(?:\d+\.?\d*|\.\d+)')
        .allMatches(d)
        .map((m) => m.group(0)!)
        .toList();
    var i = 0, cmd = 'M';
    var x = 0.0, y = 0.0;
    double n() => double.parse(tok[i++]);
    while (i < tok.length) {
      if ('MLHVCZ'.contains(tok[i])) cmd = tok[i++];
      switch (cmd) {
        case 'M':
          p.moveTo(x = n(), y = n());
          cmd = 'L';
        case 'L':
          p.lineTo(x = n(), y = n());
        case 'H':
          p.lineTo(x = n(), y);
        case 'V':
          p.lineTo(x, y = n());
        case 'C':
          final a = n(), b = n(), c = n(), e = n();
          p.cubicTo(a, b, c, e, x = n(), y = n());
        case 'Z':
          p.close();
      }
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24.0;
    canvas.scale(k);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke / k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    // path ขึ้นต้น '!' = เจาะทะลุ (ลบพื้น) · '~' = เส้นเจาะบาง ๆ ตามขอบ (แบ่งส่วนในไอคอนทึบ)
    final knock =
        paths.any((p) => p.$1.startsWith('!') || p.$1.startsWith('~'));
    if (knock) canvas.saveLayer(const Rect.fromLTWH(-2, -2, 28, 28), Paint());
    for (final (d, solid, evenOdd) in paths) {
      if (d.startsWith('!')) {
        canvas.drawPath(
            _parse(d.substring(1)), Paint()..blendMode = BlendMode.clear);
        continue;
      }
      if (d.startsWith('~')) {
        canvas.drawPath(
            _parse(d.substring(1)),
            Paint()
              ..blendMode = BlendMode.clear
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0);
        continue;
      }
      if (solid) {
        final path = _parse(d)
          ..fillType = evenOdd ? PathFillType.evenOdd : PathFillType.nonZero;
        canvas.drawPath(path, fill);
        // ขยายขอบพื้นออกครึ่งหนึ่งของ grow ทุกด้าน = เส้นไอคอนหนาขึ้นเท่า grow
        if (grow > 0) {
          canvas.drawPath(
              path,
              Paint()
                ..color = color
                ..style = PaintingStyle.stroke
                ..strokeWidth = grow / k
                ..strokeJoin = StrokeJoin.round);
        }
      } else {
        canvas.drawPath(_parse(d), paint);
      }
    }
    if (knock) canvas.restore();
  }

  @override
  bool shouldRepaint(_SolarPainter old) =>
      old.color != color ||
      old.paths != paths ||
      old.stroke != stroke ||
      old.grow != grow;
}

/// ภาพประกอบการ์ด Doctor Note (Figma 477:101) แปลงจาก SVG 512×512 · (path, สี, evenOdd)
/// ต้นฉบับ: assets/images/er_dx_note.svg · วาดด้วย _VecArt (ไม่ต้องพึ่งแพ็กเกจ svg)
const List<(String, int, bool)> _noteArtPaths = [
  (
    'M146.59 74.27C157.82 72.57 158.67 80 163.1 88C163.71 89.09 164.36 90.45 164.77 91.62C167.47 93.08 171.6 95.46 174.53 96.13C176.97 96.35 179.71 96.53 182.1 96.91C181.57 89.87 189.61 87.21 194.46 91.38C196.44 93.09 196.32 96.55 197.47 98.66C197.18 99.73 200.81 113.5 201.4 115.75C201.86 115.49 201.67 115.57 202.26 115.57C206.41 119.52 215.13 126.62 217.8 131.61C221.54 138.58 223.97 149.07 226.5 156.92C228.5 163.15 232.12 172.83 232.65 179.09C233.12 184.52 230.77 193.84 225.62 196.88C229.2 202.55 231.22 207.54 227.04 213.65C221.38 217.32 219.34 217.49 213.22 214.03C211.88 213.01 210.5 212.03 209.11 211.07C208.54 211.52 207.61 212.29 207.03 212.66C201.52 216.97 198.21 216.37 191.88 215.75C189.9 216.64 189.25 216.82 187.03 217.26C182.52 218.28 176.28 217.6 171.81 216.67C166.61 215.59 161.62 212.94 156.95 210.51C156.73 210.44 154.56 208.97 154.18 208.75C150.57 206.63 144.35 201.75 140.77 200.23C139.02 198.7 137.13 197.68 135.16 196.46C131.8 194.38 126.75 191.15 124.08 188.22C113.07 176.12 110.06 157.61 108.87 141.84C108.59 138.04 108.21 133.77 108.32 130.07C100.84 123.14 97.73 119.23 101.73 109.03C103.89 106.13 106.08 102.23 108.52 99.04C119.45 84.73 129.33 78.12 146.59 74.27Z',
    0xFF1F8CFE,
    false
  ),
  (
    'M182.1 96.91C181.57 89.87 189.61 87.21 194.46 91.38C196.44 93.09 196.32 96.55 197.47 98.66C197.18 99.73 200.81 113.5 201.4 115.75L211.14 154.1C214.19 165.88 217.51 178.17 220.25 189.97C215.59 184.84 211.05 179.62 206.62 174.3C203.46 170.51 199.78 166.8 198.49 161.96C195.93 151.48 192.94 138.84 189.91 128.56C189.22 125.42 183.82 103.88 182.73 102.24C183.13 100.54 182.62 98.56 182.1 96.91Z',
    0xFF1B1B22,
    false
  ),
  (
    'M207.03 212.66C205.08 211.47 204.54 211.46 202.41 209.9C187.92 199.28 176.14 185.66 165.29 171.44C164 169.75 158.99 164.82 160.87 162.97C162.9 162.97 167.15 169.16 168.78 171.02C175.67 178.87 182.62 187.43 190.16 194.63C196.09 200.31 202.85 205.78 209.11 211.07C208.54 211.52 207.61 212.29 207.03 212.66Z',
    0xFF2460FC,
    false
  ),
  (
    'M187.03 217.26C184.63 215.51 178.14 213.05 174.51 210.65C172.68 209.41 170.91 208.06 169.23 206.62C165.54 203.41 145.84 184.44 144.17 181.32C144.23 180.51 144.1 180.89 144.66 180.19L145.33 180.11C147.6 180.97 151.86 186.53 153.9 188.52C162.48 196.89 170.77 205.94 181.75 211.19C184.65 212.58 189.61 213.81 191.88 215.75C189.9 216.64 189.25 216.82 187.03 217.26Z',
    0xFF2460FC,
    false
  ),
  (
    'M189.91 128.56C192.94 138.84 195.93 151.48 198.49 161.96C192.76 159.64 183.22 133.41 189.91 128.56Z',
    0xFF2460FC,
    false
  ),
  (
    'M174.53 96.13C176.97 96.35 179.71 96.53 182.1 96.91C182.62 98.56 183.13 100.54 182.73 102.24C179.92 100.37 177.04 98.39 174.53 96.13Z',
    0xFF292A38,
    false
  ),
  (
    'M404.65 0L510.49 0C510.53 1.17 510.32 2 509.89 3.08C506.76 10.86 503.64 18.66 500.54 26.45L480.22 77.54C474.01 93.43 467.71 109.29 461.32 125.11C459.52 129.53 457.86 133.98 456.12 138.42C455.55 139.89 453.91 141.76 452.65 142.68C447.5 145.03 431.02 133.9 427.39 130.36C425.96 133.08 422.94 139.38 421.24 141.59C407.74 124.76 396.08 116.86 373.95 116.25C374.2 113.29 376.27 106.61 377.16 103.64L382.2 86.8C380.28 85.6 377.83 83.35 376.11 81.79C375.8 81.02 375.62 80.33 375.93 79.51C377.31 75.81 378.64 72.07 379.98 68.34L390.8 38.54L399.54 14C401.04 9.78 402.87 3.99 404.65 0Z',
    0xFFE9ECF3,
    false
  ),
  (
    'M383.75 82.61C400.59 88.25 415.33 96.88 428.06 109.37C429.44 110.72 433.63 115.09 434.59 116.56C432.34 120.09 429.38 126.44 427.39 130.36C425.96 133.08 422.94 139.38 421.24 141.59C407.74 124.76 396.08 116.86 373.95 116.25C374.2 113.29 376.27 106.61 377.16 103.64L382.2 86.8C382.66 85.81 383.36 83.7 383.75 82.61Z',
    0xFFD48957,
    false
  ),
  (
    'M434.59 116.56C436.63 119.11 438.55 121.92 440.41 124.61C444.38 130.36 448.23 136.22 451.74 142.26C451.88 142.51 452.43 142.62 452.65 142.68C447.5 145.03 431.02 133.9 427.39 130.36C429.38 126.44 432.34 120.09 434.59 116.56Z',
    0xFFCED1E3,
    false
  ),
  (
    'M376.11 81.79C379.32 81.45 380.71 81.77 383.75 82.61C383.36 83.7 382.66 85.81 382.2 86.8C380.28 85.6 377.83 83.35 376.11 81.79Z',
    0xFFCED1E3,
    false
  ),
  (
    'M449.35 113.96C452.56 113.23 455.75 115.26 456.45 118.48C457.15 121.7 455.09 124.87 451.87 125.55C448.68 126.21 445.55 124.18 444.86 121C444.17 117.82 446.17 114.67 449.35 113.96Z',
    0xFF292A38,
    false
  ),
  (
    'M454.81 100.16C457.93 99.38 461.1 101.29 461.88 104.42C462.66 107.55 460.75 110.71 457.62 111.49C454.49 112.27 451.32 110.36 450.55 107.23C449.77 104.1 451.68 100.94 454.81 100.16Z',
    0xFF292A38,
    false
  ),
  (
    'M5.04 0L105.4 0C106.04 0.69 106.95 1.64 107.42 2.44C112.91 11.69 118.34 21 123.69 30.33C125.58 33.62 127.93 35.73 125.17 38.98C125.02 41.48 144.91 68.8 146.59 74.27C129.33 78.12 119.45 84.73 108.52 99.04C106.08 102.23 103.89 106.13 101.73 109.03C99.19 107.11 90.22 95.39 87.22 91.87C83.02 95.96 69.42 108.02 63.48 106.26C63.03 106.07 62.61 105.82 62.23 105.52C60.39 104.12 53.3 89.83 51.73 86.92L32.26 51.08L20.44 29.4C17.73 24.5 5.66 3.81 5.04 0Z',
    0xFFE9ECF3,
    false
  ),
  (
    'M78.25 80.49C79.72 77.92 81.42 75.7 83.19 73.32C92.57 60.6 104.34 49.82 117.84 41.59C119.51 40.59 121.75 38.9 123.66 38.36C124.43 38.14 124.64 38.53 125.17 38.98C125.02 41.48 144.91 68.8 146.59 74.27C129.33 78.12 119.45 84.73 108.52 99.04C106.08 102.23 103.89 106.13 101.73 109.03C99.19 107.11 90.22 95.39 87.22 91.87C84.51 88.31 81.21 83.8 78.25 80.49Z',
    0xFFD48957,
    false
  ),
  (
    'M78.25 80.49C81.21 83.8 84.51 88.31 87.22 91.87C83.02 95.96 69.42 108.02 63.48 106.26C63.81 105.93 66.49 100.46 66.97 99.52C70.42 92.83 73.9 86.64 78.25 80.49Z',
    0xFFCED1E3,
    false
  ),
  (
    'M63.8 76.7C66.95 76.44 69.73 78.77 70.02 81.92C70.31 85.07 68.02 87.87 64.87 88.21C62.8 88.42 60.77 87.51 59.56 85.82C58.36 84.13 58.15 81.91 59.02 80.03C59.9 78.14 61.72 76.87 63.8 76.7Z',
    0xFF292A38,
    false
  ),
  (
    'M56.93 63.09C60.05 62.56 63.01 64.66 63.54 67.78C64.08 70.9 61.99 73.86 58.87 74.4C55.74 74.94 52.77 72.84 52.24 69.72C51.7 66.59 53.8 63.63 56.93 63.09Z',
    0xFF292A38,
    false
  ),
  (
    'M373.95 116.25C396.08 116.86 407.74 124.76 421.24 141.59C423.26 145.32 424.68 148.37 423.35 152.82C422.41 155.95 418.17 161.99 415.97 164.22C415.81 172.4 415.76 180.59 415.8 188.77C415.79 194.32 415.71 202.93 414.76 208.4C414.03 212.46 412.77 216.4 411.03 220.13C409.02 224.4 402.17 234.53 399.31 238.95C393.95 247.24 386.96 257.13 380.01 264.09C378.42 265.68 373.96 269.56 371.87 270.36C371.05 263.72 370.61 254.6 370.12 247.82C369.54 244.36 369.43 233.08 368.55 231.17C365.28 238.94 362.43 243.79 353.66 245.45C349.79 245.16 346.62 244.04 344.42 240.59C339.59 233.03 343.42 224.02 345.59 216.3C347.26 210.38 349.79 204.11 351.01 198.12C353.06 191 356.43 183.68 357.96 176.37C358.33 174.62 357.64 169.88 357.51 167.89C357.3 164.7 357.27 161.5 357.44 158.3C357.94 149.8 360.38 145.45 362.99 137.73C363.74 135.5 362.61 128.88 363.46 125.58C365.37 119.26 366.73 116.16 373.95 116.25Z',
    0xFF1F8CFE,
    false
  ),
  (
    'M368.55 231.17C370.32 226.14 372.45 219.7 374.49 214.89C377.42 226.39 377.55 235.67 371.7 246.4C371.24 247.26 370.96 247.39 370.12 247.82C369.54 244.36 369.43 233.08 368.55 231.17Z',
    0xFF2460FC,
    false
  ),
  (
    'M140.77 200.23C144.35 201.75 150.57 206.63 154.18 208.75C154.56 208.97 156.73 210.44 156.95 210.51C156.22 212.43 154.91 237.25 154.62 241.15L147.68 336.42L145.57 366.07C145.24 370.8 144.93 378.05 144.24 382.51C150.93 382.66 159.4 383.45 166.26 383.88L203.06 386.2C202.28 391.6 200.65 400.21 200.19 405.3C196.72 405.19 191.7 404.58 188.05 404.29L161.16 402.16L145.16 400.98C142.13 400.77 136.12 400.49 133.45 399.76C130.6 398.95 128.17 397.07 126.68 394.5C125.26 392.02 125.03 389.66 125.18 386.89C125.46 381.39 126.1 375.88 126.64 370.39L128.79 347.22C131.07 321.57 133.2 295.92 135.19 270.25L138.97 221.71L139.93 208.22C140.09 205.98 140.21 202.28 140.77 200.23Z',
    0xFF292A38,
    false
  ),
  (
    'M368.55 231.17C369.43 233.08 369.54 244.36 370.12 247.82C370.61 254.6 371.05 263.72 371.87 270.36C374.5 303.24 376.92 336.14 379.12 369.05L380.87 394.35C381.19 399.01 381.66 403.71 381.62 408.38C381.57 414.14 376.61 418.38 371.01 418.45C365.61 418.49 360 417.85 354.58 417.39L316.01 414.25C312.79 414 301.43 412.88 298.55 413.03C298.23 407.4 297.76 400.49 297.8 394.94C301.81 395.07 306.39 395.56 310.45 395.88L332.88 397.65L350.65 399.07C354.13 399.35 358.46 399.59 361.84 400.07C361.36 397.56 361.24 390.97 361.1 388.13L359.89 365.17L355.48 282.91L354.27 259.64C354.09 255.51 354.04 249.41 353.66 245.45C362.43 243.79 365.28 238.94 368.55 231.17Z',
    0xFF292A38,
    false
  ),
  (
    'M197.47 98.66C209.49 99.78 221.5 101.01 233.49 102.36L297.57 109.2L335.45 113.21C340.33 113.74 345.41 114.28 350.26 114.83C358.57 115.77 361.04 117.77 363.46 125.58C362.61 128.88 363.74 135.5 362.99 137.73C360.38 145.45 357.94 149.8 357.44 158.3C357.27 161.5 357.3 164.7 357.51 167.89C357.64 169.88 358.33 174.62 357.96 176.37C356.43 183.68 353.06 191 351.01 198.12C351.32 194.68 350.55 186.05 350.36 181.97L348.98 154.73C348.59 148 347.95 139.72 348 133.05C340.19 132.01 332.12 131.18 324.28 130.24L266.84 123.37C245.39 120.83 223.7 117.91 202.26 115.57C201.67 115.57 201.86 115.49 201.4 115.75C200.81 113.5 197.18 99.73 197.47 98.66Z',
    0xFF292A38,
    false
  ),
  (
    'M203.06 386.2C203.73 382.74 204.19 380.3 208.35 380.52C214.42 380.83 220.45 381.47 226.5 381.95L264.88 384.95C274.48 385.69 284.18 386.26 293.76 387.28C294.41 387.35 296.07 388.36 296.7 388.73C297.73 391.11 297.67 392.37 297.8 394.94C297.76 400.49 298.23 407.4 298.55 413.03C298.44 413.54 298.15 414.99 297.83 415.36C295.51 417.97 290.25 416.88 287.11 416.65C282.5 416.35 277.88 415.99 273.28 415.56C267.39 415.05 267.26 414.69 265.1 420.68C259.87 435.13 238.46 435.21 233.06 420.75C231.96 417.83 231.63 415.68 231.12 412.59C225.63 410.8 204.21 411.49 201.45 409.11C200.42 408.23 200.26 406.55 200.19 405.3C200.65 400.21 202.28 391.6 203.06 386.2Z',
    0xFFABB2C1,
    false
  ),
  (
    'M246.75 407.98C249.27 407.19 252.02 407.82 253.95 409.63C255.87 411.44 256.67 414.15 256.04 416.72C255.4 419.29 253.43 421.31 250.88 422.02C247.03 423.08 243.03 420.86 241.91 417.03C240.78 413.19 242.93 409.17 246.75 407.98Z',
    0xFFCED1E3,
    false
  ),
  (
    'M227.04 213.65C227.73 216.19 228.46 218.74 228.74 221.37C229.01 223.9 228.6 239.38 227.73 240.81C227.5 241.18 227.33 241.17 226.95 241.33C225.85 241.1 225.76 241 225.16 239.87C222.17 234.28 217.76 228.86 214.95 223.27C214.13 221.65 214.06 216.36 213.22 214.03C219.34 217.49 221.38 217.32 227.04 213.65Z',
    0xFF1B1B22,
    false
  ),
];

/// ภาพประกอบ Doctor Note แบบเคลื่อนไหว (idle วน 10 วิ):
/// มือถือปากกาเขียนทีละบรรทัดบนคลิปบอร์ด 3 บรรทัด · หยุดอ่าน · ลบหมึกแล้วเริ่มใหม่
/// มือที่ถือคลิปบอร์ดขยับเบา ๆ ตามจังหวะหายใจ
class _NoteArt extends StatefulWidget {
  const _NoteArt();

  @override
  State<_NoteArt> createState() => _NoteArtState();
}

class _NoteArtState extends State<_NoteArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 16))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => CustomPaint(
                  painter: _NoteArtPainter(_c.value), size: Size.infinite),
            ),
          ),
        ),
      );
}

class _NoteArtPainter extends CustomPainter {
  _NoteArtPainter(this.t);
  final double t;

  static List<Path>? _cache;
  static List<Path> get _paths => _cache ??= [
        for (final (d, _, eo) in _noteArtPaths)
          _SolarPainter._parse(d)
            ..fillType = eo ? PathFillType.evenOdd : PathFillType.nonZero
      ];

  /// ชิ้นของแขนที่ถือปากกา (แขนเสื้อ ข้อมือ ถุงมือ ปากกา)
  static const _writer = {0, 1, 2, 3, 4, 5, 12, 13, 14, 15, 16, 24};

  /// ท่อนกรอบคลิปบอร์ดต้นฉบับ (แทนด้วยกรอบเต็มวง)
  static const _frame = {19, 20, 21};

  /// ชิ้นของมือที่ถือคลิปบอร์ด
  static const _holder = {6, 7, 8, 9, 10, 11, 17, 18};

  // ปลายปากกาในภาพ · บรรทัดหมึก (เริ่ม x, จบ x, y) เอียงตามคลิปบอร์ด
  static const _tip = Offset(221.0, 240.0);
  // คลิปบอร์ดหันหัว (ที่หนีบ) ออกจากแพทย์ = กระดาษกลับหัวในภาพ
  // แพทย์จึงเขียนจากฝั่งที่หนีบ (ล่างในภาพ) ขึ้นมา และจากขวาไปซ้ายในภาพ
  static const _lines = [
    (190.0, 318.0, 352.0),
    (196.0, 320.0, 324.0),
    (232.0, 322.0, 296.0),
  ];
  static const _slope = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 512.0);
    // มิติ: เงาคลิปบอร์ดนุ่ม ๆ + แผ่นกระดาษไล่สี (ใต้หมึก)
    final board = Path()
      ..moveTo(171.0, 106.0)
      ..lineTo(353.0, 125.0)
      ..lineTo(372.0, 406.0)
      ..lineTo(137.0, 388.0)
      ..close();
    canvas.drawPath(
        board.shift(const Offset(6.0, 14.0)),
        Paint()
          ..color = const Color(0x2A0B1B3F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14.0));
    canvas.drawPath(
        board,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFE8EDF6)],
          ).createShader(const Rect.fromLTRB(137.0, 106.0, 372.0, 406.0)));
    // จังหวะ (idle นุ่ม ๆ): เขียน 3 บรรทัดจากฝั่งที่หนีบขึ้นมา (0–0.66) · ค้าง (0.66–0.82)
    // หมึกจางหายโดยปากกาอยู่ที่เดิม (0.82–0.9) · แล้วค่อยเลื่อนกลับบรรทัดแรก (0.9–1)
    const per = 0.22, writeEnd = 0.66, fadeAt = 0.82, backAt = 0.9;
    double lineY(int k, double x) {
      final (x0, _, y) = _lines[k];
      return y + (x - x0) * _slope + math.sin(x * 0.22) * 0.6;
    }

    final fade = t < fadeAt
        ? 1.0
        : (1.0 -
            Curves.easeOut
                .transform(((t - fadeAt) / (backAt - fadeAt)).clamp(0.0, 1.0)));
    final ink = Paint()
      ..color = const Color(0xFF233A8B).withValues(alpha: 0.9 * fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final first = Offset(_lines.first.$2, lineY(0, _lines.first.$2));
    var pen = first;
    for (var k = 0; k < _lines.length; k++) {
      final (x0, x1, _) = _lines[k];
      final start = k * per;
      if (t < start || fade <= 0) break;
      // 80% ของช่วง = เขียน (เร่ง-ผ่อนนุ่ม) · 20% = ยกปากกาไปต้นบรรทัดถัดไป
      final w = Curves.easeInOut
          .transform(((t - start) / (per * 0.8)).clamp(0.0, 1.0));
      // เขียนจากขวาไปซ้ายในภาพ (ซ้ายไปขวาของแพทย์)
      final xe = x1 - (x1 - x0) * w;
      final path = Path()..moveTo(x1, lineY(k, x1));
      for (var x = x1 - 2.0; x >= xe; x -= 2.0) {
        path.lineTo(x, lineY(k, x));
      }
      canvas.drawPath(path, ink);
      if (t < start + per && t < writeEnd) {
        final lift = (((t - start) / per - 0.8) / 0.2).clamp(0.0, 1.0);
        final here = Offset(xe, lineY(k, xe));
        if (lift > 0 && k + 1 < _lines.length) {
          final nx = _lines[k + 1].$2;
          final next = Offset(nx, lineY(k + 1, nx));
          final e = Curves.easeInOut.transform(lift);
          pen = Offset.lerp(here, next, e)! -
              Offset(0.0, math.sin(lift * math.pi) * 2.0);
        } else {
          pen = here;
        }
      }
    }
    if (t >= writeEnd) {
      final (x0, _, _) = _lines.last;
      final end = Offset(x0, lineY(_lines.length - 1, x0));
      final back = t < backAt
          ? 0.0
          : Curves.easeInOutSine.transform((t - backAt) / (1.0 - backAt));
      pen = Offset.lerp(end, first, back)! -
          Offset(0.0, math.sin(back * math.pi) * 3.0);
    }
    // แขนที่เขียน: หมุนรอบหัวไหล่ (นอกภาพมุมซ้ายบน) + ยื่น/หดตามแนวแขน
    // ให้ปลายปากกาไปถึง pen โดยแขนเสื้อยังโผล่จากขอบภาพเสมอ (ไม่ลอยหลุด)
    const pivot = Offset(-200.0, -250.0);
    final v0 = _tip - pivot, v = pen - pivot;
    final turn = v.direction - v0.direction;
    final slide = v.distance - v0.distance;
    final axis = v0 / v0.distance;
    // มือถือคลิปบอร์ด: ลอยขึ้นลง 0.8px ช้า ๆ
    final breathe = math.sin(t * math.pi * 2) * 0.8;
    final paths = _paths;
    Paint fill(int i) => Paint()..color = Color(_noteArtPaths[i].$2);
    // ลำดับวาด: คลิปบอร์ด → มือที่ถือ → แขนที่เขียน (แขนอยู่เหนือคลิปบอร์ดเสมอ)
    final order = [
      for (var i = 0; i < paths.length; i++)
        if (!_writer.contains(i) && !_holder.contains(i)) i,
      for (var i = 0; i < paths.length; i++)
        if (_holder.contains(i)) i,
      for (var i = 0; i < paths.length; i++)
        if (_writer.contains(i)) i,
    ];
    // กรอบคลิปบอร์ดในต้นฉบับถูกตัดเป็นท่อนรอบมือ (19–21) พอมือขยับจะเห็นรอยขาด
    // จึงวาดกรอบเต็มวงแทน (เส้นกลางกรอบตามมุมทั้งสี่ของต้นฉบับ)
    canvas.drawPath(
        Path()
          ..moveTo(171.0, 106.0)
          ..lineTo(353.0, 125.0)
          ..lineTo(372.0, 406.0)
          ..lineTo(137.0, 388.0)
          ..close(),
        Paint()
          // กรอบไล่สี: ขอบบนสว่างกว่า (แสงจากบน) ให้ดูมีความหนา
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A4D63), Color(0xFF1E1F2A)],
          ).createShader(const Rect.fromLTRB(137.0, 106.0, 372.0, 406.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 17.0
          ..strokeJoin = StrokeJoin.round);
    for (final i in order) {
      if (_frame.contains(i)) continue;
      canvas.save();
      if (_writer.contains(i)) {
        canvas.translate(pivot.dx, pivot.dy);
        canvas.rotate(turn);
        canvas.translate(-pivot.dx, -pivot.dy);
        canvas.translate(axis.dx * slide, axis.dy * slide);
        // แขนเสื้อ: ยืดย้อนแนวแขน (กวาดทีละ 2px = ขอบเรียบ ไม่เป็นขั้น)
        // กันช่องว่างตอนแขนยื่นออก
        if (i == 12) {
          final ext = Path();
          for (var d = 2.0; d <= 220.0; d += 2.0) {
            ext.addPath(paths[i], -axis * d);
          }
          canvas.drawPath(ext, fill(i));
        }
      } else if (_holder.contains(i)) {
        canvas.translate(0.0, breathe);
      }
      // เงามือตกบนกระดาษ (ก่อนวาดถุงมือ)
      if (i == 0 || i == 17) {
        canvas.drawPath(
            paths[i].shift(const Offset(8.0, 12.0)),
            Paint()
              ..color = const Color(0x330B1B3F)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.0));
      }
      canvas.drawPath(paths[i], fill(i));
      // แสงเงาบนถุงมือ/แขนเสื้อ: ไฮไลต์ขาวมุมบนซ้าย → เงาเข้มมุมล่างขวา
      if (const {0, 17, 6, 12}.contains(i)) {
        final b = paths[i].getBounds();
        canvas.drawPath(
            paths[i],
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0x40FFFFFF),
                  Color(0x00FFFFFF),
                  Color(0x26000A3A),
                ],
                stops: const [0.0, 0.45, 1.0],
              ).createShader(b));
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_NoteArtPainter old) => old.t != t;
}

/// แถวที่ลำดับเปลี่ยน (key เดิม ย้ายตำแหน่ง): เลื่อนจากตำแหน่งเดิมไปตำแหน่งใหม่แบบ FLIP
class _SwapSlide extends StatefulWidget {
  const _SwapSlide({super.key, required this.child});
  final Widget child;

  @override
  State<_SwapSlide> createState() => _SwapSlideState();
}

class _SwapSlideState extends State<_SwapSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));
  Offset? _last;
  Offset _from = Offset.zero;

  // ตำแหน่งในรายการ (เทียบกับ parent · เลื่อนหน้า/คีย์บอร์ดขึ้นไม่นับ) · ต่างจากเดิม = เลื่อนจากที่เดิม
  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || box.parent == null) return;
    final now = box.localToGlobal(Offset.zero, ancestor: box.parent);
    final last = _last;
    _last = now;
    if (last == null) return;
    final d = Offset(0.0, last.dy - now.dy);
    if (d.dy.abs() < 1.0) return;
    // ระหว่างเลื่อนอยู่ = ต่อจากตำแหน่งที่เห็นตอนนี้
    final cur = _from * (1.0 - Curves.easeInOutCubic.transform(_c.value));
    setState(() => _from = d + (_c.isAnimating ? cur : Offset.zero));
    _c.forward(from: 0.0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, c) {
        final k = _c.isAnimating || _c.value < 1.0
            ? 1.0 - Curves.easeInOutCubic.transform(_c.value)
            : 0.0;
        return Transform.translate(offset: _from * k, child: c);
      },
    );
  }
}

/// เหรียญพลิกเมื่อค่าเปลี่ยน: หมุนมุม tilt ของเหรียญเอง (ชั้นความหนาหมุนตาม ไม่แบน)
/// เหรียญเดิมหมุนจนตั้งสันขอบ → สลับเป็นค่าใหม่ → หมุนต่อทางเดิมจนกลับมุมปกติ
class _CoinFlip extends StatefulWidget {
  const _CoinFlip({required this.value, required this.builder});
  final String value;
  final Widget Function(String value, double tilt) builder;

  @override
  State<_CoinFlip> createState() => _CoinFlipState();
}

class _CoinFlipState extends State<_CoinFlip>
    with SingleTickerProviderStateMixin {
  static const double _rest = 0.55;
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 560), value: 1.0);
  late String _old = widget.value;

  @override
  void didUpdateWidget(_CoinFlip w) {
    super.didUpdateWidget(w);
    if (w.value != widget.value) {
      _old = w.value;
      _c.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final v = _c.value;
          if (v >= 1.0) return widget.builder(widget.value, _rest);
          // ครึ่งแรก: เร่งออก · ครึ่งหลัง: ชะลอเข้า (ต่อเนื่องเป็นการหมุนเดียว)
          final a = Curves.easeInOutSine.transform(v) * math.pi;
          final tilt = _rest + a;
          // เลยสันขอบ (90°) = ด้านใหม่หันมา · มุมวนกลับให้อยู่ช่วง −90..90
          final front = tilt < math.pi / 2;
          final scale = 1.0 + 0.08 * math.sin(v * math.pi);
          return Transform.scale(
            scale: scale,
            child: widget.builder(
                front ? _old : widget.value, front ? tilt : tilt - math.pi),
          );
        },
      );
}
