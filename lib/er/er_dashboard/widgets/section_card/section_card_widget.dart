import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String number;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final pad =
        MediaQuery.sizeOf(context).width < kBreakpointMedium ? 12.0 : 16.0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E83E6).withValues(alpha: 0.10),
            blurRadius: 28.0,
            offset: const Offset(0.0, 16.0),
            spreadRadius: -4.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.92),
                  Colors.white.withValues(alpha: 0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(28.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.70),
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.5,
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
                  padding: EdgeInsets.all(pad + 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildNumberOrb(context, theme),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.titleMedium.override(
                                    fontFamily: theme.titleMediumFamily,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !theme.titleMediumIsCustom,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: theme.labelSmall.override(
                                    fontFamily: theme.labelSmallFamily,
                                    letterSpacing: 0.8,
                                    useGoogleFonts: !theme.labelSmallIsCustom,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                      SizedBox(height: pad),
                      child,
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

  Widget _buildNumberOrb(BuildContext context, FlutterFlowTheme theme) {
    return Container(
      width: 34.0,
      height: 34.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: const AlignmentDirectional(-0.6, -0.8),
          end: const AlignmentDirectional(0.6, 0.8),
          colors: [theme.secondary, theme.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.40),
            blurRadius: 10.0,
            offset: const Offset(0.0, 4.0),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.50),
            blurRadius: 2.0,
            offset: const Offset(-1.0, -1.0),
            spreadRadius: -1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: theme.labelMedium.override(
          fontFamily: theme.labelMediumFamily,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.0,
          useGoogleFonts: !theme.labelMediumIsCustom,
        ),
      ),
    );
  }
}
