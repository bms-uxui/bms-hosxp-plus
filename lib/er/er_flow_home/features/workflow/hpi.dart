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
        // พิมพ์เองแล้ว: คงบรรทัดตามที่พิมพ์ (ไม่ยุบ/ตัดบรรทัดใหม่)
        'HPI' => _hpiManual ? v : _prettyHpi(v),
        _icd10Label => _multiItems(v, icd: true).join('\n'),
        _ => v,
      };

  /// ค่าที่เข้ามาทางอื่นแล้วยังไม่ถูกจัด (เช่น ถอดเสียงเติมต่อท้าย) จัดให้ตอนแสดง
  /// ไม่มีปุ่มจัดเอง: ทุกค่าที่เข้า (พิมพ์ · พูด · template · AI) ถูกจัดบรรทัดทันที
  void _hpiAutoPretty() {
    // กำลังพิมพ์อยู่: ยังไม่จัด (เคอร์เซอร์จะกระโดด) · จัดตอนออกจากช่อง
    if (_inlineFocus['$_speechStep|HPI']?.hasFocus ?? false) return;
    // ผู้ใช้พิมพ์/แก้เองแล้ว: ไม่จัดบรรทัดทับ (เคารพการขึ้นบรรทัดใหม่ที่พิมพ์เอง)
    if (_hpiManual) return;
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

  /// template ที่เหมาะกับเคสนี้: AI (Gemma) เลือกจากข้อมูลเคสก่อน ยังไม่ได้ผล = ตามประเภทผู้ป่วย/อาการสำคัญ
  String get _hpiSuggest => _hpiAi[_caseP().hn]?.$1 ?? _hpiRuleSuggest;

  /// ให้ AI เลือก template HPI จากข้อมูลเคส (ครั้งเดียวต่อเคส)
  /// ผลแสดงเป็นการ์ดข้อเสนอในหน้าแรกของ HPI (ช่องยังว่าง) แพทย์กดใช้เอง
  void _hpiAiEnsure() {
    final hn = _caseP().hn;
    if (_hpiAi.containsKey(hn)) return;
    _hpiAi[hn] = null;
    final ids =
        [for (final t in _hpiTemplates) '- ${t.$1}: ${t.$2}'].join('\n');
    final sys =
        'คุณเป็นผู้ช่วยแพทย์ห้องฉุกเฉิน เลือก template HPI ที่เหมาะกับผู้ป่วยรายนี้ที่สุด 1 อัน '
        'จากรายการนี้เท่านั้น:\n$ids\n'
        'ตอบเป็น JSON {"id":"<id จากรายการ>","why":"เหตุผลสั้น ๆ ไม่เกิน 1 ประโยค อ้างข้อมูลที่ได้รับ"} '
        'ตอบภาษาไทย';
    () async {
      try {
        final out = await ErAi.chat([
          {'role': 'system', 'content': sys},
          {'role': 'user', 'content': _dxCaseText()},
        ], json: true, temperature: 0.1, maxTokens: 160);
        final j = ErAi.extractJson(out);
        final id = '${j?['id'] ?? ''}'.trim();
        final t = _hpiTemplates.where((x) => x.$1 == id).firstOrNull;
        if (t == null) throw 'id';
        if (!mounted) return;
        // แสดงเป็นข้อเสนอในหน้าแรกของ HPI (แพทย์กดใช้เอง ไม่วางอัตโนมัติ)
        setState(() => _hpiAi[hn] = (id, '${j?['why'] ?? ''}'));
        _dxTick.value++;
      } catch (_) {
        // ใช้ไม่ได้ = ใช้กติกาเดิม (ประเภทผู้ป่วย/อาการสำคัญ)
        if (mounted) {
          setState(() => _hpiAi[hn] = (_hpiRuleSuggest, ''));
          _dxTick.value++;
        }
      }
    }();
  }

  /// เลือก template ตามกติกา (ประเภทผู้ป่วย/อาการสำคัญ) ใช้ตอน AI ยังไม่ตอบหรือใช้ไม่ได้
  String get _hpiRuleSuggest {
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

  /// ใช้ template: ยังไม่ได้เล่า = วางข้อความ template · เล่าเองไว้แล้ว = AI จัดลง template
  void _hpiUseTemplate((String, String, String) t) {
    final cur = (_filled[_speechStep]['HPI'] ?? '').trim();
    if (_hpiManual && cur.isNotEmpty && !cur.contains('[')) {
      _hpiApplyTemplate(t);
      return;
    }
    setState(() {
      _hpiManual = false;
      _lastFilled = [(_speechStep, 'HPI', cur)];
      _filled[_speechStep]['HPI'] = _prettyHpi(t.$3);
    });
  }

  /// หน้า HPI (แบบการ์ด Diagnosis Text): หัวข้อ + คำอธิบาย · Dr.Note 3D มุมขวาบน
  /// แผ่นปุ่มลัด เพิ่ม/แก้ · เทมเพลต · ประวัติ HPI → ข้อความที่ลงแล้วแสดงใต้แผ่น
  /// เพิ่ม/แก้ = เข้าหน้าย่อย (breadcrumb + footer ยกเลิก | ไมค์ | บันทึก)
  Widget _hpiPage(String label) {
    if (_hpiEdit) return _hpiEditPage(label);
    final text = (_filled[_speechStep][label] ?? '').trim();
    Widget tileBtn(IconData icon, String t, VoidCallback onTap) => Expanded(
          child: _Press(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: const BoxDecoration(
                      color: _panel, shape: BoxShape.circle),
                  child: Icon(icon, size: 24.0, color: _blue),
                ),
                const SizedBox(height: 8.0),
                Text(t,
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
              ]),
            ),
          ),
        );
    void open() => setState(() {
          _hpiDraft = _filled[_speechStep][label] ?? '';
          _hpiEdit = true;
        });
    final by = _byMap(label)['HPI'];
    // แบบหน้าวินิจฉัย: การ์ด AI บนสุด (แพทย์กดเอง) · ผลแนะนำเปิดใน bottom sheet
    final ai = _aiAskCard(
      title: 'AI แนะนำเทมเพลต',
      sub: 'Dr.Note เลือกเทมเพลต HPI จากข้อมูลเคส',
      btn: 'แนะนำ',
      onTap: _hpiAiOpenSheet,
      compact: true,
      // สมุดเทมเพลตพลิกหน้า → ที่คั่น → เช็ก (วาดเอง ไม่ใช้ WebView)
      art: const _TemplateBookHero(),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: _wfFootH + 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ai,
        const SizedBox(height: 12.0),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          child: Stack(children: [
            // รูปประกอบ (Figma 431:96): แพทย์ซักประวัติผู้ป่วย พื้นโปร่ง ชิดมุมขวาบน
            // ขอบล่างจาง (แบบการ์ด Diagnosis Text)
            Positioned(
              right: 0.0,
              top: 0.0,
              width: 110.0,
              height: 110.0,
              child: _dxArtFade(Image.asset('assets/images/er_hpi_doctor.png',
                  fit: BoxFit.cover, filterQuality: FilterQuality.medium)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('ประวัติอาการปัจจุบัน',
                          style: _t(17.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 4.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 130.0),
                      child: Text('เล่าอาการตั้งแต่เริ่มจนมาถึงโรงพยาบาล',
                          style:
                              _t(12.5, color: _ink3, weight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(children: [
                        text.isEmpty
                            ? tileBtn(Icons.add_rounded, 'เพิ่ม', open)
                            : tileBtn(Icons.edit_outlined, 'แก้ไข', open),
                        tileBtn(Icons.post_add_rounded, 'เทมเพลต',
                            _hpiPickTemplate),
                        tileBtn(Icons.history_rounded, 'ประวัติ HPI',
                            _showHpiHistory),
                      ]),
                    ),
                    // ข้อความที่ลงแล้ว: แถวแบบรายการคำสั่งแพทย์ แตะ = แก้
                    if (text.isNotEmpty)
                      _gListRow(
                        first: true,
                        inset: 8.0,
                        title: text,
                        titleLines: 2,
                        sub: by == null
                            ? 'แตะเพื่อแก้'
                            : [
                                by,
                                if (_atMap(label)['HPI'] case final t?)
                                  _clock(t),
                              ].join('  '),
                        onTap: open,
                        trail: IconButton(
                          onPressed: open,
                          tooltip: 'แก้ HPI',
                          iconSize: 20.0,
                          constraints: const BoxConstraints(
                              minWidth: 40.0, minHeight: 40.0),
                          icon: const Icon(Icons.edit_outlined, color: _ink3),
                        ),
                      ),
                  ]),
            ),
          ]),
        ),
      ]),
    );
  }

  /// bottom sheet ข้อเสนอเทมเพลตจาก Dr.Note (แบบ AI ช่วยวินิจฉัย): ยังไม่เคยขอ = เริ่มคิดพร้อมเปิด
  /// กำลังคิด → เทมเพลตที่แนะนำ + เหตุผล + ตัวอย่างข้อความ · ใช้ / เลือกเทมเพลตอื่น
  Future<void> _hpiAiOpenSheet() async {
    // เปิดครั้งแรกของเคส: เล่นแอนิเมชันวิเคราะห์เสมอ (AI ตอบเร็วก็ยังเห็นการสแกนจนจบ)
    final hn0 = _caseP().hn;
    if (!_hpiRevealed.contains(hn0)) {
      _hpiScanned.add(hn0);
      _hpiScanAt = DateTime.now();
    }
    _hpiAiEnsure();
    final pick = await _placedSheet<String>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 640.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => ValueListenableBuilder<int>(
        valueListenable: _dxTick,
        builder: (_, __, ___) {
          final hn = _caseP().hn;
          final ai = _hpiAi[hn];
          final loading = ai == null;
          final t = _hpiTemplates.where((x) => x.$1 == _hpiSuggest).firstOrNull;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 20.0, color: _blue),
                      const SizedBox(width: 8.0),
                      Text('AI แนะนำเทมเพลต',
                          style: _t(18.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 16.0),
                    // กำลังคิด: แอนิเมชันสแกนข้อมูลเคสแบบ AI ช่วยวินิจฉัย → ได้ผลแล้วเล่นตอนจบก่อนแสดงผล
                    if (loading ||
                        t == null ||
                        (_hpiScanned.contains(hn) &&
                            !_hpiRevealed.contains(hn)))
                      () {
                        if (loading) {
                          _hpiScanned.add(hn);
                          _hpiRevealed.remove(hn);
                        }
                        return _DxAnalyzing(
                            items: _dxScanItems(),
                            groups: const [
                              'สัญญาณชีพ',
                              'อาการและประวัติ',
                              'ผลแล็บ'
                            ],
                            base: _t(12.5),
                            // สแกนอย่างน้อย 2.6 วิ แล้วค่อยเล่นตอนจบ (AI ตอบเร็วไม่วูบผ่าน)
                            done: !loading &&
                                () {
                                  final left =
                                      const Duration(milliseconds: 2600) -
                                          DateTime.now().difference(
                                              _hpiScanAt ?? DateTime(2000));
                                  if (left > Duration.zero) {
                                    Future.delayed(left, () => _dxTick.value++);
                                    return false;
                                  }
                                  return true;
                                }(),
                            onDone: () {
                              _hpiRevealed.add(hn);
                              _dxTick.value++;
                            });
                      }()
                    else ...[
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: const LinearGradient(colors: [
                            Color(0x1AFF9C78),
                            Color(0x1A3965E1),
                          ]),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.$2,
                                  style: _t(18.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              if (ai.$2.isNotEmpty) ...[
                                const SizedBox(height: 6.0),
                                Text(ai.$2,
                                    style: _t(14.0,
                                        color: _ink2,
                                        weight: FontWeight.w500,
                                        height: 1.45)),
                              ],
                              const SizedBox(height: 12.0),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: _panel,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(_prettyHpi(t.$3),
                                    style: _t(13.0,
                                        color: _ink2,
                                        weight: FontWeight.w500,
                                        height: 1.5)),
                              ),
                            ]),
                      ),
                      const SizedBox(height: 16.0),
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(ctx, t.$1),
                        style: FilledButton.styleFrom(
                          backgroundColor: _blue,
                          minimumSize: const Size(double.infinity, 48.0),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 20.0),
                        label: Text('ใช้เทมเพลตนี้',
                            style: _t(15.0,
                                color: Colors.white, weight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8.0),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, '*'),
                        style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44.0)),
                        child: Text('เลือกเทมเพลตอื่น',
                            style: _t(14.0,
                                color: _blue, weight: FontWeight.w600)),
                      ),
                    ],
                  ]),
            ),
          );
        },
      ),
    );
    if (pick == null || !mounted) return;
    if (pick == '*') {
      _hpiPickTemplate();
      return;
    }
    final t = _hpiTemplates.where((x) => x.$1 == pick).firstOrNull;
    if (t != null) _hpiUseTemplate(t);
  }

  /// หน้าย่อยเขียน/แก้ HPI: คำอธิบาย + ช่องพิมพ์ยาว (ไมค์อยู่ footer)
  Widget _hpiEditPage(String label) => ListView(
        key: const ValueKey('hpi-edit'),
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 96.0),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 4.0, 0.0, 12.0),
            child: Text(
                'พิมพ์ หรือแตะไมค์ด้านล่างแล้วเล่าอาการตั้งแต่เริ่มจนมาถึงโรงพยาบาล',
                style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: ErSpeechEditor(
              initial: _hpiDraft,
              hint:
                  'เช่น ผู้ป่วยหญิง 54 ปี ล้มศีรษะกระแทกพื้น 1 ชั่วโมงก่อนมา รพ.',
              onChanged: (v) => _hpiDraft = v,
              textStyle: _t(15.0, color: _inkTitle, weight: FontWeight.w500),
              accent: _blue,
              fill: _panelSoft,
              border: _line,
              // สูงตามข้อความ
              minLines: 1,
              maxLines: 18,
              showMic: false,
              onSpeech: (sp, on) {
                if (on) {
                  _dxSpeech.value = sp;
                } else if (_dxSpeech.value == sp) {
                  _dxSpeech.value = null;
                }
              },
            ),
          ),
        ],
      );

  /// หน้าย่อย HPI อยู่ (หัวแผง = breadcrumb · footer = ยกเลิก | ไมค์ | บันทึก)
  bool get _hpiNested => _hpiEdit && _isHpiStep(_speechStep) && _formAt == 0;

  void _hpiEditSave() {
    final t = _hpiDraft.trim();
    setState(() {
      if (t.isEmpty) {
        _filled[_speechStep].remove('HPI');
      } else {
        final changed = (_filled[_speechStep]['HPI'] ?? '').trim() != t;
        _filled[_speechStep]['HPI'] = t;
        _stampBy('HPI', ['HPI']);
        // ลง timeline ประวัติ HPI (แผงซ้าย): ใคร เมื่อไหร่
        if (changed) {
          final now = DateTime.now();
          _hpiLog.putIfAbsent(_caseP().hn, () => []).add((
            '${now.hour.toString().padLeft(2, '0')}:'
                '${now.minute.toString().padLeft(2, '0')}',
            ErSession.instance.user?.name ?? '-',
            t,
          ));
        }
      }
      _hpiEdit = false;
    });
  }

  Widget _hpiCrumb() => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 6.0, 16.0, 6.0),
        child: Row(children: [
          InkWell(
            onTap: () => setState(() => _hpiEdit = false),
            borderRadius: BorderRadius.circular(100.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('HPI',
                  style: _t(14.0, color: _blue, weight: FontWeight.w600)),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
          const SizedBox(width: 4.0),
          Flexible(
            child: Text(
                (_filled[_speechStep]['HPI'] ?? '').trim().isEmpty
                    ? 'เพิ่ม HPI'
                    : 'แก้ HPI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
        ]),
      );

  /// การ์ด HPI (Figma 220-412): หัวกรมท่า gloss มีแท็บ "เลือกเทมเพลต" + "ดูประวัติ" ชิดขวา
  /// ช่องพิมพ์สีขาวต่อจากหัว · หน้าตรวจร่างกายใช้การ์ดเดียวกัน (onTemplate/foot/onFoot แทนของ HPI)
  Widget _hpiShell(Widget field,
      {String? title,
      VoidCallback? onTemplate,
      String? foot,
      VoidCallback? onFoot,
      bool templateTab = true}) {
    const head = 54.0;
    // มุมการ์ดหลัก 14 ตาม design-rules (ช่องพิมพ์ด้านในใช้ 14 เท่ากัน)
    const r = 14.0;
    // แท็บบนหัว: solid = ขาวต่อกับช่องพิมพ์ · ไม่ solid = โปร่งบนพื้นกรมท่า
    Widget tab(IconData icon, String label, VoidCallback onTap,
        {bool solid = false}) {
      final fg = solid ? _blue : Colors.white;
      return _Press(
        child: Material(
          color: solid ? _panel : Colors.white.withValues(alpha: 0.14),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
          child: InkWell(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12.0)),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 16.0, color: fg),
                const SizedBox(width: 6.0),
                Text(label,
                    style: _t(11.0, color: fg, weight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: [
      // พื้นหัว navy แบบ gloss (สว่างบน เข้มล่าง) ซ้อนใต้การ์ดช่องพิมพ์
      Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        height: head + r * 2,
        // ไมค์ทำงาน = พื้น gradient AI ไหลวน (น้ำเงิน ม่วง ชมพู ฟ้า) · ปกติ = navy
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(r)),
          child: Stack(fit: StackFit.expand, children: [
            Container(
              decoration: BoxDecoration(gradient: _glossGrad(_blue)),
              foregroundDecoration: _InnerGloss(r, dark: true),
            ),
            AnimatedOpacity(
              opacity: _recording ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              child: _AiFlow(on: _recording),
            ),
          ]),
        ),
      ),
      // มาสคอต Dr.Note มุมซ้ายหัวการ์ด (ครึ่งล่างหลบหลังการ์ดช่องพิมพ์) + ข้อความสถานะ
      // ขยับตามเสียงพูด (speech to text) · ข้อความ = สถานะไมค์/ผู้ช่วย หรือคำที่ถอดได้ล่าสุด
      // ข้อความสถานะอยู่แถวเดียวกับแท็บ (ซ้ายของแท็บ) หัวการ์ดเลยเตี้ยได้
      Positioned(
        top: head - 46.0,
        left: 116.0,
        right: templateTab ? 230.0 : 96.0,
        height: 36.0,
        child: _drNoteSay(),
      ),
      Positioned(
        top: head,
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: field,
      ),
      // Dr.Note 3D ล้นขึ้นเหนือขอบบนการ์ด (top overflow) ปลายตัวอยู่ในแถบหัวพอดี
      Builder(builder: (context) {
        final b = _drBox ?? (-14.0, -17.0, 170.0, 84.0);
        return Positioned(
          left: b.$1,
          top: b.$2,
          width: b.$3,
          height: b.$4,
          child: _drNoteMascot(),
        );
      }),
      // ปุ่มเปิด debugger หมุนท่า (debug build เท่านั้น)
      if (kDebugMode)
        Positioned(
          top: 6.0,
          right: 12.0,
          child: GestureDetector(
            onTap: () => setState(() => _drPoseOpen = !_drPoseOpen),
            child: Container(
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.threed_rotation_rounded,
                  size: 14.0, color: Colors.white),
            ),
          ),
        ),
      if (_drPoseOpen)
        Positioned(
            top: head + 8.0, left: 8.0, right: 8.0, child: _drPoseDebugger()),
      // แท็บเลือกเทมเพลต (ต่อกับช่องพิมพ์ ทับขอบบน 1 px) ตามด้วยดูประวัติ
      Positioned(
        top: head - 32.0,
        right: 16.0,
        height: 33.0,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // หน้ากรอกข้อความยาว: ปุ่มเลือกเทมเพลตย้ายไปอยู่ขวาสุดของแถวหัวข้อในการ์ดแทน
          if (templateTab) ...[
            tab(Icons.post_add_rounded, 'เลือกเทมเพลต',
                onTemplate ?? _hpiPickTemplate,
                solid: true),
            const SizedBox(width: 6.0),
          ],
          // ไมค์อยู่บนหัวการ์ด (แทนตำแหน่งดูประวัติ) ใกล้ช่องที่กำลังกรอก
          // ดูประวัติย้ายไปแถวหัวข้อในการ์ด
          Padding(
            padding: const EdgeInsets.only(bottom: 1.0),
            child: ValueListenableBuilder<int>(
              valueListenable: _micFrame,
              builder: (context, _, __) => _Press(
                child: Material(
                  color:
                      _recording ? _red : Colors.white.withValues(alpha: 0.14),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: InkWell(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12.0)),
                    onTap: _micToggle,
                    // กดค้าง = พิมพ์สั่ง Dr.Note (พูดดังไม่ได้ข้างเตียง / เสียงรอบข้างดัง)
                    onLongPress: _typeToDrNote,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                            _recording ? Icons.stop_rounded : Icons.mic_rounded,
                            size: 16.0,
                            color: Colors.white),
                        const SizedBox(width: 6.0),
                        Text(
                            _recording
                                ? '${_recSec ~/ 60}:${(_recSec % 60).toString().padLeft(2, '0')}'
                                : 'พูด',
                            style: _num(11.0,
                                color: Colors.white, weight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  /// Dr.Note ขยับตามสถานะเสียง: ฟังอยู่ = เด้งตามความดังเสียง · คิด = เอียงไปมา
  /// ผู้ช่วยพูด = กระดึ๊บ · ว่าง = ลอยหายใจช้า ๆ (อัปเดตผ่าน _micFrame ไม่ rebuild ทั้งหน้า)
  Widget _drNoteMascot() => RepaintBoundary(
        // Dr.Note 3D: พูดอยู่ = ปากกาเขียนลงตัว · กำลังคิด = โน้มฟัง · ว่าง = ลอยหายใจ
        child: ValueListenableBuilder<int>(
          valueListenable: _micFrame,
          builder: (context, _, __) => ErDrNote3D(
            pose: _drPose,
            // เปิดไมค์/ถอดเสียง/ตีความ = ปากกา morph เป็น chat bubble 3D (ฟังอยู่)
            // ตีความเสร็จลงข้อมูลแล้ว (_stt 4) = bubble morph กลับเป็นปากกาแล้วเขียน · ว่าง = idle
            mode: _stt == 4
                ? ErDrNoteMode.write
                : (_recording || _agentBusy || _stt == 2 || _stt == 3)
                    ? ErDrNoteMode.think
                    : ErDrNoteMode.idle,
          ),
        ),
      );

  /// debugger หมุนท่า Dr.Note (debug build เท่านั้น): แตะมาสคอตค้างเพื่อเปิด/ปิด
  Widget _drPoseDebugger() {
    final p = _drPose ?? (-0.35, 0.42, 0.24, 0.9);
    // ค่าตั้งต้นกรอบ = ตำแหน่งใน _hpiShell (head 54)
    final b = _drBox ?? (-14.0, -17.0, 170.0, 84.0);
    Widget sl(String k, double v, double min, double max,
            (double, double, double, double) Function(double) set) =>
        Row(children: [
          SizedBox(
              width: 22.0,
              child: Text(k,
                  style: _t(11.0, color: _inkTitle, weight: FontWeight.w700))),
          Expanded(
            child: Slider(
                value: v.clamp(min, max),
                min: min,
                max: max,
                onChanged: (x) => setState(() => _drPose = set(x))),
          ),
          SizedBox(
              width: 44.0,
              child: Text(v.toStringAsFixed(2),
                  textAlign: TextAlign.right, style: _num(10.5, color: _ink2))),
        ]);
    Widget slBox(String k, double v, double min, double max,
            (double, double, double, double) Function(double) set) =>
        Row(children: [
          SizedBox(
              width: 22.0,
              child: Text(k,
                  style: _t(11.0, color: _blue, weight: FontWeight.w700))),
          Expanded(
            child: Slider(
                value: v.clamp(min, max),
                min: min,
                max: max,
                onChanged: (x) => setState(() => _drBox = set(x))),
          ),
          SizedBox(
              width: 44.0,
              child: Text(v.toStringAsFixed(0),
                  textAlign: TextAlign.right, style: _num(10.5, color: _ink2))),
        ]);
    return Material(
      elevation: 6.0,
      borderRadius: BorderRadius.circular(12.0),
      color: _panel,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text('Dr.Note pose (debug)',
                style: _t(12.0, color: _inkTitle, weight: FontWeight.w700)),
            const Spacer(),
            TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                      text:
                          'rotation.set(${p.$1.toStringAsFixed(2)}, ${p.$2.toStringAsFixed(2)}, ${p.$3.toStringAsFixed(2)}) scale ${p.$4.toStringAsFixed(2)} · box left ${b.$1.toStringAsFixed(0)} top ${b.$2.toStringAsFixed(0)} w ${b.$3.toStringAsFixed(0)} h ${b.$4.toStringAsFixed(0)}'));
                  HapticFeedback.mediumImpact();
                },
                child: Text('คัดลอกค่า', style: _t(11.0, color: _blue))),
            TextButton(
                onPressed: () => setState(() {
                      _drPose = (-0.35, 0.42, 0.24, 0.9);
                      _drBox = null;
                    }),
                child: Text('รีเซ็ต', style: _t(11.0, color: _ink2))),
            IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _drPoseOpen = false),
                icon: const Icon(Icons.close_rounded, size: 18.0)),
          ]),
          sl('X', p.$1, -3.14, 3.14, (x) => (x, p.$2, p.$3, p.$4)),
          sl('Y', p.$2, -3.14, 3.14, (x) => (p.$1, x, p.$3, p.$4)),
          sl('Z', p.$3, -3.14, 3.14, (x) => (p.$1, p.$2, x, p.$4)),
          sl('S', p.$4, 0.3, 2.0, (x) => (p.$1, p.$2, p.$3, x)),
          const Divider(height: 10.0),
          // ตำแหน่ง/ขนาดกรอบบนหัวการ์ด (px)
          slBox('L', b.$1, -40.0, 200.0, (x) => (x, b.$2, b.$3, b.$4)),
          slBox('T', b.$2, -80.0, 40.0, (x) => (b.$1, x, b.$3, b.$4)),
          slBox('W', b.$3, 50.0, 240.0, (x) => (b.$1, b.$2, x, b.$4)),
          slBox('H', b.$4, 40.0, 200.0, (x) => (b.$1, b.$2, b.$3, x)),
        ]),
      ),
    );
  }

  /// ข้อความข้าง Dr.Note: คำที่ถอดเสียงได้ล่าสุดตอนพูด หรือสถานะของผู้ช่วย
  Widget _drNoteSay() => ValueListenableBuilder<int>(
        valueListenable: _micFrame,
        builder: (context, _, __) {
          final heard = _capLive.isNotEmpty
              ? _capLive
              : (_capLines.isNotEmpty ? _capLines.last.text : '');
          final st = _stt;
          // กำลังทำงาน (ฟัง/ถอดเสียง/ตีความ) = แถบสถานะ 3 ขั้น + คำที่ได้ยิน
          final working = _recording || st == 2 || st == 3 || st == 4;
          if (!working) {
            final idleBusy = _agentBusy;
            return Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      idleBusy
                          ? 'กำลังแปลงเสียงเป็นข้อความ…'
                          : 'กดเปิดไมค์เพื่อพูด',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0,
                          color: Colors.white, weight: FontWeight.w700)),
                  if (!idleBusy)
                    Text('ให้ Dr. Note ช่วยบันทึกข้อมูล',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(10.5,
                            color: Colors.white.withValues(alpha: 0.75))),
                ],
              ),
            );
          }
          Widget step(int i, String label) {
            final active = switch (i) {
              1 => _recording,
              2 => st == 2,
              _ => st == 3,
            };
            final done = switch (i) {
              1 => !_recording && st >= 2,
              2 => st == 3 || st == 4,
              _ => st == 4,
            };
            return Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 12.0,
                height: 12.0,
                // แต่ละขั้นมีท่าของตัวเอง: ฟัง = คลื่นเสียง · ถอดเสียง = จุดพิมพ์ · ตีความ = ประกาย
                child: active
                    ? _StepAnim(kind: i)
                    : Icon(
                        done
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 12.0,
                        color: done
                            ? const Color(0xFF86EFAC)
                            : Colors.white.withValues(alpha: 0.55)),
              ),
              const SizedBox(width: 4.0),
              Text(label,
                  style: _t(10.5,
                      color: active || done
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                      weight: active ? FontWeight.w700 : FontWeight.w500)),
            ]);
          }

          Widget sep() => Container(
                width: 6.0,
                height: 1.2,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                color: Colors.white.withValues(alpha: 0.4),
              );
          final line = heard.isNotEmpty
              ? '“$heard”'
              : _recording
                  ? 'พูดได้เลย หยุดพูดแล้ว Dr.Note ตีความให้ทันที'
                  : st == 4
                      ? 'ลงข้อมูลแล้ว'
                      : '';
          return Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // พื้นที่แคบตอนมีปุ่ม "แตะเพื่อส่ง": ย่อทั้งแถวแทนการล้น
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    step(1, 'ฟัง'),
                    sep(),
                    step(2, 'ถอดเสียง'),
                    sep(),
                    step(3, 'ตีความ'),
                  ]),
                ),
                if (line.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  Text(line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(10.5,
                          color: Colors.white.withValues(alpha: 0.85),
                          weight: FontWeight.w500)),
                ],
              ],
            ),
          );
        },
      );

  /// พิมพ์ข้อความให้ Dr.Note ตีความลงช่องแทนการพูด (ทางเดียวกับคำพูดที่ถอดเสียงแล้ว)
  Future<void> _typeToDrNote() async {
    final ctl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
        title: Text('พิมพ์สั่ง Dr.Note',
            style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
        content: SizedBox(
          width: 460.0,
          child: TextField(
            controller: ctl,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            style: _t(13.5, color: _inkTitle),
            decoration: InputDecoration(
              hintText: 'เช่น ปอดมี wheeze ทั้งสองข้าง ที่เหลือปกติหมด',
              hintStyle: _t(13.5, color: _ink3),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: _line)),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ยกเลิก', style: _t(13.0, color: _ink2))),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _blue),
              onPressed: () => Navigator.pop(ctx, ctl.text.trim()),
              child: Text('ส่งให้ Dr.Note',
                  style:
                      _t(13.0, color: Colors.white, weight: FontWeight.w700))),
        ],
      ),
    );
    if (text == null || text.isEmpty || !mounted) return;
    final gen = ++_agentGen;
    setState(() {
      _utter[_speechStep].add(text);
      _logTurn(true, text);
      _agentBusy = true;
      _agentStatus = 'กำลังตีความ…';
    });
    await _agentTurn(text, gen);
    if (mounted) setState(() => _agentBusy = false);
  }

  /// เลือกเทมเพลต HPI: รายการพร้อมตัวอย่างข้อความ · เทมเพลตที่เหมาะกับเคสอยู่บนสุด
  Future<void> _hpiPickTemplate() async {
    final sug = _hpiSuggest;
    final list = [
      ..._hpiTemplates.where((t) => t.$1 == sug),
      ..._hpiTemplates.where((t) => t.$1 != sug),
    ];
    final picked = await _placedSheet<(String, String, String)>(
      context: context,
      // bottom sheet กว้างไม่เกิน 640 และอยู่กลางจอ
      constraints: const BoxConstraints(maxWidth: 640.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => SizedBox(
        height: MediaQuery.sizeOf(ctx).height * 0.7,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
            child: Row(children: [
              Expanded(
                child: Text('เลือกเทมเพลต HPI',
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              Text('${list.length} รายการ', style: _t(11.0, color: _ink3)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 16.0),
              itemCount: list.length,
              separatorBuilder: (_, i) =>
                  const Divider(height: 1.0, color: _line),
              // ข้อเสนอ Dr.Note อยู่หน้าแรกของ HPI แล้ว (รายการนี้เรียงที่แนะนำไว้บนสุด)
              itemBuilder: (_, i) => InkWell(
                onTap: () => Navigator.pop(ctx, list[i]),
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(list[i].$2,
                          style: _t(13.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                      const SizedBox(height: 4.0),
                      Text(list[i].$3,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _t(11.0, color: _ink2, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
    if (picked == null || !mounted) return;
    _hpiUseTemplate(picked);
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
            onTap: () => _hpiUseTemplate(t),
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

/// ป้ายบอกทางแบบใน รพ.: แผ่นป้ายบนเสา แต่ละแถว = หน้า (เลขวง + ชื่อหน้า)
/// เข้าครั้งแรก: แสดงหน้าปัจจุบันทันที (ไม่ไล่ทุกหน้า)
/// เปลี่ยนหน้า: เลื่อนไปหน้าใหม่ · หน้าที่ครบแล้ว = วงเขียว ✓
class _WaySign extends StatefulWidget {
  const _WaySign({
    super.key,
    required this.names,
    required this.done,
    required this.at,
    required this.busy,
    required this.style,
    required this.numStyle,
    this.rowH = 28.0,
    this.cable = 9.0,
    this.icons,
    this.iconPaths,
    this.tilt = 0.4,
    this.depth = 0.004,
  });

  final List<String> names;
  final List<bool> done;
  final int at;
  final bool busy;
  final TextStyle style;
  final TextStyle numStyle;

  /// ความสูงแผ่นป้าย / ความยาวสลิง (ป้ายใหญ่ใน hero ใช้ค่ามากขึ้น)
  final double rowH;
  final double cable;

  /// ไอคอนประจำแต่ละแถว (ขวามือในป้าย) · null = เฉพาะ ✓/ธง
  final List<IconData>? icons;

  /// ไอคอน Phosphor (path) ต่อแถว ใช้แทน icons ถ้ามี (null ในแถว = ใช้ icons)
  final List<List<(String, bool, bool)>?>? iconPaths;

  /// มุมเอียงป้าย (หมุนแกน Y) + ความลึก perspective · ป้ายกว้างใช้ค่าน้อยลงไม่ให้หดมาก
  final double tilt;
  final double depth;

  @override
  State<_WaySign> createState() => _WaySignState();
}

class _WaySignState extends State<_WaySign> with TickerProviderStateMixin {
  double get _rowH => widget.rowH;
  late final AnimationController _c = AnimationController(vsync: this);

  /// ป้ายหย่อนลงจากเพดาน (ครั้งแรก) / แกว่งเบา ๆ ตอนเปลี่ยนหน้า
  late final AnimationController _hang = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));
  bool _dropIn = true;

  /// แสงวิ่งผ่านป้ายเป็นระยะ: วิ่ง 1.4 วิ แล้วพัก 2.4 วิ (ช่วงพัก controller หยุด ไม่วาดเฟรม)
  late final AnimationController _shine = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..addStatusListener((st) {
      if (st == AnimationStatus.completed) {
        _shineGap = Timer(const Duration(milliseconds: 2400), () {
          if (mounted) _shine.forward(from: 0.0);
        });
      }
    })
    ..forward();
  Timer? _shineGap;
  late Animation<double> _pos;

  /// หน้าล่าสุดที่ป้ายของแต่ละขั้นหยุดอยู่ (ไล่ครบทุกหน้าเฉพาะครั้งแรกของขั้น)
  static final Map<Key?, int> _last = {};

  @override
  void initState() {
    super.initState();
    final prev = _last[widget.key];
    _last[widget.key] = widget.at;
    if (prev != null) {
      // เคยเห็นแล้ว: เลื่อนจากหน้าเดิมไปหน้าปัจจุบันอย่างเดียว
      _pos = Tween(begin: prev.toDouble(), end: widget.at.toDouble())
          .chain(CurveTween(curve: Curves.easeInOutCubic))
          .animate(_c);
      _c
        ..duration = const Duration(milliseconds: 420)
        ..forward();
      _dropIn = false;
      _hang.forward();
      return;
    }
    // ครั้งแรก: แสดงชื่อหน้าปัจจุบันเลย (ไม่ไล่ทุกหน้า) · ป้ายยังหย่อนลงจากเพดาน
    _pos = AlwaysStoppedAnimation(widget.at.toDouble());
    _hang.forward();
  }

  @override
  void didUpdateWidget(_WaySign old) {
    super.didUpdateWidget(old);
    if (old.at != widget.at) {
      _last[widget.key] = widget.at;
      final from = _pos.value;
      _pos = Tween(begin: from, end: widget.at.toDouble())
          .chain(CurveTween(curve: Curves.easeInOutCubic))
          .animate(_c);
      _c
        ..duration = const Duration(milliseconds: 420)
        ..forward(from: 0.0);
      _dropIn = false;
      _hang.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _hang.dispose();
    _shineGap?.cancel();
    _shine.dispose();
    super.dispose();
  }

  Widget _row(int i) {
    final ok = widget.done[i] && i != widget.at;
    final last = i == widget.names.length - 1;
    return SizedBox(
      height: _rowH,
      child: Row(children: [
        Expanded(
          child: Text(widget.names[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: widget.style),
        ),
        SizedBox(width: _rowH * 0.2),
        // ลูกศรบอกทางไปหน้าถัดไป · ครบแล้ว = ✓ · หน้าสุดท้าย = ธงเส้นชัย
        widget.busy && i == widget.at
            ? SizedBox(
                width: 12.0,
                height: 12.0,
                child: CircularProgressIndicator(
                    strokeWidth: 1.4, color: widget.style.color))
            : (!ok && widget.iconPaths?[i] != null)
                // ไอคอน Phosphor (Fill) ชุดเดียวกับรางขั้น
                ? _SolarIcon('',
                    size: _rowH * 0.55,
                    color: widget.style.color ?? Colors.white,
                    paths: widget.iconPaths![i])
                : Icon(
                    // ครบแล้ว = ✓ · มีไอคอนประจำแถว = ไอคอนนั้น · ไม่มี = ธงที่หน้าสุดท้าย
                    ok
                        ? Icons.check_rounded
                        : (widget.icons?[i] ??
                            (last ? Icons.flag_rounded : null)),
                    size: _rowH * 0.55,
                    color: ok ? const Color(0xFF5DC46E) : widget.style.color),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.names.length;
    final cable = widget.cable;
    // แยกชั้นวาดทั้งป้าย: ป้ายแกว่ง/แสงวิ่ง ไม่ทำให้การ์ดรอบ ๆ วาดใหม่
    return RepaintBoundary(
        child: Tooltip(
      message: [
        for (var i = 0; i < n; i++)
          '${i + 1}. ${widget.names[i]}${widget.done[i] ? ' ✓' : ''}'
      ].join('\n'),
      // หย่อนลง (เด้งนิดที่ปลาย) + แกว่งแบบลูกตุ้มหน่วงรอบจุดแขวนด้านบน
      child: AnimatedBuilder(
        animation: _hang,
        builder: (context, child) {
          final t = _hang.value;
          final dy = _dropIn
              ? -(1.0 -
                      Curves.easeOutBack.transform((t / 0.5).clamp(0.0, 1.0))) *
                  (cable + _rowH + 4.0)
              : 0.0;
          final amp = _dropIn ? 0.05 : 0.03;
          final sw = _dropIn ? ((t - 0.3) / 0.7).clamp(0.0, 1.0) : t;
          final angle = math.sin(sw * math.pi * 3.0) * amp * (1.0 - sw);
          return Transform.translate(
            offset: Offset(0.0, dy),
            child: Transform.rotate(
                angle: angle, alignment: Alignment.topCenter, child: child),
          );
        },
        child: Stack(children: [
          // แผ่นป้ายทรงลูกศรชี้ขวา (แบบป้ายบอกทาง) เอียงมุมมอง 3D นิด ๆ
          // พื้นเงินปัด + ขอบขาวด้านใน + แสงวิ่งผ่าน (shimmer) เป็นระยะ
          Positioned(
            left: 0.0,
            right: 0.0,
            top: cable + 1.0,
            height: _rowH,
            child: Transform(
              alignment: Alignment.center,
              // เอียงแบบป้ายบอกทาง: หมุนรอบแกนตั้ง (perspective จริง) ปลายซ้ายใกล้ตา
              // ขอบบน-ล่างลู่เข้าหาปลายลูกศรเท่า ๆ กัน (ไม่ใช้ skew ซ้อน ภาพจะบิดเพี้ยน)
              transform: Matrix4.identity()
                ..setEntry(3, 2, widget.depth)
                ..rotateY(-widget.tilt),
              // สลิงอยู่ใน layer เดียวกับแผ่นป้าย: เอียง/หย่อน/แกว่งไปพร้อมกัน ติดขอบป้ายพอดี
              // (ยาวเกินขึ้นไปด้านบน ส่วนที่เกินถูกตัดที่ขอบการ์ด)
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // เสาแขวนสแตนเลส 2 ต้น (ไล่เงินซ้าย-ขวาให้ดูกลม) + ปลอกยึดที่ปลายเสา
                    for (final f in const [0.2, 0.68])
                      Positioned(
                        left: f * box.maxWidth - 3.0,
                        top: -(cable + 80.0),
                        width: 6.0,
                        height: cable + 81.0,
                        child: Column(children: [
                          Expanded(
                            child: Container(
                              width: 3.2,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Color(0xFF9AA2AD),
                                  Color(0xFFE9ECF0),
                                  Color(0xFF8A929D),
                                ]),
                              ),
                            ),
                          ),
                          Container(
                            width: 6.0,
                            height: 4.0,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF8A929D),
                                Color(0xFFE3E6EA),
                                Color(0xFF7D8591),
                              ]),
                              borderRadius: BorderRadius.circular(1.0),
                            ),
                          ),
                        ]),
                      ),
                    // แผ่นป้ายทรงลูกศรชี้ขวา สีหลัก + ขอบขาวด้านใน
                    Positioned.fill(
                      child: ClipPath(
                        clipper: _ArrowSignClip(),
                        child: Stack(children: [
                          const Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  // สีหลัก (navy) ไล่อ่อน-เข้มเบา ๆ ให้ดูเป็นแผ่นโลหะพ่นสี
                                  colors: [_blue2, _blue, _blue],
                                  stops: [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // ขอบขาวด้านใน ตามทรงลูกศร
                          Positioned.fill(
                              child: CustomPaint(painter: _ArrowSignBorder())),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                _rowH * 0.34, 0.0, _rowH * 0.6, 0.0),
                            child: ClipRect(
                              child: AnimatedBuilder(
                                animation: _c,
                                // สร้างเฉพาะแถวที่โผล่ในกรอบ (ห่างหน้าปัจจุบัน < 1 แถว)
                                builder: (context, _) => Stack(children: [
                                  for (var i = 0; i < n; i++)
                                    if ((i - _pos.value).abs() < 1.0)
                                      Positioned(
                                        left: 0.0,
                                        right: 0.0,
                                        top: (i - _pos.value) * _rowH,
                                        height: _rowH,
                                        child: Opacity(
                                          opacity:
                                              (1.0 - (i - _pos.value).abs())
                                                  .clamp(0.0, 1.0),
                                          child: _row(i),
                                        ),
                                      ),
                                ]),
                              ),
                            ),
                          ),
                          // shimmer: แถบแสงเฉียงวิ่งซ้าย → ขวา แล้วพักก่อนวิ่งรอบใหม่
                          // แยกชั้นวาด: แสงขยับแล้วพื้น/ตัวหนังสือไม่ต้องวาดใหม่
                          Positioned.fill(
                            child: IgnorePointer(
                              child: RepaintBoundary(
                                  child: AnimatedBuilder(
                                animation: _shine,
                                builder: (context, _) {
                                  final t = _shine.value;
                                  if (t <= 0.0 || t >= 1.0) {
                                    return const SizedBox.shrink();
                                  }
                                  final x = -1.6 +
                                      3.2 * Curves.easeInOut.transform(t);
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(x - 0.5, -1.0),
                                        end: Alignment(x + 0.5, 1.0),
                                        colors: [
                                          Colors.white.withValues(alpha: 0.0),
                                          Colors.white.withValues(alpha: 0.35),
                                          Colors.white.withValues(alpha: 0.0),
                                        ],
                                        stops: const [0.3, 0.5, 0.7],
                                      ),
                                    ),
                                  );
                                },
                              )),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    ));
  }
}

/// ทรงป้ายลูกศรชี้ขวา: มุมซ้ายมนเล็ก ปลายขวาแหลม
class _ArrowSignClip extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => _arrowSignPath(s, 0.0);

  @override
  bool shouldReclip(_ArrowSignClip old) => false;
}

Path _arrowSignPath(Size s, double inset) {
  final tip = s.height * 0.5;
  const r = 3.0;
  final l = inset, t = inset, b = s.height - inset, w = s.width - inset;
  return Path()
    ..moveTo(l + r, t)
    ..lineTo(w - tip, t)
    ..lineTo(w - inset * 0.4, s.height / 2)
    ..lineTo(w - tip, b)
    ..lineTo(l + r, b)
    ..quadraticBezierTo(l, b, l, b - r)
    ..lineTo(l, t + r)
    ..quadraticBezierTo(l, t, l + r, t)
    ..close();
}

/// ขอบขาวด้านในของป้าย (แบบป้ายจราจร)
class _ArrowSignBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
        _arrowSignPath(size, 2.2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.85));
  }

  @override
  bool shouldRepaint(_ArrowSignBorder old) => false;
}

/// พื้นหลังแบบ AI: blob สีนุ่ม ๆ ลอยวนช้า ๆ บนพื้นน้ำเงินเข้ม (ทำงานเฉพาะตอน on)
class _AiFlow extends StatefulWidget {
  const _AiFlow({required this.on});

  final bool on;

  @override
  State<_AiFlow> createState() => _AiFlowState();
}

class _AiFlowState extends State<_AiFlow> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8));

  @override
  void initState() {
    super.initState();
    if (widget.on) _c.repeat();
  }

  @override
  void didUpdateWidget(_AiFlow old) {
    super.didUpdateWidget(old);
    if (widget.on && !_c.isAnimating) _c.repeat();
    // ปิดไมค์: ปล่อยให้จางออกก่อนค่อยหยุด (ไม่ค้างเฟรม)
    if (!widget.on && _c.isAnimating) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !widget.on) _c.stop();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(painter: _AiFlowPainter(_c)),
      );
}

class _AiFlowPainter extends CustomPainter {
  _AiFlowPainter(this.anim) : super(repaint: anim);

  final Animation<double> anim;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = anim.value;
    // พื้น: gradient ทแยงหมุนช้า ๆ ไล่ indigo → violet → fuchsia → sky แล้ววนกลับ
    canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            colors: const [
              Color(0xFF3730A3),
              Color(0xFF6D28D9),
              Color(0xFFB21DC8),
              Color(0xFF2563EB),
              Color(0xFF3730A3),
            ],
            stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
            transform: GradientRotation(t * 2 * math.pi),
          ).createShader(Rect.fromCenter(
              center: rect.center,
              width: size.width * 1.4,
              height: size.width * 1.4)));
    // แสงนุ่มด้านบน + เงาล่าง ให้มีมิติเหมือนกระจก
    canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x33FFFFFF), Color(0x00FFFFFF), Color(0x26000000)],
            stops: [0.0, 0.5, 1.0],
          ).createShader(rect));
    // แถบประกายวิ่งผ่านเฉียง ๆ ทุกรอบ
    final x = (t * 1.6 % 1.0) * (size.width * 1.6) - size.width * 0.3;
    canvas.save();
    canvas.clipRect(rect);
    canvas.translate(x, 0);
    canvas.skew(-0.35, 0);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, 60, size.height),
        Paint()
          ..shader = const LinearGradient(colors: [
            Color(0x00FFFFFF),
            Color(0x2EFFFFFF),
            Color(0x00FFFFFF),
          ]).createShader(Rect.fromLTWH(0, 0, 60, size.height)));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AiFlowPainter old) => false;
}

