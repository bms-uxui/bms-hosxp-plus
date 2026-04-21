import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_tertiary/item_list_tertiary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_ordering_doctor_widget.dart'
    show ButtonsheetOrderingDoctorWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetOrderingDoctorModel
    extends FlutterFlowModel<ButtonsheetOrderingDoctorWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel;
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

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    searchBarSecondaryModel =
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
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    searchBarSecondaryModel.dispose();
    itemListTertiaryModel1.dispose();
    itemListTertiaryModel2.dispose();
    itemListTertiaryModel3.dispose();
    itemListTertiaryModel4.dispose();
    itemListTertiaryModel5.dispose();
  }
}
