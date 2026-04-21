import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'item_admit_widget.dart' show ItemAdmitWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemAdmitModel extends FlutterFlowModel<ItemAdmitWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonPrimaryModel.dispose();
  }
}
