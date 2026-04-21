import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/er/physical_examination/abdomen/abdomen_widget.dart';
import '/er/physical_examination/buttonsheet_emergency_indications/buttonsheet_emergency_indications_widget.dart';
import '/er/physical_examination/buttonsheet_overall_patient_status/buttonsheet_overall_patient_status_widget.dart';
import '/er/physical_examination/chest/chest_widget.dart';
import '/er/physical_examination/constitutional/constitutional_widget.dart';
import '/er/physical_examination/e_n_t_mounth/e_n_t_mounth_widget.dart';
import '/er/physical_examination/extremities/extremities_widget.dart';
import '/er/physical_examination/eyes/eyes_widget.dart';
import '/er/physical_examination/ga/ga_widget.dart';
import '/er/physical_examination/genitalia/genitalia_widget.dart';
import '/er/physical_examination/heart/heart_widget.dart';
import '/er/physical_examination/heent/heent_widget.dart';
import '/er/physical_examination/neurological/neurological_widget.dart';
import '/er/physical_examination/pr/pr_widget.dart';
import '/er/physical_examination/pv/pv_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_autocomplete_options_list.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_physical_examination_copy2_widget.dart'
    show AddPhysicalExaminationCopy2Widget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddPhysicalExaminationCopy2Model
    extends FlutterFlowModel<AddPhysicalExaminationCopy2Widget> {
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
  // State field(s) for TextField widget.
  final textFieldKey1 = GlobalKey();
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? textFieldSelectedOption1;
  String? Function(BuildContext, String?)? textController1Validator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // Model for Ga component.
  late GaModel gaModel1;
  // Model for Ga component.
  late GaModel gaModel2;
  // Model for Ga component.
  late GaModel gaModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for HEENT component.
  late HeentModel heentModel1;
  // Model for HEENT component.
  late HeentModel heentModel2;
  // Model for HEENT component.
  late HeentModel heentModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // Model for Heart component.
  late HeartModel heartModel1;
  // Model for Heart component.
  late HeartModel heartModel2;
  // Model for Heart component.
  late HeartModel heartModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // Model for Chest component.
  late ChestModel chestModel1;
  // Model for Chest component.
  late ChestModel chestModel2;
  // Model for Chest component.
  late ChestModel chestModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;
  // Model for Abdomen component.
  late AbdomenModel abdomenModel1;
  // Model for Abdomen component.
  late AbdomenModel abdomenModel2;
  // Model for Abdomen component.
  late AbdomenModel abdomenModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode6;
  TextEditingController? textController6;
  String? Function(BuildContext, String?)? textController6Validator;
  // Model for PR component.
  late PrModel prModel1;
  // Model for PR component.
  late PrModel prModel2;
  // Model for PR component.
  late PrModel prModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode7;
  TextEditingController? textController7;
  String? Function(BuildContext, String?)? textController7Validator;
  // Model for PV component.
  late PvModel pvModel1;
  // Model for PV component.
  late PvModel pvModel2;
  // Model for PV component.
  late PvModel pvModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode8;
  TextEditingController? textController8;
  String? Function(BuildContext, String?)? textController8Validator;
  // Model for Genitalia component.
  late GenitaliaModel genitaliaModel1;
  // Model for Genitalia component.
  late GenitaliaModel genitaliaModel2;
  // Model for Genitalia component.
  late GenitaliaModel genitaliaModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode9;
  TextEditingController? textController9;
  String? Function(BuildContext, String?)? textController9Validator;
  // Model for Neurological component.
  late NeurologicalModel neurologicalModel1;
  // Model for Neurological component.
  late NeurologicalModel neurologicalModel2;
  // Model for Neurological component.
  late NeurologicalModel neurologicalModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode10;
  TextEditingController? textController10;
  String? Function(BuildContext, String?)? textController10Validator;
  // Model for Extremities component.
  late ExtremitiesModel extremitiesModel1;
  // Model for Extremities component.
  late ExtremitiesModel extremitiesModel2;
  // Model for Extremities component.
  late ExtremitiesModel extremitiesModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode11;
  TextEditingController? textController11;
  String? Function(BuildContext, String?)? textController11Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode12;
  TextEditingController? textController12;
  String? Function(BuildContext, String?)? textController12Validator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel2;
  // Model for Constitutional component.
  late ConstitutionalModel constitutionalModel1;
  // Model for Constitutional component.
  late ConstitutionalModel constitutionalModel2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode13;
  TextEditingController? textController13;
  String? Function(BuildContext, String?)? textController13Validator;
  // Model for Eyes component.
  late EyesModel eyesModel1;
  // Model for Eyes component.
  late EyesModel eyesModel2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode14;
  TextEditingController? textController14;
  String? Function(BuildContext, String?)? textController14Validator;
  // Model for ENTMounth component.
  late ENTMounthModel eNTMounthModel1;
  // Model for ENTMounth component.
  late ENTMounthModel eNTMounthModel2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode15;
  TextEditingController? textController15;
  String? Function(BuildContext, String?)? textController15Validator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel3;

  @override
  void initState(BuildContext context) {
    buttonAIgenerateModel = createModel(context, () => ButtonAIgenerateModel());
    datePickerModel1 = createModel(context, () => DatePickerModel());
    timePickerModel1 = createModel(context, () => TimePickerModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    datePickerModel2 = createModel(context, () => DatePickerModel());
    timePickerModel2 = createModel(context, () => TimePickerModel());
    bottonPrimaryModel1 = createModel(context, () => BottonPrimaryModel());
    gaModel1 = createModel(context, () => GaModel());
    gaModel2 = createModel(context, () => GaModel());
    gaModel3 = createModel(context, () => GaModel());
    heentModel1 = createModel(context, () => HeentModel());
    heentModel2 = createModel(context, () => HeentModel());
    heentModel3 = createModel(context, () => HeentModel());
    heartModel1 = createModel(context, () => HeartModel());
    heartModel2 = createModel(context, () => HeartModel());
    heartModel3 = createModel(context, () => HeartModel());
    chestModel1 = createModel(context, () => ChestModel());
    chestModel2 = createModel(context, () => ChestModel());
    chestModel3 = createModel(context, () => ChestModel());
    abdomenModel1 = createModel(context, () => AbdomenModel());
    abdomenModel2 = createModel(context, () => AbdomenModel());
    abdomenModel3 = createModel(context, () => AbdomenModel());
    prModel1 = createModel(context, () => PrModel());
    prModel2 = createModel(context, () => PrModel());
    prModel3 = createModel(context, () => PrModel());
    pvModel1 = createModel(context, () => PvModel());
    pvModel2 = createModel(context, () => PvModel());
    pvModel3 = createModel(context, () => PvModel());
    genitaliaModel1 = createModel(context, () => GenitaliaModel());
    genitaliaModel2 = createModel(context, () => GenitaliaModel());
    genitaliaModel3 = createModel(context, () => GenitaliaModel());
    neurologicalModel1 = createModel(context, () => NeurologicalModel());
    neurologicalModel2 = createModel(context, () => NeurologicalModel());
    neurologicalModel3 = createModel(context, () => NeurologicalModel());
    extremitiesModel1 = createModel(context, () => ExtremitiesModel());
    extremitiesModel2 = createModel(context, () => ExtremitiesModel());
    extremitiesModel3 = createModel(context, () => ExtremitiesModel());
    bottonPrimaryModel2 = createModel(context, () => BottonPrimaryModel());
    constitutionalModel1 = createModel(context, () => ConstitutionalModel());
    constitutionalModel2 = createModel(context, () => ConstitutionalModel());
    eyesModel1 = createModel(context, () => EyesModel());
    eyesModel2 = createModel(context, () => EyesModel());
    eNTMounthModel1 = createModel(context, () => ENTMounthModel());
    eNTMounthModel2 = createModel(context, () => ENTMounthModel());
    bottonPrimaryModel3 = createModel(context, () => BottonPrimaryModel());
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
    textFieldFocusNode1?.dispose();

    bottonPrimaryModel1.dispose();
    gaModel1.dispose();
    gaModel2.dispose();
    gaModel3.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    heentModel1.dispose();
    heentModel2.dispose();
    heentModel3.dispose();
    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    heartModel1.dispose();
    heartModel2.dispose();
    heartModel3.dispose();
    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    chestModel1.dispose();
    chestModel2.dispose();
    chestModel3.dispose();
    textFieldFocusNode5?.dispose();
    textController5?.dispose();

    abdomenModel1.dispose();
    abdomenModel2.dispose();
    abdomenModel3.dispose();
    textFieldFocusNode6?.dispose();
    textController6?.dispose();

    prModel1.dispose();
    prModel2.dispose();
    prModel3.dispose();
    textFieldFocusNode7?.dispose();
    textController7?.dispose();

    pvModel1.dispose();
    pvModel2.dispose();
    pvModel3.dispose();
    textFieldFocusNode8?.dispose();
    textController8?.dispose();

    genitaliaModel1.dispose();
    genitaliaModel2.dispose();
    genitaliaModel3.dispose();
    textFieldFocusNode9?.dispose();
    textController9?.dispose();

    neurologicalModel1.dispose();
    neurologicalModel2.dispose();
    neurologicalModel3.dispose();
    textFieldFocusNode10?.dispose();
    textController10?.dispose();

    extremitiesModel1.dispose();
    extremitiesModel2.dispose();
    extremitiesModel3.dispose();
    textFieldFocusNode11?.dispose();
    textController11?.dispose();

    textFieldFocusNode12?.dispose();
    textController12?.dispose();

    bottonPrimaryModel2.dispose();
    constitutionalModel1.dispose();
    constitutionalModel2.dispose();
    textFieldFocusNode13?.dispose();
    textController13?.dispose();

    eyesModel1.dispose();
    eyesModel2.dispose();
    textFieldFocusNode14?.dispose();
    textController14?.dispose();

    eNTMounthModel1.dispose();
    eNTMounthModel2.dispose();
    textFieldFocusNode15?.dispose();
    textController15?.dispose();

    bottonPrimaryModel3.dispose();
  }
}
