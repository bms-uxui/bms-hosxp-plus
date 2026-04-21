import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/opd/widget/appointment_o_p_dpage/appointment_o_p_dpage_widget.dart';
import '/opd/widget/averagetime_o_p_dpage/averagetime_o_p_dpage_widget.dart';
import '/opd/widget/button_o_p_d_appointment/button_o_p_d_appointment_widget.dart';
import '/opd/widget/button_o_p_d_averagetime/button_o_p_d_averagetime_widget.dart';
import '/opd/widget/button_o_p_d_servicerecipient/button_o_p_d_servicerecipient_widget.dart';
import '/opd/widget/service_o_p_dpage/service_o_p_dpage_widget.dart';
import 'dart:math';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'homepage_o_p_d_model.dart';
export 'homepage_o_p_d_model.dart';

class HomepageOPDWidget extends StatefulWidget {
  const HomepageOPDWidget({super.key});

  static String routeName = 'Homepage_OPD';
  static String routePath = 'homepageOPD';

  @override
  State<HomepageOPDWidget> createState() => _HomepageOPDWidgetState();
}

class _HomepageOPDWidgetState extends State<HomepageOPDWidget>
    with TickerProviderStateMixin {
  late HomepageOPDModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomepageOPDModel());

    animationsMap.addAll({
      'buttonOPDServicerecipientOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'buttonOPDAveragetimeOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'buttonOPDAppointmentOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
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
              title: wrapWithModel(
                model: _model.appBarUserModel,
                updateCallback: () => safeSetState(() {}),
                child: AppBarUserWidget(),
              ),
              actions: [],
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
                child: Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.fromLTRB(
                        0,
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
                        0,
                        () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 160.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 160.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 150.0;
                          } else {
                            return 150.0;
                          }
                        }(),
                      ),
                      scrollDirection: Axis.vertical,
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
                          child: MasonryGridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverSimpleGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 2;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 2;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 3;
                                } else {
                                  return 3;
                                }
                              }(),
                            ),
                            crossAxisSpacing: () {
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
                            mainAxisSpacing: () {
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
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonOPDServicerecipientOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonOPDServicerecipientOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeopdmenu = 1;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model
                                            .buttonOPDServicerecipientModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child:
                                            ButtonOPDServicerecipientWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonOPDServicerecipientOnActionTriggerAnimation']!,
                                    ),
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonOPDAveragetimeOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonOPDAveragetimeOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeopdmenu = 2;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonOPDAveragetimeModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonOPDAveragetimeWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonOPDAveragetimeOnActionTriggerAnimation']!,
                                    ),
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonOPDAppointmentOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonOPDAppointmentOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeopdmenu = 3;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonOPDAppointmentModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonOPDAppointmentWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonOPDAppointmentOnActionTriggerAnimation']!,
                                    ),
                              ][index]();
                            },
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 560.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 560.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 980.0;
                              } else {
                                return 980.0;
                              }
                            }(),
                          ),
                          decoration: BoxDecoration(
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.0),
                              topRight: Radius.circular(24.0),
                            ),
                          ),
                          child: Stack(
                            children: [
                              if (FFAppState().homeopdmenu == 1)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: wrapWithModel(
                                    model: _model.serviceOPDpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ServiceOPDpageWidget(),
                                  ),
                                ),
                              if (FFAppState().homeopdmenu == 2)
                                Container(
                                  child: wrapWithModel(
                                    model: _model.averagetimeOPDpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: AveragetimeOPDpageWidget(),
                                  ),
                                ),
                              if (FFAppState().homeopdmenu == 3)
                                Container(
                                  child: wrapWithModel(
                                    model: _model.appointmentOPDpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: AppointmentOPDpageWidget(),
                                  ),
                                ),
                            ],
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
                    Align(
                      alignment: AlignmentDirectional(0.0, 1.0),
                      child: wrapWithModel(
                        model: _model.navBarModel,
                        updateCallback: () => safeSetState(() {}),
                        child: NavBarWidget(
                          navbar: 2,
                          hide: false,
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(1.0, 1.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0.0,
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
                            valueOrDefault<double>(
                              () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 106.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 106.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 116.0;
                                } else {
                                  return 116.0;
                                }
                              }(),
                              0.0,
                            )),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context
                                .pushNamed(ExaminationroomOPDWidget.routeName);
                          },
                          child: wrapWithModel(
                            model: _model.bottonSecondaryModel,
                            updateCallback: () => safeSetState(() {}),
                            child: BottonSecondaryWidget(
                              buttonsecondary: 'ห้องตรวจ',
                              icon: FaIcon(
                                FontAwesomeIcons.stethoscope,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                size: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
