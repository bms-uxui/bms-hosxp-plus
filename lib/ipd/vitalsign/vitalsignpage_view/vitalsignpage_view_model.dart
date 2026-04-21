import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/antibiotices_view/antibiotices_view_widget.dart';
import '/ipd/vitalsign/graphicsheetpage_view/graphicsheetpage_view_widget.dart';
import '/ipd/vitalsign/nurs_probltm_view/nurs_probltm_view_widget.dart';
import '/ipd/vitalsign/nurw_records_view/nurw_records_view_widget.dart';
import '/ipd/vitalsign/treatment_view/treatment_view_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'vitalsignpage_view_widget.dart' show VitalsignpageViewWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VitalsignpageViewModel extends FlutterFlowModel<VitalsignpageViewWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Graphicsheetpage_View component.
  late GraphicsheetpageViewModel graphicsheetpageViewModel;
  // Model for Antibiotices_View component.
  late AntibioticesViewModel antibioticesViewModel;
  // Model for NurwRecords_View component.
  late NurwRecordsViewModel nurwRecordsViewModel;
  // Model for NursProbltm_View component.
  late NursProbltmViewModel nursProbltmViewModel;
  // Model for Treatment_View component.
  late TreatmentViewModel treatmentViewModel;

  @override
  void initState(BuildContext context) {
    graphicsheetpageViewModel =
        createModel(context, () => GraphicsheetpageViewModel());
    antibioticesViewModel = createModel(context, () => AntibioticesViewModel());
    nurwRecordsViewModel = createModel(context, () => NurwRecordsViewModel());
    nursProbltmViewModel = createModel(context, () => NursProbltmViewModel());
    treatmentViewModel = createModel(context, () => TreatmentViewModel());
  }

  @override
  void dispose() {
    graphicsheetpageViewModel.dispose();
    antibioticesViewModel.dispose();
    nurwRecordsViewModel.dispose();
    nursProbltmViewModel.dispose();
    treatmentViewModel.dispose();
  }
}
