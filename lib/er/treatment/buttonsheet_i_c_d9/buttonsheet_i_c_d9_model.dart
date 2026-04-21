import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_secondary/item_list_secondary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_i_c_d9_widget.dart' show ButtonsheetICD9Widget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetICD9Model extends FlutterFlowModel<ButtonsheetICD9Widget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel;
  // Model for Item_list_Secondary component.
  late ItemListSecondaryModel itemListSecondaryModel1;
  // Model for Item_list_Secondary component.
  late ItemListSecondaryModel itemListSecondaryModel2;
  // Model for Item_list_Secondary component.
  late ItemListSecondaryModel itemListSecondaryModel3;
  // Model for Item_list_Secondary component.
  late ItemListSecondaryModel itemListSecondaryModel4;
  // Model for Item_list_Secondary component.
  late ItemListSecondaryModel itemListSecondaryModel5;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    searchBarSecondaryModel =
        createModel(context, () => SearchBarSecondaryModel());
    itemListSecondaryModel1 =
        createModel(context, () => ItemListSecondaryModel());
    itemListSecondaryModel2 =
        createModel(context, () => ItemListSecondaryModel());
    itemListSecondaryModel3 =
        createModel(context, () => ItemListSecondaryModel());
    itemListSecondaryModel4 =
        createModel(context, () => ItemListSecondaryModel());
    itemListSecondaryModel5 =
        createModel(context, () => ItemListSecondaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    searchBarSecondaryModel.dispose();
    itemListSecondaryModel1.dispose();
    itemListSecondaryModel2.dispose();
    itemListSecondaryModel3.dispose();
    itemListSecondaryModel4.dispose();
    itemListSecondaryModel5.dispose();
  }
}
