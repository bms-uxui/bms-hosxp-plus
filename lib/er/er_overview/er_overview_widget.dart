/// หน้าภาพรวมของโมดูล ER ตามแบบใน Figma (node 96-1343)
///
/// โครงหน้าแบ่งสามคอลัมน์
///   - แถบเมนูซ้ายสุด 83px
///   - แผงสรุป 486px  : หัวข้อ · การ์ดตัวเลข 4 ใบ · กราฟรายชั่วโมง · การแจ้งเตือน
///   - พื้นที่ขวา      : แท็บกระแสงาน · หัวข้อ ER Workflow · ฉากสามมิติ · แถบสรุปล่าง
///
/// รอบนี้ลงเฉพาะเลย์เอาต์ ช่องฉากสามมิติเว้นไว้ก่อน (ดู [_scenePlaceholder])
/// ข้อมูลทั้งหมดยังเป็นข้อมูลจำลอง รอต่อกับฐานข้อมูลจริงของ HOSxP
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ------------------------------------------------------------------ ชุดสี
// ค่าสีมาจาก design token ในไฟล์ Figma โดยตรง
const Color _bg = Color(0xFFF9F9F9);
const Color _surface = Color(0xFFFFFFFF);
const Color _sceneBg = Color(0xFFEDEDED);
const Color _primary = Color(0xFF001B7C);
const Color _line = Color(0x1A000000);
const Color _muted = Color(0xFF667085);
const Color _disabled = Color(0xFFD9D9D9);

const Color _danger = Color(0xFFEF4444);
const Color _caution = Color(0xFFF97316);
const Color _warning = Color(0xFFEAB308);
const Color _success = Color(0xFF22C55E);

/// สี่ขั้นของกระแสงานใน ER ตรงกับแท็บด้านบนของพื้นที่ขวา
enum _Stage {
  triage('คัดกรอง', Icons.assignment_ind_rounded, _caution),
  treatment('ตรวจรักษา', Icons.medical_services_rounded, _primary),
  after('หลังการตรวจ', Icons.logout_rounded, _success);

