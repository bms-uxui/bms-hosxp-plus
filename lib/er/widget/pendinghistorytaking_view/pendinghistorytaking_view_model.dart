import '/dsign_system/icon_style/icon_female/icon_female_widget.dart';
import '/dsign_system/icon_style/icon_male/icon_male_widget.dart';
import '/er/item_patient_e_r/item_patient_e_r_widget.dart';
import '/er/widget/emergency_e_s_i/emergency_e_s_i_widget.dart';
import '/er/widget/resuscitation_e_s_i/resuscitation_e_s_i_widget.dart';
import '/er/widget/semi_urgent_e_s_i/semi_urgent_e_s_i_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'pendinghistorytaking_view_widget.dart'
    show PendinghistorytakingViewWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PendinghistorytakingViewModel
    extends FlutterFlowModel<PendinghistorytakingViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Item_PatientER component.
  late ItemPatientERModel itemPatientERModel1;
  // Model for Item_PatientER component.
  late ItemPatientERModel itemPatientERModel2;
  // Model for Item_PatientER component.
  late ItemPatientERModel itemPatientERModel3;

  @override
  void initState(BuildContext context) {
    itemPatientERModel1 = createModel(context, () => ItemPatientERModel());
    itemPatientERModel2 = createModel(context, () => ItemPatientERModel());
    itemPatientERModel3 = createModel(context, () => ItemPatientERModel());
  }

  @override
  void dispose() {
    itemPatientERModel1.dispose();
    itemPatientERModel2.dispose();
    itemPatientERModel3.dispose();
  }
}
