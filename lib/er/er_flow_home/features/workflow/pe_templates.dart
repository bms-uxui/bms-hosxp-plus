// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ช่องบันทึกอิสระท้ายฟอร์มตรวจร่างกาย (ช่อง "บันทึกการตรวจร่างกาย" ของ HOSxP)
const String _peNoteLabel = 'บันทึกการตรวจแบบละเอียด';

bool _peHasDetail(String label) => label != _peNoteLabel;

/// ช่องทบทวนระบบ (ROS) ในขั้นตรวจร่างกาย
bool _isRos(String label) => label.startsWith('ROS ');

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesWorkflowPeTemplatesState on State<ErFlowHomeWidget> {
  // ------------------------------------------------ template ตรวจร่างกาย
  List<ErPeTemplate> _peTemplates = erPeBuiltIns;

  /// ระบบที่ template ที่เลือกครอบคลุม (null = ไม่ใช้ template ตรวจทุกระบบ)
  Set<String>? _peScope;

  /// template ที่ใช้ล่าสุดในขั้นตรวจร่างกาย (แสดงบนปุ่มเลือก)
  String? _peTplUsed;

  /// ระบบที่เพิ่งเลือกปกติ: กำลังเล่นแถบเขียวไล่ซ้าย→ขวา ก่อนซ่อนแถว
  final Set<String> _peSweep = {};

  /// กางแถวระบบที่ปกติ (ซ่อนไว้) กลับมาให้แก้
  bool _peShowNormal = false;

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
      if (_peHasDetail(l) && !_isRos(l) && !scope.contains(l)) {
        _filled[st][l] = 'ไม่ได้ตรวจ';
      }
    }
    _peScope = scope;
  }

  /// ระบบที่ template ตรวจร่างกายเก็บได้ (ตามฟอร์มตรวจร่างกายของแพทย์)
  List<String> get _peTplSystems => [
        for (final (l, _) in _peFields)
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
          if (!await _askDelete('ลบเทมเพลตนี้?',
              'เทมเพลต "${t.name}" จะถูกลบ ใช้ซ้ำไม่ได้อีก', 'ลบเทมเพลต')) {
            return;
          }
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
    // ชิ้นใต้นิ้วพอดีก่อน (ชิปเรียงแนวนอน เช่น template HPI)
    // ไม่โดนชิ้นไหน: แถวที่ความสูงตรงนิ้ว ใกล้นิ้วที่สุดในแนวนอน (แถวเรียงแนวตั้ง)
    String? hit;
    var best = double.infinity;
    for (final e in _tplRows.entries) {
      final ctx = e.value.$1;
      if (!ctx.mounted) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final r = box.localToGlobal(Offset.zero) & box.size;
      if (global.dy < r.top || global.dy > r.bottom) continue;
      final d = r.contains(global) ? -1.0 : (r.center.dx - global.dx).abs();
      if (d < best) {
        best = d;
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
    // ซ้ายของแถวไม่พอ (เช่นชิปในแผงซ้าย) → วางขวาของนิ้วแทน ไม่บังชิ้นที่ชี้
    final roomLeft = _peekRowLeft - w - 16.0 >= 12.0;
    final left = (roomLeft ? _peekRowLeft - w - 16.0 : _peekAt.dx + 28.0)
        .clamp(12.0, screen.width - w - 12.0);
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

  /// หน้ารวมตรวจร่างกาย: ทุกระบบในหน้าเดียว แถวละระบบ (ชื่อ ตัวเลือก)
  /// ผิดปกติ/มีรายละเอียดแล้ว = ช่องรายละเอียดใต้แถว · ท้ายสุดเป็นบันทึกแบบละเอียด
  /// หน้าผลตรวจ (PE) หรือหน้าทบทวนระบบ (ros: true) ใช้โครงเดียวกัน
  /// ROS: ปกติ = ไม่มีอาการ · ผิดปกติ = มีอาการ (ต้องระบุ)
  /// หัวหน้าตรวจร่างกายแบบ Google (ภาษาเดียวกับซักประวัติ): ชื่อหน้า + คำอธิบายเล็ก
  /// ปุ่ม tonal ขวามือ · วางบนแผงขาวตรง ๆ ไม่มีกรอบซ้อนกรอบ
  Widget _peShell(String title, String sub, Widget child, {Widget? action}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 10.0),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: _t(16.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                    const SizedBox(height: 2.0),
                    Text(sub,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
            if (action != null) ...[const SizedBox(width: 8.0), action],
          ]),
        ),
        Expanded(child: child),
      ]);

  Widget _pePage(List<String> fields, Map<String, String> items,
      {bool ros = false}) {
    final known = _filled[_speechStep];
    final systems = [
      for (final f in fields)
        if (_peHasDetail(f) && _isRos(f) == ros) f
    ];
    // ระบบที่ยังว่างและเลือก "ปกติ" ได้ (Neuro เป็น GCS/รูม่านตา ไม่นับ)
    final rest = [
      for (final f in systems)
        if ((known[f] ?? '').trim().isEmpty &&
            _fieldOptions(f, items[f] ?? '').contains('ปกติ'))
          f
    ];
    // นับเฉพาะที่ตอบจริง (ช่องว่างไม่บังคับ แต่ไม่ใช่ "ตอบแล้ว")
    final done = systems.where((f) => _hasVal(_speechStep, f)).length;
    final normal = [
      for (final f in systems)
        if (known[f] == 'ปกติ') f
    ];
    return _peShell(
      ros ? 'ทบทวนระบบ (ROS)' : 'ผลตรวจร่างกาย',
      [
        if (_peTplUsed != null) 'เทมเพลต $_peTplUsed',
        '${ros ? 'อาการที่ผู้ป่วยบอก' : 'สิ่งที่ตรวจพบ'} ตอบแล้ว $done จาก ${systems.length} ระบบ',
      ].join(' '),
      action: _triIconBtn(Icons.post_add_rounded, 'เทมเพลต', _pePickSheet),
      ListView(
        key: PageStorageKey('pe-page-$_speechStep-$ros'),
        padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 96.0),
        children: [
          // ทางลัด: ระบบที่ยังว่างทั้งหมด = ปกติ (ปุ่ม tonal เต็มแถว)
          if (rest.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: _Press(
                child: Material(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(10.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () => setState(() {
                      _lastFilled = [
                        for (final f in rest) (_speechStep, f, known[f])
                      ];
                      for (final f in rest) {
                        _filled[_speechStep][f] = 'ปกติ';
                      }
                      if (!_peShowNormal) _peSweep.addAll(rest);
                    }),
                    child: SizedBox(
                      height: 44.0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.done_all_rounded,
                                size: 18.0, color: _blue),
                            const SizedBox(width: 8.0),
                            Text(
                                '${ros ? 'ที่เหลือไม่มีอาการ' : 'ที่เหลือปกติ'} (${rest.length} ระบบ)',
                                style: _t(13.0,
                                    color: _blue, weight: FontWeight.w600)),
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          // ระบบปกติซ่อนไว้ (แตะกาง/ซ่อน)
          if (normal.isNotEmpty) _peNormalSummary(normal, ros: ros),
          // แถวตั้งค่าแบบ Google: ชื่อระบบซ้าย ตัวเลือกขวา คั่นด้วยเส้นบาง
          for (final (i, f) in systems.indexed)
            _peSweepRow(
                f,
                hidden: known[f] == 'ปกติ' && !_peShowNormal,
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: _glow.contains(f)
                        ? _blue.withValues(alpha: 0.06)
                        : null,
                    border: i == 0
                        ? null
                        : const Border(
                            top: BorderSide(color: Color(0xFFE8EAED))),
                  ),
                  // ผิดปกติ: ช่องกรอกรายละเอียดกางใต้แถวในหน้าเดียวกัน
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(ros ? f.substring(4) : f,
                                style: _t(14.5,
                                    color: _needsDetail(_speechStep, f)
                                        ? _red
                                        : _inkTitle,
                                    weight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 8.0),
                          _peOpts(f, items[f] ?? '', known[f]),
                        ]),
                        if (known[f] == 'ผิดปกติ')
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 2.0),
                            child: _detailBox(f),
                          ),
                      ],
                    ),
                  ),
                )),
          // ประวัติการตรวจครั้งก่อน: ปุ่มข้อความท้ายรายการ (ไม่แย่งปุ่มหลักหัวหน้า)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showPeHistory(ros: ros),
              icon: const Icon(Icons.history_rounded, size: 18.0),
              label: Text('ดูประวัติการตรวจ',
                  style: _t(13.0, color: _blue, weight: FontWeight.w600)),
              style: TextButton.styleFrom(foregroundColor: _blue),
            ),
          ),
        ],
      ),
    );
  }

  /// แถวที่เพิ่งเลือกปกติ: แถบเขียวไล่จากซ้ายไปขวา แล้วยุบแถวหายไป
  Widget _peSweepRow(String f, Widget row, {bool hidden = false}) {
    // key คงที่ต่อระบบ: แถวอื่นไม่สลับ state กันตอนแถวนี้หายไป (ปุ่มไม่กะพริบ)
    final key = ValueKey('pe-row-$f');
    // ซ่อน/กางแถวปกติ (ปุ่มแก้ไข/ซ่อน) ยุบ-ขยายนุ่ม ๆ ไม่กระโดด
    if (!_peSweep.contains(f)) {
      return AnimatedSize(
        key: key,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        child:
            hidden ? const SizedBox(width: double.infinity, height: 0.0) : row,
      );
    }
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1100),
      onEnd: () {
        if (mounted) setState(() => _peSweep.remove(f));
      },
      builder: (context, t, child) {
        double seg(double a, double b, Curve c) =>
            c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
        // เติมเขียว → เนื้อหาจางออกตามแถบ → แถวยุบนุ่ม ๆ ต่อเนื่องไม่มีจังหวะหยุด
        final fill = seg(0.0, 0.45, Curves.easeInOutCubic);
        final fade = seg(0.25, 0.55, Curves.easeOut);
        final shrink = seg(0.5, 1.0, Curves.easeInOutCubic);
        final gone = seg(0.8, 1.0, Curves.easeOut);
        return ClipRect(
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1.0 - shrink,
            child: Stack(children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 1.0 - gone,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fill,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(8.0)),
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(opacity: 1.0 - fade, child: child),
            ]),
          ),
        );
      },
      child: row,
    );
  }

  /// แถวสรุประบบที่ปกติ (ซ่อนไว้): แตะเพื่อกาง/ซ่อน
  Widget _peNormalSummary(List<String> ok, {bool ros = false}) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _peShowNormal = !_peShowNormal),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, size: 18.0, color: _green),
              const SizedBox(width: 8.0),
              // ที่แคบ (ปุ่มที่เหลือปกติกินที่): ตัวนับย่อด้วย … ไม่ล้น
              Expanded(
                child: Text('${ros ? 'ไม่มีอาการ' : 'ปกติ'} ${ok.length} ระบบ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(12.5, color: _green, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 8.0),
              Text(_peShowNormal ? 'ซ่อน' : 'แก้ไข',
                  style: _t(11.5, color: _blue, weight: FontWeight.w700)),
            ]),
          ),
        ),
      );

  /// หน้า 2 ของตรวจร่างกาย: บันทึกการตรวจแบบละเอียด
  /// ตรวจแบบละเอียด: การ์ดแบบ Diagnosis Text (หัวข้อ คำอธิบาย ภาพประกอบ)
  /// แผ่นปุ่มลัด เพิ่ม/แก้ไข (เข้าหน้าย่อยพิมพ์) · เทมเพลต · ดูประวัติ · บันทึกแล้วแสดงเป็นแถว
  Widget _peNotePage(String hint) {
    if (_peNoteEdit) {
      // หน้าย่อย: ช่องพิมพ์ rich text เต็มหน้า (หัวแผง = breadcrumb · footer = ย้อนกลับ | บันทึก)
      return _notePage(_peNoteLabel, _peNoteLabel, hint);
    }
    final note = (_filled[_speechStep][_peNoteLabel] ?? '').trim();
    final by = _byMap(_peNoteLabel)['note'];
    final at = _atMap(_peNoteLabel)['note'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 96.0),
      children: [
        _dxCard(
          'ตรวจแบบละเอียด',
          'ผลตรวจเพิ่มเติมแบบพิมพ์อิสระ ไม่บังคับ',
          _dxArtFade(const _ExamHero()),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _dxTiles([
              (Icons.add_rounded, 'เพิ่ม', _peNoteOpen),
              (Icons.post_add_rounded, 'เทมเพลต', _pePickSheet),
              (Icons.history_rounded, 'ดูประวัติ', _showPeHistory),
            ]),
            if (note.isNotEmpty)
              _gListRow(
                first: true,
                inset: 8.0,
                titleLines: 3,
                title: note,
                sub: [
                  if (by != null) by,
                  if (at != null) _clock(at),
                ].join('  '),
                onTap: _peNoteOpen,
                trail: IconButton(
                  onPressed: _peNoteOpen,
                  tooltip: 'แก้บันทึกการตรวจ',
                  iconSize: 20.0,
                  constraints:
                      const BoxConstraints(minWidth: 40.0, minHeight: 40.0),
                  icon: const Icon(Icons.edit_outlined, color: _ink3),
                ),
              ),
            const SizedBox(height: 8.0),
          ]),
        ),
      ],
    );
  }

  /// เปิดหน้าย่อยพิมพ์ตรวจแบบละเอียด (เก็บค่าเดิมไว้คืนเมื่อกดย้อนกลับ)
  void _peNoteOpen() => setState(() {
        _formFwd = true;
        _peNoteBackup = _filled[_speechStep][_peNoteLabel];
        _peNoteEdit = true;
      });

  /// หน้าย่อยตรวจแบบละเอียดเปิดอยู่ (หัวแผงเป็น breadcrumb · footer เป็นปุ่มของหน้าย่อย)
  bool get _peNoteNested => _peNoteEdit && _isPeStep(_speechStep);

  /// บันทึก: ปิดหน้าย่อย + ลงผู้เขียน/เวลา (แบบแถว Doctor Note)
  void _peNoteSave() => setState(() {
        _peNoteEdit = false;
        final who = ErSession.instance.user?.name;
        final text = (_filled[_speechStep][_peNoteLabel] ?? '').trim();
        if (who == null || text.isEmpty) return;
        final now = DateTime.now();
        final hm =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        _filled[_speechStep]['$_peNoteLabel - by'] = 'note\t$who\t$hm';
      });

  void _peNoteCancel() => setState(() {
        final b = _peNoteBackup;
        if (b == null || b.trim().isEmpty) {
          _filled[_speechStep].remove(_peNoteLabel);
        } else {
          _filled[_speechStep][_peNoteLabel] = b;
        }
        _inlineCtl['$_speechStep|$_peNoteLabel']?.text = b ?? '';
        _peNoteEdit = false;
      });

  Widget _peNoteCrumb() => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 6.0, 16.0, 6.0),
        child: Row(children: [
          InkWell(
            onTap: _peNoteCancel,
            borderRadius: BorderRadius.circular(100.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('ตรวจแบบละเอียด',
                  style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
          const SizedBox(width: 4.0),
          Flexible(
            child: Text(
                (_peNoteBackup ?? '').trim().isEmpty
                    ? 'เพิ่มบันทึกการตรวจ'
                    : 'แก้บันทึกการตรวจ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
        ]),
      );

  /// หน้ากรอกข้อความยาวในการ์ดหัวกรมท่า (ตรวจแบบละเอียด / HPI):
  /// การ์ดขาว หัวข้อ + ช่องพิมพ์เริ่ม 1 บรรทัด สูงตามข้อความ
  Widget _notePage(String label, String title, String hint,
          {VoidCallback? onTemplate,
          VoidCallback? onHistory,
          bool bare = false}) =>
      // design language ปัจจุบัน: ไม่มีการ์ดครอบ/หัวซ้ำ (หัวหน้าอยู่ใน _peShell แล้ว)
      // ช่องพิมพ์ = แผ่นขาวขอบบาง 0.5 มุม 16 · แถบเครื่องมือขาว คั่นเส้นบาง
      Padding(
        padding: bare
            ? const EdgeInsets.only(bottom: 0.0)
            : const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 96.0),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child: Stack(children: [
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              height: 44.0,
              child: _richToolbar(label,
                  onTemplate: onTemplate, onHistory: onHistory),
            ),
            Positioned.fill(
              top: 44.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 28.0),
                child: _inlineInput(label, _filled[_speechStep][label],
                    hint: hint,
                    style: _t(14.0,
                        color: _inkTitle, weight: FontWeight.w500, height: 1.5),
                    hintStyle: _t(14.0, color: _ink3, height: 1.5),
                    fill: true,
                    rich: true,
                    maxLines: null),
              ),
            ),
            // จำนวนตัวอักษร มุมขวาล่าง
            Positioned(
              right: 14.0,
              bottom: 8.0,
              child: Text(
                  '${(_filled[_speechStep][label] ?? '').length} ตัวอักษร',
                  style: _num(11.0, color: _ink3)),
            ),
          ]),
        ),
      );

  /// แถบเครื่องมือ rich text: หนา · หัวข้อ · bullet · เลขลำดับ | เทมเพลต · ประวัติ
  /// อยู่ใน TextFieldTapRegion: แตะแล้วช่องไม่หลุดโฟกัส (คีย์บอร์ดไม่หุบ)
  Widget _richToolbar(String label,
      {VoidCallback? onTemplate, VoidCallback? onHistory}) {
    Widget btn(IconData icon, String tip, VoidCallback onTap) => Tooltip(
          message: tip,
          child: _Press(
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: onTap,
              child: SizedBox(
                width: 34.0,
                height: 34.0,
                child: Icon(icon, size: 19.0, color: _ink2),
              ),
            ),
          ),
        );
    return TextFieldTapRegion(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        decoration: const BoxDecoration(
          color: _panel,
          border:
              Border(bottom: BorderSide(color: Color(0xFFE8EAED), width: 0.5)),
        ),
        child: Material(
          color: Colors.transparent,
          child: Row(children: [
            btn(Icons.format_bold_rounded, 'ตัวหนา',
                () => _richWrap(label, '**')),
            btn(Icons.title_rounded, 'หัวข้อ',
                () => _richLinePrefix(label, (i) => '# ')),
            btn(Icons.format_list_bulleted_rounded, 'รายการ',
                () => _richLinePrefix(label, (i) => '• ')),
            btn(Icons.format_list_numbered_rounded, 'รายการลำดับเลข',
                () => _richLinePrefix(label, (i) => '${i + 1}. ')),
            if (onTemplate != null || onHistory != null)
              Container(
                  width: 1.0,
                  height: 20.0,
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: _line),
            if (onTemplate != null)
              btn(Icons.post_add_rounded, 'เลือกเทมเพลต', onTemplate),
            if (onHistory != null)
              btn(Icons.history_rounded, 'ดูประวัติ', onHistory),
          ]),
        ),
      ),
    );
  }

  /// ใส่ค่าใหม่ลงช่อง + เก็บลง _filled + คงโฟกัสไว้
  void _richSet(String label, String text, TextSelection sel) {
    final c = _inlineCtl['$_speechStep|$label'];
    if (c == null) return;
    c.value = TextEditingValue(text: text, selection: sel);
    setState(() {
      if (label == 'HPI') _hpiManual = true;
      if (text.trim().isEmpty) {
        _filled[_speechStep].remove(label);
      } else {
        _filled[_speechStep][label] = text;
      }
    });
    _inlineFocusOf(label).requestFocus();
  }

  /// ครอบข้อความที่เลือกด้วยเครื่องหมาย (ตัวหนา) · ไม่ได้เลือก = ใส่คู่แล้ววางเคอร์เซอร์ตรงกลาง
  /// เลือกคำที่หนาอยู่แล้ว = เอาตัวหนาออก
  void _richWrap(String label, String mark) {
    final c = _inlineCtl['$_speechStep|$label'];
    if (c == null) return;
    final t = c.text;
    var sel = c.selection;
    if (!sel.isValid) sel = TextSelection.collapsed(offset: t.length);
    final a = sel.start, b = sel.end;
    final inner = t.substring(a, b);
    if (inner.length >= mark.length * 2 &&
        inner.startsWith(mark) &&
        inner.endsWith(mark)) {
      final un = inner.substring(mark.length, inner.length - mark.length);
      _richSet(label, t.replaceRange(a, b, un),
          TextSelection(baseOffset: a, extentOffset: a + un.length));
      return;
    }
    final out = '$mark$inner$mark';
    _richSet(
        label,
        t.replaceRange(a, b, out),
        inner.isEmpty
            ? TextSelection.collapsed(offset: a + mark.length)
            : TextSelection(baseOffset: a, extentOffset: a + out.length));
  }

  /// ใส่/เอาออก เครื่องหมายต้นบรรทัด (หัวข้อ · bullet · เลขลำดับ) ทุกบรรทัดที่เลือก
  void _richLinePrefix(String label, String Function(int i) prefix) {
    final c = _inlineCtl['$_speechStep|$label'];
    if (c == null) return;
    final t = c.text;
    var sel = c.selection;
    if (!sel.isValid) sel = TextSelection.collapsed(offset: t.length);
    final start = sel.start == 0 ? 0 : t.lastIndexOf('\n', sel.start - 1) + 1;
    var end = t.indexOf('\n', sel.end);
    if (end < 0) end = t.length;
    final lines = t.substring(start, end).split('\n');
    final any = RegExp(r'^(# |• |\d+\. )');
    final p0 = prefix(0);
    bool has(String l) => p0 == '# '
        ? l.startsWith('# ')
        : p0 == '• '
            ? l.startsWith('• ')
            : RegExp(r'^\d+\. ').hasMatch(l);
    // ทุกบรรทัดเป็นแบบนี้อยู่แล้ว = เอาออก · ไม่งั้นเปลี่ยนเป็นแบบนี้
    final remove = lines.every(has);
    final out = [
      for (var i = 0; i < lines.length; i++)
        remove
            ? lines[i].replaceFirst(any, '')
            : '${prefix(i)}${lines[i].replaceFirst(any, '')}'
    ].join('\n');
    _richSet(label, t.replaceRange(start, end, out),
        TextSelection.collapsed(offset: start + out.length));
  }

  /// ตัวเลือกของระบบในหน้ารวม: ชิปแถวเดียว (ปกติ/ผิดปกติ/ไม่ได้ตรวจ)
  /// ระบบที่มีช่องย่อย (Neuro: GCS รูม่านตา) ใช้การ์ดช่องเดิม
  Widget _peOpts(String f, String hint, String? value) {
    final opts = _fieldOptions(f, hint);
    if (opts.isEmpty || _fieldGroups(f).length > 1) {
      return _guideFieldCard(f, hint, value, true, big: true);
    }
    // segmented แบบ Google: ปุ่มต่อกันในแคปซูลเดียว · ไอคอนชุดเดียวกับตารางประวัติการตรวจ
    // ยังไม่เลือก = ไอคอนเส้นเทา · เลือกแล้ว = ไอคอนทึบสีสถานะ + พื้นจาง (สีโผล่เมื่อเลือกเท่านั้น)
    (IconData, IconData, Color) look(String o) => switch (o) {
          'ปกติ' => (
              Icons.check_circle_outline_rounded,
              Icons.check_circle_rounded,
              _green
            ),
          'ผิดปกติ' => (Icons.error_outline_rounded, Icons.error_rounded, _red),
          'ไม่ได้ตรวจ' => (
              Icons.remove_circle_outline_rounded,
              Icons.remove_circle_rounded,
              _ink2
            ),
          _ => (Icons.circle_outlined, Icons.circle, _ink2),
        };
    return Container(
      height: 38.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final (i, o) in opts.indexed) ...[
          if (i > 0) Container(width: 1.0, color: const Color(0xFFDADCE0)),
          Tooltip(
            message: o,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() {
                  _lastFilled = [(_speechStep, f, value)];
                  _filled[_speechStep][f] = o;
                  // กางแถวปกติอยู่ (โหมดแก้ไข): ไม่เล่นแถบเขียว/ไม่ซ่อน แถวคงอยู่ให้แก้ต่อ
                  if (o == 'ปกติ' && value != 'ปกติ' && !_peShowNormal) {
                    _peSweep.add(f);
                  }
                }),
                child: Builder(builder: (_) {
                  final on = o == value;
                  final (off, fill, col) = look(o);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52.0,
                    alignment: Alignment.center,
                    color:
                        on ? col.withValues(alpha: 0.12) : Colors.transparent,
                    child: Icon(on ? fill : off,
                        size: 20.0, color: on ? col : _ink3),
                  );
                }),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  /// เลือกเทมเพลตตรวจร่างกาย (แท็บบนการ์ด): แตะเพื่อเติมผลตามเทมเพลต
  Future<void> _pePickSheet() async {
    final picked = await _placedSheet<ErPeTemplate>(
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
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 12.0, 8.0),
            child: Row(children: [
              Expanded(
                child: Text('เลือกเทมเพลตตรวจร่างกาย',
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openPeTemplates();
                },
                child: Text('จัดการเทมเพลต',
                    style: _t(11.0, color: _ink3, weight: FontWeight.w600)),
              ),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 16.0),
              itemCount: _peTemplates.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1.0, color: _line),
              itemBuilder: (_, i) {
                final t = _peTemplates[i];
                return InkWell(
                  onTap: () => Navigator.pop(ctx, t),
                  borderRadius: BorderRadius.circular(12.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(t.name,
                              style: _t(13.0,
                                  color: _inkTitle, weight: FontWeight.w700)),
                          if (_peTplUsed == t.name) ...[
                            const SizedBox(width: 8.0),
                            const Icon(Icons.check_circle_rounded,
                                size: 14.0, color: _blue),
                          ],
                        ]),
                        const SizedBox(height: 4.0),
                        Text(
                            [
                              for (final e in t.values.entries)
                                if (!e.key.contains(' - '))
                                  '${e.key} ${e.value}'
                            ].join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _t(11.0, color: _ink2, height: 1.4)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _applyPeTemplate(picked);
      _peTplUsed = picked.name;
    });
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

  /// ขั้นตรวจร่างกายของบทบาทที่ login (แพทย์ 2 · พยาบาล 8 · ไม่มี = 2 แบบเดิม)
  int get _peStep {
    final i = _steps.indexWhere((s) => s.$2 == 'ตรวจร่างกาย');
    return i < 0 ? 2 : i;
  }

  /// แพทย์และพยาบาลมีขั้นตรวจร่างกาย (ฟอร์ม _peFields ชุดเดียวกัน)
  bool _isPeStep(int step) =>
      ErSession.instance.role != ErRole.triage &&
      step >= 0 &&
      step < _steps.length &&
      _steps[step].$2 == 'ตรวจร่างกาย';
}

// ------------------------------------------------ วาดภาพการตรวจร่างกาย

/// เส้นที่วาดบนภาพ · จุดเป็นสัดส่วน 0–1 ของกรอบวาด (ย่อ/ขยายกรอบแล้วเส้นอยู่ที่เดิม)
/// เครื่องมือวาด (โหมดวาดแบบละเอียด)
enum _PeTool { move, pen, marker, eraser, line, arrow, rect, oval, text }

/// ความหนาเส้นเป็นหน่วยของกรอบกว้าง 360 (ย่อ/ขยายตามกรอบจริง)
class _PeStroke {
  _PeStroke(this.color, this.width, this.pts,
      {this.tool = _PeTool.pen, this.text = ''});
  final Color color;
  final double width;
  final List<Offset> pts;
  final _PeTool tool;
  String text;
}

/// รูปที่แนบวางบนภาพ: จุดกลางและความกว้างเป็นสัดส่วนของกรอบ · aspect = สูง/กว้างของรูป
class _PeSticker {
  _PeSticker(this.bytes, this.c, this.w, this.aspect);
  final Uint8List bytes;
  Offset c;
  double w;
  final double aspect;
}

/// ภาพการตรวจร่างกายหนึ่งภาพ: พื้น (template / ภาพถ่าย / ว่าง) + เส้นที่วาด
class _PeShot {
  _PeShot(
      {required this.name,
      this.tpl,
      this.loc,
      this.photo,
      List<_PeStroke>? strokes,
      List<_PeSticker>? stickers,
      this.by = '',
      this.at = ''})
      : strokes = strokes ?? [],
        stickers = stickers ?? [];
  final String name;
  final String? tpl;

  /// บริเวณที่แตะเลือกบนหุ่น 3D (studio) ใช้เป็นตำแหน่งเมื่อภาพไม่บอกตำแหน่งเอง
  final String? loc;
  final Uint8List? photo;
  final List<_PeStroke> strokes;
  final List<_PeSticker> stickers;
  String by;
  String at;

  /// คำพูดตอนพูดเพื่อวาด (ใช้วิเคราะห์ว่าเครื่องหมายคืออะไร)
  List<String> said = [];

  /// รูปประกอบที่แนบใน studio
  List<Uint8List> attach = const [];

  /// ภาพย่อซูมที่แต่ละบริเวณ (studio) · หลายภาพ = สไลด์อัตโนมัติบนการ์ด
  List<Uint8List> focus = const [];

  /// ภาพซูมของแต่ละบริเวณ (ใช้แทนรูปแผลเมื่อบริเวณนั้นไม่ได้แนบรูป)
  Map<String, Uint8List> focusBy = const {};

  /// รูปประกอบ/รายละเอียดแยกตามบริเวณ (เปิดภาพ 3D กลับมาดู/แก้ใน studio)
  Map<String, List<Uint8List>> attachBy = const {};
  Map<String, String> notesBy = const {};

  /// รายละเอียดแยกตามเวลา ต่อบริเวณ: (ข้อความ, เวลา HH:MM, ผู้บันทึก) เก่า → ใหม่
  Map<String, List<(String, String, String)>> noteLogBy = const {};

  /// เส้นที่วาดบนหุ่น 3D (studio): [{id, color, r, bone, pts}] แสดงบนหุ่นหน้าผู้ป่วย
  List<Map<String, Object?>> d3 = const [];

  /// ผลวิเคราะห์ภาพ: (รหัสบนหุ่น 3D, skin|bone|organ, คำสั้น ๆ, ตำแหน่งภาษาไทย)
  List<(String, String, String, String)> findings = const [];

  /// รหัสที่หุ่น 3D ไฮไลต์ (erHighlight: zone:/bone:/อวัยวะ)
  List<String> get codes => {for (final f in findings) f.$1}.toList();

  _PeShot copy() => _PeShot(
          name: name,
          tpl: tpl,
          loc: loc,
          photo: photo,
          by: by,
          at: at,
          strokes: [
            for (final s in strokes)
              _PeStroke(s.color, s.width, [...s.pts],
                  tool: s.tool, text: s.text)
          ],
          stickers: [
            for (final k in stickers) _PeSticker(k.bytes, k.c, k.w, k.aspect)
          ])
        ..said = [...said]
        ..focus = focus
        ..focusBy = focusBy
        ..d3 = d3
        ..findings = findings;
}

/// mock ภาพตรวจร่างกายเริ่มต้น: ใส่ครั้งเดียวต่อการเปิดแอป
bool _peSeeded = false;
const String _peSeedHn = '670123469';

/// ภาพการตรวจร่างกายของผู้ป่วยแต่ละคน (HN → รายการภาพ)
final Map<String, List<_PeShot>> _peShots = {};

/// ภาพที่กำลังวาด (null = ไม่ได้อยู่หน้าวาด) · ลำดับในรายการ (-1 = ภาพใหม่)
_PeShot? _peDraft;
int _peDraftAt = -1;

/// เปิดหน้าเลือกภาพจาก Template
bool _peTplOpen = false;

/// สีปากกาที่เลือก
Color _pePen = const Color(0xFFD93025);

/// ภาพ Template (render จาก BodyParts3D ตามชุดภาพ pe_image_list ของ HOSxP) แบ่งหมวด
/// (ชื่อหมวด, [(ชื่อภาพ, เลขภาพ HOSxP)])
const List<(String, List<(String, String)>)> _peTplGroups = [
  (
    'ทั้งตัว',
    [
      ('ชาย', '30'),
      ('หญิง', '09'),
      ('หน้า-หลัง', '01'),
      ('Body chart', '02'),
      ('Rule of nines 1', '38'),
      ('Rule of nines 2', '39'),
      ('Rule of nines 3', '40'),
    ]
  ),
  (
    'ศีรษะและใบหน้า',
    [
      ('ศีรษะ 1', '11'),
      ('ศีรษะ 2', '12'),
      ('ศีรษะ 3', '13'),
      ('ศีรษะ 4', '14'),
      ('ศีรษะ 5', '15'),
      ('ตา', '41'),
      ('ตาซ้าย', '07'),
      ('ตาขวา', '08'),
      ('จมูก', '31'),
    ]
  ),
  (
    'แขนและมือ',
    [
      ('ไหล่', '42'),
      ('มือซ้าย 1', '24'),
      ('มือซ้าย 2', '25'),
      ('มือซ้าย 3', '26'),
      ('มือซ้าย 4', '27'),
      ('มือขวา 1', '34'),
      ('มือขวา 2', '35'),
      ('มือขวา 3', '36'),
      ('มือขวา 4', '37'),
    ]
  ),
  (
    'ขาและเท้า',
    [
      ('ข้อเท้าซ้าย', '19'),
      ('เท้าซ้าย 1', '20'),
      ('เท้าซ้าย 2', '21'),
      ('เท้าซ้าย 3', '22'),
      ('เท้าซ้าย 4', '23'),
      ('เท้าขวา 1', '32'),
      ('เท้าขวา 2', '33'),
    ]
  ),
  (
    'ช่องท้องและส่องกล้อง',
    [
      ('KUB', '16'),
      ('EGD', '06'),
      ('Colonoscopy', '03'),
    ]
  ),
];

String _peTplAsset(String id) => 'assets/images/er_pe_tpl_$id.png';

/// ตำแหน่งบนร่างกาย → (ชื่อไทย, heatmap ผิวหนัง, กระดูก, อวัยวะภายในที่อยู่ใต้ตำแหน่งนั้น)
/// ใช้เลือกการแสดงบนหุ่น 3D ตามชนิดความผิดปกติ (ผิวหนัง / กระดูก / อวัยวะ)
const Map<String, (String, String?, String?, List<String>)> _peLocs = {
  'head': ('ศีรษะ', 'zone:head', 'bone:skull', ['brain']),
  'throat': ('คอ', 'zone:throat', 'bone:cspine', []),
  'chest': ('หน้าอก', 'zone:chest', 'bone:sternum', ['heart', 'lungs']),
  'chest_r': ('อกขวา', 'zone:chest', 'bone:ribs_r', ['lungs']),
  'chest_l': ('อกซ้าย', 'zone:chest', 'bone:ribs_l', ['heart', 'lungs']),
  'epigastric': ('ลิ้นปี่', 'zone:epigastric', null, ['stomach']),
  'ruq': ('ท้องขวาบน', 'zone:ruq', 'bone:ribs_r', ['liver']),
  'luq': ('ท้องซ้ายบน', 'zone:luq', 'bone:ribs_l', ['stomach']),
  'abdomen': ('รอบสะดือ', 'zone:abdomen', null, ['intestine']),
  'rlq': ('ท้องขวาล่าง', 'zone:rlq', 'bone:pelvis', ['intestine']),
  'llq': ('ท้องซ้ายล่าง', 'zone:llq', 'bone:pelvis', ['intestine']),
  'suprapubic': (
    'เหนือหัวหน่าว',
    'zone:suprapubic',
    'bone:pelvis',
    ['bladder']
  ),
  'shoulder_r': ('ไหล่ขวา', 'zone:shoulder_r', 'bone:clavicle_r', []),
  'shoulder_l': ('ไหล่ซ้าย', 'zone:shoulder_l', 'bone:clavicle_l', []),
  'arm_r': ('ต้นแขนขวา', 'zone:arm_r', 'bone:humerus_r', []),
  'arm_l': ('ต้นแขนซ้าย', 'zone:arm_l', 'bone:humerus_l', []),
  'forearm_r': ('แขนท่อนล่างขวา', 'zone:forearm_r', 'bone:forearm_r', []),
  'forearm_l': ('แขนท่อนล่างซ้าย', 'zone:forearm_l', 'bone:forearm_l', []),
  'hand_r': ('มือขวา', 'zone:hand_r', 'bone:hand_r', []),
  'hand_l': ('มือซ้าย', 'zone:hand_l', 'bone:hand_l', []),
  'thigh_r': ('ต้นขาขวา', 'zone:thigh_r', 'bone:femur_r', []),
  'thigh_l': ('ต้นขาซ้าย', 'zone:thigh_l', 'bone:femur_l', []),
  'shin_r': ('ขาท่อนล่างขวา', 'zone:shin_r', 'bone:tibia_r', []),
  'shin_l': ('ขาท่อนล่างซ้าย', 'zone:shin_l', 'bone:tibia_l', []),
  'ankle_r': ('ข้อเท้าขวา', 'zone:foot_r', 'bone:ankle_r', []),
  'ankle_l': ('ข้อเท้าซ้าย', 'zone:foot_l', 'bone:ankle_l', []),
  'foot_r': ('เท้าขวา', 'zone:foot_r', 'bone:foot_r', []),
  'foot_l': ('เท้าซ้าย', 'zone:foot_l', 'bone:foot_l', []),
  'kub': (
    'ไตและทางเดินปัสสาวะ',
    'zone:lowback',
    'bone:lspine',
    ['kidneys', 'bladder']
  ),
  'egd': ('ทางเดินอาหารส่วนบน', 'zone:epigastric', null, ['stomach']),
  'colon': ('ลำไส้ใหญ่', 'zone:abdomen', null, ['intestine']),
};

/// ภาพ Template เฉพาะส่วน → ตำแหน่ง (ภาพทั้งตัว/ไหล่/ภาพถ่าย ไม่อยู่ในนี้)
const Map<String?, String> _peTplLoc = {
  '11': 'head',
  '12': 'head',
  '13': 'head',
  '14': 'head',
  '15': 'head',
  '41': 'head',
  '07': 'head',
  '08': 'head',
  '31': 'head',
  '24': 'hand_l',
  '25': 'hand_l',
  '26': 'hand_l',
  '27': 'hand_l',
  '34': 'hand_r',
  '35': 'hand_r',
  '36': 'hand_r',
  '37': 'hand_r',
  '19': 'ankle_l',
  '20': 'foot_l',
  '21': 'foot_l',
  '22': 'foot_l',
  '23': 'foot_l',
  '32': 'foot_r',
  '33': 'foot_r',
  '16': 'kub',
  '06': 'egd',
  '03': 'colon',
};

/// ตำแหน่งบนภาพร่างกายด้านหน้า (Template 30 ชาย / 09 หญิง ขนาด 800×900)
/// p = พิกัด 0–1 ของภาพ · ซ้ายของภาพ = ขวาของผู้ป่วย (_r)
String? _peFrontLoc(Offset p, {bool female = false}) {
  final x = p.dx, y = p.dy;
  if (x < 0 || x > 1 || y < 0 || y > 1) return null;
  final dx = x - 0.5;
  final side = dx < 0 ? 'r' : 'l';
  // ครึ่งความกว้างลำตัว (หญิง: เอวคอด สะโพกผาย)
  final hw = female ? (y < 0.5 ? 0.215 : 0.245) : 0.235;
  if (y < 0.10) return 'head';
  if (y < 0.15 && dx.abs() < 0.12) return 'throat';
  if (dx.abs() > hw) {
    // แขน: ไหล่ → ต้นแขน → ข้อศอก ~0.55 → ปลายแขน → มือ ~0.78
    if (y < 0.24) return 'shoulder_$side';
    if (y < 0.55) return 'arm_$side';
    if (y < 0.78) return 'forearm_$side';
    return 'hand_$side';
  }
  if (y < 0.42) return dx.abs() < 0.08 ? 'chest' : 'chest_$side';
  if (y < 0.55) {
    return dx.abs() < 0.07 ? 'epigastric' : (side == 'r' ? 'ruq' : 'luq');
  }
  if (y < 0.88) {
    if (dx.abs() < 0.07) return y < 0.75 ? 'abdomen' : 'suprapubic';
    return side == 'r' ? 'rlq' : 'llq';
  }
  return 'thigh_$side';
}

/// รหัสที่หุ่น 3D ไฮไลต์ได้ (กระดูก · ผิวหนังเป็นบริเวณ · อวัยวะ)
const List<String> _peBodyCodes = [
  'bone:skull', 'bone:cspine', 'bone:tspine', 'bone:lspine', 'bone:pelvis',
  'bone:sternum', 'bone:ribs_l', 'bone:ribs_r', 'bone:clavicle_l',
  'bone:clavicle_r', 'bone:scapula_l', 'bone:scapula_r', 'bone:humerus_l',
  'bone:humerus_r', 'bone:forearm_l', 'bone:forearm_r', 'bone:hand_l',
  'bone:hand_r', 'bone:femur_l', 'bone:femur_r', 'bone:knee_l', 'bone:knee_r',
  'bone:tibia_l', 'bone:tibia_r', 'bone:ankle_l', 'bone:ankle_r',
  'bone:foot_l', 'bone:foot_r', //
  'zone:head', 'zone:throat', 'zone:chest', 'zone:epigastric', 'zone:ruq',
  'zone:luq', 'zone:abdomen', 'zone:rlq', 'zone:llq', 'zone:suprapubic',
  'zone:flank_r', 'zone:flank_l', 'zone:lowback', //
  'brain', 'heart', 'lungs', 'liver', 'stomach', 'kidneys', 'intestine',
  'bladder',
];

/// สีปากกา: แดง (ผิดปกติ/แผล) · กรมท่า · ดำ
const List<Color> _pePens = [
  Color(0xFFD93025),
  Color(0xFF1A3A8B),
  Color(0xFF202124),
];

extension _FeaturesWorkflowPeDrawPart on _ErFlowHomeWidgetState {
  List<_PeShot> get _peShotList {
    _peSeedOnce();
    return _peShots.putIfAbsent(_caseP().hn, () => []);
  }

  /// mock: เคสอุบัติเหตุ A1 (HN 670123469) มีภาพตรวจร่างกายจากแพทย์อยู่แล้ว
  /// หมุด ศีรษะ + ต้นขาขวา · ภาพย่อซูมที่จุด · รูปแผล · รายละเอียดมีเวลา
  void _peSeedOnce() {
    if (_peSeeded) return;
    _peSeeded = true;
    () async {
      Future<Uint8List> a(String p) async =>
          (await rootBundle.load('assets/images/wound/$p'))
              .buffer
              .asUint8List();
      try {
        final day = _peNowStamp().split(' ').first;
        // (ผู้บันทึก, เวลา, [(บริเวณ, จุดบนหุ่น, รายละเอียด, รูปแผล)], ภาพซูม)
        final seeds = [
          (
            'นพ. ธีรภัทร อมรเลิศ',
            '$day 07:50',
            [
              (
                'head',
                {
                  'id': 'seed-t-head',
                  'bone': 'Head',
                  'pts': [
                    [-0.5025, 1.8019, 0.0478]
                  ]
                },
                'แผลฉีกขาดหนังศีรษะ เลือดออก กดห้ามเลือดไว้ รอเย็บ',
                ['wound_1.jpg'],
              ),
              (
                'l-leg',
                {
                  'id': 'seed-t-leg',
                  'bone': 'Hip.L',
                  'pts': [
                    [-0.3364, 0.4067, 0.0614]
                  ]
                },
                'แผลถลอกหน้าแข้งซ้าย 4x2 cm มีเศษดินติด ล้างแผลแล้ว',
                <String>[],
              ),
            ],
            ['pe_seed_head.jpg', 'pe_seed_shin.jpg'],
          ),
          (
            'พญ. ศิริพร กิตติวงศ์',
            '$day 08:20',
            [
              (
                'head',
                {
                  'id': 'seed-s-head',
                  'bone': 'Head',
                  'pts': [
                    [-0.5025, 1.8019, 0.0478]
                  ]
                },
                'แผลฉีกขาดหนังศีรษะด้านหน้า ยาว 3 cm ขอบไม่เรียบ มีเลือดซึม',
                ['wound_1.jpg', 'wound_3.jpg'],
              ),
              (
                'r-thigh',
                {
                  'id': 'seed-s-thigh',
                  'bone': 'Hip.R',
                  'pts': [
                    [-0.6069, 0.7624, 0.1074]
                  ]
                },
                'ต้นขาขวาผิดรูป บวม กดเจ็บมาก ขยับไม่ได้ ชีพจรปลายเท้าคลำได้',
                ['wound_2.jpg'],
              ),
            ],
            ['pe_seed_head.jpg', 'pe_seed_thigh.jpg'],
          ),
        ];
        final shots = <_PeShot>[];
        for (final (by, at, regs, focusFiles) in seeds) {
          final photos = <String, List<Uint8List>>{};
          for (final (r, _, _, files) in regs) {
            photos[r] = [for (final f in files) await a(f)];
            for (final b in photos[r]!) {
              _peAttachMeta[b] = (at, by);
            }
          }
          final focus = [for (final f in focusFiles) await a(f)];
          final focusBy = {
            for (final (k, r) in regs.indexed)
              if (k < focus.length) r.$1: focus[k]
          };
          shots.add(_PeShot(
              name: [for (final r in regs) _peName(r.$1)].join(' '),
              photo: focus.first,
              by: by,
              at: at)
            ..said = [for (final r in regs) '${_peName(r.$1)}: ${r.$3}']
            ..attach = [for (final l in photos.values) ...l]
            ..focus = focus
            ..focusBy = focusBy
            ..notesBy = {for (final r in regs) r.$1: r.$3}
            ..attachBy = photos
            ..noteLogBy = {
              for (final r in regs) r.$1: [(r.$3, at, by)]
            }
            ..d3 = [
              for (final r in regs)
                {...r.$2, 'color': '#d93025', 'r': 0.003, 'region': r.$1}
            ]);
        }
        if (!mounted) return;
        setState(() =>
            _peShots.putIfAbsent(_peSeedHn, () => []).insertAll(0, shots));
      } catch (e) {
        debugPrint('PE seed: $e');
      }
    }();
  }

  /// หน้าย่อยของหน้าวาดภาพเปิดอยู่ (หัวแผงเป็น breadcrumb · footer เป็นปุ่มของหน้าย่อย)
  bool get _peDrawNested {
    if (!_isPeStep(_speechStep) || (_peDraft == null && !_peTplOpen)) {
      return false;
    }
    final pgs = _pePages([for (final (l, _) in _forms[_speechStep]) l]);
    return _formAt == pgs.indexOf('draw');
  }

  void _peOpenDraw(_PeShot s, {int at = -1}) => setState(() {
        _formFwd = true;
        _peDraft = s.copy();
        _peDraftAt = at;
        _peTplOpen = false;
      });

  void _peDrawClose() => setState(() {
        _formFwd = false;
        _peDraft = null;
        _peTplOpen = false;
      });

  /// ถ่ายภาพ / นำเข้าภาพ แล้วเปิดหน้าวาดทับภาพนั้น
  Future<void> _pePick(ImageSource src) async {
    try {
      final f = await ImagePicker()
          .pickImage(source: src, maxWidth: 1600, imageQuality: 85);
      if (f == null || !mounted) return;
      final bytes = await f.readAsBytes();
      if (!mounted) return;
      _peOpenDraw(_PeShot(
          name: src == ImageSource.camera ? 'ภาพถ่าย' : 'ภาพนำเข้า',
          photo: bytes));
    } catch (_) {
      if (mounted) {
        _wfToast(
            src == ImageSource.camera
                ? 'เปิดกล้องไม่ได้ในเครื่องนี้'
                : 'เปิดคลังภาพไม่ได้',
            error: true);
      }
    }
  }

  void _peDrawSave() {
    final d = _peDraft;
    if (d == null) return;
    final now = DateTime.now();
    d
      ..by = ErSession.instance.user?.name ?? ''
      ..at =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final list = _peShotList;
    setState(() {
      if (_peDraftAt >= 0 && _peDraftAt < list.length) {
        list[_peDraftAt] = d;
      } else {
        list.add(d);
      }
      _formFwd = false;
      _peDraft = null;
      // แผงซ้ายไปแท็บตรวจร่างกาย (PE) ให้เห็นภาพที่เพิ่งบันทึก
      _detailTab = 2;
      _examMode = 1;
    });
    _wfToast('บันทึกภาพแล้ว');
    // ส่วนของร่างกายที่วาดไว้ → ไฮไลต์บนหุ่น 3D
    _peSyncShot(d);
  }

  Future<void> _peDrawDelete() async {
    if (!await _askDelete(
        'ลบภาพนี้?', 'ภาพที่วาดและหมุดบนภาพนี้จะหายทั้งหมด', 'ลบภาพ')) {
      return;
    }
    if (!mounted) return;
    final list = _peShotList;
    setState(() {
      if (_peDraftAt >= 0 && _peDraftAt < list.length)
        list.removeAt(_peDraftAt);
      _formFwd = false;
      _peDraft = null;
    });
  }

  /// วิเคราะห์ภาพที่วาด แล้วให้หุ่น 3D แสดงตามชนิดความผิดปกติ
  /// 1) หาตำแหน่งของแต่ละเครื่องหมาย (ภาพเฉพาะส่วน = ตำแหน่งของภาพ ·
  ///    ภาพชาย/หญิงด้านหน้า = แบ่งบริเวณจากพิกัด)
  /// 2) ข้อความกำกับใกล้เครื่องหมาย + คำพูดตอนพูดเพื่อวาด → AI ตัดสินว่าเป็น
  ///    ผิวหนัง (heatmap) · กระดูก (ชิ้นนั้นเรืองทะลุผิว) · อวัยวะภายใน
  ///    ไม่มีข้อความ = ผิวหนัง (วงบนภาพส่วนใหญ่คือแผล/รอยช้ำ/จุดกดเจ็บ)
  /// ภาพอื่น (Body chart, Rule of nines, ไหล่, ภาพถ่าย) = ให้ AI ดูภาพ + พิกัดเลือกรหัสเอง
  Future<void> _peSyncShot(_PeShot s) async {
    final shapes = [
      for (final k in s.strokes)
        if (k.tool != _PeTool.eraser &&
            k.tool != _PeTool.text &&
            k.pts.isNotEmpty)
          k
    ];
    final texts = [
      for (final k in s.strokes)
        if (k.tool == _PeTool.text && k.text.trim().isNotEmpty) k
    ];
    if (shapes.isEmpty && texts.isEmpty) {
      if (mounted) setState(() => s.findings = const []);
      return;
    }
    Offset lo(List<Offset> p) =>
        p.reduce((a, b) => Offset(math.min(a.dx, b.dx), math.min(a.dy, b.dy)));
    Offset hi(List<Offset> p) =>
        p.reduce((a, b) => Offset(math.max(a.dx, b.dx), math.max(a.dy, b.dy)));
    Offset mid(_PeStroke k) => k.tool == _PeTool.text
        ? k.pts.first
        : Offset.lerp(lo(k.pts), hi(k.pts), 0.5)!;
    // ข้อความกำกับ: ข้อความที่ใกล้เครื่องหมายนั้นที่สุด (ภายใน 0.22 ของกรอบ)
    // ข้อความที่ไม่มีเครื่องหมายใกล้ = เป็นเครื่องหมายเอง
    final labels = <_PeStroke, List<String>>{for (final k in shapes) k: []};
    final marks = [...shapes];
    for (final t in texts) {
      _PeStroke? near;
      var best = 0.22;
      for (final k in shapes) {
        final d = (mid(k) - t.pts.first).distance;
        if (d < best) {
          best = d;
          near = k;
        }
      }
      if (near != null) {
        labels[near]!.add(t.text.trim());
      } else {
        marks.add(t);
        labels[t] = [t.text.trim()];
      }
    }
    try {
      Uint8List? img;
      var mime = 'image/png';
      if (s.tpl != null) {
        img = (await rootBundle.load(_peTplAsset(s.tpl!))).buffer.asUint8List();
      } else if (s.photo != null) {
        img = s.photo;
        mime = 'image/jpeg';
      }
      var aspect = 4 / 3;
      if (img != null) {
        final im = await decodeImageFromList(img);
        aspect = im.height / im.width;
      }
      // พิกัดกรอบวาด → พิกัดภาพ (ผกผันของการวางภาพแบบ contain + ขอบ _peBgPad)
      const pad = _peBgPad;
      final innerW = 1 - 2 * pad, innerH = 4 / 3 - 2 * pad;
      final sc = math.min(innerW, innerH / aspect);
      final iw = sc, ih = sc * aspect;
      final ox = pad + (innerW - iw) / 2, oy = pad + (innerH - ih) / 2;
      Offset inImg(Offset o) =>
          Offset((o.dx - ox) / iw, (o.dy * 4 / 3 - oy) / ih);
      String? locOf(_PeStroke k) =>
          _peTplLoc[s.tpl] ??
          (const {'30', '09'}.contains(s.tpl)
              ? _peFrontLoc(inImg(mid(k)), female: s.tpl == '09')
              : null) ??
          s.loc;
      final locs = [for (final k in marks) locOf(k)];
      final about = [s.name, ...s.said].join(' · ');

      final out = <(String, String, String, String)>[];
      if (locs.every((l) => l != null)) {
        // รู้ตำแหน่งครบ: ให้ AI ตัดสินแค่ชนิด (ไม่มีข้อความเลย = ผิวหนังทั้งหมด)
        final hasWords =
            s.said.isNotEmpty || labels.values.any((v) => v.isNotEmpty);
        var kinds = <int, (String, String, String)>{};
        if (hasWords) kinds = await _peAskKinds(marks, locs, labels, about);
        for (final (i, k) in marks.indexed) {
          final loc = _peLocs[locs[i]]!;
          // ไม่มีข้อความกำกับและไม่ได้พูด = ผิวหนัง (heatmap) ไม่เดาเอง
          final own = labels[k]!.isNotEmpty || s.said.isNotEmpty;
          final (kind, organ, label) =
              (own ? kinds[i] : null) ?? ('skin', '', labels[k]!.join(' '));
          final code = switch (kind) {
            'bone' => loc.$3 ?? loc.$2,
            'organ' => loc.$4.contains(organ)
                ? organ
                : (_peBodyCodes.contains(organ)
                    ? organ
                    : (loc.$4.isEmpty ? loc.$2 : loc.$4.first)),
            _ => loc.$2,
          };
          if (code == null) continue;
          out.add((code, kind, label, loc.$1));
        }
      } else if (img != null) {
        // ภาพที่ไม่รู้ตำแหน่ง: AI ดูภาพ + พิกัด + ข้อความ แล้วเลือกรหัสและชนิดเอง
        String pt(Offset o) {
          final q = inImg(o);
          return '(${q.dx.clamp(0.0, 1.0).toStringAsFixed(2)},'
              '${q.dy.clamp(0.0, 1.0).toStringAsFixed(2)})';
        }

        final desc = [
          for (final (i, k) in marks.indexed)
            '$i. ${k.tool.name} ที่ ${pt(mid(k))}'
                '${labels[k]!.isEmpty ? '' : ' ข้อความ "${labels[k]!.join(' ')}"'}',
        ].join('\n');
        final prompt =
            '''ภาพ "${s.name}" ที่แนบมาคือภาพบันทึกการตรวจร่างกาย แพทย์วาดเครื่องหมาย (พิกัด 0–1 ของภาพ):
$desc
${s.said.isEmpty ? '' : 'คำพูดของแพทย์: ${s.said.join(' / ')}\n'}ภาพร่างกายด้านหน้า: ซ้ายของผู้ป่วยอยู่ทางขวาของภาพ (ด้านหลังกลับกัน)

วิเคราะห์แต่ละเครื่องหมายว่าเป็นความผิดปกติชนิดใด
- skin = แผล รอยช้ำ บวม ผื่น ไหม้ จุดกดเจ็บ หรือไม่ระบุ → ใช้รหัส zone:
- bone = กระดูกหัก ผิดรูป ข้อเคลื่อน → ใช้รหัส bone:
- organ = ความผิดปกติของอวัยวะภายใน → ใช้ชื่ออวัยวะ
เลือกรหัสจากรายการนี้เท่านั้น: ${_peBodyCodes.join(', ')}
ตอบ JSON เท่านั้น: {"items":[{"i":0,"code":"...","kind":"skin|bone|organ","label":"คำสั้น ๆ เช่น แผลถลอก","where":"ตำแหน่งภาษาไทย"}]}''';
        final j = ErAi.extractJson(
            await ErAi.vision(prompt, img, mime: mime, maxTokens: 500));
        for (final raw in (j?['items'] as List?) ?? const []) {
          if (raw is! Map) continue;
          final code = '${raw['code']}';
          if (!_peBodyCodes.contains(code)) continue;
          final kind = code.startsWith('bone:')
              ? 'bone'
              : code.startsWith('zone:')
                  ? 'skin'
                  : 'organ';
          out.add(
              (code, kind, '${raw['label'] ?? ''}', '${raw['where'] ?? ''}'));
        }
      }
      if (!mounted) return;
      // คงชั้นผิวหนังไว้: กระดูก/อวัยวะที่ผิดปกติเรืองทะลุผิวเฉพาะชิ้นนั้น
      // (ไม่เปิดชั้นกระดูกทั้งตัว)
      setState(() => s.findings = out);
    } catch (_) {}
  }

  /// ให้ AI ตัดสินชนิดของแต่ละเครื่องหมายจากข้อความกำกับและคำพูด
  /// คืน i → (skin|bone|organ, ชื่ออวัยวะ, คำสั้น ๆ)
  Future<Map<int, (String, String, String)>> _peAskKinds(
      List<_PeStroke> marks,
      List<String?> locs,
      Map<_PeStroke, List<String>> labels,
      String about) async {
    final list = [
      for (final (i, k) in marks.indexed)
        '$i. ${k.tool.name} ที่${_peLocs[locs[i]]!.$1}'
            '${labels[k]!.isEmpty ? '' : ' ข้อความ "${labels[k]!.join(' ')}"'}'
            ' (อวัยวะใต้ตำแหน่ง: ${_peLocs[locs[i]]!.$4.isEmpty ? '-' : _peLocs[locs[i]]!.$4.join(', ')})',
    ].join('\n');
    final prompt = '''แพทย์ห้องฉุกเฉินวาดเครื่องหมายบนภาพตรวจร่างกาย
ภาพ/คำพูด: $about
เครื่องหมาย:
$list

วิเคราะห์ว่าแต่ละเครื่องหมายเป็นความผิดปกติชนิดใด (ตัดสินจากข้อความ/คำพูดเท่านั้น ห้ามเดาจากตำแหน่ง)
- skin = แผล รอยช้ำ บวม ผื่น ไหม้ จุดกดเจ็บ ปวด หรือไม่มีข้อความระบุ
- bone = กระดูกหัก ร้าว ผิดรูป ข้อเคลื่อน
- organ = ความผิดปกติของอวัยวะภายใน (ระบุ organ จาก: brain, heart, lungs, liver, stomach, kidneys, intestine, bladder)
ตอบ JSON เท่านั้น: {"items":[{"i":0,"kind":"skin|bone|organ","organ":"","label":"คำสั้น ๆ เช่น แผลถลอก กระดูกหัก"}]}''';
    final j = ErAi.extractJson(await ErAi.chat([
      {'role': 'user', 'content': prompt}
    ], fast: true, json: true, maxTokens: 400));
    return {
      for (final raw in (j?['items'] as List?) ?? const [])
        if (raw is Map && raw['i'] is num)
          (raw['i'] as num).toInt(): (
            const {'skin', 'bone', 'organ'}.contains(raw['kind'])
                ? '${raw['kind']}'
                : 'skin',
            '${raw['organ'] ?? ''}',
            '${raw['label'] ?? ''}',
          ),
    };
  }

  Widget _peDrawCrumb() => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 6.0, 16.0, 6.0),
        child: Row(children: [
          InkWell(
            onTap: _peDrawClose,
            borderRadius: BorderRadius.circular(100.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('วาดภาพ',
                  style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
          const SizedBox(width: 4.0),
          Flexible(
            child: Text(
                _peTplOpen
                    ? 'เลือกภาพ'
                    : _peDraftAt >= 0
                        ? 'แก้ภาพ ${_peDraft?.name ?? ''}'
                        : _peDraft?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
        ]),
      );

  /// หน้าย่อย "วาดภาพ" ของขั้นตรวจร่างกาย
  /// ปุ่มลัด: วาดภาพ (เลือกพื้นจาก Template) · ถ่ายภาพ · นำเข้าภาพ แล้วรายการภาพที่บันทึกแล้ว
  Widget _peDrawPage() {
    if (_peDraft case final d?) return _peEditor(d);
    if (_peTplOpen) return _peTplGrid();
    final shots = _peShotList;
    return ListView(
      key: const ValueKey('pe-draw'),
      padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 110.0),
      children: [
        _dxCard(
          'วาดภาพการตรวจร่างกาย',
          'วาดบนภาพร่างกาย ถ่ายภาพ หรือนำเข้าภาพ',
          _dxArtFade(const _ExamHero()),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // วาดภาพ = studio หุ่น 3D เต็มจอ (แตะบริเวณ / ภาพสำเร็จรูป) แล้ววาดทับ
            _dxTiles([
              (
                Icons.draw_outlined,
                'วาดภาพ',
                // เปิด studio หุ่น 3D เต็มจอทันที (หุ่นเลื่อนจากตำแหน่งเดิมมาซ้าย)
                _peOpenStudio
              ),
              (
                Icons.photo_camera_outlined,
                'ถ่ายภาพ',
                () => _pePick(ImageSource.camera)
              ),
              (
                Icons.add_photo_alternate_outlined,
                'นำเข้าภาพ',
                () => _pePick(ImageSource.gallery)
              ),
            ]),
            if (shots.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(16.0),
                  border:
                      Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                ),
                child: Wrap(spacing: 12.0, runSpacing: 12.0, children: [
                  for (final (i, s) in shots.indexed)
                    _Press(
                      child: GestureDetector(
                        onTap: () => _peOpenDraw(s, at: i),
                        child: SizedBox(
                          width: 96.0,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _peThumb(s, 96.0),
                                const SizedBox(height: 6.0),
                                Text(s.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _t(12.5,
                                        color: _inkTitle,
                                        weight: FontWeight.w600)),
                                if (s.at.isNotEmpty)
                                  Text(_clock(s.at),
                                      style: _t(11.0,
                                          color: _ink3,
                                          weight: FontWeight.w500)),
                              ]),
                        ),
                      ),
                    ),
                ]),
              ),
          ]),
        ),
      ],
    );
  }

  /// ภาพย่อ (สัดส่วนกรอบวาด 3:4) ใช้ทั้งรายการในขั้นตรวจร่างกายและแท็บตรวจร่างกายแผงซ้าย
  Widget _peThumb(_PeShot s, double w) => Container(
        width: w,
        height: w * 4 / 3,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        // ภาพจาก studio: ซูมที่จุด (หลายจุด = สไลด์อัตโนมัติ) · ภาพ 2D = แคนวาส
        child: s.focus.isNotEmpty
            ? _PeFocusSlides(shots: s.focus)
            : IgnorePointer(child: _PeCanvas(shot: s, readOnly: true)),
      );

  /// เลือกภาพจาก Template: หัวหมวด + ตารางภาพย่อ (แผ่นเทาฟ้าอ่อน ไม่มีกรอบ)
  /// แตะแล้วเปิดหน้าวาดทับภาพนั้น
  Widget _peTplGrid({void Function(String name, String id)? onPick}) =>
      LayoutBuilder(builder: (context, box) {
        const gap = 10.0;
        final cols = ((box.maxWidth + gap) / (96.0 + gap)).floor().clamp(3, 6);
        final w = (box.maxWidth - gap * (cols - 1)) / cols;
        Widget tile(String name, String id) => _Press(
              child: GestureDetector(
                onTap: () => onPick != null
                    ? onPick(name, id)
                    : _peOpenDraw(_PeShot(name: name, tpl: id)),
                child: SizedBox(
                  width: w,
                  child: Column(children: [
                    Container(
                      width: w,
                      height: w * 1.25,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _panelSoft,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      // พื้นขาวของภาพโปร่งใส (ความสว่าง → ความทึบ) เส้นเป็นสีหมึกเข้ม
                      // ภาพจึงวางบนแผ่นได้เนียน ไม่เห็นกล่องขาวซ้อน
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0, 0, 0, 0, 32, //
                          0, 0, 0, 0, 42, //
                          0, 0, 0, 0, 70, //
                          -0.333, -0.333, -0.334, 1,
                          0, // นอกภาพ (โปร่งใส) คงโปร่งใส
                        ]),
                        child: Image.asset(_peTplAsset(id),
                            fit: BoxFit.contain,
                            cacheWidth: 240,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_outlined, color: _ink3)),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: _t(12.5, color: _ink, weight: FontWeight.w500)),
                  ]),
                ),
              ),
            );
        return ListView(
          key: const ValueKey('pe-tpl'),
          padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 110.0),
          children: [
            for (final (g, items) in _peTplGroups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 10.0),
                child: Text(g,
                    style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
              ),
              Wrap(spacing: gap, runSpacing: 12.0, children: [
                for (final (name, id) in items) tile(name, id),
              ]),
              const SizedBox(height: 12.0),
            ],
          ],
        );
      });

  /// หน้าวาด: แถบเครื่องมือ (สีปากกา · ย้อน · ล้าง · ลบภาพ) + กรอบวาด 3:4
  Widget _peEditor(_PeShot d) {
    Widget tool(IconData icon, String tip, VoidCallback? onTap) => IconButton(
        tooltip: tip,
        onPressed: onTap,
        icon: Icon(icon, size: 22.0, color: onTap == null ? _ink3 : _blue));
    return Column(
      key: const ValueKey('pe-editor'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          for (final c in _pePens)
            GestureDetector(
              onTap: () => setState(() => _pePen = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 32.0,
                height: 32.0,
                margin: const EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                  border: Border.all(
                      color: _pePen == c ? _panel : Colors.transparent,
                      width: 3.0),
                  boxShadow: [
                    if (_pePen == c) BoxShadow(color: c, spreadRadius: 2.0),
                  ],
                ),
              ),
            ),
          const Spacer(),
          tool(Icons.undo_rounded, 'ย้อน',
              d.strokes.isEmpty ? null : () => setState(d.strokes.removeLast)),
          tool(Icons.layers_clear_outlined, 'ล้างเส้น',
              d.strokes.isEmpty ? null : () => setState(d.strokes.clear)),
          tool(Icons.open_in_full_rounded, 'วาดแบบละเอียด (เต็มจอ)',
              _peOpenFull),
          if (_peDraftAt >= 0)
            tool(Icons.delete_outline_rounded, 'ลบภาพ', _peDrawDelete),
        ]),
        const SizedBox(height: 8.0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 96.0),
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border:
                        Border.all(color: const Color(0xFFDADCE0), width: 0.5),
                  ),
                  child: _PeCanvas(
                      shot: d, color: _pePen, onChanged: () => setState(() {})),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// กรอบวาด: ภาพพื้น (contain) + เส้นที่วาด · ลากนิ้วเพื่อวาด (readOnly = ภาพย่อ)
