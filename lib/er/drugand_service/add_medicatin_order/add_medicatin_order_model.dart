import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/count_controller/count_controller_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/er/drugand_service/buttonsheet_frequency/buttonsheet_frequency_widget.dart';
import '/er/drugand_service/buttonsheet_language/buttonsheet_language_widget.dart';
import '/er/drugand_service/buttonsheet_med/buttonsheet_med_widget.dart';
import '/er/drugand_service/buttonsheet_route_medication/buttonsheet_route_medication_widget.dart';
import '/er/drugand_service/buttonsheet_time_coe/buttonsheet_time_coe_widget.dart';
import '/er/drugand_service/buttonsheet_unit/buttonsheet_unit_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_medicatin_order_widget.dart' show AddMedicatinOrderWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddMedicatinOrderModel extends FlutterFlowModel<AddMedicatinOrderWidget> {
  ///  Local state fields for this page.

  int? mode = 2;

  ///  State fields for stateful widgets in this page.

  // Model for Item_Drugallergy component.
  late ItemDrugallergyModel itemDrugallergyModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for CountController component.
  late CountControllerModel countControllerModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // Model for Dropdown component.
  late DropdownModel dropdownModel5;
  // Model for Dropdown component.
  late DropdownModel dropdownModel6;
  // Model for CountController component.
  late CountControllerModel countControllerModel2;
  // Model for CountController component.
  late CountControllerModel countControllerModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel7;
  // Model for Dropdown component.
  late DropdownModel dropdownModel8;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    itemDrugallergyModel = createModel(context, () => ItemDrugallergyModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    countControllerModel1 = createModel(context, () => CountControllerModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    dropdownModel6 = createModel(context, () => DropdownModel());
    countControllerModel2 = createModel(context, () => CountControllerModel());
    countControllerModel3 = createModel(context, () => CountControllerModel());
    dropdownModel7 = createModel(context, () => DropdownModel());
    dropdownModel8 = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    itemDrugallergyModel.dispose();
    dropdownModel1.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    dropdownModel2.dispose();
    countControllerModel1.dispose();
    dropdownModel3.dispose();
    dropdownModel4.dispose();
    dropdownModel5.dispose();
    dropdownModel6.dispose();
    countControllerModel2.dispose();
    countControllerModel3.dispose();
    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    dropdownModel7.dispose();
    dropdownModel8.dispose();
    bottonPrimaryModel.dispose();
  }
}
