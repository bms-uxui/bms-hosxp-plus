import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/button_cancel/button_cancel_widget.dart';
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
import 'alert_dialog_delete_model.dart';
export 'alert_dialog_delete_model.dart';

class AlertDialogDeleteWidget extends StatefulWidget {
  const AlertDialogDeleteWidget({super.key});

  @override
  State<AlertDialogDeleteWidget> createState() =>
      _AlertDialogDeleteWidgetState();
}

class _AlertDialogDeleteWidgetState extends State<AlertDialogDeleteWidget>
    with TickerProviderStateMixin {
  late AlertDialogDeleteModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlertDialogDeleteModel());

    animationsMap.addAll({
      'imageOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          SaturateEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_6_.._2568_16_05_47.png',
                        width: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 74.0;
                          } else {
                            return 74.0;
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
                            return 74.0;
                          } else {
                            return 74.0;
                          }
                        }(),
                        fit: BoxFit.cover,
                      ),
                    ).animateOnPageLoad(
                        animationsMap['imageOnPageLoadAnimation']!),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'ลบข้อมูล!',
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
                        ),
                        Text(
                          'คุณต้องการลบข้อมูลนี้หรือไม่?',
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
                color: FlutterFlowTheme.of(context).primaryBackground,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: wrapWithModel(
                        model: _model.buttonCancelModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ButtonCancelWidget(),
                      ),
                    ),
                    wrapWithModel(
                      model: _model.bottonPrimaryModel,
                      updateCallback: () => safeSetState(() {}),
                      child: BottonPrimaryWidget(
                        buttonprimary: 'ตกลง',
                      ),
                    ),
                  ].divide(SizedBox(width: 12.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
