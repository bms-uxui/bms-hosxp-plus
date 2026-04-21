import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/count_controller/count_controller_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'add_icd9_dischage_widget.dart' show AddIcd9DischageWidget;
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddIcd9DischageModel extends FlutterFlowModel<AddIcd9DischageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel1;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel1;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel2;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Model for CountController component.
  late CountControllerModel countControllerModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // Model for Dropdown component.
  late DropdownModel dropdownModel5;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    datePickerModel1 = createModel(context, () => DatePickerModel());
    timePickerModel1 = createModel(context, () => TimePickerModel());
    datePickerModel2 = createModel(context, () => DatePickerModel());
    timePickerModel2 = createModel(context, () => TimePickerModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    countControllerModel = createModel(context, () => CountControllerModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    dropdownModel1.dispose();
    dropdownModel2.dispose();
    datePickerModel1.dispose();
    timePickerModel1.dispose();
    datePickerModel2.dispose();
    timePickerModel2.dispose();
    dropdownModel3.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    countControllerModel.dispose();
    dropdownModel4.dispose();
    dropdownModel5.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    bottonPrimaryModel.dispose();
  }
}
