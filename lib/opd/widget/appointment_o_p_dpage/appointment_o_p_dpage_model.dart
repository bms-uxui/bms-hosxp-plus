import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import 'dart:ui';
import 'appointment_o_p_dpage_widget.dart' show AppointmentOPDpageWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppointmentOPDpageModel
    extends FlutterFlowModel<AppointmentOPDpageWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Icon_Title component.
  late IconTitleModel iconTitleModel;

  @override
  void initState(BuildContext context) {
    iconTitleModel = createModel(context, () => IconTitleModel());
  }

  @override
  void dispose() {
    iconTitleModel.dispose();
  }
}
