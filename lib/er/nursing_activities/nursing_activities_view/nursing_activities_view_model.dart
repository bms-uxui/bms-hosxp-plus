import '/dsign_system/button_styles/botton_primary1/botton_primary1_widget.dart';
import '/er/nursing_activities/buttonsheet_receiveorders_lab/buttonsheet_receiveorders_lab_widget.dart';
import '/er/nursing_activities/buttonsheet_receiveorders_medicine_medicalsupplies/buttonsheet_receiveorders_medicine_medicalsupplies_widget.dart';
import '/er/nursing_activities/buttonsheet_receiveorders_treatment/buttonsheet_receiveorders_treatment_widget.dart';
import '/er/nursing_activities/buttonsheet_receiveorders_treatment_copy/buttonsheet_receiveorders_treatment_copy_widget.dart';
import '/er/nursing_activities/buttonsheet_receiveorders_x_ray/buttonsheet_receiveorders_x_ray_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'nursing_activities_view_widget.dart' show NursingActivitiesViewWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NursingActivitiesViewModel
    extends FlutterFlowModel<NursingActivitiesViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model1;
  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model2;
  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model3;
  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model4;
  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model5;
  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model6;
  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model7;

  @override
  void initState(BuildContext context) {
    bottonPrimary1Model1 = createModel(context, () => BottonPrimary1Model());
    bottonPrimary1Model2 = createModel(context, () => BottonPrimary1Model());
    bottonPrimary1Model3 = createModel(context, () => BottonPrimary1Model());
    bottonPrimary1Model4 = createModel(context, () => BottonPrimary1Model());
    bottonPrimary1Model5 = createModel(context, () => BottonPrimary1Model());
    bottonPrimary1Model6 = createModel(context, () => BottonPrimary1Model());
    bottonPrimary1Model7 = createModel(context, () => BottonPrimary1Model());
  }

  @override
  void dispose() {
    bottonPrimary1Model1.dispose();
    bottonPrimary1Model2.dispose();
    bottonPrimary1Model3.dispose();
    bottonPrimary1Model4.dispose();
    bottonPrimary1Model5.dispose();
    bottonPrimary1Model6.dispose();
    bottonPrimary1Model7.dispose();
  }
}
