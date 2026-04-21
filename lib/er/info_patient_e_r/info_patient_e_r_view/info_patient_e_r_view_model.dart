import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/info_patient_e_r/item_admit/item_admit_widget.dart';
import '/er/info_patient_e_r/item_expired/item_expired_widget.dart';
import '/er/info_patient_e_r/item_refer/item_refer_widget.dart';
import '/er/treatmentsummaryreport_view/treatmentsummaryreport_view_widget.dart';
import '/er/widget/resuscitation_e_s_i/resuscitation_e_s_i_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/admit/item_chronic_disease/item_chronic_disease_widget.dart';
import '/ipd/admit/item_congenital_disease/item_congenital_disease_widget.dart';
import '/ipd/admit/item_surgicalhistory/item_surgicalhistory_widget.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'info_patient_e_r_view_widget.dart' show InfoPatientERViewWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InfoPatientERViewModel extends FlutterFlowModel<InfoPatientERViewWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController1;

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for Treatmentsummaryreport_View component.
  late TreatmentsummaryreportViewModel treatmentsummaryreportViewModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for Item_ChronicDisease component.
  late ItemChronicDiseaseModel itemChronicDiseaseModel;
  // Model for Item_CongenitalDisease component.
  late ItemCongenitalDiseaseModel itemCongenitalDiseaseModel;
  // Model for Item_Surgicalhistory component.
  late ItemSurgicalhistoryModel itemSurgicalhistoryModel;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController2;

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel3;
  // Model for Item_Drugallergy component.
  late ItemDrugallergyModel itemDrugallergyModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel4;
  // Model for ResuscitationESI component.
  late ResuscitationESIModel resuscitationESIModel;
  // Model for Item_Admit component.
  late ItemAdmitModel itemAdmitModel;
  // Model for Item_Refer component.
  late ItemReferModel itemReferModel;
  // Model for Item_Expired component.
  late ItemExpiredModel itemExpiredModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    treatmentsummaryreportViewModel =
        createModel(context, () => TreatmentsummaryreportViewModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    itemChronicDiseaseModel =
        createModel(context, () => ItemChronicDiseaseModel());
    itemCongenitalDiseaseModel =
        createModel(context, () => ItemCongenitalDiseaseModel());
    itemSurgicalhistoryModel =
        createModel(context, () => ItemSurgicalhistoryModel());
    iconButtonTertiaryModel3 =
        createModel(context, () => IconButtonTertiaryModel());
    itemDrugallergyModel = createModel(context, () => ItemDrugallergyModel());
    iconButtonTertiaryModel4 =
        createModel(context, () => IconButtonTertiaryModel());
    resuscitationESIModel = createModel(context, () => ResuscitationESIModel());
    itemAdmitModel = createModel(context, () => ItemAdmitModel());
    itemReferModel = createModel(context, () => ItemReferModel());
    itemExpiredModel = createModel(context, () => ItemExpiredModel());
  }

  @override
  void dispose() {
    expandableExpandableController1.dispose();
    iconButtonTertiaryModel1.dispose();
    treatmentsummaryreportViewModel.dispose();
    iconButtonTertiaryModel2.dispose();
    itemChronicDiseaseModel.dispose();
    itemCongenitalDiseaseModel.dispose();
    itemSurgicalhistoryModel.dispose();
    expandableExpandableController2.dispose();
    iconButtonTertiaryModel3.dispose();
    itemDrugallergyModel.dispose();
    iconButtonTertiaryModel4.dispose();
    resuscitationESIModel.dispose();
    itemAdmitModel.dispose();
    itemReferModel.dispose();
    itemExpiredModel.dispose();
  }
}
