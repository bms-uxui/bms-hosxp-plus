import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'add_discharge_summary_widget.dart' show AddDischargeSummaryWidget;
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddDischargeSummaryModel
    extends FlutterFlowModel<AddDischargeSummaryWidget> {
  ///  State fields for stateful widgets in this component.

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
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    dropdownModel1.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    dropdownModel2.dispose();
    dropdownModel3.dispose();
    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    bottonPrimaryModel.dispose();
  }
}
