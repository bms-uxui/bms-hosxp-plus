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
  /// ค่าที่ผู้ช่วยกรอก: HPI จัดบรรทัดให้อัตโนมัติ · ICD-10 แยกบรรทัดละรหัส
  String _fmtField(String label, String v) => switch (label) {
        'HPI' => _prettyHpi(v),
        _icd10Label => _multiItems(v, icd: true).join('\n'),
        _ => v,
      };

  /// ค่าที่เข้ามาทางอื่นแล้วยังไม่ถูกจัด (เช่น ถอดเสียงเติมต่อท้าย) จัดให้ตอนแสดง
  /// ไม่มีปุ่มจัดเอง: ทุกค่าที่เข้า (พิมพ์ · พูด · template · AI) ถูกจัดบรรทัดทันที
  void _hpiAutoPretty() {
    // กำลังพิมพ์อยู่: ยังไม่จัด (เคอร์เซอร์จะกระโดด) · จัดตอนออกจากช่อง
    if (_inlineFocus['$_speechStep|HPI']?.hasFocus ?? false) return;
    final v = _filled[_speechStep]['HPI'];
    if (v == null || v.isEmpty || _prettyHpi(v) == v) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = _filled[_speechStep]['HPI'];
      if (!mounted || now == null) return;
      final pretty = _prettyHpi(now);
      if (pretty != now) setState(() => _filled[_speechStep]['HPI'] = pretty);
    });
  }

  /// ปุ่ม "ดูประวัติ HPI" มุมขวาล่างของช่องกรอก → ไฮไลต์ส่วน HPI ในการ์ด CC แท็บภาพรวม
  Widget _hpiHistoryBtn() => _Press(
        child: GestureDetector(
          onTap: _showHpiHistory,
          child: Container(
            height: 32.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: _line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.history_rounded, size: 14.0, color: _inkTitle),
              const SizedBox(width: 6.0),
              Text('ดูประวัติ HPI',
                  style: _t(10.5, color: _inkTitle, weight: FontWeight.w500)),
            ]),
          ),
        ),
      );

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

  /// แถวเลือก template เหนือช่อง HPI: ป้าย "เทมเพลต · n รายการ" + ชิปเลื่อนแนวนอน
  /// (แนะนำตามเคสขึ้นก่อน) · แตะเพื่อวาง/แทนที่ · เล่าเองไว้แล้ว = AI จัดลง template
  Widget _hpiTemplateBar() {
    final sug = _hpiSuggest;
    final list = [
      ..._hpiTemplates.where((t) => t.$1 == sug),
      ..._hpiTemplates.where((t) => t.$1 != sug),
    ];
    return Row(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('เทมเพลต',
              style: _t(11.5, color: _inkTitle, weight: FontWeight.w600)),
          if (_hpiApplying)
            Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(
                  width: 9.0,
                  height: 9.0,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.4, color: _blue)),
              const SizedBox(width: 4.0),
              Text('กำลังจัด…', style: _t(9.0, color: _blue)),
            ])
          else
            Text('${list.length} รายการ', style: _t(9.0, color: _ink3)),
        ],
      ),
      const SizedBox(width: 10.0),
      // ชิปล้นออกถึงขอบขวาของแผง (เลยระยะขอบเนื้อหา 16) บอกว่าเลื่อนต่อได้
      Expanded(
        child: SizedBox(
          height: 32.0,
          child: LayoutBuilder(
            builder: (context, box) => OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: box.maxWidth + 16.0,
              maxWidth: box.maxWidth + 16.0,
              minHeight: 32.0,
              maxHeight: 32.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16.0),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6.0),
                itemBuilder: (_, i) => _hpiChip(list[i], list[i].$1 == sug),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  /// ชิป template หนึ่งตัว · แตะ = วาง/แทนที่
  /// กดค้าง = การ์ดตัวอย่างแบบเดียวกับ template ตรวจร่างกาย (_peekMove) · ลากไปชิปอื่นเพื่อเลื่อนดู
  Widget _hpiChip((String, String, String) t, bool rec) => _Press(
        child: Builder(builder: (chipCtx) {
          _tplRows[t.$2] = (chipCtx, t.$3);
          return GestureDetector(
            onLongPressStart: (d) {
              _peekTitle = t.$2;
              _peekMove(d.globalPosition);
            },
            onLongPressMoveUpdate: (d) => _peekMove(d.globalPosition),
            onLongPressEnd: (_) => _peekHide(),
            onLongPressCancel: _peekHide,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: _line),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (rec) ...[
                  const Icon(Icons.auto_awesome_rounded,
                      size: 11.0, color: _blue),
                  const SizedBox(width: 4.0),
                ],
                Text(t.$2,
                    style: _t(10.5, color: _inkTitle, weight: FontWeight.w600)),
              ]),
            ),
          );
        }),
      );

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
