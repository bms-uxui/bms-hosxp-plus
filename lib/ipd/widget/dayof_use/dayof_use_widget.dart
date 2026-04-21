import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dayof_use_model.dart';
export 'dayof_use_model.dart';

class DayofUseWidget extends StatefulWidget {
  const DayofUseWidget({
    super.key,
    this.numday,
  });

  final String? numday;

  @override
  State<DayofUseWidget> createState() => _DayofUseWidgetState();
}

class _DayofUseWidgetState extends State<DayofUseWidget> {
  late DayofUseModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DayofUseModel());

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
          colors: [
            FlutterFlowTheme.of(context).accent2,
            FlutterFlowTheme.of(context).accent1
          ],
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF2B66C7),
                  size: 12.0,
                ),
              ),
            ),
            RichText(
              textScaler: MediaQuery.of(context).textScaler,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'จำนวนวันที่ใช้  ',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                  TextSpan(
                    text: valueOrDefault<String>(
                      widget!.numday,
                      '0',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                  TextSpan(
                    text: ' วัน',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  )
                ],
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                    ),
              ),
            ),
          ].divide(SizedBox(width: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 4.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 8.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 8.0;
            } else {
              return 8.0;
            }
          }())),
        ),
      ),
    );
  }
}
