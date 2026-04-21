import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/er/patient_screening/buttonsheet_eyeopeningresponse/buttonsheet_eyeopeningresponse_widget.dart';
import '/er/patient_screening/buttonsheet_facility_types/buttonsheet_facility_types_widget.dart';
import '/er/patient_screening/buttonsheet_motorresponse/buttonsheet_motorresponse_widget.dart';
import '/er/patient_screening/buttonsheet_typeof_arrival/buttonsheet_typeof_arrival_widget.dart';
import '/er/patient_screening/buttonsheet_verbalresponse/buttonsheet_verbalresponse_widget.dart';
import '/er/patient_screening/item_level_consciousness/item_level_consciousness_widget.dart';
import '/er/patient_screening/item_pain_score/item_pain_score_widget.dart';
import '/er/patient_screening/item_triage_levels/item_triage_levels_widget.dart';
import '/er/patient_screening/item_typepatient_e_r/item_typepatient_e_r_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_autocomplete_options_list.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/consult/buttonsheet_doctor/buttonsheet_doctor_widget.dart';
import '/ipd/lab_xray/buttonsheet_patient_condition/buttonsheet_patient_condition_widget.dart';
import '/ipd/vitalsign/buttonsheet_dutydoctor/buttonsheet_dutydoctor_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_screening_widget.dart' show AddScreeningWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddScreeningModel extends FlutterFlowModel<AddScreeningWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for DatePicker component.
  late DatePickerModel datePickerModel;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // Model for Dropdown component.
  late DropdownModel dropdownModel5;
  // Model for Item_TypepatientER component.
  late ItemTypepatientERModel itemTypepatientERModel1;
  // Model for Item_TypepatientER component.
  late ItemTypepatientERModel itemTypepatientERModel2;
  // Model for Item_TypepatientER component.
  late ItemTypepatientERModel itemTypepatientERModel3;
  // Model for Item_TypepatientER component.
  late ItemTypepatientERModel itemTypepatientERModel4;
  // Model for Item_TypepatientER component.
  late ItemTypepatientERModel itemTypepatientERModel5;
  // Model for Item_TypepatientER component.
  late ItemTypepatientERModel itemTypepatientERModel6;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // State field(s) for TextField widget.
  final textFieldKey1 = GlobalKey();
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? textFieldSelectedOption1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode6;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode7;
  TextEditingController? textController7;
  String? Function(BuildContext, String?)? textController7Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode8;
  TextEditingController? textController8;
  String? Function(BuildContext, String?)? textController8Validator;
  // Model for Item_LevelConsciousness component.
  late ItemLevelConsciousnessModel itemLevelConsciousnessModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode9;
  TextEditingController? textController9;
  String? Function(BuildContext, String?)? textController9Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel6;
  // Model for Dropdown component.
  late DropdownModel dropdownModel7;
  // Model for Dropdown component.
  late DropdownModel dropdownModel8;
  // Model for Item_PainScore component.
  late ItemPainScoreModel itemPainScoreModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode10;
  TextEditingController? textController10;
  String? Function(BuildContext, String?)? textController10Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel9;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode11;
  TextEditingController? textController11;
  String? Function(BuildContext, String?)? textController11Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel10;
  // Model for Item_TriageLevels component.
  late ItemTriageLevelsModel itemTriageLevelsModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    datePickerModel = createModel(context, () => DatePickerModel());
    timePickerModel = createModel(context, () => TimePickerModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    itemTypepatientERModel1 =
        createModel(context, () => ItemTypepatientERModel());
    itemTypepatientERModel2 =
        createModel(context, () => ItemTypepatientERModel());
    itemTypepatientERModel3 =
        createModel(context, () => ItemTypepatientERModel());
    itemTypepatientERModel4 =
        createModel(context, () => ItemTypepatientERModel());
    itemTypepatientERModel5 =
        createModel(context, () => ItemTypepatientERModel());
    itemTypepatientERModel6 =
        createModel(context, () => ItemTypepatientERModel());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    itemLevelConsciousnessModel =
        createModel(context, () => ItemLevelConsciousnessModel());
    dropdownModel6 = createModel(context, () => DropdownModel());
    dropdownModel7 = createModel(context, () => DropdownModel());
    dropdownModel8 = createModel(context, () => DropdownModel());
    itemPainScoreModel = createModel(context, () => ItemPainScoreModel());
    dropdownModel9 = createModel(context, () => DropdownModel());
    dropdownModel10 = createModel(context, () => DropdownModel());
    itemTriageLevelsModel = createModel(context, () => ItemTriageLevelsModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    datePickerModel.dispose();
    timePickerModel.dispose();
    dropdownModel1.dispose();
    dropdownModel2.dispose();
    dropdownModel3.dispose();
    dropdownModel4.dispose();
    dropdownModel5.dispose();
    itemTypepatientERModel1.dispose();
    itemTypepatientERModel2.dispose();
    itemTypepatientERModel3.dispose();
    itemTypepatientERModel4.dispose();
    itemTypepatientERModel5.dispose();
    itemTypepatientERModel6.dispose();
    iconButtonTertiaryModel.dispose();
    textFieldFocusNode1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    textFieldFocusNode5?.dispose();
    textController5?.dispose();

    textFieldFocusNode6?.dispose();
    textController6?.dispose();

    textFieldFocusNode7?.dispose();
    textController7?.dispose();

    textFieldFocusNode8?.dispose();
    textController8?.dispose();

    itemLevelConsciousnessModel.dispose();
    textFieldFocusNode9?.dispose();
    textController9?.dispose();

    dropdownModel6.dispose();
    dropdownModel7.dispose();
    dropdownModel8.dispose();
    itemPainScoreModel.dispose();
    textFieldFocusNode10?.dispose();
    textController10?.dispose();

    dropdownModel9.dispose();
    textFieldFocusNode11?.dispose();
    textController11?.dispose();

    dropdownModel10.dispose();
    itemTriageLevelsModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
