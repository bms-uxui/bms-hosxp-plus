import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'item_s_p_e_c_i_a_l_i_n_v_e_s_t_i_g_a_t_i_o_n_s_widget.dart'
    show ItemSPECIALINVESTIGATIONSWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemSPECIALINVESTIGATIONSModel
    extends FlutterFlowModel<ItemSPECIALINVESTIGATIONSWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel;

  @override
  void initState(BuildContext context) {
    dateandTimeRecordeModel =
        createModel(context, () => DateandTimeRecordeModel());
  }

  @override
  void dispose() {
    dateandTimeRecordeModel.dispose();
  }
}
