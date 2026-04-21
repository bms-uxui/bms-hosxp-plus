import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/item_appiontment/item_appiontment_widget.dart';
import '/ipd/widget/item_e_m_r_i_p_d/item_e_m_r_i_p_d_widget.dart';
import '/ipd/widget/item_e_m_r_o_p_d/item_e_m_r_o_p_d_widget.dart';
import 'dart:ui';
import 'e_m_rpage_view_widget.dart' show EMRpageViewWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EMRpageViewModel extends FlutterFlowModel<EMRpageViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for Item_EMR_IPD component.
  late ItemEMRIPDModel itemEMRIPDModel1;
  // Model for Item_EMR_OPD component.
  late ItemEMROPDModel itemEMROPDModel1;
  // Model for Item_EMR_OPD component.
  late ItemEMROPDModel itemEMROPDModel2;
  // Model for Item_EMR_IPD component.
  late ItemEMRIPDModel itemEMRIPDModel2;
  // Model for Item_Appiontment component.
  late ItemAppiontmentModel itemAppiontmentModel;

  @override
  void initState(BuildContext context) {
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    itemEMRIPDModel1 = createModel(context, () => ItemEMRIPDModel());
    itemEMROPDModel1 = createModel(context, () => ItemEMROPDModel());
    itemEMROPDModel2 = createModel(context, () => ItemEMROPDModel());
    itemEMRIPDModel2 = createModel(context, () => ItemEMRIPDModel());
    itemAppiontmentModel = createModel(context, () => ItemAppiontmentModel());
  }

  @override
  void dispose() {
    iconButtonTertiaryModel1.dispose();
    iconButtonTertiaryModel2.dispose();
    itemEMRIPDModel1.dispose();
    itemEMROPDModel1.dispose();
    itemEMROPDModel2.dispose();
    itemEMRIPDModel2.dispose();
    itemAppiontmentModel.dispose();
  }
}
