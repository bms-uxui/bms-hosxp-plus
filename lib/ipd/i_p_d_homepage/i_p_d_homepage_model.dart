import '/dsign_system/app_bar_user/app_bar_user_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/widget/admit_i_p_dpage/admit_i_p_dpage_widget.dart';
import '/ipd/widget/averagesleepdays_i_p_dpage/averagesleepdays_i_p_dpage_widget.dart';
import '/ipd/widget/bedoccupancyrate_i_p_dpage/bedoccupancyrate_i_p_dpage_widget.dart';
import '/ipd/widget/button_i_p_d_admit/button_i_p_d_admit_widget.dart';
import '/ipd/widget/button_i_p_d_averagesleepdays/button_i_p_d_averagesleepdays_widget.dart';
import '/ipd/widget/button_i_p_d_bedoccupancyrate/button_i_p_d_bedoccupancyrate_widget.dart';
import '/ipd/widget/button_i_p_d_discharge/button_i_p_d_discharge_widget.dart';
import '/ipd/widget/button_i_p_d_emptybed/button_i_p_d_emptybed_widget.dart';
import '/ipd/widget/button_i_p_d_treat/button_i_p_d_treat_widget.dart';
import '/ipd/widget/discharge_i_p_dpage/discharge_i_p_dpage_widget.dart';
import '/ipd/widget/emptybed_i_p_dpage/emptybed_i_p_dpage_widget.dart';
import '/ipd/widget/treat_i_p_dpage/treat_i_p_dpage_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'i_p_d_homepage_widget.dart' show IPDHomepageWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IPDHomepageModel extends FlutterFlowModel<IPDHomepageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AppBar_User component.
  late AppBarUserModel appBarUserModel;
  // Model for Button_IPD_Treat component.
  late ButtonIPDTreatModel buttonIPDTreatModel;
  // Model for Button_IPD_Admit component.
  late ButtonIPDAdmitModel buttonIPDAdmitModel;
  // Model for Button_IPD_Emptybed component.
  late ButtonIPDEmptybedModel buttonIPDEmptybedModel;
  // Model for Button_IPD_Discharge component.
  late ButtonIPDDischargeModel buttonIPDDischargeModel;
  // Model for Button_IPD_Averagesleepdays component.
  late ButtonIPDAveragesleepdaysModel buttonIPDAveragesleepdaysModel;
  // Model for Button_IPD_Bedoccupancyrate component.
  late ButtonIPDBedoccupancyrateModel buttonIPDBedoccupancyrateModel;
  // Model for Treat_IPDpage component.
  late TreatIPDpageModel treatIPDpageModel;
  // Model for Admit_IPDpage component.
  late AdmitIPDpageModel admitIPDpageModel;
  // Model for Emptybed_IPDpage component.
  late EmptybedIPDpageModel emptybedIPDpageModel;
  // Model for Discharge_IPDpage component.
  late DischargeIPDpageModel dischargeIPDpageModel;
  // Model for Averagesleepdays_IPDpage component.
  late AveragesleepdaysIPDpageModel averagesleepdaysIPDpageModel;
  // Model for Bedoccupancyrate_IPDpage component.
  late BedoccupancyrateIPDpageModel bedoccupancyrateIPDpageModel;
  // Model for Nav_Bar component.
  late NavBarModel navBarModel;
  // Model for BottonSecondary component.
  late BottonSecondaryModel bottonSecondaryModel1;
  // Model for BottonSecondary component.
  late BottonSecondaryModel bottonSecondaryModel2;

  @override
  void initState(BuildContext context) {
    appBarUserModel = createModel(context, () => AppBarUserModel());
    buttonIPDTreatModel = createModel(context, () => ButtonIPDTreatModel());
    buttonIPDAdmitModel = createModel(context, () => ButtonIPDAdmitModel());
    buttonIPDEmptybedModel =
        createModel(context, () => ButtonIPDEmptybedModel());
    buttonIPDDischargeModel =
        createModel(context, () => ButtonIPDDischargeModel());
    buttonIPDAveragesleepdaysModel =
        createModel(context, () => ButtonIPDAveragesleepdaysModel());
    buttonIPDBedoccupancyrateModel =
        createModel(context, () => ButtonIPDBedoccupancyrateModel());
    treatIPDpageModel = createModel(context, () => TreatIPDpageModel());
    admitIPDpageModel = createModel(context, () => AdmitIPDpageModel());
    emptybedIPDpageModel = createModel(context, () => EmptybedIPDpageModel());
    dischargeIPDpageModel = createModel(context, () => DischargeIPDpageModel());
    averagesleepdaysIPDpageModel =
        createModel(context, () => AveragesleepdaysIPDpageModel());
    bedoccupancyrateIPDpageModel =
        createModel(context, () => BedoccupancyrateIPDpageModel());
    navBarModel = createModel(context, () => NavBarModel());
    bottonSecondaryModel1 = createModel(context, () => BottonSecondaryModel());
    bottonSecondaryModel2 = createModel(context, () => BottonSecondaryModel());
  }

  @override
  void dispose() {
    appBarUserModel.dispose();
    buttonIPDTreatModel.dispose();
    buttonIPDAdmitModel.dispose();
    buttonIPDEmptybedModel.dispose();
    buttonIPDDischargeModel.dispose();
    buttonIPDAveragesleepdaysModel.dispose();
    buttonIPDBedoccupancyrateModel.dispose();
    treatIPDpageModel.dispose();
    admitIPDpageModel.dispose();
    emptybedIPDpageModel.dispose();
    dischargeIPDpageModel.dispose();
    averagesleepdaysIPDpageModel.dispose();
    bedoccupancyrateIPDpageModel.dispose();
    navBarModel.dispose();
    bottonSecondaryModel1.dispose();
    bottonSecondaryModel2.dispose();
  }

  /// Action blocks.
  Future test(BuildContext context) async {}
}
