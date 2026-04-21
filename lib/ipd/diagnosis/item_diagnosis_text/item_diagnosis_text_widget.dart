import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_diagnosis_text_model.dart';
export 'item_diagnosis_text_model.dart';

class ItemDiagnosisTextWidget extends StatefulWidget {
  const ItemDiagnosisTextWidget({
    super.key,
    this.typediag,
    this.condition,
    this.name,
    this.finalcolor2,
    this.finalcolor1,
    this.finaliconcolor,
    this.auditcolor2,
    this.auditcolor1,
    this.auditiconcolor,
  });

  final String? typediag;
  final String? condition;
  final String? name;
  final Color? finalcolor2;
  final Color? finalcolor1;
  final Color? finaliconcolor;
  final Color? auditcolor2;
  final Color? auditcolor1;
  final Color? auditiconcolor;

  @override
  State<ItemDiagnosisTextWidget> createState() =>
      _ItemDiagnosisTextWidgetState();
}

class _ItemDiagnosisTextWidgetState extends State<ItemDiagnosisTextWidget> {
  late ItemDiagnosisTextModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemDiagnosisTextModel());

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
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(valueOrDefault<double>(
              () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                  return 12.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointMedium) {
                  return 12.0;
                } else if (MediaQuery.sizeOf(context).width <
                    kBreakpointLarge) {
                  return 16.0;
                } else {
                  return 16.0;
                }
              }(),
              0.0,
            )),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  valueOrDefault<String>(
                    widget!.typediag,
                    'Type Diag',
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodyMediumFamily,
                        color: Color(0xFFD667FF),
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
                      child: DateandTimeRecordeWidget(),
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
              ].divide(SizedBox(width: 16.0)),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0x08D667FF),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(valueOrDefault<double>(
                () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 12.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 12.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 16.0;
                  } else {
                    return 16.0;
                  }
                }(),
                0.0,
              )),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          textScaler: MediaQuery.of(context).textScaler,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'อาการ : ',
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .labelMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .labelMediumIsCustom,
                                    ),
                              ),
                              TextSpan(
                                text: valueOrDefault<String>(
                                  widget!.condition,
                                  'Condition',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              )
                            ],
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyMediumFamily,
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        valueOrDefault<Color>(
                                          widget!.finalcolor1,
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                        ),
                                        valueOrDefault<Color>(
                                          widget!.finalcolor2,
                                          Color(0xFFADADAD),
                                        )
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: valueOrDefault<Color>(
                                        widget!.finaliconcolor,
                                        FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      size: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'Final',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodySmallIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 4.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        valueOrDefault<Color>(
                                          widget!.auditcolor1,
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                        ),
                                        valueOrDefault<Color>(
                                          widget!.auditcolor2,
                                          Color(0xFFADADAD),
                                        )
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(0.0, -1.0),
                                      end: AlignmentDirectional(0, 1.0),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: valueOrDefault<Color>(
                                        widget!.auditiconcolor,
                                        FlutterFlowTheme.of(context)
                                            .secondaryText,
                                      ),
                                      size: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'Audit',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodySmallFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodySmallIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 4.0)),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ],
                  ),
                  StyledDivider(
                    height: 1.0,
                    thickness: 1.0,
                    color: FlutterFlowTheme.of(context).alternate,
                    lineStyle: DividerLineStyle.dashed,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
                      child: RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'ผู้วินิจฉัย : ',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelSmallFamily,
                                    letterSpacing: 0.0,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .labelSmallIsCustom,
                                  ),
                            ),
                            TextSpan(
                              text: valueOrDefault<String>(
                                widget!.name,
                                'Full Name',
                              ),
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .bodySmallFamily,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    useGoogleFonts:
                                        !FlutterFlowTheme.of(context)
                                            .bodySmallIsCustom,
                                  ),
                            )
                          ],
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
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
        ],
      ),
    );
  }
}
