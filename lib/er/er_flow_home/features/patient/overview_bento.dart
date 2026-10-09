// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// แท็บที่เลือกในการ์ดคำสั่งแพทย์ (bento): true = Fast track
bool _bentoFastTab = false;

/// แฟ้มที่เลือกในเมนู Fast track (หน้ารายละเอียด)
String _ftTabSel = '';

/// KPI ที่กางคำอธิบายอยู่ในลู่เวลา (ชื่อ KPI)
String? _ftKpiOpen;

/// สีชุด Fast track: แดงเร่งด่วน (แยกจากแดงค่าผิดปกติทั่วไป)
const _ftRed = Color(0xFFD93025);
const _ftRedDeep = Color(0xFFA50E0E);
const _ftRedSoft = Color(0xFFFCE8E6);

// ------------------------------------------------ แท็บภาพรวมแบบ bento
// ขนาดช่องตามความสำคัญข้างเตียง: V/S เต็มแถว · CC/HPI ใหญ่ + ช่องเล็ก
// (งานติดตาม · X-ray · วินิจฉัย) · Lab เต็มแถว · แผน + ทางลัด EMR/Progress note

extension _FeaturesPatientOverviewBentoPart on _ErFlowHomeWidgetState {
  /// เรียงผล lab อัตโนมัติ: ผิดปกติก่อน → ตัวเลขปกติ → ข้อความ → รูป
  /// (คงลำดับเดิมในกลุ่มเดียวกัน) · eGFR อยู่หัวเสมอเมื่อเปิด profile ไต
  List<ErLab> _sortLabs(List<ErLab> labs) {
    int rank(ErLab l) => l.name == 'eGFR'
        ? -1
        : l.abnormal
            ? 0
            : l.isNumeric
                ? 1
                : (l.type == ErLabType.image ? 3 : 2);
    return [
      for (final r in [-1, 0, 1, 2, 3])
        for (final l in labs)
          if (rank(l) == r) l
    ];
  }

