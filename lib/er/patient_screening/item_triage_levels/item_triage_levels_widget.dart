import '/dsign_system/alertdialog/alert_dialog_generate/alert_dialog_generate_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/er/patient_screening/buttonsheet_samary_a_i_e_r_copy/buttonsheet_samary_a_i_e_r_copy_widget.dart';
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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_triage_levels_model.dart';
export 'item_triage_levels_model.dart';

class ItemTriageLevelsWidget extends StatefulWidget {
  const ItemTriageLevelsWidget({super.key});

  @override
  State<ItemTriageLevelsWidget> createState() => _ItemTriageLevelsWidgetState();
}

class _ItemTriageLevelsWidgetState extends State<ItemTriageLevelsWidget>
    with TickerProviderStateMixin {
  late ItemTriageLevelsModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemTriageLevelsModel());

    animationsMap.addAll({
      'buttonAIgenerateOnPageLoadAnimation': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 850.0.ms,
            duration: 1210.0.ms,
            color: Color(0x80FFFFFF),
            angle: 0.524,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(valueOrDefault<double>(
          () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 12.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 12.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 16.0;
            } else {
              return 16.0;
            }
          }(),
          0.0,
        )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FlutterFlowTheme.of(context).customColor19,
                            FlutterFlowTheme.of(context).customColor20
                          ],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(0.0, -1.0),
                          end: AlignmentDirectional(0, 1.0),
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Icon(
                          Icons.emergency_rounded,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          size: 10.0,
                        ),
                      ),
                    ),
                    Text(
                      'ระดับความเร่งด่วน (ESI)',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ].divide(SizedBox(width: 8.0)),
                ),
                Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Builder(
                    builder: (context) => InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              elevation: 0,
                              insetPadding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              alignment: AlignmentDirectional(0.0, 0.0)
                                  .resolve(Directionality.of(context)),
                              child: AlertDialogGenerateWidget(),
                            );
                          },
                        );

                        await Future.delayed(
                          Duration(
                            milliseconds: 3500,
                          ),
                        );
                        unawaited(
                          () async {
                            Navigator.pop(context);
                          }(),
                        );
                        showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          isDismissible: false,
                          useSafeArea: true,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: ButtonsheetSamaryAIERCopyWidget(),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                      child: wrapWithModel(
                        model: _model.buttonAIgenerateModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ButtonAIgenerateWidget(
                          aiGenerate: 'วิเคราะห์ข้อมูล',
                          icon: Icon(
                            Icons.auto_awesome,
                            color: FlutterFlowTheme.of(context).customColor8,
                            size: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 16.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 16.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 18.0;
                              } else {
                                return 18.0;
                              }
                            }(),
                          ),
                        ),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['buttonAIgenerateOnPageLoadAnimation']!),
                  ),
                ),
              ],
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
            MasonryGridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 3;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 3;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 5;
                  } else {
                    return 5;
                  }
                }(),
              ),
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              itemCount: 5,
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                0,
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return [
                  () => InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          FFAppState().ItemTriageLevels = 1;
                          safeSetState(() {});
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation1'] !=
                              null) {
                            animationsMap['containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 1
                                          ? Color(0x80E15D69)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 1
                                          ? Color(0x7FBE1E2D)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    )
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/ESI1.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                              animationsMap[
                                  'containerOnActionTriggerAnimation1']!,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Resuscitation',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        color: valueOrDefault<Color>(
                                          FFAppState().ItemTriageLevels == 1
                                              ? Color(0xFFBE1E2D)
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                                Text(
                                  'ภาวะวิกฤต',
                                  maxLines: 1,
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
                              ],
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                  () => InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          FFAppState().ItemTriageLevels = 2;
                          safeSetState(() {});
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation2'] !=
                              null) {
                            animationsMap['containerOnActionTriggerAnimation2']!
                                .controller
                                .forward(from: 0.0);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 2
                                          ? Color(0x80BD6EF2)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 2
                                          ? Color(0x7FAF1EBE)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    )
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/ESI2.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                              animationsMap[
                                  'containerOnActionTriggerAnimation2']!,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Emergency',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        color: valueOrDefault<Color>(
                                          FFAppState().ItemTriageLevels == 2
                                              ? Color(0xFFAF1EBE)
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                                Text(
                                  'เร่งด่วน',
                                  maxLines: 1,
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
                              ],
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                  () => InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          FFAppState().ItemTriageLevels = 3;
                          safeSetState(() {});
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation3'] !=
                              null) {
                            animationsMap['containerOnActionTriggerAnimation3']!
                                .controller
                                .forward(from: 0.0);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 3
                                          ? Color(0x80FFB960)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 3
                                          ? Color(0x80DC8610)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    )
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/ESI3.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                              animationsMap[
                                  'containerOnActionTriggerAnimation3']!,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Urgent',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        color: valueOrDefault<Color>(
                                          FFAppState().ItemTriageLevels == 3
                                              ? Color(0xFFDC8610)
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                                Text(
                                  'เร่งด่วนปานกลาง',
                                  maxLines: 1,
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
                              ],
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                  () => InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          FFAppState().ItemTriageLevels = 4;
                          safeSetState(() {});
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation4'] !=
                              null) {
                            animationsMap['containerOnActionTriggerAnimation4']!
                                .controller
                                .forward(from: 0.0);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 4
                                          ? Color(0x8037BD80)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 4
                                          ? Color(0x80006838)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    )
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/ESI4.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                              animationsMap[
                                  'containerOnActionTriggerAnimation4']!,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Semi-urgent',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        color: valueOrDefault<Color>(
                                          FFAppState().ItemTriageLevels == 4
                                              ? FlutterFlowTheme.of(context)
                                                  .customColor6
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                                Text(
                                  'อาการไม่รุนแรงมาก',
                                  maxLines: 1,
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
                              ],
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                  () => InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          FFAppState().ItemTriageLevels = 5;
                          safeSetState(() {});
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation5'] !=
                              null) {
                            animationsMap['containerOnActionTriggerAnimation5']!
                                .controller
                                .forward(from: 0.0);
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 40.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 5
                                          ? Color(0x7F838689)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    ),
                                    valueOrDefault<Color>(
                                      FFAppState().ItemTriageLevels == 5
                                          ? Color(0x7F465054)
                                          : FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                    )
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 24.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 32.0;
                                    } else {
                                      return 32.0;
                                    }
                                  }(),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/ESI5.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ).animateOnActionTrigger(
                              animationsMap[
                                  'containerOnActionTriggerAnimation5']!,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Non-Urgent',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        color: valueOrDefault<Color>(
                                          FFAppState().ItemTriageLevels == 5
                                              ? FlutterFlowTheme.of(context)
                                                  .secondaryText
                                              : FlutterFlowTheme.of(context)
                                                  .primaryText,
                                          FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                ),
                                Text(
                                  'ไม่เร่งด่วน',
                                  maxLines: 1,
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
                              ],
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                ][index]();
              },
            ),
          ].divide(SizedBox(height: 8.0)),
        ),
      ),
    );
  }
}
