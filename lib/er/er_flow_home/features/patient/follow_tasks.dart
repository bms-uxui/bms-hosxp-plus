// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientFollowTasksState on State<ErFlowHomeWidget> {
  /// งานที่ทำเสร็จแล้ว (ติ๊กในรายการ)
  final Set<String> _taskDone = {};
}

extension _FeaturesPatientFollowTasksPart on _ErFlowHomeWidgetState {
  /// widget งานที่ต้องติดตาม (หน้าภาพรวม): งานทุกแถวพร้อมปุ่มเตือน + นับถอยหลัง
  Widget _followWidget() => _detailBlock('งานที่ต้องติดตาม', [
        for (var i = 0; i < _followTasks.length; i++)
          _todoRow(_followTasks[i], last: i == _followTasks.length - 1),
      ]);

  /// แถวงานแบบ to-do: วงกลมติ๊ก · ชื่องาน + เวลา · ปุ่มไอคอน (เตือน / เปิดตรวจซ้ำ)
  Widget _todoRow(_Task t, {bool last = false, double pad = 9.0}) {
    final done = _taskDone.contains(t.title);
    return Container(
      padding: EdgeInsets.symmetric(vertical: pad),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(children: [
        _Press(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() =>
                  done ? _taskDone.remove(t.title) : _taskDone.add(t.title));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? _blue : Colors.transparent,
                border: Border.all(
                    color: done ? _blue : (t.urgent ? _red : _g5), width: 1.8),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 14.0, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(11.5,
                          color: done ? _ink3 : (t.urgent ? _red : _inkTitle),
                          weight: FontWeight.w600)
                      .copyWith(
                          decoration:
                              done ? TextDecoration.lineThrough : null)),
              Text(
                  done
                      ? 'เสร็จแล้ว'
                      : '${_clock(t.time)} · รอ ${_hm(t.waitMin)} · ${t.detail}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(9.5, color: _ink3)),
            ],
          ),
        ),
        if (!done) ...[
          const SizedBox(width: 6.0),
          _remBell(t.title),
          if (t.doctor) ...[
            const SizedBox(width: 4.0),
            _Press(
              child: Tooltip(
                message: 'เปิดตรวจซ้ำ',
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: () => setState(() => _detailTab = 2),
                  child: Container(
                    width: 26.0,
                    height: 26.0,
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(Icons.medical_services_outlined,
                        size: 15.0, color: _ink2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ]),
    );
  }

  /// แถบงานของพยาบาล (footer overlay): การ์ดงานเรียงแนวนอน เลื่อนซ้ายขวาได้
  /// แต่ละใบ = วงกลมติ๊ก · ชื่องาน/เวลารอ · ปุ่มตั้งเตือน
  Widget _nurseFooter() {
    final tasks = _followTasks.where((t) => !t.doctor).toList()
      ..sort((a, b) {
        final da = _taskDone.contains(a.title),
            db = _taskDone.contains(b.title);
        if (da != db) return da ? 1 : -1;
        if (a.urgent != b.urgent) return a.urgent ? -1 : 1;
        return b.waitMin.compareTo(a.waitMin);
      });
    final left = tasks.where((t) => !_taskDone.contains(t.title)).length;
    return Positioned(
      left: 12.0,
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
