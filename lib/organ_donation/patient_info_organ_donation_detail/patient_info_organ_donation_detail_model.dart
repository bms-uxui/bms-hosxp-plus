import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/organ_donation/approached/approached_widget.dart';
import '/organ_donation/buttonsheet_reasoneyewasnotpreserved/buttonsheet_reasoneyewasnotpreserved_widget.dart';
import '/organ_donation/discussionnotinitiated_preview/discussionnotinitiated_preview_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'patient_info_organ_donation_detail_widget.dart'
    show PatientInfoOrganDonationDetailWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientInfoOrganDonationDetailModel
    extends FlutterFlowModel<PatientInfoOrganDonationDetailWidget> {
  ///  Local state fields for this page.

  String? brainCardiac;

  String? donationPotential;

  String? waedCT;

  String? discussion;

  String? approach;

  String? eyepreservation;

  ///  State fields for stateful widgets in this page.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for Approached component.
  late ApproachedModel approachedModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    approachedModel = createModel(context, () => ApproachedModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    dropdownModel = createModel(context, () => DropdownModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel1.dispose();
    approachedModel.dispose();
    iconButtonTertiaryModel2.dispose();
    dropdownModel.dispose();
  }
}
