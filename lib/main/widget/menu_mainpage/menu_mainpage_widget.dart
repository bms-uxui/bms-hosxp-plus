import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'menu_mainpage_model.dart';
export 'menu_mainpage_model.dart';

class MenuMainpageWidget extends StatefulWidget {
  const MenuMainpageWidget({super.key});

  @override
  State<MenuMainpageWidget> createState() => _MenuMainpageWidgetState();
}

class _MenuMainpageWidgetState extends State<MenuMainpageWidget> {
  late MenuMainpageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuMainpageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          valueOrDefault<double>(
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
          ),
          0.0,
          valueOrDefault<double>(
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
          ),
          0.0),
      child: MasonryGridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 4;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 4;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 5;
            } else {
              return 5;
            }
          }(),
        ),
        crossAxisSpacing: () {
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
        mainAxisSpacing: () {
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
            () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(OrganDonationpageWidget.routeName);
                      },
                      child: Container(
                        width: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 64.0;
                          } else {
                            return 64.0;
                          }
                        }(),
                        height: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 64.0;
                          } else {
                            return 64.0;
                          }
                        }(),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x19000000),
                              offset: Offset(
                                0.0,
                                0.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.circular(24.0),
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            width: 0.5,
                          ),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: Image.asset(
                                'assets/images/ChatGPT_Image_21_.._2568_16_08_55.png',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'บริจาคอวัยวะ',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                          ),
                    ),
                  ].divide(SizedBox(height: 12.0)),
                ),
            () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    badges.Badge(
                      badgeContent: Text(
                        '3',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                      showBadge: true,
                      shape: badges.BadgeShape.circle,
                      badgeColor: FlutterFlowTheme.of(context).error,
                      elevation: 4.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                      position: badges.BadgePosition.topEnd(),
                      animationType: badges.BadgeAnimationType.scale,
                      toAnimate: true,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed(ConsultListWidget.routeName);
                        },
                        child: Container(
                          width: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 56.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 56.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 64.0;
                            } else {
                              return 64.0;
                            }
                          }(),
                          height: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 56.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 56.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 64.0;
                            } else {
                              return 64.0;
                            }
                          }(),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4.0,
                                color: Color(0x19000000),
                                offset: Offset(
                                  0.0,
                                  0.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(24.0),
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              width: 0.5,
                            ),
                          ),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.asset(
                                  'assets/images/ChatGPT_Image_16_.._2568_16_10_35.png',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Consoult',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                          ),
                    ),
                  ].divide(SizedBox(height: 12.0)),
                ),
          ][index]();
        },
      ),
    );
  }
}
