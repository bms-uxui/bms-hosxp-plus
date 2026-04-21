import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'donorssignature_widget.dart' show DonorssignatureWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

class DonorssignatureModel extends FlutterFlowModel<DonorssignatureWidget> {
  ///  Local state fields for this page.

  bool? signature = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Signature widget.
  SignatureController? signatureController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    signatureController?.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    bottonPrimaryModel.dispose();
  }
}
