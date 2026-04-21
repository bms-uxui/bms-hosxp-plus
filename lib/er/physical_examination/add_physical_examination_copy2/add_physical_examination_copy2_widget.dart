import '/dsign_system/button_styles/botton_primary/botton_primary_widget.dart';
import '/dsign_system/button_styles/button_a_igenerate/button_a_igenerate_widget.dart';
import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/dsign_system/from_field/time_picker/time_picker_widget.dart';
import '/er/physical_examination/abdomen/abdomen_widget.dart';
import '/er/physical_examination/buttonsheet_emergency_indications/buttonsheet_emergency_indications_widget.dart';
import '/er/physical_examination/buttonsheet_overall_patient_status/buttonsheet_overall_patient_status_widget.dart';
import '/er/physical_examination/chest/chest_widget.dart';
import '/er/physical_examination/constitutional/constitutional_widget.dart';
import '/er/physical_examination/e_n_t_mounth/e_n_t_mounth_widget.dart';
import '/er/physical_examination/extremities/extremities_widget.dart';
import '/er/physical_examination/eyes/eyes_widget.dart';
import '/er/physical_examination/ga/ga_widget.dart';
import '/er/physical_examination/genitalia/genitalia_widget.dart';
import '/er/physical_examination/heart/heart_widget.dart';
import '/er/physical_examination/heent/heent_widget.dart';
import '/er/physical_examination/neurological/neurological_widget.dart';
import '/er/physical_examination/pr/pr_widget.dart';
import '/er/physical_examination/pv/pv_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_autocomplete_options_list.dart';
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
import 'add_physical_examination_copy2_model.dart';
export 'add_physical_examination_copy2_model.dart';

class AddPhysicalExaminationCopy2Widget extends StatefulWidget {
  const AddPhysicalExaminationCopy2Widget({super.key});

  static String routeName = 'Add_PhysicalExaminationCopy2';
  static String routePath = 'addPhysicalExaminationCopy2';

  @override
  State<AddPhysicalExaminationCopy2Widget> createState() =>
      _AddPhysicalExaminationCopy2WidgetState();
}

