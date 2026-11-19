// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ ปลายทาง Admit / Refer
const String _dispLabel = 'สภาพผู้ป่วยออกจากห้อง ER';
const String _destLabel = 'ตึกผู้ป่วยใน / สถานพยาบาลที่ส่งไป';

/// หน้าย่อยเลือกสภาพผู้ป่วยเปิดอยู่ (หัวแผง = breadcrumb · footer = ย้อนกลับ | เสร็จ)
bool _dispPickOpen = false;

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

  /// ไอคอน + ผลที่ตามมาของแต่ละสภาพผู้ป่วยออกจาก ER
  (IconData, String) _dispMeta(String o) => switch (o) {
        'Admit' => (Icons.local_hotel_rounded, 'รับไว้รักษาและเลือกตึก'),
        'Refer ทางกาย' => (
            Icons.local_shipping_rounded,
            'ส่งต่อและเลือกสถานพยาบาล'
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

  /// การ์ดซ้อนรอบแถว: ขาว ขอบ 0.5 มุม 16 · ห่างขอบการ์ดนอก 8 (เว้นล่าง 8)
  Widget _nestCard(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
        ),
        child: child,
      );

  /// แถวสภาพผู้ป่วยออกจาก ER (แบบแถวประเภทอุบัติเหตุ): เหรียญไอคอน · ชื่อ · ค่าที่เลือก
  /// แตะ = รายการให้เลือก
  Widget _dispRow(List<String> opts) {
    final sel = _filled[_speechStep][_dispLabel];
    return _nestCard(_gListRow(
      first: true,
      inset: 8.0,
      lead: _SoStatusCoin.field(
          sel == null ? Icons.logout_rounded : _dispMeta(sel).$1),
      title: 'สภาพผู้ป่วย',
      sub: sel == null
          ? 'ยังไม่ได้เลือก'
          : [sel, _dispMeta(sel).$2].where((t) => t.isNotEmpty).join('  '),
      onTap: () async {
        HapticFeedback.selectionClick();
        setState(() {
          _formFwd = true;
          _dispPickOpen = true;
        });
      },
    ));
  }

  /// หน้าย่อยเลือกสภาพผู้ป่วยเปิดอยู่ (เฉพาะหน้าฟอร์มที่มีช่องสภาพผู้ป่วย)
  bool get _dispPickNested {
    if (!_dispPickOpen || _speechStep >= _forms.length) return false;
    final fs = [for (final (l, _) in _forms[_speechStep]) l];
    return fs.contains(_dispLabel) && fs.elementAtOrNull(_formAt) == _dispLabel;
  }

  void _dispPickClose() => setState(() {
        _formFwd = false;
        _dispPickOpen = false;
      });

  /// breadcrumb: สภาพผู้ป่วยออกจากห้อง ER › เลือกสภาพผู้ป่วย · แตะส่วนแรก = กลับ
  Widget _dispPickCrumb() => Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 16.0, 6.0),
        child: Row(children: [
          _CrumbPrev(_dispLabel, onTap: _dispPickClose),
          const _CrumbSep(),
          Expanded(
            child: Text('เลือกสภาพผู้ป่วย',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w600)),
          ),
        ]),
      );

  /// หน้าย่อยเลือกสภาพผู้ป่วย (ภาษาเดียวกับการ์ดระบบหน้าตรวจร่างกาย):
  /// การ์ดละตัวเลือก ภาพประกอบซ้ายบน (เว้นที่ไว้ก่อน) · เลือกอยู่ = ✓ มุมขวาบน · ชื่อหนา + ผลที่ตามมา
  Widget _dispPickPage(List<String> opts) {
    final sel = _filled[_speechStep][_dispLabel];
    Widget card(String o) {
      final on = o == sel;
      final (icon, sub) = _dispMeta(o);
      return _Press(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _lastFilled = [(_speechStep, _dispLabel, sel)];
              _filled[_speechStep][_dispLabel] = o;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: on ? const Color(0xFFE2EAF8) : _panel,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                  color: on ? const Color(0x00DADCE0) : const Color(0xFFDADCE0),
                  width: 0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // ที่ภาพประกอบ (รอภาพ 3D) · ตอนนี้ไอคอนของตัวเลือก
                    Container(
                      width: 72.0,
                      height: 72.0,
                      decoration: BoxDecoration(
                        color: on ? _panel : _panelSoft,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Icon(icon, size: 28.0, color: _blue),
                    ),
                    const Spacer(),
                    if (on)
                      const Icon(Icons.check_circle_rounded,
                          size: 24.0, color: _blue),
                  ]),
                  const SizedBox(height: 8.0),
                  Text(o,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                  Text(sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0, color: _ink3, weight: FontWeight.w500)),
                ]),
          ),
        ),
      );
    }

    const per = 2;
    return Column(
      key: const ValueKey('disp-pick'),
      children: [
        for (var i = 0; i < opts.length; i += per)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0.0 : 8.0),
            child: IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = i; j < i + per; j++) ...[
                      if (j > i) const SizedBox(width: 8.0),
                      Expanded(
                          child: j < opts.length
                              ? card(opts[j])
                              : const SizedBox.shrink()),
                    ],
                  ]),
            ),
          ),
      ],
    );
  }

  /// การ์ดเลือกสภาพผู้ป่วยออกจาก ER (3 คอลัมน์) · ไอคอน + ชื่อ + ผลที่ตามมา
  Widget _dispCards(
      List<String> opts, String? sel, void Function(String) pick) {
    final meta = _dispMeta;
    const per = 3;
    Widget card(String o) {
      final on = o == sel;
      final (icon, sub) = meta(o);
      return _Press(
        child: GestureDetector(
          onTap: () => pick(o),
          // การ์ดซ้อน: ขาว ขอบ 0.5 มุม 16 · ที่เลือก = พื้นฟ้าอ่อน ตัวกรมท่า (Google style)
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(10.0, 12.0, 8.0, 12.0),
            decoration: BoxDecoration(
              color: on ? const Color(0xFFE2EAF8) : _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                  color: on ? const Color(0x00DADCE0) : const Color(0xFFDADCE0),
                  width: 0.5),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, size: 22.0, color: _blue),
              const SizedBox(height: 8.0),
              Text(o,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(13.0,
                      color: on ? _blue : _inkTitle, weight: FontWeight.w700)),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 2.0),
                Text(sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
              ],
            ]),
          ),
        ),
      );
    }

    return Column(children: [
      for (var i = 0; i < opts.length; i += per)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0.0 : 8.0),
          child: IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var j = i; j < i + per; j++) ...[
                if (j > i) const SizedBox(width: 8.0),
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

  /// เนื้อหาการ์ดวันเวลา (ภาษาเดียวกับการ์ดเหตุการณ์ในอุบัติเหตุ):
  /// แผ่นปุ่มลัด ตอนนี้ / เลือกวันเวลา · แถววันเวลาที่ลงแล้ว (แตะ = เลือกใหม่)
  Widget _dateTimeTiles(String label) {
    final value = _filled[_speechStep][label];
    void put(DateTime t) {
      HapticFeedback.selectionClick();
      setState(() {
        _lastFilled = [(_speechStep, label, value)];
        _filled[_speechStep][label] = _fmtDateTime(t);
      });
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
      _dxTiles([
        (Icons.schedule_rounded, 'ตอนนี้', () => put(DateTime.now())),
        (Icons.edit_calendar_rounded, 'เลือกวันเวลา', pickCustom),
      ]),
      _nestCard(_gListRow(
        first: true,
        inset: 8.0,
        lead: _SoStatusCoin.field(Icons.event_rounded),
        title: 'วันเวลาออกจากห้อง',
        sub: value ?? 'ยังไม่ได้เลือก',
        onTap: pickCustom,
      )),
    ]);
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

    // แถวเดียว: ช่องวันเวลา (แตะเพื่อเลือกเอง) · ปุ่มนาฬิกา = ใช้เวลาปัจจุบัน
    return Row(children: [
      Expanded(
        child: InkWell(
          onTap: pickCustom,
          borderRadius: BorderRadius.circular(16.0),
          // การ์ดซ้อน: ขาว ขอบ 0.5 มุม 16 (แบบแผ่นในการ์ดหน้าวินิจฉัย)
          child: Container(
            height: 52.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
            ),
            child: Row(children: [
              Icon(Icons.event_rounded,
                  size: 18.0, color: value != null ? _blue : _ink3),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(value ?? 'เลือกวันที่และเวลา',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: value != null
                        ? _num(15.0, color: _inkTitle, weight: FontWeight.w700)
                        : _t(13.5, color: _ink3)),
              ),
              const Icon(Icons.edit_calendar_rounded, size: 18.0, color: _ink3),
            ]),
          ),
        ),
      ),
      const SizedBox(width: 8.0),
      // ปุ่มนาฬิกา: ลงวันเวลาปัจจุบันในแตะเดียว
      Tooltip(
        message: 'ใช้เวลาปัจจุบัน · ${_fmtDateTime(DateTime.now())}',
        child: _Press(
          child: GestureDetector(
            onTap: () => put(DateTime.now()),
            // ปุ่มรอง tonal (ปุ่มหลักของหน้าคือปุ่มล่าง)
            child: Container(
              height: 52.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE2EAF8),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.schedule_rounded, size: 18.0, color: _blue),
                const SizedBox(width: 6.0),
                Text('ตอนนี้',
                    style: _t(13.5, color: _blue, weight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ------------------------------------------------ สรุปการรับบริการห้องฉุกเฉิน
// ตามฟอร์ม HOSxP "การรับเข้าห้องฉุกเฉิน" + "การคัดแยกและการจำหน่าย"
// แสดงในหน้าสรุปของขั้นคัดกรอง (รับเข้า + คัดแยก) และขั้นจำหน่าย (ครบทุกส่วน)

/// เวลาทางด่วนตามประเภทผู้ป่วย: (ชื่อ, ประเภทที่ใช้)
const List<(String, List<_Ptype>)> _visitStamps = [
  ('เวลาทำ ECG 12 lead', [_Ptype.stemi]),
  ('ทำบอลลูน (STEMI)', [_Ptype.stemi]),
  ('เวลาเริ่ม CT/MRI สมอง', [_Ptype.stroke, _Ptype.trauma]),
  ('ได้รับยาละลายลิ่มเลือด', [_Ptype.stroke, _Ptype.stemi]),
  ('เวลาวินิจฉัย Sepsis', [_Ptype.sepsis]),
  ('ได้รับยา Antibiotics', [_Ptype.sepsis]),
];

/// ธงของ visit (ติ๊กได้ในหน้าสรุป)
const List<String> _visitFlags = [
  'รับไว้สังเกตอาการ (Observe)',
  'ผู้ป่วยคดี',
  'ผู้ป่วยเสียชีวิตก่อนมาถึง รพ.',
  'กลับมารักษาซ้ำ',
];

extension _VisitSummaryPart on _ErFlowHomeWidgetState {
  int _stepIdx(String name) => _steps.indexWhere((s) => s.$2 == name);

  /// ค่าของขั้นอื่น (ข้อมูลรับเข้าอยู่ในขั้นคัดกรอง ผลจำหน่ายอยู่ในขั้นจำหน่าย)
  String? _valOf(String step, String key) {
    final i = _stepIdx(step);
    if (i < 0 || i >= _filled.length) return null;
    final v = _filled[i][key];
    return (v == null || v.isEmpty) ? null : v;
  }

  String? _inOf(String k) => _valOf('คัดกรอง', 'รับเข้า ER - $k');

  /// เวลา/ธงของ visit เก็บไว้ที่ขั้นคัดกรอง (ใช้ร่วมกันทุกหน้าสรุป)
  String? _sumGet(String k) => _valOf('คัดกรอง', 'sum:$k');
  void _sumSet(String k, String? v) {
    final i = _stepIdx('คัดกรอง');
    if (i < 0 || i >= _filled.length) return;
    setState(() {
      if (v == null) {
        _filled[i].remove('sum:$k');
      } else {
        _filled[i]['sum:$k'] = v;
      }
    });
  }

  /// การ์ดสรุปการรับบริการ · full = ขั้นจำหน่าย (เพิ่มการตรวจ ทางด่วน จำหน่าย)
  Widget _visitSummary({required bool full}) {
    final p = _caseP();
    final c = _case;
    final admit = _inOf('วัน-เวลาเข้าห้อง ER') ??
        _fmtDateTime(DateTime.now().subtract(Duration(minutes: p.waitMin)));
    final log = _triLog[p.hn];
    final triTime =
        log != null && log.isNotEmpty ? _fmtDateTime(log.first.$1) : null;

    Widget section(String title, List<Widget> kids) => Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: _t(12.0, color: _blue, weight: FontWeight.w700)),
              const SizedBox(height: 4.0),
              LayoutBuilder(builder: (_, box) {
                final cols = box.maxWidth >= 420 ? 2 : 1;
                final w = (box.maxWidth - (cols - 1) * 12.0) / cols;
                return Wrap(spacing: 12.0, runSpacing: 0.0, children: [
                  for (final k in kids) SizedBox(width: w, child: k),
                ]);
              }),
            ],
          ),
        );
    Widget kv(String k, String? v, {bool bad = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 128.0,
              child: Text(k,
                  style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(v ?? '-',
                  style: _t(12.0,
                      color: bad ? _red : (v == null ? _ink3 : _inkTitle),
                      weight: FontWeight.w600)),
            ),
          ]),
        );
    // เวลาที่บันทึกได้ในหน้านี้: ปุ่ม "ใช้เวลาปัจจุบัน"
    Widget stamp(String k) {
      final v = _sumGet(k);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(children: [
          SizedBox(
            width: 128.0,
            child:
                Text(k, style: _t(11.0, color: _ink3, weight: FontWeight.w500)),
          ),
          Expanded(
            child: v != null
                ? GestureDetector(
                    onTap: () => _sumSet(k, null),
                    child: Text(v,
                        style: _t(12.0,
                            color: _inkTitle, weight: FontWeight.w600)),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: _Press(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _sumSet(k, _fmtDateTime(DateTime.now()));
                        },
                        child: Container(
                          height: 32.0,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _blue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text('ใช้เวลาปัจจุบัน',
                              style: _t(11.0,
                                  color: _blue, weight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
          ),
        ]),
      );
    }

    Widget flag(String k) {
      final on = _sumGet(k) != null;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          _sumSet(k, on ? null : '1');
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 40.0),
          child: Row(children: [
            Icon(
                on
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 20.0,
                color: on ? _blue : _g5),
            const SizedBox(width: 6.0),
            Expanded(
              child: Text(k,
                  style: _t(12.0,
                      color: on ? _blue : _inkTitle, weight: FontWeight.w600)),
            ),
          ]),
        ),
      );
    }

    final stamps = [
      for (final (k, types) in _visitStamps)
        if (p.type != null && types.contains(p.type)) k,
    ];
    final outTime =
        _valOf('จำหน่าย', _outTimeLabel) ?? _inOf('วัน-เวลาออกจาก ER');
    final disp = _valOf('จำหน่าย', _dispLabel) ?? _inOf('สภาพผู้ป่วยออกจาก ER');

    // แบนราบ: อยู่ในกรอบหน้าสรุปอยู่แล้ว ไม่ซ้อนกรอบ/หัวข้อซ้ำ
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          section('การรับเข้าห้องฉุกเฉิน', [
            kv('รับเข้าห้องวันที่', admit),
            kv('เวร', _inOf('เวร')),
            kv('แพทย์เวร', _inOf('แพทย์เวร')),
            kv('ประเภทการมา', c.arrival.isEmpty ? null : c.arrival),
            kv('สภาพ', _inOf('สภาพผู้ป่วย') ?? c.condition),
            kv('ข้อบ่งชี้กรณีฉุกเฉิน', _inOf('ข้อบ่งชี้กรณีฉุกเฉิน')),
            kv('แผนก', _qDeptName),
            kv('เริ่มตรวจ', _inOf('เวลาเริ่มตรวจ')),
            if (full) kv('ตรวจเสร็จ', _inOf('เวลาตรวจเสร็จ')),
          ]),
          section('การคัดแยก', [
            kv('ระดับคัดแยก (Triage)',
                p.esi == null ? null : 'ESI ${p.esi!.level} ${p.esi!.en}'),
            kv('เวลาจัดความเร่งด่วนเสร็จ', triTime),
          ]),
          // ประวัติการคัดแยก
          if (log != null && log.isNotEmpty)
            for (final (t, from, to, kind, why, by) in log)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                    '${_fmtDateTime(t)}  ${from == null ? '' : 'ESI $from → '}ESI $to  $kind  $by${why.isEmpty ? '' : '  ($why)'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _t(11.0, color: _ink2, weight: FontWeight.w500)),
              ),
          if (stamps.isNotEmpty)
            section('เวลาทางด่วน ${p.type!.label}', [
              for (final k in stamps) stamp(k),
            ]),
          if (full) ...[
            section('การจำหน่าย', [
              kv('ผลการรักษาที่ ER', disp),
              stamp('เวลาตัดสินใจจำหน่าย'),
              kv('วันที่/เวลา ออกจากห้อง ER', outTime),
            ]),
          ],
          section('ข้อมูลเพิ่มเติม', [
            for (final f in _visitFlags)
              if (full || f != 'รับไว้สังเกตอาการ (Observe)') flag(f),
          ]),
        ],
      ),
    );
  }
}
