import '/er/er_dashboard/widgets/section_card/section_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChiefComplaint {
  const ChiefComplaint({
    required this.label,
    required this.count,
    required this.admitPercent,
  });
  final String label;
  final int count;
  final int admitPercent;
}

class ChiefComplaintsWidget extends StatelessWidget {
  const ChiefComplaintsWidget({super.key});

  static const _complaints = [
    ChiefComplaint(label: 'เจ็บหน้าอก', count: 410, admitPercent: 42),
    ChiefComplaint(label: 'หายใจลำบาก', count: 371, admitPercent: 38),
    ChiefComplaint(
        label: 'อุบัติเหตุ / บาดเจ็บ', count: 351, admitPercent: 22),
    ChiefComplaint(label: 'ปวดท้อง', count: 301, admitPercent: 18),
    ChiefComplaint(label: 'ไข้สูง', count: 278, admitPercent: 11),
    ChiefComplaint(label: 'ชัก / หมดสติ', count: 200, admitPercent: 55),
    ChiefComplaint(label: 'ปวดศีรษะ', count: 171, admitPercent: 9),
    ChiefComplaint(
        label: 'แขน / ขาอ่อนแรง', count: 131, admitPercent: 60),
    ChiefComplaint(label: 'อาเจียน', count: 115, admitPercent: 15),
    ChiefComplaint(label: 'วิงเวียน / เป็นลม', count: 98, admitPercent: 20),
  ];

  Color _barColor(FlutterFlowTheme theme, int rank) {
    if (rank == 1) return theme.customColor20;
    if (rank == 2) return const Color(0xFF8B9399);
    if (rank == 3) return const Color(0xFF92522B);
    return theme.info;
  }

  (Color, Color) _medalColors(int rank) {
    switch (rank) {
      case 1:
        return (const Color(0xFFFFD166), const Color(0xFFDB8B00));
      case 2:
        return (const Color(0xFFD5DBE0), const Color(0xFF8B9399));
      case 3:
        return (const Color(0xFFD9965E), const Color(0xFF92522B));
      default:
        return (Colors.transparent, Colors.transparent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isCompact =
        MediaQuery.sizeOf(context).width < kBreakpointMedium;

    return DashboardSectionCard(
      number: '5',
      title: 'อาการนำที่พบบ่อย',
      subtitle:
          'CHIEF COMPLAINTS · 10 อันดับอาการยอดฮิตเดือนนี้ พร้อมสัดส่วน Admit',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTop3Section(context, theme, isCompact),
          const SizedBox(height: 14.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: theme.alternate.withValues(alpha: 0.55),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14.0,
                  offset: const Offset(0, 6),
                  spreadRadius: -3,
                ),
              ],
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 3; i < _complaints.length; i++) ...[
                  _DetailComplaintRow(
                    complaint: _complaints[i],
                    rank: i + 1,
                  ),
                  if (i < _complaints.length - 1)
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
          ),
        ],
      ),
    );
  }

  Widget _buildTop3Section(
    BuildContext context,
    FlutterFlowTheme theme,
    bool isCompact,
  ) {
    final hero = _HeroComplaintCard(
      complaint: _complaints[0],
      barColor: _barColor(theme, 1),
      medalColors: _medalColors(1),
    );
    final mini2 = _MiniComplaintCard(
      complaint: _complaints[1],
      rank: 2,
      medalColors: _medalColors(2),
    );
    final mini3 = _MiniComplaintCard(
      complaint: _complaints[2],
      rank: 3,
      medalColors: _medalColors(3),
    );

    if (isCompact) {
      return Column(
        children: [
          hero,
          const SizedBox(height: 10.0),
          mini2,
          const SizedBox(height: 10.0),
          mini3,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: hero),
        const SizedBox(width: 12.0),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              mini2,
              const SizedBox(height: 10.0),
              mini3,
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroComplaintCard extends StatelessWidget {
  const _HeroComplaintCard({
    required this.complaint,
    required this.barColor,
    required this.medalColors,
  });

  final ChiefComplaint complaint;
  final Color barColor;
  final (Color, Color) medalColors;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final (medalLight, medalDark) = medalColors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: barColor.withValues(alpha: 0.18),
            blurRadius: 28.0,
            offset: const Offset(0.0, 14.0),
            spreadRadius: -6.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0.0, 3.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.96),
                  Colors.white.withValues(alpha: 0.82),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -80.0,
                  right: -80.0,
                  child: IgnorePointer(
                    child: Container(
                      width: 220.0,
                      height: 220.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            barColor.withValues(alpha: 0.22),
                            barColor.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 1.0,
                  left: 16.0,
                  right: 16.0,
                  height: 1.2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _crownOrb(medalLight, medalDark),
                          const Spacer(),
                          _topChip(context, theme, barColor),
                        ],
                      ),
                      const SizedBox(height: 28.0),
                      Text(
                        complaint.label,
                        style: theme.titleMedium.override(
                          fontFamily: theme.titleMediumFamily,
                          color: theme.primaryText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.titleMediumIsCustom,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${complaint.count}',
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
                                useGoogleFonts:
                                    !theme.labelMediumIsCustom,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'Admit ${complaint.admitPercent}%',
                        style: theme.labelSmall.override(
                          fontFamily: theme.labelSmallFamily,
                          color: barColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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
      ),
    );
  }

  Widget _crownOrb(Color medalLight, Color medalDark) {
    return Container(
      width: 44.0,
      height: 44.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: const AlignmentDirectional(-0.8, -1.0),
          end: const AlignmentDirectional(0.8, 1.0),
          colors: [medalLight, medalDark],
        ),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: medalDark.withValues(alpha: 0.55),
            blurRadius: 14.0,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const FaIcon(
        FontAwesomeIcons.crown,
        color: Colors.white,
        size: 18.0,
      ),
    );
  }

  Widget _topChip(
      BuildContext context, FlutterFlowTheme theme, Color accent) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          color: accent.withValues(alpha: 0.30),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 3.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        'อาการอันดับ 1',
        style: theme.labelSmall.override(
          fontFamily: theme.labelSmallFamily,
          color: accent,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          useGoogleFonts: !theme.labelSmallIsCustom,
        ),
      ),
    );
  }
}

