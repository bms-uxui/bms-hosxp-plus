import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/menutab/menutab_widget.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/main/widget/tab_a_d/tab_a_d_widget.dart';
import '/main/widget/tab_u_t/tab_u_t_widget.dart';
import '/main/widget/tab_v_b/tab_v_b_widget.dart';
import 'dart:ui';
import 'i_p_d_mainpage_widget.dart' show IPDMainpageWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IPDMainpageModel extends FlutterFlowModel<IPDMainpageWidget> {
  ///  Local state fields for this component.

  String page = 'กำลังรักษา';

  ///  State fields for stateful widgets in this component.

  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;
  // Model for menutab component.
  late MenutabModel menutabModel1;
  // Model for menutab component.
  late MenutabModel menutabModel2;
  // Model for menutab component.
  late MenutabModel menutabModel3;
  // Model for Tab_UT component.
  late TabUTModel tabUTModel;
  // Model for Tab_AD component.
  late TabADModel tabADModel;
  // Model for Tab_VB component.
  late TabVBModel tabVBModel;

  @override
  void initState(BuildContext context) {
    iconTitleModel = createModel(context, () => IconTitleModel());
    menutabModel1 = createModel(context, () => MenutabModel());
    menutabModel2 = createModel(context, () => MenutabModel());
    menutabModel3 = createModel(context, () => MenutabModel());
    tabUTModel = createModel(context, () => TabUTModel());
    tabADModel = createModel(context, () => TabADModel());
    tabVBModel = createModel(context, () => TabVBModel());
  }

  @override
  void dispose() {
    iconTitleModel.dispose();
    menutabModel1.dispose();
    menutabModel2.dispose();
    menutabModel3.dispose();
    tabUTModel.dispose();
    tabADModel.dispose();
    tabVBModel.dispose();
  }
}