  const _Stage(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// ระดับความสำคัญของการแจ้งเตือน กำหนดสีจุดมุมขวาของการ์ด
enum _Level {
  critical('วิกฤต', _danger),
  urgent('เร่งด่วน', _caution),
  watch('เฝ้าระวัง', _warning),
  normal('ปกติ', _success);

  const _Level(this.label, this.color);

  final String label;
  final Color color;
}

/// การแจ้งเตือนหนึ่งรายการในแผงซ้าย
class _Alert {
  const _Alert(this.time, this.title, this.detail, this.level);

  final String time;
  final String title;
  final String detail;
  final _Level level;
}

const List<_Alert> _alerts = [
  _Alert('10:22', 'ผู้ป่วย ESI 1 ยังไม่ได้พบแพทย์เกิน 5 นาที',
      'นายกิตติพงษ์ รัตน์ · เตียง A3 · รอแพทย์เวรกู้ชีพ', _Level.critical),
  _Alert('10:18', 'เตียงสังเกตอาการเหลือ 2 จาก 10',
      'ผู้ป่วยรอเตียง 5 ราย · คาดว่าเต็มภายใน 20 นาที', _Level.urgent),
  _Alert('10:05', 'ผลตรวจทางห้องปฏิบัติการค้างเกิน 60 นาที',
      'นางอรสา ลิ้มเจริญ · เตียง A2 · รอผลเพาะเชื้อ', _Level.watch),
  _Alert('09:54', 'ส่งต่อผู้ป่วยไปวอร์ดอายุรกรรมสำเร็จ',
      'นายปรีชา ดำรงค์ · ย้ายออกจากเตียง A5 แล้ว', _Level.normal),
  _Alert('09:41', 'คัดกรองครบทุกรายในคิวเช้า',
      'คัดกรอง 18 ราย · เวลาเฉลี่ย 6 นาที ต่อราย', _Level.normal),
];

/// ตัวเลขแท่งของกราฟผู้ป่วยเข้าออกรายชั่วโมง 24 ชั่วโมงล่าสุด
/// ค่าคือสัดส่วน 0–1 ของความสูงแท่ง
const List<double> _hourly = [
  0.34, 0.28, 0.47, 0.39, 0.63, 0.55, 0.86, 0.94, //
  0.78, 1.00, 0.91, 0.75, 0.69, 0.81, 0.72, 0.59,
  0.66, 0.56, 0.44, 0.31, 0.23, 0.16, 0.13, 0.19,
];

/// ช่วงชั่วโมงที่ถือว่าเป็นช่วงพีค แท่งในช่วงนี้ย้อมสีหลัก
const int _peakFrom = 6;
const int _peakTo = 16;

/// เวลานาฬิกาแบบไทย ลงท้ายด้วย "น." เสมอ เช่น 10:22 น.
String _clock(String hhmm) => '$hhmm น.';

class ErOverviewWidget extends StatefulWidget {
  const ErOverviewWidget({super.key});

  static const String routeName = 'Er_Overview';
  static const String routePath = 'erOverview';

  @override
  State<ErOverviewWidget> createState() => _ErOverviewWidgetState();
}

class _ErOverviewWidgetState extends State<ErOverviewWidget> {
  /// แท็บที่เลือกอยู่ null = ภาพรวมทั้งหมด
  _Stage? _tab;

  /// ตัวกรองการแจ้งเตือน null = ทุกระดับ
  _Level? _filter;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // ------------------------------------------------------------ ตัวหนังสือ
  /// ฟอนต์มาจากไฟล์ที่ฝังในแอป ไม่ได้โหลดจากเน็ต จอในห้องฉุกเฉินจึงไม่พังตอนเน็ตหลุด
  TextStyle _t(double size,
          {Color color = _primary,
          FontWeight weight = FontWeight.w400,
          double? height}) =>
      TextStyle(
          fontFamily: 'NotoSansThai',
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: height);

  TextStyle _num(double size,
          {Color color = _primary, FontWeight weight = FontWeight.w600}) =>
      TextStyle(
          fontFamily: 'NotoSansThai',
          fontSize: size,
          color: color,
          fontWeight: weight);

  void _go(String routeName) {
    try {
      context.pushNamed(routeName);
    } catch (e) {
      debugPrint('เปิดเส้นทาง $routeName ไม่ได้: $e');
    }
  }

  // ------------------------------------------------------------ แถบเมนูซ้าย
  Widget _railItem(IconData icon,
          {bool active = false, bool dot = false, VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 13.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 63.0,
                height: 52.0,
                decoration: BoxDecoration(
                  color: active ? _primary : _disabled,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon,
                    size: 22.0, color: active ? Colors.white : _muted),
              ),
              if (dot)
                Positioned(
                  right: -7.0,
                  top: -7.0,
                  child: Container(
                    width: 18.0,
                    height: 18.0,
                    decoration: const BoxDecoration(
                        color: _danger, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _rail() => Container(
        width: 83.0,
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(right: BorderSide(color: _line)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12.0),
            Container(
              width: 63.0,
              height: 63.0,
              decoration: BoxDecoration(
                color: _disabled,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Image.asset('assets/images/app_launcher_icon.png',
                  errorBuilder: (c, e, s) => const Icon(Icons.local_hospital,
                      size: 30.0, color: _primary)),
            ),
            const SizedBox(height: 40.0),
            _railItem(Icons.insights_rounded, active: true),
            _railItem(Icons.grid_view_rounded, onTap: () => _go('Er_Bed_View')),
            _railItem(Icons.people_alt_rounded,
                onTap: () => _go('ERHomepageCopy')),
            _railItem(Icons.bar_chart_rounded, onTap: () => _go('ERDashboard')),
            _railItem(Icons.map_rounded, onTap: () => _go('Er_Floor_Map')),
            _railItem(Icons.notifications_rounded, dot: true),
            _railItem(Icons.settings_rounded),
            const Spacer(),
            Text(_clock('10:24'),
                style: _num(12.0, color: _muted, weight: FontWeight.w400)),
            Text('27 พ.ค.', style: _t(11.0, color: _muted)),
            const SizedBox(height: 20.0),
            Container(
              width: 47.0,
              height: 47.0,
              decoration:
                  const BoxDecoration(color: _disabled, shape: BoxShape.circle),
              child:
                  const Icon(Icons.person_rounded, size: 24.0, color: _muted),
            ),
            const SizedBox(height: 17.0),
          ],
        ),
      );

  // ------------------------------------------------------------- แผงซ้าย
  /// การ์ดตัวเลขหนึ่งใบ ป้ายชื่ออยู่มุมซ้ายบน ตัวเลขชิดขวาล่างตามแบบ
  Widget _statCard(String label, String value, String unit,
      {Color valueColor = _primary}) {
    return Expanded(
      child: Container(
        height: 100.0,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: _surface,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _t(12.0, color: _muted)),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _num(32.0, color: valueColor)),
                ),
                const SizedBox(width: 4.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(unit, style: _t(12.0, color: _muted)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statGrid() => Column(
        children: [
          Row(
            children: [
              _statCard('ผู้ป่วยในห้องตอนนี้', '20', 'ราย'),
              const SizedBox(width: 16.0),
              _statCard('ค้างเกินเกณฑ์', '11', 'ราย', valueColor: _danger),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              _statCard('เวลาเฉลี่ยใน ER', '2:18', 'ชม.'),
              const SizedBox(width: 16.0),
              _statCard('เตียงว่าง', '2', 'จาก 10'),
            ],
          ),
        ],
      );

  /// กราฟแท่งผู้ป่วยเข้าออกรายชั่วโมง แท่งในช่วงพีคย้อมสีหลัก
  Widget _hourlyChart() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ผู้ป่วยเข้าออกรายชั่วโมง', style: _t(12.0, color: _muted)),
              const Spacer(),
              Text('24 ชม.', style: _t(12.0, color: _muted)),
            ],
          ),
          const SizedBox(height: 7.0),
          SizedBox(
            height: 64.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _hourly.length; i++)
                  Container(
                    width: 14.0,
                    height: (_hourly[i] * 64.0).clamp(6.0, 64.0),
                    decoration: BoxDecoration(
                      color:
                          i >= _peakFrom && i <= _peakTo ? _primary : _disabled,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );

  Widget _filterChip(String label, _Level? level) {
    final active = _filter == level;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(100.0),
        onTap: () => setState(() => _filter = level),
        child: Container(
          height: 31.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _primary : _surface,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text(label,
              style: _t(12.0,
                  color: active ? Colors.white : _primary,
                  weight: active ? FontWeight.w600 : FontWeight.w400)),
        ),
      ),
    );
  }

  Widget _alertCard(_Alert a) => Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: _surface,
          border: Border.all(color: _line),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.time,
                      style:
                          _num(12.0, color: _muted, weight: FontWeight.w400)),
                  const SizedBox(height: 6.0),
                  Text(a.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(13.0, weight: FontWeight.w600)),
                  const SizedBox(height: 4.0),
                  Text(a.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _t(12.0, color: _muted)),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            Container(
              width: 16.0,
              height: 16.0,
              decoration:
                  BoxDecoration(color: a.level.color, shape: BoxShape.circle),
            ),
          ],
        ),
      );

