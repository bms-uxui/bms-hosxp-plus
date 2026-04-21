import '/dsign_system/from_field/count_controller/count_controller_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/buttonsheet_levelof_consciousness/buttonsheet_levelof_consciousness_widget.dart';
import '/ipd/vitalsign/buttonsheet_typeofsymptoms/buttonsheet_typeofsymptoms_widget.dart';
import 'dart:ui';
import 'form_data_widget.dart' show FormDataWidget;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FormDataModel extends FlutterFlowModel<FormDataWidget> {
  ///  State fields for stateful widgets in this component.

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
  String? Function(BuildContext, String?)? textController3Validator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for CountController component.
  late CountControllerModel countControllerModel1;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // Model for CountController component.
  late CountControllerModel countControllerModel2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode5;
  TextEditingController? textController5;
  String? Function(BuildContext, String?)? textController5Validator;

  @override
  void initState(BuildContext context) {
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    countControllerModel1 = createModel(context, () => CountControllerModel());
    countControllerModel2 = createModel(context, () => CountControllerModel());
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    dropdownModel1.dispose();
    dropdownModel2.dispose();
    countControllerModel1.dispose();
    textFieldFocusNode4?.dispose();
    textController4?.dispose();

    countControllerModel2.dispose();
    textFieldFocusNode5?.dispose();
    textController5?.dispose();
  }
}
