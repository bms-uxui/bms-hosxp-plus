// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _TabsOverviewUrgentStripState on State<ErFlowHomeWidget> {
  /// แถบล่างของหน้าภาพรวม ชุดเดียวกับหน้าผังเตียง: ค้นหา + การ์ดเตียง
  final ScrollController _footScroll = ScrollController();
  final String _footQuery = '';
  _FootSort _footSort = _FootSort.esi;
}

extension _TabsOverviewUrgentStripPart on _ErFlowHomeWidgetState {
  /// ฉากอาคารแผนกสามมิติ สี่ปีกคือสี่ขั้นของกระแสงาน โถงกลางคือที่นั่งรอ
  /// ไอคอนกับตัวเลขเป็นวิดเจ็ตของ Flutter ที่ลอยตามตำแหน่งปีกซึ่งฝั่งสามมิติ
  /// คำนวณส่งกลับมา ข้อความไทยจึงคมเท่าส่วนอื่นของหน้า
  // ------------------------------------------------- แถบรายชื่อเร่งด่วน
  /// ผู้ป่วยทั้งห้องเรียงตามความเร่งด่วน กรองด้วยคำค้นในแถบล่าง
  ///
  /// เฉพาะผู้ป่วยที่มีเตียง · เรียงระดับ ESI ก่อน แล้วค่อยเวลารอมาก→น้อย
  List<_P> get _footFiltered {
    final q = _footQuery.trim().toLowerCase();
    final list = _patients.where((p) {
      // หน้าภาพรวมแสดงเฉพาะผู้ป่วยที่ได้เตียงแล้ว
      if (p.bed == null) return false;
      // แถบล่างแสดงเฉพาะเคสเร่งด่วน ESI 1-3
      if ((p.esi?.level ?? 9) > 3) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.hn.contains(q) ||
          (p.bed ?? '').toLowerCase().contains(q) ||
          p.note.toLowerCase().contains(q) ||
          (p.esi?.label ?? 'ยังไม่คัดกรอง').contains(q) ||
          p.stage.label.contains(q);
    }).toList();
    list.sort((a, b) {
      switch (_footSort) {
        case _FootSort.esi:
          final ea = a.esi?.level ?? 9;
          final eb = b.esi?.level ?? 9;
          if (ea != eb) return ea.compareTo(eb);
          return b.waitMin.compareTo(a.waitMin);
        case _FootSort.wait:
          return b.waitMin.compareTo(a.waitMin);
        case _FootSort.bed:
          // มีเตียงมาก่อน เรียงรหัสเตียง แล้วคนไม่มีเตียงตามเวลารอ
          if (a.bed != null && b.bed != null) return a.bed!.compareTo(b.bed!);
          if (a.bed != null) return -1;
          if (b.bed != null) return 1;
          return b.waitMin.compareTo(a.waitMin);
      }
    });
    return list;
  }

  /// สถานะเตียงแบบย่อ มุมขวาของแถบล่าง: เตียงที่ใช้ + จำนวนแต่ละระดับ
  /// หมายเลขคิว (QN) จำลองตามลำดับการมาถึง — รอต่อเลขคิวจริงของ HOSxP
  String _qn(_P p) => (_patients.indexWhere((x) => x.hn == p.hn) + 1)
      .toString()
      .padLeft(3, '0');

  /// ค่าผิดปกติของเคส เรียงสำคัญก่อน: (ชื่อ ค่า สูง/ต่ำ)
  List<(String, String, String)> _footAbn(_P p) {
    final c = erCaseOf(p.hn);
    double? last(List<double> s) => s.isEmpty || s.last <= 0 ? null : s.last;
    final sbp = last(c.sbp), sp = last(c.spo2), hr = last(c.hr);
    final rr = last(c.rr), bt = last(c.bt);
    return [
      if (sbp != null && sbp < 90) ('BP', c.bp, 'ต่ำ'),
      if (sp != null && sp < 92) ('SpO₂', '${sp.round()}%', 'ต่ำ'),
      if (hr != null && hr > 120) ('HR', '${hr.round()}', 'สูง'),
      if (hr != null && hr < 50) ('HR', '${hr.round()}', 'ต่ำ'),
      if (rr != null && rr > 24) ('RR', '${rr.round()}', 'สูง'),
      if (sbp != null && sbp >= 180) ('BP', c.bp, 'สูง'),
      if (bt != null && bt >= 39.0) ('BT', bt.toStringAsFixed(1), 'สูง'),
      for (final l in c.labs)
        if (l.abnormal)
          (
            l.name,
            l.resultText,
            !l.isNumeric ? '' : (l.value > l.hi ? 'สูง' : 'ต่ำ')
          ),
    ];
  }

