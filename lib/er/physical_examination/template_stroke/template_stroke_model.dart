import '/er/physical_examination/item_drug_oder/item_drug_oder_widget.dart';
import '/er/physical_examination/item_set_o_r/item_set_o_r_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'template_stroke_widget.dart' show TemplateStrokeWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TemplateStrokeModel extends FlutterFlowModel<TemplateStrokeWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Item_drugOder component.
  late ItemDrugOderModel itemDrugOderModel1;
  // Model for Item_drugOder component.
  late ItemDrugOderModel itemDrugOderModel2;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // State field(s) for Checkbox widget.
  bool? checkboxValue3;
  // State field(s) for Checkbox widget.
  bool? checkboxValue4;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue5;
  // State field(s) for Checkbox widget.
  bool? checkboxValue6;
  // State field(s) for Checkbox widget.
  bool? checkboxValue7;
  // State field(s) for Checkbox widget.
  bool? checkboxValue8;
  // State field(s) for Checkbox widget.
  bool? checkboxValue9;
  // State field(s) for Checkbox widget.
  bool? checkboxValue10;
  // State field(s) for Checkbox widget.
  bool? checkboxValue11;
  // State field(s) for Checkbox widget.
  bool? checkboxValue12;
  // State field(s) for Checkbox widget.
  bool? checkboxValue13;
  // State field(s) for Checkbox widget.
  bool? checkboxValue14;
  // State field(s) for Checkbox widget.
  bool? checkboxValue15;
  // State field(s) for Checkbox widget.
  bool? checkboxValue16;
  // State field(s) for Checkbox widget.
  bool? checkboxValue17;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue18;
  // Model for Item_SetOR component.
  late ItemSetORModel itemSetORModel;

  @override
  void initState(BuildContext context) {
    itemDrugOderModel1 = createModel(context, () => ItemDrugOderModel());
    itemDrugOderModel2 = createModel(context, () => ItemDrugOderModel());
    itemSetORModel = createModel(context, () => ItemSetORModel());
  }

  @override
  void dispose() {
    itemDrugOderModel1.dispose();
    itemDrugOderModel2.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    itemSetORModel.dispose();
  }
}