/// ท่าของขั้นที่กำลังทำ (12×12): 1 ฟัง = แท่งคลื่นเสียงเด้ง · 2 ถอดเสียง = จุดสามจุดไล่เด้ง
/// · 3 ตีความ = ประกายสี่แฉกหมุนกะพริบ
class _StepAnim extends StatefulWidget {
  const _StepAnim({required this.kind});

  final int kind;

  @override
  State<_StepAnim> createState() => _StepAnimState();
}

class _StepAnimState extends State<_StepAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
      painter: _StepAnimPainter(_c, widget.kind), size: const Size(12, 12));
}

class _StepAnimPainter extends CustomPainter {
  _StepAnimPainter(this.anim, this.kind) : super(repaint: anim);

  final Animation<double> anim;
  final int kind;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    final p = Paint()..color = Colors.white;
    final w = size.width, h = size.height;
    switch (kind) {
      case 1:
        // คลื่นเสียง: 3 แท่งสูงต่ำไม่พร้อมกัน สีแดงอ่อน (ไมค์ติด)
        p.color = const Color(0xFFFF8A8A);
        for (var i = 0; i < 3; i++) {
          final v =
              0.35 + 0.65 * (0.5 + 0.5 * math.sin((t + i * 0.3) * 2 * math.pi));
          final bh = h * v;
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(i * w / 3 + 1, (h - bh) / 2, w / 3 - 2, bh),
                  const Radius.circular(1.2)),
              p);
        }
      case 2:
        // ถอดเสียง: จุดสามจุดเด้งไล่กันแบบกำลังพิมพ์
        for (var i = 0; i < 3; i++) {
          final ph = ((t - i * 0.18) % 1.0);
          final up = ph < 0.4 ? math.sin(ph / 0.4 * math.pi) : 0.0;
          canvas.drawCircle(Offset(2 + i * 4.0, h * 0.62 - up * 4.0), 1.5, p);
        }
      default:
        // ตีความ: ประกายสี่แฉกหมุน + ขยายหดเบา ๆ
        final c = Offset(w / 2, h / 2);
        final sc = 0.75 + 0.25 * math.sin(t * 2 * math.pi);
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(t * math.pi);
        canvas.scale(sc);
        final r = w / 2, k = w * 0.12;
        final path = Path()
          ..moveTo(0, -r)
          ..quadraticBezierTo(k, -k, r, 0)
          ..quadraticBezierTo(k, k, 0, r)
          ..quadraticBezierTo(-k, k, -r, 0)
          ..quadraticBezierTo(-k, -k, 0, -r)
          ..close();
        p.color = const Color(0xFFFDE68A);
        canvas.drawPath(path, p);
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_StepAnimPainter old) => old.kind != kind;
}

