import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/chronic_disease/chronic_disease_widget.dart';
import '/dsign_system/congenital_disease/congenital_disease_widget.dart';
import '/dsign_system/drug_allergy/drug_allergy_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/dsign_system/status_appointment/status_appointment_widget.dart';
import '/dsign_system/status_lab/status_lab_widget.dart';
import '/dsign_system/status_rx/status_rx_widget.dart';
import '/dsign_system/status_tx/status_tx_widget.dart';
import '/dsign_system/status_xray/status_xray_widget.dart';
import '/dsign_system/surgical_history/surgical_history_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/opd/fillter_examinationroom_o_p_d/fillter_examinationroom_o_p_d_widget.dart';
import '/opd/widget/urgency_l1/urgency_l1_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'patient_list_o_p_d_widget.dart' show PatientListOPDWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientListOPDModel extends FlutterFlowModel<PatientListOPDWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SearchBarPrimary component.
  late SearchBarPrimaryModel searchBarPrimaryModel;
  // Model for UrgencyL1 component.
  late UrgencyL1Model urgencyL1Model;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for ChronicDisease component.
  late ChronicDiseaseModel chronicDiseaseModel;
  // Model for CongenitalDisease component.
  late CongenitalDiseaseModel congenitalDiseaseModel;
  // Model for DrugAllergy component.
  late DrugAllergyModel drugAllergyModel;
  // Model for SurgicalHistory component.
  late SurgicalHistoryModel surgicalHistoryModel;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for StatusLab component.
  late StatusLabModel statusLabModel;
  // Model for StatusXray component.
  late StatusXrayModel statusXrayModel;
  // Model for StatusTx component.
  late StatusTxModel statusTxModel;
  // Model for StatusRx component.
  late StatusRxModel statusRxModel;
  // Model for StatusAppointment component.
  late StatusAppointmentModel statusAppointmentModel;
  // Model for Nav_Bar component.
  late NavBarModel navBarModel;

  @override
  void initState(BuildContext context) {
    searchBarPrimaryModel = createModel(context, () => SearchBarPrimaryModel());
    urgencyL1Model = createModel(context, () => UrgencyL1Model());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    chronicDiseaseModel = createModel(context, () => ChronicDiseaseModel());
    congenitalDiseaseModel =
        createModel(context, () => CongenitalDiseaseModel());
    drugAllergyModel = createModel(context, () => DrugAllergyModel());
    surgicalHistoryModel = createModel(context, () => SurgicalHistoryModel());
    statusLabModel = createModel(context, () => StatusLabModel());
    statusXrayModel = createModel(context, () => StatusXrayModel());
    statusTxModel = createModel(context, () => StatusTxModel());
    statusRxModel = createModel(context, () => StatusRxModel());
    statusAppointmentModel =
        createModel(context, () => StatusAppointmentModel());
    navBarModel = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    searchBarPrimaryModel.dispose();
    urgencyL1Model.dispose();
    iconButtonTertiaryModel.dispose();
    chronicDiseaseModel.dispose();
    congenitalDiseaseModel.dispose();
    drugAllergyModel.dispose();
    surgicalHistoryModel.dispose();
    expandableExpandableController.dispose();
    statusLabModel.dispose();
    statusXrayModel.dispose();
    statusTxModel.dispose();
    statusRxModel.dispose();
    statusAppointmentModel.dispose();
    navBarModel.dispose();
  }
}
