// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ความสูงคงที่ของการ์ดช่องกรอกใน flipbook
const double _flipH = 128.0;

/// บล็อกที่แสดงอยู่ตอนนี้: ของผู้ช่วย (รอบล่าสุดของขั้นนี้) + บล็อกตั้งต้น
/// ฟอร์มกับหน้าสรุปยืนยันใช้ของขั้นเสมอ (ผู้ช่วยส่งมาแทนไม่ได้)
/// การ์ดของระบบที่ผู้ช่วยแทนไม่ได้ (เลือก template · สรุปความเร่งด่วน)
bool _pinnedBlock(ErUiBlock b) =>
    b.data['order_pick'] == true ||
    b.data['esi_ai'] == true ||
    b.data['hpi_pick'] == true ||
    b.data['pe_pick'] == true;

/// ลำดับการนำเสนอการ์ด: ภาพรวม → อันตราย → ข้อมูลประกอบ → สิ่งที่ต้องทำ → ไปต่อ
const Map<ErUiType, int> _uiOrder = {
  ErUiType.brief: 0,
  ErUiType.alert: 1,
  ErUiType.timer: 2,
  ErUiType.vitals: 3,
  ErUiType.labs: 4,
  ErUiType.imaging: 5,
  ErUiType.checklist: 6,
  ErUiType.form: 7,
  ErUiType.orderSet: 8,
  ErUiType.nextStep: 9,
};

/// แผงผู้ช่วยข้างวงล้อ: ข้อความ → ลำดับสิ่งที่ชี้ → คำอธิบาย หรือการ์ดที่ต้องลงมือทำ
/// หน้าตาเดียวกับแผงในหน้า (ขาว ขอบบาง มุม 14) ไม่ใช่การ์ดชนิดใหม่
/// แถบผู้ช่วยแถบเดียวติดล่างจอ: ทำทีละเรื่อง
/// ซ้าย = ขั้น + คำถามของผู้ช่วย · กลาง = ช่องที่ต้องกรอกตอนนี้ช่องเดียว
/// ขวา = เปลี่ยนหน้า + ไมค์ (กดค้างพูด) + ปิด · สูงคงที่ ไม่บังหน้าจอส่วนบน
const double _barH = 176.0;

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesWorkflowWorkflowPanelState on State<ErFlowHomeWidget> {
  /// รุ่นของหน้าผู้ช่วย (เปลี่ยนแล้วการ์ดสลับใหม่)
  int _agentUiGen = 0;
  final Set<int> _speechDone = {};

  /// ช่องข้อความที่ผู้ช่วยเพิ่งแก้: ข้อความเดิม + รุ่น (แสดง diff แบบพิมพ์ทีละตัว)
  final Map<String, (String, int)> _diffs = {};

  // ---------------------------------------------- โหมดพูดเพื่อบันทึก
  // ตามแบบ 186:68 — แถบโค้งครึ่งวงกลมด้านล่าง ไมค์ใหญ่ตรงกลาง
  // ขั้นตอนเรียงเป็นวงกลมบนแถบโค้ง (แบบอ้างอิง: มาตรวัดที่ติ๊กขั้นที่ผ่านแล้ว)
  // เขียวมีเครื่องหมายถูก = ทำแล้ว · ขอบน้ำเงิน = ขั้นปัจจุบัน · ขาว = ยังไม่ถึง

  /// HN ของคนไข้ที่ข้อมูลการพูดปัจจุบันเป็นของ
  String? _speechHn;

  final ScrollController _stepperScroll = ScrollController();
}

extension _FeaturesWorkflowWorkflowPanelPart on _ErFlowHomeWidgetState {
  void _openSpeech({int step = 0}) {
    if (_speechHn != _caseP().hn) {
      _resetSpeechCase();
      _speechHn = _caseP().hn;
    }
    final wasOpen = _speechOpen && _wfReady;
    setState(() {
      _speechOpen = true;
      _wfShown = true;
      _speechStep = step;
      _summaryOpen = false;
    });
    // แผงยังไม่กาง: รอกางเสร็จ (560 ms) ค่อยใส่เนื้อหา + ให้ผู้ช่วยทักทาย
    // ไม่แย่งเฟรม animation · หน้าที่ไม่ใช่ภาพรวม (ไม่มีแผงกาง) ทักทายเลย
    if (wasOpen || !_clyOn) {
      _agentGreet();
    } else {
      Future.delayed(const Duration(milliseconds: 580), _wfMakeReady);
    }
  }

  /// ใส่เนื้อหาจริงของแผง workflow + ทักทาย (เรียกซ้ำได้ ทำครั้งเดียว)
  void _wfMakeReady() {
    if (!mounted || !_speechOpen || _wfReady) return;
    setState(() => _wfReady = true);
    _agentGreet();
  }

  void _confirmStep() {
    _skipAsked = -1;
    _uiIdx = 0;
    _formAt = 0;
    _orderPick.clear();
    _uiTicks.clear();
    _stopRecord(send: false);
    _robot.stop();
    setState(() {
      _speechDone.add(_speechStep);
      if (_speechStep < _steps.length - 1) _speechStep += 1;
    });
    _agentGreet();
  }