  /// แผงขวาของแท็บภาพรวม · แคบกว่า 560 = คอลัมน์เดียว
  Widget _clyBento() => LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 640.0;
        // fill: การ์ดใหญ่สูงเต็มเท่าคอลัมน์ข้าง (IntrinsicHeight + stretch)
        Widget pair(Widget big, List<Widget> side,
                {int bigFlex = 3, bool fill = false}) =>
            wide
                ? _bentoRow(fill, [
                    Expanded(flex: bigFlex, child: big),
                    const SizedBox(width: 10.0),
                    Expanded(
                      flex: 2,
                      child: Column(children: [
                        for (var i = 0; i < side.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10.0),
                          side[i],
                        ],
                      ]),
                    ),
                  ])
                : Column(children: [
                    big,
                    for (final s in side) ...[const SizedBox(height: 10.0), s],
                  ]);
        return ListView(
          padding: const EdgeInsets.all(12.0),
          children: _appearAll([
            if (_aovOn) ...[
              _aiOverview(),
              const SizedBox(height: 10.0),
            ],
            _clyVitals(),
            const SizedBox(height: 10.0),
            // fast track ที่เปิดอยู่ (ไม่มี = ไม่แสดงช่องนี้)
            if (_ftOf(_caseP().hn).isNotEmpty) ...[
              _bentoFastTrack(),
              const SizedBox(height: 10.0),
            ],
            pair(_clyCc(), [_bentoTasks(), _bentoXray(), _bentoDx()],
                bigFlex: 2, fill: true),
            const SizedBox(height: 10.0),
            _clyLabs(),
            const SizedBox(height: 10.0),
            // ไม่มีแผนการดูแลและแถบขั้นถัดไป (ผู้ใช้ให้เอาออก) · EMR คู่ Progress note
            wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _bentoEmr()),
                    const SizedBox(width: 10.0),
                    Expanded(child: _bentoProgress()),
                  ])
                : Column(children: [
                    _bentoEmr(),
                    const SizedBox(height: 10.0),
                    _bentoProgress(),
                  ]),
          ]),
        );
      });

  /// ช่อง bento Fast track: แฟ้มละช่อง · เวลาตั้งแต่เปิด · บันทึกแล้วกี่จุด
  /// จุดถัดไปที่ต้องบันทึก + เป้า (เกินเป้า = แดง) · แตะ = แท็บ Fast track ในการ์ดคำสั่ง
  /// ชื่อแท็บ: แท็บ Fast track มีสายฟ้านำหน้า และเป็นสีแดงเสมอ
  Widget _ftTabLabel(String label, int n, bool on, bool fast, double size) {
    final c = fast ? _ftRed : (on ? _blue : _ink2);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (fast) ...[
        Icon(Icons.bolt_rounded, size: size + 4.0, color: c),
        const SizedBox(width: 2.0),
      ],
      Text('$label  $n',
          style: _t(size,
              color: c,
              weight: on || fast ? FontWeight.w700 : FontWeight.w500)),
    ]);
  }

  /// แท็บ Fast track: แฟ้มละการ์ด = หัว (ไอคอน ชื่อ เวลาเปิด นาฬิกา)
  /// + เป้าหมายเวลา (KPI) พร้อมสถานะ + รายการบันทึกเวลา (แตะแถว = บันทึก)
  Widget _ftTabBody() {
    final hn = _caseP().hn;
    final open = _ftOf(hn).entries.toList();
    final tasks = _fastTasks(hn);
    final now = DateTime.now();
    if (open.isEmpty) {
      return Center(
        child: Text('เคสนี้ยังไม่ได้เปิด Fast track',
            style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
      );
    }
    String hm(int m) => m >= 60
        ? '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')} ชม.'
        : '$m นาที';

    Widget card(ErFastTrack t, DateTime since) {
      final mine = [
        for (final x in tasks)
          if (x.detail.startsWith(t.name)) x
      ];
      final done = mine.where((x) => _taskDone.contains(x.title)).length;
      // เวลาของจุดหนึ่ง: มาถึง ER = เวลาเปิดแฟ้ม · อื่น ๆ = เวลาที่บันทึก
      DateTime? timeOf(String id) {
        if (id == erFtDoor.id) return since;
        final it = t.items.where((i) => i.id == id).firstOrNull;
        if (it == null) return null;
        return _taskDoneAt[it.label] ?? _taskDoneAt['${it.label} (${t.name})'];
      }

      String nameOf(String id) => id == erFtDoor.id
          ? 'มาถึง'
          : t.items.where((i) => i.id == id).firstOrNull?.label ?? id;

      Widget label(String s) => Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 4.0),
            child:
                Text(s, style: _t(13.0, color: _ink2, weight: FontWeight.w600)),
          );

      final crit = _ftCriteria[hn]?[t.id] ?? const <String>[];
      Widget section(String title, String sub, Widget child) => Container(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 16.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFDADCE0)),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(title,
                          style: _t(16.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    Text(sub,
                        style: _t(12.5, color: _ink3, weight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 12.0),
                  child,
                ]),
          );
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // เหตุผลที่เปิดแฟ้ม (เกณฑ์จากหน้าคัดกรอง)
        Text(
            crit.isEmpty
                ? 'เข้าเกณฑ์: ไม่ได้ระบุ'
                : 'เข้าเกณฑ์: ${crit.join(', ')}',
            style: _t(13.0,
                color: crit.isEmpty ? _ink3 : _ftRedDeep,
                weight: FontWeight.w600)),
        const SizedBox(height: 12.0),
        if (t.kpis.isNotEmpty) ...[
          section(
              'เป้าหมายเวลา (KPI)',
              'เปิดมาแล้ว ${hm(now.difference(since).inMinutes)}',
              _ftKpiChart(t, since, timeOf, nameOf, now)),
          const SizedBox(height: 12.0),
        ],
        section(
            'บันทึกเวลา',
            'บันทึกแล้ว $done จาก ${mine.length} จุด',
            Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final x in mine) _taskCheckRow(x)])),
      ]);
    }

    // แท็บ Google ต่อแฟ้ม (แบบหน้ากิจกรรมพยาบาล) · หัวหน้า/รูป ใช้ _clyInfoPage
    final ids = [
      for (final e in open)
        if (erFastTrackById(e.key) != null) e.key
    ];
    if (!ids.contains(_ftTabSel)) _ftTabSel = ids.first;
    Widget tab(String id) {
      final on = _ftTabSel == id;
      return _Press(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            setState(() => _ftTabSel = id);
          },
          child: IntrinsicWidth(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 9.0),
                    child: Text(erFastTrackById(id)!.name,
                        textAlign: TextAlign.center,
                        style: _t(14.0,
                            color: on ? _blue : _ink2,
                            weight: on ? FontWeight.w600 : FontWeight.w500)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: on ? _blue : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3.0)),
                    ),
                  ),
                ]),
          ),
        ),
      );
    }

    final sel = open.firstWhere((e) => e.key == _ftTabSel);
    return _clyInfoPage(
      'Fast track',
      'ติดตามเวลาสำคัญตามเป้าการรักษา',
      'ft',
      const [],
      by: 'พยาบาลคัดกรอง',
      at: _taskClock(sel.value),
      heroArt:
          const SizedBox(width: 100.0, height: 110.0, child: _StopwatchHero()),
      below: Transform.translate(
        offset: const Offset(-12.0, 0.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [for (final id in ids) tab(id)]),
        ),
      ),
      extra: [
        KeyedSubtree(
            key: ValueKey('ft-$_ftTabSel'),
            child: card(erFastTrackById(_ftTabSel)!, sel.value)),
      ],
    );
  }

  /// เป้าหมายเวลาแบบลู่เวลา (แกนนาฬิกาจริงร่วมกันทุกแถว) อ่านง่าย:
  /// ซ้าย = ชื่อ KPI + วัดจากไหนถึงไหน · กลาง = แถบเวลา · ขวา = ผลเป็นคำพูด
  /// แถบ: เทา = ช่วงที่ยังทันเป้า (ปลายมีธง) · สีเต็ม = เวลาที่ใช้จริง
  /// น้ำเงิน = กำลังนับ · เขียว = เสร็จทันเป้า · แดง = เกินเป้า
  Widget _ftKpiChart(
      ErFastTrack t,
      DateTime since,
      DateTime? Function(String) timeOf,
      String Function(String) nameOf,
      DateTime now) {
    final lanes = [
      for (final k in t.kpis)
        if (!k.before) (k, timeOf(k.from), timeOf(k.to))
    ];
    // แกนเวลา: ตั้งแต่เหตุการณ์แรกสุดถึงตอนนี้/ธงไกลสุด
    var lo = since, hi = now;
    for (final (k, a, b) in lanes) {
      if (a != null && a.isBefore(lo)) lo = a;
      if (b != null && b.isBefore(lo)) lo = b;
      if (a != null && k.maxMin != null) {
        final g = a.add(Duration(minutes: k.maxMin!));
        if (g.isAfter(hi)) hi = g;
      }
    }
    final span = math.max(30.0, hi.difference(lo).inSeconds / 60.0 * 1.06);
    double at(DateTime d) => d.difference(lo).inSeconds / 60.0;
    // ขีดแกนทุกชั่วโมง/ครึ่งชั่วโมงเป็นเวลานาฬิกาจริง
    final step = span <= 90
        ? 15
        : span <= 240
            ? 30
            : 60;
    final first = lo.add(Duration(minutes: step - lo.minute % step));
    final ticks = <DateTime>[
      for (var d = DateTime(
              first.year, first.month, first.day, first.hour, first.minute);
          at(d) <= span;
          d = d.add(Duration(minutes: step)))
        d
    ];

    (String, Color) verdict(ErFtKpi k, DateTime? a, DateTime? b) {
      if (a == null) return ('รอ${nameOf(k.from)}', _ink3);
      if (b != null && b.isBefore(a)) return ('เวลาไม่ต่อเนื่อง', _ftRed);
      final m = (b ?? now).difference(a).inMinutes;
      final max = k.maxMin;
      if (max == null)
        return (b == null ? 'นับอยู่ $m นาที' : 'ใช้ $m นาที', _ink2);
      if (m > max) return ('เกินเป้า ${m - max} นาที', _ftRed);
      if (b != null) return ('ทันเป้า ใช้ $m นาที', _green);
      return ('เหลือ ${max - m} นาที', _blue);
    }

    int rank((ErFtKpi, DateTime?, DateTime?) l) {
      final (k, a, b) = l;
      if (a == null) return 3;
      final m = (b ?? now).difference(a).inMinutes;
      if (k.maxMin != null && m > k.maxMin! && !(b != null && b.isBefore(a))) {
        return 0;
      }
      return b == null ? 1 : 2;
    }

    lanes.sort((x, y) => rank(x).compareTo(rank(y)));
    const labelW = 190.0, resultW = 120.0;
    // คำอธิบายเมื่อกดแถว: วัดอะไร เริ่ม/จบกี่โมง ต้องเสร็จภายในกี่โมง ผล และที่มา
    Widget detail(ErFtKpi k, DateTime? a, DateTime? b, String v, Color c) {
      final bad = a != null && b != null && b.isBefore(a);
      final due = a == null || k.maxMin == null
          ? null
          : a.add(Duration(minutes: k.maxMin!));
      Widget kv(String key, String val, [Color? col]) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 120.0,
                child: Text(key,
                    style: _t(12.5, color: _ink2, weight: FontWeight.w500)),
              ),
              Expanded(
                child: Text(val,
                    style: _t(13.0,
                        color: col ?? _inkTitle, weight: FontWeight.w600)),
              ),
            ]),
          );
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 10.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ประโยคอธิบาย | อ้างอิงเล็ก ๆ มุมขวาบน (FYI)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(
                  'วัดเวลาตั้งแต่${nameOf(k.from)} จนถึง${nameOf(k.to)}'
                  '${k.maxMin == null ? ' (ติดตามอย่างเดียว ไม่มีเป้า)' : ' ควรไม่เกิน ${k.maxMin} นาที'}',
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
            ),
            const SizedBox(width: 12.0),
            Text('อ้างอิง: ${k.source}',
                style: _t(11.5, color: _ink3, weight: FontWeight.w500)),
          ]),
          const SizedBox(height: 6.0),
          // คีย์สั้น ชื่อเหตุการณ์ไปอยู่ฝั่งค่า (ไม่ตัดบรรทัด)
          kv('เริ่มนับ',
              '${nameOf(k.from)}  ${a == null ? 'ยังไม่บันทึก' : _taskClock(a)}'),
          kv('ปลายทาง',
              '${nameOf(k.to)}  ${b == null ? 'ยังไม่บันทึก' : _taskClock(b)}'),
          if (due != null && b == null)
            kv('ต้องเสร็จภายใน', _taskClock(due),
                now.isAfter(due) ? _ftRed : _blue),
          kv('ผล', bad ? 'เวลาปลายทางมาก่อนเวลาเริ่ม ตรวจสอบเวลาที่บันทึก' : v,
              c),
        ]),
      );
    }

    Widget lane((ErFtKpi, DateTime?, DateTime?) l) {
      final (k, a, b) = l;
      final (v, c) = verdict(k, a, b);
      final bad = a != null && b != null && b.isBefore(a);
      final open = _ftKpiOpen == k.label;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _ftKpiOpen = open ? null : k.label);
          },
          child: SizedBox(
            height: 52.0,
            child: Row(children: [
              SizedBox(
                width: labelW,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          k.maxMin == null
                              ? k.label
                              : '${k.label}  ≤ ${k.maxMin} นาที',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(13.5,
                              color: _inkTitle, weight: FontWeight.w600)),
                      Text('${nameOf(k.from)} ถึง ${nameOf(k.to)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              _t(11.5, color: _ink3, weight: FontWeight.w500)),
                    ]),
              ),
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _FtLanePainter(
                    span: span,
                    now: at(now),
                    start: a == null || bad ? null : at(a),
                    end: b == null || bad ? null : at(b),
                    target: k.maxMin?.toDouble(),
                  ),
                ),
              ),
              SizedBox(
                width: resultW,
                child: Text(v,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    style: _t(13.0, color: c, weight: FontWeight.w700)),
              ),
              AnimatedRotation(
                turns: open ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 220),
                child: const Icon(Icons.expand_more_rounded,
                    size: 20.0, color: _ink3),
              ),
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: open
              ? detail(k, a, b, v, c)
              : const SizedBox(width: double.infinity),
        ),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // แกนเวลา: เวลานาฬิกาจริง + ป้ายตอนนี้
      SizedBox(
        height: 24.0,
        child: Row(children: [
          const SizedBox(width: labelW),
          Expanded(
            child: LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth;
              double x(DateTime d) => at(d) / span * w;
              final nx = x(now);
              return Stack(clipBehavior: Clip.none, children: [
                for (final d in ticks)
                  if ((x(d) - nx).abs() > 56)
                    Positioned(
                      left: x(d) - 30,
                      width: 60,
                      bottom: 4.0,
                      child: Text(_taskClock(d),
                          textAlign: TextAlign.center,
                          style: _num(11.0,
                              color: _ink3, weight: FontWeight.w500)),
                    ),
                Positioned(
                  left: (nx - 48).clamp(0.0, w - 96),
                  width: 96.0,
                  bottom: 2.0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7.0, vertical: 1.0),
                      decoration: BoxDecoration(
                          color: _ftRed,
                          borderRadius: BorderRadius.circular(100.0)),
                      child: Text('ตอนนี้ ${_taskClock(now)}',
                          style: _t(11.0,
                              color: Colors.white, weight: FontWeight.w600)),
                    ),
                  ),
                ),
              ]);
            }),
          ),
          const SizedBox(width: resultW + 20.0),
        ]),
      ),
      for (final (i, l) in lanes.indexed) ...[
        if (i > 0) const Divider(height: 1.0, color: Color(0xFFF1F3F4)),
        lane(l),
      ],
      const SizedBox(height: 8.0),
      Wrap(spacing: 16.0, runSpacing: 4.0, children: [
        for (final (Color c, String s) in const [
          (Color(0xFFE6F4EA), 'ช่วงที่ยังทันเป้า (ปลายมีธง)'),
          (Color(0xFF1A73E8), 'กำลังนับ'),
          (Color(0xFF1E9E5A), 'เสร็จทันเป้า'),
          (Color(0xFFD93025), 'เกินเป้า'),
        ])
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 14.0,
              height: 8.0,
              decoration: BoxDecoration(
                  color: c, borderRadius: BorderRadius.circular(4.0)),
            ),
            const SizedBox(width: 5.0),
            Text(s, style: _t(11.5, color: _ink2, weight: FontWeight.w500)),
          ]),
      ]),
    ]);
  }

  /// ไอคอนประจำแฟ้ม fast track (ชุดเดียวกับการ์ดในหน้าคัดกรอง)
  static const _ftIcons = {
    'stroke': Icons.psychology_outlined,
    'stemi': Icons.monitor_heart_outlined,
    'sepsis': Icons.coronavirus_outlined,
    'trauma': Icons.car_crash_outlined,
    'head': Icons.personal_injury_outlined,
  };

  Widget _bentoFastTrack() {
    final hn = _caseP().hn;
    final now = DateTime.now();
    final tasks = _fastTasks(hn);
    Widget cell(ErFastTrack t, DateTime since) {
      final mine = [
        for (final x in tasks)
          if (x.detail.startsWith(t.name)) x
      ];
      final done = mine.where((x) => _taskDone.contains(x.title)).length;
      final next = mine.where((x) => !_taskDone.contains(x.title)).firstOrNull;
      final m = now.difference(since).inMinutes;
      final dur = m >= 60
          ? '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')} ชม.'
          : '$m นาที';
      // เป้าของจุดถัดไป (นับจากเวลาเปิด) · เกิน = แดง
      final goal = RegExp(r'≤ (\d+) นาที').firstMatch(next?.detail ?? '');
      final limit = goal == null ? null : int.parse(goal.group(1)!);
      final over = limit != null && m > limit;
      // แบบกะทัดรัด: แฟ้มละช่องเรียงข้างกัน คั่นเส้นตั้ง (ไม่กินความสูง)
      // ไอคอนวงโทนอ่อน | ชื่อ + เวลา / จุดถัดไป + สถานะ · แดงเฉพาะเมื่อเกินเป้า
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: const BoxDecoration(
                  color: _ftRedSoft, shape: BoxShape.circle),
              child: Icon(_ftIcons[t.id] ?? Icons.bolt_rounded,
                  size: 17.0, color: _ftRed),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(t.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(14.0,
                                color: _inkTitle, weight: FontWeight.w600)),
                      ),
                      Text(dur,
                          style: _num(14.0,
                              color: _inkTitle, weight: FontWeight.w600)),
                    ]),
                    const SizedBox(height: 1.0),
                    Text(
                        next == null
                            ? 'บันทึกครบ ${mine.length} จุดแล้ว'
                            : limit != null && over
                                ? 'เกินเป้า ${m - limit} นาที  ต่อไป: ${next.title}'
                                : 'ต่อไป: ${next.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0,
                            color: over && next != null ? _ftRed : _ink2,
                            weight: FontWeight.w500)),
                  ]),
            ),
          ]),
        ),
      );
    }

    final open = _ftOf(hn).entries.toList();
    return _bentoTile(
      icon: Icons.bolt_rounded,
      accent: _ftRed,
      title: 'Fast track',
      count: '${open.length} แฟ้ม',
      // แตะช่อง = ไปเมนู Fast track (KPI + บันทึกเวลาเต็มหน้า)
      onTap: () => setState(() {
        _tabDir = 1;
        _detailTab = _ftTab;
      }),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final (k, e) in open.indexed) ...[
            if (k > 0)
              const VerticalDivider(
                  width: 24.0, thickness: 1.0, color: Color(0xFFE8EAED)),
            if (erFastTrackById(e.key) case final t?) cell(t, e.value),
          ],
        ]),
      ),
    );
  }

  Widget _bentoRow(bool fill, List<Widget> children) => fill
      ? IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children))
      : Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);

  /// ช่อง bento มาตรฐาน: หัว (ไอคอน · ชื่อ · ตัวนับ ›) + เนื้อหา · แตะเพื่อไปแท็บเต็ม
  Widget _bentoTile({
    required IconData icon,
    required String title,
    String count = '',
    required Widget child,
    VoidCallback? onTap,
    bool dark = false,
    Color? accent,
  }) {
    final fg = dark ? Colors.white : _inkTitle;
    return _Press(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 16.0),
          decoration: dark
              ? BoxDecoration(
                  gradient: _glossGrad(_blue),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: _glossLift(_blue),
                )
              : _clyCardDeco,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Icon(icon,
                    size: 18.0, color: dark ? Colors.white : accent ?? _blue),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(title,
                      style: _t(15.0, color: fg, weight: FontWeight.w600)),
                ),
                if (count.isNotEmpty)
                  Text(count,
                      style: _num(11.0,
                          color: dark ? Colors.white : _ink3,
                          weight: FontWeight.w600)),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 16.0, color: dark ? Colors.white : _ink3),
              ]),
              const SizedBox(height: 8.0),
              child,
            ],
          ),
        ),
      ),
    );
  }

  /// X-ray: แกลเลอรีสูงสุด 3 ภาพ · แตะภาพ = ดูเต็มจอ · แตะหัว = แท็บ X-ray
  Widget _bentoXray() {
    final imgs = _case.imaging;
    final show = imgs.take(3).toList();
    Widget thumb(int i) => _Press(
          child: GestureDetector(
            onTap: () => _xrayView(imgs, i),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(show[i].asset,
                      height: 72.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          height: 72.0,
                          color: _panelSoft,
                          child: const Icon(Icons.image_not_supported_outlined,
                              color: _ink3))),
                ),
                const SizedBox(height: 4.0),
                Text(show[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.5, color: _inkTitle, weight: FontWeight.w700)),
                Text(show[i].result,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(9.5, color: _ink2)),
              ],
            ),
          ),
        );
    return _bentoTile(
      icon: Icons.image_rounded,
      title: 'X-ray',
      count: imgs.isEmpty ? '' : '${imgs.length}',
      onTap: () => setState(() => _detailTab = _xrayTab),
      child: imgs.isEmpty
          ? Text('ยังไม่ได้ส่งภาพถ่าย', style: _t(11.0, color: _ink3))
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 6.0),
                // ช่องว่างคงที่ 3 ช่อง ภาพน้อยกว่า 3 ก็ขนาดเท่าเดิม
                Expanded(child: i < show.length ? thumb(i) : const SizedBox()),
              ],
            ]),
    );
  }

  /// งานที่ต้องติดตาม แบบ to-do: แถบกรมท่าด้านบน (ชื่อซ้าย วันที่ขวา) แผ่นขาวซ้อนทับ
  /// แถว = ช่องติ๊ก · ชื่องาน · เวลาสั่ง/รอบวัด · ปุ่มเตือน
  Widget _bentoTasks() {
    // แท็บในการ์ด: คำสั่งแพทย์ทั่วไป / เวลาสำคัญ fast track (ตามประเภทผู้ป่วย)
    final fastAll = _fastTasks(_caseP().hn);
    final fastTitles = {for (final t in fastAll) t.title};
    final onFast = _bentoFastTab && fastAll.isNotEmpty;
    // Fast track คงลำดับตาม HOSxP (ไม่เรียงใหม่)
    final tasks = onFast
        ? fastAll
        : _sortTasks([
            for (final t in _allTasks)
              if (!fastTitles.contains(t.title)) t
          ], inPlace: true);
    final left = [
      for (final t in tasks)
        if (!_taskDone.contains(t.title)) t
    ];
    final allDone = tasks.isNotEmpty && left.isEmpty;
    final now = DateTime.now();
    const days = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์'
    ];
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', //
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    final date = 'วัน${days[now.weekday - 1]} ${now.day} '
        '${months[now.month - 1]} ${now.year + 543}';

    // แพทย์ผู้สั่ง (ไม่ซ้ำ ตามลำดับที่พบ) เป็นบรรทัดรองใต้หัวการ์ด
    final doctors = <String>[
      for (final t in tasks)
        if (t.by.isNotEmpty) t.by
    ].toSet().toList();
    final band = Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // หัวการ์ดตามแท็บที่เลือก
            Text(onFast ? 'เวลาสำคัญ Fast track' : 'คำสั่งแพทย์',
                style: _t(17.0,
                    color: allDone
                        ? _green
                        : onFast
                            ? _ftRed
                            : _inkTitle,
                    weight: FontWeight.w700)),
            if (onFast || doctors.isNotEmpty) ...[
              const SizedBox(height: 2.0),
              // Fast track: บอกความคืบหน้าการบันทึกเวลา (แบบการ์ดบนฉากเตียง)
              Text(
                  onFast
                      ? 'บันทึกเวลาแล้ว ${tasks.length - left.length} จาก ${tasks.length}'
                      : doctors.join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
            ],
          ]),
        ),
        // เว้นที่ให้ภาพแฟ้ม (วาดแยกด้านหลังการ์ดคำสั่ง)
        const SizedBox(width: 92.0),
      ]),
    );

    // Google style (แบบ Google Tasks): รายการที่ต้องทำก่อน · เสร็จแล้วรวมเป็นกลุ่มท้าย
    // ไม่มีลายจุด/ป้ายสี · แถวเรียบ มีเส้นคั่นบาง
    final doneList = [
      for (final t in tasks)
        if (_taskDone.contains(t.title)) t
    ];
    // แท็บแบบ Google (ขีดใต้แท็บที่เลือก) · ไม่มีงาน fast track = ไม่แสดงแท็บ
    Widget tab(String label, int n, bool on, bool fast) => Expanded(
          child: InkWell(
            onTap: on
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    setState(() => _bentoFastTab = fast);
                  },
            child: Container(
              height: 44.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: on
                          ? (fast ? _ftRed : _blue)
                          : const Color(0xFFDADCE0),
                      width: on ? 3.0 : 1.0),
                ),
              ),
              child: _ftTabLabel(label, n, on, fast, 13.0),
            ),
          ),
        );
    final pending = (bool fast) => _allTasks
        .where((t) =>
            fastTitles.contains(t.title) == fast &&
            !_taskDone.contains(t.title))
        .length;
    final tabs = fastAll.isEmpty
        ? null
        // พื้นขาวทับภาพแฟ้มด้านหลัง (ไม่ให้แฟ้มบังชื่อแท็บ)
        : Container(
            color: _panel,
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 0.0),
            child: Row(children: [
              tab('คำสั่ง', pending(false), !onFast, false),
              tab('Fast track', pending(true), onFast, true),
            ]),
          );
    final sheet =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final t in left) _taskCheckRow(t),
      if (doneList.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 16.0, 4.0),
          child: Text('เสร็จแล้ว ${doneList.length} รายการ',
              style: _t(12.0, color: _ink2, weight: FontWeight.w600)),
        ),
        for (final t in doneList) _taskCheckRow(t),
      ],
      const SizedBox(height: 4.0),
      // ท้ายการ์ด: ลิงก์ข้อความสีฟ้าแบบ Google
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
          child: TextButton(
            onPressed: () => setState(() => _detailTab = 3),
            child: Text('ดูทั้งหมดในคำสั่งแพทย์',
                style: _t(12.5, color: _blue, weight: FontWeight.w600)),
          ),
        ),
      ),
    ]);

    // การ์ดขาวขอบเทาแบบหน้าคัดกรอง (หัวไม่ใช่แถบกรมท่าทึบ)
    return Container(
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
      ),
      // ขอบวาดทับลูก (แถบแท็บพื้นขาวไม่บังเส้นขอบมุมบน)
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDADCE0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        // ภาพแฟ้มหนีบกระดาษใหญ่ เอียงแบบ perspective อยู่หลังการ์ดงาน
        // ปลายล่างจมใต้การ์ดงานใบแรก (แบบรูป hero หน้าส่งตรวจ)
        Positioned(
          right: 18.0,
          // แท็บอยู่บนสุด: แฟ้มเลื่อนลงไปข้างหัวการ์ด
          top: tabs == null ? 8.0 : 56.0,
          width: 80.0,
          height: 93.0,
          // เข้าฉาก + วน: แฟ้มโผล่ขึ้นครั้งเดียว แล้วเช็ก/ข้อความวาดเข้าซ้ำเป็นรอบ
          // แท็บ Fast track = นาฬิกาจับเวลา · คำสั่ง = แฟ้มหนีบกระดาษ
          child: onFast
              ? const _StopwatchHero(key: ValueKey('sw'))
              : const _ClipboardHero(key: ValueKey('cb')),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // แท็บบนสุดของการ์ด แล้วตามด้วยหัวการ์ด
          if (tabs != null) tabs,
          band,
          sheet,
        ]),
      ]),
    );
  }

  String _taskClock(DateTime d) => _clock(
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}');

  /// แถวงาน: ชื่องาน · เวลาสั่ง/รอบวัด · ปุ่ม "รับคำสั่ง" ขวาสุด (ไม่มีปุ่มเตือน/ตรวจซ้ำ)
  /// เสร็จแล้ว = ชื่อสีจาง + ใครทำ/เวลาเสร็จ + ป้ายเขียว "เสร็จแล้ว"
  /// compact = แถวเดียวเตี้ย (การ์ดในผังเตียง): ชื่อ 1 บรรทัด + เวลาต่อท้ายเล็ก วงติ๊กเล็ก
  Widget _taskCheckRow(_Task t, {bool compact = false}) {
    final done = _taskDone.contains(t.title);
    final at = _taskDoneAt[t.title];
    final rec = _taskRounds[_roundKey(t)];
    final partial = !done && rec != null && rec.isNotEmpty;
    // ไม่บอกผู้ทำในการ์ดนี้ (ดูได้ในแท็บคำสั่งแพทย์) เหลือแค่รอบ/เวลา
    final meta = partial
        ? 'รอบ ${rec.length} เสร็จ ${_taskClock(rec.last.$2)}'
        : done
            ? 'เสร็จ${at == null ? '' : ' ${_taskClock(at)}'}'
            : t.detail.startsWith('รอบที่')
                ? 'วัด ${_clock(t.time)} ${t.detail}'
                // fast track: แฟ้ม + เป้าเวลา
                : t.time.isEmpty
                    ? t.detail
                    : 'สั่ง ${_clock(t.time)}';
    final metaColor = done ? _ink3 : _ink2;
    // แต่ละคำสั่งอยู่ในการ์ดพื้น surface (เทาฟ้าอ่อน) มุมโค้ง 12
    // แตะได้ทั้งการ์ด = รับคำสั่ง (ยังไม่เสร็จ)
    return _Press(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: done ? null : () => _taskAcceptSheet(t),
            child: Container(
              margin: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, compact ? 6.0 : 8.0),
              padding: compact
                  ? const EdgeInsets.fromLTRB(12.0, 6.0, 4.0, 6.0)
                  : const EdgeInsets.fromLTRB(14.0, 8.0, 6.0, 8.0),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.title,
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: _t(13.0,
                                  // ชื่อสีปกติ · ด่วนบอกด้วย chip แดงเล็กท้ายบรรทัดรอง (แดงไม่ท่วมแถว)
                                  color: done ? _ink3 : _inkTitle,
                                  weight:
                                      done ? FontWeight.w500 : FontWeight.w600,
                                  height: 1.25)
                              .copyWith(
                                  decoration:
                                      done ? TextDecoration.lineThrough : null,
                                  decorationColor: _ink3)),
                      SizedBox(height: compact ? 0.0 : 2.0),
                      Row(children: [
                        Flexible(
                          child: Text(meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(11.0,
                                  color: metaColor, weight: FontWeight.w500)),
                        ),
                        // ด่วน = ไฟไซเรน 3D (ErSiren3D ชุดเดียวกับปุ่มส่ง RESUS) แทน chip
                        if (!done && t.urgent) ...[
                          const SizedBox(width: 6.0),
                          // ขยายโมเดลเต็มกล่อง (ค่าตั้งต้น 0.63 เผื่อที่ว่างรอบตัว)
                          const SizedBox(
                              width: 24.0,
                              height: 18.0,
                              child: ErSiren3D(
                                  pose: (-0.13, -1.98, -0.2, 1.15),
                                  glow: false)),
                        ],
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                // ขวา: วงติ๊กแทนปุ่ม · แตะวงว่าง = รับคำสั่ง (กดค้างยืนยัน) · เสร็จ = เช็กเขียว
                IgnorePointer(
                  child: GestureDetector(
                    child: SizedBox(
                      width: compact ? 30.0 : 40.0,
                      height: compact ? 30.0 : 40.0,
                      child: Icon(
                          done
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: compact ? 20.0 : 26.0,
                          color: done ? _green : _ink3),
                    ),
                  ),
                ),
              ]),
            )));
  }

  /// รับคำสั่ง: อธิบายว่าจะบันทึกอะไร แล้วเลื่อน "ทำเสร็จ" เพื่อยืนยัน
  void _taskAcceptSheet(_Task t) {
    final name = _taskDoer;
    final now = DateTime.now();
    // ครบแล้ว = ค้าง sheet ไว้ แถบหัวไล่สีเขียว + confetti แล้วค่อยปิด
    var celebrate = false;
    // เวลาที่กรอกเอง (ทำไปก่อนแล้วมาบันทึกทีหลัง) · null = ใช้เวลาจริงตอนกดยืนยัน
    DateTime? manual;
    final hm = t.time.split(':');
    final ordered = hm.length == 2
        ? DateTime(now.year, now.month, now.day, int.tryParse(hm[0]) ?? 0,
            int.tryParse(hm[1]) ?? 0)
        : null;
    final mins = ordered == null ? null : now.difference(ordered).inMinutes;
    final ago = t.time.isEmpty
        ? 'Fast track'
        : mins == null || mins < 0
            ? 'สั่งเมื่อ ${_clock(t.time)}'
            : mins < 60
                ? 'สั่งเมื่อ $mins นาทีที่ผ่านมา'
                : 'สั่งเมื่อ ${mins ~/ 60} ชม. ${mins % 60} นาทีที่ผ่านมา';
    _placedSheet<void>(
      context: context,
      // bottom sheet กว้างไม่เกิน 580 และอยู่กลางจอ
      constraints: const BoxConstraints(maxWidth: 580.0),
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final rounds = _taskRoundInfo(t);
        final round = rounds == null
            ? null
            : ((rounds.cur + 1).clamp(1, rounds.n), rounds.n);
        final onDark = celebrate;
        // หัวข้อชิดซ้าย · ค่าชิดขวา (ไม่มีไอคอน)
        Widget line(String k, String v, {bool first = false}) => Padding(
              padding: EdgeInsets.only(top: first ? 0.0 : 8.0),
              child: Row(children: [
                Text(k, style: _t(12.0, color: _ink3)),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(v,
                      textAlign: TextAlign.right,
                      style:
                          _t(12.5, color: _inkTitle, weight: FontWeight.w600)),
                ),
              ]),
            );
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // แถบหัวตาม Figma (HOSXP V6 ER 322:1006): ภาพประกอบซ้าย ·
                // รับคำสั่งแพทย์ · ชื่องาน + ป้ายรอบ · สั่งเมื่อกี่นาที · ลำดับขั้นเป็นวงกลม
                Stack(clipBehavior: Clip.none, children: [
                  Container(
                    height: rounds == null ? 184.0 : 206.0,
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(children: [
                      // ไล่สีเขียวจากซ้ายไปขวาเมื่อทำครบ
                      Positioned.fill(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: celebrate ? 1.0 : 0.0),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeInOutCubic,
                          builder: (context, v, _) => Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: v,
                              heightFactor: 1.0,
                              child: const ColoredBox(color: _green),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Image.asset('assets/images/order_accept.png',
                              height: 172.0, fit: BoxFit.contain),
                          const SizedBox(width: 18.0),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  0.0, 20.0, 20.0, 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // บรรทัดบน: หัวข้อซ้าย · สั่งเมื่อ มุมขวาบน
                                  Row(children: [
                                    Text(
                                        celebrate
                                            ? 'ทำครบแล้ว'
                                            : 'รับคำสั่งแพทย์',
                                        style: _t(12.0,
                                            color:
                                                onDark ? Colors.white : _ink2,
                                            weight: FontWeight.w600)),
                                    const Spacer(),
                                    Icon(Icons.schedule_rounded,
                                        size: 13.0,
                                        color: onDark ? Colors.white70 : _ink3),
                                    const SizedBox(width: 3.0),
                                    Text(ago,
                                        style: _t(11.0,
                                            color:
                                                onDark ? Colors.white70 : _ink2,
                                            weight: FontWeight.w500)),
                                  ]),
                                  const SizedBox(height: 4.0),
                                  Text(t.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(19.0,
                                          color: onDark
                                              ? Colors.white
                                              : (t.urgent ? _red : _inkTitle),
                                          weight: FontWeight.w700,
                                          height: 1.2)),
                                  // รอบปัจจุบันเป็นข้อความใต้ชื่อคำสั่ง
                                  if (round != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                          celebrate
                                              ? 'ครบ ${round.$2} รอบ'
                                              : 'รอบที่ ${round.$1} จาก ${round.$2}',
                                          style: _t(12.0,
                                              color:
                                                  onDark ? Colors.white : _ink2,
                                              weight: FontWeight.w600)),
                                    ),
                                  // timeline เฉพาะคำสั่งที่ต้องทำซ้ำหลายรอบ
                                  if (round != null) ...[
                                    const Spacer(),
                                    _orderSteps(rounds!, onDark: onDark),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  // confetti พุ่งจากกลางแถบหัวเมื่อทำครบ
                  if (celebrate)
                    const Positioned.fill(
                      child: IgnorePointer(child: _Confetti()),
                    ),
                ]),
                const SizedBox(height: 18.0),
                // หัวข้อซ้าย · คำอธิบายชิดขวาในแถวเดียวกัน
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('ข้อมูลที่จะถูกบันทึก',
                      style:
                          _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                        'กดค้างจนเต็ม ระบบจะบันทึกชื่อและเวลาที่รับคำสั่ง',
                        textAlign: TextAlign.right,
                        style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      line('ชื่อผู้ทำ', name, first: true),
                      line(
                          'เวลา',
                          manual == null
                              ? '${_taskClock(now)} (เวลาจริงตอนกดยืนยัน)'
                              : '${_taskClock(manual!)} (กรอกเอง)'),
                      if (t.by.isNotEmpty)
                        line('ผู้สั่ง', '${t.by} เวลา ${_clock(t.time)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 18.0),
                // ซ้าย: ทางเลือกกรอกเวลาเอง · ขวา: ปุ่มหลักกดค้าง (ทำไปก่อนแล้วมาบันทึกทีหลัง)
                Row(children: [
                  SizedBox(
                    height: 56.0,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: _blue,
                        backgroundColor: const Color(0xFFE8ECF5),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      ),
                      onPressed: celebrate
                          ? null
                          : () async {
                              if (manual != null) {
                                setSheet(() => manual = null);
                                return;
                              }
                              final v = await showTimePicker(
                                  context: ctx,
                                  initialTime: TimeOfDay.fromDateTime(now));
                              if (v == null) return;
                              final d = DateTime.now();
                              setSheet(() => manual = DateTime(
                                  d.year, d.month, d.day, v.hour, v.minute));
                            },
                      icon: Icon(
                          manual == null
                              ? Icons.edit_calendar_rounded
                              : Icons.restore_rounded,
                          size: 18.0),
                      label: Text(
                          manual == null ? 'กรอกเวลาเอง' : 'ใช้เวลาจริง',
                          style:
                              _t(13.0, color: _blue, weight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _SlideConfirm(
                      label: 'กดค้างเพื่อรับคำสั่ง',
                      style: _t(13.0,
                          color: Colors.white, weight: FontWeight.w700),
                      onDone: () {
                        final at = manual ?? DateTime.now();
                        // ×N: บันทึกรอบนี้ · ครบทุกรอบแล้วค่อยนับว่าคำสั่งเสร็จ
                        final multi = rounds != null && rounds.own;
                        var label = t.title;
                        if (multi) {
                          final recs =
                              _taskRounds.putIfAbsent(_roundKey(t), () => []);
                          setState(() => recs.add((name, at)));
                          label = '${t.title} รอบ ${recs.length}/${rounds.n}';
                          if (recs.length >= rounds.n &&
                              !_taskDone.contains(t.title)) {
                            _taskToggle(t);
                          }
                        } else if (!_taskDone.contains(t.title)) {
                          _taskToggle(t);
                        }
                        // กรอกเวลาเอง: เขียนทับเวลาที่ _taskToggle ใส่เป็นตอนนี้
                        if (manual != null && _taskDone.contains(t.title)) {
                          _taskDoneAt[t.title] = at;
                        }
                        HapticFeedback.mediumImpact();
                        final finished = _taskDone.contains(t.title);
                        void close() {
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          _taskNotice(
                              'บันทึกแล้ว $label โดย $name ${_taskClock(at)}');
                        }

                        if (!finished) {
                          close();
                          return;
                        }
                        // ทำครบ: ค้างหน้าไว้ ไล่เขียว + confetti แล้วปิดเอง
                        setSheet(() => celebrate = true);
                        HapticFeedback.heavyImpact();
                        Future.delayed(
                            const Duration(milliseconds: 2000), close);
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// ข้อมูลรอบของคำสั่งที่ทำซ้ำ: n รอบ · รอบปัจจุบัน (0-based) · ใครทำ/เมื่อไรของแต่ละรอบ
  /// own = บันทึกรอบในคำสั่งนี้เอง (×N) · ไม่ใช่ = แต่ละรอบเป็นงานแยก ("รอบที่ i/n")
  ({int n, int cur, List<(String, DateTime)?> done, bool own})? _taskRoundInfo(
      _Task t) {
    final rm = RegExp(r'รอบที่\s*(\d+)\s*/\s*(\d+)').firstMatch(t.detail);
    if (rm != null) {
      final i = int.parse(rm.group(1)!), n = int.parse(rm.group(2)!);
      // รอบอื่นคืองานชื่อเดียวกัน (ก่อนวงเล็บเวลา) ที่ detail เป็น "รอบที่ k/n"
      final base = t.title.split(' (').first;
      final done = <(String, DateTime)?>[
        for (var k = 1; k <= n; k++)
          () {
            for (final o in _allTasks) {
              if (o.title.split(' (').first == base &&
                  o.detail.startsWith('รอบที่ $k/$n') &&
                  _taskDone.contains(o.title)) {
                final at = _taskDoneAt[o.title];
                return at == null ? null : (_taskDoneBy[o.title] ?? '', at);
              }
            }
            return null;
          }(),
      ];
      return (n: n, cur: (i - 1).clamp(0, n - 1), done: done, own: false);
    }
    final xm = RegExp(r'[×x]\s*(\d+)\s*$').firstMatch(t.title);
    final n = xm == null ? 0 : int.parse(xm.group(1)!);
    if (n < 2) return null;
    final recs = _taskRounds[_roundKey(t)] ?? const [];
    return (
      n: n,
      cur: recs.length.clamp(0, n),
      done: [for (var k = 0; k < n; k++) k < recs.length ? recs[k] : null],
      own: true,
    );
  }

  /// timeline รอบของคำสั่งที่ต้องทำซ้ำ (Figma): วงละรอบ ต่อด้วยเส้น
  /// รอบที่ทำแล้ว = เขียว + ใครทำ เมื่อไร · รอบนี้ = กรมท่า · รอบถัดไป = ขาว
  Widget _orderSteps(
      ({int n, int cur, List<(String, DateTime)?> done, bool own}) r,
      {bool onDark = false}) {
    final n = r.n.clamp(1, 12);
    String short(String who) => who.split(' ').take(2).join(' ');
    // จังหวะปรากฏ: วงถัดไปช้ากว่ากัน 140ms (เส้นเชื่อมขึ้นระหว่างวง)
    const step = 140;
    Widget dot(int i) {
      final ok = r.done[i] != null;
      // รอบนี้ = วงเส้นประกรมท่า + นาฬิกา (ยังไม่ทำ ไม่ถม)
      if (!ok && i == r.cur) {
        return SizedBox(
          width: 36.0,
          height: 36.0,
          child: CustomPaint(
            painter: const _DashRing(_blue),
            child: const Icon(Icons.schedule_rounded, size: 18.0, color: _blue),
          ),
        );
      }
      return Container(
        width: 36.0,
        height: 36.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ok ? _green : _panel,
          border:
              onDark && ok ? Border.all(color: Colors.white, width: 2.0) : null,
        ),
        // เครื่องหมายถูกเด้งขึ้นหลังวงปรากฏ
        child: ok
            ? _PopIn(
                delay: Duration(milliseconds: 180 + step * 2 * i + 160),
                child: const Icon(Icons.check_rounded,
                    size: 18.0, color: Colors.white),
              )
            : null,
      );
    }

    Widget label(int i) {
      final d = r.done[i];
      final lines = d != null
          ? [short(d.$1), _taskClock(d.$2)]
          // รอบนี้ = ชื่อผู้ใช้ + เวลาตอนนี้ (สิ่งที่จะถูกบันทึกเมื่อกดค้างยืนยัน)
          : i == r.cur
              ? [short(_taskDoer), _taskClock(DateTime.now())]
              : ['รอบ ${i + 1}', 'ยังไม่ทำ'];
      return SizedBox(
        height: 30.0,
        child: OverflowBox(
          maxWidth: 110.0,
          maxHeight: 30.0,
          // ไอคอนคน = ผู้ทำ · นาฬิกา = เวลา (รอบที่ยังไม่ถึงไม่มีไอคอน)
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (d != null || i == r.cur) ...[
                Icon(Icons.person_rounded,
                    size: 11.0,
                    color:
                        onDark ? Colors.white : (i == r.cur ? _blue : _ink3)),
                const SizedBox(width: 2.0),
              ],
              Flexible(
                child: Text(lines[0],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(10.0,
                        color: onDark
                            ? Colors.white
                            : (d != null || i == r.cur ? _inkTitle : _ink3),
                        weight: i == r.cur ? FontWeight.w700 : FontWeight.w600,
                        height: 1.2)),
              ),
            ]),
            if (lines[1].isNotEmpty)
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (d != null || i == r.cur) ...[
                  Icon(Icons.schedule_rounded,
                      size: 10.0, color: onDark ? Colors.white70 : _ink3),
                  const SizedBox(width: 2.0),
                ],
                Text(lines[1],
                    style: _num(9.5,
                            color: onDark ? Colors.white70 : _ink3,
                            weight: FontWeight.w500)
                        .copyWith(height: 1.2)),
              ]),
          ]),
        ),
      );
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < n; i++) ...[
        if (i > 0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 17.0),
              // เส้นเชื่อมยืดจากซ้ายไปขวาก่อนวงถัดไปจะขึ้น
              child: _GrowLine(
                delay: Duration(milliseconds: 180 + step * (2 * i - 1)),
                color: onDark
                    ? Colors.white
                    : r.done[i - 1] != null
                        ? _green.withValues(alpha: 0.6)
                        : _panel,
              ),
            ),
          ),
        SizedBox(
          width: 36.0,
          child: _PopIn(
            delay: Duration(milliseconds: 180 + step * 2 * i),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              dot(i),
              const SizedBox(height: 4.0),
              label(i),
            ]),
          ),
        ),
      ],
    ]);
  }

  void _taskNotice(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  /// วินิจฉัย (สูงสุด 3 รายการ) พร้อมรหัส ICD-10
  Widget _bentoDx() {
    // รุนแรงก่อน: critical → urgent → normal (คงลำดับเดิมในระดับเดียวกัน)
    final dx = [
      for (final lv in ErLevel.values)
        for (final d in _case.dx)
          if (d.level == lv) d
    ];
    return _bentoTile(
      icon: Icons.assignment_rounded,
      title: 'วินิจฉัย',
      count: dx.isEmpty ? '' : '${dx.length}',
      child: dx.isEmpty
          ? Text('ยังไม่มีการวินิจฉัย', style: _t(11.0, color: _ink3))
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final d in dx.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6.0,
                          height: 6.0,
                          margin: const EdgeInsets.only(top: 5.0, right: 6.0),
                          decoration: BoxDecoration(
                              color: _levelColor(d.level),
                              shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Text(d.text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _t(11.0,
                                  color: _inkTitle,
                                  weight: FontWeight.w600,
                                  height: 1.3)),
                        ),
                        if (d.icd10 != null)
                          Text(d.icd10!,
                              style: _num(10.0,
                                  color: _ink3, weight: FontWeight.w600)),
                      ]),
                ),
            ]),
    );
  }

  /// ทางลัด EMR: จำนวน visit + CC ครั้งก่อน
  Widget _bentoEmr() {
    final hv = erHpiVisits(_case);
    final prev = hv.length > 1 ? hv[1] : null;
    return _bentoTile(
      icon: Icons.folder_shared_rounded,
      title: 'EMR',
      count: '${hv.length} visit',
      onTap: () => setState(() => _detailTab = 9),
      child: Text(
          prev == null
              ? 'ไม่มีประวัติ visit ก่อนหน้า'
              : '${prev.date} · ${prev.cc}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _t(10.5, color: _ink2, weight: FontWeight.w600, height: 1.3)),
    );
  }

  /// ทางลัด Progress note: ข้อความล่าสุด หรือชวนเริ่มเขียน
  Widget _bentoProgress() {
    final text = _progress[_case.hn]?.text.trim() ?? '';
    return _bentoTile(
      icon: Icons.edit_note_rounded,
      title: 'Progress note',
      onTap: () => setState(() => _detailTab = 10),
      child: Text(text.isEmpty ? 'ยังไม่ได้เขียน' : text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: _t(10.5,
              color: text.isEmpty ? _ink3 : _ink,
              weight: FontWeight.w500,
              height: 1.35)),
    );
  }
}

