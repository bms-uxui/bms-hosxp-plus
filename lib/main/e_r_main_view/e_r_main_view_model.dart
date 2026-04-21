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
import 'e_r_main_view_widget.dart' show ERMainViewWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ERMainViewModel extends FlutterFlowModel<ERMainViewWidget> {
  ///  Local state fields for this component.

  String view = 'รอคัดกรอง';

  ///  State fields for stateful widgets in this component.

  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel;
  // Model for Pendinghistorytaking_View component.
  late PendinghistorytakingViewModel pendinghistorytakingViewModel;
  // Model for Pendingdoctorvisit_View component.
  late PendingdoctorvisitViewModel pendingdoctorvisitViewModel;
  // Model for DoctorVisitCompleted_View component.
  late DoctorVisitCompletedViewModel doctorVisitCompletedViewModel;

  @override
  void initState(BuildContext context) {
    searchBarSecondaryModel =
        createModel(context, () => SearchBarSecondaryModel());
    pendinghistorytakingViewModel =
        createModel(context, () => PendinghistorytakingViewModel());
    pendingdoctorvisitViewModel =
        createModel(context, () => PendingdoctorvisitViewModel());
    doctorVisitCompletedViewModel =
        createModel(context, () => DoctorVisitCompletedViewModel());
  }

  @override
  void dispose() {
    searchBarSecondaryModel.dispose();
    pendinghistorytakingViewModel.dispose();
    pendingdoctorvisitViewModel.dispose();
    doctorVisitCompletedViewModel.dispose();
  }
}
