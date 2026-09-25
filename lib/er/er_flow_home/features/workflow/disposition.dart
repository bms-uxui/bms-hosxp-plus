// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ ปลายทาง Admit / Refer
const String _dispLabel = 'สภาพผู้ป่วยออกจากห้อง ER';
const String _destLabel = 'ตึกผู้ป่วยใน / สถานพยาบาลที่ส่งไป';

extension _FeaturesWorkflowDispositionPart on _ErFlowHomeWidgetState {
  String get _disp => _filled[_speechStep][_dispLabel] ?? '';

  List<String> _masterNames(String id) {
    final m = ErMaster.maybe;
    if (m == null) return const [];
    for (final t in m.tables) {
      if (t.id == id) return [for (final it in t.activeItems) it.name];
    }
    return const [];
  }

  /// ตัวเลือกปลายทาง: Admit → ตึกเรียงตามที่แนะนำ · Refer → สถานพยาบาล
  List<String> _destOptions() {
    final d = _disp;
    if (d.startsWith('Admit') || d.startsWith('Observe')) return _wardRanked();
    if (d.startsWith('Refer')) {
      final all = _masterNames('er_refer_hospital');
      // Refer ทางจิต: โรงพยาบาลจิตเวชขึ้นก่อน
      return d.contains('จิต')
          ? [
              ...all.where((h) => h.contains('จิตเวช')),
              ...all.where((h) => !h.contains('จิตเวช'))
            ]
          : all;
    }
    return const [];
  }

  /// ตึกผู้ป่วยในเรียงตามความเหมาะกับเคส: ตัดตึกเพศตรงข้าม/สูติสำหรับชาย
  /// แล้วให้คะแนนตามสาขาที่เข้ากับวินิจฉัย ช่องทางด่วน และความรุนแรง
  List<String> _wardRanked() {
    final c = _case;
    final p = _caseP();
    final male = c.sex.contains('ชาย');
    final child = c.age < 15;
    final text = '${c.cc} ${c.dx.map((d) => d.text).join(' ')}'.toLowerCase();
    bool has(List<String> ws) => ws.any(text.contains);
    final critical = p.esi?.level == 1;
    int score(String w) {
      var sc = 0;
      if (child) return w.contains('กุมาร') ? 100 : 0;
      if (p.type == _Ptype.stroke && w.contains('Stroke')) sc += 60;
      if (p.type == _Ptype.stemi && w.contains('CCU')) sc += 60;
      if (p.type == _Ptype.sepsis && w.contains('ICU อายุรกรรม'))
        sc += critical ? 60 : 20;
      if (has(['fracture', 'หัก', 'ผิดรูป']) && w.contains('กระดูก')) sc += 50;
      if (has(['head injury', 'ศีรษะ', 'intracranial']) && w.contains('ประสาท'))
        sc += 45;
      if (p.type == _Ptype.trauma && critical && w.contains('ICU ศัลยกรรม'))
        sc += 55;
      if (p.type == _Ptype.trauma && w.contains('ศัลยกรรม')) sc += 15;
      if (p.type != _Ptype.trauma && w.contains('อายุรกรรม')) sc += 10;
      if (w.contains(male ? 'ชาย' : 'หญิง')) sc += 5;
      return sc;
    }

    final wards = _masterNames('er_ipd_ward').where((w) {
      if (male &&
          (w.contains('หญิง') || w.contains('สูติ') || w.contains('นรีเวช'))) {
        return false;
      }
      if (!male && w.contains('ชาย')) return false;
      if (!child && w.contains('กุมาร')) return false;
      return true;
    }).toList();
    final idx = {for (var i = 0; i < wards.length; i++) wards[i]: i};
    wards.sort((a, b) {
      final d = score(b).compareTo(score(a));
      return d != 0 ? d : idx[a]!.compareTo(idx[b]!);
    });
    return wards;
  }

  /// แถวตึก/สถานพยาบาลที่แนะนำ 3 อันดับแรก แตะเพื่อเลือก (ใต้ช่องปลายทาง)
  Widget _destSuggest() {
    final d = _disp;
    final opts = _destOptions();
    if (opts.isEmpty) {
      return Text(
          d.isEmpty
              ? 'เลือกสภาพผู้ป่วยออกจาก ER ก่อน (Admit / Refer) แล้วเลือกปลายทาง'
              : 'ไม่ต้องระบุปลายทางสำหรับ "$d"',
          style: _t(10.0, color: _ink3));
    }
    final cur = _filled[_speechStep][_destLabel];
    // เปลี่ยน Admit ↔ Refer แล้วปลายทางเดิมไม่อยู่ในรายการใหม่: ล้างให้เลือกใหม่
    if (cur != null && cur.isNotEmpty && !opts.contains(cur)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _filled[_speechStep][_destLabel] == cur) {
          setState(() => _filled[_speechStep].remove(_destLabel));
        }
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(d.startsWith('Refer') ? 'สถานพยาบาลที่แนะนำ' : 'ตึกที่แนะนำตามเคส',
            style: _t(9.5, color: _ink3, weight: FontWeight.w600)),
        const SizedBox(height: 4.0),
        Wrap(spacing: 6.0, runSpacing: 6.0, children: [
          for (var i = 0; i < opts.length && i < 3; i++)
            _Press(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _lastFilled = [(_speechStep, _destLabel, cur)];
                    _filled[_speechStep][_destLabel] = opts[i];
                  });
                },
                child: Container(
                  height: 30.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: cur == opts[i] ? _blue : _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: cur == opts[i] ? _blue : _line),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (i == 0) ...[
                      Icon(Icons.auto_awesome_rounded,
                          size: 11.0,
                          color: cur == opts[i] ? Colors.white : _blue),
                      const SizedBox(width: 4.0),
                    ],
                    Text(opts[i],
                        style: _t(10.5,
                            color: cur == opts[i] ? Colors.white : _ink2,
                            weight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
        ]),
      ],
    );
  }
}
