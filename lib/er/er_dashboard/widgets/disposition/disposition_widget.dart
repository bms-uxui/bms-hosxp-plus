import '/er/er_dashboard/widgets/section_card/section_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DispositionSlice {
  const DispositionSlice({
    required this.label,
    required this.hint,
    required this.percent,
    required this.color,
  });
  final String label;
  final String hint;
  final double percent;
  final Color color;
}

class DispositionWidget extends StatefulWidget {
  const DispositionWidget({super.key});

  @override
  State<DispositionWidget> createState() => _DispositionWidgetState();
}

class _DispositionWidgetState extends State<DispositionWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final slices = <DispositionSlice>[
      DispositionSlice(
        label: 'กลับบ้าน',
        hint: 'ผู้ป่วยที่แพทย์ให้กลับบ้านได้',
        percent: 64,
        color: theme.customColor10,
      ),
      DispositionSlice(
        label: 'Admit',
        hint: 'รับไว้นอนโรงพยาบาล',
        percent: 19,
        color: theme.info,
      ),
      DispositionSlice(
        label: 'Observe',
        hint: 'สังเกตอาการใน ER ต่อ',
        percent: 10,
        color: theme.customColor18,
      ),
      DispositionSlice(
        label: 'Refer',
        hint: 'ส่งต่อโรงพยาบาลอื่น',
        percent: 4,
        color: theme.customColor7,
      ),
      DispositionSlice(
        label: 'เสียชีวิต',
        hint: 'ผู้ป่วยเสียชีวิตใน ER',
        percent: 3,
        color: theme.customColor20,
      ),
    ];

    return DashboardSectionCard(
      number: '6',
      title: 'ผลลัพธ์ของผู้ป่วย',
      subtitle: 'DISPOSITION · ผู้ป่วย ER วันนี้ไปทางไหนบ้าง',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              height: 260.0,
              width: 260.0,
              child: _buildDonut(context, slices),
            ),
          ),
          const SizedBox(height: 16.0),
          _buildLegendCard(context, slices),
        ],
      ),
    );
  }

  Widget _buildDonut(
      BuildContext context, List<DispositionSlice> slices) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 3.0,
            centerSpaceRadius: 70.0,
            startDegreeOffset: -90,
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                setState(() {
                  _touchedIndex =
                      response?.touchedSection?.touchedSectionIndex ?? -1;
                });
              },
            ),
            sections: [
              for (var i = 0; i < slices.length; i++)
                PieChartSectionData(
                  value: slices[i].percent,
                  gradient: LinearGradient(
                    begin: const Alignment(-0.8, -1.0),
                    end: const Alignment(0.8, 1.0),
                    colors: [
                      Color.lerp(slices[i].color, Colors.white, 0.22) ??
                          slices[i].color,
                      slices[i].color,
                      Color.lerp(slices[i].color, Colors.black, 0.22) ??
                          slices[i].color,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.8,
                  ),
                  radius: _touchedIndex == i ? 64.0 : 54.0,
                  title: '${slices[i].percent.toStringAsFixed(0)}%',
                  titleStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: _touchedIndex == i ? 14.0 : 12.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 4.0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        _buildCenterBadge(context, slices),
      ],
    );
  }

  Widget _buildCenterBadge(
      BuildContext context, List<DispositionSlice> slices) {
    final theme = FlutterFlowTheme.of(context);
    final total = slices.fold<double>(0, (s, e) => s + e.percent);
    return Container(
      width: 120.0,
      height: 120.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: const Alignment(-0.7, -1.0),
          end: const Alignment(0.7, 1.0),
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14.0,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'รวม',
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: theme.secondaryText,
              letterSpacing: 0.8,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            '${total.toStringAsFixed(0)}%',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              color: theme.customColor3,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              lineHeight: 1.0,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard(
      BuildContext context, List<DispositionSlice> slices) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.80),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < slices.length; i++) ...[
            _buildLegendRow(context, slices[i]),
            if (i < slices.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Divider(
                  height: 1.0,
                  color: theme.alternate.withValues(alpha: 0.5),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendRow(BuildContext context, DispositionSlice slice) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 14.0,
            height: 14.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  slice.color.withValues(alpha: 0.95),
                  slice.color.withValues(alpha: 0.70),
                ],
              ),
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: [
                BoxShadow(
                  color: slice.color.withValues(alpha: 0.30),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slice.label,
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.titleSmallIsCustom,
                  ),
                ),
                Text(
                  slice.hint,
                  style: theme.labelSmall.override(
                    fontFamily: theme.labelSmallFamily,
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.labelSmallIsCustom,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 72.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                gradient: LinearGradient(
                  begin: const Alignment(-0.8, -1.0),
                  end: const Alignment(0.8, 1.0),
                  colors: [
                    slice.color,
                    Color.lerp(slice.color, Colors.black, 0.22) ?? slice.color,
                  ],
                ),
              boxShadow: [
                BoxShadow(
                  color: slice.color.withValues(alpha: 0.45),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 3.0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 1.0,
                  left: 10.0,
                  right: 10.0,
                  height: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.90),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Center(
                    child: Text(
                      '${slice.percent.toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        useGoogleFonts: !theme.titleSmallIsCustom,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}
