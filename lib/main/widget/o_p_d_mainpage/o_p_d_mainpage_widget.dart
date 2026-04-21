import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/main/widget/item_medicineroom/item_medicineroom_widget.dart';
import '/main/widget/item_right_treatment/item_right_treatment_widget.dart';
import '/main/widget/workflow/workflow_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'o_p_d_mainpage_model.dart';
export 'o_p_d_mainpage_model.dart';

class OPDMainpageWidget extends StatefulWidget {
  const OPDMainpageWidget({super.key});

  @override
  State<OPDMainpageWidget> createState() => _OPDMainpageWidgetState();
}

class _OPDMainpageWidgetState extends State<OPDMainpageWidget> {
  late OPDMainpageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OPDMainpageModel());

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
      decoration: BoxDecoration(),
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
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wrapWithModel(
                  model: _model.iconTitleModel,
                  updateCallback: () => safeSetState(() {}),
                  child: IconTitleWidget(
                    titletext: 'ข้อมูลผู้ป่วยนอกแยกตามสถานะรอรับบริการ',
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
                        fontFamily:
                            FlutterFlowTheme.of(context).labelSmallFamily,
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
                    child: Stack(
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: wrapWithModel(
                            model: _model.workflowModel,
                            updateCallback: () => safeSetState(() {}),
                            child: WorkflowWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
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
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ห้องยา',
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
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
                  mainAxisSpacing: () {
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
                  itemCount: 2,
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
                            model: _model.itemMedicineroomModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: ItemMedicineroomWidget(
                              name: 'RDU',
                              quantity: 125,
                            ),
                          ),
                      () => wrapWithModel(
                            model: _model.itemMedicineroomModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: ItemMedicineroomWidget(
                              name: 'ประวัติการแพ้ยา',
                              quantity: 40,
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
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สิทธิการรักษา',
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
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
                  mainAxisSpacing: () {
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
                  itemCount: 3,
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
                            model: _model.itemRightTreatmentModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: ItemRightTreatmentWidget(
                              name: 'ชำระเงิน',
                              quantity: '650',
                            ),
                          ),
                      () => wrapWithModel(
                            model: _model.itemRightTreatmentModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: ItemRightTreatmentWidget(
                              name: 'ข้าราชการ',
                              quantity: '460',
                            ),
                          ),
                      () => wrapWithModel(
                            model: _model.itemRightTreatmentModel3,
                            updateCallback: () => safeSetState(() {}),
                            child: ItemRightTreatmentWidget(
                              name: 'ประกันสังคม',
                              quantity: '300',
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
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 12.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 16.0;
            } else {
              return 16.0;
            }
          }())),
        ),
      ),
    );
  }
}