/// ลายจุดจาง ๆ บนแผ่นงาน (แบบกระดาษโน้ตของต้นแบบ)
class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x140B1B3F);
    const step = 16.0;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.9, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}

/// แฟ้มหนีบกระดาษแบบ 2D flat (สี Google): แผ่นรองฟ้า · กระดาษขาว · ตัวหนีบเหลือง
/// บนกระดาษมีเช็กเขียว 2 บรรทัด + บรรทัดเทาว่าง (คำสั่งที่ยังไม่ทำ)
/// แฟ้มหนีบกระดาษบนการ์ดคำสั่งแพทย์: โผล่ขึ้น เล่นท่า ค้างนิ่ง 15 วิ แล้ววนรอบ
/// เช็กและข้อความวาดเข้าทีละแถว ค้างไว้ จางหาย แล้ววาดใหม่
class _ClipboardHero extends StatefulWidget {
  const _ClipboardHero({super.key});

  @override
  State<_ClipboardHero> createState() => _ClipboardHeroState();
}

class _ClipboardHeroState extends State<_ClipboardHero>
    with TickerProviderStateMixin {
  // หนึ่งรอบ 11.8 วิ: appear 1.8 วิ (แฟ้มโผล่ + เช็ก/ข้อความวาด) · idle 10 วิ
  // (มุมกระดาษพับลงแล้วคลี่ระหว่าง idle) · แล้ววนกลับ appear ใหม่
  late final AnimationController _in = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 5800));
  late final AnimationController _loop = AnimationController(vsync: this);
  Timer? _rest;

  // เล่นถึงคลี่มุมเสร็จ (4.5 วิ) แล้วค้างนิ่ง 15 วิ ค่อยเล่นท่าออกแล้ววนใหม่
  // ช่วงค้าง controller หยุด = ไม่ขอเฟรม (ไม่บังคับ composite ฉาก 3D ทุก vsync)
  static const _hold = 4.5 / 5.8;

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  Future<void> _cycle() async {
    while (mounted) {
      try {
        await _in.animateTo(_hold).orCancel;
        final rest = Completer<void>();
        _rest = Timer(const Duration(seconds: 15), rest.complete);
        await rest.future;
        if (!mounted) return;
        await _in.forward().orCancel;
        _in.value = 0.0;
      } on TickerCanceled {
        return;
      }
    }
  }

  @override
  void dispose() {
    _rest?.cancel();
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_in, _loop]),
      builder: (context, _) {
        // ไม่มี idle ยาว: จบท่าพับแล้วออก แล้ววนเข้าใหม่ทันที
        const total = 5.8, appear = 1.8;
        final sec = _in.value * total;
        final t = (sec / appear).clamp(0.0, 1.0);
        // appear: 0–0.45 แฟ้มโผล่ · 0.4–1 เช็ก/ข้อความวาดทีละแถว
        final e = Curves.easeOutBack
            .transform(const Interval(0.0, 0.45).transform(t));
        final reveal = const Interval(0.4, 1.0).transform(t);
        // idle: พับมุม + ดึง 3 จังหวะ · ก่อนวนใหม่จางออก 0.4 วิสุดท้าย
        double fold = 0.0;
        // พับลงครั้งเดียว (2.2–2.6) → ค้างแล้วดึงเบา ๆ 3 จังหวะ (2.6–4.1) → คลี่กลับ (4.1–4.5)
        if (sec > 2.2 && sec < 4.5) {
          fold = sec < 2.6
              ? Curves.easeOutCubic.transform((sec - 2.2) / 0.4)
              : sec < 4.1
                  ? 1.0 + 0.12 * math.sin(((sec - 2.6) % 0.5) / 0.5 * math.pi)
                  : 1.0 - Curves.easeInOutCubic.transform((sec - 4.1) / 0.4);
        }
        // ออกก่อนวนใหม่ (สะท้อนท่าเข้า): เช็ก/ข้อความหดกลับ 0.5 วิ แล้วแฟ้มจมลง
        // หมุนเอียงไปท่าเริ่มต้นเดียวกับตอนเข้า 0.6 วิ → รอบใหม่ต่อได้ไม่สะดุด
        final erase = ((sec - (total - 1.1)) / 0.5).clamp(0.0, 1.0);
        final sink = Curves.easeInCubic
            .transform(((sec - (total - 0.6)) / 0.6).clamp(0.0, 1.0));
        final pos = sink > 0 ? 1.0 - sink : e;
        final shown = erase > 0 ? reveal * (1.0 - erase) : reveal;
        return Opacity(
          opacity: const Interval(0.0, 0.2).transform(t) *
              (1.0 - const Interval(0.5, 1.0).transform(sink)),
          child: Transform.translate(
            offset: Offset(0.0, 40.0 * (1.0 - pos)),
            child: Transform.rotate(
              angle: -0.35 * (1.0 - pos),
              // ซ้อนหลายชั้นตามแกนลึก (z) = เห็นสันหนาของแผ่นรองและปึกกระดาษ
              child: Stack(fit: StackFit.expand, children: [
                for (var i = 6; i >= 1; i--)
                  Transform(
                    alignment: Alignment.center,
                    transform: _clipTilt(-i * 1.2),
                    child: CustomPaint(painter: _ClipArt(layer: 1)),
                  ),
                for (var i = 3; i >= 1; i--)
                  Transform(
                    alignment: Alignment.center,
                    transform: _clipTilt(i * 0.9),
                    child: CustomPaint(painter: _ClipArt(layer: 2)),
                  ),
                Transform(
                  alignment: Alignment.center,
                  transform: _clipTilt(3.6),
                  child:
                      CustomPaint(painter: _ClipArt(reveal: shown, fold: fold)),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

/// มุมเอียงของแฟ้ม (perspective) เลื่อนตามแกนลึก z ก่อนหมุน
Matrix4 _clipTilt(double z) => Matrix4.identity()
  ..setEntry(3, 2, 0.0022)
  ..rotateX(0.28)
  ..rotateY(-0.42)
  ..rotateZ(0.12)
  ..translate(0.0, 0.0, z);

class _ClipArt extends CustomPainter {
  /// 0 = หน้าเต็ม · 1 = สันแผ่นรอง · 2 = ขอบปึกกระดาษ
  const _ClipArt(
      {this.layer = 0, this.reveal = 1.0, this.fold = 0.0, this.fade = 1.0});
  final int layer;

  /// ความทึบของเช็ก/ข้อความ (สงวนไว้)
  final double fade;

  /// 0..1 มุมบนขวาของกระดาษพับลง (idle)
  final double fold;

  /// 0..1 เช็กและเส้นข้อความบนกระดาษวาดเข้าทีละแถว (appear)
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final board = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.1, w * 0.84, h * 0.88),
        Radius.circular(w * 0.12));
    if (layer == 1) {
      canvas.drawRRect(board, Paint()..color = const Color(0xFF1A5BC4));
      return;
    }
    canvas.drawRRect(board, Paint()..color = const Color(0xFF4285F4));
    // กระดาษ
    final paper = RRect.fromRectAndRadius(
        // ขอบแผ่นรองบาง: กระดาษกินพื้นที่เกือบเต็มแผ่นรอง
        Rect.fromLTWH(
            w * 0.13, h * 0.14, w * 0.74, h * 0.80), // ขอบบนแตะใต้คลิปหนีบพอดี
        Radius.circular(w * 0.07));
    if (layer == 2) {
      canvas.drawRRect(paper, Paint()..color = const Color(0xFFE3E7EE));
      return;
    }
    canvas.drawRRect(paper, Paint()..color = Colors.white);
    // มุมพับบนขวา: ตัดมุมกระดาษ (เห็นแผ่นรองฟ้า) + แผ่นพับเทาอ่อนพร้อมเงา
    if (fold > 0.001) {
      final r = paper.outerRect;
      final d = w * 0.17 * fold;
      final tr = r.topRight;
      canvas.drawPath(
          Path()
            ..moveTo(tr.dx - d, tr.dy)
            ..lineTo(tr.dx, tr.dy)
            ..lineTo(tr.dx, tr.dy + d)
            ..close(),
          Paint()..color = const Color(0xFF4285F4));
      final flap = Path()
        ..moveTo(tr.dx - d, tr.dy)
        ..lineTo(tr.dx - d, tr.dy + d)
        ..lineTo(tr.dx, tr.dy + d)
        ..close();
      canvas.drawPath(
          flap.shift(Offset(-w * 0.012, h * 0.012)),
          Paint()
            ..color = const Color(0x33000000)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
      canvas.drawPath(flap, Paint()..color = const Color(0xFFE8EAED));
    }
    // บรรทัด: เช็กเขียว 2 บรรทัดบน · วงเทาบรรทัดล่าง
    final check = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = Paint()
      ..color = const Color(0xFFDADCE0)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    // แต่ละแถวเริ่มห่างกัน: เช็กลากเส้นเข้า แล้วเส้นข้อความยืดออกตาม
    Path part(Path p, double k) {
      if (k <= 0) return Path();
      final out = Path();
      for (final m in p.computeMetrics()) {
        out.addPath(
            m.extractPath(0, m.length * k.clamp(0.0, 1.0)), Offset.zero);
      }
      return out;
    }

    for (var i = 0; i < 3; i++) {
      final y = h * (0.34 + i * 0.15);
      final x0 = w * 0.28;
      final k = ((reveal - i * 0.22) / 0.45).clamp(0.0, 1.0);
      if (k <= 0) continue;
      final kc = (k / 0.45).clamp(0.0, 1.0);
      final kl = ((k - 0.35) / 0.65).clamp(0.0, 1.0);
      if (i < 2) {
        canvas.drawPath(
            part(
                Path()
                  ..moveTo(x0, y)
                  ..lineTo(x0 + w * 0.05, y + h * 0.04)
                  ..lineTo(x0 + w * 0.13, y - h * 0.04),
                kc),
            check);
      } else {
        canvas.drawCircle(
            Offset(x0 + w * 0.06, y),
            w * 0.05 * Curves.easeOutBack.transform(kc),
            Paint()
              ..color = const Color(0xFFDADCE0)
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.035);
      }
      if (kl > 0) {
        final xs = x0 + w * 0.2, xe = w * 0.68;
        canvas.drawLine(Offset(xs, y), Offset(xs + (xe - xs) * kl, y), line);
      }
    }
    // ตัวหนีบเหลือง + ห่วง
    final clip = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.04, w * 0.4, h * 0.14),
        Radius.circular(w * 0.05));
    canvas.drawRRect(clip, Paint()..color = const Color(0xFFFBBC04));
    canvas.drawCircle(Offset(w * 0.5, h * 0.06), w * 0.06,
        Paint()..color = const Color(0xFFFBBC04));
    canvas.drawCircle(
        Offset(w * 0.5, h * 0.06), w * 0.025, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ClipArt old) =>
      old.layer != layer || old.reveal != reveal || old.fold != fold;
}

/// ปุ่มกดค้างยืนยัน: กดค้าง 1.2 วิ พื้นเขียวกระจายจากกลาง ครบ = ยืนยัน · ปล่อยก่อน = ถอยกลับ
/// (ชื่อเดิม _SlideConfirm คงไว้ ผู้เรียกไม่ต้องแก้)
class _SlideConfirm extends StatefulWidget {
  const _SlideConfirm(
      {required this.label, required this.style, required this.onDone});

  final String label;
  final TextStyle style;
  final VoidCallback onDone;

  @override
  State<_SlideConfirm> createState() => _SlideConfirmState();
}

class _SlideConfirmState extends State<_SlideConfirm>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..addStatusListener((st) {
      if (st == AnimationStatus.completed && !_fired) {
        _fired = true;
        HapticFeedback.heavyImpact();
        widget.onDone();
      }
    });
  bool _fired = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down() {
    if (_fired) return;
    HapticFeedback.selectionClick();
    _c.forward();
  }

  void _up() {
    if (_fired) return;
    _c.animateBack(0.0, duration: const Duration(milliseconds: 220));
  }

  @override
  Widget build(BuildContext context) {
    const h = 56.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(),
      onTapCancel: _up,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final v = _c.value;
          final done = _fired || v >= 1.0;
          Widget label(Color c) =>
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(done ? Icons.check_rounded : Icons.touch_app_rounded,
                    size: 20.0, color: c),
                const SizedBox(width: 8.0),
                Text(done ? 'เสร็จแล้ว' : widget.label,
                    style: widget.style.copyWith(color: c)),
              ]);
          return Container(
            height: h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              // filled primary: พื้นกรมท่า ปุ่มหลักของ sheet
              color: _blue,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Stack(children: [
              // พื้นเขียวกระจายออกจากกลางปุ่มไปสองข้างตามเวลาที่กดค้าง
              Center(
                child: FractionallySizedBox(
                  widthFactor: v,
                  heightFactor: 1.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                ),
              ),
              // ข้อความขาวบนพื้นกรมท่า และบนช่วงที่เขียวทับ
              Center(child: label(widget.style.color!)),
              ClipRect(
                clipper: _CenterClip(v),
                child: Center(child: label(Colors.white)),
              ),
            ]),
          );
        },
      ),
    );
  }
}