class _AddPhysicalExaminationCopy2WidgetState
    extends State<AddPhysicalExaminationCopy2Widget>
    with TickerProviderStateMixin {
  late AddPhysicalExaminationCopy2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;
  var hasGaTriggered1 = false;
  var hasGaTriggered2 = false;
  var hasGaTriggered3 = false;
  var hasHeentTriggered1 = false;
  var hasHeentTriggered2 = false;
  var hasHeentTriggered3 = false;
  var hasHeartTriggered1 = false;
  var hasHeartTriggered2 = false;
  var hasHeartTriggered3 = false;
  var hasChestTriggered2 = false;
  var hasChestTriggered3 = false;
  var hasAbdomenTriggered1 = false;
  var hasAbdomenTriggered2 = false;
  var hasAbdomenTriggered3 = false;
  var hasPrTriggered1 = false;
  var hasPrTriggered2 = false;
  var hasPrTriggered3 = false;
  var hasPvTriggered1 = false;
  var hasPvTriggered2 = false;
  var hasPvTriggered3 = false;
  var hasGenitaliaTriggered1 = false;
  var hasGenitaliaTriggered2 = false;
  var hasGenitaliaTriggered3 = false;
  var hasNeurologicalTriggered1 = false;
  var hasNeurologicalTriggered2 = false;
  var hasNeurologicalTriggered3 = false;
  var hasExtremitiesTriggered1 = false;
  var hasExtremitiesTriggered2 = false;
  var hasExtremitiesTriggered3 = false;
  var hasConstitutionalTriggered1 = false;
  var hasConstitutionalTriggered2 = false;
  var hasEyesTriggered1 = false;
  var hasEyesTriggered2 = false;
  var hasENTMounthTriggered1 = false;
  var hasENTMounthTriggered2 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddPhysicalExaminationCopy2Model());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.textController1 ??= TextEditingController();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

    _model.textController6 ??= TextEditingController();
    _model.textFieldFocusNode6 ??= FocusNode();

    _model.textController7 ??= TextEditingController();
    _model.textFieldFocusNode7 ??= FocusNode();

    _model.textController8 ??= TextEditingController();
    _model.textFieldFocusNode8 ??= FocusNode();

    _model.textController9 ??= TextEditingController();
    _model.textFieldFocusNode9 ??= FocusNode();

    _model.textController10 ??= TextEditingController();
    _model.textFieldFocusNode10 ??= FocusNode();

    _model.textController11 ??= TextEditingController();
    _model.textFieldFocusNode11 ??= FocusNode();

    _model.textController12 ??= TextEditingController();
    _model.textFieldFocusNode12 ??= FocusNode();

    _model.textController13 ??= TextEditingController();
    _model.textFieldFocusNode13 ??= FocusNode();

    _model.textController14 ??= TextEditingController();
    _model.textFieldFocusNode14 ??= FocusNode();

    _model.textController15 ??= TextEditingController();
    _model.textFieldFocusNode15 ??= FocusNode();

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
      'buttonAIgenerateOnPageLoadAnimation': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 850.0.ms,
            duration: 1210.0.ms,
            color: Color(0x80FFFFFF),
            angle: 0.524,
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
      'gaOnActionTriggerAnimation1': AnimationInfo(
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
      'gaOnActionTriggerAnimation2': AnimationInfo(
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
      'gaOnActionTriggerAnimation3': AnimationInfo(
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
      'heentOnActionTriggerAnimation1': AnimationInfo(
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
      'heentOnActionTriggerAnimation2': AnimationInfo(
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
      'heentOnActionTriggerAnimation3': AnimationInfo(
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
      'heartOnActionTriggerAnimation1': AnimationInfo(
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
      'heartOnActionTriggerAnimation2': AnimationInfo(
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
      'heartOnActionTriggerAnimation3': AnimationInfo(
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
      'chestOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
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
      'chestOnActionTriggerAnimation2': AnimationInfo(
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
      'chestOnActionTriggerAnimation3': AnimationInfo(
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
      'abdomenOnActionTriggerAnimation1': AnimationInfo(
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
      'abdomenOnActionTriggerAnimation2': AnimationInfo(
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
      'abdomenOnActionTriggerAnimation3': AnimationInfo(
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
      'prOnActionTriggerAnimation1': AnimationInfo(
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
      'prOnActionTriggerAnimation2': AnimationInfo(
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
      'prOnActionTriggerAnimation3': AnimationInfo(
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
      'pvOnActionTriggerAnimation1': AnimationInfo(
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
      'pvOnActionTriggerAnimation2': AnimationInfo(
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
      'pvOnActionTriggerAnimation3': AnimationInfo(
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
      'genitaliaOnActionTriggerAnimation1': AnimationInfo(
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
      'genitaliaOnActionTriggerAnimation2': AnimationInfo(
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
      'genitaliaOnActionTriggerAnimation3': AnimationInfo(
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
      'neurologicalOnActionTriggerAnimation1': AnimationInfo(
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
      'neurologicalOnActionTriggerAnimation2': AnimationInfo(
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
      'neurologicalOnActionTriggerAnimation3': AnimationInfo(
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
      'extremitiesOnActionTriggerAnimation1': AnimationInfo(
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
      'extremitiesOnActionTriggerAnimation2': AnimationInfo(
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
      'extremitiesOnActionTriggerAnimation3': AnimationInfo(
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
      'constitutionalOnActionTriggerAnimation1': AnimationInfo(
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
      'constitutionalOnActionTriggerAnimation2': AnimationInfo(
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
      'eyesOnActionTriggerAnimation1': AnimationInfo(
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
      'eyesOnActionTriggerAnimation2': AnimationInfo(
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
      'eNTMounthOnActionTriggerAnimation1': AnimationInfo(
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
      'eNTMounthOnActionTriggerAnimation2': AnimationInfo(
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
    context.watch<FFAppState>();

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
                'ตรวจร่างกาย',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).titleMediumFamily,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).titleMediumIsCustom,
                    ),
              ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation']!),
              actions: [
                Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                    child: wrapWithModel(
                      model: _model.buttonAIgenerateModel,
                      updateCallback: () => safeSetState(() {}),
                      child: ButtonAIgenerateWidget(
                        aiGenerate: 'บันทึกข้อมูลด้วย AI',
                        icon: Icon(
                          Icons.mic_rounded,
                          color: FlutterFlowTheme.of(context).customColor8,
                          size: () {
                            if (MediaQuery.sizeOf(context).width <
                                kBreakpointSmall) {
                              return 16.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointMedium) {
                              return 16.0;
                            } else if (MediaQuery.sizeOf(context).width <
                                kBreakpointLarge) {
                              return 18.0;
                            } else {
                              return 18.0;
                            }
                          }(),
                        ),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['buttonAIgenerateOnPageLoadAnimation']!),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                  opacity: 0.2,
                  child: Align(
                    alignment: AlignmentDirectional(1.0, 1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Image.asset(
                        'assets/images/ChatGPT_Image_18_.._2568_16_02_16.png',
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
                  child: Builder(
                    builder: (context) {
                      if (_model.pageview == 1) {
                        return Column(
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
                                        return 16.0;
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
                                        return 16.0;
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
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
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
                                child: ListView(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 16.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 16.0;
                                      } else {
                                        return 16.0;
                                      }
                                    }(),
                                    0,
                                    24.0,
                                  ),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/ChatGPT_Image_15_.._2568_13_39_54.png',
                                          width: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 84.0;
                                            } else {
                                              return 84.0;
                                            }
                                          }(),
                                          height: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 84.0;
                                            } else {
                                              return 84.0;
                                            }
                                          }(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        'ข้อมูลการซักประวัติและการตรวจรักษา',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                      ),
                                    ),
                                    Container(
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
                                          children: [
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
                                                  () => MasonryGridView.builder(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        gridDelegate:
                                                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: () {
                                                            if (MediaQuery.sizeOf(
                                                                        context)
                                                                    .width <
                                                                kBreakpointSmall) {
                                                              return 2;
                                                            } else if (MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width <
                                                                kBreakpointMedium) {
                                                              return 2;
                                                            } else if (MediaQuery
                                                                        .sizeOf(
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
                                                                      children:
                                                                          [
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
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.calendar_month_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 10.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'วันที่เริ่มตรวจ',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.normal,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                    wrapWithModel(
                                                                      model: _model
                                                                          .datePickerModel1,
                                                                      updateCallback:
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                      child:
                                                                          DatePickerWidget(
                                                                        textlabel:
                                                                            'วันที่',
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      height:
                                                                          8.0)),
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
                                                                      children:
                                                                          [
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
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.access_time_filled_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 10.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'เวลาเริ่มตรวจ',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.normal,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                    wrapWithModel(
                                                                      model: _model
                                                                          .timePickerModel1,
                                                                      updateCallback:
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                      child:
                                                                          TimePickerWidget(
                                                                        textlabel:
                                                                            'เวลา',
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      height:
                                                                          8.0)),
                                                                ),
                                                          ][index]();
                                                        },
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
                                                                MainAxisSize
                                                                    .min,
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
                                                                    end: AlignmentDirectional(
                                                                        0, 1.0),
                                                                  ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .emergency_rounded,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    size: 10.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'ข้อบ่งชี้กรณีฉุกเฉิน',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelSmallFamily,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelSmallIsCustom,
                                                                    ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 8.0)),
                                                          ),
                                                          InkWell(
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
                                                              showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                isDismissible:
                                                                    false,
                                                                useSafeArea:
                                                                    true,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
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
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
                                                                      child:
                                                                          ButtonsheetEmergencyIndicationsWidget(),
                                                                    ),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .dropdownModel1,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  DropdownWidget(),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 8.0)),
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
                                                                MainAxisSize
                                                                    .min,
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
                                                                    end: AlignmentDirectional(
                                                                        0, 1.0),
                                                                  ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                          0.0,
                                                                          0.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .personal_injury,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    size: 10.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                'สภาพผู้ป่วยออกจาหห้อง ER',
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          FlutterFlowTheme.of(context)
                                                                              .labelSmallFamily,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      useGoogleFonts:
                                                                          !FlutterFlowTheme.of(context)
                                                                              .labelSmallIsCustom,
                                                                    ),
                                                              ),
                                                            ].divide(SizedBox(
                                                                width: 8.0)),
                                                          ),
                                                          InkWell(
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
                                                              showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                isDismissible:
                                                                    false,
                                                                useSafeArea:
                                                                    true,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
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
                                                                    child:
                                                                        Padding(
                                                                      padding: MediaQuery
                                                                          .viewInsetsOf(
                                                                              context),
                                                                      child:
                                                                          ButtonsheetOverallPatientStatusWidget(),
                                                                    ),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .dropdownModel2,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  DropdownWidget(),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 8.0)),
                                                      ),
                                                  () => MasonryGridView.builder(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        gridDelegate:
                                                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: () {
                                                            if (MediaQuery.sizeOf(
                                                                        context)
                                                                    .width <
                                                                kBreakpointSmall) {
                                                              return 2;
                                                            } else if (MediaQuery
                                                                        .sizeOf(
                                                                            context)
                                                                    .width <
                                                                kBreakpointMedium) {
                                                              return 2;
                                                            } else if (MediaQuery
                                                                        .sizeOf(
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
                                                                      children:
                                                                          [
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
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.calendar_month_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 10.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'วันที่ตรวจเสร็จ',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.normal,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                    wrapWithModel(
                                                                      model: _model
                                                                          .datePickerModel2,
                                                                      updateCallback:
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                      child:
                                                                          DatePickerWidget(
                                                                        textlabel:
                                                                            'วันที่',
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      height:
                                                                          8.0)),
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
                                                                      children:
                                                                          [
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
                                                                              begin: AlignmentDirectional(0.0, -1.0),
                                                                              end: AlignmentDirectional(0, 1.0),
                                                                            ),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.access_time_filled_rounded,
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              size: 10.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          'เวลาตรวจเสร็จ',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelSmall
                                                                              .override(
                                                                                fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.normal,
                                                                                useGoogleFonts: !FlutterFlowTheme.of(context).labelSmallIsCustom,
                                                                              ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                    wrapWithModel(
                                                                      model: _model
                                                                          .timePickerModel2,
                                                                      updateCallback:
                                                                          () =>
                                                                              safeSetState(() {}),
                                                                      child:
                                                                          TimePickerWidget(
                                                                        textlabel:
                                                                            'เวลา',
                                                                      ),
                                                                    ),
                                                                  ].divide(SizedBox(
                                                                      height:
                                                                          8.0)),
                                                                ),
                                                          ][index]();
                                                        },
                                                      ),
                                                ][index]();
                                              },
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
                                                            .customColor9,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor10
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
                                                          .fileMedical,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'HPI',
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
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Autocomplete<String>(
                                                initialValue:
                                                    TextEditingValue(),
                                                optionsBuilder:
                                                    (textEditingValue) {
                                                  if (textEditingValue.text ==
                                                      '') {
                                                    return const Iterable<
                                                        String>.empty();
                                                  }
                                                  return <String>[]
                                                      .where((option) {
                                                    final lowercaseOption =
                                                        option.toLowerCase();
                                                    return lowercaseOption
                                                        .contains(
                                                            textEditingValue
                                                                .text
                                                                .toLowerCase());
                                                  });
                                                },
                                                optionsViewBuilder: (context,
                                                    onSelected, options) {
                                                  return AutocompleteOptionsList(
                                                    textFieldKey:
                                                        _model.textFieldKey1,
                                                    textController:
                                                        _model.textController1!,
                                                    options: options.toList(),
                                                    onSelected: onSelected,
                                                    textStyle: TextStyle(),
                                                    textHighlightStyle:
                                                        TextStyle(),
                                                    elevation: 4.0,
                                                    optionBackgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryBackground,
                                                    optionHighlightColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryBackground,
                                                    maxHeight: 200.0,
                                                  );
                                                },
                                                onSelected: (String selection) {
                                                  safeSetState(() => _model
                                                          .textFieldSelectedOption1 =
                                                      selection);
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                },
                                                fieldViewBuilder: (
                                                  context,
                                                  textEditingController,
                                                  focusNode,
                                                  onEditingComplete,
                                                ) {
                                                  _model.textFieldFocusNode1 =
                                                      focusNode;

                                                  _model.textController1 =
                                                      textEditingController;
                                                  return TextFormField(
                                                    key: _model.textFieldKey1,
                                                    controller:
                                                        textEditingController,
                                                    focusNode: focusNode,
                                                    onEditingComplete:
                                                        onEditingComplete,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 5,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController1Validator
                                                        .asValidator(context),
                                                  );
                                                },
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 16.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
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
                                    _model.pageview = 2;
                                    safeSetState(() {});
                                  },
                                  child: wrapWithModel(
                                    model: _model.bottonPrimaryModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: BottonPrimaryWidget(
                                      buttonprimary: 'ถัดไป',
                                    ),
                                  ),
                                ),
                              ),
                          ]
                              .divide(SizedBox(height: 8.0))
                              .addToStart(SizedBox(height: () {
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
                          }())),
                        );
                      } else if (_model.pageview == 2) {
                        return Column(
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
                                        return 16.0;
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
                                        return 16.0;
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
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
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
                                child: ListView(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 16.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 16.0;
                                      } else {
                                        return 16.0;
                                      }
                                    }(),
                                    0,
                                    24.0,
                                  ),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/ChatGPT_Image_15_.._2568_13_49_36.png',
                                          width: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 84.0;
                                            } else {
                                              return 84.0;
                                            }
                                          }(),
                                          height: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 84.0;
                                            } else {
                                              return 84.0;
                                            }
                                          }(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        'ตรวจร่างกาย',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Wrap(
                                        spacing: 12.0,
                                        runSpacing: 12.0,
                                        alignment: WrapAlignment.start,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.start,
                                        direction: Axis.horizontal,
                                        runAlignment: WrapAlignment.start,
                                        verticalDirection:
                                            VerticalDirection.down,
                                        clipBehavior: Clip.none,
                                        children: [
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              safeSetState(() {
                                                _model.checkboxValue1 = true;
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
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                    ),
                                                    unselectedWidgetColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText,
                                                  ),
                                                  child: Checkbox(
                                                    value: _model
                                                            .checkboxValue1 ??=
                                                        false,
                                                    onChanged:
                                                        (newValue) async {
                                                      safeSetState(() => _model
                                                              .checkboxValue1 =
                                                          newValue!);
                                                      if (newValue!) {
                                                        FFAppState().ga = 1;
                                                        FFAppState().HEENT = 1;
                                                        FFAppState().Heart = 1;
                                                        FFAppState().Chest = 1;
                                                        FFAppState().Abdomen =
                                                            1;
                                                        FFAppState().PR = 1;
                                                        FFAppState().PV = 1;
                                                        FFAppState().Genitalia =
                                                            1;
                                                        FFAppState()
                                                            .Neurological = 1;
                                                        FFAppState()
                                                            .Extremities = 1;
                                                        safeSetState(() {});
                                                        safeSetState(() {
                                                          _model.checkboxValue2 =
                                                              false;
                                                        });
                                                      } else {
                                                        FFAppState().ga = 0;
                                                        FFAppState().HEENT = 0;
                                                        FFAppState().Heart = 0;
                                                        FFAppState().Chest = 0;
                                                        FFAppState().Abdomen =
                                                            0;
                                                        FFAppState().PR = 0;
                                                        FFAppState().PV = 0;
                                                        FFAppState().Genitalia =
                                                            0;
                                                        FFAppState()
                                                            .Neurological = 0;
                                                        FFAppState()
                                                            .Extremities = 0;
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    side: (FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText !=
                                                            null)
                                                        ? BorderSide(
                                                            width: 2,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText!,
                                                          )
                                                        : null,
                                                    activeColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    checkColor: FlutterFlowTheme
                                                            .of(context)
                                                        .secondaryBackground,
                                                  ),
                                                ),
                                                Text(
                                                  'ปกติทั้งหมด',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              _model.checkboxValue1 ==
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
                                          InkWell(
                                            splashColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () async {
                                              safeSetState(() {
                                                _model.checkboxValue2 = true;
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
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                    ),
                                                    unselectedWidgetColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText,
                                                  ),
                                                  child: Checkbox(
                                                    value: _model
                                                            .checkboxValue2 ??=
                                                        false,
                                                    onChanged:
                                                        (newValue) async {
                                                      safeSetState(() => _model
                                                              .checkboxValue2 =
                                                          newValue!);
                                                      if (newValue!) {
                                                        FFAppState().ga = 3;
                                                        FFAppState().HEENT = 3;
                                                        FFAppState().Heart = 3;
                                                        FFAppState().Chest = 3;
                                                        FFAppState().Abdomen =
                                                            3;
                                                        FFAppState().PR = 3;
                                                        FFAppState().PV = 3;
                                                        FFAppState().Genitalia =
                                                            3;
                                                        FFAppState()
                                                            .Neurological = 3;
                                                        FFAppState()
                                                            .Extremities = 3;
                                                        safeSetState(() {});
                                                        safeSetState(() {
                                                          _model.checkboxValue1 =
                                                              false;
                                                        });
                                                      } else {
                                                        FFAppState().ga = 0;
                                                        FFAppState().HEENT = 0;
                                                        FFAppState().Heart = 0;
                                                        FFAppState().Chest = 0;
                                                        FFAppState().Abdomen =
                                                            0;
                                                        FFAppState().PR = 0;
                                                        FFAppState().PV = 0;
                                                        FFAppState().Genitalia =
                                                            0;
                                                        FFAppState()
                                                            .Neurological = 0;
                                                        FFAppState()
                                                            .Extremities = 0;
                                                        safeSetState(() {});
                                                      }
                                                    },
                                                    side: (FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText !=
                                                            null)
                                                        ? BorderSide(
                                                            width: 2,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText!,
                                                          )
                                                        : null,
                                                    activeColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    checkColor: FlutterFlowTheme
                                                            .of(context)
                                                        .secondaryBackground,
                                                  ),
                                                ),
                                                Text(
                                                  'ไม่ได้ตรวจทั้งหมด',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              _model.checkboxValue2 ==
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
                                        ],
                                      ),
                                    ),
                                    Container(
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                          .personal_injury_sharp,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'GA',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: () {
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
                                              mainAxisSpacing: () {
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
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'gaOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasGaTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'gaOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().ga = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.gaModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: GaWidget(
                                                            text: 'ปกติ',
                                                            ga: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'gaOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasGaTriggered1),
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
                                                          if (animationsMap[
                                                                  'gaOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasGaTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'gaOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().ga = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.gaModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: GaWidget(
                                                            text: 'ผิดปกติ',
                                                            ga: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'gaOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasGaTriggered2),
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
                                                          if (animationsMap[
                                                                  'gaOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasGaTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'gaOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().ga = 3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.gaModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: GaWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            ga: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'gaOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasGaTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().ga == 2)
                                              Container(
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController2,
                                                    focusNode: _model
                                                        .textFieldFocusNode2,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController2Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                      Icons.face_5_outlined,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'HEENT',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: () {
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
                                              mainAxisSpacing: () {
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
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'heentOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasHeentTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'heentOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().HEENT =
                                                              1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .heentModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: HeentWidget(
                                                            text: 'ปกติ',
                                                            heent: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'heentOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasHeentTriggered1),
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
                                                          if (animationsMap[
                                                                  'heentOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasHeentTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'heentOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().HEENT =
                                                              2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .heentModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: HeentWidget(
                                                            text: 'ผิดปกติ',
                                                            heent: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'heentOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasHeentTriggered2),
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
                                                          if (animationsMap[
                                                                  'heentOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasHeentTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'heentOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().HEENT =
                                                              3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .heentModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: HeentWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            heent: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'heentOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasHeentTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().HEENT == 2)
                                              Container(
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController3,
                                                    focusNode: _model
                                                        .textFieldFocusNode3,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController3Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                      Icons.favorite_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Heart',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'heartOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasHeartTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'heartOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Heart =
                                                              1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .heartModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: HeartWidget(
                                                            text: 'ปกติ',
                                                            heart: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'heartOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasHeartTriggered1),
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
                                                          if (animationsMap[
                                                                  'heartOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasHeartTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'heartOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Heart =
                                                              2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .heartModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: HeartWidget(
                                                            text: 'ผิดปกติ',
                                                            heart: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'heartOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasHeartTriggered2),
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
                                                          if (animationsMap[
                                                                  'heartOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasHeartTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'heartOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Heart =
                                                              3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .heartModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: HeartWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            heart: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'heartOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasHeartTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().Heart == 2)
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController4,
                                                    focusNode: _model
                                                        .textFieldFocusNode4,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController4Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                      FontAwesomeIcons.lungs,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 8.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Chest',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'chestOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            animationsMap[
                                                                    'chestOnActionTriggerAnimation1']!
                                                                .controller
                                                                .forward(
                                                                    from: 0.0);
                                                          }
                                                          FFAppState().Heart =
                                                              1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .chestModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: ChestWidget(
                                                            text: 'ปกติ',
                                                            chest: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                        animationsMap[
                                                            'chestOnActionTriggerAnimation1']!,
                                                      ),
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
                                                          if (animationsMap[
                                                                  'chestOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasChestTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'chestOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Heart =
                                                              2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .chestModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: ChestWidget(
                                                            text: 'ผิดปกติ',
                                                            chest: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'chestOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasChestTriggered2),
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
                                                          if (animationsMap[
                                                                  'chestOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasChestTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'chestOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Heart =
                                                              3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .chestModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: ChestWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            chest: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'chestOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasChestTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().Chest == 2)
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController5,
                                                    focusNode: _model
                                                        .textFieldFocusNode5,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController5Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                          .personal_injury_sharp,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Abdomen',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'abdomenOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasAbdomenTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'abdomenOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Abdomen =
                                                              1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .abdomenModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: AbdomenWidget(
                                                            text: 'ปกติ',
                                                            abdomen: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'abdomenOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasAbdomenTriggered1),
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
                                                          if (animationsMap[
                                                                  'abdomenOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasAbdomenTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'abdomenOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Abdomen =
                                                              2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .abdomenModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: AbdomenWidget(
                                                            text: 'ผิดปกติ',
                                                            abdomen: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'abdomenOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasAbdomenTriggered2),
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
                                                          if (animationsMap[
                                                                  'abdomenOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasAbdomenTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'abdomenOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Abdomen =
                                                              3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .abdomenModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: AbdomenWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            abdomen: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'abdomenOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasAbdomenTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().Abdomen == 2)
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController6,
                                                    focusNode: _model
                                                        .textFieldFocusNode6,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController6Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                      FontAwesomeIcons.pooStorm,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'PR',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'prOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasPrTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'prOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().PR = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.prModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: PrWidget(
                                                            text: 'ปกติ',
                                                            pr: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'prOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasPrTriggered1),
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
                                                          if (animationsMap[
                                                                  'prOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasPrTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'prOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().PR = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.prModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: PrWidget(
                                                            text: 'ผิดปกติ',
                                                            pr: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'prOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasPrTriggered2),
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
                                                          if (animationsMap[
                                                                  'prOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasPrTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'prOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().PR = 3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.prModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: PrWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            pr: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'prOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasPrTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().PR == 2)
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController7,
                                                    focusNode: _model
                                                        .textFieldFocusNode7,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController7Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                          .self_improvement_outlined,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'PV',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'pvOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasPvTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'pvOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().PV = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.pvModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: PvWidget(
                                                            text: 'ปกติ',
                                                            pv: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'pvOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasPvTriggered1),
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
                                                          if (animationsMap[
                                                                  'pvOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasPvTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'pvOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().PV = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.pvModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: PvWidget(
                                                            text: 'ผิดปกติ',
                                                            pv: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'pvOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasPvTriggered2),
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
                                                          if (animationsMap[
                                                                  'pvOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasPvTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'pvOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().PV = 3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.pvModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: PvWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            pv: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'pvOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasPvTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().PV == 2)
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController8,
                                                    focusNode: _model
                                                        .textFieldFocusNode8,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController8Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                      Icons.egg,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Genitalia',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'genitaliaOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasGenitaliaTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'genitaliaOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Genitalia = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .genitaliaModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              GenitaliaWidget(
                                                            text: 'ปกติ',
                                                            genitalia: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'genitaliaOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasGenitaliaTriggered1),
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
                                                          if (animationsMap[
                                                                  'genitaliaOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasGenitaliaTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'genitaliaOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Genitalia = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .genitaliaModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              GenitaliaWidget(
                                                            text: 'ผิดปกติ',
                                                            genitalia: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'genitaliaOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasGenitaliaTriggered2),
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
                                                          if (animationsMap[
                                                                  'genitaliaOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasGenitaliaTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'genitaliaOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Genitalia = 3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .genitaliaModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              GenitaliaWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            genitalia: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'genitaliaOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasGenitaliaTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().Genitalia == 2)
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController9,
                                                    focusNode: _model
                                                        .textFieldFocusNode9,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController9Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                      size: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Neurological',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'neurologicalOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasNeurologicalTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'neurologicalOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Neurological = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .neurologicalModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              NeurologicalWidget(
                                                            text: 'ปกติ',
                                                            neurological: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'neurologicalOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasNeurologicalTriggered1),
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
                                                          if (animationsMap[
                                                                  'neurologicalOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasNeurologicalTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'neurologicalOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Neurological = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .neurologicalModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              NeurologicalWidget(
                                                            text: 'ผิดปกติ',
                                                            neurological: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'neurologicalOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasNeurologicalTriggered2),
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
                                                          if (animationsMap[
                                                                  'neurologicalOnActionTriggerAnimation3'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasNeurologicalTriggered3 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'neurologicalOnActionTriggerAnimation3']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Neurological = 3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .neurologicalModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              NeurologicalWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            neurological: 3,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'neurologicalOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasNeurologicalTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().Neurological == 2)
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController10,
                                                    focusNode: _model
                                                        .textFieldFocusNode10,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController10Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                          .directions_run_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Extremities',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: 12.0,
                                              mainAxisSpacing: 12.0,
                                              itemCount: 3,
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
                                                          if (animationsMap[
                                                                  'extremitiesOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasExtremitiesTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'extremitiesOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Extremities = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .extremitiesModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              ExtremitiesWidget(
                                                            text: 'ปกติ',
                                                            extremities: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'extremitiesOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasExtremitiesTriggered1),
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
                                                          if (animationsMap[
                                                                  'extremitiesOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasExtremitiesTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'extremitiesOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Extremities = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .extremitiesModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              ExtremitiesWidget(
                                                            text: 'ผิดปกติ',
                                                            extremities: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'extremitiesOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasExtremitiesTriggered2),
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
                                                          if (animationsMap[
                                                                  'extremitiesOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasExtremitiesTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'extremitiesOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Extremities = 3;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .extremitiesModel3,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              ExtremitiesWidget(
                                                            text: 'ไม่ได้ตรวจ',
                                                            extremities: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'extremitiesOnActionTriggerAnimation3']!,
                                                          hasBeenTriggered:
                                                              hasExtremitiesTriggered3),
                                                ][index]();
                                              },
                                            ),
                                            if (FFAppState().Extremities == 2)
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController11,
                                                    focusNode: _model
                                                        .textFieldFocusNode11,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController11Validator
                                                        .asValidator(context),
                                                  ),
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
                                                            .customColor11,
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor12
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
                                                      Icons.boy_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'บันทึกการตรวจร่างกาย',
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
                                            Container(
                                              decoration: BoxDecoration(),
                                              child: Container(
                                                width: double.infinity,
                                                child: TextFormField(
                                                  controller:
                                                      _model.textController12,
                                                  focusNode: _model
                                                      .textFieldFocusNode12,
                                                  autofocus: false,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'รายละเอียด...',
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMediumFamily,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelMediumIsCustom,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryBackground,
                                                  ),
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
                                                  maxLines: null,
                                                  minLines: 1,
                                                  cursorColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .primary,
                                                  validator: _model
                                                      .textController12Validator
                                                      .asValidator(context),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 16.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
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
                                    _model.pageview = 3;
                                    safeSetState(() {});
                                  },
                                  child: wrapWithModel(
                                    model: _model.bottonPrimaryModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: BottonPrimaryWidget(
                                      buttonprimary: 'ถัดไป',
                                    ),
                                  ),
                                ),
                              ),
                          ]
                              .divide(SizedBox(height: 8.0))
                              .addToStart(SizedBox(height: () {
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
                          }())),
                        );
                      } else if (_model.pageview == 3) {
                        return Column(
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
                                        return 16.0;
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
                                        return 16.0;
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
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: 100.0,
                                      height: 3.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
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
                                child: ListView(
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    () {
                                      if (MediaQuery.sizeOf(context).width <
                                          kBreakpointSmall) {
                                        return 12.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointMedium) {
                                        return 16.0;
                                      } else if (MediaQuery.sizeOf(context)
                                              .width <
                                          kBreakpointLarge) {
                                        return 16.0;
                                      } else {
                                        return 16.0;
                                      }
                                    }(),
                                    0,
                                    24.0,
                                  ),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/ChatGPT_Image_15_.._2568_16_25_50.png',
                                          width: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 84.0;
                                            } else {
                                              return 84.0;
                                            }
                                          }(),
                                          height: () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 64.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 84.0;
                                            } else {
                                              return 84.0;
                                            }
                                          }(),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        'Review of System',
                                        style: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmallFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .titleSmallIsCustom,
                                            ),
                                      ),
                                    ),
                                    Container(
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
                                                      Icons.sick,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Constitutional',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: () {
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
                                              mainAxisSpacing: () {
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
                                              itemCount: 2,
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
                                                          if (animationsMap[
                                                                  'constitutionalOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasConstitutionalTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'constitutionalOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Constitutional = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .constitutionalModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              ConstitutionalWidget(
                                                            text: 'Possitive',
                                                            constitutional: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'constitutionalOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasConstitutionalTriggered1),
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
                                                          if (animationsMap[
                                                                  'constitutionalOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasConstitutionalTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'constitutionalOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .Constitutional = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .constitutionalModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              ConstitutionalWidget(
                                                            text: 'Negative',
                                                            constitutional: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'constitutionalOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasConstitutionalTriggered2),
                                                ][index]();
                                              },
                                            ),
                                            if ((FFAppState().Constitutional ==
                                                    1) &&
                                                (FFAppState().Constitutional ==
                                                    2))
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController13,
                                                    focusNode: _model
                                                        .textFieldFocusNode13,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController13Validator
                                                        .asValidator(context),
                                                  ),
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
                                                      Icons.remove_red_eye,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'Eyes',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: () {
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
                                              mainAxisSpacing: () {
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
                                              itemCount: 2,
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
                                                          if (animationsMap[
                                                                  'eyesOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasEyesTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'eyesOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Eyes = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.eyesModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: EyesWidget(
                                                            text: 'Possitive',
                                                            eyes: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'eyesOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasEyesTriggered1),
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
                                                          if (animationsMap[
                                                                  'eyesOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasEyesTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'eyesOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState().Eyes = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model:
                                                              _model.eyesModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: EyesWidget(
                                                            text: 'Negative',
                                                            eyes: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'eyesOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasEyesTriggered2),
                                                ][index]();
                                              },
                                            ),
                                            if ((FFAppState().Eyes == 1) &&
                                                (FFAppState().Eyes == 2))
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController14,
                                                    focusNode: _model
                                                        .textFieldFocusNode14,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController14Validator
                                                        .asValidator(context),
                                                  ),
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
                                                      Icons.hearing_sharp,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      size: 10.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  'ENT/Mounth',
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
                                            MasonryGridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                              ),
                                              crossAxisSpacing: () {
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
                                              mainAxisSpacing: () {
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
                                              itemCount: 2,
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
                                                          if (animationsMap[
                                                                  'eNTMounthOnActionTriggerAnimation1'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasENTMounthTriggered1 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'eNTMounthOnActionTriggerAnimation1']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .ENTMounth = 1;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .eNTMounthModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              ENTMounthWidget(
                                                            text: 'Possitive',
                                                            eNTMounth: 1,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'eNTMounthOnActionTriggerAnimation1']!,
                                                          hasBeenTriggered:
                                                              hasENTMounthTriggered1),
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
                                                          if (animationsMap[
                                                                  'eNTMounthOnActionTriggerAnimation2'] !=
                                                              null) {
                                                            safeSetState(() =>
                                                                hasENTMounthTriggered2 =
                                                                    true);
                                                            SchedulerBinding
                                                                .instance
                                                                .addPostFrameCallback((_) async => animationsMap[
                                                                        'eNTMounthOnActionTriggerAnimation2']!
                                                                    .controller
                                                                    .forward(
                                                                        from:
                                                                            0.0));
                                                          }
                                                          FFAppState()
                                                              .ENTMounth = 2;
                                                          safeSetState(() {});
                                                        },
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .eNTMounthModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child:
                                                              ENTMounthWidget(
                                                            text: 'Negative',
                                                            eNTMounth: 2,
                                                          ),
                                                        ),
                                                      ).animateOnActionTrigger(
                                                          animationsMap[
                                                              'eNTMounthOnActionTriggerAnimation2']!,
                                                          hasBeenTriggered:
                                                              hasENTMounthTriggered2),
                                                ][index]();
                                              },
                                            ),
                                            if ((FFAppState().ENTMounth == 1) &&
                                                (FFAppState().ENTMounth == 2))
                                              Container(
                                                decoration: BoxDecoration(),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController15,
                                                    focusNode: _model
                                                        .textFieldFocusNode15,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      hintText: 'รายละเอียด...',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMediumFamily,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                useGoogleFonts:
                                                                    !FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMediumIsCustom,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryBackground,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
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
                                                    maxLines: null,
                                                    minLines: 1,
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    validator: _model
                                                        .textController15Validator
                                                        .asValidator(context),
                                                  ),
                                                ),
                                              ),
                                          ].divide(SizedBox(height: 8.0)),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 16.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
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
                                    _model.pageview = 4;
                                    safeSetState(() {});
                                  },
                                  child: wrapWithModel(
                                    model: _model.bottonPrimaryModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: BottonPrimaryWidget(
                                      buttonprimary: 'ถัดไป',
                                    ),
                                  ),
                                ),
                              ),
                          ]
                              .divide(SizedBox(height: 8.0))
                              .addToStart(SizedBox(height: () {
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
                          }())),
                        );
                      } else {
                        return Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(),
                        );
                      }
                    },
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
