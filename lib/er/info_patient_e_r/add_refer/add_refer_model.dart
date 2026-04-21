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
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_refer_widget.dart' show AddReferWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddReferModel extends FlutterFlowModel<AddReferWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    dropdownModel1 = createModel(context, () => DropdownModel());
    datePickerModel = createModel(context, () => DatePickerModel());
    timePickerModel = createModel(context, () => TimePickerModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    dropdownModel1.dispose();
    datePickerModel.dispose();
    timePickerModel.dispose();
    dropdownModel2.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    bottonPrimaryModel.dispose();
  }
}