/// ตัดให้เห็นช่วงกลางกว้าง k (0..1) ของความกว้าง
class _CenterClip extends CustomClipper<Rect> {
  const _CenterClip(this.k);
  final double k;

  @override
  Rect getClip(Size size) => Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * k,
      height: size.height);

  @override
  bool shouldReclip(_CenterClip old) => old.k != k;
}

/// วงเส้นประรอบวงกลม (รอบที่กำลังจะทำ)
class _DashRing extends CustomPainter {
  const _DashRing(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 1.2;
    final c = size.center(Offset.zero);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    const dashes = 14;
    const sweep = 2 * math.pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * sweep,
          sweep * 0.55, false, p);
    }
  }

  @override
  bool shouldRepaint(_DashRing old) => old.color != color;
}

/// ปรากฏหลังหน่วงเวลา: ขยายจาก 0.4 แบบเด้ง (elasticOut) + จาง
class _PopIn extends StatefulWidget {
  const _PopIn({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
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
        builder: (context, child) => Opacity(
          opacity: Curves.easeOut.transform((_c.value * 2.0).clamp(0.0, 1.0)),
          child: Transform.scale(
            scale: 0.4 + 0.6 * Curves.elasticOut.transform(_c.value),
            child: child,
          ),
        ),
        child: widget.child,
      );
}

/// เส้นเชื่อมยืดจากซ้ายไปขวาหลังหน่วงเวลา
class _GrowLine extends StatefulWidget {
  const _GrowLine({required this.delay, required this.color});

