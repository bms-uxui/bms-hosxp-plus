import '/dsign_system/button_styles/botton_primary1/botton_primary1_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/not_data/not_data_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/drugand_service/item_drug/item_drug_widget.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import 'dart:ui';
import 'drunglist_view_widget.dart' show DrunglistViewWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DrunglistViewModel extends FlutterFlowModel<DrunglistViewWidget> {
  ///  Local state fields for this component.

  bool buttonMedOder = true;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for Item_Drugallergy component.
  late ItemDrugallergyModel itemDrugallergyModel1;
  // Model for Item_Drugallergy component.
  late ItemDrugallergyModel itemDrugallergyModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model;
  // Model for Item_drug component.
  late ItemDrugModel itemDrugModel1;
  // Model for Item_drug component.
  late ItemDrugModel itemDrugModel2;
  // Model for Not_Data component.
  late NotDataModel notDataModel;
  // Model for Item_drug component.
  late ItemDrugModel itemDrugModel3;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    itemDrugallergyModel1 = createModel(context, () => ItemDrugallergyModel());
    itemDrugallergyModel2 = createModel(context, () => ItemDrugallergyModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    bottonPrimary1Model = createModel(context, () => BottonPrimary1Model());
    itemDrugModel1 = createModel(context, () => ItemDrugModel());
    itemDrugModel2 = createModel(context, () => ItemDrugModel());
    notDataModel = createModel(context, () => NotDataModel());
    itemDrugModel3 = createModel(context, () => ItemDrugModel());
  }

  @override
  void dispose() {
    expandableExpandableController.dispose();
    iconButtonTertiaryModel1.dispose();
    itemDrugallergyModel1.dispose();
    itemDrugallergyModel2.dispose();
    iconButtonTertiaryModel2.dispose();
    bottonPrimary1Model.dispose();
    itemDrugModel1.dispose();
    itemDrugModel2.dispose();
    notDataModel.dispose();
    itemDrugModel3.dispose();
  }
}
