import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_o_p_d_averagetime_model.dart';
export 'button_o_p_d_averagetime_model.dart';

class ButtonOPDAveragetimeWidget extends StatefulWidget {
  const ButtonOPDAveragetimeWidget({super.key});

  @override
  State<ButtonOPDAveragetimeWidget> createState() =>
      _ButtonOPDAveragetimeWidgetState();
}

class _ButtonOPDAveragetimeWidgetState
    extends State<ButtonOPDAveragetimeWidget> {
  late ButtonOPDAveragetimeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonOPDAveragetimeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return AnimatedContainer(
      duration: Duration(milliseconds: 2000),
      curve: Curves.bounceOut,
      width: double.infinity,
      height: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 100.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 100.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 120.0;
        } else {
          return 120.0;
        }
      }(),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: double.infinity,
            height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 48.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 48.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 56.0;
              } else {
                return 56.0;
              }
            }(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  valueOrDefault<Color>(
                    FFAppState().homeopdmenu == 2
                        ? FlutterFlowTheme.of(context).accent1
                        : FlutterFlowTheme.of(context).customColor1,
                    Color(0x4D2397FF),
                  ),
                  valueOrDefault<Color>(
                    FFAppState().homeopdmenu == 2
                        ? FlutterFlowTheme.of(context).accent2
                        : FlutterFlowTheme.of(context).customColor2,
                    Color(0x323E83E6),
                  )
                ],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.56, -1.0),
                end: AlignmentDirectional(-0.56, 1.0),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              border: Border.all(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                width: 0.5,
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
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
                        0.0,
                        0.0),
                    child: Text(
                      'เวลารับบริการ',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: valueOrDefault<Color>(
                              FFAppState().homeopdmenu == 2
                                  ? FlutterFlowTheme.of(context)
                                      .secondaryBackground
                                  : FlutterFlowTheme.of(context).primary,
                              FlutterFlowTheme.of(context).secondaryBackground,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(1.0, 1.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 8.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_27_.._2568_16_20_42.png',
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Walk In',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .labelSmallFamily,
                                fontSize: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 12.0;
                                  } else {
                                    return 12.0;
                                  }
                                }(),
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .labelSmallIsCustom,
                              ),
                        ),
                        RichText(
                          textScaler: MediaQuery.of(context).textScaler,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '30',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleMediumFamily,
                                      color: FFAppState().homeopdmenu == 2
                                          ? FlutterFlowTheme.of(context)
                                              .customColor3
                                          : FlutterFlowTheme.of(context)
                                              .primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      lineHeight: 1.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleMediumIsCustom,
                                    ),
                              ),
                              TextSpan(
                                text: '  นาที',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .labelSmallFamily,
                                      fontSize: () {
                                        if (MediaQuery.sizeOf(context).width <
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
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .labelSmallIsCustom,
                                    ),
                              )
                            ],
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  color: Color(0xFF2A5490),
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ),
                      ].divide(SizedBox(height: 6.0)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                    child: Container(
                      width: 1.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'มาตามนัด',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .labelSmallFamily,
                                fontSize: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 12.0;
                                  } else {
                                    return 12.0;
                                  }
                                }(),
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .labelSmallIsCustom,
                              ),
                        ),
                        RichText(
                          textScaler: MediaQuery.of(context).textScaler,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '25.3',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleMediumFamily,
                                      color: FFAppState().homeopdmenu == 2
                                          ? FlutterFlowTheme.of(context)
                                              .customColor3
                                          : FlutterFlowTheme.of(context)
                                              .primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      lineHeight: 1.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleMediumIsCustom,
                                    ),
                              ),
                              TextSpan(
                                text: '  นาที',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .labelSmallFamily,
                                      fontSize: () {
                                        if (MediaQuery.sizeOf(context).width <
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
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .labelSmallIsCustom,
                                    ),
                              )
                            ],
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  color: Color(0xFF2A5490),
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ),
                      ].divide(SizedBox(height: 6.0)),
                    ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
