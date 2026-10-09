// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

bool _samePos(List<ErBedScreenPos> a, List<ErBedScreenPos> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].code != b[i].code ||
        a[i].visible != b[i].visible ||
        (a[i].dx - b[i].dx).abs() > 0.5 ||
        (a[i].dy - b[i].dy).abs() > 0.5) {
      return false;
    }
  }
  return true;
}

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _TabsOverviewOverviewSceneState on State<ErFlowHomeWidget> {
  /// ช่วงงานที่กำลังซูมดูอยู่ในหน้าภาพรวม null = ยังไม่ได้ซูม
  /// ต่างจาก _open ตรงที่ยังอยู่หน้าภาพรวม ฉากเดิม แค่ขยายเข้าไปดูมุมนั้น
  _Phase? _zoom;

  /// ตำแหน่งการ์ดสรุปในฉาก ลากย้ายได้อิสระ เริ่มจากค่าตั้งต้นใน _spots
  /// เก็บเป็นสัดส่วนของกรอบฉาก ย่อ/ขยายหน้าต่างแล้วการ์ดยังอยู่จุดเดิม
  final Map<_Phase, Offset> _cardAt = {..._spots};

  /// จุดยึดของการซูมล่าสุด ค้างไว้แม้ซูมออกแล้ว
  ///
  /// ถ้าสลับจุดยึดกลับไปกลางจอพร้อมกับที่สเกลเริ่มลด ภาพจะกระตุกทันทีที่กด
  /// เพราะจุดยึดเปลี่ยนแบบไม่มีอนิเมชัน สเกล 1.0 จะยึดตรงไหนก็ได้ผลเหมือนกัน
  /// จึงปล่อยให้ค้างที่มุมเดิมจนกว่าจะซูมมุมใหม่
  Alignment _zoomAt = Alignment.center;
}

/// ตำแหน่งการ์ดสรุปบนหน้าผังแผนก: เรียงเป็นคอลัมน์ซ้าย ผังอยู่ฝั่งขวา
/// (การ์ดไม่ทับโซน) ลำดับบนลงล่างตามลำดับงาน
const Map<_Phase, Offset> _floorSpots = {
  _Phase.triage: Offset(0.03, 0.12),
  _Phase.treatment: Offset(0.03, 0.33),
  _Phase.after: Offset(0.03, 0.54),
  _Phase.observe: Offset(0.03, 0.54),
};

/// การ์ดคำสั่งแพทย์บนฉาก: เลื่อนรายการแล้วซ่อนหัวการ์ด (คืนเมื่อเลื่อนกลับบนสุด)
final ValueNotifier<bool> _ordersHeadHidden = ValueNotifier(false);
String? _ordersHeadHn;

