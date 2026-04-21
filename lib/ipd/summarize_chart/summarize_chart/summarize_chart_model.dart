import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/not_data/not_data_widget.dart';
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
import '/ipd/summarize_chart/fillter_summarize_chart/fillter_summarize_chart_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:styled_divider/styled_divider.dart';
import 'summarize_chart_widget.dart' show SummarizeChartWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SummarizeChartModel extends FlutterFlowModel<SummarizeChartWidget> {
  ///  Local state fields for this page.

  int filtter = 1;

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
  // Model for Not_Data component.
  late NotDataModel notDataModel1;
  // Model for Not_Data component.
  late NotDataModel notDataModel2;
  // Model for Not_Data component.
  late NotDataModel notDataModel3;
  // Model for Not_Data component.
  late NotDataModel notDataModel4;

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
    notDataModel1 = createModel(context, () => NotDataModel());
    notDataModel2 = createModel(context, () => NotDataModel());
    notDataModel3 = createModel(context, () => NotDataModel());
    notDataModel4 = createModel(context, () => NotDataModel());
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
    notDataModel1.dispose();
    notDataModel2.dispose();
    notDataModel3.dispose();
    notDataModel4.dispose();
  }
}
