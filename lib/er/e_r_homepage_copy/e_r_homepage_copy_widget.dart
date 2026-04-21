import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/er/er_dashboard/widgets/chief_complaints/chief_complaints_widget.dart';
import '/er/er_dashboard/widgets/disposition/disposition_widget.dart';
import '/er/er_dashboard/widgets/kpi_overview_section/kpi_overview_section_widget.dart';
import '/er/er_dashboard/widgets/length_of_stay/length_of_stay_widget.dart';
import '/er/er_dashboard/widgets/patient_flow/patient_flow_widget.dart';
import '/er/er_dashboard/widgets/triage_classification/triage_classification_widget.dart';
import '/er/widget/doctor_visit_completed_view/doctor_visit_completed_view_widget.dart';
import '/er/widget/pendingdoctorvisit_view/pendingdoctorvisit_view_widget.dart';
import '/er/widget/pendinghistorytaking_view/pendinghistorytaking_view_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'e_r_homepage_copy_model.dart';
export 'e_r_homepage_copy_model.dart';

class ERHomepageCopyWidget extends StatefulWidget {
  const ERHomepageCopyWidget({super.key});

  static String routeName = 'ER_HomepageCopy';
  static String routePath = 'eRHomepageCopy';

  @override
  State<ERHomepageCopyWidget> createState() => _ERHomepageCopyWidgetState();
}

