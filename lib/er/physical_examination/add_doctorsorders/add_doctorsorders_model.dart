import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/er/physical_examination/buttonsheet_doctorsorders_template/buttonsheet_doctorsorders_template_widget.dart';
import '/er/physical_examination/template_general_emergency/template_general_emergency_widget.dart';
import '/er/physical_examination/template_non_emergent/template_non_emergent_widget.dart';
import '/er/physical_examination/template_s_t_e_m_i/template_s_t_e_m_i_widget.dart';
import '/er/physical_examination/template_sepsis/template_sepsis_widget.dart';
import '/er/physical_examination/template_stroke/template_stroke_widget.dart';
import '/er/physical_examination/template_trauma/template_trauma_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'add_doctorsorders_widget.dart' show AddDoctorsordersWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddDoctorsordersModel extends FlutterFlowModel<AddDoctorsordersWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Dropdown component.
  late DropdownModel dropdownModel;
  // Model for Template_Stroke component.
  late TemplateStrokeModel templateStrokeModel;
  // Model for Template_STEMI component.
  late TemplateSTEMIModel templateSTEMIModel;
  // Model for Template_Sepsis component.
  late TemplateSepsisModel templateSepsisModel;
  // Model for Template_Trauma component.
  late TemplateTraumaModel templateTraumaModel;
  // Model for Template_GeneralEmergency component.
  late TemplateGeneralEmergencyModel templateGeneralEmergencyModel;
  // Model for Template_Non-Emergent component.
  late TemplateNonEmergentModel templateNonEmergentModel;
  // Model for BottonPrimary component.
  late BottonPrimaryModel bottonPrimaryModel;

  @override
  void initState(BuildContext context) {
    dropdownModel = createModel(context, () => DropdownModel());
    templateStrokeModel = createModel(context, () => TemplateStrokeModel());
    templateSTEMIModel = createModel(context, () => TemplateSTEMIModel());
    templateSepsisModel = createModel(context, () => TemplateSepsisModel());
    templateTraumaModel = createModel(context, () => TemplateTraumaModel());
    templateGeneralEmergencyModel =
        createModel(context, () => TemplateGeneralEmergencyModel());
    templateNonEmergentModel =
        createModel(context, () => TemplateNonEmergentModel());
    bottonPrimaryModel = createModel(context, () => BottonPrimaryModel());
  }

  @override
  void dispose() {
    dropdownModel.dispose();
    templateStrokeModel.dispose();
    templateSTEMIModel.dispose();
    templateSepsisModel.dispose();
    templateTraumaModel.dispose();
    templateGeneralEmergencyModel.dispose();
    templateNonEmergentModel.dispose();
    bottonPrimaryModel.dispose();
  }
}
