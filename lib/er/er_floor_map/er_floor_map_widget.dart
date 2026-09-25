/// ผังห้องฉุกเฉินสามมิติ — คนไข้ทุกคนมีที่อยู่ในฉาก ไม่ใช่เฉพาะคนที่ได้เตียง
///
/// ฉากมาจาก assets/models/er_floor.glb ซึ่งมีจุดคัดกรอง โซนนั่งรอ เตียงสองแถว
/// และจุดรอออก อยู่ในห้องเดียวกัน ฝั่งสามมิติส่งตำแหน่งบนจอของแต่ละจุดกลับมา
/// ให้ Flutter วางป้ายจำนวนคนทับ
///
/// ข้อมูลผู้ป่วยยังเป็นของจำลอง รอฟิลด์ zone กับ bed_id จากฐานข้อมูลจริง
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../er_flow_home/er_flow_3d.dart';

const Color _bg = Color(0xFFF8F9FA);
const Color _panel = Color(0xFFFFFFFF);
const Color _panelSoft = Color(0xFFF1F3F4);
const Color _line = Color(0xFFE3E6EA);
const Color _ink = Color(0xFF202124);
const Color _ink2 = Color(0xFF5F6368);
const Color _ink3 = Color(0xFF9AA0A6);
const Color _blue = Color(0xFF4285F4);
const Color _red = Color(0xFFEA4335);
const Color _green = Color(0xFF34A853);

enum _Esi {
  one(1, 'กู้ชีพ', Color(0xFFBE1E2D)),
  two(2, 'ฉุกเฉิน', Color(0xFFAF1EBE)),
  three(3, 'เร่งด่วน', Color(0xFFDC8610)),
  four(4, 'กึ่งเร่งด่วน', Color(0xFF006838)),
  five(5, 'ไม่เร่งด่วน', Color(0xFF465054));

  const _Esi(this.level, this.label, this.color);

  final int level;
  final String label;
  final Color color;
}

/// ที่อยู่ของผู้ป่วยในห้อง ตรงกับชื่อกลุ่มในไฟล์ฉาก
class _Spot {
  const _Spot(this.key, this.label);

  final String key;
  final String label;
}

const List<_Spot> _zones = [
  _Spot('zone_triage', 'จุดคัดกรอง'),
  _Spot('zone_waiting', 'โซนนั่งรอ'),
  _Spot('zone_wheelchair', 'จอดรถเข็น'),
  _Spot('zone_entrance', 'ทางเข้า-ออก'),
];

/// ผู้ป่วยหนึ่งคน อยู่ที่เตียง (bed_A1) หรือโซน (zone_waiting)
/// ท่าที่ผู้ป่วยอยู่ ตรงกับฟิลด์ สภาพผู้ป่วย ในหน้าคัดกรองของโค้ดเบสเดิม
enum _Placement {
  bed('นอนเตียง', Icons.bed_rounded),
  wheelchair('นั่งรถเข็น', Icons.accessible_rounded),
  chair('นั่งรอ', Icons.event_seat_rounded),
  walk('เดินได้', Icons.directions_walk_rounded);

