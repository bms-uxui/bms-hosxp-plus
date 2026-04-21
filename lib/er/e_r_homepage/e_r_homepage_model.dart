import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'e_r_homepage_widget.dart' show ERHomepageWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ERHomepageModel extends FlutterFlowModel<ERHomepageWidget> {
  ///  Local state fields for this page.

  int? filter = 1;

  ///  State fields for stateful widgets in this page.

  // Model for AppBar_User component.
  late AppBarUserModel appBarUserModel;
  // Model for Nav_Bar component.
  late NavBarModel navBarModel;
  // Model for BottonSecondary component.
  late BottonSecondaryModel bottonSecondaryModel;

  @override
  void initState(BuildContext context) {
    appBarUserModel = createModel(context, () => AppBarUserModel());
    navBarModel = createModel(context, () => NavBarModel());
    bottonSecondaryModel = createModel(context, () => BottonSecondaryModel());
  }

  @override
  void dispose() {
    appBarUserModel.dispose();
    navBarModel.dispose();
    bottonSecondaryModel.dispose();
  }

  /// Action blocks.
  Future test(BuildContext context) async {}
}
