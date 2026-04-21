import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/date_recorde/date_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/item_practices/item_practices_widget.dart';
import 'dart:ui';
import 'item_appiontment_widget.dart' show ItemAppiontmentWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemAppiontmentModel extends FlutterFlowModel<ItemAppiontmentWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for DateRecorde component.
  late DateRecordeModel dateRecordeModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Item_Practices component.
  late ItemPracticesModel itemPracticesModel;

  @override
  void initState(BuildContext context) {
    dateRecordeModel = createModel(context, () => DateRecordeModel());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    itemPracticesModel = createModel(context, () => ItemPracticesModel());
  }

  @override
  void dispose() {
    dateRecordeModel.dispose();
    iconButtonTertiaryModel.dispose();
    itemPracticesModel.dispose();
  }
}
