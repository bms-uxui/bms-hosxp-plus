import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/summarize_chart/item_i_m_p_o_r_t_a_n_t_n_o_n_o_p_e_r_a_t_i_n_g_r_o_o_m_p_r_o_c_e_d_u_r_e_s/item_i_m_p_o_r_t_a_n_t_n_o_n_o_p_e_r_a_t_i_n_g_r_o_o_m_p_r_o_c_e_d_u_r_e_s_widget.dart';
import '/ipd/summarize_chart/item_o_p_e_r_a_t_i_o_n_r_o_o_m_p_r_o_c_e_d_u_r_e/item_o_p_e_r_a_t_i_o_n_r_o_o_m_p_r_o_c_e_d_u_r_e_widget.dart';
import '/ipd/summarize_chart/item_s_p_e_c_i_a_l_i_n_v_e_s_t_i_g_a_t_i_o_n_s/item_s_p_e_c_i_a_l_i_n_v_e_s_t_i_g_a_t_i_o_n_s_widget.dart';
import 'dart:ui';
import 'discharge_summary_operation_view_widget.dart'
    show DischargeSummaryOperationViewWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DischargeSummaryOperationViewModel
    extends FlutterFlowModel<DischargeSummaryOperationViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel1;
  // Model for Item_OPERATIONROOMPROCEDURE component.
  late ItemOPERATIONROOMPROCEDUREModel itemOPERATIONROOMPROCEDUREModel1;
  // Model for Item_OPERATIONROOMPROCEDURE component.
  late ItemOPERATIONROOMPROCEDUREModel itemOPERATIONROOMPROCEDUREModel2;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel2;
  // Model for Item_IMPORTANTNONOPERATINGROOMPROCEDURES component.
  late ItemIMPORTANTNONOPERATINGROOMPROCEDURESModel
      itemIMPORTANTNONOPERATINGROOMPROCEDURESModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel3;
  // Model for Item_SPECIALINVESTIGATIONS component.
  late ItemSPECIALINVESTIGATIONSModel itemSPECIALINVESTIGATIONSModel;

  @override
  void initState(BuildContext context) {
    iconButtonPrimaryModel1 =
        createModel(context, () => IconButtonPrimaryModel());
    itemOPERATIONROOMPROCEDUREModel1 =
        createModel(context, () => ItemOPERATIONROOMPROCEDUREModel());
    itemOPERATIONROOMPROCEDUREModel2 =
        createModel(context, () => ItemOPERATIONROOMPROCEDUREModel());
    iconButtonPrimaryModel2 =
        createModel(context, () => IconButtonPrimaryModel());
    itemIMPORTANTNONOPERATINGROOMPROCEDURESModel = createModel(
        context, () => ItemIMPORTANTNONOPERATINGROOMPROCEDURESModel());
    iconButtonPrimaryModel3 =
        createModel(context, () => IconButtonPrimaryModel());
    itemSPECIALINVESTIGATIONSModel =
        createModel(context, () => ItemSPECIALINVESTIGATIONSModel());
  }

  @override
  void dispose() {
    iconButtonPrimaryModel1.dispose();
    itemOPERATIONROOMPROCEDUREModel1.dispose();
    itemOPERATIONROOMPROCEDUREModel2.dispose();
    iconButtonPrimaryModel2.dispose();
    itemIMPORTANTNONOPERATINGROOMPROCEDURESModel.dispose();
    iconButtonPrimaryModel3.dispose();
    itemSPECIALINVESTIGATIONSModel.dispose();
  }
}
