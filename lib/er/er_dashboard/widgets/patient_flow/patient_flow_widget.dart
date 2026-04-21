import '/er/er_dashboard/widgets/section_card/section_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PatientFlowWidget extends StatefulWidget {
  const PatientFlowWidget({super.key});

  @override
  State<PatientFlowWidget> createState() => _PatientFlowWidgetState();
}

class _PatientFlowWidgetState extends State<PatientFlowWidget>
    with SingleTickerProviderStateMixin {
  // Live snapshot at 16:00 — chart only renders data up through 16:00.
  static const _hours = [0, 2, 4, 6, 8, 10, 12, 14, 16];
  static const _inflow = [6, 4, 3, 9, 20, 27, 31, 28, 23];
  static const _outflow = [4, 3, 2, 6, 16, 23, 28, 26, 21];
  static const _admit = [2, 1, 1, 2, 4, 5, 6, 5, 4];

  static const double _currentHour = 16.0;

  late List<bool> _visible;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _visible = [true, true, true];
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _toggle(int index) {
    setState(() {
      final activeCount = _visible.where((v) => v).length;
      if (_visible[index] && activeCount == 1) {
        _visible = [true, true, true];
      } else {
        _visible[index] = !_visible[index];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final sumInflow = _inflow.reduce((a, b) => a + b);
    final sumOutflow = _outflow.reduce((a, b) => a + b);
    final sumAdmit = _admit.reduce((a, b) => a + b);

    final peakInflow = _inflow.reduce((a, b) => a > b ? a : b);
    final peakInflowHour = _hours[_inflow.indexOf(peakInflow)];
    final peakOutflow = _outflow.reduce((a, b) => a > b ? a : b);
    final peakAdmit = _admit.reduce((a, b) => a > b ? a : b);

    return DashboardSectionCard(
      number: '3',
      title: 'กระแสผู้ป่วยรายชั่วโมง',
      subtitle: 'ติดตามผู้ป่วยเข้า – ออก – นอน รพ. ตลอด 24 ชั่วโมง',
      trailing: _SectionInfoButton(
        accent: theme.info,
        onTap: () => _showSectionInfo(context, theme),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10.0, 22.0, 18.0, 18.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  theme.primaryBackground.withValues(alpha: 0.45),
                ],
              ),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: theme.alternate.withValues(alpha: 0.60),
                width: 1.0,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double minChartWidth = 720.0;
                final double chartWidth = constraints.maxWidth < minChartWidth
                    ? minChartWidth
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: chartWidth,
                    height: 260.0,
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, _) =>
                          _buildLineChart(context, theme),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14.0),
          _buildSeriesLegend(
            context,
            theme,
            totals: [sumInflow, sumOutflow, sumAdmit],
            peaks: [peakInflow, peakOutflow, peakAdmit],
            peakHour: peakInflowHour,
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, FlutterFlowTheme theme) {
    LineChartBarData series(
      List<int> data,
      Color color,
      int index, {
      bool dashed = false,
      bool fill = false,
    }) {
      final visible = _visible[index];
      final effective = visible ? color : color.withValues(alpha: 0.08);
      return LineChartBarData(
        spots: [
          for (var i = 0; i < data.length; i++)
            FlSpot(_hours[i].toDouble(), data[i].toDouble()),
        ],
        isCurved: true,
        curveSmoothness: 0.3,
        color: effective,
        barWidth: visible ? 3.4 : 1.2,
        dashArray: dashed ? [6, 4] : null,
        shadow: visible
            ? Shadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 10.0,
                offset: const Offset(0, 5),
              )
            : const Shadow(color: Colors.transparent),
        dotData: FlDotData(
          show: visible,
          getDotPainter: (spot, percent, bar, i) => FlDotCirclePainter(
            radius: 3.5,
            color: Colors.white,
            strokeWidth: 2.0,
            strokeColor: color,
          ),
        ),
        belowBarData: BarAreaData(
          show: visible && fill,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.32),
              color.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }

    final seriesList = [
      series(_inflow, theme.info, 0, fill: true),
      series(_outflow, theme.customColor10, 1, dashed: true),
      series(_admit, theme.customColor16, 2, dashed: true),
    ];

    return LineChart(
      duration: Duration.zero,
      LineChartData(
        minX: -1,
        maxX: 24,
        minY: 0,
        maxY: 38,
        lineBarsData: seriesList,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32.0,
              interval: 10,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: theme.labelSmall.override(
                  fontFamily: theme.labelSmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.labelSmallIsCustom,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28.0,
              interval: 2,
              getTitlesWidget: (value, meta) {
                final hr = value.toInt();
                if (hr % 2 != 0) return const SizedBox.shrink();
                if (hr < 0 || hr > 24) return const SizedBox.shrink();
                final display = hr == 24 ? 0 : hr;
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    '${display.toString().padLeft(2, '0')}:00',
                    style: theme.labelSmall.override(
                      fontFamily: theme.labelSmallFamily,
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.labelSmallIsCustom,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.alternate.withValues(alpha: 0.55),
            strokeWidth: 1.0,
            dashArray: const [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            VerticalLine(
              x: _currentHour,
              color: theme.customColor20
                  .withValues(alpha: 0.35 + _pulseCtrl.value * 0.60),
              strokeWidth: 1.4 + _pulseCtrl.value * 2.0,
              dashArray: const [5, 4],
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.topCenter,
                direction: LabelDirection.horizontal,
                padding: const EdgeInsets.only(bottom: 6.0),
                labelResolver: (line) => '  ตอนนี้ 16:00  ',
                style: TextStyle(
                  color: theme.customColor20,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.0,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) =>
                theme.customColor3.withValues(alpha: 0.85),
            tooltipRoundedRadius: 18.0,
            tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 14.0, vertical: 12.0),
            tooltipMargin: 14.0,
            tooltipBorder: BorderSide(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.2,
            ),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) {
              if (spots.isEmpty) return [];
              final hour = spots.first.x.toInt();
              const labelMap = ['ผู้ป่วยเข้า', 'ผู้ป่วยออก', 'รับเข้านอน'];
              final seriesColors = [
                theme.info,
                theme.customColor10,
                theme.customColor16,
              ];

              final bodyShadow = [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
              ];

              return List<LineTooltipItem?>.generate(spots.length, (i) {
                final spot = spots[i];
                final lineIndex = spot.barIndex;
                if (lineIndex < _visible.length && !_visible[lineIndex]) {
                  return null;
                }
                final label = lineIndex < labelMap.length
                    ? labelMap[lineIndex]
                    : '';
                final bulletColor = lineIndex < seriesColors.length
                    ? seriesColors[lineIndex]
                    : theme.info;

                final rowSpans = <TextSpan>[
                  TextSpan(
                    text: '●  ',
                    style: TextStyle(
                      color: bulletColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          color: bulletColor.withValues(alpha: 0.55),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: '$label · ${spot.y.toInt()} ราย',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          i == 0 ? FontWeight.w700 : FontWeight.w600,
                      fontSize: i == 0 ? 13.0 : 12.0,
                      shadows: bodyShadow,
                    ),
                  ),
                ];

                if (i == 0) {
                  return LineTooltipItem(
                    '${hour.toString().padLeft(2, '0')}:00\n',
                    TextStyle(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontWeight: FontWeight.w600,
                      fontSize: 11.0,
                      letterSpacing: 0.8,
                      shadows: bodyShadow,
                    ),
                    children: rowSpans,
                  );
                }
                return LineTooltipItem(
                  '',
                  const TextStyle(),
                  children: rowSpans,
                );
              });
            },
          ),
          getTouchedSpotIndicator: (chart, indexes) {
            return indexes.map((i) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: theme.customColor3.withValues(alpha: 0.30),
                  strokeWidth: 1.5,
                  dashArray: const [4, 4],
                ),
                FlDotData(
                  getDotPainter: (spot, percent, bar, idx) =>
                      FlDotCirclePainter(
                    radius: 6.5,
                    color: Colors.white,
                    strokeWidth: 3.0,
                    strokeColor: bar.color ?? theme.info,
                  ),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildSeriesLegend(
    BuildContext context,
    FlutterFlowTheme theme, {
    required List<int> totals,
    required List<int> peaks,
    required int peakHour,
  }) {
    final items = <_FlowSeries>[
      _FlowSeries(
        color: theme.info,
        title: 'ผู้ป่วยเข้า ER',
        description: 'จำนวนผู้ป่วยที่ลงทะเบียนเข้า ER',
        total: totals[0],
        peak: peaks[0],
        contextLabel:
            'สูงสุด ${peaks[0]} ที่ ${peakHour.toString().padLeft(2, '0')}:00',
      ),
      _FlowSeries(
        color: theme.customColor10,
        title: 'ผู้ป่วยออก ER',
        description: 'ออกจาก ER ทั้งหมด (กลับบ้าน · ย้าย · ส่งต่อ)',
        total: totals[1],
        peak: peaks[1],
        contextLabel: 'สูงสุด ${peaks[1]} ราย/ชม.',
      ),
      _FlowSeries(
        color: theme.customColor16,
        title: 'รับเข้านอน',
        description: 'ผู้ป่วยที่แพทย์สั่งรับไว้ใน Ward',
        total: totals[2],
        peak: peaks[2],
        contextLabel: 'สูงสุด ${peaks[2]} ราย/ชม.',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.alternate.withValues(alpha: 0.55),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _SeriesLegendRow(
              data: items[i],
              active: _visible[i],
              onToggle: () => _toggle(i),
            ),
            if (i < items.length - 1)
              Divider(
                height: 1.0,
                thickness: 1.0,
                color: theme.alternate.withValues(alpha: 0.55),
                indent: 8.0,
                endIndent: 8.0,
              ),
          ],
        ],
      ),
    );
  }

  void _showSectionInfo(BuildContext context, FlutterFlowTheme theme) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                        color: theme.info.withValues(alpha: 0.18),
                        blurRadius: 32.0,
                        offset: const Offset(0, 16),
                        spreadRadius: -6,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32.0,
                            height: 32.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: const AlignmentDirectional(-0.8, -1.0),
                                end: const AlignmentDirectional(0.8, 1.0),
                                colors: [
                                  theme.info,
                                  Color.lerp(theme.info, Colors.black, 0.16) ??
                                      theme.info,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.info.withValues(alpha: 0.35),
                                  blurRadius: 8.0,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.info,
                              color: Colors.white,
                              size: 12.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'กระแสผู้ป่วยรายชั่วโมง',
                                  style: theme.titleMedium.override(
                                    fontFamily: theme.titleMediumFamily,
                                    color: theme.customColor3,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !theme.titleMediumIsCustom,
                                  ),
                                ),
                                Text(
                                  'คำอธิบาย · สูตรการคำนวณ',
                                  style: theme.labelSmall.override(
                                    fontFamily: theme.labelSmallFamily,
                                    color: theme.secondaryText,
                                    letterSpacing: 0.6,
                                    useGoogleFonts:
                                        !theme.labelSmallIsCustom,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20.0,
                              color: theme.secondaryText,
                            ),
                            tooltip: 'ปิด',
                            splashRadius: 20.0,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32.0,
                              minHeight: 32.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'ติดตามจำนวนผู้ป่วยเข้า · ออก · รับเข้านอน ER ตลอด 24 ชั่วโมง โดยเก็บข้อมูลทุก 2 ชั่วโมง · แตะที่รายการด้านล่างเพื่อเปิด/ปิดเส้นกราฟ',
                        style: theme.bodyMedium.override(
                          fontFamily: theme.bodyMediumFamily,
                          color: theme.primaryText,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                          lineHeight: 1.5,
                          useGoogleFonts: !theme.bodyMediumIsCustom,
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      _formulaBlock(
                        theme,
                        accent: theme.info,
                        label: 'ผู้ป่วยเข้า ER',
                        formula:
                            'เข้า = ค้างจาก ชม.ก่อน + เข้ามาใหม่ − ออกจาก ER',
                      ),
                      const SizedBox(height: 8.0),
                      _formulaBlock(
                        theme,
                        accent: theme.customColor10,
                        label: 'ผู้ป่วยออก ER',
                        formula: 'ออก = กลับบ้าน + ย้าย Ward + ส่งต่อ (Refer)',
                      ),
                      const SizedBox(height: 8.0),
                      _formulaBlock(
                        theme,
                        accent: theme.customColor16,
                        label: 'รับเข้านอน',
                        formula: 'จำนวนผู้ป่วยที่แพทย์สั่ง Admit ต่อชั่วโมง',
                      ),
                      const SizedBox(height: 10.0),
                      _formulaBlock(
                        theme,
                        accent: theme.customColor3,
                        label: 'อัตราส่วน Peak',
                        formula:
                            'Peak Ratio = Peak Hour ÷ Avg Inflow · เช่น 31 ÷ 15 = 2.1 เท่า',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _formulaBlock(
    FlutterFlowTheme theme, {
    required Color accent,
    required String label,
    required String formula,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            formula,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.primaryText,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              lineHeight: 1.4,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowSeries {
  const _FlowSeries({
    required this.color,
    required this.title,
    required this.description,
    required this.total,
    required this.peak,
    required this.contextLabel,
  });

  final Color color;
  final String title;
  final String description;
  final int total;
  final int peak;
  final String contextLabel;
}

class _SeriesLegendRow extends StatefulWidget {
  const _SeriesLegendRow({
    required this.data,
    required this.active,
    required this.onToggle,
  });

  final _FlowSeries data;
  final bool active;
  final VoidCallback onToggle;

  @override
  State<_SeriesLegendRow> createState() => _SeriesLegendRowState();
}

class _SeriesLegendRowState extends State<_SeriesLegendRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final data = widget.data;
    final inactive = !widget.active;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: inactive ? 0.55 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: _hovered && widget.active
                  ? data.color.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 18.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.active
                          ? [
                              Color.lerp(
                                      data.color, Colors.white, 0.18) ??
                                  data.color,
                              data.color,
                            ]
                          : [
                              data.color.withValues(alpha: 0.25),
                              data.color.withValues(alpha: 0.18),
                            ],
                    ),
                    boxShadow: widget.active
                        ? [
                            BoxShadow(
                              color: data.color.withValues(
                                  alpha: _hovered ? 0.55 : 0.35),
                              blurRadius: _hovered ? 6.0 : 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelMedium.override(
                          fontFamily: theme.labelMediumFamily,
                          color: theme.primaryText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          decoration: inactive
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          useGoogleFonts: !theme.labelMediumIsCustom,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        data.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelSmall.override(
                          fontFamily: theme.labelSmallFamily,
                          color: theme.secondaryText,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.labelSmallIsCustom,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      textScaler: MediaQuery.of(context).textScaler,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${data.total}',
                            style: theme.titleLarge.override(
                              fontFamily: theme.titleLargeFamily,
                              color: theme.customColor3,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.0,
                              lineHeight: 1.0,
                              useGoogleFonts: !theme.titleLargeIsCustom,
                            ),
                          ),
                          TextSpan(
                            text: ' ราย',
                            style: theme.labelSmall.override(
                              fontFamily: theme.labelSmallFamily,
                              color: theme.secondaryText,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.labelSmallIsCustom,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      data.contextLabel,
                      style: theme.labelSmall.override(
                        fontFamily: theme.labelSmallFamily,
                        color: data.color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.labelSmallIsCustom,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionInfoButton extends StatelessWidget {
  const _SectionInfoButton({required this.accent, required this.onTap});

  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: accent.withValues(alpha: 0.12),
        highlightColor: accent.withValues(alpha: 0.06),
        child: Tooltip(
          message: 'ดูสูตรและคำอธิบาย',
          waitDuration: const Duration(milliseconds: 400),
          child: Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.12),
              border: Border.all(
                color: accent.withValues(alpha: 0.30),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: FaIcon(
              FontAwesomeIcons.info,
              color: accent,
              size: 12.0,
            ),
          ),
        ),
      ),
    );
  }
}
