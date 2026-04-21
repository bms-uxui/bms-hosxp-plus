import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/physical_examination/template_stroke/template_stroke_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'buttonsheet_samary_a_i_e_r_widget.dart'
    show ButtonsheetSamaryAIERWidget;
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class ButtonsheetSamaryAIERModel
    extends FlutterFlowModel<ButtonsheetSamaryAIERWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Template_Stroke component.
  late TemplateStrokeModel templateStrokeModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    templateStrokeModel = createModel(context, () => TemplateStrokeModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    templateStrokeModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
