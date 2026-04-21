import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/e_r_main_view/e_r_main_view_widget.dart';
import '/main/main_view/main_view_widget.dart';
import '/main/menuicon/menuicon_widget.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import 'dart:ui';
import 'main_page_widget.dart' show MainPageWidget;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MainPageModel extends FlutterFlowModel<MainPageWidget> {
  ///  Local state fields for this page.

  String viewpage = 'หน้าแรก';

  ///  State fields for stateful widgets in this page.

  // Model for AppBar_User component.
  late AppBarUserModel appBarUserModel;
  // Model for Main_View component.
  late MainViewModel mainViewModel;
  // Model for ER_Main_View component.
  late ERMainViewModel eRMainViewModel;
  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;
  // Model for menuicon component.
  late MenuiconModel menuiconModel1;
  // Model for menuicon component.
  late MenuiconModel menuiconModel2;
  // Model for menuicon component.
  late MenuiconModel menuiconModel3;
  // Model for menuicon component.
  late MenuiconModel menuiconModel4;
  // Model for menuicon component.
  late MenuiconModel menuiconModel5;

  @override
  void initState(BuildContext context) {
    appBarUserModel = createModel(context, () => AppBarUserModel());
    mainViewModel = createModel(context, () => MainViewModel());
    eRMainViewModel = createModel(context, () => ERMainViewModel());
    iconTitleModel = createModel(context, () => IconTitleModel());
    menuiconModel1 = createModel(context, () => MenuiconModel());
    menuiconModel2 = createModel(context, () => MenuiconModel());
    menuiconModel3 = createModel(context, () => MenuiconModel());
    menuiconModel4 = createModel(context, () => MenuiconModel());
    menuiconModel5 = createModel(context, () => MenuiconModel());
  }

  @override
  void dispose() {
    appBarUserModel.dispose();
    mainViewModel.dispose();
    eRMainViewModel.dispose();
    iconTitleModel.dispose();
    menuiconModel1.dispose();
    menuiconModel2.dispose();
    menuiconModel3.dispose();
    menuiconModel4.dispose();
    menuiconModel5.dispose();
  }

  /// Action blocks.
  Future test(BuildContext context) async {}
}
