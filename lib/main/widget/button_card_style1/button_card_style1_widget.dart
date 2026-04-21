import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_card_style1_model.dart';
export 'button_card_style1_model.dart';

class ButtonCardStyle1Widget extends StatefulWidget {
  const ButtonCardStyle1Widget({
    super.key,
    this.title,
    this.amount,
    this.unit,
    this.icon,
    required this.action,
    required this.stage,
  });

  final String? title;
  final String? amount;
  final String? unit;
  final String? icon;
  final Future Function()? action;
  final String? stage;

  @override
  State<ButtonCardStyle1Widget> createState() => _ButtonCardStyle1WidgetState();
}

class _ButtonCardStyle1WidgetState extends State<ButtonCardStyle1Widget>
    with TickerProviderStateMixin {
  late ButtonCardStyle1Model _model;

  var hasContainerTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonCardStyle1Model());

    animationsMap.addAll({
      'containerOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 500.0.ms,
            begin: Offset(1.02, 1.02),
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
    context.watch<FFAppState>();

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (animationsMap['containerOnActionTriggerAnimation'] != null) {
          safeSetState(() => hasContainerTriggered = true);
          SchedulerBinding.instance.addPostFrameCallback((_) async =>
              animationsMap['containerOnActionTriggerAnimation']!
                  .controller
                  .forward(from: 0.0));
        }
        unawaited(
          () async {
            await widget.action?.call();
          }(),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x19000000),
              offset: Offset(
                0.0,
                0.0,
              ),
            )
          ],
          gradient: LinearGradient(
            colors: [
              valueOrDefault<Color>(
                widget!.stage == widget!.title
                    ? FlutterFlowTheme.of(context).accent2
                    : Color(0xFFF7F8FF),
                Color(0xFFF7F8FF),
              ),
              valueOrDefault<Color>(
                widget!.stage == widget!.title
                    ? FlutterFlowTheme.of(context).accent1
                    : Color(0xFFA6C9FF),
                Color(0xFFA6C9FF),
              )
            ],
            stops: [0.0, 1.0],
            begin: AlignmentDirectional(0.0, -1.0),
            end: AlignmentDirectional(0, 1.0),
          ),
          borderRadius: BorderRadius.circular(32.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).secondaryBackground,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional(1.0, -1.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 4.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(),
                      child: Image.network(
                        widget!.icon!,
                        width: 48.0,
                        height: 48.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }(),
                              0.0,
                            ),
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }(),
                              0.0,
                            ),
                            0.0,
                            0.0),
                        child: Text(
                          valueOrDefault<String>(
                            widget!.title,
                            'Title',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                color: widget!.stage == widget!.title
                                    ? FlutterFlowTheme.of(context)
                                        .secondaryBackground
                                    : FlutterFlowTheme.of(context).primary,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0,
                        ),
                        child: Container(
                          height: 64.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }(),
                              0.0,
                            )),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'จำนวน',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                                RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: valueOrDefault<String>(
                                          widget!.amount,
                                          '0',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLargeFamily,
                                              color: valueOrDefault<Color>(
                                                FFAppState().maintabmenu == 1
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .customColor3
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                Color(0xFF154194),
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleLargeIsCustom,
                                            ),
                                      ),
                                      TextSpan(
                                        text: ' ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmallFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodySmallIsCustom,
                                            ),
                                      ),
                                      TextSpan(
                                        text: valueOrDefault<String>(
                                          widget!.unit,
                                          'Unit',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmallFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .labelSmallIsCustom,
                                            ),
                                      )
                                    ],
                                    style: FlutterFlowTheme.of(context)
                                        .headlineLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .headlineLargeFamily,
                                          color: Color(0xFF2A5490),
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .headlineLargeIsCustom,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ].divide(SizedBox(height: 4.0)),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animateOnActionTrigger(
        animationsMap['containerOnActionTriggerAnimation']!,
        hasBeenTriggered: hasContainerTriggered);
  }
}
