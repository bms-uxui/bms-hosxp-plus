import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'add_treatmentsummary_widget.dart' show AddTreatmentsummaryWidget;
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddTreatmentsummaryModel
    extends FlutterFlowModel<AddTreatmentsummaryWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Dropdown component.
  late DropdownModel dropdownModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    dropdownModel = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    dropdownModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    bottonPrimaryModel.dispose();
  }
}
