import '/dsign_system/from_field/count_controller/count_controller_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/er/drugand_service/buttonsheet_frequency/buttonsheet_frequency_widget.dart';
import '/er/drugand_service/buttonsheet_route_medication/buttonsheet_route_medication_widget.dart';
import '/er/drugand_service/buttonsheet_time_coe/buttonsheet_time_coe_widget.dart';
import '/er/drugand_service/buttonsheet_unit/buttonsheet_unit_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'item_drug_oder_widget.dart' show ItemDrugOderWidget;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemDrugOderModel extends FlutterFlowModel<ItemDrugOderWidget> {
  ///  Local state fields for this component.

  int? mode = 2;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for Dropdown component.
  late DropdownModel dropdownModel1;
  // Model for CountController component.
  late CountControllerModel countControllerModel;
  // Model for Dropdown component.
  late DropdownModel dropdownModel2;
  // Model for Dropdown component.
  late DropdownModel dropdownModel3;
  // Model for Dropdown component.
  late DropdownModel dropdownModel4;
  // Model for Dropdown component.
  late DropdownModel dropdownModel5;

  @override
  void initState(BuildContext context) {
    dropdownModel1 = createModel(context, () => DropdownModel());
    countControllerModel = createModel(context, () => CountControllerModel());
    dropdownModel2 = createModel(context, () => DropdownModel());
    dropdownModel3 = createModel(context, () => DropdownModel());
    dropdownModel4 = createModel(context, () => DropdownModel());
    dropdownModel5 = createModel(context, () => DropdownModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    dropdownModel1.dispose();
    countControllerModel.dispose();
    dropdownModel2.dispose();
    dropdownModel3.dispose();
    dropdownModel4.dispose();
    dropdownModel5.dispose();
  }
}
