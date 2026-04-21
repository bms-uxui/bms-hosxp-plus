import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/item_list_tertiary/item_list_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_nursingrecords_type_widget.dart'
    show ButtonsheetNursingrecordsTypeWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetNursingrecordsTypeModel
    extends FlutterFlowModel<ButtonsheetNursingrecordsTypeWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel1;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel2;
  // Model for Item_list_Tertiary component.
  late ItemListTertiaryModel itemListTertiaryModel3;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    itemListTertiaryModel1 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel2 =
        createModel(context, () => ItemListTertiaryModel());
    itemListTertiaryModel3 =
        createModel(context, () => ItemListTertiaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    itemListTertiaryModel1.dispose();
    itemListTertiaryModel2.dispose();
    itemListTertiaryModel3.dispose();
  }
}
