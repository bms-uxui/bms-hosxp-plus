import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/vitalsign/antibiotices_view/antibiotices_view_widget.dart';
import '/ipd/vitalsign/graphicsheetpage_view/graphicsheetpage_view_widget.dart';
import '/ipd/vitalsign/nurs_probltm_view/nurs_probltm_view_widget.dart';
import '/ipd/vitalsign/nurw_records_view/nurw_records_view_widget.dart';
import '/ipd/vitalsign/treatment_view/treatment_view_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'vitalsignpage_view_model.dart';
export 'vitalsignpage_view_model.dart';

class VitalsignpageViewWidget extends StatefulWidget {
  const VitalsignpageViewWidget({
    super.key,
    bool? buttonaddTreatment,
    this.crossAxisCount,
    bool? bottonAddNursRecod,
    bool? buttonaddNursPromple,
    this.sizemenu,
  })  : this.buttonaddTreatment = buttonaddTreatment ?? false,
        this.bottonAddNursRecod = bottonAddNursRecod ?? false,
        this.buttonaddNursPromple = buttonaddNursPromple ?? false;

  final bool buttonaddTreatment;
  final int? crossAxisCount;
  final bool bottonAddNursRecod;
  final bool buttonaddNursPromple;
  final double? sizemenu;

  @override
  State<VitalsignpageViewWidget> createState() =>
      _VitalsignpageViewWidgetState();
}