class _PeCanvas extends StatefulWidget {
  const _PeCanvas(
      {required this.shot,
      this.color = const Color(0xFFD93025),
      this.readOnly = false,
      this.onChanged});
  final _PeShot shot;
  final Color color;
  final bool readOnly;
  final VoidCallback? onChanged;

  @override
  State<_PeCanvas> createState() => _PeCanvasState();
}

class _PeCanvasState extends State<_PeCanvas> {
  int _rev = 0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final size = box.biggest;
        Offset norm(Offset p) => Offset((p.dx / size.width).clamp(0.0, 1.0),
            (p.dy / size.height).clamp(0.0, 1.0));
        final s = widget.shot;
        final bg = s.tpl != null
            ? Image.asset(_peTplAsset(s.tpl!),
                fit: BoxFit.contain,
                cacheWidth: widget.readOnly ? 300 : null,
                errorBuilder: (_, __, ___) => const SizedBox.shrink())
            : s.photo != null
                // ภาพหุ่น 3D: ฉากกว้าง หุ่นอยู่กลาง → เต็มกรอบตามความสูง
                ? (s.d3.isNotEmpty
                    // ขยายเข้าตัวหุ่น (ฉากมีพื้นว่างรอบตัว)
                    ? Transform.scale(
                        scale: 1.35,
                        child: Image.memory(s.photo!, fit: BoxFit.cover))
                    : Image.memory(s.photo!, fit: BoxFit.contain))
                : null;
        final paint = CustomPaint(
          size: size,
          painter: _PeStrokePainter(s.strokes, _rev, widget.readOnly),
        );
        return Stack(fit: StackFit.expand, children: [
          if (bg != null)
            Padding(padding: EdgeInsets.all(size.width * _peBgPad), child: bg),
          for (final k in s.stickers) _peStickerBox(k, size),
          if (widget.readOnly)
            paint
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => setState(() {
                s.strokes
                    .add(_PeStroke(widget.color, 3.0, [norm(d.localPosition)]));
                _rev++;
              }),
              onPanUpdate: (d) => setState(() {
                if (s.strokes.isEmpty) return;
                s.strokes.last.pts.add(norm(d.localPosition));
                _rev++;
              }),
              onPanEnd: (_) => widget.onChanged?.call(),
              child: paint,
            ),
        ]);
      });
}