  final Duration delay;
  final Color color;

  @override
  State<_GrowLine> createState() => _GrowLineState();
}

class _GrowLineState extends State<_GrowLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
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
        builder: (context, _) => Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: Curves.easeOutCubic.transform(_c.value),
            child: Container(height: 2.0, color: widget.color),
          ),
        ),
      );
}

/// confetti พุ่งขึ้นจากกลางล่างแล้วตกตามแรงโน้มถ่วง หมุนและจางลง (1.8 วิ)
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..forward();
  final _bits = List.generate(70, (i) {
    final r = math.Random(i * 7919);
    final ang = -math.pi / 2 + (r.nextDouble() - 0.5) * 2.2;
    final sp = 260.0 + r.nextDouble() * 320.0;
    return (
      vx: math.cos(ang) * sp,
      vy: math.sin(ang) * sp,
      spin: (r.nextDouble() - 0.5) * 14.0,
      w: 5.0 + r.nextDouble() * 5.0,
      h: 3.0 + r.nextDouble() * 4.0,
      color: const [
        Color(0xFFFFC53D),
        Color(0xFF4ADE80),
        Colors.white,
        Color(0xFF60A5FA),
        Color(0xFFF472B6),
      ][i % 5],
    );
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ConfettiPainter(_c, _bits), size: Size.infinite);
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.anim, this.bits) : super(repaint: anim);

  final Animation<double> anim;
  final List<
      ({
        double vx,
        double vy,
        double spin,
        double w,
        double h,
        Color color
      })> bits;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * 1.8; // วินาที
    const g = 620.0;
    final o = Offset(size.width * 0.62, size.height * 0.85);
    final fade = (1.0 - (anim.value - 0.7) / 0.3).clamp(0.0, 1.0);
    final p = Paint();
    for (final b in bits) {
      final x = o.dx + b.vx * t;
      final y = o.dy + b.vy * t + 0.5 * g * t * t;
      p.color = b.color;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(b.spin * t);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: b.w, height: b.h), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}

