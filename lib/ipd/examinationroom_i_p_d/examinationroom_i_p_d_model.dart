import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/widget/item_examinationroom_i_p_d/item_examinationroom_i_p_d_widget.dart';
import 'dart:math';
import '/index.dart';
import 'examinationroom_i_p_d_widget.dart' show ExaminationroomIPDWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExaminationroomIPDModel
    extends FlutterFlowModel<ExaminationroomIPDWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SearchBarPrimary component.
  late SearchBarPrimaryModel searchBarPrimaryModel;
  // Model for Item_Examinationroom_IPD component.
  late ItemExaminationroomIPDModel itemExaminationroomIPDModel1;
  // Model for Item_Examinationroom_IPD component.
  late ItemExaminationroomIPDModel itemExaminationroomIPDModel2;
  // Model for Item_Examinationroom_IPD component.
  late ItemExaminationroomIPDModel itemExaminationroomIPDModel3;

  @override
  void initState(BuildContext context) {
    searchBarPrimaryModel = createModel(context, () => SearchBarPrimaryModel());
    itemExaminationroomIPDModel1 =
        createModel(context, () => ItemExaminationroomIPDModel());
    itemExaminationroomIPDModel2 =
        createModel(context, () => ItemExaminationroomIPDModel());
    itemExaminationroomIPDModel3 =
        createModel(context, () => ItemExaminationroomIPDModel());
  }

  @override
  void dispose() {
    searchBarPrimaryModel.dispose();
    itemExaminationroomIPDModel1.dispose();
    itemExaminationroomIPDModel2.dispose();
    itemExaminationroomIPDModel3.dispose();
  }
}