  void _closeSpeech() {
    _agentGen++;
    _robot.stop();
    _stopRecord(send: false);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _speechOpen = false;
      _orderEditing = null;
      _agentBusy = false;
      _agentStatus = '';
      _agentChoices = null;
    });
  }

  /// หน้าสรุปก่อนบันทึก: ทุกช่องของขั้นพร้อมค่า แตะแถวเพื่อกลับไปแก้ช่องนั้น
  /// ครบแล้วจึงกดยืนยันได้ ยังไม่ครบปุ่มจะพาไปช่องแรกที่ขาด
  Widget _reviewCard(ErUiBlock b) {
    final labels = _stepLabels(_speechStep);
    final known = _filled[_speechStep];
    final missing = [
      for (final l in labels)
        if (!_fieldDone(_speechStep, l)) l
    ];
    final seq = _uiSeq;
    final formIdx = seq.indexWhere((x) => x.type == ErUiType.form);
    void editAt(String l) {
      if (formIdx < 0) return;
      final i = _formFields(seq[formIdx]).indexOf(l);
      setState(() {
        _formFwd = false;
        _uiIdx = formIdx;
        _formAt = i < 0 ? 0 : i;
      });
    }

    final done = missing.isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Icon(done ? Icons.fact_check_rounded : Icons.pending_actions_rounded,
              size: 18.0, color: done ? _blue : _blue),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text('สรุปก่อนบันทึก · ${_steps[_speechStep].$2}',
                style: _t(13.5, color: _inkTitle, weight: FontWeight.w700)),
          ),
          Text(
              done ? 'ครบ ${labels.length} ช่อง' : 'ขาด ${missing.length} ช่อง',
              style: _t(10.5,
                  color: done ? _blue : _blue, weight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8.0),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: _line),
            ),
            child: SingleChildScrollView(
              child: Column(children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0) const Divider(height: 1.0, color: _line),
                  InkWell(
                    onTap: () => editAt(labels[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140.0,
                              child: Text(labels[i],
                                  style: _t(11.0,
                                      color: _ink2, weight: FontWeight.w600)),
                            ),
                            Expanded(
                              child: Text(
                                  _needsDetail(_speechStep, labels[i])
                                      ? 'ผิดปกติ · ต้องระบุรายละเอียด'
                                      : [
                                          known[labels[i]] ?? 'ยังไม่ได้กรอก',
                                          if ((known['${labels[i]} - รายละเอียด'] ??
                                                  '')
                                              .isNotEmpty)
                                            known['${labels[i]} - รายละเอียด']!,
                                        ].join(' · '),
                                  style: _t(11.5,
                                      color: _fieldDone(_speechStep, labels[i])
                                          ? _inkTitle
                                          : _blue,
                                      weight: FontWeight.w600)),
                            ),
                            const Icon(Icons.edit_rounded,
                                size: 13.0, color: _g5),
                          ]),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formFlip(
      ErUiBlock b, List<String> fields, Map<String, String> items) {
    final known = _filled[_speechStep];
    final n = fields.length;
    final at = _formAt.clamp(0, n - 1);
    void go(int d) => _formGo(d, n);

    final f = fields[at];
    final tall = _flipFill;
    // ช่องพิมพ์อิสระ (ไม่มีตัวเลือก/หน่วย) ยืดเต็มความสูงได้ · ช่องตัวเลือกเลื่อนภายใน
    final free = f != _destLabel &&
        _fieldOptions(f, items[f]!).isEmpty &&
        _fieldUnit(items[f]!).isEmpty &&
        _fieldGroups(f).length <= 1;
    final front = Container(
      key: ValueKey('flip_${_speechStep}_$f'),
      // สูงเท่ากันทุกช่อง ไม่ว่าจะเป็นช่องพิมพ์หรือตัวเลือกหลายแถว
      height: tall ?? _flipH,
      // ไม่มีการ์ดครอบ: ชื่อช่อง + ช่องกรอกวางบนพื้นแผงตรง ๆ
      padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
      // ช่องที่ผู้ช่วยเพิ่งลง/แก้: พื้นฟ้าจาง ๆ ชั่วครู่ (AI glow)
      color: _glow.contains(f) ? _blue.withValues(alpha: 0.06) : _panel,
      // แถวเดียว: ซ้ายชื่อช่อง ขวาช่องกรอก · แผงกาง: ชื่อบน ช่องกรอกเต็มความสูง
      child: tall != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Text(f,
                      style:
                          _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
                  if (_termOf(f) case final sub?) ...[
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(10.5, color: _ink3)),
                    ),
                  ] else
                    const Spacer(),
                  if (_fieldDone(_speechStep, f))
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 13.0, color: _blue),
                      const SizedBox(width: 3.0),
                      Text('บันทึกแล้ว',
                          style:
                              _t(10.0, color: _blue, weight: FontWeight.w600)),
                    ]),
                ]),
                const SizedBox(height: 10.0),
                Expanded(
                  child: _fieldWithExtras(
                      f,
                      _guideFieldCard(f, items[f]!, known[f], true,
                          big: true,
                          fill: free,
                          onPick: () => Future.delayed(
                                  const Duration(milliseconds: 380), () {
                                if (_isPeStep(_speechStep) &&
                                    _filled[_speechStep][f] == 'ผิดปกติ') {
                                  return;
                                }
                                if (mounted && _formAt == at) go(1);
                              })),
                      fill: true,
                      scroll: !free),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(f,
                          style: _t(13.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      if (_termOf(f) case final sub?)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(sub,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _t(10.0, color: _ink3, height: 1.3)),
                        ),
                      if (_fieldDone(_speechStep, f))
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 12.0, color: _blue),
                            const SizedBox(width: 3.0),
                            Text('บันทึกแล้ว',
                                style: _t(9.5,
                                    color: _blue, weight: FontWeight.w600)),
                          ]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                // ช่องกรอกตัวจริง (ขนาดใหญ่) ใช้ร่วมกับโหมด checklist
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: _fieldWithExtras(
                          f,
                          _guideFieldCard(f, items[f]!, known[f], true,
                              big: true,
                              onPick: () => Future.delayed(
                                      const Duration(milliseconds: 380), () {
                                    // ผิดปกติ = รอกรอกรายละเอียดก่อน ไม่พลิกหน้าเอง
                                    if (_isPeStep(_speechStep) &&
                                        _filled[_speechStep][f] == 'ผิดปกติ')
                                      return;
                                    if (mounted && _formAt == at) go(1);
                                  }))),
                    ),
                  ),
                ),
              ],
            ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -200) go(1);
            if (v > 200) go(-1);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // แอนิเมชันเปลี่ยนหน้าทำที่ชั้นนอก (_clyGuideBody) ที่นี่ไม่ซ้อนอีกชั้น
              AnimatedSwitcher(
                duration: Duration.zero,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (cur, prev) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...prev, if (cur != null) cur]),
                transitionBuilder: (child, anim) {
                  final incoming = child.key == front.key;
                  final sign = (_formFwd ? 1.0 : -1.0) * (incoming ? 1 : -1);
                  return AnimatedBuilder(
                    animation: anim,
                    child: child,
                    builder: (_, ch) => Opacity(
                      opacity: anim.value.clamp(0.0, 1.0),
                      child: Transform(
                        alignment: _formFwd
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(sign * (1 - anim.value) * math.pi / 2.2),
                        child: ch,
                      ),
                    ),
                  );
                },
                child: front,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  /// สีและไอคอนตามความหมายของตัวเลือก (ปกติ = เขียว ผิดปกติ = แดง ไม่ได้ตรวจ = เทา)
  (Color, IconData?) _choiceTone(String o) => switch (o) {
        'ปกติ' || 'ไม่มี' || 'สวม' || 'คาด' || 'ไม่ดื่ม' || 'ไม่ใช้' => (
            _blue,
            Icons.check_circle_rounded
          ),
        'ผิดปกติ' || 'มี' => (_red, Icons.error_rounded),
        'ไม่ได้ตรวจ' || 'ไม่ทราบ' || 'ข้าม' => (
            _ink3,
            Icons.remove_circle_rounded
          ),
        _ => (_blue, null),
      };

  /// ปุ่มตัวเลือกใหญ่ เต็มช่อง สูง 44 (เป้ากดใหญ่ ใช้มือเดียวได้)
  Widget _bigChoice(String o, bool on, VoidCallback onTap,
      {double height = 44.0, bool left = false}) {
    final (col, icon) = _choiceTone(o);
    return _Press(
        child: Material(
      color: on ? col : _panel,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          height: height,
          alignment: left ? Alignment.centerLeft : Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: on ? col : col.withValues(alpha: 0.35), width: 1.5),
          ),
          padding: EdgeInsets.symmetric(horizontal: left ? 12.0 : 6.0),
          // ย่อทั้งปุ่มลงเมื่อแคบ ไม่ตัดคำ ("ไม่ได้ตรวจ" ต้องอ่านครบ)
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 15.0, color: on ? Colors.white : col),
                const SizedBox(width: 4.0),
              ],
              Text(o,
                  maxLines: 1,
                  style: _t(12.5,
                      color: on ? Colors.white : col, weight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    ));
  }

  /// ชิปตัวเลือก: size = ขนาดตัวอักษรกำหนดเอง (ใช้ในช่องย่อยที่พื้นที่แคบ)
  Widget _optChip(String o, bool on, bool big, VoidCallback onTap,
          {double? size}) =>
      _Press(
          child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          padding: big
              ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0)
              : EdgeInsets.symmetric(
                  horizontal: size == null ? 8.0 : 10.0,
                  vertical: size == null ? 3.0 : 4.0),
          decoration: BoxDecoration(
            color: on ? _blue : _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(color: on ? _blue : _line),
          ),
          child: Text(o,
              style: _t(size ?? (big ? 11.5 : 9.0),
                  color: on ? Colors.white : _ink2,
                  weight: on ? FontWeight.w700 : FontWeight.w500)),
        ),
      ));

  /// เลือกจากรายการ master ยาว ๆ (ICD-10 ยา Lab ตึก ...) มีช่องค้นหา
  /// เลือกช่องทั้งช่องจากรายการยาว แล้วบันทึกลงฟอร์ม
  Future<void> _pickFromList(String label, List<String> opts,
      {VoidCallback? onPick}) async {
    final picked =
        await _listSheet(label, opts, current: _filled[_speechStep][label]);
    if (picked == null || !mounted) return;
    setState(() {
      _lastFilled = [(_speechStep, label, _filled[_speechStep][label])];
      _filled[_speechStep][label] = picked;
      if (label == _procLabel) _autoIcd9();
      _allergyWarn = _allergyConflict();
    });
    onPick?.call();
  }

  Future<String?> _listSheet(String label, List<String> opts,
      {String? current}) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) {
        var q = '';
        return StatefulBuilder(builder: (ctx, set) {
          final list = [
            for (final o in opts)
              if (q.isEmpty || o.toLowerCase().contains(q.toLowerCase())) o
          ];
          return SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.7,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                child: Row(children: [
                  Expanded(
                    child: Text(label,
                        style: _t(15.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ),
                  Text('${opts.length} รายการ', style: _t(11.0, color: _ink3)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  onChanged: (v) => set(() => q = v.trim()),
                  style: _t(13.0),
                  decoration: InputDecoration(
                    hintText: 'ค้นหา',
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
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 16.0),
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1.0, color: _line),
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: Text(list[i], style: _t(12.5, color: _ink)),
                    trailing: current == list[i]
                        ? const Icon(Icons.check_rounded, color: _blue)
                        : null,
                    onTap: () => Navigator.pop(ctx, list[i]),
                  ),
                ),
              ),
            ]),
          );
        });
      },
    );
    return picked;
  }

  Widget _guideFieldCard(String label, String hint, String? value, bool done,
      {bool big = false, bool fill = false, VoidCallback? onPick}) {
    final opts = _fieldOptions(label, hint);
    final unit = _fieldUnit(hint);
    // ตัวเลือกที่ตรงกับค่า: ตรงทั้งคำก่อน แล้วค่อยคำที่อยู่ในค่า (ยาวสุดชนะ)
    String? sel;
    if (value != null && opts.isNotEmpty) {
      sel = opts.contains(value)
          ? value
          : (opts.where((o) => value.contains(o)).toList()
                ..sort((a, b) => b.length.compareTo(a.length)))
              .firstOrNull;
    }
    Widget field;
    final groups = _fieldGroups(label);
    if (groups.length > 1) {
      // หลายช่องย่อย: ค่ารวมเป็น "ตัวเลือก · ตัวเลือก" ตามลำดับกลุ่ม
      String? pickOf(List<String> o) {
        if (value == null) return null;
        final hit = o.where((x) => value.contains(x)).toList()
          ..sort((a, b) => b.length.compareTo(a.length));
        return hit.firstOrNull;
      }

      // ค่าเก็บตามตำแหน่งกลุ่ม "a · b" (กลุ่มที่ยังไม่เลือก = "-")
      // กลุ่มที่ตัวเลือกซ้ำกัน (รูม่านตาซ้าย/ขวา) จึงแยกกันได้
      final parts = value?.split(' · ');
      final cur = [
        for (var gi = 0; gi < groups.length; gi++)
          parts != null && parts.length == groups.length
              ? (groups[gi].$2.contains(parts[gi]) ? parts[gi] : null)
              : pickOf(groups[gi].$2)
      ];
      void setGroup(int gi, String o) {
        final next = [...cur]..[gi] = o;
        setState(() {
          _lastFilled = [(_speechStep, label, value)];
          _filled[_speechStep][label] = next.map((x) => x ?? '-').join(' · ');
        });
        // ครบทุกกลุ่มแล้วค่อยพลิกไปช่องถัดไป
        if (next.every((x) => x != null)) onPick?.call();
      }

      // ช่องย่อยละก้อน: ชื่อเล็กด้านบน · ตัวเลือกไม่เกิน 4 เป็นชิป มากกว่านั้นเป็นปุ่มเลือกจากรายการ
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var gi = 0; gi < groups.length; gi++)
            Padding(
              padding: EdgeInsets.only(top: gi == 0 ? 0 : (big ? 8.0 : 5.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(groups[gi].$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(big ? 9.5 : 8.5,
                          color: _ink3, weight: FontWeight.w600)),
                  const SizedBox(height: 3.0),
                  groups[gi].$2.length <= 4
                      ? Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: [
                            for (final o in groups[gi].$2)
                              _optChip(
                                  o, o == cur[gi], false, () => setGroup(gi, o),
                                  size: big ? 11.0 : 9.0),
                          ],
                        )
                      : InkWell(
                          onTap: () async {
                            final o = await _listSheet(
                                groups[gi].$1, groups[gi].$2,
                                current: cur[gi]);
                            if (o != null && mounted) setGroup(gi, o);
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 7.0),
                            decoration: BoxDecoration(
                              color: _panelSoft,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                  color: cur[gi] != null
                                      ? _blue.withValues(alpha: 0.5)
                                      : _line),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: Text(cur[gi] ?? 'เลือก…',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(big ? 12.0 : 9.5,
                                        color:
                                            cur[gi] != null ? _inkTitle : _ink3,
                                        weight: cur[gi] != null
                                            ? FontWeight.w600
                                            : FontWeight.w400)),
                              ),
                              const Icon(Icons.expand_more_rounded,
                                  size: 16.0, color: _ink3),
                            ]),
                          ),
                        ),
                ],
              ),
            ),
        ],
      );
    } else if (big && label.contains('วันที่') && label.contains('เวลา')) {
      // วันที่-เวลา: ปุ่ม "ตอนนี้" + date time picker
      field = _dateTimeField(label, value, onPick);
    } else if (big && label == _dispLabel && opts.isNotEmpty) {
      // สภาพผู้ป่วยออกจาก ER: การ์ดเลือกในหน้าเลย (ไม่เปิดรายการซ้อน)
      field = _dispCards(opts, sel, (o) {
        setState(() {
          _lastFilled = [(_speechStep, label, value)];
          _filled[_speechStep][label] = o;
        });
        onPick?.call();
      });
    } else if (big && opts.length >= 2 && opts.length <= 4) {
      // ตัวเลือกน้อย (ปกติ/ผิดปกติ/ไม่ได้ตรวจ, มี/ไม่มี ...): ปุ่มใหญ่กว้างเท่ากัน กดง่าย
      void pick(String o) {
        setState(() {
          _lastFilled = [(_speechStep, label, value)];
          _filled[_speechStep][label] = o;
        });
        // ผิดปกติ: บังคับระบุรายละเอียดทันที
        if (_needsDetail(_speechStep, label)) {
          _editField('$label - รายละเอียด',
              title: '$label ผิดปกติ · ระบุรายละเอียด');
          return;
        }
        onPick?.call();
      }

      // ตัวเลือกยาว (เช่น ข้อบ่งชี้กรณีฉุกเฉิน): เรียงคนละบรรทัด อ่านครบ ไม่ย่อ
      final stacked = opts.any((o) => o.length > 10);
      field = stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < opts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 5.0),
                  _bigChoice(opts[i], opts[i] == sel, () => pick(opts[i]),
                      height: 34.0, left: true),
                ],
              ],
            )
          : Row(children: [
              for (var i = 0; i < opts.length; i++) ...[
                if (i > 0) const SizedBox(width: 6.0),
                Expanded(
                    child: _bigChoice(
                        opts[i], opts[i] == sel, () => pick(opts[i]))),
              ],
            ]);
    } else if (opts.isNotEmpty && opts.length <= 8) {
      field = Wrap(
        spacing: big ? 7.0 : 4.0,
        runSpacing: big ? 7.0 : 4.0,
        children: [
          for (final o in opts)
            InkWell(
              onTap: () {
                setState(() {
                  _lastFilled = [(_speechStep, label, value)];
                  _filled[_speechStep][label] = o;
                });
                onPick?.call();
              },
              borderRadius: BorderRadius.circular(100.0),
              child: Container(
                padding: big
                    ? const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 7.0)
                    : const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: o == sel ? _blue : _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: o == sel ? _blue : _line),
                ),
                child: Text(o,
                    style: _t(big ? 12.5 : 9.0,
                        color: o == sel ? Colors.white : _ink2,
                        weight: o == sel ? FontWeight.w700 : FontWeight.w500)),
              ),
            ),
        ],
      );
    } else {
      // ช่องพิมพ์ (หรือ dropdown ที่ตัวเลือกยาว แสดงเป็นช่องเลือก)
      final dropdown = opts.length > 8;
      field = InkWell(
        onTap: () => dropdown
            ? _pickFromList(label, opts, onPick: onPick)
            : _editField(label),
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          height: fill && unit.isEmpty && !dropdown ? double.infinity : null,
          alignment: fill ? Alignment.topLeft : null,
          padding: big
              ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0)
              : const EdgeInsets.symmetric(horizontal: 9.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(big ? 12.0 : 8.0),
            border: Border.all(
                color: value != null ? _blue.withValues(alpha: 0.5) : _line),
          ),
          child: Row(children: [
            Expanded(
              child: value != null && unit.isEmpty && _diffs[label] != null
                  // ผู้ช่วยเพิ่งแก้: พิมพ์ส่วนที่เพิ่มทีละตัว (เขียว) ขีดฆ่าส่วนที่แก้ ส่วนที่ลบเป็นแดง
                  ? _TextDiff(
                      key: ValueKey('diff_${label}_${_diffs[label]!.$2}'),
                      before: _diffs[label]!.$1,
                      after: value,
                      style: _t(big ? 13.5 : 10.0,
                          color: _inkTitle, weight: FontWeight.w600),
                      onDone: () {
                        if (mounted) setState(() => _diffs.remove(label));
                      },
                    )
                  : Text(
                      value ??
                          (hint.isEmpty
                              ? (dropdown ? 'เลือก…' : 'พิมพ์หรือพูด…')
                              : hint),
                      maxLines:
                          unit.isEmpty ? (fill ? null : (big ? 8 : 3)) : 1,
                      overflow: fill ? null : TextOverflow.ellipsis,
                      style: unit.isEmpty
                          ? _t(big ? 13.5 : 10.0,
                              color: value != null ? _inkTitle : _ink3,
                              weight: value != null
                                  ? FontWeight.w600
                                  : FontWeight.w400)
                          : _num(big ? 20.0 : 12.0,
                              color: value != null ? _inkTitle : _ink3,
                              weight: FontWeight.w700)),
            ),
            if (unit.isNotEmpty)
              Text(unit, style: _t(big ? 12.0 : 9.0, color: _ink3)),
            if (dropdown)
              const Icon(Icons.expand_more_rounded, size: 15.0, color: _ink3),
          ]),
        ),
      );
    }
    // flipbook มีหัวการ์ดของตัวเอง ใช้เฉพาะช่องกรอก
    if (big) return field;
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.fromLTRB(9.0, 7.0, 9.0, 8.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
            color: _lastFilled.any((f) => f.$2 == label)
                ? _blue
                : (done ? _line : _blue.withValues(alpha: 0.35))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(label,
                  style: _t(9.5, color: _ink2, weight: FontWeight.w700)),
            ),
            Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 13.0,
                color: done ? _blue : _g5),
          ]),
          const SizedBox(height: 5.0),
          field,
        ],
      ),
    );
  }

  // ================================================ Generative UI ของผู้ช่วย
  // ผู้ช่วยตอบเป็นบล็อก UI (er_genui.dart) วาดในแผงขวาระหว่างโหมดพูด
  // แพทย์เห็นข้อมูลที่ต้องใช้ + ลงมือได้ในที่เดียว ไม่ต้องสลับแท็บ
  // แต่ละขั้นมีบล็อกตั้งต้น (_guideUi) เสมอ ผู้ช่วยเสริม/แทนที่ได้ตามบทสนทนา

  /// บล็อกตั้งต้นของขั้น: พาแพทย์ไปตามเส้นทางเคสแม้ผู้ช่วยยังไม่ตอบ UI มา
  List<ErUiBlock> _guideUi(int step) {
    final c = _case;
    final p = _caseP();
    final out = <ErUiBlock>[];
    ErUiBlock b(String type, Map<String, dynamic> d) => erParseUi([
          {'type': type, ...d}
        ]).map((x) => ErUiBlock(x.type, x.data, source: 'guide')).first;
    final allergy = c.allergies.isEmpty
        ? null
        : b('alert', {
            'level': 'critical',
            'title': 'แพ้ยา / แพ้อาหาร',
            'text': c.allergies.join(' · '),
          });
    final fast = switch (p.type) {
      _Ptype.stroke => ('Door-to-needle (rtPA)', 60),
      _Ptype.stemi => ('Door-to-balloon (PCI)', 90),
      _Ptype.sepsis => ('Sepsis bundle 1 ชม.', 60),
      _Ptype.trauma => ('Golden hour', 60),
      _ => null,
    };
    final arrive = c.times.isEmpty ? null : c.times.first;
    ErUiBlock? timer() => fast == null || arrive == null
        ? null
        : b('timer', {
            'label': fast.$1,
            'since': c.onset ?? arrive,
            'target_min': fast.$2
          });

    // พยาบาลคัดกรอง ขั้นระดับ ESI: สรุปความเร่งด่วนโดยผู้ช่วย + ระดับที่แนะนำ
    if (ErSession.instance.isTriage && step == _steps.length - 1) {
      out.add(b('brief', {'title': 'สรุปความเร่งด่วน', 'esi_ai': true}));
    }
    if (ErSession.instance.isNurse) {
      if (step == 1)
        out.add(b('vitals', {
          'keys': ['hr', 'bp', 'spo2', 'rr', 'bt', 'gcs']
        }));
      if (allergy != null) out.add(allergy);
      return _withReview(out, step, b);
    }
    switch (step) {
      case 0:
        out.add(b('brief', {
          'title':
              '${c.sex} ${c.ageText} · ${p.esi == null ? 'รอคัดกรอง' : 'ESI ${p.esi!.level}'}',
          'points': [
            c.cc,
            if (c.underlying.isNotEmpty)
              'โรคประจำตัว: ${c.underlying.join(', ')}',
            if (c.dx.isNotEmpty) 'Dx: ${c.dx.first.text}',
          ],
        }));
        out.add(b('vitals', {
          'keys': ['hr', 'bp', 'spo2', 'rr', 'bt', 'gcs']
        }));
        if (allergy != null) out.add(allergy);
        final t = timer();
        if (t != null) out.add(t);
      case 1:
      case 2:
      case 3:
        if (step == 1 && _isHpiStep(step)) {
          // หน้าแรกของ HPI: เลือก template ก่อน
          out.add(
              b('brief', {'title': 'เลือก template HPI', 'hpi_pick': true}));
        }
        if (step == 2) {
          // หน้าแรกของตรวจร่างกาย: เลือก template ก่อน
          out.add(b('brief', {'title': 'เลือก template', 'pe_pick': true}));
          out.add(b('vitals', {
            'keys': ['hr', 'bp', 'spo2', 'gcs']
          }));
        }
      case 4:
        // สั่ง Order Set ในขั้นนี้ (ย้ายมาจากแท็บคำสั่งแพทย์)
        out.add(b('brief', {'title': 'สั่ง Order Set', 'order_pick': true}));
        final abn = [
          for (final l in c.labs)
            if (l.abnormal) l.name
        ];
        if (abn.isNotEmpty) out.add(b('labs', {'names': abn.take(4).toList()}));
        if (allergy != null) out.add(allergy);
        final tpl = switch (p.type) {
          _Ptype.stroke => 'template_stroke',
          _Ptype.stemi => 'template_stemi',
          _Ptype.sepsis => 'template_sepsis',
          _Ptype.trauma => 'template_trauma',
          _ => 'template_general_emergency',
        };
        final kb = ErFormKb.maybe;
        if (kb != null) {
          out.add(b('order_set', {
            'title': 'ชุดคำสั่งแนะนำ · ${p.type?.label ?? 'ทั่วไป'}',
            'groups': [
              for (final f in const ['ยา/เวชภัณฑ์', 'Lab', 'X-ray', 'หัตถการ'])
                if (kb.options(tpl, f).isNotEmpty)
                  {
                    'field': f,
                    'items': kb
                        .options(tpl, f)
                        .where((o) => o != 'อื่นๆ')
                        .take(5)
                        .toList(),
                  },
            ],
          }));
        }
        final t = timer();
        if (t != null) out.add(t);
      default:
        out.add(b('brief', {
          'title': 'สรุปก่อนจำหน่าย',
          'points': [
            if (c.dx.isNotEmpty) 'Dx: ${c.dx.map((d) => d.text).join(', ')}',
            'ขั้นถัดไป: ${c.nextStep}${c.nextDetail.isEmpty ? '' : ' · ${c.nextDetail}'}',
            if (c.disposition.isNotEmpty) 'Disposition: ${c.disposition}',
          ],
        }));
    }
    return _withReview(out, step, b);
  }

  /// ท้ายทุกขั้นของทุกบทบาท: ฟอร์มครบทุกช่อง + หน้าสรุปก่อนยืนยันบันทึก
  List<ErUiBlock> _withReview(List<ErUiBlock> out, int step,
      ErUiBlock Function(String, Map<String, dynamic>) b) {
    final last = step >= _steps.length - 1;
    return [
      ...out,
      b('form', {
        'title': _steps[step].$2,
        'fields': [for (final (l, _) in _forms[step]) l],
      }),
      b('next_step', {
        'review': true,
        'title': last ? 'ยืนยันและจบเคส' : 'ยืนยันบันทึก',
        'action': last ? 'summary' : 'confirm_step',
      }),
    ];
  }

  List<ErUiBlock> get _uiSeq {
    // ข้อมูลที่หน้ารายละเอียดแสดงอยู่แล้ว (สัญญาณชีพ แล็บ แพ้ยา ...) ไม่แสดงซ้ำ
    // ตัดตามชนิดข้อมูล ไม่ขึ้นกับแท็บ แผงผู้ช่วยจึงเหมือนเดิมทุกแท็บ
    // ไม่ใช้ generative UI แล้ว: แสดงเป็นขั้น ๆ เฉพาะตัวช่วยกรอก → ช่องฟอร์มทีละช่อง → สรุปยืนยัน
    final list = [
      // หน้าแรกของทุกขั้น: หน้าคำแนะนำ (ขั้นนี้ทำอะไร กรอกอะไร ใช้งานยังไง)
      ErUiBlock(ErUiType.brief, const {'intro': true}, source: 'guide'),
      for (final b in _guideUi(_speechStep))
        if (_pinnedBlock(b) ||
            b.type == ErUiType.form ||
            b.type == ErUiType.nextStep)
          b
    ];
    int rank(ErUiBlock b) => b.data['intro'] == true
        ? -2
        : (b.type == ErUiType.alert && b.str('level') == 'critical')
            ? -1
            : _uiOrder[b.type]!;
    // stable sort
    final idx = {for (var i = 0; i < list.length; i++) list[i]: i};
    list.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : idx[a]!.compareTo(idx[b]!);
    });
    return list;
  }

  void _uiGo(int d, int n) {
    final to = (_uiIdx + d).clamp(0, n - 1);
    if (to != _uiIdx) {
      setState(() {
        _formFwd = d > 0;
        _uiIdx = to;
      });
    }
  }

  Widget _agentBar() {
    final seq = _uiSeq;
    final n = seq.length;
    final at = n == 0 ? 0 : _uiIdx.clamp(0, n - 1);
    final cur = n == 0 ? null : seq[at];
    // กรอกครบทุกช่องของขั้น: พาไปหน้าสรุปยืนยันเอง (ครั้งเดียวต่อการครบ)
    final complete =
        _stepLabels(_speechStep).every((l) => _fieldDone(_speechStep, l));
    if (complete && _reviewShown != _speechStep && n > 0) {
      _reviewShown = _speechStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _uiIdx = _uiSeq.length - 1);
      });
    } else if (!complete && _reviewShown == _speechStep) {
      _reviewShown = -1;
    }
    final busy = _agentStatus.isNotEmpty;
    final say = busy
        ? _agentStatus
        : (_agentSay.isEmpty ? 'น้องช่วยพร้อมค่ะ' : _agentSay);
    final total = _pageCount(seq);
    final page = _pageAt(seq);
    final showChoices = _agentChoices != null &&
        !_agentBusy &&
        cur?.type != ErUiType.form &&
        cur?.data['pe_pick'] != true &&
        cur?.data['hpi_pick'] != true;
    return Positioned(
      left: 12.0,
      right: 12.0,
      bottom: 12.0,
      height: _barH,
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: _line),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x220B1B3F),
                  blurRadius: 28.0,
                  offset: Offset(0, 10)),
            ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ---- ซ้าย: ขั้น + คำถาม
            SizedBox(
              width: 290.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _barSteps(),
                    const SizedBox(height: 10.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22.0,
                          height: 22.0,
                          margin: const EdgeInsets.only(top: 1.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [Color(0xFF3B5BDB), Color(0xFF001B7C)]),
                          ),
                          child: Icon(
                              _agentBusy
                                  ? Icons.more_horiz_rounded
                                  : Icons.auto_awesome_rounded,
                              size: 12.0,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            layoutBuilder: (a, b) => Stack(
                                alignment: Alignment.topLeft,
                                children: [...b, if (a != null) a]),
                            child: Text(say,
                                key: ValueKey(say),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.5,
                                    color: busy ? _ink3 : _inkTitle,
                                    weight: FontWeight.w600,
                                    height: 1.4)),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (showChoices)
                      SizedBox(
                        height: 28.0,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final o in _agentChoices!.$2)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: _optChip(o, false, false,
                                    () => _pickChoice(_agentChoices!.$1, o),
                                    size: 11.0),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1.0, color: _line),
            // ---- กลาง: สิ่งที่ต้องทำตอนนี้ (ช่องเดียว / การ์ดเดียว)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 4.0),
                child: cur == null
                    ? Center(
                        child: Text('แตะไมค์แล้วพูดได้เลย',
                            style: _t(12.0, color: _ink3)))
                    : GestureDetector(
                        onHorizontalDragEnd: n < 2 || cur.type == ErUiType.form
                            ? null
                            : (d) {
                                final v = d.primaryVelocity ?? 0;
                                if (v < -200) _uiGo(1, n);
                                if (v > 200) _uiGo(-1, n);
                              },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          layoutBuilder: (a, b) => Stack(
                              alignment: Alignment.topLeft,
                              children: [...b, if (a != null) a]),
                          child: KeyedSubtree(
                            key: ValueKey(
                                '${_speechStep}_${at}_${cur.key}_$_agentUiGen'),
                            child: SizedBox(
                              height: _barH - 16.0,
                              child: _uiBlock(cur),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const VerticalDivider(width: 1.0, color: _line),
            // ---- ขวา: หน้า + ไมค์ + ปิด
            SizedBox(
              width: 112.0,
              child: Stack(children: [
                Positioned(
                  top: 6.0,
                  right: 6.0,
                  child: _dockArrow(Icons.close_rounded, _closeSpeech),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (total > 1)
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        _dockArrow(Icons.chevron_left_rounded,
                            page > 0 ? () => _pageGo(seq, page - 1) : null),
                        Text('${page + 1}/$total',
                            style: _num(10.5,
                                color: _ink2, weight: FontWeight.w700)),
                        _dockArrow(
                            Icons.chevron_right_rounded,
                            page < total - 1
                                ? () => _pageGo(seq, page + 1)
                                : null),
                      ])
                    else
                      const SizedBox(height: 22.0),
                    const SizedBox(height: 8.0),
                    _barMic(),
                    const SizedBox(height: 6.0),
                    ValueListenableBuilder<int>(
                      valueListenable: _micFrame,
                      builder: (_, __, ___) => _micLabel(),
                    ),
                  ],
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  /// จุดความคืบหน้าของขั้น (แตะเพื่อข้ามไปขั้นนั้น) + ชื่อขั้นปัจจุบัน
  Widget _barSteps() => Row(children: [
        for (var i = 0; i < _steps.length; i++)
          GestureDetector(
            onTap: () {
              if (i == _speechStep) return;
              _robot.stop();
              _stopRecord(send: false);
              setState(() => _speechStep = i);
              _agentGreet();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == _speechStep ? 18.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                color: _speechDone.contains(i)
                    ? _blue
                    : (i == _speechStep ? _blue : _line),
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
          ),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(
              'ขั้น ${_speechStep + 1}/${_steps.length} · ${_steps[_speechStep].$2}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _t(10.0, color: _ink3, weight: FontWeight.w600)),
        ),
      ]);

  /// ไมค์ในแถบ: แตะเปิด แตะอีกครั้งปิดแล้วส่ง · คลื่นรอบปุ่มตามเสียงจริงตอนฟัง
  Widget _barMic() {
    const r = 26.0;
    return SizedBox(
      width: r * 2 + 28.0,
      height: r * 2 + 28.0,
      child: Stack(alignment: Alignment.center, children: [
        if (_recording)
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<int>(
                valueListenable: _micFrame,
                builder: (_, __, ___) => CustomPaint(
                  painter: _MicWave(levels: _wave, inner: r + 3.0, color: _red),
                ),
              ),
            ),
          ),
        Material(
          color: _recording ? _red : (_agentBusy ? _g5 : _blue),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          shadowColor: _blue.withValues(alpha: 0.4),
          // แตะ = เปิดไมค์ · แตะอีกครั้ง = ปิดแล้วส่ง (ไม่ต้องกดค้าง)
          child: InkWell(
            onTap: _micToggle,
            child: SizedBox(
              width: r * 2,
              height: r * 2,
              child: Icon(
                  _recording
                      ? Icons.graphic_eq_rounded
                      : (_agentBusy
                          ? Icons.more_horiz_rounded
                          : Icons.mic_rounded),
                  size: 24.0,
                  color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }

  /// ข้อความสถานะใต้ไมค์ (บรรทัดเดียว)
  Widget _micLabel() {
    final talking = _robot.mood == ErAuraMood.talking;
    final (text, col) = _recording
        ? (
            'แตะเพื่อส่ง ${_recSec ~/ 60}:${(_recSec % 60).toString().padLeft(2, '0')}',
            _red
          )
        : _agentBusy
            ? ('กำลังคิด…', _ink2)
            : talking
                ? ('กำลังพูด', _blue)
                : ('แตะเพื่อพูด', _ink3);
    return Text(text,
        maxLines: 1, style: _num(9.5, color: col, weight: FontWeight.w700));
  }

  /// จำนวนหน้าของขั้นนี้: การ์ดทั่วไป 1 หน้า ฟอร์ม 1 หน้าต่อช่อง
  /// ขั้นที่แสดงทุกช่องของฟอร์มในหน้าเดียว (ไม่แบ่งหน้าละช่อง)
  /// พยาบาล "ออกจาก ER": ช่องสั้นและกรอกต่อเนื่องกัน ดูพร้อมกันสะดวกกว่า
  bool get _formAllAtOnce =>
      ErSession.instance.role == ErRole.nurse &&
      _speechStep < _steps.length &&
      _steps[_speechStep].$2 == 'ออกจาก ER';

  int _pagesOf(ErUiBlock b) => b.type != ErUiType.form
      ? 1
      : _formAllAtOnce
          ? 1
          : math.max(1, _formFields(b).length);

  int _pageCount(List<ErUiBlock> seq) => seq.fold(0, (a, b) => a + _pagesOf(b));

  /// หน้าปัจจุบัน (นับรวมทุกการ์ด)
  int _pageAt(List<ErUiBlock> seq) {
    if (seq.isEmpty) return 0;
    final at = _uiIdx.clamp(0, seq.length - 1);
    var p = 0;
    for (var i = 0; i < at; i++) {
      p += _pagesOf(seq[i]);
    }
    return p +
        (seq[at].type == ErUiType.form
            ? _formAt.clamp(0, _pagesOf(seq[at]) - 1)
            : 0);
  }

  /// ไปหน้าที่ p: หาการ์ดที่หน้านั้นอยู่ แล้วตั้งช่องของฟอร์มถ้าเป็นฟอร์ม
  void _pageGo(List<ErUiBlock> seq, int p) {
    final cur = _pageAt(seq);
    var rest = p;
    for (var i = 0; i < seq.length; i++) {
      final n = _pagesOf(seq[i]);
      if (rest < n) {
        setState(() {
          _formFwd = p > cur;
          _uiIdx = i;
          _formAt = seq[i].type == ErUiType.form ? rest : 0;
        });
        return;
      }
      rest -= n;
    }
  }

  /// หน้าในขั้นนี้: (ชื่อหน้า, ครบแล้ว) เรียงตามลำดับหน้าใน stepper
  List<(String, bool)> _pageMeta(List<ErUiBlock> seq) {
    final step = _speechStep;
    final all = _stepLabels(step).every((l) => _fieldDone(step, l));
    return [
      for (final b in seq)
        if (b.type == ErUiType.form && _formAllAtOnce)
          ('แบบฟอร์ม', _formFields(b).every((f) => _fieldDone(step, f)))
        else if (b.type == ErUiType.form)
          for (final f in _formFields(b)) (f, _fieldDone(step, f))
        else if (b.data['intro'] == true)
          ('เริ่มต้น', true)
        else if (b.data['hpi_pick'] == true || b.data['pe_pick'] == true)
          ('Template', true)
        else if (b.data['order_pick'] == true)
          ('Order Set', _orderPicked.isNotEmpty)
        else if (b.data['esi_ai'] == true)
          ('ESI แนะนำ', true)
        else if (b.type == ErUiType.nextStep)
          ('สรุป', all)
        else
          (b.str('title', 'ข้อมูล'), true),
    ];
  }

  /// stepper ด้านบน: แต่ละหน้ามีแถบ · ชื่อ · สถานะครบ (✓) แตะเพื่อไปหน้านั้น
  /// หน้ามากเกินความกว้าง เลื่อนแนวนอนได้ และเลื่อนให้หน้าปัจจุบันอยู่ในจอเอง
  Widget _pageStepper(List<ErUiBlock> seq, int page) {
    // ตัดหน้าคำแนะนำออก: ช่องที่ k ของ stepper = หน้าที่ k+1
    final meta = _pageMeta(seq).skip(1).toList();
    final at = page - 1;
    return LayoutBuilder(builder: (context, box) {
      final avail = box.maxWidth - 32.0;
      final w = math.max(76.0, avail / meta.length);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_stepperScroll.hasClients) return;
        final target = (at * w - (avail - w) / 2)
            .clamp(0.0, _stepperScroll.position.maxScrollExtent);
        if ((_stepperScroll.offset - target).abs() > 1.0) {
          _stepperScroll.animateTo(target,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic);
        }
      });
      return SizedBox(
        height: 40.0,
        child: ListView.builder(
          controller: _stepperScroll,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: meta.length,
          itemBuilder: (context, i) {
            final (title, done) = meta[i];
            final cur = i == at;
            final bar =
                cur ? _blue : (done ? _green.withValues(alpha: 0.7) : _line);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _pageGo(seq, i + 1),
              child: SizedBox(
                width: w,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0, top: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: bar,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Row(children: [
                        if (done) ...[
                          const Icon(Icons.check_circle_rounded,
                              size: 11.0, color: _green),
                          const SizedBox(width: 3.0),
                        ],
                        Expanded(
                          child: Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(9.5,
                                  color: cur ? _inkTitle : _ink3,
                                  weight:
                                      cur ? FontWeight.w600 : FontWeight.w500)),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// ปุ่มขวาล่าง: เริ่มกรอก → ถัดไป → หน้าสรุป: ครบ = "ครบแล้ว ไปขั้นต่อไป" (ยืนยันบันทึก)
  /// ยังขาด = "ไปช่องที่ขาด" · ขั้นสุดท้ายครบ = "จบเคส" (เปิดสรุปเคส)
  Widget _nextBtn(List<ErUiBlock> seq, int page, int total) {
    if (page == 0 && total > 1) {
      return _navBtn(
          'เริ่มกรอก', Icons.chevron_right_rounded, () => _pageGo(seq, 1),
          trailing: true);
    }
    if (page < total - 1) {
      return _navBtn(
          'ถัดไป', Icons.chevron_right_rounded, () => _pageGo(seq, page + 1),
          trailing: true);
    }
    final step = _speechStep;
    final missing = [
      for (final l in _stepLabels(step))
        if (!_fieldDone(step, l)) l
    ];
    // สั่งข้ามขั้นนี้แล้ว: ยังไม่ครบก็ไปต่อได้ (ช่องที่ขาดยังเห็นในหน้าตรวจสอบ)
    if (missing.isNotEmpty && _skipAsked == step) {
      return _navBtn('ข้ามขั้นนี้ · ขั้นต่อไป', Icons.chevron_right_rounded,
          () {
        _formFwd = true;
        _confirmStep();
      }, trailing: true);
    }
    if (missing.isNotEmpty) {
      return _navBtn(
          'ไปช่องที่ขาด (${missing.length})', Icons.chevron_right_rounded, () {
        final fi = seq.indexWhere((x) => x.type == ErUiType.form);
        if (fi < 0) return;
        final k = _formFields(seq[fi]).indexOf(missing.first);
        setState(() {
          _formFwd = false;
          _uiIdx = fi;
          _formAt = k < 0 ? 0 : k;
        });
      }, trailing: true);
    }
    final last = step >= _steps.length - 1;
    return _navBtn(last ? 'ครบแล้ว · จบเคส' : 'ครบแล้ว · ขั้นต่อไป',
        Icons.chevron_right_rounded, () {
      if (last) {
        _closeSpeech();
        _openSummary();
      } else {
        _formFwd = true;
        _confirmStep();
      }
    }, trailing: true);
  }

  /// ปุ่มเปลี่ยนหน้าขนาดใหญ่ (สูง 44) กดง่ายบนแท็บเล็ต
  Widget _navBtn(String label, IconData icon, VoidCallback? onTap,
      {bool primary = true, bool trailing = false}) {
    final on = onTap != null;
    final fg = primary && on ? Colors.white : (on ? _blue : _g5);
    final ic = Icon(icon, size: 20.0, color: fg);
    return _Press(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44.0,
          decoration: BoxDecoration(
            gradient: primary && on ? _glossGrad(_blue) : _glossWhite,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: primary && on ? _blue : _line),
            boxShadow: on
                ? _glossLift(primary ? _blue : const Color(0xFF0B1B3F))
                : null,
          ),
          foregroundDecoration: _InnerGloss(12.0, dark: primary && on),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            // ระยะไอคอน-ข้อความ 6 ไม่ให้ไอคอนชิดตัวอักษร
            if (!trailing) ...[ic, const SizedBox(width: 6.0)],
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.0, color: fg, weight: FontWeight.w600)),
            ),
            if (trailing) ...[const SizedBox(width: 6.0), ic],
          ]),
        ),
      ),
    );
  }

  Widget _dockArrow(IconData icon, VoidCallback? onTap) => _Press(
          child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 22.0,
          height: 22.0,
          child: Icon(icon, size: 16.0, color: onTap == null ? _g5 : _blue),
        ),
      ));

  /// เนื้อการ์ดในแผ่นล่าง: หัวข้อ + เนื้อหาเลื่อนได้ (แผ่นเป็นพื้นให้ ไม่มีกรอบซ้อน)
  Widget _uiCard(ErUiBlock b,
      {required IconData icon,
      required String title,
      Color? accent,
      Widget? trailing,
      required Widget child}) {
    final a = accent ?? _blue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 22.0,
            height: 22.0,
            decoration: BoxDecoration(
              color: a.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Icon(icon, size: 13.0, color: a),
          ),
          const SizedBox(width: 7.0),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(12.5, color: _inkTitle, weight: FontWeight.w700)),
          ),
          if (trailing != null) trailing,
        ]),
        const SizedBox(height: 6.0),
        Flexible(child: SingleChildScrollView(child: child)),
      ],
    );
  }
}
