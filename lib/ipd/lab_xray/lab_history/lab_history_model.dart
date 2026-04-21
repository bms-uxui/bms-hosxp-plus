import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/lab_xray/item_lab_history/item_lab_history_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'lab_history_widget.dart' show LabHistoryWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LabHistoryModel extends FlutterFlowModel<LabHistoryWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel;
  // Model for Item_lab_history component.
  late ItemLabHistoryModel itemLabHistoryModel1;
  // Model for Item_lab_history component.
  late ItemLabHistoryModel itemLabHistoryModel2;
  // Model for Item_lab_history component.
  late ItemLabHistoryModel itemLabHistoryModel3;

  @override
  void initState(BuildContext context) {
    dateandTimeRecordeModel =
        createModel(context, () => DateandTimeRecordeModel());
    itemLabHistoryModel1 = createModel(context, () => ItemLabHistoryModel());
    itemLabHistoryModel2 = createModel(context, () => ItemLabHistoryModel());
    itemLabHistoryModel3 = createModel(context, () => ItemLabHistoryModel());
  }

  @override
  void dispose() {
    dateandTimeRecordeModel.dispose();
    itemLabHistoryModel1.dispose();
    itemLabHistoryModel2.dispose();
    itemLabHistoryModel3.dispose();
  }
}
