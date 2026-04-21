import '/consult/ask_conslult_detail/ask_conslult_detail_widget.dart';
import '/consult/ask_conslult_detail3/ask_conslult_detail3_widget.dart';
import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/consult/fillter_consult_patient/fillter_consult_patient_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'cousult_view_widget.dart' show CousultViewWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CousultViewModel extends FlutterFlowModel<CousultViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel1;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel2;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel3;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel4;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel5;

  @override
  void initState(BuildContext context) {
    buttonFillterModel = createModel(context, () => ButtonFillterModel());
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    dateandTimeRecordeModel1 =
        createModel(context, () => DateandTimeRecordeModel());
    dateandTimeRecordeModel2 =
        createModel(context, () => DateandTimeRecordeModel());
    dateandTimeRecordeModel3 =
        createModel(context, () => DateandTimeRecordeModel());
    dateandTimeRecordeModel4 =
        createModel(context, () => DateandTimeRecordeModel());
    dateandTimeRecordeModel5 =
        createModel(context, () => DateandTimeRecordeModel());
  }

  @override
  void dispose() {
    buttonFillterModel.dispose();
    iconButtonPrimaryModel.dispose();
    dateandTimeRecordeModel1.dispose();
    dateandTimeRecordeModel2.dispose();
    dateandTimeRecordeModel3.dispose();
    dateandTimeRecordeModel4.dispose();
    dateandTimeRecordeModel5.dispose();
  }
}
