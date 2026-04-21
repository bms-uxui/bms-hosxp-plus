import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'urgent_e_s_i_model.dart';
export 'urgent_e_s_i_model.dart';

class UrgentESIWidget extends StatefulWidget {
  const UrgentESIWidget({super.key});

  @override
  State<UrgentESIWidget> createState() => _UrgentESIWidgetState();
}

class _UrgentESIWidgetState extends State<UrgentESIWidget> {
  late UrgentESIModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UrgentESIModel());

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
          colors: [Color(0x25FFB960), Color(0x25DC8610)],
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
                  colors: [Color(0xFFFFB960), Color(0xFFDC8610)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                ),
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Urgent',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                    color: Color(0xFFDC8610),
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
