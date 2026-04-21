import '/dsign_system/icon_style/icon_female/icon_female_widget.dart';
import '/dsign_system/icon_style/icon_male/icon_male_widget.dart';
import '/er/item_patient_e_r/item_patient_e_r_widget.dart';
import '/er/widget/non_urgent_e_s_i/non_urgent_e_s_i_widget.dart';
import '/er/widget/semi_urgent_e_s_i/semi_urgent_e_s_i_widget.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'pendingdoctorvisit_view_widget.dart' show PendingdoctorvisitViewWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PendingdoctorvisitViewModel
    extends FlutterFlowModel<PendingdoctorvisitViewWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;
  // Model for Item_PatientER component.
  late ItemPatientERModel itemPatientERModel1;
  // Model for Item_PatientER component.
  late ItemPatientERModel itemPatientERModel2;

  @override
  void initState(BuildContext context) {
    itemPatientERModel1 = createModel(context, () => ItemPatientERModel());
    itemPatientERModel2 = createModel(context, () => ItemPatientERModel());
  }

  @override
  void dispose() {
    itemPatientERModel1.dispose();
    itemPatientERModel2.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
