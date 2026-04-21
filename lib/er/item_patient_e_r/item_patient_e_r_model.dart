import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'item_patient_e_r_widget.dart' show ItemPatientERWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemPatientERModel extends FlutterFlowModel<ItemPatientERWidget> {
  ///  Local state fields for this component.

  bool screeningData = false;

  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    expandableExpandableController.dispose();
  }
}
