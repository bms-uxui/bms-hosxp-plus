import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/widget/dayof_use/dayof_use_widget.dart';
import 'dart:ui';
import 'item_antibiotices_widget.dart' show ItemAntibioticesWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemAntibioticesModel extends FlutterFlowModel<ItemAntibioticesWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for DayofUse component.
  late DayofUseModel dayofUseModel1;
  // Model for DayofUse component.
  late DayofUseModel dayofUseModel2;

  @override
  void initState(BuildContext context) {
    dayofUseModel1 = createModel(context, () => DayofUseModel());
    dayofUseModel2 = createModel(context, () => DayofUseModel());
  }

  @override
  void dispose() {
    dayofUseModel1.dispose();
    dayofUseModel2.dispose();
  }
}
