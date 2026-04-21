import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_primary/item_list_primary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_address_widget.dart' show ButtonsheetAddressWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetAddressModel
    extends FlutterFlowModel<ButtonsheetAddressWidget> {
  ///  Local state fields for this component.

  int? address = 1;

  String? province;

  String? district;

  String? subdistrict;

  String? postalCode;

  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel1;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel1;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel2;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel3;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel4;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel5;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel6;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel7;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel8;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel2;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel9;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel10;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel11;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel12;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel13;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel3;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel14;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel15;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel16;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel17;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel4;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel18;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    searchBarSecondaryModel1 =
        createModel(context, () => SearchBarSecondaryModel());
    itemListPrimaryModel1 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel2 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel3 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel4 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel5 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel6 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel7 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel8 = createModel(context, () => ItemListPrimaryModel());
    searchBarSecondaryModel2 =
        createModel(context, () => SearchBarSecondaryModel());
    itemListPrimaryModel9 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel10 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel11 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel12 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel13 = createModel(context, () => ItemListPrimaryModel());
    searchBarSecondaryModel3 =
        createModel(context, () => SearchBarSecondaryModel());
    itemListPrimaryModel14 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel15 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel16 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel17 = createModel(context, () => ItemListPrimaryModel());
    searchBarSecondaryModel4 =
        createModel(context, () => SearchBarSecondaryModel());
    itemListPrimaryModel18 = createModel(context, () => ItemListPrimaryModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    searchBarSecondaryModel1.dispose();
    itemListPrimaryModel1.dispose();
    itemListPrimaryModel2.dispose();
    itemListPrimaryModel3.dispose();
    itemListPrimaryModel4.dispose();
    itemListPrimaryModel5.dispose();
    itemListPrimaryModel6.dispose();
    itemListPrimaryModel7.dispose();
    itemListPrimaryModel8.dispose();
    searchBarSecondaryModel2.dispose();
    itemListPrimaryModel9.dispose();
    itemListPrimaryModel10.dispose();
    itemListPrimaryModel11.dispose();
    itemListPrimaryModel12.dispose();
    itemListPrimaryModel13.dispose();
    searchBarSecondaryModel3.dispose();
    itemListPrimaryModel14.dispose();
    itemListPrimaryModel15.dispose();
    itemListPrimaryModel16.dispose();
    itemListPrimaryModel17.dispose();
    searchBarSecondaryModel4.dispose();
    itemListPrimaryModel18.dispose();
    bottonPrimaryModel.dispose();
  }
}