/// รูปที่แนบ วางตามสัดส่วนกรอบ (ขอบขาว + เงาบาง แบบรูปถ่ายแปะ)
Widget _peStickerBox(_PeSticker k, Size size, {Widget? overlay}) {
  final w = k.w * size.width;
  final h = w * k.aspect;
  return Positioned(
    left: k.c.dx * size.width - w / 2,
    top: k.c.dy * size.height - h / 2,
    width: w,
    height: h,
    child: Stack(clipBehavior: Clip.none, children: [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x330B1B3F),
                  blurRadius: 6.0,
                  offset: Offset(0.0, 2.0)),
            ],
          ),
          child: Image.memory(k.bytes, fit: BoxFit.cover),
        ),
      ),
      if (overlay != null) overlay,
    ]),
  );
}

class _PeStrokePainter extends CustomPainter {
  _PeStrokePainter(this.strokes, this.rev, this.small);
  final List<_PeStroke> strokes;
  final int rev;
  final bool small;

  @override
  void paint(Canvas canvas, Size size) {
    // ความหนาเป็นหน่วยกรอบกว้าง 360 · ยางลบลบเฉพาะชั้นเส้น (ภาพพื้นอยู่คนละชั้น)
    final k = size.width / 360.0;
    Offset at(Offset o) => Offset(o.dx * size.width, o.dy * size.height);
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final s in strokes) {
      if (s.pts.isEmpty) continue;
      final p = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(small ? 0.6 : 1.0, s.width * k)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final a = at(s.pts.first), b = at(s.pts.last);
      switch (s.tool) {
        case _PeTool.line:
          canvas.drawLine(a, b, p);
        case _PeTool.arrow:
          canvas.drawLine(a, b, p);
          final d = b - a;
          if (d.distance > 1) {
            final head = math.max(10.0 * k, p.strokeWidth * 3.5);
            for (final t in [d.direction + 2.6, d.direction - 2.6]) {
              canvas.drawLine(
                  b, b + Offset(math.cos(t), math.sin(t)) * head, p);
            }
          }
        case _PeTool.rect:
          canvas.drawRect(Rect.fromPoints(a, b), p);
        case _PeTool.oval:
          canvas.drawOval(Rect.fromPoints(a, b), p);
        case _PeTool.text:
          final tp = TextPainter(
            text: TextSpan(
                text: s.text,
                style: TextStyle(
                    color: s.color,
                    fontSize: (10.0 + s.width * 2.0) * k,
                    fontWeight: FontWeight.w600)),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: size.width);
          tp.paint(canvas, a);
        case _PeTool.move:
          break;
        case _PeTool.pen || _PeTool.marker || _PeTool.eraser:
          if (s.tool == _PeTool.marker) {
            p
              ..color = s.color.withValues(alpha: 0.35)
              ..strokeWidth = p.strokeWidth * 3.0;
          } else if (s.tool == _PeTool.eraser) {
            p
              ..blendMode = BlendMode.clear
              ..strokeWidth = p.strokeWidth * 4.0;
          }
          if (s.pts.length == 1) {
            canvas.drawCircle(
                a,
                p.strokeWidth / 2,
                Paint()
                  ..color = p.color
                  ..blendMode = p.blendMode);
            continue;
          }
          final path = Path()..moveTo(a.dx, a.dy);
          for (final o in s.pts.skip(1)) {
            final q = at(o);
            path.lineTo(q.dx, q.dy);
          }
          canvas.drawPath(path, p);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeStrokePainter o) => true;
}

// ------------------------------------------------ วาดภาพแบบละเอียด (เต็มจอ)

/// ขอบรอบภาพพื้นเป็นสัดส่วนความกว้างกรอบ (เท่ากันทุกขนาด เส้นที่วาดจึงตรงตำแหน่งเดิม)
const double _peBgPad = 0.04;

/// ชื่อสีที่ AI ใช้ (พูดเพื่อวาด) → สี
const Map<String, Color> _peColorNames = {
  'red': Color(0xFFD93025),
  'orange': Color(0xFFE8710A),
  'yellow': Color(0xFFF9AB00),
  'green': Color(0xFF188038),
  'blue': Color(0xFF1A73E8),
  'navy': Color(0xFF1A3A8B),
  'purple': Color(0xFF9334E6),
  'black': Color(0xFF202124),
};

/// สีในโหมดละเอียด
const List<Color> _peFullColors = [
  Color(0xFFD93025),
  Color(0xFFE8710A),
  Color(0xFFF9AB00),
  Color(0xFF188038),
  Color(0xFF1A73E8),
  Color(0xFF1A3A8B),
  Color(0xFF9334E6),
  Color(0xFF202124),
  Color(0xFFFFFFFF),
];

/// ความหนาเส้น (หน่วยกรอบ 360)
const List<double> _peFullWidths = [1.5, 3.0, 6.0];

const List<(_PeTool, IconData, String)> _peFullTools = [
  (_PeTool.move, Icons.pan_tool_outlined, 'ย้าย/ซูม'),
  (_PeTool.pen, Icons.edit_outlined, 'ปากกา'),
  (_PeTool.marker, Icons.border_color_outlined, 'ไฮไลต์'),
  (_PeTool.eraser, Icons.auto_fix_normal_outlined, 'ยางลบ'),
  (_PeTool.line, Icons.horizontal_rule_rounded, 'เส้นตรง'),
  (_PeTool.arrow, Icons.north_east_rounded, 'ลูกศร'),
  (_PeTool.rect, Icons.crop_square_rounded, 'สี่เหลี่ยม'),
  (_PeTool.oval, Icons.circle_outlined, 'วงกลม'),
  (_PeTool.text, Icons.title_rounded, 'ข้อความ'),
];

extension _FeaturesWorkflowPeFullPart on _ErFlowHomeWidgetState {
  /// เปิดโหมดวาดแบบละเอียดเต็มจอ (แก้ภาพที่กำลังวาดอยู่ตัวเดิม)
  void _peOpenFull({VoidCallback? onSaved}) {
    final d = _peDraft;
    if (d == null) return;
    Navigator.of(context, rootNavigator: true)
        .push(PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) => _PeFullEditor(
        shot: d,
        onSave: () {
          Navigator.of(ctx).pop();
          onSaved?.call();
          _peDrawSave();
        },
      ),
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
            scale: Tween(begin: 0.98, end: 1.0)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
            child: child),
      ),
    ))
        .then((_) {
      if (mounted) setState(() {});
    });
  }
}

/// หน้าวาดแบบละเอียด: แถบบน (ปิด · ชื่อ · ย้อน/ทำซ้ำ/ล้าง · แนบรูป · บันทึก)
/// รางเครื่องมือซ้าย · กรอบวาดกลาง (ซูม/เลื่อนด้วยเครื่องมือย้าย) · สีและขนาดขวา
class _PeFullEditor extends StatefulWidget {
  const _PeFullEditor({required this.shot, required this.onSave});
  final _PeShot shot;
  final VoidCallback onSave;

  @override
  State<_PeFullEditor> createState() => _PeFullEditorState();
}

class _PeFullEditorState extends State<_PeFullEditor> {
  _PeTool _tool = _PeTool.pen;
  Color _color = _pePen;
  double _width = 3.0;
  final List<_PeStroke> _redo = [];
  final _view = TransformationController();
  int _rev = 0;

  /// พูดเพื่อวาด: ไมค์ → ถอดเสียง → AI อ่านภาพพื้น + คำพูด → รูปทรงบนภาพ
  late final ErSpeechInput _speech = ErSpeechInput()..addListener(_onSpeech);
  ErSpeechState _speechWas = ErSpeechState.idle;
  bool _drawing = false;

  /// ข้อความใต้กรอบวาด: คำที่ได้ยิน / ผลการวาด (จางหายเอง)
  String _caption = '';
  Timer? _captionT;

  _PeShot get _d => widget.shot;

