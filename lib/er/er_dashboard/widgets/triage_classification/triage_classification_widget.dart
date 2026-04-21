import '/er/er_dashboard/widgets/section_card/section_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class TriageLevelData {
  const TriageLevelData({
    required this.level,
    required this.label,
    required this.count,
    required this.color,
  });
  final String level;
  final String label;
  final int count;
  final Color color;
}

class TriageClassificationWidget extends StatefulWidget {
  const TriageClassificationWidget({super.key});

  @override
  State<TriageClassificationWidget> createState() =>
      _TriageClassificationWidgetState();
}

class _TriageClassificationWidgetState
    extends State<TriageClassificationWidget> {
  int? _focusedIndex;

  void _setFocus(int? i) {
    if (_focusedIndex != i) {
      setState(() => _focusedIndex = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final levels = [
      TriageLevelData(
        level: 'Level 1',
        label: 'Resus',
        count: 12,
        color: theme.customColor20,
      ),
      TriageLevelData(
        level: 'Level 2',
        label: 'Emergency',
        count: 48,
        color: theme.customColor16,
      ),
      TriageLevelData(
        level: 'Level 3',
        label: 'Urgent',
        count: 134,
        color: theme.customColor18,
      ),
      TriageLevelData(
        level: 'Level 4',
        label: 'Semi-Urgent',
        count: 89,
        color: theme.customColor10,
      ),
      TriageLevelData(
        level: 'Level 5',
        label: 'Non-Urgent',
        count: 29,
        color: theme.customColor12,
      ),
    ];

    final total = levels.fold<int>(0, (s, l) => s + l.count);

    return DashboardSectionCard(
      number: '2',
      title: 'แยกตามระดับความเร่งด่วน',
      subtitle:
          'TRIAGE CLASSIFICATION · แตะหรือชี้ที่แท่งสีเพื่อดูรายละเอียด',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalHeader(context, theme, total),
          const SizedBox(height: 14.0),
          _buildCallout(context, theme, levels, total),
          const SizedBox(height: 10.0),
          _buildSegmentedBar(context, theme, levels, total),
          const SizedBox(height: 18.0),
          _buildLevelList(context, theme, levels, total),
        ],
      ),
    );
  }

  Widget _buildTotalHeader(
      BuildContext context, FlutterFlowTheme theme, int total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ผู้ป่วยรวมวันนี้',
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
                      text: '  ราย',
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
            ],
          ),
        ),
        _buildTrendPill(context, theme, percent: 4.2, up: true),
      ],
    );
  }

  Widget _buildTrendPill(
    BuildContext context,
    FlutterFlowTheme theme, {
    required double percent,
    required bool up,
  }) {
    final color = up ? theme.success : theme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: color,
            size: 12.0,
          ),
          const SizedBox(width: 4.0),
          Text(
            '${percent.toStringAsFixed(1)}% จากเมื่อวาน',
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallout(
    BuildContext context,
    FlutterFlowTheme theme,
    List<TriageLevelData> levels,
    int total,
  ) {
    final hasFocus = _focusedIndex != null;
    final level = hasFocus ? levels[_focusedIndex!] : null;
    final color = level?.color ?? theme.secondaryText;
    final percent =
        level != null ? (level.count / total * 100).toStringAsFixed(1) : '';

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
                          text: '${level!.level} · ${level.label}',
                          style: theme.labelMedium.override(
                            fontFamily: theme.labelMediumFamily,
                            color: theme.primaryText,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.0,
                            useGoogleFonts: !theme.labelMediumIsCustom,
                          ),
                        ),
                        TextSpan(
                          text: '  ·  ${level.count} ราย  ·  $percent%',
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
                      text: 'ชี้ที่แท่งสีเพื่อดูรายละเอียดของแต่ละระดับ',
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
    List<TriageLevelData> levels,
    int total,
  ) {
    const double height = 24.0;
    const double gap = 3.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalGapWidth = gap * (levels.length - 1);
        final availableWidth = totalWidth - totalGapWidth;

        return SizedBox(
          height: height + 8.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < levels.length; i++) ...[
                _buildSegment(
                  context,
                  theme,
                  level: levels[i],
                  index: i,
                  width: availableWidth * levels[i].count / total,
                  height: height,
                  isFirst: i == 0,
                  isLast: i == levels.length - 1,
                ),
                if (i < levels.length - 1) const SizedBox(width: gap),
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
    required TriageLevelData level,
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
                        Color.lerp(level.color, Colors.white, 0.55) ??
                            level.color,
                        Color.lerp(level.color, Colors.white, 0.35) ??
                            level.color,
                      ]
                    : [
                        Color.lerp(level.color, Colors.white, 0.18) ??
                            level.color,
                        level.color,
                        Color.lerp(level.color, Colors.black, 0.15) ??
                            level.color,
                      ],
                stops: dimmed ? const [0.0, 1.0] : const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: level.color
                      .withValues(alpha: focused ? 0.55 : (dimmed ? 0.10 : 0.30)),
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

  Widget _buildLevelList(
    BuildContext context,
    FlutterFlowTheme theme,
    List<TriageLevelData> levels,
    int total,
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
          for (var i = 0; i < levels.length; i++) ...[
            _buildLevelRow(context, theme, levels[i], i, total),
            if (i < levels.length - 1)
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

  Widget _buildLevelRow(
    BuildContext context,
    FlutterFlowTheme theme,
    TriageLevelData level,
    int index,
    int total,
  ) {
    final focused = _focusedIndex == index;
    final percent = level.count / total * 100;

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
                ? level.color.withValues(alpha: 0.10)
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
                      Color.lerp(level.color, Colors.white, 0.18) ??
                          level.color,
                      level.color,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: level.color.withValues(alpha: focused ? 0.55 : 0.35),
                      blurRadius: focused ? 6.0 : 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: level.level,
                        style: theme.labelMedium.override(
                          fontFamily: theme.labelMediumFamily,
                          color: theme.primaryText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.labelMediumIsCustom,
                        ),
                      ),
                      TextSpan(
                        text: '  ·  ${level.label}',
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
              ),
              const SizedBox(width: 10.0),
              RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${level.count}',
                      style: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: theme.customColor3,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.titleSmallIsCustom,
                      ),
                    ),
                    TextSpan(
                      text: ' ราย',
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
                        color: level.color,
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
}
