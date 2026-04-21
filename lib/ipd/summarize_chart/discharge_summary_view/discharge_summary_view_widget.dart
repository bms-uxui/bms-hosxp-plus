import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/diagnosis/item_diagnosis_i_c_d10/item_diagnosis_i_c_d10_widget.dart';
import '/ipd/diagnosis/item_diagnosis_i_c_d9_c_m/item_diagnosis_i_c_d9_c_m_widget.dart';
import '/ipd/summarize_chart/add_discharge_summary/add_discharge_summary_widget.dart';
import '/ipd/summarize_chart/add_icd10_dischage/add_icd10_dischage_widget.dart';
import '/ipd/summarize_chart/add_icd9_dischage/add_icd9_dischage_widget.dart';
import '/ipd/summarize_chart/add_treatmentsummary/add_treatmentsummary_widget.dart';
import '/ipd/summarize_chart/item_discharge/item_discharge_widget.dart';
import '/ipd/summarize_chart/item_treatmentsummary/item_treatmentsummary_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'discharge_summary_view_model.dart';
export 'discharge_summary_view_model.dart';

class DischargeSummaryViewWidget extends StatefulWidget {
  const DischargeSummaryViewWidget({super.key});

  @override
  State<DischargeSummaryViewWidget> createState() =>
      _DischargeSummaryViewWidgetState();
}

