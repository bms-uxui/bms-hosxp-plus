import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import 'dart:ui';
import 'buttonsheet_department_detial_widget.dart'
    show ButtonsheetDepartmentDetialWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetDepartmentDetialModel
    extends FlutterFlowModel<ButtonsheetDepartmentDetialWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    iconTitleModel = createModel(context, () => IconTitleModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel.dispose();
    iconTitleModel.dispose();
  }
}
