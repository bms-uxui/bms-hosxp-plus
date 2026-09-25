// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _TabsPhaseRecentState on State<ErFlowHomeWidget> {
  /// ผู้ป่วยที่เปิดดูล่าสุด (ใหม่สุดก่อน) ตั้งต้นด้วยเคสที่แพทย์เวรเพิ่งดูในกะนี้
  final List<String> _recentHn = [
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

  Widget _recentCard(_P p) {
    final c = erCaseOf(p.hn);
    final target = erBodyPrimary(c);
    return _Press(
        scale: 0.98,
        child: Material(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openPatient(p),
            child: SizedBox(
              height: 120.0,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // map ตำแหน่งบนหุ่นไม่ได้ (เช่น เบาหวาน ความดัน) = ไม่แสดงหุ่น ข้อความเต็มการ์ด
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
                    width: target == null ? null : 170.0,
                    right: target == null ? 0.0 : null,
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
                          // อาการสำคัญ (CC) จากจุดคัดกรอง
                          Text(c.cc,
                              maxLines: 4,
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
