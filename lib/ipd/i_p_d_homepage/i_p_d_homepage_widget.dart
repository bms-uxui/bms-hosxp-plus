import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/widget/admit_i_p_dpage/admit_i_p_dpage_widget.dart';
import '/ipd/widget/averagesleepdays_i_p_dpage/averagesleepdays_i_p_dpage_widget.dart';
import '/ipd/widget/bedoccupancyrate_i_p_dpage/bedoccupancyrate_i_p_dpage_widget.dart';
import '/ipd/widget/button_i_p_d_admit/button_i_p_d_admit_widget.dart';
import '/ipd/widget/button_i_p_d_averagesleepdays/button_i_p_d_averagesleepdays_widget.dart';
import '/ipd/widget/button_i_p_d_bedoccupancyrate/button_i_p_d_bedoccupancyrate_widget.dart';
import '/ipd/widget/button_i_p_d_discharge/button_i_p_d_discharge_widget.dart';
import '/ipd/widget/button_i_p_d_emptybed/button_i_p_d_emptybed_widget.dart';
import '/ipd/widget/button_i_p_d_treat/button_i_p_d_treat_widget.dart';
import '/ipd/widget/discharge_i_p_dpage/discharge_i_p_dpage_widget.dart';
import '/ipd/widget/emptybed_i_p_dpage/emptybed_i_p_dpage_widget.dart';
import '/ipd/widget/treat_i_p_dpage/treat_i_p_dpage_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'i_p_d_homepage_model.dart';
export 'i_p_d_homepage_model.dart';

class IPDHomepageWidget extends StatefulWidget {
  const IPDHomepageWidget({super.key});

  static String routeName = 'IPD_Homepage';
  static String routePath = 'iPDHomepage';

  @override
  State<IPDHomepageWidget> createState() => _IPDHomepageWidgetState();
}

class _IPDHomepageWidgetState extends State<IPDHomepageWidget>
    with TickerProviderStateMixin {
  late IPDHomepageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IPDHomepageModel());

    animationsMap.addAll({
      'buttonIPDTreatOnActionTriggerAnimation': AnimationInfo(
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
      'buttonIPDAdmitOnActionTriggerAnimation': AnimationInfo(
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
      'buttonIPDEmptybedOnActionTriggerAnimation': AnimationInfo(
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
      'buttonIPDDischargeOnActionTriggerAnimation': AnimationInfo(
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
      'buttonIPDAveragesleepdaysOnActionTriggerAnimation': AnimationInfo(
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
      'buttonIPDBedoccupancyrateOnActionTriggerAnimation': AnimationInfo(
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
                            itemCount: 6,
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
                                                'buttonIPDTreatOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonIPDTreatOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeipdmenu = 1;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonIPDTreatModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonIPDTreatWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonIPDTreatOnActionTriggerAnimation']!,
                                    ),
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonIPDAdmitOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonIPDAdmitOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeipdmenu = 2;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonIPDAdmitModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonIPDAdmitWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonIPDAdmitOnActionTriggerAnimation']!,
                                    ),
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonIPDEmptybedOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonIPDEmptybedOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeipdmenu = 3;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonIPDEmptybedModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonIPDEmptybedWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonIPDEmptybedOnActionTriggerAnimation']!,
                                    ),
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonIPDDischargeOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonIPDDischargeOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeipdmenu = 4;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonIPDDischargeModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonIPDDischargeWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonIPDDischargeOnActionTriggerAnimation']!,
                                    ),
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonIPDAveragesleepdaysOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonIPDAveragesleepdaysOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeipdmenu = 5;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model
                                            .buttonIPDAveragesleepdaysModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child:
                                            ButtonIPDAveragesleepdaysWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonIPDAveragesleepdaysOnActionTriggerAnimation']!,
                                    ),
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonIPDBedoccupancyrateOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonIPDBedoccupancyrateOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().homeipdmenu = 6;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model
                                            .buttonIPDBedoccupancyrateModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child:
                                            ButtonIPDBedoccupancyrateWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonIPDBedoccupancyrateOnActionTriggerAnimation']!,
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
                              if (FFAppState().homeipdmenu == 1)
                                Container(
                                  child: wrapWithModel(
                                    model: _model.treatIPDpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: TreatIPDpageWidget(),
                                  ),
                                ),
                              if (FFAppState().homeipdmenu == 2)
                                Container(
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, -1.0),
                                    child: wrapWithModel(
                                      model: _model.admitIPDpageModel,
                                      updateCallback: () => safeSetState(() {}),
                                      child: AdmitIPDpageWidget(),
                                    ),
                                  ),
                                ),
                              if (FFAppState().homeipdmenu == 3)
                                Container(
                                  child: wrapWithModel(
                                    model: _model.emptybedIPDpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: EmptybedIPDpageWidget(),
                                  ),
                                ),
                              if (FFAppState().homeipdmenu == 4)
                                Container(
                                  child: wrapWithModel(
                                    model: _model.dischargeIPDpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: DischargeIPDpageWidget(),
                                  ),
                                ),
                              if (FFAppState().homeipdmenu == 5)
                                Container(
                                  child: wrapWithModel(
                                    model: _model.averagesleepdaysIPDpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: AveragesleepdaysIPDpageWidget(),
                                  ),
                                ),
                              if (FFAppState().homeipdmenu == 6)
                                Container(
                                  child: wrapWithModel(
                                    model: _model.bedoccupancyrateIPDpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: BedoccupancyrateIPDpageWidget(),
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
                          navbar: 3,
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
                                  return 90.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 90.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 116.0;
                                } else {
                                  return 116.0;
                                }
                              }(),
                              0.0,
                            )),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context
                                    .pushNamed(SummarizeChartWidget.routeName);
                              },
                              child: wrapWithModel(
                                model: _model.bottonSecondaryModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: BottonSecondaryWidget(
                                  buttonsecondary: 'รอสรุป Chart',
                                  icon: Icon(
                                    Icons.table_chart,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    size: 16.0,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                    ExaminationroomIPDWidget.routeName);
                              },
                              child: wrapWithModel(
                                model: _model.bottonSecondaryModel2,
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
                          ].divide(SizedBox(width: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 8.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 8.0;
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
