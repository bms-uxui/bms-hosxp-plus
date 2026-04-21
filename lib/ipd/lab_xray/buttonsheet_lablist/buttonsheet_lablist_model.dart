import '/dsign_system/search_bar_style/search_bar_secondary/search_bar_secondary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'buttonsheet_lablist_widget.dart' show ButtonsheetLablistWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonsheetLablistModel
    extends FlutterFlowModel<ButtonsheetLablistWidget> {
  ///  Local state fields for this component.

  int? itemlab;

  ///  State fields for stateful widgets in this component.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // State field(s) for Checkbox widget.
  bool? checkboxValue3;
  // State field(s) for Checkbox widget.
  bool? checkboxValue4;
  // State field(s) for Checkbox widget.
  bool? checkboxValue5;
  // State field(s) for Checkbox widget.
  bool? checkboxValue6;
  // State field(s) for Checkbox widget.
  bool? checkboxValue7;
  // State field(s) for Checkbox widget.
  bool? checkboxValue8;
  // State field(s) for Checkbox widget.
  bool? checkboxValue9;
  // State field(s) for Checkbox widget.
  bool? checkboxValue10;
  // State field(s) for Checkbox widget.
  bool? checkboxValue11;
  // State field(s) for Checkbox widget.
  bool? checkboxValue12;
  // State field(s) for Checkbox widget.
  bool? checkboxValue13;
  // State field(s) for Checkbox widget.
  bool? checkboxValue14;
  // State field(s) for Checkbox widget.
  bool? checkboxValue15;
  // Model for SearchBarSecondary component.
  late SearchBarSecondaryModel searchBarSecondaryModel2;
  // State field(s) for Checkbox widget.
  bool? checkboxValue16;
  // State field(s) for Checkbox widget.
  bool? checkboxValue17;
  // State field(s) for Checkbox widget.
  bool? checkboxValue18;
  // State field(s) for Checkbox widget.
  bool? checkboxValue19;
  // State field(s) for Checkbox widget.
  bool? checkboxValue20;
  // State field(s) for Checkbox widget.
  bool? checkboxValue21;
  // State field(s) for Checkbox widget.
  bool? checkboxValue22;
  // State field(s) for Checkbox widget.
  bool? checkboxValue23;
  // State field(s) for Checkbox widget.
  bool? checkboxValue24;
  // State field(s) for Checkbox widget.
  bool? checkboxValue25;
  // State field(s) for Checkbox widget.
  bool? checkboxValue26;

  @override
  void initState(BuildContext context) {
    searchBarSecondaryModel1 =
        createModel(context, () => SearchBarSecondaryModel());
    searchBarSecondaryModel2 =
        createModel(context, () => SearchBarSecondaryModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    searchBarSecondaryModel1.dispose();
    searchBarSecondaryModel2.dispose();
  }
}
