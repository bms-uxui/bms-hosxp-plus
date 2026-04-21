import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'donorssignature_model.dart';
export 'donorssignature_model.dart';

class DonorssignatureWidget extends StatefulWidget {
  const DonorssignatureWidget({super.key});

  static String routeName = 'Donorssignature';
  static String routePath = 'donorssignature';

  @override
  State<DonorssignatureWidget> createState() => _DonorssignatureWidgetState();
}

class _DonorssignatureWidgetState extends State<DonorssignatureWidget>
    with TickerProviderStateMixin {
  late DonorssignatureModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;
  var hasIconTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DonorssignatureModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.textController ??= TextEditingController(text: 'นายทดลอง ทดสอบ');
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
      'iconOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          RotateEffect(
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
                'ลายเซ็นผู้บริจาค',
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
                      borderRadius: BorderRadius.circular(0.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_29_.._2568_15_17_23.png',
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
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: () {
                                        if (MediaQuery.sizeOf(context).width <
                                            kBreakpointSmall) {
                                          return 450.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointMedium) {
                                          return 450.0;
                                        } else if (MediaQuery.sizeOf(context)
                                                .width <
                                            kBreakpointLarge) {
                                          return 650.0;
                                        } else {
                                          return 650.0;
                                        }
                                      }(),
                                      decoration: BoxDecoration(
                                        color: Color(0x41F1F4F8),
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Opacity(
                                            opacity: 0.05,
                                            child: Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.asset(
                                                  'assets/images/ChatGPT_Image_29_.._2568_15_17_23.png',
                                                  width: 200.0,
                                                  height: 200.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Builder(
                                            builder: (context) {
                                              if (_model.signature == true) {
                                                return ClipRect(
                                                  child: Signature(
                                                    controller: _model
                                                            .signatureController ??=
                                                        SignatureController(
                                                      penStrokeWidth: 2.0,
                                                      penColor:
                                                          Color(0xFF14181B),
                                                      exportBackgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                    backgroundColor:
                                                        Color(0x00FFFFFF),
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                );
                                              } else {
                                                return InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    _model.signature = true;
                                                    safeSetState(() {});
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24.0),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0.0, 0.0),
                                                      child: Text(
                                                        'เริ่มเซ็นลายเซ็น',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .override(
                                                                  fontFamily: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLargeFamily,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyLargeIsCustom,
                                                                ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(1.0, -1.0),
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
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  if (_model.signature!) {
                                                    _model.signature = false;
                                                    safeSetState(() {});
                                                    if (animationsMap[
                                                            'iconOnActionTriggerAnimation'] !=
                                                        null) {
                                                      safeSetState(() =>
                                                          hasIconTriggered =
                                                              true);
                                                      SchedulerBinding.instance
                                                          .addPostFrameCallback((_) async =>
                                                              await animationsMap[
                                                                      'iconOnActionTriggerAnimation']!
                                                                  .controller
                                                                  .forward(
                                                                      from:
                                                                          0.0));
                                                    }
                                                    safeSetState(() {
                                                      _model.signatureController
                                                          ?.clear();
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  width: () {
                                                    if (MediaQuery.sizeOf(
                                                                context)
                                                            .width <
                                                        kBreakpointSmall) {
                                                      return 32.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 32.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
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
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointMedium) {
                                                      return 32.0;
                                                    } else if (MediaQuery
                                                                .sizeOf(context)
                                                            .width <
                                                        kBreakpointLarge) {
                                                      return 40.0;
                                                    } else {
                                                      return 40.0;
                                                    }
                                                  }(),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        valueOrDefault<Color>(
                                                      _model.signature == true
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primaryBackground,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.restart_alt_rounded,
                                                      color:
                                                          valueOrDefault<Color>(
                                                        _model.signature == true
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground
                                                            : FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText,
                                                      ),
                                                      size: 18.0,
                                                    ).animateOnActionTrigger(
                                                        animationsMap[
                                                            'iconOnActionTriggerAnimation']!,
                                                        hasBeenTriggered:
                                                            hasIconTriggered),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                      child: MasonryGridView.builder(
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
                                        itemCount: 1,
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
                                                        Text(
                                                          'ชื่อผู้เซ็น',
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
                                                        ),
                                                      ].divide(
                                                          SizedBox(width: 8.0)),
                                                    ),
                                                    Container(
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
                                                          hintText:
                                                              'รายละเอียด...',
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
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
                                                                  useGoogleFonts:
                                                                      !FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMediumIsCustom,
                                                                ),
                                                        maxLines: null,
                                                        minLines: 1,
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
                                                  ].divide(
                                                      SizedBox(height: 8.0)),
                                                ),
                                          ][index]();
                                        },
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                            ].addToStart(SizedBox(height: () {
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
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.safePop();
                            },
                            child: wrapWithModel(
                              model: _model.bottonPrimaryModel,
                              updateCallback: () => safeSetState(() {}),
                              child: BottonPrimaryWidget(
                                buttonprimary: 'บันทึก',
                              ),
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
