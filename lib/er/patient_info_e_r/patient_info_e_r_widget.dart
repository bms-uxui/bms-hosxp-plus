import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/er/accident/accident_view/accident_view_widget.dart';
import '/er/diagnosis/diag_e_r_view/diag_e_r_view_widget.dart';
import '/er/drugand_service/drug_srevice_e_r_view/drug_srevice_e_r_view_widget.dart';
import '/er/emr/e_m_r_er_view/e_m_r_er_view_widget.dart';
import '/er/fillter_menu_e_r/fillter_menu_e_r_widget.dart';
import '/er/info_patient_e_r/info_patient_e_r_view/info_patient_e_r_view_widget.dart';
import '/er/menu_patient_info_e_r/menu_patient_info_e_r_widget.dart';
import '/er/nursing_activities/nursing_activities_view/nursing_activities_view_widget.dart';
import '/er/observe/observe_view/observe_view_widget.dart';
import '/er/patient_screening/patient_screening_view/patient_screening_view_widget.dart';
import '/er/physical_examination/physical_examination_view/physical_examination_view_widget.dart';
import '/er/treatment/treatment_e_r_view/treatment_e_r_view_widget.dart';
import '/er/waitingfor_screening/waitingfor_screening_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/appiontment_view/appiontment_view_widget.dart';
import '/ipd/drugand_service/item_drugallergy/item_drugallergy_widget.dart';
import '/ipd/lab_xray/lab_xray_view/lab_xray_view_widget.dart';
import '/ipd/medical_certificate/medicalcertificate_view/medicalcertificate_view_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'package:styled_divider/styled_divider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'patient_info_e_r_model.dart';
export 'patient_info_e_r_model.dart';

class PatientInfoERWidget extends StatefulWidget {
  const PatientInfoERWidget({super.key});

  static String routeName = 'Patient_Info_ER';
  static String routePath = 'patientInfoER';

  @override
  State<PatientInfoERWidget> createState() => _PatientInfoERWidgetState();
}

