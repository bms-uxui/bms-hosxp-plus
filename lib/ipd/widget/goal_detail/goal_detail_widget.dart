import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'goal_detail_model.dart';
export 'goal_detail_model.dart';

class GoalDetailWidget extends StatefulWidget {
  const GoalDetailWidget({
    super.key,
    this.goal,
    Color? bgcolor,
  }) : this.bgcolor = bgcolor ?? const Color(0xFFF1F4F8);

  final String? goal;
  final Color bgcolor;

  @override
  State<GoalDetailWidget> createState() => _GoalDetailWidgetState();
}

class _GoalDetailWidgetState extends State<GoalDetailWidget> {
  late GoalDetailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoalDetailModel());

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
      width: double.infinity,
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          widget!.bgcolor,
          Color(0xFFF1F4F8),
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(valueOrDefault<double>(
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
          0.0,
        )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF37BD80), Color(0xFF006838)],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Icon(
                      Icons.mode_standby_rounded,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      size: 10.0,
                    ),
                  ),
                ),
                Text(
                  'เป้าหมาย',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ].divide(SizedBox(width: 8.0)),
            ),
            Text(
              valueOrDefault<String>(
                widget!.goal,
                'Goal Detail',
              ),
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                    letterSpacing: 0.0,
                    lineHeight: 1.7,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).labelMediumIsCustom,
                  ),
            ),
          ].divide(SizedBox(height: 8.0)),
        ),
      ),
    );
  }
}
