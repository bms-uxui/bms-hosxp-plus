import '/dsign_system/date_recorde/date_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'item_lab_history_widget.dart' show ItemLabHistoryWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemLabHistoryModel extends FlutterFlowModel<ItemLabHistoryWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for DateRecorde component.
  late DateRecordeModel dateRecordeModel;

  @override
  void initState(BuildContext context) {
    dateRecordeModel = createModel(context, () => DateRecordeModel());
  }

  @override
  void dispose() {
    dateRecordeModel.dispose();
  }
}
