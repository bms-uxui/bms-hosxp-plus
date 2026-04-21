import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/diagnosis/item_diagnosis_i_c_d10/item_diagnosis_i_c_d10_widget.dart';
import '/ipd/diagnosis/item_diagnosis_i_c_d9_c_m/item_diagnosis_i_c_d9_c_m_widget.dart';
import '/ipd/diagnosis/item_diagnosis_text/item_diagnosis_text_widget.dart';
import 'dart:ui';
import 'diag_e_r_view_widget.dart' show DiagERViewWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DiagERViewModel extends FlutterFlowModel<DiagERViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel1;
  // Model for Item_DiagnosisICD10 component.
  late ItemDiagnosisICD10Model itemDiagnosisICD10Model;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel2;
  // Model for Item_DiagnosisICD9CM component.
  late ItemDiagnosisICD9CMModel itemDiagnosisICD9CMModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel3;
  // Model for Item_DiagnosisText component.
  late ItemDiagnosisTextModel itemDiagnosisTextModel1;
  // Model for Item_DiagnosisText component.
  late ItemDiagnosisTextModel itemDiagnosisTextModel2;

  @override
  void initState(BuildContext context) {
    iconButtonPrimaryModel1 =
        createModel(context, () => IconButtonPrimaryModel());
    itemDiagnosisICD10Model =
        createModel(context, () => ItemDiagnosisICD10Model());
    iconButtonPrimaryModel2 =
        createModel(context, () => IconButtonPrimaryModel());
    itemDiagnosisICD9CMModel =
        createModel(context, () => ItemDiagnosisICD9CMModel());
    iconButtonPrimaryModel3 =
        createModel(context, () => IconButtonPrimaryModel());
    itemDiagnosisTextModel1 =
        createModel(context, () => ItemDiagnosisTextModel());
    itemDiagnosisTextModel2 =
        createModel(context, () => ItemDiagnosisTextModel());
  }

  @override
  void dispose() {
    iconButtonPrimaryModel1.dispose();
    itemDiagnosisICD10Model.dispose();
    iconButtonPrimaryModel2.dispose();
    itemDiagnosisICD9CMModel.dispose();
    iconButtonPrimaryModel3.dispose();
    itemDiagnosisTextModel1.dispose();
    itemDiagnosisTextModel2.dispose();
  }
}
