// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

// ------------------------------------------------ ลิ้นชักส่งต่อผู้ป่วย (F9)
// แบบหน้าจอ "การส่งต่อ" ของ HOSxP: ส่งต่อห้อง · สถานะ · เงินรอชำระ · จำนวนรายการยา
// ปุ่ม F9 บนแถบบน (หรือคีย์ F9) เปิดลิ้นชัก · กด F9 อีกครั้ง/ปุ่มยืนยัน = ส่งต่อ

mixin _FeaturesPatientF9DrawerState on State<ErFlowHomeWidget> {
  /// ลิ้นชักส่งต่อเปิดอยู่
  bool _f9Open = false;

  /// ห้องที่ส่งต่อ
  String _f9Room = '';

  /// สถานะใหม่ของผู้ป่วย · null = ออกจากห้องฉุกเฉิน
  _Stage? _f9Stage;

  /// หน้าในแผ่นส่งต่อ: 0 แนะนำ · 1 การบันทึก · 2 ส่งต่อ · 3 ค่าใช้จ่าย · 4 สรุป
  int _f9Page = 0;

  /// นับรอบที่เปิดลิ้นชัก F9: เปลี่ยน = เล่นเรื่องเปิด (เอกสารเก็บเข้าแฟ้ม) + หัวข้อ/รายการจางเข้าใหม่
  int _f9Gen = 0;

  /// เลื่อนเนื้อหาลง = การ์ดหัวย่อเหลือชื่อบรรทัดเดียว (ซ่อนคำอธิบายและกระดาษ) · กลับบนสุด = ขยายคืน
  bool _f9Collapsed = false;

  /// ยืนยันส่งต่อแล้ว กำลังแสดงหน้าสำเร็จสีเขียวในลิ้นชัก (ชื่อผู้ป่วย, สถานะถัดไป, ห้อง)
  /// ข้อมูลผู้ป่วยย้ายจริงตอนหน้าสำเร็จปิด ([_f9Finish])
  (String, String, String)? _f9Sent;
}

extension _FeaturesPatientF9DrawerPart on _ErFlowHomeWidgetState {
  /// ห้องส่งต่อ (ข้อมูลตัวอย่าง): ของจริงเป็นรายการห้อง/จุดบริการที่โรงพยาบาลตั้งเอง มีหลายสิบห้อง
  /// หน้าส่งต่อจึงแสดงเฉพาะห้องที่ใช้บ่อย [_f9RoomsTop] + ปุ่มดูห้องทั้งหมด (แผ่นรายการมีช่องค้นหา)
  static const List<String> _f9Rooms = [
    'ห้องตรวจฉุกเฉิน',
    'ห้องสังเกตอาการ',
    'ห้องเอกซเรย์',
    'ห้องยา',
    'การเงิน',
    'กลับบ้าน',
    'Admit (หอผู้ป่วย)',
    'Refer',
    'ห้องชันสูตร (Lab)',
    'ห้อง CT Scan',
    'ห้องอัลตราซาวด์',
    'ห้องทำแผล',
    'ห้องฉีดยา',
    'ห้องผ่าตัด',
    'ห้องคลอด',
    'ห้องตรวจอายุรกรรม',
    'ห้องตรวจศัลยกรรม',
    'ห้องตรวจกุมารเวช',
    'ห้องตรวจสูตินรีเวช',
    'ห้องตรวจกระดูกและข้อ',
    'ห้องตรวจตา',
    'ห้องตรวจหู คอ จมูก',
    'ห้องทันตกรรม',
    'ห้องกายภาพบำบัด',
    'ห้องไตเทียม',
    'ห้องจิตเวช',
    'ห้องแพทย์แผนไทย',
    'ห้องให้คำปรึกษา',
    'ศูนย์ส่งต่อ',
    'ศูนย์เปล',
    'ห้องเวชระเบียน',
    'ห้องตรวจสิทธิ',
  ];

  /// ห้องที่ใช้บ่อยจากห้องฉุกเฉิน (แสดงเป็นปุ่มในหน้าส่งต่อ)
  static const List<String> _f9RoomsTop = [
    'ห้องตรวจฉุกเฉิน',
    'ห้องสังเกตอาการ',
    'ห้องเอกซเรย์',
    'ห้องยา',
    'การเงิน',
    'Admit (หอผู้ป่วย)',
  ];

  /// ขั้นถัดไปของผู้ป่วย · null = ออกจากห้องฉุกเฉิน
  _Stage? _nextStage(_Stage s) => switch (s) {
        _Stage.triage => _Stage.waitDoctor,
        _Stage.waitDoctor => _Stage.treatment,
        _Stage.treatment => _Stage.discharge,
        _Stage.observe => _Stage.discharge,
        _Stage.discharge => null,
      };

  /// ห้องตั้งต้น: ตามการจำหน่ายที่บันทึกไว้ ไม่มีก็ตามขั้นถัดไป
  String _f9DefaultRoom(_Stage? next, ErCase c) {
    final d = c.disposition;
    if (next == _Stage.discharge || next == null) {
      if (d.startsWith('Admit')) return 'Admit (หอผู้ป่วย)';
      if (d.startsWith('Refer')) return 'Refer';
      if (d.contains('กลับบ้าน')) return 'กลับบ้าน';
      return 'การเงิน';
    }
    return next == _Stage.observe ? 'ห้องสังเกตอาการ' : 'ห้องตรวจฉุกเฉิน';
  }

  /// ยอดรอชำระ (จำลองจากรายการที่สั่งในเคส) · สิทธิจ่ายเองเท่านั้น สิทธิอื่นเบิกได้ = 0
  double _f9Amount(ErCase c) {
    if (c.right != 'จ่ายเอง') return 0;
    return 150.0 +
        c.labs.length * 80.0 +
        c.meds.length * 45.0 +
        c.imaging.length * 200.0;
  }

