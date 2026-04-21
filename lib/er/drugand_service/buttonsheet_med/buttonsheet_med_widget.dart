import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_tertiary/item_list_tertiary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'buttonsheet_med_model.dart';
export 'buttonsheet_med_model.dart';

class ButtonsheetMedWidget extends StatefulWidget {
  const ButtonsheetMedWidget({super.key});

  @override
  State<ButtonsheetMedWidget> createState() => _ButtonsheetMedWidgetState();
}

class _ButtonsheetMedWidgetState extends State<ButtonsheetMedWidget>
    with TickerProviderStateMixin {
  late ButtonsheetMedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ButtonsheetMedModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

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
                  'Medication',
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
            child: Column(
              children: [
                Align(
                  alignment: Alignment(0.0, 0),
                  child: TabBar(
                    labelColor: FlutterFlowTheme.of(context).primaryText,
                    unselectedLabelColor:
                        FlutterFlowTheme.of(context).secondaryText,
                    labelPadding: EdgeInsets.all(2.0),
                    labelStyle: FlutterFlowTheme.of(context)
                        .labelLarge
                        .override(
                          fontFamily:
                              FlutterFlowTheme.of(context).labelLargeFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).labelLargeIsCustom,
                        ),
                    unselectedLabelStyle: FlutterFlowTheme.of(context)
                        .bodyLarge
                        .override(
                          fontFamily:
                              FlutterFlowTheme.of(context).bodyLargeFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                        ),
                    indicatorColor: FlutterFlowTheme.of(context).primary,
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    tabs: [
                      Tab(
                        text: 'ยา',
                      ),
                      Tab(
                        text: 'เวชภัณฑ์',
                      ),
                    ],
                    controller: _model.tabBarController,
                    onTap: (i) async {
                      [() async {}, () async {}][i]();
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _model.tabBarController,
                    children: [
                      Padding(
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
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            wrapWithModel(
                              model: _model.searchBarSecondaryModel1,
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
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
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
                                      padding:
                                          EdgeInsets.all(valueOrDefault<double>(
                                        () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
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
                                              FFAppState().medecationOrder =
                                                  'ยา';
                                              safeSetState(() {});
                                              Navigator.pop(context);
                                            },
                                            child: wrapWithModel(
                                              model:
                                                  _model.itemListTertiaryModel1,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: ItemListTertiaryWidget(
                                                title: 'Paracetamol 500 mg',
                                                titlecolor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                showline: true,
                                                icon: FaIcon(
                                                  FontAwesomeIcons.capsules,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 8.0,
                                                ),
                                                iconcolor2:
                                                    FlutterFlowTheme.of(context)
                                                        .customColor8,
                                                iconcolor1:
                                                    FlutterFlowTheme.of(context)
                                                        .customColor7,
                                              ),
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel2,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'Paracetamol 500 mg',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: true,
                                              icon: FaIcon(
                                                FontAwesomeIcons.capsules,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 8.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel3,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'Ibuprofen 200 mg',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: true,
                                              icon: FaIcon(
                                                FontAwesomeIcons.capsules,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 8.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel4,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'Ibuprofen 200 mg',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: true,
                                              icon: FaIcon(
                                                FontAwesomeIcons.capsules,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 8.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel5,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'Ibuprofen 200 mg',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: true,
                                              icon: FaIcon(
                                                FontAwesomeIcons.capsules,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 8.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel6,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'Ibuprofen 200 mg',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: true,
                                              icon: FaIcon(
                                                FontAwesomeIcons.capsules,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 8.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel7,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'Ciprofloxacin 500 mg',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: false,
                                              icon: FaIcon(
                                                FontAwesomeIcons.capsules,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 8.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
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
                          }())).addToStart(SizedBox(height: () {
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
                      Padding(
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
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            wrapWithModel(
                              model: _model.searchBarSecondaryModel2,
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
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
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
                                      padding:
                                          EdgeInsets.all(valueOrDefault<double>(
                                        () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
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
                                              FFAppState().medecationOrder =
                                                  'เวชภัณฑ์';
                                              safeSetState(() {});
                                              Navigator.pop(context);
                                            },
                                            child: wrapWithModel(
                                              model:
                                                  _model.itemListTertiaryModel8,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: ItemListTertiaryWidget(
                                                title: 'ผ้าก๊อซ',
                                                titlecolor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                showline: true,
                                                icon: Icon(
                                                  Icons.healing_outlined,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 10.0,
                                                ),
                                                iconcolor2:
                                                    FlutterFlowTheme.of(context)
                                                        .customColor8,
                                                iconcolor1:
                                                    FlutterFlowTheme.of(context)
                                                        .customColor7,
                                              ),
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel9,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'ผ้าก๊อซ',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: true,
                                              icon: Icon(
                                                Icons.healing_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 10.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel10,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'แอลกอฮอล์ 70%',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: true,
                                              icon: Icon(
                                                Icons.healing_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 10.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel11,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'พลาสเตอร์ยา',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: true,
                                              icon: Icon(
                                                Icons.healing_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 10.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.itemListTertiaryModel12,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: ItemListTertiaryWidget(
                                              title: 'พลาสเตอร์ยา',
                                              titlecolor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              showline: false,
                                              icon: Icon(
                                                Icons.healing_outlined,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                size: 10.0,
                                              ),
                                              iconcolor2:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor8,
                                              iconcolor1:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor7,
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
                          }())).addToStart(SizedBox(height: () {
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
