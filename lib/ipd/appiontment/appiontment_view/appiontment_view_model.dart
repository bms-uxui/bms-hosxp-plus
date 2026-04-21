import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/item_appiontment/item_appiontment_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'appiontment_view_widget.dart' show AppiontmentViewWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppiontmentViewModel extends FlutterFlowModel<AppiontmentViewWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController;

  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for Item_Appiontment component.
  late ItemAppiontmentModel itemAppiontmentModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for Item_Appiontment component.
  late ItemAppiontmentModel itemAppiontmentModel2;
  // Model for Item_Appiontment component.
  late ItemAppiontmentModel itemAppiontmentModel3;

  @override
  void initState(BuildContext context) {
    iconButtonSecondaryModel =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    itemAppiontmentModel1 = createModel(context, () => ItemAppiontmentModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    itemAppiontmentModel2 = createModel(context, () => ItemAppiontmentModel());
    itemAppiontmentModel3 = createModel(context, () => ItemAppiontmentModel());
  }

  @override
  void dispose() {
    expandableExpandableController.dispose();
    iconButtonSecondaryModel.dispose();
    iconButtonTertiaryModel1.dispose();
    itemAppiontmentModel1.dispose();
    iconButtonTertiaryModel2.dispose();
    itemAppiontmentModel2.dispose();
    itemAppiontmentModel3.dispose();
  }
}
