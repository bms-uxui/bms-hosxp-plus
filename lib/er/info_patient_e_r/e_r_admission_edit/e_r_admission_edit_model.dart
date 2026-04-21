import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/er/physical_examination/buttonsheet_emergency_indications/buttonsheet_emergency_indications_widget.dart';
import '/er/physical_examination/buttonsheet_overall_patient_status/buttonsheet_overall_patient_status_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/lab_xray/buttonsheet_patient_condition/buttonsheet_patient_condition_widget.dart';
import '/ipd/vitalsign/buttonsheet_dutydoctor/buttonsheet_dutydoctor_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'e_r_admission_edit_widget.dart' show ERAdmissionEditWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ERAdmissionEditModel extends FlutterFlowModel<ERAdmissionEditWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for DatePicker component.
  late DatePickerModel datePickerModel1;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel2;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel2;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel3;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel3;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel4;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel4;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    datePickerModel1 = createModel(context, () => DatePickerModel());
    timePickerModel1 = createModel(context, () => TimePickerModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    datePickerModel2 = createModel(context, () => DatePickerModel());
    timePickerModel2 = createModel(context, () => TimePickerModel());
    datePickerModel3 = createModel(context, () => DatePickerModel());
    timePickerModel3 = createModel(context, () => TimePickerModel());
    datePickerModel4 = createModel(context, () => DatePickerModel());
    timePickerModel4 = createModel(context, () => TimePickerModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    datePickerModel1.dispose();
    timePickerModel1.dispose();
    dropdownModel1.dispose();
    dropdownModel2.dispose();
    dropdownModel3.dispose();
    datePickerModel2.dispose();
    timePickerModel2.dispose();
    datePickerModel3.dispose();
    timePickerModel3.dispose();
    datePickerModel4.dispose();
    timePickerModel4.dispose();
    dropdownModel4.dispose();
    bottonPrimaryModel.dispose();
  }
}
