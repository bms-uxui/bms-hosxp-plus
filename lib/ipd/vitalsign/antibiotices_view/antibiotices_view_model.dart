import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/item_antibiotices/item_antibiotices_widget.dart';
import 'dart:ui';
import 'antibiotices_view_widget.dart' show AntibioticesViewWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AntibioticesViewModel extends FlutterFlowModel<AntibioticesViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Item_Antibiotices component.
  late ItemAntibioticesModel itemAntibioticesModel1;
  // Model for Item_Antibiotices component.
  late ItemAntibioticesModel itemAntibioticesModel2;

  @override
  void initState(BuildContext context) {
    itemAntibioticesModel1 =
        createModel(context, () => ItemAntibioticesModel());
    itemAntibioticesModel2 =
        createModel(context, () => ItemAntibioticesModel());
  }

  @override
  void dispose() {
    itemAntibioticesModel1.dispose();
    itemAntibioticesModel2.dispose();
  }
}
