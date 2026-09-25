// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

String _clockWait(int m) => m >= 60 ? '${m ~/ 60} ชม. ${m % 60} น.' : '$m นาที';

/// นาฬิกาจำลองของฉาก (ข้อมูล mock อิงเวลานี้)
const String _simNow = '10:25';
int _minutesSince(String hhmm) {
  int toMin(String t) {
    final p = t.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  return (toMin(_simNow) - toMin(hhmm)).clamp(0, 24 * 60);
}

extension _FeaturesPatientPatientHeaderPart on _ErFlowHomeWidgetState {
  Widget _detailTopBar() {
    final p = _sceneSelected(_open!);
    final c = erCaseOf(p.hn);
    // แบบ ClyHealth: ซ้าย = กลับ + ชื่อ · กลาง = กลุ่มแท็บแบบเม็ดยา · ขวา = ปุ่มไอคอน
    return Container(
      height: _clyOn ? 58.0 : 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      decoration: BoxDecoration(
        color: _panel,
        border: _clyOn ? const Border(bottom: BorderSide(color: _line)) : null,
      ),
      child: Row(
        children: [
          _topIcon(
              Icons.arrow_back_rounded,
              false,
              () => setState(() {
                    _detail = false;
                    _timelineOpen = false;
                  })),
          const SizedBox(width: 10.0),
          if (_clyOn)
            Expanded(child: _profileHeader(p, c))
          else ...[
            SizedBox(
              width: 150.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          _t(12.5, color: _inkTitle, weight: FontWeight.w600)),
                  Text('${c.age} ปี · เตียง ${p.bed ?? '—'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(10.0, color: _ink3)),
                ],
              ),
            ),
          ],
          // แท็บอยู่ในการ์ดขวาแล้ว · หน้าสรุป AI ยังแสดงบนแถบบน
          if (!_clyOn)
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: _clyOn ? _cyGlass : _panelSoft,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: _clyOn ? _cyEdge : _panelSoft),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      for (var i = 0; i < _detailTabs.length; i++)
                        _detailTabItem(i),
                    ]),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 10.0),
          Stack(clipBehavior: Clip.none, children: [
            _topIcon(Icons.notifications_none_rounded, _alertsOpen,
                () => setState(() => _alertsOpen = !_alertsOpen)),
            if (_allAlerts.any((a) => a.level == _Level.critical))
              Positioned(
                right: -3.0,
                top: -3.0,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    constraints: const BoxConstraints(minWidth: 16.0),
                    height: 16.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                        '${_allAlerts.where((a) => a.level == _Level.critical).length}',
                        style: _num(9.0,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
              ),
          ]),
          const SizedBox(width: 8.0),
          _topIcon(
              Icons.auto_awesome_outlined,
              _summaryOpen,
              () => _summaryOpen
                  ? setState(() => _summaryOpen = false)
                  : _openSummary()),
          const SizedBox(width: 8.0),
          _topIcon(Icons.history_rounded, _timelineOpen,
              () => setState(() => _timelineOpen = !_timelineOpen)),
          const SizedBox(width: 8.0),
          _topIcon(Icons.check_rounded, true, () {}),
        ],
      ),
    );
  }

  /// แถบบนแบบโปรไฟล์ผู้ป่วย: รูป · ชื่อ ESI · ข้อมูลพื้นฐาน + อาการสำคัญ · ค่าสำคัญ
  Widget _profileHeader(_P p, ErCase c) {
    final meta = '${c.age} ปี  ·  HN ${p.hn}  ·  เตียง ${p.bed ?? '—'}';
    // GCS แบบย่อ E4V5M6 = 15 จากข้อความเต็ม
    String gcs() {
      final g = c.gcs;
      if (g == null) return '—';
      final m = RegExp(r'([EVM])(\d)').allMatches(g).toList();
      if (m.length < 3) return g;
      final sum = m.fold<int>(0, (a, x) => a + int.parse(x.group(2)!));
      return '$sum  (${m.map((x) => x.group(0)).join(' ')})';
    }

    final facts = [
      (
        'แพ้ยา / อาหาร',
        c.allergies.isEmpty ? 'ไม่มี' : c.allergies.join(', '),
        c.allergies.isNotEmpty
      ),
      (
        'โรคประจำตัว',
        c.underlying.isEmpty ? 'ไม่มี' : c.underlying.join(', '),
        false
      ),
      ('GCS', gcs(), false),
      ('อยู่ใน ER', _hm(p.waitMin), false),
    ];
    Widget fact((String, String, bool) f) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(f.$1, style: _t(9.0, color: f.$3 ? _red : _ink3)),
            Text(f.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(11.0,
                    color: f.$3 ? _red : _inkTitle, weight: FontWeight.w600)),
          ],
        );
    return Row(children: [
      // รูป + เพศที่มุมขวาล่าง
      Tooltip(
        message: c.sex,
        child: Stack(clipBehavior: Clip.none, children: [
          ClipOval(
            child: Image.asset(_faceUrl(p.hn),
                width: 38.0, height: 38.0, fit: BoxFit.cover),
          ),
          Positioned(
            right: -3.0,
            bottom: -3.0,
            child: Container(
              width: 17.0,
              height: 17.0,
              decoration: BoxDecoration(
                gradient: _glossGrad(_blue),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              foregroundDecoration: const _InnerGloss(100.0, dark: true),
              child: Icon(
                  c.sex.contains('หญิง')
                      ? Icons.female_rounded
                      : Icons.male_rounded,
                  size: 11.0,
                  color: Colors.white),
            ),
          ),
        ]),
      ),
      const SizedBox(width: 10.0),
      Expanded(
        flex: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Flexible(
                child: Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t(13.5, color: _inkTitle, weight: FontWeight.w600)),
              ),
              if (p.esi != null) ...[
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    gradient: _glossGrad(p.esi!.color),
                    borderRadius: BorderRadius.circular(100.0),
                    boxShadow: _glossLift(p.esi!.color),
                  ),
                  foregroundDecoration: const _InnerGloss(100.0, dark: true),
                  child: Text('ESI ${p.esi!.level} · ${p.esi!.label}',
                      style: _t(9.5,
                          color: Colors.white, weight: FontWeight.w600)),
                ),
              ],
            ]),
            const SizedBox(height: 1.0),
            Text(meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(10.0, color: _ink2)),
          ],
        ),
      ),
      Container(
        width: 1.0,
        height: 30.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        color: _line,
      ),
      Expanded(
        flex: 6,
        child: Row(children: [
          for (var k = 0; k < facts.length; k++) ...[
            if (k > 0) const SizedBox(width: 12.0),
            Expanded(flex: k < 2 ? 3 : 2, child: fact(facts[k])),
          ],
        ]),
      ),
    ]);
  }

  /// ปุ่มไอคอนกลมบนแถบบน (on = พื้นสีหลัก)
  Widget _topIcon(IconData icon, bool on, VoidCallback onTap) => _Press(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 34.0,
            height: 34.0,
            decoration: BoxDecoration(
              gradient: on ? _glossGrad(_blue) : _glossWhite,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: on ? _blue : _line),
              boxShadow: _glossLift(on ? _blue : const Color(0xFF0B1B3F)),
            ),
            foregroundDecoration: _InnerGloss(10.0, dark: on),
            child: Icon(icon, size: 18.0, color: on ? Colors.white : _cySlate),
          ),
        ),
      );
}
