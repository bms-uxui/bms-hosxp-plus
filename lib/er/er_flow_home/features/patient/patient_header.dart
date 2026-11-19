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
    // พยาบาลคัดกรอง = ดูอย่างเดียว: ป้ายเทาแทนปุ่มบันทึกส่งต่อ
    if (_viewOnly) {
      return Container(
        height: 40.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.visibility_outlined, size: 18.0, color: _ink2),
          const SizedBox(width: 8.0),
          Text('ดูอย่างเดียว',
              style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
        ]),
      );
    }
    final p = _open == null ? null : _sceneSelected(_open!);
    final next = p == null ? null : _nextStage(p.stage);
    final to = next == null ? 'ออกจาก ER' : _Phase.of(next).label;
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
              const Icon(Icons.save_outlined, size: 18.0, color: Colors.white),
              const SizedBox(width: 8.0),
              // ป้ายบอกการกระทำ (ปลายทางอยู่ใน tooltip)
              Text('บันทึกส่งต่อ',
                  style:
                      _t(13.0, color: Colors.white, weight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }

  /// รายละเอียดแพ้ยา / อาหาร (bottom sheet): ภาพประกอบ + จำนวนแยกประเภท
  /// รายการแบ่งกลุ่ม ยา → อาหาร: ชื่อ · ระดับความรุนแรง · อาการที่เคยเกิด · แหล่งข้อมูล
  /// แสดงเฉพาะข้อมูลที่มี (ไม่มีข้อมูลอาการ = บอกว่าไม่ได้ระบุ)
  void _allergySheet(ErCase c) {
    HapticFeedback.selectionClick();
    final rows = [
      for (final a in c.allergies) (name: a, info: erAllergyInfo(a)),
    ];
    final groups = <(
      String,
      List<
          ({
            String name,
            ({String type, String reaction, String severity})? info
          })>
    )>[
      for (final t in const ['ยา', 'อาหาร'])
        if (rows.any((r) => (r.info?.type ?? 'ยา') == t))
          (
            t,
            [
              for (final r in rows)
                if ((r.info?.type ?? 'ยา') == t) r
            ]
          ),
    ];
    Widget sevBadge(String sev) {
      final hot = sev == 'รุนแรง';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: hot ? _red : const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Text(sev,
            style: _t(12.0,
                color: hot ? Colors.white : _ink2, weight: FontWeight.w600)),
      );
    }

    Widget item(
            ({
              String name,
              ({String type, String reaction, String severity})? info
            }) r) =>
        Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.fromLTRB(16.0, 14.0, 14.0, 14.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(r.name,
                    style: _t(17.0, color: _red, weight: FontWeight.w700)),
              ),
              if (r.info?.severity case final sv? when sv != '-') sevBadge(sv),
            ]),
            const SizedBox(height: 10.0),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 92.0,
                child: Text('อาการที่เคยเกิด',
                    style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
              ),
              Expanded(
                child: Text(
                    (r.info?.reaction ?? '-') == '-'
                        ? 'ไม่ได้ระบุ'
                        : r.info!.reaction,
                    style: _t(14.0,
                        color: _inkTitle,
                        weight: FontWeight.w500,
                        height: 1.4)),
              ),
            ]),
            const SizedBox(height: 6.0),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 92.0,
                child: Text('แหล่งข้อมูล',
                    style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
              ),
              Expanded(
                child: Text('ผู้ป่วย/ญาติแจ้ง บันทึกใน HOSxP',
                    style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
              ),
            ]),
          ]),
        );

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      // ปิดได้ทางปุ่ม "รับทราบ" เท่านั้น: แตะพื้นหลัง / ลากลง ไม่ปิด
      isDismissible: false,
      enableDrag: false,
      // พื้นขาว: ภาพประกอบมีพื้นขาวทึบ กลืนกับ sheet
      backgroundColor: _panel,
      constraints: const BoxConstraints(maxWidth: 560.0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      // เลื่อนรายการ = หัว (ชื่อ + คำอธิบาย) หดเป็นแถบบาง ภาพประกอบย่อเข้ามุมขวา
      // ปุ่ม "รับทราบ" ลอยอยู่ล่างตลอด (รายการเลื่อนลอดใต้ปุ่ม)
      builder: (sctx) {
        final off = ValueNotifier<double>(0.0);
        const collapse = 90.0;
        return ValueListenableBuilder<double>(
          valueListenable: off,
          builder: (context, o, _) {
            final t = (o / collapse).clamp(0.0, 1.0);
            final tc = Curves.easeOut.transform(t);
            return Stack(clipBehavior: Clip.none, children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sctx).height * 0.86),
                child: SafeArea(
                  top: false,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // หัว: ชื่อ (22 → 17) · คำอธิบายจางหาย · เว้นขวาให้ภาพ (ใหญ่ → เล็ก)
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          20.0, 28.0 - 12.0 * tc, 20.0, 12.0 - 4.0 * tc),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24.0)),
                        border: Border(
                            bottom: BorderSide(
                                color: _line.withValues(alpha: tc),
                                width: 0.5)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('แพ้ยา / อาหาร',
                                    style: _t(22.0 - 5.0 * tc,
                                        color: _inkTitle,
                                        weight: FontWeight.w700)),
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    heightFactor: 1.0 - tc,
                                    child: Opacity(
                                      opacity: 1.0 - tc,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                            'สิ่งที่ผู้ป่วยแพ้และอาการที่เคยเกิด',
                                            style: _t(13.0,
                                                color: _ink2,
                                                weight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        SizedBox(width: 150.0 - 96.0 * tc, height: 1.0),
                      ]),
                    ),
                    Flexible(
                      child: Stack(children: [
                        NotificationListener<ScrollUpdateNotification>(
                          onNotification: (n) {
                            if (n.depth == 0) off.value = n.metrics.pixels;
                            return false;
                          },
                          child: ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 4.0, 20.0, 92.0),
                            children: [
                              for (final (t, list) in groups) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      4.0, 8.0, 4.0, 8.0),
                                  child: Text(t == 'ยา' ? 'แพ้ยา' : 'แพ้อาหาร',
                                      style: _t(14.0,
                                          color: _ink2,
                                          weight: FontWeight.w600)),
                                ),
                                for (final r in list) item(r),
                              ],
                            ],
                          ),
                        ),
                        // ปุ่มหลักลอยล่าง: รับทราบ = ทางเดียวที่ปิด sheet
                        Positioned(
                          left: 0.0,
                          right: 0.0,
                          bottom: 0.0,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 16.0, 20.0, 20.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  _panel.withValues(alpha: 0.0),
                                  _panel,
                                  _panel
                                ],
                                stops: const [0.0, 0.3, 1.0],
                              ),
                            ),
                            child: FilledButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(sctx);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: _blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52.0),
                                shape: const StadiumBorder(),
                              ),
                              child: Text('รับทราบ',
                                  style: _t(15.0,
                                      color: Colors.white,
                                      weight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
              // ภาพประกอบ: ล้นขอบบนของ sheet · เลื่อนแล้วย่อเข้ามุมขวาในแถบหัว
              Positioned(
                top: -64.0 + 70.0 * tc,
                right: 12.0 + 4.0 * tc,
                width: 196.0 - 136.0 * tc,
                height: 196.0 - 136.0 * tc,
                child: const IgnorePointer(child: _AllergyArt()),
              ),
            ]);
          },
        );
      },
    );
  }

  /// แถบบนแบบโปรไฟล์ผู้ป่วย: รูป · ชื่อ ESI · ข้อมูลพื้นฐาน + อาการสำคัญ · ค่าสำคัญ
  Widget _profileHeader(_P p, ErCase c) {
    // คั่นด้วย • (ผู้ใช้เลือก 2026-10-26 แทนเส้นตั้ง)
    final meta = [
      c.ageText,
      'HN ${p.hn}',
      if (p.bed != null) 'เตียง ${p.bed}',
      if (c.bloodGroup.isNotEmpty) 'หมู่เลือด ${c.bloodGroup}',
    ].join('  •  ');
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
      // GCS + รูม่านตา ย้ายไปการ์ดสัญญาณชีพในภาพรวม (ER-9264)
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
      // แพ้ยา/อาหาร (มีรายการ): แตะ = bottom sheet รายละเอียด (ประเภท อาการ ความรุนแรง)
      final tapAllergy = f.$1 == 'แพ้ยา / อาหาร' && c.allergies.isNotEmpty;
      final body = _copyable(
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
      if (!tapAllergy) return body;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _allergySheet(c),
        child: body,
      );
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
      // เน้นฝั่งชื่อ (2026-10-22): ชื่อ + ESI + pain ได้พื้นที่มากกว่า ไม่ถูกตัด …
      Expanded(
        flex: 9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Flexible(
                child: Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
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
      // ข้อมูลประกอบ: แพ้ยา/โรคประจำตัวกว้างสุด (รายการยาวเลื่อนอ่านได้)
      Expanded(
        flex: 6,
        child: Row(children: [
          // 3 ช่อง (GCS/รูม่านตาย้ายไปการ์ดสัญญาณชีพ): แพ้ยา | โรคประจำตัว (ยาวสุด) | อยู่ใน ER
          // เส้นตั้งคั่นแต่ละช่อง ระยะเท่ากัน
          for (var k = 0; k < facts.length; k++) ...[
            if (k > 0)
              Container(
                width: 1.0,
                height: 30.0,
                margin: const EdgeInsets.symmetric(horizontal: 14.0),
                color: _line,
              ),
            Expanded(flex: const [3, 4, 2][k % 3], child: fact(facts[k])),
          ],
        ]),
      ),
    ]);
  }

  /// chip = แบบ chip ของ Google (สูง 24 มุม 8 ตัว 11.5) ให้สูงเท่าป้ายข้าง ๆ บนการ์ดผังเตียง
  Widget _painPill(int ps, {bool chip = false}) {
    final v = ps.clamp(0, 10);
    // สีชุดเดียวกับแถบความปวดหน้าคัดกรอง (เขียว เหลือง น้ำตาล ส้ม ม่วง)
    final bg = _PainFaceSliderState.colorAt(v / 10.0);
    const fg = Colors.white;
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
        // หน้า emoji ชุดเดียวกับแถบความปวดหน้าคัดกรอง (วงสีตามระดับ + หน้า 3D นิ่ง)
        Builder(builder: (context) {
          final t = v / 10.0;
          final c = _PainFaceSliderState.colorAt(t);
          return Container(
            width: 18.0,
            height: 18.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
              border: Border.all(color: Colors.white, width: 1.0),
            ),
            child: CustomPaint(
              painter: _PainFacePainter(t, const Color(0x00000000),
                  Color.lerp(c, Colors.black, 0.55)!,
                  sphere: true),
            ),
          );
        }),
        const SizedBox(width: 4.0),
        Text('Pain $v/10',
            style: chip
                ? _t(11.5,
                    // เข้มพอผ่าน WCAG AA 4.5:1 บนพื้นจาง (เหลือง/ส้มต้องเข้มกว่า)
                    color: Color.lerp(bg, Colors.black, 0.5)!,
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
                fontFamily: _fontFam,
                fontFamilyFallback: _fontFb,
                fontSize: 11.5 * _txtScale,
                color: const Color(0xFFB3261E),
                fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// ภาพประกอบแพ้ยา / อาหาร แยกชิ้น (ตัดจากภาพต้นฉบับ 1024 → ชิ้นละไฟล์ er_al_*.png พิกัดบนกรอบ 512)
/// เข้าฉากไล่ทีละชิ้น (ไม่มีวงพื้นหลัง): ขวดยาเด้งขึ้น → แผงยา/แคปซูลเลื่อนออกจากหลังขวด
/// → กุ้ง นม ถั่ว ไข่ อัลมอนด์ แคปซูล เมล็ดถั่ว กระเด็นออกจากขวดไปเข้าที่ทีละชิ้น
class _AllergyArt extends StatefulWidget {
  const _AllergyArt();
  @override
  State<_AllergyArt> createState() => _AllergyArtState();
}

class _AllergyArtState extends State<_AllergyArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1700));
  // รอ sheet เลื่อนขึ้นก่อน
  late final Timer _start = Timer(const Duration(milliseconds: 220), () {
    if (mounted) _c.forward();
  });

  @override
  void initState() {
    super.initState();
    _start;
  }

  @override
  void dispose() {
    _start.cancel();
    _c.dispose();
    super.dispose();
  }

  // (ชื่อไฟล์, x, y, กว้าง, สูง) บนกรอบ 512
  static const _bottle = ('bottle', 129.0, 101.0, 211.5, 348.5);
  static const _behind = [
    ('blister', 15.0, 220.0, 132.5, 138.0),
    ('cap1', 123.0, 214.0, 37.5, 42.5),
  ];
  static const _around = [
    ('shrimp', 84.0, 66.0, 102.5, 105.5),
    ('milk', 321.5, 49.5, 106.0, 157.5),
    ('peanut', 43.0, 139.5, 77.0, 76.0),
    ('egg', 382.5, 194.0, 99.5, 89.5),
    ('almond', 345.5, 262.5, 51.0, 55.0),
    ('cap2', 351.5, 333.5, 63.5, 60.5),
    ('nut', 405.0, 307.0, 34.5, 32.0),
  ];

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: LayoutBuilder(builder: (context, box) {
          final k = box.maxWidth / 512.0;
          Widget img(String n) => Image.asset('assets/images/er_al_$n.png',
              fit: BoxFit.fill, gaplessPlayback: true);
          return AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              double seg(double a, double b, [Curve c = Curves.easeOutCubic]) =>
                  c.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));
              Widget at((String, double, double, double, double) p,
                      {Offset shift = Offset.zero,
                      double scale = 1.0,
                      double turn = 0.0,
                      double op = 1.0,
                      Alignment pivot = Alignment.center}) =>
                  Positioned(
                    left: (p.$2 + shift.dx) * k,
                    top: (p.$3 + shift.dy) * k,
                    width: p.$4 * k,
                    height: p.$5 * k,
                    child: Opacity(
                      opacity: op.clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: turn,
                        child: Transform.scale(
                            scale: scale, alignment: pivot, child: img(p.$1)),
                      ),
                    ),
                  );
              final bo = seg(0.06, 0.40, Curves.easeOutBack);
              // กลางขวด (จุดที่ชิ้นรอบ ๆ กระเด็นออกมา)
              const cx = 235.0, cy = 275.0;
              return Stack(clipBehavior: Clip.none, children: [
                // หลังขวด: เลื่อนออกจากใต้ขวด (ขอบที่ถูกขวดบังไม่โผล่)
                for (final (i, p) in _behind.indexed)
                  () {
                    final t = seg(0.30 + 0.07 * i, 0.58 + 0.07 * i);
                    return at(p,
                        shift: Offset(46.0 * (1 - t), 6.0 * (1 - t)),
                        op: seg(0.30 + 0.07 * i, 0.40 + 0.07 * i));
                  }(),
                at(_bottle,
                    scale: 0.55 + 0.45 * bo,
                    pivot: Alignment.bottomCenter,
                    op: seg(0.06, 0.18)),
                // รอบขวด: กระเด็นจากกลางขวดไปเข้าที่ ขยาย + หมุนเล็กน้อย
                for (final (i, p) in _around.indexed)
                  () {
                    final a = 0.36 + 0.065 * i;
                    final t = seg(a, a + 0.30, Curves.easeOutBack);
                    final mx = cx - (p.$2 + p.$4 / 2),
                        my = cy - (p.$3 + p.$5 / 2);
                    return at(p,
                        shift: Offset(mx, my) * (0.6 * (1 - t)),
                        scale: 0.2 + 0.8 * t,
                        turn: (i.isEven ? -0.5 : 0.5) * (1 - t),
                        op: seg(a, a + 0.10));
                  }(),
              ]);
            },
          );
        }),
      );
}
