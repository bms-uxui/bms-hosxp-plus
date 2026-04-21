import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/admit/admitpage_view/admitpage_view_widget.dart';
import '/ipd/appiontment/appiontment_view/appiontment_view_widget.dart';
import '/ipd/consult/cousult_view/cousult_view_widget.dart';
import '/ipd/diagnosis/diag_view/diag_view_widget.dart';
import '/ipd/drugand_service/drug_srevice_view/drug_srevice_view_widget.dart';
import '/ipd/emr/e_m_rpage_view/e_m_rpage_view_widget.dart';
import '/ipd/lab_xray/lab_xray_view/lab_xray_view_widget.dart';
import '/ipd/medical_certificate/medicalcertificate_view/medicalcertificate_view_widget.dart';
import '/ipd/order_sheet/order_sheet_view/order_sheet_view_widget.dart';
import '/ipd/vitalsign/vitalsignpage_view/vitalsignpage_view_widget.dart';
import '/ipd/widget/menu_patient_info_i_p_d/menu_patient_info_i_p_d_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'patient_info_i_p_d_model.dart';
export 'patient_info_i_p_d_model.dart';

class PatientInfoIPDWidget extends StatefulWidget {
  const PatientInfoIPDWidget({super.key});

  static String routeName = 'Patient_Info_IPD';
  static String routePath = 'patientInfoIPD';

  @override
  State<PatientInfoIPDWidget> createState() => _PatientInfoIPDWidgetState();
}

