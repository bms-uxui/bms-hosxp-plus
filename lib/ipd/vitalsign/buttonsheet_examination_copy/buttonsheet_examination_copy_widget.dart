import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_secondary/item_list_secondary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'buttonsheet_examination_copy_model.dart';
export 'buttonsheet_examination_copy_model.dart';

class ButtonsheetExaminationCopyWidget extends StatefulWidget {
  const ButtonsheetExaminationCopyWidget({
    super.key,
    required this.user,
  });

  final String? user;

  @override
  State<ButtonsheetExaminationCopyWidget> createState() =>
      _ButtonsheetExaminationCopyWidgetState();
}

class _ButtonsheetExaminationCopyWidgetState
    extends State<ButtonsheetExaminationCopyWidget> {
  late ButtonsheetExaminationCopyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonsheetExaminationCopyModel());

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
                  'Examination',
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
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.itemListSecondaryModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ItemListSecondaryWidget(
                                      title: '001',
                                      titlecolor:
                                          FlutterFlowTheme.of(context).primary,
                                      subtitle: 'ทอสอบ',
                                      subtitelcolor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      hideline: true,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.itemListSecondaryModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ItemListSecondaryWidget(
                                      title: '002',
                                      titlecolor:
                                          FlutterFlowTheme.of(context).primary,
                                      subtitle: 'ทอสอบ',
                                      subtitelcolor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      hideline: true,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.itemListSecondaryModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ItemListSecondaryWidget(
                                      title: '003',
                                      titlecolor:
                                          FlutterFlowTheme.of(context).primary,
                                      subtitle: 'ทอสอบ',
                                      subtitelcolor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      hideline: true,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.itemListSecondaryModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ItemListSecondaryWidget(
                                      title: '004',
                                      titlecolor:
                                          FlutterFlowTheme.of(context).primary,
                                      subtitle: 'ทอสอบ',
                                      subtitelcolor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      hideline: true,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: wrapWithModel(
                                    model: _model.itemListSecondaryModel5,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ItemListSecondaryWidget(
                                      title: '005',
                                      titlecolor:
                                          FlutterFlowTheme.of(context).primary,
                                      subtitle: 'ทอสอบ',
                                      subtitelcolor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      hideline: false,
                                    ),
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
