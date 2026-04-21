import '/dsign_system/button_styles/icon_button_secondary/icon_button_secondary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/medical_certificate/more_medicalcertificate/more_medicalcertificate_widget.dart';
import '/ipd/vitalsign/item_co_operator/item_co_operator_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'treatment_i_p_d_detail_widget.dart' show TreatmentIPDDetailWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TreatmentIPDDetailModel
    extends FlutterFlowModel<TreatmentIPDDetailWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for IconButtonSecondary component.
  late IconButtonSecondaryModel iconButtonSecondaryModel;
  // Model for Item_CoOperator component.
  late ItemCoOperatorModel itemCoOperatorModel1;
  // Model for Item_CoOperator component.
  late ItemCoOperatorModel itemCoOperatorModel2;

  @override
  void initState(BuildContext context) {
    iconButtonSecondaryModel =
        createModel(context, () => IconButtonSecondaryModel());
    itemCoOperatorModel1 = createModel(context, () => ItemCoOperatorModel());
    itemCoOperatorModel2 = createModel(context, () => ItemCoOperatorModel());
  }

  @override
  void dispose() {
    iconButtonSecondaryModel.dispose();
    itemCoOperatorModel1.dispose();
    itemCoOperatorModel2.dispose();
  }
}
