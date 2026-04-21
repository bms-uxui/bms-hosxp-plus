import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ipd/widget/item_department_i1/item_department_i1_widget.dart';
import '/ipd/widget/item_department_i10/item_department_i10_widget.dart';
import '/ipd/widget/item_department_i11/item_department_i11_widget.dart';
import '/ipd/widget/item_department_i2/item_department_i2_widget.dart';
import '/ipd/widget/item_department_i3/item_department_i3_widget.dart';
import '/ipd/widget/item_department_i4/item_department_i4_widget.dart';
import '/ipd/widget/item_department_i5/item_department_i5_widget.dart';
import '/ipd/widget/item_department_i6/item_department_i6_widget.dart';
import '/ipd/widget/item_department_i7/item_department_i7_widget.dart';
import '/ipd/widget/item_department_i8/item_department_i8_widget.dart';
import '/ipd/widget/item_department_i9/item_department_i9_widget.dart';
import '/main/widget/icon_title/icon_title_widget.dart';
import '/opd/widget/i_c_d10_treatment_o_p_d/i_c_d10_treatment_o_p_d_widget.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'treat_i_p_dpage_model.dart';
export 'treat_i_p_dpage_model.dart';

class TreatIPDpageWidget extends StatefulWidget {
  const TreatIPDpageWidget({super.key});

  @override
  State<TreatIPDpageWidget> createState() => _TreatIPDpageWidgetState();
}

