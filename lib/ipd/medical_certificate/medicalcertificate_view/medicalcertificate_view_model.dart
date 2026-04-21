import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/medical_certificate/item_medicalcertificate/item_medicalcertificate_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'medicalcertificate_view_widget.dart' show MedicalcertificateViewWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MedicalcertificateViewModel
    extends FlutterFlowModel<MedicalcertificateViewWidget> {
  ///  Local state fields for this component.

  bool buttonadd = true;

  ///  State fields for stateful widgets in this component.

  // Model for IconButtonPrimary component.
  late IconButtonPrimaryModel iconButtonPrimaryModel;
  // Model for Item_Medicalcertificate component.
  late ItemMedicalcertificateModel itemMedicalcertificateModel1;
  // Model for Item_Medicalcertificate component.
  late ItemMedicalcertificateModel itemMedicalcertificateModel2;

  @override
  void initState(BuildContext context) {
    iconButtonPrimaryModel =
        createModel(context, () => IconButtonPrimaryModel());
    itemMedicalcertificateModel1 =
        createModel(context, () => ItemMedicalcertificateModel());
    itemMedicalcertificateModel2 =
        createModel(context, () => ItemMedicalcertificateModel());
  }

  @override
  void dispose() {
    iconButtonPrimaryModel.dispose();
    itemMedicalcertificateModel1.dispose();
    itemMedicalcertificateModel2.dispose();
  }
}
