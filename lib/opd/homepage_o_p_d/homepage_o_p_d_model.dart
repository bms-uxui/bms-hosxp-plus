import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/opd/widget/appointment_o_p_dpage/appointment_o_p_dpage_widget.dart';
import '/opd/widget/averagetime_o_p_dpage/averagetime_o_p_dpage_widget.dart';
import '/opd/widget/button_o_p_d_appointment/button_o_p_d_appointment_widget.dart';
import '/opd/widget/button_o_p_d_averagetime/button_o_p_d_averagetime_widget.dart';
import '/opd/widget/button_o_p_d_servicerecipient/button_o_p_d_servicerecipient_widget.dart';
import '/opd/widget/service_o_p_dpage/service_o_p_dpage_widget.dart';
import 'dart:math';
import '/index.dart';
import 'homepage_o_p_d_widget.dart' show HomepageOPDWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomepageOPDModel extends FlutterFlowModel<HomepageOPDWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AppBar_User component.
  late AppBarUserModel appBarUserModel;
  // Model for Button_OPD_Servicerecipient component.
  late ButtonOPDServicerecipientModel buttonOPDServicerecipientModel;
  // Model for Button_OPD_Averagetime component.
  late ButtonOPDAveragetimeModel buttonOPDAveragetimeModel;
  // Model for Button_OPD_Appointment component.
  late ButtonOPDAppointmentModel buttonOPDAppointmentModel;
  // Model for Service_OPDpage component.
  late ServiceOPDpageModel serviceOPDpageModel;
  // Model for Averagetime_OPDpage component.
  late AveragetimeOPDpageModel averagetimeOPDpageModel;
  // Model for Appointment_OPDpage component.
  late AppointmentOPDpageModel appointmentOPDpageModel;
  // Model for Nav_Bar component.
  late NavBarModel navBarModel;
  // Model for BottonSecondary component.
  late BottonSecondaryModel bottonSecondaryModel;

  @override
  void initState(BuildContext context) {
    appBarUserModel = createModel(context, () => AppBarUserModel());
    buttonOPDServicerecipientModel =
        createModel(context, () => ButtonOPDServicerecipientModel());
    buttonOPDAveragetimeModel =
        createModel(context, () => ButtonOPDAveragetimeModel());
    buttonOPDAppointmentModel =
        createModel(context, () => ButtonOPDAppointmentModel());
    serviceOPDpageModel = createModel(context, () => ServiceOPDpageModel());
    averagetimeOPDpageModel =
        createModel(context, () => AveragetimeOPDpageModel());
    appointmentOPDpageModel =
        createModel(context, () => AppointmentOPDpageModel());
    navBarModel = createModel(context, () => NavBarModel());
    bottonSecondaryModel = createModel(context, () => BottonSecondaryModel());
  }

  @override
  void dispose() {
    appBarUserModel.dispose();
    buttonOPDServicerecipientModel.dispose();
    buttonOPDAveragetimeModel.dispose();
    buttonOPDAppointmentModel.dispose();
    serviceOPDpageModel.dispose();
    averagetimeOPDpageModel.dispose();
    appointmentOPDpageModel.dispose();
    navBarModel.dispose();
    bottonSecondaryModel.dispose();
  }

  /// Action blocks.
  Future test(BuildContext context) async {}
}
