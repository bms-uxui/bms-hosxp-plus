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
  'Diagnosis ICD-10': 'รหัสโรค',
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
            l
      ];

  /// ช่องไม่บังคับ: เว้นว่างได้ ไม่นับเป็นช่องที่ขาด (ไม่ขวางการไปหน้าสรุป)
  static const Set<String> _optionalFields = {'บันทึกการตรวจแบบละเอียด'};

  /// ช่องนี้ครบหรือยัง: ผลตรวจ "ผิดปกติ" ต้องมีรายละเอียดเสมอ
  bool _fieldDone(int st, String l) {
    final v = _filled[st][l];
    if (v == null || v.trim().isEmpty) return _optionalFields.contains(l);
    // template ที่ยังมีช่องว่าง [ ] = ยังเล่าไม่ครบ ไม่นับว่ากรอกแล้ว
    if (RegExp(r'\[[^\]]*\]').hasMatch(v)) return false;
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
}
