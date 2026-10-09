// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

String _clockWait(int m) => m >= 60 ? '${m ~/ 60} ชม. ${m % 60} น.' : '$m นาที';

/// นาฬิกาจำลองของฉาก (ข้อมูล mock อิงเวลานี้)
const String _simNow = '10:25';
int _minutesSince(String hhmm) {
  int toMin(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  return (toMin(_simNow) - toMin(hhmm)).clamp(0, 24 * 60);
}

/// เวลาแบบสัมพัทธ์ของเวลาวัด (hh:mm) เช่น "3 นาทีที่แล้ว"
/// ข้อมูล mock อิงนาฬิกาจำลอง · ค่าที่บันทึกจริงหลังเวลาจำลองอิงนาฬิกาเครื่อง
String _ago(String hhmm) {
  int toMin(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  if (hhmm.isEmpty) return '';
  final now = DateTime.now();
  final real = now.hour * 60 + now.minute;
  final t = toMin(hhmm);
  final ref = t > toMin(_simNow) ? real : toMin(_simNow);
  final m = (ref - t).clamp(0, 24 * 60);
  if (m < 1) return 'เมื่อสักครู่';
  if (m < 60) return '$m นาทีที่แล้ว';
  // ชั่วโมงขึ้นไป: สั้นพอให้อยู่ในหัวการ์ดเล็ก
  return '${m ~/ 60} ชม.ที่แล้ว';
}

extension _FeaturesPatientPatientHeaderPart on _ErFlowHomeWidgetState {
  Widget _detailTopBar() {
    final p = _sceneSelected(_open!);
    final c = erCaseOf(p.hn);
    // แบบ ClyHealth: ซ้าย = กลับ + ชื่อ · กลาง = กลุ่มแท็บแบบเม็ดยา · ขวา = ปุ่มไอคอน
    return Container(
      height: _clyOn ? 58.0 : 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      decoration: BoxDecoration(
        color: _panel,
        border: _clyOn ? const Border(bottom: BorderSide(color: _line)) : null,
      ),
      child: Row(
        children: [
          _topIcon(
              Icons.arrow_back_rounded,
              false,
              () => setState(() {
                    FocusManager.instance.primaryFocus?.unfocus();
                    _detail = false;
                    _timelineOpen = false;
                  })),
          const SizedBox(width: 10.0),
          if (_clyOn)
            Expanded(child: _profileHeader(p, c))
          else ...[
            SizedBox(
              width: 150.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(12.5, color: _inkTitle, weight: FontWeight.w600)),
                  Text('${c.ageText} · เตียง ${p.bed ?? '—'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(10.0, color: _ink3)),
                ],
              ),
            ),
          ],
          // แท็บอยู่ในการ์ดขวาแล้ว · หน้าสรุป AI ยังแสดงบนแถบบน
          if (!_clyOn)
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: _clyOn ? _cyGlass : _panelSoft,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: _clyOn ? _cyEdge : _panelSoft),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      for (final i in _barTabIdx) _detailTabItem(i),
                      _moreTabItem(),
                    ]),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 10.0),
          // มุมขวาบน = ส่งต่อ flow ถัดไป (F9 แบบ HOSxP) · แจ้งเตือน/ประวัติย้ายไปมุมซ้ายล่าง
          _saveF9Btn(),
        ],
      ),
    );
  }

  Widget _saveF9Btn() {
    final p = _open == null ? null : _sceneSelected(_open!);
    final next = p == null ? null : _nextStage(p.stage);
    final to = next?.label ?? 'ออกจาก ER';
    return Tooltip(
      message: 'บันทึกและส่งต่อไป$to (F9)',
      child: _Press(
        child: GestureDetector(
          onTap: _saveF9,
          // Google style: ปุ่มหลักแบบ pill ทึบ ไม่มีเงาวาว
          child: Container(
            height: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.send_rounded, size: 16.0, color: Colors.white),
              const SizedBox(width: 8.0),
              Text(to,
                  style:
                      _t(13.0, color: Colors.white, weight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }

  /// มุมซ้ายล่างหน้าผู้ป่วย: แจ้งเตือน · ประวัติการบันทึก (การ์ดลอยแบบแถบขั้นตอน)
  Widget _detailDock() => Container(
        padding: const EdgeInsets.all(6.0),
        decoration: _clyCardDeco,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            _topIcon(Icons.notifications_none_rounded, _alertsOpen,
                () => setState(() => _alertsOpen = !_alertsOpen)),
            if (_allAlerts.any((a) => a.level == _Level.critical))
              Positioned(
                right: -3.0,
                top: -3.0,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    constraints: const BoxConstraints(minWidth: 16.0),
                    height: 16.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                        '${_allAlerts.where((a) => a.level == _Level.critical).length}',
                        style: _num(9.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 8.0),
          _topIcon(Icons.history_rounded, _timelineOpen,
              () => setState(() => _timelineOpen = !_timelineOpen)),
        ]),
      );

  /// แถบบนแบบโปรไฟล์ผู้ป่วย: รูป · ชื่อ ESI · ข้อมูลพื้นฐาน + อาการสำคัญ · ค่าสำคัญ
  Widget _profileHeader(_P p, ErCase c) {
    // คั่นด้วยเส้นตั้งแบบแถว HN ในการ์ดผังเตียง (ไม่ใช้ ·)
    final meta = [
      c.ageText,
      'HN ${p.hn}',
      if (p.bed != null) 'เตียง ${p.bed}',
      if (c.bloodGroup.isNotEmpty) 'หมู่เลือด ${c.bloodGroup}',
    ].join('  |  ');
    // GCS แบบย่อ E4V5M6 = 15 จากข้อความเต็ม
    String gcs() {
      final g = c.gcs;
      if (g == null) return '—';
      final m = RegExp(r'([EVM])(\d)').allMatches(g).toList();
      if (m.length < 3) return g;
      final sum = m.fold<int>(0, (a, x) => a + int.parse(x.group(2)!));
      return '$sum (${m.map((x) => x.group(0)).join()})';
    }

    final facts = [
      (
        'แพ้ยา / อาหาร',
        c.allergies.isEmpty ? 'ไม่มี' : c.allergies.join(', '),
        c.allergies.isNotEmpty
      ),
      (
        'โรคประจำตัว',
        c.underlying.isEmpty ? 'ไม่มี' : c.underlying.join(', '),
        false
      ),
      ('GCS', gcs(), false),
      ('รูม่านตา', erPupilOf(c), erPupilOf(c).contains('ช้า')),
      ('อยู่ใน ER', _hm(p.waitMin), false),
    ];
    // หลายรายการ (โรคประจำตัว / แพ้ยา): หัวบอกจำนวน
    List<String>? many(String label) => switch (label) {
          'โรคประจำตัว' => c.underlying.length > 1 ? c.underlying : null,
          'แพ้ยา / อาหาร' => c.allergies.length > 1 ? c.allergies : null,
          _ => null,
        };
    Widget fact((String, String, bool) f) {
      final items = many(f.$1);
      final style =
          _t(12.5, color: f.$3 ? _red : _inkTitle, weight: FontWeight.w600);
      return _copyable(
          f.$1,
          '${f.$1}: ${f.$2}',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(items == null ? f.$1 : '${f.$1} (${items.length})',
                  style: _t(10.0, color: f.$3 ? _red : _ink3)),
              // ยาวเกินช่อง = เลื่อนไปท้ายแล้วกลับรอบเดียวตอนเข้าหน้า (ไม่ตัด …)
              _Marquee(items == null ? f.$2 : items.join(', '),
                  style: style, once: true),
            ],
          ));
    }

    return Row(children: [
      // รูป + เพศที่มุมขวาล่าง
      Tooltip(
        message: c.sex,
        child: Stack(clipBehavior: Clip.none, children: [
          ClipOval(
            child: Image.asset(_faceUrl(p.hn),
                width: 38.0, height: 38.0, fit: BoxFit.cover),
          ),
          Positioned(
            right: -3.0,
            bottom: -3.0,
            child: Container(
              width: 17.0,
              height: 17.0,
              decoration: BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                  c.sex.contains('หญิง')
                      ? Icons.female_rounded
                      : Icons.male_rounded,
                  size: 11.0,
                  color: Colors.white),
            ),
          ),
        ]),
      ),
      const SizedBox(width: 10.0),
      Expanded(
        flex: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Flexible(
                child: Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w600)),
              ),
              if (p.esi != null) ...[
                const SizedBox(width: 10.0),
                // สายรัดข้อมือ ESI แบบเดียวกับการ์ดผังเตียง
                _esiBand(p, p.esi!.color),
              ],
              // ESI ต่ำกว่าเกณฑ์ = ป้ายเตือน "ควรเป็น ESI n" (แตะดูเหตุผล)
              _esiGapBadge(p),
              // pain score ต่อจาก ESI · รูปหน้าและสีตามระดับ แบบหน้าคัดกรอง HOSxP+
              if (c.painScore case final ps?) ...[
                const SizedBox(width: 6.0),
                _painPill(ps, chip: true),
              ],
            ]),
            const SizedBox(height: 3.0),
            Text(meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(11.0, color: _ink2)),
          ],
        ),
      ),
      Container(
        width: 1.0,
        height: 30.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        color: _line,
      ),
      // ข้อมูลสำคัญได้พื้นที่มากกว่าชื่อ · แพ้ยา/โรคประจำตัวกว้างสุด (รายการยาว)
      Expanded(
        flex: 7,
        child: Row(children: [
          for (var k = 0; k < facts.length; k++) ...[
            if (k > 0) const SizedBox(width: 12.0),
            Expanded(flex: k < 2 ? 4 : 2, child: fact(facts[k])),
          ],
        ]),
      ),
    ]);
  }

  /// pain score: ค่าและรูปหน้าจาก item_pain_score ของ HOSxP+ · หน้าตาตาม design language
  /// (pill ขาวนูน) · ปวดมาก (≥ 7) เท่านั้นที่เป็นสีแดง ตามกฎ 60-30-10
  /// สีพื้น pain pill = สีหลักของหน้า icon HOSxP+ ระดับนั้น (0–10)
  /// (ข้อยกเว้นสี 60-30-10 เหมือนสี ESI — สเกลความปวดเป็นภาษาสีที่คลินิกรู้จัก)
  (Color, Color) _painColors(int v) {
    const bg = [
      Color(0xFF2090F0), // 0
      Color(0xFF2A9BF0), // 1
      Color(0xFF45B065), // 2
      Color(0xFF30A070), // 3
      Color(0xFFA0A040), // 4
      Color(0xFFF0C850), // 5
      Color(0xFFA87538), // 6
      Color(0xFFF0A020), // 7
      Color(0xFFF08010), // 8
      Color(0xFFE83A10), // 9
      Color(0xFFB01020), // 10
    ];
    // ตัวอักษรขาวทุกระดับ · เงาจางช่วยอ่านบนพื้นสว่าง
    return (bg[v], Colors.white);
  }

  /// chip = แบบ chip ของ Google (สูง 24 มุม 8 ตัว 11.5) ให้สูงเท่าป้ายข้าง ๆ บนการ์ดผังเตียง
  Widget _painPill(int ps, {bool chip = false}) {
    final v = ps.clamp(0, 10);
    final (bg, fg) = _painColors(v);
    final face = v == 4
        ? 'assets/images/PainScore5_(1).png'
        : 'assets/images/PainScore${v + 1}.png';
    return Container(
      height: chip ? 24.0 : null,
      padding: chip
          ? const EdgeInsets.fromLTRB(4.0, 0.0, 8.0, 0.0)
          : const EdgeInsets.fromLTRB(3.0, 2.0, 8.0, 2.0),
      // chip: พื้น surface โทนจางของสีระดับปวด ตัวอักษรสีระดับเข้มขึ้น
      decoration: BoxDecoration(
        gradient: chip ? null : _glossGrad(bg),
        color:
            chip ? Color.alphaBlend(bg.withValues(alpha: 0.16), _panel) : null,
        borderRadius: BorderRadius.circular(chip ? 8.0 : 100.0),
        boxShadow: chip ? null : _glossLift(bg),
      ),
      foregroundDecoration: chip ? null : const _InnerGloss(100.0, dark: true),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // หน้าสีบนพื้นสี: วงขาวรองให้หน้าเด่น
        Container(
          width: 17.0,
          height: 17.0,
          padding: const EdgeInsets.all(1.0),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Image.asset(face),
        ),
        const SizedBox(width: 4.0),
        Text('Pain $v/10',
            style: chip
                ? _t(11.5,
                    // เข้มพอผ่าน WCAG AA 4.5:1 บนพื้นจาง (เหลือง/ส้มต้องเข้มกว่า)
                    color: Color.lerp(
                        bg, Colors.black, v == 5 || v == 7 ? 0.5 : 0.35)!,
                    weight: FontWeight.w700)
                : _t(9.5, color: fg, weight: FontWeight.w700)
                    .copyWith(shadows: const [
                    Shadow(color: Color(0x66000000), blurRadius: 2.0),
                  ])),
      ]),
    );
  }

  /// ปุ่มไอคอนกลมบนแถบบน (on = พื้นสีหลัก)
  Widget _topIcon(IconData icon, bool on, VoidCallback onTap) => _Press(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40.0,
            height: 40.0,
            // Google style: ปุ่มไอคอนกลมแบน · on = พื้นกรมท่า
            decoration: BoxDecoration(
              color: on ? _blue : _panel,
              shape: BoxShape.circle,
              border: Border.all(color: on ? _blue : const Color(0xFFDADCE0)),
            ),
            child: Icon(icon, size: 18.0, color: on ? Colors.white : _ink2),
          ),
        ),
      );
}

