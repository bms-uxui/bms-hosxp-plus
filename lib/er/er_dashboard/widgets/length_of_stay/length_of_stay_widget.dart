import '/er/er_dashboard/widgets/section_card/section_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LosStep {
  const LosStep({
    required this.label,
    required this.minutes,
    required this.color,
  });
  final String label;
  final int minutes;
  final Color color;
}

class LengthOfStayWidget extends StatefulWidget {
  const LengthOfStayWidget({super.key});

  @override
  State<LengthOfStayWidget> createState() => _LengthOfStayWidgetState();
}

class _LengthOfStayWidgetState extends State<LengthOfStayWidget> {
  int? _focusedIndex;

  void _setFocus(int? i) {
    if (_focusedIndex != i) {
      setState(() => _focusedIndex = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    final steps = [
      LosStep(
          label: 'Triage / คัดแยก',
          minutes: 8,
          color: theme.customColor12),
      LosStep(
          label: 'รอพบแพทย์',
          minutes: 22,
          color: theme.info),
      LosStep(
          label: 'ตรวจ / รักษา',
          minutes: 35,
          color: theme.customColor10),
      LosStep(
          label: 'รอผล Lab',
          minutes: 45,
          color: theme.customColor18),
      LosStep(
          label: 'รอผล X-ray',
          minutes: 25,
          color: theme.customColor7),
      LosStep(
          label: 'รอ Admit',
          minutes: 68,
          color: theme.customColor20),
      LosStep(
          label: 'Discharge / จำหน่าย',
          minutes: 20,
          color: theme.customColor5),
    ];

    final total = steps.fold<int>(0, (s, e) => s + e.minutes);
    final maxMinutes =
        steps.map((e) => e.minutes).reduce((a, b) => a > b ? a : b);
    final bottleneckIndex =
        steps.indexWhere((e) => e.minutes == maxMinutes);

    return DashboardSectionCard(
      number: '4',
      title: 'ระยะเวลาแต่ละขั้นตอน',
      subtitle:
          'LENGTH OF STAY · แตะหรือชี้ที่แท่งสีเพื่อดูรายละเอียดแต่ละขั้นตอน',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalHeader(context, theme, total),
          const SizedBox(height: 12.0),
          _buildBottleneckCallout(
              context, theme, steps[bottleneckIndex], total),
          const SizedBox(height: 14.0),
          _buildCallout(context, theme, steps, total, bottleneckIndex),
          const SizedBox(height: 10.0),
          _buildSegmentedBar(context, theme, steps, total, bottleneckIndex),
          const SizedBox(height: 18.0),
          _buildStepList(context, theme, steps, total, bottleneckIndex),
        ],
      ),
    );
  }

