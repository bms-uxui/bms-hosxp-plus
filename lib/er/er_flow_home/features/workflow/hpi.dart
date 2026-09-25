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
                      _hpiManual = false;
                      _lastFilled = [(_speechStep, 'HPI', cur)];
                      _filled[_speechStep]['HPI'] = _prettyHpi(t.$3);
                    });
                    next();
                  },
                ),
            ]),
          ),
        ),
        const SizedBox(height: 8.0),
        // เล่าเองในฟอร์มเปล่า (พิมพ์/พูด) แล้วค่อยเลือก template มาจัดทีหลัง
        _Press(
          child: Material(
            color: _panel,
            borderRadius: BorderRadius.circular(12.0),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                setState(() {
                  _hpiManual = true;
                  final v = _filled[_speechStep]['HPI'] ?? '';
                  // ยังเป็น template ที่ไม่ได้เติม = ล้างให้เป็นฟอร์มเปล่า
                  if (v.contains('[')) {
                    _lastFilled = [(_speechStep, 'HPI', v)];
                    _filled[_speechStep].remove('HPI');
                  }
                });
                next();
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: _blue.withValues(alpha: 0.5)),
                ),
                child: Row(children: [
                  const Icon(Icons.edit_note_rounded, size: 22.0, color: _blue),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('เพิ่ม HPI ด้วยตนเอง',
                              style: _t(12.5,
                                  color: _blueHue, weight: FontWeight.w700)),
                          Text(
                              'ฟอร์มเปล่า พิมพ์หรือพูดเล่าได้เลย แล้วค่อยเลือก template มาจัดทีหลัง',
                              style: _t(10.0, color: _ink3)),
                        ]),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20.0, color: _blue),
                ]),
              ),
            ),
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

  String _hpiTemplatePrompt() => _hpiManual
      ? '''
แพทย์เลือกเล่า HPI เอง (ยังไม่ใช้ template): เขียน HPI เป็นย่อหน้าจากสิ่งที่แพทย์พูด
คงถ้อยคำของแพทย์ ไม่ใส่ [ ] ไม่เดาข้อมูล ห้ามใส่ "hpi_template"
HPI ใน "ค่าที่บันทึกไว้แล้ว" เป็นต้นฉบับ: ต่อท้ายข้อมูลใหม่ แก้เฉพาะวลีที่ถูกแก้ ส่ง HPI ทั้งย่อหน้าใน fields'''
      : '''
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
        Row(children: [
          Text(_hpiManual ? 'จัดลง template (AI เติมจากที่เล่า)' : 'Template',
              style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
          if (_hpiApplying) ...[
            const SizedBox(width: 6.0),
            const SizedBox(
                width: 10.0,
                height: 10.0,
                child:
                    CircularProgressIndicator(strokeWidth: 1.6, color: _blue)),
            const SizedBox(width: 4.0),
            Text('กำลังจัด…', style: _t(9.5, color: _blue)),
          ],
        ]),
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
                onTap: () {
                  final cur = (_filled[_speechStep]['HPI'] ?? '').trim();
                  // เล่าเองไว้แล้ว: ให้ AI จัดข้อความที่เล่าลง template นี้
                  if (_hpiManual && cur.isNotEmpty && !cur.contains('[')) {
                    _hpiApplyTemplate(t);
                    return;
                  }
                  setState(() {
                    _hpiManual = false;
                    _lastFilled = [(_speechStep, 'HPI', cur)];
                    _filled[_speechStep]['HPI'] = _prettyHpi(t.$3);
                  });
                },
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

  /// เอาข้อความ HPI ที่เล่าเองมาจัดลง template ที่เลือก (AI เติมช่อง [ ])
  /// ข้อมูลที่ไม่มีช่องรองรับต่อท้ายประโยคที่เกี่ยวข้อง · ช่องที่ไม่ได้เล่าคง [คำใบ้]
  Future<void> _hpiApplyTemplate((String, String, String) t) async {
    if (_hpiApplying) return;
    final step = _speechStep;
    final old = (_filled[step]['HPI'] ?? '').trim();
    setState(() => _hpiApplying = true);
    try {
      final out = await ErAi.chat([
        {
          'role': 'system',
          'content': '''
จัดประวัติปัจจุบัน (HPI) ที่แพทย์เล่า ลงใน template ที่ให้
- แทนที่ "[คำใบ้]" ทั้งก้อนด้วยข้อมูลจากที่เล่า ไม่ต้องมีวงเล็บ
- ช่องที่ไม่มีข้อมูล คง "[คำใบ้]" เดิมไว้ตรงตัวอักษร ห้ามเดา
- ข้อมูลที่เล่าแต่ไม่มีช่องรองรับ ต่อท้ายประโยคที่เกี่ยวข้องสั้น ๆ ห้ามทิ้งข้อมูล
- ใช้ถ้อยคำของแพทย์ ห้ามเพิ่มข้อมูลใหม่
ตอบ JSON: {"hpi":"ย่อหน้า HPI ที่จัดแล้ว"}'''
        },
        {
          'role': 'user',
          'content': 'template (${t.$2}):\n${t.$3}\n\nที่แพทย์เล่า:\n$old'
        },
      ], fast: true, json: true, temperature: 0.1, maxTokens: 900);
      final v = (ErAi.extractJson(out)?['hpi'] ?? '').toString().trim();
      if (!mounted || v.isEmpty) return;
      setState(() {
        _hpiManual = false;
        _lastFilled = [(step, 'HPI', old)];
        _diffs['HPI'] = (old, ++_diffGen);
        _filled[step]['HPI'] = _prettyHpi(v);
        _flashGlow({'HPI'});
      });
    } catch (e) {
      if (mounted) {
        setState(() => _agentStatus = 'จัดลง template ไม่สำเร็จ ลองใหม่');
      }
    } finally {
      if (mounted) setState(() => _hpiApplying = false);
    }
  }
}