class _PatientInfoERWidgetState extends State<PatientInfoERWidget>
    with TickerProviderStateMixin {
  late PatientInfoERModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasMenuPatientInfoERTriggered1 = false;
  var hasMenuPatientInfoERTriggered2 = false;
  var hasMenuPatientInfoERTriggered3 = false;
  var hasMenuPatientInfoERTriggered4 = false;
  var hasMenuPatientInfoERTriggered5 = false;
  var hasMenuPatientInfoERTriggered6 = false;
  var hasMenuPatientInfoERTriggered7 = false;
  var hasMenuPatientInfoERTriggered8 = false;
  var hasMenuPatientInfoERTriggered9 = false;
  var hasMenuPatientInfoERTriggered10 = false;
  var hasMenuPatientInfoERTriggered11 = false;
  var hasMenuPatientInfoERTriggered12 = false;
  var hasMenuPatientInfoERTriggered13 = false;
  var hasMenuPatientInfoERTriggered14 = false;
  var hasMenuPatientInfoERTriggered15 = false;
  var hasMenuPatientInfoERTriggered16 = false;
  var hasMenuPatientInfoERTriggered17 = false;
  var hasMenuPatientInfoERTriggered18 = false;
  var hasMenuPatientInfoERTriggered19 = false;
  var hasMenuPatientInfoERTriggered20 = false;
  var hasMenuPatientInfoERTriggered21 = false;
  var hasMenuPatientInfoERTriggered22 = false;
  var hasMenuPatientInfoERTriggered23 = false;
  var hasMenuPatientInfoERTriggered24 = false;
  var hasMenuPatientInfoERTriggered25 = false;
  var hasMenuPatientInfoERTriggered26 = false;
  var hasMenuPatientInfoERTriggered27 = false;
  var hasMenuPatientInfoERTriggered28 = false;
  var hasMenuPatientInfoERTriggered29 = false;
  var hasMenuPatientInfoERTriggered30 = false;
  var hasMenuPatientInfoERTriggered31 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientInfoERModel());

    _model.expandableExpandableController =
        ExpandableController(initialExpanded: true)
          ..addListener(() => safeSetState(() {}));
    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.5, 1.5),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 100.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 100.0.ms,
            duration: 600.0.ms,
            begin: Offset(-23.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'rowOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: Offset(-23.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation8': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation9': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation10': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation11': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation12': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation13': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation14': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation15': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation16': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation17': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation18': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation19': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation20': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation21': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation22': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation23': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation24': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation25': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation26': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation27': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation28': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation29': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation30': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'menuPatientInfoEROnActionTriggerAnimation31': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).accent2,
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: FlutterFlowTheme.of(context).accent2,
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 60.0;
                          } else {
                            return 60.0;
                          }
                        }(),
                        height: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 60.0;
                          } else {
                            return 60.0;
                          }
                        }(),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).secondary,
                              FlutterFlowTheme.of(context).accent2
                            ],
                            stops: [0.0, 1.0],
                            begin: AlignmentDirectional(0.0, -1.0),
                            end: AlignmentDirectional(0, 1.0),
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0x33FFFFFF),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Hero(
                              tag: 'er',
                              transitionOnUserGestures: true,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Image.asset(
                                  'assets/images/ChatGPT_Image_20_.._2568_16_00_35.png',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              child: Container(
                                width: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 20.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 20.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 24.0;
                                  } else {
                                    return 24.0;
                                  }
                                }(),
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 20.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 20.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 24.0;
                                  } else {
                                    return 24.0;
                                  }
                                }(),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(
                                        0.0,
                                        2.0,
                                      ),
                                    )
                                  ],
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF62B3FF),
                                      Color(0xFF2397FF)
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0, 1.0),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.mars,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    size: () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 14.0;
                                      } else {
                                        return 14.0;
                                      }
                                    }(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animateOnPageLoad(
                          animationsMap['containerOnPageLoadAnimation']!),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'นายทดสอบ ทดสอบ',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      fontSize: () {
                                        if (MediaQuery.sizeOf(context).width <
                                            kBreakpointSmall) {
                                          return 14.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointMedium) {
                                          return 14.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointLarge) {
                                          return 18.0;
                                        } else {
                                          return 18.0;
                                        }
                                      }(),
                                      letterSpacing: 0.2,
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          color: Color(0x6757636C),
                                          offset: Offset(0.0, 0.0),
                                          blurRadius: 4.0,
                                        )
                                      ],
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                              ).animateOnPageLoad(
                                  animationsMap['textOnPageLoadAnimation']!),
                            ].divide(SizedBox(width: 12.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.56, -1.0),
                                    end: AlignmentDirectional(-0.56, 1.0),
                                  ),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 2.0, 12.0, 2.0),
                                  child: Text(
                                    'Q 1',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          fontSize: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 10.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 10.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 14.0;
                                            } else {
                                              return 14.0;
                                            }
                                          }(),
                                          letterSpacing: 0.8,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              wrapWithModel(
                                model: _model.waitingforScreeningModel,
                                updateCallback: () => safeSetState(() {}),
                                child: WaitingforScreeningWidget(),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0x1914181B),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 2.0, 12.0, 2.0),
                                  child: Text(
                                    'HN 0000001',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 10.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 10.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 14.0;
                                            } else {
                                              return 14.0;
                                            }
                                          }(),
                                          letterSpacing: 0.8,
                                          fontWeight: FontWeight.w600,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context)
                                          .customColor19,
                                      FlutterFlowTheme.of(context).customColor20
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.56, -1.0),
                                    end: AlignmentDirectional(-0.56, 1.0),
                                  ),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 2.0, 12.0, 2.0),
                                  child: Text(
                                    'อายุ 52 ปี',
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodySmallFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 10.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 10.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 14.0;
                                            } else {
                                              return 14.0;
                                            }
                                          }(),
                                          letterSpacing: 0.8,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodySmallIsCustom,
                                        ),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ).animateOnPageLoad(
                              animationsMap['rowOnPageLoadAnimation']!),
                        ].divide(SizedBox(height: 8.0)),
                      ),
                    ].divide(SizedBox(width: 12.0)),
                  ),
                ].divide(SizedBox(width: 8.0)),
              ),
              actions: [
                Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.safePop();
                      },
                      child: wrapWithModel(
                        model: _model.iconButtonTertiaryModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: IconButtonTertiaryWidget(
                          iconbuttontertiary: Icon(
                            Icons.close_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 16.0,
                          ),
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 0.2,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, -1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_30_.._2568_11_49_46.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.contain,
                        alignment: Alignment(1.0, 1.0),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(56.0),
                child: Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Stack(
                    children: [
                      if (FFAppState().filtermenuER == 'All')
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      isDismissible: false,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: FillterMenuERWidget(),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 8.0,
                                          color: Color(0x26000000),
                                          offset: Offset(
                                            0.0,
                                            0.0,
                                          ),
                                          spreadRadius: 0.0,
                                        )
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          4.0, 4.0, 4.0, 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            decoration: BoxDecoration(
                                              color: Color(0x34FFFFFF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Icon(
                                                Icons.table_rows_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 14.0,
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 1;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation1'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered1 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation1']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ข้อมูลผู้ป่วย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 1
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 1,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation1']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered1),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 2;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation2'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered2 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation2']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'EMR',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedicalAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 2
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 2,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation2']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered2),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 3;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation3'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered3 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation3']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'คัดกรอง',
                                      icon: Icon(
                                        Icons.person_search,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 3
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 16.0,
                                      ),
                                      tabMenuPatientInfoER: 3,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation3']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered3),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 4;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation4'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered4 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation4']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ตรวจร่งกาย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userMd,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 4
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 4,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation4']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered4),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 5;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation5'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered5 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation5']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel5,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'กิจกรรมพยาบาล',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userNurse,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 5
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 5,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation5']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered5),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 6;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation6'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered6 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation6']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel6,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'อุบัติเหตุ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userInjured,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 6
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 6,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation6']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered6),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 7;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation7'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered7 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation7']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel7,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'สังเกอาการ',
                                      icon: Icon(
                                        Icons.remove_red_eye_rounded,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 7
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 7,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation7']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered7),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 8;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation8'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered8 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation8']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel8,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'หัตถการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.syringe,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 8
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 8,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation8']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered8),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 9;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation9'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered9 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation9']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel9,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'Lab/X-Ray',
                                      icon: FaIcon(
                                        FontAwesomeIcons.vial,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 9
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 9,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation9']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered9),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 10;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation10'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered10 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation10']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel10,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'การวินิจฉัย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileContract,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  10
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 10,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation10']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered10),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 11;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation11'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered11 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation11']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel11,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ยา/ค่าบริการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.capsules,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  11
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 11,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation11']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered11),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 12;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation12'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered12 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation12']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel12,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'นัดหมาย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.calendarDay,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  12
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 12,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation12']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered12),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 13;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation13'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered13 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation13']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel13,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ใบรับรองแพทย์',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedical,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  13
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 13,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation13']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered13),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 14;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation14'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered14 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation14']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel14,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'สรุปการรักษา',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedicalAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  14
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 14,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation14']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered14),
                              ].divide(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())).addToStart(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }())).addToEnd(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }())),
                            ),
                          ),
                        ),
                      if (FFAppState().filtermenuER == 'Doctor')
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      isDismissible: false,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: FillterMenuERWidget(),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 8.0,
                                          color: Color(0x26000000),
                                          offset: Offset(
                                            0.0,
                                            0.0,
                                          ),
                                          spreadRadius: 0.0,
                                        )
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          4.0, 4.0, 4.0, 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            decoration: BoxDecoration(
                                              color: Color(0x34FFFFFF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Icon(
                                                Icons.table_rows_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 14.0,
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 1;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation15'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered15 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation15']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel15,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ข้อมูลผู้ป่วย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 1
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 1,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation15']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered15),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 2;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation16'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered16 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation16']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel16,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'EMR',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedicalAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 2
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 2,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation16']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered16),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 4;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation17'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered17 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation17']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel17,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ตรวจร่งกาย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userMd,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 4
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 4,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation17']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered17),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 9;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation18'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered18 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation18']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel18,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'Lab/X-Ray',
                                      icon: FaIcon(
                                        FontAwesomeIcons.vial,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 9
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 9,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation18']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered18),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 10;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation19'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered19 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation19']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel19,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'การวินิจฉัย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileContract,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  10
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 10,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation19']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered19),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 11;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation20'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered20 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation20']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel20,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ยา/ค่าบริการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.capsules,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  11
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 11,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation20']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered20),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 13;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation21'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered21 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation21']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel21,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ใบรับรองแพทย์',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedical,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  13
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 13,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation21']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered21),
                              ].divide(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())).addToStart(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }())).addToEnd(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }())),
                            ),
                          ),
                        ),
                      if (FFAppState().filtermenuER == 'Nurse')
                        Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      isDismissible: false,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: FillterMenuERWidget(),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 8.0,
                                          color: Color(0x26000000),
                                          offset: Offset(
                                            0.0,
                                            0.0,
                                          ),
                                          spreadRadius: 0.0,
                                        )
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        width: 0.6,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          4.0, 4.0, 4.0, 4.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            height: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 28.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 32.0;
                                              } else {
                                                return 32.0;
                                              }
                                            }(),
                                            decoration: BoxDecoration(
                                              color: Color(0x34FFFFFF),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Icon(
                                                Icons.table_rows_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 14.0,
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 1;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation22'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered22 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation22']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel22,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ข้อมูลผู้ป่วย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 1
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 1,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation22']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered22),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 2;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation23'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered23 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation23']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel23,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'EMR',
                                      icon: FaIcon(
                                        FontAwesomeIcons.fileMedicalAlt,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 2
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 2,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation23']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered23),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 3;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation24'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered24 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation24']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel24,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'คัดกรอง',
                                      icon: Icon(
                                        Icons.person_search,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 3
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 16.0,
                                      ),
                                      tabMenuPatientInfoER: 3,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation24']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered24),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 5;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation25'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered25 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation25']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel25,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'กิจกรรมพยาบาล',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userNurse,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 5
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 5,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation25']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered25),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 6;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation26'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered26 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation26']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel26,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'อุบัติเหตุ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.userInjured,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 6
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 6,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation26']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered26),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 7;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation27'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered27 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation27']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel27,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'สังเกอาการ',
                                      icon: Icon(
                                        Icons.remove_red_eye_rounded,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 7
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 7,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation27']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered27),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 8;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation28'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered28 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation28']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel28,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'หัตถการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.syringe,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 8
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 8,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation28']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered28),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 9;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation29'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered29 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation29']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel29,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'Lab/X-Ray',
                                      icon: FaIcon(
                                        FontAwesomeIcons.vial,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER == 9
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 9,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation29']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered29),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 11;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation30'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered30 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation30']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel30,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'ยา/ค่าบริการ',
                                      icon: FaIcon(
                                        FontAwesomeIcons.capsules,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  11
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 12.0,
                                      ),
                                      tabMenuPatientInfoER: 11,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation30']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered30),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().TabMenuPatientInfoER = 12;
                                    safeSetState(() {});
                                    if (animationsMap[
                                            'menuPatientInfoEROnActionTriggerAnimation31'] !=
                                        null) {
                                      safeSetState(() =>
                                          hasMenuPatientInfoERTriggered31 =
                                              true);
                                      SchedulerBinding.instance
                                          .addPostFrameCallback((_) async =>
                                              animationsMap[
                                                      'menuPatientInfoEROnActionTriggerAnimation31']!
                                                  .controller
                                                  .forward(from: 0.0));
                                    }
                                  },
                                  child: wrapWithModel(
                                    model: _model.menuPatientInfoERModel31,
                                    updateCallback: () => safeSetState(() {}),
                                    child: MenuPatientInfoERWidget(
                                      namemenu: 'นัดหมาย',
                                      icon: FaIcon(
                                        FontAwesomeIcons.calendarDay,
                                        color: valueOrDefault<Color>(
                                          FFAppState().TabMenuPatientInfoER ==
                                                  12
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        size: 10.0,
                                      ),
                                      tabMenuPatientInfoER: 12,
                                    ),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'menuPatientInfoEROnActionTriggerAnimation31']!,
                                    hasBeenTriggered:
                                        hasMenuPatientInfoERTriggered31),
                              ].divide(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 8.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 12.0;
                                } else {
                                  return 12.0;
                                }
                              }())).addToStart(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }())).addToEnd(SizedBox(width: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 12.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 16.0;
                                } else {
                                  return 16.0;
                                }
                              }())),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              centerTitle: false,
              toolbarHeight: 74.0,
              elevation: 0.0,
            )
          ],
          body: Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    0.0,
                    valueOrDefault<double>(
                      () {
                        if (MediaQuery.sizeOf(context).width <
                            kBreakpointSmall) {
                          return 0.0;
                        } else if (MediaQuery.sizeOf(context).width <
                            kBreakpointMedium) {
                          return 0.0;
                        } else if (MediaQuery.sizeOf(context).width <
                            kBreakpointLarge) {
                          return 8.0;
                        } else {
                          return 8.0;
                        }
                      }(),
                      0.0,
                    ),
                    0.0,
                    0.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xCC3E83E6),
                        FlutterFlowTheme.of(context).primaryBackground,
                        FlutterFlowTheme.of(context).primaryBackground
                      ],
                      stops: [0.0, 0.34, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        if (FFAppState().TabMenuPatientInfoER == 1) {
                          return Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.infoPatientERViewModel,
                              updateCallback: () => safeSetState(() {}),
                              child: InfoPatientERViewWidget(),
                            ),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 2) {
                          return wrapWithModel(
                            model: _model.eMRErViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: EMRErViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 3) {
                          return wrapWithModel(
                            model: _model.patientScreeningViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: PatientScreeningViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 4) {
                          return wrapWithModel(
                            model: _model.physicalExaminationViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: PhysicalExaminationViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 5) {
                          return wrapWithModel(
                            model: _model.nursingActivitiesViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: NursingActivitiesViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 6) {
                          return wrapWithModel(
                            model: _model.accidentViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: AccidentViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 7) {
                          return wrapWithModel(
                            model: _model.observeViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: ObserveViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 8) {
                          return wrapWithModel(
                            model: _model.treatmentERViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: TreatmentERViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 9) {
                          return wrapWithModel(
                            model: _model.labXrayViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: LabXrayViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 10) {
                          return wrapWithModel(
                            model: _model.diagERViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: DiagERViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 11) {
                          return wrapWithModel(
                            model: _model.drugSreviceERViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: DrugSreviceERViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 12) {
                          return wrapWithModel(
                            model: _model.appiontmentViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: AppiontmentViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 13) {
                          return wrapWithModel(
                            model: _model.medicalcertificateViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: MedicalcertificateViewWidget(),
                          );
                        } else if (FFAppState().TabMenuPatientInfoER == 14) {
                          return Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  valueOrDefault<double>(
                                    () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 16.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 16.0;
                                      } else {
                                        return 16.0;
                                      }
                                    }(),
                                    0.0,
                                  ),
                                  0.0,
                                  valueOrDefault<double>(
                                    () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 16.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 16.0;
                                      } else {
                                        return 16.0;
                                      }
                                    }(),
                                    0.0,
                                  ),
                                  0.0),
                              child: ListView(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 16.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 16.0;
                                    } else {
                                      return 16.0;
                                    }
                                  }(),
                                  0,
                                  0,
                                ),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF5997F4),
                                          FlutterFlowTheme.of(context).primary
                                        ],
                                        stops: [0.0, 1.0],
                                        begin: AlignmentDirectional(0.0, -1.0),
                                        end: AlignmentDirectional(0, 1.0),
                                      ),
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(valueOrDefault<double>(
                                        () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 16.0;
                                          } else {
                                            return 16.0;
                                          }
                                        }(),
                                        0.0,
                                      )),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/ChatGPT_Image_11_.._2568_12_02_02.png',
                                                      width: () {
                                                        if (MediaQuery.sizeOf(
                                                                    context)
                                                                .width <
                                                            kBreakpointSmall) {
                                                          return 32.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointMedium) {
                                                          return 32.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointLarge) {
                                                          return 40.0;
                                                        } else {
                                                          return 40.0;
                                                        }
                                                      }(),
                                                      height: () {
                                                        if (MediaQuery.sizeOf(
                                                                    context)
                                                                .width <
                                                            kBreakpointSmall) {
                                                          return 32.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointMedium) {
                                                          return 32.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointLarge) {
                                                          return 40.0;
                                                        } else {
                                                          return 40.0;
                                                        }
                                                      }(),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Text(
                                                    'สรุปการรักษา Fast Track',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMediumFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMediumIsCustom,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(width: 8.0)),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 1.0,
                                            thickness: 1.0,
                                            color: Color(0x33FFFFFF),
                                          ),
                                          Text(
                                            'โรงพยาบาลทดสอบ',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 8.0,
                                            alignment: WrapAlignment.start,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            direction: Axis.horizontal,
                                            runAlignment: WrapAlignment.start,
                                            verticalDirection:
                                                VerticalDirection.down,
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0x26FFFFFF),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 2.0, 12.0, 2.0),
                                                  child: Text(
                                                    'HN : 12345678',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0x26FFFFFF),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 2.0, 12.0, 2.0),
                                                  child: Text(
                                                    'ประเภท : Trauma',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ].divide(SizedBox(height: 8.0)),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        Opacity(
                                          opacity: 0.5,
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(1.0, -1.0),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/ChatGPT_Image_28_.._2568_08_44_08.png',
                                                  width: 60.0,
                                                  height: 60.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      0.0),
                                              child: Text(
                                                'ข้อมูลผู้ป่วย',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLargeFamily,
                                                      color: Color(0xFF245EBD),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLargeIsCustom,
                                                    ),
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0x0B2397FF),
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 5.0,
                                                    sigmaY: 5.0,
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        valueOrDefault<double>(
                                                      () {
                                                        if (MediaQuery.sizeOf(
                                                                    context)
                                                                .width <
                                                            kBreakpointSmall) {
                                                          return 12.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointMedium) {
                                                          return 16.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointLarge) {
                                                          return 16.0;
                                                        } else {
                                                          return 16.0;
                                                        }
                                                      }(),
                                                      0.0,
                                                    )),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        MasonryGridView.builder(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          gridDelegate:
                                                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 3;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 3;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 4;
                                                              } else {
                                                                return 4;
                                                              }
                                                            }(),
                                                          ),
                                                          crossAxisSpacing:
                                                              12.0,
                                                          mainAxisSpacing: 12.0,
                                                          itemCount: 3,
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                          shrinkWrap: true,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return [
                                                              () => Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'เพศ',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodySmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                              letterSpacing: 0.0,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        'ชาย',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                              () => Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'อายุ',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodySmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                              letterSpacing: 0.0,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        '52 ปี',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                              () => Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'รหัสผู้ป่วย',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodySmall
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                              letterSpacing: 0.0,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        '12345678',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                            ][index]();
                                                          },
                                                        ),
                                                        StyledDivider(
                                                          height: 1.0,
                                                          thickness: 1.0,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          lineStyle:
                                                              DividerLineStyle
                                                                  .dashed,
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'โคประจำตัว',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodySmallFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodySmallIsCustom,
                                                                  ),
                                                            ),
                                                            Text(
                                                              'ไม่มี',
                                                              maxLines: 1,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ].divide(SizedBox(
                                                          height: 12.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(valueOrDefault<double>(
                                        () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 12.0;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 16.0;
                                          } else {
                                            return 16.0;
                                          }
                                        }(),
                                        0.0,
                                      )),
                                      child: Container(
                                        width: double.infinity,
                                        color: Color(0x00000000),
                                        child: ExpandableNotifier(
                                          controller: _model
                                              .expandableExpandableController,
                                          child: ExpandablePanel(
                                            header: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.warning_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      size: 16.0,
                                                    ),
                                                    Text(
                                                      'แพ้ยา',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodySmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallFamily,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodySmallIsCustom,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                                wrapWithModel(
                                                  model: _model
                                                      .iconButtonTertiaryModel2,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child:
                                                      IconButtonTertiaryWidget(
                                                    iconbuttontertiary: Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      size: 14.0,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            collapsed: Container(),
                                            expanded: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                wrapWithModel(
                                                  model: _model
                                                      .itemDrugallergyModel,
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: ItemDrugallergyWidget(
                                                    num: '1',
                                                    drug: 'Penicillin',
                                                    reaction:
                                                        'ผื่นลมพิษ (Urticaria), คัน, หายใจลำบาก, หน้าและคอบวม (Angioedema), ช็อก (Anaphylaxis)',
                                                    colorbg1: Color(0x0BBE1E2D),
                                                    colorbg2: FlutterFlowTheme
                                                            .of(context)
                                                        .secondaryBackground,
                                                    colorborder:
                                                        Color(0x0BBE1E2D),
                                                  ),
                                                ),
                                              ]
                                                  .divide(SizedBox(height: 8.0))
                                                  .addToStart(
                                                      SizedBox(height: 8.0)),
                                            ),
                                            theme: ExpandableThemeData(
                                              tapHeaderToExpand: true,
                                              tapBodyToExpand: false,
                                              tapBodyToCollapse: false,
                                              headerAlignment:
                                                  ExpandablePanelHeaderAlignment
                                                      .center,
                                              hasIcon: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        Opacity(
                                          opacity: 0.5,
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(1.0, -1.0),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/ChatGPT_Image_27_.._2568_13_36_56.png',
                                                  width: 60.0,
                                                  height: 60.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      0.0),
                                              child: Text(
                                                'สัญญาณชีพ',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLargeFamily,
                                                      color: Color(0xFF245EBD),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLargeIsCustom,
                                                    ),
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0x0B2397FF),
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 5.0,
                                                    sigmaY: 5.0,
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        valueOrDefault<double>(
                                                      () {
                                                        if (MediaQuery.sizeOf(
                                                                    context)
                                                                .width <
                                                            kBreakpointSmall) {
                                                          return 12.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointMedium) {
                                                          return 16.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointLarge) {
                                                          return 16.0;
                                                        } else {
                                                          return 16.0;
                                                        }
                                                      }(),
                                                      0.0,
                                                    )),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        MasonryGridView.builder(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          gridDelegate:
                                                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: () {
                                                              if (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width <
                                                                  kBreakpointSmall) {
                                                                return 2;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointMedium) {
                                                                return 2;
                                                              } else if (MediaQuery
                                                                          .sizeOf(
                                                                              context)
                                                                      .width <
                                                                  kBreakpointLarge) {
                                                                return 4;
                                                              } else {
                                                                return 4;
                                                              }
                                                            }(),
                                                          ),
                                                          crossAxisSpacing:
                                                              12.0,
                                                          mainAxisSpacing: 12.0,
                                                          itemCount: 4,
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                            0,
                                                            0,
                                                            0,
                                                            0,
                                                          ),
                                                          shrinkWrap: true,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return [
                                                              () => Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children:
                                                                            [
                                                                          Container(
                                                                            width:
                                                                                20.0,
                                                                            height:
                                                                                20.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  Color(0xFF8BBAFF),
                                                                                  FlutterFlowTheme.of(context).info
                                                                                ],
                                                                                stops: [
                                                                                  0.0,
                                                                                  1.0
                                                                                ],
                                                                                begin: AlignmentDirectional(0.0, -1.0),
                                                                                end: AlignmentDirectional(0, 1.0),
                                                                              ),
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(4.0),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                child: Image.asset(
                                                                                  'assets/images/thermometer.png',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'อุณหภูมิ',
                                                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.normal,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                      RichText(
                                                                        textScaler:
                                                                            MediaQuery.of(context).textScaler,
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: '37.2',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '   ํC',
                                                                              style: GoogleFonts.roboto(
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                fontSize: 10.0,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                letterSpacing: 0.0,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                              () => Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children:
                                                                            [
                                                                          Container(
                                                                            width:
                                                                                20.0,
                                                                            height:
                                                                                20.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  Color(0xFF8BBAFF),
                                                                                  FlutterFlowTheme.of(context).info
                                                                                ],
                                                                                stops: [
                                                                                  0.0,
                                                                                  1.0
                                                                                ],
                                                                                begin: AlignmentDirectional(0.0, -1.0),
                                                                                end: AlignmentDirectional(0, 1.0),
                                                                              ),
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(4.0),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                child: Image.asset(
                                                                                  'assets/images/blood-pressure_(1).png',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'ความดัน',
                                                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.normal,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                      RichText(
                                                                        textScaler:
                                                                            MediaQuery.of(context).textScaler,
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: '120/78',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '  kg.',
                                                                              style: GoogleFonts.roboto(
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                fontSize: 10.0,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                letterSpacing: 0.0,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                              () => Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children:
                                                                            [
                                                                          Container(
                                                                            width:
                                                                                20.0,
                                                                            height:
                                                                                20.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  Color(0xFF8BBAFF),
                                                                                  FlutterFlowTheme.of(context).info
                                                                                ],
                                                                                stops: [
                                                                                  0.0,
                                                                                  1.0
                                                                                ],
                                                                                begin: AlignmentDirectional(0.0, -1.0),
                                                                                end: AlignmentDirectional(0, 1.0),
                                                                              ),
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(4.0),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                child: Image.asset(
                                                                                  'assets/images/pulse-rate.png',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'อัตราการเต้นชีพจร',
                                                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.normal,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                      RichText(
                                                                        textScaler:
                                                                            MediaQuery.of(context).textScaler,
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: '82',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '  rpm',
                                                                              style: GoogleFonts.roboto(
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                fontSize: 10.0,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                letterSpacing: 0.0,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                              () => Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children:
                                                                            [
                                                                          Container(
                                                                            width:
                                                                                20.0,
                                                                            height:
                                                                                20.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                colors: [
                                                                                  Color(0xFF8BBAFF),
                                                                                  FlutterFlowTheme.of(context).info
                                                                                ],
                                                                                stops: [
                                                                                  0.0,
                                                                                  1.0
                                                                                ],
                                                                                begin: AlignmentDirectional(0.0, -1.0),
                                                                                end: AlignmentDirectional(0, 1.0),
                                                                              ),
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsets.all(4.0),
                                                                              child: ClipRRect(
                                                                                borderRadius: BorderRadius.circular(0.0),
                                                                                child: Image.asset(
                                                                                  'assets/images/lungs_(1).png',
                                                                                  width: 200.0,
                                                                                  height: 200.0,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            'อัตราการหายใจ',
                                                                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.normal,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                      RichText(
                                                                        textScaler:
                                                                            MediaQuery.of(context).textScaler,
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: '\t18',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '  bpm',
                                                                              style: GoogleFonts.roboto(
                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                fontSize: 10.0,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                letterSpacing: 0.0,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                            ][index]();
                                                          },
                                                        ),
                                                        StyledDivider(
                                                          height: 1.0,
                                                          thickness: 1.0,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          lineStyle:
                                                              DividerLineStyle
                                                                  .dashed,
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        FlutterFlowTheme.of(context)
                                                                            .customColor7,
                                                                        FlutterFlowTheme.of(context)
                                                                            .customColor8
                                                                      ],
                                                                      stops: [
                                                                        0.0,
                                                                        1.0
                                                                      ],
                                                                      begin: AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                      end: AlignmentDirectional(
                                                                          0,
                                                                          1.0),
                                                                    ),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                  child: Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        FaIcon(
                                                                      FontAwesomeIcons
                                                                          .waveSquare,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      size: 8.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'GCS',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).labelSmallFamily,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                      ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 8.0)),
                                                            ),
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: 'E3 ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: 'V2 ',
                                                                    style:
                                                                        TextStyle(),
                                                                  ),
                                                                  TextSpan(
                                                                    text: 'M6 ',
                                                                    style:
                                                                        TextStyle(),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              height: 8.0)),
                                                        ),
                                                      ].divide(SizedBox(
                                                          height: 12.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        Opacity(
                                          opacity: 0.5,
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(1.0, -1.0),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/ChatGPT_Image_2_.._2568_10_54_59.png',
                                                  width: 60.0,
                                                  height: 60.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      valueOrDefault<double>(
                                                        () {
                                                          if (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              kBreakpointSmall) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointMedium) {
                                                            return 12.0;
                                                          } else if (MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width <
                                                              kBreakpointLarge) {
                                                            return 16.0;
                                                          } else {
                                                            return 16.0;
                                                          }
                                                        }(),
                                                        0.0,
                                                      ),
                                                      0.0),
                                              child: Text(
                                                'การวินิจฉัย',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyLarge
                                                    .override(
                                                      fontFamily:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLargeFamily,
                                                      color: Color(0xFF245EBD),
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      useGoogleFonts:
                                                          !FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLargeIsCustom,
                                                    ),
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Color(0x0B2397FF),
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(24.0),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 5.0,
                                                    sigmaY: 5.0,
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                        valueOrDefault<double>(
                                                      () {
                                                        if (MediaQuery.sizeOf(
                                                                    context)
                                                                .width <
                                                            kBreakpointSmall) {
                                                          return 12.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointMedium) {
                                                          return 12.0;
                                                        } else if (MediaQuery
                                                                    .sizeOf(
                                                                        context)
                                                                .width <
                                                            kBreakpointLarge) {
                                                          return 16.0;
                                                        } else {
                                                          return 16.0;
                                                        }
                                                      }(),
                                                      0.0,
                                                    )),
                                                    child: Text(
                                                      'Penetrating abdomen',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Stack(
                                      children: [
                                        Opacity(
                                          opacity: 0.5,
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(1.0, -1.0),
                                            child: Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/ChatGPT_Image_2_.._2568_11_05_00.png',
                                                  width: 60.0,
                                                  height: 60.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(
                                              valueOrDefault<double>(
                                            () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 12.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 16.0;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 16.0;
                                              } else {
                                                return 16.0;
                                              }
                                            }(),
                                            0.0,
                                          )),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'ไทม์ไลน์การรักษา',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyLarge
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyLargeFamily,
                                                          color:
                                                              Color(0xFF245EBD),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLargeIsCustom,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(width: 8.0)),
                                              ),
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: () {
                                                      if (MediaQuery.sizeOf(
                                                                  context)
                                                              .width <
                                                          kBreakpointSmall) {
                                                        return 48.0;
                                                      } else if (MediaQuery
                                                                  .sizeOf(
                                                                      context)
                                                              .width <
                                                          kBreakpointMedium) {
                                                        return 48.0;
                                                      } else if (MediaQuery
                                                                  .sizeOf(
                                                                      context)
                                                              .width <
                                                          kBreakpointLarge) {
                                                        return 56.0;
                                                      } else {
                                                        return 56.0;
                                                      }
                                                    }(),
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          height: () {
                                                            if (MediaQuery.sizeOf(
                                                                        context)
                                                                    .width <
                                                                kBreakpointSmall) {
                                                              return 590.0;
                                                            } else if (MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width <
                                                                kBreakpointMedium) {
                                                              return 590.0;
                                                            } else if (MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width <
                                                                kBreakpointLarge) {
                                                              return 670.0;
                                                            } else {
                                                              return 670.0;
                                                            }
                                                          }(),
                                                          child:
                                                              StyledVerticalDivider(
                                                            width: 1.0,
                                                            thickness: 1.0,
                                                            indent: 24.0,
                                                            endIndent: 24.0,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .alternate,
                                                            lineStyle:
                                                                DividerLineStyle
                                                                    .dashed,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF75AFFF),
                                                                                FlutterFlowTheme.of(context).primary
                                                                              ],
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.medical_services_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Triage',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children:
                                                                              [
                                                                            Container(
                                                                              width: 24.0,
                                                                              height: 24.0,
                                                                              decoration: BoxDecoration(
                                                                                gradient: LinearGradient(
                                                                                  colors: [
                                                                                    Color(0xFF75AFFF),
                                                                                    FlutterFlowTheme.of(context).primary
                                                                                  ],
                                                                                  stops: [
                                                                                    0.0,
                                                                                    1.0
                                                                                  ],
                                                                                  begin: AlignmentDirectional(0.0, -1.0),
                                                                                  end: AlignmentDirectional(0, 1.0),
                                                                                ),
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: Align(
                                                                                alignment: AlignmentDirectional(0.0, 0.0),
                                                                                child: Icon(
                                                                                  Icons.flash_on,
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  size: 12.0,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              'Activate Trauma Fast Track',
                                                                              maxLines: 1,
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                  ),
                                                                            ),
                                                                          ].divide(SizedBox(width: 12.0)),
                                                                        ),
                                                                        Wrap(
                                                                          spacing:
                                                                              12.0,
                                                                          runSpacing:
                                                                              8.0,
                                                                          alignment:
                                                                              WrapAlignment.start,
                                                                          crossAxisAlignment:
                                                                              WrapCrossAlignment.start,
                                                                          direction:
                                                                              Axis.horizontal,
                                                                          runAlignment:
                                                                              WrapAlignment.start,
                                                                          verticalDirection:
                                                                              VerticalDirection.down,
                                                                          clipBehavior:
                                                                              Clip.none,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.calendar_month_rounded,
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                  size: 14.0,
                                                                                ),
                                                                                Text(
                                                                                  '2 ก.ย. 2568',
                                                                                  maxLines: 1,
                                                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                        letterSpacing: 0.0,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ].divide(SizedBox(width: 4.0)),
                                                                            ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.access_time,
                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                  size: 14.0,
                                                                                ),
                                                                                Text(
                                                                                  '20 นาที',
                                                                                  maxLines: 1,
                                                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                        letterSpacing: 0.0,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ].divide(SizedBox(width: 4.0)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF75AFFF),
                                                                                FlutterFlowTheme.of(context).primary
                                                                              ],
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.groups_sharp,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Trauma Team Arrival',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF75AFFF),
                                                                                FlutterFlowTheme.of(context).primary
                                                                              ],
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.water_drop_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'MTP',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF75AFFF),
                                                                                FlutterFlowTheme.of(context).primary
                                                                              ],
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.output_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'ER Out',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF75AFFF),
                                                                                FlutterFlowTheme.of(context).primary
                                                                              ],
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.content_cut_sharp,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'OR',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF75AFFF),
                                                                                FlutterFlowTheme.of(context).primary
                                                                              ],
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.timer_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Door ER to Door OR',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF75AFFF),
                                                                                FlutterFlowTheme.of(context).primary
                                                                              ],
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.water_drop_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '1st Blood Transfusion',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0x0B2397FF),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                border:
                                                                    Border.all(
                                                                  color: Color(
                                                                      0x0B2397FF),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24.0),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX: 5.0,
                                                                    sigmaY: 5.0,
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.all(
                                                                        valueOrDefault<
                                                                            double>(
                                                                      () {
                                                                        if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointSmall) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointMedium) {
                                                                          return 12.0;
                                                                        } else if (MediaQuery.sizeOf(context).width <
                                                                            kBreakpointLarge) {
                                                                          return 16.0;
                                                                        } else {
                                                                          return 16.0;
                                                                        }
                                                                      }(),
                                                                      0.0,
                                                                    )),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              24.0,
                                                                          height:
                                                                              24.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(
                                                                              colors: [
                                                                                Color(0xFF75AFFF),
                                                                                FlutterFlowTheme.of(context).primary
                                                                              ],
                                                                              stops: [
                                                                                0.0,
                                                                                1.0
                                                                              ],
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.chat_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 12.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'Trauma Team Consult',
                                                                          maxLines:
                                                                              1,
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 12.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 12.0)),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 16.0)),
                                                  ),
                                                ],
                                              ),
                                            ].divide(SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ].divide(SizedBox(height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 12.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 16.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 16.0;
                                  } else {
                                    return 16.0;
                                  }
                                }())),
                              ),
                            ),
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [],
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
