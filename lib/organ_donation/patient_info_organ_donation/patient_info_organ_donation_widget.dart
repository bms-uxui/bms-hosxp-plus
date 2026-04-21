import '/dsign_system/alertdialog/alert_dialog_i_dcard/alert_dialog_i_dcard_widget.dart';
import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/consult/buttonsheet_doctor/buttonsheet_doctor_widget.dart';
import '/organ_donation/buttonsheet_numeye/buttonsheet_numeye_widget.dart';
import '/organ_donation/buttonsheet_reasoneyewasnotpreserved/buttonsheet_reasoneyewasnotpreserved_widget.dart';
import '/organ_donation/buttonsheet_reasonsforunsuccessfu/buttonsheet_reasonsforunsuccessfu_widget.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'patient_info_organ_donation_model.dart';
export 'patient_info_organ_donation_model.dart';

class PatientInfoOrganDonationWidget extends StatefulWidget {
  const PatientInfoOrganDonationWidget({super.key});

  static String routeName = 'Patient_Info_OrganDonation';
  static String routePath = 'patientInfoOrganDonation';

  @override
  State<PatientInfoOrganDonationWidget> createState() =>
      _PatientInfoOrganDonationWidgetState();
}

class _PatientInfoOrganDonationWidgetState
    extends State<PatientInfoOrganDonationWidget>
    with TickerProviderStateMixin {
  late PatientInfoOrganDonationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;
  var hasContainerTriggered1 = false;
  var hasContainerTriggered2 = false;
  var hasContainerTriggered3 = false;
  var hasContainerTriggered4 = false;
  var hasContainerTriggered5 = false;
  var hasContainerTriggered6 = false;
  var hasContainerTriggered7 = false;
  var hasContainerTriggered8 = false;
  var hasContainerTriggered9 = false;
  var hasContainerTriggered10 = false;
  var hasContainerTriggered11 = false;
  var hasContainerTriggered12 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientInfoOrganDonationModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

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
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation8': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation9': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation10': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation11': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnActionTriggerAnimation12': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(1.1, 1.1),
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

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              tag: 'OrganDonationpage',
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
                  opacity: 0.1,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_25_.._2568_16_31_01.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.contain,
                        alignment: Alignment(1.0, -1.0),
                      ),
                    ),
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
              return Container(
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
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    0,
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
                    0,
                    0,
                  ),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    Padding(
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
                          0.0,
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
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8.0,
                              color: Color(0x19000000),
                              offset: Offset(
                                0.0,
                                0.0,
                              ),
                              spreadRadius: 0.0,
                            )
                          ],
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Stack(
                          children: [
                            Opacity(
                              opacity: 0.2,
                              child: Align(
                                alignment: AlignmentDirectional(1.0, -1.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 12.0, 12.0, 0.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/ChatGPT_Image_25_.._2568_16_31_01.png',
                                      width: 80.0,
                                      height: 80.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
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
                                      Text(
                                        'หอผู้ป่วย',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmallFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .labelSmallIsCustom,
                                            ),
                                      ),
                                      Text(
                                        'หอผู้ป่วยวิกฤตศัลยกรรมหัวใจ',
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMediumFamily,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyMediumIsCustom,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0x09465054),
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24.0),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5.0,
                                        sigmaY: 5.0,
                                      ),
                                      child: Padding(
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
                                              return 12.0;
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
                                        child: MasonryGridView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: () {
                                              if (MediaQuery.sizeOf(context)
                                                      .width <
                                                  kBreakpointSmall) {
                                                return 2;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointMedium) {
                                                return 2;
                                              } else if (MediaQuery.sizeOf(
                                                          context)
                                                      .width <
                                                  kBreakpointLarge) {
                                                return 4;
                                              } else {
                                                return 4;
                                              }
                                            }(),
                                          ),
                                          crossAxisSpacing: 12.0,
                                          mainAxisSpacing: 12.0,
                                          itemCount: 4,
                                          padding: EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            0,
                                          ),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return [
                                              () => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'HN',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                      Text(
                                                        '00000001',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                              () => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'AN',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                      Text(
                                                        '00000001',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                              () => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'โรคที่เสียชีวิต',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                      Text(
                                                        'หัวใจล้มเหลว',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                              () => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'วัน-เวลาเสียชีวิต',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodySmallFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodySmallIsCustom,
                                                                ),
                                                      ),
                                                      Text(
                                                        '5 เม.ย 2568 - 09:00 น.',
                                                        maxLines: 1,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMediumFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                            ][index]();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 560.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 560.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 980.0;
                          } else {
                            return 980.0;
                          }
                        }(),
                      ),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                valueOrDefault<double>(
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
                                ),
                                0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ข้อมูลการบริจาค',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyLargeFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyLargeIsCustom,
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: double.infinity,
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
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent1
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
                                                              0.0, -1.0),
                                                      end: AlignmentDirectional(
                                                          0, 1.0),
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: FaIcon(
                                                      FontAwesomeIcons.brain,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 8.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Brain/Cardiac',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                        MasonryGridView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                          ),
                                          crossAxisSpacing: 12.0,
                                          mainAxisSpacing: 12.0,
                                          itemCount: 2,
                                          padding: EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            0,
                                          ),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return [
                                              () => InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      _model.brainCardiac =
                                                          'Brain';
                                                      safeSetState(() {});
                                                      if (animationsMap[
                                                              'containerOnActionTriggerAnimation1'] !=
                                                          null) {
                                                        safeSetState(() =>
                                                            hasContainerTriggered1 =
                                                                true);
                                                        SchedulerBinding
                                                            .instance
                                                            .addPostFrameCallback(
                                                                (_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 100.0,
                                                      constraints:
                                                          BoxConstraints(
                                                        minWidth: 100.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            _model
                                                                        .brainCardiac ==
                                                                    'Brain'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent2
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                            _model
                                                                        .brainCardiac ==
                                                                    'Brain'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent1
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    8.0,
                                                                    12.0,
                                                                    8.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .brain,
                                                                color: _model
                                                                            .brainCardiac ==
                                                                        'Brain'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                size: 14.0,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Text(
                                                                'Brain',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      color: _model.brainCardiac ==
                                                                              'Brain'
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .secondaryBackground
                                                                          : FlutterFlowTheme.of(context)
                                                                              .secondaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ).animateOnActionTrigger(
                                                      animationsMap[
                                                          'containerOnActionTriggerAnimation1']!,
                                                      hasBeenTriggered:
                                                          hasContainerTriggered1),
                                              () => InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      _model.brainCardiac =
                                                          'Cardiac';
                                                      safeSetState(() {});
                                                      if (animationsMap[
                                                              'containerOnActionTriggerAnimation2'] !=
                                                          null) {
                                                        safeSetState(() =>
                                                            hasContainerTriggered2 =
                                                                true);
                                                        SchedulerBinding
                                                            .instance
                                                            .addPostFrameCallback(
                                                                (_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 100.0,
                                                      constraints:
                                                          BoxConstraints(
                                                        minWidth: 100.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            _model.brainCardiac ==
                                                                    'Cardiac'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent2
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                            _model.brainCardiac ==
                                                                    'Cardiac'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent1
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    8.0,
                                                                    12.0,
                                                                    8.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .solidHeart,
                                                                color: _model
                                                                            .brainCardiac ==
                                                                        'Cardiac'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                size: 14.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Cardiac',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: _model.brainCardiac ==
                                                                            'Cardiac'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ).animateOnActionTrigger(
                                                      animationsMap[
                                                          'containerOnActionTriggerAnimation2']!,
                                                      hasBeenTriggered:
                                                          hasContainerTriggered2),
                                            ][index]();
                                          },
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
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent1
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
                                                              0.0, -1.0),
                                                      end: AlignmentDirectional(
                                                          0, 1.0),
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: FaIcon(
                                                      FontAwesomeIcons
                                                          .handHoldingHeart,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 8.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'ศักยภาพการบริจาค',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 2,
                                              padding: EdgeInsets.fromLTRB(
                                                0,
                                                0,
                                                0,
                                                0,
                                              ),
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return [
                                                  () => InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.donationPotential =
                                                              'มีศักยภาพ ';
                                                          safeSetState(() {});
                                                          if (animationsMap[
                                                                  'containerOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasContainerTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            minWidth: 150.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                _model.donationPotential ==
                                                                        'มีศักยภาพ '
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor5
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                _model.donationPotential ==
                                                                        'มีศักยภาพ '
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor6
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: _model.donationPotential ==
                                                                            'มีศักยภาพ '
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'มีศักยภาพ ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color: _model.donationPotential == 'มีศักยภาพ '
                                                                              ? FlutterFlowTheme.of(context).secondaryBackground
                                                                              : FlutterFlowTheme.of(context).secondaryText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 8.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'containerOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasContainerTriggered3),
                                                  () => InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.donationPotential =
                                                              'ไม่มีศักยภาพ';
                                                          safeSetState(() {});
                                                          if (animationsMap[
                                                                  'containerOnActionTriggerAnimation4'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasContainerTriggered4 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation4']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            minWidth: 150.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                _model.donationPotential ==
                                                                        'ไม่มีศักยภาพ'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor19
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                _model.donationPotential ==
                                                                        'ไม่มีศักยภาพ'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor20
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .cancel_rounded,
                                                                    color: _model.donationPotential ==
                                                                            'ไม่มีศักยภาพ'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'ไม่มีศักยภาพ',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.donationPotential ==
                                                                                'ไม่มีศักยภาพ'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 8.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'containerOnActionTriggerAnimation4']!,
                                                          hasBeenTriggered:
                                                              hasContainerTriggered4),
                                                ][index]();
                                              },
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ].divide(SizedBox(height: 12.0)),
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
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent1
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
                                                              0.0, -1.0),
                                                      end: AlignmentDirectional(
                                                          0, 1.0),
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.local_hospital,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'ได้รับการแจ้งจาก Ward ถึง TC',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 2,
                                              padding: EdgeInsets.fromLTRB(
                                                0,
                                                0,
                                                0,
                                                0,
                                              ),
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return [
                                                  () => InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.waedCT =
                                                              'ได้รับการแจ้ง';
                                                          safeSetState(() {});
                                                          if (animationsMap[
                                                                  'containerOnActionTriggerAnimation5'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasContainerTriggered5 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation5']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            minWidth: 150.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                _model.waedCT ==
                                                                        'ได้รับการแจ้ง'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor5
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                _model.waedCT ==
                                                                        'ได้รับการแจ้ง'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor6
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: _model.waedCT ==
                                                                            'ได้รับการแจ้ง'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'ได้รับการแจ้ง',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color: _model.waedCT == 'ได้รับการแจ้ง'
                                                                              ? FlutterFlowTheme.of(context).secondaryBackground
                                                                              : FlutterFlowTheme.of(context).secondaryText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 8.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'containerOnActionTriggerAnimation5']!,
                                                          hasBeenTriggered:
                                                              hasContainerTriggered5),
                                                  () => InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.waedCT =
                                                              'ไม่ได้รับการแจ้ง';
                                                          safeSetState(() {});
                                                          if (animationsMap[
                                                                  'containerOnActionTriggerAnimation6'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasContainerTriggered6 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation6']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            minWidth: 150.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                _model.waedCT ==
                                                                        'ไม่ได้รับการแจ้ง'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor19
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                _model.waedCT ==
                                                                        'ไม่ได้รับการแจ้ง'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor20
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .cancel_rounded,
                                                                    color: _model.waedCT ==
                                                                            'ไม่ได้รับการแจ้ง'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'ไม่ได้รับการแจ้ง',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.waedCT ==
                                                                                'ไม่ได้รับการแจ้ง'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 8.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'containerOnActionTriggerAnimation6']!,
                                                          hasBeenTriggered:
                                                              hasContainerTriggered6),
                                                ][index]();
                                              },
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ].divide(SizedBox(height: 12.0)),
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
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent1
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
                                                              0.0, -1.0),
                                                      end: AlignmentDirectional(
                                                          0, 1.0),
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.chat_bubble_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 8.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'ได้รับการเจรจา',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                        MasonryGridView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                          ),
                                          crossAxisSpacing: 12.0,
                                          mainAxisSpacing: 12.0,
                                          itemCount: 2,
                                          padding: EdgeInsets.fromLTRB(
                                            0,
                                            0,
                                            0,
                                            0,
                                          ),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return [
                                              () => InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      _model.discussion =
                                                          'ได้รับการเจรจา';
                                                      safeSetState(() {});
                                                      if (animationsMap[
                                                              'containerOnActionTriggerAnimation7'] !=
                                                          null) {
                                                        safeSetState(() =>
                                                            hasContainerTriggered7 =
                                                                true);
                                                        SchedulerBinding
                                                            .instance
                                                            .addPostFrameCallback(
                                                                (_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation7']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                      }
                                                    },
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        minWidth: 150.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            _model.discussion ==
                                                                    'ได้รับการเจรจา'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor5
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                            _model.discussion ==
                                                                    'ได้รับการเจรจา'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor6
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    8.0,
                                                                    12.0,
                                                                    8.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: _model
                                                                            .discussion ==
                                                                        'ได้รับการเจรจา'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                size: 16.0,
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Text(
                                                                'ได้รับการเจรจา',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .bodyMediumFamily,
                                                                      color: _model.discussion ==
                                                                              'ได้รับการเจรจา'
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .secondaryBackground
                                                                          : FlutterFlowTheme.of(context)
                                                                              .secondaryText,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .bodyMediumIsCustom,
                                                                    ),
                                                              ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ).animateOnActionTrigger(
                                                      animationsMap[
                                                          'containerOnActionTriggerAnimation7']!,
                                                      hasBeenTriggered:
                                                          hasContainerTriggered7),
                                              () => InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      _model.discussion =
                                                          'ไม่ได้เจรจา';
                                                      safeSetState(() {});
                                                      if (animationsMap[
                                                              'containerOnActionTriggerAnimation8'] !=
                                                          null) {
                                                        safeSetState(() =>
                                                            hasContainerTriggered8 =
                                                                true);
                                                        SchedulerBinding
                                                            .instance
                                                            .addPostFrameCallback(
                                                                (_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation8']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                      }
                                                    },
                                                    child: Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        minWidth: 150.0,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            _model.discussion ==
                                                                    'ไม่ได้เจรจา'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor19
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                            _model.discussion ==
                                                                    'ไม่ได้เจรจา'
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor20
                                                                : FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    100.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    8.0,
                                                                    12.0,
                                                                    8.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .cancel_rounded,
                                                                color: _model
                                                                            .discussion ==
                                                                        'ไม่ได้เจรจา'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                size: 16.0,
                                                              ),
                                                            ),
                                                            Text(
                                                              'ไม่ได้เจรจา',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: _model.discussion ==
                                                                            'ไม่ได้เจรจา'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        !FlutterFlowTheme.of(context)
                                                                            .bodyMediumIsCustom,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  ).animateOnActionTrigger(
                                                      animationsMap[
                                                          'containerOnActionTriggerAnimation8']!,
                                                      hasBeenTriggered:
                                                          hasContainerTriggered8),
                                            ][index]();
                                          },
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
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent2,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .accent1
                                                      ],
                                                      stops: [0.0, 1.0],
                                                      begin:
                                                          AlignmentDirectional(
                                                              0.0, -1.0),
                                                      end: AlignmentDirectional(
                                                          0, 1.0),
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons
                                                          .mark_chat_read_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 8.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'การเจรจา',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 2,
                                              padding: EdgeInsets.fromLTRB(
                                                0,
                                                0,
                                                0,
                                                0,
                                              ),
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return [
                                                  () => InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.approach =
                                                              'เจรจาสำเร็จ';
                                                          safeSetState(() {});
                                                          if (animationsMap[
                                                                  'containerOnActionTriggerAnimation9'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasContainerTriggered9 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation9']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            minWidth: 150.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                _model.approach ==
                                                                        'เจรจาสำเร็จ'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor5
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                _model.approach ==
                                                                        'เจรจาสำเร็จ'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor6
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: _model.approach ==
                                                                            'เจรจาสำเร็จ'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'เจรจาสำเร็จ',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                          color: _model.approach == 'เจรจาสำเร็จ'
                                                                              ? FlutterFlowTheme.of(context).secondaryBackground
                                                                              : FlutterFlowTheme.of(context).secondaryText,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          useGoogleFonts:
                                                                              !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 8.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'containerOnActionTriggerAnimation9']!,
                                                          hasBeenTriggered:
                                                              hasContainerTriggered9),
                                                  () => InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.approach =
                                                              'เจรจาไม่สำเร็จ';
                                                          safeSetState(() {});
                                                          if (animationsMap[
                                                                  'containerOnActionTriggerAnimation10'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasContainerTriggered10 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'containerOnActionTriggerAnimation10']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                            minWidth: 150.0,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                _model.approach ==
                                                                        'เจรจาไม่สำเร็จ'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor19
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                _model.approach ==
                                                                        'เจรจาไม่สำเร็จ'
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor20
                                                                    : FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .cancel_rounded,
                                                                    color: _model.approach ==
                                                                            'เจรจาไม่สำเร็จ'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondaryBackground
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    size: 16.0,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'เจรจาไม่สำเร็จ',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.approach ==
                                                                                'เจรจาไม่สำเร็จ'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 8.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'containerOnActionTriggerAnimation10']!,
                                                          hasBeenTriggered:
                                                              hasContainerTriggered10),
                                                ][index]();
                                              },
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            if (_model.approach ==
                                                'เจรจาสำเร็จ') {
                                              return Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Builder(
                                                      builder: (context) =>
                                                          InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder:
                                                                (dialogContext) {
                                                              return Dialog(
                                                                elevation: 0,
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                alignment: AlignmentDirectional(
                                                                        0.0,
                                                                        0.0)
                                                                    .resolve(
                                                                        Directionality.of(
                                                                            context)),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    FocusScope.of(
                                                                            dialogContext)
                                                                        .unfocus();
                                                                    FocusManager
                                                                        .instance
                                                                        .primaryFocus
                                                                        ?.unfocus();
                                                                  },
                                                                  child:
                                                                      AlertDialogIDcardWidget(),
                                                                ),
                                                              );
                                                            },
                                                          );

                                                          await Future.delayed(
                                                            Duration(
                                                              milliseconds:
                                                                  3500,
                                                            ),
                                                          );
                                                          unawaited(
                                                            () async {
                                                              Navigator.pop(
                                                                  context);
                                                            }(),
                                                          );

                                                          context.pushNamed(
                                                              DonorssignatureWidget
                                                                  .routeName);
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor17,
                                                                Color(
                                                                    0xFFEC9828)
                                                              ],
                                                              stops: [0.0, 1.0],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      0.0,
                                                                      -1.0),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      0, 1.0),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24.0),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Opacity(
                                                                opacity: 0.2,
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          1.0,
                                                                          -1.0),
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            12.0,
                                                                            12.0,
                                                                            0.0),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/ChatGPT_Image_29_.._2568_13_29_22.png',
                                                                        width:
                                                                            60.0,
                                                                        height:
                                                                            60.0,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
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
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Icon(
                                                                          Icons
                                                                              .info_rounded,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          size:
                                                                              18.0,
                                                                        ),
                                                                        Align(
                                                                          alignment: AlignmentDirectional(
                                                                              -1.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            'ทำเอกสารการยินยอมก่อนบริจาคดวงตา',
                                                                            style: FlutterFlowTheme.of(context).bodyLarge.override(
                                                                                  fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  letterSpacing: 0.0,
                                                                                  useGoogleFonts: !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Color(
                                                                          0xCDFFFFFF),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        width:
                                                                            2.0,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0),
                                                                      child:
                                                                          BackdropFilter(
                                                                        filter:
                                                                            ImageFilter.blur(
                                                                          sigmaX:
                                                                              5.0,
                                                                          sigmaY:
                                                                              5.0,
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.all(valueOrDefault<double>(
                                                                            () {
                                                                              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                                                                                return 12.0;
                                                                              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                                                                                return 12.0;
                                                                              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                                                                                return 16.0;
                                                                              } else {
                                                                                return 16.0;
                                                                              }
                                                                            }(),
                                                                            0.0,
                                                                          )),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Align(
                                                                                alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                child: Text(
                                                                                  'อ่านบัตรประชาชน เพื่อเริ่มเซ็นเอกสาร',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                                        letterSpacing: 0.0,
                                                                                        useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                              wrapWithModel(
                                                                                model: _model.iconButtonTertiaryModel2,
                                                                                updateCallback: () => safeSetState(() {}),
                                                                                child: IconButtonTertiaryWidget(
                                                                                  iconbuttontertiary: Icon(
                                                                                    Icons.keyboard_arrow_right_rounded,
                                                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                                                    size: 14.0,
                                                                                  ),
                                                                                  color: Color(0xCCFFFFFF),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              );
                                            } else if (_model.approach ==
                                                'เจรจาไม่สำเร็จ') {
                                              return Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Divider(
                                                    height: 1.0,
                                                    thickness: 1.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
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
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 20.0,
                                                            height: 20.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor19,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor20
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        0, 1.0),
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .info_rounded,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                size: 10.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'สาเหตุที่เจรจาไม่สำเร็จ',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 8.0)),
                                                      ),
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isDismissible:
                                                                false,
                                                            useSafeArea: true,
                                                            context: context,
                                                            builder: (context) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .unfocus();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();
                                                                },
                                                                child: Padding(
                                                                  padding: MediaQuery
                                                                      .viewInsetsOf(
                                                                          context),
                                                                  child:
                                                                      ButtonsheetReasonsforunsuccessfuWidget(),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .dropdownModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: DropdownWidget(
                                                            textlabel:
                                                                'กรุณาเลือกสาเหตุ',
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                                ]
                                                    .divide(
                                                        SizedBox(height: 12.0))
                                                    .addToStart(
                                                        SizedBox(height: 12.0)),
                                              );
                                            } else {
                                              return Container(
                                                width: double.infinity,
                                                height: 0.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
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
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .accent2,
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .accent1
                                                          ],
                                                          stops: [0.0, 1.0],
                                                          begin:
                                                              AlignmentDirectional(
                                                                  0.0, -1.0),
                                                          end:
                                                              AlignmentDirectional(
                                                                  0, 1.0),
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        child: Icon(
                                                          Icons.remove_red_eye,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          size: 10.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'การจัดเก็บดวงตา',
                                                      style: FlutterFlowTheme
                                                              .of(context)
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
                                                  ].divide(
                                                      SizedBox(width: 8.0)),
                                                ),
                                                MasonryGridView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  gridDelegate:
                                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                  ),
                                                  crossAxisSpacing: 12.0,
                                                  mainAxisSpacing: 12.0,
                                                  itemCount: 2,
                                                  padding: EdgeInsets.fromLTRB(
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return [
                                                      () => InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              _model.eyepreservation =
                                                                  'จัดเก็บสำเร็จ';
                                                              safeSetState(
                                                                  () {});
                                                              if (animationsMap[
                                                                      'containerOnActionTriggerAnimation11'] !=
                                                                  null) {
                                                                safeSetState(() =>
                                                                    hasContainerTriggered11 =
                                                                        true);
                                                                SchedulerBinding
                                                                    .instance
                                                                    .addPostFrameCallback((_) async => animationsMap[
                                                                            'containerOnActionTriggerAnimation11']!
                                                                        .controller
                                                                        .forward(
                                                                            from:
                                                                                0.0));
                                                              }
                                                            },
                                                            child: Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                minWidth: 150.0,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    _model.eyepreservation ==
                                                                            'จัดเก็บสำเร็จ'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .customColor5
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryBackground,
                                                                    _model.eyepreservation ==
                                                                            'จัดเก็บสำเร็จ'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .customColor6
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryBackground
                                                                  ],
                                                                  stops: [
                                                                    0.0,
                                                                    1.0
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0,
                                                                          1.0),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100.0),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        color: _model.eyepreservation ==
                                                                                'จัดเก็บสำเร็จ'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        size:
                                                                            16.0,
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          Text(
                                                                        'จัดเก็บสำเร็จ',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                              color: _model.eyepreservation == 'จัดเก็บสำเร็จ' ? FlutterFlowTheme.of(context).secondaryBackground : FlutterFlowTheme.of(context).secondaryText,
                                                                              letterSpacing: 0.0,
                                                                              useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          8.0)),
                                                                ),
                                                              ),
                                                            ),
                                                          ).animateOnActionTrigger(
                                                              animationsMap[
                                                                  'containerOnActionTriggerAnimation11']!,
                                                              hasBeenTriggered:
                                                                  hasContainerTriggered11),
                                                      () => InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              _model.eyepreservation =
                                                                  'จัดเก็บไม่สำเร็จ';
                                                              safeSetState(
                                                                  () {});
                                                              if (animationsMap[
                                                                      'containerOnActionTriggerAnimation12'] !=
                                                                  null) {
                                                                safeSetState(() =>
                                                                    hasContainerTriggered12 =
                                                                        true);
                                                                SchedulerBinding
                                                                    .instance
                                                                    .addPostFrameCallback((_) async => animationsMap[
                                                                            'containerOnActionTriggerAnimation12']!
                                                                        .controller
                                                                        .forward(
                                                                            from:
                                                                                0.0));
                                                              }
                                                            },
                                                            child: Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                minWidth: 150.0,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    _model.eyepreservation ==
                                                                            'จัดเก็บไม่สำเร็จ'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .customColor19
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryBackground,
                                                                    _model.eyepreservation ==
                                                                            'จัดเก็บไม่สำเร็จ'
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .customColor20
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryBackground
                                                                  ],
                                                                  stops: [
                                                                    0.0,
                                                                    1.0
                                                                  ],
                                                                  begin:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          -1.0),
                                                                  end:
                                                                      AlignmentDirectional(
                                                                          0,
                                                                          1.0),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100.0),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .cancel_rounded,
                                                                        color: _model.eyepreservation ==
                                                                                'จัดเก็บไม่สำเร็จ'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        size:
                                                                            16.0,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'จัดเก็บไม่สำเร็จ',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                            color: _model.eyepreservation == 'จัดเก็บไม่สำเร็จ'
                                                                                ? FlutterFlowTheme.of(context).secondaryBackground
                                                                                : FlutterFlowTheme.of(context).secondaryText,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            useGoogleFonts:
                                                                                !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                          ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      width:
                                                                          8.0)),
                                                                ),
                                                              ),
                                                            ),
                                                          ).animateOnActionTrigger(
                                                              animationsMap[
                                                                  'containerOnActionTriggerAnimation12']!,
                                                              hasBeenTriggered:
                                                                  hasContainerTriggered12),
                                                    ][index]();
                                                  },
                                                ),
                                              ].divide(SizedBox(height: 8.0)),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            if (_model.eyepreservation ==
                                                'จัดเก็บสำเร็จ') {
                                              return Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Divider(
                                                    height: 1.0,
                                                    thickness: 1.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                  ),
                                                  MasonryGridView.builder(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    gridDelegate:
                                                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                    ),
                                                    crossAxisSpacing: 12.0,
                                                    mainAxisSpacing: 12.0,
                                                    itemCount: 2,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
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
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                          20.0,
                                                                      height:
                                                                          20.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        gradient:
                                                                            LinearGradient(
                                                                          colors: [
                                                                            FlutterFlowTheme.of(context).accent2,
                                                                            FlutterFlowTheme.of(context).accent1
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
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .calendar_month_rounded,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          size:
                                                                              10.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'วันที่จัดเก็บ',
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
                                                                      width:
                                                                          8.0)),
                                                                ),
                                                                wrapWithModel(
                                                                  model: _model
                                                                      .datePickerModel,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  child:
                                                                      DatePickerWidget(
                                                                    textlabel:
                                                                        'วันที่',
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  height: 8.0)),
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
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                          20.0,
                                                                      height:
                                                                          20.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        gradient:
                                                                            LinearGradient(
                                                                          colors: [
                                                                            FlutterFlowTheme.of(context).accent2,
                                                                            FlutterFlowTheme.of(context).accent1
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
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .access_time_filled_rounded,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          size:
                                                                              10.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      'เวลาจัดเก็บ',
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
                                                                      width:
                                                                          8.0)),
                                                                ),
                                                                wrapWithModel(
                                                                  model: _model
                                                                      .timePickerModel,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  child:
                                                                      TimePickerWidget(
                                                                    textlabel:
                                                                        'เวลา',
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  height: 8.0)),
                                                            ),
                                                      ][index]();
                                                    },
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
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 20.0,
                                                            height: 20.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor11,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor12
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        0, 1.0),
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .onetwothree,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                size: 12.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'จำนวน',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 8.0)),
                                                      ),
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isDismissible:
                                                                false,
                                                            useSafeArea: true,
                                                            context: context,
                                                            builder: (context) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .unfocus();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();
                                                                },
                                                                child: Padding(
                                                                  padding: MediaQuery
                                                                      .viewInsetsOf(
                                                                          context),
                                                                  child:
                                                                      ButtonsheetNumeyeWidget(),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .dropdownModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: DropdownWidget(
                                                            textlabel:
                                                                'กรุณาเลือกสาเหตุ',
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                                ]
                                                    .divide(
                                                        SizedBox(height: 12.0))
                                                    .addToStart(
                                                        SizedBox(height: 12.0)),
                                              );
                                            } else if (_model.eyepreservation ==
                                                'จัดเก็บไม่สำเร็จ') {
                                              return Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Divider(
                                                    height: 1.0,
                                                    thickness: 1.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
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
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 20.0,
                                                            height: 20.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor19,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor20
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.0,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        0, 1.0),
                                                              ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .info_rounded,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                size: 10.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'สาเหตุที่ไม่ได้จัดเก็บดวงตา',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width: 8.0)),
                                                      ),
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          showModalBottomSheet(
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            isDismissible:
                                                                false,
                                                            useSafeArea: true,
                                                            context: context,
                                                            builder: (context) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          context)
                                                                      .unfocus();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();
                                                                },
                                                                child: Padding(
                                                                  padding: MediaQuery
                                                                      .viewInsetsOf(
                                                                          context),
                                                                  child:
                                                                      ButtonsheetReasoneyewasnotpreservedWidget(),
                                                                ),
                                                              );
                                                            },
                                                          ).then((value) =>
                                                              safeSetState(
                                                                  () {}));
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .dropdownModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: DropdownWidget(
                                                            textlabel:
                                                                'กรุณาเลือกสาเหตุ',
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                                ]
                                                    .divide(
                                                        SizedBox(height: 12.0))
                                                    .addToStart(
                                                        SizedBox(height: 12.0)),
                                              );
                                            } else {
                                              return Container(
                                                width: double.infinity,
                                                height: 0.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
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
                                    child: MasonryGridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: () {
                                          if (MediaQuery.sizeOf(context).width <
                                              kBreakpointSmall) {
                                            return 1;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointMedium) {
                                            return 1;
                                          } else if (MediaQuery.sizeOf(context)
                                                  .width <
                                              kBreakpointLarge) {
                                            return 2;
                                          } else {
                                            return 2;
                                          }
                                        }(),
                                      ),
                                      crossAxisSpacing: 12.0,
                                      mainAxisSpacing: 12.0,
                                      itemCount: 2,
                                      padding: EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        0,
                                      ),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return [
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .customColor5,
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .customColor6
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .userMd,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: 10.0,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'ผู้เจรจา',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                  InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        isDismissible: false,
                                                        useSafeArea: true,
                                                        context: context,
                                                        builder: (context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              FocusScope.of(
                                                                      context)
                                                                  .unfocus();
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                            child: Padding(
                                                              padding: MediaQuery
                                                                  .viewInsetsOf(
                                                                      context),
                                                              child:
                                                                  ButtonsheetDoctorWidget(),
                                                            ),
                                                          );
                                                        },
                                                      ).then((value) =>
                                                          safeSetState(() {}));
                                                    },
                                                    child: wrapWithModel(
                                                      model:
                                                          _model.dropdownModel4,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child: DropdownWidget(),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                          () => Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .customColor5,
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .customColor6
                                                            ],
                                                            stops: [0.0, 1.0],
                                                            begin:
                                                                AlignmentDirectional(
                                                                    0.0, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    0, 1.0),
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: FaIcon(
                                                            FontAwesomeIcons
                                                                .userMd,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            size: 10.0,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'ผู้จัดเก็บ',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelSmallFamily,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelSmallIsCustom,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 8.0)),
                                                  ),
                                                  InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        isDismissible: false,
                                                        useSafeArea: true,
                                                        context: context,
                                                        builder: (context) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              FocusScope.of(
                                                                      context)
                                                                  .unfocus();
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                            child: Padding(
                                                              padding: MediaQuery
                                                                  .viewInsetsOf(
                                                                      context),
                                                              child:
                                                                  ButtonsheetDoctorWidget(),
                                                            ),
                                                          );
                                                        },
                                                      ).then((value) =>
                                                          safeSetState(() {}));
                                                    },
                                                    child: wrapWithModel(
                                                      model:
                                                          _model.dropdownModel5,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child: DropdownWidget(),
                                                    ),
                                                  ),
                                                ].divide(SizedBox(height: 8.0)),
                                              ),
                                        ][index]();
                                      },
                                    ),
                                  ),
                                ),
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
                              }())).addToStart(SizedBox(height: () {
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
                              }())).addToEnd(SizedBox(height: 24.0)),
                            ),
                          ),
                          if (!valueOrDefault<bool>(
                            isWeb
                                ? MediaQuery.viewInsetsOf(context).bottom > 0
                                : _isKeyboardVisible,
                            false,
                          ))
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 24.0),
                              child: wrapWithModel(
                                model: _model.bottonPrimaryModel,
                                updateCallback: () => safeSetState(() {}),
                                child: BottonPrimaryWidget(
                                  buttonprimary: 'บันทึก',
                                ),
                              ),
                            ),
                        ],
                      ),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
