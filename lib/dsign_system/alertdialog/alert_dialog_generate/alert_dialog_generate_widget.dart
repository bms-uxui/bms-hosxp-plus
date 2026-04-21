import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'alert_dialog_generate_model.dart';
export 'alert_dialog_generate_model.dart';

class AlertDialogGenerateWidget extends StatefulWidget {
  const AlertDialogGenerateWidget({super.key});

  @override
  State<AlertDialogGenerateWidget> createState() =>
      _AlertDialogGenerateWidgetState();
}

class _AlertDialogGenerateWidgetState extends State<AlertDialogGenerateWidget>
    with TickerProviderStateMixin {
  late AlertDialogGenerateModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlertDialogGenerateModel());

    animationsMap.addAll({
      'blurOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'imageOnPageLoadAnimation1': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 170.ms),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 170.0.ms,
            duration: 1250.0.ms,
            begin: Offset(0.5, 0.5),
            end: Offset(1.0, 1.0),
          ),
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 170.0.ms,
            duration: 1250.0.ms,
            begin: 0.5,
            end: 1.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation2': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 170.ms),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 380.0.ms,
            duration: 1250.0.ms,
            begin: Offset(0.5, 0.5),
            end: Offset(1.0, 1.0),
          ),
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 380.0.ms,
            duration: 1250.0.ms,
            begin: 0.5,
            end: 1.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation3': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 380.ms),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 380.0.ms,
            duration: 1250.0.ms,
            begin: Offset(0.0, 0.0),
            end: Offset(1.0, 1.0),
          ),
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 380.0.ms,
            duration: 1250.0.ms,
            begin: 0.5,
            end: 1.0,
          ),
        ],
      ),
      'textOnPageLoadAnimation': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 1480.0.ms,
            color: Color(0x80FFFFFF),
            angle: 0.524,
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ),
        child: Container(
          width: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 280.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 280.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 380.0;
            } else {
              return 380.0;
            }
          }(),
          decoration: BoxDecoration(
            color: Color(0xE5FFFFFF),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: Color(0xB2F1F4F8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(valueOrDefault<double>(
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
                )),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      child: Stack(
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.5, 0.0),
                            child: Hero(
                              tag: 'AIgenerate',
                              transitionOnUserGestures: true,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/ChatGPT_Image_5_.._2568_17_09_03.png',
                                  width: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 48.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 48.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 56.0;
                                    } else {
                                      return 56.0;
                                    }
                                  }(),
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 48.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 48.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 56.0;
                                    } else {
                                      return 56.0;
                                    }
                                  }(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ).animateOnPageLoad(
                                animationsMap['imageOnPageLoadAnimation1']!),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-0.77, -0.81),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/ChatGPT_Image_5_.._2568_17_09_03.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ).animateOnPageLoad(
                                animationsMap['imageOnPageLoadAnimation2']!),
                          ),
                          Align(
                            alignment: AlignmentDirectional(-0.61, 0.79),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/ChatGPT_Image_5_.._2568_17_09_03.png',
                                width: 16.0,
                                height: 16.0,
                                fit: BoxFit.cover,
                              ),
                            ).animateOnPageLoad(
                                animationsMap['imageOnPageLoadAnimation3']!),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'กำลังประมวนผล',
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyLargeFamily,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyLargeIsCustom,
                              ),
                        ).animateOnPageLoad(
                            animationsMap['textOnPageLoadAnimation']!),
                        Text(
                          'กำลังวิเคราะห์ข้อมูล กรุณารอสักครู่...',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .bodyMediumFamily,
                                letterSpacing: 0.0,
                                lineHeight: 1.8,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .bodyMediumIsCustom,
                              ),
                        ),
                      ].divide(SizedBox(height: 4.0)),
                    ),
                  ].divide(SizedBox(height: 16.0)),
                ),
              ),
              Divider(
                height: 1.0,
                thickness: 1.0,
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              Padding(
                padding: EdgeInsets.all(valueOrDefault<double>(
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
                )),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'ยกเลิก',
                                style: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyLargeFamily,
                                      color: FlutterFlowTheme.of(context).error,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyLargeIsCustom,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ].divide(SizedBox(width: 12.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animateOnPageLoad(animationsMap['blurOnPageLoadAnimation']!);
  }
}
