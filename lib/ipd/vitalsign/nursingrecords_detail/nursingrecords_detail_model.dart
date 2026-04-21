import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/medical_certificate/more_medicalcertificate/more_medicalcertificate_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'nursingrecords_detail_widget.dart' show NursingrecordsDetailWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NursingrecordsDetailModel
    extends FlutterFlowModel<NursingrecordsDetailWidget> {
  ///  Local state fields for this page.

  int? tabmenu = 1;

  ///  State fields for stateful widgets in this page.

  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonSecondaryModel =
        createModel(context, () => IconButtonSecondaryModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    iconButtonSecondaryModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
