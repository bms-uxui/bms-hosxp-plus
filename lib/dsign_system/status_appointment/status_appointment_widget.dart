import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'status_appointment_model.dart';
export 'status_appointment_model.dart';

class StatusAppointmentWidget extends StatefulWidget {
  const StatusAppointmentWidget({super.key});

  @override
  State<StatusAppointmentWidget> createState() =>
      _StatusAppointmentWidgetState();
}

class _StatusAppointmentWidgetState extends State<StatusAppointmentWidget> {
  late StatusAppointmentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StatusAppointmentModel());

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
      constraints: BoxConstraints(
        minWidth: 100.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x34228EEC), Color(0x66228EEC)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.56, -1.0),
          end: AlignmentDirectional(-0.56, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(2.0, 2.0, 12.0, 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'มาตามนัด',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                    color: Color(0xFF007FE7),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodySmallIsCustom,
                  ),
            ),
          ].divide(SizedBox(width: 8.0)),
        ),
      ),
    );
  }
}
