import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/admit/item_surgicalhistory/item_surgicalhistory_widget.dart';
import 'dart:ui';
import 'operative_note_view_widget.dart' show OperativeNoteViewWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class OperativeNoteViewModel extends FlutterFlowModel<OperativeNoteViewWidget> {
  ///  Local state fields for this component.

  bool buttonReport = true;

  ///  State fields for stateful widgets in this component.

  // Model for Item_Surgicalhistory component.
  late ItemSurgicalhistoryModel itemSurgicalhistoryModel;

  @override
  void initState(BuildContext context) {
    itemSurgicalhistoryModel =
        createModel(context, () => ItemSurgicalhistoryModel());
  }

  @override
  void dispose() {
    itemSurgicalhistoryModel.dispose();
  }
}
