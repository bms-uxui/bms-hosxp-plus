import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'e_r_homepage_model.dart';
export 'e_r_homepage_model.dart';

class ERHomepageWidget extends StatefulWidget {
  const ERHomepageWidget({super.key});

  static String routeName = 'ER_Homepage';
  static String routePath = 'eRHomepage';

  @override
  State<ERHomepageWidget> createState() => _ERHomepageWidgetState();
}

class _ERHomepageWidgetState extends State<ERHomepageWidget> {
  late ERHomepageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ERHomepageModel());

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
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: ListView(
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
                                  return 126.0;
                                } else {
                                  return 126.0;
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
