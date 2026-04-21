import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pin_model.dart';
export 'pin_model.dart';

class PinWidget extends StatefulWidget {
  const PinWidget({super.key});

  static String routeName = 'PIN';
  static String routePath = 'pin';

  @override
  State<PinWidget> createState() => _PinWidgetState();
}

class _PinWidgetState extends State<PinWidget> with TickerProviderStateMixin {
  late PinModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasButtonTriggered1 = false;
  var hasButtonTriggered2 = false;
  var hasButtonTriggered3 = false;
  var hasButtonTriggered4 = false;
  var hasButtonTriggered5 = false;
  var hasButtonTriggered6 = false;
  var hasButtonTriggered7 = false;
  var hasButtonTriggered8 = false;
  var hasButtonTriggered9 = false;
  var hasButtonTriggered10 = false;
  var hasButtonTriggered11 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PinModel());

    _model.pinCodeFocusNode ??= FocusNode();

    animationsMap.addAll({
      'buttonOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation8': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation9': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation10': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.05, 1.05),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation11': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          TintEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            color: Color(0x653675D4),
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
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
        backgroundColor: FlutterFlowTheme.of(context).accent2,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).accent2,
            automaticallyImplyLeading: false,
            actions: [],
            centerTitle: false,
            elevation: 0.0,
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              alignment: AlignmentDirectional(0.0, -1.0),
              image: Image.asset(
                'assets/images/bgpin.png',
              ).image,
            ),
            gradient: LinearGradient(
              colors: [
                Color(0xCC3E83E6),
                FlutterFlowTheme.of(context).secondaryBackground
              ],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: Image.asset(
                            'assets/images/ChatGPT_Image_21_.._2568_14_10_36.png',
                            width: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 130.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 130.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 180.0;
                              } else {
                                return 180.0;
                              }
                            }(),
                            height: () {
                              if (MediaQuery.sizeOf(context).width <
                                  kBreakpointSmall) {
                                return 130.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointMedium) {
                                return 130.0;
                              } else if (MediaQuery.sizeOf(context).width <
                                  kBreakpointLarge) {
                                return 200.0;
                              } else {
                                return 200.0;
                              }
                            }(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ใส่รหัส PIN ',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .bodyLargeFamily,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  lineHeight: 1.7,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .bodyLargeIsCustom,
                                ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Container(
                              width: 350.0,
                              decoration: BoxDecoration(),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: PinCodeTextField(
                                  autoDisposeControllers: false,
                                  appContext: context,
                                  length: 6,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        color: Color(0x0057B99C),
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  enableActiveFill: true,
                                  autoFocus: false,
                                  focusNode: _model.pinCodeFocusNode,
                                  enablePinAutofill: false,
                                  errorTextSpace: 0.0,
                                  showCursor: false,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primary,
                                  obscureText: false,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  pinTheme: PinTheme(
                                    fieldHeight: 20.0,
                                    fieldWidth: 20.0,
                                    borderWidth: 0.1,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(100.0),
                                      bottomRight: Radius.circular(100.0),
                                      topLeft: Radius.circular(100.0),
                                      topRight: Radius.circular(100.0),
                                    ),
                                    shape: PinCodeFieldShape.circle,
                                    activeColor:
                                        FlutterFlowTheme.of(context).primary,
                                    inactiveColor: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    selectedColor: Color(0x003675D4),
                                    activeFillColor:
                                        FlutterFlowTheme.of(context).primary,
                                    inactiveFillColor:
                                        FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    selectedFillColor:
                                        FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                  ),
                                  controller: _model.pinCodeController,
                                  onChanged: (_) {},
                                  onCompleted: (_) async {
                                    context.pushNamed(
                                        SelectBranchWidget.routeName);
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: _model.pinCodeControllerValidator
                                      .asValidator(context),
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 24.0)),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 390.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 390.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 450.0;
                  } else {
                    return 450.0;
                  }
                }(),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FFButtonWidget(
                                onPressed: () async {
                                  if (animationsMap[
                                          'buttonOnActionTriggerAnimation1'] !=
                                      null) {
                                    safeSetState(
                                        () => hasButtonTriggered1 = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => animationsMap[
                                                'buttonOnActionTriggerAnimation1']!
                                            .controller
                                            .forward(from: 0.0)
                                            .whenComplete(animationsMap[
                                                    'buttonOnActionTriggerAnimation1']!
                                                .controller
                                                .reverse));
                                  }
                                  HapticFeedback.selectionClick();
                                  await actions.pinCodeString(
                                    '1',
                                  );
                                  safeSetState(() {
                                    _model.pinCodeController?.text =
                                        FFAppState().pinCode;
                                  });
                                },
                                text: '1',
                                options: FFButtonOptions(
                                  width: 64.0,
                                  height: 64.0,
                                  padding: EdgeInsets.all(0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleLargeFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                        lineHeight: 2.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleLargeIsCustom,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                showLoadingIndicator: false,
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'buttonOnActionTriggerAnimation1']!,
                                  hasBeenTriggered: hasButtonTriggered1),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation2'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered2 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation2']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation2']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '4',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '4',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsets.all(0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation2']!,
                                    hasBeenTriggered: hasButtonTriggered2),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation3'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered3 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation3']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation3']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '7',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '7',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsets.all(0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation3']!,
                                    hasBeenTriggered: hasButtonTriggered3),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () {
                                    print('Button pressed ...');
                                  },
                                  text: 'ลืม',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Color(0x001D8B6B),
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMediumFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .bodyMediumIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation4'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered4 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation4']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation4']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '2',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '2',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsets.all(0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation4']!,
                                    hasBeenTriggered: hasButtonTriggered4),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation5'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered5 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation5']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation5']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '5',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '5',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsets.all(0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation5']!,
                                    hasBeenTriggered: hasButtonTriggered5),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation6'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered6 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation6']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation6']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '8',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '8',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsets.all(0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation6']!,
                                    hasBeenTriggered: hasButtonTriggered6),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation7'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered7 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation7']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation7']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '0',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '0',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation7']!,
                                    hasBeenTriggered: hasButtonTriggered7),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation8'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered8 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation8']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation8']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '3',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '3',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsets.all(0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation8']!,
                                    hasBeenTriggered: hasButtonTriggered8),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation9'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered9 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation9']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation9']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '6',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '6',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsets.all(0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation9']!,
                                    hasBeenTriggered: hasButtonTriggered9),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation10'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered10 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation10']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation10']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.pinCodeString(
                                      '9',
                                    );
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '9',
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsets.all(0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleLargeFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          lineHeight: 2.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleLargeIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation10']!,
                                    hasBeenTriggered: hasButtonTriggered10),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    if (animationsMap[
                                            'buttonOnActionTriggerAnimation11'] !=
                                        null) {
                                      safeSetState(
                                          () => hasButtonTriggered11 = true);
                                      SchedulerBinding.instance.addPostFrameCallback(
                                          (_) async => animationsMap[
                                                  'buttonOnActionTriggerAnimation11']!
                                              .controller
                                              .forward(from: 0.0)
                                              .whenComplete(animationsMap[
                                                      'buttonOnActionTriggerAnimation11']!
                                                  .controller
                                                  .reverse));
                                    }
                                    HapticFeedback.selectionClick();
                                    await actions.removeLastPinCodeDigit();
                                    FFAppState().pinCode = FFAppState().pinCode;
                                    safeSetState(() {});
                                    safeSetState(() {
                                      _model.pinCodeController?.text =
                                          FFAppState().pinCode;
                                    });
                                  },
                                  text: '',
                                  icon: FaIcon(
                                    FontAwesomeIcons.backspace,
                                    size: 18.0,
                                  ),
                                  options: FFButtonOptions(
                                    width: 64.0,
                                    height: 64.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        6.0, 0.0, 0.0, 0.0),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmallFamily,
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          letterSpacing: 0.0,
                                          useGoogleFonts:
                                              !FlutterFlowTheme.of(context)
                                                  .titleSmallIsCustom,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(100.0),
                                    hoverColor:
                                        FlutterFlowTheme.of(context).primary,
                                    hoverTextColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  showLoadingIndicator: false,
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation11']!,
                                    hasBeenTriggered: hasButtonTriggered11),
                              ),
                            ],
                          ),
                        ].divide(SizedBox(width: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 40.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 40.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 60.0;
                          } else {
                            return 60.0;
                          }
                        }())),
                      ),
                    ),
                  ],
                ),
              ),
            ].divide(SizedBox(height: 16.0)),
          ),
        ),
      ),
    );
  }
}