extension _TabsOverviewOverviewScenePart on _ErFlowHomeWidgetState {
  /// ภาพฉากกระแสงาน ER สามขั้น พร้อมการ์ดสรุปลอยข้างแต่ละขั้น
  ///
  /// ใช้ภาพเรนเดอร์จากแบบ (Figma node 148-2597) แทนฉากสามมิติที่รันจริง
  /// ตำแหน่งการ์ดวางเป็นสัดส่วนของกรอบ ตามผังใน Figma node 96-1343
  /// ภาพฉากกระแสงาน ER สามขั้น พร้อมการ์ดสรุปลอยข้างแต่ละขั้น
  ///
  /// ตำแหน่งการ์ดวางเป็นสัดส่วนของกรอบ ตามผังใน Figma node 96-1343
  Widget _stairScene() => LayoutBuilder(
        builder: (context, c) {
          final zoomed = _zoom != null && _open == null;
          Widget card(_Phase ph) => Positioned(
                left: _cardAt[ph]!.dx * c.maxWidth,
                top: _cardAt[ph]!.dy * c.maxHeight,
                // ใบที่ไม่ได้ซูมจางหายไป เหลือใบเดียวคู่กับมุมที่ขยาย
                child: AnimatedOpacity(
                  opacity: zoomed && _zoom != ph ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeInOutCubic,
                  child: IgnorePointer(
                    ignoring: zoomed && _zoom != ph,
                    // ลากการ์ดไปวางตรงไหนก็ได้ในฉาก เก็บเป็นสัดส่วนของกรอบ
                    child: GestureDetector(
                      onPanUpdate: (d) => setState(() {
                        final cur = _cardAt[ph]!;
                        _cardAt[ph] = Offset(
                          (cur.dx + d.delta.dx / c.maxWidth).clamp(0.0, 0.92),
                          (cur.dy + d.delta.dy / c.maxHeight).clamp(0.0, 0.86),
                        );
                      }),
                      child:
                          _loading ? _statCardSkeleton() : _sceneStatCard(ph),
                    ),
                  ),
                ),
              );
          return Stack(
            children: [
              // หน้าภาพรวม: พื้นหลังฉากเป็นขาว ขอบซ้ายไล่จางจากพื้นแอปเข้าหาขาว
              if (_open == null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white,
                            Colors.white,
                          ],
                          stops: const [0.0, 0.22, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              // ซูมเข้าไปที่มุมของช่วงงานที่เลือก จุดยึดคือตำแหน่งการ์ดใบนั้น
              Positioned.fill(
                child: ClipRect(
                  child: AnimatedScale(
                    scale: zoomed ? 1.75 : 1.0,
                    alignment: _zoomAt,
                    duration: const Duration(milliseconds: 620),
                    curve: Curves.easeInOutCubic,
                    child: _sceneFor(_open),
                  ),
                ),
              ),
              // แตะที่ฉากตอนซูมอยู่เพื่อถอยกลับ
              if (zoomed)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _zoom = null),
                  ),
                ),
              // ระหว่างโหลด คลุมฉากด้วยแผ่น skeleton แล้วค่อยเฟดออก
              // (ฉากยัง mount อยู่ข้างล่าง วิดีโอ/WebView จึงไม่โหลดซ้ำ)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _loading ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 260),
                    child: Container(
                      color: _bg,
                      padding:
                          const EdgeInsets.fromLTRB(24.0, 34.0, 24.0, 30.0),
                      // โหลดเสร็จ = หยุด shimmer (ticker วนตลอดบังคับวาดเฟรมทับ WebView)
                      child: TickerMode(
                        enabled: _loading,
                        child: _Shimmer(
                          child: Center(
                            child: _open == null
                                ? _bone(c.maxWidth * 0.46, c.maxHeight * 0.78,
                                    radius: 28.0)
                                : _bone(c.maxWidth * 0.86, c.maxHeight * 0.55,
                                    radius: 24.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // โหมดภาพรวมโชว์ครบสามใบ เลือกช่วงงานแล้วเหลือใบเดียว
              // ปิดการ์ดในฉากไว้ก่อนระหว่างจัดองค์ประกอบฉากใหม่
              if (_open == null && _showSceneStats) ...[
                // (กลุ่มการ์ดของโหมดภาพรวม)
                card(_Phase.triage),
                card(_Phase.treatment),
                card(_Phase.after),
                // แผงสรุปของช่วงงานที่ซูมอยู่ เลื่อนขึ้นมาจากขอบล่าง
                Positioned(
                  left: 16.0,
                  right: 16.0,
                  bottom: 14.0,
                  child: IgnorePointer(
                    ignoring: !zoomed,
                    child: AnimatedSlide(
                      offset: zoomed ? Offset.zero : const Offset(0, 0.25),
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeInOutCubic,
                      child: AnimatedOpacity(
                        opacity: zoomed ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        child: _zoomPanel(_zoom ?? _Phase.triage),
                      ),
                    ),
                  ),
                ),
              ],
              if (_open != null) ...[
                // ปุ่มเลื่อนดูเตียงก่อนหน้า/ถัดไป กึ่งกลางแนวตั้งของฉาก
                if (!_loading) ...[
                  Positioned(
                    left: 16.0,
                    top: c.maxHeight * 0.30,
                    child: _stepButton(Icons.chevron_left_rounded, -1),
                  ),
                  Positioned(
                    right: 16.0,
                    top: c.maxHeight * 0.30,
                    child: _stepButton(Icons.chevron_right_rounded, 1),
                  ),
                ],
                // การ์ดผู้ป่วยลอยล่างฉาก ต้องวางหลัง WebView ใน Stack
                // ไม่งั้นมุมมองฝั่งระบบจะทับจนมองไม่เห็น
                Positioned(
                  left: 16.0,
                  right: 16.0,
                  bottom: 14.0,
                  // ‹ › เปลี่ยนผู้ป่วย: เลื่อนแบบเปลี่ยนหน้า การ์ดเดิมออกเต็มความกว้าง
                  // การ์ดใหม่ตามเข้ามาจากอีกฝั่งพร้อมกัน (ไม่ซ้อนจาง) · ตัดขอบซ้ายขวา
                  // แต่เว้นด้านบนให้ภาพประกอบที่ยื่นเหนือการ์ดยังเห็น
                  child: _loading
                      ? _patientCardSkeleton()
                      : ClipRect(
                          clipper: const _TopOpenClip(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 420),
                            switchInCurve: Curves.easeInOutCubic,
                            switchOutCurve: Curves.easeInOutCubic,
                            layoutBuilder: (cur, prev) => Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.bottomCenter,
                                children: [...prev, if (cur != null) cur]),
                            transitionBuilder: (child, a) {
                              final incoming = child.key ==
                                  ValueKey(_sceneSelected(_open!).hn);
                              final dx =
                                  (incoming ? 1.0 : -1.0) * _sceneDir * 1.04;
                              return SlideTransition(
                                position: Tween(
                                        begin: Offset(dx, 0.0),
                                        end: Offset.zero)
                                    .animate(a),
                                child: child,
                              );
                            },
                            child: KeyedSubtree(
                                key: ValueKey(_sceneSelected(_open!).hn),
                                child: RepaintBoundary(
                                    child: _scenePatientCard(_open!))),
                          ),
                        ),
                ),
              ],
            ],
          );
        },
      );

  /// V/S ของเตียงที่เลือก ส่งเข้าฉาก 3D (จอ monitor ติดกำแพงเหนือหัวเตียง)
  Map<String, Object?>? _sceneVitalsData(_P p) {
    final c = erCaseOf(p.hn);
    if (c.times.isEmpty) return null;
    final vs = _vitalsFor(c);
    ErVital? by(String l) => vs.where((v) => v.label == l).firstOrNull;
    String f(double x) =>
        x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
    String val(String l) {
      final v = by(l);
      if (v == null || v.series.isEmpty) return '--';
      return v.display ?? f(v.series.last);
    }

    final bad = [
      for (final l in const ['HR', 'BP', 'SpO₂', 'RR', 'BT'])
        if (by(l)?.color == _red) l,
    ];
    return {
      'hr': val('HR'),
      'hrN': by('HR')?.series.lastOrNull ?? 80.0,
      'spo2': val('SpO₂'),
      'bp': val('BP'),
      'rr': val('RR'),
      'bt': val('BT'),
      'time': _clock(c.times.last),
      'alarms': [for (final l in bad) l == 'SpO₂' ? 'SpO2' : l],
      // เลขเตียงแสดงเป็นป้ายบนกำแพงหัวเตียงในฉาก (แทนป้ายบนการ์ด)
      'bed': p.bed,
      'bad': bad,
    };
  }

  /// แผงสรุปของช่วงงานที่ซูมดูอยู่ในหน้าภาพรวม
  ///
  /// ตอบคำถามที่การ์ดเล็กตอบไม่ได้ — ช้าตรงไหน ใครยังไม่ได้เตียง
  /// คนกองอยู่ที่ขั้นย่อยไหน และแบ่งตามความเร่งด่วนอย่างไร
  Widget _zoomPanel(_Phase phase) {
    final people = _ofPhase(phase);
    final over = people.where((p) => p.over).length;
    final noBed = people.where((p) => p.bed == null).length;
    final avg = people.isEmpty
        ? 0
        : (people.map((p) => p.waitMin).reduce((a, b) => a + b) / people.length)
            .round();
    final worst = people.isEmpty
        ? 0
        : people.map((p) => p.waitMin).reduce((a, b) => a > b ? a : b);
    final counts = <_Esi, int>{
      for (final e in _Esi.values) e: people.where((p) => p.esi == e).length,
    };
    final none = people.where((p) => p.esi == null).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                    color: _stageColor(phase.stages.first),
                    shape: BoxShape.circle),
              ),
              const SizedBox(width: 7.0),
              Text(phase.label,
                  style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
              const SizedBox(width: 8.0),
              Text('${people.length} ราย', style: _t(11.0, color: _ink3)),
              const Spacer(),
              _zoomAction('เปิดช่วงงานนี้', () {
                setState(() {
                  _zoom = null;
                  _open = phase;
                  _detail = false;
                });
                _simulateLoad(const Duration(milliseconds: 500));
              }),
              const SizedBox(width: 8.0),
              _zoomAction('ถอยกลับ', () => setState(() => _zoom = null),
                  primary: false),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _zoomStat('เกินเกณฑ์', '$over', 'ราย',
                  color: over > 0 ? _red : _ink),
              _zoomStat('ยังไม่ได้เตียง', '$noBed', 'ราย',
                  color: noBed > 0 ? _blue : _ink),
              _zoomStat('รอเฉลี่ย', _hm(avg), null),
              _zoomStat('รอนานสุด', _hm(worst), null,
                  color: worst > 0 && over > 0 ? _red : _ink),
              // คนกองอยู่ขั้นย่อยไหนของช่วงงานนี้
              SizedBox(
                width: 170.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('แยกตามขั้น', style: _t(9.5, color: _ink3)),
                    const SizedBox(height: 4.0),
                    for (final st in phase.stages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(st.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(10.0, color: _ink2)),
                            ),
                            Text('${_of(st).length}',
                                style: _num(10.5,
                                    color: _ink, weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(width: 12.0),
              // แถบสัดส่วนความเร่งด่วน อ่านง่ายกว่าโดนัทเล็ก ๆ ในการ์ด
              SizedBox(
                width: 190.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ความเร่งด่วน', style: _t(9.5, color: _ink3)),
                    const SizedBox(height: 5.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: SizedBox(
                        height: 10.0,
                        child: Row(
                          children: [
                            for (final e in _Esi.values)
                              if (counts[e]! > 0)
                                Expanded(
                                  flex: counts[e]!,
                                  child: ColoredBox(color: e.color),
                                ),
                            if (none > 0)
                              Expanded(
                                flex: none,
                                child: const ColoredBox(color: _ink3),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 2.0,
                      children: [
                        for (final e in _Esi.values)
                          if (counts[e]! > 0)
                            _zoomKey('${e.level}', counts[e]!, e.color),
                        if (none > 0) _zoomKey('—', none, _ink3),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ตัวเลขหนึ่งช่องในแผงซูม
  Widget _zoomStat(String label, String value, String? unit,
          {Color color = _ink}) =>
      Padding(
        padding: const EdgeInsets.only(right: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: _t(9.5, color: _ink3)),
            const SizedBox(height: 3.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value,
                    style: _num(17.0, color: color, weight: FontWeight.w700)),
                if (unit != null) ...[
                  const SizedBox(width: 3.0),
                  Text(unit, style: _t(9.5, color: _ink3)),
                ],
              ],
            ),
          ],
        ),
      );

  /// คำอธิบายสีหนึ่งตัวใต้แถบสัดส่วน
  Widget _zoomKey(String label, int count, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4.0),
          Text('$label · $count',
              style: _num(9.5, color: _ink2, weight: FontWeight.w600)),
        ],
      );

  /// ปุ่มเล็กในหัวแผงซูม
  Widget _zoomAction(String label, VoidCallback onTap, {bool primary = true}) =>
      _Press(
          child: Material(
        color: primary ? _blue : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(label,
                style: _t(10.5,
                    color: primary ? Colors.white : _ink2,
                    weight: FontWeight.w600)),
          ),
        ),
      ));

  /// ป้าย ESI แบบสายรัดข้อมือ: สายสีระดับ · หมุดกดซ้าย · แผ่นป้ายขาวตรงกลาง (ชื่อระดับสีระดับ)
  /// [t] = ความคืบหน้าตอนปรากฏ 0..1 (1 = ใส่เสร็จ นิ่ง แบน)
  ///
  /// ปรากฏแบบสามมิติ: สายม้วนเป็นหลอดอยู่ที่หมุด แล้วคลี่ออกไปทางขวา
  /// ส่วนที่ยังม้วนโค้งไปด้านหลัง (แกนลึกจริง มี perspective) จากนั้นกดหมุด แล้วพิมพ์ชื่อ
  Widget _esiBand(_P? p, Color color, {double t = 1.0, _Esi? esi}) {
    // หน้าคัดกรอง: ยังไม่มีเคส _P ส่งระดับที่เลือกมาตรง ๆ
    final e = esi ?? p?.esi;
    double seg(double a, double b, [Curve c = Curves.linear]) =>
        c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
    // เริ่มหลังการ์ดเลื่อนเข้าที่ (สลับคน 420ms) จะได้เห็นม้วนคลี่ครบ
    final show = seg(0.24, 0.3, Curves.easeOut);
    final unroll = seg(0.27, 0.8, Curves.easeInOutCubic); // คลี่ม้วน
    final snap = seg(0.76, 0.9, Curves.easeOutBack); // กดหมุด (เด้งเบา)
    final print = seg(0.8, 1.0, Curves.easeOut); // ป้ายชื่อ
    final band = Container(
      height: 24.0,
      padding: const EdgeInsets.fromLTRB(5.0, 3.0, 10.0, 3.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // หมุดกดของสายรัด: เด้งตอนล็อก
        Transform.scale(
          scale: t >= 1.0 ? 1.0 : 0.4 + 0.6 * snap,
          child: Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 5.0),
        // แผ่นป้ายพิมพ์ชื่อ (ขาว ตัวสีระดับ): ตัวอักษรค่อย ๆ ขึ้นจากซ้าย
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => LinearGradient(
              colors: const [Colors.white, Colors.transparent],
              // ขอบจางเริ่มนอกซ้าย: ยังไม่ถึงเวลาพิมพ์ = ไม่เห็นตัวอักษรเลย
              stops: [
                (print * 1.15 - 0.15).clamp(0.0, 1.0),
                (print * 1.15).clamp(0.0, 1.0)
              ],
            ).createShader(r),
            child: Text(e == null ? 'ยังไม่คัดกรอง' : e.en,
                // ESI 3 (ส้ม) บนขาวได้ 2.8:1: เข้มขึ้นให้ผ่าน AA (≥ 4.5:1)
                style: _t(11.0,
                    color: e?.level == 3
                        ? Color.lerp(color, Colors.black, 0.45)!
                        : color,
                    weight: FontWeight.w700)),
          ),
        ),
      ]),
    );
    if (t >= 1.0) return band;
    // ม้วนกระดาษคลี่: ตัวจริงโปร่งใสไว้กำหนดขนาด แล้ววาดสายเป็นแถบตั้งเรียงกัน
    // ส่วนที่คลี่แล้ว (ซ้ายของ u) แบนราบ · ที่เหลือพันเป็นม้วนกลมอยู่หน้าสาย
    // ม้วนกลิ้งไปทางขวาและเล็กลงตามสายที่เหลือ
    return Opacity(
      opacity: show,
      child: Stack(children: [
        Opacity(opacity: 0.0, child: band),
        Positioned.fill(
          child: LayoutBuilder(builder: (context, c) {
            const n = 28;
            final w = c.maxWidth;
            final sw = w / n;
            final u = w * unroll;
            // รัศมีม้วนตามความยาวที่ยังม้วนอยู่ (ม้วนใหญ่ตอนเริ่ม แล้วหดลง)
            final r = 2.0 + 6.0 * math.sqrt(((w - u) / w).clamp(0.0, 1.0));
            final slices = <(double, Widget)>[];
            for (var i = 0; i < n; i++) {
              final x = i * sw;
              var dx = 0.0, dz = 0.0, a = 0.0;
              if (x > u) {
                // พันรอบม้วน: ม้วนขึ้นมาทางกล้อง (อยู่บนสายที่คลี่แล้ว)
                a = (x - u) / r;
                dx = u + r * math.sin(a) - x;
                dz = -r * (1.0 - math.cos(a));
              }
              // ด้านนอกม้วน = หลังกระดาษ (สีสายเข้ม ไม่มีตัวอักษร)
              final back = math.cos(a) < 0.0;
              // แสงตกจากด้านหน้า: แถบที่เอียงหนีกล้องมืดลง
              final shade = 0.3 * (1.0 - math.cos(a).abs());
              // สายเต็มความกว้าง ตัดเอาเฉพาะช่วง [x, x+sw] (ทับขอบ 0.6 กันรอยต่อ)
              Widget slice = ClipRect(
                clipper: _SliceClip(x, sw + 0.6),
                child: SizedBox(width: w, child: band),
              );
              slice = ColorFiltered(
                colorFilter: back
                    ? ColorFilter.mode(
                        Color.lerp(color, Colors.black, 0.18 + shade * 0.6)!,
                        BlendMode.srcIn)
                    : ColorFilter.mode(Colors.black.withValues(alpha: shade),
                        BlendMode.srcATop),
                child: slice,
              );
              slices.add((
                dz,
                Positioned.fill(
                  child: Transform(
                    // หมุนรอบขอบซ้ายของแถบตัวเอง
                    origin: Offset(x, 0.0),
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.004)
                      ..translate(dx, 0.0, dz)
                      ..rotateY(a),
                    child: slice,
                  ),
                )
              ));
            }
            // วาดไกลก่อนใกล้: ชั้นนอกของม้วนทับชั้นใน
            slices.sort((p, q) => q.$1.compareTo(p.$1));
            return Stack(
                clipBehavior: Clip.none,
                children: [for (final e in slices) e.$2]);
          }),
        ),
      ]),
    );
  }

  /// ตัวอักษร/ไอคอนบนพื้นแดงจาง: แดงเข้ม (Google on-error-container) ผ่าน AA 5.8:1
  /// (_red บนพื้นแดง 8% ได้แค่ 4.2:1 ไม่ผ่าน)
  static const Color _onErr = Color(0xFFB3261E);

  /// ป้ายประเภทผู้ป่วย fast track: ⚡ + ชื่อแฟ้ม (สูงเท่า chip ข้าง ๆ)
  /// เนื้อหาการ์ดคนไข้ เข้าฉากไล่ทีละส่วน (ชื่อ, อาการ, ปุ่ม, การ์ดขวา)
  /// จาง + ลอยขึ้น เล่นใหม่เมื่อเปลี่ยนคน
  Widget _cardIn(String hn, int i, Widget child) =>
      TweenAnimationBuilder<double>(
        key: ValueKey('card-$hn-$i'),
        tween: Tween(begin: 0.0, end: 1.0),
        // ไล่บนลงล่าง: เริ่มหลังแถวป้ายด้านบน (สายรัด ESI โผล่ราว 0.45 วิ)
        duration: Duration(milliseconds: 1200 + 110 * i),
        builder: (context, v, child) {
          final t = Curves.easeOutCubic.transform(
              Interval((750 + 110 * i) / (1200 + 110 * i), 1.0).transform(v));
          return Opacity(
            opacity: t,
            child: Transform.translate(
                offset: Offset(0.0, 14.0 * (1.0 - t)), child: child),
          );
        },
        child: child,
      );

  /// ป้ายแถวบนการ์ด เข้าฉากไล่ทีละอันต่อจากสายรัด ESI (เล่นใหม่เมื่อเปลี่ยนคน)
  /// จาง + เด้งขยายจากซ้าย
  Widget _rowIn(String hn, int i, Widget child) =>
      TweenAnimationBuilder<double>(
        key: ValueKey('row-$hn-$i'),
        tween: Tween(begin: 0.0, end: 1.0),
        // เริ่มทันทีที่สายรัดโผล่ แล้วไล่อันละ 0.07 วินาที (แถวบนสุด มาก่อนเนื้อหา)
        duration: Duration(milliseconds: 950 + 70 * i),
        builder: (context, v, child) {
          final start = (500 + 70 * i) / (950 + 70 * i);
          final t = Interval(start, 1.0).transform(v);
          final pop = Curves.easeOutBack.transform(t);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(-8.0 * (1.0 - t), 0.0),
              child: Transform.scale(
                  alignment: Alignment.centerLeft,
                  scale: 0.7 + 0.3 * pop,
                  child: child),
            ),
          );
        },
        child: child,
      );

  Widget _ftBadge(String name) => Container(
        height: 24.0,
        padding: const EdgeInsets.fromLTRB(2.0, 0.0, 8.0, 0.0),
        decoration: BoxDecoration(
          // แดงทึบ ตัวขาว: เด่นกว่าป้ายอื่นบนการ์ด (เคสเร่งด่วน)
          color: _ftRed,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          // นาฬิกาจับเวลา 3D ตัวเดียวกับ hero บนวงขาว (นิ่ง ไม่เล่นท่า)
          // ภาพวาดใหญ่กว่าวงขาว (ปุ่มกดโผล่พ้นวง) ตัวเรือนจึงเต็มวง
          Container(
            width: 21.0,
            height: 21.0,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: OverflowBox(
              maxWidth: 34.0,
              maxHeight: 34.0,
              child: Transform.translate(
                offset: const Offset(0.5, 2.0),
                child: const SizedBox(
                  width: 34.0,
                  height: 34.0,
                  child: CustomPaint(painter: _StopwatchArt(1.0)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          Text(name,
              style: _t(11.5, color: Colors.white, weight: FontWeight.w700)),
        ]),
      );

  /// สิ่งที่แพ้จัดกลุ่มตามประเภท (ยาก่อน แล้วอาหาร) ไม่มีข้อมูลประเภท = ยา
  List<(String, List<String>)> _allergyGroups(List<String> all) {
    final m = <String, List<String>>{};
    for (final a in all) {
      (m[erAllergyInfo(a)?.type ?? 'ยา'] ??= []).add(a);
    }
    return [
      for (final k in [
        'ยา',
        'อาหาร',
        ...m.keys.where((k) => k != 'ยา' && k != 'อาหาร')
      ])
        if (m[k] case final v?) (k, v),
    ];
  }

  /// pill แพ้ยา/อาหาร: ชื่อสิ่งที่แพ้ต่อกันในป้ายเดียว (ไม่บอกอาการ)
  Widget _allergyPill(String kind, List<String> names) {
    // chip error แบบ Google: สูง 24 มุม 8 ไอคอนเตือนนำหน้า
    return Container(
      height: 24.0,
      padding: const EdgeInsets.fromLTRB(6.0, 0.0, 8.0, 0.0),
      decoration: BoxDecoration(
        color: _onErr.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // ไอคอนตามประเภท: ยา = แคปซูลขีดฆ่า (แบบ mdi:pill-off) · อาหาร = no_food
        kind == 'อาหาร'
            ? const Icon(Icons.no_food_outlined, size: 15.0, color: _onErr)
            : const SizedBox(
                width: 15.0,
                height: 15.0,
                child: CustomPaint(painter: _PillOffPainter(_onErr))),
        const SizedBox(width: 4.0),
        Flexible(
            child: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: 'แพ้$kind ${names.join(', ')}',
                style: _t(11.5, color: _onErr, weight: FontWeight.w700)),
          ]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )),
      ]),
    );
  }

  /// การ์ดผู้ป่วยในผังเตียง + แถบหัวกรมท่า (Figma 268-868)
  /// แถบหัว: ช่วงเวลาในห้องฉุกเฉิน · จุดขั้นตอน · ภาพประกอบขั้นปัจจุบัน · สถานะปัจจุบัน
  /// การ์ดขาวซ้อนทับขอบล่างของแถบ ภาพประกอบยืนบนขอบบนของการ์ด
  Widget _scenePatientCard(_Phase phase) {
    const band = 62.0;
    final p = _sceneSelected(phase);
    final ph = _Phase.of(p.stage);
    // แตะตรงไหนของการ์ดก็เข้าหน้ารายละเอียด (ปุ่ม/แถวคำสั่งข้างในยังทำงานของตัวเอง)
    return _CardRipple(
      onTap: () => _openDetail(p),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          left: 0.0,
          right: 0.0,
          top: 0.0,
          height: band + 34.0,
          child: Container(
            // Google style: กรมท่าเรียบ ไม่มีเงาวาว
            decoration: const BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
            ),
            padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 0.0),
            alignment: Alignment.topLeft,
            // เข้าฉากก่อนเนื้อหาการ์ด (เปลี่ยนคน = เล่นใหม่): หัวข้อเลื่อนจากซ้าย
            // ขั้นตอนเด้งทีละวงซ้ายไปขวา สถานะเลื่อนจากขวา
            child: TweenAnimationBuilder<double>(
              key: ValueKey('band-${p.hn}'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              builder: (context, v, _) {
                Widget slide(Widget w, double a, double b, double dx) {
                  final t = Curves.easeOutCubic
                      .transform(Interval(a, b).transform(v));
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                        offset: Offset(dx * (1.0 - t), 0.0), child: w),
                  );
                }

                return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      slide(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('ช่วงเวลาในห้องฉุกเฉิน',
                                  style: _t(14.0,
                                      color: Colors.white,
                                      weight: FontWeight.w600)),
                              const SizedBox(height: 2.0),
                              Text('ติดตามสถานะผู้ป่วยในห้องฉุกเฉิน',
                                  style: _t(11.5,
                                      color: _pInk2, weight: FontWeight.w500)),
                            ],
                          ),
                          0.0,
                          0.45,
                          -16.0),
                      // stepper กึ่งกลางแถบ (ระหว่างหัวข้อซ้ายกับสถานะขวา)
                      Expanded(
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: _phaseSteps(ph, p, t: v))),
                      slide(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('สถานะปัจจุบัน',
                                  style: _t(11.5,
                                      color: _pInk2, weight: FontWeight.w500)),
                              const SizedBox(height: 2.0),
                              Text(ph.label,
                                  style: _t(14.0,
                                      color: Colors.white,
                                      weight: FontWeight.w600)),
                            ],
                          ),
                          0.4,
                          0.9,
                          16.0),
                    ]);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: band),
          child: _scenePatientBody(phase, p),
        ),
      ]),
    );
  }

  /// ขั้นตอนในแถบหัว = ช่วงงานเดียวกับแถบข้าง (ไอคอนเดียวกัน) เรียงตามแถบข้าง
  /// ผ่านแล้ว = เขียว · ช่วงงานปัจจุบัน = ขาว ไอคอนกรมท่า · ยังไม่ถึง = ขาวจาง
  Widget _phaseSteps(_Phase now, _P p, {double t = 1.0}) {
    const steps = _Phase.values;
    final at = steps.indexOf(now);
    Color line(bool reached) =>
        reached ? _green : Colors.white.withValues(alpha: 0.28);
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // เส้นเชื่อมยาวชนขอบวง: ครึ่งซ้าย/ขวาของแต่ละขั้นต่อกันพอดี
          // เข้าฉาก: แต่ละขั้นเด้งขึ้นไล่ซ้ายไปขวา
          for (var i = 0; i < steps.length; i++)
            Builder(builder: (context) {
              final k = Interval(0.15 + 0.12 * i, 0.55 + 0.12 * i)
                  .transform(t.clamp(0.0, 1.0));
              return Opacity(
                opacity: k,
                child: Transform.scale(
                  scale: 0.6 + 0.4 * Curves.easeOutBack.transform(k),
                  child: _phaseStep(steps[i], i < at, i == at,
                      i <= at ? _phaseCheck(p, steps[i]) : null,
                      lineL: i == 0 ? null : line(i <= at),
                      lineR: i == steps.length - 1 ? null : line(i + 1 <= at)),
                ),
              );
            }),
        ]);
  }

  /// หนึ่ง checkpoint: แตะแล้วขึ้น tooltip ชื่อช่วง + เวลาเริ่ม + ผู้ดูแล
  Widget _phaseStep(
      _Phase ph, bool done, bool now, ({String who, String time})? check,
      {Color? lineL, Color? lineR}) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 3),
      preferBelow: false,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: _inkTitle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      richMessage: TextSpan(children: [
        TextSpan(
            text: ph.label,
            style: _t(11.0, color: Colors.white, weight: FontWeight.w700)),
        if (check != null) ...[
          TextSpan(
              text: '\n${_clock(check.time)}',
              style: _num(10.5, color: Colors.white)),
          TextSpan(
              text: '\n${check.who}',
              style: _t(10.5, color: Colors.white.withValues(alpha: 0.8))),
        ] else
          TextSpan(
              text: '\nยังไม่ถึงช่วงนี้',
              style: _t(10.5, color: Colors.white.withValues(alpha: 0.8))),
      ]),
      child: SizedBox(
        width: 88.0 * _txtScale,
        height: 34.0,
        child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Row(children: [
                Expanded(
                    child: Container(
                        height: 2.5, color: lineL ?? Colors.transparent)),
                Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? _green
                        : now
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.18),
                    border: now ? Border.all(color: _green, width: 2.0) : null,
                  ),
                  child: Icon(_phaseIcon(ph),
                      size: 18.0,
                      color: done
                          ? Colors.white
                          : now
                              ? _blue
                              : Colors.white.withValues(alpha: 0.6)),
                ),
                Expanded(
                    child: Container(
                        height: 2.5, color: lineR ?? Colors.transparent)),
              ]),
            ]),
      ),
    );
  }

  /// เวลาเริ่มกับผู้ดูแลของแต่ละช่วงงาน จากทีมประจำเวรและเหตุการณ์ของเคส
  ({String who, String time}) _phaseCheck(_P p, _Phase ph) {
    final c = erCaseOf(p.hn);
    String? member(bool Function(String role) f) {
      for (final (name, role) in c.team) {
        if (f(role)) return name;
      }
      return null;
    }

    final ts = [...c.times, ...c.events.map((e) => e.time)]..sort();
    final doc = [
      for (final e in c.events)
        if (e.byDoctor) e.time
    ]..sort();
    final first = ts.isEmpty ? '-' : ts.first;
    return switch (ph) {
      _Phase.triage => (
          who: member((r) => r.contains('คัดกรอง')) ?? 'พย. ณัฐพร ล.',
          time: first
        ),
      _Phase.treatment => (
          who: member((r) => r.contains('แพทย์')) ?? 'นพ. ธีรภัทร อ.',
          time: doc.isNotEmpty
              ? doc.first
              : ts.length > 1
                  ? ts[1]
                  : first
        ),
      _ => (
          who: member((r) => r == 'พยาบาลประจำเตียง') ?? 'พย. วราภรณ์ ส.',
          time: ts.isEmpty ? '-' : ts.last
        ),
    };
  }

  Widget _scenePatientBody(_Phase phase, _P p) {
    final color = p.esi?.color ?? _ink3;
    return Container(
      // padding สมดุลกับมุมโค้ง 12 · ขอบซ้ายขวาเท่ากัน
      padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 16.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // pill แบบเดียวกับหัวหน้ารายละเอียดผู้ป่วย: เตียง (ขาวนูน) · ESI (สีนูน) · pain
              // ยังไม่ได้เตียง = ไม่มีป้ายเตียง
              // เลขเตียงอยู่บนป้ายหัวเตียงในฉาก 3D แล้ว ไม่ซ้ำบนการ์ด
              // ปรากฏแบบสายรัดข้อมือจริง (เล่นใหม่เมื่อเปลี่ยนคนไข้):
              // 1) สายที่พับครึ่งคลี่ออก 2) กดหมุดล็อก (หมุดเด้ง) 3) ป้ายชื่อพิมพ์ขึ้น
              TweenAnimationBuilder<double>(
                key: ValueKey('esi-${p.hn}'),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1900),
                builder: (context, v, _) =>
                    RepaintBoundary(child: _esiBand(p, color, t: v)),
              ),
              if (erCaseOf(p.hn).painScore case final ps?) ...[
                const SizedBox(width: 6.0),
                _rowIn(p.hn, 1, _painPill(ps, chip: true)),
              ],
              // ประเภทผู้ป่วย = fast track ที่เปิดอยู่ · หลายแฟ้ม = ป้ายเดียว ชื่อต่อกัน
              if (_ftOf(p.hn).isNotEmpty) ...[
                const SizedBox(width: 6.0),
                _rowIn(
                    p.hn,
                    2,
                    _ftBadge([
                      for (final id in _ftOf(p.hn).keys)
                        erFastTrackById(id)?.name ?? id
                    ].join(' + '))),
              ],
              // แพ้ยา / อาหาร ต่อจากป้าย ESI · ล้นแถวแล้วขึ้นบรรทัดใหม่
              const SizedBox(width: 6.0),
              // แถวเดียว เลื่อนแนวนอน ล้นขวาได้ (ขอบขวาจาง) ไม่ขึ้นบรรทัดใหม่
              Expanded(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => const LinearGradient(
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.9, 1.0],
                  ).createShader(r),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      // รวมเป็นป้ายเดียวต่อประเภท: แพ้ยา A, B · แพ้อาหาร C
                      for (final (k, (kind, names))
                          in _allergyGroups(erCaseOf(p.hn).allergies)
                              .indexed) ...[
                        _rowIn(p.hn, 3 + k, _allergyPill(kind, names)),
                        const SizedBox(width: 6.0),
                      ],
                    ]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          IntrinsicHeight(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _cardIn(p.hn, 0, _scenePatientIdentity(p, color)),
                    const SizedBox(height: 10.0),
                    // อาการสำคัญ (CC) จากคัดกรอง แทนสรุปโดยระบบ
                    _cardIn(
                      p.hn,
                      2,
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('อาการสำคัญ',
                                style: _t(11.5,
                                    color: _ink3, weight: FontWeight.w600)),
                            const SizedBox(height: 2.0),
                            Text(
                              erCaseOf(p.hn).cc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: _t(13.5,
                                  height: 1.45,
                                  color: _inkTitle,
                                  weight: FontWeight.w600),
                            ),
                          ]),
                    ),
                    // ปุ่มอยู่ใต้คอลัมน์ซ้าย · การ์ดขวายืดลงถึงขอบล่าง
                    const Spacer(),
                    const SizedBox(height: 14.0),
                    // ปุ่ม 3 อัน (หลังการตรวจ/สังเกตอาการ) ในการ์ดแคบ: ย่อทั้งแถวแทนล้นขวา
                    _cardIn(
                        p.hn,
                        3,
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // เฉพาะปุ่มที่พาไปหน้าจริง: คำสั่งแพทย์ / ผลแล็บ = แท็บในหน้ารายละเอียด
                              // ช่วงคัดกรองยังไม่มีการสั่งแล็บ = ไม่มีปุ่มผลแล็บ
                              if (_Phase.of(p.stage) != _Phase.triage)
                                _sceneCardAction(
                                    Icons.science_rounded, 'ผลแล็บ',
                                    dot: _labNewOf(p.hn).isNotEmpty,
                                    onTap: () => _openDetail(p, tab: 6)),
                              // หลังการตรวจ: เตรียมบันทึกข้อมูลอุบัติเหตุ (บันทึกแล้ว = ไอคอนติ๊ก)
                              if (phase == _Phase.after)
                                _sceneCardAction(
                                    _accSaved(p.hn)
                                        ? Icons.check_circle_rounded
                                        : Icons.car_crash_rounded,
                                    'อุบัติเหตุ',
                                    onTap: () => _openAccident(p)),
                              // สังเกตอาการ: เปิดหน้าบันทึก observe ของเคส (บันทึกแล้ว = ไอคอนติ๊ก)
                              if (phase == _Phase.observe)
                                _sceneCardAction(
                                    _obsRec.containsKey(p.hn)
                                        ? Icons.check_circle_rounded
                                        : Icons.edit_note_rounded,
                                    'บันทึก Observe',
                                    onTap: () => _openObserve(p)),
                              // ปุ่มหลักต่อจากปุ่มรองด้านซ้าย (ไม่ดันไปมุมขวา)
                              const SizedBox(width: 8.0),
                              _Press(
                                child: GestureDetector(
                                  onTap: () => _openDetail(p),
                                  child: Container(
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: _blue,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.person_search_rounded,
                                            size: 16.0, color: Colors.white),
                                        const SizedBox(width: 8.0),
                                        Text('ดูข้อมูล',
                                            style: _t(13.0,
                                                color: Colors.white,
                                                weight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 18.0),
              // กราฟสัญญาณชีพชุดเดียวกับหน้าผังเตียง
              Expanded(
                flex: 5,
                child: _cardIn(
                    p.hn,
                    1,
                    Container(
                      padding: phase == _Phase.observe
                          ? const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0)
                          : EdgeInsets.zero,
                      decoration:
                          phase == _Phase.observe ? _clyTileDeco() : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ปัดซ้าย/ขวาเปลี่ยนกราฟทีละค่า (แท่งแบบเดียวกับหน้ารายละเอียด)
                          // สังเกตอาการ: ไทม์ไลน์กิจกรรมพยาบาลแทนกราฟสัญญาณชีพ
                          SizedBox(
                            // ขยายตามขนาดตัวอักษรที่ตั้งไว้
                            // +54 = แถวปุ่มที่ย้ายไปอยู่ใต้คอลัมน์ซ้าย (ยืดถึงขอบล่างการ์ด)
                            height: 270.0 + (_txtScale - 1.0) * 60.0,
                            child: phase == _Phase.observe
                                ? _nurseActivity(p)
                                // ช่วงคัดกรอง: ยังไม่มีคำสั่งแพทย์ = กราฟสัญญาณชีพ (ปัดเปลี่ยนค่า) แบบเดิม
                                : _Phase.of(p.stage) == _Phase.triage
                                    ? _bedVitals(erCaseOf(p.hn))
                                    : _NoCardRipple(child: _sceneOrders(p)),
                          ),
                        ],
                      ),
                    )),
              ),
            ],
          )),
        ],
      ),
    );
  }

  /// คำสั่งแพทย์ของผู้ป่วยในการ์ดบนฉาก: ที่ยังไม่ได้ทำ ด่วนก่อน · แตะ = เปิดแท็บคำสั่งแพทย์
  Widget _sceneOrders(_P p) {
    // แท็บ คำสั่ง / Fast track ใช้ค่าร่วมกับการ์ดในหน้ารายละเอียด (_bentoFastTab)
    final fastAll = _fastTasks(p.hn);
    final fastTitles = {for (final t in fastAll) t.title};
    // เคสไม่ได้เปิด fast track = ไม่มีแท็บ
    final onFast = _bentoFastTab && fastAll.isNotEmpty;
    final all = onFast
        ? fastAll
        : _sortTasks([
            for (final t in _tasksOfHn(p.hn))
              if (!fastTitles.contains(t.title)) t
          ]);
    final pending = [
      for (final t in all)
        if (!_taskDone.contains(t.title)) t
    ];
    int left(bool fast) => _tasksOfHn(p.hn)
        .where((t) =>
            fastTitles.contains(t.title) == fast &&
            !_taskDone.contains(t.title))
        .length;
    Widget tab(String label, int n, bool fast) {
      final on = onFast == fast;
      return Expanded(
        child: InkWell(
          onTap: on
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  setState(() => _bentoFastTab = fast);
                },
          child: Container(
            height: 38.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color:
                        on ? (fast ? _ftRed : _blue) : const Color(0xFFDADCE0),
                    width: on ? 3.0 : 1.0),
              ),
            ),
            child: _ftTabLabel(label, n, on, fast, 12.5),
          ),
        ),
      );
    }

    // เปลี่ยนคนไข้: รายการเริ่มบนสุด หัวการ์ดกลับมา
    if (_ordersHeadHn != p.hn) {
      _ordersHeadHn = p.hn;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _ordersHeadHidden.value = false);
    }
    // บรรทัดรองใต้หัว = แพทย์ผู้สั่ง แบบเดียวกับการ์ดในหน้ารายละเอียดเคส
    final doctors = <String>[
      for (final t in all)
        if (t.by.isNotEmpty) t.by
    ].toSet().toList();
    // ชุดเดียวกับการ์ดคำสั่งแพทย์ในหน้ารายละเอียดผู้ป่วย (_bentoTasks):
    // แฟ้มหนีบกระดาษมุมขวา + แถวงาน _taskCheckRow (แตะแถว = รับคำสั่ง)
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
        // แท็บ Fast track: แดงจาง ๆ ไล่จากใต้แท็บลงมา (ชุดเดียวกับการ์ดในหน้าคัดกรอง)
        Positioned(
          left: 0.0,
          right: 0.0,
          top: fastAll.isEmpty ? 0.0 : 42.0,
          height: 110.0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 260),
              opacity: onFast ? 1.0 : 0.0,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFEF4F3), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
        ),
        // รูปแฟ้มเป็นส่วนของหัวการ์ด: หัวหุบ = ซ่อนด้วย ไม่โผล่ทับรายการ
        Positioned(
          // พอดีความสูงหัวการ์ด ไม่จมใต้แถวงานแรก (แถวไม่บังรูป)
          right: 14.0,
          top: fastAll.isEmpty ? 4.0 : 44.0,
          width: 50.0,
          height: 54.0,
          child: ValueListenableBuilder<bool>(
            valueListenable: _ordersHeadHidden,
            builder: (context, hide, child) => AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: hide ? 0.0 : 1.0,
                // ซ่อนอยู่ = หยุด animation ไม่ให้ขอเฟรมเปล่า
                child: TickerMode(enabled: !hide, child: child!)),
            // แท็บ Fast track = นาฬิกาจับเวลา · คำสั่ง = แฟ้มหนีบกระดาษ
            child: onFast
                ? const _StopwatchHero(key: ValueKey('sw'))
                : const _ClipboardHero(key: ValueKey('cb')),
          ),
        ),
        Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // แท็บบนสุด (ไม่หุบตามการเลื่อน) พื้นขาวทับรูปแฟ้ม
              if (fastAll.isNotEmpty)
                Container(
                  color: _panel,
                  padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 0.0),
                  child: Row(children: [
                    tab('คำสั่ง', left(false), false),
                    tab('Fast track', left(true), true),
                  ]),
                ),
              // หัวการ์ด: แตะ = เปิดแท็บคำสั่งแพทย์ · เลื่อนรายการลง = หัวหุบซ่อน
              ValueListenableBuilder<bool>(
                valueListenable: _ordersHeadHidden,
                builder: (context, hide, child) => AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: hide ? 0.0 : 1.0,
                    child:
                        hide ? const SizedBox(width: double.infinity) : child,
                  ),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openDetail(p, tab: 3),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('ordhead-${p.hn}-$onFast'),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                            offset: Offset(0.0, 6.0 * (1 - v)), child: child)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 80.0, 8.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(
                                  onFast
                                      ? 'เวลาสำคัญ Fast track'
                                      : 'คำสั่งแพทย์',
                                  style: _t(15.0,
                                      color: _inkTitle,
                                      weight: FontWeight.w700)),
                              if (_orderNewOf(p.hn)) ...[
                                const SizedBox(width: 6.0),
                                _newDot(8.0),
                              ],
                            ]),
                            const SizedBox(height: 1.0),
                            Text(
                                onFast
                                    ? 'บันทึกเวลาแล้ว ${fastAll.length - pending.length} จาก ${fastAll.length}'
                                    : doctors.isEmpty
                                        ? 'ทำครบแล้ว'
                                        : doctors.join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _t(12.0,
                                    color: _ink2, weight: FontWeight.w500)),
                          ]),
                    ),
                  ),
                ),
              ),
              // การ์ดสูงคงที่ในผังเตียง: รายการเลื่อนในการ์ด (ไม่ล้นล่าง)
              Flexible(
                child: NotificationListener<ScrollUpdateNotification>(
                  onNotification: (n) {
                    final h = n.metrics.pixels > 12.0;
                    if (_ordersHeadHidden.value != h) {
                      _ordersHeadHidden.value = h;
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    key: ValueKey('orders-${p.hn}'),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // เข้าฉากไล่บนลงล่าง ทุกครั้งที่สลับแท็บหรือเปลี่ยนคน
                          for (final (i, t) in pending.indexed)
                            i > 7
                                ? _taskCheckRow(t, compact: true)
                                : TweenAnimationBuilder<double>(
                                    key: ValueKey('ord-${p.hn}-$onFast-$i'),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration:
                                        Duration(milliseconds: 380 + 60 * i),
                                    builder: (context, v, child) {
                                      final k = Curves.easeOutCubic.transform(
                                          Interval((60 * i) / (380 + 60 * i),
                                                  1.0)
                                              .transform(v));
                                      return Opacity(
                                        opacity: k,
                                        child: Transform.translate(
                                            offset: Offset(0.0, 10.0 * (1 - k)),
                                            child: child),
                                      );
                                    },
                                    child: _taskCheckRow(t, compact: true),
                                  ),
                        ]),
                  ),
                ),
              ),
            ]),
      ]),
    );
  }

  /// แถวรูป ชื่อ และ HN ของผู้ป่วยในการ์ด
  Widget _scenePatientIdentity(_P p, Color color) => Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                _faceUrl(p.hn),
                fit: BoxFit.cover,
                errorBuilder: (c, e, st) => Container(
                  color: color.withValues(alpha: 0.12),
                  alignment: Alignment.center,
                  child: Icon(Icons.person_rounded, size: 22.0, color: color),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: _t(17.0, weight: FontWeight.w600)),
                const SizedBox(height: 2.0),
                Text('HN ${p.hn}', style: _t(11.5, color: _ink2)),
              ],
            ),
          ),
        ],
      );

  Widget _sceneCardAction(IconData icon, String label,
          {required VoidCallback onTap, bool dot = false}) =>
      _Press(
          child: Padding(
        padding: const EdgeInsets.only(right: 0.0),
        // มีของใหม่ = จุดแดงมุมขวาบน
        child: Stack(clipBehavior: Clip.none, children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(color: const Color(0xFFDADCE0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16.0, color: _blue),
                    const SizedBox(width: 6.0),
                    Text(label,
                        style: _t(12.5, color: _blue, weight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          if (dot) Positioned(right: -2.0, top: -2.0, child: _newDot(10.0)),
        ]),
      ));

  /// การ์ดสรุปหนึ่งขั้นที่ลอยอยู่บนฉาก: จำนวนผู้ป่วยในขั้นนี้ + แยกตามความเร่งด่วน
  /// แถบ ESI แบบแบ่งช่อง: ความกว้างตามจำนวน · ช่องเล็กสุดพอใส่ตัวเลข
  Widget _esiSegBar(List<(Color, int)> segs) {
    if (segs.isEmpty) {
      return Container(
        height: 16.0,
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(5.0),
        ),
      );
    }
    return Row(children: [
      for (var i = 0; i < segs.length; i++) ...[
        if (i > 0) const SizedBox(width: 2.0),
        Expanded(
          // flex ตามจำนวน + ฐานคงที่ ให้ช่อง 1 รายยังกว้างพอใส่เลข
          flex: segs[i].$2 * 4 + 3,
          child: Container(
            height: 16.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: segs[i].$1,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(i == 0 ? 5.0 : 2.0),
                right: Radius.circular(i == segs.length - 1 ? 5.0 : 2.0),
              ),
            ),
            child: Text('${segs[i].$2}',
                style: _num(9.5, color: Colors.white, weight: FontWeight.w700)),
          ),
        ),
      ],
    ]);
  }

  Widget _sceneStatCard(_Phase phase) {
    final people = _ofPhase(phase);
    final counts = <_Esi, int>{
      for (final e in _Esi.values) e: people.where((p) => p.esi == e).length,
    };
    final none = people.where((p) => p.esi == null).length;
    final on = _open == phase || _zoom == phase;
    // ignore: unused_element
    Widget esi(Color c, String label, int n) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.0,
              height: 18.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: _glossGrad(c),
                borderRadius: BorderRadius.circular(5.0),
              ),
              foregroundDecoration: const _InnerGloss(5.0, dark: true),
              child: Text(label,
                  style:
                      _num(9.5, color: Colors.white, weight: FontWeight.w700)),
            ),
            const SizedBox(width: 3.0),
            Text('$n',
                style: _num(11.0, color: _inkTitle, weight: FontWeight.w700)),
          ],
        );
    return _Press(
      child: GestureDetector(
        onTap: () => setState(() {
          if (_open != null) {
            _open = on ? null : phase;
          } else {
            _zoom = _zoom == phase ? null : phase;
            if (_zoom != null) {
              _zoomAt = Alignment(
                  _cardAt[_zoom]!.dx * 2 - 1, _cardAt[_zoom]!.dy * 2 - 1);
            }
          }
        }),
        child: Container(
          width: 176.0,
          padding: const EdgeInsets.fromLTRB(12.0, 9.0, 12.0, 10.0),
          decoration: _clyCardDeco.copyWith(
            border: Border.all(
                color: on ? _stageColor(phase.stages.first) : _line,
                width: on ? 1.5 : 1.0),
          ),
          foregroundDecoration: const _InnerGloss(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(phase.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
                  ),
                  Text('${people.length}',
                      style: _num(20.0,
                          color: _inkTitle, weight: FontWeight.w700)),
                  const SizedBox(width: 3.0),
                  Text('ราย', style: _t(9.5, color: _ink3)),
                ],
              ),
              const SizedBox(height: 6.0),
              // ความเร่งด่วน: แถบแบ่งช่องตามสัดส่วนจำนวนแต่ละระดับ ESI (สีตามระดับ)
              // ตัวเลขในช่อง = จำนวนราย · ระดับที่ไม่มีคนไม่มีช่อง
              _esiSegBar([
                for (final e in _Esi.values)
                  if (counts[e]! > 0) (e.color, counts[e]!),
                if (none > 0) (_g5, none),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

/// ตัดซ้าย/ขวา/ล่างตามขนาดจริง แต่เปิดด้านบน (ภาพประกอบยื่นเหนือการ์ด)
class _TopOpenClip extends CustomClipper<Rect> {
  const _TopOpenClip();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0.0, -200.0, size.width, size.height + 20.0);

  @override
  bool shouldReclip(covariant _TopOpenClip oldClipper) => false;
}

/// แคปซูลยาเอียง 45° + เส้นขีดฆ่า (สื่อ "แพ้ยา") · Flutter ไม่มีไอคอน pill-off ในชุด Icons
class _PillOffPainter extends CustomPainter {
  const _PillOffPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(w / 2, size.height / 2);
    canvas.rotate(-math.pi / 4);
    // แคปซูล: ครึ่งซ้ายทึบ ครึ่งขวาโปร่ง
    final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.86, height: w * 0.4),
        Radius.circular(w * 0.2));
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(-w, -w, 0, w));
    canvas.drawRRect(r, Paint()..color = color);
    canvas.restore();
    canvas.drawRRect(r, stroke);
    canvas.restore();
    // เส้นขีดฆ่าจากซ้ายบนไปขวาล่าง (ตัดผ่านแคปซูล) พร้อมขอบว่างรอบเส้น
    final a = Offset(w * 0.1, w * 0.1), b = Offset(w * 0.9, w * 0.9);
    canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color
          ..strokeWidth = w * 0.12
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_PillOffPainter old) => old.color != color;
}

