import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/assessment_detail/assessment_detail_widget.dart';
import '/ipd/vitalsign/nursingproblems_detail/nursingproblems_detail_widget.dart';
import '/ipd/vitalsign/planning_detail/planning_detail_widget.dart';
import '/ipd/widget/goal_detail/goal_detail_widget.dart';
import 'dart:ui';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_nurs_probltm_model.dart';
export 'item_nurs_probltm_model.dart';

class ItemNursProbltmWidget extends StatefulWidget {
  const ItemNursProbltmWidget({
    super.key,
    this.userrecorder,
    this.day,
    this.month,
    this.year,
    this.time,
    Color? color,
    this.nursingproblems,
    this.goal,
    this.planning,
    this.assessment,
  }) : this.color = color ?? const Color(0xFF465054);

  final String? userrecorder;
  final String? day;
  final String? month;
  final String? year;
  final String? time;
  final Color color;
  final String? nursingproblems;
  final String? goal;
  final String? planning;
  final String? assessment;

  @override
  State<ItemNursProbltmWidget> createState() => _ItemNursProbltmWidgetState();
}

class _ItemNursProbltmWidgetState extends State<ItemNursProbltmWidget> {
  late ItemNursProbltmModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemNursProbltmModel());

    _model.expandableExpandableController =
        ExpandableController(initialExpanded: false)
          ..addListener(() => safeSetState(() {}));
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
          child: Container(
            width: double.infinity,
            color: Color(0x00000000),
            child: ExpandableNotifier(
              controller: _model.expandableExpandableController,
              child: ExpandablePanel(
                header: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ผู้บันทึก',
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodySmallIsCustom,
                              ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 8.0, 0.0),
                              child: wrapWithModel(
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
                            ),
                            wrapWithModel(
                              model: _model.iconButtonTertiaryModel,
                              updateCallback: () => safeSetState(() {}),
                              child: IconButtonTertiaryWidget(
                                iconbuttontertiary: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 14.0,
                                ),
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      valueOrDefault<String>(
                        widget!.userrecorder,
                        'Name',
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily:
                                FlutterFlowTheme.of(context).bodyMediumFamily,
                            color: FlutterFlowTheme.of(context).accent1,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            useGoogleFonts: !FlutterFlowTheme.of(context)
                                .bodyMediumIsCustom,
                          ),
                    ),
                  ],
                ),
                collapsed: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: wrapWithModel(
                    model: _model.nursingproblemsDetailModel1,
                    updateCallback: () => safeSetState(() {}),
                    child: NursingproblemsDetailWidget(
                      nursingproblems: widget!.nursingproblems,
                      bgcolor: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                  ),
                ),
                expanded: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wrapWithModel(
                        model: _model.nursingproblemsDetailModel2,
                        updateCallback: () => safeSetState(() {}),
                        child: NursingproblemsDetailWidget(
                          nursingproblems: widget!.nursingproblems,
                          bgcolor:
                              FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                      wrapWithModel(
                        model: _model.goalDetailModel,
                        updateCallback: () => safeSetState(() {}),
                        child: GoalDetailWidget(
                          goal: widget!.goal,
                          bgcolor:
                              FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                      wrapWithModel(
                        model: _model.planningDetailModel,
                        updateCallback: () => safeSetState(() {}),
                        child: PlanningDetailWidget(
                          planning: widget!.planning,
                          bgcolor:
                              FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                      wrapWithModel(
                        model: _model.assessmentDetailModel,
                        updateCallback: () => safeSetState(() {}),
                        child: AssessmentDetailWidget(
                          assessment: widget!.assessment,
                          bgcolor:
                              FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                ),
                theme: ExpandableThemeData(
                  tapHeaderToExpand: true,
                  tapBodyToExpand: false,
                  tapBodyToCollapse: false,
                  headerAlignment: ExpandablePanelHeaderAlignment.top,
                  hasIcon: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