  String _money(double v) {
    final s = v.toStringAsFixed(2);
    final i = s.indexOf('.');
    final whole = s
        .substring(0, i)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => ',');
    return '$whole${s.substring(i)}';
  }

  /// F9: ปิดอยู่ = เปิดลิ้นชัก · เปิดอยู่ = ยืนยันส่งต่อ
  void _saveF9() {
    // F9 จากคีย์บอร์ดก็ส่งต่อไม่ได้ตอนดูอย่างเดียว
    if (_viewOnly) return _viewOnlyNotice();
    if (!_detail || _open == null) return;
    // หน้าสำเร็จค้างอยู่ = ไม่รับ F9 ซ้ำ
    if (_f9Sent != null) return;
    // เปิดอยู่: ยังไม่ถึงหน้าสรุป = ไปหน้าสรุป (กันกดพลาด) · หน้าสรุป = ยืนยันส่งต่อ
    if (_f9Open) {
      if (_f9Page < 3) {
        HapticFeedback.selectionClick();
        setState(() => _f9Page = 3);
        return;
      }
      _f9Confirm();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final p = _sceneSelected(_open!);
    final next = _nextStage(p.stage);
    setState(() {
      _f9Stage = next;
      _f9Room = _f9DefaultRoom(next, erCaseOf(p.hn));
      _f9Open = true;
      _f9Page = 0;
      _f9Collapsed = false;
      _f9Gen++;
    });
  }

  /// ปิดลิ้นชัก · ถ้าหน้าสำเร็จค้างอยู่ = จบการส่งต่อเลย
  void _f9Close() =>
      _f9Sent != null ? _f9Finish() : setState(() => _f9Open = false);

  /// ยืนยันส่งต่อ: แสดงหน้าสำเร็จสีเขียวในลิ้นชัก (แบบบันทึกสำเร็จของ workflow แต่เล่าด้วยแฟ้ม)
  /// แล้วค่อยย้ายผู้ป่วยและกลับหน้ารายชื่อตอนหน้าสำเร็จปิด
  void _f9Confirm() {
    if (_f9Sent != null || _open == null) return;
    final p = _sceneSelected(_open!);
    final next = _f9Stage;
    ErFeedback.confirm();
    setState(() => _f9Sent = (
          p.name,
          next == null ? 'ออกจากห้องฉุกเฉิน' : _Phase.of(next).label,
          _f9Room
        ));
  }

  void _f9Finish() {
    if (_f9Sent == null || _open == null) return;
    _f9Sent = null;
    final p = _sceneSelected(_open!);
    final next = _f9Stage;
    final i = _patients.indexWhere((x) => x.hn == p.hn);
    if (i < 0) return;
    if (_speechOpen) _closeSpeech();
    unawaited(Posthog().capture(
      eventName: 'patient_care_stage_updated',
      properties: {
        'destination_stage': next?.name ?? 'er_departure',
        if (p.type?.name case final t?) 'patient_type': t,
      },
    ).catchError((_) {}));
    if (next == null) {
      // ออกจาก ER: เอาออกจากรายชื่อ
      _patients.removeAt(i);
      setState(() => _f9Open = false);
    } else {
      _patients[i] = _P(p.hn, p.name, next, 0,
          esi: p.esi, bed: p.bed, note: _f9Room, type: p.type);
      setState(() => _f9Open = false);
    }
    // บันทึกเสร็จ: กลับหน้าแรก (ภาพรวมห้องฉุกเฉิน) ทุกกรณี
    setState(() {
      _detail = false;
      _timelineOpen = false;
      _open = null;
      _zoom = null;
      _sceneHn = null;
    });
  }

  /// ช่องบังคับที่ยังไม่ได้บันทึก แยกตามขั้น workflow: (ขั้น, ชื่อช่องที่ขาด)
  /// ฟอร์มยังไม่เคยเปิดกับเคสนี้ = ทุกช่องยังว่าง
  List<(int, List<String>)> _f9Missing(String hn) {
    final mine = _speechHn == hn;
    final nurse = ErSession.instance.role == ErRole.nurse;
    final out = <(int, List<String>)>[];
    for (final st in _stepOrder) {
      final name = _steps[st].$2;
      final List<String> miss;
      if (nurse && name == 'ซักประวัติ') {
        if (_hxSaved.contains(hn)) continue;
        // ซักประวัติ: อาการสำคัญ สัญญาณชีพ แพ้ยา สูบบุหรี่ ดื่มสุรา (บังคับ)
        final v = mine
            ? (_filled[7]['การแพ้ยา / การสูบบุหรี่ / การดื่มสุรา'] ?? '')
                .split(' · ')
            : const <String>[];
        const req = ['การแพ้ยา', 'การสูบบุหรี่', 'การดื่มสุรา'];
        final ccDone = _qCc.isNotEmpty || _regCtl('cc').text.trim().isNotEmpty;
        miss = [
          if (!mine || !ccDone) 'อาการสำคัญ',
          if (!mine || _triVal('hr') == null || _triVal('sbp') == null)
            'สัญญาณชีพ',
          for (final (i, l) in req.indexed)
            if (v.length != 3 || v[i] == '-') l,
        ];
      } else if (nurse && name == 'สัญญาณชีพ') {
        // วัดซ้ำเป็นรอบ ๆ ไม่มีช่องค้าง
        continue;
      } else if (nurse && name == 'คัดกรอง') {
        // ทวนข้อมูลจากจุดคัดกรอง ไม่มีช่องให้กรอกเพิ่ม
        continue;
      } else {
        miss = [
          for (final l in _stepLabels(st))
            if (!mine || !_fieldDone(st, l)) l,
        ];
      }
      if (miss.isNotEmpty) out.add((st, miss));
    }
    return out;
  }

  /// ลิ้นชักบันทึกส่งต่อ (F9) ขอบขวา กว้าง 440 · การ์ดหัวเทาตามโครง Figma 1081:264 (ชื่อ · คำอธิบาย)
  /// แฟ้มมุมขวาบน (โมเดลเดียวกับ AI Overview) = เรื่องเล่าต่อเนื่องจากหน้าแนะนำถึงหน้าสรุป
  /// หน้า 0 แนะนำ → 1 ส่งต่อ → 2 ค่าใช้จ่าย → 3 สรุป (ยืนยันส่งต่อ) ตามหน้าจอส่งต่อของ HOSxP (knowledge ข้อ 43)
  /// การบันทึกที่ยังขาดไม่ใช่หน้าแยก (ไม่ได้ห้ามส่งต่อ) = แถวเตือนในหน้าสรุป แตะแล้วไปขั้นที่ขาด
  /// หน้าแนะนำ = การ์ดหัว (ชื่อ คำอธิบาย แฟ้ม) + รายการสิ่งที่ต้องตรวจ · หน้าตรวจ = กระดาษออกจากแฟ้ม แฟ้มจมลงใต้การ์ด
  Widget _f9DrawerPanel() {
    if (_open == null) return const SizedBox(width: 440.0);
    final p = _sceneSelected(_open!);
    final c = erCaseOf(p.hn);
    final amount = _f9Amount(c);
    final drugs = c.meds.length;
    final miss = _f9Missing(p.hn);
    // ขั้นที่ยังบันทึกไม่ครบ (พยาบาลไม่นับสัญญาณชีพ/คัดกรอง)
    final missSteps = [
      for (final (st, _) in miss)
        if (!(ErSession.instance.role == ErRole.nurse &&
            (_steps[st].$2 == 'สัญญาณชีพ' || _steps[st].$2 == 'คัดกรอง')))
          st
    ];
    final pg = _f9Page.clamp(0, 3);
    final intro = pg == 0;
    void go(int i) {
      HapticFeedback.selectionClick();
      setState(() {
        _f9Page = i;
        _f9Collapsed = false;
      });
    }

    // ---- ขั้นของแผ่น (ชื่อ, คำอธิบายคงที่, ไอคอน)
    const steps = <(String, String, IconData)>[
      ('ส่งต่อ', 'ห้องและสถานะถัดไปของผู้ป่วย', Icons.alt_route_rounded),
      ('ค่าใช้จ่าย', 'ยอดรอชำระและรายการยาของเคสนี้', Icons.payments_outlined),
      ('สรุป', 'ตรวจทานแล้วยืนยันส่งต่อ', Icons.task_alt_rounded),
    ];

    // แถวอ่านอย่างเดียว / แตะได้: ชื่อซ้าย ค่าขวา (› เมื่อแตะได้)
    Widget info(String label, String value,
            {bool first = false, Color? tone, VoidCallback? onTap}) =>
        Column(mainAxisSize: MainAxisSize.min, children: [
          if (!first)
            const Divider(
                height: 1.0, indent: 8.0, endIndent: 8.0, color: _line),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56.0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    8.0, 10.0, onTap == null ? 8.0 : 4.0, 10.0),
                child: Row(children: [
                  Text(label,
                      style: _t(14.0, color: _ink2, weight: FontWeight.w500)),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(value,
                        textAlign: TextAlign.right,
                        style: _t(14.0,
                            color: tone ?? _inkTitle, weight: FontWeight.w600)),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 4.0),
                    const Icon(Icons.chevron_right_rounded,
                        size: 22.0, color: _ink3),
                  ],
                ]),
              ),
            ),
          ),
        ]);

    // ---- สถานะ = เมนูช่วงงานในแถบซ้าย + ออกจากห้องฉุกเฉิน (ชื่อ/ไอคอนชุดเดียวกับแถบซ้าย)
    _Stage stageFor(_Phase ph) =>
        ph.stages.contains(p.stage) ? p.stage : ph.stages.first;
    // ไอคอน Phosphor (Regular) ชุดเดียวกับรางเมนู
    final phaseOpts = <(_Phase?, String, String)>[
      for (final ph in _Phase.values)
        (
          ph,
          ph.label,
          switch (ph) {
            _Phase.triage => 'ph-clipboard-text',
            _Phase.treatment => 'ph-first-aid-kit',
            _Phase.after => 'ph-sign-out',
            _Phase.observe => 'ph-eye',
          }
        ),
      (null, 'ออกจาก ER', 'ph-door-open'),
    ];
    Widget ph(String name, double size, Color c) => _SolarIcon('',
        size: size, color: c, paths: _f9PhIcons[name] ?? _solarIcons[name]);
    final curPhase = _f9Stage == null ? null : _Phase.of(_f9Stage!);
    String roomIc(String r) => switch (r) {
          'ห้องตรวจฉุกเฉิน' => 'ph-first-aid-kit',
          'ห้องสังเกตอาการ' => 'ph-eye',
          'ห้องเอกซเรย์' => 'ph-scan',
          'ห้องยา' => 'ph-pill',
          'การเงิน' => 'ph-money',
          'กลับบ้าน' => 'ph-house',
          'Admit (หอผู้ป่วย)' => 'ph-bed',
          'Refer' => 'ph-ambulance',
          _ => 'ph-door-open',
        };

    // ---- หน้าส่งต่อ (ตาม wireframe): หัวข้อ · แผงพื้นเทาไล่ลงขาว · ไทล์ขาว (วงไอคอน + ชื่อ)
    Widget label(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 8.0),
          child: Text(t,
              style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
        );
    Widget fadePanel(Widget child) => Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_panelSoft, _panel],
              stops: [0.25, 1.0],
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: child,
        );
    // ไทล์: เลือกแล้ว = พื้นกรมท่าทึบ ไอคอน/ชื่อขาว + ✓ ท้ายปุ่ม (ไม่มีเส้นขอบ)
    // เปลี่ยนสถานะ = ค่าเดียว (0..1) ไล่สีพื้น ไอคอน ตัวอักษร พร้อมกัน · ✓ ค่อย ๆ กางออก (ไม่โผล่ทันที)
    Widget tile(String name, String ic, bool on, VoidCallback pick) => _Press(
          child: GestureDetector(
            onTap: () {
              if (on) return;
              HapticFeedback.selectionClick();
              setState(pick);
            },
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: on ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              builder: (_, v, __) {
                final ink = Color.lerp(_inkTitle, Colors.white, v)!;
                return Container(
                  height: 46.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Color.lerp(_panel, _blue, v),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Row(children: [
                    Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                          color: Color.lerp(
                              _panelSoft, const Color(0x29FFFFFF), v),
                          shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: ph(ic, 17.0, Color.lerp(_ink2, Colors.white, v)!),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // น้ำหนักคงที่: ตัวอักษรไม่ขยับความกว้างตอนเปลี่ยนสถานะ
                          style: _t(13.5, color: ink, weight: FontWeight.w600)),
                    ),
                    SizedBox(
                      width: 24.0 * v,
                      child: Opacity(
                        opacity: v,
                        child: Transform.scale(
                          scale: 0.6 + 0.4 * v,
                          child: const OverflowBox(
                            maxWidth: 24.0,
                            child: Icon(Icons.check_rounded,
                                size: 18.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ]),
                );
              },
            ),
          ),
        );
    Widget card(List<Widget> kids) => Container(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFDADCE0), width: 0.5),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: kids),
        );

    final Widget content = switch (pg) {
      1 => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          label('ส่งต่อห้อง'),
          // ห้องมีหลายสิบ: ปุ่มเฉพาะห้องที่ใช้บ่อย (ห้องที่เลือกอยู่นอกชุดนี้ = ขึ้นเป็นปุ่มแรก)
          // ที่เหลือเลือกจากแผ่นรายการที่มีช่องค้นหา
          fadePanel(Column(children: [
            _qGrid(2, [
              for (final r in [
                if (!_f9RoomsTop.contains(_f9Room)) _f9Room,
                ..._f9RoomsTop.take(_f9RoomsTop.contains(_f9Room) ? 6 : 5),
              ])
                tile(r, roomIc(r), r == _f9Room, () => _f9Room = r)
            ]),
            const SizedBox(height: 10.0),
            _Press(
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  final v = await _listSheet('ส่งต่อห้อง', _f9Rooms,
                      current: _f9Room);
                  if (v != null && mounted) setState(() => _f9Room = v);
                },
                child: Container(
                  height: 44.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: const Color(0xFFDADCE0)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.search_rounded, size: 18.0, color: _blue),
                    const SizedBox(width: 6.0),
                    Text('ดูห้องทั้งหมด ${_f9Rooms.length} ห้อง',
                        style: _t(13.5, color: _blue, weight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ])),
          const SizedBox(height: 16.0),
          label('สถานะถัดไป'),
          // เส้นทางของผู้ป่วยแบบ workflow แนวตั้ง: เหรียญขั้น + เส้นเชื่อมลงขั้นถัดไป · ชื่อ + คำอธิบายด้านขวา
          // ขั้นที่ผ่านแล้ว = ✓ เขียว · ขั้นที่ผู้ป่วยอยู่ = ป้าย "สถานะปัจจุบัน" · ขั้นที่เลือกส่งต่อ = เหรียญกรมท่า การ์ดขาว (ขั้นอื่นไม่มีพื้น)
          // เส้น: เขียว = ผ่านมาแล้ว · กรมท่า = ช่วงจากขั้นปัจจุบันถึงขั้นที่เลือก · เทา = ที่เหลือ · แตะแถวเพื่อเลือก
          fadePanel(Builder(builder: (context) {
            const descs = [
              'ประเมินอาการแรกรับ',
              'ตรวจและให้การรักษา',
              'รอผลตรวจหรือรอรับยา',
              'ติดตามอาการต่อเนื่อง',
              'สิ้นสุดการดูแลในห้องฉุกเฉิน',
            ];
            final n = phaseOpts.length;
            final at = _Phase.values.indexOf(_Phase.of(p.stage));
            final sel = phaseOpts.indexWhere((o) => o.$1 == curPhase);
            final lo = math.min(at, sel), hi = math.max(at, sel);
            // สีเส้นช่วง k → k+1
            Color seg(int k) => k >= lo && k < hi
                ? _blue
                : k < at
                    ? const Color(0xFF22B45E)
                    : const Color(0xFFD5DCE8);
            return Column(children: [
              for (final (k, (o, l, _)) in phaseOpts.indexed)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (k == sel) return;
                    HapticFeedback.selectionClick();
                    setState(() => _f9Stage = o == null ? null : stageFor(o));
                  },
                  child: SizedBox(
                    height: 66.0,
                    child: Row(children: [
                      // เหรียญ + เส้นเชื่อมบน/ล่าง
                      SizedBox(
                        width: 52.0,
                        height: 66.0,
                        child: Stack(alignment: Alignment.center, children: [
                          if (k > 0)
                            Positioned(
                              top: 0.0,
                              height: 33.0,
                              width: 3.0,
                              child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  color: seg(k - 1)),
                            ),
                          if (k < n - 1)
                            Positioned(
                              bottom: 0.0,
                              height: 33.0,
                              width: 3.0,
                              child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  color: seg(k)),
                            ),
                          AnimatedScale(
                            scale: k == sel ? 1.1 : 0.88,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutBack,
                            child: SizedBox.square(
                              dimension: 36.0,
                              child: FittedBox(
                                child: _CoinFlip(
                                  value: k == sel
                                      ? 'on'
                                      : k < at
                                          ? 'done'
                                          : 'off',
                                  builder: (v, tilt) {
                                    final ic = o == null
                                        ? Icons.logout_rounded
                                        : _sideOutline(_phaseIcon(o));
                                    return switch (v) {
                                      'on' =>
                                        _SoStatusCoin.field(ic, tilt: tilt),
                                      'done' => const _SoStatusCoin.done(),
                                      _ => _SoStatusCoin.field(ic,
                                          on: false, tilt: tilt),
                                    };
                                  },
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeInOutCubic,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: k == sel
                                ? _panel
                                : _panel.withValues(alpha: 0.0),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l,
                                        maxLines: 1,
                                        style: _t(14.0,
                                            color: k == sel ? _blue : _inkTitle,
                                            weight: FontWeight.w600)),
                                    Text(descs[k],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: _t(12.5,
                                            color: _ink2,
                                            weight: FontWeight.w500)),
                                  ]),
                            ),
                            if (k == at)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2EAF8),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Text('สถานะปัจจุบัน',
                                    style: _t(11.5,
                                        color: _blue, weight: FontWeight.w600)),
                              ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
            ]);
          })),
        ]),
      2 => card([
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 12.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('เงินรอชำระ',
                  style: _t(13.0, color: _ink2, weight: FontWeight.w500)),
              TweenAnimationBuilder<double>(
                key: ValueKey('f9-amt-${p.hn}'),
                tween: Tween(begin: 0.0, end: amount),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => Text.rich(TextSpan(children: [
                  TextSpan(
                      text: _money(v),
                      style: _num(32.0,
                          color: _inkTitle, weight: FontWeight.w700)),
                  TextSpan(
                      text: '  บาท',
                      style: _t(14.0, color: _ink3, weight: FontWeight.w500)),
                ])),
              ),
            ]),
          ),
          info('สิทธิการรักษา', c.right, first: true),
          info('รายการยา', '$drugs รายการ'),
        ]),
      // สรุป: ภาษาเดียวกับหน้าส่งต่อ (หัวข้อ + แผง) · แตะแผง = กลับไปแก้หน้านั้น
      _ => Builder(builder: (context) {
          final at = _Phase.values.indexOf(_Phase.of(p.stage));
          final sel = phaseOpts.indexWhere((o) => o.$1 == curPhase);
          IconData icOf(int k) => phaseOpts[k].$1 == null
              ? Icons.logout_rounded
              : _sideOutline(_phaseIcon(phaseOpts[k].$1!));
          // จุดบนเส้นทาง: เหรียญ + ป้ายเล็ก + ชื่อขั้น
          Widget node(Widget coin, String cap, String name, bool on) =>
              Expanded(
                child: Column(children: [
                  SizedBox.square(
                      dimension: 44.0, child: FittedBox(child: coin)),
                  const SizedBox(height: 6.0),
                  Text(cap,
                      style: _t(12.0, color: _ink2, weight: FontWeight.w500)),
                  Text(name,
                      maxLines: 1,
                      style: _t(15.0,
                          color: on ? _blue : _inkTitle,
                          weight: FontWeight.w700)),
                ]),
              );
          Widget edit(Widget child, VoidCallback onTap) => _Press(
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: child));
          // line = แถวรายการเรียบ ไม่มีกล่อง ไม่มีพื้น (คั่นด้วยเส้นบาง)
          Widget row(String icon, String cap, String value,
                  {Color? tone, bool line = false}) =>
              Container(
                height: 54.0,
                padding: EdgeInsets.symmetric(horizontal: line ? 4.0 : 10.0),
                decoration: line
                    ? null
                    : BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                child: Row(children: [
                  Container(
                    width: 30.0,
                    height: 30.0,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: _panelSoft, shape: BoxShape.circle),
                    child: ph(icon, 18.0, _ink2),
                  ),
                  const SizedBox(width: 10.0),
                  Text(cap,
                      style: _t(13.5, color: _ink2, weight: FontWeight.w500)),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(value,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(15.0,
                            color: tone ?? _inkTitle, weight: FontWeight.w700)),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 20.0, color: _ink3),
                ]),
              );
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label('ส่งต่อ'),
                fadePanel(Column(children: [
                  // เส้นทาง: สถานะปัจจุบัน → สถานะถัดไป
                  edit(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 12.0),
                      child: Row(children: [
                        node(_SoStatusCoin.field(icOf(at), on: false),
                            'สถานะปัจจุบัน', phaseOpts[at].$2, false),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 34.0),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            for (var k = 0; k < 3; k++)
                              Container(
                                width: 6.0,
                                height: 3.0,
                                margin: const EdgeInsets.only(right: 4.0),
                                decoration: BoxDecoration(
                                  color: _blue,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 20.0, color: _blue),
                          ]),
                        ),
                        node(_SoStatusCoin.field(icOf(sel)), 'สถานะถัดไป',
                            phaseOpts[sel].$2, true),
                      ]),
                    ),
                    () => go(1),
                  ),
                  edit(
                      row(roomIc(_f9Room), 'ส่งต่อห้อง', _f9Room), () => go(1)),
                ])),
                const SizedBox(height: 16.0),
                label('ค่าใช้จ่าย'),
                edit(
                    row('ph-money', 'เงินรอชำระ', '${_money(amount)} บาท',
                        tone: amount > 0 ? _red : null, line: true),
                    () => go(2)),
                const Divider(height: 1.0, indent: 44.0, color: _line),
                edit(row('ph-pill', 'รายการยา', '$drugs รายการ', line: true),
                    () => go(2)),
                // ยังบันทึกไม่ครบ = เตือน แตะแล้วปิดลิ้นชักไปขั้นแรกที่ขาด (ส่งต่อได้อยู่)
                if (missSteps.isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  label('การบันทึก'),
                  edit(
                      row('ph-clipboard-text', 'ยังไม่ได้บันทึก',
                          '${missSteps.length} ขั้น', tone: _red, line: true),
                      () {
                    _f9Close();
                    _openSpeech(step: missSteps.first);
                  }),
                ],
              ]);
        }),
    };

    // ---- การ์ดหัว (โครง Figma ย่อให้พอดี iPad: พื้นเทามน 20 · ชื่อ 20 bold · คำอธิบาย 14) สูงเท่ากันทุกหน้า
    final title = intro ? 'บันทึกส่งต่อผู้ป่วย' : steps[pg - 1].$1;
    final sub = intro ? 'ตรวจทีละหัวข้อแล้วยืนยันส่งต่อ' : steps[pg - 1].$2;

    final hero = AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
      // เต็มกว้างเสมอ (แฟ้ม/กระดาษยึดขอบขวาการ์ด)
      width: double.infinity,
      height: _f9Collapsed ? 50.0 : 84.0,
      padding: EdgeInsets.fromLTRB(18.0, _f9Collapsed ? 12.0 : 16.0, 18.0, 0.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _panelSoft,
        borderRadius: BorderRadius.circular(20.0),
      ),
      // ย่อแล้วคำอธิบายล้นความสูงการ์ด (จางหาย + ถูกตัด) ไม่ให้ขึ้นแถบ overflow
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Appear(
            key: ValueKey('f9-hero-$_f9Gen'),
            index: 1,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (w, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                      position:
                          Tween(begin: const Offset(0.0, 0.3), end: Offset.zero)
                              .animate(a),
                      child: w)),
              child: Column(
                  key: ValueKey('f9-head-$pg'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 100.0),
                      child: Text(title,
                          style: _t(18.0,
                              color: _inkTitle, weight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 2.0),
                    AnimatedOpacity(
                      opacity: _f9Collapsed ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 100.0),
                        child: Text(sub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _t(13.0,
                                color: _ink2, weight: FontWeight.w500)),
                      ),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );

    Widget stack() => Stack(clipBehavior: Clip.none, children: [
          hero,
          // แฟ้มสุขภาพ (ตัวเดียวกับ AI Overview) มุมขวาบน ล้นเหนือการ์ดหัวเล็กน้อย · กระดาษของแต่ละขั้นเลื่อนออกจากในแฟ้ม
          Positioned(
            right: 0.0,
            top: -16.0,
            width: 104.0,
            height: 104.0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                  opacity: _f9Collapsed ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedSlide(
                      offset: Offset(0.0, _f9Collapsed ? 0.25 : 0.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      child: _F9Folder(
                        out: pg,
                        gen: _f9Gen,
                        data: _F9PaperData(
                          room: _f9Rooms.indexOf(_f9Room),
                          stage: curPhase == null
                              ? -1
                              : _Phase.values.indexOf(curPhase),
                        ),
                      ))),
            ),
          ),
        ]);

    // ลิ้นชักเต็มสูงขอบขวา (พื้นขาว เส้นซ้าย + เงา แบบลิ้นชักอื่นของหน้าผู้ป่วย)
    final panel = Container(
      width: 440.0,
      decoration: BoxDecoration(
        color: _panel,
        border: const Border(left: BorderSide(color: _line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24.0,
            offset: const Offset(-6, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          stack(),
          const SizedBox(height: 16.0),
          Expanded(
            child: _wfFadePage(
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (cur, prev) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...prev, if (cur != null) cur]),
                transitionBuilder: (w, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position:
                        Tween(begin: const Offset(0.0, 0.06), end: Offset.zero)
                            .animate(a),
                    child: w,
                  ),
                ),
                child: intro
                    // หน้าแนะนำ: รายการสิ่งที่ต้องตรวจ ชุดเดียวกับหน้าแนะนำของ workflow
                    ? ListView(
                        key: ValueKey('f9-intro-$_f9Gen'),
                        padding:
                            const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 100.0),
                        children: [
                          _stepIntroList(
                              [for (final (n, d, _) in steps) (n, d)])
                        ],
                      )
                    // เลื่อนลง = ย่อการ์ดหัว · กลับบนสุด = ขยายคืน (เฉพาะการเลื่อนแนวตั้งของหน้า)
                    // ย่อเมื่อเนื้อหายาวพอเท่านั้น (ย่อแล้วพื้นที่เพิ่ม 56 ต้องยังเลื่อนได้ ไม่งั้นเด้งกลับ)
                    : NotificationListener<ScrollNotification>(
                        key: ValueKey('f9-page-$pg'),
                        onNotification: (n) {
                          if (n.depth != 0 || n.metrics.axis != Axis.vertical) {
                            return false;
                          }
                          final m = n.metrics;
                          final want = _f9Collapsed
                              ? m.pixels > 0.5
                              : m.pixels > 24.0 && m.maxScrollExtent > 80.0;
                          if (want != _f9Collapsed) {
                            setState(() => _f9Collapsed = want);
                          }
                          return false;
                        },
                        child: ListView(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 100.0),
                          children: [content],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 28.0),
                child: Row(children: [
                  // หน้าแนะนำ = ปิดลิ้นชัก (×) · หน้าตรวจ = ย้อนกลับ (ปุ่มกลมชุดเดียวกับ footer workflow)
                  intro
                      ? Flexible(
                          fit: FlexFit.loose,
                          flex: 0,
                          child: _wfFootSide(
                              left: true,
                              show: true,
                              child: _wfIconBtn(
                                  Icons.close_rounded, 'ปิด', _f9Close)),
                        )
                      : _wfFootBack(() => go(pg - 1)),
                  Expanded(
                    child: switch (pg) {
                      0 => _navBtn('ดำเนินการต่อ', Icons.chevron_right_rounded,
                          () => go(1),
                          trailing: true),
                      3 => _navBtn(
                          'ยืนยันส่งต่อ', Icons.check_rounded, _f9Confirm),
                      _ => _navBtn('ถัดไป', Icons.chevron_right_rounded,
                          () => go(pg + 1),
                          trailing: true),
                    },
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
    // หน้าสำเร็จสีเขียวทับทั้งลิ้นชักหลังยืนยัน
    return Stack(children: [
      panel,
      if (_f9Sent != null)
        Positioned.fill(
          child: _F9Success(
            key: ValueKey('f9-success-$_f9Gen'),
            name: _f9Sent!.$1,
            line: 'ส่งต่อไป${_f9Sent!.$3} สถานะ${_f9Sent!.$2}',
            by: ErSession.instance.user?.name ?? 'คุณ',
            base: _t(14.0, color: Colors.white, weight: FontWeight.w500),
            onEnd: _f9Finish,
          ),
        ),
    ]);
  }
}

/// แฟ้มบันทึกส่งต่อ = แฟ้มสุขภาพโมเดลเดียวกับภาพ AI Overview (_Scene3D.folder) สีเหลืองส้ม + กากบาทขาว หันเฉียงซ้าย
/// เพิ่มเฉพาะกระดาษ 2 ขั้น (ส่งต่อ · ค่าใช้จ่าย) · [out] = หน้าที่อยู่ (0 แนะนำ · 1..2 ขั้น · 3 สรุป)
/// เข้าหน้าตรวจ = กระดาษออกจากแฟ้มเต็มแผ่น แฟ้มจมลงใต้ขอบการ์ดหาย · แผ่นของขั้นที่ตรวจยกสูงกว่า · 4 = ตราเขียว ✓
class _F9Folder extends StatefulWidget {
  const _F9Folder(
      {required this.out, required this.gen, this.data = const _F9PaperData()});
  final int out;

  /// ข้อมูลที่กระดาษแต่ละขั้นย่อลงมาแสดง
  final _F9PaperData data;

  /// เปลี่ยนทุกครั้งที่เปิดลิ้นชัก = เล่นเรื่องเปิดใหม่
  final int gen;

  @override
  State<_F9Folder> createState() => _F9FolderState();
}

/// เรื่องเปิดลิ้นชัก (เล่นครั้งเดียวต่อการเปิด แล้วค้าง): แฟ้มหมุนโผล่ขึ้นจากขอบล่างการ์ดหัว
/// → กระดาษ 2 ขั้นเด้งขึ้นสุดทีละแผ่นแล้วลงไปค้างโผล่ครึ่ง ๆ · ดำเนินการต่อ = กระดาษออก แฟ้มจมหาย (เรื่องต่อเนื่อง)
class _F9FolderState extends State<_F9Folder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _story = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200), value: 1.0);

  @override
  void didUpdateWidget(covariant _F9Folder old) {
    super.didUpdateWidget(old);
    if (widget.gen != old.gen) _story.forward(from: 0.0);
  }

  @override
  void dispose() {
    _story.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(
          // ตัดที่ขอบล่างการ์ดหัวหน้าแนะนำ = แฟ้มโผล่ขึ้นจากขอบการ์ด
          child: ClipRect(
            clipper: const _F9FolderClip(),
            child: RepaintBoundary(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: widget.out.toDouble()),
                duration: const Duration(milliseconds: 640),
                builder: (_, p, __) => AnimatedBuilder(
                  animation: _story,
                  builder: (_, __) => CustomPaint(
                      painter: _F9FolderPainter(p, _story.value, widget.data)),
                ),
              ),
            ),
          ),
        ),
        // ครบทุกขั้น (หน้าสรุป) = ตราเขียว ✓ ที่มุมขวาล่างของแฟ้ม (หันซ้ายตามปกแฟ้ม)
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.78, 0.86),
            // โผล่หลังแฟ้มกลับขึ้นมาเข้าที่ (รอ ~0.5 วิ): เด้งขยาย + หมุนพลิกมาหยุดหันซ้าย · ออก = หดเร็ว
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: widget.out >= 3 ? 1.0 : 0.0),
              duration: Duration(milliseconds: widget.out >= 3 ? 1150 : 160),
              builder: (_, v, __) {
                final t = ((v - 0.45) / 0.55).clamp(0.0, 1.0);
                final pop = Curves.easeOutBack.transform(t);
                final spin = 1.0 - Curves.easeOutCubic.transform(t);
                return Opacity(
                  opacity: (t * 4.0).clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0.0, 10.0 * (1.0 - pop)),
                    child: Transform.scale(
                      scale: pop,
                      child: SizedBox.square(
                        dimension: 32.0,
                        child: FittedBox(
                          // หันซ้ายตามปกแฟ้ม (เหรียญปกติหันขวา)
                          child: _PeBadge25D(
                              kind: 0,
                              size: 36.0,
                              tilt: -0.45 - 2.0 * math.pi * spin),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ]);
}

class _F9FolderPainter extends CustomPainter {
  _F9FolderPainter(this.p, this.t, this.data,
      {this.calm = false, this.tuck = 0.0});

  /// หน้าสำเร็จ: เก็บกระดาษที่โผล่อยู่ลงแฟ้ม (0 = โผล่ตามเรื่องเปิด · 1 = เก็บเกือบมิด)
  final double tuck;

  /// หน้าสำเร็จ: แฟ้มหมุนขึ้นมาแบบนิ่ง ๆ ไม่เด้ง
  final bool calm;

  /// p = ความคืบหน้าหน้าตรวจ (0..4) · t = เวลาเรื่องเปิดลิ้นชัก (0..1 · 1 = จบแล้ว นิ่ง)
  final double p, t;

  /// ข้อมูลจริงที่กระดาษย่อลงมาแสดง (หน้าตาล้อหน้าของขั้นนั้น)
  final _F9PaperData data;

  double _seg(double a, double b, [Curve c = Curves.easeInOutCubic]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  static const _ink = Color(0xFF4A6FEA),
      _bar = Color(0xFFDCE2EC),
      _pick = Color(0xFFE2EAF8);

  // ไอคอนของกระดาษแต่ละขั้น (ส่งต่อ · ค่าใช้จ่าย) ชุดเดียวกับขั้นในลิ้นชัก
  static const _icons = [Icons.alt_route_rounded, Icons.payments_outlined];

  // แฟ้มเอกสารสีเหลืองส้ม (แฟ้มเวชระเบียนกระดาษ) · กากบาทขาว
  static const _folder = Color(0xFFF5AD3C);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 100.0;
    canvas.save();
    canvas.scale(k);
    // เรื่องเปิด: แฟ้มหมุนโผล่ขึ้นจากขอบล่างการ์ดหัว (ตัดที่ขอบการ์ด) จากเกือบตะแคงมาหันหน้า
    // หันเฉียงไปทางซ้าย (yaw บวก) เข้าหาเนื้อหาของลิ้นชัก
    final rise =
        _seg(0.06, 0.52, calm ? Curves.easeOutCubic : Curves.easeOutBack);
    final spin = _seg(0.06, 0.56, Curves.easeOutCubic);
    // หน้าตรวจ: แฟ้มจมลงใต้ขอบการ์ดหาย (ตัดที่ขอบ) ทิ้งกระดาษไว้ · ย้อนกลับหน้าแนะนำ = แฟ้มขึ้นมารับ
    // แฟ้มพ้นไปแล้วมีที่ว่าง = กระดาษขยาย 35% เกือบเต็มความสูงการ์ด
    // หน้าสรุป (p 2→3): เอกสารกลับเข้าแฟ้ม แฟ้มขึ้นมาปิดเรื่อง พร้อมตรา ✓
    final back = Curves.easeInOutCubic.transform((p - 2.0).clamp(0.0, 1.0));
    final out = p.clamp(0.0, 1.0) * (1.0 - back);
    final sc = _Scene3D(
        yaw: 0.38 - 1.7 * (1.0 - spin),
        pitch: 0.3,
        center: Offset(50.0, 84.0 + 64.0 * (1.0 - rise)),
        f: 170.0,
        scale: 1.75 * (1.0 + 0.35 * Curves.easeInOutCubic.transform(out)));
    final sink = 72.0 * Curves.easeInCubic.transform(out);
    // (หน้าสรุป: out = 0 แล้ว = แฟ้มกลับขึ้นมา กระดาษกลับเข้าแฟ้ม ขนาดเดิม)
    // กระดาษที่ออกมาแล้วเลื่อนลงมา ขอบล่างเลยขอบการ์ดเล็กน้อย (ถูกตัดที่ขอบ = วางพิงขอบการ์ด)
    final drop = 16.0 * Curves.easeInOutCubic.transform(out);
    _V down(_V v) => _V(v.x, v.y + sink, v.z);
    sc.folder(down, _folder, cross: true, layer: 1);

    // กระดาษขั้น i: ขอบล่างจมใต้ปก ยืดขอบบนขึ้นแทนการเลื่อน (แบบกระดาษของ AI Overview)
    // เรียงเป็นปึกเรียบ ๆ เอียงนิดเดียว เยื้องซ้ายขวา · หน้าตรวจ: แผ่นของขั้นนั้นมาอยู่หน้าสุดและยกสูง
    final pr = p.round();
    final cur = pr >= 1 && pr <= 2 ? pr - 1 : -1;
    final glyphs = <(Offset, Offset, Offset, double, IconData)>[];
    for (var i = 0; i < 2; i++) {
      final rank = cur < 0 ? i : (i == cur ? 1 : 0);
      // เรื่องเปิด: แฟ้มเข้าที่แล้วกระดาษเด้งขึ้นสุดทีละแผ่น แล้วค่อยลงไปค้างโผล่ครึ่ง ๆ (เห็นแถบหัว)
      // หน้าตรวจ: โฟกัสกระดาษแผ่นเดียว = แผ่นของขั้นนั้นตั้งตรงกลางการ์ด แผ่นอื่นจมลงใต้ขอบการ์ด
      // (เปลี่ยนหน้า = แผ่นเก่าจมลง แผ่นใหม่ขึ้นมาแทน) · หน้าสรุป: ทุกแผ่นกลับขึ้นมาซ้อนกัน
      final t0 = 0.42 + 0.14 * i;
      final up = _seg(t0, t0 + 0.15, Curves.easeOutCubic);
      final settle = _seg(t0 + 0.15, t0 + 0.36, Curves.easeInOutCubic);
      final peek = up + (0.62 - up) * settle;
      // หน้าสรุป: กระดาษเก็บลงแฟ้มเกือบมิด (เห็นแค่ขอบบน) = แฟ้มปิดเรียบร้อย
      final r = math.max(Curves.easeOutCubic.transform(out),
          peek * (1.0 - 0.75 * back) * (1.0 - 0.85 * tuck));
      final focus = Curves.easeInOutCubic
          .transform((1.0 - (p - (i + 1)).abs()).clamp(0.0, 1.0));
      final summary = (p - 2.0).clamp(0.0, 1.0);
      final hide = Curves.easeInCubic
          .transform((out * (1.0 - focus) * (1.0 - summary)).clamp(0.0, 1.0));
      final lift = 3.0 * focus - 60.0 * hide;
      // ตอนลงเอียงไหวนิดเดียวสลับซ้ายขวา (กระดาษพลิ้ว) แล้วนิ่ง
      final sway = 0.05 * math.sin(math.pi * settle) * (i.isEven ? 1.0 : -1.0);
      final ang = [-0.06, 0.06][i] * r * (1.0 - focus) + sway,
          dx = [-3.0, 3.5][i] * r * (1.0 - focus);
      final ca = math.cos(ang), sa = math.sin(ang);
      _V tf(_V v) {
        final y = v.y + 3.0;
        return _V(
            v.x * ca - y * sa + dx, v.x * sa + y * ca - 3.0 - lift + drop, v.z);
      }

      final top = -20.0 - [17.0, 15.0][i] * r;
      final z0 = -0.55 - 0.3 * rank;
      final base = 0.3 + 0.08 * rank;
      // ขอบกระดาษ (มีความหนา รับแสง) + หน้ากระดาษขาวล้วนไม่ลงเงา
      sc._sub = base;
      sc.slab([
        const Offset(-10, -3),
        Offset(-10, top),
        Offset(10, top),
        const Offset(10, -3),
      ], z0, z0 + 0.15, const Color(0xFFE3E8F0), tf, layer: 1);
      final zf = z0 - 0.02;
      // ชั้นย่อยบนกระดาษ (lv 0 = พื้นกระดาษ · ยิ่งมากยิ่งอยู่หน้า) · ใต้ขอบล่างกระดาษไม่วาด
      void rect(double x0, double y0, double x1, double y1, Color c,
          [int lv = 2]) {
        if (lv > 0 && y1 > -4.0) return;
        sc.faces.add(_Face([
          tf(_V(x0, y1, zf)),
          tf(_V(x0, y0, zf)),
          tf(_V(x1, y0, zf)),
          tf(_V(x1, y1, zf)),
        ], c, flat: true, group: 1, order: sc.order + base + 0.02 + 0.01 * lv));
      }

      // กระดาษ = ไอคอนของขั้นนั้น (ชุดเดียวกับรายการหน้าแนะนำ) ในวงฟ้าอ่อนกลางแผ่น
      // แถบหัวน้ำเงินด้านบน (เห็นตอนโผล่ในแฟ้ม) + เส้นข้อความเทา 2 เส้นใต้ไอคอน
      rect(-10.0, top, 10.0, -3.0, Colors.white, 0);
      rect(-7.0, top + 2.6, 0.0, top + 4.1, _ink);
      const cy0 = 15.5, rr = 7.2;
      if (top + cy0 + rr <= -4.0) {
        sc.faces.add(_Face([
          for (var k = 0; k < 20; k++)
            tf(_V(rr * math.cos(math.pi * k / 10),
                top + cy0 + rr * math.sin(math.pi * k / 10), zf)),
        ], _pick, flat: true, group: 1, order: sc.order + base + 0.04));
      }
      rect(-6.0, top + 25.6, 6.0, top + 26.8, _bar);
      rect(-6.0, top + 28.4, 2.0, top + 29.6, _bar);
      // ไอคอนวาดทับหลังฉาก (ตามระนาบกระดาษ) เฉพาะแผ่นที่โฟกัส · หน้าสรุป = แผ่นหน้าสุด
      final a = focus;
      if (a > 0.01) {
        final o = sc.project(tf(_V(0.0, top + cy0, zf)));
        final ux = sc.project(tf(_V(1.0, top + cy0, zf))) - o;
        final uy = sc.project(tf(_V(0.0, top + cy0 + 1.0, zf))) - o;
        glyphs.add((o, ux, uy, a * a, _icons[i]));
      }
    }
    sc._sub = 0.0;
    sc.paint(canvas);
    for (final (o, ux, uy, a, ic) in glyphs) {
      final tp = TextPainter(
          text: TextSpan(
              text: String.fromCharCode(ic.codePoint),
              style: TextStyle(
                  fontFamily: ic.fontFamily,
                  package: ic.fontPackage,
                  fontSize: 9.0,
                  height: 1.0,
                  color: _ink.withValues(alpha: a))),
          textDirection: TextDirection.ltr)
        ..layout();
      canvas.save();
      canvas.transform(Matrix4(
        ux.dx, ux.dy, 0.0, 0.0, //
        uy.dx, uy.dy, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        o.dx, o.dy, 0.0, 1.0,
      ).storage);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_F9FolderPainter o) =>
      o.p != p ||
      o.t != t ||
      o.data != data ||
      o.calm != calm ||
      o.tuck != tuck;
}

/// ขอบตัดของแฟ้ม: ล่าง = ขอบล่างการ์ดหัวหน้าแนะนำ (กล่องแฟ้มเริ่ม -16 · การ์ดสูง 84) · บน/ข้างปล่อยล้นได้
class _F9FolderClip extends CustomClipper<Rect> {
  const _F9FolderClip();
  @override
  Rect getClip(Size s) => Rect.fromLTRB(-200.0, -400.0, s.width + 200.0, 100.0);
  @override
  bool shouldReclip(covariant CustomClipper<Rect> old) => false;
}

/// ข้อมูลจริงย่อลงบนกระดาษ: ห้องที่เลือก · สถานะที่เลือก (แถวแรกของไทล์)
class _F9PaperData {
  const _F9PaperData({this.room = -1, this.stage = -1});
  final int room, stage;

  @override
  bool operator ==(Object o) =>
      o is _F9PaperData && o.room == room && o.stage == stage;

  @override
  int get hashCode => Object.hash(room, stage);
}

/// ไอคอน Phosphor (MIT, Regular) ของลิ้นชักส่งต่อ · path 24×24 แปลงจาก SVG ต้นฉบับ (arc → cubic)
const _f9PhIcons = <String, List<(String, bool, bool)>>{
  // Phosphor first-aid-kit (Regular)
  'ph-first-aid-kit': [
    (
      'M20.25 5.25L16.5 5.25L16.5 4.5C16.5 3.257 15.493 2.25 14.25 2.25L9.75 2.25C8.507 2.25 7.5 3.257 7.5 4.5L7.5 5.25L3.75 5.25C2.922 5.25 2.25 5.922 2.25 6.75L2.25 18.75C2.25 19.578 2.922 20.25 3.75 20.25L20.25 20.25C21.078 20.25 21.75 19.578 21.75 18.75L21.75 6.75C21.75 5.922 21.078 5.25 20.25 5.25ZM9 4.5C9 4.086 9.336 3.75 9.75 3.75L14.25 3.75C14.664 3.75 15 4.086 15 4.5L15 5.25L9 5.25ZM20.25 18.75L3.75 18.75L3.75 6.75L20.25 6.75L20.25 18.75ZM15 12.75C15 13.164 14.664 13.5 14.25 13.5L12.75 13.5L12.75 15C12.75 15.414 12.414 15.75 12 15.75C11.586 15.75 11.25 15.414 11.25 15L11.25 13.5L9.75 13.5C9.336 13.5 9 13.164 9 12.75C9 12.336 9.336 12 9.75 12L11.25 12L11.25 10.5C11.25 10.086 11.586 9.75 12 9.75C12.414 9.75 12.75 10.086 12.75 10.5L12.75 12L14.25 12C14.664 12 15 12.336 15 12.75Z',
      true,
      false
    ),
  ],
  // Phosphor scan (Regular)
  'ph-scan': [
    (
      'M21 3.75L21 7.5C21 7.914 20.664 8.25 20.25 8.25C19.836 8.25 19.5 7.914 19.5 7.5L19.5 4.5L16.5 4.5C16.086 4.5 15.75 4.164 15.75 3.75C15.75 3.336 16.086 3 16.5 3L20.25 3C20.664 3 21 3.336 21 3.75ZM7.5 19.5L4.5 19.5L4.5 16.5C4.5 16.086 4.164 15.75 3.75 15.75C3.336 15.75 3 16.086 3 16.5L3 20.25C3 20.664 3.336 21 3.75 21L7.5 21C7.914 21 8.25 20.664 8.25 20.25C8.25 19.836 7.914 19.5 7.5 19.5ZM20.25 15.75C19.836 15.75 19.5 16.086 19.5 16.5L19.5 19.5L16.5 19.5C16.086 19.5 15.75 19.836 15.75 20.25C15.75 20.664 16.086 21 16.5 21L20.25 21C20.664 21 21 20.664 21 20.25L21 16.5C21 16.086 20.664 15.75 20.25 15.75ZM3.75 8.25C4.164 8.25 4.5 7.914 4.5 7.5L4.5 4.5L7.5 4.5C7.914 4.5 8.25 4.164 8.25 3.75C8.25 3.336 7.914 3 7.5 3L3.75 3C3.336 3 3 3.336 3 3.75L3 7.5C3 7.914 3.336 8.25 3.75 8.25ZM7.5 6.75L16.5 6.75C16.914 6.75 17.25 7.086 17.25 7.5L17.25 16.5C17.25 16.914 16.914 17.25 16.5 17.25L7.5 17.25C7.086 17.25 6.75 16.914 6.75 16.5L6.75 7.5C6.75 7.086 7.086 6.75 7.5 6.75ZM8.25 15.75L15.75 15.75L15.75 8.25L8.25 8.25Z',
      true,
      false
    ),
  ],
  // Phosphor money (Regular)
  'ph-money': [
    (
      'M12 8.25C9.929 8.25 8.25 9.929 8.25 12C8.25 14.071 9.929 15.75 12 15.75C14.071 15.75 15.75 14.071 15.75 12C15.75 9.929 14.071 8.25 12 8.25ZM12 14.25C10.757 14.25 9.75 13.243 9.75 12C9.75 10.757 10.757 9.75 12 9.75C13.243 9.75 14.25 10.757 14.25 12C14.25 13.243 13.243 14.25 12 14.25ZM22.5 5.25L1.5 5.25C1.086 5.25 0.75 5.586 0.75 6L0.75 18C0.75 18.414 1.086 18.75 1.5 18.75L22.5 18.75C22.914 18.75 23.25 18.414 23.25 18L23.25 6C23.25 5.586 22.914 5.25 22.5 5.25ZM18.155 17.25L5.845 17.25C5.334 15.52 3.98 14.166 2.25 13.655L2.25 10.345C3.98 9.834 5.334 8.48 5.845 6.75L18.155 6.75C18.666 8.48 20.02 9.834 21.75 10.345L21.75 13.655C20.02 14.166 18.666 15.52 18.155 17.25ZM21.75 8.753C20.85 8.367 20.133 7.65 19.747 6.75L21.75 6.75ZM4.253 6.75C3.867 7.65 3.15 8.367 2.25 8.753L2.25 6.75ZM2.25 15.247C3.15 15.633 3.867 16.35 4.253 17.25L2.25 17.25ZM19.747 17.25C20.133 16.35 20.85 15.633 21.75 15.247L21.75 17.25Z',
      true,
      false
    ),
  ],
  // Phosphor house (Regular)
  'ph-house': [
    (
      'M20.56 10.189L13.06 2.689C12.475 2.103 11.525 2.103 10.94 2.689L3.44 10.189C3.157 10.469 2.999 10.852 3 11.25L3 20.25C3 20.664 3.336 21 3.75 21L9.75 21C10.164 21 10.5 20.664 10.5 20.25L10.5 15L13.5 15L13.5 20.25C13.5 20.664 13.836 21 14.25 21L20.25 21C20.664 21 21 20.664 21 20.25L21 11.25C21.001 10.852 20.843 10.469 20.56 10.189ZM19.5 19.5L15 19.5L15 14.25C15 13.836 14.664 13.5 14.25 13.5L9.75 13.5C9.336 13.5 9 13.836 9 14.25L9 19.5L4.5 19.5L4.5 11.25L12 3.75L19.5 11.25Z',
      true,
      false
    ),
  ],
  // Phosphor bed (Regular)
  'ph-bed': [
    (
      'M20.25 6.75L3 6.75L3 4.5C3 4.086 2.664 3.75 2.25 3.75C1.836 3.75 1.5 4.086 1.5 4.5L1.5 19.5C1.5 19.914 1.836 20.25 2.25 20.25C2.664 20.25 3 19.914 3 19.5L3 16.5L22.5 16.5L22.5 19.5C22.5 19.914 22.836 20.25 23.25 20.25C23.664 20.25 24 19.914 24 19.5L24 10.5C24 8.429 22.321 6.75 20.25 6.75ZM3 8.25L9.75 8.25L9.75 15L3 15ZM11.25 15L11.25 8.25L20.25 8.25C21.493 8.25 22.5 9.257 22.5 10.5L22.5 15Z',
      true,
      false
    ),
  ],
  // Phosphor ambulance (Regular)
  'ph-ambulance': [
    (
      'M7.5 11.25C7.5 10.836 7.836 10.5 8.25 10.5L9.75 10.5L9.75 9C9.75 8.586 10.086 8.25 10.5 8.25C10.914 8.25 11.25 8.586 11.25 9L11.25 10.5L12.75 10.5C13.164 10.5 13.5 10.836 13.5 11.25C13.5 11.664 13.164 12 12.75 12L11.25 12L11.25 13.5C11.25 13.914 10.914 14.25 10.5 14.25C10.086 14.25 9.75 13.914 9.75 13.5L9.75 12L8.25 12C7.836 12 7.5 11.664 7.5 11.25ZM24 11.25L24 17.25C24 18.078 23.328 18.75 22.5 18.75L20.906 18.75C20.566 20.077 19.37 21.006 18 21.006C16.63 21.006 15.434 20.077 15.094 18.75L10.406 18.75C10.066 20.077 8.87 21.006 7.5 21.006C6.13 21.006 4.934 20.077 4.594 18.75L3 18.75C2.172 18.75 1.5 18.078 1.5 17.25L1.5 6.75C1.5 5.922 2.172 5.25 3 5.25L17.25 5.25C17.664 5.25 18 5.586 18 6L18 6.75L21.242 6.75C21.856 6.748 22.409 7.122 22.635 7.693L23.947 10.974C23.982 11.062 24 11.156 24 11.25ZM18 8.25L18 10.5L22.142 10.5L21.242 8.25ZM3 17.25L4.594 17.25C4.934 15.923 6.13 14.994 7.5 14.994C8.87 14.994 10.066 15.923 10.406 17.25L15.094 17.25C15.297 16.471 15.803 15.807 16.5 15.404L16.5 6.75L3 6.75ZM9 18C9 17.172 8.328 16.5 7.5 16.5C6.672 16.5 6 17.172 6 18C6 18.828 6.672 19.5 7.5 19.5C8.328 19.5 9 18.828 9 18ZM19.5 18C19.5 17.172 18.828 16.5 18 16.5C17.172 16.5 16.5 17.172 16.5 18C16.5 18.828 17.172 19.5 18 19.5C18.828 19.5 19.5 18.828 19.5 18ZM22.5 17.25L22.5 12L18 12L18 15C19.368 15.001 20.562 15.926 20.906 17.25Z',
      true,
      false
    ),
  ],
  // Phosphor clipboard-text (Regular)
  'ph-clipboard-text': [
    (
      'M15.75 14.25C15.75 14.664 15.414 15 15 15L9 15C8.586 15 8.25 14.664 8.25 14.25C8.25 13.836 8.586 13.5 9 13.5L15 13.5C15.414 13.5 15.75 13.836 15.75 14.25ZM15 10.5L9 10.5C8.586 10.5 8.25 10.836 8.25 11.25C8.25 11.664 8.586 12 9 12L15 12C15.414 12 15.75 11.664 15.75 11.25C15.75 10.836 15.414 10.5 15 10.5ZM20.25 4.5L20.25 20.25C20.25 21.078 19.578 21.75 18.75 21.75L5.25 21.75C4.422 21.75 3.75 21.078 3.75 20.25L3.75 4.5C3.75 3.672 4.422 3 5.25 3L8.649 3C9.502 2.046 10.72 1.5 12 1.5C13.28 1.5 14.498 2.046 15.351 3L18.75 3C19.578 3 20.25 3.672 20.25 4.5ZM9 6L15 6C15 4.343 13.657 3 12 3C10.343 3 9 4.343 9 6ZM18.75 4.5L16.242 4.5C16.413 4.982 16.5 5.489 16.5 6L16.5 6.75C16.5 7.164 16.164 7.5 15.75 7.5L8.25 7.5C7.836 7.5 7.5 7.164 7.5 6.75L7.5 6C7.5 5.489 7.587 4.982 7.758 4.5L5.25 4.5L5.25 20.25L18.75 20.25Z',
      true,
      false
    ),
  ],
  // Phosphor sign-out (Regular)
  'ph-sign-out': [
    (
      'M11.25 20.25C11.25 20.664 10.914 21 10.5 21L4.5 21C4.086 21 3.75 20.664 3.75 20.25L3.75 3.75C3.75 3.336 4.086 3 4.5 3L10.5 3C10.914 3 11.25 3.336 11.25 3.75C11.25 4.164 10.914 4.5 10.5 4.5L5.25 4.5L5.25 19.5L10.5 19.5C10.914 19.5 11.25 19.836 11.25 20.25ZM21.531 11.469L17.781 7.719C17.488 7.426 17.012 7.426 16.719 7.719C16.426 8.012 16.426 8.488 16.719 8.781L19.19 11.25L10.5 11.25C10.086 11.25 9.75 11.586 9.75 12C9.75 12.414 10.086 12.75 10.5 12.75L19.19 12.75L16.719 15.219C16.426 15.512 16.426 15.988 16.719 16.281C17.012 16.574 17.488 16.574 17.781 16.281L21.531 12.531C21.671 12.39 21.751 12.199 21.751 12C21.751 11.801 21.671 11.61 21.531 11.469Z',
      true,
      false
    ),
  ],
  // Phosphor door-open (Regular)
  'ph-door-open': [
    (
      'M21.75 20.25L19.5 20.25L19.5 3.75C19.5 2.922 18.828 2.25 18 2.25L6 2.25C5.172 2.25 4.5 2.922 4.5 3.75L4.5 20.25L2.25 20.25C1.836 20.25 1.5 20.586 1.5 21C1.5 21.414 1.836 21.75 2.25 21.75L21.75 21.75C22.164 21.75 22.5 21.414 22.5 21C22.5 20.586 22.164 20.25 21.75 20.25ZM18 20.25L16.5 20.25L16.5 3.75L18 3.75ZM6 3.75L15 3.75L15 20.25L6 20.25ZM13.5 12.375C13.5 12.996 12.996 13.5 12.375 13.5C11.754 13.5 11.25 12.996 11.25 12.375C11.25 11.754 11.754 11.25 12.375 11.25C12.996 11.25 13.5 11.754 13.5 12.375Z',
      true,
      false
    ),
  ],
};

/// หน้าสำเร็จของการส่งต่อ (ทับลิ้นชัก F9) ภาษาเดียวกับบันทึกสำเร็จของ workflow ([_SaveBurst]) แต่เล่าด้วยแฟ้ม:
/// 1) สีเขียวแผ่จากปุ่มยืนยันจนเต็มลิ้นชัก 2) แฟ้มหมุนขึ้นมาจากด้านล่างช้า ๆ มาหยุดกลางจอ (เรียบ ไม่เด้ง)
/// 3) ตรา ✓ จางเข้ามาประทับมุมแฟ้ม + confetti 4) ข้อความ + ปุ่มกลับหน้ารายชื่อ นับถอยหลังแล้วปิดเอง
/// 5) ตอนปิด: ทุกอย่างจางออก
class _F9Success extends StatefulWidget {
  const _F9Success(
      {super.key,
      required this.name,
      required this.line,
      required this.by,
      required this.base,
      required this.onEnd});
  final String name, line, by;
  final TextStyle base;
  final VoidCallback onEnd;

  @override
  State<_F9Success> createState() => _F9SuccessState();
}

class _F9SuccessState extends State<_F9Success> with TickerProviderStateMixin {
  static const _wait = 6;
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3400));
  late final AnimationController _cd = AnimationController(
      vsync: this, duration: const Duration(seconds: _wait));
  // ตอนปิด: แฟ้มพุ่งออกขวา ข้อความจาง แล้วค่อยจบ
  late final AnimationController _out = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  final _confetti = Stopwatch();
  final _at = DateTime.now();
  bool _ended = false;

  @override
  void initState() {
    super.initState();
    _c
      ..addListener(() {
        if (!_confetti.isRunning && _c.value >= 0.84) {
          _confetti.start();
          HapticFeedback.mediumImpact();
        }
      })
      ..addStatusListener((st) {
        if (st == AnimationStatus.completed) _cd.forward();
      })
      ..forward();
    _cd.addStatusListener((st) {
      if (st == AnimationStatus.completed) _end();
    });
  }

  void _end() {
    if (_ended) return;
    _ended = true;
    _cd.stop();
    _out.forward().whenComplete(widget.onEnd);
  }

  @override
  void dispose() {
    _c.dispose();
    _cd.dispose();
    _out.dispose();
    super.dispose();
  }

  static double _seg(double v, double a, double b,
          [Curve c = Curves.easeOutCubic]) =>
      c.transform(((v - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) => GestureDetector(
        // กันแตะทะลุไปลิ้นชักข้างใต้
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: LayoutBuilder(builder: (context, box) {
          final w = box.maxWidth, h = box.maxHeight;
          final center = Offset(w / 2, h * 0.32);
          return AnimatedBuilder(
            animation: Listenable.merge([_c, _cd, _out]),
            builder: (context, _) {
              final t = _c.value;
              final out = Curves.easeInCubic.transform(_out.value);
              // แฟ้ม: หมุนขึ้นมาจากด้านล่างช้า ๆ มาหยุดกลางจอ (ไม่เด้ง ไม่บิน) พร้อมจางเข้า
              const side = 240.0;
              // เรื่องเดียวกับตอนเปิดลิ้นชัก: แฟ้มหมุนขึ้น กระดาษโผล่ในแฟ้มทีละแผ่น → แล้วเก็บลงแฟ้ม
              final story = _seg(t, 0.10, 0.64, Curves.linear);
              final tuck = _seg(t, 0.66, 0.82, Curves.easeInOutCubic);
              final fade = _seg(t, 0.12, 0.28) * (1.0 - out);
              final fx = center.dx - side / 2;
              final fy = center.dy -
                  side * 0.62 +
                  70.0 * (1.0 - _seg(t, 0.10, 0.40, Curves.easeOutCubic));
              // ตรา ✓: จางเข้า ขยายเล็กน้อย หมุนมาหยุด หลังแฟ้มนิ่ง
              final stamp = _seg(t, 0.80, 0.94);
              final label = _seg(t, 0.70, 0.88) * (1.0 - out);
              final act = Curves.easeOutCubic
                      .transform((_cd.value * 8.0).clamp(0.0, 1.0)) *
                  (1.0 - out);
              final left = (_wait * (1.0 - _cd.value)).ceil();
              TextStyle ts(double size, FontWeight wt, [double a = 1.0]) =>
                  widget.base.copyWith(
                      fontSize: size,
                      fontWeight: wt,
                      color: Colors.white.withValues(alpha: a),
                      decoration: TextDecoration.none);
              return Stack(children: [
                Positioned.fill(
                  child: CustomPaint(
                      painter: _F9GreenArt(
                          _seg(t, 0.0, 0.26, Curves.easeInOutCubic))),
                ),
                // แสงขาวนุ่มหลังแฟ้ม (ให้แฟ้มเด่นบนพื้นเขียว)
                Positioned(
                  left: center.dx - 170.0,
                  top: center.dy - 170.0,
                  width: 340.0,
                  height: 340.0,
                  child: Opacity(
                    opacity: fade,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          Color(0x55FFFFFF),
                          Color(0x22FFFFFF),
                          Color(0x00FFFFFF),
                        ], stops: [
                          0.0,
                          0.55,
                          1.0
                        ]),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                      painter: _SaveConfetti(
                          sec: _confetti.elapsedMilliseconds / 1000.0,
                          from: center,
                          clip: Offset.zero & Size(w, h))),
                ),
                Positioned(
                  left: fx,
                  top: fy,
                  width: side,
                  height: side,
                  child: Opacity(
                    opacity: fade,
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned.fill(
                        child: CustomPaint(
                            painter: _F9FolderPainter(
                                0.0, story, const _F9PaperData(),
                                calm: true, tuck: tuck)),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: const Alignment(0.78, 0.86),
                          child: Opacity(
                            opacity: stamp,
                            child: Transform.scale(
                              scale: 0.7 + 0.3 * stamp,
                              child: SizedBox.square(
                                dimension: side * 0.31,
                                child: FittedBox(
                                  child: _PeBadge25D(
                                      kind: 0,
                                      size: 36.0,
                                      tilt: -0.45 - 1.1 * (1.0 - stamp)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                Positioned(
                  left: 24.0,
                  right: 24.0,
                  top: center.dy + 120.0,
                  child: Opacity(
                    opacity: label,
                    child: Transform.translate(
                      offset: Offset(0.0, 8.0 * (1.0 - label)),
                      child: Column(children: [
                        Text('ส่งต่อผู้ป่วยเรียบร้อย',
                            textAlign: TextAlign.center,
                            style: ts(22.0, FontWeight.w700)),
                        const SizedBox(height: 10.0),
                        Text(widget.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ts(16.0, FontWeight.w700)),
                        const SizedBox(height: 2.0),
                        Text(widget.line,
                            textAlign: TextAlign.center,
                            style: ts(14.0, FontWeight.w600, 0.92)),
                        const SizedBox(height: 10.0),
                        Text(
                            '${widget.by}  เวลา ${_at.hour.toString().padLeft(2, '0')}:${_at.minute.toString().padLeft(2, '0')} น.',
                            textAlign: TextAlign.center,
                            style: ts(13.0, FontWeight.w500, 0.85)),
                      ]),
                    ),
                  ),
                ),
                // ปุ่มกลับหน้ารายชื่อ + นับถอยหลังปิดเอง (ขึ้นหลังเรื่องจบ)
                Positioned(
                  left: 20.0,
                  right: 20.0,
                  bottom: 28.0,
                  child: IgnorePointer(
                    ignoring: act < 0.5,
                    child: Opacity(
                      opacity: act,
                      child: Transform.translate(
                        offset: Offset(0.0, 16.0 * (1.0 - act)),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('กลับหน้ารายชื่อเองใน $left วินาที',
                              style: ts(13.0, FontWeight.w500, 0.9)),
                          const SizedBox(height: 10.0),
                          _Press(
                            child: GestureDetector(
                              onTap: _end,
                              child: Container(
                                height: 52.0,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Text('กลับหน้ารายชื่อผู้ป่วย',
                                    style: widget.base.copyWith(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E8E3E),
                                        decoration: TextDecoration.none)),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ]);
            },
          );
        }),
      );
}

/// พื้นเขียวของหน้าสำเร็จ: วงกลมแผ่จากปุ่มยืนยัน (ล่างกลาง) จนเต็มลิ้นชัก · สีชุดเดียวกับบันทึกสำเร็จของ workflow
class _F9GreenArt extends CustomPainter {
  _F9GreenArt(this.v);
  final double v;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.clipRect(r);
    final from = Offset(size.width / 2, size.height - 54.0);
    canvas.drawCircle(
      from,
      v * (size.height + size.width),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2FA352), Color(0xFF1E8E3E)],
        ).createShader(r),
    );
  }

  @override
  bool shouldRepaint(_F9GreenArt o) => o.v != v;
}