// ------------------------------------------------ ผังห้องฉุกเฉินสามมิติ (หน้าภาพรวม)

/// ผังแผนกสามมิติ หมุน/ซูม/แตะโซนได้ (ErFloor3D) แต่ละโซนมีหุ่นผู้ป่วยสีตาม ESI
/// โซนแดง ESI 1-2 · เหลือง 3 · เขียว 4-5 (ตรวจรักษาที่ยังไม่คัดกรองนับเขียว)
extension _TabsOverviewFloorPart on _ErFlowHomeWidgetState {
  Widget _floorPlan() {
    const grey = Color(0xFF9AA0A6);
    Color hue(_P p) => p.esi?.hue ?? grey;
    final treat = _ofPhase(_Phase.treatment);
    List<Color> esiIn(bool Function(int? lv) f) => [
          for (final p in treat)
            if (f(p.esi?.level)) hue(p)
        ];
    return RepaintBoundary(
      child: ErFloor3D(
        zones: [
          ErFloorZone(
              id: 'red',
              label: 'โซนแดง',
              color: const Color(0xFFE5394A),
              patients: esiIn((l) => l != null && l <= 2)),
          ErFloorZone(
              id: 'yellow',
              label: 'โซนเหลือง',
              color: const Color(0xFFF2B829),
              patients: esiIn((l) => l == 3)),
          ErFloorZone(
              id: 'green',
              label: 'โซนเขียว',
              color: const Color(0xFF34A853),
              patients: esiIn((l) => l == null || l >= 4)),
          ErFloorZone(
              id: 'triage',
              label: 'คัดกรอง',
              color: const Color(0xFF4A6FD8),
              patients: [for (final p in _ofPhase(_Phase.triage)) hue(p)]),
          ErFloorZone(
              id: 'after',
              label: 'หลังการตรวจ',
              color: const Color(0xFF7E8DA3),
              patients: [for (final p in _ofPhase(_Phase.after)) hue(p)]),
        ],
      ),
    );
  }
}

