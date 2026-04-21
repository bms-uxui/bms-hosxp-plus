import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/order_sheet/info_staff/info_staff_widget.dart';
import 'dart:ui';
import 'item_off_widget.dart' show ItemOffWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemOffModel extends FlutterFlowModel<ItemOffWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for info_staff component.
  late InfoStaffModel infoStaffModel;

  @override
  void initState(BuildContext context) {
    infoStaffModel = createModel(context, () => InfoStaffModel());
  }

  @override
  void dispose() {
    infoStaffModel.dispose();
  }
}
