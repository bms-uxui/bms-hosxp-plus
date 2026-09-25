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
    final opts = _destOptions();
    if (opts.isEmpty) {
      return const SizedBox.shrink();
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

  /// การ์ดเลือกสภาพผู้ป่วยออกจาก ER (3 คอลัมน์) · ไอคอน + ชื่อ + ผลที่ตามมา
  Widget _dispCards(
      List<String> opts, String? sel, void Function(String) pick) {
    (IconData, String) meta(String o) => switch (o) {
          'Admit' => (Icons.local_hotel_rounded, 'รับไว้รักษา · เลือกตึก'),
          'Refer ทางกาย' => (
              Icons.local_shipping_rounded,
              'ส่งต่อ · เลือกสถานพยาบาล'
            ),
          'Refer ทางจิต' => (Icons.psychology_rounded, 'ส่งต่อจิตเวช'),
          'รับยา' => (Icons.medication_rounded, 'รับยากลับบ้าน'),
          'Observe' => (Icons.visibility_rounded, 'สังเกตอาการใน ER'),
          'กลับบ้าน' => (Icons.home_rounded, 'จำหน่ายกลับบ้าน'),
          'หนีกลับ' => (Icons.directions_run_rounded, 'ออกโดยไม่แจ้ง'),
          'ปฏิเสธการรักษา' => (Icons.do_not_disturb_on_rounded, 'ลงนามปฏิเสธ'),
          'ตาย' => (Icons.heart_broken_rounded, 'เสียชีวิต'),
          _ => (Icons.logout_rounded, ''),
        };
    const per = 3;
    Widget card(String o) {
      final on = o == sel;
      final (icon, sub) = meta(o);
      return _Press(
        child: GestureDetector(
          onTap: () => pick(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.fromLTRB(10.0, 9.0, 10.0, 9.0),
            decoration: BoxDecoration(
              gradient: on ? _glossGrad(_blue) : _glossWhite,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: on ? _blue : _line),
              boxShadow: _glossLift(on ? _blue : const Color(0xFF0B1B3F)),
            ),
            foregroundDecoration: _InnerGloss(12.0, dark: on),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 18.0, color: on ? Colors.white : _blue),
              const SizedBox(height: 4.0),
              Text(o,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(12.5,
                      color: on ? Colors.white : _inkTitle,
                      weight: FontWeight.w700)),
              if (sub.isNotEmpty)
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(9.5,
                        color: on ? Colors.white70 : _ink3,
                        weight: FontWeight.w500)),
            ]),
          ),
        ),
      );
    }

    return Column(children: [
      for (var i = 0; i < opts.length; i += per)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0.0 : 7.0),
          child: IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var j = i; j < i + per; j++) ...[
                if (j > i) const SizedBox(width: 7.0),
                Expanded(
                    child: j < opts.length
                        ? card(opts[j])
                        : const SizedBox.shrink()),
              ],
            ]),
          ),
        ),
    ]);
  }

  /// วันที่-เวลา แบบ พ.ศ. เช่น 25/09/2569 11:20 น.
  String _fmtDateTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)}/${t.year + 543} '
        '${two(t.hour)}:${two(t.minute)} น.';
  }

  /// ช่องวันที่-เวลา: ปุ่ม "ใช้เวลาปัจจุบัน" กดครั้งเดียว · หรือเลือกเองด้วย date/time picker
  Widget _dateTimeField(String label, String? value, VoidCallback? onPick) {
    void put(DateTime t) {
      setState(() {
        _lastFilled = [(_speechStep, label, value)];
        _filled[_speechStep][label] = _fmtDateTime(t);
      });
      onPick?.call();
    }

    Future<void> pickCustom() async {
      final now = DateTime.now();
      final d = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now.subtract(const Duration(days: 7)),
        lastDate: now.add(const Duration(days: 1)),
      );
      if (d == null || !mounted) return;
      final tm = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(now));
      if (tm == null || !mounted) return;
      put(DateTime(d.year, d.month, d.day, tm.hour, tm.minute));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // เลือกเอง: แตะช่องเพื่อเปิด date time picker
      InkWell(
        onTap: pickCustom,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: value != null ? _blue.withValues(alpha: 0.5) : _line),
          ),
          child: Row(children: [
            Icon(Icons.event_rounded,
                size: 18.0, color: value != null ? _blue : _ink3),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(value ?? 'เลือกวันที่และเวลา',
                  style: value != null
                      ? _num(15.0, color: _inkTitle, weight: FontWeight.w700)
                      : _t(13.5, color: _ink3)),
            ),
            const Icon(Icons.edit_calendar_rounded, size: 18.0, color: _ink3),
          ]),
        ),
      ),
      const SizedBox(height: 8.0),
      // ใช้วันเวลาปัจจุบัน
      _Press(
        child: GestureDetector(
          onTap: () => put(DateTime.now()),
          child: Container(
            height: 40.0,
            decoration: BoxDecoration(
              gradient: _glossGrad(_blue),
              borderRadius: BorderRadius.circular(100.0),
              boxShadow: _glossLift(_blue),
            ),
            foregroundDecoration: const _InnerGloss(100.0, dark: true),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.schedule_rounded,
                  size: 16.0, color: Colors.white),
              const SizedBox(width: 6.0),
              Text('ใช้เวลาปัจจุบัน · ${_fmtDateTime(DateTime.now())}',
                  style:
                      _t(12.0, color: Colors.white, weight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    ]);
  }
}
