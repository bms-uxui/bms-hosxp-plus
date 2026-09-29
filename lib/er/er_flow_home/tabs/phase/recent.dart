// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _TabsPhaseRecentState on State<ErFlowHomeWidget> {
  /// ผู้ป่วยที่เปิดดูล่าสุด (ใหม่สุดก่อน) ตั้งต้นด้วยเคสที่แพทย์เวรเพิ่งดูในกะนี้
  final List<String> _recentHn = [
    '670123476',
    '670123477',
    '670123469',
    '670123468',
    '670123460',
    '670123461',
    '670123470',
    '670123474',
  ];
}

extension _TabsPhaseRecentPart on _ErFlowHomeWidgetState {
  // ------------------------------------------------- ผู้ป่วยที่ดูล่าสุด
  // การ์ดตาม Figma 195-681: ชื่อ เตียง/ขั้นงาน ค่าเด่นหนึ่งค่า
  // + หุ่นเงาครอปเฉพาะส่วน ไฮไลต์อวัยวะของอาการสำคัญ

  void _touchRecent(String hn) {
    _recentHn.remove(hn);
    _recentHn.insert(0, hn);
    if (_recentHn.length > 8) _recentHn.removeLast();
  }

  Widget _recentSection() {
    final people = [
      for (final hn in _recentHn)
        for (final p in _patients)
          if (p.hn == hn) p,
    ];
    if (people.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        Row(children: [
          Text('ผู้ป่วยที่ดูล่าสุด',
              style: _t(12.5, color: _lpInk, weight: FontWeight.w700)),
          const Spacer(),
          Text('${people.length} ราย', style: _t(10.0, color: _lpInk3)),
        ]),
        const SizedBox(height: 8.0),
        for (final p in people)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _recentCard(p),
          ),
      ],
    );
  }

  /// ค่าหลักของเคสที่ map ตำแหน่งบนหุ่นไม่ได้ (knowledge #41)
  /// เลือกจากคำใน CC + วินิจฉัย แล้วใช้ค่าจริงของเคสเท่านั้น (ไม่มีค่า = null ไม่แสดงภาพ)
  ({String label, String value, String unit, List<double> series, bool bad})?
      _recentMetric(ErCase c, {bool strongOnly = false}) {
    // strongOnly ดูแค่ CC + วินิจฉัยหลัก (วินิจฉัยรอง เช่น ความดันในเคสอุบัติเหตุ ไม่นับ)
    final dxText = strongOnly
        ? (c.dx.isEmpty ? '' : c.dx.first.text)
        : c.dx.map((d) => d.text).join(' ');
    final t = '${c.cc} $dxText'.toLowerCase();
    bool has(List<String> k) => k.any(t.contains);
    // strongOnly: เฉพาะโรคที่ตัวโรคคือค่า (น้ำตาล ความดัน) ใช้ก่อนหุ่นเสมอ
    // อาการร่วมอย่าง "ซึม" ไม่ควรทำให้การ์ด DKA กลายเป็นหุ่นที่ศีรษะ
    if (has(['น้ำตาล', 'เบาหวาน', 'dka', 'glucose', 'hypoglyc', 'hyperglyc'])) {
      final g = c.labs
          .where((l) =>
              l.isNumeric &&
              RegExp(r'glucose|dtx|fbs|blood sugar', caseSensitive: false)
                  .hasMatch(l.name))
          .firstOrNull;
      if (g != null) {
        return (
          label: g.name,
          value: g.resultText,
          unit: 'mg/dL',
          series: const <double>[],
          bad: g.abnormal
        );
      }
    }
    if (has(['ความดัน', 'hypertens']) && c.sbp.isNotEmpty) {
      return (
        label: 'BP',
        value: c.bp,
        unit: 'mmHg',
        series: c.sbp,
        bad: c.sbp.last >= 140 || c.sbp.last < 90
      );
    }
    if (strongOnly) return null;
    if (has(['ไข้', 'ติดเชื้อ', 'sepsis', 'หนาวสั่น']) && c.bt.isNotEmpty) {
      final v = c.bt.last;
      return (
        label: 'BT',
        value: v.toStringAsFixed(1),
        unit: '°C',
        series: c.bt,
        bad: v > 37.5 || v < 36.0
      );
    }
    if (has(['หอบ', 'เหนื่อย', 'หายใจ', 'dyspnea']) && c.spo2.isNotEmpty) {
      final v = c.spo2.last;
      return (
        label: 'SpO₂',
        value: v.round().toString(),
        unit: '%',
        series: c.spo2,
        bad: v < 95
      );
    }
    return null;
  }

  /// ภาพฝั่งขวาของการ์ดแทนหุ่น: ค่าหลักตัวใหญ่ + กราฟแนวโน้ม (แดงเมื่อผิดปกติ)
  Widget _recentMetricArt(
      ({
        String label,
        String value,
        String unit,
        List<double> series,
        bool bad
      }) m) {
    final col = m.bad ? _red : _blue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(m.label, style: _t(10.0, color: _ink3, weight: FontWeight.w600)),
        // ค่ายาว (BP 178/104) ย่อเองให้พอดีพื้นที่ ไม่ล้นการ์ด
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(m.value,
                    style: _num(24.0,
                        color: m.bad ? _red : _inkTitle,
                        weight: FontWeight.w700)),
                const SizedBox(width: 3.0),
                Text(m.unit, style: _t(9.5, color: _ink3)),
              ]),
        ),
        const SizedBox(height: 4.0),
        if (m.series.length > 1)
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: CustomPaint(
                painter: _VsSpark(
                  values: m.series,
                  labels: [for (final _ in m.series) ''],
                  pick: m.series.length - 1,
                  ink: col,
                  faint: _ink3,
                  fill: col.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _recentCard(_P p) {
    final c = erCaseOf(p.hn);
    // โรคที่ตัวโรคคือค่า (เบาหวาน = น้ำตาล ความดัน = BP) แสดงค่าก่อนหุ่นเสมอ
    // ที่เหลือ: มีตำแหน่งบนหุ่น = หุ่น · ไม่มี = ค่าหลักของอาการ (ไข้ = BT หอบ = SpO₂)
    final strong = _recentMetric(c, strongOnly: true);
    final target = strong != null ? null : erBodyPrimary(c);
    final metric = strong ?? (target == null ? _recentMetric(c) : null);
    return _Press(
        scale: 0.98,
        child: Material(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openPatient(p),
            child: SizedBox(
              // ขยายตามขนาดตัวอักษรที่ตั้งไว้
              height: 120.0 + (_txtScale - 1.0) * 60.0,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // map ตำแหน่งบนหุ่นไม่ได้ (เช่น เบาหวาน ความดัน) = แสดงค่าหลักแทน
                  // ไม่มีค่าที่เกี่ยวข้องด้วย = ข้อความเต็มการ์ด
                  if (metric != null)
                    Positioned(
                      right: 12.0,
                      top: 10.0,
                      bottom: 12.0,
                      width: 120.0,
                      child: _recentMetricArt(metric),
                    ),
                  if (target != null) ...[
                    // หุ่น 3D กว้างสองเท่าของพื้นที่เดิม ล้นไปใต้ข้อความได้ โดนตัดแค่ขอบการ์ด
                    Positioned(
                      right: -46.0,
                      top: 0.0,
                      bottom: 0.0,
                      width: 216.0,
                      child: Tooltip(
                        message: 'อาการสำคัญ: ${c.cc} · ${target.th}',
                        child: SizedBox(
                          height: 120.0,
                          child: ClipRect(child: _bodyMapThumb(target)),
                        ),
                      ),
                    ),
                    // ไล่ขาวจากซ้าย ให้ข้อความอ่านง่ายเหนือหุ่น
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _panel,
                                _panel.withValues(alpha: 0.85),
                                _panel.withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.38, 0.62],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  Positioned(
                    left: 0.0,
                    top: 0.0,
                    bottom: 0.0,
                    width: target == null && metric == null ? null : 170.0,
                    right: target == null && metric == null ? 0.0 : null,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 4.0, 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            _rowAvatarLight(p),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(11.5,
                                          color: _inkTitle,
                                          weight: FontWeight.w700)),
                                  Text(
                                      p.bed == null
                                          ? p.stage.label
                                          : '${p.bed} · ${p.stage.label}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _t(9.0, color: _ink3)),
                                ],
                              ),
                            ),
                          ]),
                          const SizedBox(height: 6.0),
                          // อาการสำคัญ (CC) จากจุดคัดกรอง มีป้ายบอกว่าเป็น CC
                          Text('CC',
                              style: _t(8.5,
                                  color: _ink3, weight: FontWeight.w700)),
                          const SizedBox(height: 1.0),
                          Text(c.cc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: _t(9.5,
                                  color: _ink2,
                                  weight: FontWeight.w600,
                                  height: 1.3)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
