import '/dsign_system/not_data/not_data_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'graphicsheetpage_view_widget.dart' show GraphicsheetpageViewWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GraphicsheetpageViewModel
    extends FlutterFlowModel<GraphicsheetpageViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Not_Data component.
  late NotDataModel notDataModel;

  @override
  void initState(BuildContext context) {
    notDataModel = createModel(context, () => NotDataModel());
  }

  @override
  void dispose() {
    notDataModel.dispose();
  }
}
