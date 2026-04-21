import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'kpi_card_model.dart';
export 'kpi_card_model.dart';

enum KpiStatus { neutral, good, warning, critical }

class KpiCardWidget extends StatefulWidget {
  const KpiCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.unit,
    this.status = KpiStatus.neutral,
    this.illustrationPath,
    this.infoDescription,
    this.infoFormula,
    this.infoExample,
  });

  final String title;
  final String value;
  final String subtitle;
  final String? unit;
  final KpiStatus status;
  final String? illustrationPath;
  final String? infoDescription;
  final String? infoFormula;
  final String? infoExample;

  bool get hasInfo =>
      (infoDescription != null && infoDescription!.isNotEmpty) ||
      (infoFormula != null && infoFormula!.isNotEmpty) ||
      (infoExample != null && infoExample!.isNotEmpty);

  @override
  State<KpiCardWidget> createState() => _KpiCardWidgetState();
}

class _KpiCardWidgetState extends State<KpiCardWidget> {
  late KpiCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => KpiCardModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Color _accentColor(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    switch (widget.status) {
      case KpiStatus.good:
        return theme.success;
      case KpiStatus.warning:
        return theme.warning;
      case KpiStatus.critical:
        return theme.error;
      case KpiStatus.neutral:
        return theme.info;
    }
  }

