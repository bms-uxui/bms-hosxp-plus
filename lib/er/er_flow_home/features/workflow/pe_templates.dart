// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ช่องบันทึกอิสระท้ายฟอร์มตรวจร่างกาย (ช่อง "บันทึกการตรวจร่างกาย" ของ HOSxP)
const String _peNoteLabel = 'บันทึกการตรวจแบบละเอียด';

bool _peHasDetail(String label) => label != _peNoteLabel;

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesWorkflowPeTemplatesState on State<ErFlowHomeWidget> {
  // ------------------------------------------------ template ตรวจร่างกาย
  List<ErPeTemplate> _peTemplates = erPeBuiltIns;

  /// ระบบที่ template ที่เลือกครอบคลุม (null = ไม่ใช้ template ตรวจทุกระบบ)
  Set<String>? _peScope;

  /// template ที่ใช้ล่าสุดในขั้นตรวจร่างกาย (แสดงบนปุ่มเลือก)
  String? _peTplUsed;

  OverlayEntry? _peek;

  /// แถว template ที่อยู่บนจอ (ชื่อ → key, เนื้อความ) ใช้หาแถวใต้นิ้วตอนลาก
  /// ใช้ context ของแถว (ไม่ใช้ GlobalKey: ตอนเปลี่ยนหน้าแถวชื่อเดียวกันอยู่พร้อมกันได้สองชุด)
  final Map<String, (BuildContext, String)> _tplRows = {};

  String? _peekTitle;
  Offset _peekAt = Offset.zero;
  double _peekRowLeft = 0.0;
}

extension _FeaturesWorkflowPeTemplatesPart on _ErFlowHomeWidgetState {
  String get _uid => ErSession.instance.user?.id ?? 'guest';

  Future<void> _loadPeTemplates() async {
    final list = await ErPeTemplates.load(_uid);
    if (mounted) setState(() => _peTemplates = list);
  }

  /// วาง template ลงฟอร์มตรวจร่างกาย (แทนค่าช่องที่ template มี)
  void _applyPeTemplate(ErPeTemplate t, {int? step}) {
    final st = step ?? _speechStep;
    final ok = {..._acceptLabels(st)};
    _lastFilled = [
      for (final e in t.values.entries)
        if (ok.contains(e.key)) (st, e.key, _filled[st][e.key])
    ];
    for (final e in t.values.entries) {
      if (ok.contains(e.key)) _filled[st][e.key] = e.value;
    }
    // ระบบนอก template = แพทย์ท่านนี้ไม่ได้ตรวจ บันทึกเป็น "ไม่ได้ตรวจ" และไม่ต้องกรอก
    final scope = {
      for (final k in t.values.keys)
        if (!k.contains(' - ')) k
    };
    for (final (l, _) in _forms[st]) {
      if (_peHasDetail(l) && !scope.contains(l)) _filled[st][l] = 'ไม่ได้ตรวจ';
    }
    _peScope = scope;
  }

  /// ระบบที่ template ตรวจร่างกายเก็บได้ (ตามฟอร์มตรวจร่างกายของแพทย์)
  List<String> get _peTplSystems => [
        for (final (l, _) in _doctorForm[_peStep])
          if (_peHasDetail(l)) l
      ];

