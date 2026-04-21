import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/er/physical_examination/buttonsheet_emergency_indications/buttonsheet_emergency_indications_widget.dart';
import '/er/physical_examination/buttonsheet_overall_patient_status/buttonsheet_overall_patient_status_widget.dart';
import '/er/physical_examination/buttonsheet_physical_examination/buttonsheet_physical_examination_widget.dart';
import '/er/physical_examination/more_physical_examination/more_physical_examination_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_autocomplete_options_list.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_physical_examination_copy_widget.dart'
    show AddPhysicalExaminationCopyWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AddPhysicalExaminationCopyModel
    extends FlutterFlowModel<AddPhysicalExaminationCopyWidget> {
  ///  Local state fields for this page.

  int? pageview = 1;

  ///  State fields for stateful widgets in this page.

  // Model for ButtonAIgenerate component.
  late ButtonAIgenerateModel buttonAIgenerateModel;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel1;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel2;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // State field(s) for TextField widget.
  final textFieldKey1 = GlobalKey();
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? textFieldSelectedOption1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel3;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel4;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel5;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel6;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel7;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel8;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel9;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel5;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel6;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode6;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel7;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode7;
  TextEditingController? textController7;
  String? Function(BuildContext, String?)? textController7Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel8;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode8;
  TextEditingController? textController8;
  String? Function(BuildContext, String?)? textController8Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel9;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode9;
  TextEditingController? textController9;
  String? Function(BuildContext, String?)? textController9Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel10;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode10;
  TextEditingController? textController10;
  String? Function(BuildContext, String?)? textController10Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel11;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode11;
  TextEditingController? textController11;
  String? Function(BuildContext, String?)? textController11Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel12;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode12;
  TextEditingController? textController12;
  String? Function(BuildContext, String?)? textController12Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel13;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode13;
  TextEditingController? textController13;
  String? Function(BuildContext, String?)? textController13Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel14;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode14;
  TextEditingController? textController14;
  String? Function(BuildContext, String?)? textController14Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel15;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode15;
  TextEditingController? textController15;
  String? Function(BuildContext, String?)? textController15Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel16;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode16;
  TextEditingController? textController16;
  String? Function(BuildContext, String?)? textController16Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel17;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode17;
  TextEditingController? textController17;
  String? Function(BuildContext, String?)? textController17Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel18;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode18;
  TextEditingController? textController18;
  String? Function(BuildContext, String?)? textController18Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel19;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode19;
  TextEditingController? textController19;
  String? Function(BuildContext, String?)? textController19Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel20;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode20;
  TextEditingController? textController20;
  String? Function(BuildContext, String?)? textController20Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel21;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode21;
  TextEditingController? textController21;
  String? Function(BuildContext, String?)? textController21Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel22;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode22;
  TextEditingController? textController22;
  String? Function(BuildContext, String?)? textController22Validator;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel10;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode23;
  TextEditingController? textController23;
  String? Function(BuildContext, String?)? textController23Validator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    buttonAIgenerateModel = createModel(context, () => ButtonAIgenerateModel());
    datePickerModel1 = createModel(context, () => DatePickerModel());
    timePickerModel1 = createModel(context, () => TimePickerModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    datePickerModel2 = createModel(context, () => DatePickerModel());
    timePickerModel2 = createModel(context, () => TimePickerModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel3 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel4 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel5 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel6 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel7 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel8 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel9 =
        createModel(context, () => IconButtonTertiaryModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    dropdownModel6 = createModel(context, () => DropdownModel());
    dropdownModel7 = createModel(context, () => DropdownModel());
    dropdownModel8 = createModel(context, () => DropdownModel());
    dropdownModel9 = createModel(context, () => DropdownModel());
    dropdownModel10 = createModel(context, () => DropdownModel());
    dropdownModel11 = createModel(context, () => DropdownModel());
    dropdownModel12 = createModel(context, () => DropdownModel());
    dropdownModel13 = createModel(context, () => DropdownModel());
    dropdownModel14 = createModel(context, () => DropdownModel());
    dropdownModel15 = createModel(context, () => DropdownModel());
    dropdownModel16 = createModel(context, () => DropdownModel());
    dropdownModel17 = createModel(context, () => DropdownModel());
    dropdownModel18 = createModel(context, () => DropdownModel());
    dropdownModel19 = createModel(context, () => DropdownModel());
    dropdownModel20 = createModel(context, () => DropdownModel());
    dropdownModel21 = createModel(context, () => DropdownModel());
    dropdownModel22 = createModel(context, () => DropdownModel());
    iconButtonTertiaryModel10 =
        createModel(context, () => IconButtonTertiaryModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    buttonAIgenerateModel.dispose();
    datePickerModel1.dispose();
    timePickerModel1.dispose();
    dropdownModel1.dispose();
    dropdownModel2.dispose();
    datePickerModel2.dispose();
    timePickerModel2.dispose();
    iconButtonTertiaryModel1.dispose();
    textFieldFocusNode1?.dispose();

    expandableExpandableController.dispose();
    iconButtonPrimaryModel.dispose();
    iconButtonTertiaryModel2.dispose();
    iconButtonTertiaryModel3.dispose();
    iconButtonTertiaryModel4.dispose();
    iconButtonTertiaryModel5.dispose();
    iconButtonTertiaryModel6.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    iconButtonTertiaryModel7.dispose();
    iconButtonTertiaryModel8.dispose();
    iconButtonTertiaryModel9.dispose();
    dropdownModel3.dispose();
    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    dropdownModel4.dispose();
    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    dropdownModel5.dispose();
    textFieldFocusNode5?.dispose();
    textController5?.dispose();

    dropdownModel6.dispose();
    textFieldFocusNode6?.dispose();
    textController6?.dispose();

    dropdownModel7.dispose();
    textFieldFocusNode7?.dispose();
    textController7?.dispose();

    dropdownModel8.dispose();
    textFieldFocusNode8?.dispose();
    textController8?.dispose();

    dropdownModel9.dispose();
    textFieldFocusNode9?.dispose();
    textController9?.dispose();

    dropdownModel10.dispose();
    textFieldFocusNode10?.dispose();
    textController10?.dispose();

    dropdownModel11.dispose();
    textFieldFocusNode11?.dispose();
    textController11?.dispose();

    dropdownModel12.dispose();
    textFieldFocusNode12?.dispose();
    textController12?.dispose();

    dropdownModel13.dispose();
    textFieldFocusNode13?.dispose();
    textController13?.dispose();

    dropdownModel14.dispose();
    textFieldFocusNode14?.dispose();
    textController14?.dispose();

    dropdownModel15.dispose();
    textFieldFocusNode15?.dispose();
    textController15?.dispose();

    dropdownModel16.dispose();
    textFieldFocusNode16?.dispose();
    textController16?.dispose();

    dropdownModel17.dispose();
    textFieldFocusNode17?.dispose();
    textController17?.dispose();

    dropdownModel18.dispose();
    textFieldFocusNode18?.dispose();
    textController18?.dispose();

    dropdownModel19.dispose();
    textFieldFocusNode19?.dispose();
    textController19?.dispose();

    dropdownModel20.dispose();
    textFieldFocusNode20?.dispose();
    textController20?.dispose();

    dropdownModel21.dispose();
    textFieldFocusNode21?.dispose();
    textController21?.dispose();

    dropdownModel22.dispose();
    textFieldFocusNode22?.dispose();
    textController22?.dispose();

    iconButtonTertiaryModel10.dispose();
    textFieldFocusNode23?.dispose();
    textController23?.dispose();

    bottonPrimaryModel.dispose();
  }
}
