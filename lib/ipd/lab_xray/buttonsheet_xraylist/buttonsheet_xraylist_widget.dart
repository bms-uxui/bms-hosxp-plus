import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_primary/item_list_primary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'buttonsheet_xraylist_model.dart';
export 'buttonsheet_xraylist_model.dart';

class ButtonsheetXraylistWidget extends StatefulWidget {
  const ButtonsheetXraylistWidget({super.key});

  @override
  State<ButtonsheetXraylistWidget> createState() =>
      _ButtonsheetXraylistWidgetState();
}

class _ButtonsheetXraylistWidgetState extends State<ButtonsheetXraylistWidget> {
  late ButtonsheetXraylistModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonsheetXraylistModel());

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
      height: MediaQuery.sizeOf(context).height * 1.0,
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
                  'รายการที่สั่ง',
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
                  ),
                  0.0,
                  valueOrDefault<double>(
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
                  ),
                  0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.searchBarSecondaryModel,
                    updateCallback: () => safeSetState(() {}),
                    child: SearchBarSecondaryWidget(),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        0,
                        0,
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
                      ),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [
                        Container(
                          width: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
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
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    Navigator.pop(context);
                                  },
                                  child: wrapWithModel(
                                    model: _model.itemListPrimaryModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ItemListPrimaryWidget(
                                      title: 'CT Oropharynx.',
                                      showline: true,
                                    ),
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CT Spine 1 part',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CT Parotid gland',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CT Multiphase 1 part',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel5,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CT Extremity / joint',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel6,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CTA Whole aorta',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel7,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CT Lower abdomen',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel8,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CT Upper abdomen',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel9,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CT Brain with CM',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel10,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'Barium enema single contrast',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel11,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'CT IAC / Temporal bone screening',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel12,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'Mammography Digital',
                                    showline: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.itemListPrimaryModel13,
                                  updateCallback: () => safeSetState(() {}),
                                  child: ItemListPrimaryWidget(
                                    title: 'Fluoroscopic Observation',
                                    showline: false,
                                  ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                          ),
                        ),
                      ].divide(SizedBox(height: () {
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
                      }())),
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
    );
  }
}
