import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'item_set_o_r_widget.dart' show ItemSetORWidget;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemSetORModel extends FlutterFlowModel<ItemSetORWidget> {
  ///  Local state fields for this component.

  int? mode = 2;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel1;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel1;
  // Model for DatePicker component.
  late DatePickerModel datePickerModel2;
  // Model for TimePicker component.
  late TimePickerModel timePickerModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel;

  @override
  void initState(BuildContext context) {
    datePickerModel1 = createModel(context, () => DatePickerModel());
    timePickerModel1 = createModel(context, () => TimePickerModel());
    datePickerModel2 = createModel(context, () => DatePickerModel());
    timePickerModel2 = createModel(context, () => TimePickerModel());
    dropdownModel = createModel(context, () => DropdownModel());
  }

  @override
  void dispose() {
    datePickerModel1.dispose();
    timePickerModel1.dispose();
    datePickerModel2.dispose();
    timePickerModel2.dispose();
    dropdownModel.dispose();
  }
}
