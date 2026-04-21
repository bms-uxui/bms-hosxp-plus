import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'assessment_detail_model.dart';
export 'assessment_detail_model.dart';

class AssessmentDetailWidget extends StatefulWidget {
  const AssessmentDetailWidget({
    super.key,
    this.assessment,
    Color? bgcolor,
  }) : this.bgcolor = bgcolor ?? const Color(0xFFF1F4F8);

  final String? assessment;
  final Color bgcolor;

  @override
  State<AssessmentDetailWidget> createState() => _AssessmentDetailWidgetState();
}

class _AssessmentDetailWidgetState extends State<AssessmentDetailWidget> {
  late AssessmentDetailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AssessmentDetailModel());

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
                      colors: [Color(0xFFB078FF), Color(0xFF9040FF)],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      size: 10.0,
                    ),
                  ),
                ),
                Text(
                  'การประเมิน',
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
                widget!.assessment,
                'Assessment Detail',
              ),
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
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
