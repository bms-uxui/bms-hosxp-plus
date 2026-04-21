import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/main/widget/item_medicineroom/item_medicineroom_widget.dart';
import '/main/widget/item_right_treatment/item_right_treatment_widget.dart';
import '/main/widget/workflow/workflow_widget.dart';
import 'dart:ui';
import 'o_p_d_mainpage_widget.dart' show OPDMainpageWidget;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OPDMainpageModel extends FlutterFlowModel<OPDMainpageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;
  // Model for Workflow component.
  late WorkflowModel workflowModel;
  // Model for Item_Medicineroom component.
  late ItemMedicineroomModel itemMedicineroomModel1;
  // Model for Item_Medicineroom component.
  late ItemMedicineroomModel itemMedicineroomModel2;
  // Model for Item_Right_Treatment component.
  late ItemRightTreatmentModel itemRightTreatmentModel1;
  // Model for Item_Right_Treatment component.
  late ItemRightTreatmentModel itemRightTreatmentModel2;
  // Model for Item_Right_Treatment component.
  late ItemRightTreatmentModel itemRightTreatmentModel3;

  @override
  void initState(BuildContext context) {
    iconTitleModel = createModel(context, () => IconTitleModel());
    workflowModel = createModel(context, () => WorkflowModel());
    itemMedicineroomModel1 =
        createModel(context, () => ItemMedicineroomModel());
    itemMedicineroomModel2 =
        createModel(context, () => ItemMedicineroomModel());
    itemRightTreatmentModel1 =
        createModel(context, () => ItemRightTreatmentModel());
    itemRightTreatmentModel2 =
        createModel(context, () => ItemRightTreatmentModel());
    itemRightTreatmentModel3 =
        createModel(context, () => ItemRightTreatmentModel());
  }

  @override
  void dispose() {
    iconTitleModel.dispose();
    workflowModel.dispose();
    itemMedicineroomModel1.dispose();
    itemMedicineroomModel2.dispose();
    itemRightTreatmentModel1.dispose();
    itemRightTreatmentModel2.dispose();
    itemRightTreatmentModel3.dispose();
  }
}
