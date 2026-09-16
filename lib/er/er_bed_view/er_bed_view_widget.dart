/// หน้ากระดานเตียงห้องฉุกเฉิน (Bed View)
///
/// สร้างตามแบบใน Figma โหนด 31-30 ของไฟล์ HOSXP-ER
///
/// ฉากเป็นห้องเดียวเรียงเตียงเป็นแถวระนาบเดียวกัน 16 ช่อง มีม่านคั่นทุกช่อง
/// render ล่วงหน้าจากโมเดลสามมิติ assets/models/hospital_bed.glb ด้วย Blender
/// (scratchpad/bed/render_room.py) แล้ววางป้ายเตียงกับไฟไฮไลต์ทับตามพิกัด
/// ที่คำนวณจากกล้องตัวเดียวกัน จึงตรงตำแหน่งโดยไม่ต้องเรนเดอร์สามมิติตอนรัน
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'er_room_3d.dart';

// ---------------------------------------------------------------- palette
// โทนสีและพื้นผิวอ้างอิง design language ของ ER Registry (bms-uxui/er-registry)
// ฟอนต์ Noto Sans Thai พื้นหลังเทาอ่อน การ์ดสีขาวแบบกระจก เงาซ้อนหลายชั้น
const Color _bg = Color(0xFFF8F9FA);
const Color _panel = Color(0xFFFFFFFF);
const Color _panelSoft = Color(0xFFF1F3F4);
const Color _line = Color(0xFFE3E6EA);
const Color _ink = Color(0xFF202124);
const Color _ink2 = Color(0xFF5F6368);
const Color _ink3 = Color(0xFF9AA0A6);
const Color _blue = Color(0xFF4285F4);
const Color _red = Color(0xFFEA4335);
const Color _amber = Color(0xFFF9AB00);
const Color _green = Color(0xFF34A853);

/// พื้นผิวการ์ดแบบกระจก ตาม GLASS_CARD ของ ER Registry
BoxDecoration _glass({double radius = 20.0}) => BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: _line),
      boxShadow: const [
        BoxShadow(
            color: Color(0x0A101828), blurRadius: 6.0, offset: Offset(0, 2)),
        BoxShadow(
            color: Color(0x1A101828), blurRadius: 36.0, offset: Offset(0, 14)),
      ],
    );

/// ระดับคัดแยกผู้ป่วย เก็บสีและชื่อไว้ที่เดียว ทุกจุดบนจอจึงใช้ค่าเดียวกัน
/// ระดับคัดแยกผู้ป่วย ใช้ชื่อและสีชุดเดียวกับวิดเจ็ต ESI ที่มีอยู่แล้ว
/// ใน lib/er/widget/*_e_s_i เพื่อให้หน้านี้พูดภาษาเดียวกับหน้าอื่นของระบบ
enum _Esi {
  one(1, 'Resuscitation', 'กู้ชีพ', Color(0xFFE15D69), Color(0xFFBE1E2D)),
  two(2, 'Emergency', 'ฉุกเฉิน', Color(0xFFBD6EF2), Color(0xFFAF1EBE)),
  three(3, 'Urgent', 'เร่งด่วน', Color(0xFFFFB960), Color(0xFFDC8610)),
  four(4, 'Semi-urgent', 'กึ่งเร่งด่วน', Color(0xFF5FD187), Color(0xFF006838)),
  five(5, 'Non-urgent', 'ไม่เร่งด่วน', Color(0xFF838689), Color(0xFF465054));

  const _Esi(this.level, this.en, this.label, this.c1, this.c2);

  final int level;

  /// ชื่ออังกฤษตามวิดเจ็ตเดิมในโปรเจกต์
  final String en;

  /// ชื่อไทยที่ใช้บนหน้าจอนี้
  final String label;

  /// สีต้นและปลายของไล่เฉดบนจุดนำหน้าป้าย
  final Color c1;
  final Color c2;

  /// สีหลักของระดับ ใช้กับตัวอักษร ป้ายเตียง และวงแหวนในฉาก
  Color get color => c2;
}

/// ภาพใบหน้าจาก Unsplash ใช้ประกอบการ์ดเตียงในแถบล่าง
/// เป็นภาพตัวอย่างสำหรับงานออกแบบเท่านั้น ไม่ใช่รูปผู้ป่วยจริง
const List<String> _facePhotos = [
  'photo-1507003211169-0a1dd7228f2d',
  'photo-1494790108377-be9c29b29330',
  'photo-1500648767791-00dcc994a43e',
  'photo-1544005313-94ddf0286df2',
  'photo-1528892952291-009c663ce843',
  'photo-1633332755192-727a05c4013d',
  'photo-1573497019940-1c28c88b4f3e',
  'photo-1521119989659-a83eee488004',
];

String _faceUrl(int index) =>
    'https://images.unsplash.com/${_facePhotos[index % _facePhotos.length]}'
    '?w=200&h=200&fit=crop&crop=faces';

/// หนึ่งรายการในบันทึกกิจกรรมของห้อง
class _LogEntry {
  const _LogEntry(this.time, this.bed, this.who, this.text,
      {this.byDoctor = false});

  final String time;
  final String bed;
  final String who;
  final String text;

  /// true = แพทย์สั่ง, false = พยาบาลปฏิบัติ ใช้แยกสีจุดบนเส้นเวลา
  final bool byDoctor;
}

/// บันทึกกิจกรรมของพยาบาลและแพทย์ เรียงจากล่าสุดลงไป
const List<_LogEntry> _activityLog = [
  _LogEntry('10:22', 'A1', 'พญ.ศิริพร', 'สั่ง CT brain ด่วน', byDoctor: true),
  _LogEntry('10:18', 'A1', 'พย.วรรณา', 'ให้ NSS 1,000 mL เปิดเส้นแล้ว'),
  _LogEntry('10:14', 'A3', 'พญ.ธนกร', 'สั่ง Adrenaline 1 mg IV',
      byDoctor: true),
  _LogEntry('10:09', 'A2', 'พย.สุนีย์', 'เจาะ Lactate และ H/C ส่งแล็บ'),
  _LogEntry('10:03', 'B1', 'พย.อรุณี', 'วัดสัญญาณชีพซ้ำ BP 96/60'),
];

