// ignore_for_file: invalid_use_of_protected_member
part of '../er_flow_home_widget.dart';

/// ขนาดตัวอักษรของทั้งโมดูล ER (ตั้งค่าได้ S / M / L / XL) คูณเข้าไปใน _t และ _num
const List<(String, double)> _txtSizes = [
  ('S', 0.9),
  ('M', 1.0),
  ('L', 1.12),
  ('XL', 1.25),
];
double _txtScale = 1.0;
const String _txtKey = 'er_text_size';

/// ฟอนต์ของทั้งโมดูล ER (ตั้งค่าได้) · ฝังในแอปทั้งหมด ไม่โหลดจากเน็ต
/// (ชื่อที่แสดง, family, fallback สำหรับภาษาไทย)
const List<(String, String, List<String>)> _fontOpts = [
  ('Google Sans', 'GoogleSans', ['NotoSansThai']),
  ('Sarabun', 'Sarabun', <String>[]),
  ('IBM Plex Sans Thai', 'IBMPlexSansThaiLooped', <String>[]),
  ('Noto Sans Thai', 'NotoSansThai', <String>[]),
];
String _fontFam = 'GoogleSans';
List<String> get _fontFb => _fontOpts
    .firstWhere((f) => f.$2 == _fontFam, orElse: () => _fontOpts.first)
    .$3;
const String _fontKey = 'er_font_family';

/// แสดงการ์ด AI Overview บนภาพรวมผู้ป่วย (ปิดได้ในตั้งค่า) จำในเครื่อง
bool _aovOn = true;
const String _aovPrefKey = 'er_ai_overview';

