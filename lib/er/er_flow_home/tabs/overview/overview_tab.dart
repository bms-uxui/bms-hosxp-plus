// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

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

  Widget _legend() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ระดับความเร่งด่วน', style: _t(10.0, color: _ink3)),
          const SizedBox(height: 6.0),
          for (final e in _Esi.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: e.color,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Text('${e.level} ${e.en}', style: _t(10.0, color: _ink2)),
                ],
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42.0,
                height: 10.0,
                decoration: BoxDecoration(
                  color: _ink3,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              const SizedBox(width: 6.0),
              Text('Not triaged', style: _t(10.0, color: _ink2)),
            ],
          ),
        ],
      );

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
                const SizedBox(height: 12.0),
                _recentSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
