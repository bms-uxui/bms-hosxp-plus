// ignore_for_file: invalid_use_of_protected_member
part of '../../er_flow_home_widget.dart';

/// state ของส่วนนี้ (ใช้ได้ทั้ง library ผ่าน _ErFlowHomeWidgetState)
mixin _FeaturesAlertsAlertsState on State<ErFlowHomeWidget> {
  /// ตัวกรองการแจ้งเตือนในแผงซ้าย null = ทุกระดับ
  _Level? _filter;

  /// การ์ดแจ้งเตือนด้านขวา เปิดจากปุ่มกระดิ่งมุมขวาบน
  bool _alertsOpen = false;

  /// เวลาของใบวิกฤตที่ปัดทิ้งไปแล้ว ไม่ต้องเด้งเป็น toast ซ้ำ
  final Set<String> _toastGone = {};
}

extension _FeaturesAlertsAlertsPart on _ErFlowHomeWidgetState {
  // ------------------------------------------------------------ แจ้งเตือน
  /// ชิปกรองระดับการแจ้งเตือน กดซ้ำที่ตัวเดิมเพื่อกลับไปดูทั้งหมด
  Widget _filterChip(String label, _Level? level) {
    final active = _filter == level;
    return _Press(
        child: Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Material(
        // อยู่บนพื้นการ์ดขาว ตัวที่เลือกจึงต้องเป็นพื้นทึบตัวอักษรขาว
        // "ทั้งหมด" ไม่มีสีประจำระดับ ใช้สีหลักแทน
        color: active ? (level?.color ?? _blue) : _panelSoft,
        borderRadius: BorderRadius.circular(100.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _filter = active ? null : level),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(label,
                style: _t(10.5,
                    color: active ? Colors.white : _ink2,
                    weight: active ? FontWeight.w600 : FontWeight.w400)),
          ),
        ),
      ),
    ));
  }

  /// ป้ายทางด่วนเฉพาะโรค — ตัวอักษรบนพื้นจางสีเดียวกัน
  /// onDark = อยู่บนแผงสีหลัก ต้องดันสีให้สว่างพอ
  Widget _typeBadge(_Ptype t, {bool onDark = false, double size = 9.0}) {
    final c = onDark ? _onDark(t.color) : t.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size * 0.7, vertical: 1.0),
      decoration: BoxDecoration(
        color: c.withValues(alpha: onDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child:
          Text(t.label, style: _num(size, color: c, weight: FontWeight.w700)),
    );
  }

  /// ป้ายระดับการแจ้งเตือน ทุกระดับหน้าตาเดียวกัน
  /// พื้นจางสีประจำระดับ + จุดสีทึบ + คำกำกับ ต่างกันแค่สี
  Widget _levelBadge(_Level level) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.5),
        decoration: BoxDecoration(
          color: level.color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.0,
              height: 6.0,
              decoration:
                  BoxDecoration(color: level.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5.0),
            Text(level.label,
                style: _t(9.5, color: level.color, weight: FontWeight.w600)),
          ],
        ),
      );

  /// แถวการแจ้งเตือนหนึ่งรายการ
  ///
  /// คั่นด้วยเส้นชุดเดียวกับรายชื่อผู้ป่วย ไม่ใช่การ์ดแยกใบ
  /// สองคอลัมน์: ป้ายระดับกับเรื่อง · เวลา
  /// ป้ายระดับวางบรรทัดบนของคอลัมน์ข้อความ ไม่ลงพื้นสีทั้งแถว
  /// ทุกระดับใช้ป้ายทรงเดียวกัน ต่างกันที่สีเท่านั้น
  Widget _alertRow(_Alert a) {
    return _Press(
        scale: 0.98,
        child: GestureDetector(
            onTap: a.hn == null ? null : () => _alertGo(a),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0.0, 11.0, 0.0, 11.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _line)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ป้ายระดับอยู่คอลัมน์เดียวกับข้อความ วางนำหน้าหัวเรื่องในบรรทัดแรก
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ป้ายระดับอยู่บรรทัดบนของคอลัมน์เดียวกับหัวเรื่อง
                          _levelBadge(a.level),
                          const SizedBox(height: 4.0),
                          Text(a.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _t(12.0,
                                  color: _ink,
                                  weight: FontWeight.w600,
                                  height: 1.25)),
                          const SizedBox(height: 2.0),
                          Text(a.detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _t(10.5, color: _ink2)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // คอลัมน์ 3 เวลาที่เกิดเหตุ ชิดขวาให้ตรงคอลัมน์เวลาของรายชื่อผู้ป่วย
                    Text(_clock(a.time),
                        style:
                            _num(11.0, color: _ink3, weight: FontWeight.w600)),
                  ],
                ),
              ),
            )));
  }

  /// การแจ้งเตือนระดับแอป: การเตือนคำสั่ง/หัตถการที่ถึงเวลา + เหตุการณ์ของห้อง
  List<_Alert> get _allAlerts => [
        for (final r in _reminders)
          if (r.fired && !r.done)
            _Alert(
              '${r.due.hour.toString().padLeft(2, '0')}:${r.due.minute.toString().padLeft(2, '0')}',
              'ถึงเวลา: ${r.title}',
              () {
                final p = _patients.where((x) => x.hn == r.hn).firstOrNull;
                return p == null
                    ? 'HN ${r.hn} · กลับไปดูผู้ป่วย'
                    : '${p.name} · เตียง ${p.bed ?? '—'} · กลับไปดูผู้ป่วย';
              }(),
              _Level.critical,
              id: 'rem:${r.hn}:${r.title}:${r.due.millisecondsSinceEpoch}',
              hn: r.hn,
            ),
        ..._alerts,
      ];

  /// แตะการเตือนของผู้ป่วย: รับทราบ แล้วเปิดหน้าผู้ป่วยที่แท็บคำสั่งแพทย์
  void _alertGo(_Alert a) {
    final p = _patients.where((x) => x.hn == a.hn).firstOrNull;
    for (final r in _reminders) {
      if (r.hn == a.hn && r.fired && !r.done && a.title.endsWith(r.title)) {
        _remDone(r);
      }
    }
    setState(() => _alertsOpen = false);
    if (p == null) return;
    _openPatient(p);
    setState(() => _detailTab = 3);
  }

  /// การ์ดแจ้งเตือนลอยใต้ปุ่มกระดิ่ง
  ///
  /// ย้ายออกจากแผงซ้ายเพราะเป็นของที่ดูเป็นครั้ง ไม่ใช่ของที่ต้องเห็นตลอด
  /// เป็นการ์ดลอย ไม่ใช่แผงที่กินความกว้าง ฉากจึงไม่ต้องหุบทุกครั้งที่เปิดดู
  Widget _alertCardOverlay() {
    final all = _allAlerts;
    final list =
        _filter == null ? all : all.where((a) => a.level == _filter).toList();
    return Container(
      width: 352.0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 28.0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 14.0, 10.0, 8.0),
            child: Row(
              children: [
                Text('การแจ้งเตือน',
                    style: _t(15.0, color: _inkTitle, weight: FontWeight.w700)),
                const SizedBox(width: 8.0),
                Text('${list.length} รายการ', style: _t(10.5, color: _ink3)),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _alertsOpen = false),
                  icon: const Icon(Icons.close_rounded, size: 20.0),
                  color: _ink2,
                  tooltip: 'ปิด',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              runSpacing: 6.0,
              children: [
                _filterChip('ทั้งหมด', null),
                for (final l in _Level.values) _filterChip(l.label, l),
              ],
            ),
          ),
          const SizedBox(height: 6.0),
          Flexible(
            child: list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text('ไม่มีการแจ้งเตือนในระดับนี้',
                          style: _t(11.0, color: _ink3)),
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                    children: [for (final a in list) _alertRow(a)],
                  ),
          ),
        ],
      ),
    );
  }

  /// toast ของใบระดับวิกฤต เด้งค้างไว้ข้างขวาจนกว่าจะปิดหรือกดดู
  ///
  /// ใบวิกฤตรอให้คนเปิดกระดิ่งไม่ได้ ต้องสะดุดตาเองโดยไม่บังฉากทั้งจอ
  /// ปิดการ์ดแจ้งเตือนอยู่ถึงจะเด้ง เปิดอยู่แล้วก็เห็นในรายการแล้ว
  Widget _alertToasts() {
    final hot = _allAlerts
        .where((a) => a.level == _Level.critical && !_toastGone.contains(a.key))
        .toList();
    if (hot.isEmpty || _alertsOpen) return const SizedBox.shrink();
    // ซ้อนเป็นตั้งเหมือนกระดาษวางทับกัน ใบหน้าสุดอ่านได้เต็ม
    // ใบที่เหลือโผล่แค่ขอบล่าง พอบอกว่ายังมีอีกโดยไม่กินพื้นที่ฉาก
    final behind = (hot.length - 1).clamp(0, 2);
    return SizedBox(
      width: 266.0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          for (var i = behind; i >= 1; i--)
            Positioned(
              left: i * 9.0,
              right: i * 9.0,
              bottom: -i * 7.0,
              child: Container(
                height: 30.0,
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: _red.withValues(alpha: 0.22)),
                  boxShadow: [
                    BoxShadow(
                      color: _red.withValues(alpha: 0.10),
                      blurRadius: 14.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          _toastCard(hot.first, more: hot.length - 1),
        ],
      ),
    );
  }

  /// การ์ด toast หนึ่งใบ — สองบรรทัด ป้ายระดับกับเวลาอยู่บน เรื่องอยู่ล่าง
  ///
  /// วางเรียงแนวนอนแล้วการ์ดยาวเกินไป กินฉากทั้งแถบ
  /// รายละเอียดอื่นอยู่ในรายการแจ้งเตือน แตะที่การ์ดเพื่อเปิด
  Widget _toastCard(_Alert a, {int more = 0}) => _Press(
      scale: 0.98,
      child: Container(
        width: 266.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: [
            BoxShadow(
              color: _red.withValues(alpha: 0.28),
              blurRadius: 18.0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: _red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => a.hn != null
                ? _alertGo(a)
                : setState(() {
                    _alertsOpen = true;
                    _filter = _Level.critical;
                  }),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Text(a.level.label,
                          style: _t(10.0,
                              color: Colors.white, weight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8.0),
                    Text(_clock(a.time),
                        style: _num(10.0,
                            color: Colors.white.withValues(alpha: 0.85),
                            weight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _toastGone.add(a.key)),
                      child: const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: Icon(Icons.close_rounded,
                            size: 15.0, color: Colors.white),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8.0),
                  Text(a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0,
                          color: Colors.white,
                          weight: FontWeight.w600,
                          height: 1.3)),
                ],
              ),
            ),
          ),
        ),
      ));

  /// ปุ่มกระดิ่งมุมขวาบน ตัวเลขคือจำนวนใบระดับวิกฤตที่ยังค้าง
  Widget _alertBell() {
    final hot = _allAlerts.where((a) => a.level == _Level.critical).length;
    return Material(
      color: _panel,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        onTap: () => setState(() => _alertsOpen = !_alertsOpen),
        child: SizedBox(
          width: 42.0,
          height: 42.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                  _alertsOpen
                      ? Icons.notifications_rounded
                      : Icons.notifications_none_rounded,
                  size: 22.0,
                  color: _blue),
              if (hot > 0)
                Positioned(
                  right: 8.0,
                  top: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 1.0),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(color: _panel, width: 1.5),
                    ),
                    child: Text('$hot',
                        style: _num(8.5,
                            color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
