import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/admit/admitpage_view/admitpage_view_widget.dart';
import '/ipd/drugand_service/drunglist_view/drunglist_view_widget.dart';
import '/ipd/lab_xray/lab_xray_view/lab_xray_view_widget.dart';
import '/ipd/medical_certificate/medicalcertificate_view/medicalcertificate_view_widget.dart';
import '/ipd/operative_note/operative_note_view/operative_note_view_widget.dart';
import '/ipd/order_sheet/order_sheet_view/order_sheet_view_widget.dart';
import '/ipd/summarize_chart/discharge_summary_operation_view/discharge_summary_operation_view_widget.dart';
import '/ipd/summarize_chart/discharge_summary_view/discharge_summary_view_widget.dart';
import '/ipd/vitalsign/vitalsignpage_view/vitalsignpage_view_widget.dart';
import '/ipd/widget/menu_patient_info_i_p_d/menu_patient_info_i_p_d_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'patient_info_summarize_chart_widget.dart'
    show PatientInfoSummarizeChartWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientInfoSummarizeChartModel
    extends FlutterFlowModel<PatientInfoSummarizeChartWidget> {
  ///  Local state fields for this page.

  bool? expan;

  ///  State fields for stateful widgets in this page.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel1;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel2;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel3;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel4;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel5;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel6;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel7;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel8;
  // Model for Admitpage_View component.
  late AdmitpageViewModel admitpageViewModel;
  // Model for OrderSheet_View component.
  late OrderSheetViewModel orderSheetViewModel;
  // Model for Vitalsignpage_View component.
  late VitalsignpageViewModel vitalsignpageViewModel;
  // Model for Lab_Xray_View component.
  late LabXrayViewModel labXrayViewModel;
  // Model for DrunglistView component.
  late DrunglistViewModel drunglistViewModel;
  // Model for Medicalcertificate_View component.
  late MedicalcertificateViewModel medicalcertificateViewModel;
  // Model for OperativeNote_View component.
  late OperativeNoteViewModel operativeNoteViewModel;
  // Model for DischargeSummaryOperation_View component.
  late DischargeSummaryOperationViewModel dischargeSummaryOperationViewModel;
  // Model for DischargeSummary_view component.
  late DischargeSummaryViewModel dischargeSummaryViewModel1;
  // Model for DischargeSummary_view component.
  late DischargeSummaryViewModel dischargeSummaryViewModel2;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    menuPatientInfoIPDModel1 =
        createModel(context, () => MenuPatientInfoIPDModel());
    menuPatientInfoIPDModel2 =
        createModel(context, () => MenuPatientInfoIPDModel());
    menuPatientInfoIPDModel3 =
        createModel(context, () => MenuPatientInfoIPDModel());
    menuPatientInfoIPDModel4 =
        createModel(context, () => MenuPatientInfoIPDModel());
    menuPatientInfoIPDModel5 =
        createModel(context, () => MenuPatientInfoIPDModel());
    menuPatientInfoIPDModel6 =
        createModel(context, () => MenuPatientInfoIPDModel());
    menuPatientInfoIPDModel7 =
        createModel(context, () => MenuPatientInfoIPDModel());
    menuPatientInfoIPDModel8 =
        createModel(context, () => MenuPatientInfoIPDModel());
    admitpageViewModel = createModel(context, () => AdmitpageViewModel());
    orderSheetViewModel = createModel(context, () => OrderSheetViewModel());
    vitalsignpageViewModel =
        createModel(context, () => VitalsignpageViewModel());
    labXrayViewModel = createModel(context, () => LabXrayViewModel());
    drunglistViewModel = createModel(context, () => DrunglistViewModel());
    medicalcertificateViewModel =
        createModel(context, () => MedicalcertificateViewModel());
    operativeNoteViewModel =
        createModel(context, () => OperativeNoteViewModel());
    dischargeSummaryOperationViewModel =
        createModel(context, () => DischargeSummaryOperationViewModel());
    dischargeSummaryViewModel1 =
        createModel(context, () => DischargeSummaryViewModel());
    dischargeSummaryViewModel2 =
        createModel(context, () => DischargeSummaryViewModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    menuPatientInfoIPDModel1.dispose();
    menuPatientInfoIPDModel2.dispose();
    menuPatientInfoIPDModel3.dispose();
    menuPatientInfoIPDModel4.dispose();
    menuPatientInfoIPDModel5.dispose();
    menuPatientInfoIPDModel6.dispose();
    menuPatientInfoIPDModel7.dispose();
    menuPatientInfoIPDModel8.dispose();
    admitpageViewModel.dispose();
    orderSheetViewModel.dispose();
    vitalsignpageViewModel.dispose();
    labXrayViewModel.dispose();
    drunglistViewModel.dispose();
    medicalcertificateViewModel.dispose();
    operativeNoteViewModel.dispose();
    dischargeSummaryOperationViewModel.dispose();
    dischargeSummaryViewModel1.dispose();
    dischargeSummaryViewModel2.dispose();
  }
}
