import '/dsign_system/alertdialog/alert_dialog_generate/alert_dialog_generate_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/buttonsheet_samary_a_i_e_r/buttonsheet_samary_a_i_e_r_widget.dart';
import '/er/physical_examination/buttonsheet_order_doctorsorders/buttonsheet_order_doctorsorders_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:styled_divider/styled_divider.dart';
import 'physical_examination_view_widget.dart'
    show PhysicalExaminationViewWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class PhysicalExaminationViewModel
    extends FlutterFlowModel<PhysicalExaminationViewWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for ButtonAIgenerate component.
  late ButtonAIgenerateModel buttonAIgenerateModel;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel1;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel3;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel4;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel5;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel6;

  @override
  void initState(BuildContext context) {
    buttonAIgenerateModel = createModel(context, () => ButtonAIgenerateModel());
    iconButtonSecondaryModel1 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    iconButtonSecondaryModel2 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel3 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel4 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel5 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel6 =
        createModel(context, () => IconButtonTertiaryModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    buttonAIgenerateModel.dispose();
    iconButtonSecondaryModel1.dispose();
    iconButtonPrimaryModel.dispose();
    iconButtonSecondaryModel2.dispose();
    iconButtonTertiaryModel1.dispose();
    iconButtonTertiaryModel2.dispose();
    iconButtonTertiaryModel3.dispose();
    iconButtonTertiaryModel4.dispose();
    iconButtonTertiaryModel5.dispose();
    iconButtonTertiaryModel6.dispose();
  }
}
