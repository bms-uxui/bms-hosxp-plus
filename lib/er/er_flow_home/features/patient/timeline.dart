// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesPatientTimelineState on State<ErFlowHomeWidget> {
  /// ลิ้นชักเส้นเวลาในหน้ารายละเอียด เปิดจากปุ่มบนแถบบน
  bool _timelineOpen = false;
}

extension _FeaturesPatientTimelinePart on _ErFlowHomeWidgetState {
  /// ลิ้นชักเส้นเวลาเหตุการณ์ เลื่อนเข้ามาจากขอบขวา
  Widget _detailTimeline() => Container(
        width: 268.0,
        padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 12.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('ประวัติการบันทึก',
                    style: _t(13.0, color: _inkTitle, weight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _timelineOpen = false),
                  icon: const Icon(Icons.close_rounded, size: 18.0),
                  color: _ink2,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'ปิด',
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (var i = 0; i < _case.events.length; i++)
                    _timelineRow(
                        _Ev(_case.events[i].time, _case.events[i].text,
                            byDoctor: _case.events[i].byDoctor),
                        last: i == _case.events.length - 1),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _timelineRow(_Ev e, {bool last = false}) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      e.byDoctor ? _blue.withValues(alpha: 0.15) : _panelSoft,
                ),
                child: Icon(
                    e.byDoctor
                        ? Icons.medical_services_rounded
                        : Icons.vaccines_rounded,
                    size: 14.0,
                    color: e.byDoctor ? _blue : _ink2),
              ),
              if (!last) Container(width: 1.5, height: 30.0, color: _line),
            ],
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_clock(e.time), style: _num(9.5, color: _ink3)),
                  Text(e.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(10.5, weight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      );
}
