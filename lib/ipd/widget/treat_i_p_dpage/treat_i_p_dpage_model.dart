import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/widget/item_department_i1/item_department_i1_widget.dart';
import '/ipd/widget/item_department_i10/item_department_i10_widget.dart';
import '/ipd/widget/item_department_i11/item_department_i11_widget.dart';
import '/ipd/widget/item_department_i2/item_department_i2_widget.dart';
import '/ipd/widget/item_department_i3/item_department_i3_widget.dart';
import '/ipd/widget/item_department_i4/item_department_i4_widget.dart';
import '/ipd/widget/item_department_i5/item_department_i5_widget.dart';
import '/ipd/widget/item_department_i6/item_department_i6_widget.dart';
import '/ipd/widget/item_department_i7/item_department_i7_widget.dart';
import '/ipd/widget/item_department_i8/item_department_i8_widget.dart';
import '/ipd/widget/item_department_i9/item_department_i9_widget.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/opd/widget/i_c_d10_treatment_o_p_d/i_c_d10_treatment_o_p_d_widget.dart';
import 'dart:ui';
import 'treat_i_p_dpage_widget.dart' show TreatIPDpageWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TreatIPDpageModel extends FlutterFlowModel<TreatIPDpageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;
  // Model for ICD10_TreatmentOPD component.
  late ICD10TreatmentOPDModel iCD10TreatmentOPDModel;
  // Model for Item_DepartmentI1 component.
  late ItemDepartmentI1Model itemDepartmentI1Model;
  // Model for Item_DepartmentI2 component.
  late ItemDepartmentI2Model itemDepartmentI2Model;
  // Model for Item_DepartmentI3 component.
  late ItemDepartmentI3Model itemDepartmentI3Model;
  // Model for Item_DepartmentI4 component.
  late ItemDepartmentI4Model itemDepartmentI4Model;
  // Model for Item_DepartmentI5 component.
  late ItemDepartmentI5Model itemDepartmentI5Model;
  // Model for Item_DepartmentI6 component.
  late ItemDepartmentI6Model itemDepartmentI6Model;
  // Model for Item_DepartmentI7 component.
  late ItemDepartmentI7Model itemDepartmentI7Model;
  // Model for Item_DepartmentI8 component.
  late ItemDepartmentI8Model itemDepartmentI8Model;
  // Model for Item_DepartmentI9 component.
  late ItemDepartmentI9Model itemDepartmentI9Model;
  // Model for Item_DepartmentI10 component.
  late ItemDepartmentI10Model itemDepartmentI10Model;
  // Model for Item_DepartmentI11 component.
  late ItemDepartmentI11Model itemDepartmentI11Model;

  @override
  void initState(BuildContext context) {
    iconTitleModel = createModel(context, () => IconTitleModel());
    iCD10TreatmentOPDModel =
        createModel(context, () => ICD10TreatmentOPDModel());
    itemDepartmentI1Model = createModel(context, () => ItemDepartmentI1Model());
    itemDepartmentI2Model = createModel(context, () => ItemDepartmentI2Model());
    itemDepartmentI3Model = createModel(context, () => ItemDepartmentI3Model());
    itemDepartmentI4Model = createModel(context, () => ItemDepartmentI4Model());
    itemDepartmentI5Model = createModel(context, () => ItemDepartmentI5Model());
    itemDepartmentI6Model = createModel(context, () => ItemDepartmentI6Model());
    itemDepartmentI7Model = createModel(context, () => ItemDepartmentI7Model());
    itemDepartmentI8Model = createModel(context, () => ItemDepartmentI8Model());
    itemDepartmentI9Model = createModel(context, () => ItemDepartmentI9Model());
    itemDepartmentI10Model =
        createModel(context, () => ItemDepartmentI10Model());
    itemDepartmentI11Model =
        createModel(context, () => ItemDepartmentI11Model());
  }

  @override
  void dispose() {
    iconTitleModel.dispose();
    iCD10TreatmentOPDModel.dispose();
    itemDepartmentI1Model.dispose();
    itemDepartmentI2Model.dispose();
    itemDepartmentI3Model.dispose();
    itemDepartmentI4Model.dispose();
    itemDepartmentI5Model.dispose();
    itemDepartmentI6Model.dispose();
    itemDepartmentI7Model.dispose();
    itemDepartmentI8Model.dispose();
    itemDepartmentI9Model.dispose();
    itemDepartmentI10Model.dispose();
    itemDepartmentI11Model.dispose();
  }
}
