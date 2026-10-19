// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// ตัวกรองระดับ ESI ของรายชื่อผู้ป่วยหน้าภาพรวม (null = ทั้งหมด)
int? _boardEsi;

extension _TabsOverviewOverviewTabPart on _ErFlowHomeWidgetState {
  // ---------------------------------------------------------------- หัวหน้า
  /// สีประจำขั้น ใช้ทั้งกับแท่นในฉากและป้ายบนจอ
  Color _stageColor(_Stage stage) {
    switch (stage) {
      // ไล่เข้มอ่อนในสีรองสีเดียว ไม่ใช่สี่สีแข่งกับสีเน้น
      case _Stage.triage:
        return _mono ? _g2 : _blue;
      case _Stage.waitDoctor:
        return _mono ? _g3 : _blue2;
      case _Stage.treatment:
        return _mono ? _g4 : _blue3;
      case _Stage.discharge:
        return _mono ? _g5 : _blue4;
      case _Stage.observe:
        return _mono ? _g5 : _blue3;
    }
  }

  /// ตัวเลขใหญ่หนึ่งช่องในแผงซ้าย เป็นการ์ดมีเส้นขอบ
  /// หน่วยต่อท้ายด้วยขนาดเล็กกว่า ตัวเลขจะได้ไม่ต้องแบกความหมายเอง
  /// อ่านง่ายบนพื้นกรมท่า: ป้ายขาวทึบเกือบเต็ม ตัวเลขขาวเสมอ (สีจางบนน้ำเงินอ่านยาก)
  /// สถานะที่ต้องสังเกต (เช่น เตียงเต็ม) บอกด้วยป้าย [tag] มุมขวาบนแทนการเปลี่ยนสีตัวเลข
  Widget _bigStat(String label, String value,
          {String? unit, Color color = _lpInk, String? tag}) =>
      Container(
        padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
        decoration: _lpCardDeco,
        foregroundDecoration: const _InnerGloss(12.0, dark: true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                child: Text(label,
                    style: _t(12.0, color: _lpInk2, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7.0, vertical: 1.0),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Text(tag,
                      style: _t(10.0,
                          color: Colors.white, weight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // ค่าใหญ่ย่อลงเองเมื่อช่องแคบ (เช่น "2:18") ไม่ล้นขวา
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        style:
                            _num(28.0, color: color, weight: FontWeight.w700)),
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4.0),
                  Flexible(
                    child: Text(unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            _t(12.0, color: _lpInk2, weight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ],
        ),
      );

  // คำอธิบายสีเคยลอยบนฉาก · หน้าภาพรวมใช้กระดานแล้ว (ป้าย ESI บอกระดับในการ์ดเอง)
  Widget _legend() => const SizedBox.shrink();

  Widget _overviewPanel() {
    final over = _patients.where((p) => p.over).length;
    // นับจากข้อมูลจริง ให้ตรงกับแถบล่างที่นับเตียงที่ใช้
    final vacant =
        _roomBeds.length - _patients.where((p) => p.bed != null).length;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          18.0, 6.0, 0.0, 76.0), // ล่างเว้นให้ป้ายผู้ใช้
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ภาพรวมห้องฉุกเฉิน',
                        style:
                            _t(19.0, color: _lpInk, weight: FontWeight.w700)),
                    Text('อัปเดทข้อมูลทุก 30 วินาที',
                        style: _t(10.5, color: _lpInk3)),
                  ],
                ),
              ),
              _collapseButton(),
            ],
          ),
          // เนื้อหาที่เหลือกลับมามีขอบขวา 16 เหมือนเดิม
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12.0),
                // ลงทะเบียนผู้ป่วยใหม่ = งานแรกของห้อง ER วางบนสุดของหน้าแรก
                Row(children: [
                  Expanded(flex: 3, child: _registerButton()),
                  const SizedBox(width: 8.0),
                  Expanded(flex: 2, child: _faceScanButton()),
                ]),
                const SizedBox(height: 12.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _bigStat(
                          'ผู้ป่วยในห้องตอนนี้', '${_patients.length}',
                          unit: 'ราย'),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _bigStat('ค้างเกินเกณฑ์', '$over',
                          unit: 'ราย',
                          color: over > 0 ? _onLight(_red) : _lpInk),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _bigStat('เวลาเฉลี่ยใน ER', '2:18', unit: 'ชม.'),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: _bigStat(
                          'เตียงว่าง', '$vacant/${_roomBeds.length}',
                          unit: 'เตียง', tag: vacant == 0 ? 'เต็ม' : null),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 10.0),
                  decoration: _lpCardDeco,
                  foregroundDecoration: const _InnerGloss(12.0, dark: true),
                  child: _HourChart(t: _t, num: _num),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- กระดานภาพรวม
  /// หน้าภาพรวม (ขวาของแผง KPI): 2 หน้าต่าง
  /// ซ้าย = visualization (placeholder รอออกแบบ) · ขวา = รายชื่อผู้ป่วย 2 คอลัมน์ เรียงตามความเร่งด่วน
  /// chip ระดับ ESI: จุดสีระดับ + ชื่อ + จำนวน · เลือกแล้ว = พื้นสีระดับอ่อน ขอบสี
  Widget _esiChip(_Esi? e, int n) {
    final on = _boardEsi == e?.level;
    final col = e?.color ?? _blue;
    return _Press(
      child: GestureDetector(
        // แตะซ้ำที่ระดับที่เลือกอยู่ = เลิกกรอง (แสดงทุกคน)
        onTap: () => setState(() => _boardEsi = on ? null : e?.level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 32.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: on ? col.withValues(alpha: 0.10) : _panel,
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(
                color: on ? col : const Color(0xFFDADCE0),
                width: on ? 1.2 : 0.5),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (e != null) ...[
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(color: col, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6.0),
            ],
            Text(e == null ? 'ทั้งหมด' : 'ESI ${e.level}',
                style: _t(12.5,
                    color: on ? (e == null ? _blue : col) : _inkTitle,
                    weight: FontWeight.w600)),
            const SizedBox(width: 6.0),
            Text('$n',
                style: _num(12.0,
                    color: on ? (e == null ? _blue : col) : _ink3,
                    weight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  Widget _overviewBoard() {
    final all = [..._patients]..sort((a, b) {
        final e = (a.esi?.level ?? 9).compareTo(b.esi?.level ?? 9);
        return e != 0 ? e : b.waitMin.compareTo(a.waitMin);
      });
    final list = _boardEsi == null
        ? all
        : all.where((p) => p.esi?.level == _boardEsi).toList();
    // เลื่อนรายชื่อขึ้น = visualize เลื่อนพ้นจอไป (แบบ SliverAppBar) · หัวข้อ + chip ค้างบนสุด
    final cardH = 206.0 + (_txtScale - 1.0) * 60.0;
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
      child: CustomScrollView(slivers: [
        // ---- visualize: placeholder เปล่า ไม่มีการ์ดครอบ
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: SizedBox(
              height: 170.0,
              child: CustomPaint(
                painter: _DashRectPainter(),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.insights_rounded,
                        size: 28.0, color: _ink3),
                    const SizedBox(height: 4.0),
                    Text('Visualization',
                        style: _t(14.0, color: _ink2, weight: FontWeight.w600)),
                    Text('รอออกแบบ',
                        style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
          ),
        ),
        // ---- หัวข้อ + chip ระดับ ESI: ค้างบนสุดเมื่อเลื่อน
        SliverPersistentHeader(
          pinned: true,
          delegate: _BoardHeader(
            height: 52.0,
            child: Container(
              color: _bg,
              alignment: Alignment.center,
              child: Row(children: [
                Text('รายชื่อผู้ป่วย',
                    style: _t(16.0, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(width: 12.0),
                // chip ชิดขวา (เลื่อนแนวนอนได้เมื่อที่ไม่พอ)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(children: [
                      for (final e in _Esi.values) ...[
                        _esiChip(e, all.where((p) => p.esi == e).length),
                        if (e != _Esi.values.last) const SizedBox(width: 6.0),
                      ],
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
        // ---- การ์ดผู้ป่วย 2 ใบต่อแถว เต็มความกว้าง
        SliverToBoxAdapter(
          child: LayoutBuilder(builder: (context, box) {
            final alertHn = _footAlertHn;
            // การ์ดมีระยะขวา 10 ในตัว: แถวละ 2 ใบพอดี
            final w = (box.maxWidth / 2 - 10.0).floorToDouble();
            return Padding(
              // เลื่อนสุดแล้วการ์ดแถวสุดท้ายเห็นครบ พ้นมุมโค้งของจอ
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Wrap(children: [
                for (final (i, p) in list.indexed)
                  SizedBox(
                    height: cardH,
                    child: _footCard(p, alertHn: alertHn, order: i, width: w),
                  ),
              ]),
            );
          }),
        ),
      ]),
    );
  }
}

/// หัวรายชื่อที่ค้างบนสุดตอนเลื่อน (ความสูงคงที่)
class _BoardHeader extends SliverPersistentHeaderDelegate {
  _BoardHeader({required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrink, bool overlaps) =>
      SizedBox.expand(child: child);
  @override
  bool shouldRebuild(_BoardHeader o) => true;
}

/// กรอบเส้นประมุมโค้ง (พื้นที่ placeholder)
class _DashRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(12.0));
    final path = Path()..addRRect(r);
    final paint = Paint()
      ..color = const Color(0xFFC4C9D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10.0) {
        canvas.drawPath(m.extractPath(d, d + 5.0), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashRectPainter o) => false;
}
