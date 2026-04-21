import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/e_r_main_view/e_r_main_view_widget.dart';
import '/main/main_view/main_view_widget.dart';
import '/main/menuicon/menuicon_widget.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_page_model.dart';
export 'main_page_model.dart';

class MainPageWidget extends StatefulWidget {
  const MainPageWidget({super.key});

  static String routeName = 'MainPage';
  static String routePath = 'mainPage';

  @override
  State<MainPageWidget> createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget> {
  late MainPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainPageModel());

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
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: FlutterFlowTheme.of(context).accent2,
              automaticallyImplyLeading: false,
              title: Align(
                alignment: AlignmentDirectional(2.1, -0.05),
                child: wrapWithModel(
                  model: _model.appBarUserModel,
                  updateCallback: () => safeSetState(() {}),
                  child: AppBarUserWidget(),
                ),
              ),
              actions: [],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FlutterFlowTheme.of(context).accent1,
                        FlutterFlowTheme.of(context).secondary
                      ],
                      stops: [0.0, 0.8],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                  ),
                ),
              ),
              centerTitle: false,
              toolbarHeight: 70.0,
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
                      FlutterFlowTheme.of(context).secondary,
                      FlutterFlowTheme.of(context).primaryBackground
                    ],
                    stops: [0.0, 0.5],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                ),
                child: Stack(
                  children: [
                    Builder(
                      builder: (context) {
                        if (_model.viewpage == 'หน้าแรก') {
                          return wrapWithModel(
                            model: _model.mainViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: MainViewWidget(),
                          );
                        } else if (_model.viewpage == 'ผู้ป่วยนอก') {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          );
                        } else if (_model.viewpage == 'ผู้ป่วยใน') {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          );
                        } else if (_model.viewpage == 'ฉุกเฉิน') {
                          return ListView(
                            padding: EdgeInsets.fromLTRB(
                              0,
                              8.0,
                              0,
                              0,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: [
                              wrapWithModel(
                                model: _model.eRMainViewModel,
                                updateCallback: () => safeSetState(() {}),
                                child: ERMainViewWidget(),
                              ),
                            ],
                          );
                        } else if (_model.viewpage == 'บริการอื่นๆ') {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.vertical,
                                children: [
                                  wrapWithModel(
                                    model: _model.iconTitleModel,
                                    updateCallback: () => safeSetState(() {}),
                                    child: IconTitleWidget(
                                      titletext: 'บริการอื่นๆ',
                                      icon: Icon(
                                        Icons.grid_view_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        size: 10.0,
                                      ),
                                      color1:
                                          FlutterFlowTheme.of(context).accent2,
                                      color2:
                                          FlutterFlowTheme.of(context).accent1,
                                    ),
                                  ),
                                  MasonryGridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: () {
                                        if (MediaQuery.sizeOf(context).width <
                                            kBreakpointSmall) {
                                          return 1;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointMedium) {
                                          return 1;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointLarge) {
                                          return 2;
                                        } else {
                                          return 2;
                                        }
                                      }(),
                                    ),
                                    crossAxisSpacing: () {
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
                                    mainAxisSpacing: () {
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
                                    itemCount: 1,
                                    padding: EdgeInsets.fromLTRB(
                                      0,
                                      0,
                                      0,
                                      0,
                                    ),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return [
                                        () => Container(
                                              width: double.infinity,
                                              height: 70.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                                image: DecorationImage(
                                                  fit: BoxFit.contain,
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, -1.0),
                                                  image: Image.asset(
                                                    'assets/images/ChatGPT_Image_8_.._2568_13_22_43.png',
                                                  ).image,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(14.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'บริจาคดวงตา',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyLarge
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLargeFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyLargeIsCustom,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      ][index]();
                                    },
                                  ),
                                ].divide(SizedBox(height: () {
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
                                }())),
                              ),
                            ),
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          );
                        }
                      },
                    ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0x00FFFFFF), Color(0xB3FFFFFF)],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              24.0, 16.0, 24.0, 24.0),
                          child: Container(
                            width: double.infinity,
                            height: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 62.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 62.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 82.0;
                              } else {
                                return 82.0;
                              }
                            }(),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8.0,
                                  color: Color(0x33000000),
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
                                  sigmaX: 50.0,
                                  sigmaY: 50.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xB2FFFFFF),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: Color(0x65FFFFFF),
                                        offset: Offset(
                                          0.0,
                                          2.0,
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(100.0),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        wrapWithModel(
                                          model: _model.menuiconModel1,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: Hero(
                                            tag: 'nab',
                                            transitionOnUserGestures: true,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: MenuiconWidget(
                                                icon: Icon(
                                                  Icons.home_filled,
                                                  color: _model.viewpage ==
                                                          'หน้าแรก'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  size: 20.0,
                                                ),
                                                tab: 'หน้าแรก',
                                                stage: _model.viewpage,
                                                action: () async {
                                                  _model.viewpage = 'หน้าแรก';
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.menuiconModel2,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: Hero(
                                            tag: 'nab',
                                            transitionOnUserGestures: true,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: MenuiconWidget(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.hospitalUser,
                                                  color:
                                                      _model.viewpage ==
                                                              'ผู้ป่วยนอก'
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                  size: 16.0,
                                                ),
                                                tab: 'ผู้ป่วยนอก',
                                                stage: _model.viewpage,
                                                action: () async {
                                                  _model.viewpage =
                                                      'ผู้ป่วยนอก';
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.menuiconModel3,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: Hero(
                                            tag: 'nab',
                                            transitionOnUserGestures: true,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: MenuiconWidget(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.procedures,
                                                  color: _model.viewpage ==
                                                          'ผู้ป่วยใน'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  size: 16.0,
                                                ),
                                                tab: 'ผู้ป่วยใน',
                                                stage: _model.viewpage,
                                                action: () async {
                                                  _model.viewpage = 'ผู้ป่วยใน';
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.menuiconModel4,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: Hero(
                                            tag: 'nab',
                                            transitionOnUserGestures: true,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: MenuiconWidget(
                                                icon: FaIcon(
                                                  FontAwesomeIcons.userInjured,
                                                  color: _model.viewpage ==
                                                          'ฉุกเฉิน'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  size: 16.0,
                                                ),
                                                tab: 'ฉุกเฉิน',
                                                stage: _model.viewpage,
                                                action: () async {
                                                  _model.viewpage = 'ฉุกเฉิน';
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.menuiconModel5,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: Hero(
                                            tag: 'nab',
                                            transitionOnUserGestures: true,
                                            child: Material(
                                              color: Colors.transparent,
                                              child: MenuiconWidget(
                                                icon: Icon(
                                                  Icons.grid_view_rounded,
                                                  color: _model.viewpage ==
                                                          'บริการอื่นๆ'
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .primary
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .primaryText,
                                                  size: 20.0,
                                                ),
                                                tab: 'บริการอื่นๆ',
                                                stage: _model.viewpage,
                                                action: () async {
                                                  _model.viewpage =
                                                      'บริการอื่นๆ';
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