  // ตัวอักษรแบบเดียวกับ _t ของหน้าหลัก (หน้านี้อยู่นอก state หลัก)
  TextStyle _t(double size,
          {Color color = _ink, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
          fontFamily: _fontFam,
          fontFamilyFallback: _fontFb,
          fontSize: size * _txtScale,
          color: color,
          fontWeight: _minW(weight));

  @override
  void dispose() {
    _view.dispose();
    _speech.removeListener(_onSpeech);
    _speech.dispose();
    _captionT?.cancel();
    super.dispose();
  }

  void _say(String t, {int ms = 5000}) {
    _captionT?.cancel();
    setState(() => _caption = t);
    if (ms > 0) {
      _captionT = Timer(Duration(milliseconds: ms), () {
        if (mounted) setState(() => _caption = '');
      });
    }
  }

  void _onSpeech() {
    if (!mounted) return;
    final st = _speech.state;
    if (st == ErSpeechState.success && _speechWas != ErSpeechState.success) {
      _speechDraw(_speech.transcript);
    } else if (st != _speechWas &&
        (st == ErSpeechState.noSpeech ||
            st == ErSpeechState.error ||
            st == ErSpeechState.permissionDenied)) {
      _say(_speech.message);
    }
    _speechWas = st;
    setState(() {});
  }

  /// แปลงคำพูดเป็นรูปทรง: ส่งภาพพื้นให้ AI หาตำแหน่ง (พิกัด 0–1 ของภาพ)
  /// แล้วแปลงเป็นพิกัดกรอบวาด (ภาพวางแบบ contain ในกรอบ 3:4 มีขอบ _peBgPad)
  Future<void> _speechDraw(String said) async {
    if (said.trim().isEmpty) return;
    setState(() => _drawing = true);
    _d.said.add(said.trim());
    _say('“$said”', ms: 0);
    try {
      Uint8List? img;
      var mime = 'image/png';
      if (_d.tpl != null) {
        img =
            (await rootBundle.load(_peTplAsset(_d.tpl!))).buffer.asUint8List();
      } else if (_d.photo != null) {
        img = _d.photo;
        mime = 'image/jpeg';
      }
      var aspect = 4 / 3;
      if (img != null) {
        final im = await decodeImageFromList(img);
        aspect = im.height / im.width;
      }
      final prompt = '''คุณช่วยแพทย์ห้องฉุกเฉินวาดบันทึกการตรวจร่างกายลงบนภาพ
ภาพ: ${img == null ? 'กระดาษเปล่า' : 'ภาพ "${_d.name}" ที่แนบมา'}
ภาพร่างกายด้านหน้า: ซ้ายของผู้ป่วยอยู่ทางขวาของภาพ (ด้านหลังกลับกัน)
คำพูดของแพทย์: "$said"

แปลงเป็นรูปทรงบนภาพ ตอบ JSON เท่านั้น:
{"shapes":[{"type":"oval|rect|arrow|line|text|cross","x":0.0,"y":0.0,"w":0.0,"h":0.0,"x2":0.0,"y2":0.0,"text":"","color":"red|orange|yellow|green|blue|navy|purple|black"}],"say":"สรุปสิ่งที่วาดสั้น ๆ ภาษาไทย"}
- พิกัดเป็นสัดส่วน 0–1 ของภาพ (0,0 = มุมซ้ายบน)
- oval/rect: x,y = จุดกลาง, w,h = ขนาด (ตำแหน่งต้องอยู่บนอวัยวะที่พูดถึงจริงในภาพ)
- arrow/line: จาก x,y ไป x2,y2 · text: x,y = มุมซ้ายบนของข้อความ · cross: x,y = จุดกลาง, w = ขนาด
- ถ้าพูดชื่อรอยโรค/ขนาด ให้วาดรูปทรงที่ตำแหน่ง และเพิ่ม text สั้น ๆ ข้าง ๆ
- ไม่ระบุสี = red สำหรับสิ่งผิดปกติ''';
      final out = img == null
          ? await ErAi.chat([
              {'role': 'user', 'content': prompt}
            ], json: true, maxTokens: 700)
          : await ErAi.vision(prompt, img, mime: mime, maxTokens: 700);
      final j = ErAi.extractJson(out);
      final shapes = (j?['shapes'] as List?) ?? const [];
      // พิกัดภาพ → พิกัดกรอบ (กรอบกว้าง 1 สูง 4/3 ในหน่วยสัดส่วน)
      const pad = _peBgPad;
      final innerW = 1 - 2 * pad, innerH = 4 / 3 - 2 * pad;
      final sc = math.min(innerW, innerH / aspect);
      final iw = sc, ih = sc * aspect;
      final ox = pad + (innerW - iw) / 2, oy = pad + (innerH - ih) / 2;
      Offset at(num? x, num? y) => Offset(
          ((ox + (x ?? 0.5).toDouble().clamp(0.0, 1.0) * iw)).clamp(0.0, 1.0),
          ((oy + (y ?? 0.5).toDouble().clamp(0.0, 1.0) * ih) / (4 / 3))
              .clamp(0.0, 1.0));
      var n = 0;
      final added = <_PeStroke>[];
      for (final raw in shapes) {
        if (raw is! Map) continue;
        final c = _peColorNames[raw['color']] ?? _peFullColors.first;
        final type = '${raw['type']}';
        final x = raw['x'] as num?, y = raw['y'] as num?;
        final w = ((raw['w'] as num?) ?? 0.12).toDouble();
        final h = ((raw['h'] as num?) ?? w).toDouble();
        final cx = (x ?? 0.5).toDouble(), cy = (y ?? 0.5).toDouble();
        switch (type) {
          case 'oval' || 'rect':
            added.add(_PeStroke(c, _width,
                [at(cx - w / 2, cy - h / 2), at(cx + w / 2, cy + h / 2)],
                tool: type == 'oval' ? _PeTool.oval : _PeTool.rect));
          case 'arrow' || 'line':
            added.add(_PeStroke(
                c, _width, [at(x, y), at(raw['x2'] as num?, raw['y2'] as num?)],
                tool: type == 'arrow' ? _PeTool.arrow : _PeTool.line));
          case 'cross':
            final d = w / 2;
            added
              ..add(_PeStroke(
                  c, _width, [at(cx - d, cy - d), at(cx + d, cy + d)],
                  tool: _PeTool.line))
              ..add(_PeStroke(
                  c, _width, [at(cx - d, cy + d), at(cx + d, cy - d)],
                  tool: _PeTool.line));
          case 'text':
            final t = '${raw['text'] ?? ''}'.trim();
            if (t.isNotEmpty) {
              added.add(_PeStroke(c, _width, [at(x, y)],
                  tool: _PeTool.text, text: t));
            }
          default:
            continue;
        }
        n++;
      }
      if (!mounted) return;
      setState(() {
        _d.strokes.addAll(added);
        _redo.clear();
        _rev++;
        _drawing = false;
      });
      _say(n == 0
          ? 'ไม่พบสิ่งที่ต้องวาดจาก “$said”'
          : '${j?['say'] ?? 'วาดแล้ว $n รายการ'} · แตะย้อนเพื่อยกเลิก');
    } catch (_) {
      if (!mounted) return;
      setState(() => _drawing = false);
      _say('วาดจากเสียงไม่สำเร็จ · ตรวจการเชื่อมต่อแล้วลองใหม่');
    }
  }

  /// ปุ่มพูดเพื่อวาด: ว่าง = ไมค์ · กำลังฟัง = แดงพร้อมเวลา · ถอดเสียง/วาด = หมุน
  Widget _micPill() {
    final st = _speech.state;
    final listening = st == ErSpeechState.listening;
    final busy = _drawing ||
        st == ErSpeechState.processing ||
        st == ErSpeechState.permission;
    final label = listening
        ? 'กำลังฟัง ${_speech.seconds ~/ 60}:${(_speech.seconds % 60).toString().padLeft(2, '0')}'
        : busy
            ? (_drawing ? 'กำลังวาด…' : 'กำลังถอดเสียง…')
            : 'พูดเพื่อวาด';
    return _Press(
      child: GestureDetector(
        onTap: busy ? null : _speech.toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: listening ? _red : _panelSoft,
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (busy)
              const SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child:
                      CircularProgressIndicator(strokeWidth: 2.0, color: _blue))
            else
              Icon(listening ? Icons.stop_rounded : Icons.mic_none_rounded,
                  size: 20.0, color: listening ? Colors.white : _blue),
            const SizedBox(width: 6.0),
            Text(label,
                style: _t(14.0,
                    color: listening ? Colors.white : _blue,
                    weight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  /// แนบรูป: วางกลางภาพ กว้าง 45% แล้วสลับเป็นเครื่องมือย้าย ให้ลาก/ย่อขยายได้ทันที
  Future<void> _attach(ImageSource src) async {
    try {
      final f = await ImagePicker()
          .pickImage(source: src, maxWidth: 1600, imageQuality: 85);
      if (f == null) return;
      final bytes = await f.readAsBytes();
      final img = await decodeImageFromList(bytes);
      if (!mounted) return;
      setState(() {
        _d.stickers.add(_PeSticker(
            bytes, const Offset(0.5, 0.5), 0.45, img.height / img.width));
        _tool = _PeTool.move;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(src == ImageSource.camera
              ? 'เปิดกล้องไม่ได้ในเครื่องนี้'
              : 'เปิดคลังภาพไม่ได้')));
    }
  }

  Future<void> _addText(Offset at) async {
    final t = await _askText('');
    if (t == null || t.isEmpty || !mounted) return;
    setState(() {
      _d.strokes
          .add(_PeStroke(_color, _width, [at], tool: _PeTool.text, text: t));
      _redo.clear();
      _rev++;
    });
  }

  /// แก้ข้อความที่วางแล้ว (ลบข้อความทั้งหมด = เอาข้อความนั้นออก)
  Future<void> _editText(_PeStroke s) async {
    final t = await _askText(s.text);
    if (t == null || !mounted) return;
    setState(() {
      if (t.isEmpty) {
        _d.strokes.remove(s);
      } else {
        s.text = t;
      }
      _rev++;
    });
  }

  /// dialog ใส่ข้อความ: null = ยกเลิก
  Future<String?> _askText(String initial) async {
    final ctl = TextEditingController(text: initial);
    final t = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text(initial.isEmpty ? 'เพิ่มข้อความ' : 'แก้ข้อความ',
            style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
        content: TextField(
          controller: ctl,
          autofocus: true,
          style: _t(15.0, color: _inkTitle, weight: FontWeight.w500),
          decoration: const InputDecoration(hintText: 'เช่น แผลถลอก 2 cm'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('ยกเลิก',
                  style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(ctl.text),
              child: Text(initial.isEmpty ? 'เพิ่ม' : 'บันทึก',
                  style: _t(14.0, color: _blue, weight: FontWeight.w700))),
        ],
      ),
    );
    // dialog ยังเล่นแอนิเมชันปิดอยู่ (TextField ยังใช้ controller): ทิ้งหลังปิดเสร็จ
    Future.delayed(const Duration(milliseconds: 400), ctl.dispose);
    return t?.trim();
  }

  /// ข้อความที่วางแล้ว (เครื่องมือย้ายหรือข้อความ): ลากเพื่อเลื่อน · แตะเพื่อแก้
  Widget _textHandle(_PeStroke s, Size size) {
    final k = size.width / 360.0;
    final tp = TextPainter(
      text: TextSpan(
          text: s.text,
          style: TextStyle(
              fontSize: (10.0 + s.width * 2.0) * k,
              fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    final p = Offset(s.pts.first.dx * size.width, s.pts.first.dy * size.height);
    return Positioned(
      left: p.dx - 6.0,
      top: p.dy - 4.0,
      width: tp.width + 12.0,
      height: tp.height + 8.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _editText(s),
        onScaleUpdate: (e) => setState(() {
          final q = s.pts.first;
          s.pts[0] = Offset(
              (q.dx + e.focalPointDelta.dx / size.width).clamp(0.0, 1.0),
              (q.dy + e.focalPointDelta.dy / size.height).clamp(0.0, 1.0));
          _rev++;
        }),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: _blue.withValues(alpha: 0.5), width: 1.0),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  bool get _shape => const {
        _PeTool.line,
        _PeTool.arrow,
        _PeTool.rect,
        _PeTool.oval
      }.contains(_tool);

  Widget _topBar() {
    Widget icon(IconData i, String tip, VoidCallback? on) => IconButton(
        tooltip: tip,
        onPressed: on,
        icon: Icon(i, size: 24.0, color: on == null ? _ink3 : _inkTitle));
    Widget menuRow(IconData i, String text) => Row(children: [
          Icon(i, size: 20.0, color: _blue),
          const SizedBox(width: 12.0),
          Text(text,
              style: _t(14.0, color: _inkTitle, weight: FontWeight.w500)),
        ]);
    return Container(
      height: 64.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: const BoxDecoration(
        color: _panel,
        border:
            Border(bottom: BorderSide(color: Color(0xFFDADCE0), width: 0.5)),
      ),
      child: Row(children: [
        icon(Icons.close_rounded, 'ปิด', () => Navigator.of(context).pop()),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('วาดแบบละเอียด',
                    style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                Text(_d.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
              ]),
        ),
        icon(
            Icons.undo_rounded,
            'ย้อน',
            _d.strokes.isEmpty
                ? null
                : () => setState(() {
                      _redo.add(_d.strokes.removeLast());
                      _rev++;
                    })),
        icon(
            Icons.redo_rounded,
            'ทำซ้ำ',
            _redo.isEmpty
                ? null
                : () => setState(() {
                      _d.strokes.add(_redo.removeLast());
                      _rev++;
                    })),
        icon(
            Icons.layers_clear_outlined,
            'ล้างเส้นทั้งหมด',
            _d.strokes.isEmpty
                ? null
                : () => setState(() {
                      _redo.clear();
                      _d.strokes.clear();
                      _rev++;
                    })),
        const SizedBox(width: 4.0),
        _micPill(),
        const SizedBox(width: 8.0),
        PopupMenuButton<ImageSource>(
          tooltip: 'แนบรูป',
          color: _panel,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          onSelected: _attach,
          itemBuilder: (_) => [
            PopupMenuItem(
                value: ImageSource.camera,
                child: menuRow(Icons.photo_camera_outlined, 'ถ่ายภาพ')),
            PopupMenuItem(
                value: ImageSource.gallery,
                child:
                    menuRow(Icons.photo_library_outlined, 'เลือกจากคลังภาพ')),
          ],
          child: Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(children: [
              const Icon(Icons.attach_file_rounded, size: 20.0, color: _blue),
              const SizedBox(width: 6.0),
              Text('แนบรูป',
                  style: _t(14.0, color: _blue, weight: FontWeight.w600)),
            ]),
          ),
        ),
        const SizedBox(width: 10.0),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _blue,
            minimumSize: const Size(0.0, 44.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            shape: const StadiumBorder(),
          ),
          onPressed: widget.onSave,
          icon: const Icon(Icons.check_rounded, size: 20.0),
          label: Text('บันทึกภาพ',
              style: _t(15.0, color: Colors.white, weight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _toolRail() => Container(
        width: 84.0,
        color: _panel,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          children: [
            for (final (t, ic, label) in _peFullTools)
              _Press(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _tool = t),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 52.0,
                        height: 34.0,
                        decoration: BoxDecoration(
                          color: _tool == t
                              ? const Color(0xFFD3E3FD)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: Icon(ic,
                            size: 22.0, color: _tool == t ? _blue : _ink2),
                      ),
                      const SizedBox(height: 4.0),
                      Text(label,
                          style: _t(11.5,
                              color: _tool == t ? _blue : _ink2,
                              weight: _tool == t
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _props() => Container(
        width: 96.0,
        color: _panel,
        padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0),
        child: Column(children: [
          Text('สี', style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
          const SizedBox(height: 8.0),
          Wrap(spacing: 10.0, runSpacing: 10.0, children: [
            for (final c in _peFullColors)
              GestureDetector(
                onTap: () => setState(() {
                  _color = c;
                  if (_tool == _PeTool.move || _tool == _PeTool.eraser) {
                    _tool = _PeTool.pen;
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c,
                    border: Border.all(
                        color: _color == c ? _blue : const Color(0xFFDADCE0),
                        width: _color == c ? 3.0 : 0.5),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 20.0),
          Text('ขนาด', style: _t(12.0, color: _ink3, weight: FontWeight.w600)),
          const SizedBox(height: 8.0),
          for (final w in _peFullWidths)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _width = w),
              child: Container(
                height: 40.0,
                margin: const EdgeInsets.only(bottom: 6.0),
                decoration: BoxDecoration(
                  color: _width == w
                      ? const Color(0xFFD3E3FD)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Center(
                  child: Container(
                    width: 40.0,
                    height: w * 1.6,
                    decoration: BoxDecoration(
                      color: _color == Colors.white ? _ink3 : _color,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      );

  /// รูปที่แนบในโหมดย้าย: ลากเพื่อย้าย สองนิ้วเพื่อย่อ/ขยาย · ปุ่ม × ลบรูป
  Widget _stickerHandle(_PeSticker k, Size size) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleUpdate: (e) => setState(() {
            k.c = Offset(
                (k.c.dx + e.focalPointDelta.dx / size.width).clamp(0.0, 1.0),
                (k.c.dy + e.focalPointDelta.dy / size.height).clamp(0.0, 1.0));
            if (e.pointerCount > 1) {
              k.w = (k.w * (1 + (e.scale - 1) * 0.08)).clamp(0.12, 1.0);
            }
          }),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: _blue, width: 1.5),
            ),
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => setState(() => _d.stickers.remove(k)),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                width: 26.0,
                height: 26.0,
                decoration: const BoxDecoration(
                    color: Color(0xCC202124), shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded,
                    size: 16.0, color: Colors.white),
              ),
            ),
          ),
        ),
      );

  Widget _canvas() => LayoutBuilder(builder: (context, box) {
        // กรอบ 3:4 ใหญ่ที่สุดที่พอดีพื้นที่
        final w = math.min(box.maxWidth - 32.0, (box.maxHeight - 32.0) * 0.75);
        final size = Size(w, w / 0.75);
        Offset norm(Offset p) => Offset((p.dx / size.width).clamp(0.0, 1.0),
            (p.dy / size.height).clamp(0.0, 1.0));
        final move = _tool == _PeTool.move;
        final text = _tool == _PeTool.text;
        final bg = _d.tpl != null
            ? Image.asset(_peTplAsset(_d.tpl!), fit: BoxFit.contain)
            : _d.photo != null
                ? Image.memory(_d.photo!, fit: BoxFit.contain)
                : null;
        return InteractiveViewer(
          transformationController: _view,
          minScale: 1.0,
          maxScale: 6.0,
          panEnabled: move,
          scaleEnabled: move,
          boundaryMargin: const EdgeInsets.all(200.0),
          child: Center(
            child: Container(
              width: size.width,
              height: size.height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1F0B1B3F),
                      blurRadius: 16.0,
                      offset: Offset(0.0, 4.0)),
                ],
              ),
              child: Stack(fit: StackFit.expand, children: [
                if (bg != null)
                  Padding(
                      padding: EdgeInsets.all(size.width * _peBgPad),
                      child: bg),
                for (final k in _d.stickers)
                  _peStickerBox(k, size,
                      overlay: move ? _stickerHandle(k, size) : null),
                IgnorePointer(
                  ignoring: move,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp:
                        text ? (e) => _addText(norm(e.localPosition)) : null,
                    onPanStart: text
                        ? null
                        : (e) => setState(() {
                              final p = norm(e.localPosition);
                              _d.strokes.add(_PeStroke(
                                  _color, _width, _shape ? [p, p] : [p],
                                  tool: _tool));
                              _redo.clear();
                              _rev++;
                            }),
                    onPanUpdate: text
                        ? null
                        : (e) => setState(() {
                              if (_d.strokes.isEmpty) return;
                              final s = _d.strokes.last;
                              final p = norm(e.localPosition);
                              if (_shape) {
                                s.pts[1] = p;
                              } else {
                                s.pts.add(p);
                              }
                              _rev++;
                            }),
                    child: CustomPaint(
                      size: size,
                      painter: _PeStrokePainter(_d.strokes, _rev, false),
                    ),
                  ),
                ),
                if (move || text)
                  for (final s in [..._d.strokes])
                    if (s.tool == _PeTool.text) _textHandle(s, size),
              ]),
            ),
          ),
        );
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF1F3F4),
        // คีย์บอร์ด (ใส่ข้อความ) ลอยทับ ไม่ย่อหน้าวาด (แผงสีไม่ล้น)
        resizeToAvoidBottomInset: false,
        // แอปตัด padding ระบบออก: เว้นแถบสถานะเอง ไม่ให้แถบบนทับนาฬิกา
        body: SafeArea(
          minimum: const EdgeInsets.only(top: 24.0),
          child: Column(children: [
            _topBar(),
            Expanded(
              child: Row(children: [
                _toolRail(),
                Container(width: 0.5, color: const Color(0xFFDADCE0)),
                Expanded(
                  child: ClipRect(
                    child: Stack(children: [
                      Positioned.fill(child: _canvas()),
                      // คำที่ได้ยิน / ผลการวาดจากเสียง
                      Positioned(
                        left: 24.0,
                        right: 24.0,
                        bottom: 20.0,
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 220),
                            opacity: _caption.isEmpty ? 0.0 : 1.0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xE6202124),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Text(_caption,
                                    textAlign: TextAlign.center,
                                    style: _t(14.0,
                                        color: Colors.white,
                                        weight: FontWeight.w500)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                Container(width: 0.5, color: const Color(0xFFDADCE0)),
                _props(),
              ]),
            ),
          ]),
        ),
      );
}

// ------------------------------------------------ studio วาดภาพ (หุ่น 3D เต็มจอ)

/// กระดูก rig ที่ใกล้เส้นที่วาดบนหุ่น 3D → ตำแหน่ง (ดู _peLocs)
const Map<String, String> _peBoneLoc = {
  'Head': 'head',
  'Neck': 'throat',
  'Chest': 'chest',
  'Belly': 'abdomen',
  'Pelvis': 'suprapubic',
  'Collar.R': 'shoulder_r',
  'Collar.L': 'shoulder_l',
  'UpperArm.R': 'arm_r',
  'UpperArm.L': 'arm_l',
  'Forearm.R': 'forearm_r',
  'Forearm.L': 'forearm_l',
  'Palm.R': 'hand_r',
  'Palm.L': 'hand_l',
  'Hip.R': 'thigh_r',
  'Hip.L': 'thigh_l',
  'Shin.R': 'shin_r',
  'Shin.L': 'shin_l',
  'Foot.R': 'foot_r',
  'Foot.L': 'foot_l',
  'Toes.R': 'foot_r',
  'Toes.L': 'foot_l',
};

/// มุมมองสำเร็จรูปบนหุ่น 3D ตามภาพ HOSxP (ศีรษะ 1 หลัง · 2 หน้า · 3 บน · 4/5 ด้านข้าง): กล้องเล็งจุดระหว่างข้อต่อ a→b (t)
/// หมุนรอบแกนหัว-เท้า (spin) เอียง (tilt) ซูม (zoom น้อย = ใกล้ · 1.4 = ทั้งตัว)
const double _pi = 3.14159265;
const Map<String, Object?> _peWhole = {'a': 'Pelvis', 'zoom': 1.4};
const Map<String, Map<String, Object?>> _peTplFocus = {
  '30': _peWhole,
  '09': _peWhole,
  '02': _peWhole,
  '38': _peWhole,
  '39': _peWhole,
  '40': _peWhole,
  '01': {'a': 'Belly', 'zoom': 1.4, 'spin': _pi},
  '11': {'a': 'Head', 'zoom': 0.75, 'spin': _pi},
  '12': {'a': 'Head', 'zoom': 0.75},
  '13': {'a': 'Head', 'zoom': 0.75, 'tilt': 0.6},
  '14': {'a': 'Head', 'zoom': 0.75, 'spin': _pi / 2},
  '15': {'a': 'Head', 'zoom': 0.75, 'spin': -_pi / 2},
  '41': {'a': 'Head', 'zoom': 0.62},
  '07': {'a': 'Head', 'zoom': 0.6},
  '08': {'a': 'Head', 'zoom': 0.6},
  '31': {'a': 'Head', 'zoom': 0.6},
  '42': {'a': 'UpperArm.R', 'zoom': 0.85},
  '24': {'a': 'Palm.L', 'zoom': 0.62},
  '25': {'a': 'Palm.L', 'zoom': 0.62, 'spin': _pi},
  '26': {'a': 'Palm.L', 'zoom': 0.62, 'spin': _pi / 2},
  '27': {'a': 'Palm.L', 'zoom': 0.62, 'spin': -_pi / 2},
  '34': {'a': 'Palm.R', 'zoom': 0.62},
  '35': {'a': 'Palm.R', 'zoom': 0.62, 'spin': _pi},
  '36': {'a': 'Palm.R', 'zoom': 0.62, 'spin': -_pi / 2},
  '37': {'a': 'Palm.R', 'zoom': 0.62, 'spin': _pi / 2},
  '19': {'a': 'Foot.L', 'zoom': 0.62, 'spin': _pi / 2},
  '20': {'a': 'Foot.L', 'b': 'Toes.L', 't': 0.5, 'zoom': 0.62},
  '21': {'a': 'Foot.L', 'b': 'Toes.L', 't': 0.5, 'zoom': 0.62, 'spin': _pi},
  '22': {'a': 'Foot.L', 'zoom': 0.62, 'spin': _pi / 2},
  '23': {'a': 'Foot.L', 'zoom': 0.62, 'spin': -_pi / 2},
  '32': {'a': 'Foot.R', 'b': 'Toes.R', 't': 0.5, 'zoom': 0.62},
  '33': {'a': 'Foot.R', 'b': 'Toes.R', 't': 0.5, 'zoom': 0.62, 'spin': _pi},
  '16': {'a': 'Belly', 'b': 'Chest', 't': 0.2, 'zoom': 1.0, 'spin': _pi},
  '06': {'a': 'Belly', 'b': 'Chest', 't': 0.6, 'zoom': 0.95},
  '03': {'a': 'Belly', 'zoom': 0.95},
};

/// บริเวณร่างกาย (taxonomy เดียวกับ CIS body map: bms-uxui/cis-redesign-2026)
/// id → (ชื่อไทย, ตำแหน่งใน _peLocs สำหรับไฮไลต์หุ่น 3D, ซูมกล้อง)
/// r/l = ขวา/ซ้ายของผู้ป่วย · ขึ้นต้น b = ด้านหลัง
final Map<String, (String, String, double)> _peRegions = {
  'head': ('ศีรษะ', 'head', 0.6),
  'neck': ('คอ', 'throat', 0.6),
  'chest': ('กลางอก', 'chest', 0.75),
  'r-chest': ('อกขวา', 'chest_r', 0.75),
  'l-chest': ('อกซ้าย', 'chest_l', 0.75),
  'r-hypochondriac': ('ใต้ชายโครงขวา', 'ruq', 0.75),
  'epigastric': ('ลิ้นปี่', 'epigastric', 0.75),
  'l-hypochondriac': ('ใต้ชายโครงซ้าย', 'luq', 0.75),
  'r-lumbar': ('บั้นเอวขวา (สีข้าง)', 'ruq', 0.75),
  'umbilical': ('รอบสะดือ', 'abdomen', 0.75),
  'l-lumbar': ('บั้นเอวซ้าย (สีข้าง)', 'luq', 0.75),
  'r-iliac': ('ท้องน้อยขวา', 'rlq', 0.75),
  'hypogastric': ('เหนือหัวหน่าว', 'suprapubic', 0.75),
  'l-iliac': ('ท้องน้อยซ้าย', 'llq', 0.75),
  'pelvis': ('เชิงกราน / หัวหน่าว', 'suprapubic', 0.75),
  'groin': ('ขาหนีบ', 'suprapubic', 0.75),
  'r-hip': ('สะโพกขวา', 'thigh_r', 0.75),
  'l-hip': ('สะโพกซ้าย', 'thigh_l', 0.75),
  'r-foot': ('เท้าขวา', 'foot_r', 0.55),
  'l-foot': ('เท้าซ้าย', 'foot_l', 0.55),
  'b-head': ('ท้ายทอย', 'head', 0.6),
  'b-nape': ('ต้นคอด้านหลัง', 'throat', 0.6),
  'bul': ('หลังส่วนบนซ้าย / สะบักซ้าย', 'chest_l', 0.75),
  'bur': ('หลังส่วนบนขวา / สะบักขวา', 'chest_r', 0.75),
  'bll': ('บั้นเอวซ้าย (หลัง)', 'kub', 0.75),
  'blc': ('กลางหลังล่าง', 'kub', 0.75),
  'blr': ('บั้นเอวขวา (หลัง)', 'kub', 0.75),
  for (final (sd, th) in [('r', 'ขวา'), ('l', 'ซ้าย')]) ...{
    '$sd-shoulder': ('ไหล่$th', 'shoulder_$sd', 0.65),
    '$sd-arm': ('ต้นแขน$th', 'arm_$sd', 0.65),
    '$sd-elbow': ('ข้อศอก$th', 'forearm_$sd', 0.6),
    '$sd-forearm': ('ปลายแขน$th', 'forearm_$sd', 0.6),
    '$sd-wrist': ('ข้อมือ$th', 'hand_$sd', 0.55),
    '$sd-hand': ('มือ$th', 'hand_$sd', 0.55),
    '$sd-thigh': ('ต้นขา$th', 'thigh_$sd', 0.75),
    '$sd-knee': ('เข่า$th', 'shin_$sd', 0.65),
    '$sd-leg': ('หน้าแข้ง$th', 'shin_$sd', 0.7),
    '$sd-ankle': ('ข้อเท้า$th', 'ankle_$sd', 0.55),
    'b$sd-shoulder': ('ไหล่$th (หลัง)', 'shoulder_$sd', 0.65),
    'b$sd-arm': ('ต้นแขน$th (หลัง)', 'arm_$sd', 0.65),
    'b$sd-elbow': ('ข้อศอก$th (หลัง)', 'forearm_$sd', 0.6),
    'b$sd-forearm': ('ปลายแขน$th (หลัง)', 'forearm_$sd', 0.6),
    'b$sd-wrist': ('ข้อมือ$th (หลัง)', 'hand_$sd', 0.55),
    'b$sd-hand': ('หลังมือ$th', 'hand_$sd', 0.55),
    'b$sd-buttock': ('ก้น/สะโพก$th', 'thigh_$sd', 0.75),
    'b$sd-thigh': ('ต้นขา$th (หลัง)', 'thigh_$sd', 0.75),
    'b$sd-knee': ('ข้อพับเข่า$th', 'shin_$sd', 0.65),
    'b$sd-leg': ('น่อง$th', 'shin_$sd', 0.7),
    'b$sd-ankle': ('ข้อเท้า$th (หลัง)', 'ankle_$sd', 0.55),
    'b$sd-heel': ('ส้นเท้า$th', 'foot_$sd', 0.55),
    'b$sd-midfoot': ('ฝ่าเท้า$th', 'foot_$sd', 0.55),
  },
};

/// ชนิดสิ่งที่พบ (finding types แบบ CIS): (ชื่อ, สีจุด, แสดงบนหุ่นเป็น skin|bone)
/// สีแยกชนิด (ไม่ใช่สีเตือนแดง/เหลือง/เขียว) · ความรุนแรงใช้ความเข้มของสี ไม่เปลี่ยนสี
const List<(String, Color, String)> _peQuickTypes = [
  ('ปวด', Color(0xFFE11D48), 'skin'),
  ('บวม', Color(0xFF0891B2), 'skin'),
  ('ผื่น/รอยโรค', Color(0xFFC026D3), 'skin'),
  ('ช้ำ/เขียวคล้ำ', Color(0xFF7C3AED), 'skin'),
  ('แผล', Color(0xFFEA580C), 'skin'),
  ('ก้อน', Color(0xFFB45309), 'skin'),
  ('ชา', Color(0xFF64748B), 'skin'),
  ('อ่อนแรง', Color(0xFF2563EB), 'skin'),
  ('ผิดรูป/ข้อติด', Color(0xFF0D9488), 'bone'),
];

/// ลักษณะความปวด (pain characters แบบ CIS)
const List<String> _pePainChars = [
  'ตื้อ/หน่วง',
  'บีบ/เกร็ง',
  'บิด',
  'แสบ/ร้อน',
  'แทง/เสียด',
  'จี๊ด/ไฟช็อต',
  'ตุบๆ/เต้น',
];

/// ชิปสิ่งที่พบ (ชื่อ, ชนิดบนหุ่น) — ใช้ร่วมกับการ์ดลอยเดิม
final List<(String, String)> _peQuickFindings = [
  for (final (l, _, k) in _peQuickTypes) (l, k),
];

/// ข้อความสิ่งที่พบของหมุด: ชนิด + ลักษณะปวด + คะแนน เช่น "ปวด แสบ/ร้อน 6/10"
String _peLabel(Map<String, Object?> s) => [
      if (s['label'] != null) '${s['label']}',
      if (s['label'] == 'ปวด' && s['pain'] != null) '${s['pain']}',
      if (s['label'] == 'ปวด' && s['nrs'] != null) '${s['nrs']}/10',
    ].join(' ');

extension _FeaturesWorkflowPeStudioPart on _ErFlowHomeWidgetState {
  /// ถามก่อนเข้าหน้าวาดภาพ (เปิดเต็มจอพร้อมหุ่น 3D)
  void _peAskStudio() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      constraints: const BoxConstraints(maxWidth: 560.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 20.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                  color: const Color(0xFFDADCE0),
                  borderRadius: BorderRadius.circular(100.0)),
            ),
            const SizedBox(height: 20.0),
            Container(
              width: 56.0,
              height: 56.0,
              decoration: const BoxDecoration(
                  color: Color(0xFFE8F0FE), shape: BoxShape.circle),
              child: const Icon(Icons.accessibility_new_rounded,
                  size: 30.0, color: _blue),
            ),
            const SizedBox(height: 14.0),
            Text('เข้าสู่หน้าวาดภาพ',
                style: _t(20.0, color: _inkTitle, weight: FontWeight.w700)),
            const SizedBox(height: 6.0),
            Text(
                'หน้าวาดภาพจะเปิดเต็มจอพร้อมหุ่น 3D วาดลงบนตัวหุ่นได้ทันที หรือเลือกภาพสำเร็จรูป',
                textAlign: TextAlign.center,
                style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
            const SizedBox(height: 22.0),
            Row(children: [
              Expanded(
                child: _navBtn('ยกเลิก', Icons.close_rounded,
                    () => Navigator.of(ctx).pop(),
                    primary: false),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _navBtn('เข้าสู่หน้าวาดภาพ', Icons.draw_outlined, () {
                  Navigator.of(ctx).pop();
                  _peOpenStudio();
                }),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  /// studio เต็มจอ: วาดบนหุ่น 3D โดยตรง · ภาพสำเร็จรูปทางขวา (วาดแบบ 2D)
  /// เปิด studio วาดภาพในหน้าเดิม: ฉาก 3D ตัวเดิม (WebView เดียวกับหน้าผู้ป่วย)
  /// เลื่อนจากตำแหน่งเดิมทางขวาไปพื้นที่ซ้าย · แถบบนและแผงขวาค่อย ๆ เข้ามา
  void _peOpenStudio([_PeShot? shot]) {
    // ค้างสถานะเปิดจากหน้าก่อน (ออกจากหน้าผู้ป่วยระหว่างเปิด) = เปิดใหม่ได้
    // เปิดอยู่จริง (ชั้น studio อยู่บนจอ) = ไม่เปิดซ้ำ · ค้างสถานะจากหน้าก่อน = เปิดใหม่
    if (_studioOn && _studioIn && !_studioClosing) return;
    setState(() {
      _studioOn = true;
      _studioIn = false;
      // เปิดรวมทุกคน: ภาพล่าสุดของตัวเอง = แก้ (บันทึกแทน) · ภาพอื่นทั้งหมด = แสดงรวม ดูอย่างเดียว
      final me = ErSession.instance.user?.name ?? '';
      final all = [
        for (final x in _peShotList)
          if (x.d3.isNotEmpty) x
      ];
      final own = all.where((x) => x.by == me).lastOrNull;
      _studioShot = own;
      _studioOpen = own;
      _studioOthers = [
        for (final x in all)
          if (!identical(x, own)) x
      ];
      // หุ่นเปลี่ยนเป็นลายเส้น + ซูมไปพร้อมกับการเลื่อน (ไม่สลับตอนจบ)
      _studioReady = true;
      _studioClosing = false;
    });
    // เริ่มเลื่อนหลังเฟรมแรก (เฟรมที่ย้ายฉาก + สร้างแผงหนัก) ไม่งั้นกินช่วงต้นของแอนิเมชัน
    // รอฉากเปลี่ยนเป็นหุ่นลายเส้นก่อน (กันเห็นผิวจริงแวบหนึ่ง) แล้วค่อยเลื่อน
    Future.delayed(const Duration(milliseconds: 380), () {
      if (mounted && _studioOn && !_studioClosing) {
        setState(() => _studioIn = true);
      }
    });
  }

  /// ปิด studio: คืนหุ่นปกติก่อน แล้วเลื่อนกลับตำแหน่งเดิม
  void _peCloseStudio() {
    if (!_studioOn || _studioClosing) return;
    _peScene.value = null;
    _sceneCtl.focus(null);
    setState(() {
      _studioClosing = true;
      _studioReady = false;
      // คืนระยะกล้องของหน้าผู้ป่วย (studio ซูมเข้าบริเวณไว้)
      _clyZoomTick++;
    });
    // กันค้าง: แอนิเมชันไม่จบ (สร้างชั้นใหม่กลางทาง) = ปิดให้ตามเวลา
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted && _studioClosing) {
        setState(() {
          _studioOn = false;
          _studioClosing = false;
        });
      }
    });
  }

  /// ชั้น studio เต็มจอ: ฉาก 3D ตัวเดิมขนาดคงที่ (ไม่ resize WebView ทุกเฟรม)
  /// ขยับด้วย Transform จากกรอบเดิม → พื้นที่ซ้าย · แถบบน/แผงขวาเลื่อนเข้า (ไม่ใช้ Opacity ทับ WebView)
  /// เลื่อนเสร็จแล้วค่อยเปลี่ยนหุ่นเป็นลายเส้น + ซูมทั้งตัว
  Widget _peStudioLayer(Widget scene, Rect from) =>
      LayoutBuilder(builder: (context, box) {
        final to = Rect.fromLTRB(0.0, MediaQuery.paddingOf(context).top + 64.0,
            box.maxWidth - 380.0, box.maxHeight);
        // กรอบเริ่ม: ขนาดสัดส่วนเดียวกับ to ย่อให้สูงเท่ากรอบเดิม วางกลางกรอบเดิม
        final k = from.height / to.height;
        final start = Rect.fromCenter(
            center: from.center, width: to.width * k, height: to.height * k);
        final target = _studioIn && !_studioClosing ? 1.0 : 0.0;
        final studio = _PeStudio(
          ctl: _sceneCtl,
          canvasKey: _studioCanvasKey,
          ready: _studioReady,
          onClose: _peCloseStudio,
          card: _dxCard,
          tiles: _dxTiles,
          art: _dxArtFade(const _ExamHero()),
          initial: _studioOpen,
          others: _studioOthers,
          // พยาบาล: ดูอย่างเดียว (ไม่มีเครื่องมือ/บันทึก)
          readOnly: ErSession.instance.isNurse,
          // อาการของเคสบนหุ่น: CC จากอาการสำคัญ (ทุกเคสมี) แล้ว Dx/ผลภาพถ่าย
          // ที่ไม่ซ้ำตำแหน่งเดิม · รวมอวัยวะภายใน (หุ่นเรืองแสงอวัยวะนั้นทะลุผิว)
          caseMarks: () {
            final cc = erBodyTargetsIn(_case.cc);
            final codes = {for (final t in cc) t.code};
            return [
              for (final t in cc) (t.code, _clyCcPhrase(t) ?? t.th, 'CC'),
              for (final t in erBodyTargets(_case))
                if (!codes.contains(t.code)) (t.code, _clyLabelText(t), 'Dx'),
            ];
          }(),
          labs: _case.labs,
          imaging: _case.imaging,
          onSpecial: (studio, name, id) {
            _peDraft = _PeShot(name: name, tpl: id.isEmpty ? null : id);
            _peDraftAt = -1;
            _peOpenFull();
          },
          // บันทึกแล้วอยู่หน้าวาดภาพต่อ · กดซ้ำ = แทนภาพเดิมของรอบนี้
          onSave: (strokes, snap, notes, photos, log, focus) {
            _peSave3d(strokes, snap, notes, photos, log, focus);
          },
          // หลังแอนิเมชันสำเร็จ: ปิดหน้าวาดภาพ แล้วปิด workflow panel
          onDone: () {
            _peCloseStudio();
            Future.delayed(const Duration(milliseconds: 480), () {
              if (mounted) _closeSpeech();
            });
          },
        );
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: target),
          duration: Duration(milliseconds: _studioClosing ? 420 : 520),
          curve: Curves.easeInOutCubic,
          onEnd: () {
            if (!mounted) return;
            if (_studioClosing) {
              setState(() {
                _studioOn = false;
                _studioClosing = false;
              });
            } else if (_studioIn && !_studioReady) {
              setState(() => _studioReady = true);
            }
          },
          // แผง studio สร้างครั้งเดียว (child) ไม่ rebuild ทุกเฟรม
          child: studio,
          builder: (context, t, child) {
            final r = Rect.lerp(start, to, t)!;
            final sc = r.width / to.width;
            return Stack(children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                      color: const Color(0xFFF1F3F4).withValues(alpha: t)),
                ),
              ),
              Positioned.fromRect(
                rect: to,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(r.left - to.left, r.top - to.top)
                    ..scale(sc, sc),
                  child: scene,
                ),
              ),
              // ก่อนเริ่มเลื่อน ฉากยังเป็นหุ่นผิวจริง (กำลังเปลี่ยนเป็นลายเส้น): ปิดไว้ไม่ให้เห็นแวบ
              if (!_studioIn && !_studioClosing)
                Positioned.fromRect(
                  rect: start,
                  child: const IgnorePointer(
                      child: ColoredBox(color: Color(0xFFF1F3F4))),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: t < 0.98,
                  child: _StudioChromeSlide(t: t, child: child!),
                ),
              ),
            ]);
          },
        );
      });

  /// บันทึกภาพที่วาดบนหุ่น 3D: ภาพฉากเป็นภาพย่อ · เส้น 3D แสดงบนหุ่นหน้าผู้ป่วย
  /// สิ่งที่พบแต่ละเส้น: ชิปสำเร็จรูป = ชนิดตามชิป · ข้อความเอง = ให้ AI ตัดสิน
  Future<void> _peSave3d(List<Map<String, Object?>> strokes, Uint8List? snap,
      [Map<String, String> notesBy = const {},
      Map<String, List<Uint8List>> photosBy = const {},
      Map<String, List<(String, String, String)>> noteLog = const {},
      Map<String, Uint8List> focus = const {}]) async {
    final notes = [
      for (final e in notesBy.entries) '${_peName(e.key)}: ${e.value}'
    ];
    final photos = [for (final l in photosBy.values) ...l];
    // ตำแหน่ง: บริเวณที่หุ่นคำนวณ (taxonomy CIS) · ไม่มี = กระดูก rig ที่ใกล้สุด
    final locs = [
      for (final s in strokes)
        _peRegions['${s['region']}']?.$2 ?? _peBoneLoc['${s['bone']}']
    ];
    String where(int i) =>
        ('${strokes[i]['region']}'.startsWith('organ:')
            ? _peName('${strokes[i]['region']}')
            : null) ??
        _peRegions['${strokes[i]['region']}']?.$1 ??
        _peLocs[locs[i]]?.$1 ??
        '';
    final names = {
      for (final (i, _) in strokes.indexed)
        if (where(i).isNotEmpty) where(i)
    };
    final now = DateTime.now();
    final shot = _PeShot(
      name: names.isEmpty ? 'หุ่น 3D' : names.take(2).join(' '),
      photo: snap,
      by: ErSession.instance.user?.name ?? '',
      at: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    )
      ..said = [...notes]
      ..attach = [...photos]
      ..focus = [...focus.values]
      ..focusBy = {...focus}
      ..notesBy = {...notesBy}
      ..attachBy = {...photosBy}
      ..noteLogBy = {
        for (final e in noteLog.entries) e.key: [...e.value]
      }
      ..d3 = [
        for (final s in strokes)
          {
            for (final e in s.entries)
              if (e.key != 'label' && e.key != 'view') e.key: e.value
          }
      ];
    setState(() {
      // studio รอบเดียวกันกดบันทึกซ้ำ = แทนภาพเดิม
      final list = _peShotList;
      final at = _studioShot == null ? -1 : list.indexOf(_studioShot!);
      if (at >= 0) {
        list[at] = shot;
      } else {
        list.add(shot);
      }
      _studioShot = shot;
      _detailTab = 2;
      _examMode = 1;
    });
    // ชนิดของสิ่งที่พบ
    final quick = {for (final (l, k) in _peQuickFindings) l: k};
    final custom = <int>[];
    final out = <(String, String, String, String)>[];
    for (final (i, s) in strokes.indexed) {
      final reg = '${s['region']}';
      if (reg.startsWith('organ:')) {
        if (s['label'] != null) {
          out.add((reg.substring(6), 'organ', _peLabel(s), _peName(reg)));
        }
        continue;
      }
      final loc = _peLocs[locs[i]];
      if (loc == null) continue;
      final label = '${s['label'] ?? ''}'.trim();
      final kind = label.isEmpty ? 'skin' : quick[label];
      if (kind == null) {
        custom.add(i);
        continue;
      }
      final code = kind == 'bone' ? (loc.$3 ?? loc.$2) : loc.$2;
      if (code != null) out.add((code, kind, _peLabel(s), where(i)));
    }
    if (custom.isNotEmpty) {
      try {
        final marks = [
          for (final i in custom)
            _PeStroke(Colors.red, 3.0, const [Offset.zero])
        ];
        final kinds = await _peAskKinds(
            marks,
            [for (final i in custom) locs[i]],
            {
              for (final (j, i) in custom.indexed)
                marks[j]: ['${strokes[i]['label']}']
            },
            'วาดบนหุ่น 3D');
        for (final (j, i) in custom.indexed) {
          final loc = _peLocs[locs[i]]!;
          final (kind, organ, label) =
              kinds[j] ?? ('skin', '', '${strokes[i]['label']}');
          final code = switch (kind) {
            'bone' => loc.$3 ?? loc.$2,
            'organ' => loc.$4.contains(organ)
                ? organ
                : (loc.$4.isEmpty ? loc.$2 : loc.$4.first),
            _ => loc.$2,
          };
          if (code != null) out.add((code, kind, label, where(i)));
        }
      } catch (_) {}
    }
    if (mounted) setState(() => shot.findings = out);
  }
}

/// หน้าย่อยพิมพ์ตรวจแบบละเอียด · ค่าเดิมก่อนแก้ (คืนเมื่อกดย้อนกลับ)
bool _peNoteEdit = false;
String? _peNoteBackup;

/// studio วาดภาพเปิดอยู่ (ชั้นบนหน้าผู้ป่วย ใช้ฉาก 3D ตัวเดิม) · กำลังปิด
bool _studioOn = false;
bool _studioClosing = false;

/// เริ่มเลื่อนเข้าแล้ว (หลังเฟรมแรก) · เลื่อนเสร็จ = เปลี่ยนหุ่นเป็นลายเส้น
bool _studioIn = false;

/// ภาพที่บันทึกจาก studio รอบนี้ (กดบันทึกซ้ำ = แทนที่) · เปิดใหม่ = เริ่มใหม่
_PeShot? _studioShot;

/// เวลาบันทึกแบบมีวันที่: "d/M/yyyy HH:MM" (พ.ศ.)
String _peNowStamp() {
  final n = DateTime.now();
  return '${n.day}/${n.month}/${n.year + 543} '
      '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
}

const List<String> _peThMonths = [
  'ม.ค.',
  'ก.พ.',
  'มี.ค.',
  'เม.ย.',
  'พ.ค.',
  'มิ.ย.',
  'ก.ค.',
  'ส.ค.',
  'ก.ย.',
  'ต.ค.',
  'พ.ย.',
  'ธ.ค.'
];

/// แสดงเวลาบันทึก: "19 ต.ค. 69 15:17 น." · ค่าเก่าที่มีแต่เวลา = วันนี้
String _peStamp(String v) {
  final p = v.split(' ');
  if (p.length < 2) return _peStamp('${_peNowStamp().split(' ').first} $v');
  final d = p[0].split('/');
  if (d.length != 3) return '$v น.';
  final m = int.tryParse(d[1]) ?? 1;
  final y = d[2].length == 4 ? d[2].substring(2) : d[2];
  return '${d[0]} ${_peThMonths[(m - 1).clamp(0, 11)]} $y ${p[1]} น.';
}

/// คีย์เรียงเวลาของ stamp "d/M/yyyy HH:MM" (ค่าเก่าที่มีแต่เวลา = วันนี้)
String _peStampKey(String v) {
  final p = v.split(' ');
  if (p.length < 2) return _peStampKey('${_peNowStamp().split(' ').first} $v');
  final d = p[0].split('/');
  if (d.length != 3) return v;
  return '${d[2].padLeft(4, '0')}${d[1].padLeft(2, '0')}'
      '${d[0].padLeft(2, '0')}${p[1].padLeft(5, '0')}';
}

/// เวลาแนบ + ผู้แนบ ของรูปประกอบแต่ละรูป (ผูกกับตัวรูป ไม่หายเมื่อเปิดภาพเดิมกลับมา)
final Expando<(String, String)> _peAttachMeta = Expando();

/// ภาพที่เปิดเข้ามาดู/แก้ใน studio รอบนี้ (null = เริ่มใหม่)
_PeShot? _studioOpen;

/// ภาพของคนอื่นที่แสดงรวมใน studio รอบนี้
List<_PeShot> _studioOthers = const [];
bool _studioReady = false;
final GlobalKey _studioCanvasKey = GlobalKey();

/// ค่าที่ studio สั่งฉาก 3D (ตัวเดิมของหน้าผู้ป่วย) · null = ฉากของหน้าผู้ป่วยปกติ
final ValueNotifier<_PeSceneCfg?> _peScene = ValueNotifier(null);

class _PeSceneCfg {
  const _PeSceneCfg({
    this.regionSel,
    this.highlight = const [],
    this.drawings = const [],
    this.draw,
    this.onStroke,
    this.onErase,
    this.onHotspots,
  });
  final String? regionSel;
  final List<String> highlight;
  final List<Map<String, Object?>> drawings;
  final Map<String, Object?>? draw;
  final ValueChanged<Map<String, Object?>>? onStroke;
  final ValueChanged<String>? onErase;
  final ValueChanged<List<ErBedScreenPos>>? onHotspots;
}

/// ภาพเฉพาะส่วนที่หุ่น 3D ไม่มีรายละเอียด (ฟัน ตา ฝีเย็บ) ใช้ภาพ HOSxP วาดแบบ 2D
const List<(String, String)> _peSpecialTpls = [
  ('ฟัน 1', '04'),
  ('ฟัน 2', '05'),
  ('ตา (ด้านหน้า)', '10'),
  ('ตา (เลนส์)', '28'),
  ('ตา (เปลือกตา)', '29'),
  ('ตาเข', '43'),
  ('ตา (มุมมอง)', '44'),
  ('ฝีเย็บ L1', '17'),
  ('ฝีเย็บ L2', '18'),
];

/// อวัยวะภายใน: (id บนหุ่น 3D, ชื่อไทย, มุมกล้อง)
const List<(String, String, Map<String, Object?>)> _peOrgans = [
  ('brain', 'สมอง', {'a': 'Head', 'zoom': 0.7}),
  ('heart', 'หัวใจ', {'a': 'Chest', 'zoom': 0.85}),
  ('lungs', 'ปอด', {'a': 'Chest', 'zoom': 0.9}),
  ('liver', 'ตับ', {'a': 'Belly', 'b': 'Chest', 't': 0.5, 'zoom': 0.85}),
  (
    'stomach',
    'กระเพาะอาหาร',
    {'a': 'Belly', 'b': 'Chest', 't': 0.5, 'zoom': 0.85}
  ),
  ('intestine', 'ลำไส้', {'a': 'Belly', 'zoom': 0.9}),
  ('kidneys', 'ไต', {'a': 'Belly', 'zoom': 0.9, 'spin': _pi}),
  ('bladder', 'กระเพาะปัสสาวะ', {'a': 'Pelvis', 'zoom': 0.8}),
];

/// ผล X-ray/Lab ที่เกี่ยวกับอวัยวะ: (ชื่อภาพขึ้นต้น, ชื่อ Lab ขึ้นต้น)
const Map<String, (List<String>, List<String>)> _peOrganResultKeys = {
  'brain': (['CT brain', 'MRI brain'], ['Glucose', 'Blood sugar', 'Na']),
  'heart': (['ECG', 'CXR', 'Echo'], ['Troponin', 'NT-proBNP', 'CK-MB', 'K']),
  'lungs': (['CXR', 'CT chest'], ['WBC', 'Lactate', 'HCO₃', 'ABG']),
  'liver': (
    ['US abdomen', 'CT abdomen'],
    ['AST', 'ALT', 'Bilirubin', 'Albumin', 'INR', 'Plt']
  ),
  'stomach': (['CT abdomen', 'Film abdomen'], ['Hb', 'Lipase']),
  'intestine': (['Film abdomen', 'CT abdomen'], ['Lactate', 'WBC', 'Hb']),
  'kidneys': (['US KUB', 'CT KUB'], ['Cr', 'BUN', 'K', 'Na', 'HCO₃', 'UA']),
  'bladder': (['US KUB'], ['UA']),
};

/// ชื่อไทยของบริเวณ (รวมอวัยวะภายใน 'organ:<id>')
String _peName(String? r) {
  if (r != null && r.startsWith('organ:')) {
    final id = r.substring(6);
    return _peOrgans.where((o) => o.$1 == id).firstOrNull?.$2 ?? id;
  }
  return _peRegions[r]?.$1 ?? 'บริเวณนี้';
}

/// มุมกล้องหมุนรอบตัว: หน้า · หลัง · ซ้าย · ขวา (ของผู้ป่วย)
const List<(String, double)> _peTurns = [
  ('หน้า', 0.0),
  ('ขวา', _pi / 2),
  ('หลัง', _pi),
  ('ซ้าย', -_pi / 2),
];

/// เครื่องมือบนหุ่น: (id, ไอคอน, ชื่อ)
const List<(String, IconData, String)> _peStudioTools = [
  // สำรวจ = หมุน/ซูมดูหุ่นอย่างเดียว แตะแล้วไม่ปักหมุด ไม่วาด
  ('move', Icons.explore_outlined, 'สำรวจ'),
  ('pin', Icons.add_location_alt_outlined, 'ปักหมุด'),
  ('pen', Icons.brush_outlined, 'ระบาย'),
  ('eraser', Icons.auto_fix_normal_outlined, 'ยางลบ'),
];

/// studio ตรวจร่างกาย (เต็มจอ)
/// ซ้าย: หุ่น 3D ลายเส้น · แตะ = ปักหมุด + ซูมไปที่จุดนั้น · ลาก = หมุน · สองนิ้ว = ซูม
///   มุมกล้อง (หน้า/ขวา/หลัง/ซ้าย) + ซูมลอยบนหุ่น
/// ขวา: ยังไม่เลือก = รายการตำแหน่งที่ปัก + ปุ่ม "เฉพาะส่วน" (ภาพ 2D ที่หุ่นไม่มี)
///       เลือกบริเวณแล้ว = รายละเอียดของบริเวณ: เครื่องมือ · จุดที่ปัก (ชนิดสิ่งที่พบ/ความปวด) · รูปประกอบ · บันทึก
class _PeStudio extends StatefulWidget {
  const _PeStudio(
      {this.anim,
      required this.ctl,
      required this.canvasKey,
      this.ready = true,
      required this.onClose,
      required this.card,
      required this.tiles,
      required this.art,
      this.caseMarks = const [],
      this.initial,
      this.readOnly = false,
      required this.onSpecial,
      required this.onSave,
      this.onDone,
      this.others = const [],
      this.labs = const [],
      this.imaging = const []});

  /// ภาพของแพทย์คนอื่น (และภาพเก่าของตัวเอง): แสดงรวมบนหุ่นเดียวกัน ดู/อ่านได้ แก้ไม่ได้
  final List<_PeShot> others;

  /// ผล Lab / X-ray ของเคส (แสดงในแผงอวัยวะภายใน)
  final List<ErLab> labs;
  final List<ErImage> imaging;

  /// บันทึกสำเร็จ (หลังแอนิเมชัน): ออกจากหน้าวาดภาพ
  final VoidCallback? onDone;

  /// เปิดภาพที่บันทึกแล้ว (หมุด รายละเอียด รูป) · null = เริ่มใหม่
  final _PeShot? initial;

  /// ภาพของคนอื่น: ดูได้อย่างเดียว (ไม่มีเครื่องมือ ไม่มีบันทึก)
  final bool readOnly;

  /// แอนิเมชันเปิด/ปิด (0 → 1): แผงขวาเลื่อนเข้า
  final Animation<double>? anim;

  /// ฉาก 3D ตัวเดียวกับหน้าผู้ป่วย (สั่งซูม/ถ่ายภาพ/ลบเส้น)
  final ErRoomDrawCtl ctl;

  /// เลื่อนเข้าเสร็จแล้ว: เริ่มสั่งฉาก (ลายเส้น หมุด ซูม)
  final bool ready;

  /// กรอบพื้นที่หุ่น: หน้าผู้ป่วยย้ายฉาก 3D มาวางตรงนี้
  final GlobalKey canvasKey;
  final VoidCallback onClose;

  /// การ์ด/แผ่นปุ่มลัด/ภาพ แบบหน้าวินิจฉัย (จาก state หลัก)
  final Widget Function(String title, String sub, Widget art, Widget body) card;
  final Widget Function(List<(IconData, String, VoidCallback)> actions) tiles;
  final Widget art;

  /// อาการของเคส: (รหัสบนหุ่น zone:/bone:, ข้อความจากเคส, ที่มา CC/Dx)
  final List<(String, String, String)> caseMarks;

  /// เปิดภาพเฉพาะส่วน (วาด 2D) ตามเลขภาพ HOSxP
  final void Function(BuildContext studio, String name, String id) onSpecial;
  final void Function(
      List<Map<String, Object?>> strokes,
      Uint8List? snap,
      Map<String, String> notes,
      Map<String, List<Uint8List>> photos,
      Map<String, List<(String, String, String)>> noteLog,
      Map<String, Uint8List> focus) onSave;

  @override
  State<_PeStudio> createState() => _PeStudioState();
}

class _PeStudioState extends State<_PeStudio> {
  ErRoomDrawCtl get _ctl => widget.ctl;
  String _tool = 'pin';

  /// ขนาดพู่กันระบาย (รัศมี ซม.)
  double _brush = 1.5;
  Color _color = const Color(0xFFD93025);
  final List<Map<String, Object?>> _strokes = [];
  bool _saving = false;

  /// สถานะตอนบันทึกล่าสุด (ว่าง = ยังไม่ได้ลงอะไร) ไว้เช็กว่ามีของค้างก่อนปิด
  String _savedSig = '';

  String _sig() => [
        for (final s in _strokes) '$s',
        for (final e in _notes.entries)
          if (e.value.text.trim().isNotEmpty) '${e.key}:${e.value.text.trim()}',
        for (final e in _noteLog.entries)
          '${e.key}:${e.value.map((v) => v.$1).join('|')}',
        for (final e in _photos.entries)
          if (e.value.isNotEmpty)
            '${e.key}:${e.value.map(identityHashCode).join(',')}',
      ].join(';');

  /// มีข้อมูลใหม่/แก้ไขตั้งแต่เปิดหรือบันทึกล่าสุด (ไม่มี = ปุ่มบันทึกกดไม่ได้)
  bool get _dirty => _sig() != _savedSig;

  /// ลายเซ็นข้อมูลของบริเวณเดียว (หมุด/สี รายละเอียด รูป ข้อความที่พิมพ์ค้าง)
  String _regionSig(String r) => [
        for (final s in _strokes)
          if (s['region'] == r) '$s',
        (_notes[r]?.text ?? '').trim(),
        for (final v in _noteLog[r] ?? const []) v.$1,
        for (final b in _photos[r] ?? const <Uint8List>[]) identityHashCode(b),
      ].join(';');

  /// ลายเซ็นแต่ละบริเวณ ณ ตอนเปิด/บันทึกล่าสุด
  Map<String, String> _savedRegionSig = {};
  void _markSaved() {
    _savedSig = _sig();
    _savedRegionSig = {for (final r in _used) r: _regionSig(r)};
  }

  /// บริเวณนี้มีข้อมูลใหม่ (ปุ่มบันทึกรายละเอียดกดได้)
  bool _regionDirty(String r) => _regionSig(r) != (_savedRegionSig[r] ?? '');

  /// บันทึกรายละเอียดของบริเวณ: ข้อความที่พิมพ์ค้าง = รายการใหม่ แล้วกลับภาพรวม
  void _saveRegion(String r) {
    _noteAdd(r);
    _overview();
  }

  /// บริเวณที่เลือกอยู่ (id แบบ CIS) · null = ภาพรวม
  String? _region;

  /// มุมกล้องปัจจุบัน (ดัชนีใน _peTurns)
  int _turn = 0;

  /// แสดงอาการของเคส (CC/Dx) บนหุ่น
  // ค่าเริ่มต้นซ่อน (2026-10-19) เปิดเองจากสวิตช์บนหุ่น
  bool _caseOn = false;

  GlobalKey get _canvasKey => widget.canvasKey;

  /// ตำแหน่งบนจอของหมุด (จากฉาก 3D) ไว้วางป้าย
  List<ErBedScreenPos> _pinPos = const [];

  bool _samePins(List<ErBedScreenPos> b) {
    if (b.length != _pinPos.length) return false;
    for (var i = 0; i < b.length; i++) {
      final a = _pinPos[i];
      if (a.code != b[i].code ||
          a.visible != b[i].visible ||
          (a.dx - b[i].dx).abs() > 0.5 ||
          (a.dy - b[i].dy).abs() > 0.5) {
        return false;
      }
    }
    return true;
  }

  /// badge ที่มา (CC/Dx): พื้นฟ้าอ่อน ตัวกรมท่า
  Widget _tagBadge(String tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child:
            Text(tag, style: _t(11.5, color: _blue, weight: FontWeight.w700)),
      );

  /// ป้ายบนหุ่น (หมุดที่ปัก + อาการของเคส CC/Dx) แบบ callout:
  /// แบ่งซ้าย/ขวาตามตำแหน่งจุด · แต่ละฝั่งเรียงเป็นคอลัมน์เดียวกัน ตามความสูงของจุด
  /// ดันลงไม่ให้ทับกัน (ล้นล่างดันกลับขึ้น) · เส้นนำหักมุมจากจุดไปหาป้าย
  /// ไม่ให้ป้ายไปทับแผ่นลอย (อวัยวะภายในซ้าย · เครื่องมือขวา)
  List<Widget> _labels(Size area) {
    // focus บริเวณอยู่ = แสดงป้ายเฉพาะหมุดของบริเวณนั้น (หมุดที่เพิ่งปัก) ไม่มี plot อื่น/CC/Dx
    const h = 32.0, gap = 6.0, lead = 22.0;
    const leftLimit = 176.0; // ขอบขวาของรายการอวัยวะภายใน + ระยะ
    final rightLimit = area.width - 96.0; // ขอบซ้ายของแถบเครื่องมือ
    const top0 = 64.0; // ใต้แถบมุมมอง
    final bottom0 = area.height - 24.0;
    final style = _t(13.5, color: _inkTitle, weight: FontWeight.w700);
    double textW(String t) {
      final tp = TextPainter(
          text: TextSpan(text: t, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: 180.0);
      return tp.width;
    }

    // รวบรวมป้าย
    final items = <_StudioLabel>[];
    // หลายคนปักบริเวณเดียวกัน = ป้ายเดียวต่อบริเวณ
    final labelled = <String>{};
    for (final p in _pinPos) {
      // นอกจอ (ตอนซูมเข้าบริเวณ) ไม่ต้องมีป้าย
      if (!p.visible ||
          p.dx < 0.0 ||
          p.dx > area.width ||
          p.dy < top0 ||
          p.dy > bottom0) {
        continue;
      }
      if (p.code.startsWith('pin:')) {
        final s = _strokes.firstWhere((x) => 'pin:${x['id']}' == p.code,
            orElse: () => const {});
        if (s.isEmpty || (_region != null && s['region'] != _region)) {
          continue;
        }
        if (s['region'] != null && !labelled.add('${s['region']}')) continue;
        final where = _name(s['region'] as String?);
        // แบบป้าย CC: บริเวณ + สิ่งที่บันทึก (รายละเอียดบรรทัดแรก)
        final note = _noteLatest('${s['region']}').split('\n').first;
        final text = [
          s['label'] == null ? where : '${_peLabel(s)}$where',
          if (note.isNotEmpty) note,
        ].join(' ');
        final ph = _photos['${s['region']}'];
        final thumb = ph == null || ph.isEmpty ? null : ph.last;
        items.add(_StudioLabel(
            Offset(p.dx, p.dy),
            text,
            null,
            textW(text) +
                56.0 +
                (thumb == null ? 0.0 : (ph!.length > 1 ? 33.0 : 30.0)),
            () => _focusRegion('${s['region']}', null),
            photo: thumb,
            photos: ph ?? const []));
      } else if (_caseOn && _region == null) {
        final i = widget.caseMarks.indexWhere((c) => c.$1 == p.code);
        if (i < 0) continue;
        final text = widget.caseMarks[i].$2;
        items.add(_StudioLabel(Offset(p.dx, p.dy), text, widget.caseMarks[i].$3,
            textW(text) + 62.0, null));
      }
    }
    if (items.isEmpty) return const [];

    // ฝั่ง: ซ้าย/ขวาของกึ่งกลางกลุ่มจุด · ฝั่งที่ไม่มีที่ว่างย้ายไปอีกฝั่ง
    final xs = [for (final it in items) it.at.dx]..sort();
    final cx = xs[xs.length ~/ 2];
    final left = [
      for (final it in items)
        if (it.at.dx < cx - 4.0) it
    ];
    final right = [
      for (final it in items)
        if (it.at.dx >= cx - 4.0) it
    ];
    double colL(List<_StudioLabel> l) =>
        l.map((e) => e.at.dx).reduce(math.min) - lead;
    double colR(List<_StudioLabel> l) =>
        l.map((e) => e.at.dx).reduce(math.max) + lead;
    // ฝั่งซ้ายแคบเกิน (ป้ายจะทับรายการอวัยวะ) = ย้ายไปขวาทีละป้าย (ป้ายกว้างสุดก่อน)
    left.sort((a, b) => b.w.compareTo(a.w));
    while (left.isNotEmpty && colL(left) - left.first.w < leftLimit) {
      final it = left.removeAt(0);
      if (right.isEmpty || colR([...right, it]) + it.w <= rightLimit) {
        right.add(it);
      } else {
        left.add(it); // ไม่มีที่ทั้งสองฝั่ง: คงไว้ แล้วตัดข้อความ
        break;
      }
    }

    // จุดที่ชิดแผ่นลอยเกิน (ป้ายจะบังจุดตัวเอง) ไปอีกฝั่ง
    const minW0 = 140.0;
    for (final it in [...right]) {
      if (it.at.dx + lead > rightLimit - minW0 &&
          it.at.dx - lead - it.w >= leftLimit) {
        right.remove(it);
        left.add(it);
      }
    }
    for (final it in [...left]) {
      if (it.at.dx - lead < leftLimit + minW0 &&
          it.at.dx + lead + it.w <= rightLimit) {
        left.remove(it);
        right.add(it);
      }
    }

    // เรียงตามความสูง ดันไม่ให้ทับกัน
    void stack(List<_StudioLabel> l) {
      l.sort((a, b) => a.at.dy.compareTo(b.at.dy));
      var y = top0 - gap;
      for (final it in l) {
        it.y = math.max(it.at.dy - h / 2, y + gap);
        y = it.y + h;
      }
      var lim = bottom0;
      for (final it in l.reversed) {
        if (it.y + h > lim) it.y = lim - h;
        lim = it.y - gap;
      }
    }

    stack(left);
    stack(right);
    // คอลัมน์ต้องเหลือที่ให้ป้ายอย่างน้อย 140 ไม่ล้นไปทับแผ่นลอย
    const minW = 140.0;
    final xl = left.isEmpty
        ? 0.0
        : colL(left)
            .clamp(leftLimit + minW, math.max(leftLimit + minW, area.width))
            .toDouble();
    final xr = right.isEmpty
        ? 0.0
        : colR(right).clamp(0.0, math.max(0.0, rightLimit - minW)).toDouble();

    final out = <Widget>[
      // เส้นนำทั้งหมดในชั้นเดียว
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
              painter: _StudioLeadPainter([
            for (final it in left)
              (it.at, Offset(xl, it.y + h / 2), it.tag == null ? _red : _blue),
            for (final it in right)
              (it.at, Offset(xr, it.y + h / 2), it.tag == null ? _red : _blue),
          ])),
        ),
      ),
    ];
    // จุด
    for (final it in items) {
      final pin = it.tag == null;
      out.add(Positioned(
        left: it.at.dx - 10.0,
        top: it.at.dy - 10.0,
        width: 20.0,
        height: 20.0,
        child: IgnorePointer(
          child: pin
              ? Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _red.withValues(alpha: 0.22)),
                  alignment: Alignment.center,
                  child: Container(
                    width: 11.0,
                    height: 11.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _red,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: _blue, width: 3.0),
                  ),
                ),
        ),
      ));
    }
    // ป้าย
    Widget chip(_StudioLabel it, double maxW) {
      final pin = it.tag == null;
      final box = Container(
        height: h,
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          // รูปเล็กของบริเวณ (ถ้ามี) หน้าป้าย
          if (it.photo != null) ...[
            it.photos.length > 1
                ? _photoStack(it.photos, 24.0,
                    _t(8.0, color: Colors.white, weight: FontWeight.w700))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Image.memory(it.photo!,
                        width: 24.0, height: 24.0, fit: BoxFit.cover),
                  ),
            const SizedBox(width: 6.0),
          ],
          // ป้ายกำกับที่มาแบบ CC/Dx: หมุดที่ปัก = "PE" (แดงอ่อน ตามสีหมุด)
          if (pin)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE8E6),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text('PE',
                  style: _t(11.5, color: _red, weight: FontWeight.w700)),
            )
          else
            _tagBadge(it.tag!),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(it.text,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
          ),
          if (pin) ...[
            const SizedBox(width: 2.0),
            const Icon(Icons.chevron_right_rounded, size: 18.0, color: _ink3),
          ],
        ]),
      );
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: math.max(90.0, maxW)),
        child: it.onTap == null
            ? IgnorePointer(child: box)
            : _Press(child: GestureDetector(onTap: it.onTap, child: box)),
      );
    }

    for (final it in left) {
      out.add(Positioned(
          right: area.width - xl, top: it.y, child: chip(it, xl - leftLimit)));
    }
    for (final it in right) {
      out.add(
          Positioned(left: xr, top: it.y, child: chip(it, rightLimit - xr)));
    }
    return out;
  }

