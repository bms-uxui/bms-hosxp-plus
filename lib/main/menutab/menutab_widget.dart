import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'menutab_model.dart';
export 'menutab_model.dart';

class MenutabWidget extends StatefulWidget {
  const MenutabWidget({
    super.key,
    this.tab,
    this.stage,
    required this.action,
  });

  final String? tab;
  final String? stage;
  final Future Function()? action;

  @override
  State<MenutabWidget> createState() => _MenutabWidgetState();
}

class _MenutabWidgetState extends State<MenutabWidget>
    with TickerProviderStateMixin {
  late MenutabModel _model;

  var hasContainerTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenutabModel());

    animationsMap.addAll({
      'containerOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.bounceOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
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
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (animationsMap['containerOnActionTriggerAnimation'] != null) {
          safeSetState(() => hasContainerTriggered = true);
          SchedulerBinding.instance.addPostFrameCallback((_) async =>
              animationsMap['containerOnActionTriggerAnimation']!
                  .controller
                  .forward(from: 0.0));
        }
        unawaited(
          () async {
            await widget.action?.call();
          }(),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutQuint,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              valueOrDefault<Color>(
                widget!.stage == widget!.tab
                    ? FlutterFlowTheme.of(context).secondary
                    : FlutterFlowTheme.of(context).primaryBackground,
                FlutterFlowTheme.of(context).primaryBackground,
              ),
              valueOrDefault<Color>(
                widget!.stage == widget!.tab
                    ? FlutterFlowTheme.of(context).accent1
                    : FlutterFlowTheme.of(context).primaryBackground,
                FlutterFlowTheme.of(context).primaryBackground,
              )
            ],
            stops: [0.0, 1.0],
            begin: AlignmentDirectional(0.0, -1.0),
            end: AlignmentDirectional(0, 1.0),
          ),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
          child: Text(
            valueOrDefault<String>(
              widget!.tab,
              'tab 1',
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                  color: valueOrDefault<Color>(
                    widget!.stage == widget!.tab
                        ? FlutterFlowTheme.of(context).secondaryBackground
                        : FlutterFlowTheme.of(context).secondaryText,
                    FlutterFlowTheme.of(context).secondaryText,
                  ),
                  letterSpacing: 0.0,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodyMediumIsCustom,
                ),
          ),
        ),
      ),
    ).animateOnActionTrigger(
        animationsMap['containerOnActionTriggerAnimation']!,
        hasBeenTriggered: hasContainerTriggered);
  }
}