/// รูปประกอบแท็บ Fast track: นาฬิกาจับเวลา 2D flat สี Google (ตัวฟ้า หน้าขาว ปุ่มเหลือง)
/// สายฟ้าเหลืองมุมขวาล่าง = เร่งด่วน · เข้าฉาก: เด้งขึ้น แล้วเข็มแดงกวาดหนึ่งรอบ
/// เล่นครั้งเดียวแล้วนิ่ง (ไม่ขอเฟรมต่อ)
class _StopwatchHero extends StatefulWidget {
  const _StopwatchHero({super.key});

  @override
  State<_StopwatchHero> createState() => _StopwatchHeroState();
}

class _StopwatchHeroState extends State<_StopwatchHero>
    with TickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    // เข้าฉากเสร็จ = สายฟ้าหมุนรอบแรกทันที แล้วค่อยพักเป็นรอบ ๆ
    ..forward().whenComplete(_spin);

  /// idle: สายฟ้าหมุนรอบตัว + เด้ง + ประกายไฟ เป็นรอบ ๆ แล้วพัก
  /// (พักด้วย Timer ไม่มี ticker ค้าง: ไม่บังคับวาดจอทุกเฟรม)
  late final AnimationController _zap = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 950));
  Timer? _wait;

  void _spin() {
    if (!mounted) return;
    _zap.forward(from: 0.0).whenComplete(_rest);
  }

  void _rest() {
    if (!mounted) return;
    _wait = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      // ไม่อยู่บนจอ (TickerMode ปิด) = ข้ามรอบนี้ ไม่เล่นทิ้ง
      if (!TickerMode.valuesOf(context).enabled) return _rest();
      _zap.forward(from: 0.0).whenComplete(_rest);
    });
  }

  @override
  void dispose() {
    _wait?.cancel();
    _zap.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_c, _zap]),
        builder: (context, _) {
          final t = _c.value;
          final pop = Curves.easeOutBack
              .transform(const Interval(0.0, 0.45).transform(t));
          // หมุนตัวในแกน 3 มิติจริง (ไม่ใช่บิดภาพ): จากหันข้างมาหยุดที่มุมสามส่วนสี่
          final turn = Curves.easeOutCubic
              .transform(const Interval(0.0, 0.7).transform(t));
          final sweep = Curves.easeInOutCubic
              .transform(const Interval(0.35, 1.0).transform(t));
          return Opacity(
            opacity: const Interval(0.0, 0.2).transform(t),
            child: Transform.translate(
              offset: Offset(0.0, 24.0 * (1.0 - pop)),
              child: CustomPaint(
                painter: _StopwatchArt(sweep,
                    yaw: -1.25 + 0.7 * turn, zap: _zap.value),
                size: Size.infinite,
              ),
            ),
          );
        },
      );
}

