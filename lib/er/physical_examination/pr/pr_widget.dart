import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pr_model.dart';
export 'pr_model.dart';

class PrWidget extends StatefulWidget {
  const PrWidget({
    super.key,
    this.text,
    this.pr,
  });

  final String? text;
  final int? pr;

  @override
  State<PrWidget> createState() => _PrWidgetState();
}

class _PrWidgetState extends State<PrWidget> {
  late PrModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrModel());

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
            FFAppState().PR == widget!.pr
                ? FlutterFlowTheme.of(context).accent2
                : FlutterFlowTheme.of(context).primaryBackground,
            FFAppState().PR == widget!.pr
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
                    color: FFAppState().PR == widget!.pr
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
