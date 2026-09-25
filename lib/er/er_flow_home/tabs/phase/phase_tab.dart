// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _TabsPhasePhaseTabState on State<ErFlowHomeWidget> {
  /// ตัวกรองรายชื่อผู้ป่วยตอนเลือกช่วงงาน
  _ListFilter _listFilter = _ListFilter.all;
}

extension _TabsPhasePhaseTabPart on _ErFlowHomeWidgetState {
  List<_P> _of(_Stage s) {
    final list = _patients.where((p) => p.stage == s).toList();
    // เรียงตามความเสี่ยง ระดับความเร่งด่วนก่อน แล้วค่อยเวลารอ
    // ขั้นรอคัดกรองไม่มีระดับ จึงเรียงด้วยเวลารออย่างเดียว
    list.sort((a, b) {
      final ea = a.esi?.level ?? 9;
      final eb = b.esi?.level ?? 9;
      if (ea != eb) return ea.compareTo(eb);
      return b.waitMin.compareTo(a.waitMin);
    });
    return list;
  }

  // ------------------------------------------------- แผงซ้ายโหมดช่วงงาน
  /// คนในช่วงงานนี้ เรียงตามความเสี่ยง ระดับความเร่งด่วนก่อน แล้วเวลารอ
  List<_P> _ofPhase(_Phase phase) {
    final list = [for (final st in phase.stages) ..._of(st)];
    list.sort((a, b) {
      final ea = a.esi?.level ?? 9;
      final eb = b.esi?.level ?? 9;
      if (ea != eb) return ea.compareTo(eb);
      return b.waitMin.compareTo(a.waitMin);
    });
    return list;
  }

  List<_P> _filtered(List<_P> people) => switch (_listFilter) {
        _ListFilter.all => people,
        _ListFilter.onBed => people.where((p) => p.bed != null).toList(),
        _ListFilter.noBed => people.where((p) => p.bed == null).toList(),
        _ListFilter.over => people.where((p) => p.over).toList(),
      };

  /// ตัวกรองรายชื่อ: ปุ่มเต็มแถบกว้างเท่ากัน แบบแถบแท็บของหน้าผู้ป่วย
  Widget _listChip(_ListFilter f) {
    final on = _listFilter == f;
    return Expanded(
      child: _Press(
        child: GestureDetector(
          onTap: () => setState(() => _listFilter = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 28.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // บนพื้นกรมท่า: ที่เลือก = pill ขาวนูน ตัวอักษรกรมท่า
              gradient: on ? _glossWhite : null,
              borderRadius: BorderRadius.circular(9.0),
              boxShadow: on ? _glossLift(const Color(0xFF000A2E)) : null,
            ),
            foregroundDecoration: on ? const _InnerGloss(9.0) : null,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(f.label,
                  style: _t(10.5,
                      color: on ? _blue : _lpInk2,
                      weight: on ? FontWeight.w600 : FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }

  /// การ์ดสรุปของช่วงงาน: จำนวนผู้ป่วยทั้งหมดในขั้นนี้อย่างเดียว
  Widget _phaseCapCard(
      _Phase phase, List<_P> people, int over, int noBed, int avg) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
      decoration: _lpCardDeco,
      foregroundDecoration: const _InnerGloss(12.0, dark: true),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text('ผู้ป่วยในขั้นนี้',
                style: _t(11.0, color: _lpInk2, weight: FontWeight.w600)),
          ),
          Text('${people.length}',
              style: _num(28.0, color: _lpInk, weight: FontWeight.w700)),
          const SizedBox(width: 4.0),
          Text('ราย', style: _t(11.0, color: _lpInk3)),
        ],
      ),
    );
  }

  Widget _phasePanel(_Phase phase, {Key? key}) {
    final people = _ofPhase(phase);
    final shown = _filtered(people);
    final over = people.where((p) => p.over).length;
    final noBed = people.where((p) => p.bed == null).length;
    final avg = people.isEmpty
        ? 0
        : (people.map((p) => p.waitMin).reduce((a, b) => a + b) / people.length)
            .round();
    return SingleChildScrollView(
      key: key,
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
                    Text(phase.label,
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
                _phaseCapCard(phase, people, over, noBed, avg),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Text('รายชื่อผู้ป่วย',
                        style:
                            _t(11.0, color: _lpInk2, weight: FontWeight.w600)),
                    const Spacer(),
                    Text('${shown.length} ราย',
                        style: _t(10.0, color: _lpInk3)),
                  ],
                ),
                const SizedBox(height: 8.0),
                // ตัวกรอง + รายชื่อรวมในการ์ดเดียว (แบบการ์ดแท็บของหน้าผู้ป่วย)
                Container(
                  padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                  decoration: _lpCardDeco,
                  foregroundDecoration: const _InnerGloss(12.0, dark: true),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: const Color(0x1F000A2E),
                          borderRadius: BorderRadius.circular(11.0),
                        ),
                        child: Row(children: [
                          for (final f in _ListFilter.values) _listChip(f)
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (shown.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                child: Text('ไม่มีผู้ป่วยตามเงื่อนไขนี้',
                                    style: _t(10.5, color: _lpInk3)),
                              )
                            else
                              for (final p in shown) _personRow(p),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
