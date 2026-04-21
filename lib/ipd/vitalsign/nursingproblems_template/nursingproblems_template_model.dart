import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/button_delet/button_delet_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/assessment_detail/assessment_detail_widget.dart';
import '/ipd/vitalsign/item_nursingproblems_template/item_nursingproblems_template_widget.dart';
import '/ipd/vitalsign/nursingproblems_detail/nursingproblems_detail_widget.dart';
import '/ipd/vitalsign/planning_detail/planning_detail_widget.dart';
import '/ipd/widget/goal_detail/goal_detail_widget.dart';
import 'dart:async';
import 'dart:ui';
import 'nursingproblems_template_widget.dart'
    show NursingproblemsTemplateWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NursingproblemsTemplateModel
    extends FlutterFlowModel<NursingproblemsTemplateWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel;
  // Model for Item_Nursingproblems_Template component.
  late ItemNursingproblemsTemplateModel itemNursingproblemsTemplateModel1;
  // Model for Item_Nursingproblems_Template component.
  late ItemNursingproblemsTemplateModel itemNursingproblemsTemplateModel2;
  // Model for Item_Nursingproblems_Template component.
  late ItemNursingproblemsTemplateModel itemNursingproblemsTemplateModel3;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for NursingproblemsDetail component.
  late NursingproblemsDetailModel nursingproblemsDetailModel;
  // Model for GoalDetail component.
  late GoalDetailModel goalDetailModel;
  // Model for PlanningDetail component.
  late PlanningDetailModel planningDetailModel;
  // Model for AssessmentDetail component.
  late AssessmentDetailModel assessmentDetailModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel4;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel5;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel6;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel7;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel8;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel9;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode6;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel10;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode7;
  TextEditingController? textController7;
  String? Function(BuildContext, String?)? textController7Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel11;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode8;
  TextEditingController? textController8;
  String? Function(BuildContext, String?)? textController8Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel12;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode9;
  TextEditingController? textController9;
  String? Function(BuildContext, String?)? textController9Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel13;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode10;
  TextEditingController? textController10;
  String? Function(BuildContext, String?)? textController10Validator;
  // Model for ButtonDelet component.
  late ButtonDeletModel buttonDeletModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel2;

  @override
  void initState(BuildContext context) {
    searchBarSecondaryModel =
        createModel(context, () => SearchBarSecondaryModel());
    itemNursingproblemsTemplateModel1 =
        createModel(context, () => ItemNursingproblemsTemplateModel());
    itemNursingproblemsTemplateModel2 =
        createModel(context, () => ItemNursingproblemsTemplateModel());
    itemNursingproblemsTemplateModel3 =
        createModel(context, () => ItemNursingproblemsTemplateModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    nursingproblemsDetailModel =
        createModel(context, () => NursingproblemsDetailModel());
    goalDetailModel = createModel(context, () => GoalDetailModel());
    planningDetailModel = createModel(context, () => PlanningDetailModel());
    assessmentDetailModel = createModel(context, () => AssessmentDetailModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel3 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel4 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel5 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel6 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel7 =
        createModel(context, () => IconButtonTertiaryModel());
    bottonPrimaryModel1 = createModel(context, () => BottonPrimaryModel());
    iconButtonTertiaryModel8 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel9 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel10 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel11 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel12 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel13 =
        createModel(context, () => IconButtonTertiaryModel());
    buttonDeletModel = createModel(context, () => ButtonDeletModel());
    bottonPrimaryModel2 = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    searchBarSecondaryModel.dispose();
    itemNursingproblemsTemplateModel1.dispose();
    itemNursingproblemsTemplateModel2.dispose();
    itemNursingproblemsTemplateModel3.dispose();
    iconButtonTertiaryModel1.dispose();
    nursingproblemsDetailModel.dispose();
    goalDetailModel.dispose();
    planningDetailModel.dispose();
    assessmentDetailModel.dispose();
    iconButtonTertiaryModel2.dispose();
    iconButtonTertiaryModel3.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    iconButtonTertiaryModel4.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    iconButtonTertiaryModel5.dispose();
    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    iconButtonTertiaryModel6.dispose();
    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    iconButtonTertiaryModel7.dispose();
    textFieldFocusNode5?.dispose();
    textController5?.dispose();

    bottonPrimaryModel1.dispose();
    iconButtonTertiaryModel8.dispose();
    iconButtonTertiaryModel9.dispose();
    textFieldFocusNode6?.dispose();
    textController6?.dispose();

    iconButtonTertiaryModel10.dispose();
    textFieldFocusNode7?.dispose();
    textController7?.dispose();

    iconButtonTertiaryModel11.dispose();
    textFieldFocusNode8?.dispose();
    textController8?.dispose();

    iconButtonTertiaryModel12.dispose();
    textFieldFocusNode9?.dispose();
    textController9?.dispose();

    iconButtonTertiaryModel13.dispose();
    textFieldFocusNode10?.dispose();
    textController10?.dispose();

    buttonDeletModel.dispose();
    bottonPrimaryModel2.dispose();
  }
}
