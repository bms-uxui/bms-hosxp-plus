import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_e_m_r_i_p_d_model.dart';
export 'item_e_m_r_i_p_d_model.dart';

class ItemEMRIPDWidget extends StatefulWidget {
  const ItemEMRIPDWidget({
    super.key,
    this.date,
    this.department,
    this.time,
    this.emrvisit,
  });

  final String? date;
  final String? department;
  final String? time;
  final int? emrvisit;

  @override
  State<ItemEMRIPDWidget> createState() => _ItemEMRIPDWidgetState();
}

class _ItemEMRIPDWidgetState extends State<ItemEMRIPDWidget> {
  late ItemEMRIPDModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemEMRIPDModel());

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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FFAppState().EMRVisit == widget!.emrvisit
                ? Color(0xFFD02E7F)
                : Color(0x1AD02E7F),
            FFAppState().EMRVisit == widget!.emrvisit
                ? Color(0xFFD02E7F)
                : Color(0x19D02E7F)
          ],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.56, -1.0),
          end: AlignmentDirectional(-0.56, 1.0),
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Align(
              alignment: AlignmentDirectional(1.0, 1.0),
              child: Transform.rotate(
                angle: 322.0 * (math.pi / 180),
                child: Opacity(
                  opacity: 0.06,
                  child: Text(
                    'IPD',
                    style: FlutterFlowTheme.of(context).displaySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).displaySmallFamily,
                          color: FFAppState().EMRVisit == widget!.emrvisit
                              ? FlutterFlowTheme.of(context).secondaryBackground
                              : Color(0xFFFFC7E0),
                          letterSpacing: 0.0,
                          useGoogleFonts: !FlutterFlowTheme.of(context)
                              .displaySmallIsCustom,
                        ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textScaler: MediaQuery.of(context).textScaler,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: valueOrDefault<String>(
                          widget!.date,
                          '12 มิ.ย.',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FFAppState().EMRVisit == widget!.emrvisit
                                  ? FlutterFlowTheme.of(context)
                                      .secondaryBackground
                                  : Color(0xFFD02E7F),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                      TextSpan(
                        text: ' - ',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FFAppState().EMRVisit == widget!.emrvisit
                                  ? FlutterFlowTheme.of(context)
                                      .secondaryBackground
                                  : Color(0xFFD02E7F),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                      TextSpan(
                        text: valueOrDefault<String>(
                          widget!.time,
                          '00:00',
                        ),
                        style: TextStyle(
                          color: FFAppState().EMRVisit == widget!.emrvisit
                              ? FlutterFlowTheme.of(context).secondaryBackground
                              : Color(0xFFD02E7F),
                        ),
                      ),
                      TextSpan(
                        text: ' น.',
                        style: TextStyle(
                          color: FFAppState().EMRVisit == widget!.emrvisit
                              ? FlutterFlowTheme.of(context).secondaryBackground
                              : Color(0xFFD02E7F),
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: Color(0xFFD02E7F),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                  maxLines: 1,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: FFAppState().EMRVisit == widget!.emrvisit
                        ? Color(0x19FFFFFF)
                        : Color(0x7FFFFFFF),
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                    child: Text(
                      valueOrDefault<String>(
                        widget!.department,
                        'Department',
                      ),
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodySmallFamily,
                            color: FFAppState().EMRVisit == widget!.emrvisit
                                ? FlutterFlowTheme.of(context)
                                    .secondaryBackground
                                : Color(0xFFD02E7F),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodySmallIsCustom,
                          ),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
          ],
        ),
      ),
    );
  }
}
