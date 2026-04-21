import '/dsign_system/button_styles/botton_primary1/botton_primary1_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/admit/item_chronic_disease/item_chronic_disease_widget.dart';
import '/ipd/admit/item_congenital_disease/item_congenital_disease_widget.dart';
import '/ipd/admit/item_surgicalhistory/item_surgicalhistory_widget.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import 'dart:ui';
import 'admitpage_view_widget.dart' show AdmitpageViewWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdmitpageViewModel extends FlutterFlowModel<AdmitpageViewWidget> {
  ///  Local state fields for this component.

  bool buttonReport = true;

  ///  State fields for stateful widgets in this component.

  // Model for BottonPrimary1 component.
  late BottonPrimary1Model bottonPrimary1Model;
  // Model for Item_ChronicDisease component.
  late ItemChronicDiseaseModel itemChronicDiseaseModel;
  // Model for Item_CongenitalDisease component.
  late ItemCongenitalDiseaseModel itemCongenitalDiseaseModel;
  // Model for Item_Surgicalhistory component.
  late ItemSurgicalhistoryModel itemSurgicalhistoryModel;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Item_Drugallergy component.
  late ItemDrugallergyModel itemDrugallergyModel1;
  // Model for Item_Drugallergy component.
  late ItemDrugallergyModel itemDrugallergyModel2;

  @override
  void initState(BuildContext context) {
    bottonPrimary1Model = createModel(context, () => BottonPrimary1Model());
    itemChronicDiseaseModel =
        createModel(context, () => ItemChronicDiseaseModel());
    itemCongenitalDiseaseModel =
        createModel(context, () => ItemCongenitalDiseaseModel());
    itemSurgicalhistoryModel =
        createModel(context, () => ItemSurgicalhistoryModel());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    itemDrugallergyModel1 = createModel(context, () => ItemDrugallergyModel());
    itemDrugallergyModel2 = createModel(context, () => ItemDrugallergyModel());
  }

  @override
  void dispose() {
    bottonPrimary1Model.dispose();
    itemChronicDiseaseModel.dispose();
    itemCongenitalDiseaseModel.dispose();
    itemSurgicalhistoryModel.dispose();
    expandableExpandableController.dispose();
    iconButtonTertiaryModel.dispose();
    itemDrugallergyModel1.dispose();
    itemDrugallergyModel2.dispose();
  }
}
