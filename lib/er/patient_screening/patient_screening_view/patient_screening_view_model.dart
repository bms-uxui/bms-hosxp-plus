import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'patient_screening_view_widget.dart' show PatientScreeningViewWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientScreeningViewModel
    extends FlutterFlowModel<PatientScreeningViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel;

  @override
  void initState(BuildContext context) {
    iconButtonSecondaryModel =
        createModel(context, () => IconButtonSecondaryModel());
  }

  @override
  void dispose() {
    iconButtonSecondaryModel.dispose();
  }
}
