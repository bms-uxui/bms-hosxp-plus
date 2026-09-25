// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ จัดรูปแบบย่อหน้า HPI
// กติกา knowledge #15: HPI เป็นย่อหน้าเดียวในฟอร์ม แต่ต้องอ่านง่าย
// จัดบรรทัดตามหัวข้อทางคลินิก (เวลา · ลักษณะ/ร้าว · อาการร่วม · ประวัติ · ยา · การดูแลก่อนมา)

/// คำที่เริ่มหัวข้อใหม่ → ขึ้นบรรทัดใหม่ก่อนคำนี้
const List<String> _hpiBreaks = [
  'เริ่มเมื่อ',
  'เมื่อ[',
  'Last',
  'พบอาการ',
  'ขณะเกิดเหตุ',
  'หมดสติ',
  'ลักษณะ',
  'ร้าวไป',
  'เป็นขณะ',
  'เป็นมากขึ้น',
  'ปัจจัย',
  'อาการร่วม',
  'ความรุนแรง',
  'ประจำเดือน',
  'ประวัติ',
  'ยาที่',
  'ยาต้าน',
  'ได้ยา',
  'ใช้ยา',
  'ได้รับการดูแล',
  'การรักษา',
];

/// จัด HPI เป็นบรรทัดตามหัวข้อ: คงช่อง [ ] ไว้ทั้งก้อน ไม่ตัดกลางวงเล็บ
String _prettyHpi(String text) {
  final flat = text
      .replaceAll(RegExp(r'^\s*[•\-]\s*', multiLine: true), '')
      .replaceAll(RegExp(r'\s*\n\s*'), ' ')
      .trim();
  if (flat.isEmpty) return flat;
  final tokens = RegExp(r'\S*\[[^\]]*\]\S*|\S+')
      .allMatches(flat)
      .map((m) => m.group(0)!)
      .toList();
  final lines = <List<String>>[[]];
  for (final t in tokens) {
    final brk = lines.last.isNotEmpty &&
        (_hpiBreaks.any((k) => t.startsWith(k)) ||
            (lines.last.last.endsWith('.') &&
                !lines.last.last.endsWith('รพ.')));
    if (brk) lines.add([]);
    lines.last.add(t);
  }
  return lines.map((l) => l.join(' ')).join('\n');
}

extension _FeaturesWorkflowHpiPart on _ErFlowHomeWidgetState {
  /// ค่าที่ผู้ช่วยกรอก: HPI จัดบรรทัดให้อัตโนมัติ
  String _fmtField(String label, String v) =>
      label == 'HPI' ? _prettyHpi(v) : v;

