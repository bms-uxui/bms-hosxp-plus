import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'urgency_l2_model.dart';
export 'urgency_l2_model.dart';

class UrgencyL2Widget extends StatefulWidget {
  const UrgencyL2Widget({super.key});

  @override
  State<UrgencyL2Widget> createState() => _UrgencyL2WidgetState();
}

class _UrgencyL2WidgetState extends State<UrgencyL2Widget> {
  late UrgencyL2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UrgencyL2Model());

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
          colors: [Color(0xFFBD6EF2), Color(0xFFAF1EBE)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 2.0, 12.0, 2.0),
        child: Text(
          'Level  2',
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