/// ค่าสัญญาณชีพหนึ่งตัว พร้อมค่าที่วัดซ้ำเป็นระยะ
class _Vital {
  const _Vital({
    required this.icon,
    required this.label,
    required this.unit,
    required this.series,
    required this.color,
    this.display,
  });

  final IconData icon;
  final String label;
  final String unit;

  /// ค่าที่วัดได้เรียงตามเวลา ตัวสุดท้ายคือค่าล่าสุด
  final List<double> series;

  /// สีที่ใช้เมื่อค่าผิดปกติ ถ้าปกติให้ใช้สีตัวอักษรทั่วไป
  final Color color;

  /// ข้อความที่จะแสดงแทนตัวเลขล่าสุด เช่น ความดันที่เป็นคู่
  final String? display;

  /// สีเส้นในกราฟรวม แยกจากสีเตือนเพื่อให้แต่ละเส้นต่างกันชัด
  Color get line =>
      const {
        'HR': Color(0xFFEA4335),
        'BP': Color(0xFF9334E6),
        'SpO₂': Color(0xFF1A73E8),
        'RR': Color(0xFFF9AB00),
        'BT': Color(0xFF34A853),
      }[label] ??
      _blue;

  double get latest => series.last;
  double get previous => series.length > 1 ? series[series.length - 2] : latest;
}

/// เวลาที่วัดสัญญาณชีพ ใช้เป็นแกนนอนของกราฟ
const List<String> _vitalTimes = ['09:22', '09:37', '09:52', '10:07', '10:22'];

const List<_Vital> _vitals = [
  _Vital(
    icon: Icons.favorite_rounded,
    label: 'HR',
    unit: 'bpm',
    series: [96, 104, 112, 121, 128],
    color: _red,
  ),
  _Vital(
    icon: Icons.monitor_heart_rounded,
    label: 'BP',
    unit: 'mmHg',
    series: [112, 104, 98, 92, 88],
    color: _red,
    display: '88/56',
  ),
  _Vital(
    icon: Icons.bubble_chart_rounded,
    label: 'SpO₂',
    unit: '%',
    series: [97, 95, 93, 91, 89],
    color: _red,
  ),
  _Vital(
    icon: Icons.air_rounded,
    label: 'RR',
    unit: '/min',
    series: [18, 20, 22, 25, 28],
    color: _amber,
  ),
  _Vital(
    icon: Icons.thermostat_rounded,
    label: 'BT',
    unit: '°C',
    series: [36.6, 36.7, 36.7, 36.8, 36.8],
    color: _ink,
  ),
];

/// กราฟรวมสัญญาณชีพทุกค่าในกรอบเดียว แต่ละเส้นปรับสเกลด้วยช่วงของตัวเอง
/// จึงเทียบ "แนวโน้ม" กันได้ทั้งที่หน่วยต่างกัน
/// ปลายเส้นมีป้ายชื่อค่าและตัวเลขล่าสุด อ่านได้โดยไม่ต้องไล่หาในคำอธิบาย
class _VitalsChart extends CustomPainter {
  _VitalsChart(this.vitals, this.gridColor, this.timeLabels, this.mutedColor);

  final List<_Vital> vitals;
  final Color gridColor;
  final Color mutedColor;
  final List<String> timeLabels;

  static const double _labelW = 92.0;
  static const double _timeH = 14.0;

  TextPainter _tp(String text, TextStyle style) => TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final plotW = size.width - _labelW;
    final plotH = size.height - _timeH;
    final n = vitals.first.series.length;
    final dx = plotW / (n - 1);