/// ชิป fast track บนแถบหัวผู้ป่วย: ⚡ ชื่อแฟ้ม + เวลาตั้งแต่เปิด (อัปเดตทุก 30 วิ)
/// สีแดงอ่อนแบบ chip (สถานะวิกฤตเวลา) · ไม่มี ticker ใช้ Timer เบา ๆ
class _FtChip extends StatefulWidget {
  const _FtChip({required this.name, required this.since});
  final String name;
  final DateTime since;

  @override
  State<_FtChip> createState() => _FtChipState();
}

class _FtChipState extends State<_FtChip> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = DateTime.now().difference(widget.since).inMinutes;
    // สั้น: 1:45 ชม. / 18 นาที
    final dur = m >= 60
        ? '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')} ชม.'
        : '$m นาที';
    return Container(
      height: 24.0,
      padding: const EdgeInsets.fromLTRB(4.0, 0.0, 8.0, 0.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE8E6),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.bolt_rounded, size: 16.0, color: Color(0xFFB3261E)),
        const SizedBox(width: 2.0),
        Text('${widget.name}  $dur',
            style: TextStyle(
                fontFamily: 'GoogleSans',
                fontFamilyFallback: const ['NotoSansThai'],
                fontSize: 11.5 * _txtScale,
                color: const Color(0xFFB3261E),
                fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