/// ตัดเอาแถบตั้งช่วง [x, x+w] ของสายรัดข้อมือ (ใช้ตอนม้วนคลี่)
class _SliceClip extends CustomClipper<Rect> {
  const _SliceClip(this.x, this.w);
  final double x, w;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(x, -2.0, w, size.height + 4.0);

  @override
  bool shouldReclip(_SliceClip old) => old.x != x || old.w != w;
}

/// ripple ทั้งการ์ด (การ์ดทึบ ripple ของ Material ข้างหลังจึงมองไม่เห็น)
/// วงคลื่นขยายจากจุดแตะ วาดทับบนการ์ด ตัดตามมุมโค้ง · ไม่กันการแตะของปุ่มข้างใน
class _CardRipple extends StatefulWidget {
  const _CardRipple({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_CardRipple> createState() => _CardRippleState();
}

class _CardRippleState extends State<_CardRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  Offset _at = Offset.zero;
  bool _held = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listener: รับนิ้วลงทุกครั้ง แม้ปุ่มข้างในชนะ gesture (ripple ยังขึ้น)
    return Listener(
      onPointerDown: (d) {
        // นิ้วลงในเขตยกเว้น (การ์ดคำสั่งขวา) = ไม่มีคลื่น
        if (_NoCardRipple._hit == d.pointer) return;
        _at = d.localPosition;
        setState(() => _held = true);
        _c.forward(from: 0.0);
      },
      onPointerUp: (_) => setState(() => _held = false),
      onPointerCancel: (_) => setState(() => _held = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // รอคลื่นกระจายให้เห็นก่อนเปลี่ยนหน้า
          Future.delayed(const Duration(milliseconds: 160), () {
            if (mounted) widget.onTap();
          });
        },
        child: Stack(clipBehavior: Clip.none, children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) => CustomPaint(
                  painter: _CardRipplePainter(_at, _c.value, _held),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// เขตยกเว้น ripple ของการ์ดคนไข้: มีปุ่ม/รายการของตัวเอง
/// Listener ข้างในได้นิ้วก่อนข้างนอกเสมอ จึงจดเลข pointer ไว้ให้ _CardRipple ข้าม
/// และกันแตะพื้นที่ว่างไม่ให้เปิดหน้ารายละเอียด
class _NoCardRipple extends StatelessWidget {
  const _NoCardRipple({required this.child});

  final Widget child;
  static int? _hit;

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (d) => _hit = d.pointer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: child,
        ),
      );
}

class _CardRipplePainter extends CustomPainter {
  const _CardRipplePainter(this.at, this.t, this.held);
  final Offset at;
  final double t;
  final bool held;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0.0 || (t >= 1.0 && !held)) return;
    final far = [
      Offset.zero,
      Offset(size.width, 0.0),
      Offset(0.0, size.height),
      Offset(size.width, size.height),
    ].map((c) => (c - at).distance).reduce(math.max);
    final e = Curves.easeOutCubic.transform(t);
    // ค้างนิ้ว = คลื่นเต็มการ์ดจาง ๆ · ปล่อย = จางหายตอนท้าย
    final a = held ? 0.10 : 0.10 * (1.0 - Curves.easeIn.transform(t));
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(12.0)));
    canvas.drawCircle(at, far * e,
        Paint()..color = const Color(0xFF0B1B3F).withValues(alpha: a));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CardRipplePainter o) =>
      o.t != t || o.at != at || o.held != held;
}
