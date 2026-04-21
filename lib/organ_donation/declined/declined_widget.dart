import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'declined_model.dart';
export 'declined_model.dart';

class DeclinedWidget extends StatefulWidget {
  const DeclinedWidget({super.key});

  @override
  State<DeclinedWidget> createState() => _DeclinedWidgetState();
}

class _DeclinedWidgetState extends State<DeclinedWidget> {
  late DeclinedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeclinedModel());

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
          colors: [Color(0x25E15D69), Color(0x28BE1E2D)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 2.0,
            sigmaY: 2.0,
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
                      colors: [
                        FlutterFlowTheme.of(context).customColor19,
                        FlutterFlowTheme.of(context).customColor20
                      ],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  'ไม่ได้รับการยินยอม',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).customColor20,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ].divide(SizedBox(width: 4.0)),
            ),
          ),
        ),
      ),
    );
  }
}