  /// หน้าต่างจัดการ template ตรวจร่างกาย (แยกจาก flow บันทึก)
  /// ซ้าย: รายการ template · ขวา: ตัวแก้ไข เลือกระบบที่ตรวจ ผล และรายละเอียด
  Future<void> _openPeTemplates() async {
    final systems = _peTplSystems;
    var sel = _peTemplates.isEmpty ? null : _peTemplates.first;
    var name = TextEditingController(text: sel?.name ?? '');
    var draft = <String, String>{...?sel?.values};
    final notes = <String, TextEditingController>{};
    TextEditingController noteOf(String l) =>
        notes.putIfAbsent(l, () => TextEditingController());
    void load(ErPeTemplate? t) {
      sel = t;
      name = TextEditingController(text: t?.name ?? '');
      draft = {...?t?.values};
      for (final l in systems) {
        noteOf(l).text = draft['$l - รายละเอียด'] ?? '';
      }
    }

    load(sel);
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
        final readOnly = sel?.builtIn ?? false;
        Future<void> save() async {
          final n = name.text.trim();
          if (n.isEmpty) return;
          final values = <String, String>{
            for (final l in systems)
              if (draft[l] != null) l: draft[l]!,
            for (final l in systems)
              if (draft[l] != null && noteOf(l).text.trim().isNotEmpty)
                '$l - รายละเอียด': noteOf(l).text.trim(),
          };
          if (values.isEmpty) return;
          final list = await ErPeTemplates.add(_uid, ErPeTemplate(n, values));
          if (!mounted) return;
          setState(() => _peTemplates = list);
          set(() => load(list.firstWhere((t) => t.name == n)));
        }

        Future<void> remove() async {
          final t = sel;
          if (t == null || t.builtIn) return;
          final list = await ErPeTemplates.remove(_uid, t.name);
          if (!mounted) return;
          setState(() => _peTemplates = list);
          set(() => load(list.isEmpty ? null : list.first));
        }

        // ตั้งต้นจากผลตรวจที่กำลังบันทึก (ถ้ามี) ไม่งั้นจากครั้งล่าสุดในประวัติ
        void fromLatest() {
          final cur = _peStep < _filled.length ? _filled[_peStep] : const {};
          set(() {
            sel = null;
            name = TextEditingController();
            draft = {};
            for (final l in systems) {
              if (cur[l] != null) draft[l] = cur[l]!;
              noteOf(l).text = cur['$l - รายละเอียด'] ?? '';
            }
            if (draft.isEmpty) {
              final last = _peRounds.last;
              for (final sy in _peSystems) {
                final l = _peField[sy.key];
                if (l == null) continue;
                final (f, note) = last.of(sy.key);
                if (f == _Finding.none) continue;
                draft[l] = switch (f) {
                  _Finding.abnormal => 'ผิดปกติ',
                  _Finding.notDone => 'ไม่ได้ตรวจ',
                  _ => 'ปกติ',
                };
                noteOf(l).text = note;
              }
            }
          });
        }

        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          clipBehavior: Clip.antiAlias,
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // รายการ template
            Container(
              width: 260.0,
              color: _panelSoft,
              padding: const EdgeInsets.fromLTRB(14.0, 18.0, 14.0, 14.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Template การตรวจร่างกาย',
                        style: _t(14.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                    const SizedBox(height: 2.0),
                    Text('ชุดระบบที่ตรวจบ่อย เรียกใช้ตอนบันทึกด้วยเสียง',
                        style: _t(10.0, color: _ink3)),
                    const SizedBox(height: 12.0),
                    _uiButton(
                        'สร้างจากผลตรวจล่าสุด', Icons.add_rounded, fromLatest),
                    const SizedBox(height: 12.0),
                    Expanded(
                      child: ListView(children: [
                        for (final t in _peTemplates)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Material(
                              color: t == sel ? _panel : Colors.transparent,
                              borderRadius: BorderRadius.circular(10.0),
                              child: InkWell(
                                onTap: () => set(() => load(t)),
                                borderRadius: BorderRadius.circular(10.0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 8.0),
                                  child: Row(children: [
                                    Icon(
                                        t.builtIn
                                            ? Icons.bookmark_border_rounded
                                            : Icons.bookmark_rounded,
                                        size: 16.0,
                                        color: t.builtIn ? _ink3 : _blue),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(t.name,
                                                style: _t(12.0,
                                                    color: _inkTitle,
                                                    weight: FontWeight.w600)),
                                            Text(
                                                '${t.systems} ระบบ${t.builtIn ? ' · ของระบบ' : ''}',
                                                style: _t(9.5, color: _ink3)),
                                          ]),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                      ]),
                    ),
                  ]),
            ),
            // ตัวแก้ไข
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 14.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: name,
                            readOnly: readOnly,
                            style: _t(15.0, weight: FontWeight.w700),
                            decoration: InputDecoration(
                              hintText: 'ชื่อ template เช่น ตรวจเด็กไข้',
                              helperText: readOnly
                                  ? 'template ของระบบ แก้ไม่ได้ · เปลี่ยนชื่อแล้วบันทึกเป็นของตัวเองได้'
                                  : null,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: readOnly ? null : (_) => set(() {}),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ]),
                      const SizedBox(height: 10.0),
                      Text(
                          'เลือกระบบที่สาขานี้ตรวจ ระบบที่ "ไม่รวม" จะบันทึกเป็นไม่ได้ตรวจและไม่ต้องกรอก',
                          style: _t(10.5, color: _ink3)),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: ListView.separated(
                          itemCount: systems.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1.0, color: _line),
                          itemBuilder: (_, i) {
                            final l = systems[i];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(children: [
                                SizedBox(
                                  width: 130.0,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(l,
                                            style: _t(12.0,
                                                color: _inkTitle,
                                                weight: FontWeight.w700)),
                                        if (_termOf(l) case final sub?)
                                          Text(sub,
                                              style: _t(9.5, color: _ink3)),
                                      ]),
                                ),
                                for (final o in const [
                                  'ไม่รวม',
                                  'ปกติ',
                                  'ผิดปกติ',
                                  'ไม่ได้ตรวจ'
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: _optChip(
                                        o,
                                        (draft[l] ?? 'ไม่รวม') == o,
                                        false,
                                        () => set(() => o == 'ไม่รวม'
                                            ? draft.remove(l)
                                            : draft[l] = o),
                                        size: 10.5),
                                  ),
                                const SizedBox(width: 6.0),
                                Expanded(
                                  child: TextField(
                                    controller: noteOf(l),
                                    enabled: draft[l] != null,
                                    minLines: 1,
                                    maxLines: 4,
                                    style: _t(11.5),
                                    decoration: const InputDecoration(
                                      hintText: 'รายละเอียดตั้งต้น',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(children: [
                        if (sel != null && !readOnly)
                          _uiButton('ลบ', Icons.delete_outline_rounded, remove,
                              primary: false),
                        const Spacer(),
                        Text(
                            '${systems.where((l) => draft[l] != null).length} ระบบ',
                            style: _t(11.0, color: _ink3)),
                        const SizedBox(width: 10.0),
                        _uiButton('บันทึก template', Icons.check_rounded, save),
                      ]),
                    ]),
              ),
            ),
          ]),
        );
      }),
    );
  }

  /// หน้าแรกของ workflow ตรวจร่างกาย: เลือก template แล้วไปกรอกต่อ
  /// เรียบที่สุด: รายการชื่อ + จำนวนระบบ · ข้าม · จัดการ (ลิงก์เล็ก)
  /// แถว template แบบเอกสาร: ไอคอนกระดาษ + ชื่อ + ตัวอย่างเนื้อความ
  /// ช่องว่าง [ ] ในตัวอย่างแสดงเป็นช่องเติมคำ (พื้นฟ้าอ่อน) ให้เห็นว่าเป็นแบบฟอร์ม
  /// ข้อความ template: ช่องเติมคำ [ ] เป็นตัวหนา (ไม่ลงพื้นหลัง)
  List<InlineSpan> _tplSpans(String text, Color blank) {
    final spans = <InlineSpan>[];
    var i = 0;
    for (final m in RegExp(r'\[([^\]]*)\]').allMatches(text)) {
      if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start)));
      spans.add(TextSpan(
          text: ' ${m.group(1)!} ',
          style: TextStyle(fontWeight: FontWeight.w700, color: blank)));
      i = m.end;
    }
    if (i < text.length) spans.add(TextSpan(text: text.substring(i)));
    return spans;
  }

  /// กดค้างแล้วลาก: การ์ดตัวอย่างลอยตามนิ้ว และเปลี่ยนเป็น template ใต้นิ้ว
  void _peekMove(Offset global) {
    String? hit;
    for (final e in _tplRows.entries) {
      final ctx = e.value.$1;
      if (!ctx.mounted) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final r = box.localToGlobal(Offset.zero) & box.size;
      if (global.dy >= r.top && global.dy <= r.bottom) {
        hit = e.key;
        _peekRowLeft = r.left;
      }
    }
    final changed = hit != null && hit != _peekTitle;
    if (hit != null) _peekTitle = hit;
    _peekAt = global;
    if (changed) HapticFeedback.selectionClick();
    if (_peek == null) {
      HapticFeedback.selectionClick();
      _peek = OverlayEntry(builder: (_) => _peekCard());
      Overlay.of(context).insert(_peek!);
    } else {
      _peek!.markNeedsBuild();
    }
  }

  /// การ์ดตัวอย่างเป็นกระดาษแนวตั้ง (สัดส่วน A4 1:1.414) ลอยข้างนิ้วทางซ้าย
  /// ขยับขึ้นลงตามนิ้ว ไม่บังแถวที่กำลังชี้
  Widget _peekCard() {
    final t = _peekTitle;
    final text = t == null ? null : _tplRows[t]?.$2;
    if (t == null || text == null) return const SizedBox.shrink();
    final screen = MediaQuery.sizeOf(context);
    const w = 270.0;
    final h = math.min(w * 1.414, screen.height - 24.0);
    final left = (_peekRowLeft - w - 16.0).clamp(12.0, screen.width - w - 12.0);
    final top = (_peekAt.dy - h / 2).clamp(12.0, screen.height - h - 12.0);
    return Positioned(
      left: left,
      top: top,
      width: w,
      height: h,
      child: IgnorePointer(
        child: Material(
          color: _panel,
          elevation: 14.0,
          shadowColor: const Color(0x400B1B3F),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6.0),
            topRight: Radius.circular(22.0),
            bottomLeft: Radius.circular(6.0),
            bottomRight: Radius.circular(6.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Template',
                    style: _t(8.5, color: _ink3, weight: FontWeight.w600)),
                const SizedBox(height: 2.0),
                Text(t,
                    style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Divider(height: 1.0, color: _line),
                ),
                Expanded(
                  child: ClipRect(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Text.rich(
                          TextSpan(children: _tplSpans(text, _blueHue)),
                          style: _t(10.5, color: _ink2, height: 1.7)),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text('ลากเพื่อดูอันอื่น · ปล่อยเพื่อปิด',
                    style: _t(8.5, color: _ink3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _peekHide() {
    _peek?.remove();
    _peek = null;
    _peekTitle = null;
  }

  Widget _tplRow(
      {required String title,
      required String preview,
      String? badge,
      required bool on,
      required VoidCallback onTap}) {
    final spans = _tplSpans(preview, on ? _pInk : _ink2);
    return _Press(
        scale: 0.98,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Builder(builder: (rowCtx) {
            _tplRows[title] = (rowCtx, preview);
            return GestureDetector(
              onLongPressStart: (d) {
                _peekTitle = title;
                _peekMove(d.globalPosition);
              },
              onLongPressMoveUpdate: (d) => _peekMove(d.globalPosition),
              onLongPressEnd: (_) => _peekHide(),
              onLongPressCancel: _peekHide,
              child: Material(
                color: on ? _blue : _panel,
                borderRadius: BorderRadius.circular(10.0),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 9.0, 12.0, 9.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: on ? _blue : _line),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // กระดาษเอกสาร: มุมพับ + เส้นบรรทัด
                        Container(
                          width: 26.0,
                          height: 32.0,
                          padding:
                              const EdgeInsets.fromLTRB(5.0, 8.0, 5.0, 5.0),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(3.0),
                              topRight: Radius.circular(8.0),
                              bottomLeft: Radius.circular(3.0),
                              bottomRight: Radius.circular(3.0),
                            ),
                            border: Border.all(color: on ? _panel : _line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final w in const [14.0, 10.0, 7.0])
                                Container(
                                  width: w,
                                  height: 2.0,
                                  margin: const EdgeInsets.only(bottom: 3.0),
                                  color: _ink3.withValues(alpha: 0.35),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(12.5,
                                          color: on ? _pInk : _inkTitle,
                                          weight: FontWeight.w700)),
                                ),
                                if (badge != null)
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.auto_awesome_rounded,
                                            size: 11.0,
                                            color: on ? _pInk : _blue),
                                        const SizedBox(width: 3.0),
                                        Text(badge,
                                            style: _t(10.0,
                                                color: on ? _pInk : _blueHue,
                                                weight: FontWeight.w700)),
                                      ]),
                              ]),
                              const SizedBox(height: 3.0),
                              Text.rich(TextSpan(children: spans),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(9.5,
                                      color: on ? _pInk2 : _ink3, height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ));
  }

  Widget _pePickCard() {
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
              for (final t in _peTemplates)
                _tplRow(
                  title: t.name,
                  preview: [
                    for (final e in t.values.entries)
                      if (!e.key.contains(' - ')) '${e.key} [${e.value}]'
                  ].join(' · '),
                  on: _peTplUsed == t.name,
                  onTap: () {
                    setState(() {
                      _applyPeTemplate(t);
                      _peTplUsed = t.name;
                    });
                    next();
                  },
                ),
            ]),
          ),
        ),
        Row(children: [
          TextButton(
            onPressed: _openPeTemplates,
            child: Text('จัดการ template',
                style: _t(11.0, color: _ink3, weight: FontWeight.w600)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _peTplUsed = null;
                _peScope = null;
              });
              next();
            },
            child: Text('ข้าม · กรอกเอง',
                style: _t(11.5, color: _blueHue, weight: FontWeight.w700)),
          ),
        ]),
      ],
    );
  }

  /// ผู้ช่วยสั่งใช้ template ด้วยเสียง: {"pe_template":"<ชื่อ>"}
  void _usePeTemplate(Map<String, dynamic> data, int step) {
    final n = data['pe_template'];
    if (n is! String || !_isPeStep(step)) return;
    final t = _peTemplates.where((x) => x.name == n.trim()).firstOrNull;
    if (t != null) {
      _applyPeTemplate(t, step: step);
      _peTplUsed = t.name;
    }
  }

  String _peTemplatePrompt() => '''
template ตรวจร่างกายของแพทย์คนนี้: ${_peTemplates.map((t) => '"${t.name}"').join(', ')}
ถ้าแพทย์พูดว่า "ใช้ template ..." หรือ "ตรวจเหมือน ..." ให้ใส่ "pe_template":"<ชื่อตรงตามรายการ>" ใน JSON
ระบบจะเติมผลตาม template ให้ แล้วเติม fields เฉพาะส่วนที่แพทย์บอกว่าต่างจาก template''';
  bool _isPeStep(int step) =>
      ErSession.instance.role == ErRole.doctor && step == 2;
}
