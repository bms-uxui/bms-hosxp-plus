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

  Widget _listChip(_ListFilter f) {
    final active = _listFilter == f;
    return _Press(
        child: Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Material(
        color: active ? Colors.white : _pSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _listFilter = f),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(f.label,
                style: _t(10.5,
                    color: active ? _pBg : _pInk2,
                    weight: active ? FontWeight.w600 : FontWeight.w400)),
          ),
        ),
      ),
    ));
  }

  /// การ์ดความจุของช่วงงาน (ย้ายจากการ์ดลอยในฉาก) + คำอธิบายเป็นประโยค
  Widget _phaseCapCard(
      _Phase phase, List<_P> people, int over, int noBed, int avg) {
    final counts = <_Esi, int>{
      for (final e in _Esi.values) e: people.where((p) => p.esi == e).length,
    };
    final none = people.where((p) => p.esi == null).length;
    final flow = _phaseFlow[phase]!;
    final net = flow.inRate - flow.outRate;
    final n = people.length;
    final full = n >= flow.cap;
    final red = _onDark(_red);
    final segs = _segColors(counts, none, flow.cap);
    Widget line(IconData icon, List<(String, bool)> parts) => Padding(
          padding: const EdgeInsets.only(top: 7.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(icon, size: 13.0, color: _pInk3),
            ),
            const SizedBox(width: 7.0),
            Expanded(
              child: Text.rich(TextSpan(children: [
                for (final t in parts)
                  TextSpan(
                      text: t.$1,
                      style: _t(10.5,
                          color: t.$2 ? _pInk : _pInk2,
                          weight: t.$2 ? FontWeight.w700 : FontWeight.w500,
                          height: 1.4)),
              ])),
            ),
          ]),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
      decoration: BoxDecoration(
        color: _pSoft,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _pLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('ความจุของช่วงนี้',
                style: _t(10.5, color: _pInk2, weight: FontWeight.w600)),
            const Spacer(),
            if (net > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.0),
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Text('คอขวด',
                    style: _t(9.5, color: red, weight: FontWeight.w700)),
              ),
          ]),
          const SizedBox(height: 2.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$n',
                  style: _num(30.0,
                      color: full ? red : _pInk, weight: FontWeight.w700)),
              const SizedBox(width: 4.0),
              Text('/ ${flow.cap} ที่รับไหว', style: _t(11.0, color: _pInk3)),
              const Spacer(),
              if (over > 0)
                Text('เกินเกณฑ์ $over ราย',
                    style: _t(11.0, color: red, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8.0),
          // หนึ่งช่อง = หนึ่งที่ที่รับได้ · สีตาม ESI · ล้นความจุเป็นแดงต่อท้าย
          Row(children: [
            for (var i = 0; i < segs.length; i++) ...[
              if (i > 0) const SizedBox(width: 3.0),
              Expanded(
                child: Container(
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: segs[i] == _panelSoft
                        ? _pLine
                        : (segs[i] == _ink3 ? _pInk3 : segs[i]),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 8.0),
          Row(children: [
            _flowRate(Icons.south_rounded, flow.inRate, _pInk2),
            const SizedBox(width: 12.0),
            _flowRate(Icons.north_rounded, flow.outRate, _pInk2),
            const Spacer(),
            Text(
                net == 0
                    ? 'คงที่'
                    : (net > 0 ? 'กอง +$net/ชม.' : 'ระบาย $net/ชม.'),
                style: _t(10.0,
                    color: net > 0 ? red : _pInk3, weight: FontWeight.w700)),
          ]),
          Container(
            height: 1.0,
            margin: const EdgeInsets.only(top: 10.0, bottom: 1.0),
            color: _pLine,
          ),
          line(Icons.groups_2_outlined, [
            if (full) ...[
              ('เกินความจุ ', false),
              ('${n - flow.cap} ราย', true),
              (' จากที่รับได้ ${flow.cap} ราย', false),
            ] else ...[
              ('ตอนนี้ $n ราย รับเพิ่มได้อีก ', false),
              ('${flow.cap - n} ราย', true),
            ],
          ]),
          line(Icons.swap_vert_rounded, [
            (
              'เข้าเฉลี่ย ${flow.inRate} ออก ${flow.outRate} รายต่อชั่วโมง · ',
              false
            ),
            (
              net > 0
                  ? 'ค้างสะสมเพิ่ม $net รายต่อชั่วโมง'
                  : net < 0
                      ? 'ระบายได้ ${-net} รายต่อชั่วโมง'
                      : 'เข้าออกเท่ากัน',
              true
            ),
          ]),
          line(Icons.timer_outlined, [
            ('รอเฉลี่ย ', false),
            (_hm(avg), true),
            (
              over > 0 ? ' · รอเกินเกณฑ์ $over ราย' : ' · ไม่มีใครรอเกินเกณฑ์',
              false
            ),
          ]),
          if (noBed > 0)
            line(Icons.bed_outlined, [
              ('ยังไม่ได้เตียง ', false),
              ('$noBed ราย', true),
            ]),
          const SizedBox(height: 9.0),
          // คำอธิบายสีช่อง: จำนวนตามระดับ ESI
          Wrap(spacing: 10.0, runSpacing: 4.0, children: [
            for (final e in _Esi.values)
              if ((counts[e] ?? 0) > 0)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                        color: e.color,
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                  const SizedBox(width: 4.0),
                  Text('ESI ${e.level} · ${counts[e]}',
                      style: _t(9.5, color: _pInk2)),
                ]),
            if (none > 0)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                      color: _pInk3, borderRadius: BorderRadius.circular(2.0)),
                ),
                const SizedBox(width: 4.0),
                Text('ยังไม่คัดกรอง · $none', style: _t(9.5, color: _pInk2)),
              ]),
          ]),
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
      padding: const EdgeInsets.fromLTRB(18.0, 6.0, 0.0, 16.0),
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
                        style: _t(19.0, color: _pInk, weight: FontWeight.w700)),
                    Text('อัปเดทข้อมูลทุก 30 วินาที',
                        style: _t(10.5, color: _pInk3)),
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
                            _t(11.0, color: _pInk2, weight: FontWeight.w600)),
                    const Spacer(),
                    Text('${shown.length} ราย', style: _t(10.0, color: _pInk3)),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(children: [
                  for (final f in _ListFilter.values) _listChip(f)
                ]),
                const SizedBox(height: 8.0),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text('ไม่มีผู้ป่วยตามเงื่อนไขนี้',
                        style: _t(10.5, color: _pInk3)),
                  )
                else
                  for (final p in shown) _personRow(p),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
