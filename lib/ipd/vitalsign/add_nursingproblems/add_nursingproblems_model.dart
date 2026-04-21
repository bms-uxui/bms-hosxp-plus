import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/button_template/button_template_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/check_box_style/check_box/check_box_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/nursingproblems_template/nursingproblems_template_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_nursingproblems_widget.dart' show AddNursingproblemsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddNursingproblemsModel
    extends FlutterFlowModel<AddNursingproblemsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ButtonTemplate component.
  late ButtonTemplateModel buttonTemplateModel;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel1;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel4;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel2;
  // Model for CheckBox component.
  late CheckBoxModel checkBoxModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    buttonTemplateModel = createModel(context, () => ButtonTemplateModel());
    datePickerModel1 = createModel(context, () => DatePickerModel());
    timePickerModel = createModel(context, () => TimePickerModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel3 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel4 =
        createModel(context, () => IconButtonTertiaryModel());
    datePickerModel2 = createModel(context, () => DatePickerModel());
    checkBoxModel = createModel(context, () => CheckBoxModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    buttonTemplateModel.dispose();
    datePickerModel1.dispose();
    timePickerModel.dispose();
    iconButtonTertiaryModel1.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    iconButtonTertiaryModel2.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    iconButtonTertiaryModel3.dispose();
    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    iconButtonTertiaryModel4.dispose();
    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    datePickerModel2.dispose();
    checkBoxModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
