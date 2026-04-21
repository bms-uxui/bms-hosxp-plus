import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/item_nurs_probltm/item_nurs_probltm_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'nurs_probltm_view_widget.dart' show NursProbltmViewWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NursProbltmViewModel extends FlutterFlowModel<NursProbltmViewWidget> {
  ///  Local state fields for this component.

  bool buttonaddNursPromple = true;

  ///  State fields for stateful widgets in this component.

  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for Item_NursProbltm component.
  late ItemNursProbltmModel itemNursProbltmModel;

  @override
  void initState(BuildContext context) {
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    itemNursProbltmModel = createModel(context, () => ItemNursProbltmModel());
  }

  @override
  void dispose() {
    iconButtonPrimaryModel.dispose();
    itemNursProbltmModel.dispose();
  }
}
