import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/consult/buttonsheet_doctor/buttonsheet_doctor_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'buttonsheet_offorder_widget.dart' show ButtonsheetOfforderWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetOfforderModel
    extends FlutterFlowModel<ButtonsheetOfforderWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // Model for Dropdown component.
  late DropdownModel dropdownModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    dropdownModel = createModel(context, () => DropdownModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    dropdownModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
