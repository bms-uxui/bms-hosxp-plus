import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'menuicon_model.dart';
export 'menuicon_model.dart';

class MenuiconWidget extends StatefulWidget {
  const MenuiconWidget({
    super.key,
    this.icon,
    this.tab,
    required this.stage,
    required this.action,
  });

  final Widget? icon;
  final String? tab;
  final String? stage;
  final Future Function()? action;

  @override
  State<MenuiconWidget> createState() => _MenuiconWidgetState();
}

class _MenuiconWidgetState extends State<MenuiconWidget>
    with TickerProviderStateMixin {
  late MenuiconModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuiconModel());

    animationsMap.addAll({
      'blurOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (animationsMap['blurOnActionTriggerAnimation'] != null) {
          animationsMap['blurOnActionTriggerAnimation']!
              .controller
              .forward(from: 0.0);
        }
        unawaited(
          () async {
            await widget.action?.call();
          }(),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: valueOrDefault<double>(
              widget!.stage == widget!.tab ? 100.0 : 0.0,
              0.0,
            ),
            sigmaY: valueOrDefault<double>(
              widget!.stage == widget!.tab ? 50.0 : 0.0,
              0.0,
            ),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: widget!.stage == widget!.tab
                ? () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 90.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 90.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointLarge) {
                      return 140.0;
                    } else {
                      return 140.0;
                    }
                  }()
                : () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 60.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 60.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointLarge) {
                      return 120.0;
                    } else {
                      return 120.0;
                    }
                  }(),
            height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 54.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 54.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 74.0;
              } else {
                return 74.0;
              }
            }(),
            decoration: BoxDecoration(
              color: valueOrDefault<Color>(
                widget!.stage == widget!.tab
                    ? Color(0x0C14181B)
                    : Color(0x00FFFFFF),
                Color(0x00FFFFFF),
              ),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: widget!.icon!,
                  ),
                  Text(
                    valueOrDefault<String>(
                      widget!.tab,
                      'tab',
                    ),
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).labelSmallFamily,
                          color: widget!.stage == widget!.tab
                              ? FlutterFlowTheme.of(context).primary
                              : FlutterFlowTheme.of(context).secondaryText,
                          fontSize: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 8.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 8.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 12.0;
                            } else {
                              return 12.0;
                            }
                          }(),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).labelSmallIsCustom,
                        ),
                  ),
                ].divide(SizedBox(height: 2.0)),
              ),
            ),
          ),
        ),
      ),
    ).animateOnActionTrigger(
      animationsMap['blurOnActionTriggerAnimation']!,
    );
  }
}