  const _Placement(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _P {
  const _P(this.name, this.at, this.waitMin,
      {this.esi, this.note = '', this.placement = _Placement.chair});

  final String name;
  final String at;
  final int waitMin;
  final _Esi? esi;
  final String note;

  /// นอนเตียง / นั่งรถเข็น / นั่งรอ / เดินได้
  final _Placement placement;
}

const List<_P> _patients = [
  _P('นายสมชาย แสงชัย', 'zone_triage', 14,
      placement: _Placement.walk, note: 'เดินมาเอง'),
  _P('นางอารยา ธนกิจ', 'zone_triage', 11,
      placement: _Placement.walk, note: 'ญาตินำส่ง'),
  _P('นายบริรักษ์ คงทน', 'zone_triage', 8, placement: _Placement.wheelchair),
  _P('นางมาลี ศรีสุข', 'zone_wheelchair', 36,
      esi: _Esi.three, placement: _Placement.wheelchair, note: 'รอผล X-ray'),
  _P('นายประเสริฐ ทองอยู่', 'zone_wheelchair', 19,
      esi: _Esi.four, placement: _Placement.wheelchair),
  _P('นางสาวณัฐมน พงศ์ดี', 'zone_waiting', 52, esi: _Esi.four),
  _P('นายอนันต์ มีทรัพย์', 'zone_waiting', 78, esi: _Esi.four),
  _P('นางกัญญารัตน์ ทองดี', 'zone_waiting', 96, esi: _Esi.four),
  _P('นายวัชระ นาคสุข', 'zone_waiting', 41, esi: _Esi.five),
  _P('นายนิติพนธ์ สุขสม', 'zone_waiting', 65, esi: _Esi.three),
  _P('นางสาวสุภาพร ว่องไว', 'bed_A1', 80,
      placement: _Placement.bed, esi: _Esi.one, note: 'รอผล CT'),
  _P('นางอรสา ลิ้มเจริญ', 'bed_A2', 105,
      placement: _Placement.bed, esi: _Esi.two, note: 'รอเพาะเชื้อ'),
  _P('นายกิตติพงษ์ รัตน์', 'bed_A3', 22,
      placement: _Placement.bed, esi: _Esi.one, note: 'รอแพทย์'),
  _P('นางสุดา กมลรัตน์', 'bed_C1', 34,
      placement: _Placement.bed, esi: _Esi.two, note: 'รอผลภาพสมอง'),
  _P('นายปรีชา ดำรงค์', 'bed_B3', 155,
      placement: _Placement.bed, esi: _Esi.two, note: 'รอเตียงวอร์ด'),
  _P('นางสาวจุฑามาศ ไชย', 'bed_B1', 45,
      placement: _Placement.bed, esi: _Esi.two),
  _P('นางสาวพิมพ์ชนก ศรี', 'bed_B2', 62,
      placement: _Placement.bed, esi: _Esi.three, note: 'พ่นยาแล้ว'),
  _P('นางพรทิพย์ ก้องเกียรติ', 'zone_entrance', 15,
      placement: _Placement.bed, esi: _Esi.three),
  _P('นายจิระ สินสมบูรณ์', 'zone_entrance', 28,
      esi: _Esi.four, note: 'รอญาติมารับ'),
  _P('นางวารุณี เพ็ญศรี', 'zone_entrance', 58,
      esi: _Esi.two, note: 'รอรถส่งต่อ'),
];

/// เตียงในผัง: ปีกตะวันออก A1-A3 ปีกใต้ B1-B3 และเตียงหัตถการ C1
const List<String> _bedKeys = [
  'bed_A1',
  'bed_A2',
  'bed_A3',
  'bed_B1',
  'bed_B2',
  'bed_B3',
  'bed_C1',
];

String _hm(int m) => m < 60
    ? '$m นาที'
    : '${m ~/ 60} ชม. ${(m % 60).toString().padLeft(2, '0')} น.';

class ErFloorMapWidget extends StatefulWidget {
  const ErFloorMapWidget({super.key});

  static const String routeName = 'Er_Floor_Map';
  static const String routePath = 'erFloorMap';

  @override
  State<ErFloorMapWidget> createState() => _ErFloorMapWidgetState();
}

class _ErFloorMapWidgetState extends State<ErFloorMapWidget> {
  final ErFlowCam _cam = const ErFlowCam(yaw: 45.0, pitch: 34.0);

  final ValueNotifier<Map<String, ErFlowStagePos>> _pos =
      ValueNotifier(const {});

  /// จุดที่เลือกอยู่ เตียงหรือโซน
  String? _sel;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  List<_P> _at(String key) => _patients.where((p) => p.at == key).toList();

  TextStyle _t(double size,
          {Color color = _ink,
          FontWeight weight = FontWeight.w400,
          double? height}) =>
      TextStyle(
          fontFamily: 'IBMPlexSansThaiLooped',
          fontSize: size,
          color: color,
          fontWeight: weight,
          height: height);

  TextStyle _num(double size,
          {Color color = _ink, FontWeight weight = FontWeight.w500}) =>
      TextStyle(
          fontFamily: 'IBMPlexSansThaiLooped',
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

  // ---------------------------------------------------------------- sidebar
  Widget _sideNavItem(IconData icon, String label,
          {bool active = false, int? badge, VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Material(
          color: active ? _blue : Colors.transparent,
          borderRadius: BorderRadius.circular(14.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 72.0,
              padding: const EdgeInsets.symmetric(vertical: 9.0),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(icon,
                          size: 21.0, color: active ? Colors.white : _ink2),
                      if (badge != null)
                        Positioned(
                          right: -7.0,
                          top: -4.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 1.0),
                            decoration: BoxDecoration(
                              color: _red,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text('$badge',
                                style: _num(9.0,
                                    color: Colors.white,
                                    weight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: _t(10.0,
                          color: active ? Colors.white : _ink2,
                          weight: active ? FontWeight.w600 : FontWeight.w400)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _sideBar() => Container(
        width: 96.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        decoration: const BoxDecoration(
          color: _panel,
          border: Border(right: BorderSide(color: _line)),
        ),
        child: Column(
          children: [
            Image.asset('assets/images/app_launcher_icon.png',
                width: 34.0,
                height: 34.0,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.local_hospital, size: 30.0, color: _blue)),
            const SizedBox(height: 4.0),
            Text('ER Module',
                style: _t(11.0, weight: FontWeight.w600),
                textAlign: TextAlign.center),
            Text('ห้องฉุกเฉิน', style: _t(9.0, color: _ink3)),
            const SizedBox(height: 12.0),
            Container(height: 1.0, color: _line),
            const SizedBox(height: 10.0),
            _sideNavItem(Icons.insights_rounded, 'ภาพรวม',
                onTap: () => _go('Er_Flow_Home')),
            _sideNavItem(Icons.grid_view_rounded, 'ผังห้อง', active: true),
            _sideNavItem(Icons.people_alt_rounded, 'รายชื่อ',
                onTap: () => _go('ERHomepageCopy')),
            _sideNavItem(Icons.bar_chart_rounded, 'ย้อนหลัง',
                onTap: () => _go('ERDashboard')),
            _sideNavItem(Icons.notifications_rounded, 'แจ้งเตือน', badge: 3),
            const Spacer(),
            Container(height: 1.0, color: _line),
            const SizedBox(height: 8.0),
            Text('10:24 น.', style: _num(16.0, weight: FontWeight.w600)),
            Text('27 พ.ค. 2568', style: _t(9.0, color: _ink3)),
            const SizedBox(height: 8.0),
            Container(
              width: 34.0,
              height: 34.0,
              decoration: const BoxDecoration(
                  color: _panelSoft, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, size: 19.0, color: _ink2),
            ),
            const SizedBox(height: 3.0),
            Text('พยาบาล ER', style: _t(9.0, color: _ink3)),
          ],
        ),
      );

  // ---------------------------------------------------------------- ป้ายในฉาก
  /// ป้ายเตียง บอกรหัสกับผู้ครอง ว่างจะเป็นป้ายโปร่ง
  Widget _bedTag(String key) {
    final code = key.replaceFirst('bed_', '');
    final people = _at(key);
    final p = people.isEmpty ? null : people.first;
    final on = _sel == key;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () => setState(() => _sel = on ? null : key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: p == null ? _panel.withValues(alpha: 0.9) : p.esi!.color,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
                color: on ? _ink : (p == null ? _line : Colors.white),
                width: on ? 2.0 : 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(code,
                  style: _num(11.5,
                      color: p == null ? _ink3 : Colors.white,
                      weight: FontWeight.w700)),
              if (p != null)
                Text(_hm(p.waitMin),
                    style: _num(9.0,
                        color: Colors.white.withValues(alpha: 0.9),
                        weight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  /// ป้ายโซน บอกจำนวนคนที่อยู่ตรงนั้น
  Widget _zoneTag(_Spot zone) {
    final people = _at(zone.key);
    final on = _sel == zone.key;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () => setState(() => _sel = on ? null : zone.key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: on ? _ink : _line, width: on ? 2.0 : 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(zone.label, style: _t(11.0, weight: FontWeight.w600)),
              const SizedBox(height: 2.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${people.length}',
                      style: _num(15.0, weight: FontWeight.w700)),
                  const SizedBox(width: 4.0),
                  Text('คน', style: _t(10.0, color: _ink3)),
                  const SizedBox(width: 6.0),
                  for (final p in people)
                    Container(
                      width: 7.0,
                      height: 7.0,
                      margin: const EdgeInsets.only(left: 2.0),
                      decoration: BoxDecoration(
                          color: p.esi?.color ?? _ink3, shape: BoxShape.circle),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- แผงล่าง
  Widget _detail() {
    final key = _sel;
    if (key == null) {
      final onBed = _patients.where((p) => p.at.startsWith('bed_')).length;
      final free = _bedKeys.where((k) => _at(k).isEmpty).length;
      final wheel =
          _patients.where((p) => p.placement == _Placement.wheelchair).length;
      final sit = _patients
          .where((p) =>
              p.placement == _Placement.chair || p.placement == _Placement.walk)
          .length;
      return Row(
        children: [
          Text('ผู้ป่วยในห้อง ${_patients.length} คน',
              style: _t(13.0, weight: FontWeight.w600)),
          const SizedBox(width: 16.0),
          Text('บนเตียง $onBed', style: _t(12.0, color: _ink2)),
          const SizedBox(width: 12.0),
          Text('นั่งรถเข็น $wheel', style: _t(12.0, color: _ink2)),
          const SizedBox(width: 12.0),
          Text('นั่งรอ/เดินได้ $sit', style: _t(12.0, color: _ink2)),
          const SizedBox(width: 12.0),
          Text('เตียงว่าง $free',
              style: _t(12.0,
                  color: free > 0 ? _green : _red, weight: FontWeight.w600)),
          const Spacer(),
          Text('แตะเตียงหรือโซนในผังเพื่อดูรายชื่อ',
              style: _t(11.0, color: _ink3)),
        ],
      );
    }
    final people = _at(key);
    final label = key.startsWith('bed_')
        ? 'เตียง ${key.replaceFirst('bed_', '')}'
        : _zones.firstWhere((z) => z.key == key).label;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: _t(14.0, weight: FontWeight.w600)),
        const SizedBox(width: 10.0),
        Text('${people.length} คน', style: _t(12.0, color: _ink2)),
        const SizedBox(width: 18.0),
        Expanded(
          child: people.isEmpty
              ? Text('ว่าง พร้อมรับผู้ป่วย', style: _t(12.0, color: _green))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final p in people)
                        Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: _panelSoft,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                    color: p.esi?.color ?? _ink3,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 7.0),
                              Icon(p.placement.icon, size: 13.0, color: _ink3),
                              const SizedBox(width: 5.0),
                              Text(p.name,
                                  style: _t(12.0, weight: FontWeight.w500)),
                              const SizedBox(width: 8.0),
                              Text(_hm(p.waitMin),
                                  style: _num(11.5, color: _ink2)),
                              if (p.note.isNotEmpty) ...[
                                const SizedBox(width: 8.0),
                                Text(p.note, style: _t(11.0, color: _ink3)),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(100.0),
          onTap: () => setState(() => _sel = null),
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.close_rounded, size: 16.0, color: _ink2),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Row(
          children: [
            _sideBar(),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22.0, 12.0, 22.0, 4.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('ผังห้องฉุกเฉิน',
                                style: _t(22.0, weight: FontWeight.w600)),
                            Text('ตำแหน่งจริงของผู้ป่วยทุกคนในห้อง',
                                style: _t(11.5, color: _ink2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ErFlow3D(
                            model: 'assets/models/er_ward.glb',
                            stages: const [],
                            cam: _cam,
                            onStageTap: (key) =>
                                setState(() => _sel = _sel == key ? null : key),
                            onPositions: (items) {
                              if (!mounted) return;
                              _pos.value = {for (final p in items) p.key: p};
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: ValueListenableBuilder<
                                Map<String, ErFlowStagePos>>(
                              valueListenable: _pos,
                              builder: (context, pos, _) => Stack(
                                children: [
                                  for (final k in _bedKeys)
                                    if (pos[k]?.visible ?? false)
                                      Positioned(
                                        left: pos[k]!.dx - 34.0,
                                        top: pos[k]!.dy - 46.0,
                                        width: 68.0,
                                        child: Center(child: _bedTag(k)),
                                      ),
                                  for (final z in _zones)
                                    if (pos[z.key]?.visible ?? false)
                                      Positioned(
                                        left: pos[z.key]!.dx - 70.0,
                                        top: pos[z.key]!.dy - 60.0,
                                        width: 140.0,
                                        child: Center(child: _zoneTag(z)),
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(22.0, 10.0, 16.0, 10.0),
                    decoration: const BoxDecoration(
                      color: _panel,
                      border: Border(top: BorderSide(color: _line)),
                    ),
                    child: _detail(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
