import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_med_model.dart';
export 'item_med_model.dart';

class ItemMedWidget extends StatefulWidget {
  const ItemMedWidget({
    super.key,
    this.num,
    this.date,
    this.time,
    this.remedvalue,
  });

  final String? num;
  final String? date;
  final String? time;
  final int? remedvalue;

  @override
  State<ItemMedWidget> createState() => _ItemMedWidgetState();
}

class _ItemMedWidgetState extends State<ItemMedWidget> {
  late ItemMedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemMedModel());

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
            FFAppState().remeditem == widget!.remedvalue
                ? Color(0xFF62B3FF)
                : Color(0x1A62B3FF),
            FFAppState().remeditem == widget!.remedvalue
                ? Color(0xFF2397FF)
                : Color(0x1A2397FF)
          ],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.56, -1.0),
          end: AlignmentDirectional(-0.56, 1.0),
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valueOrDefault<String>(
                widget!.num,
                'ลำดับที่ 1',
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                    color: valueOrDefault<Color>(
                      FFAppState().remeditem == widget!.remedvalue
                          ? FlutterFlowTheme.of(context).secondaryBackground
                          : FlutterFlowTheme.of(context).primary,
                      FlutterFlowTheme.of(context).primary,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                  ),
            ),
            Container(
              decoration: BoxDecoration(
                color: FFAppState().remeditem == widget!.remedvalue
                    ? Color(0x19FFFFFF)
                    : Color(0x7FFFFFFF),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                child: RichText(
                  textScaler: MediaQuery.of(context).textScaler,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: valueOrDefault<String>(
                          widget!.date,
                          '00 M.M. YYYY',
                        ),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: valueOrDefault<Color>(
                                FFAppState().remeditem == widget!.remedvalue
                                    ? FlutterFlowTheme.of(context)
                                        .secondaryBackground
                                    : FlutterFlowTheme.of(context).primary,
                                FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                      TextSpan(
                        text: ' - ',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: valueOrDefault<Color>(
                                FFAppState().remeditem == widget!.remedvalue
                                    ? FlutterFlowTheme.of(context)
                                        .secondaryBackground
                                    : FlutterFlowTheme.of(context).primary,
                                FlutterFlowTheme.of(context).primary,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                      TextSpan(
                        text: valueOrDefault<String>(
                          widget!.time,
                          '00:00',
                        ),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: valueOrDefault<Color>(
                                FFAppState().remeditem == widget!.remedvalue
                                    ? FlutterFlowTheme.of(context)
                                        .secondaryBackground
                                    : FlutterFlowTheme.of(context).primary,
                                FlutterFlowTheme.of(context).primary,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                      TextSpan(
                        text: ' น.',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: valueOrDefault<Color>(
                                FFAppState().remeditem == widget!.remedvalue
                                    ? FlutterFlowTheme.of(context)
                                        .secondaryBackground
                                    : FlutterFlowTheme.of(context).primary,
                                FlutterFlowTheme.of(context).primary,
                              ),
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
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
              ),
            ),
          ].divide(SizedBox(height: 8.0)),
        ),
      ),
    );
  }
}
