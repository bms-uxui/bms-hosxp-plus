import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/from_field/count_controller/count_controller_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/buttonsheet_examination/buttonsheet_examination_widget.dart';
import '/ipd/vitalsign/item_co_operator/item_co_operator_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_treatment_i_p_d_widget.dart' show AddTreatmentIPDWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddTreatmentIPDModel extends FlutterFlowModel<AddTreatmentIPDWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for CountController component.
  late CountControllerModel countControllerModel1;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Model for CountController component.
  late CountControllerModel countControllerModel2;
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
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for Item_CoOperator component.
  late ItemCoOperatorModel itemCoOperatorModel1;
  // Model for Item_CoOperator component.
  late ItemCoOperatorModel itemCoOperatorModel2;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    dropdownModel1 = createModel(context, () => DropdownModel());
    countControllerModel1 = createModel(context, () => CountControllerModel());
    countControllerModel2 = createModel(context, () => CountControllerModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    datePickerModel1 = createModel(context, () => DatePickerModel());
    timePickerModel1 = createModel(context, () => TimePickerModel());
    datePickerModel2 = createModel(context, () => DatePickerModel());
    timePickerModel2 = createModel(context, () => TimePickerModel());
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    itemCoOperatorModel1 = createModel(context, () => ItemCoOperatorModel());
    itemCoOperatorModel2 = createModel(context, () => ItemCoOperatorModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    dropdownModel1.dispose();
    countControllerModel1.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    countControllerModel2.dispose();
    dropdownModel2.dispose();
    datePickerModel1.dispose();
    timePickerModel1.dispose();
    datePickerModel2.dispose();
    timePickerModel2.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    iconButtonPrimaryModel.dispose();
    itemCoOperatorModel1.dispose();
    itemCoOperatorModel2.dispose();
    bottonPrimaryModel.dispose();
  }
}