    // เส้นกริดแนวตั้งตรงเวลาที่วัด พร้อมเวลาด้านล่าง
    for (var i = 0; i < n; i++) {
      final x = i * dx;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, plotH),
        Paint()..color = gridColor.withValues(alpha: i == n - 1 ? 0.9 : 0.5),
      );
      final tp = _tp(timeLabels[i],
          TextStyle(fontSize: 8.5, color: mutedColor, height: 1.0));
      tp.paint(canvas, Offset(x - tp.width / 2, plotH + 3));
    }

    // เรียงป้ายปลายเส้นไม่ให้ทับกัน
    final ends = <_Vital, double>{};
    for (final v in vitals) {
      final lo = v.series.reduce((a, b) => a < b ? a : b);
      final hi = v.series.reduce((a, b) => a > b ? a : b);
      final span = (hi - lo).abs() < 0.001 ? 1.0 : hi - lo;
      Offset at(int i) => Offset(
            i * dx,
            plotH - 8 - (v.series[i] - lo) / span * (plotH - 18),
          );

      final path = Path()..moveTo(at(0).dx, at(0).dy);
      for (var i = 1; i < n; i++) {
        final p0 = at(i - 1);
        final p1 = at(i);
        path.cubicTo((p0.dx + p1.dx) / 2, p0.dy, (p0.dx + p1.dx) / 2, p1.dy,
            p1.dx, p1.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = v.line,
      );
      final last = at(n - 1);
      canvas.drawCircle(last, 3.6, Paint()..color = v.line);
      canvas.drawCircle(
          last,
          3.6,
          Paint()
            ..color = const Color(0xFFFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
      ends[v] = last.dy;
    }

    // ดันป้ายที่ชนกันให้ห่างกันอย่างน้อย 15 พิกเซล
    final sorted = ends.keys.toList()
      ..sort((a, b) => ends[a]!.compareTo(ends[b]!));
    double? prevY;
    for (final v in sorted) {
      var y = ends[v]!;
      if (prevY != null && y - prevY < 15.0) y = prevY + 15.0;
      prevY = y;

      final label = v.display ??
          (v.latest % 1 == 0
              ? v.latest.toStringAsFixed(0)
              : v.latest.toStringAsFixed(1));
      final name = _tp('${v.label} ',
          TextStyle(fontSize: 10.0, color: mutedColor, height: 1.0));
      final value = _tp(
          label,
          TextStyle(
              fontSize: 12.5,
              color: v.color,
              fontWeight: FontWeight.w700,
              height: 1.0));
      final unit = _tp(' ${v.unit}',
          TextStyle(fontSize: 8.5, color: mutedColor, height: 1.0));

      final x0 = plotW + 8.0;
      canvas.drawLine(
        Offset(plotW, ends[v]!),
        Offset(x0 - 3, y),
        Paint()
          ..color = v.line.withValues(alpha: 0.5)
          ..strokeWidth = 1.2,
      );
      name.paint(canvas, Offset(x0, y - name.height / 2));
      value.paint(canvas, Offset(x0 + name.width, y - value.height / 2));
      unit.paint(
          canvas, Offset(x0 + name.width + value.width, y - unit.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _VitalsChart old) => old.vitals != vitals;
}

class _Bed {
  const _Bed(
    this.code,
    this.name,
    this.complaint,
    this.esi, {
    this.vacant = false,
    this.summary = '',
  });

  final String code;
  final String name;
  final String complaint;
  final _Esi esi;
  final bool vacant;

  /// บทสรุปที่ระบบสังเคราะห์จากบันทึก สัญญาณชีพ และคำสั่งการรักษา
  final String summary;
}

/// 10 เตียงของห้องฉุกเฉิน มีผู้ป่วย 8 ราย ว่าง 2 เตียง
/// รหัสเตียงต้องตรงกับชื่อช่องในฉาก (er_room_beds.dart) ไม่งั้นป้ายจะไม่ขึ้น
const List<_Bed> _beds = [
  _Bed('A1', 'นายสมชาย แสงชัย', 'อุบัติเหตุจราจร เจ็บหน้าอก', _Esi.one,
      summary:
          'ชายไทย 45 ปี ถูกรถชนขณะขี่จักรยานยนต์ มาถึงห้องฉุกเฉิน 18 นาที เจ็บหน้าอกซ้ายและหายใจเร็วขึ้นต่อเนื่อง ชีพจรไต่จาก 96 เป็น 128 ความดันตกจาก 112 เหลือ 88/56 ค่าออกซิเจนลดลงทุกครั้งที่วัด เข้าได้กับภาวะช็อกจากการเสียเลือด แพทย์สั่ง CT ด่วนเมื่อ 10:22'),
  _Bed('A2', 'นางอารยา ธนกิจ', 'ติดเชื้อในกระแสเลือด', _Esi.one,
      summary:
          'หญิงไทย 62 ปี ไข้สูงหนาวสั่นสองวัน ปัสสาวะแสบขัด ซึมลงในหกชั่วโมงหลัง ความดันต่ำและชีพจรเร็วตั้งแต่แรกรับ เจาะ Lactate และเพาะเชื้อในเลือดแล้วเมื่อ 10:09 รอผล เข้าเกณฑ์ติดเชื้อในกระแสเลือด ควรได้ยาปฏิชีวนะภายในหนึ่งชั่วโมง'),
  _Bed('A3', 'นายกิตติพงษ์ รัตน์', 'หัวใจหยุดเต้น', _Esi.one,
      summary:
          'ชายไทย 58 ปี หมดสติที่บ้าน ญาติทำ CPR ก่อนนำส่ง คลำชีพจรได้หลังกู้ชีพ 8 นาที ให้ Adrenaline ไปแล้วหนึ่งครั้งเมื่อ 10:14 ขณะนี้ความดันยังต่ำและต้องเฝ้าจังหวะการเต้นหัวใจต่อเนื่อง'),
  _Bed('A4', 'นายภราดร คำแก้ว', 'หลอดเลือดสมอง', _Esi.two,
      summary:
          'ชายไทย 71 ปี พูดไม่ชัดและแขนขาข้างขวาอ่อนแรงเฉียบพลัน เริ่มมีอาการ 70 นาทีก่อนถึงโรงพยาบาล ยังอยู่ในกรอบเวลาให้ยาละลายลิ่มเลือด รอผลภาพสมองเพื่อตัดเลือดออกก่อนตัดสินใจ'),
  _Bed('A5', 'นางสาวณฐมน พงศ์ดี', 'ปวดท้องเฉียบพลัน', _Esi.two,
      summary:
          'หญิงไทย 34 ปี ปวดท้องน้อยขวาเฉียบพลัน 6 ชั่วโมง กดเจ็บชัดที่ท้องน้อยขวา ไข้ต่ำ ๆ คลื่นไส้ ประวัติและการตรวจเข้าได้กับไส้ติ่งอักเสบ รอผลเลือดและอัลตราซาวด์'),
  _Bed('B1', 'นายวีระชัย ลาภมี', 'เลือดออกทางเดินอาหาร', _Esi.two,
      summary:
          'ชายไทย 66 ปี อาเจียนเป็นเลือดสองครั้งและถ่ายดำ มีประวัติกินยาแก้ปวดกลุ่ม NSAIDs ประจำ ความดันเริ่มตกและชีพจรเร็ว ต้องเตรียมเลือดและส่องกล้องทางเดินอาหารส่วนต้น'),
  _Bed('B2', 'นางสาวพิมพ์ชนก ศรี', 'หอบหืดกำเริบ', _Esi.two,
      summary:
          'หญิงไทย 28 ปี หอบหืดกำเริบหลังสัมผัสฝุ่น หายใจมีเสียงวี้ดทั้งสองข้าง พูดได้เป็นคำ ๆ พ่นยาขยายหลอดลมไปแล้วสองรอบ อาการดีขึ้นบางส่วน ยังต้องเฝ้าระวังการหายใจล้มเหลว'),
  _Bed('B3', 'นางสุดา กมลรัตน์', 'ไข้สูง', _Esi.four,
      summary:
          'หญิงไทย 41 ปี ไข้สูงสามวันร่วมกับปวดเมื่อยตามตัวและผื่นแดง ไม่มีอาการทางระบบหายใจ ความดันและออกซิเจนปกติ รอผลตรวจหาสาเหตุของไข้'),
  _Bed('B4', 'เตียงว่าง', '', _Esi.five, vacant: true),
  _Bed('B5', 'เตียงว่าง', '', _Esi.five, vacant: true),
];

class ErBedViewWidget extends StatefulWidget {
  const ErBedViewWidget({super.key});

  static const String routeName = 'Er_Bed_View';
  static const String routePath = 'erBedView';

  @override
  State<ErBedViewWidget> createState() => _ErBedViewWidgetState();
}

class _ErBedViewWidgetState extends State<ErBedViewWidget> {
  int _selected = 0;

  /// ตำแหน่งป้ายเตียงบนจอ ฝั่งสามมิติส่งกลับมาถี่มาก
  /// ใช้ ValueNotifier เพื่อให้วาดใหม่เฉพาะชั้นป้าย ไม่ลาก rebuild ทั้งหน้า
  final ValueNotifier<Map<String, ErBedScreenPos>> _bedPos =
      ValueNotifier(const {});

  // ---- แผงปรับฉากสามมิติ (สำหรับจูนตอนออกแบบ) ----
  bool _debug = false;
  ErCam _cam = const ErCam();

  /// ทิศทางที่เพิ่งเลื่อน ใช้กำหนดว่าการ์ดใหม่จะเลื่อนเข้ามาจากฝั่งไหน
  bool _forward = true;

  void _select(int index) => setState(() {
        if (index != _selected) {
          final diff = (index - _selected + _beds.length) % _beds.length;
          _forward = diff <= _beds.length / 2;
        }
        _selected = index;
      });

  /// เปิดหน้าอื่นตามชื่อเส้นทางที่ลงทะเบียนไว้ใน nav.dart
  void _go(String routeName) {
    try {
      context.pushNamed(routeName);
    } catch (e) {
      debugPrint('เปิดเส้นทาง $routeName ไม่ได้: $e');
    }
  }

  /// คัดลอกค่ากล้องที่ปรับไว้เป็นโค้ด Dart ผู้ใช้จึงส่งค่ากลับมาให้ตั้งเป็น
  /// ค่าเริ่มต้นในโค้ดได้เลย โดยไม่ต้องจดตัวเลขเอง
  Future<void> _copyCamSetting() async {
    final text = 'ErCam(\n'
        '  iso: ${_cam.iso},\n'
        '  zoom: ${_cam.zoom.toStringAsFixed(2)},\n'
        '  pitch: ${_cam.pitch.toStringAsFixed(1)},\n'
        '  bedTurn: ${_cam.bedTurn.toStringAsFixed(1)},\n'
        '  screenX: ${_cam.screenX.toStringAsFixed(0)},\n'
        '  shiftY: ${_cam.shiftY.toStringAsFixed(2)},\n'
        '  height: ${_cam.height.toStringAsFixed(2)},\n'
        '  distance: ${_cam.distance.toStringAsFixed(2)},\n'
        '  fov: ${_cam.fov.toStringAsFixed(1)},\n'
        '  yaw: ${_cam.yaw.toStringAsFixed(1)},\n'
        '  lookY: ${_cam.lookY.toStringAsFixed(2)},\n'
        '  tagLift: ${_cam.tagLift.toStringAsFixed(2)},\n'
        ')';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 420.0,
        backgroundColor: _ink,
        duration: const Duration(seconds: 3),
        content: Text('คัดลอกค่ากล้องแล้ว วางส่งกลับมาได้เลย',
            style: _t(12.5, color: Colors.white)),
      ),
    );
  }

  final ScrollController _stripScroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  /// คำค้นของแถบล่าง กรองจากรหัสเตียง ชื่อ และอาการ
  String _query = '';

  @override
  void initState() {
    super.initState();
    // กระดานเตียงออกแบบมาสำหรับจอแนวนอน บังคับหมุนตอนเข้าหน้า
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _stripScroll.dispose();
    _bedPos.dispose();
    _search.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- text helpers
  TextStyle _t(
    double size, {
    Color color = _ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.25,
    double spacing = 0,
  }) =>
      GoogleFonts.notoSansThai(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
      );

  TextStyle _num(
    double size, {
    Color color = _ink,
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.notoSansThai(
        fontSize: size,
        color: color,
        fontWeight: weight,
        height: 1.1,
      );

  // ------------------------------------------------------------------ top bar
  Widget _sideNavItem(IconData icon, String label,
          {bool active = false, int? badge, VoidCallback? onTap}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: active ? _blue : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon,
                        size: 19.0, color: active ? Colors.white : _ink2),
                    if (badge != null)
                      Positioned(
                        right: -7.0,
                        top: -5.0,
                        child: Container(
                          width: 15.0,
                          height: 15.0,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: _red, shape: BoxShape.circle),
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
                    style: _t(10.5,
                        color: active ? Colors.white : _ink2,
                        weight: active ? FontWeight.w600 : FontWeight.w400)),
              ],
            ),
          ),
        ),
      );

  /// แถบเมนูแนวตั้งด้านซ้าย แทนแถบบนเดิม คืนพื้นที่แนวสูงให้ฉาก
  Widget _sideBar() => Container(
        width: 96.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: _panel,
          border: const Border(right: BorderSide(color: _line)),
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/ChatGPT_Image_18_.._2568_10_55_29.png',
              width: 40.0,
              height: 40.0,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4.0),
            Text('ER Module',
                style: _t(10.5, weight: FontWeight.w700),
                textAlign: TextAlign.center),
            Text('ห้องฉุกเฉิน',
                style: _t(9.5, color: _ink3), textAlign: TextAlign.center),
            const SizedBox(height: 12.0),
            Container(height: 1.0, color: _line),
            const SizedBox(height: 10.0),
            _sideNavItem(Icons.grid_view_rounded, 'มุมมองเตียง', active: true),
            _sideNavItem(Icons.people_alt_rounded, 'รายชื่อผู้ป่วย',
                onTap: () => _go('ER_Homepage')),
            _sideNavItem(Icons.change_history_rounded, 'คัดแยก',
                onTap: () => _go('Add_Screening')),
            _sideNavItem(Icons.notifications_rounded, 'แจ้งเตือน', badge: 3),
            _sideNavItem(Icons.more_horiz_rounded, 'เพิ่มเติม'),
            const Spacer(),
            _sideNavItem(Icons.tune_rounded, 'ปรับฉาก',
                active: _debug, onTap: () => setState(() => _debug = !_debug)),
            Container(height: 1.0, color: _line),
            const SizedBox(height: 8.0),
            Text('10:24', style: _num(16.0, weight: FontWeight.w600)),
            Text('27 พ.ค. 2568',
                style: _t(9.5, color: _ink3), textAlign: TextAlign.center),
            const SizedBox(height: 8.0),
            Container(
              width: 32.0,
              height: 32.0,
              decoration: const BoxDecoration(
                  color: _panelSoft, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: _ink2, size: 18.0),
            ),
            const SizedBox(height: 3.0),
            Text('พยาบาล ER',
                style: _t(9.5, color: _ink2), textAlign: TextAlign.center),
          ],
        ),
      );

  // --------------------------------------------------------------- left panel
  // -------------------------------------------------------------- right rail
  // ------------------------------------------------------------------- stage
  /// ป้ายเตียงที่ลอยเหนือเตียงในฉาก สีบอกระดับคัดแยก ตัวเลขกำกับซ้ำ
  /// เพื่อไม่ให้ต้องอ่านจากสีอย่างเดียว
  Widget _bedTag(_Bed bed, {bool active = false}) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(
            horizontal: active ? 12.0 : 8.0, vertical: active ? 7.0 : 4.0),
        decoration: BoxDecoration(
          color: bed.vacant ? _panel : bed.esi.color,
          borderRadius: BorderRadius.circular(9.0),
          border: Border.all(
              color:
                  active ? Colors.white : bed.esi.color.withValues(alpha: 0.4),
              width: active ? 2.0 : 1.0),
          boxShadow: [
            BoxShadow(
              color: active
                  ? bed.esi.color.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.14),
              blurRadius: active ? 20.0 : 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${bed.code} · ESI ${bed.esi.level}',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: _num(active ? 12.5 : 10.5,
                    color: bed.vacant ? _ink2 : Colors.white,
                    weight: FontWeight.w600)),
            if (active && !bed.vacant)
              Text(bed.name,
                  style:
                      _t(10.5, color: Colors.white, weight: FontWeight.w500)),
          ],
        ),
      );

  /// ฉากห้องฉุกเฉินสามมิติจริง เต็มจอ เป็นพื้นหลังของทั้งหน้า
  ///
  /// จำนวนเตียงในฉากมาจากรายการเตียงจริง แตะเตียงบนฉากได้ และเมื่อเลือกเตียง
  /// กล้องจะแพนไปหาเตียงนั้น ป้ายเตียงเป็นวิดเจ็ตของ Flutter ที่ลอยตาม
  /// ตำแหน่งบนจอซึ่งฝั่งสามมิติคำนวณส่งกลับมาทุกเฟรม
  Widget _stage() => Stack(
        children: [
          Positioned.fill(
            child: ErRoom3D(
              beds: [
                for (final b in _beds)
                  ErRoomBed(code: b.code, color: b.esi.color, vacant: b.vacant),
              ],
              selectedCode: _beds[_selected].code,
              cam: _cam,
              onBedTap: (code) {
                final i = _beds.indexWhere((b) => b.code == code);
                if (i >= 0) _select(i);
              },
              onPositions: (items) {
                if (!mounted) return;
                _bedPos.value = {for (final p in items) p.code: p};
              },
            ),
          ),
          // ชั้นป้ายเตียงวาดใหม่ตามตำแหน่งที่ฝั่งสามมิติส่งมา
          // แยก RepaintBoundary ไว้ ไม่ให้กระทบการ์ดอื่นบนหน้า
          Positioned.fill(
            child: RepaintBoundary(
              child: ValueListenableBuilder<Map<String, ErBedScreenPos>>(
                valueListenable: _bedPos,
                builder: (context, pos, _) => Stack(
                  children: [
                    for (int i = 0; i < _beds.length; i++)
                      if (pos[_beds[i].code]?.visible ?? false)
                        Positioned(
                          left: pos[_beds[i].code]!.dx - 62.0,
                          top: pos[_beds[i].code]!.dy - 14.0,
                          width: 124.0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () => _select(i),
                              child: _bedTag(_beds[i], active: i == _selected),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  // ---------------------------------------------------------- debugger ฉาก 3D
  Widget _slider(String label, double value, double min, double max,
      String unit, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        children: [
          SizedBox(
              width: 74.0, child: Text(label, style: _t(11.0, color: _ink2))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 12.0),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                activeColor: _blue,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 52.0,
            child: Text('${value.toStringAsFixed(2)}$unit',
                textAlign: TextAlign.right,
                style: _num(11.0, color: _ink, weight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  /// แผงปรับฉากสามมิติ ใช้จูนมุมกล้องตอนออกแบบ ไม่ใช่ของผู้ใช้ปลายทาง
  Widget _debugPanel() => Container(
        width: 330.0,
        padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 12.0),
        decoration: _glass(radius: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded, size: 16.0, color: _ink2),
                const SizedBox(width: 6.0),
                Text('ปรับฉากสามมิติ',
                    style: _t(12.5, weight: FontWeight.w600)),
                const Spacer(),
                InkWell(
                  onTap: _copyCamSetting,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy_rounded, size: 13.0, color: _blue),
                      const SizedBox(width: 4.0),
                      Text('คัดลอกค่า',
                          style:
                              _t(11.0, color: _blue, weight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                InkWell(
                  onTap: () => setState(() => _cam = const ErCam()),
                  child: Text('คืนค่าเริ่มต้น',
                      style: _t(11.0, color: _blue, weight: FontWeight.w500)),
                ),
                const SizedBox(width: 10.0),
                InkWell(
                  onTap: () => setState(() => _debug = false),
                  child:
                      const Icon(Icons.close_rounded, size: 16.0, color: _ink3),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Row(
              children: [
                Text('โหมดภาพ', style: _t(11.0, color: _ink2)),
                const SizedBox(width: 10.0),
                for (final mode in const [false, true])
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100.0),
                      onTap: () =>
                          setState(() => _cam = _cam.copyWith(iso: mode)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: _cam.iso == mode ? _blue : _panelSoft,
                          borderRadius: BorderRadius.circular(100.0),
                          border: Border.all(color: _line),
                        ),
                        child: Text(mode ? 'ไอโซเมตริก' : 'เพอร์สเปกทีฟ',
                            style: _t(11.0,
                                color: _cam.iso == mode ? Colors.white : _ink2,
                                weight: FontWeight.w500)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6.0),
            if (_cam.iso) ...[
              _slider('ขนาดภาพ', _cam.zoom, 1.5, 14.0, ' ม.',
                  (v) => setState(() => _cam = _cam.copyWith(zoom: v))),
              _slider('มุมก้ม', _cam.pitch, 5.0, 80.0, '°',
                  (v) => setState(() => _cam = _cam.copyWith(pitch: v))),
            ] else ...[
              _slider('ความสูงกล้อง', _cam.height, 0.5, 7.0, ' ม.',
                  (v) => setState(() => _cam = _cam.copyWith(height: v))),
              _slider('ระยะห่าง', _cam.distance, 1.2, 16.0, ' ม.',
                  (v) => setState(() => _cam = _cam.copyWith(distance: v))),
              _slider('มุมมองภาพ', _cam.fov, 16.0, 70.0, '°',
                  (v) => setState(() => _cam = _cam.copyWith(fov: v))),
            ],
            _slider('มุมเอียง', _cam.yaw, -90.0, 90.0, '°',
                (v) => setState(() => _cam = _cam.copyWith(yaw: v))),
            _slider('จุดเล็ง', _cam.lookY, -2.0, 2.5, ' ม.',
                (v) => setState(() => _cam = _cam.copyWith(lookY: v))),
            _slider('เลื่อนแนวนอน', _cam.shiftX, -6.0, 6.0, ' ม.',
                (v) => setState(() => _cam = _cam.copyWith(shiftX: v))),
            _slider('เลื่อนแนวตั้ง', _cam.shiftY, -3.0, 3.0, ' ม.',
                (v) => setState(() => _cam = _cam.copyWith(shiftY: v))),
            _slider('หมุนเตียง', _cam.bedTurn, -180.0, 180.0, '°',
                (v) => setState(() => _cam = _cam.copyWith(bedTurn: v))),
            _slider('เลื่อนภาพบนจอ', _cam.screenX, -500.0, 500.0, ' px',
                (v) => setState(() => _cam = _cam.copyWith(screenX: v))),
            _slider('ยกป้ายเตียง', _cam.tagLift, -0.3, 1.2, ' ม.',
                (v) => setState(() => _cam = _cam.copyWith(tagLift: v))),
            const SizedBox(height: 4.0),
            Text(
              'เตียง ${_beds.length} ช่อง · เลือก ${_beds[_selected].code} · '
              'ป้ายที่มองเห็น '
              '${_bedPos.value.values.where((p) => p.visible).length}',
              style: _t(10.5, color: _ink3),
            ),
          ],
        ),
      );

  // ------------------------------------------------------------ patient card
  /// ป้ายระดับคัดแยก ใช้รูปแบบเดียวกับวิดเจ็ต ESI เดิมของโปรเจกต์
  Widget _esiPill(_Esi esi) => Container(
        padding: const EdgeInsets.fromLTRB(6.0, 3.0, 12.0, 3.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const AlignmentDirectional(0.0, -1.0),
            end: const AlignmentDirectional(0.0, 1.0),
            colors: [
              esi.c1.withValues(alpha: 0.15),
              esi.c2.withValues(alpha: 0.16),
            ],
          ),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const AlignmentDirectional(0.0, -1.0),
                  end: const AlignmentDirectional(0.0, 1.0),
                  colors: [esi.c1, esi.c2],
                ),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5.0),
            Text('ESI ${esi.level} · ${esi.en}',
                style: _t(11.5, color: esi.c2, weight: FontWeight.w500)),
          ],
        ),
      );

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Text(label,
            style: _t(12.0, color: Colors.white, weight: FontWeight.w500)),
      );

  Widget _cardAction(IconData icon, String label) => Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: _panelSoft,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.0, color: _ink2),
            const SizedBox(width: 8.0),
            Text(label, style: _t(13.0, weight: FontWeight.w500)),
          ],
        ),
      );

  /// การ์ดผู้ป่วยที่กำลังดู ลอยทับฉากตรงกลาง แบ่งสองฝั่ง
  /// ซ้ายคือตัวผู้ป่วยและอาการ ขวาคือสัญญาณชีพ
  Widget _patientPanel() {
    final b = _beds[_selected];
    return Container(
      width: 660.0,
      padding: const EdgeInsets.all(12.0),
      decoration: _glass(radius: 22.0),
      // ความสูงของการ์ดมาจากเนื้อหาจริง ไม่ต้องเลื่อน
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _chip(b.code, b.esi.color),
              const SizedBox(width: 6.0),
              _esiPill(b.esi),
              const SizedBox(width: 6.0),
              if (!b.vacant)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(color: _red.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('กู้ชีพ',
                          style:
                              _t(11.5, color: _red, weight: FontWeight.w600)),
                      const SizedBox(width: 5.0),
                      const Icon(Icons.warning_amber_rounded,
                          size: 13.0, color: _red),
                    ],
                  ),
                ),
              const Spacer(),
              if (!b.vacant)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('เวลาอยู่ในห้องฉุกเฉิน',
                        style: _t(10.0, color: _ink3)),
                    Text('18 นาที', style: _num(16.0, weight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36.0,
                          height: 36.0,
                          decoration: const BoxDecoration(
                              color: _panelSoft, shape: BoxShape.circle),
                          child: const Icon(Icons.person_rounded,
                              color: _ink2, size: 20.0),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  b.vacant
                                      ? 'เตียงว่าง พร้อมรับผู้ป่วย'
                                      : b.name,
                                  style: _t(17.0, weight: FontWeight.w600)),
                              const SizedBox(height: 2.0),
                              Text(
                                  b.vacant
                                      ? 'เตียง ${b.code} · ทำความสะอาดแล้ว'
                                      : 'HN 670123456  |  45 ปี / ชาย  |  ไทย',
                                  style: _t(11.5, color: _ink2)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!b.vacant) ...[
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 13.0, color: _blue),
                          const SizedBox(width: 5.0),
                          Text('สรุปโดยระบบ',
                              style: _t(10.5,
                                  color: _blue, weight: FontWeight.w600)),
                          const SizedBox(width: 6.0),
                          Text('ตรวจทานก่อนใช้ตัดสินใจ',
                              style: _t(9.5, color: _ink3)),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        b.summary.isEmpty ? b.complaint : b.summary,
                        style: _t(12.5, height: 1.45, color: _ink),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14.0),
              if (!b.vacant)
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: _panelSoft,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: _line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('สัญญาณชีพ', style: _t(10.5, color: _ink3)),
                            const Spacer(),
                            Text('วัดซ้ำทุก 15 นาที',
                                style: _t(9.5, color: _ink3)),
                          ],
                        ),
                        const SizedBox(height: 6.0),
                        SizedBox(
                          height: 104.0,
                          child: CustomPaint(
                            painter: _VitalsChart(
                                _vitals, _line, _vitalTimes, _ink3),
                            size: Size.infinite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (!b.vacant) ...[
            const SizedBox(height: 12.0),
            Row(
              children: [
                _cardAction(Icons.person_search_rounded, 'ข้อมูลผู้ป่วย'),
                _cardAction(Icons.assignment_rounded, 'สั่งการรักษา'),
                _cardAction(Icons.science_rounded, 'ผลตรวจ'),
                _cardAction(Icons.edit_note_rounded, 'บันทึก'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.call_rounded,
                          size: 16.0, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Text('ขอความช่วยเหลือ',
                          style: _t(13.0,
                              color: Colors.white, weight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// การ์ดสถิติลอยมุมซ้ายบนของฉาก สรุปภาพรวมห้องแบบอ่านผ่านตา
  Widget _statsCard() {
    final counts = <_Esi, int>{
      for (final e in _Esi.values)
        e: _beds.where((b) => !b.vacant && b.esi == e).length,
    };
    final used = _beds.where((b) => !b.vacant).length;

    Widget stat(String label, String value, Color color) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _t(10.0, color: _ink3)),
            const SizedBox(height: 1.0),
            Text(value,
                style: _num(19.0, color: color, weight: FontWeight.w600)),
          ],
        );

    Widget bar() {
      final total = _beds.length;
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: SizedBox(
          height: 6.0,
          child: Row(
            children: [
              for (final e in _Esi.values)
                if ((counts[e] ?? 0) > 0)
                  Expanded(
                    flex: counts[e]!,
                    child: Container(color: e.color),
                  ),
              if (total - used > 0)
                Expanded(
                  flex: total - used,
                  child: Container(color: _line),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 244.0,
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 13.0),
      decoration: _glass(radius: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_hospital_rounded,
                  size: 15.0, color: _ink2),
              const SizedBox(width: 6.0),
              Text('ภาพรวมห้องฉุกเฉิน',
                  style: _t(12.0, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: stat('เตียงที่ใช้', '$used / ${_beds.length}', _ink)),
              Expanded(child: stat('วิกฤต', '${counts[_Esi.one] ?? 0}', _red)),
              Expanded(
                  child: stat('ว่าง', '${_beds.where((b) => b.vacant).length}',
                      _green)),
            ],
          ),
          const SizedBox(height: 10.0),
          bar(),
          const SizedBox(height: 10.0),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 13.0, color: _ink3),
              const SizedBox(width: 5.0),
              Text('รอนานสุด', style: _t(10.5, color: _ink3)),
              const Spacer(),
              Text('52 นาที',
                  style: _num(12.5, color: _amber, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 3.0),
          Row(
            children: [
              const Icon(Icons.pending_actions_rounded,
                  size: 13.0, color: _ink3),
              const SizedBox(width: 5.0),
              Text('งานค้าง', style: _t(10.5, color: _ink3)),
              const Spacer(),
              Text('5 รายการ',
                  style: _num(12.5, color: _ink, weight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  /// การ์ดบันทึกกิจกรรมของพยาบาลและแพทย์ ลอยชิดขวาของฉาก
  Widget _timelineCard() => Container(
        width: 268.0,
        padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
        decoration: _glass(radius: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 15.0, color: _ink2),
                const SizedBox(width: 6.0),
                Text('บันทึกกิจกรรมล่าสุด',
                    style: _t(12.0, weight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                _logLegend(_blue, 'แพทย์'),
                const SizedBox(width: 12.0),
                _logLegend(_green, 'พยาบาล'),
              ],
            ),
            const SizedBox(height: 10.0),
            for (final e in _activityLog) _logRow(e),
          ],
        ),
      );

  Widget _logLegend(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.0,
            height: 7.0,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5.0),
          Text(label, style: _t(10.0, color: _ink3)),
        ],
      );

  /// หนึ่งบรรทัดของบันทึกกิจกรรม เวลา เส้นเชื่อม และรายละเอียด
  Widget _logRow(_LogEntry e) => Padding(
        padding: const EdgeInsets.only(bottom: 7.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34.0,
              child: Text(e.time,
                  style: _num(10.5, color: _ink3, weight: FontWeight.w500)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0, right: 7.0),
              child: Container(
                width: 7.0,
                height: 7.0,
                decoration: BoxDecoration(
                  color: e.byDoctor ? _blue : _green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.text,
                      style: _t(10.5, color: _ink, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text('${e.bed} · ${e.who}', style: _t(9.5, color: _ink3)),
                ],
              ),
            ),
          ],
        ),
      );

  /// การ์ดผู้ป่วยแบบซ้อน เห็นการ์ดของเตียงก่อนหน้าและถัดไปโผล่ข้าง ๆ
  /// การ์ดผู้ป่วยเดี่ยว ไม่มีการ์ดซ้อนข้าง
  Widget _patientCarousel() => AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) {
          final slide = Tween<Offset>(
            begin: Offset(_forward ? 0.16 : -0.16, 0),
            end: Offset.zero,
          ).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: slide,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(anim),
                child: child,
              ),
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(_beds[_selected].code),
          child: _patientPanel(),
        ),
      );

  Widget _stepButton(IconData icon, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(100.0),
        onTap: onTap,
        child: Container(
          width: 54.0,
          height: 54.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _panel.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: _line),
          ),
          child: Icon(icon, color: _ink, size: 24.0),
        ),
      );

  // -------------------------------------------------------------- bed strip
  Widget _stripCard(int index) {
    final b = _beds[index];
    final on = index == _selected;
    return GestureDetector(
      onTap: () => _select(index),
      child: Container(
        width: 148.0,
        margin: const EdgeInsets.only(right: 10.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
              color: on ? b.esi.color : _line, width: on ? 2.0 : 1.0),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: b.esi.color,
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Text(b.code,
                            style: _num(12.0,
                                color: Colors.white, weight: FontWeight.w600)),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Opacity(
                    opacity: b.vacant ? 0.35 : 0.95,
                    child: Image.asset('assets/images/bed/bed_thumb.png',
                        height: 48.0, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 2.0),
                  Text(b.name,
                      style: _t(12.5, weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (b.complaint.isNotEmpty)
                    Text(b.complaint,
                        style: _t(11.0, color: _ink2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (!b.vacant)
              // รูปผู้ป่วยเป็นวงกลม ลอยอยู่เหนือเตียง กึ่งกลางการ์ด
              Positioned(
                left: 0.0,
                right: 0.0,
                top: 26.0,
                child: Center(
                  child: Container(
                    width: 46.0,
                    height: 46.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        _faceUrl(index),
                        width: 46.0,
                        height: 46.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: _panelSoft,
                          alignment: Alignment.center,
                          child: const Icon(Icons.person_rounded,
                              size: 20.0, color: _ink3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// สถานะเตียงแบบย่อ วางมุมขวาบนของแถบล่าง แทนแผงเต็มด้านซ้าย
  Widget _bedStatusCompact() {
    final counts = <_Esi, int>{
      for (final e in _Esi.values)
        e: _beds.where((b) => !b.vacant && b.esi == e).length,
    };
    final used = _beds.where((b) => !b.vacant).length;
    Widget pill(_Esi esi) => Container(
          margin: const EdgeInsets.only(left: 6.0),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: esi.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100.0),
            border: Border.all(color: esi.color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7.0,
                height: 7.0,
                decoration:
                    BoxDecoration(color: esi.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5.0),
              Text('ESI ${esi.level}', style: _t(10.5, color: _ink2)),
              const SizedBox(width: 4.0),
              Text('${counts[esi] ?? 0}',
                  style: _num(11.5, color: esi.color, weight: FontWeight.w600)),
            ],
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('เตียงที่ใช้ ', style: _t(11.0, color: _ink3)),
        Text('$used', style: _num(15.0, weight: FontWeight.w600)),
        Text(' / ${_beds.length}', style: _num(11.5, color: _ink2)),
        const SizedBox(width: 4.0),
        for (final e in _Esi.values) pill(e),
        const SizedBox(width: 8.0),
        InkWell(
          borderRadius: BorderRadius.circular(100.0),
          onTap: () {},
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: _panelSoft,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(color: _line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dashboard_rounded, size: 14.0, color: _ink2),
                const SizedBox(width: 6.0),
                Text('ผังเตียง', style: _t(11.5, weight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// เตียงที่ตรงกับคำค้น ถ้าไม่ได้พิมพ์อะไรคือทุกเตียง
  List<int> get _filtered {
    final q = _query.trim().toLowerCase();
    final all = [for (int i = 0; i < _beds.length; i++) i];
    if (q.isEmpty) return all;
    return all.where((i) {
      final b = _beds[i];
      return b.code.toLowerCase().contains(q) ||
          b.name.toLowerCase().contains(q) ||
          b.complaint.toLowerCase().contains(q) ||
          b.esi.en.toLowerCase().contains(q) ||
          b.esi.label.contains(q);
    }).toList();
  }

  Widget _searchField() => SizedBox(
        width: 240.0,
        height: 32.0,
        child: TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          style: _t(12.0),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _panelSoft,
            hintText: 'ค้นหาเตียง ชื่อ หรืออาการ',
            hintStyle: _t(11.5, color: _ink3),
            prefixIcon:
                const Icon(Icons.search_rounded, size: 16.0, color: _ink3),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
            suffixIcon: _query.isEmpty
                ? null
                : InkWell(
                    onTap: () => setState(() {
                      _search.clear();
                      _query = '';
                    }),
                    child: const Icon(Icons.close_rounded,
                        size: 15.0, color: _ink3),
                  ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 30.0, minHeight: 30.0),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: const BorderSide(color: _line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: const BorderSide(color: _line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100.0),
              borderSide: const BorderSide(color: _blue),
            ),
          ),
        ),
      );

  Widget _bottomStrip() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 8.0),
      decoration: BoxDecoration(
        color: _panel,
        border: const Border(top: BorderSide(color: _line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: _panelSoft,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: _line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('เรียงตาม ', style: _t(12.0, color: _ink2)),
                    Text('ความเร่งด่วน',
                        style: _t(12.0, weight: FontWeight.w600)),
                    const SizedBox(width: 4.0),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 17.0, color: _ink2),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              _searchField(),
              if (_query.isNotEmpty) ...[
                const SizedBox(width: 8.0),
                Text('พบ ${_filtered.length} เตียง',
                    style: _t(11.0, color: _ink2)),
              ],
              const Spacer(),
              _bedStatusCompact(),
            ],
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            height: 126.0,
            child: Builder(builder: (context) {
              final idx = _filtered;
              if (idx.isEmpty) {
                return Center(
                  child: Text('ไม่พบเตียงที่ตรงกับคำค้น',
                      style: _t(12.0, color: _ink3)),
                );
              }
              return ListView.builder(
                controller: _stripScroll,
                scrollDirection: Axis.horizontal,
                itemCount: idx.length,
                itemBuilder: (context, i) => _stripCard(idx[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ฉากสามมิติเป็นพื้นหลังของทั้งหน้า ทุกแผงลอยทับแบบโปร่งแสง
          Positioned.fill(child: _stage()),
          // ไล่ขาวจาง ๆ ตามขอบจอ ให้ฉากค่อย ๆ จมหายไปกับพื้นหลังของหน้า
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          _bg,
                          _bg.withValues(alpha: 0.0),
                          _bg.withValues(alpha: 0.0),
                          _bg,
                        ],
                        stops: const [0.0, 0.16, 0.84, 1.0],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _bg,
                          _bg.withValues(alpha: 0.0),
                          _bg.withValues(alpha: 0.0),
                          _bg,
                        ],
                        stops: const [0.0, 0.14, 0.82, 1.0],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                _sideBar(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // แถวบน: ภาพรวมซ้าย บันทึกกิจกรรมขวา
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _statsCard(),
                                  const Spacer(),
                                  _timelineCard(),
                                ],
                              ),
                              // แถวล่าง: การ์ดผู้ป่วยแบบซ้อน พร้อมปุ่มเลื่อนเตียง
                              Flexible(
                                fit: FlexFit.loose,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _stepButton(
                                      Icons.chevron_left_rounded,
                                      () => _select(
                                          (_selected - 1 + _beds.length) %
                                              _beds.length),
                                    ),
                                    const SizedBox(width: 10.0),
                                    _patientCarousel(),
                                    const SizedBox(width: 10.0),
                                    _stepButton(
                                      Icons.chevron_right_rounded,
                                      () => _select(
                                          (_selected + 1) % _beds.length),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      RepaintBoundary(child: _bottomStrip()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_debug)
            Positioned(right: 14.0, bottom: 14.0, child: _debugPanel()),
        ],
      ),
    );
  }
}
