import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/drugand_service/drunglist_view/drunglist_view_widget.dart';
import '/ipd/drugand_service/item_service/item_service_widget.dart';
import 'dart:ui';
import 'drug_srevice_view_widget.dart' show DrugSreviceViewWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DrugSreviceViewModel extends FlutterFlowModel<DrugSreviceViewWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for DrunglistView component.
  late DrunglistViewModel drunglistViewModel;
  // Model for Item_Service component.
  late ItemServiceModel itemServiceModel;

  @override
  void initState(BuildContext context) {
    drunglistViewModel = createModel(context, () => DrunglistViewModel());
    itemServiceModel = createModel(context, () => ItemServiceModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    drunglistViewModel.dispose();
    itemServiceModel.dispose();
  }
}
