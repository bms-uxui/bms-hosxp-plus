import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'fillter_treatment_i_p_d_widget.dart' show FillterTreatmentIPDWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FillterTreatmentIPDModel
    extends FlutterFlowModel<FillterTreatmentIPDWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;

  @override
  void initState(BuildContext context) {
    calendarSelectedDay = DateTimeRange(
      start: DateTime.now().startOfDay,
      end: DateTime.now().endOfDay,
    );
  }

  @override
  void dispose() {}
}
