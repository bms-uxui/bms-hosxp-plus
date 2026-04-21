import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_i_p_d_averagesleepdays_model.dart';
export 'button_i_p_d_averagesleepdays_model.dart';

class ButtonIPDAveragesleepdaysWidget extends StatefulWidget {
  const ButtonIPDAveragesleepdaysWidget({super.key});

  @override
  State<ButtonIPDAveragesleepdaysWidget> createState() =>
      _ButtonIPDAveragesleepdaysWidgetState();
}

class _ButtonIPDAveragesleepdaysWidgetState
    extends State<ButtonIPDAveragesleepdaysWidget> {
  late ButtonIPDAveragesleepdaysModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonIPDAveragesleepdaysModel());

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
                    FFAppState().homeipdmenu == 5
                        ? FlutterFlowTheme.of(context).accent1
                        : FlutterFlowTheme.of(context).customColor1,
                    Color(0xFF245EBD),
                  ),
                  valueOrDefault<Color>(
                    FFAppState().homeipdmenu == 5
                        ? FlutterFlowTheme.of(context).accent2
                        : FlutterFlowTheme.of(context).customColor2,
                    Color(0xFF3E83E6),
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
                  alignment: AlignmentDirectional(1.0, 1.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 8.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_30_.._2568_13_19_14.png',
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
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
                      'วันนอนเฉลี่ย',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: valueOrDefault<Color>(
                              FFAppState().homeipdmenu == 5
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
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'จำนวน',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).labelSmallFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).labelSmallIsCustom,
                        ),
                  ),
                  RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '65',
                          style: FlutterFlowTheme.of(context)
                              .titleLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleLargeFamily,
                                color: valueOrDefault<Color>(
                                  FFAppState().homeipdmenu == 5
                                      ? FlutterFlowTheme.of(context)
                                          .customColor3
                                      : FlutterFlowTheme.of(context).primary,
                                  Color(0xFF154194),
                                ),
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleLargeIsCustom,
                              ),
                        ),
                        TextSpan(
                          text: '  วัน',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .labelSmallFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .labelSmallIsCustom,
                              ),
                        )
                      ],
                      style:
                          FlutterFlowTheme.of(context).headlineLarge.override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .headlineLargeFamily,
                                color: Color(0xFF2A5490),
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .headlineLargeIsCustom,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
