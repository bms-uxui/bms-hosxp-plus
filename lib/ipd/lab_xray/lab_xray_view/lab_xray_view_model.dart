import '/dsign_system/button_styles/button_fillter/button_fillter_widget.dart';
import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/lab_xray/fillter_lab/fillter_lab_widget.dart';
import '/ipd/lab_xray/fillter_labhistory/fillter_labhistory_widget.dart';
import '/ipd/lab_xray/lab_result_image/lab_result_image_widget.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'lab_xray_view_widget.dart' show LabXrayViewWidget;
import 'package:styled_divider/styled_divider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LabXrayViewModel extends FlutterFlowModel<LabXrayViewWidget> {
  ///  Local state fields for this component.

  bool buttonadd = true;

  ///  State fields for stateful widgets in this component.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController1;

  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel1;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel1;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel3;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel4;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel5;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel6;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel7;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel8;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel9;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel10;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel11;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel12;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel13;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel14;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel15;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel16;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel17;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel18;
  // Model for Button_Fillter component.
  late ButtonFillterModel buttonFillterModel2;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController2;

  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel3;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel19;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel20;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel21;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel22;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel23;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel24;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel25;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController3;

  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel4;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel26;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel27;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel28;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel29;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel30;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel31;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel32;
  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController4;

  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel2;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel33;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel5;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel34;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel35;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel6;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel36;
  // Model for DateandTimeRecorde component.
  late DateandTimeRecordeModel dateandTimeRecordeModel7;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel37;

  @override
  void initState(BuildContext context) {
    buttonFillterModel1 = createModel(context, () => ButtonFillterModel());
    iconButtonSecondaryModel1 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
    dateandTimeRecordeModel1 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel2 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel3 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel4 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel5 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel6 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel7 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel8 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel9 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel10 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel11 =
        createModel(context, () => IconButtonTertiaryModel());
    dateandTimeRecordeModel2 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel12 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel13 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel14 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel15 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel16 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel17 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel18 =
        createModel(context, () => IconButtonTertiaryModel());
    buttonFillterModel2 = createModel(context, () => ButtonFillterModel());
    dateandTimeRecordeModel3 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel19 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel20 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel21 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel22 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel23 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel24 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel25 =
        createModel(context, () => IconButtonTertiaryModel());
    dateandTimeRecordeModel4 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel26 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel27 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel28 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel29 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel30 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel31 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel32 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonSecondaryModel2 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonTertiaryModel33 =
        createModel(context, () => IconButtonTertiaryModel());
    dateandTimeRecordeModel5 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel34 =
        createModel(context, () => IconButtonTertiaryModel());
    iconButtonTertiaryModel35 =
        createModel(context, () => IconButtonTertiaryModel());
    dateandTimeRecordeModel6 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel36 =
        createModel(context, () => IconButtonTertiaryModel());
    dateandTimeRecordeModel7 =
        createModel(context, () => DateandTimeRecordeModel());
    iconButtonTertiaryModel37 =
        createModel(context, () => IconButtonTertiaryModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    expandableExpandableController1.dispose();
    buttonFillterModel1.dispose();
    iconButtonSecondaryModel1.dispose();
    iconButtonTertiaryModel1.dispose();
    dateandTimeRecordeModel1.dispose();
    iconButtonTertiaryModel2.dispose();
    iconButtonTertiaryModel3.dispose();
    iconButtonTertiaryModel4.dispose();
    iconButtonTertiaryModel5.dispose();
    iconButtonTertiaryModel6.dispose();
    iconButtonTertiaryModel7.dispose();
    iconButtonTertiaryModel8.dispose();
    iconButtonTertiaryModel9.dispose();
    iconButtonTertiaryModel10.dispose();
    iconButtonTertiaryModel11.dispose();
    dateandTimeRecordeModel2.dispose();
    iconButtonTertiaryModel12.dispose();
    iconButtonTertiaryModel13.dispose();
    iconButtonTertiaryModel14.dispose();
    iconButtonTertiaryModel15.dispose();
    iconButtonTertiaryModel16.dispose();
    iconButtonTertiaryModel17.dispose();
    iconButtonTertiaryModel18.dispose();
    buttonFillterModel2.dispose();
    expandableExpandableController2.dispose();
    dateandTimeRecordeModel3.dispose();
    iconButtonTertiaryModel19.dispose();
    iconButtonTertiaryModel20.dispose();
    iconButtonTertiaryModel21.dispose();
    iconButtonTertiaryModel22.dispose();
    iconButtonTertiaryModel23.dispose();
    iconButtonTertiaryModel24.dispose();
    iconButtonTertiaryModel25.dispose();
    expandableExpandableController3.dispose();
    dateandTimeRecordeModel4.dispose();
    iconButtonTertiaryModel26.dispose();
    iconButtonTertiaryModel27.dispose();
    iconButtonTertiaryModel28.dispose();
    iconButtonTertiaryModel29.dispose();
    iconButtonTertiaryModel30.dispose();
    iconButtonTertiaryModel31.dispose();
    iconButtonTertiaryModel32.dispose();
    expandableExpandableController4.dispose();
    iconButtonSecondaryModel2.dispose();
    iconButtonTertiaryModel33.dispose();
    dateandTimeRecordeModel5.dispose();
    iconButtonTertiaryModel34.dispose();
    iconButtonTertiaryModel35.dispose();
    dateandTimeRecordeModel6.dispose();
    iconButtonTertiaryModel36.dispose();
    dateandTimeRecordeModel7.dispose();
    iconButtonTertiaryModel37.dispose();
  }
}
