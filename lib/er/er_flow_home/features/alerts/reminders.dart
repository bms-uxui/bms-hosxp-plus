// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

String _mmss(Duration d) {
  if (d.isNegative) return 'ถึงเวลา';
  final m = d.inMinutes, sec = d.inSeconds % 60;
  return m >= 60
      ? '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')} ชม.'
      : '$m:${sec.toString().padLeft(2, '0')}';
}

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesAlertsRemindersState on State<ErFlowHomeWidget> {
  // ------------------------------------------ การเตือนคำสั่งแพทย์ / หัตถการ
  // ตั้งเวลาที่ต้องกลับไปดูผู้ป่วย นับถอยหลังบนรายการ ถึงเวลาแล้วเด้งเตือน
  // (เสียง + สั่น) ทุกหน้า พร้อมปุ่มไปหาผู้ป่วย / เลื่อน 5 นาที

  final List<_Reminder> _reminders = [];
  Timer? _remTimer;

  /// เดินทุกวินาที: อัปเดตแค่ป้ายนับถอยหลัง (ไม่ rebuild ทั้งหน้า)
  final ValueNotifier<int> _remTick = ValueNotifier(0);

  /// การเตือนวิกฤตที่ส่งเป็นแจ้งเตือนระบบไปแล้ว (key → ไม่ส่งซ้ำ)
  final Set<String> _notified = {};
}

extension _FeaturesAlertsRemindersPart on _ErFlowHomeWidgetState {
  void _remCheck() {
    _remTick.value++;
    _notifySync();
    final now = DateTime.now();
    var fired = false;
    for (final r in _reminders) {
      if (!r.fired && !now.isBefore(r.due)) {
        r.fired = true;
        fired = true;
      }
    }
    if (fired && mounted) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
      setState(() {});
    }
  }

  /// ส่งการเตือนวิกฤตใบใหม่เป็นแจ้งเตือนระบบ · ใบที่รับทราบแล้วเอาออกจากแถบ
  void _notifySync() {
    final now = <String>{};
    for (final a in _allAlerts) {
      if (a.level != _Level.critical) continue;
      final k = '${a.key}|${a.title}';
      now.add(k);
      if (_notified.add(k)) {
        ErNotify.show(k, a.title, a.detail, hn: a.hn);
      }
    }
    for (final k in _notified.difference(now).toList()) {
      _notified.remove(k);
      ErNotify.cancel(k);
    }
  }

  /// แตะแจ้งเตือนระบบ: เปิดผู้ป่วยที่แท็บคำสั่งแพทย์ · ไม่มี HN เปิดรายการแจ้งเตือน
  void _notifyOpen(String hn) {
    if (!mounted) return;
    final a = _allAlerts
        .where((x) => x.hn == hn && x.level == _Level.critical)
        .firstOrNull;
    if (a != null) {
      _alertGo(a);
    } else {
      setState(() {
        _alertsOpen = true;
        _filter = _Level.critical;
      });
    }
  }

  _Reminder? _remOf(String title) {
    final hn = _caseP().hn;
    for (final r in _reminders) {
      if (r.hn == hn && r.title == title && !r.done) return r;
    }
    return null;
  }

  void _remSet(String hn, String title, int minutes) {
    setState(() {
      _reminders.removeWhere((r) => r.hn == hn && r.title == title);
      _reminders.add(
          _Reminder(hn, title, DateTime.now().add(Duration(minutes: minutes))));
    });
    HapticFeedback.selectionClick();
  }

  void _remDone(_Reminder r) => setState(() => r.done = true);

  /// ปุ่มกระดิ่งในแถวคำสั่ง: ยังไม่ตั้ง = เลือกเวลา · ตั้งแล้ว = ป้ายนับถอยหลัง
  Widget _remBell(String title) {
    final hn = _caseP().hn;
    final r = _remOf(title);
    return MenuAnchor(
      alignmentOffset: const Offset(-120.0, 4.0),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(_panel),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 4.0),
          child: Text(r == null ? 'เตือนให้กลับมาดูใน' : 'เตือนอยู่ · $title',
              style: _t(10.0, color: _ink3, weight: FontWeight.w600)),
        ),
        if (r == null)
          for (final m in const [5, 15, 30, 60])
            MenuItemButton(
              leadingIcon:
                  const Icon(Icons.alarm_add_rounded, size: 17.0, color: _blue),
              onPressed: () => _remSet(hn, title, m),
              child: Text(m == 60 ? '1 ชั่วโมง' : '$m นาที',
                  style: _t(12.0, weight: FontWeight.w600)),
            )
        else ...[
          MenuItemButton(
            leadingIcon:
                const Icon(Icons.more_time_rounded, size: 17.0, color: _blue),
            onPressed: () => setState(() {
              r.due = (r.due.isBefore(DateTime.now()) ? DateTime.now() : r.due)
                  .add(const Duration(minutes: 5));
              r.fired = false;
            }),
            child:
                Text('เพิ่ม 5 นาที', style: _t(12.0, weight: FontWeight.w600)),
          ),
          MenuItemButton(
            leadingIcon:
                const Icon(Icons.alarm_off_rounded, size: 17.0, color: _red),
            onPressed: () => _remDone(r),
            child: Text('ยกเลิกการเตือน',
                style: _t(12.0, color: _red, weight: FontWeight.w600)),
          ),
        ],
      ],
      builder: (_, menu, __) => _Press(
        child: GestureDetector(
          onTap: () => menu.isOpen ? menu.close() : menu.open(),
          child: r == null
              ? Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.alarm_add_rounded,
                      size: 15.0, color: _ink2),
                )
              : ValueListenableBuilder<int>(
                  valueListenable: _remTick,
                  builder: (_, __, ___) {
                    final left = r.due.difference(DateTime.now());
                    final due = left.isNegative;
                    final soon = left.inSeconds < 120;
                    final col = due ? _red : (soon ? _blue : _blue);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: due ? _red : col.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(due ? Icons.alarm_on_rounded : Icons.alarm_rounded,
                            size: 13.0, color: due ? Colors.white : col),
                        const SizedBox(width: 3.0),
                        Text(_mmss(left),
                            style: _num(10.0,
                                color: due ? Colors.white : col,
                                weight: FontWeight.w700)),
                      ]),
                    );
                  },
                ),
        ),
      ),
    );
  }

  /// การ์ดรวมการเตือนของผู้ป่วยรายนี้ (คอลัมน์งานที่ต้องติดตาม)
  Widget _remListCard() {
    final hn = _caseP().hn;
    final list = [
      for (final r in _reminders)
        if (r.hn == hn && !r.done) r
    ]..sort((a, b) => a.due.compareTo(b.due));
    if (list.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 6.0),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.alarm_rounded, size: 15.0, color: _blue),
            const SizedBox(width: 6.0),
            Text('การเตือน',
                style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
            const Spacer(),
            Text('${list.length} รายการ', style: _t(10.0, color: _ink3)),
          ]),
          const SizedBox(height: 4.0),
          for (final r in list)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(children: [
                Expanded(
                  child: Text(r.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(11.0, color: _inkTitle, weight: FontWeight.w600)),
                ),
                const SizedBox(width: 6.0),
                _remBell(r.title),
              ]),
            ),
        ],
      ),
    );
  }
}
