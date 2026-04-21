import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/drugand_service/tag_number_pills/tag_number_pills_widget.dart';
import '/er/drugand_service/tag_price/tag_price_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_drug_e_rremet_model.dart';
export 'item_drug_e_rremet_model.dart';

class ItemDrugERremetWidget extends StatefulWidget {
  const ItemDrugERremetWidget({
    super.key,
    this.num,
    this.drug,
    this.quantity,
    this.unit,
    this.howusemedicine,
    this.pharmacist,
    this.orderdate,
    this.discontinuancedate,
    this.price,
    this.time,
  });

  final String? num;
  final String? drug;
  final String? quantity;
  final String? unit;
  final String? howusemedicine;
  final String? pharmacist;
  final String? orderdate;
  final String? discontinuancedate;
  final String? price;
  final String? time;

  @override
  State<ItemDrugERremetWidget> createState() => _ItemDrugERremetWidgetState();
}

class _ItemDrugERremetWidgetState extends State<ItemDrugERremetWidget> {
  late ItemDrugERremetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemDrugERremetModel());

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
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Theme(
                          data: ThemeData(
                            checkboxTheme: CheckboxThemeData(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            unselectedWidgetColor:
                                FlutterFlowTheme.of(context).secondaryText,
                          ),
                          child: Checkbox(
                            value: _model.checkboxValue ??= false,
                            onChanged: (newValue) async {
                              safeSetState(
                                  () => _model.checkboxValue = newValue!);
                            },
                            side: (FlutterFlowTheme.of(context).secondaryText !=
                                    null)
                                ? BorderSide(
                                    width: 2,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText!,
                                  )
                                : null,
                            activeColor: FlutterFlowTheme.of(context).primary,
                            checkColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                        ),
                        RichText(
                          textScaler: MediaQuery.of(context).textScaler,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: valueOrDefault<String>(
                                  widget!.num,
                                  '0',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .customColor8,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                              TextSpan(
                                text: '. ',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .customColor8,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ),
                              TextSpan(
                                text: valueOrDefault<String>(
                                  widget!.drug,
                                  'Drug',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .customColor8,
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
                          maxLines: 1,
                        ),
                      ],
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
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  direction: Axis.horizontal,
                  runAlignment: WrapAlignment.start,
                  verticalDirection: VerticalDirection.down,
                  clipBehavior: Clip.none,
                  children: [
                    wrapWithModel(
                      model: _model.tagNumberPillsModel,
                      updateCallback: () => safeSetState(() {}),
                      child: TagNumberPillsWidget(
                        quantity: widget!.quantity,
                        unit: widget!.unit,
                      ),
                    ),
                    wrapWithModel(
                      model: _model.tagPriceModel,
                      updateCallback: () => safeSetState(() {}),
                      child: TagPriceWidget(
                        price: widget!.price,
                      ),
                    ),
                  ],
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0x089040FF),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                width: 2.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        valueOrDefault<String>(
                          widget!.howusemedicine,
                          'How to use the medicine',
                        ),
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                      StyledDivider(
                        height: 1.0,
                        thickness: 1.0,
                        color: FlutterFlowTheme.of(context).alternate,
                        lineStyle: DividerLineStyle.dashed,
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        direction: Axis.horizontal,
                        runAlignment: WrapAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 4.0, 12.0, 4.0),
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'ผู้สั่ง : ',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmallFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .labelSmallIsCustom,
                                          ),
                                    ),
                                    TextSpan(
                                      text: valueOrDefault<String>(
                                        widget!.pharmacist,
                                        'Full Name',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
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
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodyMediumIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  12.0, 4.0, 12.0, 4.0),
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'วัน-เวลาที่สั่ง : ',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmallFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .labelSmallIsCustom,
                                          ),
                                    ),
                                    TextSpan(
                                      text: valueOrDefault<String>(
                                        widget!.orderdate,
                                        '00 M.M. YYYY',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                    TextSpan(
                                      text: ' - ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                    TextSpan(
                                      text: valueOrDefault<String>(
                                        widget!.time,
                                        '00:00',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                    ),
                                    TextSpan(
                                      text: ' น.',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            letterSpacing: 0.0,
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
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodyMediumIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
