import '/flutter_flow/flutter_flow_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'fillter_treatment_i_p_d_model.dart';
export 'fillter_treatment_i_p_d_model.dart';

class FillterTreatmentIPDWidget extends StatefulWidget {
  const FillterTreatmentIPDWidget({super.key});

  @override
  State<FillterTreatmentIPDWidget> createState() =>
      _FillterTreatmentIPDWidgetState();
}

class _FillterTreatmentIPDWidgetState extends State<FillterTreatmentIPDWidget> {
  late FillterTreatmentIPDModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FillterTreatmentIPDModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        height: () {
          if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
            return 550.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
            return 550.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
            return 650.0;
          } else {
            return 650.0;
          }
        }(),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Text(
                    'กรองข้อมูล',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily:
                              FlutterFlowTheme.of(context).titleSmallFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts:
                              !FlutterFlowTheme.of(context).titleSmallIsCustom,
                        ),
                  ),
                  Container(
                    width: 50.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional(1.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'ตกลง',
                          style: GoogleFonts.roboto(
                            color: FlutterFlowTheme.of(context).info,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                    valueOrDefault<double>(
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
                    ),
                    0.0,
                    valueOrDefault<double>(
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
                    ),
                    0.0),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    () {
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
                  ),
                  scrollDirection: Axis.vertical,
                  children: [
                    Container(
                      width: 100.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(24.0),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                safeSetState(() {
                                  _model.checkboxValue1 = true;
                                });
                                safeSetState(() {
                                  _model.checkboxValue2 = false;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Theme(
                                      data: ThemeData(
                                        checkboxTheme: CheckboxThemeData(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          shape: CircleBorder(),
                                        ),
                                        unselectedWidgetColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                      ),
                                      child: Checkbox(
                                        value: _model.checkboxValue1 ??= false,
                                        onChanged: (newValue) async {
                                          safeSetState(() => _model
                                              .checkboxValue1 = newValue!);
                                          if (newValue!) {
                                            safeSetState(() {
                                              _model.checkboxValue2 = false;
                                            });
                                          }
                                        },
                                        side: (FlutterFlowTheme.of(context)
                                                    .alternate !=
                                                null)
                                            ? BorderSide(
                                                width: 2,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate!,
                                              )
                                            : null,
                                        activeColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        checkColor: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'ตามวันที่',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyLargeFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyLargeIsCustom,
                                            ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ),
                            ),
                            if (_model.checkboxValue1 == true)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: FlutterFlowCalendar(
                                  color: FlutterFlowTheme.of(context).primary,
                                  iconColor: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  weekFormat: false,
                                  weekStartsMonday: false,
                                  rowHeight: 36.0,
                                  onChange: (DateTimeRange? newSelectedDate) {
                                    safeSetState(() => _model
                                        .calendarSelectedDay = newSelectedDate);
                                  },
                                  titleStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .titleSmallFamily,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .titleSmallIsCustom,
                                      ),
                                  dayOfWeekStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .labelSmallFamily,
                                        fontSize: 10.0,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .labelSmallIsCustom,
                                      ),
                                  dateStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: FlutterFlowTheme.of(context)
                                            .bodySmallFamily,
                                        letterSpacing: 0.0,
                                        useGoogleFonts:
                                            !FlutterFlowTheme.of(context)
                                                .bodySmallIsCustom,
                                      ),
                                  selectedDateStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmallFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodySmallIsCustom,
                                          ),
                                  inactiveDateStyle:
                                      FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmallFamily,
                                            color: Color(0x98465054),
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .labelSmallIsCustom,
                                          ),
                                ),
                              ),
                            Divider(
                              height: 1.0,
                              thickness: 1.0,
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                safeSetState(() {
                                  _model.checkboxValue2 = true;
                                });
                                safeSetState(() {
                                  _model.checkboxValue1 = false;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
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
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Theme(
                                      data: ThemeData(
                                        checkboxTheme: CheckboxThemeData(
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          shape: CircleBorder(),
                                        ),
                                        unselectedWidgetColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                      ),
                                      child: Checkbox(
                                        value: _model.checkboxValue2 ??= false,
                                        onChanged: (newValue) async {
                                          safeSetState(() => _model
                                              .checkboxValue2 = newValue!);
                                          if (newValue!) {
                                            safeSetState(() {
                                              _model.checkboxValue1 = false;
                                            });
                                          }
                                        },
                                        side: (FlutterFlowTheme.of(context)
                                                    .alternate !=
                                                null)
                                            ? BorderSide(
                                                width: 2,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate!,
                                              )
                                            : null,
                                        activeColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        checkColor: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'แสดงทั้งหมด',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontFamily:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyLargeFamily,
                                              letterSpacing: 0.0,
                                              useGoogleFonts:
                                                  !FlutterFlowTheme.of(context)
                                                      .bodyLargeIsCustom,
                                            ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ),
                    ),
                  ].divide(SizedBox(height: () {
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
                  }())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
