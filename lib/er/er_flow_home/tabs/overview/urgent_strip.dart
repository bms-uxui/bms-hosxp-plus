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

  /// fast track KPI ที่กำลังนับ/เกินเป้า (สูงสุด 3) สำหรับวนในหัวการ์ด
  /// ('Door-to-CT เกิน 79 นาที', 'ครบ 08:33 น.')
  List<(String, String)> _footFtItems(_P p) => [
        for (final (k, st, c) in _ftKpiBrief(p.hn).take(3))
          if (c != _ink3 && c != _green)
            (
              '${k.split(' ≤').first} ${st.split(' (').first.replaceFirst('เกินเป้า', 'เกิน')}',
              RegExp(r'\((.*)\)').firstMatch(st)?.group(1) ?? '',
            ),
      ];

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
  /// [esiTag] = ป้ายระดับ ESI หน้า QN · กระดานที่แบ่งกลุ่มตาม ESI อยู่แล้วไม่ต้องมี
  Widget _footCard(_P p,
          {String? alertHn,
          int order = 0,
          double width = 250.0,
          bool esiTag = true}) =>
      _footAlert(
          p, p.hn == alertHn ? _footAbn(p) : const <(String, String, String)>[],
          order: order, width: width, esiTag: esiTag);

  /// แถบหัวแดง "แจ้งเตือนค่าผิดปกติ" + ค่าที่ผิดปกติ + ภาพผู้ป่วยบนเตียงล้นมุมขวา
  /// แผ่นขาวซ้อนด้านล่าง: รูป ชื่อ ประเภท · เวลา QN เตียง
  /// ปรากฏ: แต่ละชิ้นในการ์ดลอยขึ้นไล่กัน (หัว · ภาพ · รูป · ชื่อ · ป้าย · ผู้ดูแล)
  /// การ์ดถัดไปเริ่มช้ากว่ากันหนึ่งจังหวะ
  Widget _footAlert(_P p, List<(String, String, String)> abn,
      {int order = 0, double width = 250.0, bool esiTag = true}) {
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
                    width: width,
                    // กรอบเทาอยู่ใต้ภาพ (ภาพผู้ป่วยวาดทับกรอบได้) · แผ่นขาวมีกรอบของตัวเอง
                    // พื้นการ์ดขาว + แถบสีเฉพาะส่วนบน (ลงไปใต้แผ่นขาวแค่ช่วงมุมโค้ง)
                    // มุมล่างจึงไม่มีสีแถบแลบออกตามขอบ
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: const Color(0xFFDADCE0)),
                    ),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(
                        left: 0.0,
                        right: 0.0,
                        top: 0.0,
                        bottom: 122.0 - 16.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            // ค่าปกติ = สีตามระดับ ESI · แจ้งเตือน = แดง (สีทึบ)
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
                                // วนแสดงต่อด้วย fast track KPI (ชื่อสั้น + เกิน/เหลือ · เวลาครบ)
                                items: [
                                  ...(alert
                                      ? [
                                          for (final x in abn)
                                            (
                                              '${x.$1} ${x.$2} ${x.$3}'.trim(),
                                              _footAbnTime(p, x.$1),
                                            )
                                        ]
                                      : _footVitals(p)),
                                  ..._footFtItems(p),
                                ],
                                label: _t(11.5,
                                    color: const Color(0xE6FFFFFF),
                                    weight: FontWeight.w500),
                                value: _t(17.0,
                                    color: Colors.white,
                                    weight: FontWeight.w700),
                              )),
                        ),
                      ),
                      // แผ่นขาวสูงคงที่ชิดล่าง · แถบแดงยืดตามความสูงแถบล่าง
                      Positioned(
                        left: 0.0,
                        right: 0.0,
                        bottom: 0.0,
                        height: 122.0,
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
                                            const EdgeInsets.only(right: 90.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // บนชื่อ: ประเภท + ป้าย fast track KPI ด่วนสุด (ER-9041)
                                            Row(children: [
                                              if (p.type != null)
                                                Text(p.type!.label,
                                                    style: _t(12.0,
                                                        color: _ink,
                                                        weight:
                                                            FontWeight.w500)),
                                              // fast track: KPI ด่วนสุดของคนนี้ (เกินเป้า = แดง · เหลือ = น้ำเงิน)
                                              // รู้ได้จากหน้าภาพรวมว่าใครเกินเป้าแล้ว (ER-9041)
                                              if (_ftKpiBrief(p.hn).firstOrNull
                                                  case (
                                                    final k,
                                                    final st,
                                                    final c
                                                  ) when c != _ink3) ...[
                                                const SizedBox(width: 6.0),
                                                Flexible(
                                                  child: Tooltip(
                                                    message: '$k  $st',
                                                    child: Container(
                                                      height: 21.0,
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          5.0, 0.0, 8.0, 0.0),
                                                      decoration: BoxDecoration(
                                                        color: c.withValues(
                                                            alpha: 0.10),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                      ),
                                                      child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            // นาฬิกาจับเวลา fast track (ชุดเดียวกับป้ายแฟ้มในการ์ดผังเตียง)
                                                            const SizedBox(
                                                                width: 18.0,
                                                                height: 18.0,
                                                                child: CustomPaint(
                                                                    painter:
                                                                        _StopwatchArt(
                                                                            1.0))),
                                                            const SizedBox(
                                                                width: 2.0),
                                                            Flexible(
                                                              child: Text(
                                                                  // เหลือ n นาที / เกินเป้า n นาที (ตัดวงเล็บเวลา)
                                                                  st
                                                                      .split(
                                                                          ' (')
                                                                      .first,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: _t(
                                                                      11.0,
                                                                      color: c,
                                                                      weight: FontWeight
                                                                          .w700)),
                                                            ),
                                                          ]),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ]),
                                            Text(p.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: _t(16.0,
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
                                        // ESI = สายรัดข้อมือแบบเดียวกับการ์ดผังเตียง
                                        if (esiTag && p.esi != null) ...[
                                          SizedBox(
                                            // ย่อทั้งขนาดวาดและขนาด layout (Transform ไม่ลด layout = ล้นล่าง)
                                            height: 21.0,
                                            child: FittedBox(
                                                child: _esiBand(p, color)),
                                          ),
                                          const SizedBox(width: 6.0),
                                        ],
                                        Text('QN ${_qn(p)}',
                                            style: _num(11.5,
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
                                        final lab = _t(10.5,
                                            color: _ink3,
                                            weight: FontWeight.w500);
                                        final val = _t(12.5,
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
                      // รูปผู้ป่วยมุมขวาใหญ่ (ไม่มีภาพผู้ป่วยนอนเตียงแล้ว) คร่อมรอยต่อแถบหัวกับแผ่นขาว
                      Positioned(
                        right: 14.0,
                        bottom: 122.0 - 46.0,
                        child: _Rise(
                            index: k0 * 2 + 3,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 84.0,
                                  height: 84.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _panelSoft,
                                    // ขอบรูป = สี ESI เสมอ (สีบอกระดับ · ป้ายเตียงเป็นสีกลาง)
                                    // ขอบรูปขาว (ลดสี) · สี ESI อยู่ที่สายรัดข้อมือแล้ว
                                    border: Border.all(
                                        color: Colors.white, width: 3.0),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(_faceUrl(p.hn),
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, st) => const Icon(
                                            Icons.person_rounded,
                                            size: 36.0,
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
                                        style: _t(11.0,
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
    // หน้าภาพรวมย้ายรายชื่อไปหน้าต่างขวาของกระดาน (_overviewBoard) แล้ว
    if (_open == null) return const SizedBox.shrink();
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
            height: 184.0 + (_txtScale - 1.0) * 60.0,
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

  // การ์ดแจ้งเตือน (มีใบเดียวในแถบ) = ลูกศรลอยต่อเนื่อง ดึงสายตา
  // การ์ดอื่น (~9 ใบ) คลื่นวาดนิ่ง: ถ้าทุกใบขยับ รวมกันเกือบ 60fps ทั้งที่ไม่มีใครแตะ (วัดบน Xiaomi)
  // ticker หยุดเองเมื่อจอซ่อน (TickerMode)
  @override
  void initState() {
    super.initState();
    _drift.value = 0.35;
    if (widget.arrows) _drift.repeat();
    if (widget.items.length > 1) _next();
  }

  // ทุกการ์ดเปลี่ยนข้อความพร้อมกันตามนาฬิกา (ทุก 2.5 วิ) ต่างคนต่างจังหวะ
  // จะมีการ์ดเลื่อนอยู่ตลอด จอเลยไม่เคยได้พัก
  void _next() {
    const step = 2500;
    final ms = DateTime.now().millisecondsSinceEpoch;
    _t = Timer(Duration(milliseconds: step - ms % step), () {
      if (!mounted) return;
      setState(() => _i = (_i + 1) % widget.items.length);
      _next();
    });
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
                            ? widget.value.color
                            : widget.value.color?.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                if (cur.$2.isNotEmpty) ...[
                  if (n > 1) const SizedBox(width: 4.0),
                  Flexible(
                    child: Text(
                        cur.$2.startsWith('ครบ') || cur.$2.startsWith('ภายใน')
                            ? 'Fast track ${cur.$2}'
                            : 'ข้อมูลเมื่อ ${cur.$2}',
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
    final band = size.height - 102.0;
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
    if (widget.on) _hop();
  }

  // เด้งจบที่ 36% ของรอบ ช่วงที่เหลือพักด้วย Timer (ไม่ขอเฟรมเปล่า)
  Timer? _rest;
  void _hop() {
    _rest?.cancel();
    _c.value = 0.0;
    _c.animateTo(0.36).then((_) {
      if (!mounted || !widget.on) return;
      _rest = Timer(const Duration(milliseconds: 1400), () {
        if (mounted && widget.on) _hop();
      });
    });
  }

  @override
  void didUpdateWidget(_Breathe old) {
    super.didUpdateWidget(old);
    if (widget.on && !old.on) _hop();
    if (!widget.on && old.on) {
      _rest?.cancel();
      _c.stop();
    }
  }

  @override
  void dispose() {
    _rest?.cancel();
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

// ---------------------------------------------------------------- หน้าแรก ER (login)

/// ข้อความแบบ `_t` ของโมดูล (ใช้นอก state ได้)
TextStyle _lgT(double size,
        {Color color = _ink, FontWeight weight = FontWeight.w500}) =>
    TextStyle(
        fontFamily: _fontFam,
        fontFamilyFallback: _fontFb,
        fontSize: size * _txtScale,
        color: color,
        fontWeight: _minW(weight),
        height: _fontLineH,
        leadingDistribution: TextLeadingDistribution.even,
        fontFeatures: const [FontFeature.tabularFigures()]);

/// ฝั่งขวาหน้าแรก ER (Figma 1248-663): Star of Life กรมท่า (กรอบ 720 ล้นขอบขวา/ล่าง 140) + ภาพแพทย์
/// เปิดหน้า: ดาวขยายเข้ามา แล้วแพทย์ลอยขึ้นตาม · หัวโผล่พ้นขอบบนดาว ขอบล่างของภาพเลยจอ
/// ข้างหลัง = เงาสะท้อน (echo) ของดาว ใหญ่ขึ้นเป็นชั้น ๆ จางลงทีละชั้นจนเต็มหน้า · ขยายออกไล่จากในสู่นอกตอนเปิดหน้า
class ErLoginShowcase extends StatefulWidget {
  const ErLoginShowcase({super.key});

  @override
  State<ErLoginShowcase> createState() => _ErLoginShowcaseState();
}

class _ErLoginShowcaseState extends State<ErLoginShowcase>
    with TickerProviderStateMixin {
  /// appear (hero): เริ่มหลังหน้าเปลี่ยนเสร็จ 0.3 วิ · รวม 1.9 วิ
  /// ดาวเด้งขยายจากเล็ก (หมุนนิด) → echo กระจายออกทีละชั้น → แพทย์ลอยขึ้นจากล่าง
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1900));
  late final Timer _introGo = Timer(const Duration(milliseconds: 300), () {
    if (mounted) _intro.forward();
  });

  @override
  void initState() {
    super.initState();
    _introGo;
  }

  /// idle: จุด halftone กระเพื่อมเป็นคลื่นนุ่ม ๆ ออกจากดาว รอบละ 7 วิ (ทีละชั้น ชั้นในก่อน)
  late final AnimationController _breath =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))
        ..repeat();

  /// จุด halftone (ตำแหน่ง, ระยะจากดาวเป็นสเกล) คำนวณครั้งเดียวต่อขนาดจอ
  List<(Offset, double)> _dots = const [];
  Size _dotsFor = Size.zero;

  /// ตารางจุดทั้งจอ (แถวเหลื่อมครึ่งช่อง) · ระยะ = สเกลเล็กสุดของดาว (รอบจุดกลางดาว) ที่ครอบจุดนั้น
  /// อยู่ในดาวหลัก/ไกลเกิน 3.3 เท่า = ไม่มีจุด
  List<(Offset, double)> _buildDots(Size size, Rect star) {
    final base = _erStarPath(star);
    final c = star.center;
    const step = 14.0;
    final out = <(Offset, double)>[];
    for (var y = step / 2; y < size.height; y += step) {
      final shift = ((y / step).floor() % 2) * step / 2;
      for (var x = step / 2 + shift; x < size.width; x += step) {
        final pt = Offset(x, y);
        for (var sc = 1.04; sc <= 3.3; sc += 0.04) {
          if (base.contains(c + (pt - c) / sc)) {
            out.add((pt, sc));
            break;
          }
        }
      }
    }
    return out;
  }

  @override
  void dispose() {
    _introGo.cancel();
    _intro.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final still = MediaQuery.of(context).disableAnimations;
        // กรอบดาว 720: ขอบขวา/ล่างเลยจอ 140
        final ox = box.maxWidth - 580.0, oy = box.maxHeight - 580.0;
        return IgnorePointer(
          child: AnimatedBuilder(
            animation: _intro,
            builder: (context, _) {
              // ระบบลดการเคลื่อนไหว = แสดงครบทันที
              final t = still ? 1.0 : _intro.value;
              double seg(double a, double b, [Curve c = Curves.easeOutCubic]) =>
                  c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
              // ดาว: 0–45% เด้งขยาย · แพทย์: 35–90% ลอยขึ้น
              final ks = seg(0.0, 0.45, Curves.easeOutBack),
                  ka = seg(0.0, 0.25),
                  kd = seg(0.35, 0.9);
              final starRect = erLoginStarRect(box.biggest);
              if (_dotsFor != box.biggest) {
                _dotsFor = box.biggest;
                _dots = _buildDots(box.biggest, starRect);
              }

              return Stack(clipBehavior: Clip.none, children: [
                // echo แบบจุด halftone: วาดใหม่เฉพาะชั้นนี้ทุกเฟรม (ดาวกับภาพแพทย์ไม่ต้องวาดตาม)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _HalftoneEcho(
                          dots: _dots,
                          wave: _breath,
                          still: still,
                          // กระจายออกจากดาว: 25–95% ของ appear
                          reach: seg(0.25, 0.95)),
                    ),
                  ),
                ),
                // ดาว (Figma: ขอบ vector ในกรอบ 0.4% 0.17% 0.48% 0.69%)
                Positioned(
                  left: ox + 720.0 * 0.0069,
                  top: oy + 720.0 * 0.004,
                  width: 720.0 * (1 - 0.0069 - 0.0017),
                  height: 720.0 * (1 - 0.004 - 0.0048),
                  child: Opacity(
                    opacity: ka,
                    child: Transform.rotate(
                      angle: -0.12 * (1.0 - ks),
                      child: Transform.scale(
                        scale: 0.55 + 0.45 * ks,
                        child: Image.asset('assets/images/er_login_star.png',
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.medium),
                      ),
                    ),
                  ),
                ),
                // แพทย์ลอยขึ้นจากล่าง 90 พร้อมจางเข้า
                Positioned(
                  left: ox - 49.0,
                  top: oy - 86.0 + 90.0 * (1.0 - kd),
                  width: 680.0,
                  height: 680.0,
                  child: Opacity(
                    opacity: kd,
                    // idle: หายใจ · พยักหน้าเบา ๆ · กะพริบตา (ระบบลดการเคลื่อนไหว = นิ่ง)
                    child: _LoginDoctor(still: still),
                  ),
                ),
              ]);
            },
          ),
        );
      });
}

/// ป้ายบอกทางหน้าแรก ER: ชุดเดียวกับป้ายในหน้าแนะนำของ workflow panel (_waySignHero)
/// แผ่นป้ายแขวนสลิง หย่อนลงตอนเปิดหน้า + แสงวิ่งผ่านเป็นระยะ
class ErLoginSign extends StatefulWidget {
  const ErLoginSign(
      {super.key,
      this.name = 'แผนกห้องฉุกเฉิน',
      this.cable = 30.0,
      this.rowH = 50.0});

  final String name;

  /// ความยาวสลิงแขวน (แขวนจากขอบบนจอ = ยาวขึ้น)
  final double cable;

  /// ความสูงแผ่นป้าย (ขนาดตัวอักษร/ความกว้างปรับตามสัดส่วน · 50 = ขนาดในหน้าแนะนำ workflow)
  final double rowH;

  @override
  State<ErLoginSign> createState() => _ErLoginSignState();
}

/// idle: ป้ายแกว่งเบา ๆ รอบจุดแขวนกลางขอบบน (ลูกตุ้ม ±0.8° รอบละ 4.6 วิ) · ระบบลดการเคลื่อนไหว = นิ่ง
class _ErLoginSignState extends State<ErLoginSign>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sway = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 4600))
    ..repeat();

  @override
  void dispose() {
    _sway.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name, cable = widget.cable, rowH = widget.rowH;
    final k = rowH / 50.0;
    final base = _lgT(16.0 * k, color: Colors.white, weight: FontWeight.w700);
    final sign = SizedBox(
      width: 300.0 * k,
      height: cable + rowH + 12.0 * k,
      child: ClipRect(
        clipBehavior: Clip.none,
        child: _WaySign(
          names: [name],
          // ดอกจันแพทย์ (Star of Life) = สัญลักษณ์ห้องฉุกเฉิน
          icons: const [Icons.emergency_rounded],
          done: const [false],
          at: 0,
          busy: false,
          rowH: rowH,
          cable: cable,
          tilt: 0.75,
          depth: 0.0022 / k,
          style: base,
          numStyle: _lgT(9.5 * k, color: Colors.white),
        ),
      ),
    );
    if (MediaQuery.of(context).disableAnimations) return sign;
    return AnimatedBuilder(
      animation: _sway,
      child: sign,
      builder: (context, child) => Transform.rotate(
        alignment: Alignment.topCenter,
        angle: 0.014 * math.sin(_sway.value * 2 * math.pi),
        child: child,
      ),
    );
  }
}

/// echo ของ Star of Life แบบจุด halftone (หน้าแรก ER)
/// จุดเรียงเป็นชั้นดาวซ้อน 5 ชั้น: ขนาดจุดลดเป็นขั้นต่อชั้น (เห็นขอบดาวแต่ละชั้นชัด) + เล็กลงเนียน ๆ ในชั้น
/// สีไล่ตามระยะ กรมท่า (ใกล้ดาว) → ฟ้าอ่อน (ไกล) · idle: ทั้งชั้นกระเพื่อมนุ่ม ๆ ไล่จากในสู่นอก
/// [reach] = ระยะที่กระจายถึงตอนเปิดหน้า (0–1) · [still] = ระบบลดการเคลื่อนไหว (จุดนิ่ง)
class _HalftoneEcho extends CustomPainter {
  _HalftoneEcho(
      {required this.dots,
      required this.wave,
      required this.still,
      required this.reach})
      : super(repaint: wave);

  final List<(Offset, double)> dots;
  final Animation<double> wave;
  final bool still;
  final double reach;

  static const _layers = [1.34, 1.74, 2.2, 2.72, 3.3];
  static const _radii = [3.4, 2.7, 2.05, 1.5, 1.05];
  static const _navy = Color(0xFF001B7C);
  static const _sky = Color(0xFF7F97E8);

  @override
  void paint(Canvas canvas, Size size) {
    if (dots.isEmpty || reach <= 0.0) return;
    final t = still ? 0.0 : wave.value;
    final edge = 1.0 + 2.4 * reach;
    // สี/คลื่นต่อชั้น คำนวณครั้งเดียวต่อเฟรม
    final paints = [
      for (var i = 0; i < _layers.length; i++)
        Paint()
          ..color = Color.lerp(_navy, _sky, i / (_layers.length - 1))!
              .withValues(alpha: 0.24 - 0.03 * i),
    ];
    final waves = [
      for (var i = 0; i < _layers.length; i++)
        still ? 0.0 : math.sin((t - i * 0.14) * 2 * math.pi),
    ];
    for (final (pt, d) in dots) {
      if (d > edge) continue;
      final li = _layers.indexWhere((l) => d <= l);
      if (li < 0) continue;
      // ในชั้นเดียวกัน: ชิดขอบในใหญ่กว่าขอบนอกนิดหน่อย (ไล่เนียน ไม่แบน)
      final lo = li == 0 ? 1.0 : _layers[li - 1];
      final inLayer = (d - lo) / (_layers[li] - lo);
      final grow = ((edge - d) / 0.3).clamp(0.0, 1.0);
      final r =
          _radii[li] * (1.0 - 0.18 * inLayer) * (1.0 + 0.16 * waves[li]) * grow;
      if (r < 0.35) continue;
      canvas.drawCircle(pt, r, paints[li]);
    }
  }

  @override
  bool shouldRepaint(_HalftoneEcho old) =>
      old.dots != dots || old.reach != reach || old.still != still;
}

/// ตำแหน่งดาว Star of Life บนหน้าแรก ER (กรอบ 720 ล้นขอบขวา/ล่าง 140 · ขอบ vector ตาม Figma)
Rect erLoginStarRect(Size size) {
  final ox = size.width - 580.0, oy = size.height - 580.0;
  return Rect.fromLTWH(ox + 720.0 * 0.0069, oy + 720.0 * 0.004,
      720.0 * (1 - 0.0069 - 0.0017), 720.0 * (1 - 0.004 - 0.0048));
}

/// เส้นรูป Star of Life ในกรอบ [r] (ใช้นอก library เช่น transition หน้าแรก)
Path erStarPath(Rect r) => _erStarPath(r);

/// ภาพแพทย์หน้าแรก ER แบบมีชีวิต (idle วนรอบละ 12 วิ · ref คลิป Kling "A gentle…" 2026-11-24)
/// วาดจากภาพเดียวใน CustomPainter: ตัว = ภาพทั้งภาพเว้นช่วงหัว · หัว (ผม + หน้า เหนือคาง) = ชิ้นแยก หมุนรอบโคนคอ
/// ชิ้นหัวทับคอลงมา 6 px (joint patch) · ช่องที่หัวขยับเผยพื้นหลังจริง (ภาพโปร่ง)
/// motion: หายใจ (ยืดจากขอบล่าง 3 ครั้ง/รอบ) · ก้มมองแท็บเล็ตแล้วเงยกลับ + เอียงคอช้า ๆ · กะพริบตาแบบตาหยีลง (ref)
/// แสง: ไล่แสงทั้งตัว (บนซ้ายสว่าง ล่างขวาเย็น) · แสงฟ้าจากจอแท็บเล็ตตกบนมือและหน้า · rim light ขอบขวาบน
/// แก้มชมพูอ่อน · เงาใต้คางเข้มขึ้นตอนก้ม
class _LoginDoctor extends StatefulWidget {
  const _LoginDoctor({required this.still});
  final bool still;
  @override
  State<_LoginDoctor> createState() => _LoginDoctorState();
}

class _LoginDoctorState extends State<_LoginDoctor>
    with SingleTickerProviderStateMixin {
  static const _asset = 'assets/images/er_login_doctor.png';
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))
        ..repeat();
  ImageInfo? _img;
  ImageStream? _stream;
  // ภาพอยู่ใน cache แล้วจะเรียกกลับทันที (ระหว่าง build): ตั้งค่าใน microtask ไม่ setState ระหว่าง build
  late final ImageStreamListener _onImg = ImageStreamListener((info, _) {
    Future.microtask(() {
      if (mounted) setState(() => _img = info);
    });
  });

  void _resolve() {
    final st = const AssetImage(_asset)
        .resolve(createLocalImageConfiguration(context));
    if (st.key != _stream?.key) {
      _stream?.removeListener(_onImg);
      _stream = st..addListener(_onImg);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void dispose() {
    _stream?.removeListener(_onImg);
    _c.dispose();
    super.dispose();
  }

  /// ค่า 0–1–0 นุ่ม ๆ ในช่วงเวลา [a, a+len] วินาทีของรอบ
  static double _bump(double sec, double a, double len) {
    final u = (sec - a) / len;
    if (u <= 0.0 || u >= 1.0) return 0.0;
    final v = math.sin(math.pi * u);
    return v * v;
  }

  /// ความคืบหน้า 0–1 ในช่วง [at, at+len] วินาที (นอกช่วง = 0)
  static double _span(double sec, double at, double len) {
    final u = (sec - at) / len;
    return u <= 0.0 || u >= 1.0 ? 0.0 : u;
  }

  /// กะพริบแบบ ref (24 fps ≈ 0.4 วิ): หยีลง 3 เฟรม · หลับค้าง 3 เฟรม · ลืม 3–4 เฟรม
  static double _blinkAt(double sec, double at) {
    final t = sec - at;
    if (t <= 0.0 || t >= 0.4) return 0.0;
    if (t < 0.12) return Curves.easeIn.transform(t / 0.12);
    if (t < 0.24) return 1.0;
    return 1.0 - Curves.easeOut.transform((t - 0.24) / 0.16);
  }

  @override
  Widget build(BuildContext context) {
    // state เดิมจาก hot reload ไม่ผ่าน didChangeDependencies: โหลดภาพตอน build ครั้งแรก
    if (_stream == null) _resolve();
    final img = _img;
    if (img == null) {
      return Image.asset(_asset,
          fit: BoxFit.cover, filterQuality: FilterQuality.medium);
    }
    if (widget.still) {
      return CustomPaint(
          size: Size.infinite, painter: _DocPainter(img, 0, 0, 0, 0, 0, 0, 0));
    }
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final sec = _c.value * 12.0;
          // เรื่องตาม ref: ก้มดูแท็บเล็ต ยิ้มปากเปิด → กะพริบ → เงยหน้ามองผู้ใช้ คิ้วยกนิด ปากเปลี่ยนเป็นยิ้มปิด
          // → ค้าง (กะพริบอีกครั้ง) → ก้มกลับไปดูแท็บเล็ต ปากเปิด
          double ss(double a, double b) {
            final u = ((sec - a) / (b - a)).clamp(0.0, 1.0);
            return u * u * (3 - 2 * u);
          }

          final breath = 0.5 - 0.5 * math.cos(sec / 4.0 * 2 * math.pi);
          final sway = math.sin(sec / 12.0 * 2 * math.pi);
          final look = ss(3.3, 4.4) * (1.0 - ss(9.0, 10.2));
          final mouth = ss(3.6, 4.0) * (1.0 - ss(9.4, 9.8));
          final brow =
              math.max(_bump(sec, 3.4, 1.6), 0.6 * _bump(sec, 9.0, 1.2));
          final blink = math.max(_blinkAt(sec, 3.0),
              math.max(_blinkAt(sec, 7.0), _blinkAt(sec, 11.0)));
          // อ้อมมือไปแตะจอหลังเครื่อง ตอนก้มดูแท็บเล็ต (ต้นรอบ และหลังก้มกลับลงไป)
          final tap = math.max(_span(sec, 0.4, 1.8), _span(sec, 10.0, 1.8));
          return CustomPaint(
              size: Size.infinite,
              painter: _DocPainter(
                  img, breath, look, sway, blink, mouth, brow, tap));
        },
      ),
    );
  }
}

class _DocPainter extends CustomPainter {
  _DocPainter(this.img, this.breath, this.look, this.sway, this.blink,
      this.mouth, this.brow, this.tap);
  final ImageInfo img;

  /// look 0 = ก้มดูแท็บเล็ต (ท่าในภาพ) · 1 = เงยมองผู้ใช้ · mouth 0 = ยิ้มปากเปิด · 1 = ยิ้มปิด · brow = คิ้วยก
  final double breath, look, sway, blink, mouth, brow;

  /// tap = ความคืบหน้าท่าอ้อมมือไปแตะจอหลังเครื่อง (0 = ท่าในภาพ)
  final double tap;

  // พิกัดในภาพต้นฉบับ 1024 (วัดจากไฟล์)
  static const _src = 1024.0;
  static const _pivot = Offset(620.0, 400.0);
  static const _eyes = [
    Rect.fromLTRB(475.0, 246.0, 495.0, 277.0),
    Rect.fromLTRB(543.0, 226.0, 564.0, 257.0),
  ];
  static const _brows = [
    Rect.fromLTRB(455.0, 214.0, 488.0, 237.0),
    Rect.fromLTRB(523.0, 197.0, 569.0, 211.0),
  ];
  // ปากยิ้มเปิด (ปิดทับด้วยสีผิวตอนเปลี่ยนเป็นยิ้มปิด)
  static const _mouthPoly = [
    Offset(550.0, 283.0),
    Offset(567.0, 285.0),
    Offset(568.0, 300.0),
    Offset(563.0, 313.0),
    Offset(554.0, 323.0),
    Offset(521.0, 323.0),
    Offset(511.0, 314.0),
    Offset(510.0, 301.0),
    Offset(528.0, 293.0),
  ];
  // ปลายแขนเสื้อข้างมือที่ชี้จอ (อยู่หน้าข้อมือ): ขอบตามภาพ + พื้นที่แขนเสื้อด้านขวาล่าง
  static const _cuff = [
    Offset(563.0, 554.0),
    Offset(558.0, 570.0),
    Offset(554.0, 580.0),
    Offset(550.0, 590.0),
    Offset(546.0, 600.0),
    Offset(542.0, 610.0),
    Offset(539.0, 620.0),
    Offset(530.0, 645.0),
    Offset(500.0, 720.0),
    Offset(720.0, 720.0),
    Offset(720.0, 545.0),
  ];
  // มือขวาที่แตะจอ (นิ้ว ฝ่ามือ ข้อมือ) เว้นคอเสื้อวีด้านขวาบน · หมุนรอบข้อมือใต้แขนเสื้อ
  // rig แขน: ข้อมือ (ใต้ปลายแขนเสื้อ) · ข้อศอก (ปลายขวาของแขนเสื้อท่อนล่าง)
  static const _wrist = Offset(552.0, 590.0), _elbow = Offset(845.0, 695.0);
  // แขนเสื้อท่อนล่าง (ขอบซ้าย = ขอบปลายแขนเสื้อตามภาพ → ข้อศอกขวา) · บนเว้นเสื้อสครับ
  static const _sleeve = [
    Offset(563.0, 554.0),
    Offset(558.0, 570.0),
    Offset(554.0, 580.0),
    Offset(550.0, 590.0),
    Offset(546.0, 600.0),
    Offset(542.0, 610.0),
    Offset(539.0, 620.0),
    Offset(530.0, 645.0),
    Offset(524.0, 684.0),
    Offset(560.0, 728.0),
    Offset(700.0, 802.0),
    Offset(835.0, 808.0),
    Offset(905.0, 720.0),
    Offset(885.0, 600.0),
    Offset(760.0, 572.0),
    Offset(640.0, 562.0),
  ];
  // ขอบบนต่ำกว่าปลายผมที่ห้อยเหนือนิ้ว (ไม่ลากผมติดมือ)
  static const _handPoly = [
    Offset(366.0, 446.0),
    Offset(450.0, 452.0),
    Offset(500.0, 462.0),
    Offset(520.0, 470.0),
    Offset(575.0, 540.0),
    Offset(578.0, 640.0),
    Offset(366.0, 640.0),
  ];
  // แท็บเล็ต (มุมบนซ้าย บนขวา ล่างขวา ล่างซ้าย) ถอดจากภาพ
  static const _tablet = [
    Offset(206.0, 371.0),
    Offset(374.0, 323.0),
    Offset(457.0, 573.0),
    Offset(306.0, 594.0),
  ];

  /// สีผิวเป็นหน้ากาก (alpha จาก แดง−น้ำเงิน: ผิว ≈ 216 · ผม/เสื้อ/ปากด้านใน = 0) ระบายเป็นสี [c]
  /// [hard] = ขอบคม (alpha อิ่มเต็มเร็ว) สำหรับรูปเงาแบน
  /// ขอบนุ่ม (ไล่ alpha ตามสัดส่วนผิวในพิกเซลขอบ) = ขอบมือไม่หยัก · [hard] = ขยายเต็มถึงพิกเซลขอบ (ใช้ปิดของเดิม)
  static ColorFilter _skinMask(Color c, {bool hard = false}) =>
      ColorFilter.matrix([
        0, 0, 0, 0, (c.r * 255.0), //
        0, 0, 0, 0, (c.g * 255.0),
        0, 0, 0, 0, (c.b * 255.0),
        hard ? 5 : 2.2, 0, hard ? -5 : -2.2, 0, hard ? -40 : -23,
      ]);

  /// เฉพาะพิกเซลสีผิว สีเดิม (วาดมือทับเงาคืน)
  static const ColorFilter _skinOnly = ColorFilter.matrix([
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    2.2, 0, -2.2, 0, -23,
  ]);
  static const _skin = Color(0xFFFCB07E);
  static const _eye = Color(0xFF222F4E);

  double get _angle => 0.045 * look + 0.006 * sway;

  /// หายใจ: ยืดขึ้นจากขอบล่าง (ใช้ร่วมทุกชิ้นที่วาดแยก ให้ตรงกับตัว)
  void _breathe(Canvas canvas, double sz) {
    canvas.translate(0.0, sz);
    canvas.scale(1.0, 1.0 + 0.007 * breath);
    canvas.translate(0.0, -sz);
  }

  /// ตำแหน่งแต่ละชิ้นในตาข่าย ณ เฟรมนี้ (คำนวณครั้งเดียวต่อ paint ใช้ทุกรอบวาด)
  List<RSTransform>? _xf;

  /// rig แขน (ค่าต่อเฟรม): (ยืด/หดแขนท่อนล่างตามแนวแขน, หมุนรอบข้อศอก)
  late final (double, double) _armP = () {
    final (hx, hy, _, _) = _reach;
    if (hx == 0.0 && hy == 0.0) return (1.0, 0.0);
    final v0 = _wrist - _elbow, v1 = v0 + Offset(hx, hy);
    return (
      v1.distance / v0.distance,
      math.atan2(v1.dy, v1.dx) - math.atan2(v0.dy, v0.dx)
    );
  }();

  /// แขนท่อนล่าง (พิกัดภาพ): ยืด/หดตามแนวข้อศอก→ข้อมือ แล้วหมุนรอบข้อศอก
  /// หดแขน = แขนพับเข้าหาตัว (มุมมองย่อส่วน) · ข้อมือไปถึงเป้าพอดี
  Offset _foreXf(Offset p) {
    final (s, th) = _armP;
    if (s == 1.0 && th == 0.0) return p;
    final ax = _wrist - _elbow;
    final u = ax / ax.distance;
    final v = p - _elbow;
    final along = v.dx * u.dx + v.dy * u.dy;
    final sv = v + u * ((s - 1.0) * along);
    final c = math.cos(th), sn = math.sin(th);
    return _elbow + Offset(sv.dx * c - sv.dy * sn, sv.dx * sn + sv.dy * c);
  }

  List<RSTransform> _transforms(double k) {
    final a0 = _angle;
    final ty = -2.5 * look;
    return [
      for (var i = 0; i < _DocMeshV6.rects.length; i++)
        () {
          final w = _DocMeshV6.weights[i];
          final r = _DocMeshV6.rects[i];
          final c = _DocMeshV6.centers[i];
          if (w <= 0.0) {
            return RSTransform.fromComponents(
                rotation: 0.0,
                scale: k,
                anchorX: 0.0,
                anchorY: 0.0,
                translateX: r.left * k,
                translateY: r.top * k);
          }
          final a = a0 * w;
          final d = c - _pivot;
          final cs = math.cos(a), sn = math.sin(a);
          final dst = Offset(_pivot.dx + d.dx * cs - d.dy * sn,
                  _pivot.dy + d.dx * sn + d.dy * cs + ty * w) *
              k;
          return RSTransform.fromComponents(
              rotation: a,
              scale: k,
              anchorX: c.dx - r.left,
              anchorY: c.dy - r.top,
              translateX: dst.dx,
              translateY: dst.dy);
        }()
    ];
  }

  /// เมทริกซ์ rig แขนท่อนล่างบน canvas (พิกัด canvas = ภาพ × k): หมุนรอบข้อศอก + ยืด/หดตามแนวแขน
  Float64List _foreMatrix(double k) {
    final (s, th) = _armP;
    final ax = _wrist - _elbow;
    final u = ax / ax.distance;
    final a = 1.0 + (s - 1.0) * u.dx * u.dx,
        b = (s - 1.0) * u.dx * u.dy,
        d = 1.0 + (s - 1.0) * u.dy * u.dy;
    final c = math.cos(th), sn = math.sin(th);
    // R·S
    final m00 = c * a - sn * b, m01 = c * b - sn * d;
    final m10 = sn * a + c * b, m11 = sn * b + c * d;
    final e = _elbow * k;
    final tx = e.dx - (m00 * e.dx + m01 * e.dy);
    final ty = e.dy - (m10 * e.dx + m11 * e.dy);
    return Float64List.fromList([
      m00, m10, 0, 0, //
      m01, m11, 0, 0,
      0, 0, 1, 0,
      tx, ty, 0, 1,
    ]);
  }

  // ปากถอดจากภาพ (พิกัดภาพ 1024): มุมซ้าย/ขวา · ขอบบน = เส้นเกือบตรงเฉียงขึ้นขวา · ขอบล่าง = โค้งลง
  static const _mL = Offset(513.0, 305.0), _mR = Offset(563.0, 288.0);

  static Offset _q(Offset a, Offset c, Offset b, double t) =>
      a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);

  static Offset _cu(Offset a, Offset c1, Offset c2, Offset b, double t) {
    final u = 1 - t;
    return a * (u * u * u) +
        c1 * (3 * u * u * t) +
        c2 * (3 * u * t * t) +
        b * (t * t * t);
  }

  /// ขอบบนปากเปิด (ซ้าย → ขวา)
  static Offset _mTop(double t) => _q(_mL, const Offset(537.0, 298.5), _mR, t);

  /// ขอบล่างปากเปิด (ซ้าย → ขวา): 2 ช่วง ผ่านจุดต่ำสุด (535, 321.5)
  static Offset _mBot(double t) => t < 0.5
      ? _cu(_mL, const Offset(516.0, 313.0), const Offset(524.0, 320.0),
          const Offset(535.0, 321.5), t * 2)
      : _cu(const Offset(535.0, 321.5), const Offset(548.0, 323.0),
          const Offset(560.0, 312.0), _mR, t * 2 - 1);

  /// ยิ้มปิด (เส้นโค้งตกท้องช้าง แบบ ref)
  static Offset _mSmile(double t) => _q(const Offset(514.0, 303.0),
      const Offset(538.0, 313.0), const Offset(563.0, 288.0), t);

  /// ปาก m: 0 = ยิ้มปากเปิด (เหมือนภาพ) · 1 = ยิ้มปิด · ระหว่างนั้นขอบบน/ล่างยุบเข้าหาเส้นยิ้ม (morph)
  void _mouth(Canvas canvas, double k, double m) {
    const n = 18;
    final e = Curves.easeInOut.transform(m.clamp(0.0, 1.0));
    final top = [
      for (var i = 0; i <= n; i++)
        Offset.lerp(_mTop(i / n), _mSmile(i / n), e)! * k
    ];
    final bot = [
      for (var i = 0; i <= n; i++)
        Offset.lerp(_mBot(i / n), _mSmile(i / n), e)! * k
    ];
    final outer = Path()..addPolygon([...top, ...bot.reversed], true);
    if (e < 0.98) {
      canvas.drawPath(outer, Paint()..color = const Color(0xFF684D4A));
      // ลิ้น (มุมล่างขวา) ตามขอบล่าง ตัดในรูปปาก จางออกตอนปิด
      canvas.save();
      canvas.clipPath(outer);
      canvas.drawPath(
          Path()
            ..moveTo(533.0 * k, 322.0 * k)
            ..cubicTo(538.0 * k, 310.0 * k, 548.0 * k, 300.0 * k, 562.0 * k,
                297.0 * k)
            ..lineTo(566.0 * k, 330.0 * k)
            ..lineTo(530.0 * k, 330.0 * k)
            ..close(),
          Paint()..color = Color.fromRGBO(221, 92, 97, 1.0 - e));
      canvas.restore();
    }
    // เส้นริมฝีปากตอนเกือบปิด → ยิ้มปิด (สีชมพูอิฐแบบ ref)
    if (e > 0.55) {
      final line = Path()..addPolygon(top, false);
      canvas.drawPath(
          line,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 4.4 * k
            ..color = Color.lerp(const Color(0x00684D4A),
                const Color(0xFFC95E58), ((e - 0.55) / 0.45).clamp(0.0, 1.0))!);
    }
  }

  // ขอบหน้าซ้าย (ขมับ → ขากรรไกร → คาง) ถอดจากภาพ: ด้านที่หันหาจอแท็บเล็ต
  static const _jaw = [
    Offset(453.0, 236.0),
    Offset(457.0, 248.0),
    Offset(460.0, 256.0),
    Offset(463.0, 264.0),
    Offset(465.0, 272.0),
    Offset(468.0, 280.0),
    Offset(470.0, 288.0),
    Offset(473.0, 296.0),
    Offset(477.0, 304.0),
    Offset(481.0, 312.0),
    Offset(486.0, 320.0),
    Offset(492.0, 328.0),
    Offset(500.0, 336.0),
    Offset(510.0, 344.0),
    Offset(520.0, 350.0),
    Offset(532.0, 354.0),
  ];

  /// แสงจอสะท้อนขอบหน้า: แถบแบนรูปพระจันทร์เสี้ยวในขอบขากรรไกร (หนาสุดช่วงคาง เรียวสองปลาย) สีฟ้าอ่อน
  /// ภาษาเดียวกับเงาแบนในภาพ (ไม่ฟุ้ง) · อยู่ในชิ้นหัว ขยับตามหัว
  void _jawGlow(Canvas canvas, double k) {
    final n = _jaw.length;
    final outer = <Offset>[], inner = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = _jaw[math.max(0, i - 1)], b = _jaw[math.min(n - 1, i + 1)];
      final t = b - a;
      final nrm = Offset(t.dy, -t.dx) / t.distance;
      final u = i / (n - 1);
      final w = 7.0 * math.pow(math.sin(math.pi * u), 0.7) * (0.6 + 0.4 * u);
      outer.add((_jaw[i] + nrm * 0.8) * k);
      inner.add((_jaw[i] + nrm * (0.8 + w)) * k);
    }
    canvas.drawPath(Path()..addPolygon([...outer, ...inner.reversed], true),
        Paint()..color = const Color.fromRGBO(222, 240, 255, 0.62));
  }

  /// ท่าแตะจอ ตามความคืบหน้า [tap] 0–1 (จอหันหาแพทย์ เราเห็นหลังเครื่อง):
  /// แขนยื่นไปข้างหน้า มือเลื่อนเข้าหาจอ พร้อมกันนั้นขอบเครื่องค่อย ๆ บังนิ้ว (ปลายนิ้วหายก่อน = นิ้วลอดไปหลังเครื่อง)
  /// → จิ้มจอ 2 ครั้ง (ข้อมืองอนิด ปลายนิ้วกดลง) → ถอนมือกลับ ขอบเครื่องเปิดนิ้วคืนพร้อมกัน
  /// คืน (เลื่อน x, เลื่อน y เป็นพิกเซลภาพ, ขอบเครื่องบังนิ้วแค่ไหน 0–1, แรงจิ้ม 0–1)
  (double, double, double, double) get _reach {
    final t = tap;
    if (t <= 0.0 || t >= 1.0) return (0.0, 0.0, 0.0, 0.0);
    double e(double a, double b) =>
        Curves.easeInOutCubic.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
    const reachX = -14.0, reachY = -2.0;
    final out = e(0.0, 0.34) * (1.0 - e(0.76, 1.0));
    final u = ((t - 0.36) / 0.38).clamp(0.0, 1.0);
    final press = math.pow(math.sin(u * 2 * math.pi).abs(), 1.6).toDouble();
    // ขอบเครื่องเปิดนิ้วคืนช้ากว่าตอนบัง (เริ่มก่อนมือถอน) นิ้วค่อย ๆ โผล่ ไม่โผล่ทีเดียว
    final cover = e(0.0, 0.34) * (1.0 - e(0.66, 1.0));
    return (
      reachX * out - 4.0 * press,
      reachY * out + 1.5 * press,
      cover,
      press
    );
  }

  /// แท็บเล็ตวาดใหม่เป็นเวกเตอร์ (ถอดจากภาพ: สี่เหลี่ยมเอียงมุมมน · ขอบขวาสว่าง · จุดกล้อง)
  /// แล้ววาดมือซ้ายที่จับเครื่องทับคืน (นิ้วมือซ้ายอยู่หน้าเครื่อง)
  /// [cover] = วาดทับมือ: บังเฉพาะฝั่งซ้ายของเส้นที่ขนานขอบขวาเครื่อง เส้นเลื่อนจากในเครื่อง (0) ถึงขอบจริง (1)
  void _tabletAndLeftHand(Canvas canvas, double sz, double k, {double? cover}) {
    canvas.save();
    _breathe(canvas, sz);
    final body = _roundQuad([for (final p in _tablet) p * k], 15.0 * k);
    canvas.save();
    if (cover != null) {
      final tr = _tablet[1], d0 = _tablet[2] - _tablet[1];
      final d = d0 / d0.distance;
      final n = Offset(d.dy, -d.dx); // ชี้ออกขวาของขอบ
      final off = -(1.0 - cover) * 64.0;
      final a = tr + n * off - d * 1500.0, b = tr + n * off + d * 1500.0;
      canvas.clipPath(Path()
        ..addPolygon([
          a * k,
          b * k,
          (b - n * 3000.0) * k,
          (a - n * 3000.0) * k,
        ], true));
    }
    canvas.drawPath(body, Paint()..color = const Color(0xFFA4AABD));
    canvas.save();
    canvas.clipPath(body);
    canvas.drawLine(
        _tablet[1] * k,
        _tablet[2] * k,
        Paint()
          ..strokeWidth = 11.0 * k
          ..color = const Color(0xFFB0B4C4));
    canvas.restore();
    canvas.drawCircle(const Offset(229.3, 390.9) * k, 7.9 * k,
        Paint()..color = const Color(0xFF1F2844));
    canvas.restore();
    canvas.clipRect(Rect.fromLTRB(200.0 * k, 420.0 * k, 372.0 * k, 700.0 * k));
    _img(
        canvas,
        sz,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = _skinOnly);
    canvas.restore();
  }

  /// สี่เหลี่ยมจากมุม 4 จุด มุมมนรัศมี [r] (ตัดตามขอบแล้วโค้งผ่านมุม)
  static Path _roundQuad(List<Offset> q, double r) {
    final p = Path();
    for (var i = 0; i < 4; i++) {
      final prev = q[(i + 3) % 4], c = q[i], next = q[(i + 1) % 4];
      final a = c + (prev - c) / (prev - c).distance * r;
      final b = c + (next - c) / (next - c).distance * r;
      if (i == 0) {
        p.moveTo(a.dx, a.dy);
      } else {
        p.lineTo(a.dx, a.dy);
      }
      p.quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
    }
    return p..close();
  }

  /// ภาพทั้งภาพ (ไม่ผ่านตาข่าย: ช่วงมือ/แขนตาข่ายไม่ขยับอยู่แล้ว)
  void _img(Canvas canvas, double sz, Paint p) {
    final im = img.image;
    canvas.drawImageRect(
        im,
        Rect.fromLTWH(0, 0, im.width.toDouble(), im.height.toDouble()),
        Offset.zero & Size(sz, sz),
        p);
  }

  /// วาดทั้งตัว (ตัว + หัวที่ขยับ) ด้วย [p] · [detail] = เปลือกตา/แก้ม (เฉพาะรอบวาดสีจริง)
  void _figure(Canvas canvas, double sz, double k, Paint p,
      {bool detail = false}) {
    final im = img.image;
    canvas.save();
    _breathe(canvas, sz);
    // ทั้งตัวเป็นตาข่ายชิ้นเล็ก (drawAtlas): หัวหมุนรอบโคนคอเต็มองศา ค่อย ๆ ลดลงถึงศูนย์ที่ไหล่
    // ภาพงอต่อเนื่อง ไม่มีรอยตัดในผม/คอ (เดิมตัดหัวเป็นชิ้นแข็ง = เห็นรอยขาดตรงผม)
    canvas.drawAtlas(im, _xf ??= _transforms(k), _DocMeshV6.rects, null, null,
        null, p..filterQuality = FilterQuality.medium);
    // รายละเอียดหน้า (คิ้ว ปาก ตา แสง) ใช้การหมุนเต็มองศาของหัว
    final pv = _pivot * k;
    canvas.save();
    canvas.translate(pv.dx, pv.dy - 2.5 * k * look);
    canvas.rotate(_angle);
    canvas.translate(-pv.dx, -pv.dy);
    if (detail) {
      // แก้มชมพูอ่อน
      // แก้มซ้ายเยื้องเข้าในหน้า (เดิมเลยขอบหน้าไปติดผม เป็นจุดชมพูบนผม)
      for (final c in const [Offset(488.0, 300.0), Offset(590.0, 288.0)]) {
        canvas.drawCircle(
            c * k,
            26.0 * k,
            Paint()
              ..shader = const RadialGradient(colors: [
                Color(0x38F4877F),
                Color(0x00F4877F),
              ]).createShader(
                  Rect.fromCircle(center: c * k, radius: 26.0 * k)));
      }
      final skinP = Paint()..color = _skin;
      _jawGlow(canvas, k);
      // คิ้วยก: ปิดคิ้วเดิมด้วยสีผิว แล้ววาดคิ้ว (ชิ้นจากภาพ) สูงขึ้น
      if (brow > 0.01) {
        for (final b0 in _brows) {
          final b = Rect.fromLTRB(
              b0.left * k, b0.top * k, b0.right * k, b0.bottom * k);
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  b.inflate(2.0 * k), Radius.circular(6 * k)),
              skinP);
          canvas.save();
          canvas.translate(0.0, -4.0 * k * brow);
          canvas.clipRect(b);
          canvas.drawImageRect(
              im,
              Rect.fromLTWH(0, 0, im.width.toDouble(), im.height.toDouble()),
              Offset.zero & Size(sz, sz),
              Paint()..filterQuality = FilterQuality.medium);
          canvas.restore();
        }
      }
      // ปาก: วาดเองเป็นเวกเตอร์ (ถอดรูปจากภาพ) ปิดปากเดิมด้วยสีผิวเสมอ แล้ว morph ปากเปิด ↔ ยิ้มปิด
      canvas.drawPath(
          Path()..addPolygon([for (final p in _mouthPoly) p * k], true), skinP);
      _mouth(canvas, k, mouth);
      // กะพริบแบบ ref: ตาหดลงหาเปลือกล่าง → หลับเป็นเส้นโค้งคว่ำ (แนวเดียวกับคิ้ว) กว้างกว่าตานิด → ลืม
      if (blink > 0.0) {
        for (final e0 in _eyes) {
          final e = Rect.fromLTRB(
              e0.left * k, e0.top * k, e0.right * k, e0.bottom * k);
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  e.inflate(2.5 * k), Radius.circular(e.width)),
              skinP);
          if (blink < 0.7) {
            final h = e.height * (1.0 - blink * 1.15);
            final w = e.width * (1.0 - 0.12 * blink);
            final bottom = e.bottom - e.height * 0.18 * blink;
            canvas.drawOval(
                Rect.fromLTRB(e.center.dx - w / 2, bottom - h,
                    e.center.dx + w / 2, bottom),
                Paint()..color = _eye);
          } else {
            final y = e.top + e.height * 0.66;
            final w = e.width * 0.68;
            canvas.drawPath(
                Path()
                  ..moveTo(e.center.dx - w, y + e.height * 0.05)
                  ..quadraticBezierTo(e.center.dx, y - e.height * 0.16,
                      e.center.dx + w, y + e.height * 0.05),
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeCap = StrokeCap.round
                  ..strokeWidth = e.width * 0.24
                  ..color = _eye);
          }
        }
      }
      // แสงจอแท็บเล็ตสะท้อนในตา: วงรีทรงเดียวกับตา (เล็กกว่า) ฟ้าขาว ด้านที่หันหาจอ (ล่างซ้าย) + จุดเล็กขวาบน
      if (blink < 0.35) {
        final o = ((1.0 - blink / 0.35) * 0.9).clamp(0.0, 1.0);
        for (final e0 in _eyes) {
          final e = Rect.fromLTRB(
              e0.left * k, e0.top * k, e0.right * k, e0.bottom * k);
          canvas.drawOval(
              Rect.fromCenter(
                  center:
                      Offset(e.left + e.width * 0.37, e.top + e.height * 0.63),
                  width: e.width * 0.36,
                  height: e.height * 0.36),
              Paint()..color = Color.fromRGBO(214, 236, 255, o));
          canvas.drawOval(
              Rect.fromCenter(
                  center:
                      Offset(e.left + e.width * 0.66, e.top + e.height * 0.28),
                  width: e.width * 0.16,
                  height: e.height * 0.16),
              Paint()..color = Color.fromRGBO(255, 255, 255, o * 0.8));
        }
      }
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sz = size.shortestSide;
    final k = sz / _src;
    final all = Offset.zero & Size(sz, sz);
    final base = Paint()..filterQuality = FilterQuality.medium;

    // 1) สีจริง + แสงทั้งหมด วาดทับเฉพาะในตัว (srcATop)
    canvas.saveLayer(all, Paint());
    _figure(canvas, sz, k, base, detail: true);
    // เงามือที่ชี้จอตกบนเสื้อ แบบภาษาภาพ (เงาแบน ขอบคม สีเงาเสื้อ ไม่ฟุ้ง):
    // รูปมือ (หน้ากากสีผิว) เลื่อนขวาล่าง (แสงหลักจากซ้ายบน) คูณสีลงบนเสื้อ แล้ววาดมือทับคืน
    final sh = Offset(9.0 * k, 13.0 * k);
    final handP = Path()..addPolygon([for (final p in _handPoly) p * k], true);
    final (_, _, cover, press) = _reach;
    final th = _armP.$2;
    final moving = th != 0.0 || _armP.$1 != 1.0;
    // ปลายแขนเสื้อตาม rig (อยู่หน้าข้อมือเสมอ)
    final cuffNow = Path.combine(PathOperation.difference, Path()..addRect(all),
        Path()..addPolygon([for (final p in _cuff) _foreXf(p) * k], true));
    final w1 = _foreXf(_wrist);
    // มือ: ติดข้อมือ หมุนตามแขนท่อนล่าง (ไม่ย่อตามแขน)
    void handXf() {
      canvas.translate(w1.dx * k, w1.dy * k);
      // จิ้มจอ: ข้อมืองอนิด ปลายนิ้วกดลง
      canvas.rotate(th - 0.03 * press);
      canvas.translate(-_wrist.dx * k, -_wrist.dy * k);
    }

    final (hx, hy, _, _) = _reach;
    final shift = math.sqrt(hx * hx + hy * hy);
    if (moving) {
      // ที่เดิมของมือ (นอกเครื่อง) = เสื้อกาวน์ + สายหูฟังที่ลอดใต้มือ · ในเครื่อง = แท็บเล็ตเวกเตอร์
      // จางเข้าตามระยะที่มือขยับ: ขยับนิดเดียว (จิ้มจอหลังเครื่อง) = มือเดิมยังรองอยู่ ไม่เห็นขอบขาว
      canvas.saveLayer(
          all,
          Paint()
            ..color = Color.fromRGBO(0, 0, 0, (shift / 8.0).clamp(0.0, 1.0)));
      _breathe(canvas, sz);
      canvas.clipPath(handP);
      _img(
          canvas,
          sz,
          Paint()
            ..colorFilter = _skinMask(const Color(0xFFF7F8FC), hard: true));
      // เหนือนิ้วนอกเครื่องเป็นพื้นหลังโปร่ง (เห็นดาวกรมท่า) ไม่ใช่เสื้อ: ลบออกแทนทาขาว
      canvas.save();
      canvas
          .clipRect(Rect.fromLTRB(415.0 * k, 440.0 * k, 450.0 * k, 478.0 * k));
      _img(
          canvas,
          sz,
          Paint()
            ..blendMode = BlendMode.dstOut
            ..colorFilter = _skinMask(const Color(0xFF000000), hard: true));
      canvas.restore();
      // เสื้อสครับที่อยู่หลังมือ (ขอบซ้ายของคอวีลากต่อลงใต้มือ) · ทาเฉพาะที่เดิมของมือ
      canvas.save();
      canvas.clipPath(Path()
        ..addPolygon([
          const Offset(562.0, 436.0) * k,
          const Offset(531.0, 524.0) * k,
          const Offset(529.0, 560.0) * k,
          const Offset(522.0, 640.0) * k,
          const Offset(600.0, 640.0) * k,
          const Offset(620.0, 436.0) * k,
        ], true));
      _img(
          canvas,
          sz,
          Paint()
            ..colorFilter = _skinMask(const Color(0xFF4A81ED), hard: true));
      canvas.restore();
      // สายหูฟังแพทย์ที่ลอดใต้มือ (ถอดแนวจากภาพ: เข้าใต้มือที่ 498,490 ออกที่ 479,596)
      canvas.drawPath(
          Path()
            ..moveTo(509.0 * k, 460.0 * k)
            ..lineTo(499.0 * k, 488.0 * k)
            ..quadraticBezierTo(487.0 * k, 540.0 * k, 479.0 * k, 598.0 * k),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 13.0 * k
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xFF223254));
      canvas.restore();
      // ที่เดิมของแขนเสื้อ (โผล่เมื่อแขนหด/หมุน): เสื้อกาวน์ขาว + แถบเสื้อสครับแนวตั้งที่ลอดใต้แขน
      // (ไม่เหลือขอบปลายแขนเสื้อเดิมซ้อนเป็นสองชั้น)
      canvas.save();
      _breathe(canvas, sz);
      canvas
          .clipPath(Path()..addPolygon([for (final p in _sleeve) p * k], true));
      canvas.drawRect(all, Paint()..color = const Color(0xFFF8F8FD));
      canvas.drawPath(
          Path()
            ..addPolygon([
              const Offset(515.0, 556.0) * k,
              const Offset(604.0, 552.0) * k,
              const Offset(604.0, 810.0) * k,
              const Offset(495.0, 810.0) * k,
              const Offset(510.0, 640.0) * k,
            ], true),
          Paint()
            ..shader = const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4A81ED), Color(0xFF3B71E0)])
                .createShader(Rect.fromLTRB(0, 560.0 * k, sz, 760.0 * k)));
      canvas.restore();
      // แขนเสื้อท่อนล่างเป็นชิ้นแข็ง หมุน/หดรอบข้อศอก
      canvas.save();
      _breathe(canvas, sz);
      canvas.transform(_foreMatrix(k));
      canvas
          .clipPath(Path()..addPolygon([for (final p in _sleeve) p * k], true));
      _img(canvas, sz, Paint()..filterQuality = FilterQuality.medium);
      canvas.restore();
    }
    // เงามือ (แบน ขอบคม) ตามมือ
    canvas.saveLayer(all, Paint()..blendMode = BlendMode.multiply);
    _breathe(canvas, sz);
    canvas.clipPath(cuffNow);
    canvas.translate(sh.dx, sh.dy);
    handXf();
    canvas.clipPath(handP);
    _img(canvas, sz,
        Paint()..colorFilter = _skinMask(const Color(0xFFC7D1EC), hard: true));
    canvas.restore();
    // แท็บเล็ตเวกเตอร์วาดเสมอ (ไม่สลับภาพเดิม↔เวกเตอร์ตอนเริ่มขยับ = ไม่กระพริบ)
    _tabletAndLeftHand(canvas, sz, k);
    // มือขวาทั้งมือ
    canvas.save();
    _breathe(canvas, sz);
    canvas.clipPath(cuffNow);
    handXf();
    canvas.clipPath(handP);
    _img(
        canvas,
        sz,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = _skinOnly);
    canvas.restore();
    // มืออ้อมไปหลังเครื่อง (จอหันหาแพทย์): แท็บเล็ตบังนิ้วที่จิ้มจอ
    if (cover > 0.0) _tabletAndLeftHand(canvas, sz, k, cover: cover);

    // ไล่แสงทั้งตัว: บนซ้ายอุ่นสว่าง → ล่างขวาเงาเย็น
    canvas.drawRect(
        all,
        Paint()
          ..blendMode = BlendMode.srcATop
          ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x1FFFF4E6),
                Color(0x00FFFFFF),
                Color(0x00FFFFFF),
                Color(0x2E1A2A6E),
              ],
              stops: [
                0.0,
                0.38,
                0.62,
                1.0
              ]).createShader(all));
    // แสงจากจอแท็บเล็ต: จอหันหาหน้าแพทย์ (เราเห็นหลังเครื่อง มีจุดกล้อง) แสงจึงพุ่งออกจากขอบจอด้านที่หันหาเธอ
    // เป็นลำแสงทรงกรวยจากขอบบน/ขวาของเครื่องไปทางหน้า (จางตามระยะ) · หลังเครื่องไม่เรือง
    final tab = Path()..addPolygon([for (final p in _tablet) p * k], true);
    final cone = Path()
      ..addPolygon([
        const Offset(300.0, 345.0) * k,
        const Offset(374.0, 323.0) * k,
        const Offset(412.0, 438.0) * k,
        const Offset(690.0, 398.0) * k,
        const Offset(470.0, 130.0) * k,
      ], true);
    // ขอบลำแสงฟุ้ง (แสงไม่มีขอบคม · เดิมขอบกรวยตัดผมเป็นเส้นตรง) · เงายังเป็นแบบแบนขอบคม
    canvas.saveLayer(
        all,
        Paint()
          ..blendMode = BlendMode.srcATop
          ..imageFilter =
              ui.ImageFilter.blur(sigmaX: 16.0 * k, sigmaY: 16.0 * k));
    canvas.clipPath(
        Path.combine(PathOperation.difference, Path()..addRect(all), tab));
    canvas.drawPath(
        cone,
        Paint()
          ..shader = LinearGradient(
              begin: Alignment(-0.27 + 0.0, 0.0),
              end: const Alignment(0.12, -0.55),
              colors: [
                Color.fromRGBO(205, 234, 255, 0.5 + 0.06 * (1.0 - look)),
                const Color.fromRGBO(205, 234, 255, 0.16),
                const Color.fromRGBO(205, 234, 255, 0.0),
              ],
              stops: const [
                0.0,
                0.45,
                1.0
              ]).createShader(all));
    // ผมสีเข้ม/หูฟังแพทย์ รับแสงแค่ประกายนิด (ไม่เป็นหมอกบนผม): ลบลำแสงตามหน้ากากความเข้ม
    _figure(
        canvas,
        sz,
        k,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..colorFilter = const ColorFilter.matrix([
            0, 0, 0, 0, 0, //
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            -1.6, -1.6, -1.6, 0, 520,
          ]));
    canvas.restore();
    canvas.restore();

    // 2) rim light (แสงย้อนจากหลังขวาบน) แบบแสงจริง:
    //    แถบบางที่ขอบ สว่างสุดที่ขอบแล้วจางเข้าใน (ซ้อน 2 ชั้น: บางสว่าง + กว้างจาง)
    //    บวกแสงแบบ screen = ผมสีเข้มติดประกายฟ้า เสื้อกาวน์ขาวแทบไม่เปลี่ยน
    //    แรงเฉพาะด้านที่หันหาแสง (ขวา/บน) จางหายไปทางซ้าย ไม่เป็นเส้นขอบรอบตัว
    canvas.saveLayer(all, Paint()..blendMode = BlendMode.screen);
    void band(double d, double alpha) {
      canvas.saveLayer(all, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
      _figure(
          canvas,
          sz,
          k,
          Paint()
            ..filterQuality = FilterQuality.medium
            ..colorFilter =
                const ColorFilter.mode(Color(0xFFB9D4FF), BlendMode.srcIn));
      canvas.save();
      // แสงมาจากขวาเฉียงบน: ลบด้วยตัวที่เลื่อนไปทางซ้ายลงเล็กน้อย
      canvas.translate(-d, d * 0.45);
      _figure(
          canvas,
          sz,
          k,
          Paint()
            ..filterQuality = FilterQuality.medium
            ..blendMode = BlendMode.dstOut);
      canvas.restore();
      canvas.restore();
    }

    band(2.0, 0.75);
    band(6.0, 0.22);
    // ทิศแสง: ซ้าย = ไม่มี rim · ขวา = เต็ม · ขอบบนหัวได้บ้าง
    canvas.drawRect(
        all,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = const LinearGradient(
                  begin: Alignment(-0.2, 0.3),
                  end: Alignment(0.75, -0.35),
                  colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)])
              .createShader(all));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DocPainter old) =>
      old.img != img ||
      old.breath != breath ||
      old.look != look ||
      old.tap != tap ||
      old.mouth != mouth ||
      old.brow != brow ||
      old.sway != sway ||
      old.blink != blink;
}

