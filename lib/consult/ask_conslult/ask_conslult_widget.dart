import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/dateand_time_recorde/dateand_time_recorde_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ask_conslult_model.dart';
export 'ask_conslult_model.dart';

class AskConslultWidget extends StatefulWidget {
  const AskConslultWidget({super.key});

  @override
  State<AskConslultWidget> createState() => _AskConslultWidgetState();
}

class _AskConslultWidgetState extends State<AskConslultWidget>
    with TickerProviderStateMixin {
  late AskConslultModel _model;

  var hasColumnTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AskConslultModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, -18.0),
            end: Offset(0.0, 0.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'columnOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.elasticOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, -100.0),
            end: Offset(0.0, 0.0),
          ),
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
    context.watch<FFAppState>();

    return Column(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ตอบ Conslult',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Color(0x80465054),
                          offset: Offset(2.0, 2.0),
                          blurRadius: 2.0,
                        )
                      ],
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                    ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  Navigator.pop(context);
                  FFAppState().Message = false;
                  safeSetState(() {});
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
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            height: 100.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        valueOrDefault<double>(
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
                        ),
                        2.0,
                        valueOrDefault<double>(
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
                        ),
                        0.0),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 16.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 16.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 24.0;
                          } else {
                            return 24.0;
                          }
                        }(),
                        0,
                        24.0,
                      ),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
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
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                            FlutterFlowTheme.of(context).accent2
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                        child: Image.asset(
                                          'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          textScaler:
                                              MediaQuery.of(context).textScaler,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'ผู้ถาม : ',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmallFamily,
                                                          letterSpacing: 0.0,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmallIsCustom,
                                                        ),
                                              ),
                                              TextSpan(
                                                text: 'นายแพทยทดลอง ทดสอบ',
                                                style:
                                                    FlutterFlowTheme.of(context)
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
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                              )
                                            ],
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumFamily,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model:
                                              _model.dateandTimeRecordeModel1,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: DateandTimeRecordeWidget(),
                                        ),
                                      ].divide(SizedBox(height: 2.0)),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                              ].divide(SizedBox(height: 4.0)),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(24.0),
                                  bottomLeft: Radius.circular(24.0),
                                  bottomRight: Radius.circular(24.0),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(valueOrDefault<double>(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.question_mark_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 16.0,
                                        ),
                                        Text(
                                          'เรื่องที่ Consult',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmallFamily,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmallIsCustom,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                    Text(
                                      'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                        if (FFAppState().Message == true)
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          RichText(
                                            textScaler: MediaQuery.of(context)
                                                .textScaler,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'ผู้ตอบ : ',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallIsCustom,
                                                          ),
                                                ),
                                                TextSpan(
                                                  text: 'นายแพทยทดลอง ทดสอบ',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                )
                                              ],
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMediumFamily,
                                                        letterSpacing: 0.0,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMediumIsCustom,
                                                      ),
                                            ),
                                          ),
                                          wrapWithModel(
                                            model:
                                                _model.dateandTimeRecordeModel2,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: DateandTimeRecordeWidget(),
                                          ),
                                        ].divide(SizedBox(height: 2.0)),
                                      ),
                                      Container(
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
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              FlutterFlowTheme.of(context)
                                                  .secondary,
                                              FlutterFlowTheme.of(context)
                                                  .accent2
                                            ],
                                            stops: [0.0, 1.0],
                                            begin:
                                                AlignmentDirectional(0.0, -1.0),
                                            end: AlignmentDirectional(0, 1.0),
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          child: Image.asset(
                                            'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 8.0)),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                              Container(
                                width: double.infinity,
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
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(24.0),
                                    topRight: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(24.0),
                                    bottomRight: Radius.circular(24.0),
                                  ),
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
                                        children: [
                                          Icon(
                                            Icons.chat_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            size: 16.0,
                                          ),
                                          Text(
                                            'คำตอบ',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  fontFamily:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallFamily,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  letterSpacing: 0.0,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmallIsCustom,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                      Text(
                                        'คนไข้ น้ำตาลสูง พึ่งเจาะวันนี้ครับ ยังไม่เคยรับยาหรือรักษาประจำแต่เคยตรวจและรับยาแค่บางช่วง\nแพทย์ที่นั่นจึงแนะนนำคนไข้มารักษาตามสิทธ์ที่อภัยภูเบศรและมาเริ่มทานสมุนไพร แต่ผู้ป่วยทานไม่ต้อเนื่อง จึงข้อ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 8.0)),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 8.0)),
                          ).animateOnActionTrigger(
                              animationsMap['columnOnActionTriggerAnimation']!,
                              hasBeenTriggered: hasColumnTriggered),
                      ].divide(SizedBox(height: () {
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
                if (FFAppState().Message == false)
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: 100.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x2596B8F3), Color(0x25326AC0)],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(0.0, -1.0),
                          end: AlignmentDirectional(0, 1.0),
                        ),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'ข้อความ...',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelMediumFamily,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w200,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelMediumIsCustom,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .bodyMediumFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .bodyMediumIsCustom,
                                    ),
                                maxLines: null,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primary,
                                validator: _model.textControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  FFAppState().Message = true;
                                  safeSetState(() {});
                                  if (animationsMap[
                                          'columnOnActionTriggerAnimation'] !=
                                      null) {
                                    safeSetState(
                                        () => hasColumnTriggered = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => animationsMap[
                                                'columnOnActionTriggerAnimation']!
                                            .controller
                                            .forward(from: 0.0));
                                  }
                                },
                                child: Container(
                                  height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 32.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 40.0;
                                    } else {
                                      return 40.0;
                                    }
                                  }(),
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
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        12.0, 0.0, 12.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.send_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 14.0,
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: Text(
                                            'ส่งคำตอบ',
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
                                                  fontWeight: FontWeight.normal,
                                                  useGoogleFonts:
                                                      !FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMediumIsCustom,
                                                ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
        ),
      ].divide(SizedBox(height: 16.0)),
    );
  }
}
