import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'ask_conslult_detail3_widget.dart' show AskConslultDetail3Widget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AskConslultDetail3Model
    extends FlutterFlowModel<AskConslultDetail3Widget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    dateandTimeRecordeModel =
        createModel(context, () => DateandTimeRecordeModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    dateandTimeRecordeModel.dispose();
  }
}