  /// สัญญาณชีพล่าสุดทีละค่า (วนแสดงในแถบกรมท่า) + เวลาวัด
  List<(String, String)> _footVitals(_P p) {
    final c = erCaseOf(p.hn);
    final at = c.times.isEmpty ? '' : _clock(c.times.last);
    double? last(List<double> s) => s.isEmpty || s.last <= 0 ? null : s.last;
    final out = [
      if (last(c.sbp) != null) ('BP ${c.bp}', at),
      if (last(c.hr) case final v?) ('HR ${v.round()}', at),
      if (last(c.spo2) case final v?) ('SpO₂ ${v.round()}%', at),
      if (last(c.rr) case final v?) ('RR ${v.round()}', at),
      if (last(c.bt) case final v?) ('BT ${v.toStringAsFixed(1)}', at),
    ];
    return out.isEmpty ? [('ยังไม่ได้วัด', '')] : out;
  }

  /// เวลาของค่าผิดปกติ ("10:22 น.") · สัญญาณชีพ = เวลาวัดล่าสุด · แล็บ = เวลารายงานผล
  String _footAbnTime(_P p, String name) {
    final c = erCaseOf(p.hn);
    final vital = const ['BP', 'SpO₂', 'HR', 'RR', 'BT'].contains(name);
    final t = vital
        ? (c.times.isEmpty ? null : c.times.last)
        : (erLabReported(p.hn, name) ??
            (c.times.isEmpty ? null : c.times.last));
    return t == null ? '' : _clock(t);
  }

  /// การ์ดแถบล่าง: เคสเร่งด่วน (ESI 1-2) ที่มีค่าผิดปกติ = การ์ดแจ้งเตือน (Figma 326:16)
  /// แจ้งเตือนค่าผิดปกติแค่รายเดียว: รายแรกในแถบ (ตามการเรียง) ที่ ESI 1-2 และมีค่าผิดปกติ
  String? get _footAlertHn {
    for (final p in _footFiltered) {
      if ((p.esi?.level ?? 5) <= 2 && _footAbn(p).isNotEmpty) return p.hn;
    }
    return null;
  }

  /// การ์ดทุกใบใช้โครงเดียวกัน: รายที่แจ้งเตือน = แถบแดงค่าผิดปกติ · อื่น ๆ = แถบกรมท่าอาการสำคัญ
  Widget _footCard(_P p, {String? alertHn, int order = 0}) => _footAlert(
      p, p.hn == alertHn ? _footAbn(p) : const <(String, String, String)>[],
      order: order);

