import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_right_treatment_model.dart';
export 'item_right_treatment_model.dart';

class ItemRightTreatmentWidget extends StatefulWidget {
  const ItemRightTreatmentWidget({
    super.key,
    this.name,
    this.quantity,
  });

  final String? name;
  final String? quantity;

  @override
  State<ItemRightTreatmentWidget> createState() =>
      _ItemRightTreatmentWidgetState();
}

class _ItemRightTreatmentWidgetState extends State<ItemRightTreatmentWidget> {
  late ItemRightTreatmentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemRightTreatmentModel());

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
      height: () {
        if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
          return 120.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
          return 120.0;
        } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
          return 140.0;
        } else {
          return 140.0;
        }
      }(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF19A015),
            Color(0xFF056F00),
            FlutterFlowTheme.of(context).secondaryBackground
          ],
          stops: [0.0, 0.7, 1.0],
          begin: AlignmentDirectional(0.0, -1.0),
          end: AlignmentDirectional(0, 1.0),
        ),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(-1.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      valueOrDefault<double>(
                        () {
                          if (MediaQuery.sizeOf(context).width <
                              kBreakpointSmall) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointMedium) {
                            return 56.0;
                          } else if (MediaQuery.sizeOf(context).width <
                              kBreakpointLarge) {
                            return 70.0;
                          } else {
                            return 70.0;
                          }
                        }(),
                        0.0,
                      ),
                      8.0,
                      0.0,
                      8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สิทธิการรักษา',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodySmallFamily,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodySmallIsCustom,
                            ),
                      ),
                      Text(
                        valueOrDefault<String>(
                          widget!.name,
                          'Right  Treatment',
                        ),
                        maxLines: 1,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  FlutterFlowTheme.of(context).bodyMediumFamily,
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              useGoogleFonts: !FlutterFlowTheme.of(context)
                                  .bodyMediumIsCustom,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(valueOrDefault<double>(
                      () {
                        if (MediaQuery.sizeOf(context).width <
                            kBreakpointSmall) {
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
                      0.0,
                    )),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'จำนวน',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                fontFamily: FlutterFlowTheme.of(context)
                                    .labelSmallFamily,
                                letterSpacing: 0.0,
                                useGoogleFonts: !FlutterFlowTheme.of(context)
                                    .labelSmallIsCustom,
                              ),
                        ),
                        RichText(
                          textScaler: MediaQuery.of(context).textScaler,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: valueOrDefault<String>(
                                  widget!.quantity,
                                  '0',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleLargeFamily,
                                      color: Color(0xFF056F00),
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleLargeIsCustom,
                                    ),
                              ),
                              TextSpan(
                                text: '  คน',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .labelSmallFamily,
                                      letterSpacing: 0.0,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .labelSmallIsCustom,
                                    ),
                              )
                            ],
                            style: FlutterFlowTheme.of(context)
                                .headlineLarge
                                .override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .headlineLargeFamily,
                                  color: Color(0xFF2A5490),
                                  letterSpacing: 0.0,
                                  useGoogleFonts: !FlutterFlowTheme.of(context)
                                      .headlineLargeIsCustom,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                valueOrDefault<double>(
                  () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 8.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 8.0;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointLarge) {
                      return 12.0;
                    } else {
                      return 12.0;
                    }
                  }(),
                  0.0,
                ),
                16.0,
                0.0,
                0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/ChatGPT_Image_21_.._2568_18_12_28.png',
                width: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 40.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 40.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 48.0;
                  } else {
                    return 48.0;
                  }
                }(),
                height: () {
                  if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                    return 40.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointMedium) {
                    return 40.0;
                  } else if (MediaQuery.sizeOf(context).width <
                      kBreakpointLarge) {
                    return 48.0;
                  } else {
                    return 48.0;
                  }
                }(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