/// การ์ด AI แบบ stacked card: แถบหัวไล่สีที่ไหลช้า ๆ + แผ่นขาวทับ (มุมโค้งเผยสีแถบ)
/// เด้งขึ้น (scale + fade) ตอนเปิด · mascot ลอยมุมซ้ายบนเหนือแถบ
class _AiCardFx extends StatefulWidget {
  const _AiCardFx(
      {required this.band, required this.mascot, required this.child});
  final Widget band;

  /// mascot รับ callback โหลดเสร็จ: เริ่มโผล่จากใต้การ์ดเมื่อเห็นตัวจริงแล้ว
  final Widget Function(VoidCallback ready) mascot;
  final Widget child;

  @override
  State<_AiCardFx> createState() => _AiCardFxState();
}

class _AiCardFxState extends State<_AiCardFx> with TickerProviderStateMixin {
  late final AnimationController _flow =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat();
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520))
    ..forward();
  // Dr.Note โผล่จากใต้แผ่นขาว หลังการ์ดเด้งเสร็จ
  late final AnimationController _in2 = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  late final Widget _mascot = widget.mascot(() {
    if (mounted) _in2.forward();
  });

  @override
  void dispose() {
    _flow.dispose();
    _in.dispose();
    _in2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rise = CurvedAnimation(parent: _in, curve: Curves.easeOutBack);
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
            blurRadius: 18.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // ชั้นการ์ด: พื้นไล่สี → Dr.Note → แถบหัว + แผ่นขาว (แผ่นขาวทับตัว Dr.Note)
      // Dr.Note จึงโผล่ขึ้นมาจากหลังขอบแผ่นขาวจริง ไม่ใช่ตัดเป็นเส้นตรง
      child: Stack(clipBehavior: Clip.none, children: [
        // พื้นไล่สีไหล (ตัดมุมโค้งเฉพาะพื้น ตัว Dr.Note ยื่นพ้นขอบบนได้)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _flow,
                builder: (context, _) {
                  final x = -1.0 + 2.0 * _flow.value;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(x - 1.0, -1.0),
                        end: Alignment(x + 1.0, 1.0),
                        tileMode: TileMode.mirror,
                        colors: const [
                          Color(0xFF4F46E5),
                          Color(0xFF7C3AED),
                          Color(0xFFC026D3),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Dr.Note 3D: เริ่มซ่อนอยู่หลังแผ่นขาว แล้วลอยขึ้นจนยื่นพ้นขอบบนการ์ด
        // จากนั้นใน WebView หมุนตัวและหลอดไฟติด (ErDrNoteMode.idea)
        Positioned(
          left: 0.0,
          top: -40.0,
          width: 150.0,
          height: 84.0,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _in2,
              builder: (context, child) {
                final k = _in2.value;
                // ยังไม่เริ่ม = อยู่ต่ำสุด ซ่อนหลังแผ่นขาวทั้งตัว (ห้ามใช้ Opacity 0
                // กับ WebView: ไม่ถูกวาด ขนาดเป็น 0 แล้วโมเดลไม่ขึ้น)
                return Transform.translate(
                  offset: Offset(
                      0.0, 92.0 * (1.0 - Curves.easeOutCubic.transform(k))),
                  child: child,
                );
              },
              child: _mascot,
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 11.0, 12.0, 11.0),
            child: widget.band,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 16.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: widget.child,
          ),
        ]),
      ]),
    );
    return FadeTransition(
      opacity: CurvedAnimation(parent: _in, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: 0.94, end: 1.0).animate(rise),
        child: card,
      ),
    );
  }
}

