import '/dsign_system/alertdialog/alert_dialog_generate/alert_dialog_generate_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/er/patient_screening/buttonsheet_samary_a_i_e_r_copy/buttonsheet_samary_a_i_e_r_copy_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'item_triage_levels_widget.dart' show ItemTriageLevelsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemTriageLevelsModel extends FlutterFlowModel<ItemTriageLevelsWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for ButtonAIgenerate component.
  late ButtonAIgenerateModel buttonAIgenerateModel;

  @override
  void initState(BuildContext context) {
    buttonAIgenerateModel = createModel(context, () => ButtonAIgenerateModel());
  }

  @override
  void dispose() {
    buttonAIgenerateModel.dispose();
  }
}
