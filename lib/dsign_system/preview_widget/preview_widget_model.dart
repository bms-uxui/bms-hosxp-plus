import '/dsign_system/alertdialog/alert_dialog_delete/alert_dialog_delete_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_error/alert_dialog_error_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_generate/alert_dialog_generate_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_information/alert_dialog_information_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_loading/alert_dialog_loading_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_success/alert_dialog_success_widget.dart';
import '/dsign_system/alertdialog/alert_dialog_warning/alert_dialog_warning_widget.dart';
import '/dsign_system/alertdialog/loading/loading_widget.dart';
import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/botton_provider_i_d/botton_provider_i_d_widget.dart';
import '/dsign_system/button_styles/botton_secondary/botton_secondary_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/check_box_style/check_box/check_box_widget.dart';
import '/dsign_system/from_field/button_sheet_datepicker/button_sheet_datepicker_widget.dart';
import '/dsign_system/search_bar_style/search_bar_primary/search_bar_primary_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:async';
import 'dart:ui';
import 'preview_widget_widget.dart' show PreviewWidgetWidget;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PreviewWidgetModel extends FlutterFlowModel<PreviewWidgetWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel1;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel2;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel3;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel4;
  // Model for BottonProviderID component.
  late BottonProviderIDModel bottonProviderIDModel;
  // Model for BottonSecondary component.
  late BottonSecondaryModel bottonSecondaryModel;
  // Model for ButtonAIgenerate component.
  late ButtonAIgenerateModel buttonAIgenerateModel;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel1;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel2;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel3;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel1;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel2;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel3;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel4;
  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel5;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel1;
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
  // Model for SearchBarPrimary component.
  late SearchBarPrimaryModel searchBarPrimaryModel;
  // Model for CheckBox component.
  late CheckBoxModel checkBoxModel1;
  // Model for CheckBox component.
  late CheckBoxModel checkBoxModel2;
  // Model for CheckBox component.
  late CheckBoxModel checkBoxModel3;
  // Model for CheckBox component.
  late CheckBoxModel checkBoxModel4;
  // State field(s) for Switch widget.
  bool? switchValue1;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // State field(s) for RadioButton widget.
  FormFieldController<String>? radioButtonValueController;

  @override
  void initState(BuildContext context) {
    bottonPrimaryModel1 = createModel(context, () => BottonPrimaryModel());
    bottonPrimaryModel2 = createModel(context, () => BottonPrimaryModel());
    bottonPrimaryModel3 = createModel(context, () => BottonPrimaryModel());
    bottonPrimaryModel4 = createModel(context, () => BottonPrimaryModel());
    bottonProviderIDModel = createModel(context, () => BottonProviderIDModel());
    bottonSecondaryModel = createModel(context, () => BottonSecondaryModel());
    buttonAIgenerateModel = createModel(context, () => ButtonAIgenerateModel());
    iconButtonPrimaryModel1 =
        createModel(context, () => IconButtonPrimaryModel());
    iconButtonPrimaryModel2 =
        createModel(context, () => IconButtonPrimaryModel());
    iconButtonPrimaryModel3 =
        createModel(context, () => IconButtonPrimaryModel());
    iconButtonSecondaryModel1 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonSecondaryModel2 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonSecondaryModel3 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonSecondaryModel4 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonSecondaryModel5 =
        createModel(context, () => IconButtonSecondaryModel());
    iconButtonTertiaryModel1 =
        createModel(context, () => IconButtonTertiaryModel());
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
    searchBarPrimaryModel = createModel(context, () => SearchBarPrimaryModel());
    checkBoxModel1 = createModel(context, () => CheckBoxModel());
    checkBoxModel2 = createModel(context, () => CheckBoxModel());
    checkBoxModel3 = createModel(context, () => CheckBoxModel());
    checkBoxModel4 = createModel(context, () => CheckBoxModel());
  }

  @override
  void dispose() {
    bottonPrimaryModel1.dispose();
    bottonPrimaryModel2.dispose();
    bottonPrimaryModel3.dispose();
    bottonPrimaryModel4.dispose();
    bottonProviderIDModel.dispose();
    bottonSecondaryModel.dispose();
    buttonAIgenerateModel.dispose();
    iconButtonPrimaryModel1.dispose();
    iconButtonPrimaryModel2.dispose();
    iconButtonPrimaryModel3.dispose();
    iconButtonSecondaryModel1.dispose();
    iconButtonSecondaryModel2.dispose();
    iconButtonSecondaryModel3.dispose();
    iconButtonSecondaryModel4.dispose();
    iconButtonSecondaryModel5.dispose();
    iconButtonTertiaryModel1.dispose();
    iconButtonTertiaryModel2.dispose();
    iconButtonTertiaryModel3.dispose();
    iconButtonTertiaryModel4.dispose();
    iconButtonTertiaryModel5.dispose();
    iconButtonTertiaryModel6.dispose();
    searchBarPrimaryModel.dispose();
    checkBoxModel1.dispose();
    checkBoxModel2.dispose();
    checkBoxModel3.dispose();
    checkBoxModel4.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
