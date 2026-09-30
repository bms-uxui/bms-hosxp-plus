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
        child: Container(
          decoration: BoxDecoration(
            gradient: _glossGrad(_blue),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(r)),
          ),
          foregroundDecoration: _InnerGloss(r, dark: true),
        ),
      ),
      // มาสคอต Dr.Note มุมซ้ายหัวการ์ด (ครึ่งล่างหลบหลังการ์ดช่องพิมพ์) + ข้อความสถานะ
      // ขยับตามเสียงพูด (speech to text) · ข้อความ = สถานะไมค์/ผู้ช่วย หรือคำที่ถอดได้ล่าสุด
      // ข้อความสถานะอยู่แถวเดียวกับแท็บ (ซ้ายของแท็บ) หัวการ์ดเลยเตี้ยได้
      Positioned(
        top: head - 46.0,
        left: 116.0,
        right: (templateTab ? 230.0 : 96.0) + (_recording ? 70.0 : 0.0),
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
      Positioned(
        top: -34.0,
        left: 6.0,
        width: 112.0,
        height: head + 30.0,
        child: _drNoteMascot(),
      ),
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
                                ? 'แตะเพื่อส่ง ${_recSec ~/ 60}:${(_recSec % 60).toString().padLeft(2, '0')}'
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
            mode: _recording
                ? ErDrNoteMode.write
                : _agentBusy
                    ? ErDrNoteMode.listen
                    : ErDrNoteMode.idle,
          ),
        ),
      );

  /// debugger หมุนท่า Dr.Note (debug build เท่านั้น): แตะมาสคอตค้างเพื่อเปิด/ปิด
  Widget _drPoseDebugger() {
    final p = _drPose ?? (-0.35, 0.42, 0.24, 1.1);
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
                          'rotation.set(${p.$1.toStringAsFixed(2)}, ${p.$2.toStringAsFixed(2)}, ${p.$3.toStringAsFixed(2)}) scale ${p.$4.toStringAsFixed(2)}'));
                  HapticFeedback.mediumImpact();
                },
                child: Text('คัดลอกค่า', style: _t(11.0, color: _blue))),
            TextButton(
                onPressed: () =>
                    setState(() => _drPose = (-0.35, 0.42, 0.24, 1.1)),
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
          // บรรทัดเดียว บอกสถานะเสียง → ข้อความ (ไม่มีบรรทัดรอง)
          // ฟังอยู่และถอดได้แล้ว = คำที่ได้ยินล่าสุด
          final text = _recording
              ? (heard.isEmpty ? 'กำลังฟัง พูดได้เลย' : heard)
              : _agentBusy
                  ? 'กำลังแปลงเสียงเป็นข้อความ…'
                  : 'กดเปิดไมค์เพื่อพูด';
          // ยังไม่ได้พูด: บรรทัดรองบอกว่า Dr. Note ช่วยอะไร
          final idle = !_recording && !_agentBusy;
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Row(
                key: ValueKey(text),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_recording) ...[
                    Container(
                      width: 7.0,
                      height: 7.0,
                      decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6.0),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(12.0,
                                color: Colors.white, weight: FontWeight.w700)),
                        if (idle)
                          Text('ให้ Dr. Note ช่วยบันทึกข้อมูล',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(10.5,
                                  color: Colors.white.withValues(alpha: 0.75))),
                      ],
                    ),
                  ),
                ],
              ),
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
    final picked = await showModalBottomSheet<(String, String, String)>(
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
              separatorBuilder: (_, __) =>
                  const Divider(height: 1.0, color: _line),
              itemBuilder: (_, i) => InkWell(
                onTap: () => Navigator.pop(ctx, list[i]),
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(list[i].$2,
                            style: _t(13.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        if (list[i].$1 == sug) ...[
                          const SizedBox(width: 8.0),
                          const Icon(Icons.auto_awesome_rounded,
                              size: 12.0, color: _blue),
                          const SizedBox(width: 3.0),
                          Text('เหมาะกับเคสนี้',
                              style: _t(10.0,
                                  color: _blue, weight: FontWeight.w600)),
                        ],
                      ]),
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
/// เข้าครั้งแรก: เลื่อนไล่ทุกหน้า (ให้รู้ว่ามีกี่หน้า) แล้วค่อยหยุดที่หน้าปัจจุบัน
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
    final n = widget.names.length;
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
    // ไล่ 0 → หน้าสุดท้าย (ค้างสั้น ๆ ทีละหน้า) แล้วกลับมาหยุดที่หน้าปัจจุบัน
    final items = <TweenSequenceItem<double>>[
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 3),
      for (var i = 0; i < n - 1; i++) ...[
        TweenSequenceItem(
            tween: Tween(begin: i.toDouble(), end: i + 1.0)
                .chain(CurveTween(curve: Curves.easeInOutCubic)),
            weight: 4),
        TweenSequenceItem(tween: ConstantTween(i + 1.0), weight: 3),
      ],
      if (widget.at != n - 1)
        TweenSequenceItem(
            tween: Tween(begin: n - 1.0, end: widget.at.toDouble())
                .chain(CurveTween(curve: Curves.easeInOutCubic)),
            weight: 6),
    ];
    _c.duration = Duration(milliseconds: 260 + 380 * n);
    // หย่อนป้ายลงก่อน แล้วค่อยไล่ทุกหน้า
    _hang.forward();
    _pos = n > 1
        ? TweenSequence(items).animate(_c)
        : AlwaysStoppedAnimation(widget.at.toDouble());
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _c.forward();
    });
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
            : Icon(
                // ครบแล้ว = ✓ · มีไอคอนประจำแถว = ไอคอนนั้น · ไม่มี = ธงที่หน้าสุดท้าย
                ok
                    ? Icons.check_rounded
                    : (widget.icons?[i] ?? (last ? Icons.flag_rounded : null)),
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
