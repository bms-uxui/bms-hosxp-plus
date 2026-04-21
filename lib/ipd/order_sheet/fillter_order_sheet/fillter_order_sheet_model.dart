import '/dsign_system/check_box_style/check_box/check_box_widget.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'fillter_order_sheet_widget.dart' show FillterOrderSheetWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FillterOrderSheetModel extends FlutterFlowModel<FillterOrderSheetWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;
  // Model for CheckBox component.
  late CheckBoxModel checkBoxModel;

  @override
  void initState(BuildContext context) {
    checkBoxModel = createModel(context, () => CheckBoxModel());
  }

  @override
  void dispose() {
    checkBoxModel.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
