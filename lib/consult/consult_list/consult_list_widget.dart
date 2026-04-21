import '/consult/ask_conslult/ask_conslult_widget.dart';
import '/consult/ask_conslult_detail/ask_conslult_detail_widget.dart';
import '/consult/ask_conslult_detail3/ask_conslult_detail3_widget.dart';
import '/consult/fillter_consult/fillter_consult_widget.dart';
import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'consult_list_model.dart';
export 'consult_list_model.dart';

class ConsultListWidget extends StatefulWidget {
  const ConsultListWidget({super.key});

  static String routeName = 'Consult_list';
  static String routePath = 'consultList';

  @override
  State<ConsultListWidget> createState() => _ConsultListWidgetState();
}

class _ConsultListWidgetState extends State<ConsultListWidget>
    with TickerProviderStateMixin {
  late ConsultListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConsultListModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

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
              leading: Align(
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: FlutterFlowIconButton(
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
              ),
              title: Text(
                'Consult',
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
                  alignment: AlignmentDirectional(0.0, 0.0),
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
                                child: FillterConsultWidget(),
                              ),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                      child: wrapWithModel(
                        model: _model.buttonFillterModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ButtonFillterWidget(),
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
                    child: Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          alignment: AlignmentDirectional(1.0, 1.0),
                          image: Image.asset(
                            'assets/images/ChatGPT_Image_17_.._2568_10_35_15.png',
                          ).image,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            FlutterFlowTheme.of(context).primary,
                            FlutterFlowTheme.of(context).secondary
                          ],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(0.0, -1.0),
                          end: AlignmentDirectional(0, 1.0),
                        ),
                      ),
                    ),
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
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment(0.0, 0),
                        child: TabBar(
                          labelColor: FlutterFlowTheme.of(context).primaryText,
                          unselectedLabelColor:
                              FlutterFlowTheme.of(context).secondaryText,
                          labelPadding: EdgeInsets.all(2.0),
                          labelStyle: FlutterFlowTheme.of(context)
                              .labelLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .labelLargeFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .labelLargeIsCustom,
                              ),
                          unselectedLabelStyle: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyLargeFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyLargeIsCustom,
                              ),
                          indicatorColor: FlutterFlowTheme.of(context).primary,
                          tabs: [
                            Tab(
                              text: 'รอ Consult',
                            ),
                            Tab(
                              text: 'ส่ง Consult',
                            ),
                          ],
                          controller: _model.tabBarController,
                          onTap: (i) async {
                            [() async {}, () async {}][i]();
                          },
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _model.tabBarController,
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
                                        return 16.0;
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
                                        return 16.0;
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
                              child: ListView(
                                padding: EdgeInsets.fromLTRB(
                                  0,
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
                                  0,
                                  24.0,
                                ),
                                scrollDirection: Axis.vertical,
                                children: [
                                  InkWell(
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
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: AskConslultWidget(),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
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
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 56.0;
                                                    } else {
                                                      return 56.0;
                                                    }
                                                  }(),
                                                  height: () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 1.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_forward_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 12.0,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 24.0,
                                                              height: 24.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                        8.0,
                                                                    color: Color(
                                                                        0x33000000),
                                                                    offset:
                                                                        Offset(
                                                                      0.0,
                                                                      2.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent2
                                                                  ],
                                                                  stops: [
                                                                    0.0,
                                                                    1.0
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0,
                                                                          1.0),
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100.0),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                                      width:
                                                                          200.0,
                                                                      height:
                                                                          200.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 4.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'นายแพทย์ทดลอง ทดสอบ',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
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
                                                          Container(
                                                            width: 12.0,
                                                            height: 12.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      4.0,
                                                                  color: Color(
                                                                      0x33000000),
                                                                  offset:
                                                                      Offset(
                                                                    0.0,
                                                                    2.0,
                                                                  ),
                                                                )
                                                              ],
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFFE93A4B),
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .error
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        0, 1.0),
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      wrapWithModel(
                                                        model: _model
                                                            .dateandTimeRecordeModel1,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child:
                                                            DateandTimeRecordeWidget(),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 2.0)),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 12.0)),
                                            ),
                                            StyledDivider(
                                              height: 1.0,
                                              thickness: 1.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              lineStyle:
                                                  DividerLineStyle.dashed,
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_20_.._2568_16_00_35.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'ชื่อผู้ป่วย : ',
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
                                                      TextSpan(
                                                        text: 'ทดลอง ทดสอบ',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'HN : ',
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
                                                      TextSpan(
                                                        text: '000001',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .question_mark_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          'คำถาม',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Text(
                                                      'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                      maxLines: 2,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 12.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
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
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                        'assets/images/ChatGPT_Image_19_.._2568_09_09_19.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              1.0, 1.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Container(
                                                            width: 16.0,
                                                            height: 16.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_forward_rounded,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                size: 12.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 24.0,
                                                            height: 24.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      8.0,
                                                                  color: Color(
                                                                      0x33000000),
                                                                  offset:
                                                                      Offset(
                                                                    0.0,
                                                                    2.0,
                                                                  ),
                                                                )
                                                              ],
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent2
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        0, 1.0),
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                width: 1.0,
                                                              ),
                                                            ),
                                                            child: Stack(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100.0),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                                    width:
                                                                        200.0,
                                                                    height:
                                                                        200.0,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 4.0)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'นายแพทย์ทดลอง ทดสอบ',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
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
                                                        Container(
                                                          width: 12.0,
                                                          height: 12.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 4.0,
                                                                color: Color(
                                                                    0x33000000),
                                                                offset: Offset(
                                                                  0.0,
                                                                  2.0,
                                                                ),
                                                              )
                                                            ],
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Color(
                                                                    0xFFE93A4B),
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .error
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .dateandTimeRecordeModel2,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          DateandTimeRecordeWidget(),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 2.0)),
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
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                        'assets/images/ChatGPT_Image_20_.._2568_16_06_55.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                textScaler:
                                                    MediaQuery.of(context)
                                                        .textScaler,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'ชื่อผู้ป่วย : ',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallIsCustom,
                                                          ),
                                                    ),
                                                    TextSpan(
                                                      text: 'ทดลอง ทดสอบ',
                                                      style: FlutterFlowTheme
                                                              .of(context)
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
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallIsCustom,
                                                          ),
                                                    )
                                                  ],
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                              RichText(
                                                textScaler:
                                                    MediaQuery.of(context)
                                                        .textScaler,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'HN : ',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallIsCustom,
                                                          ),
                                                    ),
                                                    TextSpan(
                                                      text: '000001',
                                                      style: FlutterFlowTheme
                                                              .of(context)
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
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallIsCustom,
                                                          ),
                                                    )
                                                  ],
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 8.0)),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  valueOrDefault<double>(
                                                () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 12.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 12.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
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
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .question_mark_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        size: 16.0,
                                                      ),
                                                      Text(
                                                        'คำถาม',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                  Text(
                                                    'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                    maxLines: 2,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 12.0)),
                                      ),
                                    ),
                                  ),
                                  Container(
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
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0),
                                                    child: Image.asset(
                                                      'assets/images/ChatGPT_Image_17_.._2568_10_35_15.png',
                                                      width: 200.0,
                                                      height: 200.0,
                                                      fit: BoxFit.cover,
                                                      alignment:
                                                          Alignment(0.0, 0.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'อายุรกรรม',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
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
                                                        Container(
                                                          width: 12.0,
                                                          height: 12.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 4.0,
                                                                color: Color(
                                                                    0x33000000),
                                                                offset: Offset(
                                                                  0.0,
                                                                  2.0,
                                                                ),
                                                              )
                                                            ],
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Color(
                                                                    0xFFE93A4B),
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .error
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .dateandTimeRecordeModel3,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          DateandTimeRecordeWidget(),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 2.0)),
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
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                        'assets/images/ChatGPT_Image_19_.._2568_10_16_09.png',
                                                        width: 200.0,
                                                        height: 200.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                textScaler:
                                                    MediaQuery.of(context)
                                                        .textScaler,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'ชื่อผู้ป่วย : ',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallIsCustom,
                                                          ),
                                                    ),
                                                    TextSpan(
                                                      text: 'ทดลอง ทดสอบ',
                                                      style: FlutterFlowTheme
                                                              .of(context)
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
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallIsCustom,
                                                          ),
                                                    )
                                                  ],
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                              RichText(
                                                textScaler:
                                                    MediaQuery.of(context)
                                                        .textScaler,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'HN : ',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallIsCustom,
                                                          ),
                                                    ),
                                                    TextSpan(
                                                      text: '000001',
                                                      style: FlutterFlowTheme
                                                              .of(context)
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
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallIsCustom,
                                                          ),
                                                    )
                                                  ],
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 8.0)),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  valueOrDefault<double>(
                                                () {
                                                  if (MediaQuery.sizeOf(context)
                                                          .width <
                                                      kBreakpointSmall) {
                                                    return 12.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
                                                          .width <
                                                      kBreakpointMedium) {
                                                    return 12.0;
                                                  } else if (MediaQuery.sizeOf(
                                                              context)
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
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .question_mark_rounded,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        size: 16.0,
                                                      ),
                                                      Text(
                                                        'คำถาม',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                  Text(
                                                    'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                    maxLines: 2,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 12.0)),
                                      ),
                                    ),
                                  ),
                                  InkWell(
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
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: AskConslultDetailWidget(),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
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
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 56.0;
                                                    } else {
                                                      return 56.0;
                                                    }
                                                  }(),
                                                  height: () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_19_.._2568_09_09_19.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 1.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_forward_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 12.0,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 24.0,
                                                              height: 24.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                        8.0,
                                                                    color: Color(
                                                                        0x33000000),
                                                                    offset:
                                                                        Offset(
                                                                      0.0,
                                                                      2.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent2
                                                                  ],
                                                                  stops: [
                                                                    0.0,
                                                                    1.0
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0,
                                                                          1.0),
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100.0),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                                      width:
                                                                          200.0,
                                                                      height:
                                                                          200.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 4.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'นายแพทย์ทดลอง ทดสอบ',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
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
                                                        ],
                                                      ),
                                                      wrapWithModel(
                                                        model: _model
                                                            .dateandTimeRecordeModel4,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child:
                                                            DateandTimeRecordeWidget(),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 2.0)),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 12.0)),
                                            ),
                                            StyledDivider(
                                              height: 1.0,
                                              thickness: 1.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              lineStyle:
                                                  DividerLineStyle.dashed,
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_19_.._2568_13_11_36.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'ชื่อผู้ป่วย : ',
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
                                                      TextSpan(
                                                        text: 'ทดลอง ทดสอบ',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'HN : ',
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
                                                      TextSpan(
                                                        text: '000001',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .question_mark_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          'คำถาม',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Text(
                                                      'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                      maxLines: 2,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
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
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 24.0,
                                                          height: 24.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent2
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                            child: Image.asset(
                                                              'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                              width: 200.0,
                                                              height: 200.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        RichText(
                                                          textScaler:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .textScaler,
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    'ผู้ตอบ : ',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelSmallIsCustom,
                                                                    ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    'นายแพทยทดลอง ทดสอบ',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodySmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodySmallIsCustom,
                                                                    ),
                                                              )
                                                            ],
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .dateandTimeRecordeModel5,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          DateandTimeRecordeWidget(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          Icons.chat_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          'คำตอบ',
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
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Text(
                                                      'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                      maxLines: 2,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
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
                                        return 16.0;
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
                                        return 16.0;
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
                              child: ListView(
                                padding: EdgeInsets.fromLTRB(
                                  0,
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
                                  0,
                                  () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 100.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 100.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
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
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: AskConslultDetail3Widget(),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
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
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 56.0;
                                                    } else {
                                                      return 56.0;
                                                    }
                                                  }(),
                                                  height: () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 1.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_back_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 12.0,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 24.0,
                                                              height: 24.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                        8.0,
                                                                    color: Color(
                                                                        0x33000000),
                                                                    offset:
                                                                        Offset(
                                                                      0.0,
                                                                      2.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent2
                                                                  ],
                                                                  stops: [
                                                                    0.0,
                                                                    1.0
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0,
                                                                          1.0),
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100.0),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                                      width:
                                                                          200.0,
                                                                      height:
                                                                          200.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 4.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'นายแพทย์ทดลอง ทดสอบ',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
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
                                                        ],
                                                      ),
                                                      wrapWithModel(
                                                        model: _model
                                                            .dateandTimeRecordeModel6,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child:
                                                            DateandTimeRecordeWidget(),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 2.0)),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 12.0)),
                                            ),
                                            StyledDivider(
                                              height: 1.0,
                                              thickness: 1.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              lineStyle:
                                                  DividerLineStyle.dashed,
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_19_.._2568_13_11_36.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'ชื่อผู้ป่วย : ',
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
                                                      TextSpan(
                                                        text: 'ทดลอง ทดสอบ',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'HN : ',
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
                                                      TextSpan(
                                                        text: '000001',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .question_mark_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          'คำถาม',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Text(
                                                      'case Hx trigeminal neuralgia ขาดยาประมาณ 2 เดือนกลับมาด้วยปัญหาเจ็บแก้มขวามาก ได้จ่ายยาเดิมไป อาการไม่ดีขึ้น วันนี้มา follow up มีอาการชาปลายมือขวาเพิ่มขึ้น No evidence of dental cause ',
                                                      maxLines: 2,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 12.0)),
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
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: AskConslultDetailWidget(),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
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
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 56.0;
                                                    } else {
                                                      return 56.0;
                                                    }
                                                  }(),
                                                  height: () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_19_.._2568_09_09_19.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 1.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_back_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 12.0,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 24.0,
                                                              height: 24.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                        8.0,
                                                                    color: Color(
                                                                        0x33000000),
                                                                    offset:
                                                                        Offset(
                                                                      0.0,
                                                                      2.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent2
                                                                  ],
                                                                  stops: [
                                                                    0.0,
                                                                    1.0
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0,
                                                                          1.0),
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100.0),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                                      width:
                                                                          200.0,
                                                                      height:
                                                                          200.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 4.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'นายแพทย์ทดลอง ทดสอบ',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
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
                                                        ],
                                                      ),
                                                      wrapWithModel(
                                                        model: _model
                                                            .dateandTimeRecordeModel7,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child:
                                                            DateandTimeRecordeWidget(),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 2.0)),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 12.0)),
                                            ),
                                            StyledDivider(
                                              height: 1.0,
                                              thickness: 1.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              lineStyle:
                                                  DividerLineStyle.dashed,
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_19_.._2568_13_11_36.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'ชื่อผู้ป่วย : ',
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
                                                      TextSpan(
                                                        text: 'ทดลอง ทดสอบ',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'HN : ',
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
                                                      TextSpan(
                                                        text: '000001',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .question_mark_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          'คำถาม',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Text(
                                                      'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                      maxLines: 2,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
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
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 24.0,
                                                          height: 24.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent2
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                            child: Image.asset(
                                                              'assets/images/ChatGPT_Image_19_.._2568_09_09_19.png',
                                                              width: 200.0,
                                                              height: 200.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        RichText(
                                                          textScaler:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .textScaler,
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    'ผู้ตอบ : ',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelSmallIsCustom,
                                                                    ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    'นายแพทยทดลอง ทดสอบ',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodySmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodySmallIsCustom,
                                                                    ),
                                                              )
                                                            ],
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .dateandTimeRecordeModel8,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          DateandTimeRecordeWidget(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          Icons.chat_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          'คำตอบ',
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
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Text(
                                                      'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                      maxLines: 2,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 12.0)),
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
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: AskConslultDetailWidget(),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
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
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 56.0;
                                                    } else {
                                                      return 56.0;
                                                    }
                                                  }(),
                                                  height: () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 48.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_17_.._2568_10_35_15.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 1.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width: 16.0,
                                                              height: 16.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        0.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_back_rounded,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  size: 12.0,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 24.0,
                                                              height: 24.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                        8.0,
                                                                    color: Color(
                                                                        0x33000000),
                                                                    offset:
                                                                        Offset(
                                                                      0.0,
                                                                      2.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .accent2
                                                                  ],
                                                                  stops: [
                                                                    0.0,
                                                                    1.0
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0,
                                                                          1.0),
                                                                ),
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Stack(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100.0),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                                                      width:
                                                                          200.0,
                                                                      height:
                                                                          200.0,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 4.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'อายุรกรรม',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
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
                                                        ],
                                                      ),
                                                      wrapWithModel(
                                                        model: _model
                                                            .dateandTimeRecordeModel9,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child:
                                                            DateandTimeRecordeWidget(),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 2.0)),
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 12.0)),
                                            ),
                                            StyledDivider(
                                              height: 1.0,
                                              thickness: 1.0,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .alternate,
                                              lineStyle:
                                                  DividerLineStyle.dashed,
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
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
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
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                        child: Image.asset(
                                                          'assets/images/ChatGPT_Image_19_.._2568_13_11_36.png',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'ชื่อผู้ป่วย : ',
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
                                                      TextSpan(
                                                        text: 'ทดลอง ทดสอบ',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                RichText(
                                                  textScaler:
                                                      MediaQuery.of(context)
                                                          .textScaler,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'HN : ',
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
                                                      TextSpan(
                                                        text: '000001',
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
                                                      )
                                                    ],
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .question_mark_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          'คำถาม',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodySmall
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallFamily,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Text(
                                                      'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                      maxLines: 2,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
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
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(
                                                    valueOrDefault<double>(
                                                  () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 12.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 24.0,
                                                          height: 24.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent2
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                            ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                            child: Image.asset(
                                                              'assets/images/ChatGPT_Image_19_.._2568_09_09_19.png',
                                                              width: 200.0,
                                                              height: 200.0,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        RichText(
                                                          textScaler:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .textScaler,
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    'ผู้ตอบ : ',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelSmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelSmallIsCustom,
                                                                    ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    'นายแพทยทดลอง ทดสอบ',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodySmallFamily,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodySmallIsCustom,
                                                                    ),
                                                              )
                                                            ],
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                          ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .dateandTimeRecordeModel10,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child:
                                                          DateandTimeRecordeWidget(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          Icons.chat_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 16.0,
                                                        ),
                                                        Text(
                                                          'คำตอบ',
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
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmallIsCustom,
                                                              ),
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Text(
                                                      'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                                      maxLines: 2,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ),
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
                    ],
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
