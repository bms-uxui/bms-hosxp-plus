import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'menu_patient_info_e_r_model.dart';
export 'menu_patient_info_e_r_model.dart';

class MenuPatientInfoERWidget extends StatefulWidget {
  const MenuPatientInfoERWidget({
    super.key,
    this.namemenu,
    this.icon,
    this.tabMenuPatientInfoER,
  });

  final String? namemenu;
  final Widget? icon;
  final int? tabMenuPatientInfoER;

  @override
  State<MenuPatientInfoERWidget> createState() =>
      _MenuPatientInfoERWidgetState();
}

class _MenuPatientInfoERWidgetState extends State<MenuPatientInfoERWidget> {
  late MenuPatientInfoERModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuPatientInfoERModel());

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

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20.0,
            sigmaY: 20.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: FFAppState().TabMenuPatientInfoER ==
                      widget!.tabMenuPatientInfoER
                  ? FlutterFlowTheme.of(context).secondaryBackground
                  : Color(0x32154194),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8.0,
                  color: FFAppState().TabMenuPatientInfoER ==
                          widget!.tabMenuPatientInfoER
                      ? Color(0x3457636C)
                      : Colors.transparent,
                  offset: Offset(
                    0.0,
                    0.0,
                  ),
                  spreadRadius: 0.0,
                )
              ],
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                color: FFAppState().TabMenuPatientInfoER ==
                        widget!.tabMenuPatientInfoER
                    ? FlutterFlowTheme.of(context).secondaryBackground
                    : Color(0x80FFFFFF),
                width: 0.6,
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 16.0, 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                        return 28.0;
                      } else if (MediaQuery.sizeOf(context).width <
                          kBreakpointMedium) {
                        return 28.0;
                      } else if (MediaQuery.sizeOf(context).width <
                          kBreakpointLarge) {
                        return 32.0;
                      } else {
                        return 32.0;
                      }
                    }(),
                    height: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                        return 28.0;
                      } else if (MediaQuery.sizeOf(context).width <
                          kBreakpointMedium) {
                        return 28.0;
                      } else if (MediaQuery.sizeOf(context).width <
                          kBreakpointLarge) {
                        return 32.0;
                      } else {
                        return 32.0;
                      }
                    }(),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FFAppState().TabMenuPatientInfoER ==
                                  widget!.tabMenuPatientInfoER
                              ? Color(0x0E3E83E6)
                              : Color(0x1AFFFFFF),
                          FFAppState().TabMenuPatientInfoER ==
                                  widget!.tabMenuPatientInfoER
                              ? Color(0x27245EBD)
                              : Color(0x1AFFFFFF)
                        ],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0.0, -1.0),
                        end: AlignmentDirectional(0, 1.0),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: widget!.icon!,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                    child: Text(
                      valueOrDefault<String>(
                        widget!.namemenu,
                        'Menu',
                      ),
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FFAppState().TabMenuPatientInfoER ==
                                    widget!.tabMenuPatientInfoER
                                ? FlutterFlowTheme.of(context).accent1
                                : FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                          ),
                    ),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
