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
import 'item_nurs_probltm_widget.dart' show ItemNursProbltmWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemNursProbltmModel extends FlutterFlowModel<ItemNursProbltmWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for NursingproblemsDetail component.
  late NursingproblemsDetailModel nursingproblemsDetailModel1;
  // Model for NursingproblemsDetail component.
  late NursingproblemsDetailModel nursingproblemsDetailModel2;
  // Model for GoalDetail component.
  late GoalDetailModel goalDetailModel;
  // Model for PlanningDetail component.
  late PlanningDetailModel planningDetailModel;
  // Model for AssessmentDetail component.
  late AssessmentDetailModel assessmentDetailModel;

  @override
  void initState(BuildContext context) {
    dateandTimeRecordeModel =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    nursingproblemsDetailModel1 =
        createModel(context, () => NursingproblemsDetailModel());
    nursingproblemsDetailModel2 =
        createModel(context, () => NursingproblemsDetailModel());
    goalDetailModel = createModel(context, () => GoalDetailModel());
    planningDetailModel = createModel(context, () => PlanningDetailModel());
    assessmentDetailModel = createModel(context, () => AssessmentDetailModel());
  }

  @override
  void dispose() {
    expandableExpandableController.dispose();
    dateandTimeRecordeModel.dispose();
    iconButtonTertiaryModel.dispose();
    nursingproblemsDetailModel1.dispose();
    nursingproblemsDetailModel2.dispose();
    goalDetailModel.dispose();
    planningDetailModel.dispose();
    assessmentDetailModel.dispose();
  }
}
