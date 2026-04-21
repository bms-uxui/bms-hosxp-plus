import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'heart_model.dart';
export 'heart_model.dart';

class HeartWidget extends StatefulWidget {
  const HeartWidget({
    super.key,
    this.text,
    this.heart,
  });

  final String? text;
  final int? heart;

  @override
  State<HeartWidget> createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<HeartWidget> {
  late HeartModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HeartModel());

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FFAppState().HEENT == widget!.heart
                ? FlutterFlowTheme.of(context).accent2
                : FlutterFlowTheme.of(context).primaryBackground,
            FFAppState().Heart == widget!.heart
                ? FlutterFlowTheme.of(context).accent1
                : FlutterFlowTheme.of(context).primaryBackground
          ],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.56, -1.0),
          end: AlignmentDirectional(-0.56, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              valueOrDefault<String>(
                widget!.text,
                'text',
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: FFAppState().Heart == widget!.heart
                        ? FlutterFlowTheme.of(context).secondaryBackground
                        : FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
          ].divide(SizedBox(width: 8.0)),
        ),
      ),
    );
  }
}
