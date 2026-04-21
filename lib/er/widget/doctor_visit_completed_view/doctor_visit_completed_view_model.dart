import '/dsign_system/not_data/not_data_widget.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'doctor_visit_completed_view_widget.dart'
    show DoctorVisitCompletedViewWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DoctorVisitCompletedViewModel
    extends FlutterFlowModel<DoctorVisitCompletedViewWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;
  // Model for Not_Data component.
  late NotDataModel notDataModel;

  @override
  void initState(BuildContext context) {
    notDataModel = createModel(context, () => NotDataModel());
  }

  @override
  void dispose() {
    notDataModel.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
