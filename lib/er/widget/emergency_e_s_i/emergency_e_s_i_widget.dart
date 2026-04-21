import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'emergency_e_s_i_model.dart';
export 'emergency_e_s_i_model.dart';

class EmergencyESIWidget extends StatefulWidget {
  const EmergencyESIWidget({super.key});

  @override
  State<EmergencyESIWidget> createState() => _EmergencyESIWidgetState();
}

class _EmergencyESIWidgetState extends State<EmergencyESIWidget> {
  late EmergencyESIModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmergencyESIModel());

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
          colors: [Color(0x25BD6EF2), Color(0x25AF1EBE)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(6.0, 2.0, 12.0, 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFBD6EF2), Color(0xFFAF1EBE)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                ),
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Emergency',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                    color: Color(0xFFAF1EBE),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodySmallIsCustom,
                  ),
            ),
          ].divide(SizedBox(width: 4.0)),
        ),
      ),
    );
  }
}
