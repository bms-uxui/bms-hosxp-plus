import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'user_profile_model.dart';
export 'user_profile_model.dart';

class UserProfileWidget extends StatefulWidget {
  const UserProfileWidget({
    super.key,
    this.name,
    this.jobposition,
    this.color,
    this.colorj,
  });

  final String? name;
  final String? jobposition;
  final Color? color;
  final Color? colorj;

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late UserProfileModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserProfileModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 48.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 48.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 56.0;
            } else {
              return 56.0;
            }
          }(),
          height: () {
            if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
              return 48.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
              return 48.0;
            } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
              return 56.0;
            } else {
              return 56.0;
            }
          }(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FlutterFlowTheme.of(context).secondary,
                FlutterFlowTheme.of(context).accent2
              ],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100.0),
            child: Image.asset(
              'assets/images/ChatGPT_Image_19_.._2568_09_05_28.png',
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valueOrDefault<String>(
                widget!.name,
                'name',
              ),
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                    color: valueOrDefault<Color>(
                      widget!.color,
                      FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Color(0x2757636C),
                        offset: Offset(0.0, 0.0),
                        blurRadius: 3.0,
                      )
                    ],
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                  ),
            ),
            Container(
              decoration: BoxDecoration(
                color: valueOrDefault<Color>(
                  widget!.colorj,
                  Color(0x34FFFFFF),
                ),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 2.0, 12.0, 2.0),
                child: Text(
                  valueOrDefault<String>(
                    widget!.jobposition,
                    'jobposition',
                  ),
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily:
                            FlutterFlowTheme.of(context).bodySmallFamily,
                        color: valueOrDefault<Color>(
                          widget!.color,
                          FlutterFlowTheme.of(context).secondaryBackground,
                        ),
                        fontSize: () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 10.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 10.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 12.0;
                          } else {
                            return 12.0;
                          }
                        }(),
                        letterSpacing: 0.0,
                        useGoogleFonts:
                            !FlutterFlowTheme.of(context).bodySmallIsCustom,
                      ),
                ),
              ),
            ),
          ].divide(SizedBox(height: 4.0)),
        ),
      ].divide(SizedBox(width: 12.0)),
    );
  }
}
