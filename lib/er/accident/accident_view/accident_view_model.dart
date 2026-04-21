import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'accident_view_widget.dart' show AccidentViewWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AccidentViewModel extends FlutterFlowModel<AccidentViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel1;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel2;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel3;

  @override
  void initState(BuildContext context) {
    iconButtonPrimaryModel1 =
        createModel(context, () => IconButtonPrimaryModel());
    iconButtonPrimaryModel2 =
        createModel(context, () => IconButtonPrimaryModel());
    iconButtonPrimaryModel3 =
        createModel(context, () => IconButtonPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonPrimaryModel1.dispose();
    iconButtonPrimaryModel2.dispose();
    iconButtonPrimaryModel3.dispose();
  }
}
