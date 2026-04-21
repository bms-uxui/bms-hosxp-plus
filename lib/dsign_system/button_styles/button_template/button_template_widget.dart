import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'button_template_model.dart';
export 'button_template_model.dart';

class ButtonTemplateWidget extends StatefulWidget {
  const ButtonTemplateWidget({
    super.key,
    this.text,
    this.icon,
  });

  final String? text;
  final Widget? icon;

  @override
  State<ButtonTemplateWidget> createState() => _ButtonTemplateWidgetState();
}

class _ButtonTemplateWidgetState extends State<ButtonTemplateWidget> {
  late ButtonTemplateModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonTemplateModel());

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
          phone: false,
        ))
          Container(
            height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 40.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 40.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 48.0;
              } else {
                return 48.0;
              }
            }(),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(100.0),
              shape: BoxShape.rectangle,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget!.icon!,
                  Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Text(
                      valueOrDefault<String>(
                        widget!.text,
                        'text',
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
            ),
          ),
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
              color: FlutterFlowTheme.of(context).secondaryBackground,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: widget!.icon!,
            ),
          ),
      ],
    );
  }
}