  /// แถบหัวแดง "แจ้งเตือนค่าผิดปกติ" + ค่าที่ผิดปกติ + ภาพผู้ป่วยบนเตียงล้นมุมขวา
  /// แผ่นขาวซ้อนด้านล่าง: รูป ชื่อ ประเภท · เวลา QN เตียง
  /// ปรากฏ: แต่ละชิ้นในการ์ดลอยขึ้นไล่กัน (หัว · ภาพ · รูป · ชื่อ · ป้าย · ผู้ดูแล)
  /// การ์ดถัดไปเริ่มช้ากว่ากันหนึ่งจังหวะ
  Widget _footAlert(_P p, List<(String, String, String)> abn, {int order = 0}) {
    final k0 = order.clamp(0, 4);
    final color = p.esi?.color ?? _red;
    final alert = abn.isNotEmpty;
    return _Press(
      scale: 0.98,
      child: GestureDetector(
        onTap: () => _openPatient(p),
        // idle: การ์ดแจ้งเตือนหายใจเบา ๆ (เงาแดงเต้นช้า) เรียกสายตาโดยไม่กระพริบ
        // ระยะห่างการ์ดอยู่นอกเงา (เงาเกาะขอบการ์ดพอดี)
        child: Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 12.0, bottom: 2.0),
            // ตัวการ์ดลอยขึ้นก่อน แล้วชิ้นข้างในไล่ตาม
            child: _Rise(
                index: k0 * 2,
                child: _Breathe(
                  on: alert,
                  child: Container(
                    width: 250.0,
                    // กรอบเทาอยู่ใต้ภาพ (ภาพผู้ป่วยวาดทับกรอบได้) · แผ่นขาวมีกรอบของตัวเอง
                    // พื้นการ์ดขาว + แถบสีเฉพาะส่วนบน (ลงไปใต้แผ่นขาวแค่ช่วงมุมโค้ง)
                    // มุมล่างจึงไม่มีสีแถบแลบออกตามขอบ
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: _line),
                    ),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(
                        left: 0.0,
                        right: 0.0,
                        top: 0.0,
                        bottom: 96.0 - 16.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            // ค่าปกติ = สีตามระดับ ESI · แจ้งเตือน = แดง
                            color: alert ? _red : color,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14.0)),
                          ),
                        ),
                      ),
                      // พื้นหลังลูกศรลอย + ค่าผิดปกติเลื่อนเปลี่ยนเอง + จุดบอกลำดับ
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: _Rise(
                              index: k0 * 2 + 1,
                              child: _AlertHead(
                                title:
                                    alert ? 'แจ้งเตือนค่าผิดปกติ' : 'สัญญาณชีพ',
                                arrows: alert,
                                // เวลาข้อมูล: สัญญาณชีพ = เวลาวัดล่าสุด · แล็บ = เวลารายงานผล
                                items: alert
                                    ? [
                                        for (final x in abn)
                                          (
                                            '${x.$1} ${x.$2} ${x.$3}'.trim(),
                                            _footAbnTime(p, x.$1),
                                          )
                                      ]
                                    : _footVitals(p),
                                label: _t(9.5,
                                    color: const Color(0xE6FFFFFF),
                                    weight: FontWeight.w500),
                                value: _t(14.0,
                                    color: Colors.white,
                                    weight: FontWeight.w700),
                              )),
                        ),
                      ),
                      // ขอบล่างของภาพถูกตัดตรง: ให้จมใต้แผ่นขาวลึกเกินมุมโค้ง + จางปลายล่าง
                      // ชิดขวาพอดีขอบการ์ด: ตัดเฉพาะส่วนที่เกินขอบขวา (ด้านบนยังล้นได้)
                      Positioned(
                        right: 0.0,
                        top: -4.0,
                        child: _Rise(
                            index: k0 * 2 + 2,
                            child: ClipRect(
                              clipper: const _ClipRightEdge(),
                              child: ShaderMask(
                                blendMode: BlendMode.dstIn,
                                shaderCallback: (r) => const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                    Colors.transparent
                                  ],
                                  stops: [0.0, 0.7, 1.0],
                                ).createShader(r),
                                child: Image.asset(
                                    'assets/images/alert_bed.png',
                                    height: 90.0,
                                    fit: BoxFit.contain),
                              ),
                            )),
                      ),
                      // แผ่นขาวสูงคงที่ชิดล่าง · แถบแดงยืดตามความสูงแถบล่าง
                      Positioned(
                        left: 0.0,
                        right: 0.0,
                        bottom: 0.0,
                        height: 96.0,
                        child: Container(
                          padding:
                              const EdgeInsets.fromLTRB(14.0, 8.0, 12.0, 10.0),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Figma: ประเภทผู้ป่วย (ข้อความธรรมดา) เหนือชื่อตัวใหญ่หนา
                                  // ประเภท + ชื่อ เว้นขวาให้รูปผู้ป่วย · แถวป้ายล่างใช้เต็มความกว้าง
                                  _Rise(
                                      index: k0 * 2 + 4,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 66.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (p.type != null)
                                              Text(p.type!.label,
                                                  style: _t(10.5,
                                                      color: _ink,
                                                      weight: FontWeight.w500)),
                                            Text(p.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: _t(14.0,
                                                    color: _inkTitle,
                                                    weight: FontWeight.w700)),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 3.0),
                                  _Rise(
                                      index: k0 * 2 + 5,
                                      child: Row(children: [
                                        // ESI = ป้ายสีตามระดับ · เตียงอยู่ใต้รูปผู้ป่วย
                                        if (p.esi != null) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5.0, vertical: 1.0),
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: Text(p.esi!.en,
                                                style: _num(9.5,
                                                    color: Colors.white,
                                                    weight: FontWeight.w700)),
                                          ),
                                          const SizedBox(width: 4.0),
                                        ],
                                        const SizedBox(width: 4.0),
                                        Text('QN ${_qn(p)}',
                                            style: _num(9.5,
                                                color: _ink2,
                                                weight: FontWeight.w600)),
                                      ])),
                                  // ผู้ดูแลของช่วงงานปัจจุบัน (ทีมประจำเวร/เหตุการณ์ของเคส)
                                  _Rise(
                                      index: k0 * 2 + 6,
                                      child: Builder(builder: (context) {
                                        final ck =
                                            _phaseCheck(p, _Phase.of(p.stage));
                                        final w = p.waitMin;
                                        final lab = _t(8.5,
                                            color: _ink3,
                                            weight: FontWeight.w500);
                                        final val = _t(10.5,
                                            color: _inkTitle,
                                            weight: FontWeight.w600);
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('ดูแลล่าสุด',
                                                          style: lab),
                                                      Text(
                                                          '${ck.who}${ck.time == '-' ? '' : ' ${_clock(ck.time)}'}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: val),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                // เวลาใน ER มุมขวาล่าง (สีเดียวกับข้อมูลอื่น)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text('อยู่ใน ER',
                                                        style: lab),
                                                    Text(
                                                        w >= 60
                                                            ? '${w ~/ 60} ชม. ${w % 60} นาที'
                                                            : '$w นาที',
                                                        style: val),
                                                  ],
                                                ),
                                              ]),
                                        );
                                      })),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                      // รูปผู้ป่วยมุมขวา (Figma) ใหญ่ ขอบแดง คร่อมรอยต่อแถบแดงกับแผ่นขาว
                      Positioned(
                        right: 14.0,
                        bottom: 96.0 - 34.0,
                        child: _Rise(
                            index: k0 * 2 + 3,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _panelSoft,
                                    // ขอบรูป = สี ESI เสมอ (สีบอกระดับ · ป้ายเตียงเป็นสีกลาง)
                                    border:
                                        Border.all(color: color, width: 2.0),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(_faceUrl(p.hn),
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, st) => const Icon(
                                            Icons.person_rounded,
                                            size: 26.0,
                                            color: _ink3)),
                                  ),
                                ),
                                // ป้ายเตียงคร่อมขอบล่างกลางรูป
                                Positioned(
                                  bottom: -8.0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0, vertical: 1.0),
                                    decoration: BoxDecoration(
                                      color: _panel,
                                      borderRadius: BorderRadius.circular(6.0),
                                      border: Border.all(color: _line),
                                    ),
                                    child: Text('เตียง ${p.bed ?? '—'}',
                                        style: _t(9.5,
                                            color: _ink2,
                                            weight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ]),
                  ),
                ))),
      ),
    );
  }

  /// แถบล่างของหน้าภาพรวม ยกมาจากหน้าผังเตียง
  /// แถวบน: ตัวเรียง ช่องค้นหา สถานะเตียง · แถวล่าง: การ์ดผู้ป่วยเลื่อนแนวนอน
  /// ปุ่มเลื่อนแถวการ์ดผู้ป่วยในแถบล่าง ทีละราวสามใบ
  Widget _footScrollButton(IconData icon, int dir) => _Press(
          child: Material(
        color: _panelSoft,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!_footScroll.hasClients) return;
            final to = (_footScroll.offset + dir * 474.0)
                .clamp(0.0, _footScroll.position.maxScrollExtent);
            _footScroll.animateTo(to,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic);
          },
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            child: Icon(icon, size: 20.0, color: _ink2),
          ),
        ),
      ));

  Widget _urgentStrip() {
    final list = _footFiltered;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 8.0),
      decoration: const BoxDecoration(
        color: _panel,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // หัวข้อเฉย ๆ (เรียงตามความเร่งด่วนเสมอ ไม่มีตัวเลือก)
              Text('เรียงตามความเร่งด่วน',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 8.0),
              Text('${list.length} ราย', style: _t(11.0, color: _ink2)),
              const Spacer(),
              // ปุ่มเลื่อนแถวการ์ด อยู่ขวาสุดของแถบ
              _footScrollButton(Icons.chevron_left_rounded, -1),
              const SizedBox(width: 6.0),
              _footScrollButton(Icons.chevron_right_rounded, 1),
            ],
          ),
          const SizedBox(height: 2.0),
          SizedBox(
            // ฟอนต์ไทยสูงกว่าฟอนต์ที่หน้าผังเตียงจูนไว้ เผื่ออีก 6px
            // ขยายตามขนาดตัวอักษรที่ตั้งไว้
            height: 170.0 + (_txtScale - 1.0) * 60.0,
            child: _loading
                ? _Shimmer(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: _bone(148.0, 128.0, radius: 14.0),
                          ),
                      ],
                    ),
                  )
                : list.isEmpty
                    ? Center(
                        child: Text('ไม่มีผู้ป่วยในเงื่อนไขนี้',
                            style: _t(12.0, color: _ink3)),
                      )
                    : Builder(builder: (context) {
                        final alertHn = _footAlertHn;
                        return ListView.builder(
                          controller: _footScroll,
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length,
                          itemBuilder: (context, i) =>
                              _footCard(list[i], alertHn: alertHn, order: i),
                        );
                      }),
          ),
        ],
      ),
    );
  }
}

