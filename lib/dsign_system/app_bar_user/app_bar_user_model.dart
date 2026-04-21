import '/dsign_system/user_profile/user_profile_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'app_bar_user_widget.dart' show AppBarUserWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppBarUserModel extends FlutterFlowModel<AppBarUserWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for User_profile component.
  late UserProfileModel userProfileModel;

  @override
  void initState(BuildContext context) {
    userProfileModel = createModel(context, () => UserProfileModel());
  }

  @override
  void dispose() {
    userProfileModel.dispose();
  }
}