/// ตาข่ายของภาพแพทย์ (พิกัดภาพ 1024): ช่อง 8 px ช่วงหัว–ไหล่ (x 380–1024, y 0–472) + ชิ้นตัวนิ่ง 2 ชิ้น
/// น้ำหนักหัว: เต็มเหนือคาง งอนุ่มช่วงคอ–ไหล่ (y 330–470) · กันแท็บเล็ตเฉพาะใต้มุมบนของเครื่อง
/// ช่องขยายขอบ 2 px ทับกัน ไม่เห็นเส้นรอยต่อ · แขนใช้ชิ้นแข็ง (rig) ไม่อยู่ในตาข่าย
class _DocMeshV6 {
  static const _cell = 8.0;
  static double _ss(double u) {
    final v = u.clamp(0.0, 1.0);
    return v * v * (3 - 2 * v);
  }

  static const _tab = [
    Offset(206.0, 371.0),
    Offset(374.0, 323.0),
    Offset(457.0, 573.0),
    Offset(306.0, 594.0),
  ];

  static double _distTab(Offset p) {
    var inside = false;
    var best = double.infinity;
    for (var i = 0, j = _tab.length - 1; i < _tab.length; j = i++) {
      final a = _tab[i], b = _tab[j];
      if ((a.dy > p.dy) != (b.dy > p.dy) &&
          p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx) {
        inside = !inside;
      }
      final ab = b - a;
      final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) /
              (ab.dx * ab.dx + ab.dy * ab.dy))
          .clamp(0.0, 1.0);
      best = math.min(best, (p - (a + ab * t)).distance);
    }
    return inside ? 0.0 : best;
  }

  static double _w(Offset c) {
    final near = 1.0 - _ss((_distTab(c) - 12.0) / 78.0);
    final gate = _ss((c.dy - 300.0) / 40.0);
    return _ss((470.0 - c.dy) / 140.0) * (1.0 - near * gate);
  }

  static final List<Rect> rects = () {
    final out = <Rect>[];
    for (var y = 0.0; y < 472.0; y += _cell) {
      for (var x = 380.0; x < 1024.0; x += _cell) {
        out.add(Rect.fromLTRB(
                x, y, math.min(x + _cell, 1024.0), math.min(y + _cell, 472.0))
            .inflate(2.0));
      }
    }
    out.add(const Rect.fromLTRB(0.0, 0.0, 382.0, 1024.0));
    out.add(const Rect.fromLTRB(378.0, 470.0, 1024.0, 1024.0));
    return out;
  }();

  static final List<Offset> centers = [for (final r in rects) r.center];

  static final List<double> weights = [
    for (var i = 0; i < rects.length; i++)
      i >= rects.length - 2 ? 0.0 : _w(centers[i])
  ];
}
