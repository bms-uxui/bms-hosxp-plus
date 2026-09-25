// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientFollowTasksState on State<ErFlowHomeWidget> {
  /// งานที่ทำเสร็จแล้ว (ติ๊กในรายการ)
  final Set<String> _taskDone = {};

  /// งานที่เพิ่มระหว่างใช้งาน (เช่น ขอวัดสัญญาณชีพซ้ำ) ต่อ HN
  final Map<String, List<_Task>> _taskExtra = {};

  /// เคสที่เปิดดูผลแล็บใหม่ / คำสั่งแพทย์ใหม่แล้ว (HN) · จุดแดงหายเมื่อเปิดดู
  final Set<String> _labSeen = {};
  final Set<String> _orderSeen = {};

  /// เวลาที่ติ๊กว่าทำแล้ว
  final Map<String, DateTime> _taskDoneAt = {};

  /// ช่องงานที่ต้องติดตามในภาพรวม (bento) กางรายการไว้ตั้งแต่แรก
  bool _tasksOpen = true;
}

extension _FeaturesPatientFollowTasksPart on _ErFlowHomeWidgetState {
  /// งานทั้งหมดของเคสที่เปิดอยู่ = งานเดิม + งานที่ขอเพิ่ม
  List<_Task> get _allTasks => [
        ..._followTasks,
        ...?_taskExtra[_caseP().hn],
      ];

  /// คำขอวัดสัญญาณชีพซ้ำที่ยังไม่ได้ทำของเคสนี้ (null = ไม่มี)
  _Task? get _vsRecheck => _taskExtra[_caseP().hn]
      ?.where((t) =>
          t.title.startsWith('วัดสัญญาณชีพซ้ำ') && !_taskDone.contains(t.title))
      .firstOrNull;

