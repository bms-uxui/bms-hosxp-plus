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

  /// ตัวกรองรายชื่อ: filter chip แบบ Google บนพื้นกรมท่า
  /// ไม่เลือก = ขอบขาวจาง · เลือก = ขาวทึบ ตัวกรมท่า + เครื่องหมายถูก · ท้ายชิปบอกจำนวน
  Widget _listChip(_ListFilter f, int n) {
    final on = _listFilter == f;
    return _Press(
      child: GestureDetector(
        onTap: () => setState(() => _listFilter = f),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 32.0,
          padding: EdgeInsets.fromLTRB(on ? 8.0 : 12.0, 0.0, 12.0, 0.0),
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: on ? Colors.white : _lpLine),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (on) ...[
              const Icon(Icons.check_rounded, size: 16.0, color: _blue),
              const SizedBox(width: 4.0),
            ],
            Text(f.label,
                style: _t(12.5,
                    color: on ? _blue : _lpInk, weight: FontWeight.w600)),
            const SizedBox(width: 6.0),
            Text('$n',
                style: _num(12.5,
                    color: on ? _blue : _lpInk2, weight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  /// สรุปหัวแผง: จำนวนผู้ป่วยในขั้นนี้ ตัวใหญ่
  Widget _phaseSummary(List<_P> people) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('${people.length}',
              style: _num(34.0, color: _lpInk, weight: FontWeight.w700)),
          const SizedBox(width: 6.0),
          Text('ราย ในขั้นนี้',
              style: _t(13.0, color: _lpInk, weight: FontWeight.w500)),
        ],
      ),
    ]);
  }

  Widget _phasePanel(_Phase phase, {Key? key}) {
    final people = _ofPhase(phase);
    final shown = _filtered(people);
    int count(_ListFilter f) => switch (f) {
          _ListFilter.all => people.length,
          _ListFilter.onBed => people.where((p) => p.bed != null).length,
          _ListFilter.noBed => people.where((p) => p.bed == null).length,
          _ListFilter.over => people.where((p) => p.over).length,
        };
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
                    Text('อัปเดตข้อมูลทุก 30 วินาที',
                        style: _t(11.5, color: _lpInk2)),
                  ],
                ),
              ),
              _collapseButton(),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 14.0),
                // ขั้นคัดกรอง: รับผู้ป่วยเข้าได้จากหน้านี้เลย (ปุ่มเดียวกับหน้าแรก)
                if (phase == _Phase.triage) ...[
                  Row(children: [
                    Expanded(flex: 3, child: _registerButton(quick: true)),
                    const SizedBox(width: 8.0),
                    Expanded(flex: 2, child: _faceScanButton()),
                  ]),
                  const SizedBox(height: 14.0),
                ],
                _phaseSummary(people),
                const SizedBox(height: 12.0),
                // ตัวกรองเลื่อนแนวนอนได้ (ไม่บีบตัวอักษร)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final (k, f) in _ListFilter.values.indexed) ...[
                      if (k > 0) const SizedBox(width: 8.0),
                      _listChip(f, count(f)),
                    ],
                  ]),
                ),
                const SizedBox(height: 8.0),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Text('ไม่มีผู้ป่วยตามเงื่อนไขนี้',
                        style: _t(12.5, color: _lpInk2)),
                  )
                else
                  for (final (k, p) in shown.indexed)
                    _personRow(p, first: k == 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
