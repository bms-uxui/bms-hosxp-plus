import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/er/drugand_service/tag_price/tag_price_widget.dart';
import '/er/treatment/buttonsheet_filtertreatment_e_r/buttonsheet_filtertreatment_e_r_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:styled_divider/styled_divider.dart';
import 'treatment_e_r_view_widget.dart' show TreatmentERViewWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TreatmentERViewModel extends FlutterFlowModel<TreatmentERViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for Tag_price component.
  late TagPriceModel tagPriceModel;

  @override
  void initState(BuildContext context) {
    buttonFillterModel = createModel(context, () => ButtonFillterModel());
    iconButtonSecondaryModel =
        createModel(context, () => IconButtonSecondaryModel());
    dateandTimeRecordeModel =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    tagPriceModel = createModel(context, () => TagPriceModel());
  }

  @override
  void dispose() {
    buttonFillterModel.dispose();
    iconButtonSecondaryModel.dispose();
    dateandTimeRecordeModel.dispose();
    iconButtonTertiaryModel.dispose();
    tagPriceModel.dispose();
  }
}