  /// บันทึกเพิ่มเติม + รูปประกอบ ของแต่ละบริเวณ
  final Map<String, TextEditingController> _notes = {};

  /// รายละเอียดที่บันทึกแล้วแยกตามเวลา ต่อบริเวณ (ช่องพิมพ์ _notes = รายการใหม่ที่ยังไม่เพิ่ม)
  final Map<String, List<(String, String, String)>> _noteLog = {};

  /// เพิ่มข้อความในช่องพิมพ์เป็นรายการใหม่ (เวลา + ผู้บันทึก) แล้วล้างช่อง
  void _noteAdd(String r) {
    final t = (_notes[r]?.text ?? '').trim();
    if (t.isEmpty) return;
    final hm = _peNowStamp();
    setState(() {
      _noteLog
          .putIfAbsent(r, () => [])
          .add((t, hm, ErSession.instance.user?.name ?? ''));
      _notes[r]!.clear();
    });
  }

  String get _me => ErSession.instance.user?.name ?? '';

  /// แก้รายการรายละเอียดของตัวเอง (คงเวลาเดิม)
  Future<void> _noteEdit(String r, int i) async {
    final cur = _noteLog[r]![i];
    final ctl = TextEditingController(text: cur.$1);
    final t = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text('แก้รายละเอียด',
            style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
        content: TextField(
          controller: ctl,
          autofocus: true,
          minLines: 2,
          maxLines: 6,
          style: _t(14.0, color: _inkTitle, weight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: _panelSoft,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ยกเลิก',
                  style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _blue),
              onPressed: () => Navigator.pop(ctx, ctl.text),
              child: Text('บันทึก',
                  style:
                      _t(14.0, color: Colors.white, weight: FontWeight.w600))),
        ],
      ),
    );
    Future.delayed(const Duration(milliseconds: 400), ctl.dispose);
    if (t == null || t.trim().isEmpty || !mounted) return;
    setState(() => _noteLog[r]![i] = (t.trim(), cur.$2, cur.$3));
  }

  /// ลบรายการรายละเอียดของตัวเอง (หลังยืนยัน)
  Future<void> _noteRemove(String r, int i) async {
    final cur = _noteLog[r]![i];
    final name = cur.$1.split('\n').first;
    final ok = await _confirm(
        'ลบรายการนี้ (${name.length > 30 ? '${name.substring(0, 30)}…' : name})',
        Text('เมื่อดำเนินการแล้วไม่สามารถย้อนกลับได้',
            style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
        'ลบ');
    if (!ok || !mounted) return;
    setState(() => _noteLog[r]!.removeAt(i));
  }

  /// ข้อความล่าสุดของบริเวณ (ใช้กับป้าย/รายการ)
  String _noteLatest(String r) {
    final draft = (_notes[r]?.text ?? '').trim();
    if (draft.isNotEmpty) return draft;
    final l = _noteLog[r];
    return l == null || l.isEmpty ? '' : l.last.$1;
  }

  final Map<String, List<Uint8List>> _photos = {};
  TextEditingController _noteCtl(String r) =>
      _notes.putIfAbsent(r, TextEditingController.new);

  @override
  void dispose() {
    for (final c in _notes.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextStyle _t(double size,
          {Color color = _ink, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
          fontFamily: _fontFam,
          fontFamilyFallback: _fontFb,
          fontSize: size * _txtScale,
          color: color,
          fontWeight: _minW(weight));

  TextStyle _num(double size,
          {Color color = _ink, FontWeight weight = FontWeight.w500}) =>
      _t(size, color: color, weight: weight)
          .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  /// เลื่อนเข้าจาก offset ตามแอนิเมชันเปิดหน้า (ไม่มี = แสดงเลย)
  Widget _slideIn(Offset from, Widget child) {
    final a = widget.anim;
    if (a == null) return child;
    return SlideTransition(
      position: Tween(begin: from, end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    );
  }

  String _name(String? r) => _peName(r);

  bool get _organ => _region?.startsWith('organ:') ?? false;

  /// สิ่งที่พบของบริเวณ: หมุด (1 จุด) · อวัยวะภายใน = รายการไม่มีตำแหน่ง
  List<Map<String, Object?>> _pinsOf(String r) => [
        for (final s in _strokes)
          if (s['region'] == r &&
              ((s['pts'] as List).length == 1 || r.startsWith('organ:')))
            s
      ];

  void _openOrgan(String id) {
    final o = _peOrgans.firstWhere((x) => x.$1 == id);
    setState(() => _region = 'organ:$id');
    _ctl.focus(o.$3);
  }

  void _addOrganFinding() {
    final r = _region;
    if (r == null) return;
    setState(() => _strokes.add({
          'id': 'o${DateTime.now().microsecondsSinceEpoch}',
          'region': r,
          'color': '#d93025',
          'pts': const <Object>[],
        }));
  }

  /// ข้อมูลของตัวเอง (ที่จะบันทึก): หมุดไม่ใช่ ro · รายละเอียดที่เราเขียน · รูปที่เราแนบ
  List<Map<String, Object?>> get _ownStrokes => [
        for (final s in _strokes)
          if (s['ro'] != true) s
      ];
  Map<String, List<(String, String, String)>> get _ownLog => {
        for (final e in _noteLog.entries)
          if (e.value.any((v) => v.$3 == _me))
            e.key: [
              for (final v in e.value)
                if (v.$3 == _me) v
            ]
      };
  Map<String, List<Uint8List>> get _ownPhotos => {
        for (final e in _photos.entries)
          if (e.value.any((b) => (_peAttachMeta[b]?.$2 ?? _me) == _me))
            e.key: [
              for (final b in e.value)
                if ((_peAttachMeta[b]?.$2 ?? _me) == _me) b
            ]
      };

  /// บริเวณที่มีข้อมูลของตัวเอง (บันทึก/ถ่ายภาพย่อเฉพาะส่วนนี้)
  List<String> get _ownUsed => {
        for (final s in _ownStrokes)
          if (s['region'] != null) '${s['region']}',
        ..._ownPhotos.keys,
        for (final e in _notes.entries)
          if (e.value.text.trim().isNotEmpty) e.key,
        ..._ownLog.keys,
      }.toList();

  /// บริเวณที่มีจุด/เส้น/รูป/บันทึก เรียงตามลำดับที่เพิ่ม
  List<String> get _used => {
        for (final s in _strokes)
          if (s['region'] != null) '${s['region']}',
        for (final e in _photos.entries)
          if (e.value.isNotEmpty) e.key,
        for (final e in _notes.entries)
          if (e.value.text.trim().isNotEmpty) e.key,
        for (final e in _noteLog.entries)
          if (e.value.isNotEmpty) e.key,
      }.toList();

  void _focusRegion(String r, List<double>? pt) {
    setState(() => _region = r);
    final z = _peRegions[r]?.$3 ?? 0.7;
    if (pt != null) {
      _ctl.focus({'pt': pt, 'zoom': z});
    } else {
      final p = _strokes.lastWhere((s) => s['region'] == r,
          orElse: () => const {})['pts'];
      if (p is List && p.isNotEmpty) {
        _ctl.focus({
          'pt': [for (final v in p.first as List) (v as num).toDouble()],
          'zoom': z
        });
      }
    }
  }

  void _overview() {
    setState(() => _region = null);
    _ctl.focus({..._peWhole, 'spin': _peTurns[_turn].$2});
  }

  void _turnTo(int i) {
    setState(() {
      _turn = i;
      _region = null;
    });
    _ctl.focus({..._peWhole, 'spin': _peTurns[i].$2});
  }

  /// ปุ่มบันทึกล่างแผงขวา: บันทึกแล้วอยู่หน้าวาดภาพต่อ (กลับภาพรวม)
  /// ปุ่ม footer แบบ workflow panel (_navBtn): pill สูง 48 · หลัก = กรมท่าทึบ ·
  /// รอง = ขาวขอบเทา · ไอคอนหน้าข้อความ ระยะ 6
  Widget _footBtn(String label, IconData icon, VoidCallback? onTap,
      {bool primary = true, Color? fg0, Widget? lead}) {
    final on = onTap != null;
    final fg = primary && on ? Colors.white : (on ? (fg0 ?? _blue) : _g5);
    return _Press(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48.0,
          decoration: BoxDecoration(
            color: primary && on ? _blue : _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(
                color: primary && on
                    ? _blue
                    : (on ? const Color(0xFFC4C7C5) : _line)),
          ),
          // แบบปุ่มย้อนกลับ/ถัดไปของ workflow: ข้อความอย่างเดียว (ไอคอนเฉพาะตอนกำลังบันทึก)
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (lead != null) ...[lead, const SizedBox(width: 6.0)],
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14.0, color: fg, weight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }

  /// footer แผงขวา: แบบ workflow panel (ไม่มีเส้นคั่น ปุ่มลอยกว้างเท่ากัน)
  /// เลือกบริเวณอยู่ = ลบ (รอง ตัวแดง) | บันทึก (หลัก)
  Widget _saveFooter() => Padding(
        padding: EdgeInsets.fromLTRB(
            16.0, 14.0, 16.0, 10.0 + MediaQuery.paddingOf(context).bottom),
        child: Row(children: [
          Expanded(
            // ยังไม่มีหมุด = ปุ่มหลักคือเริ่มปักหมุด (เลือกเครื่องมือปักหมุด + เล่นคำแนะนำบนหุ่น)
            child: _region != null
                ? _footBtn('บันทึกรายละเอียด', Icons.check_rounded,
                    _regionDirty(_region!) ? () => _saveRegion(_region!) : null)
                : _footBtn(
                    _used.isEmpty ? 'เริ่มปักหมุด' : 'บันทึกภาพตรวจร่างกาย',
                    _used.isEmpty
                        ? Icons.add_location_alt_outlined
                        : Icons.check_rounded,
                    _saving
                        ? null
                        : _used.isEmpty
                            ? _startPin
                            : (_dirty ? _save : null),
                    lead: _saving
                        ? const SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.0, color: _g5))
                        : _used.isEmpty
                            ? null
                            : Icon(Icons.save_outlined,
                                size: 18.0,
                                color: _dirty ? Colors.white : _g5)),
          ),
        ]),
      );

  /// เล่นคำแนะนำการปักหมุดซ้ำ (เปลี่ยน key ให้แอนิเมชันเริ่มใหม่)
  int _coachTick = 0;

  void _startPin() => setState(() {
        _tool = 'pin';
        _coachTick++;
      });

  Future<void> _save() async {
    if (_saving || _ownUsed.isEmpty || !_dirty) return;
    // ยืนยันก่อนบันทึก: สรุปบริเวณที่จะบันทึก (เฉพาะของตัวเอง)
    final regs = _ownUsed;
    final ok = await _confirm(
        'บันทึกภาพตรวจร่างกาย?',
        Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('บันทึก ${regs.length} บริเวณ',
                  style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
              const SizedBox(height: 6.0),
              Text(regs.map(_name).join(', '),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
            ]),
        'บันทึก',
        tone: _blue);
    if (!ok || !mounted) return;
    setState(() => _saving = true);
    // ข้อความที่พิมพ์ค้างไว้ = เพิ่มเป็นรายการใหม่ก่อนบันทึก
    for (final r in [..._notes.keys]) {
      _noteAdd(r);
    }
    // ภาพย่อ: ซูมที่แต่ละบริเวณแล้วถ่ายทีละภาพ (หลายบริเวณ = สไลด์บนการ์ด)
    final focus = <String, Uint8List>{};
    for (final r in regs) {
      if (_region != r) {
        _focusRegion(r, null);
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
      }
      final b = await _ctl.snapshot();
      if (!mounted) return;
      if (b != null) focus[r] = b;
    }
    final snap = focus.isNotEmpty ? focus.values.first : await _ctl.snapshot();
    if (!mounted) return;
    final log = _ownLog;
    widget.onSave(
      [
        for (final s in _ownStrokes)
          {
            for (final e in s.entries)
              if (e.key != 'ro' && e.key != 'by') e.key: e.value
          }
      ],
      snap,
      {
        for (final e in log.entries)
          e.key: [for (final x in e.value) x.$1].join('\n')
      },
      _ownPhotos,
      log,
      focus,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _markSaved();
    });
    // แอนิเมชันบันทึกสำเร็จ แล้วออกจากหน้าวาดภาพ
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (ctx, _, __) => _PeSaveSuccess(
          regions: regs.length, onDone: () => Navigator.of(ctx).pop()),
    );
    if (!mounted) return;
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      _overview();
    }
  }

  /// ปุ่มยืนยันแบบเดียวกันทั้ง studio: ยกเลิก + ปุ่มแดง
  Future<bool> _confirm(String title, Widget content, String action,
          {Color? tone}) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _panel,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(title,
              style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
          content: content,
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('ยกเลิก',
                    style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: tone ?? _red),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(action,
                    style: _t(14.0,
                        color: Colors.white, weight: FontWeight.w600))),
          ],
        ),
      ) ==
      true;

  /// ลบรูปประกอบหลังยืนยัน (กันลบพลาด)
  Future<void> _askRemovePhoto(String r, int i, Uint8List b) async {
    final ok = await _confirm(
        'ลบรูปที่ ${i + 1}?',
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child:
                Image.memory(b, width: 64.0, height: 64.0, fit: BoxFit.cover),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Text('ลบแล้วรูปนี้จะหายจากบริเวณ${_name(r)}',
                style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
          ),
        ]),
        'ลบรูป');
    if (!ok || !mounted) return;
    setState(() => _photos[r]?.remove(b));
  }

  /// ลบบริเวณ: หมุด/เส้นบนหุ่น รายละเอียด รูป ของบริเวณนั้น แล้วกลับภาพรวม
  Future<void> _askRemoveRegion(String r) async {
    final ids = [
      for (final st in _strokes)
        if (st['region'] == r) '${st['id']}'
    ];
    final ok = await _confirm(
        'ลบบริเวณนี้ (${_name(r)})',
        Text('หมุด เส้นที่วาด รายละเอียด และรูปของบริเวณนี้จะหายทั้งหมด',
            style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
        'ลบบริเวณ');
    if (!ok || !mounted) return;
    for (final id in ids) {
      _ctl.erase(id);
    }
    setState(() {
      _strokes.removeWhere((st) => st['region'] == r);
      _notes.remove(r)?.clear();
      _noteLog.remove(r);
      _photos.remove(r);
    });
    _overview();
  }

  /// ปิด studio: มีของที่ยังไม่บันทึก ถามก่อน
  /// ปิด studio: มีข้อมูลยังไม่บันทึก = ถามบันทึกก่อนออก (บันทึก / ไม่บันทึก / ยกเลิก)
  Future<void> _askClose() async {
    if (widget.readOnly || _sig() == _savedSig) {
      widget.onClose();
      return;
    }
    final canSave = _ownUsed.isNotEmpty;
    final pick = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text('บันทึกภาพตรวจร่างกายก่อนออก?',
            style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
        content: Text('มีตำแหน่ง รูป หรือรายละเอียดที่ยังไม่ได้บันทึก',
            style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
        // ไม่บันทึก ซ้ายสุด (แยกจากปุ่มหลัก) · ยกเลิก = ปิดหน้าต่าง อยู่ต่อในหน้าวาด
        actions: [
          Row(children: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'discard'),
                child: Text('ไม่บันทึก',
                    style: _t(14.0, color: _red, weight: FontWeight.w600))),
            const Spacer(),
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: Text('ยกเลิก',
                    style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
            if (canSave) ...[
              const SizedBox(width: 4.0),
              FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: _blue, shape: const StadiumBorder()),
                  onPressed: () => Navigator.pop(ctx, 'save'),
                  child: Text('บันทึก',
                      style: _t(14.0,
                          color: Colors.white, weight: FontWeight.w600))),
            ],
          ]),
        ],
      ),
    );
    if (!mounted) return;
    if (pick == 'discard') widget.onClose();
    // บันทึก = ขั้นตอนเดียวกับปุ่มบันทึกมุมขวาบน (ยืนยัน แอนิเมชัน แล้วออก)
    if (pick == 'save') await _save();
  }

  Future<void> _attach(ImageSource src) async {
    final r = _region;
    if (r == null) return;
    try {
      final f = await ImagePicker()
          .pickImage(source: src, maxWidth: 1600, imageQuality: 85);
      if (f == null) return;
      final b = await f.readAsBytes();
      if (!mounted) return;
      // เวลา + ผู้แนบ ติดไปกับรูป (แสดงในรายการรูป และคงอยู่เมื่อเปิดภาพเดิมกลับมา)
      _peAttachMeta[b] = (
        _peNowStamp(),
        ErSession.instance.user?.name ?? '',
      );
      setState(() => _photos.putIfAbsent(r, () => []).add(b));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(src == ImageSource.camera
              ? 'เปิดกล้องไม่ได้ในเครื่องนี้'
              : 'เปิดคลังภาพไม่ได้')));
    }
  }

  Future<void> _customLabel(Map<String, Object?> s) async {
    final ctl = TextEditingController();
    final t = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Text('สิ่งที่พบ',
            style: _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
        content: TextField(
          controller: ctl,
          autofocus: true,
          style: _t(15.0, color: _inkTitle, weight: FontWeight.w500),
          decoration: const InputDecoration(hintText: 'เช่น ข้อไหล่หลุด ตับโต'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('ยกเลิก',
                  style: _t(14.0, color: _ink2, weight: FontWeight.w600))),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(ctl.text),
              child: Text('บันทึก',
                  style: _t(14.0, color: _blue, weight: FontWeight.w700))),
        ],
      ),
    );
    Future.delayed(const Duration(milliseconds: 400), ctl.dispose);
    if (t == null || t.trim().isEmpty || !mounted) return;
    setState(() => s['label'] = t.trim());
  }

  // ------------------------------------------------------------ แถบบน

  Widget _topBar() {
    Widget icon(IconData i, String tip, VoidCallback? on) => IconButton(
        tooltip: tip,
        onPressed: on,
        icon: Icon(i, size: 24.0, color: on == null ? _ink3 : _inkTitle));
    final n = _used.length;
    return Container(
      height: 64.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: const BoxDecoration(
        color: _panel,
        border:
            Border(bottom: BorderSide(color: Color(0xFFDADCE0), width: 0.5)),
      ),
      child: Row(children: [
        icon(Icons.close_rounded, 'ปิด', _askClose),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.readOnly ? 'ภาพตรวจร่างกาย' : 'วาดภาพตรวจร่างกาย',
                    style: _t(18.0, color: _inkTitle, weight: FontWeight.w700)),
                Text(
                    widget.readOnly
                        ? 'ดูอย่างเดียว ภาพจากแพทย์'
                        : n == 0
                            ? 'แตะบนหุ่นตรงจุดที่ผิดปกติเพื่อปักตำแหน่ง'
                            : 'ระบุแล้ว $n บริเวณ',
                    style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
              ]),
        ),
        // หน้าเปล่า: เปิดหน้าวาด 2D บนกระดาษขาว (ปุ่มรอง ขาวขอบเทา)
        if (!widget.readOnly) ...[
          _Press(
            child: GestureDetector(
              onTap: () => widget.onSpecial(context, 'หน้าเปล่า', ''),
              child: Container(
                height: 40.0,
                padding: const EdgeInsets.fromLTRB(14.0, 0.0, 18.0, 0.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: const Color(0xFFC4C7C5)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.note_add_outlined, size: 18.0, color: _blue),
                  const SizedBox(width: 6.0),
                  Text('หน้าเปล่า',
                      style: _t(14.0, color: _blue, weight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
        // ปุ่มบันทึกอยู่มุมขวาบน (แทนปุ่มย้อนเดิม)
        if (!widget.readOnly)
          _Press(
            child: GestureDetector(
              onTap: _saving || _used.isEmpty || !_dirty ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 40.0,
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                decoration: BoxDecoration(
                  color: _used.isEmpty || !_dirty ? _panelSoft : _blue,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _saving
                      ? const SizedBox(
                          width: 18.0,
                          height: 18.0,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.0, color: Colors.white))
                      : Icon(Icons.save_outlined,
                          size: 18.0,
                          color: _used.isEmpty || !_dirty ? _g5 : Colors.white),
                  const SizedBox(width: 6.0),
                  Text('บันทึกภาพตรวจร่างกาย',
                      style: _t(14.0,
                          color: _used.isEmpty || !_dirty ? _g5 : Colors.white,
                          weight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        const SizedBox(width: 12.0),
      ]),
    );
  }

  // ------------------------------------------------------------ ลอยบนหุ่น

  Widget _floatCard(Widget child,
          {EdgeInsets pad = const EdgeInsets.all(4.0)}) =>
      Container(
        padding: pad,
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: child,
      );

  /// มุมกล้อง หน้า · ขวา · หลัง · ซ้าย (segmented ลอยกลางล่าง)
  Widget _turnBar() => _floatCard(
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (i, (label, _)) in _peTurns.indexed)
            _Press(
              child: GestureDetector(
                onTap: () => _turnTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 36.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _turn == i && _region == null
                        ? const Color(0xFFD3E3FD)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(label,
                      style: _t(13.5,
                          color: _turn == i && _region == null ? _blue : _ink2,
                          weight: FontWeight.w600)),
                ),
              ),
            ),
        ]),
      );

  /// แถบบอกบริเวณที่เลือก + ปุ่มกลับภาพรวม (ลอยกลางบน)
  Widget _regionChip() => _floatCard(
        Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 10.0),
          const Icon(Icons.location_on_rounded, size: 18.0, color: _blue),
          const SizedBox(width: 6.0),
          Text(_name(_region),
              style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          const SizedBox(width: 6.0),
          _Press(
            child: GestureDetector(
              onTap: _overview,
              child: Container(
                height: 32.0,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _panelSoft,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text('ทั้งตัว',
                    style: _t(13.0, color: _blue, weight: FontWeight.w600)),
              ),
            ),
          ),
        ]),
      );

  // ------------------------------------------------------------ แผงขวา

  Widget _sectionTitle(String t, {Widget? trail, double top = 18.0}) => Padding(
        padding: EdgeInsets.fromLTRB(4.0, top, 4.0, 8.0),
        child: Row(children: [
          Expanded(
            child: Text(t,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          if (trail != null) trail,
        ]),
      );

  Widget _pill(String label, bool on, VoidCallback onTap, {Color? dot}) =>
      _Press(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 32.0,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: on ? (dot ?? _blue).withValues(alpha: 0.12) : _panel,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                  color: on ? (dot ?? _blue) : const Color(0xFFDADCE0),
                  width: on ? 1.0 : 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (dot != null) ...[
                Container(
                    width: 8.0,
                    height: 8.0,
                    decoration:
                        BoxDecoration(color: dot, shape: BoxShape.circle)),
                const SizedBox(width: 6.0),
              ],
              Text(label,
                  style: _t(13.0,
                      color: on ? (dot ?? _blue) : _inkTitle,
                      weight: FontWeight.w600)),
            ]),
          ),
        ),
      );

  /// ภาพรวม: รายการบริเวณที่ระบุแล้ว + ภาพเฉพาะส่วน
  /// แผ่นลอยบนฝั่งหุ่น: แบบการ์ดแผงขวา (ขาว ขอบ 0.5 มุม 16 ไม่มีเงา)
  Widget _floatPanel(Widget child) => Container(
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: child,
      );

  Widget _floatItem(IconData? ic, String label, bool on, VoidCallback onTap,
          {int count = 0, List<(String, bool, bool)>? paths}) =>
      _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 36.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: on ? const Color(0xFFE8F0FE) : Colors.transparent,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (paths != null) ...[
                _SolarIcon('',
                    size: 20.0,
                    color: on ? _blue : _ink2,
                    // เส้นจาก Figma บาง = หนาเพิ่ม
                    grow: 0.6,
                    paths: paths),
                const SizedBox(width: 8.0),
              ] else if (ic != null) ...[
                Icon(ic, size: 18.0, color: on ? _blue : _ink2),
                const SizedBox(width: 8.0),
              ],
              Text(label,
                  style: _t(13.0,
                      color: on ? _blue : _inkTitle, weight: FontWeight.w600)),
              if (count > 0) ...[
                const SizedBox(width: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text('$count',
                      style: _num(11.0,
                          color: Colors.white, weight: FontWeight.w700)),
                ),
              ],
            ]),
          ),
        ),
      );

  /// มุมมอง: segmented แนวนอน (ทั้งตัว · เฉพาะส่วน)
  Widget _viewBar() =>
      _floatPanel(Row(mainAxisSize: MainAxisSize.min, children: [
        _floatItem(Icons.collections_outlined, 'เทมเพลต', false, _specialSheet),
      ]));

  /// สวิตช์แสดงป้ายอาการของเคสบนหุ่น
  /// สวิตช์แสดง/ซ่อนอาการของเคสบนหุ่น: ชื่อสั้น + สวิตช์เด่น (pill ขาวขอบบาง)
  Widget _caseToggle() => _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _caseOn = !_caseOn),
          child: Container(
            height: 40.0,
            padding: const EdgeInsets.fromLTRB(14.0, 0.0, 4.0, 0.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('CC/Dx',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 2.0),
              Switch(
                value: _caseOn,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeThumbColor: Colors.white,
                activeTrackColor: _blue,
                onChanged: (v) => setState(() => _caseOn = v),
              ),
            ]),
          ),
        ),
      );

  /// เครื่องมือบนหุ่น: สำรวจ · ปักหมุด (หลัก) · เลือกปักหมุดแล้วมีเมนูย่อย วาด · ลบเส้น
  /// เมนูย่อยเป็นแผ่นพื้น surface ใต้ปักหมุด (เล็กกว่า) · วาด = เลือกรูปทรง + สีในแผ่นเดียวกัน
  Widget _drawTools() {
    final sub = _tool != 'move';
    Widget item(String id, IconData ic, String label,
        {bool small = false, bool parent = false}) {
      final on = _tool == id;
      final tint = on || parent;
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _tool = id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: small ? 56.0 : 64.0,
            padding: EdgeInsets.symmetric(vertical: small ? 6.0 : 8.0),
            decoration: BoxDecoration(
              color: on
                  ? (small ? _panel : const Color(0xFFE8F0FE))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(small ? 10.0 : 12.0),
              border: on && small
                  ? Border.all(color: const Color(0xFFDADCE0), width: 0.5)
                  : null,
            ),
            child: Column(children: [
              Icon(ic, size: small ? 18.0 : 22.0, color: tint ? _blue : _ink2),
              const SizedBox(height: 3.0),
              Text(label,
                  style: _t(small ? 11.0 : 11.5,
                      color: tint ? _blue : _ink2, weight: FontWeight.w600)),
            ]),
          ),
        ),
      );
    }

    Widget divider() => Container(
        width: 36.0,
        height: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        color: const Color(0xFFDADCE0));

    return _floatPanel(Column(mainAxisSize: MainAxisSize.min, children: [
      for (final (id, ic, label) in _peStudioTools)
        if (id != 'pen' && id != 'eraser')
          item(id, ic, label,
              parent: id == 'pin' && (_tool == 'pen' || _tool == 'eraser')),
      // เมนูย่อยของปักหมุด: กางลงจากใต้ปักหมุด (ขยายความสูง + เลื่อนลงเล็กน้อย)
      // ไม่ใช้ Opacity (แผงลอยทับ WebView)
      AnimatedSize(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: !sub
            ? const SizedBox(width: 64.0)
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: -8.0, end: 0.0),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (_, dy, child) =>
                    Transform.translate(offset: Offset(0.0, dy), child: child),
                child: Container(
                  width: 64.0,
                  margin: const EdgeInsets.only(top: 4.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final (id, ic, label) in _peStudioTools)
                      if (id == 'pen' || id == 'eraser')
                        item(id, ic, label, small: true),
                    if (_tool == 'pen') ...[
                      divider(),
                      // ความหนาพู่กัน: แถบเลื่อนแนวตั้ง (บาง ↓ · หนา ↑)
                      SizedBox(
                        width: 40.0,
                        height: 64.0,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4.0,
                              activeTrackColor: _blue,
                              inactiveTrackColor: const Color(0xFFDADCE0),
                              thumbColor: _blue,
                              overlayShape: SliderComponentShape.noOverlay,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8.0),
                            ),
                            child: Slider(
                              value: _brush,
                              min: 0.5,
                              max: 4.0,
                              onChanged: (v) => setState(() => _brush = v),
                            ),
                          ),
                        ),
                      ),
                      Text('${_brush.toStringAsFixed(1)} ซม.',
                          style:
                              _t(10.5, color: _ink2, weight: FontWeight.w600)),
                      divider(),
                      // สี 2 คอลัมน์
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: [
                          for (final c in _peFullColors.take(6))
                            GestureDetector(
                              onTap: () => setState(() => _color = c),
                              child: Container(
                                width: 20.0,
                                height: 20.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c,
                                  border: Border.all(
                                      color: _color == c ? _blue : Colors.white,
                                      width: _color == c ? 2.5 : 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                    ],
                  ]),
                ),
              ),
      ),
    ]));
  }

  /// อวัยวะภายใน: รายการแนวตั้ง
  Widget _organList() => _floatPanel(IntrinsicWidth(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                child: Text('อวัยวะภายใน',
                    style: _t(12.0, color: _ink3, weight: FontWeight.w700)),
              ),
              for (final (id, th, _) in _peOrgans)
                _floatItem(
                    null, th, _region == 'organ:$id', () => _openOrgan(id),
                    count: _pinsOf('organ:$id').length,
                    paths: _peOrganIcons[id]),
            ]),
      ));

  /// แผ่นรายการในการ์ด (แบบรายการในการ์ดวินิจฉัย): ขาว ขอบ 0.5 มุม 16 · แถวคั่นเส้นบาง
  Widget _listBox(List<Widget> rows) => Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: Column(children: [
          for (final (i, r) in rows.indexed)
            Container(
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : const Border(
                        top: BorderSide(color: Color(0xFFE8EAED), width: 0.5)),
              ),
              child: r,
            ),
        ]),
      );

  /// ภาพรวม (แบบขั้นแรกของเมนูวินิจฉัย): การ์ดหัวข้อ + คำอธิบาย + ภาพมุมขวา
  /// แผ่นปุ่มลัด แล้วรายการที่ลงแล้ว
  Widget _overviewPanel() {
    final used = _used;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 96.0),
      children: [
        widget.card(
          'ภาพตรวจร่างกาย',
          widget.readOnly
              ? (used.isEmpty
                  ? 'ไม่มีตำแหน่งที่บันทึก'
                  : 'บันทึก ${used.length} บริเวณ แตะเพื่อดูรายละเอียด')
              : used.isEmpty
                  ? 'แตะบนหุ่นตรงจุดที่ผิดปกติเพื่อปักตำแหน่ง'
                  : 'ระบุแล้ว ${used.length} บริเวณ แตะเพื่อแก้ไข',
          widget.art,
          used.isEmpty && widget.readOnly
              ? const SizedBox(height: 8.0)
              : used.isEmpty
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 18.0),
                      decoration: BoxDecoration(
                        color: _panelSoft,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(children: [
                        const Icon(Icons.touch_app_outlined,
                            size: 22.0, color: _blue),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                              'ปักหมุดแล้วระบบซูมไปที่บริเวณนั้น ลงรายละเอียด แนบรูป และวาดเพิ่มได้',
                              style: _t(13.0,
                                  color: _ink2, weight: FontWeight.w500)),
                        ),
                      ]),
                    )
                  : _listBox([for (final r in used) _usedRow(r)]),
        ),
        // อาการของเคส (CC จากอาการสำคัญ · Dx จากการวินิจฉัย) ที่แสดงบนหุ่น
        if (widget.caseMarks.isNotEmpty) ...[
          const SizedBox(height: 12.0),
          widget.card(
            'อาการของเคส',
            'จากอาการสำคัญ (CC) และการวินิจฉัย (Dx)',
            const SizedBox.shrink(),
            _listBox([
              for (final c in widget.caseMarks)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
                  child: Row(children: [
                    SizedBox(
                        width: 34.0,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: _tagBadge(c.$3))),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(c.$2,
                          style: _t(14.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ),
                  ]),
                ),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _usedRow(String r) {
    final pins = _pinsOf(r);
    final labels = {
      for (final s in pins)
        if (s['label'] != null) _peLabel(s)
    };
    final photos = _photos[r]?.length ?? 0;
    final note = _noteLatest(r);
    final empty = labels.isEmpty && note.isEmpty && photos == 0;
    // วันเวลาที่แก้ล่าสุดของบริเวณ (รายละเอียด/รูปประกอบ ที่ใหม่สุด)
    final stamps = [
      for (final e in _noteLog[r] ?? const []) e.$2 as String,
      for (final b in _photos[r] ?? const <Uint8List>[])
        if (_peAttachMeta[b] != null) _peAttachMeta[b]!.$1,
    ]..sort((a, b) => _peStampKey(a).compareTo(_peStampKey(b)));
    return _Press(
      child: GestureDetector(
        onTap: () => _focusRegion(r, null),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 8.0, 10.0),
          child: Row(children: [
            // ภาพเล็กของบริเวณ: หลายรูป = ซ้อนเป็นปึก + ป้าย +x
            _regionThumb(r),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name(r),
                        style: _t(14.5,
                            color: _inkTitle, weight: FontWeight.w700)),
                    Text(
                        [
                          if (labels.isNotEmpty) labels.join(', '),
                          if (note.isNotEmpty) note,
                          if (labels.isEmpty && note.isEmpty && photos == 0)
                            'ยังไม่มีรายละเอียด',
                        ].join('  '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.5,
                            color: empty ? _ink3 : _ink2,
                            weight: FontWeight.w500)),
                    if (stamps.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(_peStamp(stamps.last),
                            style: _t(12.0,
                                color: _ink3, weight: FontWeight.w500)),
                      ),
                  ]),
            ),
            const Icon(Icons.chevron_right_rounded, color: _ink3),
          ]),
        ),
      ),
    );
  }

  Widget _regionThumb(String r) {
    final list = _photos[r] ?? const <Uint8List>[];
    Widget tile(Widget child, {double size = 48.0}) => Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: child,
        );
    // ไม่ได้แนบรูป: ใช้ภาพซูมบริเวณนั้นจากภาพที่บันทึกไว้ (ถ้ามี)
    final fz = widget.initial?.focusBy[r] ??
        [for (final o in widget.others) o.focusBy[r]].nonNulls.firstOrNull;
    if (list.isEmpty && fz != null) {
      return tile(Image.memory(fz, fit: BoxFit.cover));
    }
    if (list.isEmpty) {
      return tile(Icon(
          r.startsWith('organ:')
              ? Icons.monitor_heart_outlined
              : Icons.location_on_outlined,
          size: 22.0,
          color: _blue));
    }
    if (list.length == 1) {
      return tile(Image.memory(list.first, fit: BoxFit.cover));
    }
    return _photoStack(
        list, 48.0, _t(11.0, color: Colors.white, weight: FontWeight.w700));
  }

  /// ภาพเฉพาะส่วน: ภาพ HOSxP ครบ 44 ภาพ แบ่งหมวด (ฟัน ตา ฝีเย็บ ที่หุ่นไม่มี ขึ้นก่อน)
  void _specialSheet() {
    final groups = <(String, List<(String, String)>)>[
      ('ฟัน', _peSpecialTpls.where((t) => t.$1.startsWith('ฟัน')).toList()),
      ('ตา', _peSpecialTpls.where((t) => t.$1.startsWith('ตา')).toList()),
      (
        'ฝีเย็บ',
        _peSpecialTpls.where((t) => t.$1.startsWith('ฝีเย็บ')).toList()
      ),
      ..._peTplGroups,
    ];
    Widget tile(BuildContext ctx, String name, String id) => _Press(
          child: GestureDetector(
            onTap: () {
              Navigator.of(ctx).pop();
              widget.onSpecial(context, name, id);
            },
            child: SizedBox(
              width: 104.0,
              child: Column(children: [
                Container(
                  width: 104.0,
                  height: 104.0,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  // กระดาษเปล่า (id ว่าง) = แผ่นขาวขอบบาง ไม่มีภาพพื้น
                  child: id.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                                color: const Color(0xFFDADCE0), width: 0.5),
                          ),
                          child: const Icon(Icons.edit_outlined,
                              size: 26.0, color: _ink3),
                        )
                      : Image.asset(_peTplAsset(id),
                          fit: BoxFit.contain, cacheWidth: 240),
                ),
                const SizedBox(height: 6.0),
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(12.5, color: _ink, weight: FontWeight.w500)),
              ]),
            ),
          ),
        );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      constraints: BoxConstraints(
          maxWidth: 640.0, maxHeight: MediaQuery.sizeOf(context).height * 0.86),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (ctx) => SafeArea(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 36.0,
                          height: 4.0,
                          decoration: BoxDecoration(
                              color: const Color(0xFFDADCE0),
                              borderRadius: BorderRadius.circular(100.0)),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text('เทมเพลต',
                          style: _t(18.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                      Text(
                          'ภาพจาก HOSxP ${groups.fold<int>(0, (n, g) => n + g.$2.length)} ภาพ เลือกแล้ววาดบนภาพ 2D',
                          style:
                              _t(13.0, color: _ink3, weight: FontWeight.w500)),
                    ]),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                  children: [
                    for (final (g, items) in groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 8.0),
                        child: Text(g,
                            style: _t(14.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                      ),
                      Wrap(spacing: 12.0, runSpacing: 12.0, children: [
                        for (final (name, id) in items) tile(ctx, name, id),
                      ]),
                    ],
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  /// รายละเอียดของบริเวณที่เลือก
  Widget _regionPanel() {
    final r = _region!;
    final photos = _photos[r] ?? const <Uint8List>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 96.0),
      children: [
        // breadcrumb แบบหน้าย่อยวินิจฉัย: ตำแหน่งที่ตรวจพบ › บริเวณ · แตะส่วนแรก = กลับภาพรวม
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
          child: Row(children: [
            InkWell(
              onTap: _overview,
              borderRadius: BorderRadius.circular(100.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('ภาพตรวจร่างกาย',
                    style: _t(14.0, color: _blue, weight: FontWeight.w600)),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20.0, color: _ink3),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(_name(r),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
            ),
          ]),
        ),
        // รายละเอียด (บันทึก) อยู่เหนือรูปประกอบ
        _sectionTitle('รายละเอียด', top: 2.0),
        // แยกตามเวลา: รายการที่บันทึกแล้ว (เวลา + ผู้บันทึก) เก่า → ใหม่ แล้วช่องเพิ่มรายการใหม่
        if ((_noteLog[r] ?? const []).isNotEmpty)
          _listBox([
            // ล่าสุดขึ้นก่อน · วันที่ + เวลา + ผู้บันทึก · แก้/ลบได้เฉพาะของตัวเอง
            for (final (i, (t, hm, who))
                in _noteLog[r]!.indexed.toList().reversed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14.0, 10.0, 4.0, 10.0),
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t,
                              style: _t(14.0,
                                  color: _inkTitle, weight: FontWeight.w500)),
                          const SizedBox(height: 2.0),
                          Text(
                              [
                                _peStamp(hm),
                                if (who.isNotEmpty) who,
                              ].join('  '),
                              style: _t(12.0,
                                  color: _ink3, weight: FontWeight.w500)),
                        ]),
                  ),
                  if (!widget.readOnly && who == _me) ...[
                    IconButton(
                      tooltip: 'แก้ไข',
                      iconSize: 19.0,
                      constraints:
                          const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                      onPressed: () => _noteEdit(r, i),
                      icon: const Icon(Icons.edit_outlined, color: _ink2),
                    ),
                    IconButton(
                      tooltip: 'ลบ',
                      iconSize: 19.0,
                      constraints:
                          const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                      onPressed: () => _noteRemove(r, i),
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: _ink2),
                    ),
                  ],
                ]),
              ),
          ])
        else if (widget.readOnly)
          Text('ไม่มีรายละเอียด',
              style: _t(13.5, color: _ink3, weight: FontWeight.w500)),
        if (!widget.readOnly)
          TextField(
            controller: _noteCtl(r),
            minLines: 2,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            style: _t(14.0, color: _inkTitle, weight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: (_noteLog[r] ?? const []).isEmpty
                  ? 'เช่น ขนาดแผล ความลึก ลักษณะขอบแผล'
                  : 'เพิ่มรายละเอียดใหม่ (บันทึกเวลาแยก)',
              hintStyle: _t(13.5, color: _ink3, weight: FontWeight.w500),
              filled: true,
              fillColor: _panelSoft,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide.none),
            ),
          ),
        // รูปประกอบ: การ์ดแบบเมนูวินิจฉัย (หัวข้อ คำอธิบาย แผ่นในขาวขอบบาง)
        const SizedBox(height: 16.0),
        widget.card(
          'รูปประกอบ',
          photos.isEmpty
              ? (widget.readOnly
                  ? 'ไม่มีรูป'
                  : 'ถ่ายหรือเลือกรูปแผล/จุดที่ตรวจพบ')
              : 'แนบแล้ว ${photos.length} รูป',
          const SizedBox.shrink(),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (!widget.readOnly)
              widget.tiles([
                (
                  Icons.photo_camera_outlined,
                  'ถ่ายภาพ',
                  () => _attach(ImageSource.camera)
                ),
                (
                  Icons.add_photo_alternate_outlined,
                  'คลังภาพ',
                  () => _attach(ImageSource.gallery)
                ),
              ]),
            // รายการรูป: แถวละรูป คั่นด้วยเส้น ไม่มีกรอบครอบ
            if (photos.isNotEmpty)
              Column(children: [
                for (final (i, b) in photos.indexed)
                  Container(
                    decoration: BoxDecoration(
                      border: i == 0
                          ? null
                          : const Border(
                              top: BorderSide(
                                  color: Color(0xFFE8EAED), width: 0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4.0, 8.0, 0.0, 8.0),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.memory(b,
                              width: 52.0, height: 52.0, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('รูปที่ ${i + 1}',
                                    style: _t(14.0,
                                        color: _inkTitle,
                                        weight: FontWeight.w600)),
                                Text(
                                    switch (_peAttachMeta[b]) {
                                      (final t, final who) => [
                                          _peStamp(t),
                                          if (who.isNotEmpty) who,
                                        ].join('  '),
                                      null => '${(b.length / 1024).round()} KB',
                                    },
                                    style: _t(12.0,
                                        color: _ink3, weight: FontWeight.w500)),
                              ]),
                        ),
                        // ลบได้เฉพาะรูปของตัวเอง (รูปเก่าไม่มีข้อมูลผู้แนบ = ลบได้)
                        if (!widget.readOnly &&
                            (_peAttachMeta[b] == null ||
                                _peAttachMeta[b]!.$2 == _me))
                          IconButton(
                            tooltip: 'ลบรูป',
                            onPressed: () => _askRemovePhoto(r, i, b),
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20.0, color: _ink2),
                          ),
                      ]),
                    ),
                  ),
              ]),
          ]),
        ),
        // อวัยวะภายใน: ผล X-ray/Lab ของเคสที่เกี่ยวกับอวัยวะนี้
        if (r.startsWith('organ:')) ...[
          const SizedBox(height: 16.0),
          _organResults(r.substring(6)),
        ],
      ],
    );
  }

  /// การ์ด X-ray / Lab ของอวัยวะ: ภาพถ่ายรังสีก่อน แล้วผล Lab (ผิดปกติ = แดง)
  Widget _organResults(String organ) {
    final (imgKeys, labKeys) =
        _peOrganResultKeys[organ] ?? (const <String>[], const <String>[]);
    // ชื่อสั้น (≤ 2 ตัว เช่น K Na Cr) ต้องตรงทั้งคำ ไม่จับ Ketone
    bool hit(String name, List<String> keys) => keys.any((k) {
          final n = name.toLowerCase(), q = k.toLowerCase();
          return n == q ||
              n.startsWith('$q ') ||
              (q.length > 2 && n.startsWith(q));
        });
    final imgs = [
      for (final x in widget.imaging)
        if (hit(x.name, imgKeys)) x
    ];
    final labs = [
      for (final l in widget.labs)
        if (hit(l.name, labKeys)) l
    ];
    final n = imgs.length + labs.length;
    Widget row(int i, Widget lead, String name, String value, bool abn,
            [String sub = '']) =>
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            border: i == 0
                ? null
                : const Border(
                    top: BorderSide(color: Color(0xFFE8EAED), width: 0.5)),
          ),
          child: Row(children: [
            lead,
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: _t(14.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                    if (sub.isNotEmpty)
                      Text(sub,
                          style:
                              _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
            ),
            const SizedBox(width: 8.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150.0),
              child: Text(value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.5,
                      color: abn ? _red : _ink2,
                      weight: abn ? FontWeight.w700 : FontWeight.w500)),
            ),
          ]),
        );
    String num(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toString();
    return widget.card(
      'X-ray / Lab',
      n == 0
          ? 'ยังไม่มีผลที่เกี่ยวกับ${_name('organ:$organ')}'
          : 'ผลที่เกี่ยวกับ${_name('organ:$organ')} $n รายการ',
      const SizedBox.shrink(),
      n == 0
          ? const SizedBox(height: 4.0)
          : Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
              ),
              child: Column(children: [
                for (final (i, x) in imgs.indexed)
                  row(
                      i,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(x.asset,
                            width: 44.0,
                            height: 44.0,
                            fit: BoxFit.cover,
                            cacheWidth: 120,
                            errorBuilder: (_, __, ___) => Container(
                                width: 44.0, height: 44.0, color: _panelSoft)),
                      ),
                      x.name,
                      x.result,
                      x.result.isNotEmpty &&
                          !x.result.toLowerCase().contains('normal') &&
                          !x.result.contains('ปกติ')),
                for (final (i, l) in labs.indexed)
                  row(
                      imgs.length + i,
                      Container(
                        width: 44.0,
                        height: 44.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _panelSoft,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.science_outlined,
                            size: 20.0, color: _blue),
                      ),
                      l.name,
                      l.resultText,
                      l.abnormal,
                      l.isNumeric ? 'ปกติ ${num(l.lo)}–${num(l.hi)}' : ''),
              ]),
            ),
    );
  }

  /// ค่าฉาก 3D (ตัวเดียวกับหน้าผู้ป่วย) ขณะเปิด studio
  _PeSceneCfg _cfg() => _PeSceneCfg(
        regionSel: _organ ? null : _region,
        // focus บริเวณ = ซ่อน plot อื่น (อาการของเคส + หมุดบริเวณอื่น)
        highlight: [
          if (_caseOn && _region == null)
            for (final c in widget.caseMarks) c.$1,
          if (_organ) _region!.substring(6),
        ],
        drawings: [
          for (final s in _strokes)
            if ((s['pts'] as List).isNotEmpty &&
                (_region == null || s['region'] == _region))
              {'id': s['id'], 'color': s['color'], 'r': s['r'], 'pts': s['pts']}
        ],
        draw: widget.readOnly
            ? null
            : {
                'tool': _tool,
                // วาด = รูปทรง (วง/กล่อง) ลากจากจุดแตะ ไม่ใช่เส้นอิสระ
                // ระบาย: ขนาดพู่กัน (รัศมี ซม.)
                if (_tool == 'pen') 'brush': _brush,
                'color': _tool == 'pin' ? '#d93025' : _hex(_color),
                'r': _tool == 'pin' ? 0.003 : 0.004,
              },
        onStroke: (s) {
          if (!mounted) return;
          final m = Map<String, Object?>.from(s)..remove('type');
          debugPrint(
              'DBG stroke ${m['id']} region=${m['region']} shape=${m['shape']}');
          // รูปทรงที่ปรับขนาด = id เดิม แทนที่ของเดิม
          final at = _strokes.indexWhere((x) => x['id'] == m['id']);
          if (at >= 0) {
            setState(() => _strokes[at] = m);
            return;
          }
          setState(() => _strokes.add(m));
          final r = m['region'] as String?;
          // ระบาย = เลือกบริเวณที่เริ่มระบาย (ไม่ย้ายกล้องกลางการระบาย)
          if (r != null && m['paint'] == true) {
            if (_region == null) setState(() => _region = r);
            return;
          }
          // ปักหมุด = เลือกบริเวณนั้น + ซูมไปที่จุด
          if (r != null && (m['pts'] as List).length == 1) {
            _focusRegion(r, [
              for (final v in (m['pts'] as List).first as List)
                (v as num).toDouble()
            ]);
          }
        },
        onErase: (id) {
          if (!mounted) return;
          // หมุดของคนอื่นลบไม่ได้: คงไว้ (ฉากวาดกลับจาก drawings)
          setState(() =>
              _strokes.removeWhere((s) => s['id'] == id && s['ro'] != true));
        },
        onHotspots: (list) {
          if (!mounted) return;
          final caseCodes = {for (final c in widget.caseMarks) c.$1};
          final pins = [
            for (final p in list)
              if (p.code.startsWith('pin:') || caseCodes.contains(p.code)) p
          ];
          if (!_samePins(pins)) setState(() => _pinPos = pins);
        },
      );

  @override
  void initState() {
    super.initState();
    // เปิดภาพเดิม: โหลดหมุด รายละเอียด รูป ของภาพนั้น
    final x = widget.initial;
    if (x != null) {
      _strokes.addAll([for (final m in x.d3) Map<String, Object?>.of(m)]);
      for (final e in x.noteLogBy.entries) {
        _noteLog[e.key] = [...e.value];
      }
      // ภาพรุ่นก่อนมีรายการแยกเวลา: ข้อความเดิมเป็นรายการเดียว (เวลาของภาพ)
      for (final e in x.notesBy.entries) {
        if (!_noteLog.containsKey(e.key) && e.value.trim().isNotEmpty) {
          _noteLog[e.key] = [(e.value.trim(), x.at, x.by)];
        }
      }
      for (final e in x.attachBy.entries) {
        _photos[e.key] = [...e.value];
      }
      // ภาพที่บันทึกก่อนมีข้อมูลแยกบริเวณ: เทียบจากข้อความ "บริเวณ: ..." · รูปไว้บริเวณแรก
      final regs = {
        for (final m in _strokes)
          if (m['region'] != null) '${m['region']}'
      };
      if (x.notesBy.isEmpty) {
        for (final r in regs) {
          for (final n in x.said) {
            if (n.startsWith('${_name(r)}:')) {
              _noteLog[r] = [
                (n.substring(_name(r).length + 1).trim(), x.at, x.by)
              ];
            }
          }
        }
      }
      if (x.attachBy.isEmpty && x.attach.isNotEmpty && regs.isNotEmpty) {
        _photos[regs.first] = [...x.attach];
      }
    }
    // ภาพของคนอื่น: หมุด รายละเอียด รูป รวมในหุ่น/รายการเดียวกัน (ro = ไม่บันทึกซ้ำ ลบไม่ได้)
    for (final o in widget.others) {
      _strokes.addAll([
        for (final m in o.d3) {...m, 'ro': true, 'by': o.by}
      ]);
      final log = o.noteLogBy.isNotEmpty
          ? o.noteLogBy
          : {
              for (final e in o.notesBy.entries)
                if (e.value.trim().isNotEmpty)
                  e.key: [(e.value.trim(), o.at, o.by)]
            };
      for (final e in log.entries) {
        (_noteLog[e.key] ??= []).addAll(e.value);
      }
      for (final e in o.attachBy.entries) {
        for (final b in e.value) {
          _peAttachMeta[b] ??= (o.at, o.by);
        }
        (_photos[e.key] ??= []).addAll(e.value);
      }
    }
    for (final l in _noteLog.values) {
      l.sort((a, b) => _peStampKey(a.$2).compareTo(_peStampKey(b.$2)));
    }
    _markSaved();
    if (widget.ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _peScene.value = _cfg();
        // ฉากยังอยู่มุมห้อง (เพิ่งโหลด) = ไปที่ตัวหุ่นทันที ไม่บินจากห้อง
        _ctl.instant();
        _ctl.focus(_peWhole);
      });
    }
  }

  @override
  void didUpdateWidget(covariant _PeStudio old) {
    super.didUpdateWidget(old);
    // เลื่อนเข้าเสร็จ: ฉาก (ตัวเดิม) เปลี่ยนเป็นหุ่นลายเส้น + ภาพรวมทั้งตัว
    if (widget.ready && !old.ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _peScene.value = _cfg();
        _ctl.focus(_peWhole);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.ready) _peScene.value = _cfg();
      });
    }
    return _studioBody();
  }

  Widget _studioBody() => Material(
        type: MaterialType.transparency,
        // ไม่เว้น safe area ล่าง: แผงขวาลงถึงขอบล่างจอ (ปุ่มลอยมีระยะล่างของตัวเองแล้ว)
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            _StudioSlide(from: const Offset(0.0, -1.2), child: _topBar()),
            Expanded(
              child: Row(children: [
                Expanded(
                  child: KeyedSubtree(
                      key: _canvasKey,
                      child: Stack(children: [
                        // ป้ายสิ่งที่พบของแต่ละหมุด (แบบป้าย CC บนหุ่นหน้าผู้ป่วย)
                        // ระหว่างเลื่อนฉากซ่อน (พิกัดป้ายเป็นของฉากที่วางเสร็จแล้ว)
                        if (_StudioT.of(context) > 0.98)
                          Positioned.fill(
                            child: LayoutBuilder(
                                builder: (context, box) => Stack(
                                    clipBehavior: Clip.none,
                                    children: _labels(box.biggest))),
                          ),
                        // ลอยซ้ายบนหุ่น: มุมมอง (ทั้งตัว · เฉพาะส่วน) + อวัยวะภายใน
                        if (_StudioT.of(context) > 0.98) ...[
                          // ซ้ายบน: มุมมอง
                          Positioned(left: 16.0, top: 16.0, child: _viewBar()),
                          // ซ้ายล่าง: รีเซ็ตตำแหน่งหุ่น (กลับทั้งตัว หันหน้าตรง)
                          Positioned(
                              left: 16.0,
                              bottom:
                                  16.0 + MediaQuery.paddingOf(context).bottom,
                              child: _floatPanel(_floatItem(
                                  Icons.restart_alt_rounded,
                                  'รีเซ็ตตำแหน่ง',
                                  false,
                                  () => _turnTo(0)))),
                          // ขวาบน: แสดง/ซ่อน CC/Dx
                          if (widget.caseMarks.isNotEmpty)
                            Positioned(
                                right: 16.0, top: 16.0, child: _caseToggle()),
                          // ขวากลาง: เครื่องมือวาดบนหุ่น (ปักหมุด · วาด · ลบเส้น · สี)
                          Positioned(
                            right: 16.0,
                            top: 72.0,
                            bottom: 120.0,
                            child: Center(
                                child: widget.readOnly
                                    ? const SizedBox.shrink()
                                    : _drawTools()),
                          ),
                          // ซ้ายกลาง: อวัยวะภายใน
                          Positioned(
                            left: 16.0,
                            top: 72.0,
                            bottom: 120.0,
                            child: Center(child: _organList()),
                          ),
                        ],
                        Positioned(
                          top: 16.0,
                          left: 0.0,
                          right: 0.0,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _region == null
                                  ? const SizedBox.shrink()
                                  : KeyedSubtree(
                                      key: ValueKey(_region),
                                      child: _regionChip()),
                            ),
                          ),
                        ),
                        // ยังไม่มีหมุด: คำแนะนำบนหุ่น (มือแตะ + วงกระเพื่อม) บอกวิธีปักหมุด
                        if (_tool != 'pen' &&
                            _region == null &&
                            _used.isEmpty &&
                            !widget.readOnly &&
                            _StudioT.of(context) > 0.98)
                          // ภาพนำบนตัวหุ่น: มือเลื่อนลงไปแตะหน้าอก วงกระเพื่อม + หมุดปักลง
                          Positioned.fill(
                            child: IgnorePointer(
                              child: _TapCoach(key: ValueKey(_coachTick)),
                            ),
                          ),
                        if (_region == null)
                          Positioned(
                            bottom: 20.0,
                            left: 0.0,
                            right: 0.0,
                            // ลูกศรวงรีรอบเท้าหุ่น (ซ่อนตอน focus บริเวณ): บอกว่าลากหมุนได้รอบตัว
                            child: IgnorePointer(
                              child: Center(
                                child: SizedBox(
                                  width: 340.0,
                                  height: 44.0,
                                  child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        const Positioned.fill(
                                            child: CustomPaint(
                                                painter: _OrbitHint())),
                                        // ป้ายกลางด้านหน้าวง
                                        Container(
                                          height: 28.0,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          decoration: BoxDecoration(
                                            color: _panel,
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            border: Border.all(
                                                color: const Color(0xFFDADCE0),
                                                width: 0.5),
                                          ),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                    Icons.threesixty_rounded,
                                                    size: 16.0,
                                                    color: _blue),
                                                const SizedBox(width: 6.0),
                                                Text('ลากเพื่อหมุน',
                                                    style: _t(12.0,
                                                        color: _ink2,
                                                        weight:
                                                            FontWeight.w600)),
                                              ]),
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                          ),
                      ])),
                ),
                _StudioSlide(
                    from: const Offset(1.0, 0.0),
                    child: Container(
                      width: 380.0,
                      decoration: const BoxDecoration(
                        color: _panel,
                        border: Border(
                            left: BorderSide(
                                color: Color(0xFFDADCE0), width: 0.5)),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        transitionBuilder: (c, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                              position: Tween(
                                      begin: const Offset(0.05, 0.0),
                                      end: Offset.zero)
                                  .animate(a),
                              child: c),
                        ),
                        child: _region == null
                            ? KeyedSubtree(
                                key: const ValueKey('overview'),
                                child: _overviewPanel())
                            : KeyedSubtree(
                                key: ValueKey('region-$_region'),
                                child: _regionPanel()),
                        // footer: ยังไม่มีหมุด = เริ่มปักหมุด · ดูบริเวณอยู่ = บันทึก
                      ).withSaveFooter(widget.readOnly ||
                              (_used.isNotEmpty && _region == null)
                          ? const SizedBox.shrink()
                          : _saveFooter()),
                    )),
              ]),
            ),
          ]),
        ),
      );
}

