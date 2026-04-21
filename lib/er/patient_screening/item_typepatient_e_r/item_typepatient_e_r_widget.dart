import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_typepatient_e_r_model.dart';
export 'item_typepatient_e_r_model.dart';

class ItemTypepatientERWidget extends StatefulWidget {
  const ItemTypepatientERWidget({
    super.key,
    this.text,
    this.typepatientER,
  });

  final String? text;
  final int? typepatientER;

  @override
  State<ItemTypepatientERWidget> createState() =>
      _ItemTypepatientERWidgetState();
}

class _ItemTypepatientERWidgetState extends State<ItemTypepatientERWidget> {
  late ItemTypepatientERModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemTypepatientERModel());

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
            FFAppState().ItemTypepatientER == widget!.typepatientER
                ? FlutterFlowTheme.of(context).accent2
                : FlutterFlowTheme.of(context).primaryBackground,
            FFAppState().ItemTypepatientER == widget!.typepatientER
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
          children: [
            Container(
              width: 14.0,
              height: 14.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              valueOrDefault<String>(
                widget!.text,
                'text',
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color:
                        FFAppState().ItemTypepatientER == widget!.typepatientER
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
