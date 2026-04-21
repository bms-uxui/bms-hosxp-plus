import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/drugand_service/tag_number_pills/tag_number_pills_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'item_drug_widget.dart' show ItemDrugWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemDrugModel extends FlutterFlowModel<ItemDrugWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Tag_Number_pills component.
  late TagNumberPillsModel tagNumberPillsModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    tagNumberPillsModel = createModel(context, () => TagNumberPillsModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    tagNumberPillsModel.dispose();
  }
}