/// ประกายในป้าย AI: ขยาย/หดและหมุนเล็กน้อยเป็นจังหวะ
class _AiTwinkle extends StatefulWidget {
  const _AiTwinkle({required this.size});
  final double size;

  @override
  State<_AiTwinkle> createState() => _AiTwinkleState();
}

class _AiTwinkleState extends State<_AiTwinkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final k = 0.5 + 0.5 * math.sin(_c.value * 6.2832);
          return Transform.rotate(
            angle: 0.25 * (k - 0.5),
            child: Transform.scale(scale: 0.85 + 0.25 * k, child: child),
          );
        },
        child: Icon(Icons.auto_awesome_rounded,
            size: widget.size, color: Colors.white),
      );
}

/// ปรากฏช้ากว่าการ์ด: เลื่อนขึ้นเล็กน้อย + จางเข้า
class _AiReveal extends StatelessWidget {
  const _AiReveal({required this.child, this.delayMs = 0});
  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 420 + delayMs),
        curve: Interval(delayMs / (420 + delayMs), 1.0,
            curve: Curves.easeOutCubic),
        builder: (context, k, child) => Opacity(
          opacity: k,
          child: Transform.translate(
              offset: Offset(0.0, 8.0 * (1.0 - k)), child: child),
        ),
        child: child,
      );
}

