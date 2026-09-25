// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ Template order (drill-in)
// เลือก template ใน Order Set แล้วเข้าไปอีกชั้น:
// rail ซ้าย = sub menu หัวข้อ progress note ใต้ขั้น Order Set · แผงกลาง = ประเมินหัวข้อนั้น
// แผงขวา = คำสั่งตามลำดับเอกสาร เฉพาะที่เกี่ยวกับหัวข้อที่เลือก (สรุป = ทั้งหมด)

mixin _FeaturesOrderTemplateTemplateViewState on State<ErFlowHomeWidget> {
  /// template ที่เปิดอยู่ (null = หน้า Order Set ปกติ)
  String? _tplOpen;

  /// หัวข้อที่เลือกใน rail · เท่ากับจำนวนหัวข้อ = สรุป
  int _tplSec = 0;

  /// ผลประเมิน progress note: หัวข้อ → ตัวเลือกที่เลือก
  final Map<String, Set<String>> _tplAns = {};

  /// ติ๊ก/ไม่ติ๊กที่แพทย์เปลี่ยนเอง: 'block|บรรทัด' → ติ๊ก
  final Map<String, bool> _tplTick = {};

  /// อัตรา ml/hr ของบรรทัดที่ต้องกรอก
  final Map<String, TextEditingController> _tplRate = {};

  /// คำสั่งที่บันทึกแล้วจาก template (แสดงในแท็บคำสั่งแพทย์)
  final List<String> _tplSaved = [];

  /// รอบประเมินที่บันทึกแล้ว (แทนคอลัมน์ Date ของเอกสาร): เวลา · สาขา · ประเมินซ้ำอีกกี่ ชม.
  final List<(DateTime, String, int)> _tplRounds = [];

  /// หน้าสรุปแสดงแบบกระดาษ (false = รายการ)
  bool _tplPaper = true;
}

extension _FeaturesOrderTemplateTemplateViewPart on _ErFlowHomeWidgetState {
  List<_PnSection> get _tplNote => _snakeNote;
  List<_TplBlock> get _tplBlocks => _snakeBlocks(_tplAns);
  bool get _tplOn => _tplOpen != null && _speechOpen;

  void _tplEnter(String id) => setState(() {
        _tplOpen = id;
        _tplSec = 0;
        _orderEditing = null;
      });

  void _tplExit() => setState(() => _tplOpen = null);

  bool _tplLineOn(_TplBlock b, int i) =>
      _tplTick['${b.id}|$i'] ?? !_snakeDefaultOff(b.id, i, _tplAns);

  int get _tplCount => [
        for (final b in _tplBlocks)
          for (var i = 0; i < b.lines.length; i++)
            if (_tplLineOn(b, i)) 1
      ].length;

  /// ผล lab ของเคสที่ใช้ประเมินเกณฑ์ข้อนี้: (ข้อความ, เข้าเกณฑ์) · null = ข้อนี้ไม่ใช้ lab
  (String, bool)? _tplLabHint(String opt) {
    ErLab? lab(String n) =>
        _case.labs.where((l) => l.name == n && l.isNumeric).firstOrNull;
    String v(double x) => x % 1 == 0 ? x.toStringAsFixed(0) : x.toString();
    switch (opt) {
      case 'Platelet < 50,000 หรือ INR > 1.2':
        final plt = lab('Plt');
        final inr = lab('INR');
        if (plt == null && inr == null) return ('ยังไม่มีผล Plt / INR', false);
        return (
          [
            if (plt != null) 'Plt ${v(plt.value)}k',
            if (inr != null) 'INR ${v(inr.value)}',
          ].join(' · '),
          (plt != null && plt.value < 50) || (inr != null && inr.value > 1.2)
        );
      case 'WBCT > 20 min':
        final w = lab('WBCT');
        return w == null
            ? ('ยังไม่มีผล WBCT', false)
            : ('WBCT ${v(w.value)} min', w.value > 20);
      case 'AKI':
        final cr = lab('Cr');
        return cr == null
            ? ('ยังไม่มีผล Cr', false)
            // เอกสารใช้ AKI เป็นเกณฑ์เฉพาะงูแมวเซา
            : _SnakeState(_tplAns).species == 'งูแมวเซา'
                ? ('Cr ${v(cr.value)} mg/dL', cr.value > cr.hi)
                : (
                    'Cr ${v(cr.value)} mg/dL · ใช้เป็นเกณฑ์เฉพาะงูแมวเซา',
                    false
                  );
    }
    return null;
  }