/// ตัดเฉพาะขอบขวา (ภาพชิดขอบการ์ด) ปล่อยบน/ล่าง/ซ้ายล้นได้
class _ClipRightEdge extends CustomClipper<Rect> {
  const _ClipRightEdge();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-1000.0, -1000.0, size.width, size.height + 1000.0);

  @override
  bool shouldReclip(_ClipRightEdge old) => false;
}

/// หัวการ์ดแจ้งเตือน: ลูกศรโปร่งลอยลงเป็นพื้นหลัง (ลงอย่างเดียว)
/// ค่าผิดปกติเลื่อนเปลี่ยนเองทุก 2.5 วิ (ขึ้นจากล่าง) + จุดบอกลำดับ · ค่าเดียว = นิ่ง ไม่มีจุด
class _AlertHead extends StatefulWidget {
  const _AlertHead(
      {required this.items,
      required this.label,
      required this.value,
      this.title = 'แจ้งเตือนค่าผิดปกติ',
      this.arrows = true});

  final String title;
  final bool arrows;

  /// (ข้อความ, เวลาข้อมูล เช่น "10:22 น." · ว่าง = ไม่แสดง)
  final List<(String, String)> items;
  final TextStyle label;
  final TextStyle value;

  @override
  State<_AlertHead> createState() => _AlertHeadState();
}

