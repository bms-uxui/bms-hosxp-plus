import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/er/accident/buttonsheet_bleeding_control/buttonsheet_bleeding_control_widget.dart';
import '/er/accident/buttonsheet_i_v_fluid/buttonsheet_i_v_fluid_widget.dart';
import '/er/accident/buttonsheet_immobilize_c_spine/buttonsheet_immobilize_c_spine_widget.dart';
import '/er/accident/buttonsheet_respiratory_care/buttonsheet_respiratory_care_widget.dart';
import '/er/accident/buttonsheet_splint/buttonsheet_splint_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_accident_basic_care_widget.dart' show AddAccidentBasicCareWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddAccidentBasicCareModel
    extends FlutterFlowModel<AddAccidentBasicCareWidget> {
  ///  Local state fields for this page.

  String? seatBelt;

  String? helmet;

  String? alcohol;

  String? drugs;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
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
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    dropdownModel1.dispose();
    dropdownModel2.dispose();
    dropdownModel3.dispose();
    dropdownModel4.dispose();
    dropdownModel5.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    bottonPrimaryModel.dispose();
  }
}