/// ขั้นตอนของเมนูวาดภาพ (หน้าแนะนำ แบบ _stepHowTo)
const List<(IconData, String, String)> _peDrawHowTo = [
  (
    Icons.touch_app_outlined,
    'ปักตำแหน่งบนหุ่น 3D',
    'แตะจุดที่ผิดปกติ ระบบปักหมุดและซูมไปที่บริเวณนั้น'
  ),
  (
    Icons.fact_check_outlined,
    'ลงรายละเอียด',
    'พิมพ์สิ่งที่พบของแต่ละบริเวณ เช่น ขนาดแผล ความลึก ลักษณะขอบแผล'
  ),
  (
    Icons.add_photo_alternate_outlined,
    'แนบรูปและวาดเพิ่ม',
    'ถ่ายภาพแผล วาดขอบบนหุ่น บันทึกขนาดและลักษณะ'
  ),
  (
    Icons.monitor_heart_outlined,
    'อวัยวะภายในและเทมเพลต',
    'ระบุความผิดปกติของอวัยวะ หรือวาดบนภาพฟัน ตา ฝีเย็บ'
  ),
];

/// พยาบาล: ดูภาพที่แพทย์บันทึก (ไม่วาดเอง)
const List<(IconData, String, String)> _peViewHowTo = [
  (
    Icons.location_on_outlined,
    'ดูตำแหน่งบนหุ่น 3D',
    'หมุดที่แพทย์ปักไว้ แตะเพื่อซูมไปที่บริเวณนั้น'
  ),
  (
    Icons.fact_check_outlined,
    'อ่านรายละเอียด',
    'สิ่งที่แพทย์พบในแต่ละบริเวณ พร้อมเวลาและผู้บันทึก'
  ),
  (
    Icons.photo_library_outlined,
    'ดูรูปประกอบ',
    'รูปแผลที่แนบไว้ ใช้ประกอบการทำแผลและเฝ้าระวัง'
  ),
];

