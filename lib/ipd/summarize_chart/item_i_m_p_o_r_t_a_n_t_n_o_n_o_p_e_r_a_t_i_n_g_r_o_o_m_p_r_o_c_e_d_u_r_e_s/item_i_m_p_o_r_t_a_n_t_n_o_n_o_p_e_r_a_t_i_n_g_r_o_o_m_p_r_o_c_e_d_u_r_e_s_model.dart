import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'item_i_m_p_o_r_t_a_n_t_n_o_n_o_p_e_r_a_t_i_n_g_r_o_o_m_p_r_o_c_e_d_u_r_e_s_widget.dart'
    show ItemIMPORTANTNONOPERATINGROOMPROCEDURESWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemIMPORTANTNONOPERATINGROOMPROCEDURESModel
    extends FlutterFlowModel<ItemIMPORTANTNONOPERATINGROOMPROCEDURESWidget> {
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
