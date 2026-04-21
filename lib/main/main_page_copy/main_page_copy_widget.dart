import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/button_mainpage_doctors_rounds/button_mainpage_doctors_rounds_widget.dart';
import '/main/widget/button_mainpage_i_p_d/button_mainpage_i_p_d_widget.dart';
import '/main/widget/doctors_rounds_mainpage/doctors_rounds_mainpage_widget.dart';
import '/main/widget/i_p_d_mainpage/i_p_d_mainpage_widget.dart';
import '/main/widget/o_p_d_mainpage/o_p_d_mainpage_widget.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_page_copy_model.dart';
export 'main_page_copy_model.dart';

class MainPageCopyWidget extends StatefulWidget {
  const MainPageCopyWidget({super.key});

  static String routeName = 'MainPageCopy';
  static String routePath = 'mainPageCopy';

  @override
  State<MainPageCopyWidget> createState() => _MainPageCopyWidgetState();
}

class _MainPageCopyWidgetState extends State<MainPageCopyWidget>
    with TickerProviderStateMixin {
  late MainPageCopyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainPageCopyModel());

    animationsMap.addAll({
      'buttonMainpageIPDOnActionTriggerAnimation': AnimationInfo(
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
      'buttonMainpageDoctorsRoundsOnActionTriggerAnimation': AnimationInfo(
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
                            return 100.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 100.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 110.0;
                          } else {
                            return 110.0;
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
                            itemCount: 2,
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
                                                'buttonMainpageIPDOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonMainpageIPDOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().maintabmenu = 2;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model.buttonMainpageIPDModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: ButtonMainpageIPDWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonMainpageIPDOnActionTriggerAnimation']!,
                                    ),
                                () => InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (animationsMap[
                                                'buttonMainpageDoctorsRoundsOnActionTriggerAnimation'] !=
                                            null) {
                                          animationsMap[
                                                  'buttonMainpageDoctorsRoundsOnActionTriggerAnimation']!
                                              .controller
                                              .forward(from: 0.0);
                                        }
                                        FFAppState().maintabmenu = 3;
                                        safeSetState(() {});
                                      },
                                      child: wrapWithModel(
                                        model: _model
                                            .buttonMainpageDoctorsRoundsModel,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child:
                                            ButtonMainpageDoctorsRoundsWidget(),
                                      ),
                                    ).animateOnActionTrigger(
                                      animationsMap[
                                          'buttonMainpageDoctorsRoundsOnActionTriggerAnimation']!,
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
                              if (FFAppState().maintabmenu == 1)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: wrapWithModel(
                                    model: _model.oPDMainpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: OPDMainpageWidget(),
                                  ),
                                ),
                              if (FFAppState().maintabmenu == 2)
                                Container(
                                  decoration: BoxDecoration(),
                                  child: wrapWithModel(
                                    model: _model.iPDMainpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: IPDMainpageWidget(),
                                  ),
                                ),
                              if (FFAppState().maintabmenu == 3)
                                Container(
                                  child: wrapWithModel(
                                    model: _model.doctorsRoundsMainpageModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: DoctorsRoundsMainpageWidget(),
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
                          navbar: 1,
                          hide: false,
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