List<(IconData, String, String)> get _peHowTo =>
    ErSession.instance.isNurse ? _peViewHowTo : _peDrawHowTo;

extension _FeaturesWorkflowPeDrawIntroPart on _ErFlowHomeWidgetState {
  /// หน้าแนะนำเมนูวาดภาพ: hero ป้ายบอกทาง + ขั้นตอน + ภาพที่บันทึกแล้ว + ปุ่มเริ่ม
  Widget _drawIntroPane() {
    final shots = _peShotList;
    final base = _t(16.0, color: Colors.white, weight: FontWeight.w700);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
          children: [
            Container(
              height: 104.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(14.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -4.0,
                      bottom: -30.0,
                      child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (r) => const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.transparent],
                          stops: [0.0, 0.73],
                        ).createShader(r),
                        child: Icon(Icons.draw_rounded,
                            size: 112.0, color: _blue.withValues(alpha: 0.1)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 300.0,
                        height: 92.0,
                        child: ClipRect(
                          child: _WaySign(
                            key: const ValueKey('sign-draw'),
                            names: const ['วาดภาพ'],
                            icons: const [Icons.draw_outlined],
                            done: [shots.isNotEmpty],
                            at: 0,
                            busy: false,
                            rowH: 50.0,
                            cable: 30.0,
                            tilt: 0.75,
                            depth: 0.0022,
                            style: base,
                            numStyle: _num(9.5, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(height: 12.0),
            _Appear(
              index: 0,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text('เกี่ยวกับแบบฟอร์มนี้',
                          style: _t(16.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ),
                    for (final (i, (_, title, desc)) in _peHowTo.indexed)
                      IntrinsicHeight(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 32.0,
                                child: Column(children: [
                                  Container(
                                    width: 32.0,
                                    height: 32.0,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F0FE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text('${i + 1}',
                                        style: _num(14.0, color: _blue)),
                                  ),
                                  if (i < _peHowTo.length - 1)
                                    Expanded(
                                      child: Container(
                                          width: 2.0,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          color: const Color(0xFFE8EAED)),
                                    ),
                                ]),
                              ),
                              const SizedBox(width: 14.0),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 5.0,
                                      bottom:
                                          i < _peHowTo.length - 1 ? 18.0 : 0.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
                                          style: _t(15.0,
                                              color: _inkTitle,
                                              weight: FontWeight.w600)),
                                      const SizedBox(height: 3.0),
                                      Text(desc,
                                          style: _t(13.0,
                                              color: _ink3,
                                              weight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                      ),
                  ]),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 14.0),
        // มีภาพ 3D ของตัวเองแล้ว = เปิดภาพล่าสุดกลับเข้าไป (เพิ่มรูป/รายละเอียดในตำแหน่งเดิม
        // หรือปักจุดใหม่ก็ได้ บันทึกแทนภาพเดิม) · ยังไม่มี = เริ่มใหม่
        child: Builder(builder: (context) {
          final me = ErSession.instance.user?.name ?? '';
          final mine = shots.lastWhere((x) => x.d3.isNotEmpty && x.by == me,
              orElse: () => _PeShot(name: ''));
          final has = mine.name.isNotEmpty;
          // พยาบาล: ดูภาพที่แพทย์วาดได้อย่างเดียว (ไม่วาดเอง)
          if (ErSession.instance.isNurse) {
            final any = shots.any((x) => x.d3.isNotEmpty);
            return _navBtn('ดูภาพตรวจร่างกาย', Icons.visibility_outlined,
                any ? () => _peOpenStudio() : null);
          }
          return _navBtn(has ? 'เปิดภาพตรวจร่างกาย' : 'เริ่มวาดภาพ',
              Icons.draw_outlined, () => _peOpenStudio(has ? mine : null));
        }),
      ),
    ]);
  }
}

/// ลูกศรวงรีรอบหุ่น (แนวพื้น) แบบมีมิติ: แถบริบบอนหนาด้านหน้า บางด้านหลัง (perspective)
/// ไล่แสงบน-ล่าง มีขอบหนา (ด้านข้าง) + เงาตกบนพื้น · หัวลูกศรสามมิติสองข้าง = ลากหมุนได้
class _OrbitHint extends CustomPainter {
  const _OrbitHint();

  @override
  void paint(Canvas canvas, Size size) {
    // ครึ่งหน้าของวงรีบนพื้นรอบเท้าหุ่น แบบเรียบ: หนาและเข้มขึ้นตามความใกล้
    // เว้นกลางให้ป้าย "ลากเพื่อหมุน" · หัวลูกศรสองข้างบอกหมุนได้ทั้งสองทาง
    final c = Offset(size.width / 2, 6.0);
    final a = size.width / 2 - 12.0, b = size.height - 14.0;
    Offset at(double t) =>
        Offset(c.dx + a * math.cos(t), c.dy + b * math.sin(t));
    double near(double t) => (math.sin(t) + 1.0) / 2.0; // 0 หลัง → 1 หน้า

    void arc(double t0, double t1) {
      const n = 40;
      for (var i = 0; i < n; i++) {
        final ta = t0 + (t1 - t0) * i / n, tb = t0 + (t1 - t0) * (i + 1) / n;
        final k = near((ta + tb) / 2);
        canvas.drawLine(
            at(ta),
            at(tb),
            Paint()
              ..color = _blue.withValues(alpha: 0.18 + 0.62 * k)
              ..strokeWidth = 1.5 + 2.5 * k
              ..strokeCap = StrokeCap.round);
      }
    }

    void head(double t, double dir) {
      final p = at(t);
      final tan = Offset(-a * math.sin(t), b * math.cos(t)) * dir;
      final u = tan / tan.distance;
      final nrm = Offset(-u.dy, u.dx);
      final k = near(t);
      final s = 6.0 + 2.0 * k;
      final tip = p + u * (s * 1.3);
      canvas.drawPath(
          Path()
            ..moveTo(p.dx + nrm.dx * s, p.dy + nrm.dy * s)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(p.dx - nrm.dx * s, p.dy - nrm.dy * s),
          Paint()
            ..color = _blue.withValues(alpha: 0.55 + 0.35 * k)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 + 1.5 * k
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }

    // เฉพาะครึ่งหน้า (ครึ่งหลังจะทับขาหุ่น) · เว้นกลางให้ป้าย
    const gap0 = 0.30, gap1 = 0.70, end0 = 0.02, end1 = 0.98;
    arc(math.pi * end0, math.pi * gap0);
    arc(math.pi * gap1, math.pi * end1);
    // หัวลูกศรที่ปลายนอก ชี้วนไปทางหลังหุ่น (หมุนได้ทั้งสองทาง)
    head(math.pi * end0, -1.0);
    head(math.pi * end1, 1.0);
  }

  @override
  bool shouldRepaint(_OrbitHint o) => false;
}

/// แถบบนเลื่อนลง + แผงขวาเลื่อนเข้าจากขวา ตามค่า t (ไม่ใช้ Opacity: ไม่ทับ WebView ด้วย saveLayer)
class _StudioChromeSlide extends StatelessWidget {
  const _StudioChromeSlide({required this.t, required this.child});
  final double t;
  final Widget child;

