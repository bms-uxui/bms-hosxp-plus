import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'er_dashboard_widget.dart' show ERDashboardWidget;

class ERDashboardModel extends FlutterFlowModel<ERDashboardWidget> {
  late AppBarUserModel appBarUserModel;
  late NavBarModel navBarModel;

  @override
  void initState(BuildContext context) {
    appBarUserModel = createModel(context, () => AppBarUserModel());
    navBarModel = createModel(context, () => NavBarModel());
  }

  @override
  void dispose() {
    appBarUserModel.dispose();
    navBarModel.dispose();
  }
}
