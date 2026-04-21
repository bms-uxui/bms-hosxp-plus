import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'animation_tablet_model.dart';
export 'animation_tablet_model.dart';

class AnimationTabletWidget extends StatefulWidget {
  const AnimationTabletWidget({super.key});

  @override
  State<AnimationTabletWidget> createState() => _AnimationTabletWidgetState();
}

class _AnimationTabletWidgetState extends State<AnimationTabletWidget>
    with TickerProviderStateMixin {
  late AnimationTabletModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AnimationTabletModel());

    animationsMap.addAll({
      'imageOnPageLoadAnimation1': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 1200.0.ms,
            duration: 30000.0.ms,
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation2': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          RotateEffect(
            curve: Curves.easeInOut,
            delay: 1200.0.ms,
            duration: 20000.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 600.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 600.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'imageOnPageLoadAnimation4': AnimationInfo(
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
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'imageOnPageLoadAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 800.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 800.0.ms,
            begin: Offset(0.0, 3.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 600.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 600.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 700.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 900.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 900.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 800.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 800.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 1100.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 1100.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 1000.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 1000.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.8, 0.8),
            end: Offset(1.0, 1.0),
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
    return Container(
      width: 590.0,
      height: 590.0,
      decoration: BoxDecoration(),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.asset(
                'assets/images/ring1.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation1']!),
          ),
          Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.asset(
                'assets/images/ring2.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation2']!),
          ),
          Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.asset(
                'assets/images/ring3.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation3']!),
          ),
          Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.asset(
                'assets/images/centerlogin.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation4']!),
          ),
          Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.asset(
                'assets/images/doctoranimation.png',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation5']!),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                    child: Container(
                      width: 70.0,
                      height: 70.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFF0E2),
                            FlutterFlowTheme.of(context).warning
                          ],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(0.0, -1.0),
                          end: AlignmentDirectional(0, 1.0),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xCDFFFFFF),
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.asset(
                          'assets/images/cratoon1.png',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['containerOnPageLoadAnimation1']!),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                    child: Container(
                      width: 70.0,
                      height: 70.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFB9D9FF),
                            FlutterFlowTheme.of(context).accent1
                          ],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(0.0, -1.0),
                          end: AlignmentDirectional(0, 1.0),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xCDFFFFFF),
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.asset(
                          'assets/images/cratoon4.png',
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).animateOnPageLoad(
                        animationsMap['containerOnPageLoadAnimation2']!),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.77, 0.59),
                  child: Container(
                    width: 70.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFBBFFD2),
                          FlutterFlowTheme.of(context).success
                        ],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0.0, -1.0),
                        end: AlignmentDirectional(0, 1.0),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xCDFFFFFF),
                        width: 2.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image.asset(
                        'assets/images/cratoon3.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation3']!),
                ),
                Align(
                  alignment: AlignmentDirectional(-0.77, -0.59),
                  child: Container(
                    width: 70.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFDEEDFF),
                          FlutterFlowTheme.of(context).info
                        ],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0.0, -1.0),
                        end: AlignmentDirectional(0, 1.0),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xCDFFFFFF),
                        width: 2.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image.asset(
                        'assets/images/cratoon6.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation4']!),
                ),
                Align(
                  alignment: AlignmentDirectional(0.77, -0.59),
                  child: Container(
                    width: 70.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFDBDF),
                          FlutterFlowTheme.of(context).error
                        ],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0.0, -1.0),
                        end: AlignmentDirectional(0, 1.0),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xCDFFFFFF),
                        width: 2.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image.asset(
                        'assets/images/cratoon2.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation5']!),
                ),
                Align(
                  alignment: AlignmentDirectional(-0.77, 0.59),
                  child: Container(
                    width: 70.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD9F9), Color(0xFFAA3A9F)],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(0.0, -1.0),
                        end: AlignmentDirectional(0, 1.0),
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xCDFFFFFF),
                        width: 2.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image.asset(
                        'assets/images/cratoon5.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation6']!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
