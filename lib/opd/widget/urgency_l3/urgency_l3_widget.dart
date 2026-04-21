import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'urgency_l3_model.dart';
export 'urgency_l3_model.dart';

class UrgencyL3Widget extends StatefulWidget {
  const UrgencyL3Widget({super.key});

  @override
  State<UrgencyL3Widget> createState() => _UrgencyL3WidgetState();
}

class _UrgencyL3WidgetState extends State<UrgencyL3Widget> {
  late UrgencyL3Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UrgencyL3Model());

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB960), Color(0xFFDC8610)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 2.0, 12.0, 2.0),
        child: Text(
          'Level  3',
          style: FlutterFlowTheme.of(context).bodySmall.override(
                fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
              ),
        ),
      ),
    );
  }
}