class _AlertHeadState extends State<_AlertHead>
    with SingleTickerProviderStateMixin {
  int _i = 0;
  Timer? _t;
  // ลูกศรเดินเฉพาะการ์ดแจ้งเตือน
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 7));

  @override
  void initState() {
    super.initState();
    _drift.repeat();
    if (widget.items.length > 1) {
      _t = Timer.periodic(const Duration(milliseconds: 2500), (_) {
        if (mounted) setState(() => _i = (_i + 1) % widget.items.length);
      });
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.items.length;
    final cur = n == 0 ? ('', '') : widget.items[_i % n];
    return Stack(children: [
      // พื้นหลัง: ผิดปกติ = ลูกศรลอยลง · ปกติ = คลื่นชีพจร (ECG) วิ่งผ่าน
      Positioned.fill(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: widget.arrows
                ? _ArrowsPainter(_drift, 1.0)
                : _PulsePainter(_drift),
          ),
        ),
      ),
      Positioned(
        left: 12.0,
        top: 8.0,
        right: 104.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: widget.label),
            ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (c, prev) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...prev, if (c != null) c]),
                transitionBuilder: (child, anim) {
                  final incoming = child.key == ValueKey(_i);
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.0, incoming ? 1.0 : -1.0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: Text(cur.$1,
                    key: ValueKey(_i),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: widget.value),
              ),
            ),
            if (n > 1 || cur.$2.isNotEmpty) ...[
              const SizedBox(height: 3.0),
              Row(children: [
                if (n > 1)
                  for (var k = 0; k < n.clamp(0, 8); k++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: k == _i % n ? 8.0 : 3.5,
                      height: 3.5,
                      margin: const EdgeInsets.only(right: 2.5),
                      decoration: BoxDecoration(
                        color: k == _i % n
                            ? Colors.white
                            : const Color(0x66FFFFFF),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                if (cur.$2.isNotEmpty) ...[
                  if (n > 1) const SizedBox(width: 4.0),
                  Flexible(
                    child: Text('ข้อมูลเมื่อ ${cur.$2}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: widget.label
                            .copyWith(fontSize: widget.label.fontSize! * 0.9)),
                  ),
                ],
              ]),
            ],
          ],
        ),
      ),
    ]);
  }
}

