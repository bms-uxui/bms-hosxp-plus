import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'nursingproblems_detail_model.dart';
export 'nursingproblems_detail_model.dart';

class NursingproblemsDetailWidget extends StatefulWidget {
  const NursingproblemsDetailWidget({
    super.key,
    this.nursingproblems,
    Color? bgcolor,
  }) : this.bgcolor = bgcolor ?? const Color(0xFFF1F4F8);

  final String? nursingproblems;
  final Color bgcolor;

  @override
  State<NursingproblemsDetailWidget> createState() =>
      _NursingproblemsDetailWidgetState();
}

class _NursingproblemsDetailWidgetState
    extends State<NursingproblemsDetailWidget> {
  late NursingproblemsDetailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NursingproblemsDetailModel());

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
                      colors: [Color(0xFFF26E79), Color(0xFFBE1E2D)],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(0.0, -1.0),
                      end: AlignmentDirectional(0, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: FaIcon(
                      FontAwesomeIcons.userNurse,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      size: 10.0,
                    ),
                  ),
                ),
                Text(
                  'ปัญหาทางพยาบาล',
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
                widget!.nursingproblems,
                'nursingproblems Detail',
              ),
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    fontFamily: FlutterFlowTheme.of(context).labelMediumFamily,
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
