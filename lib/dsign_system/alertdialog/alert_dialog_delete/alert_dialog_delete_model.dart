import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/button_cancel/button_cancel_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'alert_dialog_delete_widget.dart' show AlertDialogDeleteWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AlertDialogDeleteModel extends FlutterFlowModel<AlertDialogDeleteWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for ButtonCancel component.
  late ButtonCancelModel buttonCancelModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    buttonCancelModel = createModel(context, () => ButtonCancelModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    buttonCancelModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
