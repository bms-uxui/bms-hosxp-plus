import '/dsign_system/alertdialog/alert_dialog_i_dcard/alert_dialog_i_dcard_widget.dart';
import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/er/buttonsheet_address/buttonsheet_address_widget.dart';
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
import 'dart:math' as math;
import 'regis_patientipd_e_r_widget.dart' show RegisPatientipdERWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class RegisPatientipdERModel extends FlutterFlowModel<RegisPatientipdERWidget> {
  ///  Local state fields for this page.

  String? gender;

  String? bloodgroup;

  int? pageview = 1;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  late MaskTextInputFormatter textFieldMask3;
  String? Function(BuildContext, String?)? textController3Validator;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel1;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  late MaskTextInputFormatter textFieldMask4;
  String? Function(BuildContext, String?)? textController4Validator;
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
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel1;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel2;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel6;
  // Model for Dropdown component.
  late DropdownModel dropdownModel7;
  // Model for Dropdown component.
  late DropdownModel dropdownModel8;
  // Model for Dropdown component.
  late DropdownModel dropdownModel9;
  // Model for Dropdown component.
  late DropdownModel dropdownModel10;
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
  // State field(s) for TextField widget.
  final textFieldKey8 = GlobalKey();
  FocusNode? textFieldFocusNode8;
  TextEditingController? textController8;
  String? textFieldSelectedOption8;
  String? Function(BuildContext, String?)? textController8Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode9;
  TextEditingController? textController9;
  String? Function(BuildContext, String?)? textController9Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode10;
  TextEditingController? textController10;
  String? Function(BuildContext, String?)? textController10Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode11;
  TextEditingController? textController11;
  String? Function(BuildContext, String?)? textController11Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode12;
  TextEditingController? textController12;
  String? Function(BuildContext, String?)? textController12Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode13;
  TextEditingController? textController13;
  String? Function(BuildContext, String?)? textController13Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode14;
  TextEditingController? textController14;
  String? Function(BuildContext, String?)? textController14Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode15;
  TextEditingController? textController15;
  String? Function(BuildContext, String?)? textController15Validator;
  // Model for Item_LevelConsciousness component.
  late ItemLevelConsciousnessModel itemLevelConsciousnessModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode16;
  TextEditingController? textController16;
  String? Function(BuildContext, String?)? textController16Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel11;
  // Model for Dropdown component.
  late DropdownModel dropdownModel12;
  // Model for Dropdown component.
  late DropdownModel dropdownModel13;
  // Model for Item_PainScore component.
  late ItemPainScoreModel itemPainScoreModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode17;
  TextEditingController? textController17;
  String? Function(BuildContext, String?)? textController17Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel14;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode18;
  TextEditingController? textController18;
  String? Function(BuildContext, String?)? textController18Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel15;
  // Model for Item_TriageLevels component.
  late ItemTriageLevelsModel itemTriageLevelsModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel2;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel3;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    datePickerModel1 = createModel(context, () => DatePickerModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    bottonPrimaryModel1 = createModel(context, () => BottonPrimaryModel());
    datePickerModel2 = createModel(context, () => DatePickerModel());
    timePickerModel = createModel(context, () => TimePickerModel());
    dropdownModel6 = createModel(context, () => DropdownModel());
    dropdownModel7 = createModel(context, () => DropdownModel());
    dropdownModel8 = createModel(context, () => DropdownModel());
    dropdownModel9 = createModel(context, () => DropdownModel());
    dropdownModel10 = createModel(context, () => DropdownModel());
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
    itemLevelConsciousnessModel =
        createModel(context, () => ItemLevelConsciousnessModel());
    dropdownModel11 = createModel(context, () => DropdownModel());
    dropdownModel12 = createModel(context, () => DropdownModel());
    dropdownModel13 = createModel(context, () => DropdownModel());
    itemPainScoreModel = createModel(context, () => ItemPainScoreModel());
    dropdownModel14 = createModel(context, () => DropdownModel());
    dropdownModel15 = createModel(context, () => DropdownModel());
    itemTriageLevelsModel = createModel(context, () => ItemTriageLevelsModel());
    bottonPrimaryModel2 = createModel(context, () => BottonPrimaryModel());
    bottonPrimaryModel3 = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    datePickerModel1.dispose();
    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    dropdownModel1.dispose();
    dropdownModel2.dispose();
    dropdownModel3.dispose();
    dropdownModel4.dispose();
    dropdownModel5.dispose();
    textFieldFocusNode5?.dispose();
    textController5?.dispose();

    textFieldFocusNode6?.dispose();
    textController6?.dispose();

    textFieldFocusNode7?.dispose();
    textController7?.dispose();

    bottonPrimaryModel1.dispose();
    datePickerModel2.dispose();
    timePickerModel.dispose();
    dropdownModel6.dispose();
    dropdownModel7.dispose();
    dropdownModel8.dispose();
    dropdownModel9.dispose();
    dropdownModel10.dispose();
    itemTypepatientERModel1.dispose();
    itemTypepatientERModel2.dispose();
    itemTypepatientERModel3.dispose();
    itemTypepatientERModel4.dispose();
    itemTypepatientERModel5.dispose();
    itemTypepatientERModel6.dispose();
    textFieldFocusNode8?.dispose();

    textFieldFocusNode9?.dispose();
    textController9?.dispose();

    textFieldFocusNode10?.dispose();
    textController10?.dispose();

    textFieldFocusNode11?.dispose();
    textController11?.dispose();

    textFieldFocusNode12?.dispose();
    textController12?.dispose();

    textFieldFocusNode13?.dispose();
    textController13?.dispose();

    textFieldFocusNode14?.dispose();
    textController14?.dispose();

    textFieldFocusNode15?.dispose();
    textController15?.dispose();

    itemLevelConsciousnessModel.dispose();
    textFieldFocusNode16?.dispose();
    textController16?.dispose();

    dropdownModel11.dispose();
    dropdownModel12.dispose();
    dropdownModel13.dispose();
    itemPainScoreModel.dispose();
    textFieldFocusNode17?.dispose();
    textController17?.dispose();

    dropdownModel14.dispose();
    textFieldFocusNode18?.dispose();
    textController18?.dispose();

    dropdownModel15.dispose();
    itemTriageLevelsModel.dispose();
    bottonPrimaryModel2.dispose();
    bottonPrimaryModel3.dispose();
  }
}
