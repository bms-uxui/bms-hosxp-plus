import '/consult/ask_conslult/ask_conslult_widget.dart';
import '/consult/ask_conslult_detail/ask_conslult_detail_widget.dart';
import '/consult/ask_conslult_detail3/ask_conslult_detail3_widget.dart';
import '/consult/fillter_consult/fillter_consult_widget.dart';
import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'consult_list_widget.dart' show ConsultListWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ConsultListModel extends FlutterFlowModel<ConsultListWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

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
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel6;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel7;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel8;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel9;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel10;

  @override
  void initState(BuildContext context) {
    buttonFillterModel = createModel(context, () => ButtonFillterModel());
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
    dateandTimeRecordeModel6 =
        createModel(context, () => DateandTimeRecordeModel());
    dateandTimeRecordeModel7 =
        createModel(context, () => DateandTimeRecordeModel());
    dateandTimeRecordeModel8 =
        createModel(context, () => DateandTimeRecordeModel());
    dateandTimeRecordeModel9 =
        createModel(context, () => DateandTimeRecordeModel());
    dateandTimeRecordeModel10 =
        createModel(context, () => DateandTimeRecordeModel());
  }

  @override
  void dispose() {
    buttonFillterModel.dispose();
    tabBarController?.dispose();
    dateandTimeRecordeModel1.dispose();
    dateandTimeRecordeModel2.dispose();
    dateandTimeRecordeModel3.dispose();
    dateandTimeRecordeModel4.dispose();
    dateandTimeRecordeModel5.dispose();
    dateandTimeRecordeModel6.dispose();
    dateandTimeRecordeModel7.dispose();
    dateandTimeRecordeModel8.dispose();
    dateandTimeRecordeModel9.dispose();
    dateandTimeRecordeModel10.dispose();
  }
}
