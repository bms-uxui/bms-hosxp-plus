import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/accident/accident_view/accident_view_widget.dart';
import '/er/diagnosis/diag_e_r_view/diag_e_r_view_widget.dart';
import '/er/drugand_service/drug_srevice_e_r_view/drug_srevice_e_r_view_widget.dart';
import '/er/emr/e_m_r_er_view/e_m_r_er_view_widget.dart';
import '/er/fillter_menu_e_r/fillter_menu_e_r_widget.dart';
import '/er/info_patient_e_r/info_patient_e_r_view/info_patient_e_r_view_widget.dart';
import '/er/menu_patient_info_e_r/menu_patient_info_e_r_widget.dart';
import '/er/nursing_activities/nursing_activities_view/nursing_activities_view_widget.dart';
import '/er/observe/observe_view/observe_view_widget.dart';
import '/er/patient_screening/patient_screening_view/patient_screening_view_widget.dart';
import '/er/physical_examination/physical_examination_view/physical_examination_view_widget.dart';
import '/er/treatment/treatment_e_r_view/treatment_e_r_view_widget.dart';
import '/er/waitingfor_screening/waitingfor_screening_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/appiontment_view/appiontment_view_widget.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import '/ipd/lab_xray/lab_xray_view/lab_xray_view_widget.dart';
import '/ipd/medical_certificate/medicalcertificate_view/medicalcertificate_view_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'patient_info_e_r_widget.dart' show PatientInfoERWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientInfoERModel extends FlutterFlowModel<PatientInfoERWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for WaitingforScreening component.
  late WaitingforScreeningModel waitingforScreeningModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel1;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel2;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel3;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel4;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel5;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel6;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel7;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel8;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel9;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel10;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel11;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel12;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel13;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel14;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel15;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel16;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel17;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel18;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel19;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel20;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel21;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel22;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel23;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel24;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel25;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel26;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel27;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel28;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel29;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel30;
  // Model for MenuPatient_InfoER component.
  late MenuPatientInfoERModel menuPatientInfoERModel31;
  // Model for Info_PatientER_View component.
  late InfoPatientERViewModel infoPatientERViewModel;
  // Model for EMR_er_view component.
  late EMRErViewModel eMRErViewModel;
  // Model for PatientScreening_View component.
  late PatientScreeningViewModel patientScreeningViewModel;
  // Model for PhysicalExamination_View component.
  late PhysicalExaminationViewModel physicalExaminationViewModel;
  // Model for NursingActivities_View component.
  late NursingActivitiesViewModel nursingActivitiesViewModel;
  // Model for Accident_View component.
  late AccidentViewModel accidentViewModel;
  // Model for Observe_View component.
  late ObserveViewModel observeViewModel;
  // Model for treatmentER_View component.
  late TreatmentERViewModel treatmentERViewModel;
  // Model for Lab_Xray_View component.
  late LabXrayViewModel labXrayViewModel;
  // Model for DiagER_View component.
  late DiagERViewModel diagERViewModel;
  // Model for Drug_SreviceER_View component.
  late DrugSreviceERViewModel drugSreviceERViewModel;
  // Model for Appiontment_View component.
  late AppiontmentViewModel appiontmentViewModel;
  // Model for Medicalcertificate_View component.
  late MedicalcertificateViewModel medicalcertificateViewModel;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for Item_Drugallergy component.
  late ItemDrugallergyModel itemDrugallergyModel;

  @override
  void initState(BuildContext context) {
    waitingforScreeningModel =
        createModel(context, () => WaitingforScreeningModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    menuPatientInfoERModel1 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel2 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel3 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel4 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel5 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel6 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel7 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel8 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel9 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel10 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel11 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel12 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel13 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel14 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel15 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel16 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel17 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel18 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel19 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel20 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel21 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel22 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel23 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel24 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel25 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel26 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel27 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel28 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel29 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel30 =
        createModel(context, () => MenuPatientInfoERModel());
    menuPatientInfoERModel31 =
        createModel(context, () => MenuPatientInfoERModel());
    infoPatientERViewModel =
        createModel(context, () => InfoPatientERViewModel());
    eMRErViewModel = createModel(context, () => EMRErViewModel());
    patientScreeningViewModel =
        createModel(context, () => PatientScreeningViewModel());
    physicalExaminationViewModel =
        createModel(context, () => PhysicalExaminationViewModel());
    nursingActivitiesViewModel =
        createModel(context, () => NursingActivitiesViewModel());
    accidentViewModel = createModel(context, () => AccidentViewModel());
    observeViewModel = createModel(context, () => ObserveViewModel());
    treatmentERViewModel = createModel(context, () => TreatmentERViewModel());
    labXrayViewModel = createModel(context, () => LabXrayViewModel());
    diagERViewModel = createModel(context, () => DiagERViewModel());
    drugSreviceERViewModel =
        createModel(context, () => DrugSreviceERViewModel());
    appiontmentViewModel = createModel(context, () => AppiontmentViewModel());
    medicalcertificateViewModel =
        createModel(context, () => MedicalcertificateViewModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    itemDrugallergyModel = createModel(context, () => ItemDrugallergyModel());
  }

  @override
  void dispose() {
    waitingforScreeningModel.dispose();
    iconButtonTertiaryModel1.dispose();
    menuPatientInfoERModel1.dispose();
    menuPatientInfoERModel2.dispose();
    menuPatientInfoERModel3.dispose();
    menuPatientInfoERModel4.dispose();
    menuPatientInfoERModel5.dispose();
    menuPatientInfoERModel6.dispose();
    menuPatientInfoERModel7.dispose();
    menuPatientInfoERModel8.dispose();
    menuPatientInfoERModel9.dispose();
    menuPatientInfoERModel10.dispose();
    menuPatientInfoERModel11.dispose();
    menuPatientInfoERModel12.dispose();
    menuPatientInfoERModel13.dispose();
    menuPatientInfoERModel14.dispose();
    menuPatientInfoERModel15.dispose();
    menuPatientInfoERModel16.dispose();
    menuPatientInfoERModel17.dispose();
    menuPatientInfoERModel18.dispose();
    menuPatientInfoERModel19.dispose();
    menuPatientInfoERModel20.dispose();
    menuPatientInfoERModel21.dispose();
    menuPatientInfoERModel22.dispose();
    menuPatientInfoERModel23.dispose();
    menuPatientInfoERModel24.dispose();
    menuPatientInfoERModel25.dispose();
    menuPatientInfoERModel26.dispose();
    menuPatientInfoERModel27.dispose();
    menuPatientInfoERModel28.dispose();
    menuPatientInfoERModel29.dispose();
    menuPatientInfoERModel30.dispose();
    menuPatientInfoERModel31.dispose();
    infoPatientERViewModel.dispose();
    eMRErViewModel.dispose();
    patientScreeningViewModel.dispose();
    physicalExaminationViewModel.dispose();
    nursingActivitiesViewModel.dispose();
    accidentViewModel.dispose();
    observeViewModel.dispose();
    treatmentERViewModel.dispose();
    labXrayViewModel.dispose();
    diagERViewModel.dispose();
    drugSreviceERViewModel.dispose();
    appiontmentViewModel.dispose();
    medicalcertificateViewModel.dispose();
    expandableExpandableController.dispose();
    iconButtonTertiaryModel2.dispose();
    itemDrugallergyModel.dispose();
  }
}
