import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/button_mainpage_doctors_rounds/button_mainpage_doctors_rounds_widget.dart';
import '/main/widget/button_mainpage_i_p_d/button_mainpage_i_p_d_widget.dart';
import '/main/widget/doctors_rounds_mainpage/doctors_rounds_mainpage_widget.dart';
import '/main/widget/i_p_d_mainpage/i_p_d_mainpage_widget.dart';
import '/main/widget/o_p_d_mainpage/o_p_d_mainpage_widget.dart';
import 'dart:math';
import 'main_page_copy_widget.dart' show MainPageCopyWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MainPageCopyModel extends FlutterFlowModel<MainPageCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AppBar_User component.
  late AppBarUserModel appBarUserModel;
  // Model for Button_Mainpage_IPD component.
  late ButtonMainpageIPDModel buttonMainpageIPDModel;
  // Model for Button_Mainpage_DoctorsRounds component.
  late ButtonMainpageDoctorsRoundsModel buttonMainpageDoctorsRoundsModel;
  // Model for OPD_Mainpage component.
  late OPDMainpageModel oPDMainpageModel;
  // Model for IPD_Mainpage component.
  late IPDMainpageModel iPDMainpageModel;
  // Model for DoctorsRounds_Mainpage component.
  late DoctorsRoundsMainpageModel doctorsRoundsMainpageModel;
  // Model for Nav_Bar component.
  late NavBarModel navBarModel;

  @override
  void initState(BuildContext context) {
    appBarUserModel = createModel(context, () => AppBarUserModel());
    buttonMainpageIPDModel =
        createModel(context, () => ButtonMainpageIPDModel());
    buttonMainpageDoctorsRoundsModel =
        createModel(context, () => ButtonMainpageDoctorsRoundsModel());
    oPDMainpageModel = createModel(context, () => OPDMainpageModel());
    iPDMainpageModel = createModel(context, () => IPDMainpageModel());
    doctorsRoundsMainpageModel =
        createModel(context, () => DoctorsRoundsMainpageModel());
    navBarModel = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    appBarUserModel.dispose();
    buttonMainpageIPDModel.dispose();
    buttonMainpageDoctorsRoundsModel.dispose();
    oPDMainpageModel.dispose();
    iPDMainpageModel.dispose();
    doctorsRoundsMainpageModel.dispose();
    navBarModel.dispose();
  }

  /// Action blocks.
  Future test(BuildContext context) async {}
}
