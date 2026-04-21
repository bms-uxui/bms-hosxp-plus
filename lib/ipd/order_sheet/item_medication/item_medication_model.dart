import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/order_sheet/buttom_off/buttom_off_widget.dart';
import '/ipd/order_sheet/buttonsheet_offorder/buttonsheet_offorder_widget.dart';
import '/ipd/order_sheet/info_staff/info_staff_widget.dart';
import 'dart:ui';
import 'item_medication_widget.dart' show ItemMedicationWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ItemMedicationModel extends FlutterFlowModel<ItemMedicationWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for Buttom_Off component.
  late ButtomOffModel buttomOffModel;
  // Model for info_staff component.
  late InfoStaffModel infoStaffModel;

  @override
  void initState(BuildContext context) {
    buttomOffModel = createModel(context, () => ButtomOffModel());
    infoStaffModel = createModel(context, () => InfoStaffModel());
  }

  @override
  void dispose() {
    buttomOffModel.dispose();
    infoStaffModel.dispose();
  }
}
