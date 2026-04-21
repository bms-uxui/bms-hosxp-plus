import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_co_operator_model.dart';
export 'item_co_operator_model.dart';

class ItemCoOperatorWidget extends StatefulWidget {
  const ItemCoOperatorWidget({
    super.key,
    this.nameCooperator,
    this.detail,
    this.number,
    this.hidedelet,
  });

  final String? nameCooperator;
  final String? detail;
  final int? number;
  final bool? hidedelet;

  @override
  State<ItemCoOperatorWidget> createState() => _ItemCoOperatorWidgetState();
}

class _ItemCoOperatorWidgetState extends State<ItemCoOperatorWidget> {
  late ItemCoOperatorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemCoOperatorModel());

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
        gradient: LinearGradient(
          colors: [Color(0x0D5FD187), Color(0x0E3AAA5F)],
          stops: [0.0, 1.0],
          begin: AlignmentDirectional(0.56, -1.0),
          end: AlignmentDirectional(-0.56, 1.0),
        ),
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
                RichText(
                  textScaler: MediaQuery.of(context).textScaler,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: valueOrDefault<String>(
                          widget!.number?.toString(),
                          '0',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FlutterFlowTheme.of(context).customColor6,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                      TextSpan(
                        text: '. ',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: Color(0xFF006838),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                      TextSpan(
                        text: valueOrDefault<String>(
                          widget!.nameCooperator,
                          'Name Co-operator',
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      )
                    ],
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyMediumFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                        ),
                  ),
                ),
                if (widget!.hidedelet ?? true)
                  wrapWithModel(
                    model: _model.iconButtonTertiaryModel,
                    updateCallback: () => safeSetState(() {}),
                    child: IconButtonTertiaryWidget(
                      iconbuttontertiary: Icon(
                        Icons.close_rounded,
                        color: FlutterFlowTheme.of(context).error,
                        size: 14.0,
                      ),
                      color: Color(0xB3FFFFFF),
                    ),
                  ),
              ].divide(SizedBox(width: 8.0)),
            ),
            RichText(
              textScaler: MediaQuery.of(context).textScaler,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'หมายเหตุ : ',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).labelSmallFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).labelSmallIsCustom,
                        ),
                  ),
                  TextSpan(
                    text: valueOrDefault<String>(
                      widget!.detail,
                      'Detail',
                    ),
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodySmallFamily,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodySmallIsCustom,
                        ),
                  )
                ],
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).labelSmallIsCustom,
                    ),
              ),
            ),
          ].divide(SizedBox(height: 8.0)),
        ),
      ),
    );
  }
}
