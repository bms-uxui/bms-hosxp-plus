import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/opd/widget/i_c_d10_treatment_o_p_d/i_c_d10_treatment_o_p_d_widget.dart';
import '/opd/widget/item_department_o1/item_department_o1_widget.dart';
import '/opd/widget/item_department_o10/item_department_o10_widget.dart';
import '/opd/widget/item_department_o2/item_department_o2_widget.dart';
import '/opd/widget/item_department_o3/item_department_o3_widget.dart';
import '/opd/widget/item_department_o4/item_department_o4_widget.dart';
import '/opd/widget/item_department_o5/item_department_o5_widget.dart';
import '/opd/widget/item_department_o6/item_department_o6_widget.dart';
import '/opd/widget/item_department_o7/item_department_o7_widget.dart';
import '/opd/widget/item_department_o8/item_department_o8_widget.dart';
import '/opd/widget/item_department_o9/item_department_o9_widget.dart';
import '/opd/widget/tab_n_s/tab_n_s_widget.dart';
import '/opd/widget/tab_t_r/tab_t_r_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'service_o_p_dpage_model.dart';
export 'service_o_p_dpage_model.dart';

class ServiceOPDpageWidget extends StatefulWidget {
  const ServiceOPDpageWidget({super.key});

  @override
  State<ServiceOPDpageWidget> createState() => _ServiceOPDpageWidgetState();
}

class _ServiceOPDpageWidgetState extends State<ServiceOPDpageWidget> {
  late ServiceOPDpageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ServiceOPDpageModel());

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

    return Padding(
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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.iconTitleModel,
                updateCallback: () => safeSetState(() {}),
                child: IconTitleWidget(
                  titletext: 'ข้อมูลผู้มารับบริการผู้ป่วยนอก',
                  icon: FaIcon(
                    FontAwesomeIcons.hospitalUser,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    size: 10.0,
                  ),
                  color1: Color(0xFF80C2FB),
                  color2: FlutterFlowTheme.of(context).info,
                ),
              ),
              Text(
                '23 พฤษภาคม 2568',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).labelSmallIsCustom,
                    ),
              ),
              Container(
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
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        direction: Axis.horizontal,
                        runAlignment: WrapAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        clipBehavior: Clip.none,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              FFAppState().TabOPDhomepage = 1;
                              safeSetState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FFAppState().TabOPDhomepage == 1
                                        ? FlutterFlowTheme.of(context).accent2
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    FFAppState().TabOPDhomepage == 1
                                        ? FlutterFlowTheme.of(context).accent1
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    valueOrDefault<double>(
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
                                    ),
                                    8.0,
                                    valueOrDefault<double>(
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
                                    ),
                                    8.0),
                                child: Text(
                                  'จำนวนผู้รับบริการ',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyMediumFamily,
                                        color: FFAppState().TabOPDhomepage == 1
                                            ? FlutterFlowTheme.of(context)
                                                .primaryBackground
                                            : FlutterFlowTheme.of(context)
                                                .secondaryText,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodyMediumIsCustom,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              FFAppState().TabOPDhomepage = 2;
                              safeSetState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FFAppState().TabOPDhomepage == 2
                                        ? FlutterFlowTheme.of(context).accent2
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    FFAppState().TabOPDhomepage == 2
                                        ? FlutterFlowTheme.of(context).accent1
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    valueOrDefault<double>(
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
                                    ),
                                    8.0,
                                    valueOrDefault<double>(
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
                                    ),
                                    8.0),
                                child: Text(
                                  'สิทธิกการรักษา',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodyMediumFamily,
                                        color: FFAppState().TabOPDhomepage == 2
                                            ? FlutterFlowTheme.of(context)
                                                .primaryBackground
                                            : FlutterFlowTheme.of(context)
                                                .secondaryText,
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
                      Stack(
                        children: [
                          if (FFAppState().TabOPDhomepage == 1)
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: wrapWithModel(
                                model: _model.tabNSModel,
                                updateCallback: () => safeSetState(() {}),
                                child: TabNSWidget(),
                              ),
                            ),
                          if (FFAppState().TabOPDhomepage == 2)
                            wrapWithModel(
                              model: _model.tabTRModel,
                              updateCallback: () => safeSetState(() {}),
                              child: TabTRWidget(),
                            ),
                        ],
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
            ].divide(SizedBox(height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 12.0;
              } else {
                return 12.0;
              }
            }())),
          ),
          if (FFAppState().TabOPDhomepage == 1)
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                wrapWithModel(
                  model: _model.iCD10TreatmentOPDModel,
                  updateCallback: () => safeSetState(() {}),
                  child: ICD10TreatmentOPDWidget(),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'แผนกผู้ป่วยนอก',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyLargeFamily,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts:
                                !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                          ),
                    ),
                    MasonryGridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 2;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 2;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 3;
                          } else {
                            return 3;
                          }
                        }(),
                      ),
                      crossAxisSpacing: () {
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
                      mainAxisSpacing: () {
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
                      itemCount: 10,
                      padding: EdgeInsets.fromLTRB(
                        0,
                        0,
                        0,
                        0,
                      ),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return [
                          () => wrapWithModel(
                                model: _model.itemDepartmentO1Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO1Widget(
                                  name: 'อายุรกรรม',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO2Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO2Widget(
                                  name: 'ศัลยกรรม',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO3Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO3Widget(
                                  name: 'สูติกรรม',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO4Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO4Widget(
                                  name: 'กุมารเวชกรรม',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO5Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO5Widget(
                                  name: 'โสต ศอ นาสิก',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO6Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO6Widget(
                                  name: 'จิตเวช',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO7Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO7Widget(
                                  name: 'แพทย์แผนไทย',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO8Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO8Widget(
                                  name: 'ศัลยกรรมประสาท',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO9Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO9Widget(
                                  name: 'เวชกรรมสังคม',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                          () => wrapWithModel(
                                model: _model.itemDepartmentO10Model,
                                updateCallback: () => safeSetState(() {}),
                                child: ItemDepartmentO10Widget(
                                  name: 'กายอุปกรณ์ (นักกายอุปกรณ์)',
                                  quantity: 0,
                                  quantitywaiting: '0',
                                  quantitychecked: '0',
                                ),
                              ),
                        ][index]();
                      },
                    ),
                  ].divide(SizedBox(height: () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 8.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 8.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointLarge) {
                      return 12.0;
                    } else {
                      return 12.0;
                    }
                  }())),
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
        ].divide(SizedBox(height: () {
          if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
            return 12.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
            return 12.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
            return 16.0;
          } else {
            return 16.0;
          }
        }())),
      ),
    );
  }
}
