import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/dsign_system/status_appointment/status_appointment_widget.dart';
import '/dsign_system/status_lab/status_lab_widget.dart';
import '/dsign_system/status_rx/status_rx_widget.dart';
import '/dsign_system/status_tx/status_tx_widget.dart';
import '/dsign_system/status_xray/status_xray_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/fillter_examinationroom_i_p_d/fillter_examinationroom_i_p_d_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:styled_divider/styled_divider.dart';
import 'patient_list_i_p_d_widget.dart' show PatientListIPDWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PatientListIPDModel extends FlutterFlowModel<PatientListIPDWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for SearchBarPrimary component.
  late SearchBarPrimaryModel searchBarPrimaryModel;
  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for StatusLab component.
  late StatusLabModel statusLabModel;
  // Model for StatusXray component.
  late StatusXrayModel statusXrayModel;
  // Model for StatusTx component.
  late StatusTxModel statusTxModel;
  // Model for StatusRx component.
  late StatusRxModel statusRxModel;
  // Model for StatusAppointment component.
  late StatusAppointmentModel statusAppointmentModel;

  @override
  void initState(BuildContext context) {
    searchBarPrimaryModel = createModel(context, () => SearchBarPrimaryModel());
    buttonFillterModel = createModel(context, () => ButtonFillterModel());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    statusLabModel = createModel(context, () => StatusLabModel());
    statusXrayModel = createModel(context, () => StatusXrayModel());
    statusTxModel = createModel(context, () => StatusTxModel());
    statusRxModel = createModel(context, () => StatusRxModel());
    statusAppointmentModel =
        createModel(context, () => StatusAppointmentModel());
  }

  @override
  void dispose() {
    searchBarPrimaryModel.dispose();
    buttonFillterModel.dispose();
    iconButtonTertiaryModel.dispose();
    statusLabModel.dispose();
    statusXrayModel.dispose();
    statusTxModel.dispose();
    statusRxModel.dispose();
    statusAppointmentModel.dispose();
  }
}
