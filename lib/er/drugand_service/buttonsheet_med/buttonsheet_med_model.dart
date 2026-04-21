import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_tertiary/item_list_tertiary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_med_widget.dart' show ButtonsheetMedWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetMedModel extends FlutterFlowModel<ButtonsheetMedWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel1;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel1;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel2;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel3;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel4;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel5;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel6;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel7;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel2;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel8;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel9;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel10;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel11;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel12;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    searchBarSecondaryModel1 =
        createModel(context, () => SearchBarSecondaryModel());
    itemListTertiaryModel1 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel2 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel3 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel4 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel5 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel6 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel7 =
        createModel(context, () => ItemListTertiaryModel());
    searchBarSecondaryModel2 =
        createModel(context, () => SearchBarSecondaryModel());
    itemListTertiaryModel8 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel9 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel10 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel11 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel12 =
        createModel(context, () => ItemListTertiaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    tabBarController?.dispose();
    searchBarSecondaryModel1.dispose();
    itemListTertiaryModel1.dispose();
    itemListTertiaryModel2.dispose();
    itemListTertiaryModel3.dispose();
    itemListTertiaryModel4.dispose();
    itemListTertiaryModel5.dispose();
    itemListTertiaryModel6.dispose();
    itemListTertiaryModel7.dispose();
    searchBarSecondaryModel2.dispose();
    itemListTertiaryModel8.dispose();
    itemListTertiaryModel9.dispose();
    itemListTertiaryModel10.dispose();
    itemListTertiaryModel11.dispose();
    itemListTertiaryModel12.dispose();
  }
}
