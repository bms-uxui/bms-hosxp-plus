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
}

extension _FeaturesPatientF9DrawerPart on _ErFlowHomeWidgetState {
  static const List<String> _f9Rooms = [
    'ห้องตรวจฉุกเฉิน',
    'ห้องสังเกตอาการ',
    'ห้องเอกซเรย์',
    'ห้องยา',
    'การเงิน',
    'กลับบ้าน',
    'Admit (หอผู้ป่วย)',
    'Refer',
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
    if (!_detail || _open == null) return;
    if (_f9Open) {
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
    });
  }

  void _f9Close() => setState(() => _f9Open = false);

  void _f9Confirm() {
    final p = _sceneSelected(_open!);
    final next = _f9Stage;
    final to = next?.label ?? 'ออกจากห้องฉุกเฉิน';
    HapticFeedback.mediumImpact();
    final i = _patients.indexWhere((x) => x.hn == p.hn);
    if (i < 0) return;
    if (_speechOpen) _closeSpeech();
    if (next == null) {
      // ออกจาก ER: เอาออกจากรายชื่อ กลับหน้าช่วงงานเดิม
      _patients.removeAt(i);
      setState(() {
        _f9Open = false;
        _detail = false;
        _timelineOpen = false;
        _sceneHn = null;
      });
    } else {
      _patients[i] = _P(p.hn, p.name, next, 0,
          esi: p.esi, bed: p.bed, note: _f9Room, type: p.type);
      setState(() {
        _f9Open = false;
        _open = _Phase.of(next);
        _sceneHn = p.hn;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ส่งต่อ ${p.name} → $_f9Room · $to แล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  Widget _f9Label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Text(t, style: _t(11.0, color: _ink2, weight: FontWeight.w600)),
      );

  Widget _f9Select<T>(
      String label, T value, List<(T, String)> opts, ValueChanged<T> on) {
    final cur = opts.firstWhere((o) => o.$1 == value, orElse: () => opts.first);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _f9Label(label),
        PopupMenuButton<int>(
          tooltip: label,
          position: PopupMenuPosition.under,
          color: _panel,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          onSelected: (i) => setState(() => on(opts[i].$1)),
          itemBuilder: (_) => [
            for (var i = 0; i < opts.length; i++)
              PopupMenuItem(
                value: i,
                height: 40.0,
                child: Row(children: [
                  Expanded(
                    child: Text(opts[i].$2,
                        style: _t(12.5,
                            color: opts[i].$1 == value ? _blue : _ink,
                            weight: opts[i].$1 == value
                                ? FontWeight.w700
                                : FontWeight.w500)),
                  ),
                  if (opts[i].$1 == value)
                    const Icon(Icons.check_rounded, size: 16.0, color: _blue),
                ]),
              ),
          ],
          child: Container(
            height: 44.0,
            padding: const EdgeInsets.only(left: 12.0, right: 8.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: _line),
            ),
            child: Row(children: [
              Expanded(
                child: Text(cur.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w600)),
              ),
              const Icon(Icons.expand_more_rounded, size: 18.0, color: _ink3),
            ]),
          ),
        ),
      ],
    );
  }

  /// ช่องตัวเลขสรุป (เงินรอชำระ · รายการยา)
  Widget _f9Stat(String label, String value, String unit,
          {bool alert = false}) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 12.0),
          decoration: BoxDecoration(
            color: _panelSoft,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: _line),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: _t(10.5, color: _ink3)),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value,
                        style: _num(22.0,
                            color: alert ? _red : _inkTitle,
                            weight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 4.0),
                Text(unit, style: _t(11.0, color: _ink3)),
              ],
            ),
          ]),
        ),
      );

  Widget _f9DrawerPanel() {
    if (_open == null) return const SizedBox(width: 360.0);
    final p = _sceneSelected(_open!);
    final c = erCaseOf(p.hn);
    final amount = _f9Amount(c);
    final drugs = c.meds.length;
    return Container(
      width: 360.0,
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 12.0, 14.0),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Text('ส่งต่อผู้ป่วย',
                style: _t(14.0, color: _inkTitle, weight: FontWeight.w700)),
          ),
          IconButton(
            onPressed: _f9Close,
            icon: const Icon(Icons.close_rounded, size: 18.0),
            color: _ink2,
          ),
        ]),
        Text('${p.name} · HN ${p.hn}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _t(11.5, color: _ink2, weight: FontWeight.w600)),
        Text('สิทธิ ${c.right} · ขั้นปัจจุบัน ${p.stage.label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _t(10.5, color: _ink3)),
        const SizedBox(height: 16.0),
        Expanded(
          child: ListView(children: [
            _f9Select<String>('ส่งต่อห้อง', _f9Room,
                [for (final r in _f9Rooms) (r, r)], (v) => _f9Room = v),
            const SizedBox(height: 12.0),
            _f9Select<_Stage?>(
                'สถานะ',
                _f9Stage,
                [
                  for (final s in _Stage.values) (s, s.label),
                  (null, 'ออกจากห้องฉุกเฉิน'),
                ],
                (v) => _f9Stage = v),
            if (p.stage == _Stage.triage && p.esi == null) ...[
              const SizedBox(height: 10.0),
              Row(children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16.0, color: _red),
                const SizedBox(width: 6.0),
                Text('ยังไม่ได้ระดับ ESI', style: _t(11.5, color: _red)),
              ]),
            ],
            const SizedBox(height: 18.0),
            Row(children: [
              _f9Stat('จำนวนเงินรอทำรายการชำระ', _money(amount), 'บาท',
                  alert: amount > 0),
              const SizedBox(width: 10.0),
              _f9Stat('จำนวนรายการยา', '$drugs', 'รายการ'),
            ]),
          ]),
        ),
        _navBtn('ยืนยัน (F9)', Icons.check_rounded, _f9Confirm),
      ]),
    );
  }
}
