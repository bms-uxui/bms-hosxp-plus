import '/dsign_system/button_styles/botton_provider_i_d/botton_provider_i_d_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/login/widget/animation_mobile/animation_mobile_widget.dart';
import '/login/widget/animation_tablet/animation_tablet_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for animation_tablet component.
  late AnimationTabletModel animationTabletModel;
  // Model for animation_mobile component.
  late AnimationMobileModel animationMobileModel;
  // Model for BottonProviderID component.
  late BottonProviderIDModel bottonProviderIDModel;

  @override
  void initState(BuildContext context) {
    animationTabletModel = createModel(context, () => AnimationTabletModel());
    animationMobileModel = createModel(context, () => AnimationMobileModel());
    bottonProviderIDModel = createModel(context, () => BottonProviderIDModel());
  }

  @override
  void dispose() {
    animationTabletModel.dispose();
    animationMobileModel.dispose();
    bottonProviderIDModel.dispose();
  }
}