class _ERHomepageCopyWidgetState extends State<ERHomepageCopyWidget>
    with TickerProviderStateMixin {
  late ERHomepageCopyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasContainerTriggered1 = false;
  var hasContainerTriggered2 = false;
  var hasContainerTriggered3 = false;
  var hasContainerTriggered4 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ERHomepageCopyModel());

    animationsMap.addAll({
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
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
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  valueOrDefault<double>(
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
                                  ),
                                  0.0,
                                  valueOrDefault<double>(
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
                                  ),
                                  0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ทะเบียนผู้ป่วยฉุกเฉิน',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyLargeIsCustom,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  valueOrDefault<double>(
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
                                  ),
                                  0.0,
                                  valueOrDefault<double>(
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
                                  ),
                                  0.0),
                              child: wrapWithModel(
                                model: _model.searchBarSecondaryModel,
                                updateCallback: () => safeSetState(() {}),
                                child: SearchBarSecondaryWidget(),
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(
                                        0.0,
                                        2.0,
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 20.0,
                                      sigmaY: 20.0,
                                    ),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.filter = 1;
                                        safeSetState(() {});
                                        if (animationsMap[
                                                'containerOnActionTriggerAnimation1'] !=
                                            null) {
                                          safeSetState(() =>
                                              hasContainerTriggered1 = true);
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) async =>
                                                  animationsMap[
                                                          'containerOnActionTriggerAnimation1']!
                                                      .controller
                                                      .forward(from: 0.0));
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              valueOrDefault<Color>(
                                                _model.filter == 1
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : Color(0x19154194),
                                                Color(0x19154194),
                                              ),
                                              valueOrDefault<Color>(
                                                _model.filter == 1
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                Color(0xCB3675D4),
                                              )
                                            ],
                                            stops: [0.0, 1.0],
                                            begin:
                                                AlignmentDirectional(0.0, -1.0),
                                            end: AlignmentDirectional(0, 1.0),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                            color: Color(0x98FFFFFF),
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  valueOrDefault<double>(
                                                    () {
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
                                                        return 16.0;
                                                      } else {
                                                        return 16.0;
                                                      }
                                                    }(),
                                                    0.0,
                                                  ),
                                                  4.0),
                                          child: Text(
                                            'รอคัดกรอง',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: _model.filter == 1
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation1']!,
                                  hasBeenTriggered: hasContainerTriggered1),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(
                                        0.0,
                                        2.0,
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 20.0,
                                      sigmaY: 20.0,
                                    ),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.filter = 2;
                                        safeSetState(() {});
                                        if (animationsMap[
                                                'containerOnActionTriggerAnimation2'] !=
                                            null) {
                                          safeSetState(() =>
                                              hasContainerTriggered2 = true);
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) async =>
                                                  animationsMap[
                                                          'containerOnActionTriggerAnimation2']!
                                                      .controller
                                                      .forward(from: 0.0));
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              valueOrDefault<Color>(
                                                _model.filter == 2
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : Color(0x19154194),
                                                Color(0x19154194),
                                              ),
                                              valueOrDefault<Color>(
                                                _model.filter == 2
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                Color(0xCB3675D4),
                                              )
                                            ],
                                            stops: [0.0, 1.0],
                                            begin:
                                                AlignmentDirectional(0.0, -1.0),
                                            end: AlignmentDirectional(0, 1.0),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                            color: Color(0x98FFFFFF),
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  valueOrDefault<double>(
                                                    () {
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
                                                        return 16.0;
                                                      } else {
                                                        return 16.0;
                                                      }
                                                    }(),
                                                    0.0,
                                                  ),
                                                  4.0),
                                          child: Text(
                                            'รอตรวจ',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: _model.filter == 2
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation2']!,
                                  hasBeenTriggered: hasContainerTriggered2),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(
                                        0.0,
                                        2.0,
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 20.0,
                                      sigmaY: 20.0,
                                    ),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.filter = 3;
                                        safeSetState(() {});
                                        if (animationsMap[
                                                'containerOnActionTriggerAnimation3'] !=
                                            null) {
                                          safeSetState(() =>
                                              hasContainerTriggered3 = true);
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) async =>
                                                  animationsMap[
                                                          'containerOnActionTriggerAnimation3']!
                                                      .controller
                                                      .forward(from: 0.0));
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              valueOrDefault<Color>(
                                                _model.filter == 3
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : Color(0x19154194),
                                                Color(0x19154194),
                                              ),
                                              valueOrDefault<Color>(
                                                _model.filter == 3
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                Color(0xCB3675D4),
                                              )
                                            ],
                                            stops: [0.0, 1.0],
                                            begin:
                                                AlignmentDirectional(0.0, -1.0),
                                            end: AlignmentDirectional(0, 1.0),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                            color: Color(0x98FFFFFF),
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  valueOrDefault<double>(
                                                    () {
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
                                                        return 16.0;
                                                      } else {
                                                        return 16.0;
                                                      }
                                                    }(),
                                                    0.0,
                                                  ),
                                                  4.0),
                                          child: Text(
                                            'ตรวจแล้ว',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: _model.filter == 3
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation3']!,
                                  hasBeenTriggered: hasContainerTriggered3),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(
                                        0.0,
                                        2.0,
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 20.0,
                                      sigmaY: 20.0,
                                    ),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.filter = 4;
                                        safeSetState(() {});
                                        if (animationsMap[
                                                'containerOnActionTriggerAnimation4'] !=
                                            null) {
                                          safeSetState(() =>
                                              hasContainerTriggered4 = true);
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) async =>
                                                  animationsMap[
                                                          'containerOnActionTriggerAnimation4']!
                                                      .controller
                                                      .forward(from: 0.0));
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              valueOrDefault<Color>(
                                                _model.filter == 4
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : Color(0x19154194),
                                                Color(0x19154194),
                                              ),
                                              valueOrDefault<Color>(
                                                _model.filter == 4
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                Color(0xCB3675D4),
                                              )
                                            ],
                                            stops: [0.0, 1.0],
                                            begin:
                                                AlignmentDirectional(0.0, -1.0),
                                            end: AlignmentDirectional(0, 1.0),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          border: Border.all(
                                            color: Color(0x98FFFFFF),
                                          ),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  valueOrDefault<double>(
                                                    () {
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
                                                        return 16.0;
                                                      } else {
                                                        return 16.0;
                                                      }
                                                    }(),
                                                    0.0,
                                                  ),
                                                  4.0),
                                          child: Text(
                                            'แดชบอร์ด',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: _model.filter == 4
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation4']!,
                                  hasBeenTriggered: hasContainerTriggered4),
                            ].divide(SizedBox(width: () {
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
                            }())).addToStart(SizedBox(width: () {
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
                            }())).addToEnd(SizedBox(width: () {
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
                        if (_model.filter != 4)
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
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0),
                              ),
                            ),
                            child: Builder(
                              builder: (context) {
                                if (_model.filter == 1) {
                                  return wrapWithModel(
                                    model: _model.pendinghistorytakingViewModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PendinghistorytakingViewWidget(),
                                  );
                                } else if (_model.filter == 2) {
                                  return wrapWithModel(
                                    model: _model.pendingdoctorvisitViewModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: PendingdoctorvisitViewWidget(),
                                  );
                                } else if (_model.filter == 3) {
                                  return wrapWithModel(
                                    model:
                                        _model.doctorVisitCompletedViewModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: DoctorVisitCompletedViewWidget(),
                                  );
                                } else {
                                  return Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(),
                                  );
                                }
                              },
                            ),
                          ),
                        if (_model.filter == 4) ...[
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                            ),
                            child: const KpiOverviewSectionWidget(),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                            ),
                            child: const TriageClassificationWidget(),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                            ),
                            child: const PatientFlowWidget(),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                            ),
                            child: const LengthOfStayWidget(),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                            ),
                            child: const ChiefComplaintsWidget(),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                              MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium
                                  ? 12.0
                                  : 16.0,
                              0.0,
                            ),
                            child: const DispositionWidget(),
                          ),
                        ],
                        const SizedBox(height: 160.0),
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
                          navbar: 5,
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
                                .pushNamed(RegisPatientipdERWidget.routeName);
                          },
                          child: wrapWithModel(
                            model: _model.bottonSecondaryModel,
                            updateCallback: () => safeSetState(() {}),
                            child: BottonSecondaryWidget(
                              buttonsecondary: 'ลงทะเบียนผู้ป่วย',
                              icon: Icon(
                                Icons.add_rounded,
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