  /// เวลาประเมินรอบถัดไป (null = ยังไม่เคยบันทึก)
  DateTime? get _tplDue => _tplRounds.isEmpty
      ? null
      : _tplRounds.last.$1.add(Duration(hours: _tplRounds.last.$3));

  String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------- rail

  /// sub menu ใต้ขั้น Order Set ใน rail workflow: หัวข้อ progress note ของ template
  Widget _tplSubmenu() {
    final secs = _tplNote;
    final done = secs.where((s) => (_tplAns[s.id] ?? {}).isNotEmpty).length;
    Widget item(int i, IconData icon, String label, bool complete) {
      final on = _tplSec == i;
      return _Press(
        child: GestureDetector(
          onTap: () => setState(() => _tplSec = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 54.0,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: on ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9.0),
              border: Border.all(
                  color:
                      on ? _blue.withValues(alpha: 0.35) : Colors.transparent),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  gradient: complete
                      ? _glossGrad(_green)
                      : (on ? _glossGrad(_blue) : _glossWhite),
                  shape: BoxShape.circle,
                  border: complete || on ? null : Border.all(color: _line),
                ),
                foregroundDecoration: _InnerGloss(100.0, dark: complete || on),
                child: Icon(complete ? Icons.check_rounded : icon,
                    size: 12.0, color: complete || on ? Colors.white : _ink3),
              ),
              const SizedBox(height: 2.0),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(8.0,
                      color: on ? _blue : _ink2,
                      weight: on ? FontWeight.w700 : FontWeight.w500,
                      height: 1.1)),
            ]),
          ),
        ),
      );
    }

    return Container(
      width: 60.0,
      margin: const EdgeInsets.only(top: 6.0),
      padding: const EdgeInsets.fromLTRB(3.0, 6.0, 3.0, 6.0),
      decoration: BoxDecoration(
        color: _blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: _blue.withValues(alpha: 0.18)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ปิด template กลับหน้า Order Set
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$done/${secs.length}',
              style: _num(11.0, color: _inkTitle, weight: FontWeight.w600)),
          const SizedBox(width: 4.0),
          Tooltip(
            message: 'ปิด template',
            child: _Press(
              child: GestureDetector(
                onTap: _tplExit,
                child:
                    const Icon(Icons.close_rounded, size: 14.0, color: _blue),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 4.0),
        for (var i = 0; i < secs.length; i++)
          item(i, secs[i].icon, secs[i].short,
              (_tplAns[secs[i].id] ?? {}).isNotEmpty),
        Container(
          width: 24.0,
          height: 1.0,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          color: _line,
        ),
        item(secs.length, Icons.fact_check_rounded, 'สรุป', false),
      ]),
    );
  }

  // ---------------------------------------------------------------- กลาง

  /// แผงกลาง: ประเมินหัวข้อ progress note ที่เลือก
  Widget _tplBody() {
    final secs = _tplNote;
    final summary = _tplSec >= secs.length;
    final sec = summary ? null : secs[_tplSec];
    final st = _SnakeState(_tplAns);

    // หัวข้อ antivenom: แสดงเฉพาะเกณฑ์ของสาขาพิษที่ประเมินไว้
    List<_PnGroup> groups() {
      if (sec == null) return const [];
      if (sec.id != 'antivenom' || st.species.isEmpty) return sec.groups;
      return [sec.groups[st.neuro ? 1 : 0]];
    }

    Widget opt(_PnSection s, _PnOpt o) {
      final set = _tplAns.putIfAbsent(s.id, () => <String>{});
      final on = set.contains(o.label);
      final hint = s.id == 'antivenom' ? _tplLabHint(o.label) : null;
      final referHint =
          s.id == 'refer' && !on && st.referHint.contains(o.label);
      return _Press(
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () => setState(() {
            if (s.single) {
              final was = on;
              set.clear();
              if (!was) set.add(o.label);
            } else if (on) {
              set.remove(o.label);
            } else {
              set.add(o.label);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.only(bottom: 6.0),
            padding: const EdgeInsets.fromLTRB(10.0, 9.0, 12.0, 9.0),
            decoration: BoxDecoration(
              color: on ? _blue.withValues(alpha: 0.07) : _panel,
              borderRadius: BorderRadius.circular(10.0),
              border:
                  Border.all(color: on ? _blue.withValues(alpha: 0.55) : _line),
            ),
            child: Row(children: [
              Icon(
                  s.single
                      ? (on
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded)
                      : (on
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded),
                  size: 19.0,
                  color: on ? _blue : _g5),
              const SizedBox(width: 9.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.label,
                        style: _t(12.0,
                            color: _inkTitle,
                            weight: on ? FontWeight.w700 : FontWeight.w600)),
                    if (o.sub.isNotEmpty)
                      Text(o.sub, style: _t(9.5, color: _ink3)),
                    if (hint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.science_rounded,
                              size: 11.0, color: hint.$2 ? _red : _ink3),
                          const SizedBox(width: 4.0),
                          Text(hint.$2 ? 'เข้าเกณฑ์ · ${hint.$1}' : hint.$1,
                              style: _t(9.5,
                                  color: hint.$2 ? _red : _ink3,
                                  weight: FontWeight.w600)),
                        ]),
                      ),
                    if (referHint)
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Text('แนะนำ · เข้าเกณฑ์จากหัวข้อที่ประเมินไว้',
                            style:
                                _t(9.5, color: _blue, weight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      );
    }

    final body = summary
        ? <Widget>[
            Text('สรุปผลประเมิน',
                style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
            const SizedBox(height: 8.0),
            for (final s in secs)
              InkWell(
                onTap: () => setState(() => _tplSec = secs.indexOf(s)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: _line))),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120.0,
                          child: Text(s.title,
                              style: _t(10.5,
                                  color: _ink3, weight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: Text(
                              (_tplAns[s.id] ?? {}).isEmpty
                                  ? '—'
                                  : _tplAns[s.id]!.join(', '),
                              style: _t(11.5,
                                  color: _inkTitle, weight: FontWeight.w600)),
                        ),
                      ]),
                ),
              ),
          ]
        : <Widget>[
            if (sec!.id == 'antivenom') ..._tplLabSuggest(groups()),
            for (final g in groups()) ...[
              if (g.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
                  child: Text(g.title,
                      style: _t(10.5, color: _ink3, weight: FontWeight.w700)),
                ),
              for (final o in g.opts) opt(sec, o),
              const SizedBox(height: 4.0),
            ],
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 8.0, 0.0),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Standing order Snake bite',
                      style: _t(10.0, color: _ink3, weight: FontWeight.w600)),
                  Text(summary ? 'สรุป' : sec!.title,
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                  _tplRoundLine(),
                ],
              ),
            ),
            IconButton(
              tooltip: 'ย่อ',
              onPressed: _closeSpeech,
              icon: const Icon(Icons.keyboard_double_arrow_left_rounded,
                  size: 20.0, color: _ink3),
            ),
          ]),
        ),
        const SizedBox(height: 4.0),
        Expanded(
          child: ListView(
            key: PageStorageKey('tpl-body-$_tplSec'),
            padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
            children: body,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
          child: Row(children: [
            Expanded(
              child: _navBtn('ย้อนกลับ', Icons.chevron_left_rounded,
                  _tplSec > 0 ? () => setState(() => _tplSec--) : _tplExit,
                  primary: false),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              flex: 2,
              child: summary
                  ? _navBtn(
                      _tplMissing > 0
                          ? 'บันทึก · ขาด $_tplMissing ช่อง'
                          : 'บันทึกคำสั่ง ($_tplCount)',
                      Icons.check_rounded,
                      _tplSave)
                  : _navBtn('ถัดไป', Icons.chevron_right_rounded,
                      () => setState(() => _tplSec++),
                      trailing: true),
            ),
          ]),
        ),
      ],
    );
  }

  /// บรรทัดที่ติ๊กแล้วแต่ยังไม่กรอกอัตรา ml/hr
  int get _tplMissing => [
        for (final b in _tplBlocks)
          for (var i = 0; i < b.lines.length; i++)
            if (b.lines[i].rate &&
                _tplLineOn(b, i) &&
                (_tplRate['${b.id}|$i']?.text ?? '').isEmpty)
              1
      ].length;

  void _tplSave() {
    if (_tplMissing > 0) {
      // ช่องอัตราอยู่ในรายการ: สลับไปมุมมองรายการให้กรอก
      setState(() => _tplPaper = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('ยังไม่กรอกอัตรา ml/hr $_tplMissing ช่อง',
              style: _t(12.0, color: Colors.white))));
      return;
    }
    final st = _SnakeState(_tplAns);
    _tplRounds.add((DateTime.now(), st.branch, st.recheckHr));
    setState(() {
      _tplSaved
        ..clear()
        ..addAll([
          for (final b in _tplBlocks)
            for (var i = 0; i < b.lines.length; i++)
              if (_tplLineOn(b, i))
                b.lines[i].rate &&
                        (_tplRate['${b.id}|$i']?.text ?? '').isNotEmpty
                    ? '${b.lines[i].text} ${_tplRate['${b.id}|$i']!.text} ml/hr'
                    : b.lines[i].text,
        ]);
      _tplOpen = null;
    });
  }

  // ---------------------------------------------------------------- ขวา

  /// แผงขวา: คำสั่งตามลำดับเอกสาร · หัวข้อที่เลือกกรองเฉพาะคำสั่งที่เกี่ยวข้อง
  Widget _tplOrders() {
    final secs = _tplNote;
    final summary = _tplSec >= secs.length;
    final secId = summary ? null : secs[_tplSec].id;
    final blocks = [
      for (final b in _tplBlocks)
        if (secId == null || b.sections.contains(secId)) b
    ];

    Widget line(_TplBlock b, int i) {
      final l = b.lines[i];
      final on = _tplLineOn(b, i);
      final key = '${b.id}|$i';
      return InkWell(
        onTap: () => setState(() => _tplTick[key] = !on),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
              crossAxisAlignment:
                  l.rate ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16.0,
                  height: 16.0,
                  margin: const EdgeInsets.only(top: 1.0, right: 9.0),
                  decoration: BoxDecoration(
                    color: on ? _blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(color: on ? _blue : _g5, width: 1.5),
                  ),
                  child: on
                      ? const Icon(Icons.check_rounded,
                          size: 12.0, color: Colors.white)
                      : null,
                ),
                Expanded(
                  child: Text(l.text,
                      style: _t(11.5,
                          color: on ? _inkTitle : _ink3,
                          weight: FontWeight.w600)),
                ),
                if (l.rate) ...[
                  const SizedBox(width: 8.0),
                  SizedBox(
                    width: 110.0,
                    child: TextField(
                      controller: _tplRate.putIfAbsent(
                          key, () => TextEditingController()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      // ให้ปุ่มบันทึกนับช่องที่ขาดใหม่
                      onChanged: (_) => setState(() {}),
                      textAlign: TextAlign.right,
                      style: _num(12.0, weight: FontWeight.w600),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'อัตรา',
                        hintStyle: _t(11.0, color: _ink3),
                        suffixText: 'ml/hr',
                        suffixStyle: _t(10.0, color: _ink3),
                        filled: true,
                        fillColor: _panelSoft,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 8.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ]),
        ),
      );
    }

    final children = <Widget>[];
    String? part;
    for (final b in blocks) {
      // หมายเหตุ antivenom ย้ายไปผูกใต้คำสั่ง antivenom แล้ว
      if (b.id == 'note_av') continue;
      if (b.part != part) {
        part = b.part;
        children.add(Padding(
          padding: EdgeInsets.only(top: children.isEmpty ? 0.0 : 14.0),
          child: Text(_tplParts[part]!,
              style: _t(10.0, color: _ink3, weight: FontWeight.w700)),
        ));
      }
      children.add(Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
        child: Text(b.title,
            style: _t(11.0, color: _ink2, weight: FontWeight.w700)),
      ));
      for (var i = 0; i < b.lines.length; i++) {
        children.add(line(b, i));
      }
      if (b.id == 'h11_av' || b.id == 'n_av') children.add(_tplAvSafety());
    }

    if (summary && _tplPaper) {
      return ListView(
        key: const PageStorageKey('tpl-paper'),
        padding: const EdgeInsets.all(12.0),
        children: [
          Row(children: [
            Expanded(
              child: Text('ตรวจทานแบบเอกสาร',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
            ),
            _tplViewToggle(),
          ]),
          const SizedBox(height: 8.0),
          _tplBranchCard(),
          _tplPaperView(),
        ],
      );
    }

    return ListView(
      key: PageStorageKey('tpl-orders-$_tplSec'),
      padding: const EdgeInsets.all(12.0),
      children: [
        if (summary)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
                alignment: Alignment.centerRight, child: _tplViewToggle()),
          ),
        _tplBranchCard(),
        Container(
          padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 10.0),
          decoration: _clyCardDeco,
          foregroundDecoration: const _InnerGloss(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          summary
                              ? 'คำสั่งทั้งหมด'
                              : 'คำสั่งที่เกี่ยวกับ ${secs[_tplSec].title}',
                          style: _t(13.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text('เลือก $_tplCount รายการ',
                      style: _t(9.5, color: _blue, weight: FontWeight.w700)),
                ),
              ]),
              const Divider(height: 18.0, color: _line),
              if (children.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('ยังไม่มีคำสั่งจากหัวข้อนี้ · ประเมินทางซ้ายก่อน',
                      style: _t(11.0, color: _ink3)),
                ),
              ...children,
            ],
          ),
        ),
      ],
    );
  }

  /// รายการ template ใต้ชิปประเภทผู้ป่วย (Order Set)
  /// Order Set ทั้งหมดเป็นการ์ด 2 คอลัมน์ (รูป · ชื่อ · ที่มา) · แตะเพื่อใช้
  /// ชุดติ๊กรายการ (inline) แสดงรายการด้านล่าง · standing order เข้าอีกชั้น
  Widget _tplPicker() {
    const icons = <String, IconData>{
      'ใช้บ่อย': Icons.star_rounded,
      'Sepsis': Icons.coronavirus_rounded,
      'Chest Pain': Icons.monitor_heart_rounded,
      'Stroke': Icons.psychology_rounded,
      'Trauma': Icons.personal_injury_rounded,
      'งูกัด': Icons.pest_control_rounded,
    };
    final sets = [
      for (final cat in _templates)
        for (final (id, title, src)
            in _orderTemplatesOf[cat] ?? [('inline', cat, '')])
          (cat, id, id == 'inline' ? cat : title, id == 'inline' ? '' : src),
    ];

    Widget card((String, String, String, String) s) {
      final (cat, id, title, src) = s;
      final on = id == 'inline' && cat == _template;
      return _Press(
        child: GestureDetector(
          onTap: () => id == 'inline'
              ? setState(() {
                  _template = cat;
                  _orderEditing = null;
                })
              : _tplEnter(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(12.0),
              border:
                  Border.all(color: on ? _blue : _line, width: on ? 1.5 : 1.0),
              boxShadow: on
                  ? [
                      BoxShadow(
                          color: _blue.withValues(alpha: 0.12),
                          blurRadius: 10.0,
                          offset: const Offset(0, 3)),
                    ]
                  : null,
            ),
            child: Row(children: [
              // รูปประจำ Order Set
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  gradient: on ? _glossGrad(_blue) : _glossWhite,
                  borderRadius: BorderRadius.circular(10.0),
                  border: on ? null : Border.all(color: _line),
                ),
                foregroundDecoration: _InnerGloss(10.0, dark: on),
                child: Icon(icons[cat] ?? Icons.description_rounded,
                    size: 22.0, color: on ? Colors.white : _blue),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _t(11.0,
                              color: _inkTitle,
                              weight: FontWeight.w700,
                              height: 1.2)),
                      if (src.isNotEmpty) ...[
                        const SizedBox(height: 2.0),
                        Text(src,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _t(9.0, color: _ink3, height: 1.2)),
                      ],
                    ]),
              ),
              if (on)
                const Icon(Icons.check_circle_rounded, size: 15.0, color: _blue)
              else if (id != 'inline')
                const Icon(Icons.chevron_right_rounded,
                    size: 16.0, color: _ink3),
            ]),
          ),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < sets.length; i += 2)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: card(sets[i])),
              const SizedBox(width: 8.0),
              Expanded(
                  child: i + 1 < sets.length
                      ? card(sets[i + 1])
                      : const SizedBox.shrink()),
            ]),
          ),
        ),
    ]);
  }
}