class _MiniComplaintCard extends StatelessWidget {
  const _MiniComplaintCard({
    required this.complaint,
    required this.rank,
    required this.medalColors,
  });

  final ChiefComplaint complaint;
  final int rank;
  final (Color, Color) medalColors;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final (medalLight, medalDark) = medalColors;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: medalDark.withValues(alpha: 0.14),
            blurRadius: 18.0,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.80),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.96),
                  medalLight.withValues(alpha: 0.14),
                ],
              ),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildOrb(theme, medalLight, medalDark),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'อันดับ $rank',
                            style: theme.labelSmall.override(
                              fontFamily: theme.labelSmallFamily,
                              color: medalDark,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              useGoogleFonts: !theme.labelSmallIsCustom,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            complaint.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.titleSmall.override(
                              fontFamily: theme.titleSmallFamily,
                              color: theme.customColor3,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.titleSmallIsCustom,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            'Admit ${complaint.admitPercent}%',
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrb(
      FlutterFlowTheme theme, Color medalLight, Color medalDark) {
    return Container(
      width: 46.0,
      height: 46.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: const AlignmentDirectional(-0.8, -1.0),
          end: const AlignmentDirectional(0.8, 1.0),
          colors: [medalLight, medalDark],
        ),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: medalDark.withValues(alpha: 0.50),
            blurRadius: 12.0,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          '${complaint.count}',
          style: theme.titleSmall.override(
            fontFamily: theme.titleSmallFamily,
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.0,
            lineHeight: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 4.0,
                offset: const Offset(0, 1),
              ),
            ],
            useGoogleFonts: !theme.titleSmallIsCustom,
          ),
        ),
      ),
    );
  }
}

class _DetailComplaintRow extends StatelessWidget {
  const _DetailComplaintRow({
    required this.complaint,
    required this.rank,
  });

  final ChiefComplaint complaint;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 26.0,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: theme.labelMedium.override(
                fontFamily: theme.labelMediumFamily,
                color: theme.secondaryText,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.labelMediumIsCustom,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              complaint.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.primaryText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${complaint.count}',
                  style: theme.titleSmall.override(
                    fontFamily: theme.titleSmallFamily,
                    color: theme.customColor3,
                    fontWeight: FontWeight.w800,
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
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          Text(
            'Admit ${complaint.admitPercent}%',
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
    );
  }
}
