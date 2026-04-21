import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'botton_secondary_model.dart';
export 'botton_secondary_model.dart';

class BottonSecondaryWidget extends StatefulWidget {
  const BottonSecondaryWidget({
    super.key,
    this.buttonsecondary,
    this.icon,
  });

  /// buttonsecondary
  final String? buttonsecondary;

  final Widget? icon;

  @override
  State<BottonSecondaryWidget> createState() => _BottonSecondaryWidgetState();
}

class _BottonSecondaryWidgetState extends State<BottonSecondaryWidget> {
  late BottonSecondaryModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottonSecondaryModel());

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
        gradient: LinearGradient(
          colors: [
            FlutterFlowTheme.of(context).accent2,
            FlutterFlowTheme.of(context).accent1
          ],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget!.icon!,
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Text(
                valueOrDefault<String>(
                  widget!.buttonsecondary,
                  'Button Secondary',
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ].divide(SizedBox(width: 8.0)),
        ),
      ),
    );
  }
}
