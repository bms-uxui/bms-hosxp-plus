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

  /// pill แพ้ยา/อาหาร (แบบเดียวกับป้ายเตียง/ESI บนการ์ด): สิ่งที่แพ้ · อาการ
  Widget _allergyPill(String a) {
    final i = erAllergyInfo(a);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        gradient: _glossWhite,
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(color: _red.withValues(alpha: 0.45)),
        boxShadow: _glossLift(const Color(0xFF0B1B3F)),
      ),
      foregroundDecoration: const _InnerGloss(100.0),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
              text: 'แพ้ $a',
              style: _t(9.5, color: _red, weight: FontWeight.w700)),
          if (i != null)
            TextSpan(
                text: ' · ${i.reaction}',
                style: _t(9.5, color: _red, weight: FontWeight.w500)),
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// ติดตามการสั่ง Lab / X-ray เป็นประโยคในสรุปโดยระบบ (จากผลที่มีในเคส)
  String _orderMonitorText(ErCase c) {
    final parts = <String>[];
    final bad = c.labs.where((l) => l.abnormal).length;
    parts.add(c.labs.isEmpty
        ? 'Lab ยังไม่มีผล'
        : 'Lab ออกผลแล้ว ${c.labs.length} รายการ'
            '${bad > 0 ? ' ผิดปกติ $bad' : ''}');
    final wait = [
      for (final i in c.imaging)
        if (i.result.startsWith('รอ')) i.name
    ];
    final done = [
      for (final i in c.imaging)
        if (!i.result.startsWith('รอ')) i.name
    ];
    if (wait.isNotEmpty) parts.add('${wait.join(', ')} รอผลอ่าน');
    if (done.isNotEmpty) parts.add('${done.join(', ')} ออกผลแล้ว');
    return parts.join(' · ');
  }

  Widget _scenePatientCard(_Phase phase) {
    final p = _sceneSelected(phase);
    final color = p.esi?.color ?? _ink3;
    return Container(
      // padding สมดุลกับมุมโค้ง 18 · ขอบซ้ายขวาเท่ากัน
      padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 16.0),
      decoration: _clyCardDeco.copyWith(
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1B3F).withValues(alpha: 0.12),
            blurRadius: 22.0,
            offset: const Offset(0.0, 8.0),
          ),
        ],
      ),
      foregroundDecoration: const _InnerGloss(18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // pill แบบเดียวกับหัวหน้ารายละเอียดผู้ป่วย: เตียง (ขาวนูน) · ESI (สีนูน) · pain
              // ยังไม่ได้เตียง = ไม่มีป้ายเตียง
              if (p.bed != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    gradient: _glossWhite,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: _line),
                    boxShadow: _glossLift(const Color(0xFF0B1B3F)),
                  ),
                  foregroundDecoration: const _InnerGloss(100.0),
                  child: Text(p.bed!,
                      style: _num(10.0,
                          color: _inkTitle, weight: FontWeight.w700)),
                ),
                const SizedBox(width: 6.0),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  gradient: _glossGrad(color),
                  borderRadius: BorderRadius.circular(100.0),
                  boxShadow: _glossLift(color),
                ),
                foregroundDecoration: const _InnerGloss(100.0, dark: true),
                child: Text(
                    p.esi == null
                        ? 'ยังไม่คัดกรอง'
                        : 'ESI ${p.esi!.level} · ${p.esi!.label}',
                    style:
                        _t(9.5, color: Colors.white, weight: FontWeight.w600)),
              ),
              if (erCaseOf(p.hn).painScore case final ps?) ...[
                const SizedBox(width: 6.0),
                _painPill(ps),
              ],
              // แพ้ยา / อาหาร ต่อจากป้าย ESI · ล้นแถวแล้วขึ้นบรรทัดใหม่
              const SizedBox(width: 6.0),
              Expanded(
                child: Wrap(spacing: 6.0, runSpacing: 4.0, children: [
                  for (final a in erCaseOf(p.hn).allergies) _allergyPill(a),
                ]),
              ),
              const SizedBox(width: 10.0),
              // ปุ่มหลักมุมขวาบน
              _Press(
                child: GestureDetector(
                  onTap: () => _openDetail(p),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _glossGrad(_blue),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: _glossLift(_blue),
                    ),
                    foregroundDecoration: const _InnerGloss(12.0, dark: true),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14.0, vertical: 7.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_search_rounded,
                            size: 15.0, color: Colors.white),
                        const SizedBox(width: 8.0),
                        Text('ดูข้อมูล',
                            style: _t(12.0,
                                color: Colors.white, weight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
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
                    // CC รวมเป็นประโยคแรกของสรุป
                    Text(
                      'มาด้วย ${erCaseOf(p.hn).cc}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.5,
                          height: 1.45,
                          color: _inkTitle,
                          weight: FontWeight.w600),
                    ),
                    Text(
                      p.over
                          ? 'ค้างในขั้น${p.stage.label}นาน ${_hm(p.waitMin)} '
                              'เกินเกณฑ์ที่กำหนด ควรเร่งจัดการก่อนรายอื่น'
                          : 'อยู่ในขั้น${p.stage.label} ${_hm(p.waitMin)} '
                              'ยังอยู่ในเกณฑ์',
                      style: _t(12.5, height: 1.45, color: _ink),
                    ),
                    // ติดตามการสั่ง Lab / X-ray
                    Text(_orderMonitorText(erCaseOf(p.hn)),
                        style: _t(12.5, height: 1.45, color: _ink)),
                  ],
                ),
              ),
              const SizedBox(width: 18.0),
              // กราฟสัญญาณชีพชุดเดียวกับหน้าผังเตียง
              Expanded(
                flex: 5,
                child: Container(
                  padding: phase == _Phase.observe
                      ? const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0)
                      : EdgeInsets.zero,
                  decoration: phase == _Phase.observe ? _clyTileDeco() : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ปัดซ้าย/ขวาเปลี่ยนกราฟทีละค่า (แท่งแบบเดียวกับหน้ารายละเอียด)
                      // สังเกตอาการ: ไทม์ไลน์กิจกรรมพยาบาลแทนกราฟสัญญาณชีพ
                      SizedBox(
                        height: 168.0,
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
          const SizedBox(height: 14.0),
          Row(
            children: [
              // เฉพาะปุ่มที่พาไปหน้าจริง: คำสั่งแพทย์ / ผลแล็บ = แท็บในหน้ารายละเอียด
              _sceneCardAction(Icons.assignment_rounded, 'คำสั่งแพทย์',
                  dot: _orderNewOf(p.hn), onTap: () => _openDetail(p, tab: 3)),
              _sceneCardAction(Icons.science_rounded, 'ผลแล็บ',
                  dot: _labNewOf(p.hn).isNotEmpty,
                  onTap: () => _openDetail(p, tab: 6)),
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
          {required VoidCallback onTap, bool dot = false}) =>
      _Press(
          child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        // มีของใหม่ = จุดแดงมุมขวาบน
        child: Stack(clipBehavior: Clip.none, children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: _glossWhite,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: _line),
                boxShadow: _glossLift(const Color(0xFF0B1B3F)),
              ),
              foregroundDecoration: const _InnerGloss(12.0),
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
          if (dot) Positioned(right: -2.0, top: -2.0, child: _newDot(10.0)),
        ]),
      ));

  /// การ์ดสรุปหนึ่งขั้นที่ลอยอยู่บนฉาก: จำนวนผู้ป่วยในขั้นนี้ + แยกตามความเร่งด่วน
  Widget _sceneStatCard(_Phase phase) {
    final people = _ofPhase(phase);
    final counts = <_Esi, int>{
      for (final e in _Esi.values) e: people.where((p) => p.esi == e).length,
    };
    final none = people.where((p) => p.esi == null).length;
    final on = _open == phase || _zoom == phase;
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
              // ความเร่งด่วน: ป้ายสี ESI + จำนวน (ระดับที่ไม่มีคนไม่แสดง)
              Wrap(spacing: 8.0, runSpacing: 4.0, children: [
                for (final e in _Esi.values)
                  if (counts[e]! > 0) esi(e.color, '${e.level}', counts[e]!),
                if (none > 0) esi(_g5, '–', none),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
