import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/diagnosis/item_diagnosis_i_c_d10/item_diagnosis_i_c_d10_widget.dart';
import '/ipd/diagnosis/item_diagnosis_i_c_d9_c_m/item_diagnosis_i_c_d9_c_m_widget.dart';
import '/ipd/summarize_chart/add_discharge_summary/add_discharge_summary_widget.dart';
import '/ipd/summarize_chart/add_icd10_dischage/add_icd10_dischage_widget.dart';
import '/ipd/summarize_chart/add_icd9_dischage/add_icd9_dischage_widget.dart';
import '/ipd/summarize_chart/add_treatmentsummary/add_treatmentsummary_widget.dart';
import '/ipd/summarize_chart/item_discharge/item_discharge_widget.dart';
import '/ipd/summarize_chart/item_treatmentsummary/item_treatmentsummary_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'discharge_summary_view_widget.dart' show DischargeSummaryViewWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DischargeSummaryViewModel
    extends FlutterFlowModel<DischargeSummaryViewWidget> {
  ///  Local state fields for this component.

  int? dischargeSummary;

  ///  State fields for stateful widgets in this component.

  // Model for Add_DischargeSummary component.
  late AddDischargeSummaryModel addDischargeSummaryModel;
  // Model for Add_icd10_dischage component.
  late AddIcd10DischageModel addIcd10DischageModel;
  // Model for Add_icd9_dischage component.
  late AddIcd9DischageModel addIcd9DischageModel;
  // Model for Add_Treatmentsummary component.
  late AddTreatmentsummaryModel addTreatmentsummaryModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel1;
  // Model for Item_Discharge component.
  late ItemDischargeModel itemDischargeModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel2;
  // Model for Item_DiagnosisICD10 component.
  late ItemDiagnosisICD10Model itemDiagnosisICD10Model;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel3;
  // Model for Item_DiagnosisICD9CM component.
  late ItemDiagnosisICD9CMModel itemDiagnosisICD9CMModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel4;
  // Model for Item_Treatmentsummary component.
  late ItemTreatmentsummaryModel itemTreatmentsummaryModel;

  @override
  void initState(BuildContext context) {
    addDischargeSummaryModel =
        createModel(context, () => AddDischargeSummaryModel());
    addIcd10DischageModel = createModel(context, () => AddIcd10DischageModel());
    addIcd9DischageModel = createModel(context, () => AddIcd9DischageModel());
    addTreatmentsummaryModel =
        createModel(context, () => AddTreatmentsummaryModel());
    iconButtonPrimaryModel1 =
        createModel(context, () => IconButtonPrimaryModel());
    itemDischargeModel = createModel(context, () => ItemDischargeModel());
    iconButtonPrimaryModel2 =
        createModel(context, () => IconButtonPrimaryModel());
    itemDiagnosisICD10Model =
        createModel(context, () => ItemDiagnosisICD10Model());
    iconButtonPrimaryModel3 =
        createModel(context, () => IconButtonPrimaryModel());
    itemDiagnosisICD9CMModel =
        createModel(context, () => ItemDiagnosisICD9CMModel());
    iconButtonPrimaryModel4 =
        createModel(context, () => IconButtonPrimaryModel());
    itemTreatmentsummaryModel =
        createModel(context, () => ItemTreatmentsummaryModel());
  }

  @override
  void dispose() {
    addDischargeSummaryModel.dispose();
    addIcd10DischageModel.dispose();
    addIcd9DischageModel.dispose();
    addTreatmentsummaryModel.dispose();
    iconButtonPrimaryModel1.dispose();
    itemDischargeModel.dispose();
    iconButtonPrimaryModel2.dispose();
    itemDiagnosisICD10Model.dispose();
    iconButtonPrimaryModel3.dispose();
    itemDiagnosisICD9CMModel.dispose();
    iconButtonPrimaryModel4.dispose();
    itemTreatmentsummaryModel.dispose();
  }
}