/// จุด 3 มิติ (x ขวา, y ขึ้น, z เข้าหากล้อง)
typedef _P3 = (double, double, double);

_P3 _p3Add(_P3 a, _P3 b) => (a.$1 + b.$1, a.$2 + b.$2, a.$3 + b.$3);
_P3 _p3Mul(_P3 a, double k) => (a.$1 * k, a.$2 * k, a.$3 * k);
double _p3Dot(_P3 a, _P3 b) => a.$1 * b.$1 + a.$2 * b.$2 + a.$3 * b.$3;
_P3 _p3Cross(_P3 a, _P3 b) => (
      a.$2 * b.$3 - a.$3 * b.$2,
      a.$3 * b.$1 - a.$1 * b.$3,
      a.$1 * b.$2 - a.$2 * b.$1
    );
_P3 _p3Norm(_P3 a) => _p3Mul(a, 1.0 / math.sqrt(_p3Dot(a, a)));

/// นาฬิกาจับเวลาแบบ 3 มิติจริง: ทุกชิ้นเป็นทรงกระบอก/แผ่นหนาในพิกัดโลก
/// หมุน yaw/pitch แล้วฉายแบบ perspective (ใกล้ใหญ่ ไกลเล็ก)
/// ซ่อนหน้าที่หันหลังให้กล้อง และลงเงาตามทิศแสง
class _StopwatchArt extends CustomPainter {
  const _StopwatchArt(this.sweep, {this.yaw = -0.55, this.zap = 0.0});

  /// 0..1 จังหวะ idle ของสายฟ้า (0 = นิ่ง)
  final double zap;

  /// 0..1 เข็มกวาดจาก 12 นาฬิกาไปหยุดที่ราว 8 นาที (เส้นโค้งความคืบหน้าตาม)
  final double sweep;

  /// มุมหันซ้าย/ขวาของตัวนาฬิกา (เรเดียน)
  final double yaw;

  static const _pitch = 0.36;
  static const _cam = 6.0; // ระยะกล้องจากจุดศูนย์กลาง (หน่วยรัศมีตัวเรือน)
  static const _depth = 0.42; // ความหนาตัวเรือน
  static const _light = (-0.45, 0.65, 0.62);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final k = math.min(w, h) * 0.31;
    final o = Offset(w * 0.47, h * 0.45);
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final cp = math.cos(_pitch), sp = math.sin(_pitch);
    final light = _p3Norm(_light);

    // หมุนจากพิกัดวัตถุ -> พิกัดกล้อง
    _P3 rot(_P3 p) {
      final x = p.$1 * cy + p.$3 * sy;
      final z = -p.$1 * sy + p.$3 * cy;
      return (x, p.$2 * cp - z * sp, p.$2 * sp + z * cp);
    }

    Offset proj(_P3 p) {
      final r = rot(p);
      final s = _cam / (_cam - r.$3) * k;
      return o + Offset(r.$1 * s, -r.$2 * s);
    }

    // หันเข้ากล้องไหม (เทียบกับเส้นสายตาจากจุดนั้นไปยังกล้อง)
    bool facing(_P3 p, _P3 n) {
      final r = rot(p), rn = rot(n);
      return _p3Dot(rn, (-r.$1, -r.$2, _cam - r.$3)) > 0;
    }

    Color shade(Color base, _P3 n, {double amb = 0.5}) {
      final d = math.max(0.0, _p3Dot(rot(n), light));
      final l = (amb + (1.0 - amb) * d).clamp(0.0, 1.0);
      // มืดลงแบบคงโทนสี (ไม่ผสมดำ สีเหลืองจะได้ไม่หม่นเป็นเขียวขี้ม้า)
      final hsl = HSLColor.fromColor(base);
      final dark = hsl
          .withLightness(hsl.lightness * 0.55)
          .withSaturation(math.min(1.0, hsl.saturation * 1.05))
          .toColor();
      return Color.lerp(dark, base, l)!;
    }

    Path poly(List<_P3> pts) =>
        Path()..addPolygon([for (final p in pts) proj(p)], true);

    // ทรงกระบอก: แกน a จากจุด p0 ยาว len รัศมี r
    void cylinder(_P3 p0, _P3 a, double len, double r, Color base,
        {Color? cap, int seg = 36, Shader Function(Rect)? capShader}) {
      a = _p3Norm(a);
      final ref = a.$2.abs() > 0.9 ? (1.0, 0.0, 0.0) : (0.0, 1.0, 0.0);
      final u = _p3Norm(_p3Cross(a, ref)), v = _p3Cross(a, u);
      final p1 = _p3Add(p0, _p3Mul(a, len));
      _P3 ring(_P3 c, double t) => _p3Add(
          c, _p3Add(_p3Mul(u, math.cos(t) * r), _p3Mul(v, math.sin(t) * r)));
      for (var i = 0; i < seg; i++) {
        final t0 = i / seg * math.pi * 2, t1 = (i + 1) / seg * math.pi * 2;
        final tm = (t0 + t1) / 2;
        final n = _p3Add(_p3Mul(u, math.cos(tm)), _p3Mul(v, math.sin(tm)));
        final q = [ring(p0, t0), ring(p0, t1), ring(p1, t1), ring(p1, t0)];
        if (!facing(_p3Mul(_p3Add(q[0], q[2]), 0.5), n)) continue;
        canvas.drawPath(
            poly(q),
            Paint()
              ..color = shade(base, n)
              ..isAntiAlias = true);
        // เติมขอบกันรอยต่อระหว่างแผ่น
        canvas.drawPath(
            poly(q),
            Paint()
              ..color = shade(base, n)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.6);
      }
      for (final (c, n) in [(p1, a), (p0, _p3Mul(a, -1.0))]) {
        if (!facing(c, n)) continue;
        final path = poly(
            [for (var i = 0; i < seg; i++) ring(c, i / seg * math.pi * 2)]);
        canvas.drawPath(
            path,
            capShader != null && c == p1
                ? (Paint()..shader = capShader(path.getBounds()))
                : (Paint()..color = shade(cap ?? base, n, amb: 0.7)));
      }
    }

    final front = _depth / 2;
    const zAxis = (0.0, 0.0, 1.0);
    _P3 onFace(double x, double y, [double lift = 0.0]) => (x, y, front + lift);

    const yellow = Color(0xFFFBBC04);
    // หูปุ่มเฉียงขวาบน (อยู่หลังก้านกลาง วาดก่อน)
    const side = (0.62, 0.78, 0.0);
    cylinder(_p3Mul(side, 0.95), side, 0.2, 0.1, const Color(0xFFE8A600));
    cylinder(_p3Mul(side, 1.13), side, 0.1, 0.17, yellow);
    // ก้าน + ปุ่มกดด้านบน
    cylinder(
        (0.0, 0.95, 0.0), (0.0, 1.0, 0.0), 0.2, 0.11, const Color(0xFFE8A600));
    cylinder((0.0, 1.13, 0.0), (0.0, 1.0, 0.0), 0.13, 0.27, yellow);

