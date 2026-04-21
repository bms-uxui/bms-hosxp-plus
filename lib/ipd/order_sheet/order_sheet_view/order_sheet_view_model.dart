import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/order_sheet/fillter_order_sheet/fillter_order_sheet_widget.dart';
import '/ipd/order_sheet/item_examination/item_examination_widget.dart';
import '/ipd/order_sheet/item_home_medication/item_home_medication_widget.dart';
import '/ipd/order_sheet/item_medication/item_medication_widget.dart';
import '/ipd/order_sheet/item_off/item_off_widget.dart';
import '/ipd/order_sheet/item_operation/item_operation_widget.dart';
import '/ipd/order_sheet/item_other/item_other_widget.dart';
import '/ipd/order_sheet/item_s_o_a_p_r_n/item_s_o_a_p_r_n_widget.dart';
import 'dart:ui';
import 'order_sheet_view_widget.dart' show OrderSheetViewWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrderSheetViewModel extends FlutterFlowModel<OrderSheetViewWidget> {
  ///  Local state fields for this component.

  bool buttonadd = true;

  ///  State fields for stateful widgets in this component.

  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Item_SOAPRN component.
  late ItemSOAPRNModel itemSOAPRNModel1;
  // Model for Item_Medication component.
  late ItemMedicationModel itemMedicationModel;
  // Model for Item_Operation component.
  late ItemOperationModel itemOperationModel;
  // Model for Item_Examination component.
  late ItemExaminationModel itemExaminationModel;
  // Model for Item_Off component.
  late ItemOffModel itemOffModel;
  // Model for Item_HomeMedication component.
  late ItemHomeMedicationModel itemHomeMedicationModel;
  // Model for Item_Other component.
  late ItemOtherModel itemOtherModel;
  // Model for Item_SOAPRN component.
  late ItemSOAPRNModel itemSOAPRNModel2;

  @override
  void initState(BuildContext context) {
    buttonFillterModel = createModel(context, () => ButtonFillterModel());
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    itemSOAPRNModel1 = createModel(context, () => ItemSOAPRNModel());
    itemMedicationModel = createModel(context, () => ItemMedicationModel());
    itemOperationModel = createModel(context, () => ItemOperationModel());
    itemExaminationModel = createModel(context, () => ItemExaminationModel());
    itemOffModel = createModel(context, () => ItemOffModel());
    itemHomeMedicationModel =
        createModel(context, () => ItemHomeMedicationModel());
    itemOtherModel = createModel(context, () => ItemOtherModel());
    itemSOAPRNModel2 = createModel(context, () => ItemSOAPRNModel());
  }

  @override
  void dispose() {
    buttonFillterModel.dispose();
    iconButtonPrimaryModel.dispose();
    expandableExpandableController.dispose();
    iconButtonTertiaryModel.dispose();
    itemSOAPRNModel1.dispose();
    itemMedicationModel.dispose();
    itemOperationModel.dispose();
    itemExaminationModel.dispose();
    itemOffModel.dispose();
    itemHomeMedicationModel.dispose();
    itemOtherModel.dispose();
    itemSOAPRNModel2.dispose();
  }
}
