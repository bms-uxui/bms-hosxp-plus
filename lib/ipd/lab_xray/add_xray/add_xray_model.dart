import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/consult/buttonsheet_doctor/buttonsheet_doctor_widget.dart';
import '/ipd/lab_xray/buttonsheet_lab_priority_levels/buttonsheet_lab_priority_levels_widget.dart';
import '/ipd/lab_xray/buttonsheet_location_orderer/buttonsheet_location_orderer_widget.dart';
import '/ipd/lab_xray/buttonsheet_patient_condition/buttonsheet_patient_condition_widget.dart';
import '/ipd/lab_xray/buttonsheet_xray_room/buttonsheet_xray_room_widget.dart';
import '/ipd/lab_xray/buttonsheet_xraylist/buttonsheet_xraylist_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_xray_widget.dart' show AddXrayWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddXrayModel extends FlutterFlowModel<AddXrayWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // Model for Dropdown component.
  late DropdownModel dropdownModel5;
  // Model for Dropdown component.
  late DropdownModel dropdownModel6;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    dropdownModel6 = createModel(context, () => DropdownModel());
    datePickerModel = createModel(context, () => DatePickerModel());
    timePickerModel = createModel(context, () => TimePickerModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    dropdownModel1.dispose();
    dropdownModel2.dispose();
    dropdownModel3.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    dropdownModel4.dispose();
    dropdownModel5.dispose();
    dropdownModel6.dispose();
    datePickerModel.dispose();
    timePickerModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