extension _SidebarSidebarPart on _ErFlowHomeWidgetState {
  /// ชิปผู้ใช้ที่ login อยู่ มุมล่างซ้าย แตะเพื่อสลับบทบาท
  Widget _userChip() {
    final u = ErSession.instance.user;
    if (u == null) return const SizedBox.shrink();
    final nurse = u.role == ErRole.nurse;
    return _Press(
        child: Material(
      color: _panel,
      // flat: ขอบบางแทนเงา
      shape: const StadiumBorder(side: BorderSide(color: _line)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ErSession.instance.signOut();
          context.goNamed(ErLoginWidget.routeName);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 4.0, 12.0, 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 14.0, backgroundImage: AssetImage(u.face)),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(u.name,
                      style:
                          _t(10.5, color: _inkTitle, weight: FontWeight.w700)),
                  Text('${u.roleLabel} · ${u.shift}',
                      style: _t(8.5, color: nurse ? _blue : _blue)),
                ],
              ),
              const SizedBox(width: 6.0),
              const Icon(Icons.swap_horiz_rounded, size: 14.0, color: _ink3),
            ],
          ),
        ),
      ),
    ));
  }

  // ---------------------------------------------------------------- sidebar

  /// แถบซ้ายสุด เป็นรางไอคอนล้วน
  ///
  /// แท็บที่เลือกใช้สีเดียวกับแผงและไม่มีมุมโค้งด้านขวา
  /// จึงดูเชื่อมเป็นชิ้นเดียวกับแผงที่อยู่ติดกัน เหมือนแท็บที่ยื่นออกมา
  /// พื้นรางเป็นสีพื้นหน้า ไม่ใช่สีแผง ความต่างตรงนี้คือสิ่งที่ทำให้อ่านออก
  Widget _sideBar() => Container(
        // กว้างเท่ารางแท็บหน้าผู้ป่วย (100 + ขอบซ้าย 8)
        width: 108.0,
        color: _bg,
        child: Column(
          children: [
            // ไม่มีโลโก้ (ผู้ใช้ขอเอาออก) · เว้นบนให้มุมเว้า (fillet) ของแท็บแรกต่อกับแผงได้เนียน
            const SizedBox(height: 32.0),
            _sideTabs(),
            // ไม่มีส่วนปักหมุดผู้ป่วยแล้ว (ผู้ใช้ขอเอาออก)
            const Spacer(),
            const SizedBox(height: 8.0),
            // ค้นหาผู้ป่วย (ชื่อหรือ HN) เปิดได้จากทุกหน้า
            Tooltip(
              message: 'ค้นหาผู้ป่วย',
              child: _Press(
                child: Material(
                  color: _panel,
                  shape: const CircleBorder(side: BorderSide(color: _line)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _openPatientSearch,
                    child: SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(Icons.search_rounded,
                          size: 21.0, color: _blue),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // แจ้งเตือน (ย้ายจากหัวรายชื่อหน้าภาพรวม): เหนือปุ่มตั้งค่า
            Tooltip(
                message: 'แจ้งเตือน',
                child: _Press(
                    child: Transform.scale(
                        scale: 0.95, child: _alertBellButton()))),
            const SizedBox(height: 8.0),
            Tooltip(
              message: 'ตั้งค่า',
              child: _Press(
                child: Material(
                  color: _panel,
                  shape: const CircleBorder(
                      side: BorderSide(color: Color(0xFFDADCE0))),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _openSettings,
                    child: const SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: Icon(Icons.settings_outlined,
                          size: 20.0, color: _ink2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(_clock('10:24'), style: _num(13.0, weight: FontWeight.w600)),
            // เว้นที่ให้ชิปผู้ใช้ที่ลอยทับมุมล่างซ้าย
            const SizedBox(height: 54.0),
          ],
        ),
      );

  /// หน้าต่างค้นหาผู้ป่วย (ref command palette): แถบค้นหาลอยแยก + การ์ดผลลัพธ์
  /// ค้นได้จาก ชื่อ · HN · QN · เตียง · อาการสำคัญ/หมายเหตุ · การวินิจฉัย
  /// ยังไม่พิมพ์ = เปิดล่าสุด แล้วตามช่วงงาน · พิมพ์แล้ว = เรียงตามความตรง (HN/เตียง/QN ตรงเป๊ะก่อน)
  /// ลูกศรขึ้นลงเลือกแถว · Enter / แตะแถว = เปิดผู้ป่วย · ไม่พบ = ลงทะเบียนผู้ป่วยใหม่
  void _openPatientSearch() {
    final ctl = TextEditingController();
    var q = '';
    // แถวที่เลือก (ลูกศรขึ้นลง) · -1 = ยังไม่เลือก ไม่มีแถวไฮไลต์ตั้งต้น
    var sel = -1;
    _Phase? ph;
    // motion: รอบผลลัพธ์ (เปลี่ยนเมื่อชุดผลเปลี่ยน) ให้แถวเล่นเข้าใหม่
    var sig = '';
    var gen = 0;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ปิดค้นหา',
      barrierColor: const Color(0x590B1B3F),
      // ปรากฏนุ่ม: จาง + ขยายจาก 0.97 + ลอยขึ้น 8 px
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a, _, child) {
        final t = Curves.easeOutCubic.transform(a.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0.0, (1 - t) * 8.0),
            child: Transform.scale(scale: 0.97 + 0.03 * t, child: child),
          ),
        );
      },
      pageBuilder: (ctx, _, __) => StatefulBuilder(builder: (ctx, set) {
        final raw = q.trim();
        final key = raw.replaceAll(' ', '').toLowerCase();
        // คะแนนความตรง (น้อย = ตรงกว่า) + เหตุผลที่ตรง (ข้อมูลที่ไม่ได้โชว์อยู่แล้ว)
        (int, String?)? match(_P p) {
          if (key.isEmpty) return (0, null);
          final qn = _qn(p);
          final nm = p.name.replaceAll(' ', '').toLowerCase();
          final num = key.replaceFirst(RegExp(r'^qn'), '');
          if (p.hn == key || (p.bed?.toLowerCase() == key)) return (0, null);
          if (num.isNotEmpty &&
              RegExp(r'^\d+$').hasMatch(num) &&
              int.tryParse(num) == int.tryParse(qn)) return (0, null);
          // ชื่อขึ้นต้น (ข้ามคำนำหน้า นาย/นาง/นางสาว/ด.ช./ด.ญ.)
          final bare =
              nm.replaceFirst(RegExp(r'^(นางสาว|นาง|นาย|ด\.ช\.|ด\.ญ\.)'), '');
          if (bare.startsWith(key)) return (1, null);
          if (nm.contains(key)) return (2, null);
          if (p.hn.contains(key)) return (2, null);
          final c = erCases[p.hn];
          final clin = <String>[
            if (p.note.isNotEmpty) p.note,
            if (c != null) ...[c.cc, for (final d in c.dx) d.text],
          ];
          for (final t in clin) {
            if (t.replaceAll(' ', '').toLowerCase().contains(key)) {
              return (3, t.length > 46 ? '${t.substring(0, 46)}…' : t);
            }
          }
          return null;
        }

        final scored = <(_P, int, String?)>[
          for (final p in _patients)
            if (match(p) case final m?) (p, m.$1, m.$2)
        ]..sort((a, b) {
            if (a.$2 != b.$2) return a.$2 - b.$2;
            final e = (a.$1.esi?.level ?? 9).compareTo(b.$1.esi?.level ?? 9);
            return e != 0 ? e : b.$1.waitMin.compareTo(a.$1.waitMin);
          });
        final why = {for (final x in scored) x.$1.hn: x.$3};
        final found = [for (final x in scored) x.$1];
        int nOf(_Phase x) =>
            found.where((p) => x.stages.contains(p.stage)).length;
        bool inPh(_P p) => ph == null || ph!.stages.contains(p.stage);
        // ยังไม่พิมพ์: เปิดล่าสุด (สูงสุด 4) + ตามช่วงงาน · พิมพ์แล้ว: ผลการค้นหารวมเดียว
        final recent = key.isEmpty
            ? [
                for (final hn in _searchRecent)
                  for (final p in _patients)
                    if (p.hn == hn && inPh(p)) p
              ].take(4).toList()
            : <_P>[];
        final shown = <(String, List<_P>)>[
          if (recent.isNotEmpty) ('เปิดล่าสุด', recent),
          if (key.isEmpty)
            for (final x in _Phase.values)
              if (ph == null || ph == x)
                (
                  x.label,
                  [
                    for (final p in found)
                      if (x.stages.contains(p.stage) && !recent.contains(p)) p
                  ]
                ),
          if (key.isNotEmpty)
            (
              'ผลการค้นหา',
              [
                for (final p in found)
                  if (inPh(p)) p
              ]
            ),
        ].where((g) => g.$2.isNotEmpty).toList();
        final flat = [for (final g in shown) ...g.$2];
        final nsig = [for (final p in flat) p.hn].join(',');
        if (nsig != sig) {
          sig = nsig;
          gen++;
        }
        if (sel >= flat.length) sel = -1;
        final cur = sel < 0 ? null : flat[sel];
        void open(_P p) {
          _searchRecent
            ..remove(p.hn)
            ..insert(0, p.hn);
          Navigator.of(ctx).pop();
          _openPatient(p);
        }

        // ชื่อ: ส่วนที่ตรงคำค้นมีพื้นเทาอ่อน (แบบ ref)
        Widget name(_P p) {
          final st = _t(14.5, color: _inkTitle, weight: FontWeight.w600);
          final i = raw.isEmpty ? -1 : p.name.indexOf(raw);
          if (i < 0) return Text(p.name, style: st);
          return Text.rich(TextSpan(style: st, children: [
            TextSpan(text: p.name.substring(0, i)),
            TextSpan(
                text: p.name.substring(i, i + raw.length),
                style: st.copyWith(backgroundColor: const Color(0xFFE3E6EC))),
            TextSpan(text: p.name.substring(i + raw.length)),
          ]));
        }

        Widget tag(String t, Color c, Color bg) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(4.0)),
              child:
                  Text(t, style: _t(11.0, color: c, weight: FontWeight.w600)),
            );

        Widget row(_P p) {
          final on = identical(p, cur);
          final w = p.waitMin >= 60
              ? '${p.waitMin ~/ 60} ชม. ${p.waitMin % 60} นาที'
              : '${p.waitMin} นาที';
          final reason = why[p.hn];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: () => open(p),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: FittedBox(child: _rowAvatar(p))),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Flexible(child: name(p)),
                              const SizedBox(width: 6.0),
                              tag(p.stage.label, _ink2,
                                  const Color(0xFFF1F3F6)),
                              const SizedBox(width: 4.0),
                              tag('อยู่ ER $w', _ink2, const Color(0xFFF1F3F6)),
                            ]),
                            const SizedBox(height: 2.0),
                            Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                      text: [
                                    'HN ${p.hn}',
                                    'QN ${_qn(p)}',
                                    if (p.bed != null) 'เตียง ${p.bed}',
                                  ].join('  ')),
                                  if (reason != null)
                                    TextSpan(
                                        text: '  ตรงกับ $reason',
                                        style: _t(12.0,
                                            color: _blue,
                                            weight: FontWeight.w500))
                                  else if (p.note.isNotEmpty)
                                    TextSpan(text: '  ${p.note}'),
                                ]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.0,
                                    color: _ink3, weight: FontWeight.w500)),
                          ]),
                    ),
                    if (on) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        width: 30.0,
                        height: 30.0,
                        decoration: BoxDecoration(
                            color: _blue,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: const Icon(Icons.chevron_right_rounded,
                            size: 20.0, color: Colors.white),
                      ),
                    ],
                  ]),
                ),
              ),
            ),
          );
        }

        Widget chip(
                IconData ic, String label, int? n, bool on, VoidCallback tap) =>
            GestureDetector(
              onTap: tap,
              child: Container(
                height: 30.0,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: on ? _blue : _panel,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: on ? _blue : _line),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(ic, size: 15.0, color: on ? Colors.white : _ink2),
                  const SizedBox(width: 5.0),
                  Text(label,
                      style: _t(12.5,
                          color: on ? Colors.white : _inkTitle,
                          weight: FontWeight.w600)),
                  if (n != null) ...[
                    const SizedBox(width: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                          // ชิปที่เลือก: ตัวเลขอยู่ในกล่องขาว
                          color: on ? Colors.white : null,
                          border: Border.all(color: on ? Colors.white : _line),
                          borderRadius: BorderRadius.circular(4.0)),
                      child: Text('$n',
                          style: _num(11.0,
                              color: on ? _blue : _ink2,
                              weight: FontWeight.w700)),
                    ),
                  ],
                ]),
              ),
            );

        BoxDecoration card() => BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(18.0),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x1F0B1B3F),
                    blurRadius: 30.0,
                    offset: Offset(0.0, 10.0)),
              ],
            );

        // แถบค้นหาตรึงที่เดิมเสมอ (ไม่ถูกคีย์บอร์ดดัน): ตำแหน่งกลางจอของกล่องเต็ม
        // คีย์บอร์ดขึ้น = กล่องผลลัพธ์เตี้ยลงพอดีพื้นที่เหนือคีย์บอร์ด
        final kb = MediaQuery.of(ctx).viewInsets.bottom;
        final scrH = MediaQuery.of(ctx).size.height;
        final top = math.max(16.0, (scrH - 542.0) / 2);
        final listMax =
            (scrH - kb - top - 52.0 - 10.0 - 16.0).clamp(120.0, 480.0);
        return MediaQuery.removeViewInsets(
          context: ctx,
          removeBottom: true,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.topCenter,
              child: Material(
                type: MaterialType.transparency,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600.0),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.0, top, 24.0, 16.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      // ---- แถบค้นหา (ลอยแยก)
                      Container(
                        height: 52.0,
                        padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                        decoration: card(),
                        child: Row(children: [
                          const Icon(Icons.search_rounded,
                              size: 22.0, color: _blue),
                          const SizedBox(width: 10.0),
                          Expanded(
                            // ลูกศรขึ้นลง (คีย์บอร์ด iPad) เลื่อนแถวที่เลือก
                            child: Focus(
                              onKeyEvent: (_, e) {
                                if (e is KeyUpEvent)
                                  return KeyEventResult.ignored;
                                if (e.logicalKey ==
                                        LogicalKeyboardKey.arrowDown &&
                                    flat.isNotEmpty) {
                                  set(() => sel = (sel + 1) % flat.length);
                                  return KeyEventResult.handled;
                                }
                                if (e.logicalKey ==
                                        LogicalKeyboardKey.arrowUp &&
                                    flat.isNotEmpty) {
                                  set(() => sel =
                                      sel <= 0 ? flat.length - 1 : sel - 1);
                                  return KeyEventResult.handled;
                                }
                                return KeyEventResult.ignored;
                              },
                              child: TextField(
                                controller: ctl,
                                autofocus: true,
                                onChanged: (v) => set(() {
                                  q = v;
                                  sel = -1;
                                }),
                                onSubmitted: (_) {
                                  // Enter: แถวที่เลือก หรือผลแรกเมื่อพิมพ์ค้นหา
                                  final t = cur ??
                                      (key.isNotEmpty && flat.isNotEmpty
                                          ? flat.first
                                          : null);
                                  if (t != null) open(t);
                                },
                                style: _t(15.0,
                                    color: _inkTitle, weight: FontWeight.w500),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'ค้นหาชื่อ HN QN เตียง หรืออาการ',
                                  hintStyle: _t(15.0,
                                      color: _ink3, weight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'ปิด',
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close_rounded,
                                size: 20.0, color: _ink2),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10.0),
                      // ---- ผลลัพธ์
                      Flexible(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: Container(
                            constraints: BoxConstraints(maxHeight: listMax),
                            decoration: card(),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 14.0, 16.0, 6.0),
                                    child: Row(children: [
                                      chip(
                                          Icons.groups_rounded,
                                          'ทั้งหมด',
                                          found.length,
                                          ph == null,
                                          () => set(() {
                                                ph = null;
                                                sel = -1;
                                              })),
                                      for (final x in _Phase.values) ...[
                                        const SizedBox(width: 6.0),
                                        chip(
                                            _phaseIcon(x),
                                            x.label,
                                            nOf(x),
                                            ph == x,
                                            () => set(() {
                                                  ph = ph == x ? null : x;
                                                  sel = -1;
                                                })),
                                      ],
                                    ]),
                                  ),
                                  Flexible(
                                    child: shown.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                16.0, 14.0, 16.0, 18.0),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      raw.isEmpty
                                                          ? 'ไม่มีผู้ป่วยในช่วงงานนี้'
                                                          : 'ไม่พบผู้ป่วยในห้องฉุกเฉินที่ตรงกับ "$raw"',
                                                      style: _t(14.0,
                                                          color: _ink2,
                                                          weight:
                                                              FontWeight.w500)),
                                                  if (raw.isNotEmpty) ...[
                                                    const SizedBox(
                                                        height: 12.0),
                                                    // ผู้ป่วยมาใหม่ยังไม่อยู่ในระบบ ER: ลงทะเบียนต่อได้เลย
                                                    FilledButton.icon(
                                                      style: FilledButton.styleFrom(
                                                          backgroundColor:
                                                              _blue,
                                                          shape:
                                                              const StadiumBorder()),
                                                      onPressed: () {
                                                        Navigator.of(ctx).pop();
                                                        _openRegister();
                                                      },
                                                      icon: const Icon(
                                                          Icons
                                                              .person_add_alt_1_rounded,
                                                          size: 18.0),
                                                      label: Text(
                                                          'ส่งตรวจและคัดกรองผู้ป่วยใหม่',
                                                          style: _t(13.5,
                                                              color:
                                                                  Colors.white,
                                                              weight: FontWeight
                                                                  .w600)),
                                                    ),
                                                  ],
                                                ]),
                                          )
                                        : ListView(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0),
                                            children: [
                                              for (final (i, (title, ps))
                                                  in shown.indexed) ...[
                                                if (i > 0)
                                                  Container(
                                                      height: 0.5,
                                                      margin: const EdgeInsets
                                                          .fromLTRB(
                                                          16.0, 8.0, 16.0, 0.0),
                                                      color: _line),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          16.0,
                                                          10.0,
                                                          16.0,
                                                          4.0),
                                                  child: Row(children: [
                                                    Icon(
                                                        switch (title) {
                                                          'เปิดล่าสุด' => Icons
                                                              .history_rounded,
                                                          'ผลการค้นหา' => Icons
                                                              .search_rounded,
                                                          _ => _phaseIcon(_Phase
                                                              .values
                                                              .firstWhere((x) =>
                                                                  x.label ==
                                                                  title)),
                                                        },
                                                        size: 14.0,
                                                        color: _ink3),
                                                    const SizedBox(width: 6.0),
                                                    Text(title,
                                                        style: _t(12.5,
                                                            color: _ink3,
                                                            weight: FontWeight
                                                                .w600)),
                                                  ]),
                                                ),
                                                for (final p in ps)
                                                  _SearchRowIn(
                                                    // ชุดผลใหม่ = เล่นเข้าใหม่ · ไล่ทีละแถว (สูงสุด 8 แถวแรก)
                                                    key: ValueKey(
                                                        '${p.hn}|$gen'),
                                                    delay: math.min(
                                                        flat.indexOf(p), 8),
                                                    selected: identical(p, cur),
                                                    // ชุดแรกตอนเปิดไม่เล่น (genie จับภาพแถวครบ)
                                                    animate: gen > 1,
                                                    child: row(p),
                                                  ),
                                              ],
                                            ],
                                          ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ).whenComplete(
        () => Future.delayed(const Duration(milliseconds: 600), ctl.dispose));
  }

  /// อ่านขนาดตัวอักษรที่ตั้งไว้ (เรียกตอนเปิดหน้า พร้อมโหลดหมุด)
  void _loadTextSize(SharedPreferences p) {
    final v = p.getDouble(_txtKey);
    if (v != null && v != _txtScale && mounted) setState(() => _txtScale = v);
    final f = p.getString(_fontKey);
    if (f != null &&
        f != _fontFam &&
        _fontOpts.any((o) => o.$2 == f) &&
        mounted) {
      setState(() => _fontFam = f);
    }
    final a = p.getBool(_aovPrefKey);
    if (a != null && a != _aovOn && mounted) setState(() => _aovOn = a);
    final cvd = p.getBool(_cvdKey);
    if (cvd != null && cvd != _cvd && mounted) setState(() => _cvd = cvd);
  }

  void _setCvd(bool v) {
    HapticFeedback.selectionClick();
    setState(() => _cvd = v);
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_cvdKey, v))
        .catchError((_) => true);
  }

  void _setAov(bool v) {
    HapticFeedback.selectionClick();
    setState(() => _aovOn = v);
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_aovPrefKey, v))
        .catchError((_) => true);
  }

  void _setFont(String family) {
    HapticFeedback.selectionClick();
    setState(() => _fontFam = family);
    SharedPreferences.getInstance()
        .then((p) => p.setString(_fontKey, family))
        .catchError((_) => true);
  }

  void _setTextSize(double v) {
    HapticFeedback.selectionClick();
    setState(() => _txtScale = v);
    SharedPreferences.getInstance()
        .then((p) => p.setDouble(_txtKey, v))
        .catchError((_) => true);
  }

  /// หน้าตั้งค่าแบบเต็มหน้า: เมนูซ้าย (การแสดงผล · Standing order) เนื้อหาขวา
  void _openSettings() {
    var tab = 0;
    var cur = _soDocs.containsKey(_template) ? _template : _soDocs.keys.first;
    final changed = <String>{};
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (ctx, a, _, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(begin: const Offset(0.0, 0.03), end: Offset.zero)
              .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      pageBuilder: (ctx, _, __) => StatefulBuilder(
        builder: (ctx, set) {
          Widget menu(int i, IconData icon, String t, String sub) {
            final on = tab == i;
            return GestureDetector(
              onTap: () => set(() => tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(bottom: 6.0),
                padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                decoration: BoxDecoration(
                  color: on ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(children: [
                  Icon(icon, size: 18.0, color: on ? Colors.white : _ink2),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t,
                            style: _t(13.0,
                                color: on ? Colors.white : _inkTitle,
                                weight: FontWeight.w600)),
                        Text(sub,
                            style: _t(10.5,
                                color: on ? const Color(0xCCFFFFFF) : _ink3,
                                weight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ]),
              ),
            );
          }

          final ai = Padding(
            padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
            child: SizedBox(
              width: 460.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ผู้ช่วย AI',
                      style:
                          _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 4.0),
                  Text('AI ช่วยสรุปและแนะนำ ผู้ใช้ตรวจทานและยืนยันเสมอ',
                      style: _t(12.0, color: _ink3)),
                  const SizedBox(height: 16.0),
                  // เปิด/ปิด AI Overview บนหน้าภาพรวมผู้ป่วย
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 10.0),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFDADCE0)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 20.0, color: _blue),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Overview',
                                  style: _t(14.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w600)),
                              Text('สรุปเคสด้วย AI บนหน้าภาพรวมผู้ป่วย',
                                  style: _t(12.0, color: _ink3)),
                            ]),
                      ),
                      Switch(
                        value: _aovOn,
                        activeThumbColor: Colors.white,
                        activeTrackColor: _blue,
                        onChanged: (v) => set(() => _setAov(v)),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          );

          // โปรไฟล์ผู้ใช้ที่ login อยู่ (ผู้ใช้จำลอง ไม่ใช่ Provider ID จริง)
          final me = ErSession.instance.user;
          Widget infoRow(String k, String v, {bool first = false}) =>
              Column(mainAxisSize: MainAxisSize.min, children: [
                if (!first)
                  const Divider(
                      height: 1.0, thickness: 0.5, color: Color(0xFFDADCE0)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Row(children: [
                    SizedBox(
                      width: 140.0,
                      child: Text(k,
                          style:
                              _t(14.0, color: _ink2, weight: FontWeight.w500)),
                    ),
                    Expanded(
                      child: Text(v,
                          style: _t(14.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ),
                  ]),
                ),
              ]);
          final profile = Padding(
            padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
            child: SizedBox(
              width: 460.0,
              child: me == null
                  ? Text('ยังไม่ได้เข้าสู่ระบบ',
                      style: _t(14.0, color: _ink3, weight: FontWeight.w500))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('โปรไฟล์',
                            style: _t(17.0,
                                color: _inkTitle, weight: FontWeight.w700)),
                        const SizedBox(height: 4.0),
                        Text('ผู้ใช้ที่เข้าสู่ระบบอยู่ในเครื่องนี้',
                            style: _t(12.0, color: _ink3)),
                        const SizedBox(height: 16.0),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 6.0),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                                color: const Color(0xFFDADCE0), width: 0.5),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 72.0,
                                    height: 72.0,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFDCE6F5)),
                                    child: Transform.scale(
                                      scale: 1.35,
                                      alignment: const Alignment(0.0, -0.55),
                                      child: Image.asset(me.face,
                                          width: 72.0,
                                          height: 72.0,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(me.name,
                                              style: _t(20.0,
                                                  color: _inkTitle,
                                                  weight: FontWeight.w700)),
                                          const SizedBox(height: 2.0),
                                          Text(me.roleLabel,
                                              style: _t(14.0,
                                                  color: _blue,
                                                  weight: FontWeight.w600)),
                                        ]),
                                  ),
                                ]),
                                const SizedBox(height: 16.0),
                                infoRow('รหัสเจ้าหน้าที่', me.id, first: true),
                                infoRow('ตำแหน่ง',
                                    me.position.replaceAll(' · ', ' ')),
                                infoRow('เวร', '${me.shift} น.'),
                                infoRow('หน่วยงาน', 'ห้องฉุกเฉิน (ER)'),
                              ]),
                        ),
                        const SizedBox(height: 16.0),
                        // เปลี่ยนผู้ใช้: ออกจากระบบแล้วกลับหน้าเลือกบทบาท
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ErSession.instance.signOut();
                              context.goNamed(ErLoginWidget.routeName);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: _red,
                              backgroundColor: _red.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              minimumSize: const Size(0.0, 48.0),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 20.0),
                            label: Text('ออกจากระบบ',
                                style: _t(14.0,
                                    color: _red, weight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
            ),
          );

          // เครดิตงานที่ใช้ (CC BY 4.0 ต้องระบุที่มา · MIT ใส่ไว้ให้เกียรติ)
          Widget credit(String name, String by, String use, String url,
                  {String license = 'CC BY 4.0'}) =>
              Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFDADCE0)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(name,
                              style: _t(14.0,
                                  color: _inkTitle, weight: FontWeight.w600)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EEF8),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(license,
                              style: _t(11.0,
                                  color: _blue, weight: FontWeight.w700)),
                        ),
                      ]),
                      const SizedBox(height: 2.0),
                      Text(by, style: _t(12.0, color: _ink2)),
                      const SizedBox(height: 6.0),
                      Text(use, style: _t(12.0, color: _ink3)),
                      const SizedBox(height: 4.0),
                      SelectableText(url,
                          style:
                              _t(12.0, color: _blue, weight: FontWeight.w500)),
                    ]),
              );
          final credits = Padding(
            padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
            child: SizedBox(
              width: 460.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('เครดิต',
                      style:
                          _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 4.0),
                  Text('ไอคอนและข้อมูลภาพที่ใช้ในโมดูล ER',
                      style: _t(12.0, color: _ink3)),
                  const SizedBox(height: 16.0),
                  credit(
                      'Phosphor Icons',
                      'โดย Helena Zhang และ Tobias Fried (MIT)',
                      'ไอคอนรางเมนูซ้าย รางขั้น workflow และแผ่นปุ่มลัดการ์ดวินิจฉัย',
                      'https://phosphoricons.com',
                      license: 'MIT'),
                  credit(
                      'BodyParts3D',
                      'โดย The Database Center for Life Science',
                      'ภาพแผนที่ร่างกายในหน้าตรวจร่างกาย',
                      'https://dbarchive.biosciencedbc.jp/en/bodyparts3d/'),
                ],
              ),
            ),
          );
          final display = Padding(
            padding: const EdgeInsets.fromLTRB(28.0, 24.0, 28.0, 20.0),
            child: SizedBox(
              width: 720.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('การแสดงผล',
                      style:
                          _t(17.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(height: 16.0),
                  Text('ขนาดตัวอักษร',
                      style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(children: [
                      for (final (label, v) in _txtSizes) ...[
                        if (label != _txtSizes.first.$1)
                          const SizedBox(width: 8.0),
                        Expanded(
                          child: _Press(
                            child: GestureDetector(
                              onTap: () => set(() => _setTextSize(v)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                height: 64.0,
                                decoration: BoxDecoration(
                                  gradient: _txtScale == v
                                      ? _glossGrad(_blue)
                                      : _glossWhite,
                                  borderRadius: BorderRadius.circular(14.0),
                                  border: Border.all(
                                      color: _txtScale == v ? _blue : _line),
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // ตัวอย่างขนาดจริง ไม่คูณ scale ปัจจุบัน
                                      Text('ก',
                                          style: TextStyle(
                                              fontFamily: _fontFam,
                                              fontFamilyFallback: _fontFb,
                                              fontSize: 16.0 * v,
                                              height: 1.1,
                                              fontWeight: FontWeight.w600,
                                              color: _txtScale == v
                                                  ? Colors.white
                                                  : _inkTitle)),
                                      Text(label,
                                          style: TextStyle(
                                              fontFamily: _fontFam,
                                              fontFamilyFallback: _fontFb,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w600,
                                              color: _txtScale == v
                                                  ? Colors.white
                                                  : _ink3)),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 12.0),
                  Text('ตัวอย่าง: ผู้ป่วยแน่นหน้าอก 2 ชั่วโมงก่อนมา รพ.',
                      style: _t(12.0, color: _inkTitle)),
                  const SizedBox(height: 24.0),
                  // โหมดตาบอดสี: แถวสวิตช์แบบ AI Overview + ตัวอย่างสีที่จะเปลี่ยน
                  Text('สี',
                      style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 8.0, 10.0),
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFDADCE0)),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('โหมดตาบอดสี',
                                  style: _t(14.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w600)),
                              Text(
                                  'เปลี่ยนสีแดง เขียว และสีระดับ ESI เป็นชุดที่แยกกันได้ชัด',
                                  style: _t(12.0, color: _ink3)),
                              const SizedBox(height: 8.0),
                              // ตัวอย่างสี ESI 1-5 ตามโหมดปัจจุบัน
                              Row(children: [
                                for (final e in _Esi.values) ...[
                                  Container(
                                    width: 22.0,
                                    height: 22.0,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: e.color,
                                        borderRadius:
                                            BorderRadius.circular(6.0)),
                                    child: Text('${e.level}',
                                        style: _t(11.0,
                                            color: Colors.white,
                                            weight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 6.0),
                                ],
                                const SizedBox(width: 6.0),
                                Text('ผิดปกติ',
                                    style: _t(12.0,
                                        color: _red, weight: FontWeight.w700)),
                                const SizedBox(width: 10.0),
                                Text('ปกติ',
                                    style: _t(12.0,
                                        color: _green,
                                        weight: FontWeight.w700)),
                              ]),
                            ]),
                      ),
                      Switch(
                        value: _cvd,
                        activeThumbColor: Colors.white,
                        activeTrackColor: _blue,
                        onChanged: (v) => set(() => _setCvd(v)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24.0),
                  // ฟอนต์: แถวละฟอนต์ (แบบรายการตั้งค่า) ชื่อ + ตัวอย่างไทย/อังกฤษ/ตัวเลข ด้วยฟอนต์นั้นจริง
                  Text('ฟอนต์',
                      style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: const Color(0xFFDADCE0)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      for (final (i, (name, fam, fb)) in _fontOpts.indexed) ...[
                        if (i > 0)
                          const Divider(
                              height: 1.0,
                              thickness: 1.0,
                              color: Color(0xFFE8EAED)),
                        InkWell(
                          onTap: () => set(() => _setFont(fam)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 12.0, 12.0, 12.0),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // แบบหน้า Google Fonts: ชื่อเล็กสีเทา · ประโยคตัวอย่างตัวใหญ่ด้วยฟอนต์นั้น
                                      Text(name,
                                          style: _t(12.0,
                                              color: _ink3,
                                              weight: FontWeight.w500)),
                                      const SizedBox(height: 4.0),
                                      Text(
                                          'มนุษย์ทั้งหลายเกิดมามีอิสระและเสมอภาคกันในเกียรติศักดิ์และสิทธิ',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: fam,
                                              fontFamilyFallback: fb,
                                              fontSize: 22.0 * _txtScale,
                                              height: 1.35,
                                              fontWeight: FontWeight.w500,
                                              color: _inkTitle)),
                                    ]),
                              ),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 160),
                                opacity: _fontFam == fam ? 1.0 : 0.0,
                                child: const Icon(Icons.check_rounded,
                                    size: 22.0, color: _blue),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ],
              ),
            ),
          );
          return Material(
            color: _panelSoft,
            child: SafeArea(
              child: Column(children: [
                // แถบบน: ปิด + ชื่อหน้า
                Container(
                  height: 56.0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: const BoxDecoration(
                    color: _panel,
                    border: Border(bottom: BorderSide(color: _line)),
                  ),
                  child: Row(children: [
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      tooltip: 'ปิด',
                      icon: const Icon(Icons.arrow_back_rounded,
                          size: 22.0, color: _inkTitle),
                    ),
                    const SizedBox(width: 4.0),
                    Text('ตั้งค่า',
                        style: _t(16.0,
                            color: _inkTitle, weight: FontWeight.w700)),
                  ]),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 250.0,
                        padding: const EdgeInsets.all(12.0),
                        decoration: const BoxDecoration(
                          color: _panel,
                          border: Border(right: BorderSide(color: _line)),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // หมวดหมู่ตั้งค่า: ทั่วไป · AI · ทางคลินิก
                              for (final (h, items) in [
                                (
                                  'บัญชี',
                                  [
                                    (
                                      4,
                                      Icons.person_outline_rounded,
                                      'โปรไฟล์',
                                      me?.name ?? 'ผู้ใช้'
                                    ),
                                  ]
                                ),
                                (
                                  'ทั่วไป',
                                  [
                                    (
                                      0,
                                      Icons.text_fields_rounded,
                                      'การแสดงผล',
                                      'ขนาดตัวอักษร'
                                    ),
                                  ]
                                ),
                                (
                                  'AI',
                                  [
                                    (
                                      2,
                                      Icons.auto_awesome_rounded,
                                      'ผู้ช่วย AI',
                                      'AI Overview'
                                    ),
                                  ]
                                ),
                                (
                                  'ทางคลินิก',
                                  [
                                    (
                                      1,
                                      Icons.account_tree_outlined,
                                      'Standing order',
                                      'จำแนกหมวดแต่ละบรรทัดในใบ'
                                    ),
                                  ]
                                ),
                                (
                                  'เกี่ยวกับ',
                                  [
                                    (
                                      3,
                                      Icons.info_outline_rounded,
                                      'เครดิต',
                                      'ไอคอนและภาพประกอบ'
                                    ),
                                  ]
                                ),
                              ]) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 14.0, 10.0, 6.0),
                                  child: Text(h,
                                      style: _t(11.0,
                                          color: _ink3,
                                          weight: FontWeight.w700)),
                                ),
                                for (final (i, ic, t, sub) in items)
                                  menu(i, ic, t, sub),
                              ],
                            ]),
                      ),
                      Expanded(
                        child: switch (tab) {
                          0 => SingleChildScrollView(
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: display)),
                          2 => Align(alignment: Alignment.topLeft, child: ai),
                          4 => SingleChildScrollView(
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: profile)),
                          3 => SingleChildScrollView(
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: credits)),
                          _ => _soStructView(cur, (k) => cur = k, changed, set),
                        },
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  /// ไอคอนประจำช่วงงาน
  IconData _phaseIcon(_Phase phase) {
    switch (phase) {
      case _Phase.triage:
        return Icons.fact_check_rounded;
      case _Phase.treatment:
        return Icons.medical_services_rounded;
      case _Phase.after:
        return Icons.logout_rounded;
      case _Phase.observe:
        return Icons.visibility_rounded;
    }
  }

  /// ปุ่มหนึ่งใบในรางไอคอน
  ///
  /// ใบที่เลือกกินเต็มความกว้างราง โค้งเฉพาะด้านซ้าย ขอบขวาชนแผงพอดี
  /// ใบที่ไม่ได้เลือกเป็นสี่เหลี่ยมมุมมนลอยอยู่กลางราง
  /// ไอคอนเส้นของแท็บที่ไม่ได้เลือก (แบบรางแท็บหน้าผู้ป่วย: ไม่เลือก = เส้น · เลือก = ทึบ)
  IconData _sideOutline(IconData filled) => switch (filled) {
        Icons.dashboard_rounded => Icons.dashboard_outlined,
        Icons.fact_check_rounded => Icons.fact_check_outlined,
        Icons.medical_services_rounded => Icons.medical_services_outlined,
        Icons.visibility_rounded => Icons.visibility_outlined,
        _ => filled,
      };

  /// รางแท็บซ้ายแบบรางแท็บหน้าผู้ป่วย / หน้าส่งตรวจ: ไอคอน + ชื่อ
  /// ที่เลือก = แผ่นสีแผง (กรมท่า) เลื่อนไปหา ต่อกับแผงข้าง ๆ มีมุมเว้าบน/ล่าง
  Widget _sideTabs() {
    const tabH = 72.0, gap = 4.0, slide = Duration(milliseconds: 260);
    final tabs = <(IconData, IconData, String, _Phase?)>[
      (Icons.dashboard_outlined, Icons.dashboard_rounded, 'ภาพรวม', null),
      for (final ph in _Phase.values)
        (_sideOutline(_phaseIcon(ph)), _phaseIcon(ph), ph.label, ph),
    ];
    final onIdx = tabs.indexWhere((t) => t.$4 == _open);

    // มุมเว้าตรงรอยต่อแท็บกับแผง (สีแผงเติมมุม สีพื้นรางเจาะโค้ง)
    Widget fillet({required bool top}) => SizedBox(
          width: 16.0,
          height: 16.0,
          child: ColoredBox(
            color: _pBg,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: top
                    ? const BorderRadius.only(
                        bottomRight: Radius.circular(16.0))
                    : const BorderRadius.only(topRight: Radius.circular(16.0)),
              ),
            ),
          ),
        );

    Widget item(int i) {
      final (outline, filled, label, phase) = tabs[i];
      final on = i == onIdx;
      return _Press(
        radius: 16.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() {
              _open = phase;
              _detail = false;
              _zoom = null;
            });
            _simulateLoad(const Duration(milliseconds: 500));
          },
          child: SizedBox(
            height: tabH,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(on ? filled : outline,
                  size: 24.0, color: on ? Colors.white : _ink3),
              const SizedBox(height: 4.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: slide,
                    style: _t(10.5,
                        color: on ? Colors.white : _ink3,
                        weight: on ? FontWeight.w700 : FontWeight.w500),
                    child: Text(label, maxLines: 1),
                  ),
                ),
              ),
            ]),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Stack(clipBehavior: Clip.none, children: [
        if (onIdx >= 0)
          AnimatedPositioned(
            duration: slide,
            curve: Curves.easeOutCubic,
            top: onIdx * (tabH + gap),
            left: 0.0,
            right: 0.0,
            height: tabH,
            child: IgnorePointer(
              child: Stack(clipBehavior: Clip.none, children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _pBg,
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(16.0)),
                    ),
                  ),
                ),
                Positioned(right: 0.0, top: -16.0, child: fillet(top: true)),
                Positioned(
                    right: 0.0, bottom: -16.0, child: fillet(top: false)),
              ]),
            ),
          ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < tabs.length; i++) ...[
            item(i),
            if (i < tabs.length - 1) const SizedBox(height: gap),
          ],
        ]),
      ]),
    );
  }
}

/// HN ผู้ป่วยที่เปิดจากหน้าค้นหาล่าสุด (ใหม่ก่อน) · โชว์ตอนยังไม่พิมพ์
final List<String> _searchRecent = [];

/// แถวผลค้นหา: เข้าด้วยจางขึ้น + เลื่อนขึ้น 6 px ไล่ทีละแถว · พื้นแถวที่เลือกเปลี่ยนแบบนุ่ม
class _SearchRowIn extends StatelessWidget {
  const _SearchRowIn(
      {super.key,
      required this.delay,
      required this.selected,
      this.animate = true,
      required this.child});
  final int delay;
  final bool animate;
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const step = 28, run = 220;
    final total = run + delay * step;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0.0 : 1.0, end: 1.0),
      duration: Duration(milliseconds: total),
      builder: (context, t, c) {
        final v = Curves.easeOutCubic
            .transform(((t * total - delay * step) / run).clamp(0.0, 1.0));
        return Opacity(
          opacity: v,
          child: Transform.translate(
              offset: Offset(0.0, (1.0 - v) * 6.0), child: c),
        );
      },
      child: Stack(children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFF1F3F6)
                    : const Color(0x00F1F3F6),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        child,
      ]),
    );
  }
}
