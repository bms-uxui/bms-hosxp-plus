import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_a_igenerate_model.dart';
export 'button_a_igenerate_model.dart';

class ButtonAIgenerateWidget extends StatefulWidget {
  const ButtonAIgenerateWidget({
    super.key,
    this.aiGenerate,
    this.icon,
  });

  /// AI Generate
  final String? aiGenerate;

  final Widget? icon;

  @override
  State<ButtonAIgenerateWidget> createState() => _ButtonAIgenerateWidgetState();
}

class _ButtonAIgenerateWidgetState extends State<ButtonAIgenerateWidget> {
  late ButtonAIgenerateModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonAIgenerateModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (responsiveVisibility(
          context: context,
          tablet: false,
          tabletLandscape: false,
          desktop: false,
        ))
          Container(
            width: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 32.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 32.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 40.0;
              } else {
                return 40.0;
              }
            }(),
            height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 32.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 32.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 40.0;
              } else {
                return 40.0;
              }
            }(),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Color(0x8AE683FF),
                  offset: Offset(
                    0.0,
                    0.0,
                  ),
                  spreadRadius: 3.0,
                )
              ],
              gradient: LinearGradient(
                colors: [Color(0xFFFFA466), Color(0xFF9E53FF)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.56, -1.0),
                end: AlignmentDirectional(-0.56, 1.0),
              ),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xE6FFFFFF),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: widget!.icon!,
                ),
              ),
            ),
          ),
        if (responsiveVisibility(
          context: context,
          phone: false,
        ))
          Container(
            height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 32.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 32.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 40.0;
              } else {
                return 40.0;
              }
            }(),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: Color(0x8AE683FF),
                  offset: Offset(
                    0.0,
                    0.0,
                  ),
                  spreadRadius: 3.0,
                )
              ],
              gradient: LinearGradient(
                colors: [Color(0xFFFFA466), Color(0xFF9E53FF)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.56, -1.0),
                end: AlignmentDirectional(-0.56, 1.0),
              ),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xE6FFFFFF),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: widget!.icon!,
                      ),
                      Text(
                        valueOrDefault<String>(
                          widget!.aiGenerate,
                          'AI Generate',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: Color(0xFF6E35B6),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
