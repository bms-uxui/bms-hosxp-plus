import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/buttonsheet_department_detial/buttonsheet_department_detial_widget.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/main/widget/item_department_m1/item_department_m1_widget.dart';
import '/main/widget/item_department_m10/item_department_m10_widget.dart';
import '/main/widget/item_department_m2/item_department_m2_widget.dart';
import '/main/widget/item_department_m3/item_department_m3_widget.dart';
import '/main/widget/item_department_m4/item_department_m4_widget.dart';
import '/main/widget/item_department_m5/item_department_m5_widget.dart';
import '/main/widget/item_department_m6/item_department_m6_widget.dart';
import '/main/widget/item_department_m7/item_department_m7_widget.dart';
import '/main/widget/item_department_m8/item_department_m8_widget.dart';
import '/main/widget/item_department_m9/item_department_m9_widget.dart';
import 'dart:ui';
import 'doctors_rounds_mainpage_widget.dart' show DoctorsRoundsMainpageWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DoctorsRoundsMainpageModel
    extends FlutterFlowModel<DoctorsRoundsMainpageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;
  // Model for Item_DepartmentM1 component.
  late ItemDepartmentM1Model itemDepartmentM1Model;
  // Model for Item_DepartmentM2 component.
  late ItemDepartmentM2Model itemDepartmentM2Model;
  // Model for Item_DepartmentM3 component.
  late ItemDepartmentM3Model itemDepartmentM3Model;
  // Model for Item_DepartmentM4 component.
  late ItemDepartmentM4Model itemDepartmentM4Model;
  // Model for Item_DepartmentM5 component.
  late ItemDepartmentM5Model itemDepartmentM5Model;
  // Model for Item_DepartmentM6 component.
  late ItemDepartmentM6Model itemDepartmentM6Model;
  // Model for Item_DepartmentM7 component.
  late ItemDepartmentM7Model itemDepartmentM7Model;
  // Model for Item_DepartmentM8 component.
  late ItemDepartmentM8Model itemDepartmentM8Model;
  // Model for Item_DepartmentM9 component.
  late ItemDepartmentM9Model itemDepartmentM9Model;
  // Model for Item_DepartmentM10 component.
  late ItemDepartmentM10Model itemDepartmentM10Model;

  @override
  void initState(BuildContext context) {
    iconTitleModel = createModel(context, () => IconTitleModel());
    itemDepartmentM1Model = createModel(context, () => ItemDepartmentM1Model());
    itemDepartmentM2Model = createModel(context, () => ItemDepartmentM2Model());
    itemDepartmentM3Model = createModel(context, () => ItemDepartmentM3Model());
    itemDepartmentM4Model = createModel(context, () => ItemDepartmentM4Model());
    itemDepartmentM5Model = createModel(context, () => ItemDepartmentM5Model());
    itemDepartmentM6Model = createModel(context, () => ItemDepartmentM6Model());
    itemDepartmentM7Model = createModel(context, () => ItemDepartmentM7Model());
    itemDepartmentM8Model = createModel(context, () => ItemDepartmentM8Model());
    itemDepartmentM9Model = createModel(context, () => ItemDepartmentM9Model());
    itemDepartmentM10Model =
        createModel(context, () => ItemDepartmentM10Model());
  }

  @override
  void dispose() {
    iconTitleModel.dispose();
    itemDepartmentM1Model.dispose();
    itemDepartmentM2Model.dispose();
    itemDepartmentM3Model.dispose();
    itemDepartmentM4Model.dispose();
    itemDepartmentM5Model.dispose();
    itemDepartmentM6Model.dispose();
    itemDepartmentM7Model.dispose();
    itemDepartmentM8Model.dispose();
    itemDepartmentM9Model.dispose();
    itemDepartmentM10Model.dispose();
  }
}
