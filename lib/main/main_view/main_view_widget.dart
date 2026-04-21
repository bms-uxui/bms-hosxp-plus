import '/dsign_system/not_data/not_data_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/main/widget/button_card_style1/button_card_style1_widget.dart';
import '/main/widget/doctors_rounds_mainpage/doctors_rounds_mainpage_widget.dart';
import '/main/widget/i_p_d_mainpage/i_p_d_mainpage_widget.dart';
import '/main/widget/o_p_dhome_mainpage/o_p_dhome_mainpage_widget.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main_view_model.dart';
export 'main_view_model.dart';

class MainViewWidget extends StatefulWidget {
  const MainViewWidget({super.key});

  @override
  State<MainViewWidget> createState() => _MainViewWidgetState();
}

class _MainViewWidgetState extends State<MainViewWidget>
    with TickerProviderStateMixin {
  late MainViewModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainViewModel());

    animationsMap.addAll({
      'buttonCardStyle1OnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 500.0.ms,
            begin: Offset(1.02, 1.02),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonCardStyle1OnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 500.0.ms,
            begin: Offset(1.02, 1.02),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'buttonCardStyle1OnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 500.0.ms,
            begin: Offset(1.02, 1.02),
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
    return Container(
      decoration: BoxDecoration(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
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
          0,
          0,
        ),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
            child: MasonryGridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 2;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 2;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 3;
                  } else {
                    return 3;
                  }
                }(),
              ),
              crossAxisSpacing: () {
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
              mainAxisSpacing: () {
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
              itemCount: 3,
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                0,
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return [
                  () => wrapWithModel(
                        model: _model.buttonCardStyle1Model1,
                        updateCallback: () => safeSetState(() {}),
                        child: ButtonCardStyle1Widget(
                          title: 'ผู้ป่วยนอก',
                          amount: '0',
                          unit: 'คน',
                          icon:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/4itxktmmyzfz/ChatGPT_Image_22_%E0%B8%9E.%E0%B8%84._2568_08_48_56.png',
                          stage: _model.view!,
                          action: () async {
                            _model.view = 'ผู้ป่วยนอก';
                            safeSetState(() {});
                          },
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'buttonCardStyle1OnActionTriggerAnimation1']!,
                      ),
                  () => wrapWithModel(
                        model: _model.buttonCardStyle1Model2,
                        updateCallback: () => safeSetState(() {}),
                        child: ButtonCardStyle1Widget(
                          title: 'ผู้ป่วยใน',
                          amount: '0',
                          unit: 'คน',
                          icon:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/8h0838kcutdg/ChatGPT_Image_22_%E0%B8%9E.%E0%B8%84._2568_08_10_21.png',
                          stage: _model.view!,
                          action: () async {
                            _model.view = 'ผู้ป่วยใน';
                            safeSetState(() {});
                          },
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'buttonCardStyle1OnActionTriggerAnimation2']!,
                      ),
                  () => wrapWithModel(
                        model: _model.buttonCardStyle1Model3,
                        updateCallback: () => safeSetState(() {}),
                        child: ButtonCardStyle1Widget(
                          title: 'แพทย์ออกตรวจ',
                          amount: '0',
                          unit: 'คน',
                          icon:
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/h-o-sx-p-upgrade-igc2oy/assets/9uxjwrvmiadp/ChatGPT_Image_22_%E0%B8%9E.%E0%B8%84._2568_08_22_52.png',
                          stage: _model.view!,
                          action: () async {
                            _model.view = 'แพทย์ออกตรวจ';
                            safeSetState(() {});
                          },
                        ),
                      ).animateOnActionTrigger(
                        animationsMap[
                            'buttonCardStyle1OnActionTriggerAnimation3']!,
                      ),
                ][index]();
              },
            ),
          ),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: () {
                if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
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
            child: Builder(
              builder: (context) {
                if (_model.view == 'ผู้ป่วยนอก') {
                  return wrapWithModel(
                    model: _model.oPDhomeMainpageModel,
                    updateCallback: () => safeSetState(() {}),
                    child: OPDhomeMainpageWidget(),
                  );
                } else if (_model.view == 'ผู้ป่วยใน') {
                  return wrapWithModel(
                    model: _model.iPDMainpageModel,
                    updateCallback: () => safeSetState(() {}),
                    child: IPDMainpageWidget(),
                  );
                } else if (_model.view == 'แพทย์ออกตรวจ') {
                  return Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 100.0),
                    child: wrapWithModel(
                      model: _model.doctorsRoundsMainpageModel,
                      updateCallback: () => safeSetState(() {}),
                      child: DoctorsRoundsMainpageWidget(),
                    ),
                  );
                } else {
                  return Container(
                    height: 200.0,
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: wrapWithModel(
                        model: _model.notDataModel,
                        updateCallback: () => safeSetState(() {}),
                        child: NotDataWidget(),
                      ),
                    ),
                  );
                }
              },
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
    );
  }
}