/// ลูกศรขาวโปร่งหลายขนาดลอยตามทิศ (dir 1 = ลง · -1 = ขึ้น) วนต่อเนื่อง
class _ArrowsPainter extends CustomPainter {
  _ArrowsPainter(this.anim, this.dir) : super(repaint: anim);

  final Animation<double> anim;
  final double dir;

  // (ตำแหน่ง x 0..1, ขนาด, ความเร็ว, จุดเริ่ม, ความทึบ)
  static const _arrows = [
    (0.06, 18.0, 1.0, 0.10, 0.10),
    (0.18, 12.0, 1.6, 0.55, 0.08),
    (0.30, 22.0, 0.8, 0.30, 0.07),
    (0.42, 14.0, 1.3, 0.80, 0.10),
    (0.52, 26.0, 0.7, 0.05, 0.06),
    (0.64, 12.0, 1.8, 0.40, 0.09),
    (0.74, 20.0, 1.0, 0.70, 0.07),
    (0.86, 16.0, 1.4, 0.20, 0.09),
    (0.95, 11.0, 1.7, 0.90, 0.08),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    final paint = Paint();
    for (final a in _arrows) {
      final s = a.$2;
      final span = size.height + s * 2.4;
      var y = ((t * a.$3 + a.$4) % 1.0) * span - s * 1.2;
      if (dir < 0) y = size.height - y;
      final x = a.$1 * size.width;
      paint.color = Colors.white.withValues(alpha: a.$5);
      // ลูกศร: หัวสามเหลี่ยม + ก้าน · ชี้ลงแล้วพลิกเมื่อขึ้น
      final h = s * 0.55;
      final path = Path()
        ..addRect(Rect.fromLTWH(x - s * 0.18, y - s, s * 0.36, s))
        ..moveTo(x - s * 0.45, y)
        ..lineTo(x + s * 0.45, y)
        ..lineTo(x, y + h)
        ..close();
      if (dir < 0) {
        canvas.save();
        canvas.translate(0, y * 2);
        canvas.scale(1, -1);
        canvas.drawPath(path, paint);
        canvas.restore();
      } else {
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ArrowsPainter old) => old.dir != dir;
}

/// เส้นคลื่นชีพจรจาง ๆ วิ่งจากซ้ายไปขวา ปลายเส้นเป็นจุดสว่าง (ค่าปกติ)
class _PulsePainter extends CustomPainter {
  _PulsePainter(this.anim) : super(repaint: anim);

  final Animation<double> anim;

  /// รูปคลื่นหนึ่งจังหวะ (x 0..1 → y -1..1) เส้นเรียบ แล้ว P · QRS · T
  static double _beat(double u) {
    if (u < 0.30) return 0.0;
    if (u < 0.36) return -0.12 * math.sin((u - 0.30) / 0.06 * math.pi);
    if (u < 0.40) return 0.0;
    if (u < 0.42) return 0.18 * (u - 0.40) / 0.02;
    if (u < 0.45) return 0.18 - 1.18 * (u - 0.42) / 0.03;
    if (u < 0.48) return -1.0 + 1.35 * (u - 0.45) / 0.03;
    if (u < 0.50) return 0.35 - 0.35 * (u - 0.48) / 0.02;
    if (u < 0.58) return 0.0;
    if (u < 0.70) return -0.22 * math.sin((u - 0.58) / 0.12 * math.pi);
    return 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // วาดเฉพาะในแถบสีด้านบน (แผ่นขาวสูง 96 ทับส่วนล่าง)
    final band = size.height - 96.0;
    final midY = band * 0.62;
    final amp = band * 0.3;
    const period = 150.0; // ความกว้างหนึ่งจังหวะ (px)
    final head = anim.value * (size.width + period) - period * 0.2;
    const tail = 180.0; // ความยาวหางที่ค่อย ๆ จาง
    final path = Path();
    var first = true;
    for (var x = math.max(0.0, head - tail);
        x <= math.min(head, size.width);
        x += 1.5) {
      final y = midY + _beat((x % period) / period) * amp;
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    if (first) return;
    final rect = Rect.fromLTRB(head - tail, 0, head, size.height);
    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round
          ..shader = const LinearGradient(colors: [
            Color(0x00FFFFFF),
            Color(0x66FFFFFF),
          ]).createShader(rect));
    if (head >= 0 && head <= size.width) {
      final y = midY + _beat((head % period) / period) * amp;
      canvas.drawCircle(
          Offset(head, y), 2.2, Paint()..color = const Color(0x80FFFFFF));
    }
  }

  @override
  bool shouldRepaint(_PulsePainter old) => false;
}

/// idle ของการ์ดแจ้งเตือน: เด้งแบบ Dock ของ macOS · on = false → ไม่ทำอะไร
class _Breathe extends StatefulWidget {
  const _Breathe({required this.on, required this.child});

  final bool on;
  final Widget child;

  @override
  State<_Breathe> createState() => _BreatheState();
}

class _BreatheState extends State<_Breathe>
    with SingleTickerProviderStateMixin {
  // สร้างใน initState: ถ้า lazy แล้วไม่เคยใช้ จะถูกสร้างครั้งแรกตอน dispose แล้ว error
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    if (widget.on) _c.repeat();
  }

  @override
  void didUpdateWidget(_Breathe old) {
    super.didUpdateWidget(old);
    if (widget.on && !_c.isAnimating) _c.repeat();
    if (!widget.on && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.on) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // เด้งแบบ Dock ของ macOS: กระโดด 9px ตก แล้วเด้งซ้ำ 3.5px จากนั้นพักจนจบรอบ
        final u = _c.value;
        double hop(double from, double len, double h) {
          final k = (u - from) / len;
          if (k < 0.0 || k > 1.0) return 0.0;
          return h * 4.0 * k * (1.0 - k); // พาราโบลา = ขึ้นช้าลง ตกเร็วขึ้น
        }

        final bob = hop(0.0, 0.22, 9.0) + hop(0.22, 0.14, 3.5);
        return Transform.translate(
          offset: Offset(0.0, -bob),
          child: child,
        );
      },
      // เลื่อนทั้ง layer เดิม ไม่วาดการ์ดใหม่ทุกเฟรม
      child: RepaintBoundary(child: widget.child),
    );
  }
}

/// ปรากฏของการ์ดแถบล่าง: ลอยขึ้น 22px + ขยายจาก 96% + จาง
/// เด้งเล็กน้อยตอนจบ (easeOutBack) · ชิ้นถัดไปช้ากว่ากัน 70ms
class _Rise extends StatefulWidget {
  const _Rise({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_Rise> createState() => _RiseState();
}

class _RiseState extends State<_Rise> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 620));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 80 + 70 * widget.index.clamp(0, 14)),
        () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final move = Curves.easeOutBack.transform(t);
          final fade = Curves.easeOut.transform((t * 1.6).clamp(0.0, 1.0));
          return Opacity(
            opacity: fade,
            child: Transform.translate(
              offset: Offset(0.0, 22.0 * (1.0 - move)),
              child: Transform.scale(scale: 0.96 + 0.04 * move, child: child),
            ),
          );
        },
        child: widget.child,
      );
}
