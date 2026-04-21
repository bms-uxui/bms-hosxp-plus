import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'fillter_labhistory_widget.dart' show FillterLabhistoryWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FillterLabhistoryModel extends FlutterFlowModel<FillterLabhistoryWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController1;
  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Additional helper methods.
  String? get radioButtonValue1 => radioButtonValueController1?.value;
  String? get radioButtonValue2 => radioButtonValueController2?.value;
}
