import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/login/item_branch/item_branch_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'select_branch_widget.dart' show SelectBranchWidget;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SelectBranchModel extends FlutterFlowModel<SelectBranchWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Item_branch component.
  late ItemBranchModel itemBranchModel1;
  // Model for Item_branch component.
  late ItemBranchModel itemBranchModel2;
  // Model for Item_branch component.
  late ItemBranchModel itemBranchModel3;

  @override
  void initState(BuildContext context) {
    itemBranchModel1 = createModel(context, () => ItemBranchModel());
    itemBranchModel2 = createModel(context, () => ItemBranchModel());
    itemBranchModel3 = createModel(context, () => ItemBranchModel());
  }

  @override
  void dispose() {
    itemBranchModel1.dispose();
    itemBranchModel2.dispose();
    itemBranchModel3.dispose();
  }
}