    // ตัวเรือน: ทรงกระบอกหนา หน้าตัดไล่แสงจากซ้ายบน
    cylinder((0.0, 0.0, -front), zAxis, _depth, 1.0, const Color(0xFFD93025),
        capShader: (b) => const RadialGradient(
              center: Alignment(-0.45, -0.55),
              radius: 1.05,
              colors: [Color(0xFFF6AEA9), Color(0xFFEA4335), Color(0xFFC5221F)],
              stops: [0.0, 0.5, 1.0],
            ).createShader(b));

    // หน้าปัดจมลงในตัวเรือน: ผนังวงในด้านบน + พื้นหน้าปัด
    const sink = 0.07;
    final face = <_P3>[
      for (var i = 0; i < 48; i++)
        onFace(math.cos(i / 48 * math.pi * 2) * 0.78,
            math.sin(i / 48 * math.pi * 2) * 0.78, -sink + 0.001)
    ];
    canvas.drawPath(
        poly([
          for (var i = 0; i < 48; i++)
            onFace(math.cos(i / 48 * math.pi * 2) * 0.78,
                math.sin(i / 48 * math.pi * 2) * 0.78, 0.001)
        ]),
        Paint()..color = const Color(0xFF8C1D18));
    final facePath = poly(face);
    canvas.drawPath(
        facePath,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.4),
            radius: 1.0,
            colors: [Colors.white, Color(0xFFE3E7ED)],
          ).createShader(facePath.getBounds()));

    final fz = -sink + 0.002;
    // ขีดบอกเวลา 12 ขีด บนระนาบหน้าปัด (ฉายตามมุมมอง)
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final d = (math.sin(a), math.cos(a));
      canvas.drawLine(
          proj(onFace(d.$1 * 0.6, d.$2 * 0.6, fz)),
          proj(onFace(d.$1 * 0.7, d.$2 * 0.7, fz)),
          Paint()
            ..color = const Color(0xFFADB3BA)
            ..strokeWidth = k * (i % 3 == 0 ? 0.07 : 0.045)
            ..strokeCap = StrokeCap.round);
    }
    // ส่วนโค้งเวลาที่ผ่านไป
    final end = sweep * math.pi * 2 * 0.72;
    if (end > 0) {
      final n = math.max(2, (end / 0.1).ceil());
      canvas.drawPath(
          poly([
            onFace(0, 0, fz),
            for (var i = 0; i <= n; i++)
              onFace(
                  math.sin(end * i / n) * 0.5, math.cos(end * i / n) * 0.5, fz),
          ]),
          Paint()..color = const Color(0x40EA4335));
    }
    // เข็มลอยเหนือหน้าปัด: เงาเข็มตกบนหน้าปัดก่อน แล้วตัวเข็ม
    final hd = (math.sin(end), math.cos(end));
    canvas.drawLine(
        proj(onFace(0.05, -0.05, fz)),
        proj(onFace(hd.$1 * 0.62 + 0.05, hd.$2 * 0.62 - 0.05, fz)),
        Paint()
          ..color = const Color(0x33000000)
          ..strokeWidth = k * 0.08
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, k * 0.03));
    canvas.drawLine(
        proj(onFace(0, 0, fz + 0.06)),
        proj(onFace(hd.$1 * 0.62, hd.$2 * 0.62, fz + 0.06)),
        Paint()
          ..color = const Color(0xFFEA4335)
          ..strokeWidth = k * 0.085
          ..strokeCap = StrokeCap.round);
    cylinder(onFace(0, 0, fz), zAxis, 0.09, 0.09, const Color(0xFF3C4043),
        cap: const Color(0xFF202124), seg: 18);

    // กระจกหน้าปัด: แสงสะท้อนโค้งซ้ายบน
    final glint = Path();
    for (var i = 0; i <= 16; i++) {
      final t = math.pi * (0.58 + 0.34 * i / 16);
      final p = proj(onFace(math.cos(t) * 0.66, math.sin(t) * 0.66, 0.0));
      i == 0 ? glint.moveTo(p.dx, p.dy) : glint.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        glint,
        Paint()
          ..color = const Color(0xCCFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = k * 0.07
          ..strokeCap = StrokeCap.round);

    // สายฟ้า: แผ่นหนาลอยหน้าตัวเรือนมุมขวาล่าง (extrude จริง มีด้านข้าง)
    // idle: หมุนรอบแกนตั้งของตัวเอง 1 รอบ + เด้งขึ้น + ขยาย แล้วแตกประกาย
    final up = math.sin(math.pi * zap);
    final spin = Curves.easeInOutCubic.transform(zap) * math.pi * 2;
    final bs = 0.88 * (1.0 + 0.14 * up);
    const bx = 0.84, by = -0.56, bz = 0.38, bd = 0.17;
    final hop = 0.2 * up;
    final cs = math.cos(spin), ss = math.sin(spin);
    // หมุนรอบแกน y ของสายฟ้า แล้ววางที่มุมตัวเรือน
    _P3 place(_P3 p) => (
          bx + p.$1 * cs + p.$3 * ss,
          by + hop + p.$2,
          front + bz - p.$1 * ss + p.$3 * cs
        );
    _P3 turn(_P3 n) => (n.$1 * cs + n.$3 * ss, n.$2, -n.$1 * ss + n.$3 * cs);
    final bolt2d = [
      (0.10, 0.55),
      (-0.32, -0.08),
      (-0.02, -0.08),
      (-0.14, -0.60),
      (0.34, 0.08),
      (0.04, 0.08),
    ];
    final bf = [for (final (x, y) in bolt2d) place((x * bs, y * bs, bd / 2))];
    final bb = [for (final (x, y) in bolt2d) place((x * bs, y * bs, -bd / 2))];
    final sides = <(double, List<_P3>, _P3)>[];
    for (var i = 0; i < bolt2d.length; i++) {
      final j = (i + 1) % bolt2d.length;
      final e = (bolt2d[j].$1 - bolt2d[i].$1, bolt2d[j].$2 - bolt2d[i].$2);
      // รูปวนทวนเข็ม: ด้านนอกอยู่ทางขวามือของขอบ
      final n = turn(_p3Norm((e.$2, -e.$1, 0.0)));
      final q = [bf[i], bf[j], bb[j], bb[i]];
      final mid = _p3Mul(_p3Add(q[0], q[2]), 0.5);
      if (!facing(mid, n)) continue;
      sides.add((rot(mid).$3, q, n));
    }
    sides.sort((a, b) => a.$1.compareTo(b.$1));
    for (final (_, q, n) in sides) {
      canvas.drawPath(
          poly(q), Paint()..color = shade(const Color(0xFFE09B00), n));
    }
    // หน้าที่หันเข้ากล้อง (หมุนครึ่งรอบ = เห็นด้านหลัง)
    final fn = turn((0.0, 0.0, 1.0));
    final showFront = facing(bf[0], fn);
    final boltFace = poly(showFront ? bf : bb);
    canvas.drawPath(
        boltFace,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = k * 0.06
          ..strokeJoin = StrokeJoin.round);
    // จังหวะสูงสุดสว่างวาบ
    canvas.drawPath(
        boltFace,
        Paint()
          ..color = Color.lerp(showFront ? yellow : const Color(0xFFF2B200),
              const Color(0xFFFFF6CC), 0.6 * up)!);
    // ประกายไฟแตกออกตอนท้ายจังหวะ
    final spark = const Interval(0.55, 1.0).transform(zap);
    if (spark > 0.0 && spark < 1.0) {
      final c0 = proj(place((0.0, 0.0, 0.0)));
      final paint = Paint()
        ..color = yellow.withValues(alpha: 1.0 - spark)
        ..strokeWidth = k * 0.07
        ..strokeCap = StrokeCap.round;
      for (final a in [-0.35, 0.5, 1.35, 2.6]) {
        final d = Offset(math.cos(a), -math.sin(a));
        final r0 = k * (0.42 + 0.28 * spark), r1 = r0 + k * 0.16 * (1 - spark);
        canvas.drawLine(c0 + d * r0, c0 + d * r1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_StopwatchArt o) =>
      o.sweep != sweep || o.yaw != yaw || o.zap != zap;
}

/// ลู่เวลาของ KPI หนึ่งตัว (ดู _ftKpiChart)
class _FtLanePainter extends CustomPainter {
  const _FtLanePainter({
    required this.span,
    required this.now,
    required this.start,
    required this.end,
    required this.target,
  });

  final double span, now;
  final double? start, end, target;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, cy = size.height / 2;
    double x(double m) => (m / span * w).clamp(0.0, w);
    const track = Color(0xFFF1F3F4), zone = Color(0xFFE6F4EA);
    const blue = Color(0xFF1A73E8), green = Color(0xFF1E9E5A);
    const red = Color(0xFFD93025);
    canvas.drawRRect(
        RRect.fromLTRBR(0, cy - 3, w, cy + 3, const Radius.circular(3)),
        Paint()..color = track);
    // เส้นตอนนี้ (ประ) ต่อกันทุกแถว
    final nx = x(now);
    final dash = Paint()
      ..color = const Color(0x66D93025)
      ..strokeWidth = 1.5;
    for (var y = 0.0; y < size.height; y += 6) {
      canvas.drawLine(
          Offset(nx, y), Offset(nx, math.min(y + 3, size.height)), dash);
    }
    final a = start;
    if (a == null) return;
    final b = end ?? now;
    final done = end != null;
    final goal = target == null ? null : a + target!;
    if (goal != null) {
      canvas.drawRRect(
          RRect.fromLTRBR(
              x(a), cy - 8, x(goal), cy + 8, const Radius.circular(6)),
          Paint()..color = zone);
    }
    final over = goal != null && b > goal;
    final okC = done ? green : blue;
    final cut = over ? goal : b;
    canvas.drawRRect(
        RRect.fromLTRBR(x(a), cy - 4, math.max(x(cut), x(a) + 4), cy + 4,
            const Radius.circular(4)),
        Paint()..color = okC);
    if (over) {
      canvas.drawRRect(
          RRect.fromLTRBR(
              x(goal) - 2, cy - 4, x(b), cy + 4, const Radius.circular(4)),
          Paint()..color = red);
    }
    canvas.drawCircle(Offset(x(a), cy), 4.5, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(x(a), cy),
        4.5,
        Paint()
          ..color = const Color(0xFF5F6368)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    final ec = over ? red : okC;
    canvas.drawCircle(
        Offset(x(b), cy), 6, Paint()..color = done ? ec : Colors.white);
    if (!done) {
      canvas.drawCircle(
          Offset(x(b), cy),
          5,
          Paint()
            ..color = ec
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
    }
    if (goal != null) {
      final gx = x(goal);
      final fc = over ? red : green;
      canvas.drawLine(
          Offset(gx, cy - 14),
          Offset(gx, cy + 8),
          Paint()
            ..color = fc
            ..strokeWidth = 1.6);
      canvas.drawPath(
          Path()
            ..moveTo(gx, cy - 14)
            ..lineTo(gx + 9, cy - 11)
            ..lineTo(gx, cy - 8)
            ..close(),
          Paint()..color = fc);
    }
  }

  @override
  bool shouldRepaint(_FtLanePainter o) =>
      o.span != span ||
      o.now != now ||
      o.start != start ||
      o.end != end ||
      o.target != target;
}
