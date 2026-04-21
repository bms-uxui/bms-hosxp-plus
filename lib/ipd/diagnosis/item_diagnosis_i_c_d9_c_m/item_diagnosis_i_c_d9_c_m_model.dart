import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'item_diagnosis_i_c_d9_c_m_widget.dart' show ItemDiagnosisICD9CMWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemDiagnosisICD9CMModel
    extends FlutterFlowModel<ItemDiagnosisICD9CMWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;

  @override
  void initState(BuildContext context) {
    dateandTimeRecordeModel =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
  }

  @override
  void dispose() {
    dateandTimeRecordeModel.dispose();
    iconButtonTertiaryModel.dispose();
  }
}
