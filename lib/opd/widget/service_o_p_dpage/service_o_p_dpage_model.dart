import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/opd/widget/i_c_d10_treatment_o_p_d/i_c_d10_treatment_o_p_d_widget.dart';
import '/opd/widget/item_department_o1/item_department_o1_widget.dart';
import '/opd/widget/item_department_o10/item_department_o10_widget.dart';
import '/opd/widget/item_department_o2/item_department_o2_widget.dart';
import '/opd/widget/item_department_o3/item_department_o3_widget.dart';
import '/opd/widget/item_department_o4/item_department_o4_widget.dart';
import '/opd/widget/item_department_o5/item_department_o5_widget.dart';
import '/opd/widget/item_department_o6/item_department_o6_widget.dart';
import '/opd/widget/item_department_o7/item_department_o7_widget.dart';
import '/opd/widget/item_department_o8/item_department_o8_widget.dart';
import '/opd/widget/item_department_o9/item_department_o9_widget.dart';
import '/opd/widget/tab_n_s/tab_n_s_widget.dart';
import '/opd/widget/tab_t_r/tab_t_r_widget.dart';
import 'dart:ui';
import 'service_o_p_dpage_widget.dart' show ServiceOPDpageWidget;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ServiceOPDpageModel extends FlutterFlowModel<ServiceOPDpageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;
  // Model for Tab_NS component.
  late TabNSModel tabNSModel;
  // Model for Tab_TR component.
  late TabTRModel tabTRModel;
  // Model for ICD10_TreatmentOPD component.
  late ICD10TreatmentOPDModel iCD10TreatmentOPDModel;
  // Model for Item_DepartmentO1 component.
  late ItemDepartmentO1Model itemDepartmentO1Model;
  // Model for Item_DepartmentO2 component.
  late ItemDepartmentO2Model itemDepartmentO2Model;
  // Model for Item_DepartmentO3 component.
  late ItemDepartmentO3Model itemDepartmentO3Model;
  // Model for Item_DepartmentO4 component.
  late ItemDepartmentO4Model itemDepartmentO4Model;
  // Model for Item_DepartmentO5 component.
  late ItemDepartmentO5Model itemDepartmentO5Model;
  // Model for Item_DepartmentO6 component.
  late ItemDepartmentO6Model itemDepartmentO6Model;
  // Model for Item_DepartmentO7 component.
  late ItemDepartmentO7Model itemDepartmentO7Model;
  // Model for Item_DepartmentO8 component.
  late ItemDepartmentO8Model itemDepartmentO8Model;
  // Model for Item_DepartmentO9 component.
  late ItemDepartmentO9Model itemDepartmentO9Model;
  // Model for Item_DepartmentO10 component.
  late ItemDepartmentO10Model itemDepartmentO10Model;

  @override
  void initState(BuildContext context) {
    iconTitleModel = createModel(context, () => IconTitleModel());
    tabNSModel = createModel(context, () => TabNSModel());
    tabTRModel = createModel(context, () => TabTRModel());
    iCD10TreatmentOPDModel =
        createModel(context, () => ICD10TreatmentOPDModel());
    itemDepartmentO1Model = createModel(context, () => ItemDepartmentO1Model());
    itemDepartmentO2Model = createModel(context, () => ItemDepartmentO2Model());
    itemDepartmentO3Model = createModel(context, () => ItemDepartmentO3Model());
    itemDepartmentO4Model = createModel(context, () => ItemDepartmentO4Model());
    itemDepartmentO5Model = createModel(context, () => ItemDepartmentO5Model());
    itemDepartmentO6Model = createModel(context, () => ItemDepartmentO6Model());
    itemDepartmentO7Model = createModel(context, () => ItemDepartmentO7Model());
    itemDepartmentO8Model = createModel(context, () => ItemDepartmentO8Model());
    itemDepartmentO9Model = createModel(context, () => ItemDepartmentO9Model());
    itemDepartmentO10Model =
        createModel(context, () => ItemDepartmentO10Model());
  }

  @override
  void dispose() {
    iconTitleModel.dispose();
    tabNSModel.dispose();
    tabTRModel.dispose();
    iCD10TreatmentOPDModel.dispose();
    itemDepartmentO1Model.dispose();
    itemDepartmentO2Model.dispose();
    itemDepartmentO3Model.dispose();
    itemDepartmentO4Model.dispose();
    itemDepartmentO5Model.dispose();
    itemDepartmentO6Model.dispose();
    itemDepartmentO7Model.dispose();
    itemDepartmentO8Model.dispose();
    itemDepartmentO9Model.dispose();
    itemDepartmentO10Model.dispose();
  }
}