  IconData _statusIcon() {
    switch (widget.status) {
      case KpiStatus.good:
        return FontAwesomeIcons.faceSmile;
      case KpiStatus.warning:
        return FontAwesomeIcons.faceMeh;
      case KpiStatus.critical:
        return FontAwesomeIcons.faceDizzy;
      case KpiStatus.neutral:
        return FontAwesomeIcons.circleInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bool isCompact =
        MediaQuery.sizeOf(context).width < kBreakpointMedium;
    final bool hasIllustration =
        widget.illustrationPath != null && widget.illustrationPath!.isNotEmpty;
    final double cardHeight = isCompact ? 164.0 : 176.0;
    final double topZoneHeight = isCompact ? 58.0 : 62.0;
    final double iconBoxWidth = hasIllustration ? 80.0 : 50.0;
    final double iconBoxHeight =
        hasIllustration ? topZoneHeight + 30.0 : topZoneHeight + 22.0;
    final Color accent = _accentColor(context);

    return Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.0),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 18.0,
            offset: const Offset(0.0, 10.0),
            spreadRadius: -4.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6.0,
            offset: const Offset(0.0, 2.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryBackground,
                  theme.primaryBackground.withValues(alpha: 0.70),
                ],
              ),
            ),
            child: Stack(
              children: [
                _buildGlow(accent),
                _buildTitle(context, theme, topZoneHeight,
                    titleRightPad: iconBoxWidth + 26.0),
                _buildIconBridge(
                  context,
                  theme,
                  accent,
                  width: iconBoxWidth,
                  height: iconBoxHeight,
                ),
                _buildWhiteContainer(
                  context,
                  theme,
                  accent,
                  top: topZoneHeight,
                ),
                if (widget.hasInfo) _buildInfoButton(context, theme, accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlow(Color accent) {
    return Positioned(
      top: -60.0,
      right: -60.0,
      child: IgnorePointer(
        child: Container(
          width: 160.0,
          height: 160.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: 0.22),
                accent.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(
      BuildContext context, FlutterFlowTheme theme, double topZoneHeight,
      {required double titleRightPad}) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: topZoneHeight,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
            16.0, 0.0, titleRightPad, 0.0),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            widget.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.labelMedium.override(
              fontFamily: theme.labelMediumFamily,
              color: theme.primaryText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
              lineHeight: 1.15,
              useGoogleFonts: !theme.labelMediumIsCustom,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBridge(
    BuildContext context,
    FlutterFlowTheme theme,
    Color accent, {
    required double width,
    required double height,
  }) {
    final bool hasIllustration =
        widget.illustrationPath != null && widget.illustrationPath!.isNotEmpty;

    if (hasIllustration) {
      return Positioned(
        top: 4.0,
        right: 10.0,
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            widget.illustrationPath!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) =>
                _fallbackBridgeContainer(context, theme, accent,
                    width: width, height: height),
          ),
        ),
      );
    }

    return Positioned(
      top: 8.0,
      right: 14.0,
      child: _fallbackBridgeContainer(
        context,
        theme,
        accent,
        width: width,
        height: height,
      ),
    );
  }

  Widget _fallbackBridgeContainer(
    BuildContext context,
    FlutterFlowTheme theme,
    Color accent, {
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            accent.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(
          color: accent.withValues(alpha: 0.32),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.24),
            blurRadius: 12.0,
            offset: const Offset(0.0, 5.0),
            spreadRadius: -2.0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3.0,
            offset: const Offset(0.0, 1.0),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 1.0,
            left: 6.0,
            right: 6.0,
            height: 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.0, -0.35),
            child: FaIcon(
              _statusIcon(),
              color: accent,
              size: 18.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteContainer(
    BuildContext context,
    FlutterFlowTheme theme,
    Color accent, {
    required double top,
  }) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10.0,
              offset: const Offset(0.0, -4.0),
              spreadRadius: -4.0,
            ),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildValue(context, theme),
              _buildSubtitle(context, theme, accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValue(BuildContext context, FlutterFlowTheme theme) {
    return RichText(
      textScaler: MediaQuery.of(context).textScaler,
      text: TextSpan(
        children: [
          TextSpan(
            text: widget.value,
            style: theme.displaySmall.override(
              fontFamily: theme.displaySmallFamily,
              color: theme.customColor3,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              lineHeight: 1.0,
              useGoogleFonts: !theme.displaySmallIsCustom,
            ),
          ),
          if (widget.unit != null && widget.unit!.isNotEmpty)
            TextSpan(
              text: '  ${widget.unit}',
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
    );
  }

  Widget _buildSubtitle(
      BuildContext context, FlutterFlowTheme theme, Color accent) {
    return Text(
      widget.subtitle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.labelSmall.override(
        fontFamily: theme.labelSmallFamily,
        color: accent,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        useGoogleFonts: !theme.labelSmallIsCustom,
      ),
    );
  }

  Widget _buildInfoButton(
      BuildContext context, FlutterFlowTheme theme, Color accent) {
    return Positioned(
      right: 10.0,
      bottom: 10.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showInfoDialog(context, theme, accent),
          customBorder: const CircleBorder(),
          splashColor: accent.withValues(alpha: 0.12),
          highlightColor: accent.withValues(alpha: 0.06),
          child: Tooltip(
            message: 'ดูสูตรและคำอธิบาย',
            waitDuration: const Duration(milliseconds: 400),
            child: Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.10),
                border: Border.all(
                  color: accent.withValues(alpha: 0.30),
                  width: 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: FaIcon(
                FontAwesomeIcons.info,
                color: accent,
                size: 10.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(
      BuildContext context, FlutterFlowTheme theme, Color accent) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420.0),
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
                        color: accent.withValues(alpha: 0.18),
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
                                  accent,
                                  Color.lerp(accent, Colors.black, 0.16) ??
                                      accent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.35),
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
                                  widget.title,
                                  style: theme.titleMedium.override(
                                    fontFamily: theme.titleMediumFamily,
                                    color: theme.customColor3,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.0,
                                    useGoogleFonts: !theme.titleMediumIsCustom,
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
                      if (widget.infoDescription != null &&
                          widget.infoDescription!.isNotEmpty) ...[
                        const SizedBox(height: 16.0),
                        Text(
                          widget.infoDescription!,
                          style: theme.bodyMedium.override(
                            fontFamily: theme.bodyMediumFamily,
                            color: theme.primaryText,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                            useGoogleFonts: !theme.bodyMediumIsCustom,
                          ),
                        ),
                      ],
                      if (widget.infoFormula != null &&
                          widget.infoFormula!.isNotEmpty) ...[
                        const SizedBox(height: 14.0),
                        _buildInfoBlock(
                          context,
                          theme,
                          accent: accent,
                          label: 'สูตรการคำนวณ',
                          content: widget.infoFormula!,
                        ),
                      ],
                      if (widget.infoExample != null &&
                          widget.infoExample!.isNotEmpty) ...[
                        const SizedBox(height: 10.0),
                        _buildInfoBlock(
                          context,
                          theme,
                          accent: theme.customColor3,
                          label: 'ตัวอย่าง',
                          content: widget.infoExample!,
                        ),
                      ],
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

  Widget _buildInfoBlock(
    BuildContext context,
    FlutterFlowTheme theme, {
    required Color accent,
    required String label,
    required String content,
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
            label.toUpperCase(),
            style: theme.labelSmall.override(
              fontFamily: theme.labelSmallFamily,
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              useGoogleFonts: !theme.labelSmallIsCustom,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            content,
            style: theme.bodyMedium.override(
              fontFamily: theme.bodyMediumFamily,
              color: theme.primaryText,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
              lineHeight: 1.5,
              useGoogleFonts: !theme.bodyMediumIsCustom,
            ),
          ),
        ],
      ),
    );
  }
}

class Solid3DBadge extends StatelessWidget {
  const Solid3DBadge({
    super.key,
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  });

  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        gradient: LinearGradient(
          begin: const AlignmentDirectional(-0.8, -1.0),
          end: const AlignmentDirectional(0.8, 1.0),
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.18) ?? color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.42),
            blurRadius: 10.0,
            offset: const Offset(0.0, 4.0),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 3.0,
            offset: const Offset(0.0, 1.0),
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
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
