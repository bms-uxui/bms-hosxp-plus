import '/dsign_system/alertdialog/alert_dialog_i_dcard/alert_dialog_i_dcard_widget.dart';
import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/consult/buttonsheet_doctor/buttonsheet_doctor_widget.dart';
import '/organ_donation/buttonsheet_numeye/buttonsheet_numeye_widget.dart';
import '/organ_donation/buttonsheet_reasoneyewasnotpreserved/buttonsheet_reasoneyewasnotpreserved_widget.dart';
import '/organ_donation/buttonsheet_reasonsforunsuccessfu/buttonsheet_reasonsforunsuccessfu_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'patient_info_organ_donation_widget.dart'
    show PatientInfoOrganDonationWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientInfoOrganDonationModel
    extends FlutterFlowModel<PatientInfoOrganDonationWidget> {
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
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // Model for Dropdown component.
  late DropdownModel dropdownModel5;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    datePickerModel = createModel(context, () => DatePickerModel());
    timePickerModel = createModel(context, () => TimePickerModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel1.dispose();
    iconButtonTertiaryModel2.dispose();
    dropdownModel1.dispose();
    datePickerModel.dispose();
    timePickerModel.dispose();
    dropdownModel2.dispose();
    dropdownModel3.dispose();
    dropdownModel4.dispose();
    dropdownModel5.dispose();
    bottonPrimaryModel.dispose();
  }
}
