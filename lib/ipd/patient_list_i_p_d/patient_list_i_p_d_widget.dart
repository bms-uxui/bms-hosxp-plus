import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/dsign_system/status_appointment/status_appointment_widget.dart';
import '/dsign_system/status_lab/status_lab_widget.dart';
import '/dsign_system/status_rx/status_rx_widget.dart';
import '/dsign_system/status_tx/status_tx_widget.dart';
import '/dsign_system/status_xray/status_xray_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/fillter_examinationroom_i_p_d/fillter_examinationroom_i_p_d_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'patient_list_i_p_d_model.dart';
export 'patient_list_i_p_d_model.dart';

class PatientListIPDWidget extends StatefulWidget {
  const PatientListIPDWidget({super.key});

  static String routeName = 'Patient_list_IPD';
  static String routePath = 'patientListIPD';

  @override
  State<PatientListIPDWidget> createState() => _PatientListIPDWidgetState();
}

class _PatientListIPDWidgetState extends State<PatientListIPDWidget>
    with TickerProviderStateMixin {
  late PatientListIPDModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientListIPDModel());

    animationsMap.addAll({
      'textOnPageLoadAnimation': AnimationInfo(
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
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).accent2,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: FlutterFlowTheme.of(context).accent2,
              automaticallyImplyLeading: false,
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 54.0,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20.0,
                ),
                onPressed: () async {
                  context.pop();
                },
              ),
              title: Text(
                'Examination room1',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation']!),
              actions: [
                Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          isDismissible: false,
                          useSafeArea: true,
                          context: context,
                          builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: FillterExaminationroomIPDWidget(),
                              ),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          wrapWithModel(
                            model: _model.buttonFillterModel,
                            updateCallback: () => safeSetState(() {}),
                            child: ButtonFillterWidget(
                              colorbg: Color(0x7FE0E3E7),
                              coloricon: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 0.2,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_30_.._2568_11_49_46.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.contain,
                        alignment: Alignment(1.0, 1.0),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.0),
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
                      0.0,
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
                      0.0),
                  child: wrapWithModel(
                    model: _model.searchBarPrimaryModel,
                    updateCallback: () => safeSetState(() {}),
                    child: SearchBarPrimaryWidget(),
                  ),
                ),
              ),
              centerTitle: false,
              toolbarHeight: 64.0,
              elevation: 0.0,
            )
          ],
          body: Builder(
            builder: (context) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xCC3E83E6),
                      FlutterFlowTheme.of(context).primaryBackground,
                      FlutterFlowTheme.of(context).primaryBackground
                    ],
                    stops: [0.0, 0.34, 1.0],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      0.0,
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
                  child: Container(
                    width: double.infinity,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              valueOrDefault<double>(
                                () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 12.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 16.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 16.0;
                                  } else {
                                    return 16.0;
                                  }
                                }(),
                                0.0,
                              ),
                              4.0,
                              valueOrDefault<double>(
                                () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 12.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 16.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 16.0;
                                  } else {
                                    return 16.0;
                                  }
                                }(),
                                0.0,
                              ),
                              0.0),
                          child: ListView(
                            padding: EdgeInsets.fromLTRB(
                              0,
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 16.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }(),
                              0,
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 100.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 100.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 120.0;
                                } else {
                                  return 120.0;
                                }
                              }(),
                            ),
                            scrollDirection: Axis.vertical,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  context.pushNamed(
                                      PatientInfoIPDWidget.routeName);
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(valueOrDefault<double>(
                                      () {
                                        if (MediaQuery.sizeOf(context).width <
                                            kBreakpointSmall) {
                                          return 12.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointMedium) {
                                          return 12.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointLarge) {
                                          return 16.0;
                                        } else {
                                          return 16.0;
                                        }
                                      }(),
                                      0.0,
                                    )),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: () {
                                                if (MediaQuery.sizeOf(context)
                                                        .width <
                                                    kBreakpointSmall) {
                                                  return 48.0;
                                                } else if (MediaQuery.sizeOf(
                                                            context)
                                                        .width <
                                                    kBreakpointMedium) {
                                                  return 48.0;
                                                } else if (MediaQuery.sizeOf(
                                                            context)
                                                        .width <
                                                    kBreakpointLarge) {
                                                  return 56.0;
                                                } else {
                                                  return 56.0;
                                                }
                                              }(),
                                              height: () {
                                                if (MediaQuery.sizeOf(context)
                                                        .width <
                                                    kBreakpointSmall) {
                                                  return 48.0;
                                                } else if (MediaQuery.sizeOf(
                                                            context)
                                                        .width <
                                                    kBreakpointMedium) {
                                                  return 48.0;
                                                } else if (MediaQuery.sizeOf(
                                                            context)
                                                        .width <
                                                    kBreakpointLarge) {
                                                  return 56.0;
                                                } else {
                                                  return 56.0;
                                                }
                                              }(),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                    FlutterFlowTheme.of(context)
                                                        .accent2
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0),
                                                    child: Image.asset(
                                                      'assets/images/ChatGPT_Image_19_.._2568_13_11_36.png',
                                                      width: 200.0,
                                                      height: 200.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            1.0, 1.0),
                                                    child: Container(
                                                      width: () {
                                                        if (MediaQuery.sizeOf(
                                                                    context)
                                                                .width <
                                                            kBreakpointSmall) {
                                                          return 20.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointMedium) {
                                                          return 20.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointLarge) {
                                                          return 24.0;
                                                        } else {
                                                          return 24.0;
                                                        }
                                                      }(),
                                                      height: () {
                                                        if (MediaQuery.sizeOf(
                                                                    context)
                                                                .width <
                                                            kBreakpointSmall) {
                                                          return 20.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointMedium) {
                                                          return 20.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointLarge) {
                                                          return 24.0;
                                                        } else {
                                                          return 24.0;
                                                        }
                                                      }(),
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            blurRadius: 4.0,
                                                            color: Color(
                                                                0x1A000000),
                                                            offset: Offset(
                                                              0.0,
                                                              2.0,
                                                            ),
                                                          )
                                                        ],
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color(0xFF62B3FF),
                                                            Color(0xFF2397FF)
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: FaIcon(
                                                          FontAwesomeIcons.mars,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: () {
                                                            if (MediaQuery.sizeOf(
                                                                        context)
                                                                    .width <
                                                                kBreakpointSmall) {
                                                              return 12.0;
                                                            } else if (MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width <
                                                                kBreakpointMedium) {
                                                              return 12.0;
                                                            } else if (MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width <
                                                                kBreakpointLarge) {
                                                              return 14.0;
                                                            } else {
                                                              return 14.0;
                                                            }
                                                          }(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'นายทดลอง ทดสอบ',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLargeFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyLargeIsCustom,
                                                                ),
                                                      ),
                                                      wrapWithModel(
                                                        model: _model
                                                            .iconButtonTertiaryModel,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child:
                                                            IconButtonTertiaryWidget(
                                                          iconbuttontertiary:
                                                              Icon(
                                                            Icons
                                                                .keyboard_arrow_right_rounded,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            size: 14.0,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        'อายุ 26 ปี',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Color(0xFFF56775),
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .error
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      12.0,
                                                                      2.0,
                                                                      12.0,
                                                                      2.0),
                                                          child: Text(
                                                            'เตียง M001',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  fontSize: () {
                                                                    if (MediaQuery.sizeOf(context)
                                                                            .width <
                                                                        kBreakpointSmall) {
                                                                      return 10.0;
                                                                    } else if (MediaQuery.sizeOf(context)
                                                                            .width <
                                                                        kBreakpointMedium) {
                                                                      return 10.0;
                                                                    } else if (MediaQuery.sizeOf(context)
                                                                            .width <
                                                                        kBreakpointLarge) {
                                                                      return 12.0;
                                                                    } else {
                                                                      return 12.0;
                                                                    }
                                                                  }(),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 12.0)),
                                                  ),
                                                ].divide(SizedBox(height: 2.0)),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 12.0)),
                                        ),
                                        StyledDivider(
                                          height: 1.0,
                                          thickness: 1.0,
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          lineStyle: DividerLineStyle.dashed,
                                        ),
                                        MasonryGridView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 3;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 3;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 5;
                                              } else {
                                                return 5;
                                              }
                                            }(),
                                          ),
                                          crossAxisSpacing: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 8.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 12.0;
                                            } else {
                                              return 12.0;
                                            }
                                          }(),
                                          mainAxisSpacing: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 8.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 12.0;
                                            } else {
                                              return 12.0;
                                            }
                                          }(),
                                          itemCount: 3,
                                          padding: EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            0,
                                          ),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return [
                                              () => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'AN',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                      Text(
                                                        '123456 78',
                                                        maxLines: 1,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                              () => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'จำนวนวันนอน',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                      Text(
                                                        '15 วัน',
                                                        maxLines: 1,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                              () => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'ประเภทคนไข้',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                      Text(
                                                        'คนไข้ทั่วไป',
                                                        maxLines: 1,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                            ][index]();
                                          },
                                        ),
                                        StyledDivider(
                                          height: 1.0,
                                          thickness: 1.0,
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          lineStyle: DividerLineStyle.dashed,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 24.0,
                                              height: 24.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    FlutterFlowTheme.of(context)
                                                        .accent2,
                                                    FlutterFlowTheme.of(context)
                                                        .accent1
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.56, -1.0),
                                                  end: AlignmentDirectional(
                                                      -0.56, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Container(
                                                width: 32.0,
                                                height: 32.0,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Image.asset(
                                                  'assets/images/ChatGPT_Image_19_.._2568_09_09_19.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            RichText(
                                              textScaler: MediaQuery.of(context)
                                                  .textScaler,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'แพทย์ผู้ตรวจ : ',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: 'กตัญญุตา อุ่นจันทร์',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  )
                                                ],
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 8.0)),
                                        ),
                                        Wrap(
                                          spacing: 8.0,
                                          runSpacing: 8.0,
                                          alignment: WrapAlignment.start,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.start,
                                          direction: Axis.horizontal,
                                          runAlignment: WrapAlignment.start,
                                          verticalDirection:
                                              VerticalDirection.down,
                                          clipBehavior: Clip.none,
                                          children: [
                                            wrapWithModel(
                                              model: _model.statusLabModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: StatusLabWidget(),
                                            ),
                                            wrapWithModel(
                                              model: _model.statusXrayModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: StatusXrayWidget(),
                                            ),
                                            wrapWithModel(
                                              model: _model.statusTxModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: StatusTxWidget(),
                                            ),
                                            wrapWithModel(
                                              model: _model.statusRxModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: StatusRxWidget(),
                                            ),
                                            wrapWithModel(
                                              model:
                                                  _model.statusAppointmentModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: StatusAppointmentWidget(),
                                            ),
                                          ],
                                        ),
                                      ].divide(SizedBox(height: 12.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: () {
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
