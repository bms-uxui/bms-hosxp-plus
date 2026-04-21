import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/buttonsheet_clinic/buttonsheet_clinic_widget.dart';
import '/ipd/appiontment/buttonsheet_conduct/buttonsheet_conduct_widget.dart';
import '/ipd/appiontment/buttonsheet_department/buttonsheet_department_widget.dart';
import '/ipd/appiontment/buttonsheet_reasonforappointment/buttonsheet_reasonforappointment_widget.dart';
import '/ipd/appiontment/fillter_date_appiontment/fillter_date_appiontment_widget.dart';
import '/ipd/appiontment/item_conduct/item_conduct_widget.dart';
import '/ipd/consult/buttonsheet_examinationroom/buttonsheet_examinationroom_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_appiontment_widget.dart' show AddAppiontmentWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddAppiontmentModel extends FlutterFlowModel<AddAppiontmentWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for ListView widget.
  ScrollController? listViewController;
  // Model for IconButtonTertiary component.
  late IconButtonTertiaryModel iconButtonTertiaryModel;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel;
  // State field(s) for StaggeredView widget.
  ScrollController? staggeredViewController1;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel1;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // State field(s) for StaggeredView widget.
  ScrollController? staggeredViewController2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // Model for Dropdown component.
  late DropdownModel dropdownModel5;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for Item_Conduct component.
  late ItemConductModel itemConductModel1;
  // Model for Item_Conduct component.
  late ItemConductModel itemConductModel2;
  // Model for Item_Conduct component.
  late ItemConductModel itemConductModel3;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    listViewController = ScrollController();
    iconButtonTertiaryModel =
        createModel(context, () => IconButtonTertiaryModel());
    datePickerModel = createModel(context, () => DatePickerModel());
    staggeredViewController1 = ScrollController();
    timePickerModel1 = createModel(context, () => TimePickerModel());
    timePickerModel2 = createModel(context, () => TimePickerModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    staggeredViewController2 = ScrollController();
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    itemConductModel1 = createModel(context, () => ItemConductModel());
    itemConductModel2 = createModel(context, () => ItemConductModel());
    itemConductModel3 = createModel(context, () => ItemConductModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    listViewController?.dispose();
    iconButtonTertiaryModel.dispose();
    datePickerModel.dispose();
    staggeredViewController1?.dispose();
    timePickerModel1.dispose();
    timePickerModel2.dispose();
    dropdownModel1.dispose();
    dropdownModel2.dispose();
    staggeredViewController2?.dispose();
    dropdownModel3.dispose();
    dropdownModel4.dispose();
    dropdownModel5.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    iconButtonPrimaryModel.dispose();
    itemConductModel1.dispose();
    itemConductModel2.dispose();
    itemConductModel3.dispose();
    bottonPrimaryModel.dispose();
  }
}
