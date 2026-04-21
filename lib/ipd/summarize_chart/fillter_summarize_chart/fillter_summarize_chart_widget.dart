import '/dsign_system/from_field/date_picker/date_picker_widget.dart';
import '/dsign_system/from_field/dropdown/dropdown_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/appiontment/buttonsheet_department/buttonsheet_department_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'fillter_summarize_chart_model.dart';
export 'fillter_summarize_chart_model.dart';

class FillterSummarizeChartWidget extends StatefulWidget {
  const FillterSummarizeChartWidget({super.key});

  @override
  State<FillterSummarizeChartWidget> createState() =>
      _FillterSummarizeChartWidgetState();
}

class _FillterSummarizeChartWidgetState
    extends State<FillterSummarizeChartWidget> {
  late FillterSummarizeChartModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FillterSummarizeChartModel());

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
            return 450.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
            return 450.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
            return 550.0;
          } else {
            return 550.0;
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
                            Column(
                              mainAxisSize: MainAxisSize.max,
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
                                          colors: [
                                            FlutterFlowTheme.of(context)
                                                .customColor7,
                                            FlutterFlowTheme.of(context)
                                                .customColor8
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: FaIcon(
                                          FontAwesomeIcons.solidHospital,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 8.0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'ตึกผู้ป่วยใน',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmallFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .labelSmallIsCustom,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      isDismissible: false,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: ButtonsheetDepartmentWidget(),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: wrapWithModel(
                                    model: _model.dropdownModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: DropdownWidget(),
                                  ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
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
                                          colors: [
                                            FlutterFlowTheme.of(context)
                                                .customColor5,
                                            FlutterFlowTheme.of(context)
                                                .customColor6
                                          ],
                                          stops: [0.0, 1.0],
                                          begin:
                                              AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: FaIcon(
                                          FontAwesomeIcons.userMd,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          size: 10.0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'แพทย์ผู้สั่งจำหน่าย',
                                      style: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmallFamily,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .labelSmallIsCustom,
                                          ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                                wrapWithModel(
                                  model: _model.dropdownModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: DropdownWidget(),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20.0,
                                          height: 20.0,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                FlutterFlowTheme.of(context)
                                                    .accent2,
                                                FlutterFlowTheme.of(context)
                                                    .accent1
                                              ],
                                              stops: [0.0, 1.0],
                                              begin: AlignmentDirectional(
                                                  0.0, -1.0),
                                              end: AlignmentDirectional(0, 1.0),
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Icon(
                                              Icons.calendar_month_rounded,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              size: 10.0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'ช่วงวันที่จำหน่าย',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                fontFamily:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmallFamily,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts:
                                                    !FlutterFlowTheme.of(
                                                            context)
                                                        .labelSmallIsCustom,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 8.0)),
                                    ),
                                  ],
                                ),
                                wrapWithModel(
                                  model: _model.datePickerModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: DatePickerWidget(
                                    textlabel: 'วันที่',
                                  ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                          ].divide(SizedBox(height: 12.0)),
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
