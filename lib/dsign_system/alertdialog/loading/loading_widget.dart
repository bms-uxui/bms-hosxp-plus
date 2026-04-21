import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'loading_model.dart';
export 'loading_model.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  late LoadingModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xC9FFFFFF),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                'assets/jsons/Animation_-_1749114655055.json',
                width: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 56.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 56.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 64.0;
                  } else {
                    return 64.0;
                  }
                }(),
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 56.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 56.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 64.0;
                  } else {
                    return 64.0;
                  }
                }(),
                fit: BoxFit.contain,
                animate: true,
              ),
            ),
          ),
        ),
        Text(
          'กำลังโหลด...',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                letterSpacing: 0.0,
                useGoogleFonts:
                    !FlutterFlowTheme.of(context).bodyMediumIsCustom,
              ),
        ),
      ].divide(SizedBox(height: 16.0)),
    );
  }
}
