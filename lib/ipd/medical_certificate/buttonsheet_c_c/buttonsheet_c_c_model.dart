import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_primary/item_list_primary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_c_c_widget.dart' show ButtonsheetCCWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetCCModel extends FlutterFlowModel<ButtonsheetCCWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    searchBarSecondaryModel =
        createModel(context, () => SearchBarSecondaryModel());
    itemListPrimaryModel = createModel(context, () => ItemListPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    searchBarSecondaryModel.dispose();
    itemListPrimaryModel.dispose();
  }
}