  Widget _buildTotalHeader(
      BuildContext context, FlutterFlowTheme theme, int total) {
    final hours = total ~/ 60;
    final minutesRemain = total % 60;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เวลาเฉลี่ยรวมใน ER',
                style: theme.labelSmall.override(
                  fontFamily: theme.labelSmallFamily,
                  color: theme.secondaryText,
                  letterSpacing: 0.8,
                  useGoogleFonts: !theme.labelSmallIsCustom,
                ),
              ),
              const SizedBox(height: 4.0),
              RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$total',
                      style: theme.displaySmall.override(
                        fontFamily: theme.displaySmallFamily,
                        color: theme.customColor3,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.0,
                        lineHeight: 1.0,
                        useGoogleFonts: !theme.displaySmallIsCustom,
                      ),
                    ),
                    TextSpan(
                      text: '  นาที',
                      style: theme.labelMedium.override(
                        fontFamily: theme.labelMediumFamily,
                        color: theme.secondaryText,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.labelMediumIsCustom,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'ประมาณ $hours ชั่วโมง $minutesRemain นาที · ตั้งแต่ลงทะเบียนจนจำหน่าย',
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
      ],
    );
  }

  Widget _buildCallout(
    BuildContext context,
    FlutterFlowTheme theme,
    List<LosStep> steps,
    int total,
    int bottleneckIndex,
  ) {
    final hasFocus = _focusedIndex != null;
    final step = hasFocus ? steps[_focusedIndex!] : null;
    final color = step?.color ?? theme.secondaryText;
    final percent =
        step != null ? (step.minutes / total * 100).toStringAsFixed(1) : '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasFocus
              ? [
                  color.withValues(alpha: 0.18),
                  color.withValues(alpha: 0.06),
                ]
              : [
                  theme.alternate.withValues(alpha: 0.45),
                  theme.alternate.withValues(alpha: 0.20),
                ],
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: hasFocus
              ? color.withValues(alpha: 0.30)
              : theme.alternate.withValues(alpha: 0.55),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 14.0,
            height: 14.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: hasFocus
                  ? TextSpan(
                      children: [
                        TextSpan(
                          text: step!.label,
                          style: theme.labelMedium.override(
                            fontFamily: theme.labelMediumFamily,
                            color: theme.primaryText,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.labelMediumIsCustom,
                          ),
                        ),
                        TextSpan(
                          text: '  ·  ${step.minutes} นาที  ·  $percent%',
                          style: theme.labelSmall.override(
                            fontFamily: theme.labelSmallFamily,
                            color: color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.labelSmallIsCustom,
                          ),
                        ),
                      ],
                    )
                  : TextSpan(
                      text: 'ชี้ที่แท่งสีเพื่อดูรายละเอียดของแต่ละขั้นตอน',
                      style: theme.labelSmall.override(
                        fontFamily: theme.labelSmallFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.labelSmallIsCustom,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedBar(
    BuildContext context,
    FlutterFlowTheme theme,
    List<LosStep> steps,
    int total,
    int bottleneckIndex,
  ) {
    const double height = 24.0;
    const double gap = 3.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalGapWidth = gap * (steps.length - 1);
        final availableWidth = totalWidth - totalGapWidth;

        return SizedBox(
          height: height + 8.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                _buildSegment(
                  context,
                  theme,
                  step: steps[i],
                  index: i,
                  width: availableWidth * steps[i].minutes / total,
                  height: height,
                  isFirst: i == 0,
                  isLast: i == steps.length - 1,
                ),
                if (i < steps.length - 1) const SizedBox(width: gap),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegment(
    BuildContext context,
    FlutterFlowTheme theme, {
    required LosStep step,
    required int index,
    required double width,
    required double height,
    required bool isFirst,
    required bool isLast,
  }) {
    final focused = _focusedIndex == index;
    final dimmed = _focusedIndex != null && !focused;

    final radius = BorderRadius.horizontal(
      left: isFirst ? Radius.circular(height / 2) : const Radius.circular(4.0),
      right: isLast ? Radius.circular(height / 2) : const Radius.circular(4.0),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setFocus(index),
      onExit: (_) => _setFocus(null),
      child: GestureDetector(
        onTap: () => _setFocus(focused ? null : index),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          scale: focused ? 1.06 : 1.0,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: width < 10 ? 10 : width,
            height: focused ? height + 4 : height,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dimmed
                    ? [
                        Color.lerp(step.color, Colors.white, 0.55) ??
                            step.color,
                        Color.lerp(step.color, Colors.white, 0.35) ??
                            step.color,
                      ]
                    : [
                        Color.lerp(step.color, Colors.white, 0.18) ??
                            step.color,
                        step.color,
                        Color.lerp(step.color, Colors.black, 0.15) ??
                            step.color,
                      ],
                stops: dimmed ? const [0.0, 1.0] : const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: step.color.withValues(
                      alpha: focused ? 0.55 : (dimmed ? 0.10 : 0.30)),
                  blurRadius: focused ? 12.0 : 6.0,
                  offset: const Offset(0.0, 2.0),
                  spreadRadius: focused ? 0 : -1,
                ),
              ],
              border: focused
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 1.5,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                children: [
                  Positioned(
                    top: 2.0,
                    left: 8.0,
                    right: 8.0,
                    height: height * 0.30,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepList(
    BuildContext context,
    FlutterFlowTheme theme,
    List<LosStep> steps,
    int total,
    int bottleneckIndex,
  ) {
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
          for (var i = 0; i < steps.length; i++) ...[
            _buildStepRow(context, theme, steps[i], i, total,
                isBottleneck: i == bottleneckIndex),
            if (i < steps.length - 1)
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

  Widget _buildStepRow(
    BuildContext context,
    FlutterFlowTheme theme,
    LosStep step,
    int index,
    int total, {
    required bool isBottleneck,
  }) {
    final focused = _focusedIndex == index;
    final percent = step.minutes / total * 100;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setFocus(index),
      onExit: (_) => _setFocus(null),
      child: GestureDetector(
        onTap: () => _setFocus(focused ? null : index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: focused
                ? step.color.withValues(alpha: 0.10)
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
                    colors: [
                      Color.lerp(step.color, Colors.white, 0.18) ??
                          step.color,
                      step.color,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: step.color.withValues(alpha: focused ? 0.55 : 0.35),
                      blurRadius: focused ? 6.0 : 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        step.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.labelMedium.override(
                          fontFamily: theme.labelMediumFamily,
                          color: theme.primaryText,
                          fontWeight:
                              isBottleneck ? FontWeight.w800 : FontWeight.w600,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.labelMediumIsCustom,
                        ),
                      ),
                    ),
                    if (isBottleneck) ...[
                      const SizedBox(width: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: step.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(100.0),
                          border: Border.all(
                            color: step.color.withValues(alpha: 0.30),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.triangleExclamation,
                              color: step.color,
                              size: 8.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'คอขวด',
                              style: theme.labelSmall.override(
                                fontFamily: theme.labelSmallFamily,
                                color: step.color,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                useGoogleFonts: !theme.labelSmallIsCustom,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${step.minutes}',
                      style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: theme.customColor3,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.titleSmallIsCustom,
                      ),
                    ),
                    TextSpan(
                      text: ' นาที',
                      style: theme.labelSmall.override(
                        fontFamily: theme.labelSmallFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.labelSmallIsCustom,
                      ),
                    ),
                    TextSpan(
                      text: '  (${percent.toStringAsFixed(1)}%)',
                      style: theme.labelSmall.override(
                        fontFamily: theme.labelSmallFamily,
                        color: step.color,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.labelSmallIsCustom,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottleneckCallout(
    BuildContext context,
    FlutterFlowTheme theme,
    LosStep step,
    int total,
  ) {
    final percent = (step.minutes / total * 100).toStringAsFixed(0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: step.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: step.color.withValues(alpha: 0.20),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: step.color.withValues(alpha: 0.30),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: FaIcon(
              FontAwesomeIcons.triangleExclamation,
              color: step.color,
              size: 10.0,
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'คอขวดหลัก · ${step.label}',
                    style: theme.labelMedium.override(
                      fontFamily: theme.labelMediumFamily,
                      color: step.color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.labelMediumIsCustom,
                    ),
                  ),
                  TextSpan(
                    text:
                        '  ·  ${step.minutes} นาที ($percent% ของเวลารวม)',
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
          ),
        ],
      ),
    );
  }
}