  /// แพทย์ขอวัดสัญญาณชีพซ้ำ: เพิ่มเป็นงานด่วนของพยาบาล (ขึ้นบนสุดของงานที่ต้องติดตาม)
  void _requestVsRecheck() {
    final now = DateTime.now();
    final hm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final me = ErSession.instance.user?.name ?? 'แพทย์';
    setState(() {
      _taskExtra.putIfAbsent(_caseP().hn, () => []).add(_Task(
          'วัดสัญญาณชีพซ้ำ ($hm)',
          'แพทย์ขอวัดซ้ำ',
          Icons.monitor_heart_rounded,
          _blue,
          hm,
          0,
          urgent: true,
          by: me));
    });
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('ส่งคำขอวัดสัญญาณชีพซ้ำให้พยาบาลแล้ว',
            style: _t(12.0, color: Colors.white))));
  }

  /// ผลแล็บใหม่ที่ยังไม่เปิดดูของเคส (ว่าง = ไม่มีจุดแดง)
  Set<String> _labNewOf(String hn) =>
      _labSeen.contains(hn) ? const {} : erLabNew(erCaseOf(hn));

  /// มีคำสั่งแพทย์ใหม่ที่ยังไม่เปิดดู
  bool _orderNewOf(String hn) =>
      !_orderSeen.contains(hn) && erOrderNew(erCaseOf(hn)) > 0;

  /// เปิดแท็บแล้ว = เห็นของใหม่แล้ว (3 คำสั่งแพทย์ · 6 แล็บ)
  void _markSeen(String hn, int tab) {
    if (tab == 6) _labSeen.add(hn);
    if (tab == 3) _orderSeen.add(hn);
  }

  /// จุดแดงบอกว่ามีของใหม่ ขอบขาวให้แยกจากพื้น
  Widget _newDot([double size = 9.0]) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(color: _red.withValues(alpha: 0.4), blurRadius: 4.0),
            ],
          ),
        ),
      );

  /// เรียงงานอัตโนมัติ: ยังไม่ทำก่อน → ด่วนก่อน → สั่งก่อนขึ้นก่อน
  /// ทำแล้วลงล่างสุด (ทำล่าสุดอยู่บน)
  List<_Task> _sortTasks(Iterable<_Task> list) {
    final l = list.toList();
    int key(_Task t) => _taskDone.contains(t.title) ? 1 : 0;
    l.sort((a, b) {
      final d = key(a).compareTo(key(b));
      if (d != 0) return d;
      if (key(a) == 1) {
        final ta = _taskDoneAt[a.title], tb = _taskDoneAt[b.title];
        if (ta != null && tb != null) return tb.compareTo(ta);
      }
      if (a.urgent != b.urgent) return a.urgent ? -1 : 1;
      return a.time.compareTo(b.time);
    });
    return l;
  }

  /// widget งานที่ต้องติดตาม (หน้าภาพรวม): งานทุกแถวพร้อมปุ่มเตือน + นับถอยหลัง
  Widget _followWidget() {
    final tasks = _sortTasks(_allTasks);
    return _detailBlock('งานที่ต้องติดตาม', [
      for (var i = 0; i < tasks.length; i++)
        _todoRow(tasks[i], last: i == tasks.length - 1),
    ]);
  }

  /// สลับสถานะงาน ทำแล้ว ↔ ยังไม่ทำ
  void _taskToggle(_Task t) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_taskDone.remove(t.title)) {
        _taskDoneAt.remove(t.title);
      } else {
        _taskDone.add(t.title);
        _taskDoneAt[t.title] = DateTime.now();
      }
    });
  }

  /// แถวงานแบบ to-do: ไอคอนงาน · ชื่องาน + เวลา · เตือน · ปุ่มสถานะ (ยังไม่ทำ / ทำแล้ว)
  /// ยังไม่ทำ = ปุ่มขอบ "ทำเสร็จ" ให้กด · ทำแล้ว = แถวจาง ขีดฆ่า + ป้ายทึบ "เสร็จแล้ว"
  Widget _todoRow(_Task t, {bool last = false, double pad = 9.0}) {
    final done = _taskDone.contains(t.title);
    final at = _taskDoneAt[t.title];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: EdgeInsets.only(bottom: last ? 0.0 : 4.0),
      padding: EdgeInsets.fromLTRB(10.0, pad, 6.0, pad),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFE9ECF2) : Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
            color: done ? Colors.transparent : (t.urgent ? _red : _line)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _t(11.5,
                          color: done ? _ink3 : (t.urgent ? _red : _inkTitle),
                          weight: FontWeight.w600,
                          height: 1.25)
                      .copyWith(
                          decoration:
                              done ? TextDecoration.lineThrough : null)),
              Text(
                  done
                      ? 'เสร็จเมื่อ${at == null ? '' : ' ${_clock('${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}')}'}'
                      // งานวัดซ้ำตามรอบ: เวลาในงาน = เวลาที่ต้องวัด ไม่ใช่เวลาสั่ง
                      : t.detail.startsWith('รอบที่')
                          ? 'วัดเวลา ${_clock(t.time)} · ${t.detail} · โดย ${t.by}'
                          : 'สั่งเมื่อ ${_clock(t.time)} โดย ${t.by}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(9.5, color: _ink3)),
            ],
          ),
        ),
        if (!done) ...[
          const SizedBox(width: 4.0),
          _remBell(t.title),
          if (t.doctor)
            IconButton(
              tooltip: 'เปิดตรวจซ้ำ',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _detailTab = 2),
              icon: const Icon(Icons.medical_services_outlined,
                  size: 16.0, color: _ink2),
            ),
        ],
        const SizedBox(width: 6.0),
        // ปุ่มสถานะ: กดสลับได้ทั้งสองทาง
        _Press(
          child: GestureDetector(
            onTap: () => _taskToggle(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 28.0,
              padding: const EdgeInsets.symmetric(horizontal: 9.0),
              decoration: BoxDecoration(
                gradient: done ? _glossGrad(_blue) : _glossWhite,
                borderRadius: BorderRadius.circular(100.0),
                border: done ? null : Border.all(color: _blue, width: 1.2),
              ),
              foregroundDecoration: _InnerGloss(100.0, dark: done),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(done ? Icons.check_circle_rounded : Icons.check_rounded,
                    size: 14.0, color: done ? Colors.white : _blue),
                const SizedBox(width: 4.0),
                // ยังไม่ทำ = ปุ่มคำกริยา "ทำเสร็จ" · ทำแล้ว = สถานะ "เสร็จแล้ว" (แตะเพื่อยกเลิก)
                Text(done ? 'เสร็จแล้ว' : 'ทำเสร็จ',
                    style: _t(10.5,
                        color: done ? Colors.white : _blue,
                        weight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  /// แถบงานของพยาบาล (footer overlay): การ์ดงานเรียงแนวนอน เลื่อนซ้ายขวาได้
  /// แต่ละใบ = วงกลมติ๊ก · ชื่องาน/เวลารอ · ปุ่มตั้งเตือน
  Widget _nurseFooter() {
    final tasks = _allTasks.where((t) => !t.doctor).toList()
      ..sort((a, b) {
        final da = _taskDone.contains(a.title),
            db = _taskDone.contains(b.title);
        if (da != db) return da ? 1 : -1;
        if (a.urgent != b.urgent) return a.urgent ? -1 : 1;
        return b.waitMin.compareTo(a.waitMin);
      });
    final left = tasks.where((t) => !_taskDone.contains(t.title)).length;
    return Positioned(
      // ซ้ายเว้นให้ปุ่มแจ้งเตือน/ประวัติมุมซ้ายล่าง
      left: 76.0,
      right: 84.0,
      bottom: 12.0,
      height: 72.0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14.0, 8.0, 8.0, 8.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1F0B1B3F),
                blurRadius: 24.0,
                offset: Offset(0, 8)),
          ],
        ),
        child: Row(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.checklist_rounded, size: 15.0, color: _blue),
                const SizedBox(width: 5.0),
                Text('งานที่ต้องติดตาม',
                    style: _t(11.5, color: _inkTitle, weight: FontWeight.w700)),
              ]),
              Text(left == 0 ? 'เสร็จครบแล้ว' : 'เหลือ $left งาน',
                  style: _t(9.5, color: _ink3)),
            ],
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8.0),
              itemBuilder: (_, i) => SizedBox(
                width: 250.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  alignment: Alignment.center,
                  child: _todoRow(tasks[i], last: true, pad: 0.0),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /// การ์ดรายการงานแบบ to-do (ทุกงานอยู่ในการ์ดเดียว คั่นด้วยเส้น)
  Widget _todoCard(List<_Task> tasks) => Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: _line),
        ),
        child: Column(children: [
          for (var i = 0; i < tasks.length; i++)
            _todoRow(tasks[i], last: i == tasks.length - 1),
        ]),
      );
}
