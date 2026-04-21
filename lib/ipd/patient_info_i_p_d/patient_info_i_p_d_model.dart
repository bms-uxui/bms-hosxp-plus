import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/admit/admitpage_view/admitpage_view_widget.dart';
import '/ipd/appiontment/appiontment_view/appiontment_view_widget.dart';
import '/ipd/consult/cousult_view/cousult_view_widget.dart';
import '/ipd/diagnosis/diag_view/diag_view_widget.dart';
import '/ipd/drugand_service/drug_srevice_view/drug_srevice_view_widget.dart';
import '/ipd/emr/e_m_rpage_view/e_m_rpage_view_widget.dart';
import '/ipd/lab_xray/lab_xray_view/lab_xray_view_widget.dart';
import '/ipd/medical_certificate/medicalcertificate_view/medicalcertificate_view_widget.dart';
import '/ipd/order_sheet/order_sheet_view/order_sheet_view_widget.dart';
import '/ipd/vitalsign/vitalsignpage_view/vitalsignpage_view_widget.dart';
import '/ipd/widget/menu_patient_info_i_p_d/menu_patient_info_i_p_d_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'patient_info_i_p_d_widget.dart' show PatientInfoIPDWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientInfoIPDModel extends FlutterFlowModel<PatientInfoIPDWidget> {
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
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel9;
  // Model for MenuPatient_InfoIPD component.
  late MenuPatientInfoIPDModel menuPatientInfoIPDModel10;
  // Model for Admitpage_View component.
  late AdmitpageViewModel admitpageViewModel;
  // Model for EMRpage_View component.
  late EMRpageViewModel eMRpageViewModel;
  // Model for Vitalsignpage_View component.
  late VitalsignpageViewModel vitalsignpageViewModel;
  // Model for Lab_Xray_View component.
  late LabXrayViewModel labXrayViewModel;
  // Model for Diag_View component.
  late DiagViewModel diagViewModel;
  // Model for Drug_Srevice_View component.
  late DrugSreviceViewModel drugSreviceViewModel;
  // Model for Appiontment_View component.
  late AppiontmentViewModel appiontmentViewModel;
  // Model for Cousult_View component.
  late CousultViewModel cousultViewModel;
  // Model for Medicalcertificate_View component.
  late MedicalcertificateViewModel medicalcertificateViewModel;
  // Model for OrderSheet_View component.
  late OrderSheetViewModel orderSheetViewModel;

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
    menuPatientInfoIPDModel9 =
        createModel(context, () => MenuPatientInfoIPDModel());
    menuPatientInfoIPDModel10 =
        createModel(context, () => MenuPatientInfoIPDModel());
    admitpageViewModel = createModel(context, () => AdmitpageViewModel());
    eMRpageViewModel = createModel(context, () => EMRpageViewModel());
    vitalsignpageViewModel =
        createModel(context, () => VitalsignpageViewModel());
    labXrayViewModel = createModel(context, () => LabXrayViewModel());
    diagViewModel = createModel(context, () => DiagViewModel());
    drugSreviceViewModel = createModel(context, () => DrugSreviceViewModel());
    appiontmentViewModel = createModel(context, () => AppiontmentViewModel());
    cousultViewModel = createModel(context, () => CousultViewModel());
    medicalcertificateViewModel =
        createModel(context, () => MedicalcertificateViewModel());
    orderSheetViewModel = createModel(context, () => OrderSheetViewModel());
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
    menuPatientInfoIPDModel9.dispose();
    menuPatientInfoIPDModel10.dispose();
    admitpageViewModel.dispose();
    eMRpageViewModel.dispose();
    vitalsignpageViewModel.dispose();
    labXrayViewModel.dispose();
    diagViewModel.dispose();
    drugSreviceViewModel.dispose();
    appiontmentViewModel.dispose();
    cousultViewModel.dispose();
    medicalcertificateViewModel.dispose();
    orderSheetViewModel.dispose();
  }
}
