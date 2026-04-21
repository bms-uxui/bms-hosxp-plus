import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'waitingfor_screening_model.dart';
export 'waitingfor_screening_model.dart';

class WaitingforScreeningWidget extends StatefulWidget {
  const WaitingforScreeningWidget({super.key});

  @override
  State<WaitingforScreeningWidget> createState() =>
      _WaitingforScreeningWidgetState();
}

class _WaitingforScreeningWidgetState extends State<WaitingforScreeningWidget> {
  late WaitingforScreeningModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WaitingforScreeningModel());

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
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(
                Icons.access_time_filled,
                color: FlutterFlowTheme.of(context).primaryText,
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
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 12.0, 2.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_filled,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 12.0,
                  ),
                  Text(
                    'รอคัดกรอง',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          color: FlutterFlowTheme.of(context).primaryText,
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
