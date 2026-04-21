import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'waitingfordoctor_model.dart';
export 'waitingfordoctor_model.dart';

class WaitingfordoctorWidget extends StatefulWidget {
  const WaitingfordoctorWidget({super.key});

  @override
  State<WaitingfordoctorWidget> createState() => _WaitingfordoctorWidgetState();
}

class _WaitingfordoctorWidgetState extends State<WaitingfordoctorWidget> {
  late WaitingfordoctorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WaitingfordoctorModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (responsiveVisibility(
          context: context,
          tablet: false,
          tabletLandscape: false,
          desktop: false,
        ))
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).customColor17,
                  FlutterFlowTheme.of(context).customColor18
                ],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(
                Icons.access_time_filled,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                size: 10.0,
              ),
            ),
          ),
        if (responsiveVisibility(
          context: context,
          phone: false,
        ))
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).customColor17,
                  FlutterFlowTheme.of(context).customColor18
                ],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 12.0, 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_filled,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    size: 12.0,
                  ),
                  Text(
                    'รอตรวจ',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          fontSize: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 10.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 10.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 14.0;
                            } else {
                              return 14.0;
                            }
                          }(),
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.normal,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  ),
                ].divide(SizedBox(width: 4.0)),
              ),
            ),
          ),
      ],
    );
  }
}
