import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'button_sheet_datepicker_widget.dart' show ButtonSheetDatepickerWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ButtonSheetDatepickerModel
    extends FlutterFlowModel<ButtonSheetDatepickerWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Calendar widget.
  DateTimeRange? calendarSelectedDay;

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
