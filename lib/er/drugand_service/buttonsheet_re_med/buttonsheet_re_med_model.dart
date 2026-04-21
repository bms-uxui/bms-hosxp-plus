import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/drugand_service/item_drug_e_rremet/item_drug_e_rremet_widget.dart';
import '/er/drugand_service/item_med/item_med_widget.dart';
import '/er/drugand_service/not_durg/not_durg_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'buttonsheet_re_med_widget.dart' show ButtonsheetReMedWidget;
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetReMedModel extends FlutterFlowModel<ButtonsheetReMedWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for Item_Med component.
  late ItemMedModel itemMedModel1;
  // Model for Item_Med component.
  late ItemMedModel itemMedModel2;
  // Model for Item_Med component.
  late ItemMedModel itemMedModel3;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // Model for Item_drugERremet component.
  late ItemDrugERremetModel itemDrugERremetModel1;
  // Model for Item_drugERremet component.
  late ItemDrugERremetModel itemDrugERremetModel2;
  // Model for Item_drugERremet component.
  late ItemDrugERremetModel itemDrugERremetModel3;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue3;
  // State field(s) for Checkbox widget.
  bool? checkboxValue4;
  // Model for Item_drugERremet component.
  late ItemDrugERremetModel itemDrugERremetModel4;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel2;
  // State field(s) for Checkbox widget.
  bool? checkboxValue5;
  // State field(s) for Checkbox widget.
  bool? checkboxValue6;
  // Model for Item_drugERremet component.
  late ItemDrugERremetModel itemDrugERremetModel5;
  // Model for Item_drugERremet component.
  late ItemDrugERremetModel itemDrugERremetModel6;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel3;
  // Model for Not_durg component.
  late NotDurgModel notDurgModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    itemMedModel1 = createModel(context, () => ItemMedModel());
    itemMedModel2 = createModel(context, () => ItemMedModel());
    itemMedModel3 = createModel(context, () => ItemMedModel());
    itemDrugERremetModel1 = createModel(context, () => ItemDrugERremetModel());
    itemDrugERremetModel2 = createModel(context, () => ItemDrugERremetModel());
    itemDrugERremetModel3 = createModel(context, () => ItemDrugERremetModel());
    bottonPrimaryModel1 = createModel(context, () => BottonPrimaryModel());
    itemDrugERremetModel4 = createModel(context, () => ItemDrugERremetModel());
    bottonPrimaryModel2 = createModel(context, () => BottonPrimaryModel());
    itemDrugERremetModel5 = createModel(context, () => ItemDrugERremetModel());
    itemDrugERremetModel6 = createModel(context, () => ItemDrugERremetModel());
    bottonPrimaryModel3 = createModel(context, () => BottonPrimaryModel());
    notDurgModel = createModel(context, () => NotDurgModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel1.dispose();
    iconButtonTertiaryModel2.dispose();
    itemMedModel1.dispose();
    itemMedModel2.dispose();
    itemMedModel3.dispose();
    itemDrugERremetModel1.dispose();
    itemDrugERremetModel2.dispose();
    itemDrugERremetModel3.dispose();
    bottonPrimaryModel1.dispose();
    itemDrugERremetModel4.dispose();
    bottonPrimaryModel2.dispose();
    itemDrugERremetModel5.dispose();
    itemDrugERremetModel6.dispose();
    bottonPrimaryModel3.dispose();
    notDurgModel.dispose();
  }
}
