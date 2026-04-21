import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/item_nurw_records/item_nurw_records_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'nurw_records_view_widget.dart' show NurwRecordsViewWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NurwRecordsViewModel extends FlutterFlowModel<NurwRecordsViewWidget> {
  ///  Local state fields for this component.

  bool bottonAddNursRecod = true;

  ///  State fields for stateful widgets in this component.

  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for Item_NurwRecords component.
  late ItemNurwRecordsModel itemNurwRecordsModel1;
  // Model for Item_NurwRecords component.
  late ItemNurwRecordsModel itemNurwRecordsModel2;

  @override
  void initState(BuildContext context) {
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    itemNurwRecordsModel1 = createModel(context, () => ItemNurwRecordsModel());
    itemNurwRecordsModel2 = createModel(context, () => ItemNurwRecordsModel());
  }

  @override
  void dispose() {
    iconButtonPrimaryModel.dispose();
    itemNurwRecordsModel1.dispose();
    itemNurwRecordsModel2.dispose();
  }
}
