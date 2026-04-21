import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/er/widget/doctor_visit_completed_view/doctor_visit_completed_view_widget.dart';
import '/er/widget/pendingdoctorvisit_view/pendingdoctorvisit_view_widget.dart';
import '/er/widget/pendinghistorytaking_view/pendinghistorytaking_view_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'e_r_homepage_copy_widget.dart' show ERHomepageCopyWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ERHomepageCopyModel extends FlutterFlowModel<ERHomepageCopyWidget> {
  ///  Local state fields for this page.

  int? filter = 1;

  ///  State fields for stateful widgets in this page.

  // Model for AppBar_User component.
  late AppBarUserModel appBarUserModel;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel;
  // Model for Pendinghistorytaking_View component.
  late PendinghistorytakingViewModel pendinghistorytakingViewModel;
  // Model for Pendingdoctorvisit_View component.
  late PendingdoctorvisitViewModel pendingdoctorvisitViewModel;
  // Model for DoctorVisitCompleted_View component.
  late DoctorVisitCompletedViewModel doctorVisitCompletedViewModel;
  // Model for Nav_Bar component.
  late NavBarModel navBarModel;
  // Model for BottonSecondary component.
  late BottonSecondaryModel bottonSecondaryModel;

  @override
  void initState(BuildContext context) {
    appBarUserModel = createModel(context, () => AppBarUserModel());
    searchBarSecondaryModel =
        createModel(context, () => SearchBarSecondaryModel());
    pendinghistorytakingViewModel =
        createModel(context, () => PendinghistorytakingViewModel());
    pendingdoctorvisitViewModel =
        createModel(context, () => PendingdoctorvisitViewModel());
    doctorVisitCompletedViewModel =
        createModel(context, () => DoctorVisitCompletedViewModel());
    navBarModel = createModel(context, () => NavBarModel());
    bottonSecondaryModel = createModel(context, () => BottonSecondaryModel());
  }

  @override
  void dispose() {
    appBarUserModel.dispose();
    searchBarSecondaryModel.dispose();
    pendinghistorytakingViewModel.dispose();
    pendingdoctorvisitViewModel.dispose();
    doctorVisitCompletedViewModel.dispose();
    navBarModel.dispose();
    bottonSecondaryModel.dispose();
  }

  /// Action blocks.
  Future test(BuildContext context) async {}
}
