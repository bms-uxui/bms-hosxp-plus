import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/buttonsheet_dutydoctor/buttonsheet_dutydoctor_widget.dart';
import '/ipd/vitalsign/buttonsheet_i_d/buttonsheet_i_d_widget.dart';
import '/ipd/vitalsign/buttonsheet_nursingrecords_type/buttonsheet_nursingrecords_type_widget.dart';
import '/ipd/vitalsign/form_data/form_data_widget.dart';
import '/ipd/vitalsign/form_fluid/form_fluid_widget.dart';
import '/ipd/vitalsign/form_pregnancy/form_pregnancy_widget.dart';
import '/ipd/vitalsign/form_vitalsign/form_vitalsign_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_nursingrecords_widget.dart' show AddNursingrecordsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddNursingrecordsModel extends FlutterFlowModel<AddNursingrecordsWidget> {
  ///  Local state fields for this page.

  int? tabmenu = 1;

  ///  State fields for stateful widgets in this page.

  // Model for ButtonAIgenerate component.
  late ButtonAIgenerateModel buttonAIgenerateModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // Model for form_data component.
  late FormDataModel formDataModel;
  // Model for form_vitalsign component.
  late FormVitalsignModel formVitalsignModel;
  // Model for form_Fluid component.
  late FormFluidModel formFluidModel;
  // Model for form_Pregnancy component.
  late FormPregnancyModel formPregnancyModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    buttonAIgenerateModel = createModel(context, () => ButtonAIgenerateModel());
    dropdownModel1 = createModel(context, () => DropdownModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    datePickerModel = createModel(context, () => DatePickerModel());
    timePickerModel = createModel(context, () => TimePickerModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    formDataModel = createModel(context, () => FormDataModel());
    formVitalsignModel = createModel(context, () => FormVitalsignModel());
    formFluidModel = createModel(context, () => FormFluidModel());
    formPregnancyModel = createModel(context, () => FormPregnancyModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    buttonAIgenerateModel.dispose();
    dropdownModel1.dispose();
    dropdownModel2.dispose();
    datePickerModel.dispose();
    timePickerModel.dispose();
    dropdownModel3.dispose();
    formDataModel.dispose();
    formVitalsignModel.dispose();
    formFluidModel.dispose();
    formPregnancyModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
