import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/setting/about_app/about_app_widget.dart';
import '/setting/connection/connection_widget.dart';
import '/setting/log_out/log_out_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'setting_widget.dart' show SettingWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingModel extends FlutterFlowModel<SettingWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel3;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel4;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel5;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel3 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel4 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel5 =
        createModel(context, () => IconButtonTertiaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel1.dispose();
    iconButtonTertiaryModel2.dispose();
    iconButtonTertiaryModel3.dispose();
    iconButtonTertiaryModel4.dispose();
    iconButtonTertiaryModel5.dispose();
  }
}
