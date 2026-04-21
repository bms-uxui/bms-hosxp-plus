import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_primary/item_list_primary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_medicalcertificate_widget.dart'
    show ButtonsheetMedicalcertificateWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetMedicalcertificateModel
    extends FlutterFlowModel<ButtonsheetMedicalcertificateWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel1;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel2;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel3;
  // Model for Item_list_Primary component.
  late ItemListPrimaryModel itemListPrimaryModel4;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    searchBarSecondaryModel =
        createModel(context, () => SearchBarSecondaryModel());
    itemListPrimaryModel1 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel2 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel3 = createModel(context, () => ItemListPrimaryModel());
    itemListPrimaryModel4 = createModel(context, () => ItemListPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    searchBarSecondaryModel.dispose();
    itemListPrimaryModel1.dispose();
    itemListPrimaryModel2.dispose();
    itemListPrimaryModel3.dispose();
    itemListPrimaryModel4.dispose();
  }
}
