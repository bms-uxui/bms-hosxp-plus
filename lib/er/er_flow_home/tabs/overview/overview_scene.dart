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
                    top: c.maxHeight * 0.40,
                    child: _stepButton(Icons.chevron_left_rounded, -1),
                  ),
                  Positioned(
                    right: 16.0,
                    top: c.maxHeight * 0.40,
                    child: _stepButton(Icons.chevron_right_rounded, 1),
                  ),
                ],
                // การ์ดผู้ป่วยลอยล่างฉาก ต้องวางหลัง WebView ใน Stack
                // ไม่งั้นมุมมองฝั่งระบบจะทับจนมองไม่เห็น
                Positioned(
                  left: 16.0,
                  right: 16.0,
                  bottom: 14.0,
                  child: _loading
                      ? _patientCardSkeleton()
                      : _scenePatientCard(_open!),
                ),
              ],
            ],
          );
        },
      );

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22.0,
            offset: const Offset(0, 8),
          ),
        ],
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

  Widget _scenePatientCard(_Phase phase) {
    final p = _sceneSelected(phase);
    final color = p.esi?.color ?? _ink3;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18.0,
            offset: const Offset(0.0, 6.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(p.bed ?? 'ยังไม่ได้เตียง',
                    style: _num(11.0, color: color, weight: FontWeight.w700)),
              ),
              const SizedBox(width: 6.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                    p.esi == null
                        ? 'ยังไม่คัดกรอง'
                        : 'ESI ${p.esi!.level} · ${p.esi!.label}',
                    style:
                        _t(10.5, color: Colors.white, weight: FontWeight.w600)),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('เวลาอยู่ในขั้น${phase.label}',
                      style: _t(10.0, color: _ink3)),
                  Text(_hm(p.waitMin),
                      style: _num(16.0,
                          weight: FontWeight.w600,
                          color: p.over ? _red : _ink)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _scenePatientIdentity(p, color),
                    const SizedBox(height: 10.0),
                    // อาการสำคัญ (CC) จากจุดคัดกรอง
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 1.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 1.0),
                          decoration: BoxDecoration(
                            color: _panelSoft,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text('CC',
                              style: _t(9.5,
                                  color: _ink2, weight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(erCaseOf(p.hn).cc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _t(12.0,
                                  color: _inkTitle,
                                  weight: FontWeight.w600,
                                  height: 1.35)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            size: 13.0, color: _blue),
                        const SizedBox(width: 5.0),
                        Text('สรุปโดยระบบ',
                            style: _t(10.5,
                                color: _blueHue, weight: FontWeight.w600)),
                        const SizedBox(width: 6.0),
                        Text('ตรวจทานก่อนใช้ตัดสินใจ',
                            style: _t(9.5, color: _ink3)),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      p.over
                          ? 'ค้างในขั้น${p.stage.label}นาน ${_hm(p.waitMin)} '
                              'เกินเกณฑ์ที่กำหนด ควรเร่งจัดการก่อนรายอื่น'
                          : 'อยู่ในขั้น${p.stage.label} ${_hm(p.waitMin)} '
                              'ยังอยู่ในเกณฑ์',
                      style: _t(12.5, height: 1.45, color: _ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14.0),
              // กราฟสัญญาณชีพชุดเดียวกับหน้าผังเตียง
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ปัดซ้าย/ขวาเปลี่ยนกราฟทีละค่า (แท่งแบบเดียวกับหน้ารายละเอียด)
                      // สังเกตอาการ: ไทม์ไลน์กิจกรรมพยาบาลแทนกราฟสัญญาณชีพ
                      SizedBox(
                        height: 128.0,
                        child: phase == _Phase.observe
                            ? _nurseActivity(p)
                            : _bedVitals(erCaseOf(p.hn)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              // เฉพาะปุ่มที่พาไปหน้าจริง: คำสั่งแพทย์ / ผลแล็บ = แท็บในหน้ารายละเอียด
              _sceneCardAction(Icons.assignment_rounded, 'คำสั่งแพทย์',
                  onTap: () => _openDetail(p, tab: 3)),
              _sceneCardAction(Icons.science_rounded, 'ผลแล็บ',
                  onTap: () => _openDetail(p, tab: 6)),
              const Spacer(),
              Material(
                color: _blue,
                borderRadius: BorderRadius.circular(14.0),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openDetail(p),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_search_rounded,
                            size: 16.0, color: Colors.white),
                        const SizedBox(width: 8.0),
                        Text('ข้อมูลผู้ป่วย',
                            style: _t(13.0,
                                color: Colors.white, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
                Text('HN ${p.hn}  |  ${p.stage.label}  |  ${p.note}',
                    style: _t(11.5, color: _ink2)),
              ],
            ),
          ),
        ],
      );

  Widget _sceneCardAction(IconData icon, String label,
          {required VoidCallback onTap}) =>
      _Press(
          child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Material(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(12.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14.0, color: _ink2),
                  const SizedBox(width: 6.0),
                  Text(label,
                      style: _t(11.0, color: _ink, weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ));

  /// การ์ดสรุปหนึ่งขั้นที่ลอยอยู่บนฉาก
  ///
  /// เล่าเรื่องคอขวด ไม่ใช่แค่จำนวนคน
  /// แถบ bullet = คนค้างจริงเทียบความจุที่ขั้นนี้รับไหว (ขีดคือเส้นความจุ)
  /// บรรทัดอัตรา = เข้า/ออกต่อชั่วโมง ต่างกันเท่าไรคือกองเพิ่มหรือระบายออก
  /// แถบล่างสุด = สัดส่วนความเร่งด่วน แทนโดนัทที่กินพื้นที่กว่า
  Widget _sceneStatCard(_Phase phase) {
    final people = _ofPhase(phase);
    final over = people.where((p) => p.over).length;
    final counts = <_Esi, int>{
      for (final e in _Esi.values) e: people.where((p) => p.esi == e).length,
    };
    final none = people.where((p) => p.esi == null).length;
    final on = _open == phase || _zoom == phase;
    final flow = _phaseFlow[phase]!;
    final net = flow.inRate - flow.outRate;
    final full = people.length >= flow.cap;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13.0),
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      child: InkWell(
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
          width: 192.0,
          padding: const EdgeInsets.fromLTRB(11.0, 9.0, 11.0, 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13.0),
            border: Border.all(
                color: on ? _stageColor(phase.stages.first) : _line,
                width: on ? 1.5 : 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(phase.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(10.0, color: _ink2)),
                  ),
                  // ป้ายคอขวดขึ้นเฉพาะขั้นที่คนเข้ามากกว่าออก
                  if (net > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 1.0),
                      decoration: BoxDecoration(
                        color: _red.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text('คอขวด',
                          style: _t(8.5, color: _red, weight: FontWeight.w700)),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${people.length}',
                      style: _num(20.0,
                          color: full ? _red : _ink, weight: FontWeight.w700)),
                  const SizedBox(width: 3.0),
                  Text('/ ${flow.cap} ที่รับไหว', style: _t(9.0, color: _ink3)),
                  const Spacer(),
                  if (over > 0)
                    Text('เกินเกณฑ์ $over',
                        style: _t(9.0, color: _red, weight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 5.0),
              // segmented chart — หนึ่งช่องคือหนึ่งที่ที่ขั้นนี้รับได้
              // ช่องที่มีคนไล่สีตามความเร่งด่วน ช่องว่างเป็นเทา
              // ล้นความจุจะมีช่องแดงต่อท้าย เห็นทันทีว่าเกินไปกี่ราย
              Builder(builder: (context) {
                final segs = _segColors(counts, none, flow.cap);
                return Row(
                  children: [
                    for (var i = 0; i < segs.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2.0),
                      Expanded(
                        child: Container(
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: segs[i],
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: 6.0),
              Row(
                children: [
                  _flowRate(Icons.south_rounded, flow.inRate, _ink2),
                  const SizedBox(width: 10.0),
                  _flowRate(Icons.north_rounded, flow.outRate, _ink2),
                  const Spacer(),
                  Text(
                      net == 0
                          ? 'คงที่'
                          : (net > 0 ? 'กอง +$net/ชม.' : 'ระบาย $net/ชม.'),
                      style: _t(9.0,
                          color: net > 0 ? _red : _ink3,
                          weight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// สีของแต่ละช่องใน segmented chart
  ///
  /// เรียงคนตามความเร่งด่วนก่อน แล้วค่อยเติมช่องว่าง
  /// ถ้าคนเกินความจุ ช่องส่วนเกินเป็นแดงต่อท้าย
  List<Color> _segColors(Map<_Esi, int> counts, int none, int cap) {
    final filled = <Color>[
      for (final e in _Esi.values) ...List.filled(counts[e] ?? 0, e.color),
      ...List.filled(none, _ink3),
    ];
    if (filled.length >= cap) {
      return [
        ...filled.take(cap),
        ...List.filled(filled.length - cap, _red),
      ];
    }
    return [...filled, ...List.filled(cap - filled.length, _panelSoft)];
  }

  /// อัตราเข้า/ออกต่อชั่วโมงหนึ่งตัว
  Widget _flowRate(IconData icon, int value, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.0, color: color),
          const SizedBox(width: 2.0),
          Text('$value/ชม.',
              style: _num(9.5, color: color, weight: FontWeight.w600)),
        ],
      );
}
