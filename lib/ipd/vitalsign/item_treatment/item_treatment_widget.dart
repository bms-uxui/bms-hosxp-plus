import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_treatment_model.dart';
export 'item_treatment_model.dart';

class ItemTreatmentWidget extends StatefulWidget {
  const ItemTreatmentWidget({
    super.key,
    this.treatment,
    this.name,
    this.day,
    this.month,
    this.year,
    this.time,
    Color? color,
  }) : this.color = color ?? const Color(0xFF465054);

  final String? treatment;
  final String? name;
  final String? day;
  final String? month;
  final String? year;
  final String? time;
  final Color color;

  @override
  State<ItemTreatmentWidget> createState() => _ItemTreatmentWidgetState();
}

class _ItemTreatmentWidgetState extends State<ItemTreatmentWidget> {
  late ItemTreatmentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemTreatmentModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          valueOrDefault<double>(
            () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 16.0;
              } else {
                return 16.0;
              }
            }(),
            0.0,
          ),
          0.0,
          valueOrDefault<double>(
            () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 16.0;
              } else {
                return 16.0;
              }
            }(),
            0.0,
          ),
          0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(valueOrDefault<double>(
            () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 12.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 16.0;
              } else {
                return 16.0;
              }
            }(),
            0.0,
          )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    valueOrDefault<String>(
                      widget!.treatment,
                      'Treatment',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      wrapWithModel(
                        model: _model.dateandTimeRecordeModel,
                        updateCallback: () => safeSetState(() {}),
                        child: DateandTimeRecordeWidget(
                          day: widget!.day,
                          month: widget!.month,
                          year: widget!.year,
                          time: widget!.time,
                          color: widget!.color,
                        ),
                      ),
                      wrapWithModel(
                        model: _model.iconButtonTertiaryModel,
                        updateCallback: () => safeSetState(() {}),
                        child: IconButtonTertiaryWidget(
                          iconbuttontertiary: Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 14.0,
                          ),
                          color: FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                  child: RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ผู้ทำหัตถการ : ',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .labelSmallFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .labelSmallIsCustom,
                              ),
                        ),
                        TextSpan(
                          text: valueOrDefault<String>(
                            widget!.name,
                            'Name',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodySmallIsCustom,
                              ),
                        )
                      ],
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            letterSpacing: 0.0,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ),
                ),
              ),
            ].divide(SizedBox(height: 8.0)),
          ),
        ),
      ),
    );
  }
}
