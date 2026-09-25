/// สัญญาณชีพที่ใช้ร่วมกันระหว่างหน้าผังเตียงกับหน้ากระแสงาน
///
/// แยกออกมาเพราะทั้งสองหน้าต้องวาดกราฟชุดเดียวกัน
/// ยังเป็นข้อมูลจำลอง ยังไม่ได้ต่อกับตารางสัญญาณชีพจริง
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// ช่วงจัดโครงหน้า ยังไม่ลงสี ทุกเส้นและตัวเลขใช้โทนเทา
/// ปรับเป็น false พร้อมกับ _mono ในหน้ากระแสงานเมื่อจะลงสีจริง
const bool erMono = false;

const Color _blue = erMono ? Color(0xFF3C4043) : Color(0xFF001B7C);
const Color _red = erMono ? Color(0xFF202124) : Color(0xFFD93025);
const Color _amber = erMono ? Color(0xFF80868B) : Color(0xFFE8A33D);
const Color _ink = Color(0xFF202124);

/// ค่าสัญญาณชีพหนึ่งตัว พร้อมค่าที่วัดซ้ำเป็นระยะ
class ErVital {
  const ErVital({
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
      (erMono
          ? const {
              'HR': Color(0xFF202124),
              'BP': Color(0xFF3C4043),
              'SpO₂': Color(0xFF5F6368),
              'RR': Color(0xFF80868B),
              'BT': Color(0xFF9AA0A6),
            }
          // กฎ 60-30-10: ทุกเส้นสีหลักเดียว ความผิดปกติใช้สีเตือน (color) แยกเอง
          : const {
              'HR': Color(0xFF001B7C),
              'SpO₂': Color(0xFF001B7C),
              'BP': Color(0xFF001B7C),
              'RR': Color(0xFF001B7C),
              'BT': Color(0xFF001B7C),
            })[label] ??
      _blue;

  double get latest => series.last;
  double get previous => series.length > 1 ? series[series.length - 2] : latest;
}

const List<String> erVitalTimes = [
  '09:22 น.',
  '09:37 น.',
  '09:52 น.',
  '10:07 น.',
  '10:22 น.',
];

const List<ErVital> erVitals = [
  ErVital(
    icon: Icons.favorite_rounded,
    label: 'HR',
    unit: 'bpm',
    series: [96, 104, 112, 121, 128],
    color: _red,
  ),
  ErVital(
    icon: Icons.monitor_heart_rounded,
    label: 'BP',
    unit: 'mmHg',
    series: [112, 104, 98, 92, 88],
    color: _red,
    display: '88/56',
  ),
  ErVital(
    icon: Icons.bubble_chart_rounded,
    label: 'SpO₂',
    unit: '%',
    series: [97, 95, 93, 91, 89],
    color: _red,
  ),
  ErVital(
    icon: Icons.air_rounded,
    label: 'RR',
    unit: '/min',
    series: [18, 20, 22, 25, 28],
    color: _amber,
  ),
  ErVital(
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
class ErVitalsChart extends CustomPainter {
  ErVitalsChart(this.vitals, this.gridColor, this.timeLabels, this.mutedColor);

  final List<ErVital> vitals;
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
      final tp = _tp(
          timeLabels[i],
          TextStyle(
              fontFamily: 'NotoSansThai',
              fontSize: 8.5,
              color: mutedColor,
              height: 1.0));
      tp.paint(canvas, Offset(x - tp.width / 2, plotH + 3));
    }

    // เรียงป้ายปลายเส้นไม่ให้ทับกัน
    final ends = <ErVital, double>{};
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
    // แล้วบีบทั้งชุดกลับเข้ากรอบ ไม่ให้ป้ายล่างสุดหลุดไปทับแถวเวลา
    const gap = 15.0;
    const pad = 7.0;
    final sorted = ends.keys.toList()
      ..sort((a, b) => ends[a]!.compareTo(ends[b]!));
    final placed = <ErVital, double>{};
    double? prev;
    for (final v in sorted) {
      var y = ends[v]!;
      if (prev != null && y - prev < gap) y = prev + gap;
      placed[v] = y;
      prev = y;
    }
    // ล้นล่าง: เลื่อนขึ้นทั้งชุด แล้วไล่ดันลงจากบนไม่ให้ล้นบนแทน
    final overflow = placed[sorted.last]! - (plotH - pad);
    if (overflow > 0) {
      double? up;
      for (final v in sorted) {
        var y = placed[v]! - overflow;
        if (y < pad) y = pad;
        if (up != null && y - up < gap) y = up + gap;
        placed[v] = y;
        up = y;
      }
    }
    for (final v in sorted) {
      final y = placed[v]!;

      final label = v.display ??
          (v.latest % 1 == 0
              ? v.latest.toStringAsFixed(0)
              : v.latest.toStringAsFixed(1));
      final name = _tp(
          '${v.label} ',
          TextStyle(
              fontFamily: 'NotoSansThai',
              fontSize: 10.0,
              color: mutedColor,
              height: 1.0));
      final value = _tp(
          label,
          TextStyle(
              fontFamily: 'NotoSansThai',
              fontSize: 12.5,
              color: v.color,
              fontWeight: FontWeight.w700,
              height: 1.0));
      final unit = _tp(
          ' ${v.unit}',
          TextStyle(
              fontFamily: 'NotoSansThai',
              fontSize: 8.5,
              color: mutedColor,
              height: 1.0));

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
  bool shouldRepaint(covariant ErVitalsChart old) => old.vitals != vitals;
}

/// กราฟรวมสัญญาณชีพแบบแตะดูค่าได้ สร้างด้วย fl_chart
///
/// แต่ละเส้นปรับสเกลด้วยช่วงของตัวเอง จึงเทียบ "แนวโน้ม" กันได้ทั้งที่หน่วยต่างกัน
/// แตะหรือลากบนกราฟแล้วขึ้นค่าทุกตัวของเวลานั้นในกล่องเดียว
/// ไม่ต้องวางป้ายปลายเส้นให้ชนกันเหมือนเวอร์ชันวาดเองอีกต่อไป
class ErVitalsLineChart extends StatelessWidget {
  const ErVitalsLineChart({
    super.key,
    this.gridColor = const Color(0x22000000),
    this.mutedColor = const Color(0xFF6B7178),
    this.vitals = erVitals,
    this.timeLabels = erVitalTimes,
  });

  final Color gridColor;
  final Color mutedColor;
  final List<ErVital> vitals;
  final List<String> timeLabels;

  /// ย่อค่าจริงให้อยู่ช่วง 0–1 ตามช่วงของเส้นนั้นเอง
  static double _norm(ErVital v, int i) {
    final lo = v.series.reduce((a, b) => a < b ? a : b);
    final hi = v.series.reduce((a, b) => a > b ? a : b);
    final span = (hi - lo).abs() < 0.001 ? 1.0 : hi - lo;
    return (v.series[i] - lo) / span;
  }

  static String _fmt(ErVital v, int i) {
    if (v.display != null && i == v.series.length - 1) return v.display!;
    final x = v.series[i];
    return x % 1 == 0 ? x.toStringAsFixed(0) : x.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final n = vitals.first.series.length;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (n - 1).toDouble(),
        minY: -0.12,
        maxY: 1.12,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: false,
          verticalInterval: 1,
          getDrawingVerticalLine: (x) =>
              FlLine(color: gridColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 16,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= timeLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Text(timeLabels[i],
                      style: TextStyle(
                          fontFamily: 'NotoSansThai',
                          fontSize: 8.5,
                          height: 1.0,
                          color: mutedColor)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (bar, indexes) => [
            for (final _ in indexes)
              TouchedSpotIndicatorData(
                FlLine(color: bar.color ?? mutedColor, strokeWidth: 1.2),
                FlDotData(
                  getDotPainter: (spot, pct, b, i) => FlDotCirclePainter(
                    radius: 3.6,
                    color: bar.color ?? mutedColor,
                    strokeWidth: 1.6,
                    strokeColor: Colors.white,
                  ),
                ),
              ),
          ],
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => const Color(0xF2202124),
            tooltipRoundedRadius: 8,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) {
              // บรรทัดแรกเป็นเวลา ที่เหลือคือค่าของแต่ละเส้น ณ เวลานั้น
              return [
                for (var k = 0; k < spots.length; k++)
                  () {
                    final s = spots[k];
                    final v = vitals[s.barIndex];
                    final i = s.x.round();
                    final head = k == 0 ? '${timeLabels[i]}\n' : '';
                    return LineTooltipItem(
                      head,
                      TextStyle(
                          fontFamily: 'NotoSansThai',
                          fontSize: 9.5,
                          color: Colors.white.withValues(alpha: 0.75)),
                      children: [
                        TextSpan(
                          text: '${v.label} ',
                          style: TextStyle(
                              fontFamily: 'NotoSansThai',
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.75)),
                        ),
                        TextSpan(
                          text: '${_fmt(v, i)} ${v.unit}',
                          style: const TextStyle(
                              fontFamily: 'NotoSansThai',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                      textAlign: TextAlign.left,
                    );
                  }(),
              ];
            },
          ),
        ),
        lineBarsData: [
          for (final v in vitals)
            LineChartBarData(
              spots: [
                for (var i = 0; i < n; i++) FlSpot(i.toDouble(), _norm(v, i)),
              ],
              isCurved: true,
              curveSmoothness: 0.28,
              preventCurveOverShooting: true,
              color: v.line,
              barWidth: 2.4,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, bar) => spot.x == (n - 1),
                getDotPainter: (spot, pct, bar, i) => FlDotCirclePainter(
                  radius: 3.2,
                  color: v.line,
                  strokeWidth: 1.6,
                  strokeColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
