import '/er/drugand_service/tag_price/tag_price_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/medical_certificate/more_medicalcertificate/more_medicalcertificate_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'medicatin_order_detail2_widget.dart' show MedicatinOrderDetail2Widget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MedicatinOrderDetail2Model
    extends FlutterFlowModel<MedicatinOrderDetail2Widget> {
  ///  State fields for stateful widgets in this page.

  // Model for Tag_price component.
  late TagPriceModel tagPriceModel;

  @override
  void initState(BuildContext context) {
    tagPriceModel = createModel(context, () => TagPriceModel());
  }

  @override
  void dispose() {
    tagPriceModel.dispose();
  }
}
