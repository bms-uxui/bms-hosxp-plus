import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'item_nurw_records_widget.dart' show ItemNurwRecordsWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemNurwRecordsModel extends FlutterFlowModel<ItemNurwRecordsWidget> {
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