  Widget _alertSection() {
    final list = _filter == null
        ? _alerts
        : _alerts.where((a) => a.level == _filter).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('การแจ้งเตือน', style: _t(14.0, weight: FontWeight.w600)),
        const SizedBox(height: 8.0),
        Row(
          children: [
            _filterChip('ทั้งหมด', null),
            for (final l in _Level.values) _filterChip(l.label, l),
          ],
        ),
        const SizedBox(height: 8.0),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text('ไม่มีการแจ้งเตือนในระดับนี้',
                style: _t(12.0, color: _muted)),
          )
        else
          for (final a in list) _alertCard(a),
      ],
    );
  }

  Widget _leftPanel() => Container(
        width: 486.0,
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(right: BorderSide(color: _line)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ภาพรวมแผนกห้องฉุกเฉิน',
                  style: _t(24.0, weight: FontWeight.w700)),
              Text('กระแสงานตามเวลาจริง · อัปเดตทุก 1 นาที',
                  style: _t(12.0, color: _muted)),
              const SizedBox(height: 16.0),
              _statGrid(),
              const SizedBox(height: 16.0),
              _hourlyChart(),
              const SizedBox(height: 16.0),
              _alertSection(),
            ],
          ),
        ),
      );

  // ------------------------------------------------------------- พื้นที่ขวา
  Widget _tabButton(String label, _Stage? stage) {
    final active = _tab == stage;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(100.0),
        onTap: () => setState(() => _tab = stage),
        child: Container(
          height: 48.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _primary : _surface,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: Text(label,
              style: _t(16.0, color: active ? Colors.white : _primary)),
        ),
      ),
    );
  }

  Widget _tabBar() => Row(
        children: [
          _tabButton('ภาพรวม', null),
          const SizedBox(width: 16.0),
          for (final s in _Stage.values) ...[
            _tabButton(s.label, s),
            if (s != _Stage.values.last) const SizedBox(width: 16.0),
          ],
        ],
      );

  /// ป้ายมุมซ้ายบนของพื้นที่ฉาก
  Widget _sceneTitle() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ER Workflow',
              style: TextStyle(
                  fontFamily: 'NotoSansThai',
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withValues(alpha: 0.5))),
          const SizedBox(height: 5.0),
          Text('แผนภาพจำลองการทำงานของแผนก ER',
              style: _t(12.0, color: Colors.black54)),
          Text('เห็นถึงการไหลของผู้ป่วยจากต้นไปจนจบ',
              style: _t(12.0, color: Colors.black54)),
        ],
      );

  /// ช่องที่ฉากสามมิติจะมาลง ตอนนี้เว้นไว้ก่อนตามที่ตกลง
  Widget _scenePlaceholder() => LayoutBuilder(
        builder: (context, c) => DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: _disabled, width: 1.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.view_in_ar_rounded,
                    size: 40.0, color: Colors.black.withValues(alpha: 0.18)),
                const SizedBox(height: 8.0),
                Text('พื้นที่ฉากสามมิติ',
                    style: _t(13.0, color: Colors.black38)),
                Text('${c.maxWidth.toInt()} × ${c.maxHeight.toInt()}',
                    style: _num(11.0,
                        color: Colors.black26, weight: FontWeight.w400)),
              ],
            ),
          ),
        ),
      );

  /// แถบสีระดับความเร่งด่วน ลอยมุมขวาล่างของฉาก
  Widget _legend() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in const [
            _danger,
            _caution,
            _warning,
            _success,
            _primary,
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Container(
                width: 70.0,
                height: 13.0,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
        ],
      );

  /// การ์ดสรุปหนึ่งใบในแถบล่าง
  Widget _summaryCard(IconData icon, Color color, String label, String value) =>
      Expanded(
        child: Container(
          height: 85.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: _surface,
            border: Border.all(color: _line),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22.0),
                ),
                child: Icon(icon, size: 22.0, color: color),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _t(12.0, color: _muted)),
                    const SizedBox(height: 4.0),
                    Text(value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _num(20.0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _summaryStrip() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('สรุปตามขั้นของกระแสงาน', style: _t(12.0, color: _muted)),
          const SizedBox(height: 8.0),
          Row(
            children: [
              _summaryCard(
                  Icons.assignment_ind_rounded, _caution, 'รอคัดกรอง', '5 ราย'),
              const SizedBox(width: 8.0),
              _summaryCard(
                  Icons.hourglass_bottom_rounded, _danger, 'รอตรวจ', '8 ราย'),
              const SizedBox(width: 8.0),
              _summaryCard(Icons.medical_services_rounded, _primary, 'ตรวจแล้ว',
                  '4 ราย'),
              const SizedBox(width: 8.0),
              _summaryCard(Icons.logout_rounded, _success, 'รอออก', '3 ราย'),
            ],
          ),
        ],
      );

  Widget _rightPanel() => Container(
        color: _sceneBg,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabBar(),
            const SizedBox(height: 32.0),
            _sceneTitle(),
            const SizedBox(height: 16.0),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _scenePlaceholder()),
                  Positioned(right: 16.0, bottom: 16.0, child: _legend()),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            _summaryStrip(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Row(
          children: [
            _rail(),
            _leftPanel(),
            Expanded(child: _rightPanel()),
          ],
        ),
      ),
    );
  }
}
