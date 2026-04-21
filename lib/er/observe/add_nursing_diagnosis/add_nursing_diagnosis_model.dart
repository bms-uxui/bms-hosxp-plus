import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/er/observe/buttonsheet_nursing_diagnosis/buttonsheet_nursing_diagnosis_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_nursing_diagnosis_widget.dart' show AddNursingDiagnosisWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddNursingDiagnosisModel
    extends FlutterFlowModel<AddNursingDiagnosisWidget> {
  ///  Local state fields for this page.

  String? seatBelt;

  String? helmet;

  String? alcohol;

  String? drugs;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    dateandTimeRecordeModel1 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    dateandTimeRecordeModel2 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    iconButtonPrimaryModel.dispose();
    dateandTimeRecordeModel1.dispose();
    iconButtonTertiaryModel1.dispose();
    dateandTimeRecordeModel2.dispose();
    iconButtonTertiaryModel2.dispose();
    bottonPrimaryModel.dispose();
  }
}
