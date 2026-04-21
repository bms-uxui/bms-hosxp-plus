import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'xray_detal_model.dart';
export 'xray_detal_model.dart';

class XrayDetalWidget extends StatefulWidget {
  const XrayDetalWidget({
    super.key,
    this.data,
  });

  final String? data;

  static String routeName = 'Xray_detal';
  static String routePath = 'xrayDetal';

  @override
  State<XrayDetalWidget> createState() => _XrayDetalWidgetState();
}

class _XrayDetalWidgetState extends State<XrayDetalWidget>
    with TickerProviderStateMixin {
  late XrayDetalModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => XrayDetalModel());

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
                'Radiology Report',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation']!),
              actions: [],
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 0.1,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_17_.._2568_17_00_13.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
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
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                  ),
                  child: Padding(
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
                        2.0,
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
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(valueOrDefault<double>(
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
                            )),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    unawaited(
                                      () async {
                                        await Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType.fade,
                                            child: FlutterFlowExpandedImageView(
                                              image: Image.network(
                                                valueOrDefault<String>(
                                                  _model.radiologyReport,
                                                  'https://images.unsplash.com/photo-1616012480717-fd9867059ca0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx4JTIwcmF5fcGVufDB8fHx8MTc1NDI4MjYzNnww&ixlib=rb-4.1.0&q=80&w=1080',
                                                ),
                                                fit: BoxFit.contain,
                                              ),
                                              allowRotation: true,
                                              tag: valueOrDefault<String>(
                                                _model.radiologyReport,
                                                'https://images.unsplash.com/photo-1616012480717-fd9867059ca0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx4JTIwcmF5fcGVufDB8fHx8MTc1NDI4MjYzNnww&ixlib=rb-4.1.0&q=80&w=1080',
                                              ),
                                              useHeroAnimation: true,
                                            ),
                                          ),
                                        );
                                      }(),
                                    );
                                  },
                                  child: Hero(
                                    tag: valueOrDefault<String>(
                                      _model.radiologyReport,
                                      'https://images.unsplash.com/photo-1616012480717-fd9867059ca0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx4JTIwcmF5fcGVufDB8fHx8MTc1NDI4MjYzNnww&ixlib=rb-4.1.0&q=80&w=1080',
                                    ),
                                    transitionOnUserGestures: true,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24.0),
                                      child: Image.network(
                                        valueOrDefault<String>(
                                          _model.radiologyReport,
                                          'https://images.unsplash.com/photo-1616012480717-fd9867059ca0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx4JTIwcmF5fcGVufDB8fHx8MTc1NDI4MjYzNnww&ixlib=rb-4.1.0&q=80&w=1080',
                                        ),
                                        width: double.infinity,
                                        height: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 400.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 400.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 600.0;
                                          } else {
                                            return 600.0;
                                          }
                                        }(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 60.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 60.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 100.0;
                                    } else {
                                      return 100.0;
                                    }
                                  }(),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.radiologyReport =
                                              'https://images.unsplash.com/photo-1616012480717-fd9867059ca0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx4JTIwcmF5fcGVufDB8fHx8MTc1NDI4MjYzNnww&ixlib=rb-4.1.0&q=80&w=1080';
                                          safeSetState(() {});
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          child: Image.network(
                                            'https://images.unsplash.com/photo-1616012480717-fd9867059ca0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx4JTIwcmF5fcGVufDB8fHx8MTc1NDI4MjYzNnww&ixlib=rb-4.1.0&q=80&w=1080',
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 100.0;
                                              } else {
                                                return 100.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 100.0;
                                              } else {
                                                return 100.0;
                                              }
                                            }(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.radiologyReport =
                                              'https://images.unsplash.com/photo-1516069677018-378515003435?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx4cmF5fGVufDB8fHx8MTc1NDI3NDMzNHww&ixlib=rb-4.1.0&q=80&w=1080';
                                          safeSetState(() {});
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          child: Image.network(
                                            'https://images.unsplash.com/photo-1516069677018-378515003435?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHx4cmF5fGVufDB8fHx8MTc1NDI3NDMzNHww&ixlib=rb-4.1.0&q=80&w=1080',
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 100.0;
                                              } else {
                                                return 100.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 100.0;
                                              } else {
                                                return 100.0;
                                              }
                                            }(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          _model.radiologyReport =
                                              'https://images.unsplash.com/photo-1564725075388-cc8338732289?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyfHx4cmF5fGVufDB8fHx8MTc1NDI3NDMzNHww&ixlib=rb-4.1.0&q=80&w=1080';
                                          safeSetState(() {});
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(24.0),
                                          child: Image.network(
                                            'https://images.unsplash.com/photo-1564725075388-cc8338732289?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyfHx4cmF5fGVufDB8fHx8MTc1NDI3NDMzNHww&ixlib=rb-4.1.0&q=80&w=1080',
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 100.0;
                                              } else {
                                                return 100.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 60.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 100.0;
                                              } else {
                                                return 100.0;
                                              }
                                            }(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 12.0)),
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
                            padding: EdgeInsets.all(valueOrDefault<double>(
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
                            )),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                FlutterFlowTheme.of(context)
                                                    .customColor5,
                                                FlutterFlowTheme.of(context)
                                                    .customColor6
                                              ],
                                              stops: [0.0, 1.0],
                                              begin: AlignmentDirectional(
                                                  0.0, -1.0),
                                              end: AlignmentDirectional(0, 1.0),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: FaIcon(
                                              FontAwesomeIcons.userMd,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              size: 10.0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'ผู้บันทึก',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmallFamily,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .labelSmallIsCustom,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                    Text(
                                      'นายแพทย์ทดลอง ทดสอบ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                                Divider(
                                  height: 1.0,
                                  thickness: 1.0,
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                FlutterFlowTheme.of(context)
                                                    .customColor9,
                                                FlutterFlowTheme.of(context)
                                                    .customColor10
                                              ],
                                              stops: [0.0, 1.0],
                                              begin: AlignmentDirectional(
                                                  0.0, -1.0),
                                              end: AlignmentDirectional(0, 1.0),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: FaIcon(
                                              FontAwesomeIcons.fileAlt,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              size: 8.0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'รายงานผล',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmallFamily,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .labelSmallIsCustom,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                    Text(
                                      'ปกติ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ].divide(SizedBox(height: 12.0)),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
