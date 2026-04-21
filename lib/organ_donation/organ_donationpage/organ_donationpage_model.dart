import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/icon_style/icon_female/icon_female_widget.dart';
import '/dsign_system/icon_style/icon_male/icon_male_widget.dart';
import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/fillter_examinationroom_i_p_d/fillter_examinationroom_i_p_d_widget.dart';
import '/organ_donation/approached/approached_widget.dart';
import '/organ_donation/declined/declined_widget.dart';
import '/organ_donation/discussionnotinitiated/discussionnotinitiated_widget.dart';
import '/organ_donation/fillter_organ_donation/fillter_organ_donation_widget.dart';
import '/organ_donation/item_patient_organ_donationpage/item_patient_organ_donationpage_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'organ_donationpage_widget.dart' show OrganDonationpageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrganDonationpageModel extends FlutterFlowModel<OrganDonationpageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SearchBarPrimary component.
  late SearchBarPrimaryModel searchBarPrimaryModel;
  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel;
  // Model for Item_PatientOrganDonationpage component.
  late ItemPatientOrganDonationpageModel itemPatientOrganDonationpageModel1;
  // Model for Item_PatientOrganDonationpage component.
  late ItemPatientOrganDonationpageModel itemPatientOrganDonationpageModel2;
  // Model for Item_PatientOrganDonationpage component.
  late ItemPatientOrganDonationpageModel itemPatientOrganDonationpageModel3;
  // Model for Item_PatientOrganDonationpage component.
  late ItemPatientOrganDonationpageModel itemPatientOrganDonationpageModel4;

  @override
  void initState(BuildContext context) {
    searchBarPrimaryModel = createModel(context, () => SearchBarPrimaryModel());
    buttonFillterModel = createModel(context, () => ButtonFillterModel());
    itemPatientOrganDonationpageModel1 =
        createModel(context, () => ItemPatientOrganDonationpageModel());
    itemPatientOrganDonationpageModel2 =
        createModel(context, () => ItemPatientOrganDonationpageModel());
    itemPatientOrganDonationpageModel3 =
        createModel(context, () => ItemPatientOrganDonationpageModel());
    itemPatientOrganDonationpageModel4 =
        createModel(context, () => ItemPatientOrganDonationpageModel());
  }

  @override
  void dispose() {
    searchBarPrimaryModel.dispose();
    buttonFillterModel.dispose();
    itemPatientOrganDonationpageModel1.dispose();
    itemPatientOrganDonationpageModel2.dispose();
    itemPatientOrganDonationpageModel3.dispose();
    itemPatientOrganDonationpageModel4.dispose();
  }
}