class _TreatIPDpageWidgetState extends State<TreatIPDpageWidget> {
  late TreatIPDpageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TreatIPDpageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wrapWithModel(
                model: _model.iconTitleModel,
                updateCallback: () => safeSetState(() {}),
                child: IconTitleWidget(
                  titletext: 'ข้อมูลการรับบริการผู้ป่วยใน',
                  icon: FaIcon(
                    FontAwesomeIcons.procedures,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    size: 10.0,
                  ),
                  color1: FlutterFlowTheme.of(context).accent2,
                  color2: FlutterFlowTheme.of(context).accent1,
                ),
              ),
              Text(
                '23 พฤษภาคม 2568',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      fontFamily: FlutterFlowTheme.of(context).labelSmallFamily,
                      letterSpacing: 0.0,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).labelSmallIsCustom,
                    ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(valueOrDefault<double>(
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
                    0.0,
                  )),
                  child: MasonryGridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: () {
                        if (MediaQuery.sizeOf(context).width <
                            kBreakpointSmall) {
                          return 1;
                        } else if (MediaQuery.sizeOf(context).width <
                            kBreakpointMedium) {
                          return 1;
                        } else if (MediaQuery.sizeOf(context).width <
                            kBreakpointLarge) {
                          return 2;
                        } else {
                          return 2;
                        }
                      }(),
                    ),
                    crossAxisSpacing: () {
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
                    mainAxisSpacing: () {
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
                    itemCount: 2,
                    padding: EdgeInsets.fromLTRB(
                      0,
                      0,
                      0,
                      0,
                    ),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return [
                        () => Container(
                              width: double.infinity,
                              height: () {
                                if (MediaQuery.sizeOf(context).width <
                                    kBreakpointSmall) {
                                  return 250.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointMedium) {
                                  return 250.0;
                                } else if (MediaQuery.sizeOf(context).width <
                                    kBreakpointLarge) {
                                  return 350.0;
                                } else {
                                  return 350.0;
                                }
                              }(),
                              decoration: BoxDecoration(
                                color: Color(0x80F1F4F8),
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(valueOrDefault<double>(
                                  () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'สถิติการรับบริการผู้ป่วยในจำแนกตามแผนก',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMediumFamily,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .bodyMediumIsCustom,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        () => Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0x1B3E83E6),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 16.0;
                                            } else {
                                              return 16.0;
                                            }
                                          }(),
                                          0.0,
                                        ),
                                        8.0,
                                        valueOrDefault<double>(
                                          () {
                                            if (MediaQuery.sizeOf(context)
                                                    .width <
                                                kBreakpointSmall) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointMedium) {
                                              return 12.0;
                                            } else if (MediaQuery.sizeOf(
                                                        context)
                                                    .width <
                                                kBreakpointLarge) {
                                              return 16.0;
                                            } else {
                                              return 16.0;
                                            }
                                          }(),
                                          0.0,
                                        ),
                                        8.0),
                                    child: Text(
                                      'รวม 520 คน',
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmallFamily,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            letterSpacing: 0.0,
                                            useGoogleFonts:
                                                !FlutterFlowTheme.of(context)
                                                    .titleSmallIsCustom,
                                          ),
                                    ),
                                  ),
                                ),
                                MasonryGridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: () {
                                    if (MediaQuery.sizeOf(context).width <
                                        kBreakpointSmall) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointMedium) {
                                      return 12.0;
                                    } else if (MediaQuery.sizeOf(context)
                                            .width <
                                        kBreakpointLarge) {
                                      return 16.0;
                                    } else {
                                      return 16.0;
                                    }
                                  }(),
                                  itemCount: 10,
                                  padding: EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    0,
                                  ),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return [
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF7DDCEB),
                                                      Color(0xFF55AFBD)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '120',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'อายุรกรรม',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF7AC1ED),
                                                      Color(0xFF4396D0)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '91',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'ศัลยกรรม',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF4A97DE),
                                                      Color(0xFF2C6CB1)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '89',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'สูติกรรม',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF7A8DE5),
                                                      Color(0xFF2E408D)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '70',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'กุมารเวชกรรม',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF806EB3),
                                                      Color(0xFF4F3C8B)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '40',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'โสต ศอ นาสิก',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFFC876BA),
                                                      Color(0xFF8D328F)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '30',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'จิตเวช',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFFE58CAC),
                                                      Color(0xFFD64162)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '30',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'แพทย์แผนไทย',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFFF5A95F),
                                                      Color(0xFFE06637)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '20',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'ศัลยกรรมประสาท',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFFF4BA1F),
                                                      Color(0xFFC39006)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '15',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'เวชกรรมสังคม',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                      () => Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFFA9CB58),
                                                      Color(0xFF67972B)
                                                    ],
                                                    stops: [0.0, 1.0],
                                                    begin: AlignmentDirectional(
                                                        0.0, -1.0),
                                                    end: AlignmentDirectional(
                                                        0, 1.0),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: AutoSizeText(
                                                    '10',
                                                    maxLines: 1,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodySmall
                                                        .override(
                                                          fontFamily:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmallFamily,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          shadows: [
                                                            Shadow(
                                                              color: Color(
                                                                  0x3257636C),
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              blurRadius: 2.0,
                                                            )
                                                          ],
                                                          useGoogleFonts:
                                                              !FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmallIsCustom,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'กายอุปกรณ์ (นักกายอุปกรณ์)',
                                                  style:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumFamily,
                                                            letterSpacing: 0.0,
                                                            useGoogleFonts:
                                                                !FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMediumIsCustom,
                                                          ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12.0)),
                                          ),
                                    ][index]();
                                  },
                                ),
                              ].divide(SizedBox(height: () {
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
                              }())),
                            ),
                      ][index]();
                    },
                  ),
                ),
              ),
            ].divide(SizedBox(height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 12.0;
              } else {
                return 12.0;
              }
            }())),
          ),
          wrapWithModel(
            model: _model.iCD10TreatmentOPDModel,
            updateCallback: () => safeSetState(() {}),
            child: ICD10TreatmentOPDWidget(),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'แผนกผู้ป่วยใน',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      useGoogleFonts:
                          !FlutterFlowTheme.of(context).bodyLargeIsCustom,
                    ),
              ),
              MasonryGridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: () {
                    if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                      return 2;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointMedium) {
                      return 2;
                    } else if (MediaQuery.sizeOf(context).width <
                        kBreakpointLarge) {
                      return 3;
                    } else {
                      return 3;
                    }
                  }(),
                ),
                crossAxisSpacing: () {
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
                mainAxisSpacing: () {
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
                itemCount: 11,
                padding: EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  0,
                ),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return [
                    () => wrapWithModel(
                          model: _model.itemDepartmentI1Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI1Widget(
                            name: 'อายุรกรรม',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI2Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI2Widget(
                            name: 'ศัลยกรรม',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI3Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI3Widget(
                            name: 'สูติกรรม',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI4Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI4Widget(
                            name: 'กุมารเวชกรรม',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI5Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI5Widget(
                            name: 'โสต ศอ นาสิก',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI6Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI6Widget(
                            name: 'จิตเวช',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI7Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI7Widget(
                            name: 'แพทย์แผนไทย',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI8Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI8Widget(
                            name: 'ศัลยกรรมประสาท',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI9Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI9Widget(
                            name: 'เวชกรรมสังคม',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI10Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI10Widget(
                            name: 'กายอุปกรณ์ (นักกายอุปกรณ์)',
                          ),
                        ),
                    () => wrapWithModel(
                          model: _model.itemDepartmentI11Model,
                          updateCallback: () => safeSetState(() {}),
                          child: ItemDepartmentI11Widget(
                            name: 'อื่นๆ',
                          ),
                        ),
                  ][index]();
                },
              ),
            ].divide(SizedBox(height: () {
              if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
                return 8.0;
              } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
                return 12.0;
              } else {
                return 12.0;
              }
            }())),
          ),
        ].divide(SizedBox(height: () {
          if (MediaQuery.sizeOf(context).width < kBreakpointSmall) {
            return 12.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointMedium) {
            return 12.0;
          } else if (MediaQuery.sizeOf(context).width < kBreakpointLarge) {
            return 16.0;
          } else {
            return 16.0;
          }
        }())),
      ),
    );
  }
}
