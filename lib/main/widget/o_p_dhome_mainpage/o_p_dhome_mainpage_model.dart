import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/main/widget/workflow/workflow_widget.dart';
import 'dart:ui';
import 'o_p_dhome_mainpage_widget.dart' show OPDhomeMainpageWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OPDhomeMainpageModel extends FlutterFlowModel<OPDhomeMainpageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;
  // Model for Workflow component.
  late WorkflowModel workflowModel;

  @override
  void initState(BuildContext context) {
    iconTitleModel = createModel(context, () => IconTitleModel());
    workflowModel = createModel(context, () => WorkflowModel());
  }

  @override
  void dispose() {
    iconTitleModel.dispose();
    workflowModel.dispose();
  }
}