  @override
  Widget build(BuildContext context) => _StudioT(t: t, child: child);
}

/// ส่งค่า t ลงไปให้แถบบน/แผงขวาใน studio
class _StudioT extends InheritedWidget {
  const _StudioT({required this.t, required super.child});
  final double t;
  static double of(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<_StudioT>()?.t ?? 1.0;
  @override
  bool updateShouldNotify(_StudioT o) => o.t != t;
}

/// เลื่อนเข้าตาม t ของ studio (แถบบนจากบน · แผงขวาจากขวา)
class _StudioSlide extends StatelessWidget {
  const _StudioSlide({required this.from, required this.child});
  final Offset from;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final t = _StudioT.of(context);
    return FractionalTranslation(
        translation: Offset.lerp(from, Offset.zero, t)!, child: child);
  }
}

/// ไอคอนอวัยวะ (Figma 496:203) path ขนาด 24
const Map<String, List<(String, bool, bool)>> _peOrganIcons = {
  'brain': [
    (
      'M9.04 1.5C9.25 1.47 9.45 1.46 9.66 1.46C10.65 1.48 11.37 1.91 12.02 2.6C12.17 2.45 12.32 2.29 12.48 2.16C13.15 1.6 14.03 1.36 14.89 1.49C16.09 1.65 16.8 2.3 17.49 3.21C19.97 3.76 21.38 5.08 21.12 7.76C22.09 8.49 22.77 9.27 22.95 10.54C23.17 12.14 22.7 12.94 21.81 14.15C22.4 16.67 21.44 18.73 18.77 19.27C18.26 21.33 17.03 22.39 14.89 22.54C13.64 22.52 12.76 22.16 12.04 21.12C11.5 21.76 10.93 22.21 10.09 22.43C9.05 22.69 7.94 22.52 7.02 21.95C6 21.3 5.53 20.42 5.29 19.28C5.06 19.24 4.84 19.19 4.62 19.12C3.69 18.85 2.9 18.2 2.46 17.34C1.93 16.33 1.9 15.21 2.24 14.13C2.13 14 2.02 13.87 1.91 13.73C0.32 11.67 0.92 9.25 2.9 7.74C2.78 4.98 3.92 3.79 6.56 3.21L6.6 3.16C7.25 2.13 7.88 1.76 9.04 1.5ZM6.26 4.31C5.2 4.62 4.88 4.86 4.24 5.75C3.76 6.42 4.15 8.07 4 8.21C2.59 9.55 1.7 9.88 2.22 12.2C2.49 13.43 3.86 13.48 4.11 13.86C4.01 14.72 3.21 14.18 3.11 14.95C2.88 16.71 3.77 17.86 5.46 18.27C5.81 17.71 5.96 17.26 6.69 17.28C6.91 17.51 6.87 17.41 6.94 17.69C6.76 18.55 5.93 19.06 6.67 20.15C7.56 21.48 9.28 21.9 10.65 21.03C11.8 20.29 11.52 18.32 11.52 17.07L11.52 12.89L11.52 7.35C11.52 6.34 11.52 5.34 11.49 4.33C11.45 2.99 10.45 2.39 9.17 2.52C7.16 3.1 7.63 4.53 6.85 4.81C6.54 4.74 6.44 4.57 6.26 4.31ZM17.79 18.99C17.52 18.53 17.1 18.05 17.16 17.58C17.3 17.38 17.29 17.39 17.51 17.29C17.78 17.29 17.87 17.37 18.08 17.54C18.29 17.79 18.46 18 18.65 18.27C20.48 17.66 21.22 16.52 20.86 14.58C20.41 14.51 20.2 14.52 19.92 14.15C19.86 13.54 20.51 13.48 20.96 13.39C21.61 12.76 21.96 12.13 21.95 11.19C21.95 10.36 21.61 9.58 21.01 9.01C20.71 8.72 19.87 8.5 19.94 8.16C20.27 6.45 19.96 4.88 17.75 4.36C16.16 6.01 17.2 2.08 13.99 2.53C13.47 2.71 13 2.94 12.73 3.46C12.59 3.75 12.56 4.05 12.55 4.37C12.48 5.82 12.44 19.64 12.67 20.21C12.9 20.76 13.47 21.16 14.02 21.35C14.75 21.61 15.41 21.53 16.09 21.18C16.96 20.73 17.43 20.11 17.73 19.18C17.75 19.12 17.77 19.05 17.79 18.99Z',
      true,
      false
    ),
    (
      'M8.91 6.94C9.19 7 9.36 7.03 9.5 7.32C9.38 7.94 8.56 8.05 8.36 8.4C7.43 10.1 7.67 10.26 5.71 10.85C5.44 10.81 5.31 10.71 5.15 10.51C5.06 9.81 6.15 9.81 6.44 9.48C7.51 8.29 7.12 7.56 8.91 6.94Z',
      true,
      false
    ),
    (
      'M8.84 13.25C9.14 13.27 9.2 13.22 9.41 13.37C9.5 13.72 9.38 13.73 9.34 14.04C9.28 14.51 9.47 15 9.15 15.43L9.01 15.44C8.64 15.24 8.48 14.88 8.27 14.52C7.7 14.71 7.37 14.95 6.91 14.45C6.72 13.76 8.2 13.65 8.76 13.3L8.84 13.25Z',
      true,
      false
    ),
    (
      'M14.9 6.98C16.34 7.13 16.8 8.11 17.3 9.28C17.8 9.65 18.71 9.83 18.87 10.36C18.82 10.61 18.72 10.66 18.53 10.83C18.2 10.77 16.57 10.52 16.41 10.44C16.29 10.23 16.08 9.26 16.04 8.98C15.89 7.99 14.79 8.18 14.61 7.5C14.68 7.22 14.71 7.21 14.9 6.98Z',
      true,
      false
    ),
    (
      'M14.78 13.23C15.35 13.24 16.84 13.69 17.04 14.27C17 14.55 16.99 14.53 16.82 14.76C16.46 14.78 15.79 14.59 15.44 14.47C14.75 14.23 14.37 13.93 14.78 13.23Z',
      true,
      false
    )
  ],
  'heart': [
    (
      'M11.68 1C12.08 1.03 13.23 1.28 13.55 1.5C13.64 1.67 13.61 1.79 13.61 1.99L13.6 2.07L13.66 2.12C14.15 1.29 14.2 1.68 14.99 1.81C16.53 2.07 15.67 3.26 15.46 4.31C15.69 4.66 15.81 4.84 15.99 5.2C16.66 5.07 17.36 4.93 18.04 4.84C18.19 4.82 18.3 4.89 18.41 4.98C18.61 5.47 18.89 6.9 18.9 7.41C18.63 7.94 17.68 7.86 17.38 8.11C17.79 8.29 18.48 7.93 18.85 8.06C19.44 8.28 19.62 9.83 19.48 10.33C19.21 10.64 18.71 10.66 18.29 10.74C19.47 13.38 19.2 16.55 18.33 19.24C17.5 21.85 16.16 23.71 13.14 22.74C10.46 21.72 7.65 19.15 6.05 16.77C4.45 14.4 3.89 11.26 5.22 8.64C5.62 7.85 6.23 7.41 6.33 6.51C6.45 5.74 6.35 4.99 6.28 4.22C6.23 3.62 5.65 2.42 6.46 2.13C7.06 1.92 8.57 1.45 9.16 1.64C9.39 1.87 9.71 4.25 9.78 4.68C10.1 4.38 10.33 4.17 10.6 3.82C11.22 3.01 11.03 1.69 11.68 1ZM8.54 2.47C8.08 2.58 7.43 2.76 6.98 2.83C7.18 3.97 7.42 5.97 7.17 7.08C6.99 7.91 5.99 8.78 5.67 9.85C4.34 14.38 7.79 18.2 11.19 20.66C12.09 21.31 13.77 22.28 14.93 22.1C15.66 21.99 16.24 21.48 16.63 20.86C17.63 19.29 18.31 16.12 18.15 14.28C17.99 11.93 17.46 10.3 15.73 8.65C14.86 9.37 14.18 10.34 14.92 11.38C15.38 12.04 16.68 12.13 16.7 12.8C16.27 13.56 15.53 12.75 14.92 12.69C14.64 12.66 14.29 12.78 14.08 12.65C14.06 12.41 14.09 12.13 14.06 11.92C14.03 11.65 13.88 11.35 13.82 11.06C13.65 10.19 13.89 9.29 14.47 8.61C15.33 7.61 16.8 7.31 18.03 7.01C17.89 6.53 17.82 6.19 17.73 5.7C15.05 6.53 12.35 6.02 11.49 9.4C11.41 9.75 11.21 10.44 10.94 10.66C10.75 10.69 10.75 10.7 10.58 10.62C10.43 10.44 10.4 10.25 10.44 10.01C10.98 6.92 12.3 6.06 15.14 5.33C14.2 4.29 14.67 3.98 15 2.73C14.7 2.62 14.72 2.58 14.45 2.63C13.88 3.08 13.87 4.82 12.77 4C12.51 3.61 12.78 2.55 12.83 2.06C12.61 2 12.37 1.95 12.14 1.88C11.98 2.6 11.84 3.48 11.52 4.14C11.3 4.53 10.89 4.82 10.56 5.12C9.87 5.75 9.53 6.56 9.3 7.46C9.18 7.97 9.21 9.33 8.91 9.68C8.71 9.74 8.7 9.76 8.49 9.7C7.92 9.25 8.46 7.21 8.66 6.58C8.74 6.3 8.88 5.91 8.94 5.62C8.92 4.65 8.67 3.45 8.54 2.47ZM18.17 8.96C17.91 8.98 17.64 9.01 17.38 9.03C17.55 9.31 17.78 9.71 17.96 9.96L18.65 9.83C18.62 9.54 18.63 9.19 18.48 8.97C18.34 8.91 18.33 8.93 18.17 8.96Z',
      true,
      false
    ),
    (
      'M10.87 12.5C11.13 12.52 11.46 12.75 11.45 13.04C11.38 14.19 10.36 14.82 9.75 15.63C9.46 16.02 9.39 16.79 9.04 17.24C7.85 17.08 8.76 15.73 9.08 15.13C9.34 14.62 9.94 14.19 10.24 13.71C10.49 13.31 10.51 12.87 10.87 12.5Z',
      true,
      false
    )
  ],
  'lungs': [
    (
      'M13.38 11.34C13.17 11.12 12.86 10.86 12.72 10.59C12.6 10.34 12.59 10.02 12.57 9.75C12.52 8.83 12.49 2.11 12.64 1.76C12.69 1.65 12.77 1.62 12.88 1.58C13.05 1.52 13.23 1.54 13.39 1.61C13.68 2.23 13.53 7.5 13.52 8.58C14.07 7.01 14.84 5.85 16.75 6.39C18.43 6.86 19.7 8.5 20.56 9.93C22.17 12.61 23.05 15.86 23 18.98C22.98 20.16 22.84 21.85 21.56 22.35C20.38 22.8 19.07 22.06 18 21.56C16.77 20.92 15.19 20.6 14.11 19.55C12.82 18.29 13.28 15.68 13.27 13.93C12.83 13.61 12.41 13.25 11.99 12.91C11.58 13.29 11.23 13.56 10.79 13.91C10.68 15.38 11.1 17.21 10.5 18.57C9.78 20.38 7.87 20.61 6.44 21.36C3.23 23.03 0.97 23.3 1 18.69C1.02 16.01 1.67 13.38 2.88 11C3.81 9.13 6.29 5.25 9.15 6.53C9.89 6.87 10.22 7.83 10.46 8.58C10.63 6.44 10.34 4.12 10.52 1.97C10.54 1.78 10.64 1.65 10.76 1.51C11.01 1.54 11.08 1.56 11.33 1.63C11.44 1.88 11.46 2.24 11.46 2.52C11.46 5.07 11.52 7.64 11.43 10.19C11.42 10.52 10.93 11.14 10.73 11.41C10.72 11.92 10.71 12.27 10.64 12.77C11.07 12.39 11.47 11.98 11.99 11.76C12.55 12.02 12.84 12.27 13.32 12.65C13.32 12.24 13.36 11.76 13.38 11.34ZM4.01 21.34C5.1 20.88 8.01 19.75 8.79 19.14C9.16 18.85 9.45 18.46 9.62 18.02C9.72 17.75 9.79 17.47 9.8 17.17C9.88 16.01 9.75 14.65 9.74 13.47C9.72 12.16 9.74 10.72 9.57 9.42C9.43 8.32 9.1 7.12 7.74 7.29C3.77 8.41 1.27 16.82 2.18 20.55C2.42 21.53 3.09 21.65 3.94 21.36L4.01 21.34ZM20.67 21.54C24.17 21.32 20.42 6.86 15.66 7.29C15.29 7.45 14.82 7.78 14.72 8.22C14.06 11.18 14.36 14.06 14.21 17.14C14.08 19.73 18.4 20.39 20.14 21.4C20.2 21.44 20.58 21.52 20.67 21.54Z',
      true,
      false
    )
  ],
  'liver': [
    (
      'M7.98 3.57C10.87 3.34 12.8 4.09 15.56 4.3C17.38 4.44 19.66 4.2 21.52 4.36C21.93 4.4 22.28 4.57 22.63 4.77C24.18 6.94 20.4 9.16 19.31 10.6C17.9 12.46 16.22 13.74 13.79 13.59C13.29 14.9 13.02 15.28 11.94 16.16C10.08 17.25 9.18 16.96 7.32 17.78C5.89 18.4 4.77 20.28 3.18 20.46C0.93 20.7 0.95 18.13 1.02 16.62C1.2 13.05 0.34 8.99 2.84 6.03C4.16 4.48 5.99 3.75 7.98 3.57ZM13 11.11C12.98 10.31 12.88 8.1 13.38 7.47C13.68 7.32 13.93 7.36 14.1 7.66C14.08 8.17 14.04 8.69 14 9.2C13.91 10.32 14.02 11.48 13.98 12.6C16.76 12.5 17.49 11.08 19.14 9.22C19.57 8.74 23.12 5.98 21.76 5.48C20.9 5.16 16.59 5.38 15.47 5.29C13.04 5.12 10.44 4.28 8.11 4.55C2.02 5.3 1.83 9.98 2.02 15.05C2.05 15.9 1.55 19.92 3.14 19.49C4.15 19.21 5.37 17.65 6.36 17.13C10 15.44 13.05 16.46 13 11.11Z',
      true,
      false
    )
  ],
  'stomach': [
    (
      'M12.32 1.05C12.54 1.06 12.62 1.04 12.79 1.19C13.25 1.97 12.53 4.55 13.94 4.65C14.11 4.66 14.77 4.38 14.97 4.31C19.49 2.79 22.43 7.06 22.62 11.14C22.77 14.21 21.68 17.2 19.61 19.46C17.86 21.35 15.38 22.65 12.91 22.71C10.19 22.77 8.41 21.79 6.78 19.75C6.63 19.56 6.29 19.43 6.02 19.47C4.27 19.8 5.53 21.9 4.71 22.92C4.56 22.94 4.4 22.97 4.28 22.87C3.91 22.55 3.99 21.68 3.99 21.26C3.98 19.94 4.43 18.64 5.95 18.51C7.3 18.37 7.87 19.66 8.75 20.38C12.06 23.08 16.77 21.41 19.21 18.37C20.99 16.15 21.86 13.45 21.58 10.63C21.33 8.16 19.81 5.36 17.15 4.98C16.03 4.75 15.05 5.47 14 5.59C12.11 5.8 12.03 3.62 12 2.3C11.98 1.77 11.96 1.43 12.32 1.05Z',
      true,
      false
    ),
    (
      'M9.85 1C10.56 1.18 10.4 1.93 10.38 2.54C10.35 4.36 10.57 6.28 12.12 7.47C12.21 7.54 12.79 7.9 12.8 7.99C13.25 11.25 12.53 15.99 8.42 16.31C6.74 16.45 5.22 15.71 3.71 17.04C2.15 18.41 2.41 20.28 2.35 22.15C2.34 22.58 2.25 22.73 1.94 23C1.11 22.6 1.45 21.93 1.39 21.22C1.13 18.02 2.84 15.08 6.35 15.23C7.92 15.3 9.06 15.75 10.4 14.4C12.06 12.73 11.89 10.76 11.91 8.61C9.89 6.89 9.37 5.46 9.41 2.77C9.42 2.09 9.21 1.4 9.85 1Z',
      true,
      false
    )
  ],
  'intestine': [
    (
      'M18.39 1.01C19.35 0.91 20.45 1.52 20.92 2.36C21.47 3.33 21.39 4.18 21.12 5.18C21.89 6.67 22.03 7.61 21.34 9.17C21.95 10.72 21.94 11.31 21.45 12.89C21.58 13.38 21.68 13.75 21.73 14.25C21.82 15.21 21.27 15.73 21 16.47C20.81 17.2 20.87 17.79 20.3 18.38C19.79 18.91 19.16 18.87 18.52 19.1C18.22 19.21 17.98 19.56 17.68 19.7C17.37 19.87 16.74 19.86 16.44 20C15.44 20.46 15.29 20.66 14.15 20.68C13.89 21.37 13.65 22.02 13.44 22.73C13.37 22.97 13.05 23.1 12.81 22.91C12.46 22.17 13.16 20.34 13.7 19.76C13.81 19.64 14.67 19.77 14.85 19.79C15.27 19.62 15.67 19.29 16.04 19.02C16.98 19.06 17.13 19.05 17.83 18.41C18.35 17.94 18.71 18.21 19.21 18.04C20.18 17.76 19.8 16.46 20.06 16.06C21.01 14.58 21.02 14.6 20.43 12.82C21.09 10.75 21.07 11.16 20.33 9.18C21.18 7.2 21 7.09 20.11 5.31C20.35 4.52 20.62 3.81 20.23 3.02C19.98 2.51 19.52 2.13 18.97 1.97C17.97 1.69 17.43 2.3 16.65 2.74C14.8 2.43 14.94 2.73 13.47 3.5C12.86 3.36 12.36 3.05 11.71 3.03C11.02 3 10.36 3.52 9.72 3.46C9.36 3.43 8.92 3 8.51 2.89C7.98 2.76 7.61 2.91 7.13 2.87C6.7 2.83 6.27 2.68 5.83 2.67C4.17 2.65 4.01 3.85 4.02 5.2C2.72 6.63 3.08 7 3.63 8.62C2.93 10.39 2.87 10.37 3.76 12.11C3.32 13.21 2.69 14.17 3.51 15.37C3.82 15.82 4.3 16.12 4.85 16.22C5.38 16.32 5.93 16.2 6.36 15.87C6.84 15.53 7.16 15.01 7.24 14.43C7.4 13.23 6.8 12.73 6.18 11.96C6.83 9.87 6.62 10.47 6.08 8.56L6.07 8.5C6.48 7.37 6.3 6.68 6.51 6.09C6.98 5.61 7.62 6.34 8.16 6.37C8.59 6.4 9.23 6.25 9.67 6.16C10.12 6.32 10.51 6.59 11.03 6.74C12.13 7.05 12.78 6.65 13.69 6.15C14.43 6.05 15.32 6.57 16.29 6.14C16.97 5.83 17 5.62 17.59 5.23C17.71 5.15 17.83 5.2 17.95 5.24C18.58 5.93 17.57 6.35 17.37 6.78C17.09 7.36 17.53 8.53 17.74 9.13C17.23 10.85 17.03 10.64 17.67 12.54C17.56 12.85 17.22 13.79 17.23 13.98C17.24 15.16 17.56 15.28 16.32 15.72C16.1 15.83 15.64 16.34 15.44 16.38C14.69 16.55 13.96 16.92 13.24 17.12C12.74 17.21 11.87 17.14 11.46 17.5C9.96 18.83 11.35 20.94 11.27 22.54C11.27 22.7 11.18 22.83 11.05 22.93C10.32 23.08 10.36 22.14 10.23 21.59C9.79 19.77 9.35 17.36 11.53 16.45C12.05 16.23 12.79 16.37 13.26 16.2C14.01 15.93 14.19 15.74 15.02 15.64C15.49 15.22 15.71 15.05 16.29 14.79C16.23 13.9 16.4 13.38 16.67 12.54C16.37 11.71 16.51 11.05 15.69 10.48C15.43 10.3 14.9 9.99 14.58 9.97C12.81 9.84 10.99 9.89 9.22 9.97C8.45 10.01 7.23 11.07 7.35 11.81C7.79 12.24 12.49 11.55 13.61 11.96C15.45 12.64 15.01 15.22 13.42 15.22C11.8 15.23 9.55 15.41 7.97 15.21C7.76 15.68 7.51 16 7.22 16.41C7.49 16.81 7.85 17.23 7.58 17.72C7.03 18.04 6.71 17.32 6.51 16.94L6.39 16.98C5.46 17.24 4.6 17.27 3.72 16.76C3 16.34 2.49 15.65 2.3 14.84C2.09 13.97 2.26 12.98 2.72 12.22C1.99 10.95 2.08 9.87 2.6 8.57C2.52 8.34 2.45 8.11 2.38 7.87C1.89 6.19 2.49 6 3.06 4.58C3.21 4.23 3.13 3.58 3.52 2.98C3.92 2.38 4.32 2.03 5.04 1.85C5.31 1.79 5.58 1.75 5.85 1.76C6.3 1.76 6.83 1.91 7.24 1.92C8.41 1.94 8.85 1.95 9.89 2.57C11.22 2.01 12.02 2 13.34 2.5C14.5 1.69 15.09 1.65 16.45 1.76C17.18 1.27 17.5 1.13 18.39 1.01ZM9.6 7.13C8.75 7.33 8.14 7.36 7.29 7.07C7.26 7.64 7.22 7.89 7.07 8.45C7.22 8.92 7.39 9.41 7.45 9.89C8.04 9.42 8.55 9.13 9.33 9.07C11.42 8.96 14.88 8.65 16.52 9.96L16.76 9.16C16.43 8.31 16.37 8.02 16.41 7.09C15.54 7.28 14.94 7.36 14.07 7.04C12.29 7.93 11.43 8.04 9.6 7.13ZM7.92 12.86C8.12 13.48 8.14 13.78 8.14 14.43C9.53 14.4 10.92 14.4 12.31 14.41C13.05 14.41 14.03 14.53 13.91 13.41C13.89 13.24 13.76 13.02 13.61 12.92C12.94 12.58 10.26 12.67 9.6 12.75C9.05 12.81 8.47 12.88 7.92 12.86Z',
      true,
      false
    )
  ],
  'kidneys': [
    (
      'M16.96 2.66C21.41 2.11 23.45 8.59 22.92 12.01C22.62 13.9 22.08 15.6 20.55 16.83C17.78 19.06 13.95 17.33 14.48 13.61C14.64 12.49 15.07 11.79 15.97 11.11C15.87 10.54 15.78 10.03 15.65 9.46C15.6 9.38 15.61 9.4 15.52 9.35C15.45 9.36 15.38 9.36 15.31 9.39C14.61 9.65 14.11 10.18 13.86 10.88C13.42 12.07 13.62 17.62 13.63 19.23C13.63 19.85 13.75 20.7 13.46 21.27C13.36 21.33 13.19 21.36 13.07 21.34C12.99 21.32 12.89 21.28 12.85 21.2C12.64 20.88 12.71 13.14 12.75 12.25C12.76 11.79 12.82 11.33 12.91 10.88C13.15 9.75 13.89 9.17 14.79 8.59C13.32 7.04 13.68 4.3 15.48 3.17C16.01 2.83 16.36 2.76 16.96 2.66ZM16.3 8.64C16.59 9.29 16.96 11 16.89 11.77C16.85 12.25 15.97 11.99 15.8 12.46C14.64 14.44 15.58 17.07 18.16 16.89C24.35 15.83 22.56 3 16.99 3.55C14.92 4.03 14.14 6.1 15.33 7.86C15.58 8.23 15.95 8.4 16.3 8.64Z',
      true,
      false
    ),
    (
      'M6.63 2.84C9.62 2.61 11.12 6.69 9.08 8.61C9.81 9.05 10.42 9.52 10.78 10.32C10.98 10.77 11.06 11.25 11.1 11.73C11.18 12.66 11.24 20.88 11.07 21.18C11.03 21.26 10.97 21.32 10.88 21.35C10.72 21.39 10.58 21.39 10.44 21.31C10.35 21.26 10.3 21.18 10.28 21.08C10.17 20.56 10.26 19.82 10.26 19.29C10.26 17.77 10.41 12.01 10.1 11.06C9.87 10.39 9.45 9.85 8.81 9.53C8.79 9.52 8.77 9.51 8.75 9.5C8.65 9.44 8.44 9.29 8.34 9.41C8.02 9.77 7.94 10.62 7.86 11.09C8.13 11.33 8.39 11.57 8.6 11.87C9.49 13.13 9.5 15.02 8.6 16.28C8.07 17.03 7.25 17.53 6.33 17.66C2.83 18.14 0.96 14.19 1 11.27C1.03 8.95 1.5 6.83 2.95 4.95C3.99 3.6 4.98 3.05 6.63 2.84ZM6.38 16.72C8.4 16.27 8.97 13.59 7.68 12.15C7.39 12.04 6.84 12.24 6.79 11.85C6.75 11.53 6.95 10.99 7.01 10.66C7.32 9.02 7.39 9.03 8.46 7.97C9.9 6.56 8.92 3.58 6.44 3.73C1.7 4.6 0.27 13.54 4.09 16.23C4.78 16.72 5.57 16.86 6.38 16.72Z',
      true,
      false
    )
  ],
  'bladder': [
    (
      'M20.82 4.2C24.14 3.93 23.2 8.46 21.08 9.34C20.91 9.45 20.35 9.71 20.25 9.83C19.21 11.13 18.55 11.46 16.96 11.84C16.67 11.91 15.83 12.76 15.31 12.9C14.71 13.06 14.05 13.12 13.45 13.28C12.34 13.8 12.37 14 11.11 14.24C11.22 15.34 11.14 16.31 10.63 17.31C10.08 18.39 9.12 19.21 7.97 19.58C6.57 20.02 5.25 19.83 3.98 19.15C3.81 19.05 3.64 18.95 3.48 18.84C0.5 16.85 0.35 12.02 2.27 9.27C3.65 7.31 5.78 6.27 8.16 6.18C8.95 6.15 9.69 6.28 10.47 6.28C11.2 6.26 12.13 5.75 12.97 5.69C13.81 5.63 14.47 5.78 15.26 5.76C15.64 5.74 16.38 5.24 16.87 5.09C17.59 4.87 18.35 4.96 19 4.81C19.61 4.67 20.09 4.33 20.82 4.2ZM3.83 17.93C4.85 18.69 5.8 19.01 7.05 18.83C9.16 18.53 10.4 16.62 10.15 14.57C10.13 14.36 10.09 13.82 10.26 13.62C10.66 13.34 11.42 13.29 11.88 13.09C12.44 12.83 12.89 12.38 13.51 12.28C14.01 12.2 14.42 12.21 14.91 12.05C15.51 11.84 16.02 11.21 16.54 10.97C17.17 10.68 17.69 10.85 18.37 10.39C18.93 10.01 19.22 9.42 19.69 9.07C20.22 8.66 21.13 8.39 21.54 7.79C21.88 7.29 22.04 6.58 22.12 5.99C21.88 5.31 21.71 5.03 20.94 5.11C20.74 5.17 20.15 5.35 20.02 5.44C19.29 5.94 18 5.65 17.36 5.92C16.02 6.48 15.45 6.92 13.91 6.61C13.08 6.44 11.96 6.84 11.19 7.12C10.39 7.36 9.14 7.1 8.26 7.1C3.92 7.1 0.91 11.34 2.22 15.5C2.51 16.45 3.07 17.29 3.83 17.93Z',
      true,
      false
    ),
    (
      'M8.48 9.49C8.76 9.54 8.81 9.55 8.97 9.74C9.07 10.1 8.88 10.39 8.74 10.72C9.28 10.61 10.66 10.23 11.2 10.34C11.34 10.36 11.43 10.54 11.49 10.67C11.48 10.83 11.48 11.02 11.31 11.07C9.43 11.65 7.93 11.44 6.4 12.96C5.86 13.61 5.51 14.72 5.04 14.9C4.22 14.69 4.82 13.7 5.06 13.26C5.68 12.12 6.55 11.64 7.63 11C7.9 10.47 8.03 9.89 8.48 9.49Z',
      true,
      false
    )
  ],
};

extension _PeSaveFooterExt on Widget {
  /// แผงขวา: เนื้อหาเลื่อนได้ + ปุ่มบันทึกติดล่าง
  /// footer แบบ workflow panel: ปุ่มลอยทับเนื้อหา (ไม่มีพื้นขาว/เส้นคั่น)
  /// เนื้อหาเลื่อนลอดใต้ปุ่ม จางบาง ๆ ช่วงปุ่ม (เหมือน _wfFadePage)
  Widget withSaveFooter(Widget footer) => Stack(children: [
        Positioned.fill(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) {
              // ไม่มีปุ่ม footer = ไม่จาง (โครงเดิม ไม่เสียตำแหน่งเลื่อน)
              if (footer is SizedBox) {
                return const LinearGradient(
                    colors: [Colors.white, Colors.white]).createShader(r);
              }
              final h = r.height;
              double at(double px) => (1.0 - px / h).clamp(0.0, 1.0);
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white.withValues(alpha: 0.6),
                  Colors.white.withValues(alpha: 0.3),
                ],
                stops: [0.0, at(110.0), at(70.0), 1.0],
              ).createShader(r);
            },
            child: this,
          ),
        ),
        Positioned(left: 0.0, right: 0.0, bottom: 0.0, child: footer),
      ]);
}

/// หลายรูป: รูปถัดไปเอียงซ้อนด้านหลัง + ป้าย +x มุมขวาล่าง (ขนาดตาม [size])
Widget _photoStack(List<Uint8List> list, double size, TextStyle badge) {
  final k = size / 48.0;
  // ขอบขาววาดทับรูป (foregroundDecoration) ให้ขอบเนียน ไม่โดนรูปกินขอบ
  Widget tile(Uint8List b, double w) => Container(
        width: w,
        height: w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(10.0 * k),
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), blurRadius: 3.0),
          ],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0 * k),
          border: Border.all(
              color: Colors.white,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignOutside),
        ),
        child: Image.memory(b,
            fit: BoxFit.cover, filterQuality: FilterQuality.medium),
      );
  return SizedBox(
    width: 54.0 * k,
    height: 52.0 * k,
    child: Stack(clipBehavior: Clip.none, children: [
      Positioned(
        left: 6.0 * k,
        top: 0.0,
        child: Transform.rotate(
            angle: 0.08,
            filterQuality: FilterQuality.medium,
            child: tile(list[1], 46.0 * k)),
      ),
      Positioned(left: 0.0, top: 4.0 * k, child: tile(list.first, size)),
      Positioned(
        right: 0.0,
        bottom: 0.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.0 * k, vertical: 1.0 * k),
          decoration: BoxDecoration(
            color: _inkTitle,
            borderRadius: BorderRadius.circular(999.0),
            border: Border.all(color: Colors.white, width: 1.5 * k),
          ),
          child: Text('+${list.length - 1}', style: badge),
        ),
      ),
    ]),
  );
}

/// แอนิเมชันบันทึกสำเร็จ: ม่านขาวจาง วงกรมท่าเด้งขึ้น ติ๊กถูกวาดเส้น
/// วงคลื่นกระจาย อนุภาคแตกออก แล้วข้อความเลื่อนขึ้น (ราว 1.7 วินาที แล้วปิดเอง)
class _PeSaveSuccess extends StatefulWidget {
  const _PeSaveSuccess({required this.regions, required this.onDone});
  final int regions;
  final VoidCallback onDone;

  @override
  State<_PeSaveSuccess> createState() => _PeSaveSuccessState();
}

class _PeSaveSuccessState extends State<_PeSaveSuccess>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1750))
    ..forward().whenComplete(() {
      if (mounted) widget.onDone();
    });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double a, double b, [Curve c = Curves.easeOutCubic]) =>
      c.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          // ม่าน: เข้า 0–0.15 ออก 0.88–1
          final veil = _seg(0.0, 0.15) * (1.0 - _seg(0.88, 1.0));
          final pop = _seg(0.06, 0.42, Curves.elasticOut);
          final tick = _seg(0.30, 0.52);
          final burst = _seg(0.34, 0.85);
          final ring = _seg(0.20, 0.80);
          final txt = _seg(0.42, 0.62);
          final out = _seg(0.88, 1.0);
          return IgnorePointer(
            child: Material(
              type: MaterialType.transparency,
              child: ColoredBox(
                color: Colors.white.withValues(alpha: 0.86 * veil),
                child: Center(
                  child: Transform.scale(
                    scale: 1.0 - 0.08 * out,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        width: 220.0,
                        height: 220.0,
                        child: CustomPaint(
                          painter: _PeSuccessPainter(
                              pop: pop,
                              tick: tick,
                              burst: burst,
                              ring: ring,
                              fade: 1.0 - out),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0.0, 14.0 * (1.0 - txt)),
                        child: Column(children: [
                          Text('บันทึกภาพตรวจร่างกายแล้ว',
                              style: TextStyle(
                                  fontFamily: _fontFam,
                                  fontFamilyFallback: _fontFb,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  color: _inkTitle.withValues(
                                      alpha: txt * (1.0 - out)))),
                          const SizedBox(height: 4.0),
                          Text('ระบุไว้ ${widget.regions} บริเวณ',
                              style: TextStyle(
                                  fontFamily: _fontFam,
                                  fontFamilyFallback: _fontFb,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: _ink2.withValues(
                                      alpha: txt * (1.0 - out)))),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _PeSuccessPainter extends CustomPainter {
  _PeSuccessPainter(
      {required this.pop,
      required this.tick,
      required this.burst,
      required this.ring,
      required this.fade});
  final double pop, tick, burst, ring, fade;

  static const _navy = _blue;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const r = 46.0;
    // วงคลื่นกระจาย 2 ชั้น
    for (final (d, k) in [(0.0, 1.0), (0.18, 0.7)]) {
      final t = ((ring - d) / (1.0 - d)).clamp(0.0, 1.0);
      if (t <= 0.0) continue;
      canvas.drawCircle(
          c,
          r + 62.0 * t,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 * (1.0 - t) + 0.5
            ..color = _navy.withValues(alpha: 0.28 * k * (1.0 - t) * fade));
    }
    // อนุภาคแตกออก: จุดกลม + ขีดสั้น สลับสี
    const cols = [
      Color(0xFF1A73E8),
      Color(0xFF34A853),
      Color(0xFFFBBC04),
      _navy,
      Color(0xFF8AB4F8),
    ];
    for (var i = 0; i < 18; i++) {
      final a = i / 18.0 * 2 * 3.14159265 + (i.isEven ? 0.0 : 0.17);
      final dist = r + 12.0 + (i % 3 == 0 ? 64.0 : 46.0) * burst;
      final p = c + Offset.fromDirection(a, dist);
      final al = (burst < 0.05 ? 0.0 : (1.0 - burst)) * fade;
      final paint = Paint()
        ..color = cols[i % cols.length].withValues(alpha: al);
      if (i % 2 == 0) {
        canvas.drawCircle(p, 4.0 * (1.0 - burst * 0.6), paint);
      } else {
        paint
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
            p, p + Offset.fromDirection(a, 9.0 * (1.0 - burst)), paint);
      }
    }
    // วงกรมท่าเด้งขึ้น + เงานุ่ม
    if (pop > 0.0) {
      canvas.drawCircle(
          c + const Offset(0.0, 6.0),
          r * pop,
          Paint()
            ..color = _navy.withValues(alpha: 0.22 * fade)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0));
      canvas.drawCircle(
          c, r * pop, Paint()..color = _navy.withValues(alpha: fade));
    }
    // ติ๊กถูกวาดเส้นตามเวลา
    if (tick > 0.0) {
      final path = Path()
        ..moveTo(c.dx - 18.0, c.dy + 1.0)
        ..lineTo(c.dx - 5.0, c.dy + 14.0)
        ..lineTo(c.dx + 20.0, c.dy - 12.0);
      final m = path.computeMetrics().first;
      canvas.drawPath(
          m.extractPath(0.0, m.length * tick),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6.0
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = Colors.white.withValues(alpha: fade));
    }
  }

  @override
  bool shouldRepaint(_PeSuccessPainter o) =>
      o.pop != pop ||
      o.tick != tick ||
      o.burst != burst ||
      o.ring != ring ||
      o.fade != fade;
}

/// ภาพย่อซูมที่จุดของภาพตรวจร่างกาย: หลายภาพ = เลื่อนสลับเองทุก 2.6 วิ + จุดบอกลำดับ
class _PeFocusSlides extends StatefulWidget {
  const _PeFocusSlides({required this.shots});
  final List<Uint8List> shots;

  @override
  State<_PeFocusSlides> createState() => _PeFocusSlidesState();
}

class _PeFocusSlidesState extends State<_PeFocusSlides> {
  int _i = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    if (widget.shots.length > 1) {
      _t = Timer.periodic(const Duration(milliseconds: 2600), (_) {
        if (mounted) setState(() => _i = (_i + 1) % widget.shots.length);
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.shots.length;
    final i = _i % n;
    return Stack(fit: StackFit.expand, children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (c, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(
              position: Tween(begin: const Offset(0.12, 0.0), end: Offset.zero)
                  .animate(a),
              child: c),
        ),
        child: Image.memory(widget.shots[i],
            key: ValueKey(i),
            fit: BoxFit.cover,
            gaplessPlayback: true,
            width: double.infinity,
            height: double.infinity),
      ),
      if (n > 1)
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 6.0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var k = 0; k < n; k++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: k == i ? 12.0 : 5.0,
                height: 5.0,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                decoration: BoxDecoration(
                  color: k == i ? _blue : _blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
          ]),
        ),
    ]);
  }
}

/// ป้ายหนึ่งอันบนหุ่นใน studio (ตำแหน่งจุด · ข้อความ · badge CC/Dx · ความกว้างโดยประมาณ)
class _StudioLabel {
  _StudioLabel(this.at, this.text, this.tag, this.w, this.onTap,
      {this.photo, this.photos = const []});

  /// รูปทั้งหมดของบริเวณ (หลายรูป = avatar stack)
  final List<Uint8List> photos;

  /// รูปเล็กของหมุด (รูปประกอบล่าสุดของบริเวณ)
  final Uint8List? photo;
  final Offset at;
  final String text;
  final String? tag; // null = หมุดที่ปัก
  final double w;
  final VoidCallback? onTap;
  double y = 0.0;
}

/// เส้นนำของป้าย: จากจุดเฉียงไปหาแนวป้าย แล้วเส้นตรงเข้าป้าย
class _StudioLeadPainter extends CustomPainter {
  _StudioLeadPainter(this.lines);
  final List<(Offset, Offset, Color)> lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (a, b, c) in lines) {
      final p = Paint()
        ..color = c.withValues(alpha: 0.55)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final dir = b.dx >= a.dx ? 1.0 : -1.0;
      final knee = Offset(b.dx - dir * 10.0, b.dy);
      canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(knee.dx, knee.dy)
            ..lineTo(b.dx, b.dy),
          p);
    }
  }

  @override
  bool shouldRepaint(_StudioLeadPainter old) => true;
}

/// ภาพนำการปักหมุดบนตัวหุ่น: มือนิ่งที่หน้าอก + วงกระเพื่อมเบา ๆ · ป้ายสั้นใต้นิ้ว
/// วาดสีโปร่งทั้งหมด (ไม่ใช้ Opacity ทับ WebView)
class _TapCoach extends StatefulWidget {
  const _TapCoach({super.key});
  @override
  State<_TapCoach> createState() => _TapCoachState();
}

class _TapCoachState extends State<_TapCoach>
    with SingleTickerProviderStateMixin {
  late final AnimationController _a = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat();

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _a,
          builder: (_, __) {
            // จุดเป้าหมาย: หน้าอกซ้ายของหุ่น (หุ่นอยู่กลางพื้นที่)
            final target = Offset(box.maxWidth * 0.5, box.maxHeight * 0.36);
            // เรียบง่าย: มือนิ่งที่จุด + วงกระเพื่อมเบา ๆ วนเรื่อย ๆ (ไม่เลื่อน ไม่ปักหมุด)
            final t = _a.value;
            const fade = 1.0;
            const press = 0.0;
            final ripple = t;
            final hand = target;
            return Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CoachRipplePainter(ripple, target, fade),
                ),
              ),
              // มือ: ปลายนิ้วชี้อยู่ที่จุด (ไอคอน touch_app ปลายนิ้วอยู่บนกลาง)
              Positioned(
                left: hand.dx - 13.0,
                top: hand.dy - 3.0,
                child: Transform.scale(
                  scale: 1.0 - 0.12 * press,
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.touch_app_rounded,
                      size: 34.0,
                      color: _blue.withValues(alpha: 0.9 * fade),
                      shadows: [
                        Shadow(
                            color: Colors.white.withValues(alpha: fade),
                            blurRadius: 6.0),
                      ]),
                ),
              ),
              // ป้ายสั้นใต้มือ
              Positioned(
                left: target.dx - 110.0,
                width: 220.0,
                top: target.dy + 44.0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: _panel.withValues(alpha: 0.92 * fade),
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(
                          color:
                              const Color(0xFFDADCE0).withValues(alpha: fade),
                          width: 0.5),
                    ),
                    child: Text('แตะจุดที่ผิดปกติเพื่อปักหมุด',
                        style: TextStyle(
                            fontFamily: _fontFam,
                            fontFamilyFallback: _fontFb,
                            fontSize: 12.5 * _txtScale,
                            color: _inkTitle.withValues(alpha: fade),
                            fontWeight: _minW(FontWeight.w600))),
                  ),
                ),
              ),
            ]);
          },
        ),
      );
}

/// วงกระเพื่อม 2 วง + หมุดแดง ณ จุดที่แตะ
class _CoachRipplePainter extends CustomPainter {
  _CoachRipplePainter(this.t, this.at, this.fade, {this.pin = false});
  final double t;
  final Offset at;
  final double fade;
  final bool pin;
  @override
  void paint(Canvas canvas, Size size) {
    if (t > 0.0) {
      for (final k in [t, (t - 0.3).clamp(0.0, 1.0)]) {
        if (k <= 0.0) continue;
        canvas.drawCircle(
            at,
            8.0 + 26.0 * k,
            Paint()
              ..color = _blue.withValues(alpha: 0.35 * (1.0 - k) * fade)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0);
      }
    }
    if (pin) {
      canvas.drawCircle(
          at, 10.0, Paint()..color = _red.withValues(alpha: 0.22 * fade));
      canvas.drawCircle(at, 5.5, Paint()..color = _red.withValues(alpha: fade));
      canvas.drawCircle(
          at,
          5.5,
          Paint()
            ..color = Colors.white.withValues(alpha: fade)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(_CoachRipplePainter o) =>
      o.t != t || o.fade != fade || o.pin != pin;
}
