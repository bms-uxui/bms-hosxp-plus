import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/er/accident/buttonsheet_accident_location/buttonsheet_accident_location_widget.dart';
import '/er/accident/buttonsheet_accident_type/buttonsheet_accident_type_widget.dart';
import '/er/accident/buttonsheet_typesof_injury/buttonsheet_typesof_injury_widget.dart';
import '/er/accident/buttonsheet_typesof_vehicles/buttonsheet_typesof_vehicles_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'add_accident_model.dart';
export 'add_accident_model.dart';

class AddAccidentWidget extends StatefulWidget {
  const AddAccidentWidget({super.key});

  static String routeName = 'Add_Accident';
  static String routePath = 'addAccident';

  @override
  State<AddAccidentWidget> createState() => _AddAccidentWidgetState();
}

class _AddAccidentWidgetState extends State<AddAccidentWidget>
    with TickerProviderStateMixin {
  late AddAccidentModel _model;

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
    _model = createModel(context, () => AddAccidentModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    animationsMap.addAll({
      'textOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(-20.0, 0.0),
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
              leading: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 54.0,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20.0,
                ),
                onPressed: () async {
                  context.pop();
                },
              ),
              title: Text(
                'บันทึกข้อมูลบัติเหตุ',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation']!),
              actions: [],
              centerTitle: false,
              toolbarHeight: 64.0,
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
                child: Container(
                  width: double.infinity,
                  height: 100.0,
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
                                    return 16.0;
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
                                    return 16.0;
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
                              }(),
                              0,
                              16.0,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: [
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
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          safeSetState(() {
                                            _model.checkboxValue = true;
                                          });
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Theme(
                                              data: ThemeData(
                                                checkboxTheme:
                                                    CheckboxThemeData(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                  ),
                                                ),
                                                unselectedWidgetColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                              ),
                                              child: Checkbox(
                                                value: _model.checkboxValue ??=
                                                    false,
                                                onChanged: (newValue) async {
                                                  safeSetState(() =>
                                                      _model.checkboxValue =
                                                          newValue!);
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText!,
                                                      )
                                                    : null,
                                                activeColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                checkColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                            ),
                                            Text(
                                              'ไม่ที่ทราบข้อมูลทั้งหมด',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumFamily,
                                                    color:
                                                        valueOrDefault<Color>(
                                                      _model.checkboxValue ==
                                                              true
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText,
                                                    ),
                                                    letterSpacing: 0.0,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMediumIsCustom,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 4.0)),
                                        ),
                                      ),
                                      Divider(
                                        height: 1.0,
                                        thickness: 1.0,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                      ),
                                      MasonryGridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 1;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 1;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
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
                                        itemCount: 7,
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
                                                                    .accent2,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent1
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons
                                                                  .calendar_month_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'วันที่เกิดเหตุ',
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
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .datePickerModel,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child: DatePickerWidget(
                                                        textlabel: 'วันที่',
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                            () => Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .accent2,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent1
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons
                                                                  .access_time_filled_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'เวลาเกิดเหตุ',
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
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    wrapWithModel(
                                                      model: _model
                                                          .timePickerModel,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child: TimePickerWidget(
                                                        textlabel: 'เวลา',
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                            () => Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor11,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor12
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons
                                                                  .nature_people_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'สถานที่เกิดเหตุ',
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
                                                              Colors
                                                                  .transparent,
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
                                                                    ButtonsheetAccidentLocationWidget(),
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
                                                            safeSetState(() {}),
                                                        child: DropdownWidget(),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                            () => Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor11,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor12
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .crutch,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'ประเภทอุบัติเหตุ',
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
                                                              Colors
                                                                  .transparent,
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
                                                                    ButtonsheetAccidentTypeWidget(),
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
                                                            safeSetState(() {}),
                                                        child: DropdownWidget(),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                            () => Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor11,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor12
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .userInjured,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 8.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'ประเภทผู้บาดเจ็บ',
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
                                                              Colors
                                                                  .transparent,
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
                                                                    ButtonsheetTypesofInjuryWidget(),
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
                                                            safeSetState(() {}),
                                                        child: DropdownWidget(),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                            () => Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor11,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor12
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons
                                                                  .directions_car_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'ยานพาหนะ',
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
                                                              Colors
                                                                  .transparent,
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
                                                                    ButtonsheetTypesofVehiclesWidget(),
                                                              ),
                                                            );
                                                          },
                                                        ).then((value) =>
                                                            safeSetState(
                                                                () {}));
                                                      },
                                                      child: wrapWithModel(
                                                        model: _model
                                                            .dropdownModel4,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child: DropdownWidget(),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                            () => Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor11,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor12
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons.onetwothree,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 12.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'ทะเบียนรถ',
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
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, -0.05),
                                                      child: Container(
                                                        width: double.infinity,
                                                        child: TextFormField(
                                                          controller: _model
                                                              .textController,
                                                          focusNode: _model
                                                              .textFieldFocusNode,
                                                          autofocus: false,
                                                          obscureText: false,
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            hintStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelMediumFamily,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w200,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelMediumIsCustom,
                                                                    ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color(
                                                                    0x00000000),
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color(
                                                                    0x00000000),
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            errorBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            focusedErrorBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .error,
                                                                width: 1.0,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            filled: true,
                                                            fillColor: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                          ),
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMediumIsCustom,
                                                              ),
                                                          cursorColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          validator: _model
                                                              .textControllerValidator
                                                              .asValidator(
                                                                  context),
                                                        ),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                          ][index]();
                                        },
                                      ),
                                    ].divide(SizedBox(height: 12.0)),
                                  ),
                                ),
                              ),
                              MasonryGridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
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
                                crossAxisSpacing: () {
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
                                mainAxisSpacing: () {
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
                                    () => Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
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
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor15,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor16
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons.cable,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'เข็มขัดนิรภัย',
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
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Wrap(
                                                      spacing: 12.0,
                                                      runSpacing: 12.0,
                                                      alignment:
                                                          WrapAlignment.start,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .start,
                                                      direction:
                                                          Axis.horizontal,
                                                      runAlignment:
                                                          WrapAlignment.start,
                                                      verticalDirection:
                                                          VerticalDirection
                                                              .down,
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.seatBelt =
                                                                'คาด';
                                                            safeSetState(() {});
                                                            if (animationsMap[
                                                                    'containerOnActionTriggerAnimation1'] !=
                                                                null) {
                                                              safeSetState(() =>
                                                                  hasContainerTriggered1 =
                                                                      true);
                                                              SchedulerBinding
                                                                  .instance
                                                                  .addPostFrameCallback((_) async => animationsMap[
                                                                          'containerOnActionTriggerAnimation1']!
                                                                      .controller
                                                                      .forward(
                                                                          from:
                                                                              0.0));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  _model.seatBelt == 'คาด'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent2
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                  _model.seatBelt == 'คาด'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent1
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.56,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        -0.56,
                                                                        1.0),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Text(
                                                                  'คาด',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.seatBelt ==
                                                                                'คาด'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ).animateOnActionTrigger(
                                                            animationsMap[
                                                                'containerOnActionTriggerAnimation1']!,
                                                            hasBeenTriggered:
                                                                hasContainerTriggered1),
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.seatBelt =
                                                                'ไม่คาด';
                                                            safeSetState(() {});
                                                            if (animationsMap[
                                                                    'containerOnActionTriggerAnimation2'] !=
                                                                null) {
                                                              safeSetState(() =>
                                                                  hasContainerTriggered2 =
                                                                      true);
                                                              SchedulerBinding
                                                                  .instance
                                                                  .addPostFrameCallback((_) async => animationsMap[
                                                                          'containerOnActionTriggerAnimation2']!
                                                                      .controller
                                                                      .forward(
                                                                          from:
                                                                              0.0));
                                                            }
                                                          },
                                                          child: Container(
                                                            width: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  _model.seatBelt ==
                                                                          'ไม่คาด'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent2
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                  _model.seatBelt ==
                                                                          'ไม่คาด'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent1
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.56,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        -0.56,
                                                                        1.0),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Text(
                                                                  'ไม่คาด',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.seatBelt ==
                                                                                'ไม่คาด'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ).animateOnActionTrigger(
                                                            animationsMap[
                                                                'containerOnActionTriggerAnimation2']!,
                                                            hasBeenTriggered:
                                                                hasContainerTriggered2),
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.seatBelt =
                                                                'ไม่ทราบ';
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
                                                            width: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  _model.seatBelt ==
                                                                          'ไม่ทราบ'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent2
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                  _model.seatBelt ==
                                                                          'ไม่ทราบ'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent1
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.56,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        -0.56,
                                                                        1.0),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Text(
                                                                  'ไม่ทราบ',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.seatBelt ==
                                                                                'ไม่ทราบ'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ).animateOnActionTrigger(
                                                            animationsMap[
                                                                'containerOnActionTriggerAnimation3']!,
                                                            hasBeenTriggered:
                                                                hasContainerTriggered3),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                    () => Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
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
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor15,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor16
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Icon(
                                                              Icons
                                                                  .sports_motorsports,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 12.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'หมวกนิรภัย',
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
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Wrap(
                                                      spacing: 12.0,
                                                      runSpacing: 12.0,
                                                      alignment:
                                                          WrapAlignment.start,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .start,
                                                      direction:
                                                          Axis.horizontal,
                                                      runAlignment:
                                                          WrapAlignment.start,
                                                      verticalDirection:
                                                          VerticalDirection
                                                              .down,
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.helmet =
                                                                'สวม';
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
                                                            width: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  _model.helmet == 'สวม'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent2
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                  _model.helmet == 'สวม'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent1
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.56,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        -0.56,
                                                                        1.0),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Text(
                                                                  'สวม',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.helmet ==
                                                                                'สวม'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ).animateOnActionTrigger(
                                                            animationsMap[
                                                                'containerOnActionTriggerAnimation4']!,
                                                            hasBeenTriggered:
                                                                hasContainerTriggered4),
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.helmet =
                                                                'ไม่สวม';
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
                                                            width: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  _model.helmet ==
                                                                          'ไม่สวม'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent2
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                  _model.helmet ==
                                                                          'ไม่สวม'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent1
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.56,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        -0.56,
                                                                        1.0),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Text(
                                                                  'ไม่สวม',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.helmet ==
                                                                                'ไม่สวม'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ).animateOnActionTrigger(
                                                            animationsMap[
                                                                'containerOnActionTriggerAnimation5']!,
                                                            hasBeenTriggered:
                                                                hasContainerTriggered5),
                                                        InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            _model.helmet =
                                                                'ไม่ทราบ';
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
                                                            width: 100.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  _model.helmet ==
                                                                          'ไม่ทราบ'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent2
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                  _model.helmet ==
                                                                          'ไม่ทราบ'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .accent1
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground
                                                                ],
                                                                stops: [
                                                                  0.0,
                                                                  1.0
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        0.56,
                                                                        -1.0),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        -0.56,
                                                                        1.0),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100.0),
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                                child: Text(
                                                                  'ไม่ทราบ',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            FlutterFlowTheme.of(context).bodyMediumFamily,
                                                                        color: _model.helmet ==
                                                                                'ไม่ทราบ'
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).secondaryText,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ).animateOnActionTrigger(
                                                            animationsMap[
                                                                'containerOnActionTriggerAnimation6']!,
                                                            hasBeenTriggered:
                                                                hasContainerTriggered6),
                                                      ],
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                    () => Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
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
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor15,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor16
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .wineBottle,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'แอลกอฮอล์',
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
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                                Wrap(
                                                  spacing: 12.0,
                                                  runSpacing: 12.0,
                                                  alignment:
                                                      WrapAlignment.start,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.start,
                                                  direction: Axis.horizontal,
                                                  runAlignment:
                                                      WrapAlignment.start,
                                                  verticalDirection:
                                                      VerticalDirection.down,
                                                  clipBehavior: Clip.none,
                                                  children: [
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
                                                        _model.alcohol = 'ดื่ม';
                                                        safeSetState(() {});
                                                        if (animationsMap[
                                                                'containerOnActionTriggerAnimation7'] !=
                                                            null) {
                                                          safeSetState(() =>
                                                              hasContainerTriggered7 =
                                                                  true);
                                                          SchedulerBinding
                                                              .instance
                                                              .addPostFrameCallback((_) async =>
                                                                  animationsMap[
                                                                          'containerOnActionTriggerAnimation7']!
                                                                      .controller
                                                                      .forward(
                                                                          from:
                                                                              0.0));
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              _model.alcohol ==
                                                                      'ดื่ม'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent2
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                              _model.alcohol ==
                                                                      'ดื่ม'
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
                                                                    0.56, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    -0.56, 1.0),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Text(
                                                              'ดื่ม',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: _model.alcohol ==
                                                                            'ดื่ม'
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
                                                        ),
                                                      ),
                                                    ).animateOnActionTrigger(
                                                        animationsMap[
                                                            'containerOnActionTriggerAnimation7']!,
                                                        hasBeenTriggered:
                                                            hasContainerTriggered7),
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
                                                        _model.alcohol =
                                                            'ไม่ดื่ม';
                                                        safeSetState(() {});
                                                        if (animationsMap[
                                                                'containerOnActionTriggerAnimation8'] !=
                                                            null) {
                                                          safeSetState(() =>
                                                              hasContainerTriggered8 =
                                                                  true);
                                                          SchedulerBinding
                                                              .instance
                                                              .addPostFrameCallback((_) async =>
                                                                  animationsMap[
                                                                          'containerOnActionTriggerAnimation8']!
                                                                      .controller
                                                                      .forward(
                                                                          from:
                                                                              0.0));
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              _model.alcohol ==
                                                                      'ไม่ดื่ม'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent2
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                              _model.alcohol ==
                                                                      'ไม่ดื่ม'
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
                                                                    0.56, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    -0.56, 1.0),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Text(
                                                              'ไม่ดื่ม',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: _model.alcohol ==
                                                                            'ไม่ดื่ม'
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
                                                        ),
                                                      ),
                                                    ).animateOnActionTrigger(
                                                        animationsMap[
                                                            'containerOnActionTriggerAnimation8']!,
                                                        hasBeenTriggered:
                                                            hasContainerTriggered8),
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
                                                        _model.alcohol =
                                                            'ไม่ทราบ';
                                                        safeSetState(() {});
                                                        if (animationsMap[
                                                                'containerOnActionTriggerAnimation9'] !=
                                                            null) {
                                                          safeSetState(() =>
                                                              hasContainerTriggered9 =
                                                                  true);
                                                          SchedulerBinding
                                                              .instance
                                                              .addPostFrameCallback((_) async =>
                                                                  animationsMap[
                                                                          'containerOnActionTriggerAnimation9']!
                                                                      .controller
                                                                      .forward(
                                                                          from:
                                                                              0.0));
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              _model.alcohol ==
                                                                      'ไม่ทราบ'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent2
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                              _model.alcohol ==
                                                                      'ไม่ทราบ'
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
                                                                    0.56, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    -0.56, 1.0),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Text(
                                                              'ไม่ทราบ',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: _model.alcohol ==
                                                                            'ไม่ทราบ'
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
                                                        ),
                                                      ),
                                                    ).animateOnActionTrigger(
                                                        animationsMap[
                                                            'containerOnActionTriggerAnimation9']!,
                                                        hasBeenTriggered:
                                                            hasContainerTriggered9),
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                    () => Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
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
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                                    .customColor15,
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor16
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
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .cannabis,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              size: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'สารเสพติด',
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
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                                Wrap(
                                                  spacing: 12.0,
                                                  runSpacing: 12.0,
                                                  alignment:
                                                      WrapAlignment.start,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.start,
                                                  direction: Axis.horizontal,
                                                  runAlignment:
                                                      WrapAlignment.start,
                                                  verticalDirection:
                                                      VerticalDirection.down,
                                                  clipBehavior: Clip.none,
                                                  children: [
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
                                                        _model.drugs = 'ใช้';
                                                        safeSetState(() {});
                                                        if (animationsMap[
                                                                'containerOnActionTriggerAnimation10'] !=
                                                            null) {
                                                          safeSetState(() =>
                                                              hasContainerTriggered10 =
                                                                  true);
                                                          SchedulerBinding
                                                              .instance
                                                              .addPostFrameCallback((_) async =>
                                                                  animationsMap[
                                                                          'containerOnActionTriggerAnimation10']!
                                                                      .controller
                                                                      .forward(
                                                                          from:
                                                                              0.0));
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              _model.drugs ==
                                                                      'ใช้'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent2
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                              _model.drugs ==
                                                                      'ใช้'
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
                                                                    0.56, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    -0.56, 1.0),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Text(
                                                              'ใช้',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: _model.drugs ==
                                                                            'ใช้'
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
                                                        ),
                                                      ),
                                                    ).animateOnActionTrigger(
                                                        animationsMap[
                                                            'containerOnActionTriggerAnimation10']!,
                                                        hasBeenTriggered:
                                                            hasContainerTriggered10),
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
                                                        _model.drugs = 'ไม่ใช้';
                                                        safeSetState(() {});
                                                        if (animationsMap[
                                                                'containerOnActionTriggerAnimation11'] !=
                                                            null) {
                                                          safeSetState(() =>
                                                              hasContainerTriggered11 =
                                                                  true);
                                                          SchedulerBinding
                                                              .instance
                                                              .addPostFrameCallback((_) async =>
                                                                  animationsMap[
                                                                          'containerOnActionTriggerAnimation11']!
                                                                      .controller
                                                                      .forward(
                                                                          from:
                                                                              0.0));
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              _model.drugs ==
                                                                      'ไม่ใช้'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent2
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                              _model.drugs ==
                                                                      'ไม่ใช้'
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
                                                                    0.56, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    -0.56, 1.0),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Text(
                                                              'ไม่ใช้',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: _model.drugs ==
                                                                            'ไม่ใช้'
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
                                                        ),
                                                      ),
                                                    ).animateOnActionTrigger(
                                                        animationsMap[
                                                            'containerOnActionTriggerAnimation11']!,
                                                        hasBeenTriggered:
                                                            hasContainerTriggered11),
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
                                                        _model.drugs =
                                                            'ไม่ทราบ';
                                                        safeSetState(() {});
                                                        if (animationsMap[
                                                                'containerOnActionTriggerAnimation12'] !=
                                                            null) {
                                                          safeSetState(() =>
                                                              hasContainerTriggered12 =
                                                                  true);
                                                          SchedulerBinding
                                                              .instance
                                                              .addPostFrameCallback((_) async =>
                                                                  animationsMap[
                                                                          'containerOnActionTriggerAnimation12']!
                                                                      .controller
                                                                      .forward(
                                                                          from:
                                                                              0.0));
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              _model.drugs ==
                                                                      'ไม่ทราบ'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent2
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                              _model.drugs ==
                                                                      'ไม่ทราบ'
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
                                                                    0.56, -1.0),
                                                            end:
                                                                AlignmentDirectional(
                                                                    -0.56, 1.0),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        8.0,
                                                                        12.0,
                                                                        8.0),
                                                            child: Text(
                                                              'ไม่ทราบ',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMediumFamily,
                                                                    color: _model.drugs ==
                                                                            'ไม่ทราบ'
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
                                                        ),
                                                      ),
                                                    ).animateOnActionTrigger(
                                                        animationsMap[
                                                            'containerOnActionTriggerAnimation12']!,
                                                        hasBeenTriggered:
                                                            hasContainerTriggered12),
                                                  ],
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                  ][index]();
                                },
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
                            }())),
                          ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