  /// แถบเหนือช่อง HPI: บอกว่าจัดรูปแบบอัตโนมัติ (แบบ prettier) + ปุ่มแก้ไข
  /// ไม่มีปุ่มจัดเอง: ทุกค่าที่เข้า (พิมพ์ · พูด · template · AI) ถูกจัดบรรทัดทันที
  Widget _hpiFormatBar() {
    final v = _filled[_speechStep]['HPI'];
    // ค่าที่เข้ามาทางอื่นแล้วยังไม่ถูกจัด (เช่น ถอดเสียงเติมต่อท้าย) จัดให้ตอนแสดง
    if (v != null && v.isNotEmpty && _prettyHpi(v) != v) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final now = _filled[_speechStep]['HPI'];
        if (!mounted || now == null) return;
        final pretty = _prettyHpi(now);
        if (pretty != now) setState(() => _filled[_speechStep]['HPI'] = pretty);
      });
    }
    return Row(children: [
      Container(
        height: 26.0,
        padding: const EdgeInsets.symmetric(horizontal: 9.0),
        decoration: BoxDecoration(
          color: _blue.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome_rounded, size: 12.0, color: _blue),
          const SizedBox(width: 4.0),
          Text('จัดรูปแบบอัตโนมัติ',
              style: _t(10.0, color: _blueHue, weight: FontWeight.w600)),
        ]),
      ),
      const Spacer(),
      _Press(
        child: GestureDetector(
          onTap: () => _editField('HPI'),
          child: Container(
            height: 28.0,
            padding: const EdgeInsets.symmetric(horizontal: 9.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: _line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.edit_outlined, size: 14.0, color: _ink2),
              const SizedBox(width: 4.0),
              Text('แก้ไข', style: _t(10.5, color: _ink2)),
            ]),
          ),
        ),
      ),
    ]);
  }

  /// หน้าแรกของ HPI: เลือก template (แนะนำตามเคสขึ้นก่อน) แล้วไปหน้าฟอร์ม
  Widget _hpiPickCard() {
    final sug = _hpiSuggest;
    final list = [
      ..._hpiTemplates.where((t) => t.$1 == sug),
      ..._hpiTemplates.where((t) => t.$1 != sug),
    ];
    final cur = _filled[_speechStep]['HPI'];
    void next() => setState(() {
          _formFwd = true;
          _uiIdx = _uiSeq.indexWhere((x) => x.type == ErUiType.form);
          _formAt = 0;
        });
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(children: [
              for (final t in list)
                _tplRow(
                  title: t.$2,
                  preview: t.$3,
                  badge: t.$1 == sug ? 'แนะนำ' : null,
                  on: cur == t.$3,
                  onTap: () {
                    setState(() {
                      _lastFilled = [(_speechStep, 'HPI', cur)];
                      _filled[_speechStep]['HPI'] = _prettyHpi(t.$3);
                    });
                    next();
                  },
                ),
            ]),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: next,
            child: Text('ข้าม · เล่าเอง',
                style: _t(11.5, color: _blueHue, weight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  bool _isHpiStep(int step) =>
      ErSession.instance.role == ErRole.doctor && step == 1;

  /// template ที่เหมาะกับเคสนี้ (ตามประเภทผู้ป่วย/อาการสำคัญ)
  String get _hpiSuggest {
    final cc = _case.cc;
    return switch (_caseP().type) {
      _Ptype.trauma => 'trauma',
      _Ptype.stemi => 'chest_pain',
      _Ptype.stroke => 'stroke',
      _Ptype.sepsis => 'fever',
      _ => cc.contains('ปวดท้อง')
          ? 'abd_pain'
          : (cc.contains('เจ็บหน้าอก') || cc.contains('แน่นหน้าอก'))
              ? 'chest_pain'
              : (cc.contains('หอบ') || cc.contains('เหนื่อย'))
                  ? 'dyspnea'
                  : 'general',
    };
  }

  String _hpiTemplatePrompt() => '''
template HPI ที่ระบบมี (แนะนำสำหรับเคสนี้: "$_hpiSuggest"):
${[for (final t in _hpiTemplates) '- ${t.$1} (${t.$2}): ${t.$3}'].join('\n')}
การใช้ template: เลือก template ที่ตรงเคสแล้วใส่ "hpi_template":"<id>" ใน JSON ระบบจะวางข้อความ template ลงช่อง HPI ให้
เมื่อแพทย์เล่าประวัติ ให้เติมข้อความใน [ ] ของ template ด้วยสิ่งที่แพทย์พูด แล้วส่ง HPI ทั้งย่อหน้าใน fields
ส่วนที่แพทย์ยังไม่ได้พูดให้คง [ ] ไว้ แล้วถามต่อทีละ 1-2 ข้อ ห้ามเดาข้อมูล
ช่อง HPI มี template ที่แพทย์เลือกวางอยู่แล้วเสมอ (ดู "ค่าที่บันทึกไว้แล้ว") ห้ามเขียนย่อหน้าใหม่แยกออกมา
ให้เติมคำพูดลงช่อง [ ] ของ template นั้นเท่านั้น ข้อมูลที่ไม่มีช่องรองรับค่อยต่อท้ายประโยคที่เกี่ยวข้องสั้น ๆ
วิธีเติม: แทนที่ "[คำใบ้]" ทั้งก้อน (รวมวงเล็บ) ด้วยค่าจริง ไม่ต้องมีวงเล็บ
  เช่น "ผู้ป่วย[เพศ/อายุ]" + "หญิง 54 ปี" → "ผู้ป่วยหญิง 54 ปี" · "อาเจียน[มี/ไม่มี]" + สองครั้ง → "อาเจียน 2 ครั้ง"
  "ขณะเกิดเหตุ[ผู้ขับขี่/ผู้โดยสาร]" + ซ้อน → "ขณะเกิดเหตุเป็นผู้โดยสาร"
ช่องที่ยังไม่ได้พูด ต้องคง "[คำใบ้]" เดิมไว้ตรงตัวอักษร ห้ามเปลี่ยนเป็น "[ ]" ห้ามเดา
HPI คือเอกสารที่ "โตขึ้นเรื่อย ๆ" จากประโยคทั้งหมดที่พูด ให้ HPI ใน "ค่าที่บันทึกไว้แล้ว" เป็นต้นฉบับ
- แก้แบบผ่าตัด: คงทุกประโยค/วลีที่ข้อมูลใหม่ไม่กระทบไว้ "ตรงตัวอักษร" ห้ามเรียบเรียงใหม่หรือสลับลำดับ
- ประโยคหลังแก้ประโยคก่อน (เช่น "ขอแก้ ไม่ได้เป็นคนขับ เป็นคนซ้อน") → เปลี่ยนเฉพาะวลีนั้น
- ถ้าประโยคเดิมถูกลบ/แก้จนข้อมูลนั้นไม่มีที่มาแล้ว → คืนวลีนั้นเป็น [ ] ของ template
- ส่ง HPI ทั้งย่อหน้าที่แก้แล้วใน fields ทุกครั้งที่มีการเปลี่ยน''';

  /// ผู้ช่วยเรียกใช้ template: {"hpi_template":"trauma"} → วางลงช่อง HPI ถ้ายังว่าง
  void _useHpiTemplate(Map<String, dynamic> data, int step) {
    final id = data['hpi_template'];
    if (id is! String || !_isHpiStep(step)) return;
    final t = _hpiTemplates.where((x) => x.$1 == id.trim()).firstOrNull;
    if (t == null) return;
    final cur = _filled[step]['HPI'];
    if (cur == null || cur.trim().isEmpty) {
      _filled[step]['HPI'] = _prettyHpi(t.$3);
    }
  }

  /// แถบเลือก template ใต้ช่อง HPI (แตะเพื่อวาง/แทนที่)
  Widget _hpiTemplateBar() {
    final sug = _hpiSuggest;
    final list = [
      ..._hpiTemplates.where((t) => t.$1 == sug),
      ..._hpiTemplates.where((t) => t.$1 != sug),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Template', style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
        const SizedBox(height: 4.0),
        SizedBox(
          height: 28.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 5.0),
            itemBuilder: (_, i) {
              final t = list[i];
              final rec = t.$1 == sug;
              return InkWell(
                onTap: () => setState(() {
                  _lastFilled = [
                    (_speechStep, 'HPI', _filled[_speechStep]['HPI'])
                  ];
                  _filled[_speechStep]['HPI'] = _prettyHpi(t.$3);
                }),
                borderRadius: BorderRadius.circular(100.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rec ? _blue.withValues(alpha: 0.08) : _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: rec ? _blue : _line),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (rec) ...[
                      const Icon(Icons.auto_awesome_rounded,
                          size: 11.0, color: _blue),
                      const SizedBox(width: 3.0),
                    ],
                    Text(t.$2,
                        style: _t(10.5,
                            color: rec ? _blueHue : _ink2,
                            weight: rec ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
