import '/dsign_system/button_styles/botton_primary1/botton_primary1_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/drugand_service/buttonsheet_re_med/buttonsheet_re_med_widget.dart';
import '/er/drugand_service/item_drug_e_r/item_drug_e_r_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import '/ipd/drugand_service/item_service/item_service_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'drug_srevice_e_r_view_widget.dart' show DrugSreviceERViewWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DrugSreviceERViewModel extends FlutterFlowModel<DrugSreviceERViewWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for Item_Drugallergy component.
  late ItemDrugallergyModel itemDrugallergyModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for Item_drugER component.
  late ItemDrugERModel itemDrugERModel1;
  // Model for Item_drugER component.
  late ItemDrugERModel itemDrugERModel2;
  // Model for Item_Service component.
  late ItemServiceModel itemServiceModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    itemDrugallergyModel = createModel(context, () => ItemDrugallergyModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    bottonPrimary1Model = createModel(context, () => BottonPrimary1Model());
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    itemDrugERModel1 = createModel(context, () => ItemDrugERModel());
    itemDrugERModel2 = createModel(context, () => ItemDrugERModel());
    itemServiceModel = createModel(context, () => ItemServiceModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    expandableExpandableController.dispose();
    iconButtonTertiaryModel1.dispose();
    itemDrugallergyModel.dispose();
    iconButtonTertiaryModel2.dispose();
    bottonPrimary1Model.dispose();
    iconButtonPrimaryModel.dispose();
    itemDrugERModel1.dispose();
    itemDrugERModel2.dispose();
    itemServiceModel.dispose();
  }
}