/// ภาพเคลื่อนไหวการ์ด "AI แนะนำเทมเพลต" (สไตล์เดียวกับแว่นขยายของวินิจฉัย)
/// เรื่องเล่า 1 รอบ: สมุดเทมเพลตเปิดอยู่ → พลิกหน้าเร็ว ๆ (ไอคอนเทมเพลตจาง ๆ ต่างกันทุกหน้า)
/// → หยุดที่หน้าที่ใช่ (ไอคอนชัด) → ที่คั่นสีส้มเด้งลง → เช็กเขียวเด้ง + ประกาย → เก็บกลับ (วนต่อเนื่อง)
class _TemplateBookHero extends StatefulWidget {
  const _TemplateBookHero();

  @override
  State<_TemplateBookHero> createState() => _TemplateBookHeroState();
}

class _TemplateBookHeroState extends State<_TemplateBookHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
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
          builder: (context, _) => CustomPaint(
              painter: _TemplateBookArt(_c.value), size: Size.infinite),
        ),
      );
}

class _TemplateBookArt extends CustomPainter {
  const _TemplateBookArt(this.t);

  /// 0..1 หนึ่งรอบ (6 วิ)
  final double t;

  /// ไอคอนเทมเพลตของแต่ละหน้า (สี) · หน้าสุดท้าย = เทมเพลตที่เลือก
  static const _tones = [
    Color(0xFFE5484D), // อุบัติเหตุ
    Color(0xFFEC6A9C), // เจ็บหน้าอก
    Color(0xFF3B82F6), // หอบเหนื่อย
    Color(0xFFF5A524), // ปวดท้อง
    Color(0xFF3965E1), // ที่เลือก
  ];

