import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'forget_p_i_n_model.dart';
export 'forget_p_i_n_model.dart';

class ForgetPINWidget extends StatefulWidget {
  const ForgetPINWidget({super.key});

  @override
  State<ForgetPINWidget> createState() => _ForgetPINWidgetState();
}

class _ForgetPINWidgetState extends State<ForgetPINWidget> {
  late ForgetPINModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ForgetPINModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          'ลืม PIN',
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .titleMediumFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .titleMediumIsCustom,
                              ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            Navigator.pop(context);
                          },
                          child: wrapWithModel(
                            model: _model.iconButtonTertiaryModel,
                            updateCallback: () => safeSetState(() {}),
                            child: IconButtonTertiaryWidget(
                              iconbuttontertiary: Icon(
                                Icons.close_rounded,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 16.0,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
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
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: () {
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
                        }()),
                        scrollDirection: Axis.vertical,
                        children: <Widget>[].divide(SizedBox(height: () {
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
