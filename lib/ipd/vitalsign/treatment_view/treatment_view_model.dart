import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/fillter_treatment_i_p_d/fillter_treatment_i_p_d_widget.dart';
import '/ipd/vitalsign/item_treatment/item_treatment_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'treatment_view_widget.dart' show TreatmentViewWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TreatmentViewModel extends FlutterFlowModel<TreatmentViewWidget> {
  ///  Local state fields for this component.

  bool buttonaddTreatment = true;

  ///  State fields for stateful widgets in this component.

  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for Item_Treatment component.
  late ItemTreatmentModel itemTreatmentModel1;
  // Model for Item_Treatment component.
  late ItemTreatmentModel itemTreatmentModel2;

  @override
  void initState(BuildContext context) {
    buttonFillterModel = createModel(context, () => ButtonFillterModel());
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    itemTreatmentModel1 = createModel(context, () => ItemTreatmentModel());
    itemTreatmentModel2 = createModel(context, () => ItemTreatmentModel());
  }

  @override
  void dispose() {
    buttonFillterModel.dispose();
    iconButtonPrimaryModel.dispose();
    itemTreatmentModel1.dispose();
    itemTreatmentModel2.dispose();
  }
}
