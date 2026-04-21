import '/dsign_system/not_data/not_data_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/button_card_style1/button_card_style1_widget.dart';
import '/main/widget/doctors_rounds_mainpage/doctors_rounds_mainpage_widget.dart';
import '/main/widget/i_p_d_mainpage/i_p_d_mainpage_widget.dart';
import '/main/widget/o_p_dhome_mainpage/o_p_dhome_mainpage_widget.dart';
import 'dart:math';
import 'main_view_widget.dart' show MainViewWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MainViewModel extends FlutterFlowModel<MainViewWidget> {
  ///  Local state fields for this component.

  String? view = 'ผู้ป่วยนอก';

  ///  State fields for stateful widgets in this component.

  // Model for Button_CardStyle1 component.
  late ButtonCardStyle1Model buttonCardStyle1Model1;
  // Model for Button_CardStyle1 component.
  late ButtonCardStyle1Model buttonCardStyle1Model2;
  // Model for Button_CardStyle1 component.
  late ButtonCardStyle1Model buttonCardStyle1Model3;
  // Model for OPDhome_Mainpage component.
  late OPDhomeMainpageModel oPDhomeMainpageModel;
  // Model for IPD_Mainpage component.
  late IPDMainpageModel iPDMainpageModel;
  // Model for DoctorsRounds_Mainpage component.
  late DoctorsRoundsMainpageModel doctorsRoundsMainpageModel;
  // Model for Not_Data component.
  late NotDataModel notDataModel;

  @override
  void initState(BuildContext context) {
    buttonCardStyle1Model1 =
        createModel(context, () => ButtonCardStyle1Model());
    buttonCardStyle1Model2 =
        createModel(context, () => ButtonCardStyle1Model());
    buttonCardStyle1Model3 =
        createModel(context, () => ButtonCardStyle1Model());
    oPDhomeMainpageModel = createModel(context, () => OPDhomeMainpageModel());
    iPDMainpageModel = createModel(context, () => IPDMainpageModel());
    doctorsRoundsMainpageModel =
        createModel(context, () => DoctorsRoundsMainpageModel());
    notDataModel = createModel(context, () => NotDataModel());
  }

  @override
  void dispose() {
    buttonCardStyle1Model1.dispose();
    buttonCardStyle1Model2.dispose();
    buttonCardStyle1Model3.dispose();
    oPDhomeMainpageModel.dispose();
    iPDMainpageModel.dispose();
    doctorsRoundsMainpageModel.dispose();
    notDataModel.dispose();
  }
}
