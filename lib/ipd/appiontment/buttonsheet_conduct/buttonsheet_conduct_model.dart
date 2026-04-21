import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_conduct_widget.dart' show ButtonsheetConductWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetConductModel
    extends FlutterFlowModel<ButtonsheetConductWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // State field(s) for Checkbox widget.
  bool? checkboxValue3;

  @override
  void initState(BuildContext context) {
    searchBarSecondaryModel =
        createModel(context, () => SearchBarSecondaryModel());
  }

  @override
  void dispose() {
    searchBarSecondaryModel.dispose();
  }
}
