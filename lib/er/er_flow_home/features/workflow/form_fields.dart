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
  'Diagnosis ICD-10': 'รหัสโรค และ Diagnosis Text ในหน้าเดียว',
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
    if (fill) {
      final hpi = _isHpiStep(_speechStep) && label == 'HPI';
      if (hpi) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _hpiFormatBar(),
            const SizedBox(height: 8.0),
            Expanded(child: field),
            const SizedBox(height: 10.0),
            _hpiTemplateBar(),
          ],
        );
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
    final hpi = _isHpiStep(_speechStep) && label == 'HPI';
    final detail = _isPeStep(_speechStep) && _peHasDetail(label);
    if (!hpi && !detail) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hpi) ...[_hpiFormatBar(), const SizedBox(height: 8.0)],
        field,
        const SizedBox(height: 8.0),
        hpi ? _hpiTemplateBar() : _detailBox(label),
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
    return InkWell(
      onTap: () => _editField(key),
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
            child: Text(
                must
                    ? 'ผิดปกติ · ต้องระบุรายละเอียด'
                    : (v ?? 'รายละเอียด (พิมพ์หรือพูดได้ยาว ๆ)'),
                style: _t(11.5,
                    color: v != null ? _inkTitle : _ink3,
                    height: 1.4,
                    weight: v != null ? FontWeight.w500 : FontWeight.w400)),
          ),
        ]),
      ),
    );
  }

  // ------------------------------------------------ Diagnosis หลายรายการ + Template ของแพทย์

  /// ช่องที่ลงได้หลายรายการ: Diagnosis Text และ ICD-10
  bool _isMultiField(String label) =>
      label == _dxTextLabel || label == _icd10Label;

  /// ค่าหลายรายการของช่อง (หนึ่งบรรทัด = หนึ่งรายการ)
  List<String> _multiItems(String? value) => [
        for (final s in (value ?? '').split('\n'))
          if (s.trim().isNotEmpty) s.trim()
      ];

  /// ICD-10 จาก master: ชื่อ → รหัส (ค่าที่เก็บในช่องเป็นชื่อตาม master)
  Map<String, String> _icd10Codes() => {
        for (final it in ErMaster.maybe?.table('er_icd10')?.activeItems ??
            const <ErMasterItem>[])
          it.name: it.code
      };

  /// รายการของช่องหลายค่า: แตะแถวเพื่อแก้ · ถังขยะลบ · ปุ่มล่างเพิ่ม
  /// Diagnosis Text มีปุ่ม "เลือกจาก Template" ของแพทย์ที่ login อยู่
  /// ขั้นที่มีทั้ง ICD-10 และ Diagnosis Text รวมเป็นหน้าเดียว (ICD-10 บน · Diagnosis Text ล่าง)
  /// ช่อง Diagnosis Text จึงไม่นับเป็นหน้าแยก แต่ยังเป็นช่องที่ผู้ช่วยเติมได้
  bool _dxMerged(int st, String l) =>
      l == _dxTextLabel && _forms[st].any((f) => f.$1 == _icd10Label);

  bool _hasDxText(int st) => _forms[st].any((f) => f.$1 == _dxTextLabel);

  Widget _multiList(String label, String? value,
      {bool big = false, bool fill = false}) {
    final Widget list;
    if (label == _icd10Label && _hasDxText(_speechStep)) {
      Widget head(String t, String sub, int n) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(children: [
              Text(t,
                  style: _t(big ? 12.5 : 10.5,
                      color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(big ? 10.0 : 9.0, color: _ink3)),
              ),
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
        children: [
          // Template ลงทั้งสองส่วนพร้อมกัน จึงอยู่บนสุดของหน้า
          Align(
            alignment: Alignment.centerLeft,
            child: _multiAddBtn(
                Icons.bookmarks_rounded,
                'เลือกจาก Template (ICD-10 + Diagnosis Text)',
                big,
                _pickDxTemplate),
          ),
          SizedBox(height: big ? 12.0 : 8.0),
          head('รหัส ICD-10', 'รหัสโรค', _multiItems(value).length),
          _multiSection(_icd10Label, value, big),
          Padding(
            padding: EdgeInsets.symmetric(vertical: big ? 12.0 : 8.0),
            child: const Divider(height: 1.0, color: _line),
          ),
          head('Diagnosis Text', 'ข้อความวินิจฉัย', _multiItems(dx).length),
          _multiSection(_dxTextLabel, dx, big),
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
    final items = _multiItems(value);
    final icd = label == _icd10Label;
    final codes = icd ? _icd10Codes() : const <String, String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: big ? 6.0 : 4.0),
          InkWell(
            onTap: () => icd ? _pickIcd10(i) : _editDxText(i),
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
                Text('${i + 1}.',
                    style: _num(big ? 12.0 : 9.5,
                        color: _ink3, weight: FontWeight.w700)),
                SizedBox(width: big ? 8.0 : 5.0),
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
          _multiAddBtn(
              Icons.add_rounded,
              icd
                  ? (items.isEmpty
                      ? 'เพิ่มรหัส ICD-10'
                      : 'เพิ่มรหัสที่ ${items.length + 1}')
                  : (items.isEmpty
                      ? 'เพิ่ม Diagnosis Text'
                      : 'เพิ่มรายการที่ ${items.length + 1}'),
              big,
              () => icd ? _pickIcd10(null) : _editDxText(null)),
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

  void _setMulti(String label, List<String> items) {
    final old = _filled[_speechStep][label];
    setState(() {
      _lastFilled = [(_speechStep, label, old)];
      if (items.isEmpty) {
        _filled[_speechStep].remove(label);
      } else {
        _filled[_speechStep][label] = items.join('\n');
      }
    });
  }

  /// เลือกรหัส ICD-10 จาก master: แก้รายการที่ i หรือเพิ่มใหม่ (i = null)
  /// รหัสที่เลือกไว้แล้วไม่แสดงซ้ำ
  Future<void> _pickIcd10(int? i) async {
    final items = _multiItems(_filled[_speechStep][_icd10Label]);
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
    _setMulti(_icd10Label, i == null ? [...items, name] : (items..[i] = name));
  }

  /// แก้ Diagnosis Text รายการที่ i หรือเพิ่มใหม่ (i = null) · บันทึกค่าว่าง = ลบรายการนั้น
  Future<void> _editDxText(int? i) async {
    final items = _multiItems(_filled[_speechStep][_dxTextLabel]);
    final ctrl = TextEditingController(text: i == null ? '' : items[i]);
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            i == null
                ? 'เพิ่ม Diagnosis Text (รายการที่ ${items.length + 1})'
                : 'แก้ Diagnosis Text รายการที่ ${i + 1}',
            style: _t(13.0, weight: FontWeight.w700)),
        content: SizedBox(
          width: 560.0,
          child: TextField(
            controller: ctrl,
            autofocus: true,
            minLines: 2,
            maxLines: 6,
            style: _t(12.5, height: 1.45),
            decoration: const InputDecoration(
                hintText: 'พิมพ์ข้อความวินิจฉัย 1 รายการ',
                border: OutlineInputBorder()),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ยกเลิก', style: _t(11.0, color: _ink3))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: Text(i == null ? 'เพิ่มรายการ' : 'บันทึก',
                  style: _t(11.0, color: Colors.white))),
        ],
      ),
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
    final icd = _multiItems(_filled[st][_icd10Label]);
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
}
