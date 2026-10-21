// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _TabsPhasePhaseTabState on State<ErFlowHomeWidget> {
  /// ตัวกรองรายชื่อผู้ป่วยตอนเลือกช่วงงาน
  _ListFilter _listFilter = _ListFilter.all;

  /// กรองเฉพาะผู้ป่วยที่เปิดแฟ้ม fast track (ตัวกรองแยก ไม่ต้องแก้ enum ใน core)
  bool _ftOnly = false;

  /// กลุ่มย่อยของ fast track (id แฟ้ม เช่น stroke) · null = ทุกกลุ่ม
  String? _ftGroup;

  /// ตำแหน่งปุ่ม Fast track / แถวชิป (จุดเริ่มของแถวย่อยที่โผล่จากใต้ปุ่ม)
  final GlobalKey _ftChipKey = GlobalKey();
  final GlobalKey _ftRowKey = GlobalKey();
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

  List<_P> _filtered(List<_P> people) => _ftOnly
      ? people
          .where((p) => _ftGroup == null
              ? _ftOf(p.hn).isNotEmpty
              : _ftOf(p.hn).containsKey(_ftGroup))
          .toList()
      : switch (_listFilter) {
          _ListFilter.all => people,
          _ListFilter.onBed => people.where((p) => p.bed != null).toList(),
          _ListFilter.noBed => people.where((p) => p.bed == null).toList(),
          _ListFilter.over => people.where((p) => p.over).toList(),
        };

  /// ตัวกรองรายชื่อ: filter chip แบบ Google บนพื้นกรมท่า
  /// ไม่เลือก = ขอบขาวจาง · เลือก = ขาวทึบ ตัวกรมท่า + เครื่องหมายถูก · ท้ายชิปบอกจำนวน
  Widget _listChip(_ListFilter f, int n) {
    final on = !_ftOnly && _listFilter == f;
    return _Press(
      child: GestureDetector(
        onTap: () => setState(() {
          _listFilter = f;
          _ftOnly = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 32.0,
          padding: EdgeInsets.fromLTRB(on ? 8.0 : 12.0, 0.0, 12.0, 0.0),
          decoration: BoxDecoration(
            // ไม่เลือก = พื้นขาวจางทึบ (ไม่ใช่แค่ขอบ) · เลือก = ขาวทึบ
            color: on ? Colors.white : const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(8.0),
            border:
                Border.all(color: on ? Colors.white : const Color(0x1FFFFFFF)),
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

  /// ชิป Fast track: แบบเดียวกับชิปตัวกรอง + สายฟ้าแดง · เลือกซ้ำ = ทั้งหมด
  Widget _ftChip(int n) {
    final on = _ftOnly;
    return KeyedSubtree(
        key: _ftChipKey,
        child: _Press(
          child: GestureDetector(
            onTap: () => setState(() {
              _ftOnly = !_ftOnly;
              _ftGroup = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 32.0,
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 12.0, 0.0),
              decoration: BoxDecoration(
                // ไม่เลือก = พื้นขาวจางทึบ (ไม่ใช่แค่ขอบ) · เลือก = ขาวทึบ
                color: on ? Colors.white : const Color(0x1FFFFFFF),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                    color: on ? Colors.white : const Color(0x1FFFFFFF)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(on ? Icons.check_rounded : Icons.bolt_rounded,
                    size: 16.0, color: on ? _blue : _ftRed),
                const SizedBox(width: 4.0),
                Text('Fast track',
                    style: _t(12.5,
                        color: on ? _blue : _lpInk, weight: FontWeight.w600)),
                const SizedBox(width: 6.0),
                Text('$n',
                    style: _num(12.5,
                        color: on ? _blue : _lpInk2, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ));
  }

  /// ชิปกลุ่มย่อย fast track: เล็กกว่าชิปหลัก (pill) · เลือก = ขาวทึบ ตัวกรมท่า
  /// ชิปกลุ่มย่อยโผล่จากใต้ปุ่ม Fast track ทีละชิป (เหลื่อมเวลา):
  /// เริ่มซ้อนอยู่ตรงปุ่ม (x = anchor, ขึ้นไปใต้แถวหลัก) แล้วลอยลงไปที่ตำแหน่งจริง
  Widget _ftSubChip(
          double v, double anchor, int i, String? id, String label, int n) =>
      _ftSubChipBody(id, label, n);

  Widget _ftSubChipBody(String? id, String label, int n) {
    final on = _ftGroup == id;
    return _Press(
      child: GestureDetector(
        onTap: () => setState(() => _ftGroup = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 28.0,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: on ? Colors.white : const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label,
                style: _t(12.0,
                    color: on ? _blue : _lpInk, weight: FontWeight.w600)),
            const SizedBox(width: 5.0),
            Text('$n',
                style: _num(12.0,
                    color: on ? _blue : _lpInk2, weight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  /// แถวรายชื่อที่โผล่/หายตามตัวกรอง: ความสูงยืด/หด (เลื่อนแถวอื่นตาม) + จาง
  Widget _rowPresence({Key? key, required bool show, required Widget child}) =>
      ClipRect(
        key: key,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          heightFactor: show ? 1.0 : 0.0,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: show ? 360 : 200),
            curve: show ? Curves.easeOut : Curves.easeIn,
            opacity: show ? 1.0 : 0.0,
            child: IgnorePointer(ignoring: !show, child: child),
          ),
        ),
      );

  /// แถวชิปเลื่อนแนวนอนแบบชิดขอบแผง: ชิปเลื่อนล้นออกขอบซ้าย/ขวาได้ (ไม่โดนตัดที่ขอบเนื้อหา)
  /// แผงเว้นซ้าย 18 ขวา 0 → ขยายกล่องเลื่อนออกซ้าย 18 แล้วเว้นใน 18 ให้ชิปแรกตรงแนวเดิม
  Widget _chipBleed(Widget row) => LayoutBuilder(
        builder: (context, box) => Transform.translate(
          offset: const Offset(-18.0, 0.0),
          child: SizedBox(
            width: box.maxWidth + 18.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: row,
            ),
          ),
        ),
      );

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
                // แถวกลุ่มย่อย fast track โผล่ออกมาจากใต้ปุ่ม Fast track:
                // เริ่มซ้อนอยู่ใต้ปุ่ม (ชิดตำแหน่งปุ่ม เลื่อนขึ้นไปอยู่หลังแถวหลัก) แล้วเลื่อนลง + กางออกทางขวา
                // แถวหลักวาดทับด้านบน (Stack ลูกหลัง) จึงเหมือนชิปย่อยหลุดออกมาจากใต้ปุ่ม · ไม่มีเส้นตัด
                TweenAnimationBuilder<double>(
                  tween: Tween(end: _ftOnly ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.linear,
                  builder: (context, v, _) {
                    // ระยะจากต้นแถวถึงปุ่ม Fast track (เฟรมก่อนหน้า) · ไม่มี = ประมาณ
                    var anchor = 112.0;
                    final fb = _ftChipKey.currentContext?.findRenderObject();
                    final sb = _ftRowKey.currentContext?.findRenderObject();
                    if (fb is RenderBox &&
                        sb is RenderBox &&
                        fb.attached &&
                        sb.attached) {
                      anchor = fb.localToGlobal(Offset.zero).dx -
                          sb.localToGlobal(Offset.zero).dx;
                    }
                    return Stack(
                        key: _ftRowKey,
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 32.0),
                                // จองที่ให้แถวย่อยตามความคืบหน้า (ดันรายชื่อลง) ไม่ตัดขอบ
                                Align(
                                  alignment: Alignment.topCenter,
                                  heightFactor:
                                      Curves.easeInOutCubic.transform(v),
                                  child: IgnorePointer(
                                    ignoring: !_ftOnly,
                                    child: Transform.translate(
                                        // ทั้งแถวเลื่อนลงจากหลังแถวชิปหลัก (ไม่เลื่อนแนวนอน)
                                        offset: Offset(
                                            0.0,
                                            -40.0 *
                                                (1 -
                                                    Curves.easeOutCubic
                                                        .transform(v))),
                                        child: Opacity(
                                            // ชิปหลักบางใบโปร่ง: จางเข้าช่วงต้น กันเห็นทะลุตอนอยู่ข้างหลัง
                                            opacity: const Interval(0.15, 0.6)
                                                .transform(v),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: _chipBleed(
                                                Row(children: [
                                                  _ftSubChip(
                                                      v,
                                                      anchor,
                                                      0,
                                                      null,
                                                      'ทุกกลุ่ม',
                                                      people
                                                          .where((p) =>
                                                              _ftOf(p.hn)
                                                                  .isNotEmpty)
                                                          .length),
                                                  for (final (ti, t)
                                                      in erFastTracks.indexed)
                                                    if (people.any((p) =>
                                                        _ftOf(p.hn).containsKey(
                                                            t.id))) ...[
                                                      const SizedBox(
                                                          width: 6.0),
                                                      _ftSubChip(
                                                          v,
                                                          anchor,
                                                          ti + 1,
                                                          t.id,
                                                          t.name,
                                                          people
                                                              .where((p) => _ftOf(
                                                                      p.hn)
                                                                  .containsKey(
                                                                      t.id))
                                                              .length),
                                                    ],
                                                ]),
                                              ),
                                            ))),
                                  ),
                                ),
                              ]),
                          // แถวหลักอยู่บนสุด ทับชิปย่อยตอนเริ่มโผล่
                          Positioned(
                            left: 0.0,
                            right: 0.0,
                            top: 0.0,
                            child: _chipBleed(
                              Row(children: [
                                // ทั้งหมด → Fast track (เฉพาะผู้ป่วยที่เปิดแฟ้ม สายฟ้าแบบป้ายบนรูป) → ตัวกรองอื่น
                                for (final (k, f)
                                    in _ListFilter.values.indexed) ...[
                                  if (k > 0) const SizedBox(width: 8.0),
                                  _listChip(f, count(f)),
                                  if (k == 0) ...[
                                    const SizedBox(width: 8.0),
                                    _ftChip(people
                                        .where((p) => _ftOf(p.hn).isNotEmpty)
                                        .length),
                                  ],
                                ],
                              ]),
                            ),
                          ),
                        ]);
                  },
                ),
                const SizedBox(height: 8.0),
                // เปลี่ยนชิปตัวกรอง: แถวเดิมอยู่กับที่ · แถวที่ไม่เข้าเงื่อนไขหุบความสูงลง + จาง
                // แถวที่เข้าเงื่อนไขกางออก + จางเข้า → รายการเลื่อนตามกันนุ่ม ๆ ไม่กระพริบทั้งรายการ
                for (final p in people)
                  _rowPresence(
                    key: ValueKey('row-${p.hn}'),
                    show: shown.contains(p),
                    child: _personRow(p, first: shown.firstOrNull == p),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: shown.isEmpty
                      ? Padding(
                          key: const ValueKey('empty'),
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Text('ไม่มีผู้ป่วยตามเงื่อนไขนี้',
                              style: _t(12.5, color: _lpInk2)),
                        )
                      : const SizedBox(
                          key: ValueKey('rows'), width: double.infinity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
