import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/menu_mainpage/menu_mainpage_widget.dart';
import 'dart:ui';
import 'more_menu_widget.dart' show MoreMenuWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MoreMenuModel extends FlutterFlowModel<MoreMenuWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Menu_Mainpage component.
  late MenuMainpageModel menuMainpageModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    menuMainpageModel = createModel(context, () => MenuMainpageModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    menuMainpageModel.dispose();
  }
}