  static double _ph(double tt, double a, double b,
          [Curve c = Curves.easeInOutCubic]) =>
      c.transform(((tt - a) / (b - a)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w * 0.5, cy = h * 0.55;
    final pw = w * 0.36, phh = h * 0.5;
    final top = cy - phh / 2, bot = cy + phh / 2;

    // จังหวะ: พลิก 4 หน้า (0.08–0.5 เร่งแล้วช้าลง) → เจอ → ที่คั่น → เช็ก → ค้าง → เก็บ
    const flips = 4;
    final flipT = _ph(t, 0.08, 0.5, Curves.easeOutCubic) * flips;
    final done = flipT.floor().clamp(0, flips);
    final frac = done >= flips ? 0.0 : flipT - done;
    final found = _ph(t, 0.5, 0.58, Curves.easeOutBack);
    final mark = _ph(t, 0.54, 0.66, Curves.easeOutBack);
    final check = _ph(t, 0.62, 0.74, Curves.elasticOut);
    final out = _ph(t, 0.88, 1.0);
    final markK = (mark - out).clamp(0.0, 1.0);
    final checkK = (check - out).clamp(0.0, 1.2);

    // เงาพื้น
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, bot + h * 0.06),
            width: w * 0.82,
            height: h * 0.08),
        Paint()..color = const Color(0x220B1B3F));

    // ปก (กรมท่า) ใหญ่กว่าหน้ากระดาษนิดหนึ่ง
    final cover = RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - pw - w * 0.04, top - h * 0.02, cx + pw + w * 0.04,
            bot + h * 0.05),
        Radius.circular(w * 0.06));
    canvas.drawRRect(cover, Paint()..color = const Color(0xFF233A8B));

    // หน้ากระดาษซ้าย/ขวา: ขอบบนโค้งขึ้นใกล้สันเล็กน้อย
    Path page(bool left) {
      final x0 = cx, x1 = left ? cx - pw : cx + pw;
      return Path()
        ..moveTo(x0, top + h * 0.02)
        ..quadraticBezierTo((x0 + x1) / 2, top - h * 0.03, x1, top)
        ..lineTo(x1, bot)
        ..quadraticBezierTo((x0 + x1) / 2, bot - h * 0.02, x0, bot)
        ..close();
    }

    final paper = Paint()..color = Colors.white;
    final shade = Paint()..color = const Color(0xFFE8ECF4);
    canvas.drawPath(page(true), paper);
    canvas.drawPath(page(false), paper);
    // เงาสันกลาง
    canvas.drawRect(
        Rect.fromLTRB(cx - w * 0.02, top + h * 0.02, cx + w * 0.02, bot),
        shade);

    // เส้นข้อความหน้าซ้าย
    final line = Paint()
      ..color = const Color(0xFFCBD2E0)
      ..strokeWidth = math.max(1.0, h * 0.025)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final y = top + phh * (0.25 + i * 0.18);
      canvas.drawLine(Offset(cx - pw * 0.8, y),
          Offset(cx - pw * (i == 3 ? 0.45 : 0.18), y), line);
    }

    // หน้าขวา: ไอคอนเทมเพลตของหน้าปัจจุบัน + เส้นข้อความ
    void rightContent(Canvas c, Color tone, double strong) {
      final ic = Offset(cx + pw * 0.5, top + phh * 0.36);
      final r = w * (0.08 + 0.025 * strong);
      c.drawCircle(
          ic, r, Paint()..color = tone.withValues(alpha: 0.25 + 0.75 * strong));
      final plus = Paint()
        ..color = Colors.white
        ..strokeWidth = math.max(1.0, r * 0.35)
        ..strokeCap = StrokeCap.round;
      c.drawLine(ic - Offset(r * 0.45, 0), ic + Offset(r * 0.45, 0), plus);
      c.drawLine(ic - Offset(0, r * 0.45), ic + Offset(0, r * 0.45), plus);
      for (var i = 0; i < 2; i++) {
        final y = top + phh * (0.68 + i * 0.16);
        c.drawLine(Offset(cx + pw * 0.2, y),
            Offset(cx + pw * (i == 1 ? 0.55 : 0.8), y), line);
      }
    }

    // หน้าที่เห็นทางขวา = หน้าถัดจากที่พลิกไปแล้ว
    final cur = done.clamp(0, _tones.length - 1);
    rightContent(canvas, _tones[cur], done >= flips ? found : 0.0);

    // หน้าที่กำลังพลิก: หมุนรอบสัน (กว้างตาม cos) ยกขอบบนตาม sin
    if (frac > 0.0 && done < flips) {
      final a = frac * math.pi;
      final cw = math.cos(a) * pw;
      final lift = math.sin(a) * h * 0.06;
      final x1 = cx + cw;
      final p = Path()
        ..moveTo(cx, top + h * 0.02)
        ..quadraticBezierTo(
            (cx + x1) / 2, top - h * 0.03 - lift, x1, top - lift)
        ..lineTo(x1, bot - lift * 0.5)
        ..quadraticBezierTo((cx + x1) / 2, bot - h * 0.02, cx, bot)
        ..close();
      // ด้านหน้า (ยังไม่เลยสัน) ขาว · ด้านหลัง (เลยสันไปซ้าย) เทาอ่อน
      canvas.drawPath(
          p,
          Paint()
            ..color = Color.lerp(
                Colors.white, const Color(0xFFDDE3EE), math.sin(a) * 0.6)!);
      canvas.drawPath(
          p,
          Paint()
            ..color = const Color(0x22000000)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.6);
    }

    // ที่คั่นสีส้ม: เด้งลงจากขอบบนหน้าขวา (หางตัด V)
    if (markK > 0.0) {
      final bx = cx + pw * 0.78, bw = w * 0.08;
      final len = h * 0.26 * markK;
      final rib = Path()
        ..moveTo(bx - bw / 2, top - h * 0.04)
        ..lineTo(bx + bw / 2, top - h * 0.04)
        ..lineTo(bx + bw / 2, top + len)
        ..lineTo(bx, top + len - bw * 0.5)
        ..lineTo(bx - bw / 2, top + len)
        ..close();
      canvas.drawPath(rib, Paint()..color = const Color(0xFFFF7A59));
    }

    // เช็กเขียว (payoff) มุมขวาล่าง + ประกาย
    if (checkK > 0.0) {
      final o = Offset(cx + pw * 0.95, bot - h * 0.02);
      final r = w * 0.14 * checkK;
      canvas.drawCircle(o, r + w * 0.02, Paint()..color = Colors.white);
      canvas.drawCircle(o, r, Paint()..color = const Color(0xFF22A06B));
      final tick = Path()
        ..moveTo(o.dx - r * 0.45, o.dy)
        ..lineTo(o.dx - r * 0.1, o.dy + r * 0.35)
        ..lineTo(o.dx + r * 0.5, o.dy - r * 0.35);
      canvas.drawPath(
          tick,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.2, r * 0.28)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
      // ประกาย 2 ดวง กระพริบหลังเช็กเด้ง
      final sp = _ph(t, 0.66, 0.8) * (1 - out);
      void star(Offset c, double s) {
        final q = Path()
          ..moveTo(c.dx, c.dy - s)
          ..quadraticBezierTo(c.dx, c.dy, c.dx + s, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s)
          ..quadraticBezierTo(c.dx, c.dy, c.dx - s, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s)
          ..close();
        canvas.drawPath(
            q, Paint()..color = const Color(0xFFF5A524).withValues(alpha: sp));
      }

      if (sp > 0) {
        star(Offset(cx - pw * 0.9, top - h * 0.02), w * 0.07 * sp);
        star(Offset(cx + pw * 0.25, top - h * 0.1), w * 0.05 * sp);
      }
    }
  }

  @override
  bool shouldRepaint(_TemplateBookArt old) => old.t != t;
}