class _VitalsignpageViewWidgetState extends State<VitalsignpageViewWidget>
    with TickerProviderStateMixin {
  late VitalsignpageViewModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VitalsignpageViewModel());

    animationsMap.addAll({
      'containerOnActionTriggerAnimation1': AnimationInfo(
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
      'containerOnActionTriggerAnimation2': AnimationInfo(
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
      'containerOnActionTriggerAnimation3': AnimationInfo(
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
      'containerOnActionTriggerAnimation4': AnimationInfo(
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
      'containerOnActionTriggerAnimation5': AnimationInfo(
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
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  valueOrDefault<double>(
                    () {
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
                    }(),
                    0.0,
                  ),
                  valueOrDefault<double>(
                    () {
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
                    }(),
                    0.0,
                  ),
                  valueOrDefault<double>(
                    () {
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
                    }(),
                    0.0,
                  ),
                  0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            if (animationsMap[
                                    'containerOnActionTriggerAnimation1'] !=
                                null) {
                              animationsMap[
                                      'containerOnActionTriggerAnimation1']!
                                  .controller
                                  .forward(from: 0.0);
                            }
                            FFAppState().MenuVitalsign = 1;
                            safeSetState(() {});
                          },
                          child: Container(
                            width: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            height: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x19000000),
                                  offset: Offset(
                                    0.0,
                                    0.0,
                                  ),
                                )
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  FFAppState().MenuVitalsign == 1
                                      ? FlutterFlowTheme.of(context).accent2
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                  FFAppState().MenuVitalsign == 1
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(0.0, -1.0),
                                end: AlignmentDirectional(0, 1.0),
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.asset(
                                  'assets/images/C8757D7A-0CAF-45DD-8F06-D83A0F7776F0-removebg-preview.png',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ).animateOnActionTrigger(
                          animationsMap['containerOnActionTriggerAnimation1']!,
                        ),
                        Text(
                          'ฟอร์มปรอท',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 12.0;
                                  } else {
                                    return 12.0;
                                  }
                                }(),
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodySmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            if (animationsMap[
                                    'containerOnActionTriggerAnimation2'] !=
                                null) {
                              animationsMap[
                                      'containerOnActionTriggerAnimation2']!
                                  .controller
                                  .forward(from: 0.0);
                            }
                            FFAppState().MenuVitalsign = 2;
                            safeSetState(() {});
                          },
                          child: Container(
                            width: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            height: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x19000000),
                                  offset: Offset(
                                    0.0,
                                    0.0,
                                  ),
                                )
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  FFAppState().MenuVitalsign == 2
                                      ? FlutterFlowTheme.of(context).accent2
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                  FFAppState().MenuVitalsign == 2
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(0.0, -1.0),
                                end: AlignmentDirectional(0, 1.0),
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.asset(
                                  'assets/images/8B18A61B-0120-46BB-B3F4-5FCA7B92AE8C-removebg-preview.png',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ).animateOnActionTrigger(
                          animationsMap['containerOnActionTriggerAnimation2']!,
                        ),
                        Text(
                          'ยาปฏิชีวนะ',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 12.0;
                                  } else {
                                    return 12.0;
                                  }
                                }(),
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodySmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            if (animationsMap[
                                    'containerOnActionTriggerAnimation3'] !=
                                null) {
                              animationsMap[
                                      'containerOnActionTriggerAnimation3']!
                                  .controller
                                  .forward(from: 0.0);
                            }
                            FFAppState().MenuVitalsign = 3;
                            safeSetState(() {});
                          },
                          child: Container(
                            width: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            height: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x19000000),
                                  offset: Offset(
                                    0.0,
                                    0.0,
                                  ),
                                )
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  FFAppState().MenuVitalsign == 3
                                      ? FlutterFlowTheme.of(context).accent2
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                  FFAppState().MenuVitalsign == 3
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(0.0, -1.0),
                                end: AlignmentDirectional(0, 1.0),
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.asset(
                                  'assets/images/B068BE02-81E3-4E14-A230-528ABD287760-removebg-preview.png',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ).animateOnActionTrigger(
                          animationsMap['containerOnActionTriggerAnimation3']!,
                        ),
                        Text(
                          'บันทึกพยาบาล',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 12.0;
                                  } else {
                                    return 12.0;
                                  }
                                }(),
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodySmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            if (animationsMap[
                                    'containerOnActionTriggerAnimation4'] !=
                                null) {
                              animationsMap[
                                      'containerOnActionTriggerAnimation4']!
                                  .controller
                                  .forward(from: 0.0);
                            }
                            FFAppState().MenuVitalsign = 4;
                            safeSetState(() {});
                          },
                          child: Container(
                            width: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            height: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x19000000),
                                  offset: Offset(
                                    0.0,
                                    0.0,
                                  ),
                                )
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  FFAppState().MenuVitalsign == 4
                                      ? FlutterFlowTheme.of(context).accent2
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                  FFAppState().MenuVitalsign == 4
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(0.0, -1.0),
                                end: AlignmentDirectional(0, 1.0),
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.asset(
                                  'assets/images/6421AD91-5C65-4176-84BF-49F8E4F29DE9-removebg-preview.png',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ).animateOnActionTrigger(
                          animationsMap['containerOnActionTriggerAnimation4']!,
                        ),
                        Text(
                          'ปัญหาทางพยาบาล',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 12.0;
                                  } else {
                                    return 12.0;
                                  }
                                }(),
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodySmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            if (animationsMap[
                                    'containerOnActionTriggerAnimation5'] !=
                                null) {
                              animationsMap[
                                      'containerOnActionTriggerAnimation5']!
                                  .controller
                                  .forward(from: 0.0);
                            }
                            FFAppState().MenuVitalsign = 5;
                            safeSetState(() {});
                          },
                          child: Container(
                            width: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            height: valueOrDefault<double>(
                              widget!.sizemenu,
                              48.0,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x19000000),
                                  offset: Offset(
                                    0.0,
                                    0.0,
                                  ),
                                )
                              ],
                              gradient: LinearGradient(
                                colors: [
                                  FFAppState().MenuVitalsign == 5
                                      ? FlutterFlowTheme.of(context).accent2
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                  FFAppState().MenuVitalsign == 5
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                ],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(0.0, -1.0),
                                end: AlignmentDirectional(0, 1.0),
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.asset(
                                  'assets/images/F921866B-16EF-45F5-9729-328C3DEB179A-removebg-preview.png',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ).animateOnActionTrigger(
                          animationsMap['containerOnActionTriggerAnimation5']!,
                        ),
                        Text(
                          'หัตถการผู้ป่วยใน',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodySmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodySmallFamily,
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 10.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 12.0;
                                  } else {
                                    return 12.0;
                                  }
                                }(),
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodySmallIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(height: 12.0)),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).secondaryBackground,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    if (FFAppState().MenuVitalsign == 1)
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: wrapWithModel(
                          model: _model.graphicsheetpageViewModel,
                          updateCallback: () => safeSetState(() {}),
                          child: GraphicsheetpageViewWidget(),
                        ),
                      ),
                    if (FFAppState().MenuVitalsign == 2)
                      wrapWithModel(
                        model: _model.antibioticesViewModel,
                        updateCallback: () => safeSetState(() {}),
                        child: AntibioticesViewWidget(),
                      ),
                    if (FFAppState().MenuVitalsign == 3)
                      wrapWithModel(
                        model: _model.nurwRecordsViewModel,
                        updateCallback: () => safeSetState(() {}),
                        child: NurwRecordsViewWidget(
                          crossAxisCount: widget!.crossAxisCount,
                          bottonAddNursRecod: widget!.bottonAddNursRecod,
                        ),
                      ),
                    if (FFAppState().MenuVitalsign == 4)
                      wrapWithModel(
                        model: _model.nursProbltmViewModel,
                        updateCallback: () => safeSetState(() {}),
                        child: NursProbltmViewWidget(
                          buttonaddNursPromple: widget!.buttonaddNursPromple,
                        ),
                      ),
                    if (FFAppState().MenuVitalsign == 5)
                      wrapWithModel(
                        model: _model.treatmentViewModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TreatmentViewWidget(
                          buttonaddTreatment: widget!.buttonaddTreatment,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ].divide(SizedBox(height: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 12.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 12.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 16.0;
            } else {
              return 16.0;
            }
          }())),
        ),
      ),
    );
  }
}
