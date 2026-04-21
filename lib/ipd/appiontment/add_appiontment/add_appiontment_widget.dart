import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_primary/icon_button_primary_widget.dart';
import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/buttonsheet_clinic/buttonsheet_clinic_widget.dart';
import '/ipd/appiontment/buttonsheet_conduct/buttonsheet_conduct_widget.dart';
import '/ipd/appiontment/buttonsheet_department/buttonsheet_department_widget.dart';
import '/ipd/appiontment/buttonsheet_reasonforappointment/buttonsheet_reasonforappointment_widget.dart';
import '/ipd/appiontment/fillter_date_appiontment/fillter_date_appiontment_widget.dart';
import '/ipd/appiontment/item_conduct/item_conduct_widget.dart';
import '/ipd/consult/buttonsheet_examinationroom/buttonsheet_examinationroom_widget.dart';
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
import 'add_appiontment_model.dart';
export 'add_appiontment_model.dart';

class AddAppiontmentWidget extends StatefulWidget {
  const AddAppiontmentWidget({super.key});

  static String routeName = 'Add_Appiontment';
  static String routePath = 'addAppiontment';

  @override
  State<AddAppiontmentWidget> createState() => _AddAppiontmentWidgetState();
}

class _AddAppiontmentWidgetState extends State<AddAppiontmentWidget>
    with TickerProviderStateMixin {
  late AddAppiontmentModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddAppiontmentModel());

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
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 40.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

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
                'นัดหมาย',
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
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 0.2,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_19_.._2568_10_31_26.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                        alignment: Alignment(1.0, -1.0),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['imageOnPageLoadAnimation']!),
                  ),
                ),
              ),
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
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await _model.listViewController?.animateTo(
                                _model.listViewController!.position
                                    .maxScrollExtent,
                                duration: Duration(milliseconds: 100),
                                curve: Curves.ease,
                              );
                            },
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
                                () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 100.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 100.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 120.0;
                                  } else {
                                    return 120.0;
                                  }
                                }(),
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
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                      'นัดวันที่',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .labelSmall
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmallFamily,
                                                            letterSpacing: 0.0,
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
                                                      isScrollControlled: true,
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
                                                                FillterDateAppiontmentWidget(),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: wrapWithModel(
                                                    model: _model
                                                        .iconButtonTertiaryModel,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child:
                                                        IconButtonTertiaryWidget(
                                                      iconbuttontertiary: Icon(
                                                        Icons.filter_alt,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        size: 12.0,
                                                      ),
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            wrapWithModel(
                                              model: _model.datePickerModel,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: DatePickerWidget(
                                                textlabel: 'วันที่',
                                              ),
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
                                              () => Column(
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
                                                                      .accent2,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent1
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
                                                                    .access_time_filled_rounded,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                size: 10.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'เวลา',
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
                                                      wrapWithModel(
                                                        model: _model
                                                            .timePickerModel1,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'ถึงเวลา',
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
                                                      wrapWithModel(
                                                        model: _model
                                                            .timePickerModel2,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child: TimePickerWidget(
                                                          textlabel: 'เวลา',
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                            ][index]();
                                          },
                                          controller:
                                              _model.staggeredViewController1,
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
                                                            .customColor5,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor6
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
                                                      FontAwesomeIcons.userMd,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'นัดพบแพทย์',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmallIsCustom,
                                                      ),
                                                ),
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            wrapWithModel(
                                              model: _model.dropdownModel1,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: DropdownWidget(),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
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
                                                            .customColor7,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor8
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
                                                          .solidHospital,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 8.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'แผนก',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmallIsCustom,
                                                      ),
                                                ),
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isDismissible: false,
                                                  useSafeArea: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child:
                                                            ButtonsheetDepartmentWidget(),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: wrapWithModel(
                                                model: _model.dropdownModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: DropdownWidget(),
                                              ),
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
                                              () => Column(
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
                                                                      .customColor9,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor10
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
                                                              child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .briefcaseMedical,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                size: 8.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'คลินิก',
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
                                                                      ButtonsheetClinicWidget(),
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
                                                          child:
                                                              DropdownWidget(),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                              () => Column(
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
                                                                      .accent2,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent1
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
                                                              child: FaIcon(
                                                                FontAwesomeIcons
                                                                    .stethoscope,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                size: 8.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            'ห้องตรวจ',
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
                                                                      ButtonsheetExaminationroomWidget(),
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
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              DropdownWidget(),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 8.0)),
                                                  ),
                                            ][index]();
                                          },
                                          controller:
                                              _model.staggeredViewController2,
                                        ),
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
                                                            .customColor13,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor14
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
                                                      Icons.note_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'เหตุที่นัด',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmallIsCustom,
                                                      ),
                                                ),
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isDismissible: false,
                                                  useSafeArea: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child:
                                                            ButtonsheetReasonforappointmentWidget(),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: wrapWithModel(
                                                model: _model.dropdownModel5,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: DropdownWidget(),
                                              ),
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
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 20.0,
                                              height: 20.0,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    FlutterFlowTheme.of(context)
                                                        .customColor17,
                                                    FlutterFlowTheme.of(context)
                                                        .customColor18
                                                  ],
                                                  stops: [0.0, 1.0],
                                                  begin: AlignmentDirectional(
                                                      0.0, -1.0),
                                                  end: AlignmentDirectional(
                                                      0, 1.0),
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: Icon(
                                                  Icons.info_rounded,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  size: 12.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'หมายเหตุ',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmallIsCustom,
                                                      ),
                                            ),
                                          ].divide(SizedBox(width: 8.0)),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          child: TextFormField(
                                            controller: _model.textController,
                                            focusNode:
                                                _model.textFieldFocusNode,
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumFamily,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w200,
                                                    useGoogleFonts:
                                                        !FlutterFlowTheme.of(
                                                                context)
                                                            .labelMediumIsCustom,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              filled: true,
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                            ),
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
                                            maxLines: null,
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            validator: _model
                                                .textControllerValidator
                                                .asValidator(context),
                                          ),
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
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor19,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor20
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
                                                      Icons.info_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'การปฎิบัติตัว',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelSmall
                                                      .override(
                                                        fontFamily:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmallFamily,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        useGoogleFonts:
                                                            !FlutterFlowTheme
                                                                    .of(context)
                                                                .labelSmallIsCustom,
                                                      ),
                                                ),
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isDismissible: false,
                                                  useSafeArea: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child:
                                                            ButtonsheetConductWidget(),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: wrapWithModel(
                                                model: _model
                                                    .iconButtonPrimaryModel,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: IconButtonPrimaryWidget(
                                                  iconbuttonprimary: Icon(
                                                    Icons.add_rounded,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    size: 20.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        wrapWithModel(
                                          model: _model.itemConductModel1,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemConductWidget(),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemConductModel2,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemConductWidget(),
                                        ),
                                        wrapWithModel(
                                          model: _model.itemConductModel3,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: ItemConductWidget(),
                                        ),
                                      ].divide(SizedBox(height: 8.0)),
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
                              }())),
                              controller: _model.listViewController,
                            ),
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
