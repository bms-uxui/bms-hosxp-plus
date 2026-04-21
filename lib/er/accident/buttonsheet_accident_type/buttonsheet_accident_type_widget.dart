import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_primary/item_list_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'buttonsheet_accident_type_model.dart';
export 'buttonsheet_accident_type_model.dart';

class ButtonsheetAccidentTypeWidget extends StatefulWidget {
  const ButtonsheetAccidentTypeWidget({super.key});

  @override
  State<ButtonsheetAccidentTypeWidget> createState() =>
      _ButtonsheetAccidentTypeWidgetState();
}

class _ButtonsheetAccidentTypeWidgetState
    extends State<ButtonsheetAccidentTypeWidget> {
  late ButtonsheetAccidentTypeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonsheetAccidentTypeModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
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
                  Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'ประเภทอุบัติเหตุ',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: wrapWithModel(
                      model: _model.iconButtonTertiaryModel,
                      updateCallback: () => safeSetState(() {}),
                      child: IconButtonTertiaryWidget(
                        iconbuttontertiary: Icon(
                          Icons.close_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 16.0,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    valueOrDefault<double>(
                      () {
                        if (MediaQuery.sizeOf(context).width <
                            kBreakpointSmall) {
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
                    ),
                    0.0,
                    valueOrDefault<double>(
                      () {
                        if (MediaQuery.sizeOf(context).width <
                            kBreakpointSmall) {
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
                    ),
                    0.0),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
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
                  ),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    Container(
                      width: 100.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(valueOrDefault<double>(
                          () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
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
                          children: [
                            wrapWithModel(
                              model: _model.itemListPrimaryModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'อุบัติเหตุการขนส่ง (V01-V89)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'พลัด ตก หรือหกล้ม (WOO-W19)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel3,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title:
                                    'สัมผัสกับแรงเชิงกลวัตถุสิ่งของ (W20-W49)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel4,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title:
                                    'สัมผัสกับแรงเชิงกลของสัตว์/คน (W50-W64)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel5,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'การตกน้ำ จมน้ำ (W65-W74)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel6,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'คุกคามการหายใจ (W75-W84)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel7,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title:
                                    'สัมผัสกระแสไฟฟ้า รังสีและอุณหภูมิ (W85-W99)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel8,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'สัมผัสควันไฟ และเปลวไฟ (X00-X99)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel9,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'สัมผัสความร้อน ของร้อน (X10-X19)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel10,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'สัมผัสพิษจากสัตว์หรือพืช (X20-X29)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel11,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'สัมผัสพลังงานจากธรรมชาติ (X30-X39)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel12,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'สัมผัสพิษและสารอื่นๆ (X40-X49)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel13,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'การออกแรงเกิน (X50-X57)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel14,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'สัมผัสกับสิ่งไม่ทราบแน่ชัด (X58-X59)',
                                showline: true,
                              ),
                            ),
                            wrapWithModel(
                              model: _model.itemListPrimaryModel15,
                              updateCallback: () => safeSetState(() {}),
                              child: ItemListPrimaryWidget(
                                title: 'ไม่ทราบทั้งสาเหตุและเจตนา (Y34)',
                                showline: false,
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                    ),
                  ].divide(SizedBox(height: () {
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
                  }())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
