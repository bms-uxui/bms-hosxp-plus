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
    'Head injury · สังเกตอาการ',
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
    'Fracture · รอ Ortho',
    'Closed fracture, neurovascular intact distal to injury.\n'
        'Splint applied, pain control, film done.\nConsult orthopedics.'
  ),
  (
    'D002',
    'Chest pain · rule out ACS',
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
  ('1', 'Principal Diagnosis', ''),
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
    const {'mmHg', '/min', '%', '°C'}.contains(hint) ? hint : '';

/// คำอธิบายใต้ชื่อช่องที่เป็นคำย่อ/ศัพท์เฉพาะ กันผู้ใช้ลืมความหมาย
const Map<String, String> _terms = {
  'HPI': 'ประวัติเจ็บป่วยปัจจุบัน',
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

extension _FeaturesWorkflowFormFieldsPart on _ErFlowHomeWidgetState {
  /// ขั้นของโหมดพูดตามบทบาทที่ login (แพทย์ / พยาบาล)
  /// แต่ละบทบาทกรอกเฉพาะฟอร์ม HOSxP ของตัวเอง (role ใน er_form_kb.json)
  List<(IconData, String)> get _steps => switch (ErSession.instance.role) {
        ErRole.doctor => _doctorSteps,
        ErRole.nurse => _nurseSteps,
        ErRole.triage => _triageSteps,
      };
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
          if (!_isPeStep(st) ||
              _peScope == null ||
              !_peHasDetail(l) ||
              _peScope!.contains(l))
            if (!_dxMerged(st, l)) l
      ];

  /// ช่องไม่บังคับ: เว้นว่างได้ ไม่นับเป็นช่องที่ขาด (ไม่ขวางการไปหน้าสรุป)
  static const Set<String> _optionalFields = {'บันทึกการตรวจแบบละเอียด'};

  /// ช่องนี้ครบหรือยัง: ผลตรวจ "ผิดปกติ" ต้องมีรายละเอียดเสมอ
  bool _fieldDone(int st, String l) {
    final v = _filled[st][l];
    if (v == null || v.trim().isEmpty) return _optionalFields.contains(l);
    // template ที่ยังมีช่องว่าง [ ] = ยังเล่าไม่ครบ ไม่นับว่ากรอกแล้ว
    if (RegExp(r'\[[^\]]*\]').hasMatch(v)) return false;
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
        return _hpiShell(field);
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
    final key = '$label - รายละเอียด';
    final v = _filled[_speechStep][key];
    final must = _needsDetail(_speechStep, label);
    // พิมพ์ในช่องได้เลย · แตะขอบกล่องก็โฟกัสช่อง
    return InkWell(
      onTap: () => _inlineFocusOf(key).requestFocus(),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: must
                  ? _red
                  : (v != null ? _blue.withValues(alpha: 0.5) : _line),
              width: must ? 1.5 : 1.0),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(must ? Icons.error_rounded : Icons.notes_rounded,
              size: 15.0, color: must ? _red : _ink3),
          const SizedBox(width: 6.0),
          Expanded(
            child: _inlineInput(key, v,
                hint: must
                    ? 'ผิดปกติ · ต้องระบุรายละเอียด'
                    : 'รายละเอียด (พิมพ์หรือพูดได้ยาว ๆ)',
                style: _t(11.5, color: _inkTitle, height: 1.4),
                hintStyle: _t(11.5, color: must ? _red : _ink3, height: 1.4),
                maxLines: 6),
          ),
        ]),
      ),
    );
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
          if (esi != null) row('ระดับ ESI', '${esi.level} ${esi.label}'),
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

  /// มีช่องพิมพ์ที่กำลังโฟกัสอยู่ (ผู้ใช้กำลังพิมพ์)
  bool get _inlineTyping => _inlineFocus.values.any((f) => f.hasFocus);

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
      int maxLines = 3,
      bool numeric = false}) {
    final step = _speechStep;
    final key = '$step|$label';
    final focus = _inlineFocusOf(label);
    final ctl = _inlineCtl.putIfAbsent(
        key, () => TextEditingController(text: value ?? ''));
    if (!focus.hasFocus && ctl.text != (value ?? '')) ctl.text = value ?? '';
    return TextField(
      controller: ctl,
      focusNode: focus,
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
      // หัวข้อส่วน: ชื่อ · ปุ่มเล็ก · จำนวนรายการชิดขวา (ไม่มีคำอธิบายสีเทา)
      Widget head(String t, int n, {Widget? action}) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(children: [
              Text(t,
                  style: _t(big ? 12.5 : 10.5,
                      color: _inkTitle, weight: FontWeight.w700)),
              if (action != null) ...[const SizedBox(width: 8.0), action],
              const Spacer(),
              if (n > 0)
                Text('$n รายการ',
                    style: _t(big ? 10.0 : 9.0,
                        color: _blue, weight: FontWeight.w600)),
            ]),
          );
      final dx = _filled[_speechStep][_dxTextLabel];
      list = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        // ลำดับหัวข้อ: 1 Diagnosis Text · 2 ICD-10 · 3 ICD-9-CM · 4 Doctor Note
        children: [
          // Template ลง Diagnosis Text + ICD-10 พร้อมกัน · ปุ่มเล็กข้างหัวข้อ
          // Re-Diag มุมขวา: ดึงวินิจฉัยจาก visit ก่อนหน้ามาใช้
          Row(children: [
            Expanded(
              child: head('Diagnosis Text', _multiItems(dx).length,
                  action: _miniBtn(
                      Icons.bookmarks_rounded, 'Template', _pickDxTemplate,
                      tooltip: 'เลือกจาก Template (Diagnosis Text + ICD-10)')),
            ),
            const SizedBox(width: 8.0),
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: _reDiagBtn(),
            ),
          ]),
          _multiSection(_dxTextLabel, dx, big),
          Padding(
            padding: EdgeInsets.symmetric(vertical: big ? 12.0 : 8.0),
            child: const Divider(height: 1.0, color: _line),
          ),
          head('รหัส ICD-10', _multiItems(value, icd: true).length),
          _multiSection(_icd10Label, value, big),
          Padding(
            padding: EdgeInsets.symmetric(vertical: big ? 12.0 : 8.0),
            child: const Divider(height: 1.0, color: _line),
          ),
          // ICD-9-CM หัตถการ (ไม่บังคับ) · มีชิปรหัสที่ลงไว้ในขั้นหัตถการให้แตะเพิ่ม
          head('รหัส ICD-9-CM',
              _multiItems(_filled[_speechStep][_icd9DxLabel]).length),
          _multiSection(_icd9DxLabel, _filled[_speechStep][_icd9DxLabel], big),
          _icd9FromProcChips(big),
          Padding(
            padding: EdgeInsets.symmetric(vertical: big ? 12.0 : 8.0),
            child: const Divider(height: 1.0, color: _line),
          ),
          // Doctor Note: พิมพ์เอง · พูด (แปลงเสียง) · Template
          head('Doctor Note', 0,
              action: Row(mainAxisSize: MainAxisSize.min, children: [
                _miniBtn(
                    Icons.mic_rounded, 'พูด', () => _editNote(autoMic: true),
                    tooltip: 'พูดแล้วแปลงเป็นข้อความ'),
                const SizedBox(width: 6.0),
                _miniBtn(Icons.bookmarks_rounded, 'Template', _pickNoteTemplate,
                    tooltip: 'เลือกจาก Template Doctor Note'),
              ])),
          _noteSection(big),
        ],
      );
    } else {
      list = _multiSection(label, value, big, template: true);
    }
    return fill ? SingleChildScrollView(child: list) : list;
  }

  /// รายการของช่องหลายค่าหนึ่งช่อง + ปุ่มเพิ่ม (template = แสดงปุ่ม Template ต่อท้าย)
  Widget _multiSection(String label, String? value, bool big,
      {bool template = false}) {
    final icd = label == _icd10Label;
    final icd9 = label == _icd9DxLabel;
    final items = _multiItems(value, icd: icd);
    final codes =
        icd ? _icd10Codes() : (icd9 ? _icd9Codes() : const <String, String>{});
    final by = _byMap(label);
    // รายการที่ยังไม่มีผู้บันทึก (เช่น ผู้ช่วยเติมจากเสียง) = แพทย์ที่ login อยู่
    if (ErSession.instance.user != null && items.any((x) => by[x] == null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _stampBy(label, items));
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: big ? 6.0 : 4.0),
          InkWell(
            onTap: () =>
                icd ? _pickIcd10(i) : (icd9 ? _pickIcd9(i) : _editDxText(i)),
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              constraints: BoxConstraints(minHeight: big ? 44.0 : 32.0),
              padding: EdgeInsets.fromLTRB(big ? 12.0 : 8.0, 4.0, 4.0, 4.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: _blue.withValues(alpha: 0.5)),
              ),
              child: Row(children: [
                if (icd)
                  _diagTypePill(items, i, big)
                else
                  Text('${i + 1}.',
                      style: _num(big ? 12.0 : 9.5,
                          color: _ink3, weight: FontWeight.w700)),
                SizedBox(width: big ? 6.0 : 4.0),
                // รหัส + ชื่อโรค/ข้อความ · บรรทัดเล็กด้านล่าง = แพทย์ผู้วินิจฉัย
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (codes[items[i]] case final code?) ...[
                                Text(code,
                                    style: _num(big ? 12.5 : 9.5,
                                        color: _blue, weight: FontWeight.w700)),
                                SizedBox(width: big ? 8.0 : 5.0),
                              ],
                              Expanded(
                                child: Text(items[i],
                                    style: _t(big ? 13.0 : 10.0,
                                        color: _inkTitle,
                                        height: 1.35,
                                        weight: FontWeight.w600)),
                              ),
                            ]),
                        _byLine(by[items[i]], big),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _setMulti(label, items..removeAt(i)),
                  tooltip: 'ลบรายการนี้',
                  iconSize: big ? 18.0 : 14.0,
                  constraints:
                      const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                  icon: const Icon(Icons.delete_outline_rounded, color: _ink3),
                ),
              ]),
            ),
          ),
        ],
        if (items.isNotEmpty) SizedBox(height: big ? 8.0 : 5.0),
        Wrap(spacing: 8.0, runSpacing: 6.0, children: [
          // ปุ่มเล็ก "เพิ่ม" ทุกส่วน (หัวข้อบอกอยู่แล้วว่าเพิ่มอะไร)
          _miniBtn(
              Icons.add_rounded,
              'เพิ่ม',
              () => icd
                  ? _pickIcd10(null)
                  : (icd9 ? _pickIcd9(null) : _editDxText(null)),
              tooltip: icd
                  ? 'เพิ่มรหัส ICD-10'
                  : (icd9 ? 'เพิ่มรหัส ICD-9-CM' : 'เพิ่ม Diagnosis Text')),
          if (template && !icd)
            _multiAddBtn(Icons.bookmarks_rounded, 'เลือกจาก Template', big,
                _pickDxTemplate),
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

  /// ปุ่ม pill เล็กข้างหัวข้อ: ตัวปุ่มสูง 28 แต่พื้นที่แตะสูง 40 (กดง่ายตามกติกา)
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
                  height: 28.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: _blue.withValues(alpha: 0.5)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 13.0, color: _blue),
                    const SizedBox(width: 4.0),
                    Text(text,
                        style: _t(10.5, color: _blue, weight: FontWeight.w700)),
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
  }

  /// เลือกรหัส ICD-10 จาก master: แก้รายการที่ i หรือเพิ่มใหม่ (i = null)
  /// รหัสที่เลือกไว้แล้วไม่แสดงซ้ำ
  Future<void> _pickIcd10(int? i) async {
    final items = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    final codes = _icd10Codes();
    final shown = {
      for (final e in codes.entries)
        if (!items.contains(e.key) || (i != null && items[i] == e.key))
          '${e.value} · ${e.key}': e.key
    };
    final cur = i == null ? null : items[i];
    final picked = await _listSheet(_icd10Label, shown.keys.toList(),
        current: cur == null ? null : '${codes[cur]} · $cur');
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

  /// เลข Type หน้ารหัส (วงกลมเล็ก) · แตะเพื่อเปลี่ยนได้ทุกรหัส รวมทั้ง Type 1
  Widget _diagTypePill(List<String> items, int i, bool big) {
    final t = _diagTypeOf(items, i);
    final main = t == '1';
    final name = _diagTypes.firstWhere((d) => d.$1 == t).$2;
    final (bg, fg) = _diagTypeTone(t);
    final d = big ? 20.0 : 16.0;
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
          style: _num(big ? 10.0 : 8.5, color: fg, weight: FontWeight.w700)),
    );
    return Tooltip(
      message: 'Type $t · $name${main ? ' (รหัสแรก)' : ''} · แตะเพื่อเปลี่ยน',
      child: InkWell(
        onTap: () => _pickDiagType(i),
        customBorder: const CircleBorder(),
        // ตัวเลขเล็ก แต่พื้นที่แตะยัง 32×40 ให้กดง่าย
        child: SizedBox(
          width: 32.0,
          height: 40.0,
          child: Center(child: badge),
        ),
      ),
    );
  }

  // ------------------------------------------------ แพทย์ผู้วินิจฉัยของแต่ละรายการ

  /// ผู้บันทึกของแต่ละรายการ: บรรทัดละ "รายการ<TAB>ชื่อแพทย์" ในช่อง "<ช่อง> - by"
  Map<String, String> _byMap(String label) => {
        for (final l in (_filled[_speechStep]['$label - by'] ?? '').split('\n'))
          if (l.split('\t') case [final k, final v]) k: v
      };

  /// ลงชื่อแพทย์ที่ login อยู่ให้รายการที่ยังไม่มีผู้บันทึก (เรียกใน setState)
  void _stampBy(String label, Iterable<String> items) {
    final who = ErSession.instance.user?.name;
    if (who == null) return;
    final m = _byMap(label);
    var changed = false;
    for (final it in items) {
      if (m[it] == null) {
        m[it] = who;
        changed = true;
      }
    }
    if (changed) {
      _filled[_speechStep]['$label - by'] =
          [for (final e in m.entries) '${e.key}\t${e.value}'].join('\n');
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
            Icon(Icons.person_rounded, size: big ? 11.0 : 9.0, color: _ink3),
            const SizedBox(width: 3.0),
            Flexible(
              child: Text('วินิจฉัยโดย $who',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(big ? 9.5 : 8.0,
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

  /// เลือกประเภทของรหัสที่ i · เลือก Type 1 = ย้ายรหัสนี้ขึ้นเป็นรหัสแรก
  /// (Principal เดิมลงเป็น 2 Comorbidity) เพื่อให้ Type 1 มีตัวเดียวเสมอ
  Future<void> _pickDiagType(int i) async {
    final items = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    if (i < 0 || i >= items.length) return;
    final opts = {
      for (final (code, name, th) in _diagTypes)
        [
          '$code · $name',
          if (th.isNotEmpty) '($th)',
          if (code == '1' && i > 0) '· ย้ายขึ้นเป็นรหัสแรก',
        ].join(' '): code
    };
    final cur = _diagTypeOf(items, i);
    final picked = await _listSheet(
        'ประเภทการวินิจฉัย · ${items[i]}', opts.keys.toList(),
        current: opts.entries.firstWhere((e) => e.value == cur).key);
    final t = opts[picked];
    if (t == null || t == cur || !mounted) return;
    if (t == '1') {
      // รหัสอื่นขึ้นเป็น Principal: ย้ายขึ้นแถวแรก Principal เดิมลงเป็น 2
      final name = items.removeAt(i);
      _storeDiagType(items.first, '2');
      _setMulti(_icd10Label, [name, ...items]);
    } else if (i == 0) {
      // Principal เปลี่ยนเป็นประเภทอื่น: ต้องมี Type 1 เสมอ → รหัสถัดไปขึ้นเป็น Principal
      if (items.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
                'ต้องมี Type 1 Principal 1 รหัส · เพิ่มรหัสอื่นก่อนแล้วค่อยเปลี่ยน',
                style: _t(12.0, color: Colors.white))));
        return;
      }
      final main = items.removeAt(0);
      _storeDiagType(main, t);
      _setMulti(_icd10Label, [items.first, main, ...items.skip(1)]);
    } else {
      setState(() => _storeDiagType(items[i], t));
    }
  }

  /// แก้ Diagnosis Text รายการที่ i หรือเพิ่มใหม่ (i = null) · บันทึกค่าว่าง = ลบรายการนั้น
  Future<void> _editDxText(int? i) async {
    final items = _multiItems(_filled[_speechStep][_dxTextLabel]);
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('หยุดไมค์ของผู้ช่วยก่อน แล้วค่อยพูดในช่องนี้')));
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
              .apply(fontFamily: 'IBMPlexSansThaiLooped'),
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

  /// ICD-9-CM ที่ลงไว้แล้วในขั้น "บาดแผล/หัตถการ" แต่ยังไม่อยู่ในรายการนี้ (แตะเพื่อเพิ่ม)
  List<String> _icd9FromProcedure() {
    final have = _multiItems(_filled[_speechStep][_icd9DxLabel]);
    return [
      for (var st = 0; st < _forms.length; st++)
        if (st != _speechStep && _forms[st].any((f) => f.$1 == _icd9Label))
          for (final n in _multiItems(_filled[st][_icd9Label]))
            if (!have.contains(n)) n
    ];
  }

  /// เลือกรหัส ICD-9-CM จาก master: แก้รายการที่ i หรือเพิ่มใหม่ (i = null)
  Future<void> _pickIcd9(int? i) async {
    final items = _multiItems(_filled[_speechStep][_icd9DxLabel]);
    final codes = _icd9Codes();
    final shown = {
      for (final e in codes.entries)
        if (!items.contains(e.key) || (i != null && items[i] == e.key))
          '${e.value} · ${e.key}': e.key
    };
    final cur = i == null ? null : items[i];
    final picked = await _listSheet('รหัสหัตถการ ICD-9-CM', shown.keys.toList(),
        current: cur == null ? null : '${codes[cur]} · $cur');
    final name = shown[picked];
    if (name == null || !mounted) return;
    _setMulti(_icd9DxLabel, i == null ? [...items, name] : (items..[i] = name));
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
          Text('จากขั้นบาดแผล/หัตถการ · แตะเพื่อเพิ่ม',
              style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
          const SizedBox(height: 4.0),
          Wrap(spacing: 5.0, runSpacing: 5.0, children: [
            for (final n in sug)
              _optChip('+ ${codes[n] == null ? '' : '${codes[n]} · '}$n', false,
                  false, () {
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
    _filled[_speechStep]['$_noteLabel - by'] = 'note\t$who';
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('แพทย์ท่านนี้ยังไม่มี Template Doctor Note',
              style: _t(12.0, color: Colors.white))));
      return;
    }
    final picked = await _listSheet(
        'Template Doctor Note · ${ErSession.instance.user?.name ?? ''}',
        mine.keys.toList());
    final text = mine[picked];
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
                    v ??
                        'แตะเพื่อพิมพ์ · กด "พูด" เพื่อแปลงเสียง · หรือเลือก Template',
                    style: _t(big ? 12.5 : 10.0,
                        color: v != null ? _inkTitle : _ink3,
                        height: 1.45,
                        weight: v != null ? FontWeight.w500 : FontWeight.w400)),
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
    final picked = await showModalBottomSheet<_DxTemplate>(
      context: context,
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
      _flashGlow({_dxTextLabel, if (name != null) _icd10Label});
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            name == null
                ? 'เพิ่ม "${t.name}" แล้ว · ไม่พบรหัส ${t.icd10} ใน master ICD-10'
                : 'เพิ่ม "${t.name}" แล้ว · ลง ICD-10 ${t.icd10} ให้อัตโนมัติ',
            style: _t(12.0, color: Colors.white))));
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
      ),
      _PastVisit(
        date: d3,
        admit: false,
        dept: 'ER ห้องฉุกเฉิน',
        vn: vn(d3, 41),
        icd: const [('A09', '1', 'นพ. ธีรภัทร อมรเลิศ')],
        dx: const ['ท้องเสียเฉียบพลัน ขาดน้ำเล็กน้อย'],
      ),
    ];
  }

  /// ปุ่ม Re-Diag (pill กรมท่าเล็ก มุมขวา · พื้นที่แตะ 40)
  Widget _reDiagBtn() => Tooltip(
        message: 'นำรหัส ICD-10 และ Diagnosis Text จาก visit ก่อนหน้ามาใช้',
        child: _Press(
          child: InkWell(
            onTap: _openReDiag,
            borderRadius: BorderRadius.circular(100.0),
            child: SizedBox(
              height: 40.0,
              child: Center(
                widthFactor: 1.0,
                child: Container(
                  height: 28.0,
                  padding: const EdgeInsets.symmetric(horizontal: 11.0),
                  decoration: BoxDecoration(
                    gradient: _glossGrad(_blue),
                    borderRadius: BorderRadius.circular(100.0),
                    boxShadow: _glossLift(_blue),
                  ),
                  foregroundDecoration: const _InnerGloss(100.0, dark: true),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.history_rounded,
                        size: 14.0, color: Colors.white),
                    const SizedBox(width: 4.0),
                    Text('Re-Diag',
                        style: _t(10.5,
                            color: Colors.white, weight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );

  /// หน้าต่าง Re-Diag: ซ้าย = รายการ visit · ขวา = วินิจฉัยของ visit ที่เลือก ติ๊กเลือกได้
  /// เลือกข้าม visit ได้ รายการที่มีอยู่แล้วใน visit นี้ติ๊กไม่ได้ (ไม่เพิ่มซ้ำ)
  Future<void> _openReDiag() async {
    final visits = _pastVisits();
    final codes = {
      for (final e in _icd10Codes().entries) e.value: e.key
    }; // รหัส → ชื่อ
    final haveIcd = _multiItems(_filled[_speechStep][_icd10Label], icd: true);
    final haveDx = _multiItems(_filled[_speechStep][_dxTextLabel]);
    var at = 0;
    // key: 'i|รหัส' หรือ 'd|ข้อความ' → ประเภท (เฉพาะ ICD-10)
    final picked = <String, String>{};
    final p = _caseP();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final v = visits[at];
        final icds = [
          for (final (code, type, doc) in v.icd)
            if (codes[code] != null) (code, codes[code]!, type, doc)
        ];
        bool hasIcd(String name) => haveIcd.contains(name);
        bool hasDx(String t) => haveDx.contains(t);
        final freeIcd = [
          for (final x in icds)
            if (!hasIcd(x.$2)) x
        ];
        final freeDx = [
          for (final t in v.dx)
            if (!hasDx(t)) t
        ];
        final allIcd = freeIcd.isNotEmpty &&
            freeIcd.every((x) => picked.containsKey('i|${x.$1}'));
        final allDx = freeDx.isNotEmpty &&
            freeDx.every((t) => picked.containsKey('d|$t'));
        void toggle(String k, [String type = '']) => set(
            () => picked.containsKey(k) ? picked.remove(k) : picked[k] = type);

        Widget selAll(bool on, bool enabled, VoidCallback onTap) => _Press(
              child: InkWell(
                onTap: enabled ? onTap : null,
                borderRadius: BorderRadius.circular(100.0),
                child: Container(
                  height: 30.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: on ? _blue : _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(
                        color: enabled ? _blue.withValues(alpha: 0.5) : _line),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(on ? Icons.check_box_rounded : Icons.done_all_rounded,
                        size: 14.0,
                        color: on ? Colors.white : (enabled ? _blue : _g5)),
                    const SizedBox(width: 4.0),
                    Text(on ? 'เลือกแล้วทั้งหมด' : 'เลือกทั้งหมด',
                        style: _t(10.0,
                            color: on ? Colors.white : (enabled ? _blue : _g5),
                            weight: FontWeight.w700)),
                  ]),
                ),
              ),
            );

        Widget row({
          required bool on,
          required bool have,
          required VoidCallback onTap,
          required Widget lead,
          required String title,
          String? sub,
        }) =>
            InkWell(
              onTap: have ? null : onTap,
              borderRadius: BorderRadius.circular(10.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(bottom: 6.0),
                padding: const EdgeInsets.fromLTRB(6.0, 8.0, 12.0, 8.0),
                decoration: BoxDecoration(
                  color: on ? _blue.withValues(alpha: 0.06) : _panel,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: on ? _blue.withValues(alpha: 0.55) : _line,
                      width: on ? 1.5 : 1.0),
                ),
                child: Row(children: [
                  SizedBox(
                    width: 36.0,
                    child: Icon(
                        have
                            ? Icons.check_circle_rounded
                            : (on
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded),
                        size: 20.0,
                        color: have ? _g5 : (on ? _blue : _ink3)),
                  ),
                  lead,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: _t(12.0,
                                color: have ? _ink3 : _inkTitle,
                                height: 1.35,
                                weight: FontWeight.w600)),
                        if (sub != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(sub,
                                style: _t(9.5,
                                    color: _ink3, weight: FontWeight.w500)),
                          ),
                      ],
                    ),
                  ),
                  if (have)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: _panelSoft,
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text('มีใน visit นี้แล้ว',
                          style:
                              _t(9.0, color: _ink3, weight: FontWeight.w700)),
                    ),
                ]),
              ),
            );

        Widget sectionHead(IconData icon, String t, Widget action) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(children: [
                Icon(icon, size: 16.0, color: _blue),
                const SizedBox(width: 6.0),
                Text(t,
                    style: _t(12.0, color: _inkTitle, weight: FontWeight.w700)),
                const Spacer(),
                action,
              ]),
            );

        // ---- รายการ visit (ซ้าย)
        final visitList = ListView.separated(
          padding: const EdgeInsets.all(10.0),
          itemCount: visits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8.0),
          itemBuilder: (_, i) {
            final x = visits[i];
            final on = i == at;
            final n = picked.keys
                .where((k) =>
                    (k.startsWith('i|') &&
                        x.icd.any((c) => 'i|${c.$1}' == k)) ||
                    (k.startsWith('d|') && x.dx.contains(k.substring(2))))
                .length;
            return InkWell(
              onTap: () => set(() => at = i),
              borderRadius: BorderRadius.circular(12.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  gradient: on ? _glossGrad(_blue) : null,
                  color: on ? null : _panel,
                  borderRadius: BorderRadius.circular(12.0),
                  border: on ? null : Border.all(color: _line),
                  boxShadow: on ? _glossLift(_blue) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(_apptDate(x.date),
                            style: _t(12.5,
                                color: on ? Colors.white : _inkTitle,
                                weight: FontWeight.w700)),
                      ),
                      if (x.admit)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: on
                                ? Colors.white.withValues(alpha: 0.2)
                                : _blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: Text('ADMIT',
                              style: _t(8.5,
                                  color: on ? Colors.white : _blue,
                                  weight: FontWeight.w700)),
                        ),
                    ]),
                    const SizedBox(height: 4.0),
                    Text(x.dept,
                        style: _t(10.0,
                            color: on ? _pInk2 : _ink2,
                            weight: FontWeight.w600)),
                    Text('VN ${x.vn}${x.an == null ? '' : ' · AN ${x.an}'}',
                        style: _num(9.0,
                            color: on ? _pInk2 : _ink3,
                            weight: FontWeight.w600)),
                    const SizedBox(height: 6.0),
                    Row(children: [
                      if (i == 0)
                        Text('ครั้งล่าสุด',
                            style: _t(9.0,
                                color: on ? Colors.white : _blue,
                                weight: FontWeight.w700)),
                      const Spacer(),
                      Text('${x.icd.length} รหัส · ${x.dx.length} ข้อความ',
                          style: _t(9.0, color: on ? _pInk2 : _ink3)),
                    ]),
                    if (n > 0) ...[
                      const SizedBox(height: 6.0),
                      Text('เลือกไว้ $n รายการ',
                          style: _t(9.5,
                              color: on ? Colors.white : _blue,
                              weight: FontWeight.w700)),
                    ],
                  ],
                ),
              ),
            );
          },
        );

        // ---- วินิจฉัยของ visit ที่เลือก (ขวา)
        final detail = ListView(
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 14.0),
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(children: [
                Icon(
                    v.admit
                        ? Icons.local_hotel_rounded
                        : Icons.event_note_rounded,
                    size: 16.0,
                    color: _blue),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text('${_apptDate(v.date)} · ${v.dept} · VN ${v.vn}',
                      style:
                          _t(11.5, color: _inkTitle, weight: FontWeight.w700)),
                ),
                if (at == 0)
                  Text('ครั้งล่าสุด',
                      style: _t(10.0, color: _blue, weight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 14.0),
            sectionHead(
                Icons.qr_code_rounded,
                'รหัส ICD-10',
                selAll(allIcd, freeIcd.isNotEmpty, () {
                  set(() {
                    for (final x in freeIcd) {
                      allIcd
                          ? picked.remove('i|${x.$1}')
                          : picked['i|${x.$1}'] = x.$3;
                    }
                  });
                })),
            if (icds.isEmpty)
              Text('ไม่มีรหัส ICD-10', style: _t(11.0, color: _ink3)),
            for (final (code, name, type, doc) in icds)
              row(
                on: picked.containsKey('i|$code'),
                have: hasIcd(name),
                onTap: () => toggle('i|$code', type),
                lead: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    // เลข Type สีตามกติกาเดียวกับหน้า ICD-10
                    Builder(builder: (_) {
                      final (bg, fg) = _diagTypeTone(type);
                      return Container(
                        width: 20.0,
                        height: 20.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: bg == null ? null : _glossGrad(bg),
                          color: bg == null ? _panel : null,
                          border: bg == null
                              ? Border.all(color: fg, width: 1.5)
                              : null,
                        ),
                        child: Text(type,
                            style:
                                _num(10.0, color: fg, weight: FontWeight.w700)),
                      );
                    }),
                    const SizedBox(width: 8.0),
                    Text(code,
                        style:
                            _num(12.5, color: _blue, weight: FontWeight.w700)),
                  ]),
                ),
                title: name,
                sub:
                    'Type $type ${_diagTypes.firstWhere((d) => d.$1 == type, orElse: () => _diagTypes[1]).$2} · วินิจฉัยโดย $doc',
              ),
            const SizedBox(height: 14.0),
            sectionHead(
                Icons.notes_rounded,
                'Diagnosis Text',
                selAll(allDx, freeDx.isNotEmpty, () {
                  set(() {
                    for (final t in freeDx) {
                      allDx ? picked.remove('d|$t') : picked['d|$t'] = '';
                    }
                  });
                })),
            if (v.dx.isEmpty)
              Text('ไม่มี Diagnosis Text', style: _t(11.0, color: _ink3)),
            for (final t in v.dx)
              row(
                on: picked.containsKey('d|$t'),
                have: hasDx(t),
                onTap: () => toggle('d|$t'),
                lead: const SizedBox.shrink(),
                title: t,
              ),
          ],
        );

        final size = MediaQuery.sizeOf(ctx);
        return Dialog(
          backgroundColor: _bg,
          insetPadding: const EdgeInsets.all(24.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          child: SizedBox(
            width: math.min(900.0, size.width - 48.0),
            height: math.min(620.0, size.height - 48.0),
            child: Column(children: [
              // หัวหน้าต่าง
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 14.0, 8.0, 10.0),
                child: Row(children: [
                  Container(
                    width: 34.0,
                    height: 34.0,
                    decoration: BoxDecoration(
                      gradient: _glossGrad(_blue),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.history_rounded,
                        size: 18.0, color: Colors.white),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Re-Diag · ใช้วินิจฉัยจาก visit ก่อนหน้า',
                            style: _t(14.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        Text(
                            '${p.name} · HN ${p.hn} · เลือก ICD-10 หรือ Diagnosis Text แยกกันได้',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(10.0, color: _ink3)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    tooltip: 'ปิด',
                    icon: const Icon(Icons.keyboard_double_arrow_left_rounded,
                        color: _ink2),
                  ),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 230.0,
                        decoration: _clyCardDeco,
                        foregroundDecoration: const _InnerGloss(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  12.0, 12.0, 12.0, 0),
                              child: Text('เลือก Visit',
                                  style: _t(12.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                            ),
                            Expanded(child: visitList),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Container(
                          decoration: _clyCardDeco,
                          foregroundDecoration: const _InnerGloss(12.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: KeyedSubtree(
                                key: ValueKey('rediag-$at'), child: detail),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ปุ่มหลักขอบล่าง
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 12.0, 14.0, 14.0),
                child: Row(children: [
                  Expanded(
                    child: Text(
                        picked.isEmpty
                            ? 'ติ๊กรายการที่ต้องการ แล้วกดเพิ่ม · ข้อมูล visit เป็นตัวอย่าง'
                            : 'เลือกไว้ ${picked.length} รายการ',
                        style: _t(10.5,
                            color: picked.isEmpty ? _ink3 : _blue,
                            weight: FontWeight.w600)),
                  ),
                  if (picked.isNotEmpty)
                    TextButton(
                      onPressed: () => set(picked.clear),
                      child:
                          Text('ล้างที่เลือก', style: _t(11.0, color: _ink3)),
                    ),
                  const SizedBox(width: 6.0),
                  _apptPrimaryBtn(
                      Icons.add_task_rounded,
                      picked.isEmpty
                          ? 'เพิ่มรายการที่เลือก'
                          : 'เพิ่ม ${picked.length} รายการใน visit นี้',
                      picked.isEmpty ? null : () => Navigator.pop(ctx, true)),
                ]),
              ),
            ]),
          ),
        );
      }),
    );
    if (ok != true || picked.isEmpty || !mounted) return;
    _applyReDiag(picked, codes);
  }

  /// เพิ่มรายการที่เลือกลง ICD-10 / Diagnosis Text ของ visit นี้ (ไม่ซ้ำ · คงประเภทเดิม)
  void _applyReDiag(Map<String, String> picked, Map<String, String> codes) {
    final st = _speechStep;
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
      if (addDx.isNotEmpty) _filled[st][_dxTextLabel] = dx.join('\n');
      _stampBy(_icd10Label, addIcd);
      _stampBy(_dxTextLabel, addDx);
      _flashGlow({
        if (addIcd.isNotEmpty) _icd10Label,
        if (addDx.isNotEmpty) _dxTextLabel,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            'Re-Diag: เพิ่ม ICD-10 ${addIcd.length} รหัส · Diagnosis Text ${addDx.length} รายการ',
            style: _t(12.0, color: Colors.white))));
  }
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
  });

  final DateTime date;
  final bool admit;
  final String dept;
  final String vn;
  final String? an;
  final List<(String, String, String)> icd;
  final List<String> dx;
}