class _DischargeSummaryViewWidgetState extends State<DischargeSummaryViewWidget>
    with TickerProviderStateMixin {
  late DischargeSummaryViewModel _model;

  var hasConditionalBuilderTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DischargeSummaryViewModel());

    animationsMap.addAll({
      'conditionalBuilderOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
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
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(valueOrDefault<double>(
          () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 12.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 16.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 16.0;
            } else {
              return 16.0;
            }
          }(),
          0.0,
        )),
        child: Builder(
          builder: (context) {
            if (_model.dischargeSummary == 1) {
              return wrapWithModel(
                model: _model.addDischargeSummaryModel,
                updateCallback: () => safeSetState(() {}),
                child: AddDischargeSummaryWidget(
                  navigatback: () async {
                    _model.dischargeSummary = null;
                    safeSetState(() {});
                  },
                  saveaction: () async {
                    _model.dischargeSummary = null;
                    safeSetState(() {});
                  },
                ),
              );
            } else if (_model.dischargeSummary == 2) {
              return wrapWithModel(
                model: _model.addIcd10DischageModel,
                updateCallback: () => safeSetState(() {}),
                child: AddIcd10DischageWidget(
                  navigatback: () async {
                    _model.dischargeSummary = null;
                    safeSetState(() {});
                  },
                  saveaction: () async {
                    _model.dischargeSummary = null;
                    safeSetState(() {});
                  },
                ),
              );
            } else if (_model.dischargeSummary == 3) {
              return wrapWithModel(
                model: _model.addIcd9DischageModel,
                updateCallback: () => safeSetState(() {}),
                child: AddIcd9DischageWidget(
                  navigatback: () async {
                    _model.dischargeSummary = null;
                    safeSetState(() {});
                  },
                  saveaction: () async {
                    _model.dischargeSummary = null;
                    safeSetState(() {});
                  },
                ),
              );
            } else if (_model.dischargeSummary == 4) {
              return wrapWithModel(
                model: _model.addTreatmentsummaryModel,
                updateCallback: () => safeSetState(() {}),
                child: AddTreatmentsummaryWidget(
                  navigatback: () async {
                    _model.dischargeSummary = null;
                    safeSetState(() {});
                  },
                  saveaction: () async {
                    _model.dischargeSummary = null;
                    safeSetState(() {});
                  },
                ),
              );
            } else {
              return ListView(
                padding: EdgeInsets.zero,
                primary: false,
                scrollDirection: Axis.vertical,
                children: [
                  Container(
                    height: 70.0,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12.0,
                          color: Color(0x19000000),
                          offset: Offset(
                            0.0,
                            0.0,
                          ),
                          spreadRadius: 2.0,
                        )
                      ],
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
                    child: Stack(
                      children: [
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ข้อมูลสรุป Discharge',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ]
                                .divide(SizedBox(width: 16.0))
                                .around(SizedBox(width: 16.0)),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional(1.0, 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(24.0),
                              bottomRight: Radius.circular(24.0),
                            ),
                            child: Image.asset(
                              'assets/images/ChatGPT_Image_21_.._2568_16_53_12.png',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                              alignment: Alignment(1.0, -1.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context).customColor5,
                                      FlutterFlowTheme.of(context).customColor6
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0, 1.0),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Icon(
                                    Icons.table_chart,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    size: 10.0,
                                  ),
                                ),
                              ),
                              Text(
                                'Discharge Summary',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .customColor10,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (animationsMap[
                                      'conditionalBuilderOnActionTriggerAnimation'] !=
                                  null) {
                                safeSetState(() =>
                                    hasConditionalBuilderTriggered = true);
                                SchedulerBinding.instance.addPostFrameCallback(
                                    (_) async => animationsMap[
                                            'conditionalBuilderOnActionTriggerAnimation']!
                                        .controller
                                        .forward(from: 0.0));
                              }
                              _model.dischargeSummary = 1;
                              safeSetState(() {});
                            },
                            child: wrapWithModel(
                              model: _model.iconButtonPrimaryModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: IconButtonPrimaryWidget(
                                iconbuttonprimary: Icon(
                                  Icons.add_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      wrapWithModel(
                        model: _model.itemDischargeModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ItemDischargeWidget(
                          border:
                              FlutterFlowTheme.of(context).primaryBackground,
                          diag: 'Acute nasopharyngitis',
                        ),
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context)
                                          .customColor11,
                                      FlutterFlowTheme.of(context).customColor12
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0, 1.0),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    '10',
                                    style: GoogleFonts.roboto(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'Diagnosis ICD-10',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .customColor12,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (animationsMap[
                                      'conditionalBuilderOnActionTriggerAnimation'] !=
                                  null) {
                                safeSetState(() =>
                                    hasConditionalBuilderTriggered = true);
                                SchedulerBinding.instance.addPostFrameCallback(
                                    (_) async => animationsMap[
                                            'conditionalBuilderOnActionTriggerAnimation']!
                                        .controller
                                        .forward(from: 0.0));
                              }
                              _model.dischargeSummary = 2;
                              safeSetState(() {});
                            },
                            child: wrapWithModel(
                              model: _model.iconButtonPrimaryModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: IconButtonPrimaryWidget(
                                iconbuttonprimary: Icon(
                                  Icons.add_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      wrapWithModel(
                        model: _model.itemDiagnosisICD10Model,
                        updateCallback: () => safeSetState(() {}),
                        child: ItemDiagnosisICD10Widget(
                          border:
                              FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context).customColor7,
                                      FlutterFlowTheme.of(context).customColor8
                                    ],
                                    stops: [0.0, 1.0],
                                    begin: AlignmentDirectional(0.0, -1.0),
                                    end: AlignmentDirectional(0, 1.0),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    '9',
                                    style: GoogleFonts.roboto(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                'Diagnosis ICD-9-CM',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color: FlutterFlowTheme.of(context)
                                          .customColor8,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (animationsMap[
                                      'conditionalBuilderOnActionTriggerAnimation'] !=
                                  null) {
                                safeSetState(() =>
                                    hasConditionalBuilderTriggered = true);
                                SchedulerBinding.instance.addPostFrameCallback(
                                    (_) async => animationsMap[
                                            'conditionalBuilderOnActionTriggerAnimation']!
                                        .controller
                                        .forward(from: 0.0));
                              }
                              _model.dischargeSummary = 3;
                              safeSetState(() {});
                            },
                            child: wrapWithModel(
                              model: _model.iconButtonPrimaryModel3,
                              updateCallback: () => safeSetState(() {}),
                              child: IconButtonPrimaryWidget(
                                iconbuttonprimary: Icon(
                                  Icons.add_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      wrapWithModel(
                        model: _model.itemDiagnosisICD9CMModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ItemDiagnosisICD9CMWidget(
                          border:
                              FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.0,
                                height: 24.0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FlutterFlowTheme.of(context).accent2,
                                      FlutterFlowTheme.of(context).accent1
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
                                    FontAwesomeIcons.stethoscope,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    size: 10.0,
                                  ),
                                ),
                              ),
                              Text(
                                'สรุปการรักษาจากแพทย์',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color:
                                          FlutterFlowTheme.of(context).accent1,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (animationsMap[
                                      'conditionalBuilderOnActionTriggerAnimation'] !=
                                  null) {
                                safeSetState(() =>
                                    hasConditionalBuilderTriggered = true);
                                SchedulerBinding.instance.addPostFrameCallback(
                                    (_) async => animationsMap[
                                            'conditionalBuilderOnActionTriggerAnimation']!
                                        .controller
                                        .forward(from: 0.0));
                              }
                              _model.dischargeSummary = 4;
                              safeSetState(() {});
                            },
                            child: wrapWithModel(
                              model: _model.iconButtonPrimaryModel4,
                              updateCallback: () => safeSetState(() {}),
                              child: IconButtonPrimaryWidget(
                                iconbuttonprimary: Icon(
                                  Icons.add_rounded,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      wrapWithModel(
                        model: _model.itemTreatmentsummaryModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ItemTreatmentsummaryWidget(
                          time: '',
                          border:
                              FlutterFlowTheme.of(context).primaryBackground,
                        ),
                      ),
                    ].divide(SizedBox(height: 8.0)),
                  ),
                ].divide(SizedBox(height: () {
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
              );
            }
          },
        ).animateOnActionTrigger(
            animationsMap['conditionalBuilderOnActionTriggerAnimation']!,
            hasBeenTriggered: hasConditionalBuilderTriggered),
      ),
    );
  }
}
