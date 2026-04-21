import '/dsign_system/button_styles/icon_button_tertiary/icon_button_tertiary_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'fillter_organ_donation_model.dart';
export 'fillter_organ_donation_model.dart';

class FillterOrganDonationWidget extends StatefulWidget {
  const FillterOrganDonationWidget({super.key});

  @override
  State<FillterOrganDonationWidget> createState() =>
      _FillterOrganDonationWidgetState();
}

class _FillterOrganDonationWidgetState
    extends State<FillterOrganDonationWidget> {
  late FillterOrganDonationModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FillterOrganDonationModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: wrapWithModel(
                      model: _model.iconButtonTertiaryModel,
                      updateCallback: () => safeSetState(() {}),
                      child: IconButtonTertiaryWidget(
                        iconbuttontertiary: Icon(
                          Icons.close_rounded,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 16.0,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
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
                                FFAppState().filterdonorssignature =
                                    'แสดงทั้งหมด';
                                safeSetState(() {});
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 56.0;
                                  } else {
                                    return 56.0;
                                  }
                                }(),
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 18.0,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            FFAppState().filterdonorssignature ==
                                                    'แสดงทั้งหมด'
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Container(
                                          width: 100.0,
                                          height: 100.0,
                                          decoration: BoxDecoration(
                                            color: valueOrDefault<Color>(
                                              FFAppState().filterdonorssignature ==
                                                      'แสดงทั้งหมด'
                                                  ? FlutterFlowTheme.of(context)
                                                      .primary
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
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
                                  ].divide(SizedBox(width: 8.0)),
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
                                FFAppState().filterdonorssignature =
                                    'ยังไม่ได้เจรจา';
                                safeSetState(() {});
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 56.0;
                                  } else {
                                    return 56.0;
                                  }
                                }(),
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 18.0,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            FFAppState().filterdonorssignature ==
                                                    'ยังไม่ได้เจรจา'
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Container(
                                          width: 100.0,
                                          height: 100.0,
                                          decoration: BoxDecoration(
                                            color: valueOrDefault<Color>(
                                              FFAppState().filterdonorssignature ==
                                                      'ยังไม่ได้เจรจา'
                                                  ? FlutterFlowTheme.of(context)
                                                      .primary
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'ยังไม่ได้เจรจา',
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
                                  ].divide(SizedBox(width: 8.0)),
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
                                FFAppState().filterdonorssignature =
                                    'เจรจาสำเร็จ';
                                safeSetState(() {});
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 56.0;
                                  } else {
                                    return 56.0;
                                  }
                                }(),
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 18.0,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            FFAppState().filterdonorssignature ==
                                                    'เจรจาสำเร็จ'
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Container(
                                          width: 100.0,
                                          height: 100.0,
                                          decoration: BoxDecoration(
                                            color: valueOrDefault<Color>(
                                              FFAppState().filterdonorssignature ==
                                                      'เจรจาสำเร็จ'
                                                  ? FlutterFlowTheme.of(context)
                                                      .primary
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'เจรจาสำเร็จ',
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
                                  ].divide(SizedBox(width: 8.0)),
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
                                FFAppState().filterdonorssignature =
                                    'ไม่ได้รับการยินยอม';
                                safeSetState(() {});
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height: () {
                                  if (MediaQuery.sizeOf(context).width <
                                      kBreakpointSmall) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointMedium) {
                                    return 48.0;
                                  } else if (MediaQuery.sizeOf(context).width <
                                      kBreakpointLarge) {
                                    return 56.0;
                                  } else {
                                    return 56.0;
                                  }
                                }(),
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 18.0,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: valueOrDefault<Color>(
                                            FFAppState().filterdonorssignature ==
                                                    'ไม่ได้รับการยินยอม'
                                                ? FlutterFlowTheme.of(context)
                                                    .primary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            FlutterFlowTheme.of(context)
                                                .secondaryText,
                                          ),
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Container(
                                          width: 100.0,
                                          height: 100.0,
                                          decoration: BoxDecoration(
                                            color: valueOrDefault<Color>(
                                              FFAppState().filterdonorssignature ==
                                                      'ไม่ได้รับการยินยอม'
                                                  ? FlutterFlowTheme.of(context)
                                                      .primary
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                          AlignmentDirectional(-1.0, 0.0),
                                      child: Text(
                                        'ไม่ได้รับการยินยอม',
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
                                  ].divide(SizedBox(width: 8.0)),
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
