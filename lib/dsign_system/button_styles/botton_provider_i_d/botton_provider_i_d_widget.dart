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
import 'botton_provider_i_d_model.dart';
export 'botton_provider_i_d_model.dart';

class BottonProviderIDWidget extends StatefulWidget {
  const BottonProviderIDWidget({super.key});

  @override
  State<BottonProviderIDWidget> createState() => _BottonProviderIDWidgetState();
}

class _BottonProviderIDWidgetState extends State<BottonProviderIDWidget>
    with TickerProviderStateMixin {
  late BottonProviderIDModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BottonProviderIDModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 1540.0.ms,
            color: Color(0x80FFFFFF),
            angle: 2.705,
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
      width: 500.0,
      height: 56.0,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            color: Color(0x32000000),
            offset: Offset(
              0.0,
              0.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(100.0),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE7CA43), Color(0xFF12861B)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(1.0, -1.0),
                end: AlignmentDirectional(-1.0, 1.0),
              ),
              borderRadius: BorderRadius.circular(100.0),
            ),
          ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!),
          Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xE5FFFFFF),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/provider.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
