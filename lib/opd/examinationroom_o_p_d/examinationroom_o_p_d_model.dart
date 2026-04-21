import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/opd/widget/item_examinationroom_o_p_d/item_examinationroom_o_p_d_widget.dart';
import 'dart:math';
import '/index.dart';
import 'examinationroom_o_p_d_widget.dart' show ExaminationroomOPDWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExaminationroomOPDModel
    extends FlutterFlowModel<ExaminationroomOPDWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SearchBarPrimary component.
  late SearchBarPrimaryModel searchBarPrimaryModel;
  // Model for Item_Examinationroom_OPD component.
  late ItemExaminationroomOPDModel itemExaminationroomOPDModel1;
  // Model for Item_Examinationroom_OPD component.
  late ItemExaminationroomOPDModel itemExaminationroomOPDModel2;
  // Model for Item_Examinationroom_OPD component.
  late ItemExaminationroomOPDModel itemExaminationroomOPDModel3;
  // Model for Nav_Bar component.
  late NavBarModel navBarModel;

  @override
  void initState(BuildContext context) {
    searchBarPrimaryModel = createModel(context, () => SearchBarPrimaryModel());
    itemExaminationroomOPDModel1 =
        createModel(context, () => ItemExaminationroomOPDModel());
    itemExaminationroomOPDModel2 =
        createModel(context, () => ItemExaminationroomOPDModel());
    itemExaminationroomOPDModel3 =
        createModel(context, () => ItemExaminationroomOPDModel());
    navBarModel = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    searchBarPrimaryModel.dispose();
    itemExaminationroomOPDModel1.dispose();
    itemExaminationroomOPDModel2.dispose();
    itemExaminationroomOPDModel3.dispose();
    navBarModel.dispose();
  }
}