class _PatientInfoIPDWidgetState extends State<PatientInfoIPDWidget>
    with TickerProviderStateMixin {
  late PatientInfoIPDModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientInfoIPDModel());

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
      'menuPatientInfoIPDOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation8': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation9': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'menuPatientInfoIPDOnActionTriggerAnimation10': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Image.asset(
                                'assets/images/ChatGPT_Image_19_.._2568_13_11_36.png',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
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
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyMediumIsCustom,
                                ),
                          ).animateOnPageLoad(
                              animationsMap['textOnPageLoadAnimation']!),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0x1914181B),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 2.0, 12.0, 2.0),
                                  child: Text(
                                    'AN 0000001',
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
                                      FlutterFlowTheme.of(context).primary,
                                      FlutterFlowTheme.of(context).accent1
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
                                    '26 ปี 3 เดือน 15 วัน',
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
                        model: _model.iconButtonTertiaryModel,
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
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation1'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 1;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel1,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'Admit',
                            tabmenupatient: 1,
                            icon: FaIcon(
                              FontAwesomeIcons.userAlt,
                              color: FFAppState().TabMenuPatientInfo == 1
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 10.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation1']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation2'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation2']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 2;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel2,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'EMR',
                            tabmenupatient: 2,
                            icon: FaIcon(
                              FontAwesomeIcons.fileMedicalAlt,
                              color: FFAppState().TabMenuPatientInfo == 2
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 12.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation2']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation3'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation3']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 3;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel3,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'Order Sheet',
                            tabmenupatient: 3,
                            icon: FaIcon(
                              FontAwesomeIcons.table,
                              color: FFAppState().TabMenuPatientInfo == 3
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 10.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation3']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation4'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation4']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 4;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel4,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'Vital Sign',
                            tabmenupatient: 4,
                            icon: FaIcon(
                              FontAwesomeIcons.heartbeat,
                              color: FFAppState().TabMenuPatientInfo == 4
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 12.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation4']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation5'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation5']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 5;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel5,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'Lab/X-Ray',
                            tabmenupatient: 5,
                            icon: FaIcon(
                              FontAwesomeIcons.vial,
                              color: FFAppState().TabMenuPatientInfo == 5
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 12.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation5']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation6'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation6']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 6;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel6,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'การวินิจฉัย',
                            tabmenupatient: 6,
                            icon: FaIcon(
                              FontAwesomeIcons.fileContract,
                              color: FFAppState().TabMenuPatientInfo == 6
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 12.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation6']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation7'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation7']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 7;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel7,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'ยา/ค่าบริการ',
                            tabmenupatient: 7,
                            icon: FaIcon(
                              FontAwesomeIcons.capsules,
                              color: FFAppState().TabMenuPatientInfo == 7
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 10.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation7']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation8'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation8']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 8;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel8,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'นัดหมาย',
                            tabmenupatient: 8,
                            icon: FaIcon(
                              FontAwesomeIcons.calendarDay,
                              color: FFAppState().TabMenuPatientInfo == 8
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 10.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation8']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation9'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation9']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 9;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel9,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'Consult',
                            tabmenupatient: 9,
                            icon: FaIcon(
                              FontAwesomeIcons.commentMedical,
                              color: FFAppState().TabMenuPatientInfo == 9
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 12.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation9']!,
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (animationsMap[
                                  'menuPatientInfoIPDOnActionTriggerAnimation10'] !=
                              null) {
                            animationsMap[
                                    'menuPatientInfoIPDOnActionTriggerAnimation10']!
                                .controller
                                .forward(from: 0.0);
                          }
                          FFAppState().TabMenuPatientInfo = 10;
                          safeSetState(() {});
                        },
                        child: wrapWithModel(
                          model: _model.menuPatientInfoIPDModel10,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuPatientInfoIPDWidget(
                            namemenu: 'ใบรับรองแพทย์',
                            tabmenupatient: 10,
                            icon: FaIcon(
                              FontAwesomeIcons.fileMedical,
                              color: FFAppState().TabMenuPatientInfo == 10
                                  ? FlutterFlowTheme.of(context).accent1
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                              size: 12.0,
                            ),
                          ),
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'menuPatientInfoIPDOnActionTriggerAnimation10']!,
                      ),
                    ].divide(SizedBox(width: () {
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
                      if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
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
                    child: Stack(
                      children: [
                        if (FFAppState().TabMenuPatientInfo == 1)
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.admitpageViewModel,
                              updateCallback: () => safeSetState(() {}),
                              child: AdmitpageViewWidget(
                                buttonReport: true,
                                crossAxisCount: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 1;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 1;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 3;
                                  } else {
                                    return 3;
                                  }
                                }(),
                              ),
                            ),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 2)
                          wrapWithModel(
                            model: _model.eMRpageViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: EMRpageViewWidget(),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 4)
                          wrapWithModel(
                            model: _model.vitalsignpageViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: VitalsignpageViewWidget(
                              buttonaddTreatment: true,
                              crossAxisCount: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 2;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 3;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 3;
                                } else {
                                  return 3;
                                }
                              }(),
                              bottonAddNursRecod: true,
                              buttonaddNursPromple: true,
                              sizemenu: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 48.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 48.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 64.0;
                                } else {
                                  return 64.0;
                                }
                              }(),
                            ),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 5)
                          wrapWithModel(
                            model: _model.labXrayViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: LabXrayViewWidget(
                              buttonadd: true,
                            ),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 6)
                          wrapWithModel(
                            model: _model.diagViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: DiagViewWidget(),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 7)
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.drugSreviceViewModel,
                              updateCallback: () => safeSetState(() {}),
                              child: DrugSreviceViewWidget(),
                            ),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 8)
                          wrapWithModel(
                            model: _model.appiontmentViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: AppiontmentViewWidget(),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 9)
                          wrapWithModel(
                            model: _model.cousultViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: CousultViewWidget(),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 10)
                          wrapWithModel(
                            model: _model.medicalcertificateViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: MedicalcertificateViewWidget(
                              buttonadd: true,
                              crossAxisCount: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 2;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 2;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 3;
                                } else {
                                  return 3;
                                }
                              }(),
                            ),
                          ),
                        if (FFAppState().TabMenuPatientInfo == 3)
                          wrapWithModel(
                            model: _model.orderSheetViewModel,
                            updateCallback: () => safeSetState(() {}),
                            child: OrderSheetViewWidget(
                              buttonadd: true,
                            ),
                          ),
                      ],
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
