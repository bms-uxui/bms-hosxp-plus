import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'workflow_model.dart';
export 'workflow_model.dart';

class WorkflowWidget extends StatefulWidget {
  const WorkflowWidget({super.key});

  @override
  State<WorkflowWidget> createState() => _WorkflowWidgetState();
}

class _WorkflowWidgetState extends State<WorkflowWidget>
    with TickerProviderStateMixin {
  late WorkflowModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WorkflowModel());

    animationsMap.addAll({
      'columnOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(-20.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'columnOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(20.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'columnOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(-20.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'columnOnPageLoadAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(20.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'columnOnPageLoadAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(-20.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'columnOnPageLoadAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(20.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, -1.0),
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
        child: Container(
          width: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 300.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 300.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 650.0;
            } else {
              return 650.0;
            }
          }(),
          height: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 600.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 600.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 1200.0;
            } else {
              return 1200.0;
            }
          }(),
          decoration: BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 200.0;
                  } else {
                    return 200.0;
                  }
                }(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'assets/images/line1-8.png',
                    ).image,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, -1.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 0.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 0.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }(),
                              0.0,
                            ),
                            16.0,
                            0.0,
                            0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6.0,
                                    color: Color(0x32FF7540),
                                    offset: Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    spreadRadius: 3.0,
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFF69427),
                                    Color(0xFFC14620)
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 8.0;
                                    } else {
                                      return 8.0;
                                    }
                                  }(),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  '1,100',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 30.0;
                                          } else {
                                            return 30.0;
                                          }
                                        }(),
                                        letterSpacing: 0.0,
                                        shadows: [
                                          Shadow(
                                            color: Color(0x19717171),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 2.0,
                                          )
                                        ],
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.double_arrow_sharp,
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        size: () {
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
                                      ),
                                    ),
                                    Text(
                                      'รอซักประวัติ',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            fontSize: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 22.0;
                                              } else {
                                                return 22.0;
                                              }
                                            }(),
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 12.0;
                                    } else {
                                      return 12.0;
                                    }
                                  }())),
                                ),
                                Text(
                                  'จำนวนคนไข้ที่รอซักประวัติ',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.7,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())),
                            ).animateOnPageLoad(
                                animationsMap['columnOnPageLoadAnimation1']!),
                          ].divide(SizedBox(width: () {
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
                          }())),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/ChatGPT_Image_24_.._2568_14_20_19.png',
                          height: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 60.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 60.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 110.0;
                            } else {
                              return 110.0;
                            }
                          }(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 200.0;
                  } else {
                    return 200.0;
                  }
                }(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'assets/images/line2-8.png',
                    ).image,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            0.0,
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 48.0;
                                } else {
                                  return 48.0;
                                }
                              }(),
                              0.0,
                            ),
                            0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'รอตรวจ',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            fontSize: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 22.0;
                                              } else {
                                                return 22.0;
                                              }
                                            }(),
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                    ),
                                    Transform.rotate(
                                      angle: 180.0 * (math.pi / 180),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Icon(
                                          Icons.double_arrow_sharp,
                                          color: Color(0xFF18844E),
                                          size: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 24.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 24.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 32.0;
                                            } else {
                                              return 32.0;
                                            }
                                          }(),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 12.0;
                                    } else {
                                      return 12.0;
                                    }
                                  }())),
                                ),
                                Text(
                                  'จำนวนคนไข้ที่รอตรวจ',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.7,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())),
                            ).animateOnPageLoad(
                                animationsMap['columnOnPageLoadAnimation2']!),
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6.0,
                                    color: Color(0x3462DE33),
                                    offset: Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    spreadRadius: 4.0,
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF78B826),
                                    Color(0xFF18844E)
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 8.0;
                                    } else {
                                      return 8.0;
                                    }
                                  }(),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  '120',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 30.0;
                                          } else {
                                            return 30.0;
                                          }
                                        }(),
                                        letterSpacing: 0.0,
                                        shadows: [
                                          Shadow(
                                            color: Color(0x19717171),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 2.0,
                                          )
                                        ],
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: () {
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
                          }())),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/ChatGPT_Image_24_.._2568_14_27_57.png',
                          height: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 60.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 60.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 110.0;
                            } else {
                              return 110.0;
                            }
                          }(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 200.0;
                  } else {
                    return 200.0;
                  }
                }(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'assets/images/line3-8.png',
                    ).image,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 0.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 0.0;
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
                            0.0,
                            0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6.0,
                                    color: Color(0x3201D6C8),
                                    offset: Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    spreadRadius: 4.0,
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF01D6C8),
                                    Color(0xFF0086AC)
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 8.0;
                                    } else {
                                      return 8.0;
                                    }
                                  }(),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  '50',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 30.0;
                                          } else {
                                            return 30.0;
                                          }
                                        }(),
                                        letterSpacing: 0.0,
                                        shadows: [
                                          Shadow(
                                            color: Color(0x19717171),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 2.0,
                                          )
                                        ],
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.double_arrow_sharp,
                                        color: Color(0xFF0086AC),
                                        size: () {
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
                                      ),
                                    ),
                                    Text(
                                      'รอผล Lab และ X-Ray',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            fontSize: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 22.0;
                                              } else {
                                                return 22.0;
                                              }
                                            }(),
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 12.0;
                                    } else {
                                      return 12.0;
                                    }
                                  }())),
                                ),
                                Text(
                                  'จำนวนคนไข้ที่รอผล Lab และ X-Ray',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.7,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())),
                            ).animateOnPageLoad(
                                animationsMap['columnOnPageLoadAnimation3']!),
                          ].divide(SizedBox(width: () {
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
                          }())),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(1.18, -0.05),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/ChatGPT_Image_24_.._2568_14_36_42.png',
                          height: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 60.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 60.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 110.0;
                            } else {
                              return 110.0;
                            }
                          }(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 200.0;
                  } else {
                    return 200.0;
                  }
                }(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'assets/images/line4.png',
                    ).image,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 48.0;
                                } else {
                                  return 48.0;
                                }
                              }(),
                              0.0,
                            ),
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 48.0;
                                } else {
                                  return 48.0;
                                }
                              }(),
                              0.0,
                            ),
                            0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'รอรับยา',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            fontSize: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 22.0;
                                              } else {
                                                return 22.0;
                                              }
                                            }(),
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                    ),
                                    Transform.rotate(
                                      angle: 180.0 * (math.pi / 180),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Icon(
                                          Icons.double_arrow_sharp,
                                          color: Color(0xFF7239A3),
                                          size: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 24.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 24.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 32.0;
                                            } else {
                                              return 32.0;
                                            }
                                          }(),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 12.0;
                                    } else {
                                      return 12.0;
                                    }
                                  }())),
                                ),
                                Text(
                                  'จำนวนคนไข้ที่รอรับยา',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.7,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())),
                            ).animateOnPageLoad(
                                animationsMap['columnOnPageLoadAnimation4']!),
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6.0,
                                    color: Color(0x322365E5),
                                    offset: Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    spreadRadius: 4.0,
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF2365E5),
                                    Color(0xFF7239A3)
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 8.0;
                                    } else {
                                      return 8.0;
                                    }
                                  }(),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  '30',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 30.0;
                                          } else {
                                            return 30.0;
                                          }
                                        }(),
                                        letterSpacing: 0.0,
                                        shadows: [
                                          Shadow(
                                            color: Color(0x19717171),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 2.0,
                                          )
                                        ],
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: () {
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
                          }())),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 48.0;
                                } else {
                                  return 48.0;
                                }
                              }(),
                              0.0,
                            ),
                            0.0,
                            0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/ChatGPT_Image_24_.._2568_14_38_44.png',
                            height: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 60.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 60.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 110.0;
                              } else {
                                return 110.0;
                              }
                            }(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 200.0;
                  } else {
                    return 200.0;
                  }
                }(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'assets/images/line5.png',
                    ).image,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 0.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 0.0;
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
                                  return 32.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 32.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 56.0;
                                } else {
                                  return 56.0;
                                }
                              }(),
                              0.0,
                            ),
                            0.0,
                            0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6.0,
                                    color: Color(0x32D457D5),
                                    offset: Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    spreadRadius: 4.0,
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFD457D5),
                                    Color(0xFFCC1933)
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 8.0;
                                    } else {
                                      return 8.0;
                                    }
                                  }(),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  '20',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 30.0;
                                          } else {
                                            return 30.0;
                                          }
                                        }(),
                                        letterSpacing: 0.0,
                                        shadows: [
                                          Shadow(
                                            color: Color(0x19717171),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 2.0,
                                          )
                                        ],
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Icon(
                                        Icons.double_arrow_sharp,
                                        color: Color(0xFFCC1933),
                                        size: () {
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
                                      ),
                                    ),
                                    Text(
                                      'Admit',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            fontSize: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 22.0;
                                              } else {
                                                return 22.0;
                                              }
                                            }(),
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 12.0;
                                    } else {
                                      return 12.0;
                                    }
                                  }())),
                                ),
                                Text(
                                  'จำนวนคนไข้ที่ Admit',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.7,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())),
                            ).animateOnPageLoad(
                                animationsMap['columnOnPageLoadAnimation5']!),
                          ].divide(SizedBox(width: () {
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
                          }())),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 48.0;
                                } else {
                                  return 48.0;
                                }
                              }(),
                              0.0,
                            ),
                            0.0,
                            0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/ChatGPT_Image_7_.._2568_17_57_10.png',
                            height: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 60.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 60.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 110.0;
                              } else {
                                return 110.0;
                              }
                            }(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 100.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 200.0;
                  } else {
                    return 200.0;
                  }
                }(),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset(
                      'assets/images/line6.png',
                    ).image,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 48.0;
                                } else {
                                  return 48.0;
                                }
                              }(),
                              0.0,
                            ),
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 48.0;
                                } else {
                                  return 48.0;
                                }
                              }(),
                              0.0,
                            ),
                            0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      'กลับบ้าน',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            fontSize: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 22.0;
                                              } else {
                                                return 22.0;
                                              }
                                            }(),
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                    ),
                                    Transform.rotate(
                                      angle: 180.0 * (math.pi / 180),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Icon(
                                          Icons.double_arrow_sharp,
                                          color: Color(0xFFDF5B28),
                                          size: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 24.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 24.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 32.0;
                                            } else {
                                              return 32.0;
                                            }
                                          }(),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 4.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 12.0;
                                    } else {
                                      return 12.0;
                                    }
                                  }())),
                                ),
                                Text(
                                  'จำนวนคนไข้ที่กลับบ้านแล้ว',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.7,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                ),
                              ].divide(SizedBox(height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 4.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())),
                            ).animateOnPageLoad(
                                animationsMap['columnOnPageLoadAnimation6']!),
                            Container(
                              width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
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
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6.0,
                                    color: Color(0x33DF5B28),
                                    offset: Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    spreadRadius: 4.0,
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFEE5C7B),
                                    Color(0xFFDF5B28)
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 3.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 8.0;
                                    } else {
                                      return 8.0;
                                    }
                                  }(),
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  '90',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        fontSize: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 16.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 30.0;
                                          } else {
                                            return 30.0;
                                          }
                                        }(),
                                        letterSpacing: 0.0,
                                        shadows: [
                                          Shadow(
                                            color: Color(0x19717171),
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 2.0,
                                          )
                                        ],
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: () {
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
                          }())),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            'assets/images/ChatGPT_Image_2_.._2568_13_41_16.png',
                            height: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 60.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 60.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 110.0;
                              } else {
                                return 110.0;
                              }
                            }(),
                            fit: BoxFit.cover,
                          ),
                        ),
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
